// ---------------------------------------------------------------------------
// -- Drago -- Matching of pattern with board position -- UMatchPattern.pas --
// ---------------------------------------------------------------------------

unit UMatchPattern;

// ---------------------------------------------------------------------------

interface

uses
  UGoban, UKombilo;

procedure ShowSearchPattern(gb : TGoban; gl : TKGameList);

procedure MatchPattern(gb : TGoban;
                       patternType, left, top, right, bottom : integer; // anchor
                       sizeX, sizeY : integer;                // pattern
                       pattern : string;                      // "
                       var found : boolean;
                       var iFound, jFound, sizeFoundX, sizeFoundY : integer);

// ---------------------------------------------------------------------------

implementation

uses
  Define, Std, BoardUtils;

const
  BlackOrEmpty = 3;
  WhiteOrEmpty = 4;
  Any          = 5; 

type
  TPatMat = array[1 .. 19, 1 .. 19] of integer;

// -- Entry point ------------------------------------------------------------

procedure ShowSearchPattern(gb : TGoban; gl : TKGameList);
var
  found : boolean;
  iFound, jFound, sizeFoundX, sizeFoundY : integer;
begin
  MatchPattern(gb,
               gl.FPatternType,
               gl.FLeft, gl.FTop, gl.FRight, gl.FBottom,
               gl.LastSizeX, gl.LastSizeY, gl.LastPattern,
               found, iFound, jFound, sizeFoundX, sizeFoundY);

  if found
    then gb.Rectangle(iFound, jFound,
                      iFound  - 1 + sizeFoundY, jFound  - 1 + sizeFoundX,
                      True, 2)
end;

// -- Make pattern matrix from pattern string and symmetry -------------------

procedure MakePatternMatrix(sym : TCoordTrans;
                            sizeX, sizeY : integer;
                            pattern : string;
                            var sizePatX, sizePatY : integer;
                            var patMat : TPatMat);
var
  i, j, player, p, q : integer;
begin
  fillchar(patMat, SizeOf(patMat), Empty);

  for i := 1 to sizeY do
    for j := 1 to sizeX do
      begin
        case pattern[(i - 1) * sizeX + j] of
          'X' : player := Black; 
          'O' : player := White; 
          'x' : player := BlackOrEmpty;
          'o' : player := WhiteOrEmpty;
          '*' : player := Any;
          else continue
        end;
        Transform(i, j, sizeY, sizeX, sym, p, q);
        patMat[p, q] := player
      end;

  if sym in [trIdent, trRot180, trSymD90, trSymD270]
    then
      begin
        sizePatX := sizeX;
        sizePatY := sizeY
      end
    else
      begin
        sizePatX := sizeY;
        sizePatY := sizeX
      end
end;

// -- Test pattern matrix at position i0, j0 ---------------------------------

function CompPatternMatrix(gb : TGoban;
                           i0, j0 : integer;
                           sizePatX, sizePatY : integer;
                           patMat : TPatMat) : boolean;
var
  i, j, inter : integer;
begin
  Result := False;

  if not gb.IsBoardCoord(i0, j0)
    then exit;

  for i := 1 to sizePatY do
    for j := 1 to sizePatX do
      begin
        inter := gb.Board[i0 - 1 + i, j0 - 1 + j];
        (*
        if gb.Board[i0 - 1 + i, j0 - 1 + j] <> patMat[i, j]
          then exit;
        *)
        case patMat[i, j] of
          Empty : if inter <> Empty then exit;
          Black : if inter <> Black then exit;
          White : if inter <> White then exit;
          BlackOrEmpty : if not inter in [Black, Empty] then exit;
          WhiteOrEmpty : if not inter in [White, Empty] then exit;
          Any : ;
        end
      end;

  Result := True
end;

// -- Inversion of pattern ---------------------------------------------------

function InversePattern(pattern : string) : string;
var
  i : integer;
begin
  Result := '';
  SetLength(Result, Length(pattern));

  for i := 1 to Length(pattern) do
    case pattern[i] of
      'X' : Result[i] := 'O';
      'O' : Result[i] := 'X';
      'x' : Result[i] := 'o';
      'o' : Result[i] := 'x';
      '*' : Result[i] := '*'
      else  Result[i] := '.'
    end
end;

// -- Test a pattern string with all symmetries around reference intersection 
// -- NOT USED

procedure DoMatchPattern(gb : TGoban;
                         iRef, jRef : integer;
                         sizeX, sizeY : integer;
                         pattern : string;
                         var found : boolean;
                         var iFound, jFound, sizeFoundX, sizeFoundY : integer);
var
  patMat : TPatMat;
  sym : TCoordTrans;
  color, i, j, sizePatX, sizePatY : integer;
begin
  if gb.IsBoardCoord(iRef, jRef)
    then color := gb.Board[iRef, jRef]
    else color := Empty;

  for sym := trIdent to trSymD270 do
    begin
      MakePatternMatrix(sym, sizeX, sizeY, pattern, sizePatX, sizePatY, patMat);

      for i := 1 to sizePatY do
        for j := 1 to sizePatX do
          if patMat[i, j] = color then
            if CompPatternMatrix(gb, iRef - i + 1, jRef - j + 1,
                                     sizePatX, sizePatY, patMat)
              then
                begin
                  found := True;
                  iFound := iRef - i + 1;
                  jFound := jRef - j + 1;
                  sizeFoundX := sizePatX;
                  sizeFoundY := sizePatY;
                  exit
                end
    end;

  found := False
end;

// --

