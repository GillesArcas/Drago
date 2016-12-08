// ---------------------------------------------------------------------------
// -- Drago -- Main form utilities -------------------------- UMainUtil.pas --
// ---------------------------------------------------------------------------

unit UMainUtil;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Menus,
  Controls, Forms,
  MMsystem,
  TntComCtrls, TntSystem,
  DefineUi, UView, UViewMain;

procedure LockMainWindow   (lock : boolean);
procedure MainTranslate;
procedure EnableCommands   (view : TView; x : TEnablingMode);
procedure EnableAllCommands(x : boolean);
procedure SetTabIcon       (tab : TObject; view : TViewMain; mode : TEnablingMode); overload;
procedure SetTabIcon       (view : TViewMain; mode : TEnablingMode); overload;
procedure SetFileName      (view: TViewMain; aName : WideString);
procedure SetMRU           (const aFolder, aName : WideString);
procedure SetMainCaption   (view: TViewMain);
function  GetMainPlacement : string;
procedure SetMainPlacement (s : string; var maximized : boolean);
procedure DragoPlaySound(sound : TSound); overload;
procedure DragoPlaySound(sound : TSound; soundName : string); overload;
procedure PlayStoneSound(isEngineMove : boolean = False);
function  SoundString(sound : TSound) : string;
procedure ConvertRelativePathsToAbsolute;
procedure ConvertAbsolutePathsToRelative;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, SysUtilsEx,
  Std, Translate, Main, UStatus, VclUtils, UActions, UStatusMain, UEngines;

// -- Control of main window updates -----------------------------------------

var
  MainWindowLockNum : integer = 0;

procedure LockMainWindow(lock : boolean);
begin
  if fmMain.Visible = False
    then exit;
    
  if lock
    then
      begin
        if MainWindowLockNum = 0
          then LockControl(fmMain, True);

        inc(MainWindowLockNum)
      end
    else
      begin
        dec(MainWindowLockNum);

        if MainWindowLockNum = 0
          then
            begin
              LockControl(fmMain, False);
              //fmMain.StatusBar.Repaint
            end;
      end
end;

// -- Translation of the main form -------------------------------------------

procedure MainTranslate;
begin
  // translation of action captions
  Actions.Translate;

  // translation of menubar captions not coded as actions
  with fmMain do
    begin
      mnFile        .Caption := U('File');
      mnCollections .Caption := U('Collections');
      mnView        .Caption := U('View');
      mnShowToolbars.Caption := U('Show toolbars');
      mnShowTB_File .Caption := U('File');
      mnShowTB_View .Caption := U('View');
      mnShowTB_Navigation.Caption := U('Navigation');
      mnShowTB_Edit .Caption := U('Edit');
      mnShowTB_Misc .Caption := U('Misc');
      mnNavigation  .Caption := U('Navigation');
      mnEdition     .Caption := U('Edit');
      mnDatabase    .Caption := U('Database');
      mnPlayer      .Caption := U('Player');
      mnReplayGames .Caption := U('Games2');
      mnProblems    .Caption := U('Problems');
      mnEngineGame  .Caption := U('Play');
      mnOptions     .Caption := U('Options');
      mnHelp        .Caption := U('Help');

      ToolbarFile   .Caption := U('File');
      ToolbarView   .Caption := U('View');
      ToolbarEdit   .Caption := U('Edit');
      ToolbarNavigation.Caption := U('Navigation');
      ToolbarMisc   .Caption := U('Misc');
    end
end;

// -- Enabling of components and actions -------------------------------------

// -- Enable all

procedure EnableAllCommands(x : boolean);
var
  i : integer;
begin
  with fmMain do
    begin
      for i := 0 to ComponentCount - 1 do
        if Components[i] is TMenuItem
          then TMenuItem(Components[i]).Enabled := x;
      Actions.EnableAll(x);
