// ---------------------------------------------------------------------------
// -- Drago -- Export to HTML module --------------------- UExporterHTM.pas --
// ---------------------------------------------------------------------------

unit UExporterHTM;

// ---------------------------------------------------------------------------

interface

uses 
  Types, Classes, Graphics, SysUtils, StrUtils,
  DefineUi, UExporter, CodePages;

type
  TExporterHTM = class(TExporter)
  private
    FileName : string;
    f : Text;
    Stream, Stream1 : String;
    images : array[0 .. 99] of TBitmap;
    function  ColImage(i : integer; images : array of TBitmap) : string;
    function  ColString(i : integer; text : array of string) : string;
    procedure Write(s : string);
    procedure Writeln(s : string);
    function  HTM_Text(s : string) : string;
    function  HTM_Para(s : string) : string;
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
  UnicodeUtils,
  UExporterIMG, 
  UImageExporterBMP;

// Processing of HTML strings

function HTM_UniDecString(const s : UTF8String) : string;
var
  w : WideString;
  i : integer;
begin
  w := UTF8Decode(s);

  if IsAnsiString(w)
    then Result := s
    else
      begin
        Result := '';

        for i := 1 to Length(w) do
          if w[i] < WideChar(128)
            then Result := Result + w[i]
            else Result := Result + '&#' + IntToStr(integer(w[i])) + ';'
      end
end;

function HTM_Special(const s : string) : string;
begin
  Result := AnsiReplaceStr(s     , '&', '&amp');
  Result := AnsiReplaceStr(Result, '<', '&lt;');
  Result := AnsiReplaceStr(Result, '>', '&gt;');
  Result := HTM_UniDecString(Result)
end;

function HTM_LineBreak(const s : string) : string;
var
  k : integer;
