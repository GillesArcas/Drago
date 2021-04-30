// ---------------------------------------------------------------------------
// -- Drago -- Action depository ----------------------------- UActions.pas --
// ---------------------------------------------------------------------------

unit UActions;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Controls, StdActns, Forms, Menus, ActnList, ComCtrls,
  Windows, IniFiles, ImgList, Dialogs,
  TntActnList, TntClasses, TntIniFiles,
  UViewMain;

type
  TActions = class(TDataModule)
    ImageList: TImageList;
    ActionList: TTntActionList;
    acFirstGame: TTntAction;
    acLastGame: TTntAction;
    acPrevGame: TTntAction;
    acNextGame: TTntAction;
    acSelectGame: TTntAction;
    acStartPos: TTntAction;
    acEndPos: TTntAction;
    acPrevMove: TTntAction;
    acNextMove: TTntAction;
    acSelectMove: TTntAction;
    acPrevVariation: TTntAction;
    acNextVariation: TTntAction;
    acPointerUp: TTntAction;
    acPointerDown: TTntAction;
    acPointerLeft: TTntAction;
    acPointerRight: TTntAction;
    acAutoReplay: TTntAction;
    acUndoMove: TTntAction;
    acDeleteBranch: TTntAction;
    acGameEdit: TTntAction;
    acGameEditBlackFirst: TTntAction;
    acGameEditWhiteFirst: TTntAction;
    acBlackToPlay: TTntAction;
    acWhiteToPlay: TTntAction;
    acAddBlack: TTntAction;
    acAddWhite: TTntAction;
    acEmpty: TTntAction;
    acMarkup: TTntAction;
    acMarkupCross: TTntAction;
    acMarkupTriangle: TTntAction;
    acMarkupCircle: TTntAction;
    acMarkupSquare: TTntAction;
    acMarkupLetter: TTntAction;
    acMarkupNumber: TTntAction;
    acMarkupLabel: TTntAction;
    acBlackTerritory: TTntAction;
    acWhiteTerritory: TTntAction;
    acNew: TTntAction;
    acNewInTab: TTntAction;
    acOpen: TTntAction;
    acOpenFolder: TTntAction;
    acOpenInTab: TTntAction;
    acOpenFolderInTab: TTntAction;
    acSave: TTntAction;
    acSaveAs: TTntAction;
    acReadOnly: TTntAction;
    acClose: TTntAction;
    acCloseAll: TTntAction;
    acQuit: TTntAction;
    acAppend: TTntAction;
    acMerge: TTntAction;
    acExtractCurrent: TTntAction;
    acExtractAll: TTntAction;
    acFavorites: TTntAction;
    acGameInfo: TTntAction;
    acPrint: TTntAction;
    acExport: TTntAction;
    acExportPos: TTntAction;
    acInsertPass: TTntAction;
    acInsert: TTntAction;
    acDisplayHelp: TTntAction;
    acDonate: TTntAction;
    acAbout: TTntAction;
    acOptions: TTntAction;
    acSetupInter: TTntAction;
    acSetupVar: TTntAction;
    acPbSession: TTntAction;
    acNewEngineGame: TTntAction;
    acResign: TTntAction;
    acJosekiTutor: TTntAction;
    acJosekiRecent: TTntAction;
    acSuggestMove: TTntAction;
    acScoreEstimate: TTntAction;
    acFusekiTutor: TTntAction;
    acPass: TTntAction;
    acCancelGame: TTntAction;
    acPbIndex: TTntAction;
    acPbCancel: TTntAction;
    acPbHint: TTntAction;
    acPbToggleFreeMode: TTntAction;
    acEngineSettings: TTntAction;
    acGmSession: TTntAction;
    acGmIndex: TTntAction;
    acGmCancel: TTntAction;
    acNavigationSettings: TTntAction;
    acToggleCoordinates: TTntAction;
    acPrevTarget: TTntAction;
    acNextTarget: TTntAction;
    acToggleMoveMarkers: TTntAction;
    acViewBoard: TTntAction;
    acViewInfo: TTntAction;
    acViewThumb: TTntAction;
    acCreateDatabase: TTntAction;
    acOpenDatabase: TTntAction;
    acAddToDatabase: TTntAction;
    acPatternSearch: TTntAction;
    acViewSettings: TTntAction;
    acPreviewSettings: TTntAction;
    acInfoSearch: TTntAction;
    acSignatureSearch: TTntAction;
    acSearchDB: TTntAction;
    acDatabaseSettings: TTntAction;
    acWildcard: TTntAction;
    acBoardSettings: TTntAction;
    acMirror: TTntAction;
    acFlip: TTntAction;
    acRotate180: TTntAction;
    acRotate90Clock: TTntAction;
    acRotate90Trigo: TTntAction;
    acRestoreTrans: TTntAction;
    acSwapColors: TTntAction;
    acLanguageSettings: TTntAction;
    acToolbarSettings: TTntAction;
    ImageList1: TImageList;
    acMakeMainBranch: TTntAction;
    acSidebarSettings: TTntAction;
    acInfluenceRegions: TTntAction;
    acRemoveProperties: TTntAction;
    acGroupStatus: TTntAction;
    acGameTreeSettings: TTntAction;
    acReloadCurrentFile: TTntAction;
    ImageListOptions: TImageList;
    acAdvancedSettings: TTntAction;
    acShowGtpWindow: TTntAction;
    acMakeGameTree: TTntAction;
    acRestoreWindow: TTntAction;
    acOpenFromClipBoard: TTntAction;
    acSaveToClipboard: TTntAction;
    acQuickSearch: TTntAction;
    acSearchSettings: TTntAction;
    acSearchSettingsModal: TTntAction;
    acEnterTab: TTntAction;
    acFullScreen: TTntAction;
    acInsertEmptyNode: TTntAction;
    acDeleteGame: TTntAction;
    acPromoteVariation: TTntAction;
    acDemoteVariation: TTntAction;
    acHome: TTntAction;

    procedure DataModuleCreate            (Sender: TObject);
    procedure DataModuleDestroy           (Sender: TObject);

    procedure acNewExecute                (Sender: TObject); // File actions
    procedure acNewInTabExecute           (Sender: TObject);
    procedure acOpenExecute               (Sender: TObject);
    procedure acOpenInTabExecute          (Sender: TObject);
    procedure acFavoritesExecute          (Sender: TObject);
    procedure acSaveExecute               (Sender: TObject);
    procedure acSaveAsExecute             (Sender: TObject);
    procedure acCloseExecute              (Sender: TObject);
    procedure acCloseAllExecute           (Sender: TObject);
    procedure acAppendExecute             (Sender: TObject);
    procedure acMergeExecute              (Sender: TObject);
    procedure acExtractCurrentExecute     (Sender: TObject);
    procedure acExtractAllExecute         (Sender: TObject);
    procedure acDeleteGameExecute         (Sender: TObject);
    procedure acGameInfoExecute           (Sender: TObject);
    procedure acPrintExecute              (Sender: TObject);
    procedure acExportExecute             (Sender: TObject);
    procedure acExportPosExecute          (Sender: TObject);
    procedure acQuitExecute               (Sender: TObject);
    procedure acFirstGameExecute          (Sender: TObject); // Navigation actions
    procedure acLastGameExecute           (Sender: TObject);
    procedure acPrevGameExecute           (Sender: TObject);
    procedure acNextGameExecute           (Sender: TObject);
    procedure acSelectGameExecute         (Sender: TObject);
    procedure acStartPosExecute           (Sender: TObject);
    procedure acEndPosExecute             (Sender: TObject);
    procedure acPrevMoveExecute           (Sender: TObject);
    procedure acNextMoveExecute           (Sender: TObject);
    procedure acSelectMoveExecute         (Sender: TObject);
    procedure acPrevVariationExecute      (Sender: TObject);
    procedure acNextVariationExecute      (Sender: TObject);
    procedure acPointerUpExecute          (Sender: TObject);
    procedure acPointerDownExecute        (Sender: TObject);
    procedure acPointerLeftExecute        (Sender: TObject);
    procedure acPointerRightExecute       (Sender: TObject);
    procedure acAutoReplayExecute         (Sender: TObject);
    procedure acUndoMoveExecute           (Sender: TObject); // Edit actions
    procedure acDeleteBranchExecute       (Sender: TObject);
    procedure acSetupInterExecute         (Sender: TObject);
    procedure acSetupVarExecute           (Sender: TObject);
    procedure acGameEditExecute           (Sender: TObject);
    procedure acGameEditBlackFirstExecute (Sender: TObject);
    procedure acGameEditWhiteFirstExecute (Sender: TObject);
    procedure acBlackToPlayExecute        (Sender: TObject);
    procedure acWhiteToPlayExecute        (Sender: TObject);
    procedure acAddBlackExecute           (Sender: TObject);
    procedure acAddWhiteExecute           (Sender: TObject);
    procedure acEmptyExecute              (Sender: TObject);
    procedure acMarkupExecute             (Sender: TObject);
    procedure acMarkupCrossExecute        (Sender: TObject);
    procedure acMarkupTriangleExecute     (Sender: TObject);
    procedure acMarkupCircleExecute       (Sender: TObject);
    procedure acMarkupSquareExecute       (Sender: TObject);
    procedure acMarkupLetterExecute       (Sender: TObject);
    procedure acMarkupNumberExecute       (Sender: TObject);
    procedure acMarkupLabelExecute        (Sender: TObject);
    procedure acBlackTerritoryExecute     (Sender: TObject);
    procedure acWhiteTerritoryExecute     (Sender: TObject);
    procedure acInsertExecute             (Sender: TObject);
    procedure acInsertPassExecute         (Sender: TObject);
    procedure acInsertEmptyNodeExecute    (Sender: TObject);
    procedure acPromoteVariationExecute   (Sender: TObject);
    procedure acDemoteVariationExecute    (Sender: TObject);
    procedure acAboutExecute              (Sender: TObject);
    procedure acNewEngineGameExecute      (Sender: TObject);
    procedure acDisplayHelpExecute        (Sender: TObject);
    procedure acOptionsExecute            (Sender: TObject);
    procedure acJosekiTutorExecute        (Sender: TObject);
    procedure acJosekiRecentExecute       (Sender: TObject);
    procedure acSuggestMoveExecute        (Sender: TObject);
    procedure acScoreEstimateExecute      (Sender: TObject);
    procedure acFusekiTutorExecute        (Sender: TObject);
    procedure acOpenFolderExecute         (Sender: TObject);
    procedure acOpenFolderInTabExecute    (Sender: TObject);
    procedure acResignExecute             (Sender: TObject);
    procedure acPassExecute               (Sender: TObject);
    procedure acCancelGameExecute         (Sender: TObject);
    procedure acPbSessionExecute          (Sender: TObject);
    procedure acPbIndexExecute            (Sender: TObject);
    procedure acPbCancelExecute           (Sender: TObject);
    procedure acPbHintExecute             (Sender: TObject);
    procedure acPbToggleFreeModeExecute   (Sender: TObject);
    procedure acReadOnlyExecute           (Sender: TObject);
    procedure acEngineSettingsExecute     (Sender: TObject);
    procedure acGmSessionExecute          (Sender: TObject);
    procedure acGmIndexExecute            (Sender: TObject);
    procedure acGmCancelExecute           (Sender: TObject);
    procedure acToggleCoordinatesExecute  (Sender: TObject);
    procedure acAutoReplaySettingsExecute (Sender: TObject);
    procedure acPrevTargetExecute         (Sender: TObject);
    procedure acNextTargetExecute         (Sender: TObject);
    procedure acNavigationSettingsExecute (Sender: TObject);
    procedure acToggleMoveMarkersExecute  (Sender: TObject);
    procedure acViewBoardExecute          (Sender: TObject);
    procedure acViewInfoExecute           (Sender: TObject);
    procedure acViewThumbExecute          (Sender: TObject);
    procedure acOpenDatabaseExecute       (Sender: TObject);
    procedure acCreateDatabaseExecute     (Sender: TObject);
    procedure acAddToDatabaseExecute      (Sender: TObject);
    procedure acPatternSearchExecute      (Sender: TObject);
    procedure acPreviewSettingsExecute    (Sender: TObject);
    procedure acViewSettingsExecute       (Sender: TObject);
    procedure acInfoSearchExecute         (Sender: TObject);
    procedure acSignatureSearchExecute    (Sender: TObject);
    procedure acSearchDBExecute           (Sender: TObject);
    procedure acDatabaseSettingsExecute   (Sender: TObject);
    procedure acWildcardExecute           (Sender: TObject);
    procedure acBoardSettingsExecute      (Sender: TObject);
    procedure acMirrorExecute             (Sender: TObject);
    procedure acRotate180Execute          (Sender: TObject);
    procedure acFlipExecute               (Sender: TObject);
    procedure acRotate90ClockExecute      (Sender: TObject);
    procedure acRotate90TrigoExecute      (Sender: TObject);
    procedure acRestoreTransExecute       (Sender: TObject);
    procedure acSwapColorsExecute         (Sender: TObject);
    procedure acToolbarSettingsExecute    (Sender: TObject);
    procedure acLanguageSettingsExecute   (Sender: TObject);
    procedure acMakeMainBranchExecute     (Sender: TObject);
    procedure acSidebarSettingsExecute    (Sender: TObject);
    procedure acInfluenceRegionsExecute   (Sender: TObject);
    procedure acRemovePropertiesExecute   (Sender: TObject);
    procedure acGroupStatusExecute        (Sender: TObject);
    procedure ActionListExecute(Action: TBasicAction;
      var Handled: Boolean);
    procedure acGameTreeSettingsExecute(Sender: TObject);
    procedure acReloadCurrentFileExecute(Sender: TObject);
    procedure acAdvancedSettingsExecute(Sender: TObject);
    procedure acShowGtpWindowExecute(Sender: TObject);
    procedure acMakeGameTreeExecute(Sender: TObject);
    procedure acRestoreWindowExecute(Sender: TObject);
    procedure acOpenFromClipBoardExecute(Sender: TObject);
    procedure acSaveToClipboardExecute(Sender: TObject);
    procedure acQuickSearchExecute(Sender: TObject);
    procedure acSearchSettingsExecute(Sender: TObject);
    procedure acSearchSettingsModalExecute(Sender: TObject);
    procedure acEnterTabExecute(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure acDonateExecute(Sender: TObject);
    procedure acHomeExecute(Sender: TObject);
  private
    Strings : TStringList;
    EditModeList : TList;
    PointerMoveList : TList;
    ChangePositionList : TList;
    function GetActiveView : TViewMain;
    property ActiveView : TViewMain read GetActiveView;
  public
    procedure Translate;
    procedure EnableAll(state : boolean);
    procedure EnableCategory(aCategory : string; state : boolean);
    procedure EnableEditShortcuts(enable : boolean);
    procedure DefaultShortCut(iniFile : TTntMemIniFile);
    function  ModeInterToAction(kmi : integer) : TAction;
    procedure SetModeInter(mode : integer);
  end;

function InternalName(const externalName : string) : string;
function ExternalName(const internalName : string) : string;

procedure GetCategories(al : TTntActionList; sl : TTntStrings; forToolbar : boolean);
procedure GetActionsFromCategories(al : TActionList; cat : string; li : TListItems);
procedure SetModeInter(mode : integer);

var
  Actions: TActions;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  ShellAPI,
  Define, DefineUi, Main, UViewBoard, Ugcom, UAutoReplay, UEngines, Translate,
  UShortcuts, UfmFavorites, UfmPrint, UfmExportPos, UfmInsert,
  UfmOptions, UfmAbout, UMemo, UProblems, UProblemUtil, HtmlHelpAPI,
  UDatabase, UfmAddToDB, UfmDBSearch, ViewUtils, UfmRemProp, UfmFactorize, 
  UStatus, UfrViewBoard, UfrDBPatternResult;

// ---------------------------------------------------------------------------

procedure TActions.DataModuleCreate(Sender: TObject);
var
  i : integer;
begin
  Strings := TStringList.Create;
  EditModeList := TList.Create;
  PointerMoveList := TList.Create;
  ChangePositionList := TList.Create;

  for i := 0 to ActionList.ActionCount - 1 do
    with ActionList.Actions[i] as TAction do
      begin
        if Hint = ''
          then Hint := Caption;
        Strings.Add(Caption);
        Strings.Add(Hint);
      end;

  // list editing actions
  EditModeList.Add(acGameEdit);
  EditModeList.Add(acGameEditBlackFirst);
  EditModeList.Add(acGameEditWhiteFirst);
  EditModeList.Add(acAddBlack);
  EditModeList.Add(acAddWhite);
  EditModeList.Add(acEmpty);
  EditModeList.Add(acMarkup);
  EditModeList.Add(acMarkupCross);
  EditModeList.Add(acMarkupTriangle);
  EditModeList.Add(acMarkupCircle);
  EditModeList.Add(acMarkupSquare);
  EditModeList.Add(acMarkupLetter);
  EditModeList.Add(acMarkupNumber);
  EditModeList.Add(acMarkupLabel);
  EditModeList.Add(acBlackTerritory);
  EditModeList.Add(acWhiteTerritory);
  EditModeList.Add(acWildcard);

  // list pointer move actions
  PointerMoveList.Add(acPointerUp);
  PointerMoveList.Add(acPointerDown);
  PointerMoveList.Add(acPointerLeft);
  PointerMoveList.Add(acPointerRight);

  // list of actions changing position on board
  ChangePositionList.Add(acNextMove);
  ChangePositionList.Add(acPrevMove);
  ChangePositionList.Add(acStartPos);
  ChangePositionList.Add(acEndPos);
end;

procedure TActions.DataModuleDestroy(Sender: TObject);
begin
  Strings.Free;
  EditModeList.Free;
  PointerMoveList.Free;
  ChangePositionList.Free
end;

procedure TActions.Translate;
var
  i : integer;
begin
  for i := 0 to ActionList.ActionCount - 1 do
    with ActionList.Actions[i] as TTnTAction do
      begin
        Caption := U(Strings[i * 2 + 0]);
        Hint    := U(Strings[i * 2 + 1])
      end
end;

function TActions.GetActiveView : TViewMain;
begin
  Result := fmMain.ActiveView
end;

// -- File actions -----------------------------------------------------------

// -- Standard

procedure TActions.acNewExecute(Sender: TObject);
begin
  UserMainNewFile(False)
end;

procedure TActions.acNewInTabExecute(Sender: TObject);
begin
  UserMainNewFile(True)
end;

procedure TActions.acOpenExecute(Sender: TObject);
begin
  UserMainOpenFile(False)
end;

procedure TActions.acOpenInTabExecute(Sender: TObject);
begin
  UserMainOpenFile(True)
end;

procedure TActions.acOpenFolderExecute(Sender: TObject);
begin
  UserMainOpenFolder(False)
end;

procedure TActions.acOpenFolderInTabExecute(Sender: TObject);
begin
  UserMainOpenFolder(True)
end;

procedure TActions.acReloadCurrentFileExecute(Sender: TObject);
begin
  DoReloadCurrentFile
end;

procedure TActions.acSaveExecute(Sender: TObject);
var
  cancel : boolean;
begin
  UserSaveFile(fmMain.ActiveView, cancel)
end;

procedure TActions.acSaveAsExecute(Sender: TObject);
var
  cancel : boolean;
begin
  if fmMain.IsFileTab(fmMain.ActiveView.TabSheet as TTabSheetEx)
    then UserSaveAs(fmMain.ActiveView, cancel)
    else UserMainSaveAsSwitch(cancel)
end;

procedure TActions.acReadOnlyExecute(Sender: TObject);
begin
  ActiveView.si.ReadOnly := not ActiveView.si.ReadOnly
end;

procedure TActions.acCloseExecute(Sender: TObject);
begin
  UserMainCloseFile
end;

procedure TActions.acCloseAllExecute(Sender: TObject);
begin
  UserMainCloseAll
end;

procedure TActions.acQuitExecute(Sender: TObject);
begin
  DoMainQuit
end;

procedure TActions.acRestoreWindowExecute(Sender: TObject);
begin
  fmMain.RestoreWindow
end;

procedure TActions.acOpenFromClipBoardExecute(Sender: TObject);
begin
  DoOpenFromClipBoard
end;

procedure TActions.acSaveToClipboardExecute(Sender: TObject);
begin
  DoSaveToClipBoard
end;

// -- Collections

procedure TActions.acAppendExecute(Sender: TObject);
begin
  DoMainAppendTo
end;

procedure TActions.acMergeExecute(Sender: TObject);
begin
  DoMainMergeFiles
end;

procedure TActions.acExtractCurrentExecute(Sender: TObject);
begin
  DoMainExtractOne
end;

procedure TActions.acExtractAllExecute(Sender: TObject);
begin
  DoMainExtractAll
end;

procedure TActions.acDeleteGameExecute(Sender: TObject);
begin
  DoRemoveCurrentGame
end;

procedure TActions.acMakeGameTreeExecute(Sender: TObject);
begin
  TfmFactorize.Execute
end;

// -- Dialogs

procedure TActions.acFavoritesExecute(Sender: TObject);
begin
  TfmFavorites.Execute
end;

procedure TActions.acGameInfoExecute(Sender: TObject);
begin
  ActiveView.OpenGameInfoDialog;
  if ActiveView is TViewBoard
    then (ActiveView as TViewBoard).UpdateGameInformation
end;

// -- Printing and exporting

procedure TActions.acPrintExecute(Sender: TObject);
begin
  TfmPrint.Execute(0)
end;

procedure TActions.acExportExecute(Sender: TObject);
begin
  TfmPrint.Execute(1)
end;

procedure TActions.acExportPosExecute(Sender: TObject);
begin
  TfmExportPos.Execute
end;

// -- View actions -----------------------------------------------------------

procedure TActions.acViewBoardExecute(Sender: TObject);
begin
  fmMain.SelectView(vmBoard)
end;

procedure TActions.acViewInfoExecute(Sender: TObject);
begin
  fmMain.SelectView(vmInfo)
end;

procedure TActions.acViewThumbExecute(Sender: TObject);
begin
  fmMain.SelectView(vmThumb)
end;

procedure TActions.acMirrorExecute(Sender: TObject);
begin
  ComposeCurrentTransform(trSymD90{trSymV})
end;

procedure TActions.acFlipExecute(Sender: TObject);
begin
  ComposeCurrentTransform(trSymD270{trSymH})
end;

procedure TActions.acRotate180Execute(Sender: TObject);
begin
  ComposeCurrentTransform(trRot180)
end;

procedure TActions.acRotate90ClockExecute(Sender: TObject);
begin
  ComposeCurrentTransform(trRot90)
end;

procedure TActions.acRotate90TrigoExecute(Sender: TObject);
begin
  ComposeCurrentTransform(trRot270)
end;

procedure TActions.acRestoreTransExecute(Sender: TObject);
begin
  ReferenceView
end;

procedure TActions.acSwapColorsExecute(Sender: TObject);
begin
  SwapColor
end;

procedure TActions.acFullScreenExecute(Sender: TObject);
begin
  fmMain.DoToggleFullScreen
end;

// -- Database actions -------------------------------------------------------

procedure TActions.acCreateDatabaseExecute(Sender: TObject);
begin
  TfmAddToDB.Execute(dbCreate)
end;

procedure TActions.acAddToDatabaseExecute(Sender: TObject);
begin
  TfmAddToDB.Execute(dbAddTo)
end;

procedure TActions.acOpenDatabaseExecute(Sender: TObject);
begin
  UserMainOpenDatabase(False)
end;

procedure TActions.acSearchDBExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(Settings.DBSearchMode)
end;

procedure TActions.acPatternSearchExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(smPattern)
end;

procedure TActions.acInfoSearchExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(smInfo)
end;

procedure TActions.acSignatureSearchExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(smSig)
end;

procedure TActions.acSearchSettingsExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(smSettings)
end;

procedure TActions.acSearchSettingsModalExecute(Sender: TObject);
begin
  TfmDBSearch.Execute(smSettingsModal)
end;

procedure TActions.acQuickSearchExecute(Sender: TObject);
begin
  UserQuickSearch
end;

// -- Navigation actions -----------------------------------------------------

// -- Tabs

procedure TActions.acEnterTabExecute(Sender: TObject);
begin
  //
end;

// -- Games

procedure TActions.acFirstGameExecute(Sender: TObject);
begin
  ActiveView.DoFirstGame
end;

procedure TActions.acLastGameExecute(Sender: TObject);
begin
  ActiveView.DoLastGame
end;

procedure TActions.acPrevGameExecute(Sender: TObject);
begin
  ActiveView.DoPrevGame
end;

procedure TActions.acNextGameExecute(Sender: TObject);
begin
  ActiveView.DoNextGame
end;

procedure TActions.acSelectGameExecute(Sender: TObject);
begin
  ActiveView.SelectGame
end;

// -- Moves

procedure TActions.acStartPosExecute(Sender: TObject);
begin
  ActiveView.DoStartPos
end;

procedure TActions.acEndPosExecute(Sender: TObject);
begin
  ActiveView.DoEndPos
end;

procedure TActions.acPrevMoveExecute(Sender: TObject);
begin
  ActiveView.DoPrevMove
end;

procedure TActions.acNextMoveExecute(Sender: TObject);
begin
  ActiveView.DoNextMove
  ;fmMain.Repaint
end;

procedure TActions.acSelectMoveExecute(Sender: TObject);
begin
  ActiveView.SelectMove
end;

// -- Moves to user defined target

procedure TActions.acPrevTargetExecute(Sender: TObject);
begin
  DoPrevTarget(ActiveView)
end;

procedure TActions.acNextTargetExecute(Sender: TObject);
begin
  DoNextTarget(ActiveView)
end;

// -- Variations

procedure TActions.acPrevVariationExecute(Sender: TObject);
begin
  DoPrevVariation(ActiveView)
end;

procedure TActions.acNextVariationExecute(Sender: TObject);
begin
  DoNextVariation(ActiveView)
end;

// -- Pointer

procedure TActions.acPointerUpExecute(Sender: TObject);
begin
  DoPointerUp(ActiveView as TViewBoard)
end;

procedure TActions.acPointerDownExecute(Sender: TObject);
begin
  DoPointerDown(ActiveView as TViewBoard)
end;

procedure TActions.acPointerLeftExecute(Sender: TObject);
begin
  DoPointerLeft(ActiveView as TViewBoard)
end;

procedure TActions.acPointerRightExecute(Sender: TObject);
begin
  DoPointerRight(ActiveView as TViewBoard)
end;

// -- Auto replay

procedure TActions.acAutoReplayExecute(Sender: TObject);
begin
  if (Sender as TAction).Checked
    then AutoReplayStart(ActiveView as TViewBoard)
    else AutoReplayStop (ActiveView as TViewBoard)
end;

// -- Edit actions -----------------------------------------------------------

// -- Undoing

procedure TActions.acUndoMoveExecute(Sender: TObject);
begin
  if not (ActiveView.si.ModeInter in [kimEG, kimEGR])
    then ActiveView.DoUndoMove
    else GtpUndo(ActiveView as TViewBoard)
end;

// -- Game edit mode

procedure TActions.acGameEditExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimGE
end;

procedure TActions.acGameEditBlackFirstExecute(Sender: TObject);
begin
  SelectPlayer(ActiveView, Black);
  ActiveView.si.ModeInter := kimGB
end;

procedure TActions.acGameEditWhiteFirstExecute(Sender: TObject);
begin
  SelectPlayer(ActiveView, White);
  ActiveView.si.ModeInter := kimGW
end;

procedure TActions.acBlackToPlayExecute(Sender: TObject);
begin
  SelectPlayer(ActiveView, Black)
end;

procedure TActions.acWhiteToPlayExecute(Sender: TObject);
begin
  SelectPlayer(ActiveView, White)
end;

// -- Stones

procedure TActions.acAddBlackExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimAB
end;

procedure TActions.acAddWhiteExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimAW
end;

procedure TActions.acEmptyExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimAE
end;

// -- Markups

procedure TActions.acMarkupExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := Settings.LastMarkup
end;

procedure TActions.acMarkupCrossExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimMA
end;

procedure TActions.acMarkupTriangleExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimTR
end;

procedure TActions.acMarkupCircleExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimCR
end;

procedure TActions.acMarkupSquareExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimSQ
end;

procedure TActions.acMarkupLetterExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimLE
end;

procedure TActions.acMarkupNumberExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimNU
end;

procedure TActions.acMarkupLabelExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimLB
end;

procedure TActions.acBlackTerritoryExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimTB
end;

procedure TActions.acWhiteTerritoryExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimTW
end;

procedure TActions.acWildcardExecute(Sender: TObject);
begin
  ActiveView.si.ModeInter := kimWC
end;

// -- Simulation of clicks on goban

procedure TActions.acSetupInterExecute(Sender: TObject);
var
  where : TPoint;
  i, j : integer;
  view : TViewBoard;
begin
  assert(ActiveView is TViewBoard);
  view := ActiveView as TViewBoard;

  where := view.frViewBoard.imGoban.ScreenToClient(Mouse.CursorPos);
  view.gb.xy2ij(where.x, where.y, i, j);
  ClickOnBoard(view, i, j, mbLeft, [ssLeft])
end;

procedure TActions.acSetupVarExecute(Sender: TObject);
var
  where : TPoint;
  i, j : integer;
  view : TViewBoard;
begin
  assert(ActiveView is TViewBoard);
  view := ActiveView as TViewBoard;

  where := view.frViewBoard.imGoban.ScreenToClient(Mouse.CursorPos);
  view.gb.xy2ij(where.x, where.y, i, j);
  ClickOnBoard(view, i, j, mbLeft, [ssLeft, ssCtrl])
end;

// -- Insertion

procedure TActions.acInsertEmptyNodeExecute(Sender: TObject);
var
  done : boolean;
begin
  fmMain.ActiveViewBoard.AddNode(done)
end;

procedure TActions.acInsertPassExecute(Sender: TObject);
begin
  InsertPass(fmMain.ActiveViewBoard)
end;

procedure TActions.acInsertExecute(Sender: TObject);
begin
  TfmInsert.Execute
end;

// -- Advanced

procedure TActions.acDeleteBranchExecute(Sender: TObject);
begin
  ActiveView.DoDeleteBranch
end;

procedure TActions.acMakeMainBranchExecute(Sender: TObject);
begin
  ActiveView.DoMakeMainBranch
end;

procedure TActions.acPromoteVariationExecute(Sender: TObject);
begin
  ActiveView.DoPromoteVariation
end;

procedure TActions.acDemoteVariationExecute(Sender: TObject);
begin
  ActiveView.DoDemoteVariation
end;

procedure TActions.acRemovePropertiesExecute(Sender: TObject);
begin
  TfmRemProp.Execute
end;

// -- Library related actions ------------------------------------------------

procedure TActions.acJosekiTutorExecute(Sender: TObject);
begin
  //DoEnterJosekiTutor(fmMain.ActiveViewBoard, '', trIdent)
end;

procedure TActions.acJosekiRecentExecute(Sender: TObject);
begin
  //DoEnterJosekiTutor(fmMain.ActiveViewBoard, '', trIdent);
end;

procedure TActions.acFusekiTutorExecute(Sender: TObject);
begin
  //DoEnterFusekiTutor(fmMain.ActiveViewBoard, '', trIdent)
end;

// -- Replaying games --------------------------------------------------------

procedure TActions.acGmSessionExecute(Sender: TObject);
begin
  if GmVerifyAndLoad(ActiveView)
    then GmEnter(ActiveView)
end;

procedure TActions.acGmIndexExecute(Sender: TObject);
begin
  if GmVerifyAndLoad(ActiveView)
    then fmMain.SelectView(vmInfoGm)
end;

procedure TActions.acGmCancelExecute(Sender: TObject);
begin
  GmLeave(ActiveView as TViewBoard)
end;

// -- Problems ---------------------------------------------------------------

procedure TActions.acPbSessionExecute(Sender: TObject);
begin
  if PbVerifyAndLoad(ActiveView)
    then PbEnter(ActiveView)
end;

procedure TActions.acPbIndexExecute(Sender: TObject);
begin
  if PbVerifyAndLoad(ActiveView)
    then fmMain.SelectView(vmInfoPb)
end;

procedure TActions.acPbHintExecute(Sender: TObject);
begin
  if ActiveView is TViewBoard
    then PbHint(ActiveView as TViewBoard)
end;

procedure TActions.acPbToggleFreeModeExecute(Sender: TObject);
begin
  if ActiveView is TViewBoard
    then PbToggleFreeMode(ActiveView as TViewBoard)
end;

procedure TActions.acPbCancelExecute(Sender: TObject);
begin
  if ActiveView is TViewBoard
    then PbLeave(ActiveView as TViewBoard)
end;

// -- Engine game actions ----------------------------------------------------

procedure TActions.acNewEngineGameExecute(Sender: TObject);
begin
  DoMainNewEngineGame
end;

procedure TActions.acPassExecute(Sender: TObject);
begin
  DoPass(ActiveView as TViewBoard)
end;

procedure TActions.acResignExecute(Sender: TObject);
begin
  DoResign(ActiveView as TViewBoard)
end;

procedure TActions.acScoreEstimateExecute(Sender: TObject);
begin
  DoScoreEstimate(ActiveView as TViewBoard)
end;

procedure TActions.acSuggestMoveExecute(Sender: TObject);
begin
  DoSuggestMove(ActiveView as TViewBoard)
end;

procedure TActions.acInfluenceRegionsExecute(Sender: TObject);
begin
  DoInfluenceRegions(ActiveView as TViewBoard)
end;

procedure TActions.acGroupStatusExecute(Sender: TObject);
begin
  ActiveView.si.ModeInterBeforeGS := ActiveView.si.ModeInter;
  ActiveView.si.ModeInter := kimGS;
  Screen.Cursor := crHelp
end;

procedure TActions.acCancelGameExecute(Sender: TObject);
begin
  StopEngine(ActiveView as TViewBoard)
end;

procedure TActions.acShowGtpWindowExecute(Sender: TObject);
begin
  ShowGtpWindow
end;

// -- Help actions -----------------------------------------------------------

procedure TActions.acAboutExecute(Sender: TObject);
begin
  TfmAbout.Execute
end;

procedure TActions.acDonateExecute(Sender: TObject);
const
  Url = 'http://www.godrago.net/HowToHelp.htm';
begin
  ShellExecute(0, 'open', Url, nil, nil, SW_SHOWNORMAL)
end;

procedure TActions.acHomeExecute(Sender: TObject);
const
  Url = 'http://www.godrago.net/';
begin
  ShellExecute(0, 'open', Url, nil, nil, SW_SHOWNORMAL)
end;

procedure TActions.acDisplayHelpExecute(Sender: TObject);
begin
  HtmlHelpShowContents
end;

// -- Option actions ---------------------------------------------------------

procedure TActions.acOptionsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoDefault)
end;

