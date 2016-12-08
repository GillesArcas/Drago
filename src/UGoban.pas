// ---------------------------------------------------------------------------
// -- Drago -- Implementation of full featured board ----------- UGoban.pas --
// ---------------------------------------------------------------------------

unit UGoban;

// ---------------------------------------------------------------------------

interface

uses 
  Types,
  Classes,
  Define, BoardUtils, UGoBoard, UBoardView, UBookBoard;

type
  TcallbackShowMove = procedure(i, j, num : integer);

type
  TBoardMark = record
    FMark : integer;
    FText : string;
    FColor : integer;
  end;

type
  TGoban  = class
  public
    GameBoard   : TGoBoard;
    BoardView   : TBoardView;
    BookBoard   : TBookBoard;
    Silence     : boolean;
    BoardMarks  : array[1 .. 19, 1 .. 19] of TBoardMark;
    BoardMarks2 : array[1 .. 19, 1 .. 19] of TBoardMark;
    ShowMoveMode: TShowMoveMode;
    NumberOfVisibleMoveNumbers : integer;
    CoordTrans  : TCoordTrans;
    FColorTrans : TColorTrans;
    CBShowMove  : TcallbackShowMove;
    iMinData, iMaxData,              // displayed zone in board coordinates
    jMinData, jMaxData : integer;
    iMinView, iMaxView,              // displayed zone in view coordinates
    jMinView, jMaxView : integer;
    FLastRect   : TRect;
  private
    FBoardSize  : integer;
    StackMN     : TPairStack;          // offset
    StackFG     : TPairStack;          // figures
    TmpMarks    : TPairStack;          // temporary markups
    TmpBoard    : array[1 .. 19, 1 .. 19] of TBoardMark;

  public
    constructor Create;
    destructor Destroy; override;
    procedure SetSize(size : integer);
    procedure Assign(source : TGoban; ignoreView : boolean = False);
    procedure Clear;
    procedure BoardSettings(aShowHoshis   : boolean;
                            aCoordStyle   : integer;
                            aShowNumber   : integer;
                            aCoordTrans   : TCoordTrans;
                            aShowMoveMode : TShowMoveMode;
                            aNumberOfVisibleMoveNumbers : integer);

    // Game
    procedure Setup(i, j, inter : integer);
    procedure Remove;
    procedure Play(i, j, color : integer; var status : integer);
    procedure Undo;
    procedure Leave(i, j : integer);
    procedure ComeBack(i, j : integer);
    function  IsValid(i, j, color : integer; var status : integer) : boolean;
    function  IsBoardCoord(i, j : integer) : boolean;

    // Graphic
    procedure SetBoardView   (aBoardView : TBoardView);
    procedure SetView        (aiMin, ajMin, aiMax, ajMax : integer);
    procedure SetDim         (aWidth, aHeight : integer; maxDiam : integer = 61);
    procedure Resize         (aWidth, aHeight : integer);

    procedure ij2xy          (i, j : integer; var x, y : integer);
    procedure xy2ij          (x, y : integer; var i, j : integer);
    function  InsideBoard    (x, y : integer) : boolean;

    procedure Draw;
    procedure DrawEmpty;
    procedure ShowVertex     (i, j : integer; backGround : boolean = True;
                              ignoreMove : boolean = False);
    procedure ShowSymbol     (i, j : integer; mrk : integer; layer : integer = 1); overload;
    procedure ShowSymbol     (i, j : integer; mrk : string); overload;
    procedure HideSearchMarks(all : boolean);
    function  IsWildcard     (i, j : integer) : boolean;

    procedure ShowTempMark   (i, j : integer; mrk : integer;
                              const txt : string = '';
                              txtColor : integer = 0);
    procedure HideTempMarks;

    //-------
    procedure FindVertexElements(i, j : integer;
                                 background : boolean;
                                 ignoreMove : boolean;
                                 var drawElems : TDrawElems;
                                 var move : integer;
                                 var alternateShowMove : boolean);
    procedure DrawVertex(i, j : integer; drawElems : TDrawElems);
    //-------

    // Offsets
    procedure PushOffset(i, k : integer);
    function  PopOffset : integer;
    function  NumWithOffset(n : integer = -1) : integer;
    // Print moves
    function  OverMoveString : string; overload;
    function  OverMoveString(figureMove : integer) : string; overload;
    // Figures
    procedure PushFG;
    procedure PopFG;
    procedure UpdateMovesFG(var minFG, maxFG : integer);
    // Vue
    procedure Rectangle(i1, j1, i2, j2 : integer; draw : boolean;
                        mode : integer = 0);

  private
    function  MoveNumberOnBoard(i, j : integer) : integer;
    function  IsMoveNumberVisibleOnBoard(i, j : integer) : boolean;
    function  MoveNumBoard   (i, j : integer) : integer;
    function  MoveNumBook    (i, j : integer) : integer;
    function  FindVertexStone(i, j : integer) : integer;
    function  FindVertexMove (i, j : integer) : integer;
    procedure SetSymbol      (i, j, mrk : integer; layer : integer = 1); overload;
    procedure SetSymbol      (i, j : integer; mrk : string); overload;
    procedure DrawSymbol     (i, j : integer; mrk : integer;
                              const txt : string = '';
                              mrk2 : integer = mrkNo;
                              txtColor : integer = 0);
  private
    procedure SetBoardSize(size : integer);
    function  GetMoveNumber : integer;
    function  GetBoard(i, j : integer) : integer;

  public
    property  BoardSize : integer read FBoardSize write SetBoardSize;
    property  ColorTrans : TColorTrans read FColorTrans write FColorTrans;
    property  MoveNumber : integer read GetMoveNumber;
    property  Board[i, j : integer] : integer read GetBoard;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils,
  Std, Ux2y,
  Translate;

