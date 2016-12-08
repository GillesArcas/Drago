// ---------------------------------------------------------------------------
// -- Drago -- Book like view ------------------------------ UBookBoard.pas --
// ---------------------------------------------------------------------------

unit UBookBoard;

// ---------------------------------------------------------------------------

interface

uses 
  Classes;

type

  TInterEvent = class
  private
    Color       : integer; // Black/White/Empty
    IsAMove     : boolean; // move or setup stone
    MoveNumber  : integer; // move number or last move number for setup stone
    CaptureMove : integer; // capturing move number
  public
    constructor Create(aColor : integer; aIsAMove : boolean; aNumber : integer);
  end;

  TOverMove = class
    MoveNumber : integer; // move played over a previous one
    RefMove    : integer; // reference move (numbered move in figure)
    RefLoc     : integer; // -1: undef, use coordinates
                          //  0: over reference move
                          //  1..4: move is played at East, North, West, South of ref move
    i, j       : integer; // coordinates if reference move not defined
  end;

  TBookBoard = class
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    procedure   Assign(source : TBookBoard);
    procedure   Play  (i, j, col, number : integer);
    procedure   Undo  (i, j : integer);
    procedure   Setup (i, j, col, number : integer);
    procedure   Remove(i, j : integer);
    procedure   Capture(i, j, number : integer);
    procedure   GiveBack(i, j : integer);
    procedure   BookBoard(i, j, figureMove : integer; var col, num : integer); overload;
    function    InterInFigure(i, j, figureMove : integer) : integer; overload;
    procedure   OverMoves(i, j, figureMove : integer; list : TList); overload;
    function    OverMoves(figureMove : integer) : TList; overload;
    function    OverMoveString(figureMove : integer) : string;
    function    StoneInFigure(i, j, figureMove : integer) : integer;
    function    NumberInFigure(i, j, figureMove : integer) : integer;
  private
    Board : array[1 .. 19, 1 .. 19] of TList;
    function    LastStone(i, j : integer) : TInterEvent;
    function    FindReference(i, j, figureMove : integer; stoneInFig : TInterEvent) : TOverMove;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  Define, Ux2y, Translate;

// -- Creation of intersection event -----------------------------------------

constructor TInterEvent.Create(aColor : integer; aIsAMove : boolean; aNumber : integer);
begin
  Color := aColor;
  IsAMove := aIsAMove;
  MoveNumber := aNumber;
  CaptureMove := -1
end;

// -- Creation and destruction -----------------------------------------------

constructor TBookBoard.Create;
var
  i, j : integer;
begin
  for i := 1 to 19 do
    for j := 1 to 19 do
      Board[i, j] := TList.Create
end;

destructor TBookBoard.Destroy;
var
  i, j : integer;
begin
  Clear;

  for i := 1 to 19 do
    for j := 1 to 19 do
      Board[i, j].Free;

  inherited
end;

// -- Clear board ------------------------------------------------------------

procedure TBookBoard.Clear;
var
  i, j, k : integer;
begin
  for i := 1 to 19 do
    for j := 1 to 19 do
      begin
        for k := 0 to Board[i, j].Count - 1 do
          TInterEvent(Board[i, j].Items[k]).Free;

        Board[i, j].Clear
      end
end;

// -- Copy -------------------------------------------------------------------

procedure TBookBoard.Assign(source : TBookBoard);
var
  i, j, k : integer;
  srcEvent, dstEvent : TInterEvent;
begin
  Clear;
  
  for i := 1 to 19 do
    for j := 1 to 19 do
      begin
        for k := 0 to source.Board[i, j].Count - 1 do
          begin
            srcEvent := TInterEvent(source.Board[i, j].Items[k]);
            dstEvent := TInterEvent.Create(srcEvent.Color, srcEvent.IsAMove,
                                           srcEvent.MoveNumber);
            dstEvent.CaptureMove := srcEvent.CaptureMove;
            Board[i, j].Add(dstEvent)
          end
      end
