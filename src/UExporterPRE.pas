// ---------------------------------------------------------------------------
// -- Drago -- Export to TPages preview ------------------ UExporterPRE.pas --
// ---------------------------------------------------------------------------

unit UExporterPRE;

// ---------------------------------------------------------------------------

interface

uses
  Types, Graphics, Classes, Jpeg,
  CodePages, UExporter, Pages;

type
  TExporterPreview = class(TExporter)
  private
    Pages : TPages;
  public
    constructor Create; override;
    destructor Destroy; override;
    function  PrinterPxPerInchX : integer; override;
    function  PrinterPxPerInchY : integer; override;
    procedure BeginDoc(var ok : boolean); override;
    procedure EndDoc; override;
    procedure BeginGroup; override;
    procedure EndGroup; override;
    procedure AddPage; override;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); override;
    procedure FontName(name : string); override;
    procedure FontSize(ptSize : integer); override;
    procedure FontStyle(styles : TExporterFontStyles); override;
    procedure SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure NewLine; override;
    procedure TextAlign(align : TExporterTextAlign) ; override;
    procedure WriteText(s : string); override;
    procedure DrawLine(double: boolean); override;
    procedure ClearColumns; override;
    procedure AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign); override;
    procedure WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault); override;
    procedure DrawImagesAcrossCols(n : integer); override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, Preview,
  UImageExporterWMF;

// -- Allocation

constructor TExporterPreview.Create;
begin
  FExportMode   := emPreviewRTF;
  FExportFigure := eiWMF;
  fmPreview     := TPreviewForm.Create(nil);
  Pages         := fmPreview.Pages;
  PaperSize     := Pages.PaperSize;
end;

destructor TExporterPreview.Destroy;
begin
  Pages.ClearColumns;
  inherited Destroy
end;

// -- Conversions

function TExporterPreview.PrinterPxPerInchX : integer;
begin
  Result := Pages.fPrinterPxPerInch.x
end;

function TExporterPreview.PrinterPxPerInchY : integer;
begin
  Result := Pages.fPrinterPxPerInch.y
end;

// -- Document

procedure TExporterPreview.BeginDoc(var ok : boolean);
begin
  ok := True;
  Pages.BeginDoc
end;

procedure TExporterPreview.EndDoc;
begin
  Pages.EndDoc
end;

procedure TExporterPreview.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
  PageMargins := Rect(mmLeft, mmTop, mmRight, mmBottom);
  Pages.PageMargins := PageMargins
end;

procedure TExporterPreview.BeginGroup;
begin
  Pages.BeginGroup;
  Pages.NewLines(0)
end;

procedure TExporterPreview.EndGroup;
begin
  Pages.EndGroup
end;

procedure TExporterPreview.AddPage;
begin
  Pages.newPage
end;

// -- Fonts

procedure TExporterPreview.FontName(name : string);
begin
  Pages.Font.Name := name
end;

procedure TExporterPreview.FontSize(ptSize : integer);
begin
  Pages.Font.Size := ptSize
end;

procedure TExporterPreview.FontStyle(styles : TExporterFontStyles);
begin
  Pages.Font.Style := [];
  if efsBold      in styles then Pages.Font.Style := Pages.Font.Style + [fsBold];
  if efsItalic    in styles then Pages.Font.Style := Pages.Font.Style + [fsItalic];
  if efsUnderline in styles then Pages.Font.Style := Pages.Font.Style + [fsUnderline]
end;

// -- Header and Footer

procedure TExporterPreview.SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean);
begin
  with Pages do
    begin
      TextAlign := taLeft;
      if sLeft   <> '' then // add a newline otherwise
        AddTextToHeaderAt(sLeft, PageMargins.Left);
      if sCenter <> '' then // add a newline otherwise
        AddTextToHeaderAt(sCenter, PaperSize.cx div 2 -
                          PrinterPxToMmX(Canvas.TextWidth(sCenter) div 2));
      TextAlign := taRight;
      AddTextToHeader(sRight);
      if addLine
        then AddLineToHeader(False)
    end
end;

procedure TExporterPreview.SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean);
begin
  with Pages do
    begin
      if addLine
        then AddLineToFooter(False);
      TextAlign := taLeft;
      if sLeft   <> '' then // add a newline otherwise
        AddTextToFooterAt(sLeft, PageMargins.Left);
      if sCenter <> '' then // add a newline otherwise
        AddTextToFooterAt(sCenter, PaperSize.cx div 2 -
                          PrinterPxToMmX(Canvas.TextWidth(sCenter) div 2));
      TextAlign := taRight;
      AddTextToFooter(sRight);
      //Newline
    end
end;

// -- Text

procedure TExporterPreview.NewLine;
begin
  Pages.NewLine
end;

function PagesTextAlign(align : TExporterTextAlign) : TTextAlign;
begin
  case align of
    etaLeft   : Result := taLeft;
    etaRight  : Result := taRight;
    etaCenter : Result := taCenter;
    etaJustified : Result := taJustified
  end
end;

procedure TExporterPreview.TextAlign(align : TExporterTextAlign);
begin
  Pages.TextAlign := PagesTextAlign(align)
end;

procedure TExporterPreview.WriteText(s : string);
begin
  Pages.DrawText(s)
end;

procedure TExporterPreview.DrawLine(double: boolean);
begin
  Pages.DrawLine(double)
end;

// -- Columns

procedure TExporterPreview.ClearColumns;
begin
  Pages.ClearColumns
end;

// Exporter columns are relative to left margin

function PagesColAlign(align : TExporterColAlign) : TColAlign;
begin
  case align of
    ecaLeft   : Result := caLeft;
    ecaRight  : Result := caRight;
    ecaCenter : Result := caCenter;
    else        Result := caLeft
  end
end;

procedure TExporterPreview.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
begin
  with Pages do
    AddColumn(PageMargins.Left + mmLeft, PageMargins.Left + mmRight, PagesColAlign(colAlign))
end;

procedure TExporterPreview.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
begin
  CleanDelimiters(text);
  Pages.DrawLinesAcrossCols(text)
end;

// -- Images

procedure TExporterPreview.DrawImagesAcrossCols(n : integer);
var
  metafile : TMetafile;
  i, x, y, size, mmColLeft, mmColRight : integer;
begin
  with Pages do
    begin
      for i := 0 to n - 1 do
        begin
          metafile := (FExportImg[i] as TExportedImageWMF).FMetafile;

          size := PrinterPxToMmX(metafile.Width);
          with PColRec(fColumns[i])^ do
            begin
              mmColLeft  := PrinterPxToMmX(ColLeft);
              mmColRight := PrinterPxToMmX(ColRight)
            end;
          x := mmColLeft + (mmColRight - mmColLeft) div 2 - size div 2;
          y := CurrentYPos;
          DrawMeta(Bounds(x, y, size, size), metafile)
        end;
      CurrentYPos := CurrentYPos + size;
      //NewLine?
    end
end;

// ---------------------------------------------------------------------------

end.