procedure TActions.acEngineSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoEngines)
end;

procedure TActions.acNavigationSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoNavigation)
end;

procedure TActions.acViewSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoView)
end;

procedure TActions.acBoardSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoBoard)
end;

procedure TActions.acPreviewSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoIndex)
end;

procedure TActions.acAutoReplaySettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoNavigation)
end;

procedure TActions.acSidebarSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoSidebar)
end;

procedure TActions.acDatabaseSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoDatabase)
end;

procedure TActions.acToolbarSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoToolbars)
end;

procedure TActions.acLanguageSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoLanguage)
end;

procedure TActions.acGameTreeSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoGameTree)
end;

procedure TActions.acAdvancedSettingsExecute(Sender: TObject);
begin
  TfmOptions.Execute(eoAdvanced)
end;

procedure TActions.acToggleCoordinatesExecute(Sender: TObject);
begin
  case Settings.CoordStyle of
    tcNone   : Settings.CoordStyle := tcKorsch;
    tcKorsch : Settings.CoordStyle := tcNone;
    tcSGF    : Settings.CoordStyle := tcNone;
  end;

  fmMain.UpdateBoards
end;

procedure TActions.acToggleMoveMarkersExecute(Sender: TObject);
begin
  case Settings.ShowMoveMode of
    smNoMark : Settings.ShowMoveMode := smMark;
    smMark   : Settings.ShowMoveMode := smNumber;
    smNumber : Settings.ShowMoveMode := smAll;
    smAll    : Settings.ShowMoveMode := smNoMark
  end;

  fmMain.UpdateBoards