end;

// -- Operations on intersection ---------------------------------------------

procedure TBookBoard.Play(i, j, col, number : integer);
begin
  Board[i, j].Add(TInterEvent.Create(col, True, number))
end;

procedure TBookBoard.Undo(i, j : integer);
begin
  // test invalid move
  if (i = 0) or (j = 0)
    then exit;

  LastStone(i, j).Free;
  Board[i, j].Delete(Board[i, j].Count - 1)
end;

procedure TBookBoard.Setup(i, j, col, number : integer);
begin
  Board[i, j].Add(TInterEvent.Create(col, False, number))
end;

procedure TBookBoard.Remove(i, j : integer);
begin
  Undo(i, j)
end;

procedure TBookBoard.Capture(i, j, number : integer);
begin
  LastStone(i, j).CaptureMove := number
end;

procedure TBookBoard.GiveBack(i, j : integer);
begin
  LastStone(i, j).CaptureMove := -1
end;

// -- Helper

function TBookBoard.LastStone(i, j : integer) : TInterEvent;
begin
  Result := TInterEvent(Board[i, j].Last)
end;

// == Content of intersection ================================================

// -- Index in intersection list of stone displayed in figure at i,j ---------
//
// -- Either the first played or setup, or the last before figure number
// -- figureMove is the first move displayed in figure
// -- returns -1 if no stone at i,j, or the index in intersection stack

function TBookBoard.StoneInFigure(i, j, figureMove : integer) : integer;
var
  n, k : integer;
  event : TInterEvent;
begin
  Result := -1;
  n := Board[i, j].Count;

  // no stone at i,j
  if n = 0
    then exit;

  // get first stone played at i,j
  event := TInterEvent(Board[i, j].First);
  Result := 0;

  // first stone after figure
  if event.MoveNumber >= figureMove
    then exit;

  // find stone before figure
  for k := n - 1 downto 0 do
    begin
      event := TInterEvent(Board[i, j].Items[k]);
      Result := k;
      if event.MoveNumber < figureMove
        then break
    end;

  // check if stone before figure is captured
  if (event.CaptureMove > -1) and (event.CaptureMove <= figureMove) then
    if k = n - 1
      then Result := -1 // no stone in figure
      else Result := k + 1 // return the next one
end;

// -- Intersection displayed in figure at i,j --------------------------------
//
// -- Returns Empty, Black or White

function TBookBoard.InterInFigure(i, j, figureMove : integer) : integer;
var
  n : integer;
begin
  n := StoneInFigure(i, j, figureMove);

  if n < 0
    then Result := Empty
    else Result := TInterEvent(Board[i, j].Items[n]).Color
end;

// -- Number displayed in figure at i,j --------------------------------------
//
// -- Returns -1 if no stone at i,j or if the stone at i,j is not numbered

function TBookBoard.NumberInFigure(i, j, figureMove : integer) : integer;
var
  n : integer;
  stoneInFig : TInterEvent;
begin
  Result := -1;

  // protect from calls in FindReference
  if (i < 1) or (i > 19) or (j < 1) or (j > 19)
    then exit;

  // get stone played at i,j in figure
  n := StoneInFigure(i, j, figureMove);

  // no stone at i,j
  if n < 0
    then exit;

  stoneInFig := TInterEvent(Board[i, j].Items[n]);

  if (stoneInFig.MoveNumber >= figureMove) and stoneInFig.IsAMove
    then Result := stoneInFig.MoveNumber
    else Result := -1
end;

// --

procedure TBookBoard.BookBoard(i, j, figureMove : integer; var col, num : integer);
begin
end;

// == Over moves =============================================================

// -- Move reference for stones with no number -------------------------------

function TBookBoard.FindReference(i, j, figureMove : integer;
                                  stoneInFig : TInterEvent) : TOverMove;
var
  reference : TOverMove;
  nE, nN, nW, nS : integer;
