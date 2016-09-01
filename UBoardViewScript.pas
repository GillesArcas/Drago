// ---------------------------------------------------------------------------
// -- Drago -- Board view for PDF through scripting -- UBoardViewScript.pas --
// ---------------------------------------------------------------------------

unit UBoardViewScript;

// ---------------------------------------------------------------------------

interface

uses
  Graphics, Classes,
  UBoardView, UBoardViewMetric;

type
  TBoardViewScript = class(TBoardViewMetric)

  public
    // list of delayed graphic commands for PDF
    ComCanvas : TStringList;

    constructor Create(aCanvas : TCanvas);
    destructor  Destroy; override;
    procedure   SetDim(aWidth, aHeight : integer; maxDiam : integer = 61); override;
    procedure   SetTextColors(inter, mrk2 : integer;
                              var pen, back : integer;
                              var style : TBrushStyle); override;
    procedure   DrawStone(i, j, color : integer); override;
    procedure   DrawTriangle(i, j, color : integer); override;
    procedure   DrawSquare(i, j, color : integer); override;
    procedure   DrawBullet(i, j, inter, color : integer); override;
    procedure   DrawCross (i, j, color : integer); override;
    procedure   DrawCircle(i, j, color : integer); override;

    procedure   DrawText(i, j, inter, mrk2 : integer; const s : string;
                         sizeText : TSizeText;
                         txtColor : integer = 0); override;
    function    GetComCanvas : TStringList; override;
  protected
    function    MaxFontSize : integer; override;
    procedure   SetLineParameters; override;
    procedure   DrawOneLine(k, x0, y0, x1, y1 : integer); override;
    procedure   DrawOneHoshi(x, y, r : integer); override;
    procedure   SetCoordParameters; override;
    function    CoordTextWidth(const s : string) : integer; override;
    function    CoordTextHeight : integer; override;
    procedure   DrawOneCoord(x, y : integer; const s : string); override;
    procedure   DrawBackground; override;
  private
    procedure   DrawTextScript(i, j, inter, mrk2, size, penCol : integer;
                               s : string;
                               empty : boolean;
                               bold : boolean = True);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  Define, Std,
  UBackground,
  UStatus,
  FontMetrics;

// -- Constructors ----------------------------------------------------------

constructor TBoardViewScript.Create(aCanvas : TCanvas);
begin
  inherited Create;

  Canvas := aCanvas;
end;

// -- Destructor -------------------------------------------------------------

destructor TBoardViewScript.Destroy;
begin
  inherited Destroy
end;

// -- Accessors --------------------------------------------------------------

function TBoardViewScript.GetComCanvas : TStringList;
begin
  Result := ComCanvas
end;

// -- Setting of dimensions --------------------------------------------------

procedure TBoardViewScript.SetDim(aWidth, aHeight : integer; maxDiam : integer = 61);
var
  fullSize : integer;
  N, W, S, E : double;
begin
  inherited SetDim(aWidth, aHeight, maxDiam);

  fullSize := BoardSize * InterWidth;
  N := NthFloat(Settings.PdfAddedBorder, 1, ';');
  W := NthFloat(Settings.PdfAddedBorder, 2, ';');
  S := NthFloat(Settings.PdfAddedBorder, 3, ';');
  E := NthFloat(Settings.PdfAddedBorder, 4, ';');

  inc(wBorderW , Round(fullSize * W));
  inc(wBorderN , Round(fullSize * N));
  inc(xMin     , Round(fullSize * W));
  inc(yMin     , Round(fullSize * N));

  inc(ExtWidth , Round(fullSize * (W + E)));
  inc(ExtHeight, Round(fullSize * (N + S)))
end;

function TBoardViewScript.MaxFontSize : integer;
begin
  Result := MaxInt
end;

// -- Display of board -------------------------------------------------------

// -- Draw background of whole board

procedure TBoardViewScript.DrawBackground;
var
  color : integer;