end;

// -- Enabling of actions ----------------------------------------------------

procedure TActions.EnableAll(state : boolean);
var
  i : integer;
begin
  for i := 0 to ActionList.ActionCount - 1 do
    with ActionList.Actions[i] as TAction do
      if Enabled <> state
        then Enabled := state
end;

procedure TActions.EnableCategory(aCategory : string; state : boolean);
var
  i : integer;
begin
  for i := 0 to ActionList.ActionCount - 1 do
    with ActionList.Actions[i] as TAction do
      if (Category = aCategory) and (Enabled <> state)
        then Enabled := state
end;

// -- Coordination of editing actions ----------------------------------------

// -- Link between ModeInter values and actions

function TActions.ModeInterToAction(kmi : integer) : TAction;
begin
  case kmi of
    kimGE : Result := acGameEdit;
    kimGB : Result := acGameEditBlackFirst;
    kimGW : Result := acGameEditWhiteFirst;
    kimAB : Result := acAddBlack;
    kimAW : Result := acAddWhite;
    kimAE : Result := acEmpty;
    kimMA : Result := acMarkupCross;
    kimTR : Result := acMarkupTriangle;
    kimCR : Result := acMarkupCircle;
    kimSQ : Result := acMarkupSquare;
    kimLE : Result := acMarkupLetter;
    kimNU : Result := acMarkupNumber;
    kimLB : Result := acMarkupLabel;
    kimTB : Result := acBlackTerritory;
    kimTW : Result := acWhiteTerritory;
    kimWC : Result := acWildcard;
    //kimVW : Result := acViewZone
    else Result := nil
  end
