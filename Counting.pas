// ---------------------------------------------------------------------------
// -- Drago -- Territory and area counting ------------------- Counting.pas --
// ---------------------------------------------------------------------------

unit Counting;

// ---------------------------------------------------------------------------

interface

uses
  Define, DefineUi, UGoban;

procedure TerritoryCounting(gb : TGoban;
                            const dead : string;
                            nBlackPrisoners, nWhitePrisoners : integer;
                            out sTB, sTW, sgfResult, detailedResult : string);
procedure AreaCounting(gb : TGoban;
                       const dead : string;
                       out sTB, sTW, sgfResult, detailedResult : string);

function KomiValue(scoring : TScoring; handicap : integer; komiHandicap0 : double) : double; overload;
function KomiValue : double; overload;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Ux2y, UStatus;

// -- Forwards ---------------------------------------------------------------

procedure FindTerritories(gb : TGoban;
                          const dead, livingBlack, livingWhite : string;
                          out sTB, sTW : string); forward;
procedure UpdatePrisoners(gb : TGoban;
                          const dead : string;
                          var nBlackPrisoners, nWhitePrisoners : integer); forward;
procedure LivingStones   (gb : TGoban;
                          const dead : string;
                          out livingBlack, livingWhite : string); forward;

// -- Calculate komi value ---------------------------------------------------

function KomiValue(scoring : TScoring; handicap : integer; komiHandicap0 : double) : double;
begin
  case scoring of
    scJapanese :
      case handicap of
        0  : Result := komiHandicap0;
        1  : Result := 0.5
        else Result := 0.5
      end;
    scChinese :
      case handicap of
        0  : Result := komiHandicap0;
        1  : Result := 0.5
        else Result := handicap + 0.5
      end;
    scAGA :
      case handicap of
        0  : Result := komiHandicap0;
        1  : Result := 0.5
        else Result := handicap - 0.5
      end;
    else
      begin
        assert(False);
        Result := 0.5
      end
  end
end;

function KomiValue : double;
begin
  Result := KomiValue(Settings.PlScoring, Settings.Handicap, Settings.Komi)
end;

// -- Working data -----------------------------------------------------------

var
  IsDead      : array[1 .. 19, 1 .. 19] of boolean;
  IsTerritory : array[1 .. 19, 1 .. 19] of integer; //0: not, 1: B, 2: W

// -- Territory counting(free intersections + prisoners) --------------------

function FormatResult(player : string; val : double) : string;
var
  settings : TFormatSettings;
begin
  settings.DecimalSeparator := '.';
  Result := Format('%s+%1.1f', [player, val], settings)
end;

procedure TerritoryCounting(gb : TGoban;
                            const dead : string;
                            nBlackPrisoners, nWhitePrisoners : integer;
                            out sTB, sTW, sgfResult, detailedResult : string);
var
  livingBlack, livingWhite : string;
  tB, tW : integer;
  komi, scoreBlack, scoreWhite : real;
begin
  komi := KomiValue;

  LivingStones   (gb, dead, livingBlack, livingWhite);
  FindTerritories(gb, dead, livingBlack, livingWhite, sTB, sTW);
  UpdatePrisoners(gb, dead, nBlackPrisoners, nWhitePrisoners);

  tB := Length(sTB) div 4;
  tW := Length(sTW) div 4;

  scoreBlack := tB + nWhitePrisoners;
  scoreWhite := tW + nBlackPrisoners + komi;
(*
  DecimalSeparator := '.';
  if scoreBlack > scoreWhite
    then sgfResult := Format('B+%1.1f', [scoreBlack - scoreWhite])
    else sgfResult := Format('W+%1.1f', [scoreWhite - scoreBlack]);
*)
  if scoreBlack > scoreWhite
    then sgfResult := FormatResult('B', scoreBlack - scoreWhite)
    else sgfResult := FormatResult('W', scoreWhite - scoreBlack);

  detailedResult := Format('[%d:%d:%d:%d:%1.1f:%1.0f:%1.1f:%s]',
                           [tB, tW, nWhitePrisoners, nBlackPrisoners,
                            komi,
                            scoreBlack,
                            scoreWhite,
                            sgfResult])
end;

// -- Area  counting (free intersection + friend stones) ---------------------

procedure AreaCounting(gb : TGoban;
                       const dead : string;
                       out sTB, sTW, sgfResult, detailedResult : string);
var
  livingBlack, livingWhite : string;
  sB, sW, tB, tW : integer;
  komi, scoreBlack, scoreWhite : real;