begin
  if Settings.PdfUseBoardColor then
    begin
      color := BoardBack.Color;
      ComCanvas.Add(Format('StrokeColor %d', [color]));
      ComCanvas.Add(Format('FillColor %d', [color]));
      ComCanvas.Add(Format('Fillpoly %d %d %d %d %d %d %d %d',
                           [0, 0, ExtWidth, 0,
                            ExtWidth, ExtHeight, 0, ExtHeight]))
    end;
end;

// -- Lines

procedure TBoardViewScript.SetLineParameters;
begin
  ComCanvas.Add(Format('StrokeColor %d', [0]))
end;

procedure TBoardViewScript.DrawOneLine(k, x0, y0, x1, y1 : integer);
var
  w : double;
begin
  if ThickEdge and ((k = 1) or (k = BoardSize))
    then w := Settings.PdfDblLineWidth
    else w := Settings.PdfLineWidth;

  ComCanvas.Add(Format('LineWidth %f', [w]));
  ComCanvas.Add(Format('Polyline %d %d %d %d', [x0, y0, x1, y1]))
end;

// -- Hoshis

procedure TBoardViewScript.DrawOneHoshi(x, y, r : integer);
var
  rf : real;
begin
  rf := Radius * Settings.PdfHoshiStoneRatio;
  ComCanvas.Add(Format('Circle %d %d %f %d %d',
                       [x, y, rf, clBlack, clBlack]))
end;

// -- Coordinates

procedure TBoardViewScript.SetCoordParameters;
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

function TBoardViewScript.CoordTextWidth(const s : string) : integer;
begin
  Result := Canvas.TextWidth(s) // approximate result
end;

function TBoardViewScript.CoordTextHeight : integer;
var
  fsize, capHeight, dy : double;
begin
  fsize     := CoorFontSize * NthFloat(Settings.PdfFontSizeAdjust, 1, ';');
  capHeight := HelveticaLightMetrics[pred('0'), 0];
  dy        := (capHeight / 1) * fsize / 1000;
  Result    := -Round(dy)
end;

procedure TBoardViewScript.DrawOneCoord(x, y : integer; const s : string);
begin
  ComCanvas.Add(Format('TextOut %d %d %s %d %d',
                      [x, y, s, CoorFontSize, CoordBack.PenColor]))
end;

// -- Handling of colors -----------------------------------------------------

procedure TBoardViewScript.SetTextColors(inter, mrk2 : integer;
                                         var pen, back : integer;
                                         var style : TBrushStyle);
begin
  case inter of
    Empty : pen := clBlack;
    Black : pen := clWhite;
    White : pen := clBlack;
  end;

  if inter <> Empty
    then style := bsClear
    else
      begin
        style := bsSolid;
        back  := clWhite
      end
end;

// -- Display of stones ------------------------------------------------------

procedure TBoardViewScript.DrawStone(i, j, color : integer);
var
  x, y : integer;
  r : double;
begin
  ij2xy(i, j, x, y);

  if color = Black
    then color := clBlack
    else color := clWhite;

  r := Radius * Settings.PdfRadiusAdjust;

  ComCanvas.Add(Format('LineWidth %f', [Settings.PdfCircleWidth]));
  ComCanvas.Add(Format('Circle %d %d %f %d %d', [x, y, r, clBlack, color]))
end;

// -- Display of marks -------------------------------------------------------

// -- Text marks

procedure TBoardViewScript.DrawText(i, j, inter, mrk2 : integer;
                                    const s : string;
                                    sizeText : TSizeText;
                                    txtColor : integer = 0);
var
  x, y, penCol, backCol, size, offset : integer;
  style : TBrushStyle;
  bold, isEmpty : boolean;
begin
  size := FontSizeForText(s, sizeText);
  bold := Settings.PdfBoldTextOnBoard;
  isEmpty := (inter = Empty);
  SetTextColors(inter, mrk2, penCol, backCol, style);

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
      DrawTextScript(i, j, inter, mrk2, size, penCol, s, isEmpty, bold)
    end