//TODO : pagecontrol
(*
      if not x
        then PageControl.OnChanging := PageControlDisableChanging
        else PageControl.OnChanging := nil;
*)
      if not x
        then OnDblClick := nil
        else OnDblClick := FormDblClick;
    end
end;

// -- Enable minimal set of actions

procedure EnableCommandsMinimal;
begin
  with Actions do
    begin
      // lock all actions
      EnableAll(False);

      // 'Database' category
      acOpenDatabase.Enabled     := True;
      acCreateDatabase.Enabled   := True;
      acSearchDB.Enabled         := True;
      acQuickSearch.Enabled      := True;
      acInfoSearch.Enabled       := True;
      acPatternSearch.Enabled    := True;
      acSignatureSearch.Enabled  := True;
      acSearchSettings.Enabled   := True;
      acSearchSettingsModal.Enabled := True;

      // 'File' category
      acNew.Enabled              := True;
      acOpen.Enabled             := True;
      acOpenFolder.Enabled       := True;
      acClose.Enabled            := True;
      acCloseAll.Enabled         := True;
      acQuit.Enabled             := True;
      acMerge.Enabled            := True;
      acFavorites.Enabled        := True;
      acGameInfo.Enabled         := True;
      acPrint.Enabled            := True;
      acExport.Enabled           := True;
      acRestoreWindow.Enabled    := True;
      acReloadCurrentfile.Enabled:= True;

      // 'Help' category
      acDisplayHelp.Enabled      := True;
      acDonate.Enabled           := True;
      acHome.Enabled             := True;
      acAbout.Enabled            := True;

      // 'Options' category
      acOptions.Enabled          := True;
      acViewSettings.Enabled     := True;
      acBoardSettings.Enabled    := True;
      acPreviewSettings.Enabled  := True;
      acSidebarSettings.Enabled  := True;
      acDatabaseSettings.Enabled := True;
      acToolbarSettings.Enabled  := True;
      acLanguageSettings.Enabled := True;
      acGameTreeSettings.Enabled := True;
      acAdvancedSettings.Enabled := True;

      // 'View' category
      acFullScreen.Enabled       := True;
      acViewBoard.Enabled        := True;
      acViewInfo.Enabled         := True;
      acViewThumb.Enabled        := True;

      // Engines
      acShowGtpWindow.Enabled    := True;
    end
end;

// -- Enable minimal set of actions when board visible

procedure EnableCommandsMinimalBoard;
begin
  // enable minimal set of actions
  EnableCommandsMinimal;

  with Actions do
    begin
      // 'View' category
      acRestoreTrans.Enabled     := True;
      acMirror.Enabled           := True;
      acFlip.Enabled             := True;
      acRotate180.Enabled        := True;
      acRotate90Clock.Enabled    := True;
      acRotate90Trigo.Enabled    := True;
      acSwapColors.Enabled       := True;

      // 'Navigation' category
      acPointerUp.Enabled        := True;
      acPointerDown.Enabled      := True;
      acPointerLeft.Enabled      := True;
      acPointerRight.Enabled     := True;

      // 'Options' category
      acToggleCoordinates.Enabled:= True;
      acToggleMoveMarkers.Enabled:= True;
    end
end;

// -- Enable actions for edit mode

