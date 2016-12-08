// ---------------------------------------------------------------------------
// -- Drago -- Abstract board (rules, no display) ------------ UGoBoard.pas --
// ---------------------------------------------------------------------------

unit UGoBoard;

// ---------------------------------------------------------------------------

interface

uses 
  Define;

type

  TChain = record
    n : integer;
    i, j : array[1 .. 361] of byte
  end;

  THistoRec = record
    i, j, x, n : integer
  end;

  TGoBoard = class
  public
    BoardSize  : integer;
    MoveNumber : integer;
    Board      : array[0 .. 20, 0 .. 20] of byte;
    TabNum     : array[1 .. 19, 1 .. 19] of integer;
    prisoner   : array[Black .. White] of integer;

    constructor Create;
    destructor  Destroy; override;
    procedure   Assign(gb : TGoBoard);

    procedure Clear;
    procedure Setup       (i, j, inter : integer; var status : integer);
    procedure Remove      (var i, j, inter : integer);
    procedure Play        (i, j, col  : integer;
                           var prisos : TChain;
                           var status : integer);
    procedure Undo        (var i, j, col : integer;
                           var prisos : TChain;
                           var status : integer);
    function  IsLastMove  (i, j : integer) : boolean;
    function  IsValid     (i, j, color : integer; var status : integer) : boolean;
    function  IsBoardCoord(i, j : integer) : boolean;
    function  JustCaptured : boolean;
    procedure GetMovePosition (num : integer; var i, j : integer);

  private
    History  : array of THistoRec;
    TopHisto : integer;
    procedure Push             (ai, aj, ax : integer; an : integer = 0);
    procedure Pop              (var ai, aj, ax : integer);
    function  LegalKoCapture   (ii, jj : integer; var prisos : TChain) : boolean;
    procedure MakeChain        (i, j : integer; var ch : TChain);
    procedure CaptureNeighbours(i, j : integer; var prisos : TChain);
    procedure CaptureChain     (i, j : integer; var prisos : TChain);
    function  IsCaptured       (i, j : integer) : boolean;
    function  IsChainCaptured  (var ch : TChain) : boolean;
    procedure AddStoneToChain  (i, j, col : integer; var ch : TChain);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std;

// -- Public -----------------------------------------------------------------
// ---------------------------------------------------------------------------

// -- Constructor and destructor ---------------------------------------------

constructor TGoBoard.Create;
begin
  BoardSize := 19;
  Clear
end;

destructor TGoBoard.Destroy;
begin
  inherited Destroy
end;

// -- Copy -------------------------------------------------------------------

procedure TGoBoard.Assign(gb : TGoBoard);
var
  i, j : integer;
begin
  BoardSize  := gb.BoardSize;
  MoveNumber := gb.MoveNumber;
  for i := 1 to 19 do
    for j := 1 to 19 do
      begin
        Board [i, j] := gb.Board [i, j];
        TabNum[i, j] := gb.TabNum[i, j]
      end;
  prisoner[Black] := gb.prisoner[Black];
  prisoner[White] := gb.prisoner[White];
  TopHisto := gb.TopHisto;
  SetLength(History, 1 + TopHisto);
  for i := 1 to TopHisto do
    History[i] := gb.History[i]
end;

// -- Reset board ------------------------------------------------------------

procedure TGoBoard.Clear;
var
  i : integer;
begin
  fillchar(Board , sizeof(Board) , Empty);
  fillchar(TabNum, sizeof(TabNum), 0);
  TopHisto := 0;
  SetLength(History, 256);
  prisoner[black] := 0;
  prisoner[white] := 0;
  MoveNumber := 0;

  for i := 0 to BoardSize + 1 do
    begin
      Board[            0, i] := 255;
      Board[BoardSize + 1, i] := 255;
      Board[i,             0] := 255;
      Board[i, BoardSize + 1] := 255
     end
end;

// -- Add and remove setup stones --------------------------------------------

procedure TGoBoard.Setup(i, j, inter : integer; var status : integer);
begin
  if not IsBoardCoord(i, j)
    then status := CgbPass
    else
      begin
        status := CgbOk;
        Push(i, j, Board[i, j]);
        Board[i, j] := inter;
        TabNum[i, j] := 0
      end