end;

// s is a format string: f1 or f1;f2 or f1;f2;f3
// f1, scale factor for ... 

function AdjustFactor(const s : string) : double;
begin
  // use 1st factor when length > 1
  if Length(s) > 1 then
    begin
      // get 1st value
      Result := NthFloat(Settings.PdfFontSizeAdjust, 1, ';');

      // if 0, the value is incorrectly stored, use default
      if Result = 0.0
        then Result := 1.0;

      exit
    end;

  // use 2nd factor for single digits
  if s[1] in ['0' .. '9'] then
    begin
      // get 2nd value
      Result := NthFloat(Settings.PdfFontSizeAdjust, 2, ';');

      // if 0, the value is absent or incorrectly stored, use 1st value
      if Result = 0.0
        then Result := AdjustFactor('10');

      exit
    end;

  // use 3rd factor for single alpha
  if s[1] in ['A' .. 'z'] then
    begin
      // get 3rd value
      Result := NthFloat(Settings.PdfFontSizeAdjust, 3, ';');

      // if 0, the value is absent or incorrectly stored, use 2nd value
      if Result = 0.0
        then Result := AdjustFactor('1');

      exit
    end;

  // remaining cases, use 1st factor
  Result := AdjustFactor('10')
end;

procedure TBoardViewScript.DrawTextScript(i, j, inter, mrk2, size, penCol : integer;
                                          s : string;
                                          empty : boolean;
                                          bold : boolean = True);
var
  x, y, z, w, x0, x1, color : integer;
  capHeight, df, h, yf, delta, fsize : double;
begin
  ij2xy(i, j, x, y);
  fsize := size * AdjustFactor(s);

  // clear background on empty intersection before writing
  if empty then
    begin
      if Settings.PdfUseBoardColor
        then color := BoardBack.MeanColor
        else color := clWhite;

      // should use fsize rather than size...
      ComCanvas.Add(Format('Circle %d %d %d %d %d',
                           [x, y, {radius} size div 2, color, color]))
    end;

  // use height of light characters
  capHeight := HelveticaLightMetrics[pred('0'), 0];
  yf := y + (capHeight / 2) * fsize / 1000;

  // 1 char strings, 1 digit numbers
  if (Length(s) = 1) and (s[1] in ['0' .. 'z']) then
    begin
      x0 := HelveticaLightMetrics[s[1], 1];
      x1 := HelveticaLightMetrics[s[1], 3];
      df := (x0 + (x1 - x0) / 2) * fsize / 1000;
      ComCanvas.Add(Format('TextOut %f %f %s %f %d %s',
                           [x - df, yf, s, fsize, penCol, iff(bold, 'bold', '')]));
      exit
    end;

  // 2 digit numbers
  if (Length(s) = 2) and TryStrToInt(s, z) then
    begin
      w  := HelveticaLightMetrics[s[1], 0]; // width of 1st char
      x0 := HelveticaLightMetrics[s[1], 1];
      x1 := HelveticaLightMetrics[s[2], 3];
      df := (x0 + (w + x1 - x0) / 2) * fsize / 1000;
      ComCanvas.Add(Format('TextOut %f %f %s %f %d %s',
                           [x - df, yf, s, fsize, penCol, iff(bold, 'bold', '')]));
      exit
    end;

  // all other strings
  if not TryStrToInt(s, z) or (Length(s) = 3) then
    begin
      // use graphic canvas here to compute width
      w := Canvas.TextWidth(s);

      dec(x, w div 2);
      ComCanvas.Add(Format('TextOut %d %f %s %f %d %s',
                           [x, yf, s, fsize, penCol, iff(bold, 'bold', '')]));
      exit;
    end;
end;

// -- Triangle marks

procedure TBoardViewScript.DrawTriangle(i, j, color : integer);
var
  x, y : integer;
  width, adjust, a, b, c : real;