procedure EnableCommandsEdit(view : TView);
begin
  // enable minimal set of actions when board visible
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Database' category
      acAddToDatabase.Enabled    := view.kh <> nil;

      // 'Edit' category
      EnableCategory('Edit', True);
      //acWildcard.Enabled         := False;

      // 'Engine' category
      acNewEngineGame.Enabled    := not IsOneEngineRunning;
      acScoreEstimate.Enabled    := Settings.AnalysisEngine.FAvailScoreEstimate;
      acSuggestMove.Enabled      := Settings.AnalysisEngine.FAvailMoveSuggestion;
      acInfluenceRegions.Enabled := Settings.AnalysisEngine.FAvailInfluenceRegion;
      acGroupStatus.Enabled      := Settings.AnalysisEngine.FAvailGroupStatus;

      // 'File' category
      EnableCategory('File', True);
      acSave.Enabled             := not view.si.FileSave;
      acExportPos.Enabled        := True;

      // 'Navigation' category
      EnableCategory('Navigation', True);

      // 'Options' category
      acEngineSettings.Enabled   := True;
      acNavigationSettings.Enabled := True;

      // 'Problems' category
      acPbSession.Enabled        := True;
      acPbIndex.Enabled          := True;

      // 'Replay' category
      acGmSession.Enabled        := True;
      acGmIndex.Enabled          := True;
    end
end;

// -- Enable actions for export position mode

procedure EnableCommandsExportPos(view : TView);
begin
  // enable minimal set of actions when board visible
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Database' category
      EnableCategory('Database', False);

      // 'Navigation' category
      EnableCategory('Navigation', True);

      // 'View' category
      acViewBoard.Enabled        := True;
      acViewInfo.Enabled         := False;
      acViewThumb.Enabled        := False;
    end
end;

// -- Enable actions for engine mode

procedure EnableCommandsEngine(view : TView);
begin
  // enable minimal set of actions when board visible
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Database' category
      EnableCategory('Database', False);

      // 'Edit' category
      acSetupInter.Enabled       := True;
      acUndoMove.Enabled         := (Settings.plUndo = euYes) and
                                     Settings.PlayingEngine.FAvailUndo;
      // 'Engine' category
      acPass.Enabled             := True;
      acResign.Enabled           := True;
      
      acNewEngineGame.Enabled    := False;
      acScoreEstimate.Enabled    := Settings.AnalysisEngine.FAvailScoreEstimate;
      acSuggestMove.Enabled      := Settings.AnalysisEngine.FAvailMoveSuggestion;
      acInfluenceRegions.Enabled := Settings.AnalysisEngine.FAvailInfluenceRegion;
      acGroupStatus.Enabled      := Settings.AnalysisEngine.FAvailGroupStatus;
      acCancelGame.Enabled       := True;

      // 'Navigation' category
      acStartPos.Enabled         := True;
      acPrevMove.Enabled         := True;
      acNextMove.Enabled         := view.si.ModeInter in [kimRGR, kimEGR];
      acEndPos.Enabled           := view.si.ModeInter in [kimRGR, kimEGR];
    end
end;

// -- Enable actions for replay mode

procedure EnableCommandsReplay(view : TView);
begin
  // enable minimal set of actions when board visible
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Database' category
      EnableCategory('Database', False);

      // 'Edit' category
      acSetupInter.Enabled       := True;

      // 'Navigation' category
      acStartPos.Enabled         := True;
      acPrevMove.Enabled         := True;
      acNextMove.Enabled         := view.si.ModeInter in [kimRGR, kimEGR];
      acEndPos.Enabled           := view.si.ModeInter in [kimRGR, kimEGR];

      // 'Replay' category
      acGmCancel.Enabled         := True
    end
end;

// -- Enable actions for problem mode

procedure EnableCommandsProblem(view : TView);
begin
  // enable minimal set of actions when board visible
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Database' category
      EnableCategory('Database', False);

      // 'Edit' category
      acSetupInter.Enabled       := True;

      // 'Navigation' category
      acNextGame.Enabled         := True;
      acStartPos.Enabled         := True;
      acPrevMove.Enabled         := True;

      // 'Problems' category
      acPbHint.Enabled           := True;
      acPbToggleFreeMode.Enabled := True;
      acPbCancel.Enabled         := True
    end
end;

// -- Enable actions for autoreplay mode

procedure EnableCommandsAutoReplay;
begin
  // enable minimal set of actions
  EnableCommandsMinimalBoard;

  with Actions do
    begin
      // 'Navigation' category
      acNextMove.Enabled         := True;
      acEndPos.Enabled           := True;
      acAutoReplay.Enabled       := True;

      // 'Options' category
      acNavigationSettings.Enabled := True
    end
