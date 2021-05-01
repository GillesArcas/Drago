// ---------------------------------------------------------------------------
// -- Drago -- Graphic unit ---------------------------------- UGraphic.pas --
// ---------------------------------------------------------------------------

unit UGraphic;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Graphics, Types, PngImage;

type
  TRGBTriple      = packed record B, G, R : byte end;
  TRGBTripleArray = array[word] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBAQuad      = packed record B, G, R, A : byte end;
  TRGBAQuadArray = array[word] of TRGBAQuad;
  PRGBAQuadArray = ^TRGBAQuadArray;

type
  TStoneGetter = procedure(bmp : TBitmap;
                           color, diameter : integer;
                           out availableDiameter : integer);

procedure UGCircle(Canvas : Tcanvas;
                   x, y, d, r, color : integer; fill : integer = -1);
procedure WACircle(Canvas : Tcanvas; x, y, d, r, color, fill : integer);
procedure AAPolyline(Canvas : Tcanvas;
                     x, y, d, penC, bckC : integer; points : array of TPoint);
procedure UGPolyline(Canvas : Tcanvas;
                     x, y, d, color : integer; points : array of TPoint);
procedure AlphaCircle(Canvas : Tcanvas;
                      CenterX, CenterY : integer;
                      Radius, LineWidth, Feather: single;
                      color : integer);
procedure ABCircle(Canvas : Tcanvas;
                   x, y, d, r, color : integer; fill : integer = -1);
procedure BorderedText(s : string; can : TCanvas; aX, aY : integer; bg : TColor);
procedure AntiAliasedStone(Canvas : Tcanvas; x, y, d, r, color : integer); overload;
procedure AntiAliasedStone(bitmap : TBitmap; x, y, d, r, color : integer); overload;
procedure AlphaLine(Canvas : TCanvas;
                    x1, y1, x2, y2, penC, backC : integer);
function  GetBmBoard  : TBitmap;
function  MeanColor(Canvas : TCanvas; Width, Height : integer) : TColor;
function  ColorNumber(bitmap : TBitmap) : integer;
function  VisibleContrast(BackGroundColor : TColor) : TColor;
procedure SymmetricTile(bitmap : TBitmap);
function AdjustFontSize(canvas  : TCanvas;
                        radius  : integer;
                        maxSize : integer;
                        styles  : TFontStyles;
                        const s : string) : integer;
procedure PseudoAntiAlias(bm : TBItmap; d : integer; backColor : TColor);
function  LoadImageToBmp(name : WideString; bmp : TBitmap; tmpPath : string) : boolean;
procedure CopyPngTransparency(bmp : TBitmap; png : TPngObject);
procedure CopyBmpTransparency(bmp : TBitmap; png : TPngObject);
procedure VerticalSymetry(bitmap : TBitmap); overload;
procedure VerticalSymetry(png : TPngObject); overload;
function  GetColorBits : integer;
procedure SplitColor(color : integer; out red, green, blue : integer);
procedure PseudoAlphaBlend(bm : TBitmap; d : integer);
procedure CopyAlphaChannel(bmpSrc, bmpDest : TBItmap);
procedure SmoothResize(apng : TPngObject; NuWidth,NuHeight:integer);
procedure ApplyPngTransparency(png : TPngObject; alpha : double);

// ---------------------------------------------------------------------------

implementation

uses
  Sysutils, Math, Classes, Jpeg, GifImage,
  Define, Std, UnicodeUtils;

// UGraphic.res is declared in the dpr

{$RangeChecks Off}
{$OverFlowChecks Off}

// -- Globals ----------------------------------------------------------------

var
  //bmBlack : TBitmap;
  //bmWhite : TBitmap;
  bmBoard : TBitmap;
  bmWork  : TBitmap;
  bmDraw  : TBitmap;

// -- Standard routines ------------------------------------------------------

// -- Colors

procedure SplitColor(color : integer; out red, green, blue : integer);
begin
  red   := Color        and $FF;
  green := Color shr 8  and $FF;
  blue  := Color shr 16 and $FF
end;

// -- Circle

procedure WACircle(Canvas : Tcanvas; x, y, d, r, color, fill : integer);
begin
  with Canvas do
    begin
      Pen.Color := color; // fill
      if fill = -1
        then Brush.Style := bsClear
        else
          begin
            Brush.Style  := bsSolid;
            //Brush.Bitmap := nil;
            Brush.Color  := fill
          end;
      ellipse(x - r, y - r, x + r + 1, y + r + 1)
      //ellipse(x - r, y - r, x + r + 1, y + r) ref
    end
end;

// -- Disk

procedure WADisk(Canvas : Tcanvas; x, y, d, r, color : integer);
begin
  with Canvas do
    begin
      Pen.Color   := color;
      Brush.Color := color;
      Brush.Style := bsSolid;
      ellipse(x - r, y - r, x + r + 1, y + r + 1)
    end
end;

// -- Polyline

procedure WAPolyline(Canvas : Tcanvas;
                     x, y, d, color : integer; points : array of TPoint);
var
  i : integer;
begin
  for i := 0 to Length(points) - 1 do
    begin
      points[i].x := x - d + points[i].x;
      points[i].y := y - d + points[i].y
    end;

  with Canvas do
    begin
      Pen.Color := color;
      Polyline(points)
    end
end;

procedure AAPolyline(Canvas : Tcanvas;
                     x, y, d, penC, bckC : integer; points : array of TPoint);
var
  i : integer;
begin
  for i := 0 to Length(points) - 1 do
    begin
      points[i].x := x - d + points[i].x;
      points[i].y := y - d + points[i].y;
    end;

  for i := 0 to High(points) - 1 do
    AlphaLine(Canvas, points[i].x, points[i].y,
              points[i+1].x, points[i+1].y,
              penC, bckC)
end;

// -- Calling routines -------------------------------------------------------

// -- Circle

procedure UGCircle(Canvas : Tcanvas;
                   x, y, d, r, color : integer; fill : integer = -1);
begin
  WACircle(Canvas, x, y, d, r, color, fill)
end;

// -- Polyline

