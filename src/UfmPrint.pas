// ---------------------------------------------------------------------------
// -- Drago -- Form for printing and exporting games --------- UfmPrint.pas --
// ---------------------------------------------------------------------------

unit UfmPrint;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, IniFiles,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, Math, StrUtils,
  Windows, Messages, Dlgs, TypInfo,
  DefineUi, UStatus, UView, CheckLst, Grids,
  TntForms, TntComCtrls, TntStdCtrls, SpTBXControls, SpTBXItem;

type
  TfmPrint = class(TTntForm)
    ProgressBar: TProgressBar;
    edDum: TEdit;
    PageControl: TTntPageControl;
    TabSheet1: TTntTabSheet;
    TabSheet2: TTntTabSheet;
    TabSheet3: TTntTabSheet;
    lbStyles: TListBox;
    pnAddStyle: TPanel;
    edAddStyle: TEdit;
    TabSheet4: TTntTabSheet;
    lbEscape: TTntLabel;
    lbDebug: TTntLabel;
    lbAddStyle: TTntLabel;
    gbSelectedGames: TSpTBXGroupBox;
    GroupBox5: TSpTBXGroupBox;
    lbInfosFormat: TTntLabel;
    edInfosFormat: TEdit;
    gbTitle: TSpTBXGroupBox;
    GroupBox6: TSpTBXGroupBox;
    edPos: TEdit;
    edStep: TEdit;
    GroupBox7: TSpTBXGroupBox;
    GroupBox1: TSpTBXGroupBox;
    GroupBox2: TSpTBXGroupBox;
    sbLayout1: TSpeedButton;
    sbLayout2: TSpeedButton;
    sbLayout3: TSpeedButton;
    Bevel1: TBevel;
    sbLayout4: TSpeedButton;
    Label1: TTntLabel;
    Label2: TTntLabel;
    Label7: TTntLabel;
    edFigPerLine: TEdit;
    edFigRatio: TEdit;
    edFirstFigRatio: TEdit;
    GroupBox3: TSpTBXGroupBox;
    Label4: TTntLabel;
    Label5: TTntLabel;
    Label6: TTntLabel;
    edLabel7: TTntLabel;
    edLeft: TEdit;
    edRight: TEdit;
    edTop: TEdit;
    edBottom: TEdit;
    gbFont: TSpTBXGroupBox;
    Label8: TTntLabel;
    Label9: TTntLabel;
    cbFontNames: TComboBox;
    cbFontSizes: TComboBox;
    gbGames: TSpTBXGroupBox;
    sgFormatGames: TStringGrid;
    gbFigures: TSpTBXGroupBox;
    sgFormatFigures: TStringGrid;
    gbSettings: TSpTBXGroupBox;
    gbPaper: TSpTBXGroupBox;
    cbPaper: TComboBox;
    cbInclTitle: TTntCheckBox;
    cbRelNum: TTntCheckBox;
    cbInclStartPos: TTntCheckBox;
    cbLastPos: TTntCheckBox;
    cbInterPos: TTntCheckBox;
    cbStepPos: TTntCheckBox;
    cbFileFig: TTntCheckBox;
    cbVariations: TTntCheckBox;
    cbMarkCom: TTntCheckBox;
    cbRemindTitle: TTntCheckBox;
    cbComments: TTntCheckBox;
    cbPrintHeader: TTntCheckBox;
    cbPrintFooter: TTntCheckBox;
    cbFirstFigAlone: TTntCheckBox;
    cbCompressPDF: TTntCheckBox;
    cbLandscape: TTntCheckBox;
    rbCurrent: TTntRadioButton;
    rbAll: TTntRadioButton;
    rbFromTo: TTntRadioButton;
    rbInfosTop: TTntRadioButton;
    rbInfosName: TTntRadioButton;
    rbInfosNo: TTntRadioButton;
    cbRemindMoves: TTntCheckBox;
    btPreview: TTntButton;
    btPrint: TTntButton;
    btCancel: TTntButton;
    btHelp: TTntButton;
    btExportGames: TTntButton;
    btExportFigures: TTntButton;
    btGoban: TTntButton;
    btAddStyle: TTntButton;
    btRemove: TTntButton;
    btOkStyle: TTntButton;
    btCancelStyle: TTntButton;
    mmViewStyle: TTntMemo;
    lbQualityJPEG: TTntLabel;
    edQualityJPEG: TTntEdit;
    edFmtMainTitle: TTntEdit;
    lbFmtMainTitle: TTntLabel;
    edFmtVarTitle: TTntEdit;
    lbFmtVarTitle: TTntLabel;
    edFrom: TTntEdit;
    lbFrom: TTntLabel;
    edTo: TTntEdit;
    lbTo: TTntLabel;
    edHeaderFormat: TTntEdit;
    edFooterFormat: TTntEdit;
    lbHeaderFormat: TTntLabel;
    lbFooterFormat: TTntLabel;
    tabSheetExportToAscii: TTntTabSheet;
    rgBoardFormat: TRadioGroup;
    procedure btPreviewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure sbLayout1Click(Sender: TObject);
    procedure sbLayout2Click(Sender: TObject);
    procedure sbLayout3Click(Sender: TObject);
    procedure edFigPerLineChange(Sender: TObject);
    procedure btPrintClick(Sender: TObject);
    procedure cbPrintHeaderClick(Sender: TObject);
    procedure cbPrintFooterClick(Sender: TObject);
    procedure rbCurrentClick(Sender: TObject);
    procedure edFromClick(Sender: TObject);
    procedure rbInfosNoClick(Sender: TObject);
    procedure btExportGamesClick(Sender: TObject);
    procedure btExportFiguresClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure cbFirstFigAloneClick(Sender: TObject);
    procedure sbLayout4Click(Sender: TObject);
    procedure cbLastPosClick(Sender: TObject);
    procedure cbInclTitleClick(Sender: TObject);
    procedure lbStylesClick(Sender: TObject);
    procedure btAddStyleClick(Sender: TObject);
    procedure btCancelStyleClick(Sender: TObject);
    procedure btOkAddStyleClick(Sender: TObject);
    procedure btOkRemoveStyleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabSheet3Show(Sender: TObject);
    procedure cbCommentsClick(Sender: TObject);
    procedure btRemoveClick(Sender: TObject);
    procedure btGobanClick(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
    var AllowChange: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure edDumKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure sgFormatGamesClick(Sender: TObject);
    procedure sgFormatFiguresClick(Sender: TObject);
    procedure sgFormatDrawCell(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; states : string);
    procedure sgFormatFiguresDrawCell(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; State: TGridDrawState);
    procedure sgFormatGamesDrawCell(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; State: TGridDrawState);
    procedure btExportGamesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    function  CheckValues : boolean;
    function  ValidateNumEdit(page : integer;
                              ed : TCustomEdit;
                              var n : integer;
                              min, max : integer) : boolean;
    procedure SetLayout(FirstFigAlone : boolean;
                        FirstFigRatio, FigPerLine, FigRatio : integer);
    function  MatchLayout(FirstFigAlone : boolean;
                          FirstFigRatio, FigPerLine, FigRatio : string) : boolean;
    procedure InitFormatTab;
    function  IsWordRunning : boolean;
    procedure SelectGameFormat(key : string);
    procedure SelectFigureFormat(key : string);
    function  GetGameFormat : TExportGame;
    function  GetFigureFormat : TExportFigure;
    function  ActiveView : TView;
    procedure SetProgressStrategy(var n : integer; var onGames : boolean);
    procedure ProgressSetting;
    function  ProgressTest : boolean;
    function  ProgressStep : boolean;
  public
    PrintOrExport : integer;
    Abort : boolean;
    class procedure Execute(printOrExportMode : integer);
    procedure UpdateForm  (st : TStatus);
    function  UpdateStatus(st : TStatus) : boolean;
    procedure UpdateViewStyle(st : TStatus);
    procedure InhibButtons(inhib : boolean);
  end;

var
  fmPrint: TfmPrint;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  TntWindows,
  Std, WinUtils, Translate, TranslateVcl, UPrint, UPrintStyles, Main,
  HtmlHelpAPI, Preview, UfmOptions, UfmExtract, UfmMsg, UDialogs, UExporter,
  UExporterNFG, UExporterPRE,
  UExporterDOC, UExporterTXT,
  UExporterHTM, UExporterRTF, UExporterIMG, UExporterPDF,
  UImageExporter,
  UImageExporterBMP,
  UImageExporterPDF,
  UImageExporterTXT,
  UImageExporterWMF;

// -- Display request --------------------------------------------------------

class procedure TfmPrint.Execute(printOrExportMode : integer);
begin
  fmPrint := TfmPrint.Create(Application);

  with fmPrint do
    try
      PrintOrExport := printOrExportMode;
      ShowModal
    finally
      Release;
      fmPrint := nil
    end
end;

function TfmPrint.ActiveView : TView;
begin
  Result := fmMain.ActiveView
end;

// -- Form update ------------------------------------------------------------

procedure TfmPrint.UpdateForm(st : TStatus);
begin
  // games
  rbCurrent.Checked       := st.PrGames = pgCurrent;
  rbAll.Checked           := st.PrGames = pgAll;
  rbFromTo.Checked        := st.PrGames = pgFromTo;
  lbFrom.Enabled          := rbFromTo.Checked;
  edFrom.Enabled          := rbFromTo.Checked;
  lbTo.Enabled            := rbFromTo.Checked;
  edTo.Enabled            := rbFromTo.Checked;
  edFrom.Text             := IntToStr(st.PrFrom);
  edTo.Text               := IntToStr(st.PrTo);
  // figures
  cbInclStartPos.Checked  := st.PrInclStartPos;
  cbLastPos.Checked       := st.PrFigures = fgLast;
  cbInterPos.Checked      := st.PrFigures = fgInter;
  cbStepPos.Checked       := st.PrFigures = fgStep;
  cbMarkCom.Checked       := st.PrFigures = fgMarkCom;
  cbFileFig.Checked       := st.PrFIgures = fgPropFG;
  edPos.Enabled           := cbInterPos.Checked;
  edPos.Text              := IntToStr(st.PrPos);
  edStep.Enabled          := cbStepPos.Checked;
  edStep.Text             := IntToStr(st.PrStep);
  cbVariations.Checked    := st.PrInclVar;
  // include info
  rbInfosNo.Checked       := st.PrInclInfos = inNone;
  rbInfosTop.Checked      := st.PrInclInfos = inTop;
  rbInfosName.Checked     := st.PrInclInfos = inName;
  case st.PrInclInfos of
    inNone : edInfosFormat.Text := '';
    inTop  : edInfosFormat.Text := st.PrInfosTopFmt;
    inName : edInfosFormat.Text := st.PrInfosNameFmt
  end;
  lbInfosFormat.Enabled   := not rbInfosNo.Checked;
  edInfosFormat.Enabled   := not rbInfosNo.Checked;
  // include comments
  cbComments.Checked      := st.PrInclComm;
  cbRemindTitle.Checked   := st.PrRemindTitle;
  cbRemindMoves.Checked   := st.PrRemindMoves;
  cbRemindTitle.Enabled   := cbComments.Checked;
  cbRemindMoves.Enabled   := cbComments.Checked;
  // titles
  cbInclTitle.Checked     := st.PrInclTitle;
  cbRelNum.Checked        := st.PrRelNum;
  edFmtMainTitle.Text     := UTF8Decode(st.PrFmtMainTitle);
  edFmtVarTitle.Text      := UTF8Decode(st.PrFmtVarTitle);
  cbInclTitleClick(nil);
  // header and footer
  cbPrintHeader.Checked   := st.PrPrintHeader;
  cbPrintFooter.Checked   := st.PrPrintFooter;
  edHeaderFormat.Text     := UTF8Decode(st.PrHeaderFormat);
  edFooterFormat.Text     := UTF8Decode(st.PrFooterFormat);
  lbHeaderFormat.Enabled  := cbPrintHeader.Checked;
  lbFooterFormat.Enabled  := cbPrintFooter.Checked;
  edHeaderFormat.Enabled  := cbPrintHeader.Checked;
  edFooterFormat.Enabled  := cbPrintFooter.Checked;
  // layout
  cbFirstFigAlone.Checked := st.PrFirstFigAlone;
  edFirstFigRatio.Enabled := cbFirstFigAlone.Checked;
  edFirstFigRatio.Text    := IntToStr(st.PrFirstFigRatio);
  edFigPerLine.Text       := IntToStr(st.PrFigPerLine);
  edFigRatio.Text         := IntToStr(st.PrFigRatio);
  // margins
  edLeft.Text             := NthWord(st.PrMargins, 1, ',');
  edRight.Text            := NthWord(st.PrMargins, 2, ',');
  edTop.Text              := NthWord(st.PrMargins, 3, ',');
  edBottom.Text           := NthWord(st.PrMargins, 4, ',');
  // fonts
  cbFontNames.Items       := Screen.Fonts;
  cbFontNames.ItemIndex   := cbFontNames.Items.IndexOf(st.PrFontName);
  cbFontSizes.ItemIndex   := cbFontSizes.Items.IndexOf(IntToStr(st.PrFontSize));
  // format
  cbPaper.Enabled         := st.PrExportGame in [egRTF, egPDF, egDOC];
  cbLandscape.Enabled     := st.PrExportGame in [egRTF, egPDF, egDOC];
  cbPaper.Text            := st.PrPaperSize;
  cbLandscape.Checked     := st.PrLandscape;
  cbCompressPDF.Checked   := st.PrCompressPDF;
  cbCompressPDF.Enabled   := st.PrExportGame = egPDF;
  lbQualityJPEG.Enabled   := st.PrExportFigure = eiJPG;
  edQualityJPEG.Text      := IntToStr(st.PrQualityJPEG);
  edQualityJPEG.Enabled   := st.PrExportFigure = eiJPG
end;

// -- Status update ----------------------------------------------------------

function TfmPrint.UpdateStatus(st : TStatus) : boolean;
var
  nLeft, nRight, nTop, nBottom : integer;
begin
  Result := CheckValues;
  if not Result
    then exit;

  // Games
  if rbCurrent.Checked then st.PrGames := pgCurrent else
  if rbAll.Checked     then st.PrGames := pgAll     else
  if rbFromTo.Checked  then st.PrGames := pgFromTo;
  if rbFromTo.Checked  then st.PrFrom  := StrToInt(edFrom.Text);
  if rbFromTo.Checked  then st.PrTo    := StrToInt(edTo  .Text);
  // Figures
  st.PrInclStartPos  := cbInclStartPos.Checked;
  if cbLastPos.Checked  then st.PrFigures := fgLast    else
  if cbInterPos.Checked then st.PrFigures := fgInter   else
  if cbStepPos.Checked  then st.PrFigures := fgStep    else
  if cbMarkCom.Checked  then st.PrFigures := fgMarkCom else
  if cbFileFig.Checked  then st.PrFigures := fgPropFG
                        else st.PrFigures := fgNone;
  if cbInterPos.Checked then st.PrPos     := StrToInt(edPos .Text);
  if cbStepPos.Checked  then st.PrStep    := StrToInt(edStep.Text);
  st.PrInclVar       := cbVariations.Checked;
  // Include game information
  if rbInfosNo.Checked   then st.PrInclInfos    := inNone else
  if rbInfosTop.Checked  then st.PrInclInfos    := inTop  else
  if rbInfosName.Checked then st.PrInclInfos    := inName;
  if rbInfosTop.Checked  then st.PrInfosTopFmt  := edInfosFormat.Text else
  if rbInfosName.Checked then st.PrInfosNameFmt := edInfosFormat.Text;
  // Include comments
  st.PrInclComm      := cbComments.Checked;
  st.PrRemindTitle   := cbRemindTitle.Checked;
  st.PrRemindMoves   := cbRemindMoves.Checked;
  // Titles
  st.PrInclTitle     := cbInclTitle.Checked;
  st.PrRelNum        := cbRelNum.Checked;
  st.PrFmtMainTitle  := UTF8Encode(edFmtMainTitle.Text);
  st.PrFmtVarTitle   := UTF8Encode(edFmtVarTitle.Text);
  // Header and footer
  st.PrPrintHeader   := cbPrintHeader.Checked;
  st.PrPrintFooter   := cbPrintFooter.Checked;
  st.PrHeaderFormat  := UTF8Encode(edHeaderFormat.Text);
  st.PrFooterFormat  := UTF8Encode(edFooterFormat.Text);
  // Layout
  st.PrFirstFigAlone := cbFirstFigAlone.Checked;
  if cbFirstFigAlone.Checked then st.PrFirstFigRatio := StrToInt(edFirstFigRatio.Text);
  st.PrFigPerLine    := StrToInt(edFigPerLine.Text);
  st.PrFigRatio      := StrToInt(edFigRatio.Text);
  // Margins
  nLeft              := StrToInt(edLeft  .Text);
  nRight             := StrToInt(edRight .Text);
  nTop               := StrToInt(edTop   .Text);
  nBottom            := StrToInt(edBottom.Text);
  st.PrMargins       := Format('%d,%d,%d,%d',
                               [nLeft, nRight, nTop, nBottom]);
  // Fonts
  st.PrFontName      := cbFontNames.Items[cbFontNames.ItemIndex];
  st.PrFontSize      := StrToIntDef(cbFontSizes.Items[cbFontSizes.ItemIndex], 10);
  // Format
  st.PrExportGame    := GetGameFormat;
  st.PrExportFigure  := GetFigureFormat;
  st.PrPaperSize     := cbPaper.Text;
  st.PrLandscape     := cbLandscape.Checked;
  st.PrCompressPDF   := cbCompressPDF.Checked;
  st.PrQualityJPEG   := StrToInt(edQualityJPEG.Text);

  // settings for export to ascii
  if PageControl.ActivePage = tabSheetExportToAscii then
    begin
      Settings.PrExportGame := egTXT;
      case rgBoardFormat.ItemIndex of
        0 : Settings.PrExportFigure := eiSSL;
        1 : Settings.PrExportFigure := eiRGG;
        2 : Settings.PrExportFigure := eiTRC;
      end
    end
end;

function TfmPrint.ValidateNumEdit(page : integer;
                                    ed : TCustomEdit;
                                 var n : integer;
                              min, max : integer) : boolean;
begin
  Result := TryStrToInt(ed.Text, n);

  if Result and (n < min) then
    begin
      ed.Text := IntToStr(min);
      Result := False
    end;
  if Result and (n > max) then
    begin
      ed.Text := IntToStr(max);
      Result := False
    end;
  if not Result then
    begin
      PageControl.ActivePage := PageControl.Pages[page];
      ActiveControl := ed;
      ed.SelStart   := 0;
      ed.SelLength  := maxint
    end
end;

function TfmPrint.CheckValues : boolean;
var
  n : integer;
begin
  Result := False;

  if rbFromTo.Checked   and not ValidateNumEdit(0, edFrom, n, 1, ActiveView.cl.Count) then exit;
  if rbFromTo.Checked   and not ValidateNumEdit(0, edTo  , n, n, ActiveView.cl.Count) then exit;
  if cbInterPos.Checked and not ValidateNumEdit(0, edPos , n, 0, 9999) then exit;
  if cbStepPos.Checked  and not ValidateNumEdit(0, edStep, n, 1, 9999) then exit;
  if cbFirstFigAlone.Checked and not ValidateNumEdit(1, edFirstFigRatio, n, 1, 100) then exit;
  if not ValidateNumEdit(1, edFigRatio  , n, 1, 100) then exit;
  if not ValidateNumEdit(1, edFigPerLine, n, 1, 10 ) then exit;
  if not ValidateNumEdit(1, edLeft      , n, 5, 100) then exit;
  if not ValidateNumEdit(1, edRight     , n, 5, 100) then exit;
  if not ValidateNumEdit(1, edTop       , n, 5, 100) then exit;
  if not ValidateNumEdit(1, edBottom    , n, 5, 100) then exit;
  if (GetFigureFormat = eiJPG) and
     not ValidateNumEdit(3, edQualityJPEG, n, 1, 100) then exit;

  Result := True
end;

procedure TfmPrint.PageControlChanging(Sender: TObject;
                                       var AllowChange: Boolean);
begin
  AllowChange := CheckValues
end;

// -- Form creation ----------------------------------------------------------

procedure TfmPrint.FormCreate(Sender: TObject);
var
  i : integer;
begin
  //fmPreview := TPreviewForm.Create(self);
  PageControl.ActivePage := PageControl.Pages[0];

  InitFormatTab;

  lbStyles.Items.AddStrings(Status.PrStyles);

  for i := 0 to ComponentCount - 1 do
    if Components[i] is TSpTBXGroupBox
      then (Components[i] as TSpTBXGroupBox).Color := $FDFCFC;

  PageControl.DoubleBuffered := True;
  //PageControl.Brush.Color := clWhite;
  for i := 0 to PageControl.PageCount - 1 do
    PageControl.Pages[i].Brush.Color := clWhite;
  //TabSheet1.Brush.Color := clWhite;
end;

// -- Form display -----------------------------------------------------------

procedure TfmPrint.FormShow(Sender : TObject);
begin
  TranslateForm(Self);

  case PrintOrExport of
    0 : begin
          Caption := AppName + ' - ' + U('Print');
          btPrint.Visible         := True;
          btExportGames.Visible   := False;
          btExportFigures.Visible := False;
          TabSheet4.TabVisible    := False;
          Settings.PrExportGame   := egRTF;
          Settings.PrExportFigure := eiWMF
        end;
    1 : begin
          Caption := AppName + ' - ' + U('Export');
          btPrint.Visible         := False;
          btExportGames.Visible   := True;
          btExportFigures.Visible := True;
          TabSheet4.TabVisible    := True;
          PageControl.ActivePage  := PageControl.Pages[3]
        end
  end;

  // adjust left of some labels
  lbFrom.Left          := edFrom.Left          - lbFrom.Width          - 5;
  lbTo.Left            := edTo.Left            - lbTo.Width            - 5;
  lbFmtMainTitle.Left  := edFmtMainTitle.Left  - lbFmtMainTitle.Width  - 5;
  lbFmtVarTitle.Left   := edFmtVarTitle.Left   - lbFmtVarTitle.Width   - 5;
  lbHeaderFormat.Left  := edHeaderFormat.Left  - lbHeaderFormat.Width  - 5;
  lbFooterFormat.Left  := edFooterFormat.Left  - lbFooterFormat.Width  - 5;

  lbAddStyle.Color := clWhite;
  lbEscape.Visible    := False;
  ProgressBar.Visible := False;
  UpdateForm(Settings);
  UpdateViewStyle(Settings);
  pnAddStyle.Visible := False;
  lbStyles.ItemIndex := 0;
  edDum.Width := 0;

  tabSheetExportToAscii.TabVisible := Status.RunFromIDE
end;

// -- Performing preview -----------------------------------------------------

procedure MakeAndTestFilename(view         : TView;
                              aExportMode  : TExportMode;
                              var filename : WideString;
                              var ok       : boolean);
var
  msg : string;
begin
  filename := ExportFilename(view, aExportMode, filename);

  case aExportMode of
    emPreviewPDF : msg := 'Please, close previous preview to proceed.';
    emPreviewDOC : msg := 'Please, close previous preview to proceed.';
    emExportPDF  : msg := 'File is in use, close to proceed.';
    emExportDOC  : msg := 'File is in use, close to proceed.';
    else // nop, other modes do not lock output file
  end;

  // test if output file is locked
  if aExportMode in [emPreviewPDF, emPreviewDOC, emExportPDF, emExportDOC] then
    while IsFileInUse(filename) do
      if view.MessageDialog(msOkCancel, imExclam, [U(msg)]) = mrCancel then
        begin
          ok := False;
          exit
        end;

  ok := True
end;

function ImageExporterFactory(exportFigure : TExportFigure) : TImageExporter;
begin
  case exportFigure of
    eiGIF, eiPNG, eiJPG, eiBMP:
      Result := TImageExporterBMP.Create;
    eiWMF :
      Result := TImageExporterWMF.Create;
    eiPDF :
      Result := TImageExporterPDF.Create;
    eiRGG, eiSSL, eiTRC :
      Result := TImageExporterTXT.Create(exportFigure);
    else // eiNON, eiEMF (not implemented), eiSGF
      Result := nil
  end
end;

function CreateExporter(exportMode   : TExportMode;
                        exportFigure : TExportFigure;
                        filename     : string) : TExporter;
begin
  case exportMode of
    emNFig :
        Result := TExporterNFig.Create;
    emPrint, emPreviewRTF :
        Result := TExporterPreview.Create;
    emExportRTF :
        Result := TExporterRTF.Create(filename);
    emPreviewPDF, emExportPDF :
        Result := TExporterPDF.Create(exportFigure, filename);
    emPreviewHTM, emExportHTM :
        Result := TExporterHTM.Create(exportFigure, filename);
    emPreviewDOC, emExportDOC :
        Result := TExporterDOC.Create(exportFigure, filename);
    emPreviewTXT, emExportTXT :
        Result := TExporterTXT.Create(exportFigure, filename);
    emExportIMG :
      Result := TExporterIMG.Create(exportFigure, filename);
    else
      Result := nil
  end;

  Result.FImageExporter := ImageExporterFactory(exportFigure)
end;

function PerformPreview(aExportMode   : TExportMode;
                        aExportFigure : TExportFigure;
                        filename      : WideString = '') : integer;
var
  view : TView;
  ok : boolean;
  returnValue : integer;
  exporter : TExporter;
begin
  view := fmMain.ActiveView;

  MakeAndTestFilename(view, aExportMode, filename, ok);
  if not ok
    then exit;

  exporter := CreateExporter(aExportMode, aExportFigure, filename);
  Result := UPrint.PerformPreview(view, ok, exporter, aExportMode, aExportFigure);
  exporter.Free;

  // open preview if required
  if (aExportMode = emPreviewRTF) and ok
    then fmPreview.ShowModal;

  if aExportMode in [emPreviewHTM, emPreviewPDF, emPreviewDOC, emPreviewTXT] then
    begin
      returnValue := Tnt_ShellExecuteW(fmMain.Handle, 'open', PWideChar(filename), nil, nil, 1 {SW_SHOWNORMAL});
      if returnValue <= 32
        then ShowMessage(Format('Unable to launch preview viewer. Error code %d', [returnValue]))
    end;

  fmMain.TabSheetEnter(fmMain.ActivePage)
end;

// -- Preview button ---------------------------------------------------------

procedure TfmPrint.btPreviewClick(Sender : TObject);
begin
  if not UpdateStatus(Settings)
    then exit;

  ProgressSetting;
  InhibButtons(True);
  if PrintOrExport = 0
    then PerformPreview(emPreviewRTF, eiWMF)
    else
      if PageControl.ActivePage <> tabSheetExportToAscii
        then
          case Settings.PrExportGame of
            egRTF : PerformPreview(emPreviewRTF, Settings.PrExportFigure);
            egPDF : PerformPreview(emPreviewPDF, Settings.PrExportFigure);
            egHTM : PerformPreview(emPreviewHTM, Settings.PrExportFigure);
            egDOC : PerformPreview(emPreviewDOC, Settings.PrExportFigure)
          end
        else
          begin
            PerformPreview(emPreviewTXT, Settings.PrExportFigure)
          end;

  ProgressBar.Visible := False;
  InhibButtons(False)
end;

function TFmPrint.IsWordRunning : boolean;
begin
  Result := IsOLERunning('Word.Application');

  if Result
    then MessageDialog(msOk, imExclam, [U('Close Word and restart export.')])
end;

// -- Print button -----------------------------------------------------------

procedure TfmPrint.btPrintClick(Sender: TObject);
var
  tmp : boolean;
begin
  if not UpdateStatus(Settings)
    then exit;
  ProgressSetting;
  InhibButtons(True);
  PerformPreview(emPrint, eiWMF); // only for Print mode

  tmp := Abort;
  ProgressBar.Visible := False;
  InhibButtons(False);
  if not tmp
    then fmPreview.BtnPrintClick(Sender)
end;

// -- Export buttons ---------------------------------------------------------

// -- Export games

procedure TfmPrint.btExportGamesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  btExportGamesClick(Sender)
end;

procedure TfmPrint.btExportGamesClick(Sender: TObject);
var
  title, ext : string;
  fileName, filter : WideString;
  eGame : TExportMode;
  eFigure : TExportFigure;
begin
  if not UpdateStatus(Settings)
    then exit;

  case Settings.PrExportGame of
    egRTF :
      begin
        title   := 'Export games to RTF format';
        filter  := U('RTF files') + ' (*.rtf)|*.rtf|';
        ext     := '.rtf';
        eGame   := emExportRTF;
        eFigure := eiWMF
      end;
    egPDF :
      begin
        title   := 'Export games to PDF format';
        filter  := U('PDF files') + ' (*.pdf)|*.pdf|';
        ext     := '.pdf';
        eGame   := emExportPDF;
        eFigure := Settings.PrExportFigure
      end;
    egHTM :
      begin
        title   := 'Export games to HTML format';
        filter  := U('HTML files') + ' (*.htm)|*.htm|';
        ext     := '.htm';
        eGame   := emExportHTM;
        eFigure := Settings.PrExportFigure
      end;
    egDOC :
      begin
        title   := 'Export games to MSWORD format';
        filter  := U('DOC files') + ' (*.doc)|*.doc|';
        ext     := '.doc';
        eGame   := emExportDOC;
        eFigure := Settings.PrExportFigure
      end;
    egTXT :
      begin
        title   := 'Export games to text format';
        filter  := U('TXT files') + ' (*.txt)|*.txt|';
        ext     := '.txt';
        eGame   := emExportTXT;
        eFigure := Settings.PrExportFigure
      end
    else exit
  end;

  if not SaveDialog(title,
                    ExtractFilePath(ActiveView.si.FileName),
                    ChangeFileExt(ActiveView.si.FileName, ext),
                    ext,
                    filter,
                    True,
                    fileName)
    then exit;

  ProgressSetting;
  InhibButtons(True);
  PerformPreview(eGame, eFigure, FileName);
  ProgressBar.Visible := False;
  InhibButtons(False);
  Application.ProcessMessages
end;

// -- Export figures

procedure TfmPrint.btExportFiguresClick(Sender: TObject);
var
  rootstr : WideString;
  ext : string;
begin
  if not UpdateStatus(Status)
    then exit;

  if False then //and Settings.PrExportFigure = eiPDF then
    begin
      MessageDialog(msOk, imExclam,
                    [U('Exporting every figures to PDF files is not implemented.'),
                     U('Report if needed!')]);
      exit
    end;

  case Settings.PrExportFigure of
    eiWMF : ext := 'wmf';
    eiGIF : ext := 'gif';
    eiPNG : ext := 'png';
    eiJPG : ext := 'jpg';
    eiBMP : ext := 'bmp';
    eiPDF : ext := 'pdf';
  end;

  if not GetRoot(ActiveView.si.FileName,
                 'Export figures',
                 ext,
                 rootstr)
    then exit;

  ProgressSetting;
  InhibButtons(True);
  PerformPreview(emExportIMG, Settings.PrExportFigure, rootstr);
  ProgressBar.Visible := False;
  InhibButtons(False)
end;

// -- Cancel button ----------------------------------------------------------

procedure TfmPrint.btCancelClick(Sender: TObject);
begin
  Close
end;

// -- Help button ------------------------------------------------------------

procedure TfmPrint.btHelpClick(Sender: TObject);
var
  s : WideString;
begin
  s := (PageControl.ActivePage as TTntTabSheet).Caption;

  if s = U('Games and figures') then HtmlHelpShowContext(IDH_Print_GamesFig) else
  if s = U('Layout' ) then HtmlHelpShowContext(IDH_Print_Layout ) else
  if s = U('Styles' ) then HtmlHelpShowContext(IDH_Print_Styles ) else
  if s = U('Formats') then HtmlHelpShowContext(IDH_Print_Formats) else
  // last chance, should not occur
  HtmlHelpShowContext(IDH_Print)
end;

// -- Board button -----------------------------------------------------------

procedure TfmPrint.btGobanClick(Sender: TObject);
//r indexFontName, indexFontSize : integer;
begin
  //indexFontName := cbFontNames.ItemIndex;
  //indexFontSize := cbFontSizes.ItemIndex;
  Assert(cbFontNames.ItemIndex >= 0);

  // open option dialog on goban tab
  Settings.LastTab := 0;
  TfmOptions.Execute(eoBoard);

  Assert(cbFontNames.ItemIndex >= 0);
  //cbFontNames.ItemIndex := indexFontName;
  //cbFontSizes.ItemIndex := indexFontSize;
end;

// Note : at one time, it was necessary to save and restore combobox indexes...

// -- Enabling/disabling buttons ---------------------------------------------

procedure TfmPrint.InhibButtons(inhib : boolean);
begin
  PageControl.Enabled     := not inhib;
  btPreview.Enabled       := not inhib;
  btPrint.Enabled         := not inhib;
  btExportGames.Enabled   := not inhib;
  btExportFigures.Enabled := not inhib;
  btGoban.Enabled         := not inhib;
  btHelp.Enabled          := not inhib;
  btCancel.Enabled        := not inhib;
  lbEscape.Visible        := inhib;
  Abort                   := False;
  btCancel.OnClick        := btCancelClick;
  //ActiveControl           := edDum
end;

// -- Handling of progress bar -----------------------------------------------

// if there is more than 10 games to print, steps will be triggered by games,
// else they will be triggered by figures

procedure TfmPrint.SetProgressStrategy(var n : integer; var onGames : boolean);
begin
  case Settings.PrGames of
    pgCurrent : n := 1;
    pgAll     : n := ActiveView.cl.Count;
    pgFromTo  : n := Settings.PrTo - Settings.PrFrom + 1
    else        n := 0 // no else case
  end;

  onGames := n >= 10;

  if not onGames
    then n := PerformPreview(emNFig, eiNON)
end;

procedure TfmPrint.ProgressSetting;
var
  n : integer;
  onGames : boolean;
begin
  SetProgressStrategy(n, onGames);
  
  UPrint.PrintStepOnGame   := ProgressTest;
  UPrint.PrintStepOnFigure := ProgressTest;
  UPrint.PrintStepFinished := ProgressTest;
  if onGames
    then UPrint.PrintStepOnGame   := ProgressStep
    else UPrint.PrintStepOnFigure := ProgressStep;

  ProgressBar.Visible  := True;
  ProgressBar.Max      := n;
  ProgressBar.Step     := 1;
  ProgressBar.Position := 0;
  Application.ProcessMessages
end;

function TfmPrint.ProgressTest : boolean;
begin
  Application.ProcessMessages;
  Result := not Abort
end;

function TfmPrint.ProgressStep : boolean;
begin
  ProgressBar.StepIt;
  Application.ProcessMessages;
  Result := not Abort
end;

// -- Esc key handling

procedure TfmPrint.FormActivate(Sender: TObject);
begin
  ActiveControl := edDum
end;

procedure TfmPrint.edDumKeyDown(Sender: TObject; var Key: Word;
                                Shift: TShiftState);
begin
  if key = VK_ESCAPE
    then Abort := True
end;

// -- Handling of game components --------------------------------------------

procedure TfmPrint.rbCurrentClick(Sender: TObject);
begin
  lbFrom.Enabled := rbFromTo.Checked;
  lbTo.Enabled   := rbFromTo.Checked;
  edFrom.Enabled := rbFromTo.Checked;
  edTo.Enabled   := rbFromTo.Checked
end;

procedure TfmPrint.edFromClick(Sender: TObject);
begin
  rbFromTo.Checked := True
end;

// -- Handling of figure components ------------------------------------------

var
  LastPosClickExit : boolean = False; // avoid calls from Checked

procedure TfmPrint.cbLastPosClick(Sender: TObject);
begin
  if LastPosClickExit
    then exit
    else LastPosClickExit := True;
  if Sender <> cbLastPos
    then cbLastPos.Checked  := False;
  if Sender <> cbInterPos
    then cbInterPos.Checked := False;
  if Sender <> cbStepPos
    then cbStepPos.Checked  := False;
  if Sender <> cbMarkCom
    then cbMarkCom.Checked  := False;
  if Sender <> cbFileFig
    then cbFileFig.Checked  := False;
  LastPosClickExit := False;

  edPos.Enabled  := cbInterPos.Checked;
  edStep.Enabled := cbStepPos.Checked
end;

// -- Handling of game information components --------------------------------

procedure TfmPrint.rbInfosNoClick(Sender: TObject);
begin
  if rbInfosNo.Checked   then edInfosFormat.Text := '';
  if rbInfosTop.Checked  then edInfosFormat.Text := Settings.PrInfosTopFmt;
  if rbInfosName.Checked then edInfosFormat.Text := Settings.PrInfosNameFmt;
  lbInfosFormat.Enabled := not rbInfosNo.Checked;
  edInfosFormat.Enabled := not rbInfosNo.Checked
end;

// -- Handling of title components -------------------------------------------

procedure TfmPrint.cbInclTitleClick(Sender: TObject);
begin
  edFmtMainTitle.Enabled := cbInclTitle.Checked;
  edFmtVarTitle.Enabled  := cbInclTitle.Checked
end;

// -- Handling of comment components -----------------------------------------

procedure TfmPrint.cbCommentsClick(Sender: TObject);
begin
  cbRemindTitle.Checked := False;
  cbRemindMoves.Checked := False;
  cbRemindTitle.Enabled := cbComments.Checked;
  cbRemindMoves.Enabled := cbComments.Checked
end;

// -- Handling of header and footer components -------------------------------

procedure TfmPrint.cbPrintHeaderClick(Sender: TObject);
begin
  lbHeaderFormat.Enabled := cbPrintHeader.Checked;
  edHeaderFormat.Enabled := cbPrintHeader.Checked
end;

procedure TfmPrint.cbPrintFooterClick(Sender: TObject);
begin
  lbFooterFormat.Enabled := cbPrintFooter.Checked;
  edFooterFormat.Enabled := cbPrintFooter.Checked
end;

// -- Handling of layout components ------------------------------------------

procedure TfmPrint.SetLayout(FirstFigAlone : boolean;
                             FirstFigRatio, FigPerLine, FigRatio : integer);
begin
  Settings.PrFirstFigAlone := FirstFigAlone;
  Settings.PrFirstFigRatio := FirstFigRatio;
  Settings.PrFigPerLine    := FigPerLine;
  Settings.PrFigRatio      := FigRatio;
  cbFirstFigAlone.Checked  := FirstFigAlone;
  edFirstFigRatio.Text     := IntToStr(FirstFigRatio);
  edFirstFigRatio.Enabled  := FirstFigAlone;
  edFigPerLine.Text        := IntToStr(FigPerLine);
  edFigRatio.Text          := IntToStr(FigRatio);
end;

function TfmPrint.MatchLayout(FirstFigAlone : boolean;
                              FirstFigRatio,
                              FigPerLine, FigRatio : string) : boolean;
begin
  Result := (cbFirstFigAlone.Checked = FirstFigAlone) and
            (edFirstFigRatio.Text    = FirstFigRatio) and
            (edFigPerLine.Text       = FigPerLine)    and
            (edFigRatio.Text         = FigRatio)
end;

procedure TfmPrint.sbLayout1Click(Sender: TObject);
begin
  SetLayout(False, Settings.PrFirstFigRatio, 1, 100)
end;

procedure TfmPrint.sbLayout2Click(Sender: TObject);
begin
  SetLayout(False, Settings.PrFirstFigRatio, 1, 50)
end;

procedure TfmPrint.sbLayout3Click(Sender: TObject);
begin
  SetLayout(False, Settings.PrFirstFigRatio, 2, 100)
end;

procedure TfmPrint.sbLayout4Click(Sender: TObject);
begin
  SetLayout(True, 75, 2, 100)
end;

procedure TfmPrint.edFigPerLineChange(Sender: TObject);
begin
  sbLayout1.Down := MatchLayout(False, edFirstFigRatio.Text, '1', '100');
  sbLayout2.Down := MatchLayout(False, edFirstFigRatio.Text, '1',  '50');
  sbLayout3.Down := MatchLayout(False, edFirstFigRatio.Text, '2', '100');
  sbLayout4.Down := MatchLayout(True , '75'                , '2', '100');
end;

procedure TfmPrint.cbFirstFigAloneClick(Sender: TObject);
begin
  edFirstFigRatio.Enabled := cbFirstFigAlone.Checked;
  edFigPerLineChange(Sender)
end;

// -- Style handling ---------------------------------------------------------

function CommaString(t : array of WideString) : WideString;
var
  i : integer;
begin
  Result := '';
  for i := 0 to High(t) do
    if t[i] <> '' then
      if Result = ''
        then Result := t[i]
        else Result := Result + ', ' + t[i]
end;

procedure TfmPrint.UpdateViewStyle(st : TStatus);
var
  s : WideString;
begin
  mmViewStyle.Clear;

  // Games
  s := U('Games') + ' = ';
  case st.PrGames of
    pgCurrent : s := s + U('Current game');
    pgAll     : s := s + U('All');
    pgFromTo  : s := s + WideFormat(U('Games from %d to %d'), [st.PrFrom, st.PrTo])
  end;
  mmViewStyle.Lines.Add(s);

  // Figures
  case st.PrFigures of
    fgNone   : s := '';
    fgLast   : s := U('End position');
    fgInter  : s := U('Position at move number') + ' ' + IntToStr(st.PrPos);
    fgPropFG : s := U('File figures');
    fgStep   : s := WideFormat(U('One figure every %d moves'), [st.PrStep]);
    fgMarkCom: s := U('One figure every markup or comment');
  end;
  s := U('Figures')
          + ' = '
          + CommaString([iff (st.PrInclStartPos, U('Start position'), ''), s]);
  mmViewStyle.Lines.Add(s);

  s := U('Include variations') + ' = '
        + iff(st.PrInclVar, U('Yes'), U('No'));
  mmViewStyle.Lines.Add(s);

  // Include info
  s := U('Include information') + ' = ';
  case st.PrInclInfos of
    inNone : s := s + U('No');
    inTop  : s := s + U('at start of game') + ', '
                      + U('with format')
                      + ' "' + st.PrInfosTopFmt + '"';
    inName : s := s + U('as name of figure 1') + ', '
                      + U('with format')
                      + ' "' + st.PrInfosNameFmt + '"';
  end;
  mmViewStyle.Lines.Add(s);

  // Include comments
  s := U('Include comments')
        + ' = '
        + CommaString([iff(st.PrInclComm, U('Yes'), U('No')),
                       iff(st.PrRemindTitle, U('remind figure titles2'), ''),
                       iff(st.PrRemindMoves, U('remind move numbers2'), '')]);
  mmViewStyle.Lines.Add(s);

  // Titles
  s := U('Print title') + ' = ';
  if not st.PrInclTitle
    then s := s + U('No')
    else s := s + U('Yes')
                + ', '
                + U(iff(st.PrRelNum, 'relative numbers2', 'absolute numbers'))
                + ', '
                + U('with formats')
                + ' "'   + UTF8Decode(st.PrFmtMainTitle)
                + '", "' + UTF8Decode(st.PrFmtVarTitle) + '"';
  mmViewStyle.Lines.Add(s);

  // Header and footer
  s := U('Print header') + ' = ';
  if not st.PrPrintHeader
    then s := s + U('No')
    else s := s + U('Yes')
                + ', ' + U('with format')
                + ' "' + UTF8Decode(st.PrHeaderFormat) + '"';
  mmViewStyle.Lines.Add(s);
  s := U('Print footer') + ' = ';
  if not st.PrPrintFooter
    then s := s + U('No')
    else s := s + U('Yes')
                + ', ' + U('with format')
                + ' "' + UTF8Decode(st.PrFooterFormat) + '"';
  mmViewStyle.Lines.Add(s);
  
  // Layout
  s := U('First figure alone in the line') + ' = ';
  if not st.PrFirstFigAlone
    then s := s + U('No')
    else s := s + U('Yes')
                + ', ' + U('with ratio')
                + ' ' + IntTostr(st.PrFirstFigRatio);
  mmViewStyle.Lines.Add(s);
  s := U('Figures per line') + ' = ' + IntTostr(st.PrFigPerLine)
                                     + ', ' + U('with ratio')
                                     + ' ' + IntTostr(st.PrFigRatio);;
  mmViewStyle.Lines.Add(s);

  // Margins
  s := U('Margins (mm)') + ' = ' + st.PrMargins;
  mmViewStyle.Lines.Add(s);

  // Fonts
  s := U('Font') + ' = ' + st.PrFontName + ', ' + IntToStr(st.PrFontSize);
  mmViewStyle.Lines.Add(s)
end;

procedure TfmPrint.TabSheet3Show(Sender: TObject);
begin
  lbStyles.ItemIndex := 0;
  lbStylesClick(Sender)
end;

procedure TfmPrint.lbStylesClick(Sender: TObject);
var
  style : string;
begin
  style := lbStyles.Items[lbStyles.ItemIndex];

  if style = 'Current'
    then
      if not UpdateStatus(Status)
        then exit
        else // nop
    else
      LoadPrintStyle(fmMain.IniFile, 'Print' + '-' + style);

  // update parameters related to style
  UpdateViewStyle(Status);
  UpdateForm(Status)
end;

// -- Handling buttons for styles --------------------------------------------

// Add button

procedure TfmPrint.btAddStyleClick(Sender: TObject);
begin
  pnAddStyle.Visible := True;
  edAddStyle.Visible := True;
  edAddStyle.Text    := '';
  lbAddStyle.Width   := 230;
  lbAddStyle.Caption := U('Add current print options as style with name:');
  btOkStyle.OnClick  := btOkAddStyleClick
end;

// Add event

procedure TfmPrint.btOkAddStyleClick(Sender: TObject);
begin
  if edAddStyle.Text = '' then
    begin
      ActiveControl := edAddStyle;
      exit
    end;
  if not UpdateStatus(Settings)
    then exit;
  SavePrintStyle(fmMain.IniFile, 'Print-' + edAddStyle.Text);
  lbStyles.Items.Add(edAddStyle.Text);
  pnAddStyle.Visible := False
end;

// Cancel button

procedure TfmPrint.btCancelStyleClick(Sender: TObject);
begin
  pnAddStyle.Visible := False;
end;

// Remove button

procedure TfmPrint.btRemoveClick(Sender: TObject);
var
  s : string;
begin
  s := Trim(lbStyles.Items[lbStyles.ItemIndex]);
  if s = 'Current'
    then exit;
  pnAddStyle.Visible := True;
  edAddStyle.Visible := False;
  edAddStyle.Text    := '';
  lbAddStyle.Width   := 230;
  lbAddStyle.Caption := U('Remove style') + ' ' + s;
  btOkStyle.OnClick  := btOkRemoveStyleClick
end;

// Remove event

procedure TfmPrint.btOkRemoveStyleClick(Sender: TObject);
begin
  fmMain.IniFile.EraseSection('Print-' + lbStyles.Items[lbStyles.ItemIndex]);
  lbStyles.Items.Delete(lbStyles.ItemIndex);
  pnAddStyle.Visible := False
end;

// -- Format tab -------------------------------------------------------------

const
  RTF = 0; HTM = 1; DOC = 2; PDF = 3;          // indexes in rgFmtGames
  WMF = 0; GIF = 1; PNG = 2; JPG = 3;
  BMP = 4; // indices rgFmtFigures

// -- Format states
//
// Simple data structure designed to be independent of format order
// A: available, S: selected, W: waiting selection

var
  GameStates   : string = 'RTF:A,PDF:A,HTM:A,DOC:A';
  FigureStates : string = 'WMF:A,PDF:A,GIF:A,PNG:A,JPG:A,BMP:A';

// -- Access to format states

function GetSelected(states : string) : string;
begin
  Result := Copy(states, Pos(':S', states) - 3, 3)
end;

function GetState(states, key : string) : char;
begin
  Result := states[Pos(Copy(key + '_', 1, 3), states) + 4]
end;

procedure SetState(var states : string; key : string; state : char);
begin
  states[Pos(Copy(key + '_', 1, 3), states) + 4] := state
end;

procedure SetAllStates(var states : string; state : char);
var
  i : integer;
begin
  i := 5;
  while i <= Length(states) do
    begin
      states[i] := state;
      inc(i, 6)
    end
end;

procedure TfmPrint.SelectGameFormat(key : string);
var
  wasJPG, wasGIF, wasPNG, wasBMP : boolean;
begin
  // reset all and select
  SetAllStates(GameStates  , 'A');
  SetState(GameStates, key, 'S');

  // store current states
  wasJPG := GetState(FigureStates, 'JPG') = 'S';
  wasGIF := GetState(FigureStates, 'GIF') = 'S';
  wasPNG := GetState(FigureStates, 'PNG') = 'S';
  wasBMP := GetState(FigureStates, 'BMP') = 'S';

  // reset all figure format states to Waiting
  SetAllStates(FigureStates, 'W');

  // game format is RTF : WMF figure format mandatory
  if key = 'RTF' then
    begin
      SetState(FigureStates, 'WMF', 'S');
      exit
    end;

  // game format is PDF : PDF or JPG figure formats, PDF is default
  if key = 'PDF' then
    begin
      SetState(FigureStates, 'PDF', iff(wasJPG, 'A', 'S'));
      SetState(FigureStates, 'JPG', iff(wasJPG, 'S', 'A'));
      exit
    end;

  // game format is HTM : GIF, PNG, JPG or BMP figure formats, GIF is default
  if key = 'HTM' then
    begin
      SetState(FigureStates, 'GIF', iff(wasPNG or
                                        wasJPG or
                                        wasBMP, 'A', 'S'));
      SetState(FigureStates, 'PNG', iff(wasPNG, 'S', 'A'));
      SetState(FigureStates, 'JPG', iff(wasJPG, 'S', 'A'));
      SetState(FigureStates, 'BMP', iff(wasBMP, 'S', 'A'));
      exit
    end;

  // game format is DOC : WMF, GIF, PNG, JPG or BMP figure formats, WMF is default
  if key = 'DOC' then
    begin
      SetState(FigureStates, 'WMF', iff(wasGIF or
                                        wasPNG or
                                        wasJPG or
                                        wasBMP, 'A', 'S'));
      SetState(FigureStates, 'GIF', iff(wasGIF, 'S', 'A'));
      SetState(FigureStates, 'PNG', iff(wasPNG, 'S', 'A'));
      SetState(FigureStates, 'JPG', iff(wasJPG, 'S', 'A'));
      SetState(FigureStates, 'BMP', iff(wasBMP, 'S', 'A'));
      exit
    end
end;

procedure TfmPrint.SelectFigureFormat(key : string);
var
  wasRTF, wasPDF, wasHTM, wasDOC : boolean;
begin
  // store current states
  wasRTF := GetState(GameStates, 'RTF') = 'S';
  wasPDF := GetState(GameStates, 'PDF') = 'S';
  wasHTM := GetState(GameStates, 'HTM') = 'S';
  wasDOC := GetState(GameStates, 'DOC') = 'S';

  if wasRTF then
    begin
      if key = 'WMF'
        then exit
    end;

  while wasPDF do
    begin
      case AnsiIndexStr(key, ['PDF', 'JPG']) of
        0 : FigureStates := 'WMF:W,PDF:S,GIF:W,PNG:W,JPG:A,BMP:W';
        1 : FigureStates := 'WMF:W,PDF:A,GIF:W,PNG:W,JPG:S,BMP:W';
        else break
      end;
      exit
    end;

  while wasHTM do
    begin
      case AnsiIndexStr(key, ['GIF', 'PNG', 'JPG', 'BMP']) of
        0 : FigureStates := 'WMF:W,PDF:W,GIF:S,PNG:A,JPG:A,BMP:A';
        1 : FigureStates := 'WMF:W,PDF:W,GIF:A,PNG:S,JPG:A,BMP:A';
        2 : FigureStates := 'WMF:W,PDF:W,GIF:A,PNG:A,JPG:S,BMP:A';
        3 : FigureStates := 'WMF:W,PDF:W,GIF:A,PNG:A,JPG:A,BMP:S';
        else break
      end;
      exit
    end;

  while wasDOC do
    begin
      case AnsiIndexStr(key, ['WMF', 'GIF', 'PNG', 'JPG', 'BMP']) of
        0 : FigureStates := 'WMF:S,PDF:W,GIF:A,PNG:A,JPG:A,BMP:A';
        1 : FigureStates := 'WMF:A,PDF:W,GIF:S,PNG:A,JPG:A,BMP:A';
        2 : FigureStates := 'WMF:A,PDF:W,GIF:A,PNG:S,JPG:A,BMP:A';
        3 : FigureStates := 'WMF:A,PDF:W,GIF:A,PNG:A,JPG:S,BMP:A';
        4 : FigureStates := 'WMF:A,PDF:W,GIF:A,PNG:A,JPG:A,BMP:S';
        else break
      end;
      exit
    end;
end;

procedure TfmPrint.InitFormatTab;
begin
  with sgFormatGames do
    begin
      if IsOLEInstalled('Word.Application')
        then RowCount := 4
        else RowCount := 3;
      ColWidths[0] := 50;
      ColWidths[1] := 200;
      ColWidths[2] := 40;
      Width := 296;
      Rows[0].Text := 'RTF'^M^J'Rich Text Format'^M^J'*.rtf';
      Rows[1].Text := 'PDF'^M^J'Portable Document Format'^M^J'*.pdf';
      Rows[2].Text := 'HTML'^M^J'Hyper Text Document'^M^J'*.htm';
      if IsOLEInstalled('Word.Application')
        then Rows[3].Text := 'DOC'^M^J'Word Document'^M^J'*.doc'
    end;
  with sgFormatFigures do
    begin
      RowCount := 6;
      ColWidths[0] := 50;
      ColWidths[1] := 200;
      ColWidths[2] := 40;
      Width := 296;
      Rows[0].Text := 'WMF'^M^J'Windows metafile'^M^J'*.wmf';
      Rows[1].Text := 'PDF'^M^J'Portable Document Format'^M^J'*.pdf';
      Rows[2].Text := 'GIF'^M^J'CompuServe'^M^J'*.gif';
      Rows[3].Text := 'PNG'^M^J'Portable Network Graphic'^M^J'*.png';
      Rows[4].Text := 'JPG'^M^J'JPEG Image'^M^J'*.jpg';
      Rows[5].Text := 'BMP'^M^J'Windows bitmap'^M^J'*.bmp';
    end;

  SelectGameFormat  (Copy(GetEnumName(TypeInfo(TExportGame),
                          ord(Settings.PrExportGame)),
                          3, 3));
  SelectFigureFormat(Copy(GetEnumName(TypeInfo(TExportFigure),
                          ord(Settings.PrExportFigure)),
                          3, 3));

  sgFormatGames.Invalidate;
  sgFormatFigures.Invalidate
end;

function  TfmPrint.GetGameFormat : TExportGame;
var
  key : string;
begin
  key := GetSelected(GameStates);
  for Result := Low(TExportGame) to High(TExportGame) do
    if ('eg' + key) = GetEnumName(TypeInfo(TExportGame), ord(Result))
      then break
end;

function  TfmPrint.GetFigureFormat : TExportFigure;
var
  key : string;
begin
  key := GetSelected(FigureStates);
  for Result := Low(TExportFigure) to High(TExportFigure) do
    if ('ei' + key) = GetEnumName(TypeInfo(TExportFigure), ord(Result))
      then break;
end;

procedure TfmPrint.sgFormatGamesClick(Sender: TObject);
var
  key : string;
begin
  key := sgFormatGames.Cells[0, sgFormatGames.Row];
  SelectGameFormat(Copy(key + '_', 1, 3));
  cbCompressPDF.Enabled := GetSelected(GameStates)   = 'PDF';
  lbQualityJPEG.Enabled := GetSelected(FigureStates) = 'JPG';
  edQualityJPEG.Enabled := GetSelected(FigureStates) = 'JPG';
  cbPaper.Enabled       := GetSelected(GameStates)  <> 'HTM';
  cbLandscape.Enabled   := GetSelected(GameStates)  <> 'HTM';
  sgFormatGames.Invalidate;
  sgFormatFigures.Invalidate
end;

procedure TfmPrint.sgFormatFiguresClick(Sender: TObject);
var
  key : string;
begin
  key := sgFormatFigures.Cells[0, sgFormatFigures.Row];
  SelectFigureFormat(Copy(key + '_', 1, 3));
  cbCompressPDF.Enabled := GetSelected(GameStates)   = 'PDF';
  lbQualityJPEG.Enabled := GetSelected(FigureStates) = 'JPG';
  edQualityJPEG.Enabled := GetSelected(FigureStates) = 'JPG';
  sgFormatGames.Invalidate;
  sgFormatFigures.Invalidate
end;

procedure TfmPrint.sgFormatGamesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  sgFormatDrawCell(Sender, ACol, ARow, Rect, GameStates)
end;

procedure TfmPrint.sgFormatFiguresDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  sgFormatDrawCell(Sender, ACol, ARow, Rect, FigureStates)
end;

procedure TfmPrint.sgFormatDrawCell(Sender: TObject;
                                    ACol, ARow: Integer;
                                    Rect: TRect;
                                    states : string);
var
  x, y : integer;
begin
  with Sender as TStringGrid do
    begin
      x := Rect.Left + 5;
      y := Rect.Top  + 3; // + (DefaultRowHeight - ImageList1.Height) div 2;

      Canvas.Font.Size := 8; //10;
      Canvas.Font.Color := clBlack;
      Canvas.Font.Style := [];

      case GetState(states, Cells[0, ARow]) of
        'S' : // selected
          begin
            Canvas.Brush.Color := clWhite;
            Canvas.Font.Color := clBlue;
          end;
        'A' : // available
          begin
            Canvas.Brush.Color := clWhite;
            //Canvas.Font.Color := clBlue;
          end;
        'W' : // waiting for selection
          begin
            Canvas.Brush.Color := $EFEFEF;
            Canvas.Font.Color := $404040;
            Canvas.Font.Size := 8;
          end
      end;

      Canvas.FillRect(Rect);

      Canvas.TextOut(x, y, Cells[ACol, ARow])
    end
end;

// ---------------------------------------------------------------------------

end.
