// ---------------------------------------------------------------------------
// -- Drago -- Board view for WMF exporting ---------- UBoardViewVector.pas --
// ---------------------------------------------------------------------------

unit UBoardViewVector;

// ---------------------------------------------------------------------------

interface

uses
  Graphics,
  UBoardViewCanvas;

type
  TBoardViewVector = class(TBoardViewCanvas)
  public
    procedure SetTextColors(inter, mrk2 : integer;
                            var pen, back : integer;
                            var style : TBrushStyle); override;
    function  MaxFontSize : integer; override;
    procedure DrawTextOnEmpty(x, y, mrk2 : integer; const s : string); override;
    procedure DrawStone(i, j, color : integer); override;
    procedure DrawCircle(i, j, color : integer); override;
    procedure DrawBackground; override;
  protected
    procedure DrawOneLine(k, x0, y0, x1, y1 : integer); override;
    procedure DrawOneHoshi(x, y, r : integer); override;
  private
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Types,
  Define, UBoardView, UGraphic;

// -- Setting of dimensions --------------------------------------------------

function TBoardViewVector.MaxFontSize : integer;
begin
  Result := MaxInt
end;

// -- Display of board -------------------------------------------------------

// -- Draw background of whole board

procedure TBoardViewVector.DrawBackground;
begin
  // nop
end;

// -- Lines

procedure TBoardViewVector.DrawOneLine(k, x0, y0, x1, y1 : integer);
begin
  with Canvas do
    begin
      if ThickEdge and ((k = 1) or (k = BoardSize))
        then Pen.Width := 2
        else Pen.Width := 1;
      PolyLine([Point(x0, y0), Point(x1, y1 - 1)])
    end
end;

// -- Hoshis

procedure TBoardViewVector.DrawOneHoshi(x, y, r : integer);
begin
  Canvas.Ellipse(x - r, y - r, x + r + 1, y + r + 1)
end;

// -- Handling of colors -----------------------------------------------------

procedure TBoardViewVector.SetTextColors(inter, mrk2 : integer;
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

procedure TBoardViewVector.DrawStone(i, j, color : integer);
var
  x, y : integer;
begin
  ij2xy(i, j, x, y);
  WACircle(Canvas, x, y, InterWidth div 2, Radius, clBlack, player2col(color))
end;

// -- Display of marks -------------------------------------------------------

// -- Text marks

procedure TBoardViewVector.DrawTextOnEmpty(x, y, mrk2 : integer; const s : string);
begin
  TextOutOnBoard(x, y, 1, s)
end;

// -- Circle marks

procedure TBoardViewVector.DrawCircle(i, j, color : integer);
var
  x, y, r : integer;
begin
  ij2xy(i, j, x, y);
  r := (Radius * 3) div 4;
  WACircle(Canvas, x, y, InterWidth div 2, r, color, -1)
end;

// ---------------------------------------------------------------------------

end.
