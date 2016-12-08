// ---------------------------------------------------------------------------
// -- Drago -- Export to PDF module ---------------------- UExporterPDF.pas --
// ---------------------------------------------------------------------------

unit UExporterPDF;

// ---------------------------------------------------------------------------
// use libHaru
//

interface

uses
  Types, Classes, Graphics, SysUtils, Jpeg,
  DefineUi, UExporter,
  hpdf, hpdf_types, hpdf_consts,
  CodePages,
  UImageExporter;

 type
  TExporterPDF = class(TExporter)
  public
    constructor Create(aExportFigure : TExportFigure; aFileName : string); override;
    destructor Destroy; override;
    function  PrinterPxPerInchX : integer; override;
    function  PrinterPxPerInchY : integer; override;
    procedure BeginDoc(var ok : boolean); override;
    procedure EndDoc; override;
    procedure BeginGroup; override;
    procedure EndGroup; override;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); override;
    procedure FontName(name : string); override;
    procedure FontSize(ptSize : integer); override;
    procedure FontStyle(styles : TExporterFontStyles); override;
    procedure Encoding(cp : TCodePage); override;
    procedure AddPage; override;
    procedure SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure NewLine; override;
    procedure NewLine(ratio : single); override;
    procedure TextAlign(align : TExporterTextAlign) ; override;
    procedure WriteText(s : string); override;
    procedure DrawLine(double: boolean); override;
    procedure ClearColumns; override;
    procedure AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign); overload; override;
    procedure AddColumn(mmLeft, mmRight : integer;
                        colAlign : TExporterColAlign;
                        colCP : TCodePage); overload; override;
    procedure WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault); override;
    procedure AddDelayImage(fig : integer; exportedImage : TExportedImage); override;
    procedure DrawImagesAcrossCols(n : integer); override;
    function  PreviewImagesAcrossCols : double;
    function  PreviewTextAcrossCols(text : TStringDynArray) : double;
    procedure FlushColsInPage(text : TStringDynArray; n : integer; cp : TCodePage = cpDefault); override;
  private
    pdf  : HPDF_Doc;
    font : HPDF_Font;
    page : HPDF_Page;
    FCodePage : TCodePage;
    //DefaultEncoder : HPDF_Encoder;
    JPAvailable  : boolean;
    CNTAvailable : boolean;
    CNSAvailable : boolean;
    KRAvailable  : boolean;
    FTrueTypeFont: string;
    FFileName : string;
    FPage : integer;
    FImageNum : integer;
    LineList : TStringList;
    FFontStyleStr : string;
    UpperPos, LowerPos, YPos: integer;
    FDisplayHeader, FDisplayFooter : boolean;
    FHeaderLine, FFooterLine : boolean;
    sLeftH, sCenterH, sRightH : WideString;
    sLeftF, sCenterF, sRightF : WideString;
    function  GetFontForEncoding(cp : TCodePage; pdf : HPDF_Doc) : HPDF_Font;
    function  LineHeight : double;
    procedure TextWidthMultiCP(pdf : HPDF_Doc;
                               page: HPDF_Page;
                               const s : string;
                               cpGame : TCodePage;
                               var words : TStringDynArray;
                               var width : TDoubleDynArray);
    procedure TextRectMultiCP (pdf : HPDF_Doc;
                               page: HPDF_Page;
                               left, top, right, bottom : double;
                               const s : string;
                               cpGame : TCodePage;
                               align : THPDF_TextAlignment);
    procedure WriteHeader;
    procedure WriteFooter;
    procedure DoHeaderOrFooter(sLeft, sCenter, sRight : string);
  end;

procedure ExportImagePDF(comCanvas : TStringList; imgName  : string);

procedure ApplyCommandCanvas(page : HPDF_Page;
                             pdf : HPDF_Doc;
                             cmd : TStringList;
                             offX, offY : double);

// ---------------------------------------------------------------------------

implementation

uses
  Std, UGMisc, UStatus,
  UImageExporterBMP,
  UImageExporterPDF;

// -- Cut string into lines fitting in width ---------------------------------

procedure GetLinesInWidth(page: HPDF_Page; const text : string; width : double;
                          list: TStringList);
var
  l : TStringList;
  s : string;
  i, n : integer;
begin
  l := TStringList.Create;
  l.Text := text;
  list.Clear;

  for i := 0 to l.Count - 1 do
    begin
      s := l[i];
      repeat
        // number of characters from full words fitting in width
        n := HPDF_Page_MeasureText(page, pchar(s), width, 1, nil);

        if (n = 0) or (n = Length(s))
          then
            begin
              list.Add(s);
              break
            end
          else
            begin
              list.Add(Copy(s, 1, n));
              s := Copy(s, n + 1, maxint)
            end
      until False
    end;
  l.Free