procedure UGPolyline(Canvas : Tcanvas;
                     x, y, d, color : integer; points : array of TPoint);
begin
  //{$ifdef GraphicDefault}
  Canvas.pen.Width := 1;
  WAPolyline(Canvas, x, y, d, color, points)
  //{$else}
  //AAPolyline(Canvas, x, y, d, color, clBlack, points)
  //{$endif}
end;

// -- Text writing with maximum transparency ---------------------------------

procedure BorderedText(s : string; can : TCanvas; aX, aY : integer; bg : TColor);
var
  bmp : TBitmap;
  buf : array[0 .. 50, 0 .. 100] of integer;
  w, h, i, j : integer;

procedure ScanBorder(i, j, i2, j2 : integer);
begin
  if (buf[i, j] = bg) and (buf[i2, j2] = bg) then
    begin
      buf[i, j] := clGreen;
      bmp.Canvas.Pixels[j, i] := clGreen
    end
end;

procedure ScanElem(i, j : integer);
var
  p, q : integer;
begin
  if buf[i, j] <> bg
    then exit;

  for p := i - 1 to i + 1 do
    for q := j - 1 to j + 1 do
      if (buf[p, q] <> bg) and (buf[p, q] <> clGreen)
        then exit;

  buf[i, j] := clGreen;
  bmp.Canvas.Pixels[j, i] := clGreen;

  ScanElem(i - 1, j);
  ScanElem(i, j - 1);
  ScanElem(i, j + 1);
  ScanElem(i + 1, j)
end;

begin
  // protect against buffer overflow 
  w := can.TextWidth (s);
  h := can.TextHeight(s);
  if (h > High(buf) + 1) or (w > High(buf[0]) + 1) then
    begin
      can.TextOut(aX - w div 2, aY - h div 2, s);
      exit
    end;
  
  // initialize new bitmap
  bmp := TBitmap.Create;
  bmp.Canvas.Font.Assign(can.Font);
  bmp.Width  := bmp.Canvas.TextWidth (s) + 0;//2;
  bmp.Height := bmp.Canvas.TextHeight(s) + 0;//2;
  bmp.Transparent := True;
  bmp.TransparentColor := clGreen;
  bmp.Canvas.Brush.Color := bg;
  bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));

  // write text on bitmap
  bmp.Canvas.TextOut(0, 0, s);//(1, 1, s);
  //bmp.SaveToFile('d:\gilles\volatil\tmp.bmp');

  // copy bitmap into buffer array
  for i := 0 to bmp.Height - 1 do
    for j := 0 to bmp.Width - 1 do
      buf[i, j] := bmp.Canvas.Pixels[j, i];

  // redefine background color (W2K can change it)
  bg := buf[0, 0];

  // scan vertical borders
  for i := 0 to bmp.Height - 1 do
    begin
      ScanBorder(i, 0, i, 1);
      ScanBorder(i, bmp.Width - 1, i, bmp.Width - 2)
    end;

  // scan horizontal borders
  for j := 1 to bmp.Width - 2 do
    begin
      ScanBorder(0, j, 1, j);
      ScanBorder(bmp.Height - 1, j, bmp.Height - 2, j)
    end;

  // scan inner pixels
  for j := 1 to bmp.Width - 2 do
    begin
      ScanElem(1, j);
      ScanElem(bmp.Height - 2, j);
    end;

  // draw bitmap on canvas
  dec(aX, bmp.Width  div 2);
  dec(aY, bmp.Height div 2);
  can.Draw(aX, aY, bmp);

  // free
  bmp.Free
end;

// -- Alphablending routines--------------------------------------------------

// -- Circle

procedure AlphaCircle(Canvas : Tcanvas;
                      CenterX, CenterY : integer;
                      Radius, LineWidth, Feather: single;
                      color : integer); overload;
var
  x, y, MaxRad, r2 : integer;
  Fact : double;
  ROPF2, ROMF2, RIPF2, RIMF2: double;
  OutRad, InRad, d : double;
  colRed, colGreen, colBlue : integer;

  procedure SetPixel(x, y : integer);
  var pix, Red, Green, Blue : TColor;
  begin
    pix   := Canvas.Pixels[x, y];
    Red   := pix        and $FF;
    Green := pix shr 8  and $FF;
    Blue  := pix shr 16 and $FF;
    Red   := Trunc(Fact * colRed   + (1 - Fact) * Red);
    Green := Trunc(Fact * colGreen + (1 - Fact) * Green);
    Blue  := Trunc(Fact * colBlue  + (1 - Fact) * Blue);
    Canvas.Pixels[x, y] := TColor(Red + Green shl 8 + Blue shl 16)
  end;

begin
  // Checks
  if Feather > LineWidth then Feather := LineWidth;

  // Split color
  colRed   := Color        and $FF;
  colGreen := Color shr 8  and $FF;
  colBlue  := Color shr 16 and $FF;

  // Determine some helpful values
  OutRad := Radius + LineWidth/2;
  InRad  := Radius - LineWidth/2;
  ROPF2  := sqr(OutRad + Feather/2);
  ROMF2  := sqr(OutRad - Feather/2);
  RIPF2  := sqr(InRad  + Feather/2);
  RIMF2  := sqr(InRad  - Feather/2);
  MaxRad := ceil(OutRad + Feather/2);

  for x := 0 to MaxRad do
    begin
      for y := 0 to MaxRad do
        begin
          r2 := sqr(x) + sqr(y);

          if r2 <  RIMF2 then continue;
          if r2 >= ROPF2 then continue;

          if r2 < RIPF2
            then d := sqrt(r2) - InRad
            else
              if r2 >= ROMF2
                then d := OutRad - sqrt(r2)
                else
                  begin
                    d := 0;
                    Canvas.Pixels[CenterX + x, CenterY + y] := color;
                    Canvas.Pixels[CenterX + x, CenterY - y] := color;
                    Canvas.Pixels[CenterX - x, CenterY + y] := color;
                    Canvas.Pixels[CenterX - x, CenterY - y] := color;
                    continue
                  end;

          Fact := d / Feather + 0.5;
          Fact := Math.Max(0, Math.Min(Fact, 1));

          SetPixel(CenterX + x, CenterY + y);
          if y > 0 then SetPixel(CenterX + x, CenterY - y);
          if x = 0 then continue;
          SetPixel(CenterX - x, CenterY + y);
          if y > 0 then SetPixel(CenterX - x, CenterY - y)
        end
    end