end;

// -- Edit mode setting

procedure TActions.SetModeInter(mode : integer);
var
  action : TAction;
  i : integer;
begin
  // find associated action
  action := ModeInterToAction(mode);

  // if not defined, nothing to do here
  if action = nil
    then exit;

  // uncheck all editing actions
  for i := 0 to EditModeList.Count - 1 do
    TAction(EditModeList.Items[i]).Checked := False;

  // check current action
  action.Checked := True;

  // handle game edit black or white first
  if mode = kimGE
    then acGameEditBlackFirst.Checked := True;
  if mode in [kimGB, kimGW]
    then acGameEdit.Checked := True;

  // update current markup action if required
  if mode in kimMarkups then
    begin
      acMarkup.Checked := True;
      // update acMarkup glyph (and button Markup in toolbar)
      acMarkup.ImageIndex := action.ImageIndex;
      // mandatory update of button
      fmMain.tbCurrentMarkup.Action := acMarkup;
      // store markup (except for pattern search wildcard)
      if mode <> kimWC
        then Settings.LastMarkup := mode
    end
end;

procedure SetModeInter(mode : integer);
begin
  Actions.SetModeInter(mode)
end;

// -- Protection of edit shortcuts -------------------------------------------

// Standard editing shortcuts can be used as action shortcuts. In that case,
// they are handled as so even if another form wants to used them (for
// instance fmGtp and edSend). It is therefore necessary for the form to
// inhibate these keys as action shortcuts.