end;

procedure TGoBoard.Remove(var i, j, inter : integer);
begin
  Pop(i, j, inter)
end;

// -- Play a move ------------------------------------------------------------

procedure TGoBoard.Play(i, j, col  : integer;
                        var prisos : TChain;
                        var status : integer);
var
  k, ii, jj : integer;
begin
  // test if coordinates are valid
  if not IsBoardCoord(i, j) then
    begin
      status := CgbPass;
      exit
    end;

  // undo (even for an invalid move) will decrement move number and pop
  // something. So invalid move increment move number and push empty record.
  inc(MoveNumber);

  // test if intersection is free
  if Board[i, j] <> Empty then
    begin
      status := CgbUnfree;
      Push(0, 0, 0);
      exit
    end;

  // put stone on board and possibly remove prisoners
  Board[i, j] := col;
  CaptureNeighbours(i, j, prisos);

  // test for suicide
  if IsCaptured(i, j) then
    begin
      Board[i, j] := Empty;                       // remove illegal move
      assert(prisos.n = 0);                       // no prisoners to restore
      status := CgbSuicide;
      Push(0, 0, 0);
      exit
    end;

  // test for ko
  if LegalKoCapture(i, j, prisos) then
    begin
      Board[i, j] := Empty;                       // remove illegal move
      with prisos do
        Board[i[1], j[1]] := ReverseColor(col);   // put back prisoner
      status := CgbKo;
      push(0, 0, 0);
      exit
    end;

  status := CgbOk;

  inc(prisoner[ReverseColor(col)], prisos.n);
  Push(i, j, Empty);
  TabNum[i, j] := MoveNumber;

  for k := 1 to prisos.n do
    begin
      ii := prisos.i[k];
      jj := prisos.j[k];
      Push(ii, jj, ReverseColor(col), TabNum[ii, jj]);
      TabNum[ii, jj] := 0
    end
end;

// -- Undo a move ------------------------------------------------------------

procedure TGoBoard.Undo(var i, j, col : integer;
                        var prisos : TChain;
                        var status : integer);
var
  tmp : integer;
begin
  if TopHisto <= 0
    then status := CgbNoUndo
    else
      begin
        status := CgbOk;
        dec(MoveNumber);
        prisos.n := 0;

        while (TopHisto > 0) and (History[TopHisto].x <> 0) do
          begin
            Pop(i, j, col);
            inc(prisos.n);
            prisos.i[prisos.n] := i;
            prisos.j[prisos.n] := j;
            dec(prisoner[col])
          end;

        Pop(i, j, tmp);
        col := ReverseColor(col)
      end
end;

// -- Predicates -------------------------------------------------------------

// Are coordinates valid?

function  TGoBoard.IsBoardCoord(i, j : integer) : boolean;
begin
  Result := Within(i, 1, BoardSize) and Within(j, 1, BoardSize)
end;

// Is it the last move?

function TGoBoard.IsLastMove(i, j : integer) : boolean;
begin
  Result := TabNum[i, j] = MoveNumber
end;

// Is it a valid move?

function TGoBoard.IsValid(i, j, color : integer; var status : integer) : boolean;
var
  prisoners : TChain;
  status2 : integer;
begin
  Play(i, j, color, prisoners, status);
  if status <> CgbPass
    then Undo(i, j, color, prisoners, status2);

  Result := status in [CgbOk, CgbPass]
end;

// Has the last move captured something?

function TGoBoard.JustCaptured : boolean;
begin
  Result := History[TopHisto].x <> Empty
end;

// -- Privates ---------------------------------------------------------------
// ---------------------------------------------------------------------------

// -- Push and pop in history stack ------------------------------------------

procedure TGoBoard.Push(ai, aj, ax : integer; an : integer = 0);
begin
  inc(TopHisto);

  if TopHisto > High(History)
    then SetLength(History, 2 * Length(History));
    
  with History[TopHisto] do
    begin
      i := ai;
      j := aj;
      x := ax;
      n := an 
    end
end;

procedure TGoBoard.Pop(var ai, aj, ax : integer);
begin
  with History[TopHisto] do
    begin
      ai := i;
      aj := j;
      ax := x;
      if ai > 0 then
        begin
          Board [ai, aj] := x;
          TabNum[ai, aj] := n
        end
    end;
  dec(TopHisto)