end;

procedure SetAlphaCircle(bitmap : TBitmap;
                       CenterX, CenterY : integer;
                       Radius, LineWidth, Feather: single;
                       color : integer); overload;
var
  x, y, MaxRad, r2 : integer;
  Fact : double;
  ROPF2, ROMF2, RIPF2, RIMF2: double;
  OutRad, InRad : double;

  procedure SetAlpha(x, y : integer; alpha : single);
  var
    line  : PRGBAQuadArray;
  begin
    line := bitmap.ScanLine[y];
    line[x].A := Round(255 * alpha)
  end;

begin
  // Checks
  if Feather > LineWidth then Feather := LineWidth;

  // Determine some helpful values
  OutRad := Radius + LineWidth/2;
  InRad  := Radius - LineWidth/2;
  ROPF2  := sqr(OutRad + Feather/2);
  ROMF2  := sqr(OutRad - Feather/2);
  RIPF2  := sqr(InRad  + Feather/2);
  RIMF2  := sqr(InRad  - Feather/2);
  MaxRad := ceil(OutRad + Feather/2);

  for x := 0 to MaxRad do
    begin
      for y := 0 to MaxRad do
        begin
          r2 := sqr(x) + sqr(y);

          if r2 < RIMF2
            then Fact := 1;
          if r2 < RIPF2
            then Fact := (sqrt(r2) - InRad)  / Feather + 0.5;
          if r2 < ROMF2
            then Fact := 1;
          if r2 < ROPF2
            then Fact := (OutRad - sqrt(r2)) / Feather + 0.5;
          if r2 >= ROPF2
            then continue; // Fact := 0;

          Fact := Math.Max(0, Math.Min(Fact, 1));
          //Fact := Sqr(Sqr(Fact));

          SetAlpha(CenterX + x, CenterY + y, Fact);
          SetAlpha(CenterX + x, CenterY - y, Fact);
          SetAlpha(CenterX - x, CenterY + y, Fact);
          SetAlpha(CenterX - x, CenterY - y, Fact)
        end
    end
end;

procedure ABCircle(Canvas : Tcanvas;
                   x, y, d, r, color : integer; fill : integer = -1);
begin
  if fill >= 0
    then WADisk(Canvas, x, y, d, r, fill);
  AlphaCircle(Canvas, x, y, r, 1{1}, 1{1}, color)
end;

// -- Stones

procedure AntiAliasedStone(Canvas : Tcanvas; x, y, d, r, color : integer);
begin
  ABCircle(Canvas, x, y, d, r, clBlack, color)
end;

procedure AntiAliasedStone(bitmap : TBitmap; x, y, d, r, color : integer);
begin
  if color >= 0
    then WADisk(bitmap.Canvas, x, y, d, r, color);
  AlphaCircle(bitmap.Canvas, x, y, r, 1{1}, 1{1}, clBlack);
  SetAlphaCircle(bitmap, x, y, r, 1{1}, 1{1}, clBlack)
end;

// -- Antialiased lines (experimental)

procedure AlphaLine(Canvas : TCanvas;
                    x1, y1, x2, y2, penC, backC : integer);
var
  xd, yd, grad, xf, yf, b1, b2 : double;
  swap, c1, c2, c3, x, y : integer;
  penR, penG, penB, backR, backG, backB : integer;
begin
  penR  := penC         and $FF;
  penG  := penC  shr 8  and $FF;
  penB  := penC  shr 16 and $FF;
  backR := backC        and $FF;
  backG := backC shr 8  and $FF;
  backB := backC shr 16 and $FF;

  xd := x2 - x1;
  yd := y2 - y1;

  if Abs(xd) > Abs(yd)
  then begin
    if x1 > x2
    then begin
      swap := x1; x1 := x2; x2 := swap;
      swap := y1; y1 := y2; y2 := swap;
      xd := x2 - x1;
      yd := y2 - y1
    end;

    grad := yd / xd;
    yf   := y1;

    for x := x1 to x2 do
      begin
        b1 :=  1 - Frac(yf);
        b2 :=      Frac(yf);

        c1 := Round(b1 * penR + b2 * backR) +
            Round(b1 * penG + b2 * backG) shl 8 +
            Round(b1 * penB + b2 * backB) shl 16;
        c2 := penC;
        c3 := Round(b2 * penR + b1 * backR) +
            Round(b2 * penG + b1 * backG) shl 8 +
            Round(b2 * penB + b1 * backB) shl 16;

        (**)
        Canvas.Pixels[x, Floor(yf)]     := c1;
        Canvas.Pixels[x, Floor(yf) + 1] := c3;
        (*
        Canvas.Pixels[x, Floor(yf)]     := c2;
        Canvas.Pixels[x, Floor(yf) - 1] := c1;
        Canvas.Pixels[x, Floor(yf) + 1] := c3;
        *)

        yf := yf + grad;
      end
  end
  else begin
    if y1 > y2
    then begin
      swap := x1; x1 := x2; x2 := swap;
      swap := y1; y1 := y2; y2 := swap;
      xd := x2 - x1;
      yd := y2 - y1
    end;

    grad := xd / yd;
    xf   := x1;

    for y := y1 to y2 do
      begin
        b1 := 1 - Frac(xf);
        b2 :=     Frac(xf);

        c1 := Round(b1 * penR + b2 * backR) +
            Round(b1 * penG + b2 * backG) shl 8 +
            Round(b1 * penB + b2 * backB) shl 16;
        c2 := penC;
        c3 := Round(b2 * penR + b1 * backR) +
            Round(b2 * penG + b1 * backG) shl 8 +
            Round(b2 * penB + b1 * backB) shl 16;

        (**)
        Canvas.Pixels[Floor(xf), y]     := c1;
        Canvas.Pixels[Floor(xf) + 1, y] := c3;
        (*
        Canvas.Pixels[Floor(xf), y]     := c2;
        Canvas.Pixels[Floor(xf) - 1, y] := c1;
        Canvas.Pixels[Floor(xf) + 1, y] := c3;
        *)

        xf := xf + grad;
      end
  end
