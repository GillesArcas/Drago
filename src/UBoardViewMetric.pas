// ---------------------------------------------------------------------------
// -- Drago -- Ancestor for graphic board views ------ UBoardViewMetric.pas --
// ---------------------------------------------------------------------------

unit UBoardViewMetric;

// ancestor for TBoardViewCanvas, TBoardViewVector, TBoardViewScript

// ---------------------------------------------------------------------------

interface

uses
  Types,
  Graphics,
  Define, UBackGround, UBoardView;

type
  TBoardViewMetric = class(TBoardView)
    BoardBack    : TBackground;   // backgrounds
    CoordBack    : TBackground;
    StoneStyle   : integer;
    ThickEdge    : boolean;
    LightSource  : TLightSource;
    PartialTouch : boolean;       // if partial intersections touch borders

    Canvas      : TCanvas; // target of drawing
    xMin, yMin  : integer; // top left board corner in screen coordinates
    d_inter     : integer; // intersection correction for partial display
    Radius      : integer; // dimensions
    Diameter    : integer;
    InterWidth  : integer;
    ExtRect     : TRect;   // dimensions of board with and without border
    ExtWidth    : integer;
    ExtHeight   : integer;
    IntRect     : TRect;
    IntWidth    : integer;
    IntHeight   : integer;
    wBorderW    : integer; // width of coordinate zone
    wBorderE    : integer;
    wBorderN    : integer;
    wBorderS    : integer;

    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(source : TBoardView); override;
    procedure BoardSettings(aBackground   : TBackground;
                            aBorderBack   : TBackground;
                            aThickEdge    : boolean;
                            aShowHoshis   : boolean;
                            aCoordStyle   : integer;
                            aStoneStyle   : integer;
                            aLightSource  : TLightSource;
                            aShowNumber   : integer;
                            aPartialTouch : boolean);
    procedure SetDim(aWidth, aHeight : integer; maxDiam : integer = 61); override;
    procedure AdjustDimFromDiameter; override;
    procedure AdjustDiameterFromDim(width, height, maxDiam : integer); override;
    procedure AdjustFont;
    function  FontSizeForText(const s : string; sizeText : TSizeText) : integer;
    procedure ij2xy(i, j : integer; var x, y : integer); override;
    procedure xy2ij(x, y : integer; var i, j : integer); override;
    function  InsideBoard(x, y : integer) : boolean; override;
    procedure DrawLines; override;
    procedure DrawHoshis; override;
    procedure DrawCoord; override;
    function  player2col(player : integer) : integer;
    procedure SetTextColors(inter, mrk2 : integer;
                            var pen, back : integer;
                            var style : TBrushStyle); virtual;
    procedure DrawSymbol(i, j, inter, mrk2 : integer; mrk : integer); override;
  protected
    TextFontSize : array[0 .. 3] of integer;
    CoorFontSize : integer;
    function    MaxFontSize : integer; virtual;
    procedure   SetLineParameters; virtual;
    procedure   DrawOneLine(k, x0, y0, x1, y1 : integer); virtual;
    procedure   SetHoshiParameters; virtual;
    procedure   DrawOneHoshi(x, y, r : integer); virtual;
    procedure   SetCoordParameters; virtual;
    function    CoordTextWidth(const s : string) : integer; virtual;
    function    CoordTextHeight : integer; virtual;
    procedure   DrawOneCoord(x, y : integer; const s : string); virtual;
    procedure   DrawTriangle(i, j, color : integer); virtual;
    procedure   DrawSquare (i, j, color : integer); virtual;
    procedure   DrawCross  (i, j, color : integer); virtual;
    procedure   DrawCircle (i, j, color : integer); virtual;
    procedure   DrawGhost  (i, j, color : integer); virtual;
    procedure   DrawCircum (i, j, color : integer); virtual;
    procedure   DrawBullet (i, j, inter, color : integer); virtual;
    procedure   DrawWildCard(i, j : integer); virtual;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  Std,
  UGraphic,
  UStatus,
  BoardUtils,
  Ux2y;

// -- Constructors

constructor TBoardViewMetric.Create;
begin
  inherited Create;

  BoardBack    := TBackground.Create(nil);
  CoordBack    := TBackground.Create(BoardBack);
  StoneStyle   := 0;
  ThickEdge    := True;
  LightSource  := lsTopLeft;
  PartialTouch := False;

  CoorFontSize := 8
end;

destructor TBoardViewMetric.Destroy;
begin
  BoardBack.Free;
  CoordBack.Free
end;