end;

// --  Conversion from TExporterColAlign to Haru align constants -------------

function hpdf_talign(align : TExporterColAlign) : THPDF_TextAlignment;
begin
  case align of
    ecaLeft   : Result := HPDF_TALIGN_LEFT;
    ecaRight  : Result := HPDF_TALIGN_RIGHT;
    ecaCenter : Result := HPDF_TALIGN_CENTER;
    else        Result := HPDF_TALIGN_LEFT
  end
end;

// -- Call to HPDF_Page_TextRect. Yes, constant has to appear explicitly (?)

function HPDF_Page_TextRect(page: HPDF_Page;
                            left, top, right, bottom: HPDF_REAL;
                            const text: HPDF_PCHAR;
                            align: THPDF_TextAlignment;
                            len: HPDF_PUINT) : HPDF_STATUS;
begin
  case align of
    HPDF_TALIGN_CENTER :
      Result := hpdf.HPDF_Page_TextRect(page, left, top, right, bottom, text,
                                        HPDF_TALIGN_CENTER, len);
    else
      Result := hpdf.HPDF_Page_TextRect(page, left, top, right, bottom, text,
                                        align, @len)
  end
end;

// -- Handling of code pages -------------------------------------------------

// -- Search closest code page handled by HPDF

function GetPDFEncoding(cp : TCodePage) : TCodePage;
begin
  case cp of
    iso8859_1 :                  // Western European
      Result := cp1252;
    shift_jis, eucjp :           // Japanese
      Result := shift_jis;
    gb18030, euc_cn, hzgb2312 :  // Simplified Chinese
      Result := euc_cn;
    big5 :                       // Traditional Chinese
      Result := big5;
    cp949, euckr, iso_2022_kr :  // Korean
      Result := euckr;
    utf8 :                       // return a default
      //Result := GetPDFEncoding(CurrentCodePage)
      Result := GetPDFEncoding(CodePageFromLanguageId(Settings.Language))
    else
      Result := cp
  end
end;

// -- Encode UTF-8 using the closest code page handled by HPDF

function UTF8ToPDFEncoding(s : string; cp : TCodePage) : string;
begin
  Result := CPEncode(UTF8Decode(s), GetPDFEncoding(cp))
end;

// -- Return encoding name for code pages handled by HPDF

function GetCodePageName(cp : TCodePage) : string;
begin
  case cp of
    iso8859_2 : Result := 'ISO8859-2';
    iso8859_4 : Result := 'ISO8859-4';
    iso8859_5 : Result := 'ISO8859-5';
    iso8859_7 : Result := 'ISO8859-7';
    iso8859_9 : Result := 'ISO8859-9';
    cp874     : Result := 'ISO8859-11'; // consider they are close enough
    cp1250    : Result := 'CP1250';
    cp1251    : Result := 'CP1251';
    cp1252    : Result := 'CP1252';
    cp1253    : Result := 'CP1253';
    cp1254    : Result := 'CP1254';
    cp1257    : Result := 'CP1257';
    cp1258    : Result := 'CP1258';
    else
      Result := 'StandardEncoding'
  end;
end;

// -- Return font for code pages handled by HPDF

function TExporterPDF.GetFontForEncoding(cp : TCodePage; pdf : HPDF_Doc) : HPDF_Font;
var
  embed : integer;
  fontname : string;