end;

// -- General graphic functions ----------------------------------------------

// -- Average color of canvas

function MeanColor0(Canvas : TCanvas; Width, Height : integer) : TColor;
const
  nSamples = 20;
var
  sR, sG, sB, k, i, j, x : integer;
begin
  sR := 0;
  sG := 0;
  sB := 0;
  for k := 1 to nSamples do
    begin
      i := Random(Height);
      j := Random(Width);
      x := Canvas.Pixels[i, j]; //??
      inc(sR, x        and $FF);
      inc(sG, x shr 8  and $FF);
      inc(sB, x shr 16 and $FF)
    end;
  Result := (sR div nSamples) + (sG div nSamples) shl 8 + (sB div nSamples) shl 16
end;

function MeanColor(Canvas : TCanvas; Width, Height : integer) : TColor;
const
  nSamplesInRow = 7;
  nSamplesInCol = 7;
  nSamples      = nSamplesInRow * nSamplesInCol;
var
  sR, sG, sB, ki, kj, i, j, di, dj, x : integer;
begin
  di := Height div nSamplesInCol;
  dj := Width  div nSamplesInRow;
  sR := 0;
  sG := 0;
  sB := 0;
  for ki := 0 to nSamplesInCol - 1 do
    for kj := 0 to nSamplesInRow - 1 do
      begin
        i := ki * di + di div 2;
        j := kj * dj + dj div 2;
        x := Canvas.Pixels[j, i];  // j first!
        inc(sR, x        and $FF);
        inc(sG, x shr 8  and $FF);
        inc(sB, x shr 16 and $FF)
      end;
  Result := (sR div nSamples) + (sG div nSamples) shl 8 + (sB div nSamples) shl 16
end;

// -- Number of colors in bitmap (exit if find more than 256)
// -- from efg2

function ColorNumber(bitmap : TBitmap) : integer;
var
  line  : PRGBTripleArray;
  nColors, i, j, R, G, B : integer;
  Flags : array[Byte] of array of TBits;
begin
  bitmap.PixelFormat := pf24bit;
  for i := 0 to 255 do
    SetLength(Flags[i], 0);
  nColors := 0;

  try
    for i := 0 to bitmap.Height - 1 do
      begin
        line := bitmap.ScanLine[i];
        for j := 0 to bitmap.Width - 1 do
          begin
            R := line[j].R;
            G := line[j].G;
            B := line[j].B;
            if Length(Flags[R]) = 0 then
              SetLength(Flags[R], 256);

            if not Assigned(Flags[R, G]) then
              begin
                Flags[R, G] := TBits.Create;
                Flags[R, G].Size := 256
              end;

            if not Flags[R, G].Bits[B]
              then inc(nColors);

            if nColors > 256 then
              begin
                nColors := 257;
                exit
              end;

            Flags[R, G].Bits[B] := True
          end
      end
  finally
    for i := 0 to 255 do
      if Length(Flags[i]) > 0 then
        begin
          for j := 0 to 255 do
            if Assigned(Flags[i, j])
              then Flags[i, j].Free;
          SetLength(Flags[i], 0)
        end;

    Result := nColors
  end
end;

// -- Best color for writing on a given background
// -- from efg2

function VisibleContrast(BackGroundColor : TColor) : TColor;
const
  cHalfBrightness = (0.3 * 255 + 0.59 * 255 + 0.11 * 255) / 2.0;
var
  Brightness : double;
begin
  with TRGBQuad(BackGroundColor) do
    Brightness := 0.3 * rgbRed + 0.59 * rgbGreen + 0.11 * rgbBlue;
  if Brightness > cHalfBrightness
    then Result := clBlack
    else Result := clWhite
end;

// -- Color resolution -------------------------------------------------------
// -- from efg2

function GetColorBits : integer;
var
  dc : hDC;
begin
  dc := GetDC(hWnd_DeskTop);
  try
    Result := GetDeviceCaps(dc, PLANES) * Min (24, GetDeviceCaps(dc, BITSPIXEL))
  finally
    ReleaseDC(0, dc)
  end
end;

// -- Adjustement of font size -----------------------------------------------

// -- Cache

type
  TAdjustFont = class
     _radius : integer;
     _s      : string;
     _styles : TFontStyles;
     _maxSize: integer;
     _size   : integer
  end;

  TAdjustFontList = class(TList)
    destructor Destroy; override;
    procedure Clear; override;
  end;

destructor TAdjustFontList.Destroy;
begin
  Clear;
  inherited Destroy
end;

procedure TAdjustFontList.Clear;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    TAdjustFont(Items[i]).Free;
  inherited Clear
end;

var
  LAdjustFont : TAdjustFontList;

// -- Strategies for finding the biggest font for a given string inside radius

// -- Width strategy

function WidthStrategy(canvas  : TCanvas;
                       radius  : integer;
                       styles  : TFontStyles;
                       const s : string) : integer;
var
  d, w : integer;
begin
  d := 2 * radius;

  with canvas do
    begin
      Font.Name   := 'Arial';
      Font.Height := -d;
      Font.Size   := Font.Size + 1;
      Font.Style  := styles;
      repeat
        Font.Size := Font.Size - 1;
        w := TextWidth(s);
      until (Font.Size <= 2) or (w < d);

      Result := Font.Size
    end
end;

// -- Diagonal strategy

function DiagonalStrategy(canvas  : TCanvas;
                          radius  : integer;
                          maxSize : integer;
                          styles  : TFontStyles;
                          const s : string) : integer;
var
  w, h : integer;
  r2 : integer;
  d2 : double;