// -- Constructor ------------------------------------------------------------

constructor TGoban.Create;
begin
  GameBoard := TGoBoard.Create;
  BookBoard := TBookBoard.Create;
  BoardView := TBoardView.Create;

  ShowMoveMode := smNoMark;
  NumberOfVisibleMoveNumbers := 1;
  CBShowMove := nil;
  StackMN := TPairStack.Create;
  StackMN.Push(0, 0);
  StackFG := TPairStack.Create;
  PushFG;
  TmpMarks := TPairStack.Create;

  SetSize(19);
end;

// -- Destructor -------------------------------------------------------------

destructor TGoban.Destroy;
begin
  FreeAndNil(GameBoard);
  FreeAndNil(BoardView);
  FreeAndNil(BookBoard);
  StackMN.Free;
  StackFG.Free;
  TmpMarks.Free;

  inherited Destroy
end;

// -- Setting of board size --------------------------------------------------

procedure TGoban.SetSize(size : integer);
begin
  BoardSize := size;
  SetView(1, 1, BoardSize, BoardSize);
  Silence := False;
  Clear
end;

// -- Accessors --------------------------------------------------------------

procedure TGoban.SetBoardView(aBoardView : TBoardView); // todo: make a property ?
begin
  //aBoardView.Assign(BoardView);
  aBoardView.AssignRoot(BoardView);

  BoardView.Free;
  BoardView := aBoardView
end;

procedure TGoban.SetBoardSize(size : integer);
begin
  FBoardSize := size;
  GameBoard.BoardSize := size;
  BoardView.BoardSize := size
end;

function TGoban.GetBoard(i, j : integer) : integer;
begin
  Result := GameBoard.Board[i, j]
end;

function TGoban.GetMoveNumber : integer;
begin
  Result := GameBoard.MoveNumber
end;

// -- Copy and settings ------------------------------------------------------

procedure TGoban.Assign(source : TGoban; ignoreView : boolean = False);
var
  i, j : integer;
begin
  BoardSize := source.BoardSize;
  GameBoard.Assign(source.GameBoard);
  if ignoreView // TODO: misleading identifier
    then BoardView.AssignRoot(source.BoardView)
    else BoardView.Assign(source.BoardView);
  BookBoard.Assign(source.BookBoard);

  ShowMoveMode := source.ShowMoveMode;
  NumberOfVisibleMoveNumbers := source.NumberOfVisibleMoveNumbers;

  CoordTrans := source.CoordTrans;
  ColorTrans := source.ColorTrans;

  iMinData := source.iMinData;
  iMaxData := source.iMaxData;
  jMinData := source.jMinData;
  jMaxData := source.jMaxData;
  iMinView := source.iMinView;
  iMaxView := source.iMaxView;
  jMinView := source.jMinView;
  jMaxView := source.jMaxView;

  for i := 1 to 19 do
    for j := 1 to 19 do
      begin
        BoardMarks [i, j] := source.BoardMarks [i, j];
        BoardMarks2[i, j] := source.BoardMarks2[i, j];
        TmpBoard   [i, j] := source.TmpBoard   [i, j]
      end;

  StackMN.Assign(source.StackMN);
  StackFG.Assign(source.StackFG);
  TmpMarks.Assign(source.TmpMarks);