end;

// -- Enabling actions for info view

procedure EnableCommandsInfoView(view : TView);
var
  isNewEngineGameEnabled : boolean;
begin
  isNewEngineGameEnabled := Actions.acNewEngineGame.Enabled;

  // enable minimal set of actions
  EnableCommandsMinimal;

  with Actions do
    begin
      // 'Database' category
      acQuickSearch.Enabled      := False;
      acAddToDatabase.Enabled    := view.kh <> nil;

      // 'Edit' category
      EnableCategory('Edit', False);

      // 'Engine' category
      acNewEngineGame.Enabled    := isNewEngineGameEnabled;

      // 'File' category
      acNewInTab.Enabled         := True;
      acOpenInTab.Enabled        := True;
      acOpenFolderInTab.Enabled  := True;
      acSaveAs.Enabled           := True;
      acAppend.Enabled           := True;
      acMerge.Enabled            := True;
      acExtractCurrent.Enabled   := True;
      acExtractAll.Enabled       := True;
      acDeleteGame.Enabled       := True;
      acMakeGameTree.Enabled     := True;

      // 'Navigation' category
      acFirstGame.Enabled        := True;
      acPrevGame.Enabled         := True;
      acNextGame.Enabled         := True;
      acLastGame.Enabled         := True;
      acSelectGame.Enabled       := True;

      // 'Problems' and 'Replay' categories
      acPbSession.Enabled        := True;
      acGmSession.Enabled        := True;
      acPbIndex.Enabled          := True;
      acGmIndex.Enabled          := True;
    end
end;

// -- Enabling actions for thumb view

procedure EnableCommandsThumbView(view : TView);
begin
  // almost the same as InfoView
  EnableCommandsInfoView(view);

  with Actions do
    begin
      // 'Database' category
      acQuickSearch.Enabled      := False;
      
      // 'File' category
      acAppend.Enabled           := True;
      acMerge.Enabled            := True;
      acExtractCurrent.Enabled   := True;
      acExtractAll.Enabled       := True;
      acDeleteGame.Enabled       := True;
      acMakeGameTree.Enabled     := True;
    end;

  if (view.cl.Count > 0) and (view.cl.Hits[1] = '') then
    with Actions do
      begin
        // 'Navigation' category
        acStartPos.Enabled        := True;
        acEndPos.Enabled          := True;
        acPrevMove.Enabled        := True;
        acNextMove.Enabled        := True;
        acSelectMove.Enabled      := True;
      end
end;

// -- Entry point

procedure EnableCommands(view : TView; x : TEnablingMode);
begin
  view.si.EnableMode := x;

  //todo: check and extend
  LockControl(fmMain.DockTop, True);

  case view.si.EnableMode of
    mdEdit      : EnableCommandsEdit     (view);
    mdAuto      : EnableCommandsAutoReplay;
    mdExpo      : EnableCommandsExportPos(view);
    mdInfoView  : EnableCommandsInfoView (view);
    mdThumbView : EnableCommandsThumbView(view);
    mdPlay      : EnableCommandsEngine   (view);
    mdGame      : EnableCommandsReplay   (view);
    mdProb      : EnableCommandsProblem  (view)
  end;

  LockControl(fmMain.DockTop, False)
end;

// -- Setting of tab icons ---------------------------------------------------

procedure SetTabIcon(tab : TObject; view : TViewMain; mode : TEnablingMode);
var
  i : integer;
begin
  // select tab icon
  case mode of
    mdCrea : i := 0;
    //mdEdit : i := iff(gv.si.FolderName = '', 1, 2);
    mdEdit : i := iff(view.kh <> nil, 5, iff(view.si.FolderName = '', 1, 2));
    else     i := 3
  end;

  // set tab icon
  (tab as TTabSheetEx).ImageIndex := i
