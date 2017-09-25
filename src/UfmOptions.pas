// ---------------------------------------------------------------------------
// -- Drago -- Input form for settings --------------------- UfmOptions.pas --
// ---------------------------------------------------------------------------

unit UfmOptions;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, ImgList, Controls, Dialogs, UfrAdvanced,
  SpTBXControls, SpTBXEditors, TntStdCtrls, ComCtrls, Graphics,
  StdCtrls, UfrCfgSpToolbars, UfrCfgShortcuts, Buttons, CheckLst,
  TntCheckLst, Forms, UfrCfgInfoPreview, Components, TntExtCtrls, TntForms,
  UfrBackStyle, ExtCtrls, TntComCtrls, Grids, TntGrids, Classes,
  Define, UViewMain, UStatus, UBackGround, SpTBXItem,
  UfrCfgGameEngines, UfrCfgPredefinedEngines, TB2Item, Menus;

type
  // temporary subclass to get at the CNDraw message.
  TSpTBXComboBox = class(SpTBXEditors.TSpTBXComboBox)
  private
    procedure CNDrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
  end;

type
  TfmOptions = class(TTntForm)
    ColorDialog: TColorDialog;
    bvPage: TBevel;
    StringGrid: TTntStringGrid;
    pnTitle: TPanel;
    lbTitle: TTntLabel;
    PageControl: TTntPageControl;
    TabSheetBoard: TTntTabSheet;
    GroupBox4: TTntGroupBox;
    imGoban: TImage;
    udGoban: TUpDown;
    BackStyle_Board: TfrBackStyle;
    BackStyle_Border: TfrBackStyle;
    Panel1: TPanel;
    TabSheetMoves: TTntTabSheet;
    TabSheetGameTree: TTntTabSheet;
    GroupBox5: TTntGroupBox;
    imTree: TImage;
    udTree: TUpDown;
    ieTvRadius: TIntEdit;
    udTvRadius: TUpDown;
    BackStyle_Tree: TfrBackStyle;
    TabSheetIndex: TTntTabSheet;
    TabSheetView: TTntTabSheet;
    BackStyle_Win: TfrBackStyle;
    TabSheetSounds: TTntTabSheet;
    TabSheet5: TTntTabSheet;
    TabSheetEngineOld: TTntTabSheet;
    TabSheetLanguage: TTntTabSheet;
    TabSheet9: TTntTabSheet;
    frCfgShortcuts: TfrCfgShortcuts;
    TabSheetDum: TTntTabSheet;
    TabSheetNavigation: TTntTabSheet;
    TabSheetSidebar: TTntTabSheet;
    Bevel4: TBevel;
    Panel2: TPanel;
    Bevel6: TBevel;
    Panel3: TPanel;
    bvStart: TBevel;
    ieTargetStep: TIntEdit;
    GroupBox9: TTntGroupBox;
    frCfgInfoPreview: TfrCfgInfoPreview;
    TabSheetDatabase: TTntTabSheet;
    cbThickLines: TTntCheckBox;
    cbHoshis: TTntCheckBox;
    cbAutoUseTimeProp: TTntCheckBox;
    cbTargetStep: TTntCheckBox;
    cbTargetComment: TTntCheckBox;
    cbTargetStartVar: TTntCheckBox;
    cbTargetEndVar: TTntCheckBox;
    cbTargetFigure: TTntCheckBox;
    cbTargetAnnotation: TTntCheckBox;
    cbStopAtTarget: TTntCheckBox;
    rgCoordinates: TTntRadioGroup;
    rgZone: TTntRadioGroup;
    rgShowMove: TTntRadioGroup;
    rgVarStyle: TTntRadioGroup;
    rgVarMarkup: TTntRadioGroup;
    rgTvMoves: TTntRadioGroup;
    gbShowNumbers: TTntGroupBox;
    cbShowTwoDigits: TTntCheckBox;
    Label7: TTntLabel;
    gbLighting: TTntGroupBox;
    imLighting: TImage;
    rbLightingLeft: TTntRadioButton;
    rbLightingRight: TTntRadioButton;
    GroupBox2: TTntGroupBox;
    udGIdxRadius: TUpDown;
    ieGIdxRadius: TIntEdit;
    GroupBox15: TTntGroupBox;
    ieSortLimit: TIntEdit;
    Label10: TTntLabel;
    Label8: TTntLabel;
    GroupBox12: TTntGroupBox;
    edCache: TEdit;
    GroupBox13: TTntGroupBox;
    cxProcessVar: TTntCheckBox;
    cxDetectDup: TTntCheckBox;
    cxOmitDup: TTntCheckBox;
    cxOmitSgfErr: TTntCheckBox;
    cxCreateEx: TTntCheckBox;
    rbDupSignature: TTntRadioButton;
    rbDupFinalPos: TTntRadioButton;
    GroupBox14: TTntGroupBox;
    edMoveLimit: TIntEdit;
    cxSearchVar: TTntCheckBox;
    Label5: TTntLabel;
    Label11: TTntLabel;
    btDefaultDB: TTntButton;
    gbFichiers: TTntGroupBox;
    cbCreer: TTntCheckBox;
    cbJoueur: TTntCheckBox;
    cbCompact: TTntCheckBox;
    cbCompressList: TTntCheckBox;
    cbLongPNames: TTntCheckBox;
    gbStart: TTntGroupBox;
    cbOpenLast: TTntCheckBox;
    cbOpenNode: TTntCheckBox;
    gbTiming: TTntGroupBox;
    lbAutoDelay: TLabel;
    lbMinDelay: TLabel;
    lbMaxDelay: TLabel;
    btMoreDelay: TSpeedButton;
    btLessDelay: TSpeedButton;
    TrackBarAutoReplay: TTrackBar;
    GroupBox1: TTntGroupBox;
    sbEngine: TSpeedButton;
    GroupBox6: TTntGroupBox;
    Edit1: TEdit;
    edCustomParam: TEdit;
    rbParDefault: TTntRadioButton;
    rbParCustom: TTntRadioButton;
    gbUndo: TTntGroupBox;
    GroupBox7: TTntGroupBox;
    GroupBox8: TTntGroupBox;
    cbEnableSounds: TTntCheckBox;
    GroupBox11: TTntGroupBox;
    sbSound: TSpeedButton;
    edSound: TEdit;
    rbSoundDefault: TTntRadioButton;
    rbSoundCustom: TTntRadioButton;
    rbSoundNone: TTntRadioButton;
    cbSounds: TTntComboBox;
    TabsheetToolbars: TTntTabSheet;
    frCfgSpToolbars: TfrCfgSpToolbars;
    edEngine: TTntEdit;
    lbEngine: TSpTBXLabel;
    rgScoringTmp: TTntRadioGroup;
    lbEngOptInhibited: TSpTBXLabel;
    TabSheetAdvanced: TTntTabSheet;
    frAdvanced: TfrAdvanced;
    cbLangue: TSpTBXComboBox;
    TntGroupBox2: TTntGroupBox;
    cbEncoding: TSpTBXComboBox;
    rgCreateEncoding: TSpTBXRadioGroup;
    TntGroupBox1: TTntGroupBox;
    cxSGFAsso: TTntCheckBox;
    cxMGTAsso: TTntCheckBox;
    GroupBox16: TSpTBXGroupBox;
    cbThemes: TComboBox;
    btTestSound3: TTntButton;
    lbAuto: TSpTBXLabel;
    lbTargets: TSpTBXLabel;
    rbUndoNo: TSpTBXRadioButton;
    rbUndoYes: TSpTBXRadioButton;
    rbUndoCapture: TSpTBXRadioButton;
    TabSheetEngines: TTntTabSheet;
    frCfgPredefinedEngines: TfrCfgPredefinedEngines;
    frCfgGameEngines: TfrCfgGameEngines;
    SpTBXGroupBox1: TSpTBXGroupBox;
    SpTBXLabel1: TSpTBXLabel;
    edGameInfoFormat: TTntEdit;
    cxGameInfoImageDisplay: TSpTBXCheckBox;
    SpTBXLabel2: TSpTBXLabel;
    edGameInfoImageDir: TTntEdit;
    GroupBox3: TSpTBXGroupBox;
    Label4: TTntLabel;
    Label6: TTntLabel;
    clbVisible: TTntCheckListBox;
    clbConditional: TTntCheckListBox;
    gbFont: TSpTBXGroupBox;
    Label2: TTntLabel;
    cbFontSize: TComboBox;
    gbTextPanels: TSpTBXGroupBox;
    Bevel3: TBevel;
    imTextColor: TImage;
    sbTextColor: TSpeedButton;
    Label3: TTntLabel;
    SpTBXLabel3: TSpTBXLabel;
    btImgDir: TSpeedButton;
    lbPath: TSpTBXLabel;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    btMore: TSpTBXButton;
    btSelectStones: TSpTBXButton;
    Label1: TSpTBXLabel;
    edVisibleMoves: TIntEdit;
    procedure FormCreate(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rgCoordinatesClick(Sender: TObject);
    procedure clbVisibleClickCheck(Sender: TObject);
    procedure clbConditionalClick(Sender: TObject);
    procedure udGobanClick(Sender: TObject; Button: TUDBtnType);
    procedure udTreeClick(Sender: TObject; Button: TUDBtnType);
    procedure TabSheetGameTreeShow(Sender: TObject);
    procedure cbOpenLastClick(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; State: TGridDrawState);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
    procedure StringGridClick(Sender: TObject);
    procedure TabSheetViewShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TabSheetBoardShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbTextColorClick(Sender: TObject);
    procedure sbSoundClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure TrackBarAutoReplayChange(Sender: TObject);
    procedure btLessDelayClick(Sender: TObject);
    procedure btMoreDelayClick(Sender: TObject);
    procedure rbLightingLeftClick(Sender: TObject);
    procedure rbLightingRightClick(Sender: TObject);
    procedure TabSheetSidebarShow(Sender: TObject);
    procedure cbSoundsChange(Sender: TObject);
    procedure rbSoundNoneClick(Sender: TObject);
    procedure rbSoundDefaultClick(Sender: TObject);
    procedure rbSoundCustomClick(Sender: TObject);
    procedure cxDetectDupClick(Sender: TObject);
    procedure btDefaultDBClick(Sender: TObject);
    procedure btTestSoundClick(Sender: TObject);
    procedure cbEnableSoundsClick(Sender: TObject);
    procedure TabSheetMovesShow(Sender: TObject);
    procedure TabSheetAdvancedShow(Sender: TObject);
    procedure cbEncodingDrawItemVO(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure frCfgGameEnginesbtAddClick(Sender: TObject);
    procedure frCfgPredefinedEnginesbtOkClick(Sender: TObject);
    procedure frCfgPredefinedEnginesbtCancelClick(Sender: TObject);
    procedure cbLangueDrawItem(Sender: TObject; ACanvas: TCanvas;
      var ARect: TRect; Index: Integer; const State: TOwnerDrawState;
      const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
    procedure cbEncodingDrawItem(Sender: TObject; ACanvas: TCanvas;
      var ARect: TRect; Index: Integer; const State: TOwnerDrawState;
      const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
    procedure btImgDirClick(Sender: TObject);
    procedure edGameInfoImageDirChange(Sender: TObject);
    procedure TabSheetEnginesShow(Sender: TObject);
    procedure btSelectStonesClick(Sender: TObject);
    procedure edVisibleMovesChange(Sender: TObject);
  private
    SoundStrings : TStringList;
    procedure Prepare(tabSheetName : string);
    procedure LoadSettings(st : TStatus);
    procedure SaveSettings(gv : TViewMain; st : TStatus);
    procedure LoadSettings_Database(st : TStatus);
    procedure SaveSettings_Database(st : TStatus);
    function  GetLighting : TLightSource;
    procedure ShowStonesForGoban;
    procedure ShowStonesForTree;
    procedure ShowStonesForLighting;
    procedure ShowStones(stoneStyle : integer;
                         lightSource : TLightSource;
                         background : TBackground; img : TImage);
    procedure ShowViewOptions;
    procedure UpdateViewOptions(var loadTree : boolean);
    procedure TabSoundsCreate(st : TStatus);
    procedure TabSoundsSave(st : TStatus);
    procedure rbSoundClick(none, default, custom : boolean; s : string);
    procedure InitCharsets;
    procedure TabSheetAdvancedCreate;
    procedure UpdateShowMoves(enableAsBooks  : boolean; showMoves : TShowMoveMode);
    function  ValidateVisibleMoveNumber(var val : integer) : boolean;
    function  ShowMoveToRadioIndex(i : TShowMoveMode) : integer;
    function  RadioIndexToShowMove(i : integer) : TShowMoveMode;
  public
    class procedure Execute(tabSheet : string = '');
  end;

var
  IsOpen : boolean = False;

// ---------------------------------------------------------------------------

implementation

uses
  StrUtils, SysUtilsEx, ActnList, MMsystem, TntGraphics, TntFileCtrl,
  DefineUi, Std, Properties, UFileAssoc, Main, UGameTree, Translate,
  TranslateVcl, HtmlHelpAPI, UfmMsg,
  UGmisc, UActions, UAutoReplay,
  CodePages, UThemes,
  UDialogs, UApply, UStatusMain, UMainUtil,
  VclUtils, UfmCustomStones, UStones;

{$R *.DFM}

// -- Display request --------------------------------------------------------

class procedure TfmOptions.Execute(tabSheet : string = '');
begin
  with TfmOptions.Create(Application) do
    try
      Prepare(tabSheet);
      ShowModal;
    finally
      Release;
      Application.ProcessMessages
    end
end;

// -- Creation of the form ---------------------------------------------------

procedure TfmOptions.FormCreate(Sender: TObject);
var
  i, ignoreLast : integer;
begin
  // inform about creation
  IsOpen := True;

  // ignore last tabs(Library, ToolbarsOld)
  ignoreLast := 2;
  TabSheetDum.Visible := False;

  // initialize list of tab captions
  StringGrid.RowCount := PageControl.PageCount - ignoreLast;
  StringGrid.ColWidths[0] := 16 + 10;
  StringGrid.ColWidths[1] := StringGrid.Width - (16 + 10) - 8;

  // fill string grid on left side
  for i := 0 to PageControl.PageCount - 1 - ignoreLast do
    StringGrid.Cells[1, i] := PageControl.Pages[i].Caption;

  // hide tabs
  PageControl.Height := PageControl.Height - 18;
  for i := 0 to PageControl.PageCount - 1 do
    PageControl.Pages[i].TabVisible := False;

  // title and bevel settings
  pnTitle.ParentBackground := False;
  bvPage.Top    := PageControl.Top    - 2;
  bvPage.Left   := PageControl.Left   - 2;
  bvPage.Height := PageControl.Height + 4;
  bvPage.Width  := PageControl.Width  + 4;

  // create background selection frames
  BackStyle_Board .Create('Board1', ShowStonesForGoban, nil);
  BackStyle_Border.Create('Coordinate background', nil, BackStyle_Board.Background);
  BackStyle_Win   .Create('Window background', nil, BackStyle_Board.Background);
  BackStyle_Tree  .Create('Background', ShowStonesForTree, BackStyle_Board.Background);

  // Advanced
  TabSheetAdvancedCreate
end;

// -- Destruction of the form ------------------------------------------------

procedure TfmOptions.FormDestroy(Sender: TObject);
begin
  BackStyle_Board .Background.Free;
  BackStyle_Border.Background.Free;
  BackStyle_Win   .Background.Free;
  BackStyle_Tree  .Background.Free;
end;

// -- Closing and memorization of last open tab ------------------------------

procedure TfmOptions.FormClose(Sender : TObject; var Action : TCloseAction);
var
  i : integer;
begin
  Actions.ActionList.State := asNormal;

  StatusMain.FmOptionPlace := GetWinStrPlacement(self);

  // save current option tab
  with PageControl do
    for i := 0 to PageCount - 1 do
      if Pages[i] = ActivePage
        then Settings.LastTab := i;

  // free data 
  frCfgShortcuts.Finalize(Actions.ActionList);
  frCfgSpToolbars.Finalize;
  SoundStrings.Free;
  frCfgGameEngines.Finalize;
  frAdvanced.Finalize;

  // inform others of destruction
  IsOpen := False
end;

// -- Opening ----------------------------------------------------------------

procedure TfmOptions.FormShow(Sender: TObject);
begin
  SetWinStrPosition(self, StatusMain.FmOptionPlace);
end;

procedure TfmOptions.Prepare(tabSheetName : string);
var
  rec : TGridRect;
  x : TComponent;
  bak : string;
begin
  Caption := AppName + ' - ' + U('Options');
  TranslateForm(Self);

  if tabSheetName = eoEngines2 then
    begin
      bak := tabSheetName;
      tabSheetName := eoEngines
    end;

  // update last tab number
  if tabSheetName <> '' then
    begin
      x := self.FindComponent(tabSheetName);
      Settings.LastTab := (x as TTntTabSheet).PageIndex
    end;

  // restore tab
  if Settings.LastTab >= PageControl.PageCount
    then Settings.LastTab := 0;
  rec.Top    := Settings.LastTab;
  rec.Bottom := Settings.LastTab;
  rec.Left   := 1;
  rec.Right  := 1;
  StringGrid.Selection   := rec;
  PageControl.ActivePage := PageControl.Pages[Settings.LastTab];
  StringGridClick(nil);

  LoadSettings(Settings);

  BackStyle_Board.Enable(True);
  udGoban.Enabled := True;
  BackStyle_Border.Enable(rgCoordinates.ItemIndex > 0);

  if bak = eoEngines2
    then frCfgGameEnginesbtAddClick(nil)
end;

// -- Initialization of all dialog controls from current settings ------------

procedure TfmOptions.LoadSettings(st : TStatus);
var
  i : integer;
  list : TStringList;
begin
  // 'Board' tab
  BackStyle_Board.Show (st.BoardBack);
  BackStyle_Board.Button4.Visible := False;
  BackStyle_Border.Show(st.BorderBack);
  cbThickLines.Checked    := st.ThickEdge;
  cbHoshis.Checked        := st.ShowHoshis;
  udGoban.Position        := st.StoneStyle;
  ShowStonesForGoban;
  btSelectStones.Enabled  := UdGoban.Position = 3;
  rgCoordinates.ItemIndex := st.CoordStyle;
  rgZone.ItemIndex        := iff(st.ZoomOnCorner, 1, 0);
  cbShowTwoDigits.Checked := st.NumOfMoveDigits = 2;

  // 'Moves' tab
  UpdateShowMoves(st.EnableAsBooks, st.ShowMoveMode);
  edVisibleMoves.Text     := IntToStr(st.NumberOfVisibleMoveNumbers);
  st.EnableAsBooksTmp     := st.EnableAsBooks;
  rgVarStyle.ItemIndex    := ord(st.VarStyle);
  rgVarMarkup.ItemIndex   := ord(VarMarkup(fmMain.ActiveView.si));
  rgVarStyle .Enabled     := not (fmMain.ActiveView.si.EnableMode in [mdProb, mdGame]);
  rgVarMarkup.Enabled     := not (fmMain.ActiveView.si.EnableMode in [mdProb, mdGame]);

  // 'Game tree' tab
  BackStyle_Tree.Show(st.TreeBack);
  udTree.Position         := st.TvStoneStyle;
  udTvRadius.Position     := st.TvRadius;
  rgTvMoves.ItemIndex     := ord(st.TvMoveNumber);
  ShowStonesForTree;

  // 'View' tab
  BackStyle_Win.Show(st.WinBackground);
  rbLightingLeft.Checked  := st.LightSource = lsTopLeft;
  rbLightingRight.Checked := st.LightSource <> lsTopLeft;
  ShowStonesForLighting;

  // fill the theme combobox
  list := TStringList.Create;
  try
    GetAvailableThemes(list);
    cbThemes.Items.Assign(list);
    cbThemes.Text := '';
    cbThemes.ItemIndex := list.IndexOf(GetCurrentTheme);
  finally
    list.Free;
  end;

  // 'Index' tab
  udGIdxRadius.Position   := st.GIdxRadius;
  frCfgInfoPreview.Initialize(st.InfoCol);
  ieSortLimit.Value       := st.SortLimit;

  // 'Sidebar' tab
  ShowViewOptions;
  cbFontSize.ItemIndex    := cbFontSize.Items.IndexOf(IntToStr(st.ComFontSize));
  ColorDialog.Color       := st.TextPanelColor;
  edGameInfoFormat.Text   := st.GameInfoPaneFormat;
  cxGameInfoImageDisplay.Checked := st.GameInfoPaneImgDisp;
  edGameInfoImageDir.Text := st.GameInfoPaneImgDir;

  with imTextColor, Canvas do
    begin
      Brush.Color := st.TextPanelColor;
      FillRect(Rect(0, 0, Width, Height))
    end;

  // 'Shortcuts' tab
  frCfgShortcuts.Initialize(Actions.ActionList);
  
  // 'Toolbars' tab
  frCfgSpToolbars.Initialize(Actions.ActionList);

  // 'Sounds' tab
  cbEnableSounds.Checked  := st.EnableSounds;
  TabSoundsCreate(st);

  // 'File' tab
  cbOpenLast.Checked      := st.OpenLast;
  cbOpenNode.Checked      := st.OpenLast and st.OpenNode;
  cbOpenNode.Enabled      := st.OpenLast;
  cbCreer.Checked         := st.DefaultProp;
  cbJoueur.Checked        := st.PlayerProp;
  cbCompact.Checked       := st.SaveCompact;
  cbCompressList.Checked  := st.CompressList;
  cbLongPNames.Checked    := st.LongPNames;
  cxSGFAsso.Checked       := IsAssociatedWithDrago(Application.ExeName, 'sgf');
  cxMGTAsso.Checked       := IsAssociatedWithDrago(Application.ExeName, 'mgt');

  // 'Navigation' tab
(*
  bvTargets.Left             := lbTargets.Left + lbTargets.Width + 1;
  bvTargets.Width            := gbTiming.Width - (bvStart.Width + lbTargets.Width);
  bvAuto.Left                := lbAuto.Left + lbAuto.Width + 1;
  bvAuto.Width               := gbTiming.Width - (bvStart.Width + lbAuto.Width);
*)
  lbTargets.Caption          := ' ' + lbTargets.Caption + ' ';
  lbAuto   .Caption          := ' ' + lbAuto   .Caption + ' ';

  cbTargetStep.Checked       := mtStep in st.MoveTargets;
  ieTargetStep.Value         := st.TargetStep;
  cbTargetComment.Checked    := mtComment in st.MoveTargets;
  cbTargetStartVar.Checked   := mtStartVar in st.MoveTargets;
  cbTargetEndVar.Checked     := mtEndVar in st.MoveTargets;
  cbTargetFigure.Checked     := mtFigure in st.MoveTargets;
  cbTargetAnnotation.Checked := mtAnnotation in st.MoveTargets;
  
  AutoReplaySetControls(TrackBarAutoReplay,
                        btLessDelay, btMoreDelay,
                        lbMinDelay, lbMaxDelay, lbAutoDelay);
  cbAutoUseTimeProp.Checked := st.AutoUseTimeProp;
  cbStopAtTarget.Checked    := st.AutoStopAtTarget;

  // 'Database' tab
  LoadSettings_Database(st);

  // 'Game engine' tab
  frCfgGameEngines.Initialize(fmMain.IniFile);
  rgScoringTmp.ItemIndex     := integer(st.plScoring);
  SetNthRadioButton([rbUndoNo, rbUndoYes, rbUndoCapture], integer(st.plUndo));

  // 'Language' tab
  // initialize language combobox
  cbLangue.Clear;
  for i := 0 to AllLanguages.Count - 1 do
    cbLangue.Items.Add(UTF8DecodeX(AllLanguages[i]));
  //protect against problem when loading language list
  try
    cbLangue.ItemIndex := cbLangue.Items.IndexOf(UTF8DecodeX(LanguageNameFromCode(st.Language)));
  except
  end;
  // load code page names
  InitCharsets;
  // initialize creation encoding
  if st.CreateEncoding = utf8
    then rgCreateEncoding.ItemIndex := 0
    else rgCreateEncoding.ItemIndex := 1
end;

// -- Update current settings from dialog controls ---------------------------

procedure TfmOptions.SaveSettings(gv : TViewMain; st : TStatus);
var
  loadTree, updateEngine, ok : boolean;
  n : integer;
begin
  // 'Board' tab
  BackStyle_Board.Setup(st.BoardBack);
  BackStyle_Border.Setup(st.BorderBack);

  st.ThickEdge       := cbThickLines.Checked;
  st.ShowHoshis      := cbHoshis.Checked;

  if udGoban.Position <= 2
    then st.StoneStyle := udGoban.Position
    else
      begin
        // special precautions for custom stones
        // paths have been set in fmCustomStones
        if WideFileExists(st.CustomBlackPath) and
           WideFileExists(st.CustomWhitePath)
          then st.StoneStyle := udGoban.Position
          else // nop, stones not found, keep current style
      end;

  st.CoordStyle      := rgCoordinates.ItemIndex;
  st.NumOfMoveDigits := iff(cbShowTwoDigits.Checked, 2, 3);
  st.ZoomOnCorner    := rgZone.ItemIndex = 1;
  UStones.ClearCacheLists;

  // 'Moves' tab
  st.EnableAsBooks := st.EnableAsBooksTmp;
  st.ShowMoveMode  := RadioIndexToShowMove(rgShowMove.ItemIndex);
  if ValidateVisibleMoveNumber(n)
    then st.NumberOfVisibleMoveNumbers := n;

  if st.VarStyle <> TVarStyle(rgVarStyle.ItemIndex) then
    begin
      st.VarStyleGame := vsUndef;
      st.VarStyleDef  := TVarStyle(rgVarStyle.ItemIndex)
    end;
  if VarMarkup(gv.si) <> TVarMarkup(rgVarMarkup.ItemIndex) then
    begin
      st.VarMarkupGame := vmUndef;
      st.VarMarkupDef  := TVarMarkup(rgVarMarkup.ItemIndex)
    end;

  Status.IgnoreFG := st.ShowMoveMode <> smBook;

  // 'Game tree' tab
  st.TvStoneStyle := udTree.Position;
  st.TvRadius     := udTvRadius.Position;
  st.TvInterH     := 3 * st.TvRadius;
  st.TvInterV     := 3 * st.TvRadius;
  st.TvMoveNumber := TTvMoves(rgTvMoves.ItemIndex);

  BackStyle_Tree.Setup(st.TreeBack);

  // 'View' tab
  st.LightSource    := GetLighting;
  BackStyle_Win.Setup(st.WinBackground);
  if cbThemes.ItemIndex > -1
    then SetCurrentTheme(cbThemes.Text);

  // 'Preview' tab
  st.GIdxRadius     := udGIdxRadius.Position;
  frCfgInfoPreview.Finalize(st.InfoCol);
  st.SortLimit      := ieSortLimit.Value;

  // 'Sidebar' tab
  UpdateViewOptions(loadTree);
  st.ComFontSize    := StrToInt(cbFontSize.Text);
  st.TextPanelColor := ColorDialog.Color;
  st.GameInfoPaneFormat := edGameInfoFormat.Text;
  st.GameInfoPaneImgDisp := cxGameInfoImageDisplay.Checked;
  st.GameInfoPaneImgDir := edGameInfoImageDir.Text;

  // 'Shortcuts' tab
  frCfgShortcuts.Update(Actions.ActionList);

  // 'Toolbars' tab
  frCfgSpToolbars.UpdateToolBars;

  // 'Sounds' tab
  st.EnableSounds   := cbEnableSounds.Checked;
  TabSoundsSave(st);

  // 'Files' tab
  st.OpenLast     := cbOpenLast.Checked;
  st.OpenNode     := cbOpenNode.Checked;
  st.DefaultProp  := cbCreer.Checked;
  st.PlayerProp   := cbJoueur.Checked;
  st.SaveCompact  := cbCompact.Checked;
  st.CompressList := cbCompressList.Checked;
  st.LongPNames   := cbLongPNames.Checked;

  // handle file associations
  ok := True;
  if cxSGFAsso.Checked <> IsAssociatedWithDrago(Application.ExeName, 'sgf') then
    if cxSGFAsso.Checked
      then RegisterAsso(Application.ExeName, '.sgf', 'Drago.Document', 'Drago Document', ok)
      else UnregisterAsso(Application.ExeName, '.sgf', 'Drago.Document', ok);
  if cxMGTAsso.Checked <> IsAssociatedWithDrago(Application.ExeName, 'mgt') then
    if cxMGTAsso.Checked
      then RegisterAsso(Application.ExeName, '.mgt', 'Drago.Document', 'Drago Document', ok)
      else UnregisterAsso(Application.ExeName, '.mgt', 'Drago.Document', ok);

  if not ok
    then MessageDialog(msOk, imExclam, [U('Unable to update file association!'),
                                        U('Check user rights.')]);

  // 'Navigation' tab
  st.MoveTargets := [];
  if cbTargetStep.Checked       then Include(st.MoveTargets, mtStep);
  if cbTargetComment.Checked    then Include(st.MoveTargets, mtComment);
  if cbTargetStartVar.Checked   then Include(st.MoveTargets, mtStartVar);
  if cbTargetEndVar.Checked     then Include(st.MoveTargets, mtEndVar);
  if cbTargetFigure.Checked     then Include(st.MoveTargets, mtFigure);
  if cbTargetAnnotation.Checked then Include(st.MoveTargets, mtAnnotation);
  st.TargetStep := ieTargetStep.Value;

  st.AutoDelay := TrackBarAutoReplay.Position * 10;
  st.AutoUseTimeProp  := cbAutoUseTimeProp.Checked;
  st.AutoStopAtTarget := cbStopAtTarget.Checked;

  // 'Database' tab
  SaveSettings_Database(st);

  // 'Advanced' tab(before 'Engines' tab which uses st.UsePortablePaths)
  frAdvanced.Update;

  // 'Engines' tab
  frCfgGameEngines.UpdateIniFile(fmMain.IniFile);
  st.PlayingEngine.LoadPlayingEngine(fmMain.IniFile, st.UsePortablePaths, st.AppPath);
  st.AnalysisEngine.LoadAnalysisEngine(fmMain.IniFile, st.UsePortablePaths, st.AppPath);
  //st.PlUndo := TEngineUndo(GetNthRadioButton([rbUndoNo, rbUndoYes, rbUndoCapture]));

  // 'Language' tab
  st.Language := LanguageCodeFromName(UTF8Encode(cbLangue.Text));
  st.DefaultEncoding := TCodePage(cbEncoding.ItemIndex);
  ApplyCA(gv, Enter, gv.gt.Root.GetProp(prCA));
  if rgCreateEncoding.ItemIndex = 0
    then st.CreateEncoding := utf8
    else st.CreateEncoding := cpDefault;
end;

// -- Processing of 'Go board' tab events ------------------------------------

// Entry

procedure TfmOptions.TabSheetBoardShow(Sender: TObject);
begin
  BackStyle_Board.Refresh;
  BackStyle_Border.Refresh
end;

// Stone selection UpDown

procedure TfmOptions.udGobanClick(Sender: TObject; Button: TUDBtnType);
begin
  // enable select stone button if updown in custom position
  btSelectStones.Enabled := UdGoban.Position = 3;

  ShowStonesForGoban
end;

procedure TfmOptions.btSelectStonesClick(Sender: TObject);
begin
  if TfmCustomStones.Execute then
    begin
      UStones.ClearCacheLists;
      ShowStonesForGoban
    end
end;

// Coordinates radio group

procedure TfmOptions.rgCoordinatesClick(Sender: TObject);
begin
  BackStyle_Border.Enable(rgCoordinates.ItemIndex > 0)
end;

// -- Processing of 'Moves' tab events ---------------------------------------

function TfmOptions.ShowMoveToRadioIndex(i : TShowMoveMode) : integer;
const
  kShowMoveToRadioIndex : array[TShowMoveMode] of integer = (0, 1, 3, 2, 5, 4);
begin
  Result := kShowMoveToRadioIndex[i]
end;

function TfmOptions.RadioIndexToShowMove(i : integer) : TShowMoveMode;
const
  kRadioIndexToShowMove : array[0 .. 5] of integer = (0, 1, 3, 2, 5, 4);
begin
  Result := TShowMoveMode(kRadioIndexToShowMove[ord(i)])
end;

procedure TfmOptions.UpdateShowMoves(enableAsBooks : boolean; showMoves : TShowMoveMode);
begin
  if enableAsBooks
    then rgShowMove.Columns := 2//3
    else rgShowMove.Columns := 2;

  if enableAsBooks
    then
      if rgShowMove.Items.Count = 6//5
        then // nop, already set
        else rgShowMove.Items.Add(U('As books'))
    else
      if rgShowMove.Items.Count = 5//4
        then // nop, already set
        else rgShowMove.Items.Delete(5);//(4);

  if (showMoves <> smBook) or enableAsBooks
    then rgShowMove.ItemIndex := ShowMoveToRadioIndex(showMoves)
    else rgShowMove.ItemIndex := 1; // number on last move by default

  rgShowMove.Buttons[4].Caption := WideFormat(U('Last %d moves with number'), [Status.NumberOfVisibleMoveNumbers])
end;

// EnableAsBooksTmp is used do synchronize rgShowMove and advanced setting
// while enabling the Cancel key to work correctly.

procedure TfmOptions.TabSheetMovesShow(Sender: TObject);
begin
  UpdateShowMoves(Status.EnableAsBooksTmp, RadioIndexToShowMove(rgShowMove.ItemIndex))
end;

function  TfmOptions.ValidateVisibleMoveNumber(var val : integer) : boolean;
begin
  Result := TryStrToInt(edVisibleMoves.Text, val) and (val >= 0)
end;

procedure TfmOptions.edVisibleMovesChange(Sender: TObject);
var
  n : integer;
begin
  if ValidateVisibleMoveNumber(n)
    then rgShowMove.Buttons[4].Caption := WideFormat(U('Last %d moves with number'), [n])
end;

// -- Processing of 'Game tree' tab events -----------------------------------

// -- Entry

procedure TfmOptions.TabSheetGameTreeShow(Sender: TObject);
begin
  BackStyle_Tree.Refresh;
  ShowStonesForTree
end;

// -- Stone selection UpDown

procedure TfmOptions.udTreeClick(Sender: TObject; Button: TUDBtnType);
begin
  ShowStonesForTree
end;

// -- Processing of 'View' tab events ----------------------------------------

// -- Entry

procedure TfmOptions.TabSheetViewShow(Sender: TObject);
begin
  BackStyle_Win.Refresh;
  ShowStonesForLighting
end;

// -- Light source radio buttons

procedure TfmOptions.rbLightingLeftClick(Sender: TObject);
begin
  rbLightingRight.Checked := not rbLightingLeft.Checked;
  ShowStonesForLighting
end;

procedure TfmOptions.rbLightingRightClick(Sender: TObject);
begin
  rbLightingLeft.Checked := not rbLightingRight.Checked;
  ShowStonesForLighting
end;

// -- Processing of 'Panels' tab events --------------------------------------

// Entry

procedure TfmOptions.TabSheetSidebarShow(Sender: TObject);
begin
  ShowViewOptions;
end;

// Update of controls

procedure TfmOptions.ShowViewOptions;
var
  n  : integer;
  vw : TViewPane;
begin
  for n := 0 to 5 do
    begin
      case n + 1 of
        0 : vw := Settings.VwMoveInfo;  // just in case
        1 : vw := Settings.VwGameInfo;
        2 : vw := Settings.VwTimeLeft;
        3 : vw := Settings.VwNodeName;
        4 : vw := Settings.VwVariation;
        5 : vw := Settings.VwTreeView;
        6 : vw := Settings.VwComments
      end;

      clbVisible    .Checked[n] := vw = vwAlways;
      clbConditional.Checked[n] := vw = vwRequired
    end;

  clbVisible.Enabled     := not (fmMain.ActiveView.si.EnableMode in [mdProb, mdGame]);
  clbConditional.Enabled := not (fmMain.ActiveView.si.EnableMode in [mdProb, mdGame])
end;

// Update of settings

procedure TfmOptions.UpdateViewOptions(var loadTree : boolean);
var
  n  : integer;
  vw : TViewPane;
begin
  for n := 0 to 5 do
    begin
      if clbVisible.Checked[n]
        then vw := vwAlways
        else
          if clbConditional.Checked[n]
            then vw := vwRequired
            else vw := vwNever;

      case n + 1 of
        0 : Settings.VwMoveInfo  := vw;  // just in case
        1 : Settings.VwGameInfo  := vw;
        2 : Settings.VwTimeLeft  := vw;
        3 : Settings.VwNodeName  := vw;
        4 : Settings.VwVariation := vw;
        5 : Settings.VwTreeView  := vw;
        6 : Settings.VwComments  := vw;
      end
    end
end;

// Always visible panel list box

procedure TfmOptions.clbVisibleClickCheck(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to clbVisible.Count - 1 do
    if clbVisible.Selected[i]
      then
        if clbVisible.Checked[i]
          then clbConditional.Checked[i] := False
end;

// Conditional list box

procedure TfmOptions.clbConditionalClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to clbConditional.Count - 1 do
    if clbConditional.Selected[i]
      then
        if clbConditional.Checked[i]
          then clbVisible.Checked[i] := False
end;

// Player image path

procedure TfmOptions.btImgDirClick(Sender: TObject);
var
  path, filename : WideString;
  ok : boolean;
begin
  if Status.GameInfoPaneImgDir = ''
    then path := Status.AppPath
    else path := WideExtractFilePath(Status.GameInfoPaneImgDir);

  ok := WideSelectDirectory(U('Player images folder'), '', path);

  if not ok
    then exit;

  Status.GameInfoPaneImgDir := path;
  edGameInfoImageDir.Text := path
end;

procedure TfmOptions.edGameInfoImageDirChange(Sender: TObject);
begin
  lbPath.Caption := WideMinimizeLabel(lbPath, edGameInfoImageDir.Text)
end;

// Panel color selection

procedure TfmOptions.sbTextColorClick(Sender: TObject);
begin
  ColorDialog.Color := Settings.TextPanelColor;
  if not ColorDialog.Execute
    then exit;

  with imTextColor, Canvas do
    begin
      Brush.Color := ColorDialog.Color;
      FillRect(Rect(0, 0, Width, Height))
    end;
end;

// -- Processing of 'Sounds' tab events --------------------------------------

procedure TfmOptions.TabSoundsCreate(st : TStatus);
var
  i : integer;
begin
  //cbSounds.Items must be in the same order than TSound

  SoundStrings := TStringList.Create;
  
  for i := 0 to cbSounds.Items.Count - 1 do
    SoundStrings.Add(SoundString(TSound(i)));

  cbSounds.ItemIndex := 0;
  cbSoundsChange(nil)
end;

procedure TfmOptions.TabSoundsSave(st : TStatus);
begin
  st.SoundStone      := SoundStrings[ord(sStone)  ];
  st.SoundInvMove    := SoundStrings[ord(sInvMove)];
  st.SoundEngineMove := SoundStrings[ord(sEngineMove)];
end;

procedure TfmOptions.cbEnableSoundsClick(Sender: TObject);
begin
  // update settings immediately to enable testing sound with button
  Settings.EnableSounds := cbEnableSounds.Checked
end;

procedure TfmOptions.cbSoundsChange(Sender: TObject);
var
  soundStr : WideString;
begin
  soundStr := SoundStrings[cbSounds.ItemIndex];

  if soundStr = 'None'
    then rbSoundNoneClick(Sender)
    else
      if soundStr = 'Default'
        then rbSoundDefaultClick(Sender)
        else rbSoundCustomClick(Sender)
end;

procedure TfmOptions.rbSoundClick(none, default, custom : boolean; s : string);
begin
  rbSoundNone   .Checked := none;
  rbSoundDefault.Checked := default;
  rbSoundCustom .Checked := custom;
  edSound.Enabled := custom;
  sbSound.Enabled := custom;
  edSound.Text := s
end;

procedure TfmOptions.rbSoundNoneClick(Sender: TObject);
begin
  SoundStrings[cbSounds.ItemIndex] := 'None';
  rbSoundClick(True, False, False, '')
end;

procedure TfmOptions.rbSoundDefaultClick(Sender: TObject);
begin
  SoundStrings[cbSounds.ItemIndex] := 'Default';
  rbSoundClick(False, True, False, '')
end;

procedure TfmOptions.rbSoundCustomClick(Sender: TObject);
var
  s : string;
begin
  s := SoundStrings[cbSounds.ItemIndex];
  s := iff((s = 'None') or (s = 'Default'), '', s);

  SoundStrings[cbSounds.ItemIndex] := s;
  rbSoundClick(False, False, True, s)
end;

procedure TfmOptions.sbSoundClick(Sender: TObject);
var
  sTitle, sPath, filename : WideString;
begin
  sTitle := WideFormat('%s: %s', [U('Select sound file'),
                                  U(cbSounds.Items[cbSounds.ItemIndex])]);
  sPath := WideExtractFileDir(SoundStrings[cbSounds.ItemIndex]);
  sPath := iff(sPath <> '', sPath, Status.AppPath);

  if OpenDialog(sTitle, sPath, '', 'wav',
                 U('Sound files') + '(*.wav)|*.wav',
                 filename)
    then
      begin
        edSound.Text := filename;
        SoundStrings[cbSounds.ItemIndex] := edSound.Text
      end
end;

procedure TfmOptions.btTestSoundClick(Sender: TObject);
begin
  DragoPlaySound(sStone, SoundStrings[cbSounds.ItemIndex])
end;

// -- Processing of 'File' tab events ----------------------------------------

procedure TfmOptions.cbOpenLastClick(Sender: TObject);
begin
  cbOpenNode.Checked := cbOpenLast.Checked and Settings.OpenNode;
  cbOpenNode.Enabled := cbOpenLast.Checked
end;

// -- Processing of 'Navigation' tab events ----------------------------------

procedure TfmOptions.TrackBarAutoReplayChange(Sender: TObject);
begin
  AutoReplayUpdateControls(TrackBarAutoReplay,
                           btLessDelay, btMoreDelay,
                           lbMinDelay, lbMaxDelay, lbAutoDelay)
end;

procedure TfmOptions.btLessDelayClick(Sender: TObject);
begin
  AutoReplayLessClick(TrackBarAutoReplay,
                      btLessDelay, btMoreDelay,
                      lbMinDelay, lbMaxDelay)
end;

procedure TfmOptions.btMoreDelayClick(Sender: TObject);
begin
  AutoReplayMoreClick(TrackBarAutoReplay,
                      btLessDelay, btMoreDelay,
                      lbMinDelay, lbMaxDelay)
end;

// -- Processing of 'Database' tab events ------------------------------------

procedure TfmOptions.LoadSettings_Database(st : TStatus);
begin
  edCache.Text           := IntToStr(st.DBCache);
  cxCreateEx.Checked     := st.DBCreateExtended;
  edMoveLimit.Value      := st.DBMoveLimit;
  cxDetectDup.Checked    := st.DBDetectDuplicates > 0;
  rbDupSignature.Checked := st.DBDetectDuplicates = 1;
  rbDupFinalPos.Checked  := st.DBDetectDuplicates = 2;
  cxOmitDup.Checked      := st.DBOmitDuplicates;
  cxOmitSgfErr.Checked   := st.DBOmitSGFErrors;
  rbDupSignature.Enabled := cxDetectDup.Checked;
  rbDupFinalPos.Enabled  := cxDetectDup.Checked;
  cxOmitDup.Enabled      := cxDetectDup.Checked;
  cxProcessVar.Checked   := st.DBProcessVariations;
  cxSearchVar.Checked    := st.DBSearchVariations
end;

procedure TfmOptions.SaveSettings_Database(st : TStatus);
begin
  st.DBCache     := StrToInt(edCache.Text);
  st.DBCreateExtended := cxCreateEx.Checked;
  st.DBMoveLimit := edMoveLimit.Value;
  if not cxDetectDup.Checked
    then st.DBDetectDuplicates := 0
    else
      if rbDupSignature.Checked
        then st.DBDetectDuplicates := 1
        else st.DBDetectDuplicates := 2;
  st.DBOmitDuplicates := cxOmitDup.Checked;
  st.DBOmitSGFErrors  := cxOmitSgfErr.Checked;
  st.DBProcessVariations := cxProcessVar.Checked;
  st.DBSearchVariations  := cxSearchVar.Checked
end;

procedure TfmOptions.btDefaultDBClick(Sender: TObject);
begin
  Settings.Default_Database;
  LoadSettings_Database(Settings)
end;

procedure TfmOptions.cxDetectDupClick(Sender: TObject);
begin
  rbDupSignature.Enabled  := cxDetectDup.Checked;
  rbDupFinalPos.Enabled   := cxDetectDup.Checked;
  cxOmitDup.Enabled       := cxDetectDup.Checked;
  cxOmitDup.Checked       := cxDetectDup.Checked;
  rbDupSignature.Checked  := cxDetectDup.Checked;
  rbDupFinalPos.Checked   := False;
end;

// -- Processing of 'Engine' tab events --------------------------------------

procedure TfmOptions.TabSheetEnginesShow(Sender: TObject);
begin
end;

// -- Processing of 'Language' tab events ------------------------------------

procedure TfmOptions.InitCharsets;
var
  list : TStringList;
  i : integer;
begin
  list := TStringList.Create;
  AppendCharsetNames(list);

  cbEncoding.Items.Clear;
  for i := 0 to list.Count - 1 do
    cbEncoding.Items.add(list[i]);

  cbEncoding.ItemIndex := ord(Settings.DefaultEncoding);

  list.Free
end;

procedure TSpTBXComboBox.CNDrawItem(var Message : TWMDrawItem);
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not ODS_FOCUS;
  inherited;
end;

procedure TfmOptions.cbLangueDrawItem(Sender: TObject; ACanvas: TCanvas;
  var ARect: TRect; Index: Integer; const State: TOwnerDrawState;
  const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
begin
  with Sender as TSpTBXComboBox do
    begin
      // erase item
      if(odSelected in State) and not(odComboBoxEdit in State)
        then Canvas.Brush.Color := $F0F0F0
        else Canvas.Brush.Color := clWhite;
      Canvas.FillRect(ARect);

      // write item
      Canvas.Font.Color := clBlack;
      Canvas.TextOut(ARect.Left + 5, ARect.Top + 2, Items[Index]);

      // finished if edit item
      if odComboBoxEdit in State
        then exit;

      // draw horizontal separator, lighter if same family
      Canvas.Pen.Color := $C0C0C0;
      Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
      Canvas.LineTo(ARect.Right, ARect.Bottom - 1)
    end
end;

procedure TfmOptions.cbEncodingDrawItemVO(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  //
end;

procedure TfmOptions.cbEncodingDrawItem(Sender: TObject; ACanvas: TCanvas;
  var ARect: TRect; Index: Integer; const State: TOwnerDrawState;
  const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
var
  s1, s2 : string;
begin
  with Sender as TSpTBXComboBox do
    begin
      // extract family codepage and codepage
      s1 := NthWord(Items[Index], 1, ',');
      s2 := NthWord(Items[Index], 2, ',');

      // erase item
      if(odSelected in State) and not(odComboBoxEdit in State)
        then Canvas.Brush.Color := $F0F0F0
        else Canvas.Brush.Color := clWhite;
      Canvas.FillRect(ARect);

      // write item
      Canvas.TextOut(ARect.Left + 5      , ARect.Top  + 2, s1);
      Canvas.TextOut(ARect.Left + 150 + 5, ARect.Top  + 2, s2);

      // draw vertical separator
      Canvas.Pen.Color := $C0C0C0;
      Canvas.MoveTo(ARect.Left + 150, ARect.Top);
      Canvas.LineTo(ARect.Left + 150, ARect.Bottom - 1);

      // finished if edit item
      if odComboBoxEdit in State
        then exit;

      // draw horizontal separator, lighter if same family
      if(Index < Items.Count - 1) and(not AnsiStartsStr(s1, Items[Index + 1]))
        then Canvas.Pen.Color := $707070
        else Canvas.Pen.Color := $C0C0C0;
      Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
      Canvas.LineTo(ARect.Right, ARect.Bottom - 1)
    end
end;

// -- Advanced ---------------------------------------------------------------

procedure TfmOptions.TabSheetAdvancedCreate;
begin
  frAdvanced.Initialize
end;

procedure TfmOptions.TabSheetAdvancedShow(Sender: TObject);
begin
  frAdvanced.Invalidate
end;

// -- Stone style selection --------------------------------------------------

// -- Get lighting origin

function TfmOptions.GetLighting : TLightSource;
begin
  if rbLightingLeft.Checked
    then Result := lsTopLeft
    else Result := lsTopRight
end;

// -- Stone selection for go board

procedure TfmOptions.ShowStonesForGoban;
begin
  ShowStones(udGoban.Position, GetLighting, BackStyle_Board.Background, imGoban);
  BackStyle_Border.Refresh
end;

// -- Stone selection for tree view

procedure TfmOptions.ShowStonesForTree;
begin
  ShowStones(udTree.Position, GetLighting, BackStyle_Tree.Background, imTree)
end;

// -- Stone selection for lighting

procedure TfmOptions.ShowStonesForLighting;
var
  stoneStyle : integer;
begin
  if udGoban.Position > 0
    then stoneStyle := udGoban.Position
    else stoneStyle := dsDefault;

  ShowStones(stoneStyle, GetLighting, BackStyle_Board.Background, imLighting)
end;

// -- Drawing of stone selection image

procedure TfmOptions.ShowStones(stoneStyle : integer;
                                lightSource : TLightSource;
                                background : TBackground; img : TImage);
var
  bmBlack, bmWhite : TStone;
  r, d, w, h, i : integer;
  stoneParams : TStoneParams;
begin
  bmBlack := nil;
  bmWhite := nil;
  r := 18;
  d := 37;

  if(stoneStyle <> dsCustom) or
    ((stoneStyle = dsCustom) and
     (LowerCase(ExtractFileExt(Settings.CustomBlackPath)) = '.png') and
     (LowerCase(ExtractFileExt(Settings.CustomBlackPath)) = '.png'))
    then
      begin
        stoneParams := TStoneParams.Create;
        stoneParams.SetParams(stoneStyle,
                              lightSource,
                              background.meanColor,
                              Settings.CustomLightSource,
                              Settings.CustomBlackPath,
                              Settings.CustomWhitePath,
                              Settings.AppPath);
        bmBlack := GetStone(Black, r, stoneParams);
        bmWhite := GetStone(White, r, stoneParams);
        stoneParams.Free;
      end;

  with img.Canvas do
    begin
      w := img.Width;
      h := img.Height;
      background.Apply(img.Canvas, Rect(0, 0, w - 1, h - 1));
      Brush.Color := clBlack;
      FrameRect(Rect(0, 0, w - 1, h - 1));
      MoveTo(0, h div 2 + 1);
      LineTo(w - 1, h div 2 + 1);
      for i := 0 to w div (2*r + 2) do
        begin
          MoveTo(r div 2 + i * (2*r + 2), 0);
          LineTo(r div 2 + i * (2*r + 2), h - 1);
        end;
      if bmWhite <> nil
        then bmWhite.Draw(img.Canvas, r div 2 + 1 * (d + 1),
                                     (h - d) div 2 + r);
      if bmBlack <> nil
        then bmBlack.Draw(img.Canvas, r div 2 + 3 * (d + 1),
                                     (h - d) div 2 + r)
    end;
end;

// -- Buttons ----------------------------------------------------------------

// -- Ok button 

procedure TfmOptions.btOkClick(Sender : TObject);
begin
  SaveSettings(fmMain.ActiveView, Settings);
  Settings.SaveIniFile(fmMain.IniFile);
  StatusMain.SaveIniFile(fmMain.IniFile);
  fmMain.UpdateMain;
  fmMain.UpdateIniFile;

  Close
end;

// -- Cancel button

procedure TfmOptions.btCancelClick(Sender : TObject);
begin
  Close
end;

// -- Help button

procedure TfmOptions.btHelpClick(Sender : TObject);
var
  s : WideString;
begin
  s :=(PageControl.ActivePage as TTntTabSheet).Caption;

  if s = U('Board'       ) then HtmlHelpShowContext(IDH_Options_Board     ) else
  if s = U('Moves'       ) then HtmlHelpShowContext(IDH_Options_Moves     ) else
  if s = U('Game tree'   ) then HtmlHelpShowContext(IDH_Options_GTree     ) else
  if s = U('View'        ) then HtmlHelpShowContext(IDH_Options_View      ) else
  if s = U('Preview2'    ) then HtmlHelpShowContext(IDH_Options_Preview   ) else
  if s = U('Sidebar'     ) then HtmlHelpShowContext(IDH_Options_Panels    ) else
  if s = U('Shortcuts'   ) then HtmlHelpShowContext(IDH_Options_Shortcuts ) else
  if s = U('Toolbars'    ) then HtmlHelpShowContext(IDH_Options_Toolbars  ) else
  if s = U('Sounds'      ) then HtmlHelpShowContext(IDH_Options_Sounds    ) else
  if s = U('Files'       ) then HtmlHelpShowContext(IDH_Options_Files     ) else
  if s = U('Navigation'  ) then HtmlHelpShowContext(IDH_Options_Navigation) else
  if s = U('Edit'        ) then HtmlHelpShowContext(IDH_Options_Edit      ) else
  if s = U('Database'    ) then HtmlHelpShowContext(IDH_Options_Database  ) else
  if s = U('Game engines') then HtmlHelpShowContext(IDH_Options_Engine    ) else
  if s = U('Language'    ) then HtmlHelpShowContext(IDH_Options_Language  ) else
  if s = U('Advanced'    ) then HtmlHelpShowContext(IDH_Options_Advanced  ) else
  // last chance, should not occur
  HtmlHelpShowContext(IDH_Options)
end;

// -- Handling of list of tab names ------------------------------------------

procedure TfmOptions.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
                                        Rect: TRect; State: TGridDrawState);
var
  x, y : integer;
  caption : WideString;
begin
  with StringGrid do
    begin
      Canvas.Brush.Color := clCream;
      Canvas.FillRect(Rect);

      x := Rect.Left + 5;
      y := Rect.Top + (DefaultRowHeight - Actions.ImageListOptions.Height) div 2;

      // output glyph in col 0
      if ACol = 0 then
        begin
          Actions.ImageListOptions.Draw(Canvas, x, y, ARow);
          exit
        end;

      // output caption in col 1
      caption := Cells[1, ARow];

      // selection of font size to fit caption in column
      Canvas.Font.Size := 10;
      //while Canvas.TextWidth(caption) >= ColWidths[1] do
      while WideCanvasTextWidth(Canvas, caption) >= (ColWidths[1] - 2) do
        Canvas.Font.Size := Canvas.Font.Size - 1;

      // style and color settings
      Canvas.Font.Color := clBlack;
      Canvas.Font.Style := [];
      if gdSelected in State then
        begin
          Canvas.Font.Color := clBlue;
          Canvas.Font.Style := [fsUnderline]
        end;

      // output caption
      WideCanvasTextOut(Canvas, x, y, caption)
    end
end;

procedure TfmOptions.StringGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  //
end;

procedure TfmOptions.StringGridClick(Sender: TObject);
begin
  PageControl.ActivePage := PageControl.Pages[StringGrid.Row];

  // does not work with tnt
  //lbTitle.Caption := ' ' + PageControl.ActivePage.Caption

  lbTitle.Caption := ' ' + StringGrid.Cells[1, StringGrid.Row]
end;

// -- Handling of key strokes ------------------------------------------------

// note : no more buttons with Cancel and Default property with True value,
// otherwise the THotKey cannot catch the keys.

procedure TfmOptions.FormKeyDown(Sender: TObject; var Key: Word;
                                 Shift: TShiftState);
begin
  if Key = VK_RETURN
    then
      //if ActiveControl.Parent = frAdvanced.VT
      if ActiveControl.Name = ''
        then
          begin
            //frAdvanced.VT.EndEditNode;
            //btOkClick(Sender);
            exit
          end
      else
      if ActiveControl <> frCfgShortcuts.edShortCut
        then
          if Shift = []
            then btOkClick(Sender)
            else //nop
        else
          begin
            frCfgShortcuts.edShortCut.KeyDown(Key, Shift);
            Key := 0
          end;
  if Key = VK_ESCAPE
    then
      if ActiveControl <> frCfgShortcuts.edShortCut
        then
          if Shift = []
            then btCancelClick(Sender)
            else //nop
        else
          begin
            frCfgShortcuts.edShortCut.KeyDown(Key, Shift);
            Key := 0
          end;
  if Key in [VK_DELETE, VK_BACK, VK_INSERT]
    then
      if ActiveControl <> frCfgShortcuts.edShortCut
        then //nop
        else
          begin
            frCfgShortcuts.edShortCut.KeyDown(Key, Shift);
            Key := 0
          end
end;

// ---------------------------------------------------------------------------

procedure TfmOptions.frCfgGameEnginesbtAddClick(Sender: TObject);
begin
  frCfgGameEngines.btAddClick(Sender);
  
  // remove frame from tab and hook predefined engine tab
  // reset when closing predefined engine tab

  // if Parent := nil, list of engines will be cleared(!?)
  //frCfgGameEngines.Parent := nil;

  frCfgPredefinedEngines.Parent := TabSheetEngines;
  frCfgPredefinedEngines.Align := alClient;

  frCfgPredefinedEngines.Initialize(frCfgGameEngines);

  btOk.OnClick     := frCfgPredefinedEnginesbtOkClick;
  btCancel.OnClick := frCfgPredefinedEnginesBtCancelClick
end;

procedure TfmOptions.frCfgPredefinedEnginesbtOkClick(Sender: TObject);
begin
  frCfgPredefinedEngines.btOkClick(Sender);

  // restore
  frCfgPredefinedEngines.Parent := nil;
  //frCfgGameEngines.Parent := TabSheeDefineEngines;
  btOk.OnClick     := btOkClick;
  btCancel.OnClick := btCancelClick
end;

procedure TfmOptions.frCfgPredefinedEnginesBtCancelClick(Sender: TObject);
begin
  frCfgPredefinedEngines.btCancelClick(Sender);

  // restore
  frCfgPredefinedEngines.Parent := nil;
  frCfgGameEngines.Parent := TabSheetEngines;
  btOk.OnClick     := btOkClick;
  btCancel.OnClick := btCancelClick
end;

// ---------------------------------------------------------------------------

end.
