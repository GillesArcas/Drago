// ---------------------------------------------------------------------------
// -- Drago -- Base class for exporter definitions ---------- UExporter.pas --
// ---------------------------------------------------------------------------

unit UExporter;

// ---------------------------------------------------------------------------

interface

uses 
  Classes,
  Types,
  DefineUi, CodePages,
  UImageExporter;

type
  TExporterFontStyle = (efsBold, efsItalic, efsUnderline, efsStrikeOut);
  TExporterFontStyles = set of TExporterFontStyle;

  TExporterColAlign  = (ecaLeft, ecaRight, ecaCurrency, ecaCenter);

  TExporterTextAlign = (etaLeft, etaRight, etaCenter, etaJustified);


// -- Base class -------------------------------------------------------------

type
  TExporter = class
    FExportMode  : TExportMode;
    FExportFigure: TExportFigure;
    FImageExporter: TImageExporter;
    PaperSize    : TSize;
    PageMargins  : TRect;
    fFontName    : string;
    fFontSize    : integer;
    fFontStyle   : TExporterFontStyles;
    fColNum      : integer;
    nFigures     : integer;
    fColLeft     : array[0 .. 100] of integer;
    fColRight    : array[0 .. 100] of integer;
    fColHigh     : array[0 .. 100] of integer;
    fColAlign    : array[0 .. 100] of TExporterColAlign;
    fColCP       : array[0 .. 100] of TCodePage;
    fColRatio    : array[0 .. 100] of integer;
    FExportImg   : array[0 .. 100] of TExportedImage;
    FComCanvas   : array[0 .. 100] of TStringList; // TODO: declare in TExporterPDF ?

    constructor Create; overload; virtual; abstract;
    constructor Create(aFileName : string); overload; virtual; abstract;
    constructor Create(aFileName : string; aExportFigure : TExportFigure); overload; virtual; abstract;
    constructor Create(aExportFigure : TExportFigure; aFileName : string); overload; virtual; abstract;
    destructor Destroy; override;
    function  Result : integer; virtual;
    procedure BeginDoc(var ok : boolean); virtual;
    procedure EndDoc; virtual;
    procedure BeginGroup; virtual;
    procedure EndGroup; virtual;
    procedure AddPage; virtual;
    procedure SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean); virtual;
    procedure SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean); virtual;
    function  PrinterPxPerInchX : integer; virtual;
    function  PrinterPxPerInchY : integer; virtual;
    function  MmToPrinterPxX(mm: integer): integer;
    function  MmToPrinterPxY(mm: integer): integer;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); virtual;
    procedure FontName(name : string); virtual;
    procedure FontSize(ptSize : integer); virtual;
    procedure FontStyle(styles : TExporterFontStyles); virtual;
    procedure Encoding(cp : TCodePage); virtual;
    procedure NewLine; overload; virtual;
    procedure NewLine(ratio : single); overload; virtual;
    procedure TextAlign(align : TExporterTextAlign); virtual;
    procedure WriteText(s : string); virtual;
    procedure DrawLine(double: boolean); virtual;
    procedure ClearColumns; virtual;
    procedure AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign); overload; virtual;
    procedure AddColumn(mmLeft, mmRight : integer;
                        colAlign : TExporterColAlign;
                        colCP : TCodePage); overload; virtual;
    procedure WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault); virtual;
    procedure CleanDelimiters(text : TStringDynArray);
    procedure ResetDelayImages(n : integer); virtual;
    procedure AddDelayImage(fig : integer; exportedImage : TExportedImage); overload; virtual;
    procedure DrawImagesAcrossCols(n : integer); virtual;
    procedure FlushColsInPage(text : TStringDynArray; n : integer; cp : TCodePage = cpDefault); virtual;
  end;

// ---------------------------------------------------------------------------

const
  TwipsPerMm = 56.69;
  GameInfoDelimiter = #$1F;

function PaperNameToSize(paper : string; landscape : boolean) : TSize;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  StrUtils;

// -- Implementation of TExporter --------------------------------------------