begin
  width  := NthFloat(Settings.PdfMarksAdjust, 1, ';');
  adjust := NthFloat(Settings.PdfMarksAdjust, 2, ';');

  ij2xy(i, j, x, y);
  a := Radius * adjust;
  b := Radius * cos(pi / 6) * adjust;
  c := Radius * sin(pi / 6) * adjust;

  ComCanvas.Add(Format('LineWidth %f', [width]));
  ComCanvas.Add(Format('StrokeColor %d', [color]));
  ComCanvas.Add(Format('Closeline %f %f %f %f %f %f',
                       [x*1.0, y - a, x - b, y + c, x + b, y + c]))
end;

// -- Square marks

procedure TBoardViewScript.DrawSquare(i, j, color : integer);
var
  x, y : integer;
  width, adjust, a : real;
begin
  width  := NthFloat(Settings.PdfMarksAdjust, 1, ';');
  adjust := NthFloat(Settings.PdfMarksAdjust, 2, ';');

  ij2xy(i, j, x, y);
  a := Radius * cos(pi / 4) * adjust;

  ComCanvas.Add(Format('LineWidth %f', [width]));
  ComCanvas.Add(Format('StrokeColor %d', [color]));
  ComCanvas.Add(Format('Closeline %f %f %f %f %f %f %f %f',
                       [x - a, y - a, x + a, y - a,
                        x + a, y + a, x - a, y + a]))
end;

procedure TBoardViewScript.DrawBullet(i, j, inter, color : integer);
var
  x, y : integer;
  width, a : real;
begin
  width  := NthFloat(Settings.PdfMarksAdjust, 1, ';');

  ij2xy(i, j, x, y);

  a := Max(3, Radius div 7);

  ComCanvas.Add(Format('LineWidth %f', [width]));
  ComCanvas.Add(Format('FillColor %d', [color]));
  ComCanvas.Add(Format('Fillpoly %f %f %f %f %f %f %f %f',
                       [x - a, y - a, x + a, y - a,
                        x + a, y + a, x - a, y + a]));

  if (inter = Empty) and (color = clWhite) then
    begin
      ComCanvas.Add(Format('StrokeColor %d', [clBlack]));
      ComCanvas.Add(Format('Closeline %f %f %f %f %f %f %f %f',
                           [x - a, y - a, x + a, y - a,
                            x + a, y + a, x - a, y + a]))
    end
end;

// -- Cross marks

procedure TBoardViewScript.DrawCross(i, j, color : integer);
var
  x, y : integer;
  width, adjust, a : real;
begin
  width  := NthFloat(Settings.PdfMarksAdjust, 1, ';');
  adjust := NthFloat(Settings.PdfMarksAdjust, 2, ';');

  ij2xy(i, j, x, y);
  a := Radius * cos(pi / 4) * adjust;

  ComCanvas.Add(Format('LineWidth %f', [width]));
  ComCanvas.Add(Format('StrokeColor %d', [color]));
  ComCanvas.Add(Format('Polyline %f %f %f %f',
                       [x - a, y - a, x + a, y + a]));
  ComCanvas.Add(Format('Polyline %f %f %f %f',
                       [x + a, y - a, x - a, y + a]));
end;

// -- Circle marks

procedure TBoardViewScript.DrawCircle(i, j, color : integer);
var
  x, y : integer;
  width, adjust, r : real;
begin
  width  := NthFloat(Settings.PdfMarksAdjust, 1, ';');
  adjust := NthFloat(Settings.PdfMarksAdjust, 2, ';');

  ij2xy(i, j, x, y);
  r := ((Radius * 3) div 4) * adjust;

  ComCanvas.Add(Format('LineWidth %f', [width]));
  ComCanvas.Add(Format('Circle %d %d %f %d %d', [x, y, r, color, -1]))
end;

// ---------------------------------------------------------------------------

end.