function TransPatternType(tr : TCoordTrans; patternType : integer) : integer;
const
  N = SIDE_N_PATTERN;
  E = SIDE_E_PATTERN;
  S = SIDE_S_PATTERN;
  W = SIDE_W_PATTERN;
  res : array[trIdent .. trSymD270, 0 .. 3] of integer
  = ((N, E, S, W), (E, S, W, N), (S, W, N, E), (W, N, E, S),
     (W, S, E, N), (N, W, S, E), (E, N, W, S), (S, E, N, W));
var
  j : integer;
begin
  case patternType of
    N : j := 0;
    E : j := 1;
    S : j := 2;
    W : j := 3
  end;
  Result := res[tr, j]
end;

// -- Test a pattern string with all symmetries on whole board ---------------

procedure DoMatchPatternBoard(gb : TGoban;
                              patternType, left, top, right, bottom : integer;
                              sizeX, sizeY : integer;
                              pattern : string;
                              var found : boolean;
                              var iFound, jFound, sizeFoundX, sizeFoundY : integer);
var
  patMat : TPatMat;
  sym : TCoordTrans;
  i, j, sizePatX, sizePatY, stepX, stepY, p1, q1, p2, q2 : integer;
  l, t, r, b : integer;
begin
  l := left;
  t := top;
  r := right;
  b := bottom;

  for sym := trIdent to trSymD270 do
    begin
      MakePatternMatrix(sym, sizeX, sizeY, pattern, sizePatX, sizePatY, patMat);

      case patternType of
        -1 :
          begin
            Assert((t = b) and (l = r));

            Transform(t, l, gb.BoardSize, sym, p1, q1);
            Transform(t + sizeY - 1, l + sizeX - 1, gb.BoardSize, sym, p2, q2);
            SortPair(p1, p2);
            SortPair(q1, q2);
            left   := q1;
            right  := q1 + 1;
            stepX  := gb.BoardSize;
            top    := p1;
            bottom := p1 + 1;
            stepY  := gb.BoardSize
          end;
        SIDE_N_PATTERN, SIDE_E_PATTERN,
        SIDE_S_PATTERN, SIDE_W_PATTERN :
          case TransPatternType(sym, patternType) of
            SIDE_N_PATTERN :
              begin
                top    := 1;
                bottom := top;
                stepY  := gb.BoardSize;
                left   := 2;
                right  := gb.BoardSize - sizePatX;
                stepX  := 1
              end;
            SIDE_S_PATTERN :
              begin
                top    := gb.BoardSize - sizePatY + 1;
                bottom := top;
                stepY  := gb.BoardSize;
                left   := 2;
                right  := gb.BoardSize - sizePatX;
                stepX  := 1
              end;
            SIDE_E_PATTERN :
              begin
                left   := gb.BoardSize - sizePatX + 1;
                right  := left;
                stepX  := gb.BoardSize ;
                top    := 2;
                bottom := gb.BoardSize - sizePatY;
                stepY  := 1
              end;
            SIDE_W_PATTERN :
              begin
                left   := 1;
                right  := left;
                stepX  := gb.BoardSize ;
                top    := 2;
                bottom := gb.BoardSize - sizePatY;
                stepY  := 1
              end;
          end;
        CENTER_PATTERN :
          begin
            left   := 1;
            right  := gb.BoardSize - sizePatX + 1;
            stepX  := 1;
            top    := 1;
            bottom := gb.BoardSize - sizePatY + 1;
            stepY  := 1;
          end;
        FULLBOARD_PATTERN :
          begin
            left   := 1;
            right  := gb.BoardSize;
            stepX  := 1;
            top    := 1;
            bottom := gb.BoardSize;
            stepY  := 1;
          end;
      end;

      i := top;
      while i <= bottom do
        begin
          j := left;
          while j <= right do
            begin
              if CompPatternMatrix(gb, i, j, sizePatX, sizePatY, patMat)
                then
                  begin
                    found := True;
                    iFound := i;
                    jFound := j;
                    sizeFoundX := sizePatX;
                    sizeFoundY := sizePatY;
                    exit
                  end;
              inc(j, stepX)
            end;
          inc(i, stepY)
        end
    end;

  found := False
end;

// -- Test a pattern around reference intersection with all symetries and colors

procedure MatchPattern(gb : TGoban;
                       patternType, left, top, right, bottom : integer; // anchor
                       sizeX, sizeY : integer;                // pattern
                       pattern : string;                      // "
                       var found : boolean;
                       var iFound, jFound, sizeFoundX, sizeFoundY : integer);
begin
  DoMatchPatternBoard(gb, patternType, left, top, right, bottom,
                      sizeX, sizeY, pattern,
                      found, iFound, jFound, sizeFoundX, sizeFoundY);

  if not found
    then DoMatchPatternBoard(gb, patternType, left, top, right, bottom,
                             sizeX, sizeY, InversePattern(pattern),
                             found, iFound, jFound, sizeFoundX, sizeFoundY);
end;

// -- Preliminary testing ----------------------------------------------------

procedure FindStoneRef(gb : TGoban;
                       i1, j1 : integer;
                       sizeX, sizeY : integer;
                       var iRef, jRef : integer);
var
  i, j : integer;
begin
  for i := i1 to i1 - 1 + sizeY do
    for j := j1 - 1 to j1 - 1 + sizeX do
      if gb.Board[i, j] = Black then
        begin
          iRef := i;
          jRef := j;
          exit
        end
end;

// ---------------------------------------------------------------------------

end.
