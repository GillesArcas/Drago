// ---------------------------------------------------------------------------
// -- Drago -- All functions for board view ---------------- UBoardView.pas --
// ---------------------------------------------------------------------------

unit UBoardView;

// ---------------------------------------------------------------------------

interface

uses
  Types,
  Classes,
  Define;

type
  TSizeText = (stNormal, stBig, stVeryBig);

type
  TDrawElems = record
    Background : boolean;
    Stone      : integer;
    MainMark   : integer;
    MainText   : string;
    MainColor  : integer;
    AuxMark    : integer;
    AuxText    : string;
    AuxColor   : integer;
    MoveNumber : integer
  end;

type
  TBoardView = class

  public
    BoardSize    : integer;

    // settings
    ShowHoshis   : boolean;
    CoordStyle   : integer;
    ShowNumber   : integer;       // 2 or 3 characters
    CoordTrans   : TCoordTrans;

    constructor Create; virtual;
    destructor  Destroy; override;
    procedure   AssignRoot(source : TBoardView);
    procedure   Assign(source : TBoardView); virtual;
    procedure   BoardSettings(aShowHoshis : boolean;
                              aCoordStyle : integer;
                              aShowNumber : integer;
                              aCoordTrans : TCoordTrans);
    procedure   SetView(aiMin, ajMin, aiMax, ajMax : integer);
    procedure   SetDim(aWidth, aHeight : integer; maxDiam : integer = 61); virtual;
    procedure   Resize(aWidth, aHeight : integer); virtual;
    procedure   AdjustToSize; virtual;
    procedure   AdjustDimFromDiameter; virtual;
    procedure   AdjustDiameterFromDim(width, height, maxDiam : integer); virtual;
    procedure   ij2xy(i, j : integer; var x, y : integer); virtual;
    procedure   xy2ij(x, y : integer; var i, j : integer); virtual;
    function    InsideBoard(x, y : integer) : boolean; virtual;
    procedure   DrawBoard;
    procedure   DrawEmpty; virtual;
    procedure   DrawBackground; overload; virtual;
    procedure   DrawLines; virtual;
    procedure   DrawHoshis; virtual;
    procedure   DrawCoord; virtual;
    procedure   DrawVertex(i, j : integer; drawElems : TDrawElems); virtual;
    procedure   DrawStone (i, j, color : integer); virtual;
    procedure   DrawSymbol(i, j, inter, mrk2 : integer; mrk : integer); virtual;
    procedure   DrawText  (i, j, inter, mrk2 : integer; const s : string;
                           sizeText : TSizeText;
                           txtColor : integer = 0); virtual;
    procedure   DrawString(i, j, inter, mrk2 : integer;
                           const s : string;
                           txtColor : integer = 0);
    procedure   DrawBackGround(i, j : integer); overload; virtual;
    procedure   DrawSigMark(i, j, n : integer); virtual;
    procedure   Rectangle(i1, j1, i2, j2 : integer; mode : integer = 0); virtual;
    function    GetComCanvas : TStringList; virtual;

    property    ComCanvas : TStringList read GetComCanvas;

  protected
    // displayed rectangle area in board coordinates
    iMin, iMax, jMin, jMax : integer;

  private
    procedure   DrawMove(i, j, inter, mrk2, num : integer);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils,
  Std;

// -- Constructors ----------------------------------------------------------

constructor TBoardView.Create;
begin
  ShowHoshis   := True;
  CoordStyle   := tcNone;
  ShowNumber   := 3;
end;

// -- Destructor -------------------------------------------------------------

destructor TBoardView.Destroy;
begin
  inherited Destroy
end;

// -- Copy -------------------------------------------------------------------
//
// Note: - Canvas is not copied as being set when creating
//       - ComCanvas missing

procedure TBoardView.AssignRoot(source : TBoardView);
// not virtual
begin
  BoardSize := source.BoardSize;

  BoardSettings(source.ShowHoshis,
                source.CoordStyle,
                source.ShowNumber,
                source.CoordTrans);

  SetView(source.iMin, source.jMin, source.iMax, source.jMax)
end;

procedure TBoardView.Assign(source : TBoardView);
// virtual
begin
  BoardSize := source.BoardSize;

  BoardSettings(source.ShowHoshis,
                source.CoordStyle,
                source.ShowNumber,
                source.CoordTrans);

  SetView(source.iMin, source.jMin, source.iMax, source.jMax)
end;

// -- Accessors --------------------------------------------------------------

function TBoardView.GetComCanvas : TStringList;
begin
  Result := nil
end;

// -- Setting of board view --------------------------------------------------

// -- Setting of display parameters

procedure TBoardView.BoardSettings(aShowHoshis : boolean;
                                   aCoordStyle : integer;
                                   aShowNumber : integer;
                                   aCoordTrans : TCoordTrans);
begin
  ShowHoshis := aShowHoshis;
  CoordStyle := aCoordStyle;
  ShowNumber := aShowNumber;
  CoordTrans := aCoordTrans
end;

// -- Setting of board zone to display