begin
  r2 := sqr(radius - 0);

  with canvas do
    begin
      Font.Name  := 'Arial';
      Font.Size  := Min(maxSize, WidthStrategy(canvas, radius, styles, s));
      Font.Style := styles;
      repeat
        Font.Size := Font.Size - 1;
        Result    := Font.Size;
        w := TextWidth (s);
        h := TextHeight(s);
        d2 := sqr(ceil(w / 2)) + sqr(ceil(h / 2))
        //d2 := sqr(w / 2) + sqr(h / 2)
      until (Font.Size <= 2) or (d2 < r2)
    end
end;

// -- Rectangular frame strategy

function RectangularStrategy(canvas  : TCanvas;
                             radius  : integer;
                             maxSize : integer;
                             styles  : TFontStyles;
                             const s : string) : integer;
var
  bmp : TBitmap;
  w, h : integer;
  r2 : integer;
  d2 : double;
  i, j, iMin, iMax, jMin, jMax : integer;
begin
  bmp := TBitmap.Create;
  r2  := sqr(radius - 0);

  with bmp.Canvas do
    begin
      Font.Name   := 'Arial';
      Font.Style  := styles;
      Font.Color  := clBlack;
      Brush.Color := clWhite;
      Font.PixelsPerInch := canvas.Font.PixelsPerInch;
      Font.Size   := Min(maxSize, WidthStrategy(canvas, radius, styles, s)) + 1; // 20 pour Seailles

      repeat
        Font.Size := Font.Size - 1;
        Result    := Font.Size;
        w := TextWidth (s);
        h := TextHeight(s);

        bmp.Width := w;
        bmp.Height:= h;
        TextOut(0, 0, s);
        //bmp.SaveToFile('d:\gilles\volatil\tmp.bmp');

        iMin := h;
        iMax := -1;
        jMin := w;
        jMax := -1;
        for i := 0 to h - 1 do
          for j := 0 to w - 1 do
            if Pixels[j, i] = clBlack then
              begin
                if i < iMin then iMin := i;
                if i > iMax then iMax := i;
                if j < jMin then jMin := j;
                if j > jMax then jMax := j;
              end;
        w := jMax - jMin + 1;
        h := iMax - iMin + 1;

        d2 := sqr(ceil(w / 2)) + sqr(ceil(h / 2))
        //d2 := sqr(w / 2) + sqr(h / 2)
      until (Font.Size <= 2) or (d2 < r2)
    end;

  bmp.Free;
  Canvas.Font.Size := Result
end;

// -- Functions

function AdjustSizeCanvas(canvas  : TCanvas;
                          radius  : integer;
                          maxSize : integer;
                          styles  : TFontStyles;
                          const s : string) : integer;
var
  i : integer;
  p : TAdjustFont;
begin
  // search in cache first
  for i := 0 to LAdjustFont.Count - 1 do
    with TAdjustFont(LAdjustFont[i])  do
      if (_radius  = radius) and
         (_s       = s)      and
         (_styles  = styles) and
         (_maxSize = maxSize)then
        begin
          Result := _size;
          exit
        end;

  Result := RectangularStrategy(canvas, Max(1, radius), maxSize, styles, s);

  p := TAdjustFont.Create;
  p._radius  := radius;
  p._s       := s;
  p._styles  := styles;
  p._maxSize := maxSize;
  p._size    := Result;
  LAdjustFont.Add(p)
end;

function AdjustSizeMeta(canvas  : TCanvas;
                        radius  : integer;
                        maxSize : integer;
                        styles  : TFontStyles;
                        const s : string) : integer;
begin
  Result := WidthStrategy(canvas, radius, styles, s)
end;

// -- Entry point

// Note : the calculation doesn't work when exporting metafiles (page, rtf,
// wmf) but is ok for ExportPos. For exporting, we use the working calculation.

function AdjustFontSize(canvas  : TCanvas;
                        radius  : integer;
                        maxSize : integer;
                        styles  : TFontStyles;
                        const s : string) : integer;
begin
  if canvas is TMetafileCanvas
    then result := AdjustSizeMeta  (canvas, radius, maxSize, styles, s)
    else result := AdjustSizeCanvas(canvas, radius, maxSize, styles, s)
end;

// -- Text envelope ----------------------------------------------------------
// -- not used

procedure TextEnvelope(canvas : TCanvas;
                       const s : string;
                       out iMin, jMin, iMax, jMax : integer);
var
  bmp : TBitmap;
  w, h : integer;
  i, j : integer;
begin
  bmp := TBitmap.Create;
  bmp.Canvas.Font.Assign(canvas.Font);

  with bmp.Canvas do
    begin
      Font.Color  := clBlack;
      Brush.Color := clWhite;
      w := TextWidth (s);
      h := TextHeight(s);

      bmp.Width := w;
      bmp.Height:= h;
      FillRect(Rect(0, 0, w, h));
      TextOut(0, 0, s);
      //bmp.SaveToFile('\gilles\volatil\tmp.bmp');

      iMin := h;
      iMax := -1;
      jMin := w;
      jMax := -1;
      for i := 0 to h - 1 do
        for j := 0 to w - 1 do
          if Pixels[j, i] = clBlack then
            begin
              if i < iMin then iMin := i;
              if i > iMax then iMax := i;
              if j < jMin then jMin := j;
              if j > jMax then jMax := j;
            end;
    end;

  bmp.Free;
end;

// -- Vertical symmetry for light origine -------------------------------------

procedure VerticalSymetry(bitmap : TBitmap);
var
  line  : PRGBTripleArray;
  triple : TRGBTriple;
  i, j : integer;
begin
  bitmap.PixelFormat := pf24bit;

  for i := 0 to bitmap.Height - 1 do
    begin
      line := bitmap.ScanLine[i];

      for j := 0 to bitmap.Width div 2 do
        begin
          triple := line[j];
          line[j] := line[bitmap.Width - 1 - j];
          line[bitmap.Width - 1 - j] := triple
        end
    end
end;

procedure VerticalSymetryV1(png : TPngObject);
var
  x, y, v : integer;
begin
  for y := 0 to png.Height - 1 do
    for X := 0 to (png.Width - 1) div 2 do
      begin
        v := png.Pixels[x, y];
        png.Pixels[x, y] := png.Pixels[png.Width - x - 1, y];
        png.Pixels[png.Width - x - 1, y] := v
   end