// -- Copy
//
// Note: Canvas is not copied, must be set when creating

procedure TBoardViewMetric.Assign(source : TBoardView);
var
  sourceMetric : TBoardViewMetric;
  i : integer;
begin
  inherited Assign(source);

  assert(source is TBoardViewMetric);
  sourceMetric := source as TBoardViewMetric;

  BoardSettings(sourceMetric.BoardBack,
                sourceMetric.CoordBack,
                sourceMetric.ThickEdge,
                sourceMetric.ShowHoshis,
                sourceMetric.CoordStyle,
                sourceMetric.StoneStyle,
                sourceMetric.LightSource,
                sourceMetric.ShowNumber,
                sourceMetric.PartialTouch);

  for i := 0 to 3 do
    TextFontSize[i] := sourceMetric.TextFontSize[i];

  SetDim(sourceMetric.ExtWidth, sourceMetric.ExtHeight);
  AdjustToSize
end;

procedure TBoardViewMetric.BoardSettings(aBackground   : TBackground;
                                         aBorderBack   : TBackground;
                                         aThickEdge    : boolean;
                                         aShowHoshis   : boolean;
                                         aCoordStyle   : integer;
                                         aStoneStyle   : integer;
                                         aLightSource  : TLightSource;
                                         aShowNumber   : integer;
                                         aPartialTouch : boolean);
begin
  ThickEdge    := aThickEdge;
  ShowHoshis   := aShowHoshis;
  StoneStyle   := aStoneStyle;
  LightSource  := aLightSource;
  CoordStyle   := aCoordStyle;
  ShowNumber   := aShowNumber;
  PartialTouch := aPartialTouch;
  BoardBack.Assign(aBackground);
  BoardBack.Update;
  CoordBack.Assign(aBorderBack);
  CoordBack.Update;
end;

procedure TBoardViewMetric.SetDim(aWidth, aHeight : integer; maxDiam : integer = 61);
begin
  // store dimensions (including border)
  ExtWidth  := aWidth;
  ExtHeight := aHeight;

  // adjust diameter using input dimensions
  AdjustDiameterFromDim(ExtWidth, ExtHeight, maxDiam);
  
  // adjust dimensions using calculated diameter
  AdjustDimFromDiameter;

  // calculate offsets for coordinate conversions
  xMin := wBorderW + Radius; // + 1;
  yMin := wBorderN + Radius; // + 1;

  // calculate font size for coordinates
  CoorFontSize := 8;
  Canvas.Font.Size := CoorFontSize;
  while (CoorFontSize > 1) and (Max(Canvas.TextWidth('19'),
                                    Canvas.TextHeight('A')) > InterWidth) do
    begin
      dec(CoorFontSize);
      Canvas.Font.Size := CoorFontSize
    end
end;

// -- Adjustment of diameter using dimensions

// Maximum stone diameter given display width and intersection range
function MaxDiameter(width, iMin, iMax : integer) : integer;
var
  n : integer;
begin
  n := iMax - iMin + 1;
  Result := (width - n + 1) div n
end;

procedure TBoardViewMetric.AdjustDiameterFromDim(width, height, maxDiam : integer);
var
  diamW, diamH : integer;
begin
  if CoordStyle = tcNone
    then
      begin
        diamW := MaxDiameter(width , jMin, jMax);
        diamH := MaxDiameter(height, iMin, iMax)
      end
    else
      begin
        diamW := MaxDiameter(width , jMin-1, jMax+1);
        diamH := MaxDiameter(height, iMin-1, iMax+1)
      end;

  Diameter := Min(diamW, diamH);
  Diameter := Min(Diameter, maxDiam);
  if not odd(Diameter)
    then dec(Diameter);

  Radius := Diameter div 2
end;

// -- Adjustment of dimensions using diameter

procedure TBoardViewMetric.AdjustDimFromDiameter;
var
  w : integer;
begin
  // calculate width of intersections
  InterWidth := Diameter + 1;
  if PartialTouch
    then d_inter := InterWidth div 2  // 2: if lines touch borders
    else d_inter := InterWidth div 3; // 3: if they don't touch

  // calculate board size
  IntWidth  := (jMax - jMin + 1) * InterWidth - 1;
  IntHeight := (iMax - iMin + 1) * InterWidth - 1;

  // protect if requested size too small
  IntWidth  := Max(1, IntWidth);
  IntHeight := Max(1, IntHeight);

  // set border width
  w         := iff(CoordStyle = tcNone, 0, InterWidth);
  wBorderW  := w;
  wBorderE  := w;
  wBorderN  := w;
  wBorderS  := w;

  ExtWidth  := IntWidth  + (wBorderW + wBorderE);
  ExtHeight := IntHeight + (wBorderN + wBorderS);

  IntRect   := Bounds(wBorderW, wBorderN, IntWidth, IntHeight);
  ExtRect   := Bounds(0, 0, ExtWidth, ExtHeight)