end;

procedure SetTabIcon(view : TViewMain; mode : TEnablingMode);
begin
  SetTabIcon(fmMain.ActivePage, view, mode)
end;

// -- Setting of main caption ------------------------------------------------

procedure SetMainCaptionFolder(view: TViewMain);
var
  fileModified, folderModified : boolean;
  i : integer;
begin
  with view do
    begin
      fileModified := not si.FileSave;

      folderModified := False;
      for i := 1 to cl.Count do
        if cl.FTree[i].Modified then
          begin
            folderModified := True;
            break
          end;

      fmMain.Caption := AppName + ' - '
                                + si.FolderName
                                + iff(folderModified, '*', '')
                                + ' - '
                                + WideExtractFileName(si.FFileName)
                                + iff(fileModified, '*', '')
    end
end;

procedure SetMainCaption(view: TViewMain);
begin
  with view do
    begin
      if si.FFileName = ''
        then fmMain.Caption := AppName + iff(si.FileSave, '', '*')
      else if si.FolderName <> ''
        then SetMainCaptionFolder(view)
      else if  si.DatabaseName <> ''
        then fmMain.Caption := AppName + ' - '
                                       + si.DatabaseName
                                       + ' - '
                                       + ExtractFileName(si.FFileName)
        else fmMain.Caption := AppName + ' - ' + si.FFileName
                                  + iff(si.FileSave, '', '*')
    end
end;

// -- Setting of file name ---------------------------------------------------
//
// TODO: TabName only used in UEngines
// TODO: SetMRU should not be limited to TViewMain

procedure SetFileName(view: TViewMain; aName : WideString);
begin
  with view do
    if (aName = '') and (si.DatabaseName = '')
      then
        // browsing file with no name
        begin
          TabName := 'Goban' + IntToStr(si.GobanNumber);
        end
    else if si.FolderName <> ''
      then
        // browsing folder, si.FolderName must be set
        begin
          TabName := WideExtractFileName(WideExcludeTrailingPathDelimiter(si.FolderName));
          SetMRU(si.FolderName, aName)
        end
    else if si.DatabaseName <> ''
      then
        // browsing database
        begin
          TabName := WideExtractFileName(si.DatabaseName);
          SetMRU(si.FolderName, si.DatabaseName)
        end
      else
        // browsing file
        begin
          TabName := WideExtractFileName(aName);
          SetMRU(si.FolderName, aName)
        end;

  (view.TabSheet as TTabSheetEx).Caption := view.TabName;
  SetMainCaption(view)
end;

// -- MRU file list ----------------------------------------------------------

function MenuString(const aFolder, aName : WideString) : WideString;
begin
  if aFolder <> ''
    then Result := aFolder
    else Result := WideExtractFileName(aName)
end;

procedure SetMRU(const aFolder, aName : WideString);
begin
  // ignore if file name is empty
  if aName = ''
    then exit;

  with fmMain do with Settings do
    begin
      // add to MRU
      MRUList.Add(aFolder, aName, 1, '');

      // set menus
      mnFile1.Visible := (MRUList.Count > 0) and (MRUList[0].Name <> '');
      mnFile2.Visible := (MRUList.Count > 1) and (MRUList[1].Name <> '');
      mnFile3.Visible := (MRUList.Count > 2) and (MRUList[2].Name <> '');
      mnFile4.Visible := (MRUList.Count > 3) and (MRUList[3].Name <> '');
      if mnFile1.Visible
        then mnFile1.Caption := '1 ' + MenuString(MRUList[0].Folder, MRUList[0].Name);
      if mnFile2.Visible
        then mnFile2.Caption := '2 ' + MenuString(MRUList[1].Folder, MRUList[1].Name);
      if mnFile3.Visible
        then mnFile3.Caption := '3 ' + MenuString(MRUList[2].Folder, MRUList[2].Name);
      if mnFile4.Visible
        then mnFile4.Caption := '4 ' + MenuString(MRUList[3].Folder, MRUList[3].Name)
    end
