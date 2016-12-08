// ---------------------------------------------------------------------------
// -- Drago -- Export to text module --------------------- UExporterTXT.pas --
// ---------------------------------------------------------------------------

unit UExporterTXT;

// ---------------------------------------------------------------------------

interface

uses 
  Types, Classes, SysUtils, StrUtils,
  DefineUi, UExporter, CodePages;

type
  TExporterTXT = class(TExporter)
  private
    FileName : string;
    f : Text;
    function  ColString(i : integer; text : array of string) : string;
    procedure Write(s : string);
    procedure Writeln(s : string);
  public
    constructor Create(aExportFigure : TExportFigure; aFileName : string); //override;
    destructor Destroy; override;
    procedure BeginDoc(var ok : boolean); override;
    procedure EndDoc; override;
    procedure BeginGroup; override;
    procedure EndGroup; override;
    procedure SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); override;
    function  PrinterPxPerInchX : integer; override;
    function  PrinterPxPerInchY : integer; override;
    procedure FontName(name : string); override;
    procedure FontSize(ptSize : integer); override;
    procedure FontStyle(styles : TExporterFontStyles); override;
    procedure TextAlign(align : TExporterTextAlign) ; override;
    procedure NewLine; override;
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
  UImageExporterTXT;

// -- Creation and destruction -----------------------------------------------

constructor TExporterTXT.Create(aExportFigure : TExportFigure;
                                aFileName : string);
begin
  FExportMode   := emExportTXT;
  FExportFigure := aExportFigure;
  FileName := aFileName;
  nFigures := 0;
end;

destructor TExporterTXT.Destroy;
begin
  inherited Destroy
end;

// -- Structure of document --------------------------------------------------

// -- Document

procedure TExporterTXT.BeginDoc(var ok : boolean);
begin
  ok := True;
  assign(f, FileName);
  {$i-}
  rewrite(f);
  {$i+}
  if IOResult <> 0 then
    begin
      ok := False;
      exit
    end;

  ClearColumns
end;

procedure TExporterTXT.EndDoc;
begin
  CloseFile(f)
end;

// -- Groups

procedure TExporterTXT.BeginGroup;
begin
end;

procedure TExporterTXT.EndGroup;
begin
end;

// -- Header and Footer

procedure TExporterTXT.SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

procedure TExporterTXT.SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

// -- Format -----------------------------------------------------------------

function TExporterTXT.PrinterPxPerInchX : integer;
begin
  Result := 360
end;

function TExporterTXT.PrinterPxPerInchY : integer;
begin
  Result := 360
end;

procedure TExporterTXT.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
end;

procedure TExporterTXT.FontName(name : string);
begin
  fFontName := name
end;

procedure TExporterTXT.FontSize(ptSize : integer);
begin
  fFontSize := ptSize
end;

procedure TExporterTXT.FontStyle(styles : TExporterFontStyles);
begin
  fFontStyle := styles
end;

procedure TExporterTXT.TextAlign(align : TExporterTextAlign);
begin
end;

// -- Text -------------------------------------------------------------------

procedure TExporterTXT.NewLine;
begin
  Writeln('')
end;

procedure TExporterTXT.WriteText(s : string);
begin
  Writeln(s)
end;

procedure TExporterTXT.DrawLine(double: boolean);
begin
  if not double
    then Writeln(DupeString('-', 10))
    else Writeln(DupeString('=', 10))
end;

// -- Columns ----------------------------------------------------------------

procedure TExporterTXT.ClearColumns;
begin
  fColNum := 0
end;

procedure TExporterTXT.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
begin
  fColLeft [fColNum] := round(mmLeft  * TwipsPerMm);
  fColRight[fColNum] := round(mmRight * TwipsPerMm);
  fColAlign[fColNum] := colAlign;
  inc(fColNum);
end;

procedure TExporterTXT.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
var
  i : integer;
begin
  if Length(text) = 0
    then exit;
  CleanDelimiters(text);

  for i := 0 to FColNum - 1 do
    if i >= Length(text)
      then //nop
      else
        begin
          Write(text[i]);
          Write(' ')
        end;

  Writeln('')
end;

function TExporterTXT.ColString(i : integer; text : array of string) : string;
begin
  Result := ''
end;

// -- Images -----------------------------------------------------------------

procedure TExporterTXT.DrawImagesAcrossCols(n : integer);
var
  i, k : integer;
  name : string;
begin
  if n = 0
    then exit;

  for k := 0 to (FExportImg[0]as TExportedImageTXT).textCanvas.Count - 1 do
    begin
      for i := 0 to n - 1 do
        begin
          Write((FExportImg[i]as TExportedImageTXT).textCanvas[k]);
          Write(' ')
        end;
      Writeln('')
    end
end;

// -- Helpers

procedure TExporterTXT.Writeln(s : string);
begin
  system.writeln(f, s)
end;

procedure TExporterTXT.Write(s : string);
begin
  system.write(f, s)
end;

// ---------------------------------------------------------------------------

end.