end;

procedure VerticalSymetry(png : TPngObject);
var
  pixelLine : pRGBLine;
  alphaLine : PngImage.pbytearray;
  p : TColor;
  x, y, v : integer;
begin
  for y := 0 to png.Height - 1 do
    begin
      pixelLine := png.Scanline[y];
      alphaLine := png.AlphaScanline[y];

      for X := 0 to (png.Width - 1) div 2 do
        begin
(*        // For unknown reason, doesnt work for diameter <= 9 with
          // sente goban stones.
          var p : tagRGBTriple;
          p := pixelLine[x];
          pixelLine[x] := pixelLine[png.Width - x - 1];
          pixelLine[png.Width - x - 1] := p;
*)
          p := png.Pixels[x, y];
          png.Pixels[x, y] := png.Pixels[png.Width - x - 1, y];
          png.Pixels[png.Width - x - 1, y] := p;

          v := alphaLine[x];
          alphaLine[x] := alphaLine[png.Width - x - 1];
          alphaLine[png.Width - x - 1] := v;
        end
    end
end;

// -- Symmetric tiling : duplicate with horizontal and vertical symmetries ---

procedure SymmetricTile(bitmap : TBitmap);
var
  halfWidth, halfHeight : integer;
  line1, line2  : PRGBTripleArray;
  i, j : integer;
begin
  bitmap.PixelFormat := pf24bit;

  halfWidth     := bitmap.Width;
  halfHeight    := bitmap.Height;
  bitmap.Width  := 2 * halfWidth;
  bitmap.Height := 2 * halfHeight;

  for i := 0 to halfHeight - 1 do
    begin
      line1 := bitmap.ScanLine[i];
      line2 := bitmap.ScanLine[bitmap.Height - 1 - i];

      for j := 0 to halfWidth - 1 do
        line1[bitmap.Width - 1 - j] := line1[j];

      for j := 0 to bitmap.Width - 1 do
        line2[j] := line1[j]
    end
end;

// -- Loading of stones and background texture -------------------------------

// -- Loading of drawn stones

// not used
procedure GetBmStonesDrawn(bmBlack, bmWhite : TBitmap; radius, backColor : integer);
var
  d, n, w : integer;
  rec : TRect;
begin
  n := GetColorBits;
  if backColor <> clWhite
    then w := clWhite
    else
      if n >= 24
        then w := clWhite - 2
        else w := clWhite - 4*(256*256+256+1);

  d := 2 * radius + 1;

  rec := Rect(0, 0, d, d);
  bmBlack.Height := d;
  bmBlack.Width  := d;
  bmWhite.Height := d;
  bmWhite.Width  := d;
  bmBlack.Canvas.Brush.Color := backColor;
  bmWhite.Canvas.Brush.Color := backColor;
  bmBlack.Canvas.FillRect(rec);
  bmWhite.Canvas.FillRect(rec);
  AntiAliasedStone(bmBlack.Canvas, radius, radius, -1, radius, clBlack);
  AntiAliasedStone(bmWhite.Canvas, radius, radius, -1, radius, w)
end;

// -- Pseudo anti alias for RubyGo stones

procedure PseudoAntiAlias(bm : TBItmap; d : integer; backColor : TColor);
var
  r, r1, r2, d2, i, j, x, colBack : integer;
  colRed, colGreen, colBlue, Red, Green, Blue : integer;
  Fact : single;
begin
  r        := d div 2;
  r1       := sqr(r - 1);
  r2       := sqr(r + 1);
  colBack  := bm.Canvas.Pixels[0, 0];
  colRed   := backColor        and $FF;
  colGreen := backColor shr 8  and $FF;
  colBlue  := backColor shr 16 and $FF;

  for i := 0 to d - 1 do
    for j := 0 to d - 1 do
      begin
        d2 := sqr(i - r) + sqr(j - r);
        if (d2 < r1) or (d2 > r2)
          then continue;

        x := bm.Canvas.Pixels[i, j];
        //if x = clWhite then continue;
        if x = colBack then continue;
        if (i = 0) or (i = d - 1) or (j = 0) or (j = d - 1) or
          (bm.Canvas.Pixels[i - 1, j    ] = colBack) or
          (bm.Canvas.Pixels[i - 1, j - 1] = colBack) or
          (bm.Canvas.Pixels[i    , j - 1] = colBack) or
        //(bm.Canvas.Pixels[i + 1, j - 1] = colBack) or //
          (bm.Canvas.Pixels[i + 1, j    ] = colBack) or
          (bm.Canvas.Pixels[i + 1, j + 1] = colBack) or
          (bm.Canvas.Pixels[i    , j + 1] = colBack) or
          (bm.Canvas.Pixels[i - 1, j + 1] = colBack)
          then
            begin
              Red   := x        and $FF;
              Green := x shr 8  and $FF;
              Blue  := x shr 16 and $FF;
              Fact  := Red / 255;
              Red   := Round(Fact * colRed   + (1 - Fact) * Red);
              Green := Round(Fact * colGreen + (1 - Fact) * Green);
              Blue  := Round(Fact * colBlue  + (1 - Fact) * Blue);
              bm.Canvas.Pixels[i, j] := Red + Green shl 8 + Blue shl 16
            end
      end
end;

procedure PseudoAlphaBlend(bm : TBitmap; d : integer);
var
  r, r1, r2, d2, i, j : integer;
  line  : PRGBAQuadArray;
begin
  assert(bm.PixelFormat = pf32bit);

  r        := d div 2;
  r1       := sqr(r - 1);
  r2       := sqr(r + 1);

  for i := 0 to d - 1 do
  begin
    line := bm.ScanLine[i];

    for j := 0 to d - 1 do
      begin
        d2 := sqr(i - r) + sqr(j - r);

        if (d2 > r2)
          then line[j].A := 0
          else
            if(d2 < r1)
              then line[j].A := 255
              else line[j].A := 255 - line[j].R
      end
  end
end;