end;

procedure TGoban.BoardSettings(aShowHoshis   : boolean;
                               aCoordStyle   : integer;
                               aShowNumber   : integer;
                               aCoordTrans   : TCoordTrans;
                               aShowMoveMode : TShowMoveMode;
                               aNumberOfVisibleMoveNumbers : integer);
begin
  self.BoardView.BoardSettings(aShowHoshis, aCoordStyle, aShowNumber, aCoordTrans);
  self.ShowMoveMode := aShowMoveMode;
  self.NumberOfVisibleMoveNumbers := aNumberOfVisibleMoveNumbers
end;

// -- Clear board ------------------------------------------------------------

procedure TGoban.Clear;
begin
  GameBoard.Clear;
  BookBoard.Clear;

  //CoordTrans := trIdent; //non pour problèmes
  //ColorTrans := ctIdent;

  StackMN.Leave(1);
  StackFG.Leave(1);
  TmpMarks.Leave(0);
  //PushFG;
  fillchar(BoardMarks , sizeof(BoardMarks ), 0);
  fillchar(BoardMarks2, sizeof(BoardMarks2), 0);
  fillchar(TmpBoard, sizeof(TmpBoard), 0);

  if Assigned(BoardView.ComCanvas)
    then BoardView.ComCanvas.Clear
end;

// ---------------------------------------------------------------------------
// -- Game functions ---------------------------------------------------------
// ---------------------------------------------------------------------------

// -- Add and remove setup stones --------------------------------------------

procedure TGoban.Setup(i, j, inter : integer);
var
  status : integer;
begin
  GameBoard.Setup(i, j, inter, status);

  if status = CgbOk then
    begin
      BookBoard.Setup(i, j, inter, MoveNumber);
      ShowVertex(i, j)
    end
end;

procedure TGoban.Remove;
var
  i, j, inter : integer;
begin
  GameBoard.Remove(i, j, inter);
  BookBoard.Remove(i, j);
  ShowVertex(i, j)
end;

// -- Play a move ------------------------------------------------------------

procedure TGoban.Play(i, j, color : integer; var status : integer);
var
  prisoners : TChain;
  k : integer;
begin
  GameBoard.Play(i, j, color, prisoners, status);

  if status = CgbOk then
    begin
      BookBoard.Play(i, j, color, MoveNumber);
      ShowVertex(i, j);

      for k := 1 to prisoners.n do
        begin
          BookBoard.Capture(prisoners.i[k], prisoners.j[k], MoveNumber);
          ShowVertex(prisoners.i[k], prisoners.j[k])
        end
    end
end;

// -- Undo a move ------------------------------------------------------------

procedure TGoban.Undo;
var
  i, j, k, color, status : integer;
  prisoners : TChain;
begin
  GameBoard.Undo(i, j, color, prisoners, status);

  if status = CgbOk then
    begin
      BookBoard.Undo(i, j);
      ShowVertex(i, j);

      for k := 1 to prisoners.n do
        begin
          BookBoard.GiveBack(prisoners.i[k], prisoners.j[k]);
          ShowVertex(prisoners.i[k], prisoners.j[k])
        end
    end
end;

// -- Leaving and coming back ------------------------------------------------

procedure TGoban.Leave(i, j : integer);
begin
  ShowVertex(i, j, True, True)
end;

procedure TGoban.ComeBack(i, j : integer);
begin
  ShowVertex(i, j)
end;

// -- Predicates -------------------------------------------------------------

function TGoban.IsValid(i, j, color : integer; var status : integer) : boolean;
begin
  Result := GameBoard.IsValid(i, j, color, status)
end;

function TGoban.IsBoardCoord(i, j : integer) : boolean;
begin
  Result := GameBoard.IsBoardCoord(i, j)