begin
  case cp of
    shift_jis, eucjp :           // Japanese
      begin
        if not JPAvailable then
          begin
            JPAvailable := True;
            HPDF_UseJPFonts(pdf);
            HPDF_UseJPEncodings(pdf)
          end;
        // font can be MS-Mincyo,MS-Gothic,MS-PMincyo,MS-PGothic
        Result := HPDF_GetFont(pdf, 'MS-Mincyo', '90ms-RKSJ-H')
      end;
    gb18030, euc_cn, hzgb2312 :  // Simplified Chinese
      begin
        if not CNSAvailable then
          begin
            CNSAvailable := True;
            HPDF_UseCNSFonts(pdf);
            HPDF_UseCNSEncodings(pdf)
          end;
        // font can be SimSun,SimHei
        Result := HPDF_GetFont(pdf, 'SimSun', 'GBK-EUC-H')
        //Result := HPDF_GetFont(pdf, 'SimHei', 'GBK-EUC-H')
      end;
    big5 :                       // Traditional Chinese, Big5
      begin
        if not CNTAvailable then
          begin
            CNTAvailable := True;
            HPDF_UseCNTFonts(pdf);
            HPDF_UseCNTEncodings(pdf)
          end;
        // font can be MingLiU
        Result := HPDF_GetFont(pdf, 'MingLiU', 'ETen-B5-H')
      end;
    cp949, euckr, iso_2022_kr :  // Korean
      begin
        if not KRAvailable then
          begin
            KRAvailable := True;
            HPDF_UseKRFonts(pdf);
            HPDF_UseKREncodings(pdf)
          end;
        // font can be Batang,Dotum,BatangChe,DotumChe
        Result := HPDF_GetFont(pdf, 'Batang', 'KSC-EUC-H')
      end;
    else
      begin
        // replace utf8 (not available) by current code page
        if cp = utf8
          //then cp := CurrentCodePage;
          then
            begin
              cp := CodePageFromLanguageId(Settings.Language);
              Result := GetFontForEncoding(cp, pdf)
            end
          else
            begin
              if Settings.PdfTrueTypeFont = ''
                then fontname := 'Helvetica' + FFontStyleStr // apply style
                else
                  if FTrueTypeFont <> ''
                    then fontname := FTrueTypeFont
                    else
                      begin
                        embed := iff(Settings.PdfEmbedTTF, HPDF_TRUE, HPDF_FALSE);
                        fontname := HPDF_LoadTTFontFromFile(pdf, PChar(Settings.PdfTrueTypeFont), embed);
                        FTrueTypeFont := fontname
                      end;
                      
              Result := HPDF_GetFont(pdf, PChar(fontname), PChar(GetCodePageName(cp)))
            end
      end
  end
end;

// -- Error handler for LibHaru ----------------------------------------------

procedure error_handler(error_no: HPDF_STATUS; detail_no: HPDF_STATUS;
                        user_data: Pointer); stdcall;
var
  msg : string;
begin
  msg := 'ERROR: ' + IntToHex(error_no, 4) + '-' + IntToStr(detail_no);
  raise Exception.Create(msg);
end;

// -- Allocation -------------------------------------------------------------

constructor TExporterPDF.Create(aExportFigure : TExportFigure; aFileName : string);
begin
  FExportMode   := emExportPDF;
  FExportFigure := aExportFigure;
  FFileName     := aFileName;
  PaperSize     := PaperNameToSize(Status.prPaperSize, Status.prLandscape);
  FFontStyleStr := '';
  LineList      := TStringList.Create;
  FPage         := 0;
  FImageNum     := 0;
  JPAvailable   := False;
  CNTAvailable  := False;
  CNSAvailable  := False;
  KRAvailable   := False;
  FTrueTypeFont := '';

  pdf := HPDF_New(@error_handler, nil);
  if pdf = nil then
  begin
    WriteLn('error: cannot create PdfDoc object\n');
    Halt(1); // todo: error handling
  end;

  if Status.prCompressPDF
    then HPDF_SetCompressionMode(pdf, HPDF_COMP_ALL)
    else HPDF_SetCompressionMode(pdf, HPDF_COMP_NONE);

  FDisplayHeader := False;
  FDisplayFooter := False;
  FHeaderLine    := False;
  FFooterLine    := False;
//DefaultEncoder := HPDF_GetCurrentEncoder (pdf);
  // font for single byte character sets
  font := HPDF_GetFont(pdf, 'Helvetica', nil);
end;

destructor TExporterPDF.Destroy;
begin
  LineList.Free;
  inherited Destroy
end;

// -- Conversions ------------------------------------------------------------

function TExporterPDF.PrinterPxPerInchX : integer;
begin
  Result := 72
end;

function TExporterPDF.PrinterPxPerInchY : integer;
begin
  Result := 72
end;

procedure TExporterPDF.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
  PageMargins := Rect(mmLeft, mmTop, mmRight, mmBottom)
end;

// -- Document ---------------------------------------------------------------

procedure TExporterPDF.BeginDoc(var ok : boolean);
begin
  ok := True;
  AddPage
end;

procedure TExporterPDF.EndDoc;
begin
  HPDF_SaveToFile(pdf, PChar(FFileName))
end;

procedure TExporterPDF.BeginGroup;
begin
  // no grouping
end;

procedure TExporterPDF.EndGroup;
begin
  // no grouping
end;

procedure TExporterPDF.AddPage;
begin
  inc(FPage);

  page := HPDF_AddPage(pdf);
  HPDF_Page_SetWidth      (page, MmToPrinterPxY(PaperSize.cx));
  HPDF_Page_SetHeight     (page, MmToPrinterPxY(PaperSize.cy));
  HPDF_Page_SetTextLeading(page, 12);

  UpperPos := MmToPrinterPxY(PaperSize.cy - PageMargins.Top)
              - Round(2 * LineHeight);
  LowerPos := MmToPrinterPxY(PageMargins.Bottom)
              + Round(2 * LineHeight);

  // write header and footer
  WriteHeader;
  WriteFooter;
  YPos := UpperPos