procedure TBoardView.SetView(aiMin, ajMin, aiMax, ajMax : integer);
begin
  iMin := aiMin;
  iMax := aiMax;
  jMin := ajMin;
  jMax := ajMax;

  SortPair(iMin, iMax);
  SortPair(jMin, jMax)
end;

// -- Setting dimensions

// virtual
procedure TBoardView.SetDim(aWidth, aHeight : integer; maxDiam : integer = 61);
begin
end;

// -- Resizing ---------------------------------------------------------------

// virtual
procedure TBoardView.Resize(aWidth, aHeight : integer);
begin
end;

// virtual
procedure TBoardView.AdjustToSize;
begin
end;

// -- Helpers for setting functions ------------------------------------------

// -- Adjustment of diameter using dimensions

procedure TBoardView.AdjustDiameterFromDim(width, height, maxDiam : integer);
begin
end;

// -- Adjustment of dimensions using diameter

procedure TBoardView.AdjustDimFromDiameter;
begin
end;

// -- Board/screen coordinate conversions ------------------------------------

procedure TBoardView.ij2xy(i, j : integer; var x, y : integer);
begin
end;

procedure TBoardView.xy2ij(x, y : integer; var i, j : integer);
begin
end;

function TBoardView.InsideBoard(x, y : integer) : boolean;
begin
  Result := False
end;

// -- Display of board -------------------------------------------------------

// -- Full board

procedure TBoardView.DrawBoard;
begin
  DrawBackground;
  DrawLines;
  DrawHoshis
end;

// -- Draw background of whole board

// virtual
procedure TBoardView.DrawBackground;
begin
end;

// -- Empty board(draw board and add coordinates)

procedure TBoardView.DrawEmpty;
begin
  DrawBoard;

  if CoordStyle <> tcNone
    then DrawCoord
end;

// -- Draw intersection background

// virtual
procedure TBoardView.DrawBackGround(i, j : integer);
begin
end;

// -- Lines

// virtual
procedure TBoardView.DrawLines;
begin
end;

// -- Hoshis

// virtual
procedure TBoardView.DrawHoshis;
begin
end;

// -- Coordinates

// virtual
procedure TBoardView.DrawCoord;
begin
end;

// -- Display of intersection ------------------------------------------------

procedure TBoardView.DrawVertex(i, j : integer; drawElems : TDrawElems);
begin
  // draw background if requested
  if drawElems.background
    then DrawBackGround(i, j);

  // draw stone if any
  if drawElems.stone <> Empty
    then DrawStone(i, j, drawElems.stone);

  // draw auxiliary mark if any (ghost stone, variation marks)
  if (drawElems.AuxMark <> mrkNo) and (drawElems.AuxMark <> mrkTXT)
    then DrawSymbol(i, j, drawElems.stone, drawElems.AuxMark, drawElems.AuxMark);

  // draw user mark if any
  if (drawElems.MainMark <> mrkNo) and (drawElems.MainMark <> mrkTXT)
    then DrawSymbol(i, j, drawElems.stone, drawElems.AuxMark, drawElems.MainMark);

  // draw text mark if any
  if drawElems.MainMark = mrkTXT
    then DrawString(i, j, drawElems.stone, drawElems.AuxMark, drawElems.MainText);

  // draw auxiliary mark if any (search marks)
  if drawElems.AuxMark = mrkTXT
    then DrawString(i, j, drawElems.stone, drawElems.AuxMark, drawElems.AuxText);

  // draw move number if any
  if drawElems.moveNumber <> 0
    then DrawMove(i, j, drawElems.stone, drawElems.AuxMark, drawElems.MoveNumber)
end;

// -- Display of stones ------------------------------------------------------

// virtual
procedure TBoardView.DrawStone(i, j, color : integer);
begin
end;

// -- Display of marks -------------------------------------------------------

// -- Entry point

// virtual
procedure TBoardView.DrawSymbol(i, j, inter, mrk2 : integer; mrk : integer);
begin
end;

// -- Text marks

// virtual
procedure TBoardView.DrawText(i, j, inter, mrk2 : integer; const s : string;
                              sizeText : TSizeText;
                              txtColor : integer = 0);
begin
end;

// -- Strings

procedure TBoardView.DrawString(i, j, inter, mrk2 : integer;
                                const s : string;
                                txtColor : integer = 0);
begin
  if Length(s) <= 2
    then DrawText(i, j, inter, mrk2, s, stBig, txtColor)
    else DrawText(i, j, inter, mrk2, s, stNormal, txtColor)
end;

// -- Move numbers

procedure TBoardView.DrawMove(i, j, inter, mrk2, num : integer);
begin
  if ShowNumber = 2
    then DrawText(i, j, inter, mrk2, RightStr(IntToStr(num), 2), stBig)
    else DrawText(i, j, inter, mrk2, RightStr(IntToStr(num), 3), stNormal)
end;

// Signature marks

// virtual
procedure TBoardView.DrawSigMark(i, j, n : integer);
begin
end;

// Rectangle

// virtual
procedure TBoardView.Rectangle(i1, j1, i2, j2 : integer; mode : integer = 0);
begin
end;

// ---------------------------------------------------------------------------

end.