begin
  komi := KomiValue;

  LivingStones(gb, dead, livingBlack, livingWhite);
  FindTerritories(gb, dead, livingBlack, livingWhite, sTB, sTW);

  sB := Length(livingBlack) div 2;
  sW := Length(livingWhite) div 2;
  tB := Length(sTB) div 4;
  tW := Length(sTW) div 4;

  scoreBlack := tB + sB;
  scoreWhite := tW + sW + komi;

  if scoreBlack > scoreWhite
    then sgfResult := FormatResult('B', scoreBlack - scoreWhite)
    else sgfResult := FormatResult('W', scoreWhite - scoreBlack);

  detailedResult := Format('[%d:%d:%d:%d:%1.1f:%1.0f:%1.1f:%s]',
                           [tB, tW, sB, sW,
                            komi,
                            scoreBlack,
                            scoreWhite,
                            sgfResult])
end;

// -- Search of living stones (including seki) from dead stones --------------

procedure LivingStones(gb : TGoban;
                       const dead : string;
                       out livingBlack, livingWhite : string);
var
  i, j, k : integer;
begin
  // mark dead stones
  fillchar(IsDead, sizeof(IsDead), False);
  k := 1;
  while k < Length(dead) do
    begin
      sgf2ij(Copy(dead, k, 2), i, j);
      inc(k, 2);

      IsDead[i, j] := True
    end;

  // search for living stones
  livingBlack := '';
  livingWhite := '';
  for i := 1 to gb.BoardSize do
    for j := 1 to gb.BoardSize do
      if (gb.Board[i, j] > 0) and (not IsDead[i, j])
        then
          if gb.Board[i, j] = 1
            then livingBlack := livingBlack + ij2sgf(i, j)
            else livingWhite := livingWhite + ij2sgf(i, j)
end;

// -- Counting of prisoners --------------------------------------------------
//
// Update the number of prisoners with prisoners on board game

procedure UpdatePrisoners(gb : TGoban;
                          const dead : string;
                          var nBlackPrisoners, nWhitePrisoners : integer);
var
  i, j, k : integer;
begin
  k := 1;
  while k < Length(dead) do
    begin
      sgf2ij(Copy(dead, k, 2), i, j);
      if gb.Board[i, j] = Black
        then inc(nBlackPrisoners)
        else inc(nWhitePrisoners);
      inc(k, 2)
    end
end;

// -- Recursive exploration of board -----------------------------------------

procedure Mark(gb : TGoban; i, j, c : integer);
begin
  if gb.Board[i, j] = 255
    then exit;
  if (gb.Board[i, j] <> Empty) and (not IsDead[i, j])
    then exit;
  if IsTerritory[i, j] = c
    then exit;
  if IsTerritory[i, j] = 3
    then exit;

  IsTerritory[i, j] := IsTerritory[i, j] + c;
  Mark(gb, i, j-1, c);
  Mark(gb, i, j+1, c);
  Mark(gb, i-1, j, c);
  Mark(gb, i+1, j, c);
end;

// -- Find territory ---------------------------------------------------------

procedure FindTerritories(gb : TGoban;
                          const dead, livingBlack, livingWhite : string;
                          out sTB, sTW : string);
var
  k, i, j, c : integer;
  alive : string;
begin
  alive := livingBlack + livingWhite;
  fillchar(IsTerritory, sizeof(IsTerritory), 0); // +1 TB, +2 TW, +3 both

  k := 1;
  while k < Length(alive) do
    begin
      sgf2ij(Copy(alive, k, 2), i, j);
      inc(k, 2);
      c := gb.Board[i, j];

      if IsTerritory[i, j] = c
        then continue;
      if IsTerritory[i, j] = 3
        then continue;

      IsTerritory[i, j] := IsTerritory[i, j] + c;
      Mark(gb, i, j-1, c);
      Mark(gb, i, j+1, c);
      Mark(gb, i-1, j, c);
      Mark(gb, i+1, j, c)
    end;

  sTB := '';
  sTW := '';
  for i := 1 to gb.BoardSize do
    for j := 1 to gb.BoardSize do
      case IsTerritory[i, j] of
        0 : ;                                 //
        1 : if gb.Board[i, j] <> 1
              then sTB := sTB + ij2pv(i, j);  // Black territory
        2 : if gb.Board[i, j] <> 2
              then sTW := sTW + ij2pv(i, j);  // White territory
        3 : ;                                 // seki/dame
      end
end;

// ---------------------------------------------------------------------------

end.