end;

// -- Fonts and encodings ----------------------------------------------------

procedure TExporterPDF.FontName(name : string);
begin
  FFontName := name
end;

procedure TExporterPDF.FontSize(ptSize : integer);
begin
  FFontSize := ptSize
end;

procedure TExporterPDF.FontStyle(styles : TExporterFontStyles);
begin
  if styles = []
    then FFontStyleStr := '';
  if styles = [efsBold]
    then FFontStyleStr := '-Bold';
  if styles = [efsItalic]
    then FFontStyleStr := '-Oblique';
  if styles = [efsBold, efsItalic]
    then FFontStyleStr := '-BoldOblique';
end;

procedure TExporterPDF.Encoding(cp : TCodePage);
begin
  FCodePage := cp
end;

// -- Header and Footer ------------------------------------------------------

procedure TExporterPDF.SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean);
begin
  FDisplayHeader := True;
  sLeftH         := sLeft;
  sCenterH       := sCenter;
  sRightH        := SRight;
  FHeaderLine    := addLine
end;

procedure TExporterPDF.SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean);
begin
  FDisplayFooter := True;
  sLeftF         := sLeft;
  sCenterF       := sCenter;
  sRightF        := SRight;
  FHeaderLine    := addLine
end;

procedure TExporterPDF.DoHeaderOrFooter(sLeft, sCenter, sRight : string);
var
  s : string;
  xLeft, xCenter, xRight : single;
begin
  s := IntToStr(FPage);

  sLeft   := StringReplace(sLeft  , '<<pagenumber>>', s, [rfReplaceAll]);
  sCenter := StringReplace(sCenter, '<<pagenumber>>', s, [rfReplaceAll]);
  sRight  := StringReplace(sRight , '<<pagenumber>>', s, [rfReplaceAll]);

  sLeft   := UTF8ToPDFEncoding(sLeft  , utf8); //CurrentCodePage);
  sCenter := UTF8ToPDFEncoding(sCenter, utf8); //CurrentCodePage);
  sRight  := UTF8ToPDFEncoding(sRight , utf8); //CurrentCodePage);

  font := GetFontForEncoding(utf8 {CurrentCodePage}, pdf);
  HPDF_Page_SetFontAndSize(page, font, FFontSize);

  xLeft   := MmToPrinterPxY(PageMargins.Left);
  xCenter := MmToPrinterPxY(PageMargins.Left +(PaperSize.cx - PageMargins.Right - PageMargins.Left) div 2)
             - HPDF_Page_TextWidth(page, PChar(sCenter)) / 2;
  xRight  := MmToPrinterPxY(PaperSize.cx - PageMargins.Right)
             - HPDF_Page_TextWidth(page, PChar(sRight));

  // left string
  HPDF_Page_BeginText(page);
  HPDF_Page_MoveTextPos(page, xLeft, YPos);
  HPDF_Page_ShowText(page, PChar(sLeft));
  HPDF_Page_EndText(page);

  //center string
  HPDF_Page_BeginText(page);
  HPDF_Page_MoveTextPos(page, xCenter, YPos);
  HPDF_Page_ShowText(page, PChar(sCenter));
  HPDF_Page_EndText(page);

  // right string
  HPDF_Page_BeginText(page);
  HPDF_Page_MoveTextPos(page, xRight, YPos);
  HPDF_Page_ShowText(page, PChar(sRight));
  HPDF_Page_EndText(page)
end;

procedure TExporterPDF.WriteHeader;
begin
  Ypos := MmToPrinterPxY(PaperSize.cy - PageMargins.Top);
  if not FDisplayHeader
    then exit;

  DoHeaderOrFooter(sLeftH, sCenterH, sRightH);

  Ypos := Round(YPos - 0.5 * LineHeight);

  HPDF_Page_SetLineWidth(page, 1);
  HPDF_Page_MoveTo(page, MmToPrinterPxY(PageMargins.Left), YPos);
  HPDF_Page_LineTo(page, MmToPrinterPxY(PaperSize.cx - PageMargins.Right), YPos);
  HPDF_Page_Stroke(page);

  Ypos := Round(YPos - 1.5 * LineHeight)
end;