procedure CopyAlphaChannel(bmpSrc, bmpDest : TBItmap);
var
  i, j : integer;
  lineSrc, lineDest  : PRGBAQuadArray;
begin
  assert(bmpSrc.PixelFormat = pf32bit);
  assert(bmpSrc.Width = bmpDest.Width);

  for i := 0 to bmpSrc.Width - 1 do
  begin
    lineSrc := bmpSrc.ScanLine[i];
    lineDest := bmpDest.ScanLine[i];

    for j := 0 to bmpSrc.Height - 1 do
      lineDest[j].A := lineSrc[j].A
  end
end;

// -- Loading of bitmap stones

// not used
procedure GetBmStoneFromResources(bmp : TBitmap; radius, color : integer);
var
  s : string;
begin
  if color = 1
    then s := 'BLACK' + IntToStr(2 * radius + 1)
    else s := 'WHITE' + IntToStr(2 * radius + 1);

  bmp.LoadFromResourceName(HInstance, s)
end;

// not used
procedure GetBmStonesBitmap(bmBlack, bmWhite : TBitmap; radius, backColor : integer);
var
  d : integer;
  rec : TRect;
  s1, s2 : string;
begin
  d := 2 * radius + 1;

  if (radius >= 5) and (radius <= 30)
    then
      begin
        s1 := 'BLACK' + IntToStr(d);
        s2 := 'WHITE' + IntToStr(d);
        bmBlack.LoadFromResourceName(HInstance, s1);
        bmWhite.LoadFromResourceName(HInstance, s2);
        {$define ref}
        {$ifdef ref}
        bmBlack.PixelFormat := pf24bit;
        bmWhite.PixelFormat := pf24bit;
        PseudoAntiAlias(bmBlack, d, backColor);
        PseudoAntiAlias(bmWhite, d, backColor)
        {$else}
        bmBlack.PixelFormat := pf32bit;
        bmWhite.PixelFormat := pf32bit;
        PseudoAlphaBlend(bmBlack, d, backColor);
        //PseudoAlphaBlend(bmWhite, d, backColor);
        CopyAlphaChannel(bmBlack, bmWhite);
        //bmBlack.SaveToFile('\gilles\volatil\black.bmp');
        //bmWhite.SaveToFile('\gilles\volatil\white.bmp');
        {$endif}
      end
    else
      begin
        if radius < 5
          then radius := 5
          else radius := 30;
        GetBmStonesBitmap(bmWork, bmDraw, radius, backColor); // use available bmp vars
        rec := Rect(0, 0, d, d);
        bmBlack.Height := d;
        bmBlack.Width  := d;
        bmWhite.Height := d;
        bmWhite.Width  := d;
        bmBlack.Canvas.FillRect(rec);
        bmWhite.Canvas.FillRect(rec);
        bmBlack.Canvas.StretchDraw(rec, bmWork);
        bmWhite.Canvas.StretchDraw(rec, bmDraw)
      end;
end;

// -- Loading of stones

// not used
procedure GetBmStones(bmBlack, bmWhite : TBitmap;
                      radius, style : integer;
                      backColor : integer = clWhite;
                      lightSource : TLightSource = lsTopRight;
                      stoneGetter : TStoneGetter = nil);
begin
  assert(False, 'Obsolete');
  
  if radius <= 1
    then radius := 1;

  case style of // cf define.pas
    dsDrawing :  GetBmStonesDrawn (bmBlack, bmWhite, radius, backColor);
    dsDefault :  GetBmStonesBitmap(bmBlack, bmWhite, radius, backColor);
    //dsJago    :  StonesPaint      (bmBlack, bmWhite, radius * 2 + 1, backColor, True);
    //dsCustom  :  GetBmStonesCustom(bmBlack, bmWhite, radius, backColor, stoneGetter);
  end;

  if (lightSource = lsTopLeft) and (style in [dsDefault, dsJago])
    then
      begin
        VerticalSymetry(bmBlack);
        VerticalSymetry(bmWhite)
      end;

  //bmBlack.SaveToFile('\Gilles\Go\Drago\black.bmp');
  //bmWhite.SaveToFile('\Gilles\Go\Drago\white.bmp')
end;

// == Drawing of ghost stones ================================================

// -- Ghost stones with 1 pixel out of 2 from background

// not used
procedure GetGhostStone1on2(stone, ghost : TBitmap; avoidBlack : boolean);
var
  back, i, j : integer;
begin
  ghost.Assign(stone);
  back := stone.Canvas.Pixels[0, 0];

  for i := 0 to stone.Height - 1 do
    begin
      for j := 0 to stone.Width - 1 do
        if Odd(i + j) then
          if (not avoidBlack) or (stone.Canvas.Pixels[i, j] <> clBlack) // ?
            then ghost.Canvas.Pixels[i, j] := back // ?
    end
end;

// -- Ghost stones with alphablending with background mean color

// not used
procedure GetGhostStoneAlpha(stone, ghost : TBitmap; backg : integer; alpha : double);
var
  trans, backRed, backGreen, backBlue, i, j : integer;
  pix, pixRed, pixGreen, pixBlue : integer;
begin
  ghost.Assign(stone);

  trans     := stone.Canvas.Pixels[0, 0];
  backRed   := backg        and $FF;
  backGreen := backg shr 8  and $FF;
  backBlue  := backg shr 16 and $FF;

  for i := 0 to stone.Height - 1 do
    begin
      for j := 0 to stone.Width - 1 do
        begin
          pix := stone.Canvas.Pixels[j, i];
          if pix <> trans then
            begin
              pixRed   := pix        and $FF;
              pixGreen := pix shr 8  and $FF;
              pixBlue  := pix shr 16 and $FF;
              pixRed   := Round(alpha * backRed   + (1 - alpha) * pixRed);
              pixGreen := Round(alpha * backGreen + (1 - alpha) * pixGreen);
              pixBlue  := Round(alpha * backBlue  + (1 - alpha) * pixBlue);
              ghost.Canvas.Pixels[j, i] := pixRed + pixGreen shl 8 + pixBlue shl 16;
            end
        end
    end
end;

// -- Ghost stones with alphablended circles