end;

// ---------------------------------------------------------------------------
// -- Display functions ------------------------------------------------------
// ---------------------------------------------------------------------------

// -- Update of display settings ---------------------------------------------

procedure TGoban.SetView(aiMin, ajMin, aiMax, ajMax : integer);
begin
  iMinData := aiMin;
  iMaxData := aiMax;
  jMinData := ajMin;
  jMaxData := ajMax;

  SortPair(iMinData, iMaxData);
  SortPair(jMinData, jMaxData);

  Transform(iMinData, jMinData, BoardSize, CoordTrans, iMinView, jMinView);
  Transform(iMaxData, jMaxData, BoardSize, CoordTrans, iMaxView, jMaxView);

  BoardView.SetView(iMinView, jMinView, iMaxView, jMaxView)
end;

procedure TGoban.SetDim(aWidth, aHeight : integer; maxDiam : integer = 61);
begin
  BoardView.SetDim(aWidth, aHeight, maxDiam)
end;

// -- Resizing ---------------------------------------------------------------

procedure TGoban.Resize(aWidth, aHeight : integer);
begin
  BoardView.Resize(aWidth, aHeight);
  Draw
end;

// -- Display of board -------------------------------------------------------

// -- Empty board

procedure TGoban.DrawEmpty;
begin
  BoardView.DrawEmpty
end;

// -- Board

procedure TGoban.Draw;
var
  i, j : integer;
begin
  if Silence
    then exit;
  
  //MilliTimer;
  DrawEmpty;

  for i := iMinData to iMaxData do
    for j := jMinData to jMaxData do
      ShowVertex(i, j, False)
  //;Trace(Format('Draw : %d', [MilliTimer]));
end;

// -- Display of intersections -----------------------------------------------

procedure TGoban.ShowVertex(i, j : integer; backGround : boolean = True;
                            ignoreMove : boolean = False);
var
  drawElems : TDrawElems;
  move : integer;
  alternateShowMove : boolean;
begin
  if Silence or not IsBoardCoord(i, j)
    then exit;

  FindVertexElements(i, j, background, ignoreMove, drawElems, move,
                            alternateShowMove);
  DrawVertex(i, j, drawElems);

  // show move number in some way if not already displayed on stones
  if alternateShowMove then
    if Assigned(CBShowMove)
      then CBShowMove(i, j, move);

  if ShowMoveMode = smBook then
    if Assigned(CBShowMove)
      then CBShowMove(i, j, -1)
end;

procedure TGoban.FindVertexElements(i, j : integer;
                                     background : boolean;
                                     ignoreMove : boolean;
                                     var drawElems : TDrawElems;
                                     var move : integer;
                                     var alternateShowMove : boolean);
begin
  // find all elements to be displayed at intersection
  drawElems.background := background;
  drawElems.stone      := FindVertexStone(i, j);
  move                 := FindVertexMove(i, j);

  drawElems.MainMark   := BoardMarks [i, j].FMark;
  drawElems.MainText   := BoardMarks [i, j].FText;
  drawElems.AuxMark    := BoardMarks2[i, j].FMark;

  // ignoreMove is True only when leaving a node
  if ignoreMove and (ShowMoveMode in [smNumber, smMark, smNumberN])
    then move := 0;

  // arbitration between marks and moves
  if (move = 0) or (drawElems.MainMark = mrkNo)
    then
      begin
        drawElems.MoveNumber := move;
        alternateShowMove := False;
      end
    else
      begin
        drawElems.MoveNumber := 0;
        alternateShowMove := GameBoard.IsLastMove(i, j)
      end;

  // use current move mark if required
  if (move <> 0) and (ShowMoveMode = smMark) then
    begin
      drawElems.MoveNumber := 0;
      drawElems.AuxMark := mrkCur
    end
end;

procedure TGoban.DrawVertex(i, j : integer; drawElems : TDrawElems);
begin
  Transform(i, j, BoardSize, CoordTrans, i, j);
  drawElems.Stone    := ColorTransform(drawElems.Stone, ColorTrans);
  drawElems.MainMark := MarkupColorTransform(drawElems.MainMark, ColorTrans);
  drawElems.AuxMark  := MarkupColorTransform(drawElems.AuxMark , ColorTrans);

  BoardView.DrawVertex(i, j, drawElems)