// The EnableEditShortcuts function must be called when the form has focus (ie
// after an OnClick event or from OnActivate event).

function IsEditShortcut(shortcut : TShortcut) : boolean;
var
  Key : Word;
  Shift : TShiftState;
begin
  ShortCutToKey(ShortCut, key, shift);
  if shift = []
    then Result := key in [VK_RETURN, VK_INSERT, VK_DELETE, VK_TAB,
                           VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN,
                           VK_PRIOR, VK_NEXT, VK_HOME, VK_END]
    else
      if shift = [ssCtrl]
        then Result := key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN,
                               ord('C'), ord('V'), ord('X'), ord('Z')]
        else Result := False
end;

procedure TActions.EnableEditShortcuts(enable : boolean);
var
  i : integer;
begin
  for i := 0 to ActionList.ActionCount - 1 do
    with ActionList.Actions[i] as TAction do
      if enable
        then
          begin
            if Tag <> 0 then
              // restore shortcut and reset tag
              begin
                ShortCut := Tag;
                Tag := 0
              end
          end
        else
          begin
            if IsEditShortcut(Shortcut) then
              // save and reset shortcut
              begin
                Tag := ShortCut;
                ShortCut := 0
              end
          end
end;

// -- Conversions between internal and external action names -----------------

function InternalName(const externalName : string) : string;
begin
  Result := 'ac' + externalName