end;

// -- Adjustment of font size for move numbers

function TBoardViewMetric.MaxFontSize : integer;
begin
  Result := Settings.MaxBoardFontSize
end;

procedure TBoardViewMetric.AdjustFont;
const
  TargetStrings : array[0 .. 3] of string = ('8', 'M', '99', '999');
var
  i : integer;
begin
  for i := 0 to 3 do
    TextFontSize[i] := AdjustFontSize(Canvas, Radius,
                                      MaxFontSize,
                                      [fsBold], TargetStrings[i])
end;

function TBoardViewMetric.FontSizeForText(const s : string; sizeText : TSizeText) : integer;
var
  x : integer;
begin
  if TryStrToInt(s, x)
    then
      case sizeText of
        stNormal  : Result := TextFontSize[3];
        stBig     : Result := TextFontSize[2];
        stVeryBig : Result := TextFontSize[0]
        else
          begin
            assert(False);
            Result := TextFontSize[0]
          end
      end
    else
      if Length(s) = 1
        then Result := TextFontSize[2] // 2 en vo, 0 pour tuto Samarkand
        else Result := AdjustFontSize(Canvas,
                                      Radius, Settings.MaxBoardFontSize,
                                      [fsBold], s)
end;

// -- Board/screen coordinate conversions ------------------------------------

// -- Board to screen

procedure TBoardViewMetric.ij2xy(i, j : integer; var x, y : integer);
begin
  x := xMin + (j - jMin) * InterWidth;
  y := yMin + (i - iMin) * InterWidth
end;

// -- Screen to board

procedure TBoardViewMetric.xy2ij(x, y : integer; var i, j : integer);
begin
  i := round((y - yMin) / InterWidth) + iMin;
  j := round((x - xMin) / InterWidth) + jMin;

  if i < iMin then i := iMin else
  if i > iMax then i := iMax;
  if j < jMin then j := jMin else
  if j > jMax then j := jMax;
end;

// -- Inside board

function TBoardViewMetric.InsideBoard(x, y : integer) : boolean;
begin
  Result := InsideRect(X, Y, IntRect)
end;

// -- Lines

// virtual
procedure TBoardViewMetric.SetLineParameters;
begin
end;

// virtual
procedure TBoardViewMetric.DrawOneLine(k, x0, y0, x1, y1 : integer);
begin
end;

procedure TBoardViewMetric.DrawLines;
var
  min, max, i, j, x, y : integer;
begin
  // set line parameters
  SetLineParameters;

  // draw horizontal lines
  min := wBorderW + InterWidth div 2;
  max := min + InterWidth * (jMax - jMin) + 1 - 1 - 1;

  if jMin > 1         then dec(min, d_inter);
  if jMax < BoardSize then inc(max, d_inter);

  for i := iMin to iMax do
    begin
      y := wBorderN + Radius + InterWidth * (i - iMin);
      DrawOneLine(i, min-1, y, max, y)
    end;

  // draw vertical lines
  min := wBorderN + InterWidth div 2;
  max := min + InterWidth * (iMax - iMin) + 1 - 1;
  dec(min);

  if iMin > 1         then dec(min, d_inter);
  if iMax < BoardSize then inc(max, d_inter);

  for j := jMin to jMax do
    begin
      x := wBorderW + Radius + InterWidth *(j - jMin);
      DrawOneLine(j, x, min, x, max - 1);
    end
end;

// -- Hoshis

// virtual
procedure TBoardViewMetric.SetHoshiParameters;
begin
end;

// virtual
procedure TBoardViewMetric.DrawOneHoshi(x, y, r : integer);
begin
end;

procedure TBoardViewMetric.DrawHoshis;
var
  s : string;
  r, k, i, j, x, y : integer;
begin
  if not ShowHoshis
    then exit;

  SetHoshiParameters;

  r  := Max(1, InterWidth div 20);
  s  := HandicapStones(BoardSize, MaxHandicap(BoardSize));

  for k := 1 to MaxHandicap(BoardSize) do
    begin
      pv2ij(nthpv(s, k), i, j);

      if Within(i, iMin, iMax) and Within(j, jMin, jMax) then
        begin
          ij2xy(i, j, x, y);
          DrawOneHoshi(x, y, r)
        end
    end