end;
                       
// -- Display of stones ------------------------------------------------------

function TGoban.FindVertexStone(i, j : integer) : integer;
begin
  if ShowMoveMode <> smBook
    then Result := Board[i, j]
    else Result := BookBoard.InterInFigure(i, j, StackFG.Peek)
end;

// -- Display of marks -------------------------------------------------------

// -- Display methods

procedure TGoban.ShowSymbol(i, j : integer; mrk : integer; layer : integer = 1);
begin
  if not IsBoardCoord(i, j)
    then exit
    else SetSymbol(i, j, mrk, layer);

  if Silence
    then exit
    else ShowVertex(i, j)
end;

procedure TGoban.ShowSymbol(i, j : integer; mrk : string);
begin
  if not IsBoardCoord(i, j)
    then exit
    else SetSymbol(i, j, mrk);

  if Silence
    then exit
    else ShowVertex(i, j)
end;

// -- Storage of markup

procedure SetBoardMark(var boardMark : TBoardMark;
                       aMark, aColor : integer;
                       const aText : string);
begin
  boardMark.FMark := aMark;
  boardMark.FText := aText;
  boardMark.FColor := aColor;
end;

// private
procedure TGoban.SetSymbol(i, j, mrk : integer; layer : integer = 1);
begin
  if layer = 2
    then BoardMarks2[i, j].FMark := mrk
    else SetBoardMark(BoardMarks[i, j], mrk, 0, '')
end;

// private
procedure TGoban.SetSymbol(i, j : integer; mrk : string);
begin
  SetBoardMark(BoardMarks[i, j], mrkTXT, 0, mrk)
end;

// -- Display of move numbers ------------------------------------------------

function TGoban.FindVertexMove(i, j : integer) : integer;
begin
  case ShowMoveMode of
    smNoMark : Result := 0;
    smBook   : Result := MoveNumBook(i, j);
    //else       Result := MoveNumBoard(i, j)
    else
      if IsMoveNumberVisibleOnBoard(i, j)
        then Result := MoveNumberOnBoard(i, j)
        else Result := 0
  end;

  if Result > 0 
    then Result := NumWithOffset(Result)
end;

// -- Calculation of move number to be displayed -----------------------------

// absolute move number for board numbering

function TGoban.MoveNumBoard(i, j : integer) : integer;
var
  num : integer;
begin
  Result := 0;
  num := GameBoard.TabNum[i, j];

  // exit if no move at inter
  if num = 0
    then exit;

  // exit if this is not the current move, when number or mark display mode
  //if (num <> MoveNumber) and (ShowMoveMode in [smNumber, smMark])
  if (not Within(num, MoveNumber - 3, MoveNumber)) and (ShowMoveMode in [smNumber, smMark])
    then exit;

  // exit if move not played in current figure
  if num < StackFG.Peek
    then exit;

  Result := num
end;

function TGoban.MoveNumberOnBoard(i, j : integer) : integer;
begin
  Result := GameBoard.TabNum[i, j]
end;

function TGoban.IsMoveNumberVisibleOnBoard(i, j : integer) : boolean;
var
  num : integer;
begin
  Result := False;
  num := GameBoard.TabNum[i, j];

  // not visible if no move at inter
  if num = 0
    then exit;

  // not visible if this is not the current move when in mark display mode
  if (num <> MoveNumber) and (ShowMoveMode in [smMark, smNumber])
    then exit;

  // not visible if not in rank of visible move numbers when in N-number display mode
  if (not Within(num, MoveNumber - NumberOfVisibleMoveNumbers + 1, MoveNumber)) and (ShowMoveMode = smNumberN)
    then exit;

  // not visible if move not played in current figure
  if num < StackFG.Peek
    then exit;

  // visible otherwise
  Result := True
end;

// absolute move number for book numbering

function TGoban.MoveNumBook(i, j : integer) : integer;
var
  num : integer;
begin
  num := BookBoard.NumberInFigure(i, j, StackFG.Peek);

  if (num > 0) and (BoardMarks[i, j].FMark = mrkNo)
    then Result := num
    else Result := 0
end;

// ---------------------------------------------------------------------------
// -- Handling of SGF properties ---------------------------------------------
// ---------------------------------------------------------------------------