begin
  k := Pos(#13#10, s);
  if k = 0
    then Result := HTM_Special(s)
    else Result := HTM_Special(Copy(s, 1, k - 1))
                   + '<br>'
                   + HTM_LineBreak(Copy(s, k + 2, Length(s)))
end;

function HTM_ParaBreak(const s : string) : string;
var
  k : integer;
begin
  k := Pos(#13#10, s);
  if k = 0
    then Result := '<p>' + HTM_Special(s) + '</p>'
    else Result := '<p>' + HTM_Special(Copy(s, 1, k - 1)) + '</p>'
                   + HTM_ParaBreak(Copy(s, k + 2, Length(s)))
end;

// -- Creation and destruction -----------------------------------------------

constructor TExporterHTM.Create(aExportFigure : TExportFigure;
                                aFileName : string);
begin
  FExportMode   := emExportHTM;
  FExportFigure := aExportFigure;
  FileName := aFileName;
  PaperSize.cx := 210;
  PaperSize.cy := 297; // always export to A4
  nFigures := 0;
end;

destructor TExporterHTM.Destroy;
begin
  Stream := '';
  inherited Destroy
end;

// -- Structure of document --------------------------------------------------

// -- Document

procedure TExporterHTM.BeginDoc (var ok : boolean);
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
  Writeln('<html>');
  Writeln('<head>');
  Writeln(Format('<meta name="generator" content="%s %s">', [AppName, AppVersion]));
  Writeln('<title></title>');
  Writeln('</head>');
  Writeln('<body>');
  // paper size ?
  // font ?
  // margins ?
  ClearColumns
end;

procedure TExporterHTM.EndDoc;
begin
  Writeln('</body>');
  Writeln('</html>');
  system.write(f, Stream);
  close(f)
end;

// -- Groups

procedure TExporterHTM.BeginGroup;
begin
  system.write(f, Stream);
  Stream := ''
end;

procedure TExporterHTM.EndGroup;
begin
end;

// -- Header and Footer

procedure TExporterHTM.SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

procedure TExporterHTM.SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean);
begin
end;

// -- Format -----------------------------------------------------------------

function TExporterHTM.PrinterPxPerInchX : integer;
begin
  Result := 360
end;

function TExporterHTM.PrinterPxPerInchY : integer;
begin
  Result := 360
end;

procedure TExporterHTM.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
  // ??
end;

procedure TExporterHTM.FontName(name : string);
begin
  fFontName := name
end;

procedure TExporterHTM.FontSize(ptSize : integer);
begin
  fFontSize := ptSize
end;

procedure TExporterHTM.FontStyle(styles : TExporterFontStyles);
begin
  fFontStyle := styles
end;

procedure TExporterHTM.TextAlign(align : TExporterTextAlign);
// TExporterTextAlign = (etaLeft, etaRight, etaCenter, etaJustified);
begin
  // ??
end;

// -- Text -------------------------------------------------------------------

procedure TExporterHTM.NewLine;
begin
  /////Writeln('<p>')
  Writeln('<br>')
end;

procedure TExporterHTM.WriteText(s : string);
begin
  /////Writeln(HTM_Text(s) + '<p>')
  Writeln(HTM_Para(s))
end;

procedure TExporterHTM.DrawLine(double: boolean);
begin
  if not double
    then Writeln('<hr>')
    else Writeln('<hr>') // ??
end;

function TExporterHTM.HTM_Text(s : string) : string;
var
  size : integer;
begin
  // 8,9 : 1; 10,11 : 2; 12,13 : 3; 14 : 4
  size := fFontSize div 2 - 3;

  Result := Format('<font size="%d" face="%s">', [size, fFontName])
          + HTM_LineBreak(s)
          + '</font>';

  if fFontStyle = [] then exit;

  if efsBold      in fFontStyle then Result := '<b>' + Result + '</b>';
  if efsItalic    in fFontStyle then Result := '<i>' + Result + '</i>';
  if efsUnderline in fFontStyle then Result := '<u>' + Result + '</u>'
end;

function TExporterHTM.HTM_Para(s : string) : string;
var
  size : integer;
begin
  // 8,9 : 1; 10,11 : 2; 12,13 : 3; 14 : 4
  size := fFontSize div 2 - 3;

  Result := Format('<font size="%d" face="%s">', [size, fFontName])
          + HTM_ParaBreak(s)
          + '</font>';

  if fFontStyle = [] then exit;

  if efsBold      in fFontStyle then Result := '<b>' + Result + '</b>';
  if efsItalic    in fFontStyle then Result := '<i>' + Result + '</i>';
  if efsUnderline in fFontStyle then Result := '<u>' + Result + '</u>'
end;

// -- Columns ----------------------------------------------------------------

procedure TExporterHTM.ClearColumns;
begin
  fColNum := 0
end;

procedure TExporterHTM.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
var
  i, lTot, rTot : integer;
begin
  fColLeft [fColNum] := round(mmLeft  * TwipsPerMm);
  fColRight[fColNum] := round(mmRight * TwipsPerMm);
  fColAlign[fColNum] := colAlign;
  inc(fColNum);

  lTot := 0;
  for i := 0 to fColNum - 1 do
    inc(lTot, fColRight[i] - fColLeft[i]);

  rTot := 0;
  for i := 0 to fColNum - 1 do
    if i = fColNum - 1
      then fColRatio[i] := 100 - rTot
      else
        begin
          fColRatio[i] := round((fColRight[i] - fColLeft[i]) * 100 div lTot);
          inc(rTot, fColRatio[i])
        end
end;

procedure TExporterHTM.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
var
  i : integer;
  s : string;
begin
  if Length(text) = 0
    then exit;
  CleanDelimiters(text);
  
  Writeln('<table width="100%"><tr>');
  for i := 0 to fColNum - 1 do
    if i >= Length(text)
      then Writeln(Format('<td width="%d%%"></td>', [fColRatio[i]]))
      else
        begin
          case fColAlign[i] of
            ecaLeft   : s := 'left';
            ecaRight  : s := 'right';
            ecaCenter : s := 'center'
          end;

          Writeln(Format('<td align="%s" valign="top" width="%d%%">%s</td>',
                         [s, fColRatio[i], HTM_Text(text[i])]))
        end;
  Writeln('</tr></table>')
end;

function TExporterHTM.ColString(i : integer; text : array of string) : string;
begin
  Result := ''
end;

// -- Images -----------------------------------------------------------------

function TExporterHTM.ColImage(i : integer; images : array of TBitmap) : string;
begin
  Result := ''
end;

procedure TExporterHTM.DrawImagesAcrossCols(n : integer);
var
  i : integer;
  name : string;
begin
  if n = 0
    then exit;

  Writeln('<table width="100%"><tr>');
  for i := 0 to fColNum - 1 do
    if i >= n
      then Writeln(Format('<td width="%d%%"></td>', [fColRatio[i]]))
      else
        begin
          ExportImage((FExportImg[i] as TExportedImageBMP).Bitmap, nil, nil, fExportFigure, fileName,
                      PrinterPxPerInchX, nFigures, name);
          inc(nFigures);
          Writeln(Format('<td align ="center" width="%d%%"><img src="%s"></td>',
                         [fColRatio[i], ExtractFileName(name)]))
        end;
  Writeln('</tr></table>')
end;

// -- Helpers

procedure TExporterHTM.Writeln(s : string);
begin
  Write(s + #13#10)
end;

procedure TExporterHTM.Write(s : string);
begin
  Stream := Stream + s
end;

// ---------------------------------------------------------------------------

end.