end;

// -- Access to the placement of the main window -----------------------------

function GetMainPlacement : string;
var
  WindowPlacement : TWindowPlacement;
begin
  WindowPlacement.length := sizeof(WindowPlacement);
  GetWindowPlacement(fmMain.Handle, @WindowPlacement);

  if StatusMain.FirstRestore then
    // if form open maximized and never restored, save restore dim
    with WindowPlacement.rcNormalPosition do
      begin
        Left   := NthInt(StatusMain.fmMainPlace,  7, ',');
        Top    := NthInt(StatusMain.fmMainPlace,  8, ',');
        right  := NthInt(StatusMain.fmMainPlace,  9, ',');
        bottom := NthInt(StatusMain.fmMainPlace, 10, ',');
      end;

  with WindowPlacement do
    begin
      Result := Format('%u,%u,%d,%d,%d,%d,%d,%d,%d,%d,%d',
                       [flags, showCmd,
                        ptMinPosition.X,
                        ptMinPosition.Y,
                        ptMaxPosition.X,
                        ptMaxPosition.Y,
                        rcNormalPosition.Left,
                        rcNormalPosition.Top,
                        rcNormalPosition.Right,
                        rcNormalPosition.Bottom,
                        fmMain.ActiveViewBoard.frViewBoard.pnImage.Width])
    end
end;

// Sizing of main window when starting

procedure SetMainPlacement(s : string; var maximized : boolean);
var
  r : TRect;
  h, w, xl, xr, yt, yb : integer;
begin
  if s = '' then
    begin
      // no placement stored, initialize to 5/6 of the screen
      r := Screen.WorkAreaRect;
      h := r.Bottom - r.Top ;
      w := r.Right  - r.Left;
      fmMain.SetBounds(round(w / 12),
                        round(h / 12),
                        round(5 * w / 6),
                        round(5 * h / 6));
      Maximized := False;
      exit
    end;

  maximized := UINT(NthInt(s, 2, ',')) = SW_SHOWMAXIMIZED;

  if maximized then
    begin
      r := Screen.WorkAreaRect;
      fmMain.SetBounds(-4, -4, r.Right + 8, r.Bottom + 8)
    end
  else
    begin
      xl := NthInt(s,  7, ',');
      yt := NthInt(s,  8, ',');
      xr := NthInt(s,  9, ',');
      yb := NthInt(s, 10, ',');
      fmMain.SetBounds(xl, yt, xr - xl + 0, yb - yt + 0)
    end
end;

// -- Sounds -----------------------------------------------------------------

procedure PlayStoneSound(isEngineMove : boolean = False);
begin
  if not isEngineMove
    then DragoPlaySound(sStone)
    else DragoPlaySound(sEngineMove)
end;

function SoundString(sound : TSound) : string;
begin
  case sound of
    sStone      : Result := Settings.SoundStone;
    sInvMove    : Result := Settings.SoundInvMove;
    sEngineMove : Result := Settings.SoundEngineMove;
  end
end;

procedure DragoPlaySound(sound : TSound);
begin
  DragoPlaySound(sound, SoundString(sound))
end;

procedure DragoPlaySound(sound : TSound; soundName : string);
var
  resource  : boolean;
begin
  if (not Settings.EnableSounds) or (soundName = 'None')
    then exit;

  resource := soundName = 'Default';

  case sound of
    sStone   : soundName := iff(resource, 'CLICK'  , soundName);
    sInvMove : soundName := iff(resource, 'INVMOVE', soundName);
    sEngineMove : soundName := iff(resource, 'CLICK', soundName);
  end;

  if resource
    then PlaySound(PAnsiChar(soundName), HInstance, SND_RESOURCE or SND_SYNC)
    else PlaySound(PAnsiChar(soundName), 0, SND_SYNC or SND_NODEFAULT);

  Application.ProcessMessages