// -- Handling of stack of offsets (MN) --------------------------------------

procedure TGoban.PushOffset(i, k : integer);
begin
  StackMN.Push(i, k)
end;

function TGoban.PopOffset : integer;
var
  i, j : integer;
begin
  StackMN.Pop;
  StackMN.Peek(i, j);
  Result := j
end;

function TGoban.NumWithOffset(n : integer = -1) : integer;
var
  i : integer;
begin
  // if no arg, shift current move number
  if n < 0
    then n := MoveNumber;

  Result := n;
  for i := Length(StackMN.Stack) - 1 downto 0 do
    if n >= StackMN.Stack[i, 0] then
      begin
        Result := n + StackMN.Stack[i, 1];
        exit
      end
end;

// -- Handling of stack of figures (FG property and export) ------------------

procedure TGoban.PushFG;
begin
  StackFG.Push(MoveNumber)
end;

procedure TGoban.PopFG;
begin
  StackFG.Pop
end;

procedure TGoban.UpdateMovesFG(var minFG, maxFG : integer);
var
  i, j, num : integer;
begin
  minFG := maxint;
  maxFG := MoveNumber;
  for i := 1 to BoardSize do
    for j := 1 to BoardSize do
      begin
        num := BookBoard.NumberInFigure(i, j, StackFG.Peek);
        if (num > 0) and (num >= StackFG.Peek)
          then
            if num < minFG
              then minFG := num
      end
end;

// -- Handling of over moves -------------------------------------------------

function TGoban.OverMoveString : string;
begin
  Result := {BookBoard.}OverMoveString(StackFG.Peek)
end;

const
  Formats : array[0 .. 5] of string
    = ('%d at %d',
       '%d at left of %d',
       '%d below %d',
       '%d at right of %d',
       '%d above %d',
       '%d at %s');

function TGoban.OverMoveString(figureMove : integer) : string;
var
  list : TList;
  i : integer;
  overMove : TOverMove;
begin
  list := BookBoard.OverMoves(figureMove);
  Result := '';

  for i := 0 to list.Count - 1 do
    begin
      overMove := TOverMove(list[i]);

      if i > 0
        then Result := Result + ', ';

      if overMove.RefLoc < 0
        then Result := Result + Format(T(Formats[5]),
                          [overMove.MoveNumber,
                           ij2kor(overMove.i, overMove.j, 19)])
        else Result := Result + Format(T(Formats[overMove.RefLoc]),
                          [NumWithOffset(overMove.MoveNumber),
                           NumWithOffset(overMove.RefMove)]);

      overMove.Free
    end;

  list.Free
end;

// ---------------------------------------------------------------------------
// -- Calls to graphic functions ---------------------------------------------
// ---------------------------------------------------------------------------

// -- Board/screen coordinate conversions ------------------------------------

procedure TGoban.ij2xy(i, j : integer; var x, y : integer);
begin
  Transform(i, j, BoardSize, CoordTrans, i, j);
  BoardView.ij2xy(i, j, x, y)
end;

procedure TGoban.xy2ij(x, y : integer; var i, j : integer);
begin
  BoardView.xy2ij(x, y, i, j);
  Transform(i, j, BoardSize, Inverse(CoordTrans), i, j)
end;

function TGoban.InsideBoard(x, y : integer) : boolean;
begin
  Result := BoardView.InsideBoard(x, y)
end;

// -- Display of marks -------------------------------------------------------

// -- Hiding of search labels
//
// all=true, hide wildcard and labels, all=false, hide only labels

procedure TGoban.HideSearchMarks(all : boolean);
begin
  exit;
end;

function TGoban.IsWildcard(i, j : integer) : boolean;
begin
  //Result := BoardMarks[i, j].FMark = mrkWC
  Result := BoardMarks2[i, j].FMark = mrkWC
end;

// -- Temporary marks

procedure TGoban.HideTempMarks;
var
  i, j : integer;
begin
  while TmpMarks.AtLeast(1) do
    begin
      TmpMarks.Pop(i, j);
      TmpBoard[i, j].FMark := mrkNo;

      //if (TmpBoard[i, j].FMark = mrkWC) or (BoardMarks[i, j].FMark = mrkWC)
      //  then BoardMarks[i, j].FMark := mrkNo;
      //if (TmpBoard[i, j].FMark = mrkWC) or (BoardMarks2[i, j].FMark = mrkWC)
      //  then BoardMarks2[i, j].FMark := mrkNo;