procedure TExporterPDF.WriteFooter;
begin
  if not FDisplayFooter
    then exit;

  Ypos := LowerPos - Round(LineHeight);

  HPDF_Page_SetLineWidth(page, 1);
  HPDF_Page_MoveTo(page, MmToPrinterPxY(PageMargins.Left), YPos);
  HPDF_Page_LineTo(page, MmToPrinterPxY(PaperSize.cx - PageMargins.Right), YPos);
  HPDF_Page_Stroke(page);

  Ypos := Round(YPos - LineHeight);
  DoHeaderOrFooter(sLeftF, sCenterF, sRightF)
end;

// -- Text -------------------------------------------------------------------

procedure TExporterPDF.NewLine;
begin
  Ypos := Round(YPos - LineHeight);
end;

procedure TExporterPDF.NewLine(ratio : single);
begin
  Ypos := Round(YPos - ratio * LineHeight);
end;

procedure TExporterPDF.TextAlign(align : TExporterTextAlign);
begin
end;

// -- Write text using current value of CodePage

procedure TExporterPDF.WriteText(s : string);
var
  i, left, right : integer;
  font : HPDF_Font;
begin
  font := GetFontForEncoding(FCodePage, pdf);
  s := UTF8ToPDFEncoding(s, FCodePage);

  left  := MmToPrinterPxX(PageMargins.Left);
  right := MmToPrinterPxX(PaperSize.cx - PageMargins.Right);
  Ypos  := Round(YPos - LineHeight);

  HPDF_Page_SetGrayFill(page, 0);
  HPDF_Page_SetFontAndSize(page, font, FFontSize);
  GetLinesInWidth(page, s, right - left, LineList);

  for i := 0 to LineList.Count - 1 do
    begin
      if Round(YPos - LineHeight) <= LowerPos
        then AddPage;

      HPDF_Page_BeginText(page);
      HPDF_Page_MoveTextPos(page, left, YPos);
      HPDF_Page_SetFontAndSize(page, font, FFontSize);
      HPDF_Page_ShowText(page, PChar(Trim(LineList[i])));
      HPDF_Page_EndText(page);

      Ypos := Round(YPos - LineHeight)
    end;
  Ypos := Round(YPos + LineHeight)
end;

procedure TExporterPDF.DrawLine(double: boolean);
begin
  Ypos := Round(YPos - 0.5 * LineHeight);

  HPDF_Page_MoveTo(page, MmToPrinterPxY(PageMargins.Left), YPos);
  HPDF_Page_LineTo(page, MmToPrinterPxY(PaperSize.cx - PageMargins.Right), YPos);
  HPDF_Page_Stroke(page);

  Ypos := Round(YPos - 0.5 * LineHeight);
end;

// -- Helpers

function TExporterPDF.LineHeight : double;
begin
  Result := Status.PdfLineHeightAdjust * HPDF_Page_GetTextLeading(page)
end;

// -- Columns ----------------------------------------------------------------

procedure TExporterPDF.ClearColumns;
begin
  fColNum := 0
end;

// Exporter columns are relative to left margin
// en mm

procedure TExporterPDF.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
begin
  fColLeft [fColNum] := mmLeft;
  fColRight[fColNum] := mmRight;
  fColAlign[fColNum] := colAlign;
  inc(fColNum)
end;

procedure TExporterPDF.AddColumn(mmLeft, mmRight : integer;
                                 colAlign : TExporterColAlign;
                                 colCP : TCodePage);
begin
  fColLeft [fColNum] := mmLeft;
  fColRight[fColNum] := mmRight;
  fColAlign[fColNum] := colAlign;
  fColCP   [fColNum] := colCP;
  inc(fColNum)
end;

function  TExporterPDF.PreviewTextAcrossCols(text : TStringDynArray) : double;
var
  i, left, right, maxLines : integer;
  strings : TStringList;
begin
  Result := 0;
  if fColNum = 0
    then exit;

  strings := TStringList.Create;
  maxLines := 0;
  HPDF_Page_SetGrayFill(page, 0);

  for i := 0 to High(text) do
    begin
      left  := MmToPrinterPxX(fColLeft [i]);
      right := MmToPrinterPxX(fColRight[i]);

      font := GetFontForEncoding(FColCP[i], pdf);
      HPDF_Page_SetFontAndSize(page, font, FFontSize);
      GetLinesInWidth(page, text[i], right - left, strings);

      if strings.Count > maxLines
        then MaxLines := strings.Count
    end;

  //if Round(YPos - maxLines * LineHeight) <= LowerPos
  //  then AddPage;

  strings.Free;
  Result := maxLines * LineHeight
end;

procedure TExporterPDF.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
var
  i, k, left, right, maxLines, YPos0 : integer;
  align : THPDF_TextAlignment;
  len : HPDF_PUINT;
  s : string;