// not used
procedure GetGhostStoneCircle(stone, ghost : TBitmap; radius, backg, color: integer);
var
  d : integer;
  rec : TRect;
begin
  d := 2 * radius + 1;

  rec := Rect(0, 0, d, d);
  ghost.Height := d;
  ghost.Width  := d;
  ghost.Canvas.Brush.Color := backg;
  ghost.Canvas.FillRect(rec);

  AlphaCircle(ghost.Canvas, radius, radius, radius-1, 1, 1, color)
end;

// -- Copy of png transparency

procedure CopyPngTransparency(bmp : TBitmap; png : TPngObject);
var
  i, j : integer;
  line  : PRGBAQuadArray;
begin
  for i := 0 to bmp.Height - 1 do
    begin
      line := bmp.ScanLine[i];
      for j := 0 to bmp.Width - 1 do
        line[j].A := png.AlphaScanline[i][j]
    end
end;

procedure CopyBmpTransparency(bmp : TBitmap; png : TPngObject);
var
  i, j : integer;
  line  : PRGBAQuadArray;
begin
  for i := 0 to bmp.Height - 1 do
    begin
      line := bmp.ScanLine[i];
      for j := 0 to bmp.Width - 1 do
        png.AlphaScanline[i][j] := line[j].A
    end
end;

procedure ApplyPngTransparency(png : TPngObject; alpha : double);
var
  i, j : integer;
begin
  for i := 0 to png.Height - 1 do
    for j := 0 to png.Width - 1 do
      png.AlphaScanline[i][j] := Round(png.AlphaScanline[i][j] * alpha)
end;

procedure SmoothResize(apng : TPngObject; NuWidth,NuHeight:integer);
var
  xscale, yscale         : Single;
  sfrom_y, sfrom_x       : Single;
  ifrom_y, ifrom_x       : Integer;
  to_y, to_x             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue, new_alpha    : Integer;
  new_colortype          : Integer;
  total_red, total_green : Single;
  total_blue, total_alpha: Single;
  IsAlpha                : Boolean;
  ix, iy                 : Integer;
  bTmp : TPngObject;
  sli, slo : pRGBLine;
  ali, alo: PngImage.pbytearray;
begin
  if not (apng.Header.ColorType in [COLOR_RGBALPHA, COLOR_RGB]) then
    raise Exception.Create('Only COLOR_RGBALPHA and COLOR_RGB formats' +
    ' are supported');
  IsAlpha := apng.Header.ColorType in [COLOR_RGBALPHA];
  if IsAlpha then new_colortype := COLOR_RGBALPHA else
    new_colortype := COLOR_RGB;
  bTmp := Tpngobject.CreateBlank(new_colortype, 8, NuWidth, NuHeight);
  //xscale := bTmp.Width / (apng.Width-1);
  //yscale := bTmp.Height / (apng.Height-1);
  xscale := bTmp.Width / (apng.Width);
  yscale := bTmp.Height / (apng.Height);
  for to_y := 0 to bTmp.Height-1 do begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];
    for to_x := 0 to bTmp.Width-1 do begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      total_alpha  := 0.0;
      for ix := 0 to 1 do if ifrom_x + ix < apng.Width - 1 then begin
        for iy := 0 to 1 do if ifrom_y + iy < apng.Height - 1 then begin
          sli := apng.Scanline[ifrom_y + iy];
          if IsAlpha then ali := apng.AlphaScanline[ifrom_y + iy];
          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;
          if IsAlpha then new_alpha := ali[ifrom_x + ix];
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
          if IsAlpha then total_alpha  := total_alpha  + new_alpha  * weight;
        end;
      end;
      slo := bTmp.ScanLine[to_y];
      if IsAlpha then alo := bTmp.AlphaScanLine[to_y];
      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);
      if isAlpha then alo[to_x] := Round(total_alpha);
    end;
  end;
  apng.Assign(bTmp);
  bTmp.Free;
end;

// -- Loading of an image file into a bitmap ---------------------------------

function LoadImageToBmp(name : WideString; bmp : TBitmap; tmpPath : string) : boolean;
var
  ext : string;
  jpg : TJPEGImage;
  gif : TGifImage;
  png : TPngObject;
begin
  if name <> AnsiString(name)
    then name := CopyFileToAnsiNameTmpFile(name, tmpPath);

  Result := True;
  ext := LowerCase(ExtractFileExt(name));

  // -- BMP
  if ext = '.bmp' then
    begin
      try
        bmp.LoadFromFile(name);
      except
        Result := False;
      end;
      exit
    end;
  // -- JPG
  if ext = '.jpg' then
    begin
      try
        try
          jpg := TJPEGImage.Create;
          jpg.LoadFromFile(name);
          bmp.Assign(jpg);
        except
          Result := False
        end
      finally
        jpg.Free;
      end;
      exit
    end;
  // -- GIF
  if ext = '.gif' then
    begin
      try
        try
          gif := TGifImage.Create;
          gif.LoadFromFile(name);
          bmp.Assign(gif);
        except
          Result := False;
        end
      finally
        gif.Free;
      end;
      exit
    end;
  // -- PNG
  if ext = '.png' then
    begin
      try
        try
          png := TPngObject.Create;
          png.LoadFromFile(name);
          bmp.Assign(png);
        except
          Result := False
        end
      finally
        png.Free;
      end;
      exit
    end;
  // Other extensions
  Result := False
end;

// -- Loading of background texture ------------------------------------------

function GetBmBoard : TBitmap;
begin
  Result := bmBoard
end;

// ---------------------------------------------------------------------------

initialization
  bmWork                  := TBitmap.Create;
  bmDraw                  := TBitmap.Create;
 //bmWork.PixelFormat      := pf24bit;
 //bmDraw.PixelFormat      := pf24bit;
  bmBoard                 := TBitmap.Create;
  bmBoard.Handle          := LoadBitmap(HInstance, 'BOARD');
  LAdjustFont             := TAdjustFontList.Create;
finalization
  bmWork.Free;
  bmDraw.Free;
  LAdjustFont.Free
end.