end;

function ExternalName(const internalName : string) : string;
begin
  Result := Copy(internalName, 3, MAXINT)
end;

// -- Default shortcuts ------------------------------------------------------

procedure TActions.DefaultShortCut(iniFile : TTntMemIniFile);

procedure Default(ident : string; key : word; shift: TShiftState);
begin
  iniFile.WriteString('Shortcuts', ident, EnShortCutToText(ShortCut(key, shift)))
end;

begin
  with iniFile do
    begin
      EraseSection('Shortcuts');

      Default('FirstGame'    , VK_HOME  , [ssCtrl]);
      Default('LastGame'     , VK_END   , [ssCtrl]);
      Default('PrevGame'     , VK_LEFT  , [ssCtrl]);
      Default('NextGame'     , VK_RIGHT , [ssCtrl]);

      Default('StartPos'     , VK_HOME  , []);
      Default('EndPos'       , VK_END   , []);
      Default('PrevMove'     , VK_LEFT  , []);
      Default('NextMove'     , VK_RIGHT , []);
      Default('PrevVariation', VK_UP    , []);
      Default('NextVariation', VK_DOWN  , []);

      Default('PointerUp'    , VK_UP    , [ssAlt]);
      Default('PointerDown'  , VK_DOWN  , [ssAlt]);
      Default('PointerLeft'  , VK_LEFT  , [ssAlt]);
      Default('PointerRight' , VK_RIGHT , [ssAlt]);

      Default('SetupInter'   , VK_RETURN, []);
      Default('SetupVar'     , VK_RETURN, [ssCtrl]);
      Default('UndoMove'     , ord('Z') , [ssCtrl]);
    end