end;

// ---------------------------------------------------------------------------

procedure ConvertRelativePathsToAbsolute;
var
  i : integer;
begin
  for i := 0 to Settings.MRUList.Count - 1 do
    begin
      Settings.MRUList[i].Folder := AppAbsolutePath(Settings.MRUList[i].Folder);
      Settings.MRUList[i].Name   := AppAbsolutePath(Settings.MRUList[i].Name);
    end;

  Settings.GameInfoPaneImgDir  := AppAbsolutePath(Settings.GameInfoPaneImgDir);
  Settings.WinBackground.Image := AppAbsolutePath(Settings.WinBackground.Image);
  Settings.BoardBack.Image     := AppAbsolutePath(Settings.BoardBack.Image);
  Settings.BorderBack.Image    := AppAbsolutePath(Settings.BorderBack.Image);
  Settings.TreeBack.Image      := AppAbsolutePath(Settings.TreeBack.Image);
  Settings.DBOpenFolder        := AppAbsolutePath(Settings.DBOpenFolder);
  Settings.DBAddFolder         := AppAbsolutePath(Settings.DBAddFolder);
  Settings.CustomBlackPath     := AppAbsolutePath(Settings.CustomBlackPath);
  Settings.CustomWhitePath     := AppAbsolutePath(Settings.CustomWhitePath);

  if (Settings.SoundStone <> '') and (Settings.SoundStone <> 'Default')
    then Settings.SoundStone := AppAbsolutePath(Settings.SoundStone);
  if (Settings.SoundInvMove <> '') and (Settings.SoundInvMove <> 'Default')
    then Settings.SoundInvMove  := AppAbsolutePath(Settings.SoundInvMove);
  if (Settings.SoundEngineMove <> '') and (Settings.SoundEngineMove <> 'Default')
    then Settings.SoundEngineMove := AppAbsolutePath(Settings.SoundEngineMove);
end;

procedure ConvertAbsolutePathsToRelative;
var
  i : integer;
begin
  for i := 0 to Settings.MRUList.Count - 1 do
    begin
      Settings.MRUList[i].Folder := AppRelativePath(Settings.MRUList[i].Folder);
      Settings.MRUList[i].Name   := AppRelativePath(Settings.MRUList[i].Name);
    end;

  Settings.GameInfoPaneImgDir  := AppRelativePath(Settings.GameInfoPaneImgDir);
  Settings.WinBackground.Image := AppRelativePath(Settings.WinBackground.Image);
  Settings.BoardBack.Image     := AppRelativePath(Settings.BoardBack.Image);
  Settings.BorderBack.Image    := AppRelativePath(Settings.BorderBack.Image);
  Settings.TreeBack.Image      := AppRelativePath(Settings.TreeBack.Image);
  Settings.DBOpenFolder        := AppRelativePath(Settings.DBOpenFolder);
  Settings.DBAddFolder         := AppRelativePath(Settings.DBAddFolder);
  Settings.CustomBlackPath     := AppRelativePath(Settings.CustomBlackPath);
  Settings.CustomWhitePath     := AppRelativePath(Settings.CustomWhitePath);

  if (Settings.SoundStone <> '') and (Settings.SoundStone <> 'Default')
    then Settings.SoundStone := AppRelativePath(Settings.SoundStone);
  if (Settings.SoundInvMove <> '') and (Settings.SoundInvMove <> 'Default')
    then Settings.SoundInvMove  := AppRelativePath(Settings.SoundInvMove);
  if (Settings.SoundEngineMove <> '') and (Settings.SoundEngineMove <> 'Default')
    then Settings.SoundEngineMove := AppRelativePath(Settings.SoundEngineMove);
end;

// ---------------------------------------------------------------------------

end.