destructor TExporter.Destroy;
begin
  FImageExporter.Free
end;

function TExporter.Result : integer;
begin
  Result := 0
end;

// -- Conversions

function TExporter.PrinterPxPerInchX : integer;
begin
  Result := 0
end;

function TExporter.PrinterPxPerInchY : integer;
begin
  Result := 0
end;

function TExporter.MmToPrinterPxX(mm: integer): integer;
begin
  Result := round(mm * PrinterPxPerInchX / 25.4)
end;

function TExporter.MmToPrinterPxY(mm: integer): integer;
begin
  Result := round(mm * PrinterPxPerInchY / 25.4)
end;

// -- Document

procedure TExporter.BeginDoc(var ok : boolean);
begin
  ok := True
end;

procedure TExporter.EndDoc;
begin
end;

procedure TExporter.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
end;

procedure TExporter.BeginGroup;
begin
end;

procedure TExporter.EndGroup;
begin
end;

procedure TExporter.AddPage;
begin
end;

// -- Fonts

procedure TExporter.FontName(name : string);
begin
end;

procedure TExporter.FontSize(ptSize : integer);
begin
end;

procedure TExporter.FontStyle(styles : TExporterFontStyles);
begin
end;

procedure TExporter.Encoding(cp : TCodePage);
begin
end;

// -- Header and Footer

procedure TExporter.SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

procedure TExporter.SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

// -- Text

procedure TExporter.NewLine;
begin
end;

procedure TExporter.NewLine(ratio : single);
begin
  if ratio < 0.5
    then // nop
    else NewLine
end;

procedure TExporter.TextAlign(align : TExporterTextAlign);
begin
end;

procedure TExporter.WriteText(s : string);
begin
end;

procedure TExporter.DrawLine(double: boolean);
begin
end;

// -- Columns

procedure TExporter.ClearColumns;
begin
end;

procedure TExporter.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
begin
end;

procedure TExporter.AddColumn(mmLeft, mmRight : integer;
                              colAlign : TExporterColAlign;
                              colCP : TCodePage);
begin
  AddColumn(mmLeft, mmRight, colAlign)
end;

procedure TExporter.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
begin
end;

procedure TExporter.CleanDelimiters(text : TStringDynArray);
var
  i : integer;
begin
  for i := 0 to High(text) do
    text[i] := AnsiReplaceStr(text[i], GameInfoDelimiter, '')
end;

// -- Images

procedure TExporter.ResetDelayImages(n : integer);
var
  i : integer;
begin
  for i := 0 to n - 1 do
    begin
      FreeAndNil(FComCanvas[i]);
      FreeAndNil(FExportImg[i])
    end
end;

procedure TExporter.AddDelayImage(fig : integer; exportedImage : TExportedImage);
begin
  FExportImg[fig] := exportedImage
end;

procedure TExporter.DrawImagesAcrossCols(n : integer);
begin
end;

// -- Document level function: flush figure and text columns -----------------
//
// Overridden by ExporterHPD as it cannot handle grouping in page

procedure TExporter.FlushColsInPage(text : TStringDynArray; n : integer; cp : TCodePage = cpDefault);
begin
  BeginGroup;
  DrawImagesAcrossCols(n);
  NewLine(0.45);
  WriteTextAcrossCols(text);
  EndGroup;
  NewLine(0.55)
end;

// ---------------------------------------------------------------------------

function PaperNameToSize(paper : string; landscape : boolean) : TSize;
var
  x : integer;
begin
  case AnsiIndexStr(paper, ['A5', 'A4', 'Letter', 'Legal', 'A3']) of
    0 : begin result.cx := 148; result.cy := 210 end;
    1 : begin result.cx := 210; result.cy := 297 end;
    2 : begin result.cx := 216; result.cy := 279 end;
    3 : begin result.cx := 216; result.cy := 356 end;
    4 : begin result.cx := 297; result.cy := 420 end;
  end;
  if landscape then
    begin
      x := result.cx; result.cx := result.cy; result.cy := x
    end
end;

// ---------------------------------------------------------------------------

end.