end;

// -- Common working for all actions -----------------------------------------

procedure TActions.ActionListExecute(Action: TBasicAction;
  var Handled: Boolean);
begin
  //fmMain.ActiveView.gb.HideTempMarks;
  if (fmMain.ActiveView.si.DbQuickSearch = qsReady) and (Action <> acNextMove)
    then fmMain.ActiveView.si.DbQuickSearch := qsOpen;

  // todo: hide details
  ///if (fmMain.ActiveView.si.DbQuickSearch  in [qsOpen, qsReady]) and not PatternSearchReady then
  if PatternSearchMode(fmMain.ActiveView) = psmQuickSearchSideBar then
    begin
      if fmMain.ActiveView is TViewBoard then
      begin
      (fmMain.ActiveView as TViewBoard).frViewBoard.frDBPatternResult.ClearResults;
      (fmMain.ActiveView as TViewBoard).frViewBoard.lbQuickSearch.Caption := ''
      end
    end;

  if True
    then fmMain.ActiveView.gb.Rectangle(0, 0, 0, 0, False);

  //if PatternSearchMode in [psmButtonSearchDBWindow, psmQuickSearchDBWindow] then
  // en test
  if PatternSearchMode(fmMain.ActiveView) in [psmButtonSearchDBWindow, psmQuickSearchDBWindow] then
    begin
      fmMain.ActiveView.gb.HideTempMarks;
      fmDBSearch.frDBPatternPanel.frResults.ClearResults;
    end;

  ///if (fmMain.ActiveView.si.DbQuickSearch in [qsOpen, qsReady]) then
  if PatternSearchMode(fmMain.ActiveView) in [psmQuickSearchDBWindow, psmQuickSearchSideBar] then
    begin
      fmMain.ActiveView.gb.HideTempMarks;
    end;
    
  Handled := False
