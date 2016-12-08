// ---------------------------------------------------------------------------
// -- Drago -- Export to MS Word ------------------------- UExporterDOC.pas --
// ---------------------------------------------------------------------------

unit UExporterDOC;

// ---------------------------------------------------------------------------

interface

uses
  Classes, Graphics, SysUtils, StrUtils, Types, Variants,
  DefineUi, UExporter, UExporterIMG, CodePages,
  ComObj;

type
  TExporterDOC = class(TExporter)
    FileName : string;
    WordApp, WordDoc, WordDocs, ActiveDoc, BeginGrp : OleVariant;
    constructor Create(aExportFigure : TExportFigure; aFileName : string); override;
    destructor Destroy; override;
    procedure BeginDoc(var ok : boolean); override;
    procedure EndDoc; override;
    procedure BeginGroup; override;
    procedure EndGroup; override;
    procedure AddPage; override;
    procedure SetupHeader(sLeft, sCenter, sRight : string; addLine : boolean); override;
    procedure SetupFooter(sLeft, sCenter, sRight : string; addLine : boolean); override;
    function  PrinterPxPerInchX : integer; override;
    function  PrinterPxPerInchY : integer; override;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); override;
    procedure FontName(name : string); override;
    procedure FontSize(ptSize : integer); override;
    procedure FontStyle(styles : TExporterFontStyles); override;
    procedure NewLine; override;
    procedure WriteText(s : string); override;
    procedure DrawLine(double: boolean); override;
    procedure ClearColumns; override;
    procedure AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign); override;
    procedure WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault); override;
    procedure DrawImagesAcrossCols(n : integer); override;
    private
    procedure GotoEnd;
    procedure DoHeaderFooter(rng : OleVariant;
                             sLeft, sCenter, sRight : string);
    procedure DoHeaderFooterString(s : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  UStatus, 
  UImageExporterBMP,
  UImageExporterWMF;

const 
  wdCollapseEnd = 0;
  wdParagraph   = 4;
  wdStory       = 6;

  wdMove        = 0;
  wdExtend      = 1;

  wdPageBreak             = $00000007;

  wdPropertyTitle         = $00000001;
  wdPropertySubject       = $00000002;
  wdPropertyAuthor        = $00000003;
  wdPropertyKeywords      = $00000004;
  wdPropertyComments      = $00000005;

  wdAlignParagraphLeft    = $00000000;
  wdAlignParagraphCenter  = $00000001;
  wdAlignParagraphRight   = $00000002;
  wdAlignParagraphJustify = $00000003;

  wdHeaderFooterPrimary   = $00000001;
  wdHeaderFooterFirstPage = $00000002;
  wdHeaderFooterEvenPages = $00000003;

  wdMainTextStory         = $00000001;
  wdPrimaryHeaderStory    = $00000007;
  wdPrimaryFooterStory    = $00000009;

  wdPaperLetter           = $00000002;
  wdPaperLetterSmall      = $00000003;
  wdPaperLegal            = $00000004;
  wdPaperExecutive        = $00000005;
  wdPaperA3               = $00000006;
  wdPaperA4               = $00000007;
  wdPaperA4Small          = $00000008;
  wdPaperA5               = $00000009;

  wdAlignTabLeft          = $00000000;
  wdAlignTabCenter        = $00000001;
  wdAlignTabRight         = $00000002;
  wdOrientLandscape       = 1;
  wdOrientPortrait        = 0;

  wdBorderTop             = $FFFFFFFF;
  wdBorderLeft            = $FFFFFFFE;
  wdBorderBottom          = $FFFFFFFD;
  wdBorderRight           = $FFFFFFFC;
  wdBorderHorizontal      = $FFFFFFFB;
  wdBorderVertical        = $FFFFFFFA;
  wdLineStyleNone         = $00000000;
  wdLineStyleSingle       = $00000001;
  wdLineStyleDouble       = $00000007;

  wdDoNotSaveChanges      = $00000000;

  wdFieldEmpty            = $FFFFFFFF;

// -- Construction and destruction -------------------------------------------

constructor TExporterDOC.Create(aExportFigure : TExportFigure; aFileName : string); 
begin
  FExportMode   := emExportDOC;
  fExportFigure := aExportFigure;
  Filename      := aFileName;
  Filename      := ChangeFileExt(Filename, '.doc');
  PaperSize     := PaperNameToSize(Settings.prPaperSize, False);
  nFigures      := 0;
end;

destructor TExporterDOC.Destroy;
begin
  inherited Destroy
end;

// -- Structure of the document ----------------------------------------------

// -- Document

procedure TExporterDOC.BeginDoc(var ok : boolean);
var
  size : TSize; 
  x : integer;
begin
  WordApp := CreateOleObject('Word.Application');
  WordApp.Visible := False;
  WordDocs  := WordApp.Documents;
  WordDoc   := WordDocs.Add;
  ActiveDoc := WordApp.ActiveDocument;
  ok := True;
  WordApp.Options.CheckSpellingAsYouType := False;
  WordApp.Options.CheckGrammarAsYouType  := False;

  ActiveDoc.BuiltInDocumentProperties[wdPropertyTitle].Value := '';
  ActiveDoc.BuiltInDocumentProperties[wdPropertyComments].Value :=
    'Exported by ' + AppName + ' ' + AppVersion;

  (* launches an exception if no printer installed
  case AnsiIndexStr(Settings.prPaperSize, ['A5', 'A4', 'Letter', 'Legal', 'A3']) of
    0 : format := wdPaperA5;
    1 : format := wdPaperA4;
    2 : format := wdPaperLetter;
    3 : format := wdPaperLegal;
    4 : format := wdPaperA3;
  end;
  ActiveDoc.PageSetup.PaperSize := format;
  *)

  ActiveDoc.PageSetup.PageWidth  := PaperSize.cx / 25.4 * 72;
  ActiveDoc.PageSetup.PageHeight := PaperSize.cy / 25.4 * 72;
  if Settings.prLandscape
    then ActiveDoc.PageSetup.Orientation := wdOrientLandscape
    else ActiveDoc.PageSetup.Orientation := wdOrientPortrait;
  if Settings.prLandscape then
    begin
      x := PaperSize.cx; PaperSize.cx := PaperSize.cy; PaperSize.cy := x
    end
end;

procedure TExporterDOC.EndDoc;
begin
  ActiveDoc.SaveAs(FileName);
  ActiveDoc.Close;
  WordApp.Quit;
  WordApp := Unassigned;
end;

// -- Groups

procedure TExporterDOC.BeginGroup;
begin
  BeginGrp := ActiveDoc.Paragraphs.Count
end;

procedure TExporterDOC.EndGroup;
var
  i : integer;
begin
  for i := BeginGrp to ActiveDoc.Paragraphs.Count - 1 do
    ActiveDoc.Paragraphs.Item(i).KeepWithNext := True
end;

// -- Pages

procedure TExporterDOC.AddPage;
var
  wd: OLEVariant;
begin
  wd := wdPageBreak;
  WordApp.Selection.Collapse(wdCollapseEnd);
  WordApp.Selection.InsertBreak(wd)
end;

// -- Header and Footer

procedure TExporterDOC.SetupHeader(sLeft, sCenter, sRight : string;
                                   addLine : boolean);
var
  rngHeader, par : OleVariant;
begin
  rngHeader := activeDoc.Sections.Item(1)
                        .Headers .Item(wdHeaderFooterPrimary).Range;

  DoHeaderFooter(rngHeader, sLeft, sCenter, sRight);

  rngHeader.InsertParagraphAfter;
  par := rngHeader.Paragraphs.Item(rngHeader.Paragraphs.Count);
  par.Borders.Item(wdBorderTop).LineStyle := wdLineStyleSingle;

  rngHeader.Font.Name := fFontName;
  rngHeader.Font.Size := fFontSize
end;

procedure TExporterDOC.SetupFooter(sLeft, sCenter, sRight : string;
                                   addLine : boolean);
var
  rngFooter, par : OleVariant;
begin
  rngFooter := activeDoc.Sections.Item(1)
                        .Footers .Item(wdHeaderFooterPrimary).Range;

  rngFooter.InsertParagraphAfter;
  par := rngFooter.Paragraphs.Item(rngFooter.Paragraphs.Count);
  par.Borders.Item(wdBorderTop).LineStyle := wdLineStyleSingle;

  DoHeaderFooter(rngFooter, sLeft, sCenter, sRight);

  rngFooter.Font.Name := fFontName;
  rngFooter.Font.Size := fFontSize
end;

procedure TExporterDOC.DoHeaderFooter(rng : OleVariant;
                                      sLeft, sCenter, sRight : string);
var
  w, w1, w2 : integer;
begin
  w  := PaperSize.cx - PageMargins.Left - PageMargins.Right;
  w1 := Round(w / 25.4 * 36);
  w2 := Round(w / 25.4 * 72);

  rng.Paragraphs.TabStops.ClearAll;
  rng.Paragraphs.TabStops.Add(w1, wdAlignTabCenter);
  rng.Paragraphs.TabStops.Add(w2, wdAlignTabRight);
  rng.Select;
  DoHeaderFooterString(sLeft);
  WordApp.Selection.InsertAfter(^I);
  DoHeaderFooterString(sCenter);
  WordApp.Selection.InsertAfter(^I);
  DoHeaderFooterString(sRight);
  ActiveDoc.StoryRanges.Item(wdMainTextStory).Select;
  GotoEnd
end;

procedure TExporterDOC.DoHeaderFooterString(s : string);
var
  p : integer;
  s1, s2 : string;
begin
  p := Pos('<<pagenumber>>', s);

  if p = 0
    then WordApp.Selection.InsertAfter(s)
    else
      begin
        s1 := LeftStr (s, p - 1);
        s2 := RightStr(s, Length(s) - p - Length('<<pagenumber>>'));

        WordApp.Selection.InsertAfter(s1);
        WordApp.Selection.Collapse(wdCollapseEnd);
        WordApp.Selection.Fields.Add(WordApp.Selection.Range,
                                     wdFieldEmpty, 'PAGE ', True);
        WordApp.Selection.InsertAfter(s2)
      end
end;

// -- Format -----------------------------------------------------------------

function  TExporterDOC.PrinterPxPerInchX : integer;
begin
  Result := 360
end;

function  TExporterDOC.PrinterPxPerInchY : integer;
begin
  Result := 360
end;

procedure TExporterDOC.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
var
  x : single;
begin
  PageMargins := Rect(mmLeft, mmTop, mmRight, mmBottom);

  x := mmLeft   / 25.4 * 72;
  ActiveDoc.PageSetup.LeftMargin     := x;
  x := mmRight  / 25.4 * 72;
  ActiveDoc.PageSetup.RightMargin    := x;
  x := mmTop    / 25.4 * 72;
 //ActiveDoc.PageSetup.TopMargin      := x;
  ActiveDoc.PageSetup.HeaderDistance := x;
  x := mmBottom / 25.4 * 72;
 //ActiveDoc.PageSetup.BottomMargin   := x;
  ActiveDoc.PageSetup.FooterDistance := x;
end;

procedure TExporterDOC.FontName(name : string);
begin
  fFontName := name
end;

procedure TExporterDOC.FontSize(ptSize : integer);
begin
  fFontSize := ptSize
end;

procedure TExporterDOC.FontStyle(styles : TExporterFontStyles);
begin
  fFontStyle := styles
end;

// -- Text -------------------------------------------------------------------

procedure TExporterDOC.NewLine;
begin
  WordApp.Selection.InsertParagraphAfter
end;

procedure TExporterDOC.WriteText(s : string);
begin
  WordApp.Selection.Collapse(wdCollapseEnd);
  WordApp.Selection.InsertAfter(UTF8Decode(s));
  WordApp.Selection.InsertParagraphAfter;

  WordApp.Selection.Range.Font.Name := fFontName;
  WordApp.Selection.Range.Font.Size := fFontSize;
  WordApp.Selection.Font.Bold      := efsBold      in fFontStyle;
  WordApp.Selection.Font.Italic    := efsItalic    in fFontStyle;
  WordApp.Selection.Font.Underline := efsUnderline in fFontStyle;

  WordApp.Selection.ParagraphFormat.Alignment := wdALignParagraphJustify
end;

procedure TExporterDOC.DrawLine(double: boolean);
var
  par : OleVariant;
begin
  WordApp.Selection.InsertParagraphAfter;
  par := activeDoc.Paragraphs.Item(activeDoc.Paragraphs.Count);
  par.Borders.Item(wdBorderTop).LineStyle := wdLineStyleSingle;
  WordApp.Selection.InsertParagraphAfter;
  par := activeDoc.Paragraphs.Item(activeDoc.Paragraphs.Count);
  par.Borders.Item(wdBorderTop).LineStyle := wdLineStyleNone;

  GotoEnd;
end;

// -- Columns ----------------------------------------------------------------

procedure TExporterDOC.ClearColumns;
begin
  fColNum := 0
end;

procedure TExporterDOC.AddColumn(mmLeft, mmRight : integer; colAlign : TExporterColAlign);
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

procedure TExporterDOC.WriteTextAcrossCols(text : TStringDynArray; cp : TCodePage = cpDefault);
var
  i, align : integer;
  table : OleVariant;
begin
  if Length(text) = 0
    then exit;
  CleanDelimiters(text);

  GotoEnd;
  table := WordDoc.Tables.Add(WordApp.Selection.Range, 1, fColNum);
  table.Borders.Item(wdBorderLeft      ).LineStyle := wdLineStyleNone;
  table.Borders.Item(wdBorderTop       ).LineStyle := wdLineStyleNone;
  table.Borders.Item(wdBorderRight     ).LineStyle := wdLineStyleNone;
  table.Borders.Item(wdBorderBottom    ).LineStyle := wdLineStyleNone;
  table.Borders.Item(wdBorderHorizontal).LineStyle := wdLineStyleNone;
  table.Borders.Item(wdBorderVertical  ).LineStyle := wdLineStyleNone;

  for i := 0 to fColNum - 1 do
    if i >= Length(text)
      then //
      else
        begin
          case fColAlign[i] of
            ecaLeft   : align := wdALignParagraphLeft;
            ecaRight  : align := wdALignParagraphRight;
            ecaCenter : align := wdALignParagraphCenter
          end;

          table.Cell(table.Rows.Count, i + 1).Range.Text := UTF8Decode(text[i]);
          table.Cell(table.Rows.Count, i + 1).Range.Font.Name := fFontName;
          table.Cell(table.Rows.Count, i + 1).Range.Font.Size := fFontSize;
          table.Cell(table.Rows.Count, i + 1).Select;
          WordApp.Selection.ParagraphFormat.Alignment := align
        end;

  GotoEnd
end;

// -- Images -----------------------------------------------------------------

procedure TExporterDOC.DrawImagesAcrossCols(n : integer);
var
  i : integer;
  name : string;
  LinkToFile : OleVariant;
  SaveWithDocument : OleVariant;
  Shape : OleVariant;
  ovName : OleVariant;
  table : OleVariant;
  bitmap : TBitmap;
  metafile : TMetafile;
begin
  if n = 0
    then exit;

  GotoEnd;
  table := WordDoc.Tables.Add(WordApp.Selection.Range, 1, fColNum);

  LinkToFile := False;
  SaveWithDocument := True;

  for i := 0 to fColNum - 1 do
    if i >= n
      then // nop
      else
        begin
          bitmap := nil;
          metafile := nil;
          if FExportFigure = eiWMF
            then metafile := (FExportImg[i] as TExportedImageWMF).FMetafile
            else bitmap   := (FExportImg[i] as TExportedImageBMP).Bitmap;
          ExportImage(bitmap, metafile, nil, FExportFigure,
                      Status.TmpPath + '\tmp.sgf',
                      PrinterPxPerInchX, nFigures, name);

          inc(nFigures);
          ovName := name;

          table.Cell(table.Rows.Count, i + 1).Select;
          WordApp.Selection.ParagraphFormat.Alignment := wdALignParagraphCenter;
          Shape := WordApp.Selection.InlineShapes.AddPicture(ovName,
                                                             LinkToFile,
                                                             SaveWithDocument,
                                                             EmptyParam)
        end;
  GotoEnd
end;

// -- Helpers ----------------------------------------------------------------

procedure TExporterDOC.GotoEnd;
var
  p1, p2 : OleVariant;
begin
  p1 := wdStory;
  p2 := wdMove;
  WordApp.Selection.EndKey (p1, p2)
end;

// ---------------------------------------------------------------------------

end.