end;

// -- Construction of the chain associated to an intersection ----------------
//
// -- Mark: add 128, unmark: decrease by 128

procedure TGoBoard.MakeChain(i, j : integer; var ch : TChain);
var
  k : integer;
begin
  ch.n := 0;
  AddStoneToChain(i, j, Board[i, j], ch);
  for k := 1 to ch.n do
    dec(Board[ch.i[k], ch.j[k]], 128)
end;

procedure TGoBoard.AddStoneToChain(i, j, col : integer; var ch : TChain);
begin
  inc(ch.n);
  ch.i[ch.n] := i;
  ch.j[ch.n] := j;
  inc(Board[i, j], 128);

  if Board[i - 1, j] = col then AddStoneToChain(i - 1, j, col, ch);
  if Board[i + 1, j] = col then AddStoneToChain(i + 1, j, col, ch);
  if Board[i, j - 1] = col then AddStoneToChain(i, j - 1, col, ch);
  if Board[i, j + 1] = col then AddStoneToChain(i, j + 1, col, ch)
end;

// -- Test if a chain is captured --------------------------------------------

function TGoBoard.IsChainCaptured(var ch : TChain) : boolean;
var
  k, i, j : integer;
begin
  Result := False;

  for k := 1 to ch.n do
    begin
      i := ch.i[k];
      j := ch.j[k];
      if (Board[i - 1, j] = Empty) or
         (Board[i + 1, j] = Empty) or
         (Board[i, j - 1] = Empty) or
         (Board[i, j + 1] = Empty) then exit
    end;

  Result := True
end;

// -- Possible capture of neighbours -----------------------------------------

procedure TGoBoard.CaptureNeighbours(i, j : integer; var prisos : TChain);
var
  col : integer;
begin
  prisos.n := 0;
  col := ReverseColor(Board[i, j]);

  if Board[i - 1, j] = col then CaptureChain(i - 1, j, prisos);
  if Board[i + 1, j] = col then CaptureChain(i + 1, j, prisos);
  if Board[i, j - 1] = col then CaptureChain(i, j - 1, prisos);
  if Board[i, j + 1] = col then CaptureChain(i, j + 1, prisos)
end;

procedure TGoBoard.CaptureChain(i, j : integer; var prisos : TChain);
var
  ch : TChain;
  k  : integer;
begin
  MakeChain(i, j, ch);

  if IsChainCaptured(ch) then
    begin
      for k := 1 to ch.n do
        begin
          inc(prisos.n);
          prisos.i[prisos.n] := ch.i[k];
          prisos.j[prisos.n] := ch.j[k];
          Board[ch.i[k]][ch.j[k]] := empty
        end
    end
end;

// -- Test for capture -------------------------------------------------------

function TGoBoard.IsCaptured(i, j : integer) : boolean;
var
  ch : TChain;
begin
  MakeChain(i, j, ch);
  Result := IsChainCaptured(ch)
end;

// -- Test for ko capture ----------------------------------------------------

function TGoBoard.LegalKoCapture(ii, jj : integer; var prisos : TChain) : boolean;
begin
  Result := False;

  if prisos.n <> 1                   // move must make a single prisoner
    then exit;
  if TopHisto < 2
    then exit;                       // be sure there is at least two moves

  with History[TopHisto] do
    Result := (x <> Empty)       and // move -1 made at least one prisoner
              (ii = i)           and // current move is at prisoner coordinates
              (jj = j);
  with History[TopHisto - 1] do
    Result := Result             and
              (x = Empty)        and // there is a single prisoner
              (prisos.i[1] = i)  and
              (prisos.j[1] = j)      // move -1 is captured
end;

// ---------------------------------------------------------------------------

procedure TGoBoard.GetMovePosition(num : integer; var i, j : integer);
var
  ii, jj : integer;
begin
  for ii := 1 to BoardSize do
    for jj := 1 to BoardSize do
      if TabNum[ii, jj] = num then
        begin
          i := ii;
          j := jj;
          exit
        end;

  // move not found
  i := 0;
  j := 0
end;

end.