end;

// -- General routines on action lists ---------------------------------------

// -- Return translated list of category names
// -- The object associated with each category is the list of actions from
// -- the category.

procedure GetCategories(al : TTntActionList; sl : TTntStrings; forToolbar : boolean);
var
  i : integer;
  s : WideString;
begin
  for i := 0 to al.ActionCount - 1 do
    with al.Actions[i] as TTntAction do
      if Tag < 0
        then Continue
        else
          begin
            if (DebugHook = 0) and (Category = 'Library')
              then Continue;

            s := U(Category);

            if sl.IndexOf(s) < 0
              then sl.AddObject(s, TList.Create);

            // s is not added if '' (?). This is possible if the
            // translation string is not UTF8.
            if sl.IndexOf(s) < 0
              then continue;

            // hack to remove pointer move actions from navigation
            // category for toolbar setting. No need to keep them as
            // using the buttons loses the position on board.
            if forToolbar
              and (Category = 'Navigation')
              and (Actions.PointerMoveList.IndexOf(al.Actions[i]) >= 0)
              then continue;

            if (Category = 'Navigation') and (al.Actions[i] = Actions.acEnterTab)
              then continue;

            (sl.Objects[sl.IndexOf(s)] as TList).Add(al.Actions[i])
          end
end;

// -- not used, if ever, beware of translation

procedure GetActionsFromCategories(al : TActionList; cat : string; li : TListItems);
var
  i: integer;
  ac : TAction;
begin
  li.Clear;
  for i := 0 to al.ActionCount - 1 do
    begin
      ac := TAction(al.Actions[i]);
      if ac.Tag < 0
        then Continue;
      if (cat <> '') and (ac.Category <> cat)
        then Continue;

      with li.Add do
        begin
          Caption := ac.Caption;
          ImageIndex := ac.ImageIndex;
        end
    end
end;

// ---------------------------------------------------------------------------


end.
