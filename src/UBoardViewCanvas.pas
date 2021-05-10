// ---------------------------------------------------------------------------
// -- Drago -- Board view for canvas drawing --------- UBoardViewCanvas.pas --
// ---------------------------------------------------------------------------

unit UBoardViewCanvas;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Graphics,
  Define, DefineUi, UBoardView, UBoardViewMetric, UStones;

type
  TBoardViewCanvas = class(TBoardViewMetric)

  public
    // target of drawing
    //inherited: Canvas       : TCanvas;

    // working data
    //inherited: CoorFontSize : integer;

    constructor Create(aCanvas : TCanvas);
    destructor  Destroy; override;
    procedure   Resize(aWidth, aHeight : integer); override;
    procedure   AdjustToSize; override;
    function    player2col(player : integer) : integer;
    procedure   DrawStone(i, j, color : integer); override;
    procedure   DrawText(i, j, inter, mrk2 : integer; const s : string;
                         sizeText : TSizeText;
                         txtColor : integer = 0); override;
    procedure   DrawBackground; overload; override;
    procedure   DrawBackground(i, j : integer); overload; override;
    procedure   DrawSigMark(i, j, n : integer); override;
    procedure   Rectangle(i1, j1, i2, j2 : integer; mode : integer = 0); override;

  protected
    //inherited: iMin, iMax, jMin, jMax : integer;
    procedure   SetTextColors(inter, mrk2 : integer;
                              var pen, back : integer;
                              var style : TBrushStyle); override;
    function    MaxFontSize : integer; override;
    procedure   SetLineParameters; override;
    procedure   DrawOneLine(k, x0, y0, x1, y1 : integer); override;
    procedure   SetHoshiParameters; override;
    procedure   DrawOneHoshi(x, y, r : integer); override;
    procedure   SetCoordParameters; override;
    function    CoordTextWidth(const s : string) : integer; override;
    function    CoordTextHeight : integer; override;
    procedure   DrawOneCoord(x, y : integer; const s : string); override;
    procedure   DrawTextOnEmpty(x, y, mrk2 : integer; const s : string); virtual;
    procedure   TextOutOnBoard(x, y, offset : integer; const s : string);
    procedure   DrawTriangle(i, j, color : integer); override;
    procedure   DrawSquare  (i, j, color : integer); override;
    procedure   DrawCross   (i, j, color : integer); override;
    procedure   DrawCircle  (i, j, color : integer); override;
    procedure   DrawGhost   (i, j, color : integer); override;
    procedure   DrawCircum  (i, j, color : integer); override;
    procedure   DrawBullet  (i, j, inter, color : integer); override;
    procedure   DrawWildCard(i, j : integer); override;

  private
    bmStone     : array[1 .. 4] of TBitmap;
    CacheRadius : integer;
    CacheStyle  : integer;
    CacheLight  : TLightSource;
    CacheColor  : integer;
    bmGoban     : TBitmap;
    FStoneParams: TStoneParams;
    FIntersectionId : array[1 .. MaxBoardSize, 1 .. MaxBoardSize] of integer;

    procedure   CreateBitmap;
    procedure   DrawTextOnBoard(i, j, mrk2 : integer; empty : boolean; const s : string);
    procedure   DrawTextOnStone(x, y, mrk2 : integer; const s : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Types, StrUtils,
  Std, UGraphic, UStatus,
  UBackground;

// -- Constructor -----------------------------------------------------------

constructor TBoardViewCanvas.Create(aCanvas : TCanvas);
var
  i, j : integer;
begin
  inherited Create;

  Canvas := aCanvas;
  CacheRadius := 0;
  bmGoban := TBitmap.Create;
  FStoneParams := TStoneParams.Create;

  for i := 1 to 4 do
    begin
      bmStone[i] := TBitmap.Create;
      bmStone[i].TransparentMode := tmAuto;
      bmStone[i].Transparent := True
    end;

  for i := 1 to MaxBoardSize do
    for j := 1 to MaxBoardSize do
      FIntersectionId[i, j] := Random(MaxInt)
end;

// -- Destructor -------------------------------------------------------------

destructor TBoardViewCanvas.Destroy;
var
  i : integer;
begin
  bmGoban.Free;
  FStoneParams.Free;
  
  for i := 1 to 4 do
    bmStone[i].Free;

  inherited Destroy
end;

// -- Setting of board view --------------------------------------------------

// -- Setting dimensions

// -- Resizing ---------------------------------------------------------------

procedure TBoardViewCanvas.Resize(aWidth, aHeight : integer);
begin
  SetDim(aWidth, aHeight);
  AdjustToSize
end;

procedure TBoardViewCanvas.AdjustToSize;
begin
  AdjustFont;
  CreateBitmap;
end;

// -- Helpers for setting functions ------------------------------------------

// -- Adjustment of font size for move numbers

function TBoardViewCanvas.MaxFontSize : integer;
begin
  Result := Settings.MaxBoardFontSize
end;

// -- Creation of bitmaps ----------------------------------------------------

// -- Board

procedure TBoardViewCanvas.CreateBitmap;
var
  can : TCanvas;
begin
  bmGoban.Width  := ExtWidth;
  bmGoban.Height := ExtHeight;

  FStoneParams.SetParams(Settings.StoneStyle,
                         Settings.LightSource,
                         BoardBack.MeanColor,
                         Settings.CustomLightSource,
                         Settings.CustomBlackPath,
                         Settings.CustomWhitePath,
                         Settings.AppPath);

  // draw board on background bitmap
  can := Canvas;
  Canvas := bmGoban.Canvas;
  DrawEmpty;
  Canvas := can
end;

// -- Display of board -------------------------------------------------------

// -- Draw background of whole board

procedure TBoardViewCanvas.DrawBackground;
begin
  if CoordBack.Style = bsAsGoban
    then BoardBack.Apply(Canvas, ExtRect)
    else
      begin
        CoordBack.Apply(Canvas, ExtRect);
        BoardBack.Apply(Canvas, IntRect)
      end
end;

// -- Draw intersection background

procedure TBoardViewCanvas.DrawBackground(i, j : integer);
var
  l, x, y : integer;
begin
  ij2xy(i, j, x, y);

  l := Radius;
  Canvas.CopyRect(Rect(x - l, y - l, x + l + 1 + 1, y + l + 1 + 1),
                  bmGoban.Canvas,
                  Rect(wBorderW + (j-jMin  ) * InterWidth,
                       wBorderN + (i-iMin  ) * InterWidth,
                       wBorderW + (j-jMin+1) * InterWidth,
                       wBorderN + (i-iMin+1) * InterWidth))
end;

// -- Lines

procedure TBoardViewCanvas.SetLineParameters;
begin
  with Canvas do
    begin
      Brush.Color := clBlack;
      Pen.Color   := clBlack;
      Pen.Mode    := pmCopy
    end
end;

procedure TBoardViewCanvas.DrawOneLine(k, x0, y0, x1, y1 : integer);
begin
  with Canvas do
    begin
      Pen.Width := 1;
      PolyLine([Point(x0, y0), Point(x1, y1)]);
      if ThickEdge and (k = 1) then
        if x0 = x1
          then PolyLine([Point(x0 + 1, y0), Point(x1 + 1, y1)])
          else PolyLine([Point(x0, y0 + 1), Point(x1, y1 + 1)]);
      if ThickEdge and (k = BoardSize) then
        if x0 = x1
          then PolyLine([Point(x0 - 1, y0), Point(x1 - 1, y1)])
          else PolyLine([Point(x0, y0 - 1), Point(x1, y1 - 1)])
    end
end;

// -- Hoshis

procedure TBoardViewCanvas.SetHoshiParameters;
begin
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1
end;

procedure TBoardViewCanvas.DrawOneHoshi(x, y, r : integer);
begin
  Canvas.PolyLine([Point(x - 1, y - 1), Point(x + 1, y - 1),
                   Point(x + 1, y + 1), Point(x - 1, y + 1),
                   Point(x - 1, y - 1)]);
end;

// -- Coordinates

procedure TBoardViewCanvas.SetCoordParameters;
begin
  with Canvas do
    begin
      Brush.Style := bsClear;
      Font.Color  := CoordBack.PenColor;
      Font.Name   := 'Arial';
      Font.Size   := CoorFontSize;
      Font.Style  := []
    end
end;

function TBoardViewCanvas.CoordTextWidth(const s : string) : integer;
begin
  Result := Canvas.TextWidth(s)
end;

function TBoardViewCanvas.CoordTextHeight : integer;
begin
  Result := Canvas.TextHeight('8')
end;

procedure TBoardViewCanvas.DrawOneCoord(x, y : integer; const s : string);
begin
  Canvas.TextOut(x, y, s)
end;

// -- Display of stones ------------------------------------------------------

// Displaying stones with several variants (as white stones from sente.goban)
// requires to memorize the variant chosen initially for each stone. This is
// necessary to keep the same variant when resizing, showing and hiding marks
// on stone, etc.
// Instead of memorizing the variant number, an id of the intersection is used
// to select the variant. The id is selected randomly when creating the object.

procedure TBoardViewCanvas.DrawStone(i, j, color : integer);
var
  x, y : integer;
  stone : TStone;
begin
  if Diameter < 3
    then exit;

  ij2xy(i, j, x, y);

  stone := GetStone(color, Radius, FStoneParams, FIntersectionId[i, j]);

  if Assigned(stone)
    then stone.Draw(Canvas, x, y)
end;

procedure TBoardViewCanvas.DrawGhost(i, j, color : integer);
var
  x, y : integer;
  stone : TStone;
begin
  if Diameter < 3
    then exit;

  ij2xy(i, j, x, y);

  stone := GetStone(color, Radius, FStoneParams, FIntersectionId[i, j]);
  stone.DrawGhost(Canvas, x, y)
end;

// -- Handling of colors -----------------------------------------------------

function TBoardViewCanvas.player2col(player : integer) : integer;
begin
  case player of
    Black : Result := clBlack;
    White : Result := clWhite;
    else    Result := clLtGray
  end;
end;

procedure TBoardViewCanvas.SetTextColors(inter, mrk2 : integer;
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

// -- Display of marks -------------------------------------------------------

// -- Text marks

procedure TBoardViewCanvas.DrawText(i, j, inter, mrk2 : integer;
                                    const s : string;
                                    sizeText : TSizeText;
                                    txtColor : integer = 0);
var
  x, y, penCol, backCol, size : integer;
  style : TBrushStyle;
  bold, isEmpty : boolean;
begin
  size := FontSizeForText(s, sizeText);
  bold := Settings.BoldTextOnBoard;
  isEmpty := (inter = Empty);
  SetTextColors(inter, mrk2, penCol, backCol, style);

  if (mrk2 = 0) and (inter = Empty)
    then penCol := txtColor;

  // avoid pen color same as background color
  if penCol = backCol
    then
      if penCol < $202020
        then inc(penCol, $202020)
        else dec(penCol, $202020);

  with Canvas do
    begin
      Font.Name   := 'Arial';
      Font.Size   := size;
      Font.Color  := penCol;
      if bold
        then Font.Style := [fsBold]
        else Font.Style := [];
      Brush.Color := backCol;
      Brush.Style := style;

      ij2xy(i, j, x, y);
      DrawTextOnBoard(i, j, mrk2, isEmpty, s)
    end
end;

procedure TBoardViewCanvas.DrawTextOnBoard(i, j, mrk2 : integer;
                                           empty : boolean;
                                           const s : string);
var
  x, y : integer;
begin
  ij2xy(i, j, x, y);
  if empty
    then DrawTextOnEmpty(x, y, mrk2, s)
    else DrawTextOnStone(x, y, mrk2, s)
end;

procedure TBoardViewCanvas.DrawTextOnStone(x, y, mrk2 : integer; const s : string);
begin
  TextOutOnBoard(x, y, iff(s = '4', 0, 1), s)
end;

procedure TBoardViewCanvas.DrawTextOnEmpty(x, y, mrk2 : integer; const s : string);
begin
  if mrk2 in [mrkPHB, mrkPHW]
    // draw text on ghost stone
    then TextOutOnBoard(x, y, 1, s)
    // draw text on board background
    else BorderedText(s, Canvas, x, y, BoardBack.MeanColor)
end;

procedure TBoardViewCanvas.TextOutOnBoard(x, y, offset : integer; const s : string);
begin
  dec(x, Canvas.TextWidth(s) div 2 - offset);
  dec(y, Canvas.TextHeight(s) div 2);
  Canvas.TextOut(x, y, s)
end;

// -- Triangle marks

procedure TBoardViewCanvas.DrawTriangle(i, j, color : integer);
var
  x, y, l : integer;
begin
  ij2xy(i, j, x, y);

  l := InterWidth div 2;

  (**)
  UGPolyline(Canvas, x, y, l, color,
             [Point(l, l - Radius),
              Point(l - (Radius * 85) div 100, l + Radius div 2),
              Point(l + (Radius * 85) div 100, l + Radius div 2),
              Point(l, l - Radius)]);
  (*
  AAPolyline(Canvas, x, y, l, color, BoardBack.MeanColor,
             [Point(l, l - Radius),
              Point(l - (Radius * 85) div 100, l + Radius div 2),
              Point(l + (Radius * 85) div 100, l + Radius div 2),
              Point(l, l - Radius)]);
  (**)
end;

// -- Square marks

procedure TBoardViewCanvas.DrawSquare(i, j, color : integer);
var
  x, y, l, a : integer;
begin
  ij2xy(i, j, x, y);

  l := InterWidth div 2;
  a := (Radius * 65) div 100;

  UGPolyline(Canvas, x, y, l, color,
             [Point(l - a, l - a),
              Point(l + a, l - a),
              Point(l + a, l + a),
              Point(l - a, l + a),
              Point(l - a, l - a)])
end;

// -- Cross marks

procedure TBoardViewCanvas.DrawCross(i, j, color : integer);
var
  x, y, a, l : integer;
begin
  ij2xy(i, j, x, y);

  l := InterWidth div 2;
  a := (Radius * 75) div 100 - 1;

  UGPolyline(Canvas,
             x, y, l, color, [Point(l - a, l - a),
                              Point(l + a, l + a)]);
  UGPolyline(Canvas,
             x, y, l, color, [Point(l + a, l - a),
                              Point(l - a, l + a)])
end;

// -- Circle marks

procedure TBoardViewCanvas.DrawCircle(i, j, color : integer);
var
  x, y, r : integer;
begin
  ij2xy(i, j, x, y);

  r := (Radius * 3) div 4;

  ABCircle(Canvas, x, y, InterWidth div 2, r, color);
end;

// -- Stone circumference marks

procedure TBoardViewCanvas.DrawCircum(i, j, color : integer);
var
  x, y : integer;
begin
  ij2xy(i, j, x, y);

  //ABCircle(Canvas, x, y, InterWidth div 2, Radius, Color)
  AlphaCircle(Canvas, x, y, Radius - 2, 2, 1, color)
end;

// -- Bullet marks

procedure TBoardViewCanvas.DrawBullet(i, j, inter, color : integer);
var
  x, y, a : integer;
begin
  ij2xy(i, j, x, y);

  a := Max(3, Radius div 7);

  with Canvas do
    begin
      if inter = Empty
        then Pen.Color := clBlack
        else Pen.Color := color;

      Pen.Width   := 1;
      Brush.Color := color;
      Rectangle(x - a + 1, y - a + 1, x + a, y + a)
    end
end;

// -- Wildcard marks

procedure TBoardViewCanvas.DrawWildCard(i, j : integer);
var
  x, y : integer;
begin
  ij2xy(i, j, x, y);

  Canvas.Pen.Width := 1;
  ABCircle(Canvas, x, y, -1, Radius * 2 div 3, $00840204, $00008400)
end;

// -- Signature mark ---------------------------------------------------------

procedure TBoardViewCanvas.DrawSigMark(i, j, n : integer);
var
  x, y : integer;
begin
  DrawText(i, j, Empty, mrkNO, IntToStr(n), stVeryBig);

  ij2xy(i, j, x, y);
  ABCircle(Canvas, x, y, InterWidth div 2, InterWidth div 2, clBlue)
end;

// -- Rectangle --------------------------------------------------------------

procedure TBoardViewCanvas.Rectangle(i1, j1, i2, j2 : integer; mode : integer = 0);
var
  x1, y1, x2, y2, a : integer;
begin
  ij2xy(i1, j1, x1, y1);
  ij2xy(i2, j2, x2, y2);

  a := Radius;

  with Canvas do
    case mode of
      0 :
        begin
          Pen.Color := clRed;
          Pen.Style := psSolid;
          Pen.Width := 2;
          Polyline([Point(x1 - a+1, y1 - a+1),
                    Point(x2 + a+0, y1 - a+1),
                    Point(x2 + a+0, y2 + a+0),
                    Point(x1 - a+1, y2 + a+0),
                    Point(x1 - a+1, y1 - a+0)])
        end;
      1 :
        begin
          Pen.Color := clBlue;
          Pen.Style := psSolid;
          Pen.Width := 1;
          Polyline([Point(x1 - a-1, y1 - a-1),
                    Point(x2 + a+1, y1 - a-1),
                    Point(x2 + a+1, y2 + a+1),
                    Point(x1 - a-1, y2 + a+1),
                    Point(x1 - a-1, y1 - a-1)])
        end;
      2 :
        begin
          if i1 = 1
            then inc(y1, 2);
          if i2 = BoardSize
            then dec(y2, 2);
          if j1 = 1
            then inc(x1, 2);
          if j2 = BoardSize
            then dec(x2, 2);

          Pen.Style := psSolid;
          Pen.Width := 1;
          Pen.Color := clRed;//$00008400;
          Polyline([Point(x1 - a-1, y1 - a-1),
                    Point(x2 + a+1, y1 - a-1),
                    Point(x2 + a+1, y2 + a+1),
                    Point(x1 - a-1, y2 + a+1),
                    Point(x1 - a-1, y1 - a-1)]);
          Pen.Color := clRed;//$00840204;
          Polyline([Point(x1 - a-2, y1 - a-2),
                    Point(x2 + a+2, y1 - a-2),
                    Point(x2 + a+2, y2 + a+2),
                    Point(x1 - a-2, y2 + a+2),
                    Point(x1 - a-2, y1 - a-2)])
        end
    end
end;

// ---------------------------------------------------------------------------

end.