begin
  if fColNum = 0
    then exit;

  // cut lines if necessary, and compute maxLines over columns

  maxLines := 0;
  HPDF_Page_SetGrayFill(page, 0);

  for i := 0 to High(text) do
    begin
      FComCanvas[i] := TStringList.Create;
      left  := MmToPrinterPxX(fColLeft [i]);
      right := MmToPrinterPxX(fColRight[i]);

      // cutting in lines will be approximate on multi CP lines
      if Pos(GameInfoDelimiter, text[i]) > 0
        then s := text[i]
        else s := UTF8ToPDFEncoding(text[i], FColCP[i]);

      font := GetFontForEncoding(FColCP[i], pdf);
      HPDF_Page_SetFontAndSize(page, font, FFontSize);

      // cut
      GetLinesInWidth(page, s, right - left, FComCanvas[i]);

      if FComCanvas[i].Count > maxLines
        then MaxLines := FComCanvas[i].Count
    end;

  if Round(YPos - maxLines * LineHeight) <= LowerPos
    then AddPage;
  YPos0 := YPos;

  // display all cut lines

  for i := 0 to High(text) do
    begin
      YPos := YPos0;
      for k := 0 to FComCanvas[i].Count - 1 do
        begin
          align := hpdf_talign(fColAlign[i]);
          left  := MmToPrinterPxX(PageMargins.Left + fColLeft [i]);
          right := MmToPrinterPxX(PageMargins.Left + fColRight[i]);

          HPDF_Page_BeginText(page);

          font := GetFontForEncoding(FColCP[i], pdf);
          HPDF_Page_SetFontAndSize(page, font, FFontSize);
          s := FComCanvas[i][k];

          if Pos(GameInfoDelimiter, text[i]) = 0
            then
              begin
                //s := UTF8ToPDFEncoding(s, FColCP[i]);
                HPDF_Page_TextRect(page, left, YPos, right, 0, PChar(s),
                                   align, @len)
              end
            else
              TextRectMultiCP(pdf, page, left, YPos, right, 0, s, cp, align);

          HPDF_Page_EndText(page);

          Ypos := Round(YPos - LineHeight)
        end;

      FreeAndNil(FComCanvas[i])
    end;

  Ypos := Round(YPos0 - maxLines * LineHeight)
end;

// -- Multi code page functions

// Input is a string formated by ParseGameInfosName with substrings from
// 2 code pages.
// Output is the list of substrings, converted to the right CP, and the
// cumulated lengths.

procedure TExporterPDF.TextWidthMultiCP(pdf : HPDF_Doc;
                                        page: HPDF_Page;
                                        const s : string;
                                        cpGame : TCodePage;
                                        var words : TStringDynArray;
                                        var width : TDoubleDynArray);
var
  cp   : TCodePage;
  font : HPDF_Font;
  i    : integer;
  w    : double;
begin
  Split(s, words, GameInfoDelimiter);
  SetLength(width, Length(words));
  w := 0;

  for i := 0 to High(words) do
    begin
      if i mod 2 = 0
        then cp := utf8
        else cp := cpGame;

      font := GetFontForEncoding(cp, pdf);
      HPDF_Page_SetFontAndSize(page, font, FFontSize);
      words[i] := UTF8ToPDFEncoding(words[i], cp);
      w := w + HPDF_Page_TextWidth(page, PChar(words[i]));
      width[i] := w
    end
end;

procedure TExporterPDF.TextRectMultiCP(pdf : HPDF_Doc;
                                       page: HPDF_Page;
                                       left, top, right, bottom : double;
                                       const s : string;
                                       cpGame : TCodePage;
                                       align : THPDF_TextAlignment);
var
  words : TStringDynArray;
  width : TDoubleDynArray;
  cp    : TCodePage;
  font  : HPDF_Font;
  i, len: integer;
  x     : double;
begin
  TextWidthMultiCP(pdf, page, s, cpGame, words, width);

  if align = HPDF_TALIGN_CENTER
    then left := left + (right - left - width[High(width)]) / 2
    else ; // nop

  for i := 0 to High(words) do
    begin
      if i mod 2 = 0
        then cp := utf8
        else cp := cpGame;

      if i = 0
        then x := left
        else x := left + width[i - 1];

      font := GetFontForEncoding(cp, pdf);
      HPDF_Page_SetFontAndSize(page, font, FFontSize);

      HPDF_Page_TextRect(page, x, top, right, bottom, PChar(words[i]),
                         HPDF_TALIGN_LEFT, @len)
    end
end;

// -- Images -----------------------------------------------------------------