(*
      if BoardMarks2[i, j].FMark = mrkWC
        then BoardMarks2[i, j].FMark := mrkNo;
*)        
      ShowVertex(i, j)
    end
end;

// public
procedure TGoban.ShowTempMark(i, j : integer; mrk : integer;
                              const txt : string = '';
                              txtColor : integer = 0);
begin
  if mrk in [mrkPHB, mrkPHW]
    then
      begin
        DrawSymbol(i, j, mrk);
        if BoardMarks[i, j].FMark <> mrkNo
          then DrawSymbol(i, j, BoardMarks[i, j].FMark,
                          BoardMarks[i, j].FText, mrk)
      end
    else
      if TmpBoard[i, j].FMark in [mrkPHB, mrkPHW]
        then DrawSymbol(i, j, mrk, txt, TmpBoard[i, j].FMark, txtColor)
        else DrawSymbol(i, j, mrk, txt, mrkNo, txtColor);

  TmpBoard[i, j].FMark := mrk;
  TmpBoard[i, j].FText := txt;

  assert(mrk <> mrkWC, '');
  //if mrk = mrkWC
  //  then BoardMarks2[i, j].FMark := mrk;
  TmpMarks.Push(i, j)
end;

// private
procedure TGoban.DrawSymbol(i, j : integer;
                            mrk : integer;
                            const txt : string = '';
                            mrk2 : integer = mrkNo;
                            txtColor : integer = 0);
var
  inter : integer;
begin
  inter := FindVertexStone(i, j);
  Transform(i, j, BoardSize, CoordTrans, i, j);

  if (mrk = mrkTxt) and (BoardMarks[i, j].FMark = mrkTxt) then
    begin
      BoardView.DrawBackGround(i, j);
      if inter <> 0
        then BoardView.DrawStone(i, j, inter);

      if mrk2 in [mrkPHB, mrkPHW]
        then BoardView.DrawSymbol(i, j, inter, mrkNo, mrk2)
    end;

  if mrk = mrkTxt
    then BoardView.DrawString(i, j, inter, mrk2, txt, txtColor)
    else BoardView.DrawSymbol(i, j, inter, mrk2, mrk)
end;

// -- Rectangle

procedure TGoban.Rectangle(i1, j1, i2, j2 : integer; draw : boolean;
                            mode : integer = 0);
var
  i, j : integer;
begin
  if draw
    then
      if (i1 > 0)
        then
          begin
            Transform(i1, j1, BoardSize, CoordTrans, i1, j1);
            Transform(i2, j2, BoardSize, CoordTrans, i2, j2);
            SortPair(i1, i2);
            SortPair(j1, j2);

            FLastRect := Rect(j1, i1, j2, i2); // Left, Top, Right, Bottom
            BoardView.Rectangle(i1, j1, i2, j2, mode)
          end
        else
          if FLastRect.Top < 0
            then // nop, please no
            else
              begin
                // redraw current rect
                BoardView.Rectangle(FLastRect.Top, FLastRect.Left,
                                    FLastRect.Bottom, FLastRect.Right)
              end
    else
      // erase
      if FLastRect.Top < 0
        then // nop, already erased
        else
          begin
            SortPair(i1, i2);
            SortPair(j1, j2);

            if not (IsBoardCoord(i1, j1) and IsBoardCoord(i2, j2)) then
              begin
                i1 := FLastRect.Top;
                j1 := FLastRect.Left;
                i2 := FLastRect.Bottom;
                j2 := FLastRect.Right;
              end;

            for i := i1-1 to i2+1 do
              begin
                ShowVertex(i, j1);
                ShowVertex(i, j2);
                ShowVertex(i, j1-1);
                ShowVertex(i, j2+1);
              end;
            for j := j1-1 to j2+1 do
              begin
                ShowVertex(i1, j);
                ShowVertex(i2, j);
                ShowVertex(i1-1, j);
                ShowVertex(i2+1, j);
              end;

            FLastRect.Top := -1
          end
end;

// ---------------------------------------------------------------------------

end.