end;

// -- Coordinates

// virtual
procedure TBoardViewMetric.SetCoordParameters;
begin
end;

// virtual
function TBoardViewMetric.CoordTextWidth(const s : string) : integer;
begin
  Result := 0
end;

// virtual
function TBoardViewMetric.CoordTextHeight : integer;
begin
  Result := 0
end;

// virtual
procedure TBoardViewMetric.DrawOneCoord(x, y : integer; const s : string);
begin
end;

procedure TBoardViewMetric.DrawCoord;
var
  i, j, x, x1, x2, y, y1, y2, ht, lt, dum : integer;
  s : string;
  s1, s2 : string;
begin
  // set parameters
  SetCoordParameters;
  ht := CoordTextHeight;

  // draw coordinates on vertical borders
  for i := iMin to iMax do
    begin
      // text of line ordinate
      s := ycoordinate(i, BoardSize, CoordStyle, CoordTrans);

      // width of text
      lt := CoordTextWidth(s);
      // ordinate
      ij2xy(i, 1, dum, y);
      dec(y, ht div 2);
      // left and right abscissa
      x1 := InterWidth div 2 - lt div 2;
      x2 := ExtWidth - InterWidth div 2 - lt div 2;
      // display coordinate
      DrawOneCoord(x1, y, s);
      DrawOneCoord(x2, y, s)
    end;

  // draw coordinates on horizontal borders
  for j := jMin to jMax do
    begin
      // text of line abscissa
      s := xcoordinate(j, BoardSize, CoordStyle, CoordTrans);

      // width of text
      lt := CoordTextWidth(s);
      // abscissa
      ij2xy(1, j, x, dum);
      dec(x, lt div 2);
      // top and bottom ordinate
      y1 := InterWidth div 2 - ht div 2;
      y2 := ExtHeight - InterWidth div 2 - ht div 2;
      // display coordinate
      DrawOneCoord(x, y1, s);
      DrawOneCoord(x, y2, s)
    end
end;

// -- Entry point

procedure TBoardViewMetric.DrawSymbol(i, j, inter, mrk2 : integer; mrk : integer);
var
  penCol, backCol : integer;
  style : TBrushStyle;
begin
  SetTextColors(inter, mrk2, penCol, backCol, style);

  case mrk of
    mrkTR : DrawTriangle(i, j, penCol);
    mrkSQ : DrawSquare  (i, j, penCol);
    mrkCR : DrawCircle  (i, j, penCol);
    mrkMA : DrawCross   (i, j, penCol);
    mrkM  : DrawTriangle(i, j, penCol);
    mrkPHB: DrawGhost   (i, j, Black);
    mrkPHW: DrawGhost   (i, j, White);
    mrkTB : DrawBullet  (i, j, inter, clBlack);
    mrkTW : DrawBullet  (i, j, inter, clWhite);
    mrkGH : DrawCircum  (i, j, clGreen);
    mrkBH : DrawCircum  (i, j, clRed);
    mrkSG : DrawCircum  (i, j, clBlue);
    mrkCS : DrawCircum  (i, j, clYellow);
    mrkCUR: DrawBullet  (i, j, inter, penCol);
    mrkWC : DrawWildCard(i, j)
  else
    assert(False)
  end
end;

// -- Handling of colors -----------------------------------------------------

function TBoardViewMetric.player2col(player : integer) : integer;
begin
  case player of
    Black : Result := clBlack;
    White : Result := clWhite;
    else    Result := clLtGray
  end;
end;

procedure TBoardViewMetric.SetTextColors(inter, mrk2 : integer;
                                         var pen, back : integer;
                                         var style : TBrushStyle);
begin
  case inter of
    Empty : pen := BoardBack.PenColor;
    Black : pen := clWhite;
    White : pen := clBlack;
  end;

  if inter <> Empty
    then style := bsClear
    else
      if mrk2 <> 0
        then
          begin
            style := bsClear;
            if mrk2 = mrkPHB
              then pen := clWhite
              else pen := clBlack
          end
        else
          begin
            style := bsSolid;
            back  := BoardBack.MeanColor
          end
end;

// -- Marks ------------------------------------------------------------------

// virtual
procedure TBoardViewMetric.DrawTriangle(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawSquare(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawCross(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawCircle(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawGhost(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawCircum(i, j, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawBullet(i, j, inter, color : integer);
begin
end;

// virtual
procedure TBoardViewMetric.DrawWildCard(i, j : integer);
begin
end;

// ---------------------------------------------------------------------------

end.