procedure TExporterPDF.AddDelayImage(fig : integer; exportedImage : TExportedImage);
begin
  inherited;
  FColHigh[fig] := exportedImage.mmWidth
end;

function TExporterPDF.PreviewImagesAcrossCols : double;
begin
  if FExportFigure = eiPDF
    then Result := MmToPrinterPxX(FColHigh[0])
    else Result := (FExportImg[0] as TExportedImageBMP).Bitmap.Width
end;

procedure TExporterPDF.DrawImagesAcrossCols(n : integer);
var
  i, left, colWidth, h, w : integer;
  bitmap : TBitmap;
  jpg : TJPEGImage;
  name : string;
  image : HPDF_Image;
begin
  if Round(YPos - MmToPrinterPxX(FColHigh[0])) <= LowerPos
    then AddPage;

  case FExportFigure of
  eiPDF :
    for i := 0 to n - 1 do
      begin
        colWidth := MmToPrinterPxX(fColRight[i] - fColLeft[i]);
        left := MmToPrinterPxX(PageMargins.Left + fColLeft[i]);
        left := left + (colWidth - MmToPrinterPxX(FColHigh[0])) div 2;

        ApplyCommandCanvas(page, pdf, (FExportImg[i]as TExportedImagePDF).TextCanvas, left, YPos);
      end;
  eiJPG :
    for i := 0 to n - 1 do
      begin
        bitmap := (FExportImg[i] as TExportedImageBMP).Bitmap;

        colWidth := MmToPrinterPxX(fColRight[i] - fColLeft[i]);
        left := MmToPrinterPxX(PageMargins.Left + fColLeft[i]);
        left := left + (colWidth - bitmap.Width) div 2;

        inc(FImageNum);
        name := Format('IMAGE%d', [FImageNum]);

        jpg := TJPEGImage.Create;
        jpg.CompressionQuality := Status.prQualityJPEG;
        jpg.Assign(bitmap);

        // save to temporary file, will be deleted with TmpPath
        name := Status.TmpPath + '/tmp.jpg';
        jpg.SaveToFile(name);
        jpg.Free;

        // load and draw image
        image := HPDF_LoadJpegImageFromFile(pdf, PChar(name));
        h := HPDF_Image_GetHeight(image);
        w := HPDF_Image_GetWidth(image);
        HPDF_Page_DrawImage(page, image, left, YPos - h, w, h);

        FColHigh[0] := h
      end
  else // should not be, nop
  end;

  if FExportFigure = eiPDF
    then YPos := YPos - MmToPrinterPxX(FColHigh[0])
    else
      begin
        bitmap := (FExportImg[0] as TExportedImageBMP).Bitmap;
        YPos := YPos - bitmap.Width
      end
end;

// -- Document level function: flush figure and text columns -----------------
//
// Overrides default as HaruPDF cannot handle grouping in page

procedure TExporterPDF.FlushColsInPage(text : TStringDynArray; n : integer; cp : TCodePage = cpDefault);
const
  ratio = 0.45;
var
  h1, h2, h3 : double;
begin
  h1 := PreviewImagesAcrossCols;
  h2 := ratio * LineHeight;
  h3 := PreviewTextAcrossCols(text);

  if YPos - (h1 + h2 + h3)  < LowerPos
    then AddPage;

  DrawImagesAcrossCols(n);
  NewLine(ratio);
  WriteTextAcrossCols(text, cp);
  NewLine(1 - ratio)
end;

// ---------------------------------------------------------------------------

procedure ColorToRGB(color : TColor; out r, g, b : double);
begin
  r := (color         and $FF) / 255;
  g := (color  shr 8  and $FF) / 255;
  b := (color  shr 16 and $FF) / 255
end;

procedure ApplyCommandCanvas(page : HPDF_Page;
                             pdf : HPDF_Doc;
                             cmd : TStringList;
                             offX, offY : double);
var
  line, func, arg1, arg2, s, name : string;
  i, k : integer;
  x, y, pen, col : integer;
  r, xf, yf, size : double;
  ewr : double; // exact width ratio
  bold : boolean;
  red, green, blue : double;
  font : HPDF_Font;