begin
  Result := TOverMove.Create;
  reference := Result;
  reference.refLoc := -1;

  // stone is a move played in figure
  if (stoneInFig.MoveNumber >= figureMove) and stoneInFig.IsAMove then
    begin
      reference.refMove := stoneInFig.MoveNumber;
      reference.refLoc  := 0;
      exit
    end;

  // look for a neighbour
  nE := NumberInFigure(i, j + 1, figureMove);
  nN := NumberInFigure(i - 1, j, figureMove);
  nW := NumberInFigure(i, j - 1, figureMove);
  nS := NumberInFigure(i + 1, j, figureMove);

  // set reference move from neighbour
  if nE > 0 then reference.refMove := nE else
  if nN > 0 then reference.refMove := nN else
  if nW > 0 then reference.refMove := nW else
  if nS > 0 then reference.refMove := nS;

  // set origin of reference move (1 .. 4: East, North, West, South)
  if nE > 0 then reference.refLoc  :=  1 else
  if nN > 0 then reference.refLoc  :=  2 else
  if nW > 0 then reference.refLoc  :=  3 else
  if nS > 0 then reference.refLoc  :=  4;

  // exit if a reference move has been found
  if reference.refLoc > 0
    then exit;

  // no reference move, use coordinates;
  reference.refLoc := -1;
  reference.i := i;
  reference.j := j
end;

// -- Over moves at one intersection -----------------------------------------

procedure TBookBoard.OverMoves(i, j, figureMove : integer; list : TList);
var
  n, k : integer;
  event : TInterEvent;
  reference, overMove : TOverMove;
begin
  n := StoneInFigure(i, j, figureMove);

  // no moves at i,j
  if n < 0
    then exit;

  // no over moves
  if n = Board[i, j].Count - 1
    then exit;

  // some over moves, find reference
  reference := FindReference(i, j, figureMove, TInterEvent(Board[i, j].Items[n]));

  for k := n + 1 to Board[i, j].Count - 1 do
    begin
      event := TInterEvent(Board[i, j].Items[k]);

      overMove            := TOverMove.Create;
      overMove.MoveNumber := event.MoveNumber;
      overMove.RefMove    := reference.RefMove;
      overMove.RefLoc     := reference.RefLoc;
      overMove.i          := reference.i;
      overMove.j          := reference.j;

      list.Add(overMove)
    end;

  reference.Free
end;

// -- Over moves for the whole board -----------------------------------------

function SortOverMoves(x1, x2 : pointer) : integer;
begin
  Result := TOverMove(x1).MoveNumber - TOverMove(x2).MoveNumber
end;

function TBookBoard.OverMoves(figureMove : integer) : TList;
var
  i, j : integer;
begin
  Result := TList.Create;

  for i := 1 to 19 do                                       //TODO: check size
    for j := 1 to 19 do
      OverMoves(i, j, figureMove, Result);

  Result.Sort(SortOverMoves)
end;

// -- Formatting of over moves -----------------------------------------------

const
  Formats : array[0 .. 5] of string
    = ('%d at %d',
       '%d at left of %d',
       '%d below %d',
       '%d at right of %d',
       '%d above %d',
       '%d at %s');

function TBookBoard.OverMoveString(figureMove : integer) : string;
var
  list : TList;
  i : integer;
  overMove : TOverMove;
begin
  list := OverMoves(figureMove);
  Result := '';

  for i := 0 to list.Count - 1 do
    begin
      overMove := TOverMove(list[i]);

      if i > 0
        then Result := Result + ', ';

      if overMove.RefLoc < 0
        then Result := Result + Format(T(Formats[5]),
                          [overMove.MoveNumber, ij2kor(overMove.i, overMove.j, 19)])
        else Result := Result + Format(T(Formats[overMove.RefLoc]),
                          [overMove.MoveNumber, overMove.RefMove]);

      overMove.Free
    end;

  list.Free
end;

// ---------------------------------------------------------------------------

end.