begin
  if cmd = nil
    then exit;

  if Settings.PdfExactWidthMm <= 0
    then ewr := 1
    else ewr := (Settings.PdfExactWidthMm * 72 / 25.4) / NthInt(cmd[0], 1);

  for i := 0 to cmd.Count - 1 do
    begin
      line := cmd[i];
      func := NthWord(line, 1);
      arg1 := NthWord(line, 2);
      arg2 := NthWord(line, 3);

      // StrokeColor
      if func = 'StrokeColor' then
        begin
          ColorToRGB(StrToInt(arg1), red, green, blue);
          HPDF_Page_SetRGBStroke(page, red, green, blue)
        end;

      // FillColor
      if func = 'FillColor' then
        begin
          ColorToRGB(StrToInt(arg1), red, green, blue);
          HPDF_Page_SetRGBFill(page, red, green, blue)
        end;

      // Fill
      if func = 'Fill' then
        begin
          //todo if required
        end;

      // LineWidth
      if func = 'LineWidth' then
        begin
          HPDF_Page_SetLineWidth(page, StrToFloatDef(arg1, 0.5))
        end;

      // Polyline x y x y ... / Closeline x y x y ... / Fillpoly x y x y ...
      if (func = 'Polyline') or (func = 'Closeline')
                             or (func = 'Fillpoly') then
        begin
          HPDF_Page_MoveTo(page, offX + ewr * StrToFloat(arg1),
                                 offY - ewr * StrToFloat(arg2));
          k := 4;
          arg1 := NthWord(line, k);

          while arg1 <> '' do
            begin
              arg2 := NthWord(line, k + 1);
              HPDF_Page_LineTo(page, offX + ewr * StrToFloat(arg1),
                                     offY - ewr * StrToFloat(arg2));
              inc(k, 2);
              arg1 := NthWord(line, k)
            end;

          if func = 'Closeline'
            then HPDF_Page_ClosePathStroke(page);

          if func = 'Fillpoly'
            then HPDF_Page_FillStroke(page);

          if func = 'Polyline'
            then HPDF_Page_Stroke(page)
        end;

      // Circle x y r pen col
      if func = 'Circle' then
        begin
          x    := NthInt(line, 2);
          y    := NthInt(line, 3);
          r    := NthFloat(line, 4);
          pen  := NthInt(line, 5);
          col  := NthInt(line, 6);

          ColorToRGB(col, red, green, blue);
          HPDF_Page_SetRGBFill(page, red, green, blue);
          ColorToRGB(pen, red, green, blue);
          HPDF_Page_SetRGBStroke(page, red, green, blue);

          HPDF_Page_Circle(page, offX + ewr * x, offY - ewr * y, ewr * r);

          if col < 0
            then HPDF_Page_Stroke(page)
            else HPDF_Page_FillStroke(page)
      end;

      // SetFont name, size
      if func = 'SetFont' then
        begin
          name := NthWord(line, 1);
          size := NthInt (line, 2);
          //todo if required
        end;

      // TextOut x y s size pen ['bold']
      if func = 'TextOut' then
        begin
          xf   := ewr * NthFloat(line, 2);
          yf   := ewr * NthFloat(line, 3);
          s    := NthWord(line, 4);
          size := ewr * NthFloat(line, 5);
          pen  := NthInt (line, 6);
          bold := NthWord(line, 7) = 'bold';

          if bold
            then font := HPDF_GetFont(pdf, 'Helvetica-Bold', nil)
            else font := HPDF_GetFont(pdf, 'Helvetica', nil);

          HPDF_Page_SetFontAndSize(page, font, size);
          HPDF_Page_BeginText(page);
          HPDF_Page_MoveTextPos(page, offX + xf, offY - yf);
          if pen = 0
            then HPDF_Page_SetGrayFill(page, 0)
            else HPDF_Page_SetGrayFill(page, 1);
          HPDF_Page_ShowText(page, PChar(s));
          HPDF_Page_EndText(page)
        end;
    end
end;

// ---------------------------------------------------------------------------

procedure ExportImagePDF(comCanvas : TStringList; imgName : string);
var
  exporter : TExporterPDF;
  ok : boolean;
  ewr : double;
begin
  exporter := TExporterPDF.Create(eiPDF, imgName);

  //pdf.SetPageMargins(10, 10, 10, 10);
  exporter.SetPageMargins(0, 0, 0, 0);
  exporter.BeginDoc(ok);

  if Settings.PdfExactWidthMm <= 0
    then ewr := 1
    else ewr := (Settings.PdfExactWidthMm * 72 / 25.4) / NthInt(comCanvas[0], 1);

  HPDF_Page_SetWidth (exporter.page, Round(NthInt(comCanvas[0], 1) * ewr));
  HPDF_Page_SetHeight(exporter.page, Round(NthInt(comCanvas[0], 2) * ewr));

  ApplyCommandCanvas(exporter.page,
                     exporter.pdf,
                     comCanvas,
                     0,
                     ewr * NthInt(comCanvas[0], 2));//pdf.YPos);
  exporter.EndDoc;
  exporter.Free
end;

// ---------------------------------------------------------------------------

end.
