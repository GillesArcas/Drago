// ---------------------------------------------------------------------------
// -- Drago -- User command processing -------------------------- UGCom.pas --
// ---------------------------------------------------------------------------

unit UGcom;

// ---------------------------------------------------------------------------

interface

uses
  Forms, Controls, Classes, DateUtils,
  Types, Windows, Math,
  TntFileCtrl, TntClasses, ClassesEx,
  Define, DefineUi, UViewBoard, UGameColl, UGameTree,
  UView, UViewMain, UFactorization;

// File related commands
procedure LogErrorMessages;
procedure DisplayErrorMessages;
procedure HandleOpenErrorMessage(strings : array of WideString);
function  IsOpenInTab    (const path, fileName : WideString;
                          out modified : boolean) : integer;
procedure UserMainNewFile(sameTab : boolean);
procedure DoMainNewFile  (sameTab : boolean; isEngineGame : boolean = False);
procedure DoMainNewDefaultFile(sameTab : boolean);
procedure UserSaveFile   (view : TViewMain; var cancel : boolean);
procedure UserSaveAs     (view : TViewMain; var cancel : boolean);
procedure UserMainSaveAsSwitch (var cancel : boolean);
procedure AskForSaving   (view : TViewMain; var cancel : boolean);
procedure SaveOrCancel   (view : TViewMain; var cancel : boolean);
procedure DoMainOpenFile (aName : WideString;
                          num : integer;
                          node : string;
                          sameTab : boolean;
                          var ok : boolean;
                          anonym : boolean = False); overload;
procedure DoMainOpenFile (aName : WideString; num : integer; node : string); overload;
procedure DoReloadCurrentFile;
procedure UserMainOpenFile(sameTab : boolean);
procedure DoMainOpenFolder(aFolder : WideString;
                           num : integer; // index of game, last file name missing
                           node : string;  // path in gtree
                           sameTab : boolean;
                           var ok : boolean); overload;
procedure DoMainOpenFolder(aFolder : WideString; index : integer; node : string); overload;
procedure UserMainOpenFolder(sameTab : boolean);
procedure DoMainOpen      (const aFolder, aName : WideString;
                           aIndex : integer;
                           const aPath : string;
                           sameTab : boolean;
                           var ok : boolean); overload;
procedure DoMainOpen      (const aFolder, aName : WideString;
                           aIndex : integer;
                           const aPath : string); overload;
procedure DoMainOpen      (const aName : WideString); overload;
procedure DoOpenFromClipBoard;
procedure DoSaveToClipBoard;
procedure DoMainAppendTo;
procedure DoMainMergeFiles;
procedure DoMainExtractOne;
procedure DoMainExtractAll;
procedure DoRemoveCurrentGame;
procedure DoFactorizeCollection(cl : TGameColl;
                                onStep : TCallBackInt;
                                onError : TCallBackStr;
                                depth, nbUnique : integer;
                                tewari : boolean); overload;
procedure DoFactorizeCollection(fileList : TWideStringList;
                                onStep : TCallBackInt;
                                onError : TCallBackStr;
                                depth, nbUnique : integer;
                                tewari : boolean); overload;
procedure UserMainCloseFile;
procedure UserMainCloseAll;
procedure VerifyAndSaveAllViews(var cancel : boolean);
procedure DoMainQuit;
procedure UserQuickSearch;        

// View related commands
procedure ReferenceView;
procedure ComposeCurrentTransform(tr : TCoordTrans);
procedure SwapColor;

procedure UserGotoMove  (view : TViewBoard);
procedure NextMoveRnd   (view : TViewBoard);
procedure GotoVar       (view : TViewBoard; index : integer);
procedure ShowNextOrVars(view : TViewBoard; mode : integer);
procedure DoGoToNode    (view : TViewBoard; gtTarget : TGameTree);
procedure GobanMouseDown(view : TViewBoard;
                         X, Y : integer;
                         Button : TMouseButton;
                         Shift : TShiftState = []);
procedure GobanMouseMove(view : TViewBoard;
                         X, Y : integer;
                         Button : TMouseButton;
                         Shift : TShiftState = []);
procedure GobanMouseUp  (view : TViewBoard;
                         X, Y : integer;
                         Button : TMouseButton;
                         Shift : TShiftState = []);

procedure DoPointerUp   (view : TViewBoard);
procedure DoPointerDown (view : TViewBoard);
procedure DoPointerLeft (view : TViewBoard);
procedure DoPointerRight(view : TViewBoard);

// Edit related commands
procedure ClickOnBoard   (view : TViewBoard;
                          i, j : integer;
                          Button : TMouseButton;
                          Shift : TShiftState = []);
procedure InputNodeName  (view : TViewBoard);
procedure InputComments  (view : TViewBoard);
procedure InputFigure    (view : TViewBoard);
procedure DoCurrentMarkup(view : TViewBoard);

// Tool commands

procedure DoEnterJosekiTutor(var view : TViewBoard; path : string; trans : TCoordTrans);
procedure DoCloseJosekiTutor(view : TViewBoard);
procedure DoEnterFusekiTutor(var view : TViewBoard; path : string; trans : TCoordTrans);
procedure DoScoreEstimate   (view : TViewBoard);
procedure DoSuggestMove     (view : TViewBoard);
procedure DoInfluenceRegions(view : TViewBoard);
procedure DoGroupStatus     (view : TViewBoard; i, j : integer);

function  PatternSearchMode : TPatternSearchMode; overload;
function  PatternSearchMode(view : TView) : TPatternSearchMode; overload;

var
  // todo : avoid global
  iCurrent, jCurrent, iStart, jStart : integer;

// ---------------------------------------------------------------------------

implementation

uses
  Dialogs, //debug
  SysUtils, SysUtilsEx, StrUtils, Clipbrd,
  Std, Translate, Ux2y, Properties, Ustatus, UApply, Main, UMainUtil, UfmNew,
  GameUtils, SgfIo,
  UfmLabel, BoardUtils, UGmisc, UEngines, UfmMsg, UTreeView,
  UfmExtract, UfmExportPos,
  UAutoReplay, UfmFreeH, UInputQueryInt, WinUtils, UActions,
  UfmUserSaveFolder, UDatabase, UfmDBSearch,
  UProblems, UDialogs, ViewUtils;

// -- Forwards ---------------------------------------------------------------

procedure DoNewFileFreeHandicapCallBack(view : TViewBoard); forward;
procedure GameEditClick(view : TViewBoard; i, j : integer; Button : TMouseButton; Shift : TShiftState);  forward;
procedure GameEditSingleClick(view : TViewBoard; i, j : integer); forward;
procedure GameEditCtrlClick(view : TViewBoard; i, j : integer); forward;
procedure GameEditClickOnStone(view : TViewBoard; i, j : integer); forward;
procedure InputABWE(view : TViewBoard; i, j, what : integer); forward;
procedure InputMarkup(view : TViewBoard; i, j : integer; pr : TPropId); forward;
procedure InputLetter(view : TViewBoard; i, j : integer); forward;
procedure InputMoveNumber(view : TViewBoard; i, j : integer); forward;
procedure IntersectionTutor(view : TViewBoard; i, j : integer); forward;

// == File related commands ==================================================

// -- Helpers ----------------------------------------------------------------

// -- Should the file be saved?

function ShouldBeSaved(view : TViewMain) : boolean;
begin
  with view do
    Result := (not si.FileSave) and (not Status.PlGame)
              or (Status.PlGame and Settings.PlAskForSave)
end;

// -- Ask for file saving to user

procedure AskForSavingFile(view : TViewMain; var cancel : boolean);
var
  name, s : WideString;
  x : integer;
begin
  cancel := False;

  if view.si.ReadOnly
    then exit;

  if ShouldBeSaved(view) then
    begin
      // find tab name
      if view.si.FileName <> ''
          then name := UTF8Decode(view.si.FileName)
          else
            begin
              name := (view.TabSheet as TTabSheetEx).Caption;
              // delete star at end of tab name
              name := Copy(name, 1, Length(name) - 1)
            end;

      s := WideFormat(U('Save changes in %s?'), [name]);
      x := MessageDialog(msYesNoCancel, imQuestion, [s]);

      case x of
          mrYes    : if view.si.FileName <> ''
                       then UserSaveFile(view, cancel)
                       else UserSaveAs  (view, cancel);
          mrNo     : ; // nothing to do
          mrCancel : cancel := True
      end
    end
end;

// -- Ask for folder saving to user

procedure AskForSavingFolder(view : TViewMain; var cancel : boolean);
var
  i, result : integer;
  list : TWideStringList;
begin
  cancel := False;

  if view.si.ReadOnly
    then exit;

  // create list of modified files in the folder
  list := TWideStringList.Create;
  for i := 1 to view.cl.Count do
    if view.cl.FTree[i].Modified
      then list.Add(view.cl.FileName[i]);

  if list.Count = 0
    then // nop: no file modified
    else
      begin
        TfmUserSaveFolder.Execute(view, list, result);
        Sleep(100);
        //fmMain.Update;
        Application.ProcessMessages;
        cancel := result = mrCancel
      end;

  list.Free
end;

// -- Switch between saving file and saving folder

procedure AskForSaving(view : TViewMain; var cancel : boolean);
begin
  if view.si.FolderName = ''
    then AskForSavingFile(view, cancel)
    else AskForSavingFolder(view, cancel)
end;

// -- Ask for saving to user, cancel if not saved

procedure SaveOrCancel(view : TViewMain; var cancel : boolean);
var
  x : integer;
  s : WideString;
begin
  cancel := False;

  if (view.si.FileName = '') or (not view.si.FileSave) then
    begin
      if view.si.FileName = ''
        then s := U('Game with no name. Save to proceed.')
        else s := U('File not saved. Save to proceed.');

      x := view.MessageDialog(msOkCancel, imExclam, [s]);
      case x of
        mrOk : if view.si.FileName <> ''
                  then UserSaveFile(view, cancel)
                  else UserSaveAs  (view, cancel);
        mrCancel : cancel := True
      end
    end
end;

// -- Ask for saving for all tabs

procedure VerifyAndSaveAllViews(var cancel : boolean);
var
  i : integer;
  view : TViewMain;
begin
  for i := 0 to fmMain.PageCount - 1 do
    begin
      view := fmMain.Pages[i].TabView;

      AskForSaving(view, cancel);
      if cancel
          then exit
    end;

  cancel := False
end;

function ActiveView : TViewMain;
begin
  result := fmMain.ActiveView
end;

// Delayed error messages

procedure LogErrorMessages;
begin
  Status.ErrMsgLogged := True;
  Status.ErrMsgLog.Clear
end;

procedure DisplayErrorMessages;
var
  w : TWideStringDynArray;
  i : integer;
begin
  // display open error messages if any
  if Status.ErrMsgLogged and (Status.ErrMsgLog.Count > 0) then
    begin
      Status.ErrMsgLogged := False;
      SetLength(w, Status.ErrMsgLog.Count);
      for i := 0 to Status.ErrMsgLog.Count - 1 do
        w[i] := Status.ErrMsgLog.Strings[i];
      MessageDialog(msOk, imExclam, w)
    end
end;

procedure HandleOpenErrorMessage(strings : array of WideString);
var
  i : integer;
begin
  if Status.ErrMsgLogged
    then
      begin
        if Status.ErrMsgLog.Count > 0
          then Status.ErrMsgLog.Add('');
        for i := 0 to High(strings) do
          Status.ErrMsgLog.Add(strings[i])
      end
    else MessageDialog(msOk, imExclam, strings)
end;

// -- New file command -------------------------------------------------------

// -- New file command in main window, update active view

procedure DoMainNewFile(sameTab : boolean; isEngineGame : boolean = False);
var
  ok : boolean;
  seMode : TStartEvent;
begin
  // lock updates
  LockMainWindow(True);

  try
    if Status.NewInFile
      then // nop
      else
        begin
          if sameTab
            then
              // new file in same tab, free current collection
              begin
                fmMain.SelectView(vmBoard);
                ActiveView.ClearView;
                ActiveView.cl.Clear
              end
            else
              // new file in new tab, make it the active view
              begin
                fmMain.CreateTab(ok);
                if not ok
                  then exit
              end;

          inc(Status.LastEditTab);
          ActiveView.si.GobanNumber := Status.LastEditTab
        end;

    // will avoid to modify panel visibility when creating in same tab
    if sameTab
      then seMode := seMainSameTab
      else seMode := seMain;

    if (not Settings.PlFree) or (Settings.Handicap < 2)
      then
        // no handicap stones or no free handicap
        begin
          ActiveView.CreateEvent;
          ActiveView.StartEvent(seMode)
        end
      else
        // free handicap placement
        begin
          ActiveView.CreateEvent(False);
          ActiveView.StartEvent(seMode);
          TfmFreeH.Execute(ActiveView as TViewBoard, DoNewFileFreeHandicapCallBack)
        end
  finally
    LockMainWindow(False)
  end;

  // select board view
  fmMain.SelectView(vmBoard);

  ActiveView.si.EngineTab := isEngineGame;

  SetTabIcon(ActiveView, mdCrea);

  // enable updates
  //LockMainWindow(False)
end;

// -- Callback from free handicap setting

procedure DoNewFileFreeHandicapCallBack(view : TViewBoard);
begin
  with view do
    begin
      gt.Root.PutProp(prHA, int2pv(Settings.Handicap));
      si.ModeInter := kimGE;
      UpdatePlayer(White)
    end
end;

// -- New file user command in main window, update active view

procedure UserMainNewFile(sameTab : boolean);
var
  cancel : boolean;
begin
  if sameTab then
    begin
      AskForSaving(ActiveView, cancel);
      if cancel
        then exit
    end;

  if TfmNew.Execute = mrCancel
    then exit;

  DoMainNewFile(sameTab)
end;

// -- Create new default file in main window, update active view

procedure DoMainNewDefaultFile(sameTab : boolean);
begin
  Settings.BoardSize := 19;
  Settings.Handicap  := 0;
  Settings.Komi := 0;
  Status.NewInFile := False;
  DoMainNewFile(sameTab)
end;

// -- Open file command ------------------------------------------------------

// -- Is the file already open?

function IsOpenInTab(const path, fileName : WideString;
                     out modified : boolean) : integer;
var
  i : integer;
  view : TView;
begin
  Result := -1;
  if (path = '') and (filename = '')
    then exit;

  for i := 0 to fmMain.PageCount - 1 do
    begin
      view := fmMain.Pages[i].TabView;

      if path = ''
        then
          // open file or db
          begin
            if view.si.FileName = fileName then
              begin
                Result := i;
                modified := not view.si.FileSave;
                exit
              end;
            if view.si.DatabaseName = fileName then
              begin
                Result := i;
                modified := False;
                exit
              end
          end
        else
          // open folder
          if view.si.FolderName = path then
            begin
              Result := i;
              modified := view.cl.IsModified;
              exit
            end
    end
end;

// -- Open file process

procedure DoMainOpenFile(  aName : WideString;
                             num : integer;
                            node : string;
                         sameTab : boolean;
                          var ok : boolean;
                          anonym : boolean = False);
var
  x : TGameColl;
  n, nReadGames, i : integer;
  modified : boolean;
begin
  // anticipate
  ok := True;

  // test if default name for joseki database or whatever
  if aName = '' then
    begin
      ok := False;
      exit
    end;

  // test if already open
  n := IsOpenInTab('', aName, modified);

  if n >= 0 then
    if modified then
      if MessageDialog(msOkCancel, imQuestion,
                       [WideFormat(U('File %s not saved.'), [aName]),
                        U('Reload and lose modifications?')]) = mrCancel
        then exit;

  // read
  x := TGameColl.Create;
  ReadSgf(x, aName, nReadGames,
          Settings.LongPNames, Settings.AbortOnReadError);

  // not read
  if nReadGames = 0 then
    begin
      HandleOpenErrorMessage([U('Error opening file') + ' ' + aName,
                              '> ' + U(ioErrorMsg[sgfResult])]);
      ok := False;
      x.Free;
      exit
    end;

  // warn if incompletely read
  if sgfResult <> 0
    then
      HandleOpenErrorMessage([U('File partialy read') + ' ' + aName,
                              '> ' + U(ioErrorMsg[sgfResult]) + ' - '
                              + U('Line') + ' ' + IntToStr(LineNumber)]);
  // lock updates
  LockMainWindow(True);

  if sameTab
    then fmMain.SelectView(vmBoard)           // necessary to force view as vmBoard, to force
    else                                      // ... LoadTreeView in ActiveView.StartEvent
      if n >= 0                               // ... otherwise displaying tree view in SelectView
        then fmMain.ActivePageIndex := n      // ... can work on uninitialized data
        else fmMain.CreateTab(ok);
  if not ok
    then exit;

  with ActiveView do
    begin
      // free current collection and use read one
      cl.Decant(x);
      x.Free;

      // update game instance
      si.ParentView := ActiveView;
      si.FolderName := '';
      si.FileName   := aName;
      si.IndexTree  := Min(num, cl.Count);
      si.FileSave   := True;
      si.ReadOnly   := False;
      //UpdatePlayer(Black); must be done after LoadTreeView in StartEvent unless NthPropId crash
      si.MainMode   := muNavigation;

      // bind gt
      gt := cl[si.IndexTree];

      // anonymize if required (eg when tmp file read after merge)
      // (avoid displaying filename even when changing event)
      if anonym then
        begin
          inc(Status.LastEditTab);
          ActiveView.si.GobanNumber := Status.LastEditTab;
          
          si.FileName := '';
          for i := 1 to cl.Count do
            cl.FTree[i].FFileName := ''
        end
    end;

  // start
  if sameTab
    then ActiveView.StartEvent(seMainSameTab, snStrict, node)
    else ActiveView.StartEvent(seMain, snStrict, node);

  // invalidate all views in tab and select board view
  fmMain.InvalidateView(vmAll);
  fmMain.SelectView(vmBoard);

  // unlock updates
  LockMainWindow(False);

  if anonym
    then SetTabIcon(ActiveView, mdCrea)
    else SetTabIcon(ActiveView, mdEdit)
end;

procedure DoReloadCurrentFile;
var
  ok : boolean;
begin
  with ActiveView do
    DoMainOpenFile(si.FileName,
                   si.IndexTree,
                   '',
                   True, // sameTab
                   ok)
end;

// -- Opening utility (drag&drop, MRU)

procedure DoMainOpenFile(aName : WideString; num : integer; node : string);
var
  ok : boolean;
begin
  DoMainOpenFile(aName, num, node, False, ok)
end;

// -- Open file user command

procedure UserMainOpenFile(sameTab : boolean);
var
  path, filename : WideString;
  cancel, ok : boolean;
begin
  if sameTab then
    begin
      AskForSaving(ActiveView, cancel);

      if cancel
        then exit;
    end;

  if Status.MRUList.Count = 0
    then path := Status.AppPath
    else path := WideExtractFilePath(Status.MRUList[0].Name);

  ok := OpenDialog('Open', path, '', 'sgf',
                   U('SGF files') + ' (*.sgf)|*.sgf|' +
                   U('MGT files') + ' (*.mgt)|*.mgt|' +
                   U('All files') + ' (*.*)|*.*',
                   filename);
  if not ok
    then exit;

  // protect against clicking on goban during loading
  Status.EnableGobanMouseDn := False;

  // log open error messages
  LogErrorMessages;

  DoMainOpenFile(filename, 1, '', sameTab, ok);

  DisplayErrorMessages;
  
  // process possible clicks on goban in protected context and restore
  Application.ProcessMessages;
  Status.EnableGobanMouseDn := True
end;

// -- Open folder command ----------------------------------------------------

// -- Open folder in main window and update active view

procedure DoMainOpenFolder(aFolder : WideString;
                                num : integer; // index of game
                               node : string;  // path in gtree
                            sameTab : boolean;
                             var ok : boolean);
var
  list : TWideStringList;
  x : TGameColl;
  n, nReadGames, i : integer;
  modified : boolean;
begin
  // anticipate
  ok := True;

  // test if default name for joseki database or whatever
  if aFolder = '' then
    begin
      ok := False;
      exit
    end;

  // test if already open
  n := IsOpenInTab(aFolder, '', modified);

  if n >= 0 then
    if modified then
      if MessageDialog(msOkCancel, imQuestion,
                       [WideFormat(U('Folder %s not saved.'), [aFolder]),
                                   U('Reload and lose modifications?')]) = mrCancel
        then exit;

  // alloc and load list of file names
  list := TWideStringList.Create;
  if True // no sub folders
    then WideAddFilesToList(list, aFolder, [afIncludeFiles, afCatPath], '*.sgf')
    else WideAddFolderToList(list, aFolder, '*.sgf', True);

  // alloc temporary collection
  x := TGameColl.Create;
  x.Folder := aFolder;

  // read each file and add it to collection
  for i := 0 to list.Count - 1 do
    begin
      ReadSgfAppend(x, list[i], nReadGames,
                    Settings.LongPNames,
                    Settings.AbortOnReadError, True);

      // warn if read error
      if nReadGames = 0
        then
          HandleOpenErrorMessage([U('Error opening file') + ' ' + list[i],
                                  U(ioErrorMsg[SgfResult])]);
                                   
       // warn if incompletely read
      if (nReadGames <> 0) and (SgfResult <> 0)
        then
          HandleOpenErrorMessage([U('File partialy read') + ' '+ list[i],
                                  U(ioErrorMsg[SgfResult]) + ' - '
                                  + U('Line') + ' ' + IntToStr(LineNumber)]);
    end;

  list.Free;
  
  if x.Count = 0 then
    begin
      x.Free;
      DoMainNewDefaultFile(sameTab);
      exit
    end;

  // lock updates
  LockMainWindow(True);

  if sameTab
    then // nop
    else
      if n >= 0
        then fmMain.ActivePageIndex := n
        else fmMain.CreateTab(ok);

  if not ok
    then exit;

  with ActiveView do
    begin
      // free current collection and use read one
      cl.Decant(x);
      x.Free;

      // update game instance
      si.ParentView := ActiveView;
      si.FolderName := WideIncludeTrailingPathDelimiter(aFolder);
      si.IndexTree  := Min(num, cl.Count);
      si.FileName   := iff(cl.Count = 0, '', cl.FileName[si.IndexTree]);
      si.FFileSave  := True;
      si.ReadOnly   := False;
      UpdatePlayer(Black);
      si.MainMode   := muNavigation;

      // bind gt
      gt := cl[si.IndexTree]
    end;

  // start and select board view
  ActiveView.StartEvent(seMain, snStrict, node);
  fmMain.SelectView(vmBoard);
  SetTabIcon(ActiveView, mdEdit);

  // unlock updates
  LockMainWindow(False)
end;

// -- Open folder user command

procedure UserMainOpenFolder(sameTab : boolean);
var
  cancel, ok : boolean;
  path : WideString;
begin
  if sameTab then
    begin
      AskForSaving(ActiveView, cancel);

      if cancel
        then exit;
    end;

  // protect against clicking on goban during loading
  Status.EnableGobanMouseDn := False;

  if Status.MRUList.Count = 0
    then path := Status.AppPath
    else path := WideExtractFilePath(Status.MRUList[0].Name);

  // log open error messages
  LogErrorMessages;

  if WideSelectDirectory(U('Open folder'), '', path)
    then DoMainOpenFolder(path, 1, '', sameTab, ok);

  DisplayErrorMessages;

  // process possible clicks on goban in protected context and restore
  Application.ProcessMessages;
  Status.EnableGobanMouseDn := True
end;

// -- Opening utility (MRU)

// not used
procedure DoMainOpenFolder(aFolder : WideString; index : integer; node : string);
var
  ok : boolean;
begin
  LogErrorMessages;
  DoMainOpenFolder(aFolder, index, node, False, ok);
  DisplayErrorMessages
end;

// -- Opening switch

procedure DoMainOpen(const aFolder, aName : WideString;
                     aIndex : integer;
                     const aPath : string;
                     sameTab : boolean;
                     var ok : boolean);
begin
  if aFolder = ''
    then
      if WideExtractFileExt(aName) = '.db'
        then DoMainOpenDatabase(aName, aIndex, aPath, sameTab, ok)
        else DoMainOpenFile(aName, aIndex, aPath, sameTab, ok)
    else
      DoMainOpenFolder(aFolder, aIndex, aPath, sameTab, ok)
end;

procedure DoMainOpen(const aFolder, aName : WideString;
                     aIndex : integer;
                     const aPath : string);
var
  ok : boolean;
begin
  DoMainOpen(aFolder, aName, aIndex, aPath, False, ok)
end;

procedure DoMainOpen(const aName : WideString);
var
  ok : boolean;
begin
  if DirectoryExists(aName)
    then DoMainOpen(aName, '', 1, '', False, ok)
    else DoMainOpen('', aName, 1, '', False, ok)
end;

// -- Save commands ----------------------------------------------------------

// -- User saving command

procedure UserSaveFile(view : TViewMain; var cancel : boolean);
begin
  if view.si.FileName = ''
    then UserSaveAs(view, cancel)
    else
      if view.cl.Folder = ''
        // file has been open from single file
        then DoSaveFile(view, view.si.FileName, ioRewrite, cancel)
        // file has been open from folder, save matching filename
        else DoSaveFile(view, view.si.FileName, ioRewrite, cancel, True)
end;

// -- User saving as command

procedure DoSaveAs(view : TViewMain; var filename : WideString; var cancel : boolean);
var
  ok : boolean;
begin
  ok := SaveDialog('Save tab content as',
                   WideExtractFilePath(filename),
                   WideExtractFileName(filename),
                   'sgf',
                   U('SGF files') + ' (*.sgf)|*.sgf',
                   True,
                   filename);

  cancel := not ok;

  if ok
    then DoSaveFile(view, filename, ioRewrite, cancel)
end;

// called from sgf file

procedure UserSaveAs(view : TViewMain; var cancel : boolean);
var
  filename : WideString;
begin
  filename := view.si.FileName;
  DoSaveAs(view, filename, cancel);
  if cancel
    then exit
    else cancel := False;

  view.si.FileSave  := True;
  view.si.FileName  := filename;
  view.si.IndexTree := view.si.IndexTree // to save Game# in .ini
end;

// called from folder or db

procedure UserMainSaveAsSwitch(var cancel : boolean);
var
  filename : WideString;
begin
  filename := '';
  DoSaveAs(ActiveView, filename, cancel);
  if cancel
    then exit
    else cancel := False;

  DoMainOpenFile(filename, 1, '')
end;

// -- Clipboard --------------------------------------------------------------

procedure DoOpenFromClipBoard;
var
  ok : boolean;
begin
  if ClipBoard.HasFormat(CF_TEXT) then
    begin
      StringToFile(Status.TmpPath + '\tmp.sgf', ClipBoard.AsText);
      DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, '', False, ok, True);
      ActiveView.si.FileSave := False
    end
end;

procedure DoSaveToClipBoard;
begin
  // save the current game, not the current tab
  ClipBoard.AsText := TreeToString(ActiveView.gt)
end;

// -- Collection commands ----------------------------------------------------

// -- Append to file in main window and update active view

procedure DoMainAppendTo;
var
  fname : WideString;
  n, k  : integer;
  modified, cancel, ok : boolean;
begin
  // select target file
  if SaveDialog('Append to',
                WideExtractFilePath(ActiveView.si.FileName),
                '',
                'sgf',
                U('SGF files') + ' (*.sgf)|*.sgf',
                False,
                fname)
    then
    else exit;

  // verify if target file is loaded and modified
  n := IsOpenInTab('', fname, modified);

  if (n >= 0) and modified then
    begin
      AskForSaving(fmMain.Pages[n].TabView, cancel);
      if cancel
        // aborted by user or system
          then exit
    end;

  LockMainWindow(True);

  k := ActiveView.cl.Count - ActiveView.si.IndexTree;
  PrintSGF(ActiveView.cl, fname, ioAppend, Settings.CompressList, Settings.SaveCompact);
  ActiveView.si.FileSave  := True;
  fmMain.CloseTab;  //!!!
  DoMainOpenFile(fname, 1, '', False, ok);
  ActiveView.ChangeEvent(ActiveView.cl.Count - k);

  LockMainWindow(False)
end;

// -- Merge files in main window and update active view

procedure DoMainMergeFiles;
var
  cancel, ok : boolean;
  names, listOneW : TTntStringList;
  listAll, listOne : TStringList;
  i : integer;
begin
  AskForSaving(ActiveView, cancel);
  if cancel
    then exit;

  names    := TTntStringList.Create;
  listOneW := TTntStringList.Create;
  listAll  := TStringList.Create;
  listOne  := TStringList.Create;
  names.Sorted := True;
  names.Clear;

  ok := OpenDialog('Merge... Select files',
                   WideExtractFilePath(ActiveView.si.FileName),
                   '', 'sgf', U('SGF files') + ' (*.sgf)|*.sgf',
                   names);
  try
    if not ok
      then exit;

    for i := 0 to names.Count - 1 do
      begin
        // read 1st sgf with tntstringlist as names may be Unicode
        listOneW.LoadFromFile(names[i]);
        // copy to ansi stringlist
        listOne.Assign(listOneW);
        // add to list of all games
        listAll.AddStrings(listOne)
      end;

    listAll.SaveToFile(Status.TmpPath + '\tmp.sgf');
    DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, '', False, ok, True);
    ActiveView.si.FileSave := False;
  finally
    names.Free;
    listAll.Free;
    listOne.Free;
    listOneW.Free
  end
end;

// -- Extract current game in main window and update active view

procedure DoMainExtractOne;
var
  ok : boolean;
begin
  PrintWholeTree(Status.TmpPath + '\tmp.sgf', ActiveView.gt,
                 Settings.CompressList, Settings.SaveCompact);
  DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, '', False, ok, True);
  ActiveView.si.FileSave := False
end;

// -- Extract all command

procedure DoMainExtractAll;
var
  cancel : boolean;
  rootstr, name : WideString;
  i : integer;
begin
  AskForSaving(ActiveView, cancel);
  if cancel
    then exit;

  if not GetRoot(ActiveView.si.FileName,
                 'Extract all...', 'sgf',
                 rootstr)
    then exit;

  Application.ProcessMessages;

  for i := 1 to ActiveView.cl.Count do
    begin
      // TODO: check unicode filename
      name := WideFormat('%s%4.4d.sgf', [rootstr, i - 1]);
      PrintWholeTree(UTF8Encode(name), ActiveView.cl[i],
                     Settings.CompressList, Settings.SaveCompact)
    end
end;

// -- Remove game in file

procedure DoRemoveCurrentGame;
begin
  if ActiveView.cl.Count = 1
    then ActiveView.MessageDialog(msOk, imExclam, [U('Unable to remove game in single game collection.')])
    else
      if ActiveView.MessageDialog(msOkCancel, imQuestion, [U('Remove current game.'),
                                                            U('Do you want to proceed?')]) = mrCancel
        then // nop
        else
          begin
            if ActiveView.si.IndexTree = ActiveView.cl.Count
              then
                begin
                  ActiveView.DoPrevGame;
                  ActiveView.cl.Delete(ActiveView.cl.Count);
                end
              else
                begin
                  ActiveView.cl.Delete(ActiveView.si.IndexTree);
                  ActiveView.ChangeEvent(ActiveView.si.IndexTree);
                end;

            ActiveView.si.FileSave := False;
            fmMain.SelectView(ActiveView.si.ViewMode)
          end
end;

// -- Factorize

procedure DoFactorizeCollection(cl : TGameColl;
                                onStep : TCallBackInt;
                                onError : TCallBackStr;
                                depth, nbUnique : integer;
                                tewari : boolean); overload;
var
  ok : boolean;
  clOut : TGameColl;
begin
  clOut := TGameColl.Create;
  CollectionFactorization(cl, clOut, depth, nbUnique, False, onStep, onError);
  PrintSGF(clOut, Status.TmpPath + '\tmp.sgf', ioRewrite, False, False);
  clOut.Free;

  DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, '', False, ok, True);
  ActiveView.si.FileSave := False
end;

procedure DoFactorizeCollection(fileList : TWideStringList;
                                OnStep : TCallBackInt;
                                OnError : TCallBackStr;
                                depth, nbUnique : integer;
                                tewari : boolean); overload;
var
  ok : boolean;
  clOut : TGameColl;
begin
  clOut := TGameColl.Create;
  CollectionFactorization(fileList, clOut, depth, nbUnique, False, onStep, onError);
  PrintSGF(clOut, Status.TmpPath + '\tmp.sgf', ioRewrite, False, False);
  clOut.Free;

  DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, '', False, ok, True);
  ActiveView.si.FileSave := False
end;

// -- Close command

procedure UserMainCloseFile;
var
  cancel : boolean;
begin
  AskForSaving(ActiveView, cancel);
  if cancel
    then exit;

  try
    LockMainWindow(True);
    if fmMain.PageCount = 1
      then DoMainNewDefaultFile(True)
      else fmMain.CloseTab;
  finally
     LockMainWindow(False)
  end
end;

// -- Close all command

procedure UserMainCloseAll;
var
  i : integer;
begin
  LockMainWindow(True);

  for i := fmMain.PageCount - 1 downto 0 do
    begin
      fmMain.ActivePage := fmMain.Pages[i];

      UserMainCloseFile
    end;

  LockMainWindow(False)
end;

// -- Quit command

procedure DoMainQuit;
begin
  fmMain.Close
end;

// == View commands ==========================================================

procedure ReferenceView;
begin
  fmMain.ActiveView.gb.CoordTrans := trIdent;
  fmMain.ActiveView.gb.BoardView.CoordTrans := trIdent;
  fmMain.ActiveView.gb.Draw
end;

procedure ComposeCurrentTransform(tr : TCoordTrans);
begin
  fmMain.ActiveView.gb.CoordTrans := Compose(fmMain.ActiveView.gb.CoordTrans, tr);
  fmMain.ActiveView.gb.BoardView.CoordTrans := fmMain.ActiveView.gb.CoordTrans;
  fmMain.ActiveView.gb.Draw
end;

procedure SwapColor;
begin
  with fmMain.ActiveView do
    begin
      if gb.ColorTrans = ctIdent
        then gb.ColorTrans := ctReverse
        else gb.ColorTrans := ctIdent;
    end;

  fmMain.ActiveView.StartDisplay(snStrict, fmMain.ActiveView.gt.StepsToNode);
  TV_Refresh(fmMain.ActiveView as TViewBoard)
end;

// == Navigation commands ====================================================

// -- Navigation in game -----------------------------------------------------

// -- Navigation from move to move -------------------------------------------

procedure DoGoToNode(view : TViewBoard; gtTarget : TGameTree);
begin
  case view.si.ModeInter of
    kimRG, kimEG :
      begin
        view.si.CurrLastMove := view.gb.MoveNumber;
        view.si.ModeInter := iff(view.si.ModeInter = kimRG, kimRGR, kimEGR);
        Actions.acNextMove.Enabled := True;
        Actions.acEndPos.Enabled := True;
      end;
    kimRGR, kimEGR :
      begin
        if gtTarget.Number = view.si.CurrLastMove then
          begin
            view.si.ModeInter := iff(view.si.ModeInter = kimRGR, kimRG, kimEG);
            Actions.acNextMove.Enabled := False;
            Actions.acEndPos.Enabled := False
          end
      end;
  end;

  view.GoToNode(gtTarget);
  //view.GoToMove(Status.LastGotoMove, not kLastQuiet);

  case view.si.ModeInter of
    kimAR :
      begin
        view.AutoReplayNext := Now;
        AutoReplaySetTimer(view)
      end
  end
end;

// -- Traversing of a game tree following a path -----------------------------

function FollowPath(gt, path : TGameTree) : TGameTree;
var
  pv : string;
  x : TGameTree;
begin
  Result := gt;

  if (path.NextNode = nil) or (gt.NextNode = nil)
    then exit;

  gt := gt.NextNode;
  path := path.NextNode;

  pv := path.GetProp(prB);
  if pv <> '' then
    begin
      x := gt;
      while (x <> nil) and (x.GetProp(prB) <> pv) do
        x := x.NextVar;
      if x <> nil then
        begin
          Result := FollowPath(x, path);
          exit
        end
    end;
  pv := path.GetProp(prW);
  if pv <> '' then
    begin
      x := gt;
      while (x <> nil) and (x.GetProp(prW) <> pv) do
        x := x.NextVar;
      if x <> nil then
        begin
          Result := FollowPath(x, path);
          exit
        end
    end;
  Result := gt
end;

procedure DoFollowPath(view : TViewBoard; path : TGameTree);
var
  gtTarget : TGameTree;
begin
  assert(False, 'Just to find out where it comes from...');
  
  view.gt := view.gt.Root;
  gtTarget := FollowPath(view.gt, path);

  // if ever it is used, check if GoToNode or DoGoToNode required ...
  view.GoToNode(gtTarget)
end;

// -- Select move by number

procedure UserGotoMove(view : TViewBoard);
var
  n : integer;
begin
  n := Status.LastGotoMove;
  if not InputQueryInt(AppName + ' - ' + U('Go to move'),
                        U('Number'), n)
    then exit;
  Status.LastGotoMove := n;

  view.GoToMove(Status.LastGotoMove, not kLastQuiet);
  TV_UpdateView(view)
end;

// -- Random move

procedure NextMoveRnd(view : TViewBoard);
begin
  ApplyNode(view, Leave);
  view.gt := SelectNextMovePropDyn{Equi}(view.gt);
  ApplyNode(view, Enter)
end;

// -- Selection in the list of variations

procedure GotoVar(view : TViewBoard; index : integer);
var
  x : TGameTree;
  n : integer;
begin
  if Status.VarStyle = vsChildren then
    begin
      x := view.gt.NextNode;
      if x = nil
        then exit;
      n := 1;
      while n < index do
        begin
          x := x.NextVar;
          inc(n)
        end;
      ApplyNode(view, Leave);
      view.gt := x;
      ApplyNode(view, Enter)
    end;

  if Status.VarStyle = vsSibling then
    begin
      x := view.gt.FirstVar;
      n := 1;
      while n < index do
        begin
          x := x.NextVar;
          inc(n)
        end;
      ApplyNode(view, Undo);
      view.gt := x;
      ApplyNode(view, Enter)
    end;

  TV_UpdateView(view)
end;

// -- Variation display handling ---------------------------------------------

// -- Clear variations on board and listbox

procedure VarClear(view : TViewBoard; varStyle : TVarStyle);
begin
  view.frViewBoard.frVariations.VarClear(varStyle);
  UGMisc.VarClear(view.gb, view.si)
end;

// -- Add an item to the listbox of variations

procedure VarAdd(view : TViewBoard;
                 x : TGameTree;
                 mode, n, player, i, j : integer;
                 selected : boolean = False);
begin
  if (mode = Enter) or (mode = Redo)
    then view.frViewBoard.frVariations.VarAdd(VarString(n, player, i, j, view.gb, x, view.si),
                                              selected)
end;

// -- Display of following moves (children style)

procedure ShowNext(view : TViewBoard; mode : integer);
var
  x : TGameTree;
  player, i, j, n : integer;
begin
  if view.gb.Silence or (view.gt = nil)
    then exit;

  VarClear(view, vsChildren);
  x := view.gt.NextNode;

  if x = nil then
    begin
      VarAdd(view, x, mode, 0, 0, 0, 0);
      exit
    end;

  n := 1;

  while x <> nil do
    begin
      x.GetMove(player, i, j);
      player := ColorTransform(player, view.gb.ColorTrans);
      DisplayVarMarkup(view.gb, view.si, mode, n, player, i, j);
      VarAdd(view, x, mode, n, player, i, j);
      inc(n);
      x := x.NextVar
    end
end;

// -- Display of the variations of the current move (sibling style)

procedure ShowVars(view : TViewBoard; mode : integer);
var
  x : TGameTree;
  player, i, j, n : integer;
begin
  if view.gb.Silence or (view.gt = nil)
    then exit;

  VarClear(view, vsSibling);
  x := view.gt.FirstVar;
  n := 1;

  while x <> nil do
    begin
      x.GetMove(player, i, j);
      player := ColorTransform(player, view.gb.ColorTrans);

      if x <> view.gt
        then DisplayVarMarkup(view.gb, view.si, mode, n, player, i, j);

      if x <> view.gt
        then VarAdd(view, x, mode, n, player, i, j)
        else VarAdd(view, x, mode, n, player, i, j, True);

      x := x.NextVar;
      inc(n)
    end
end;

// -- Entry point

procedure ShowNextOrVars(view : TViewBoard; mode : integer);
begin
  case Status.VarStyle of
    vsChildren : ShowNext(view, mode);
    vsSibling  : ShowVars(view, mode)
  end
end;

// -- Moves of pointer on go board -------------------------------------------

// -- Moving the pointer device relatively to its current position

procedure MoveRelPointer(view : TViewBoard; deltaI, deltaJ : integer);
var
  where : TPoint;
  i, j : integer;
begin
  with view do
    begin
      where := frViewBoard.imGoban.ScreenToClient(Mouse.CursorPos);
      gb.xy2ij(where.x, where.y, i, j);
      inc(i, deltaI);
      inc(j, deltaJ);
      i := EnsureRange(i, gb.iMinView, gb.iMaxView);
      j := EnsureRange(j, gb.jMinView, gb.jMaxView);
      gb.ij2xy(i, j, where.x, where.y);
      Mouse.CursorPos := frViewBoard.imGoban.ClientToScreen(where)
    end
end;

// -- Commands

procedure DoPointerUp(view : TViewBoard);
begin
  MoveRelPointer(view, -1, 0)
end;

procedure DoPointerDown(view : TViewBoard);
begin
  MoveRelPointer(view, 1, 0)
end;

procedure DoPointerLeft(view : TViewBoard);
begin
  MoveRelPointer(view, 0, -1)
end;

procedure DoPointerRight(view : TViewBoard);
begin
  MoveRelPointer(view, 0, 1)
end;

// == Database commands ======================================================

var
  iMinQuickSearch, iMaxQuickSearch,
  jMinQuickSearch, jMaxQuickSearch : integer;

function PatternSearchMode : TPatternSearchMode; 
begin
  if PatternSearchReady
    then
      if Actions.acQuickSearch.Checked
        then Result := psmQuickSearchDBWindow
        else Result := psmButtonSearchDBWindow
    else
      if Actions.acQuickSearch.Checked
        then Result := psmQuickSearchSideBar
        else Result := psmNone
end;

function PatternSearchMode(view : TView) : TPatternSearchMode;
begin
  if PatternSearchReady
    then
      if view.si.DbQuickSearch in [qsOpen, qsReady]
        then Result := psmQuickSearchDBWindow
        else Result := psmButtonSearchDBWindow
    else
      if view.si.DbQuickSearch in [qsOpen, qsReady]
        then Result := psmQuickSearchSideBar
        else Result := psmNone
end;

procedure QuickSearchMsgProc(const s : WideString);
begin
  if Assigned(fmDBSearch) and Assigned(fmDBSearch.frDBPatternPanel)
    then fmDBSearch.ShowStatusMsg(U(s))
    else (ActiveView as TViewBoard).QuickSearchStatusMessage(s)
end;

procedure UserQuickSearch;
begin
  if not (ActiveView is TViewBoard)
    then exit;

  if Assigned(fmDBSearch) and (Assigned(fmDBSearch.frDBRequestPanel) or
                               Assigned(fmDBSearch.frDBSignaturePanel))
    then
      begin
        Actions.acQuickSearch.Checked := False;
        exit
      end;

  //if fmMain.btQuickSearch.Checked
  if Actions.acQuickSearch.Checked
    then (ActiveView as TViewBoard).InitQuickSearch
    else (ActiveView as TViewBoard).ExitQuickSearch
end;

procedure InitQuickSearch;
// btQuickSearch has been checked either in main toolbar or in Search window
begin
  (ActiveView as TViewBoard).InitQuickSearch
end;

procedure ExitQuickSearch;
begin
  (ActiveView as TViewBoard).ExitQuickSearch
end;

procedure QuickSearch(view : TViewBoard);
var
  ok : boolean;
  s : string;
  t0 : double;
  searchGameTree : TGameTree;
  index : integer;
begin
  if fmMain.DBListOfTabs.Top = nil then
    begin
      view.QuickSearchStatusMessage(U('No database loaded'));
      //view.gb.Rectangle(0, 0, 0, 0, False);
      exit
    end;

  ActiveDBTab.TabView.kh.Reset;
  t0 := Now;
(*
  searchGameTree := fmMain.ActiveView.gt.Root.Copy;
  s := fmMain.ActiveView.gt.StepsToNode;
*)
  try
    Screen.Cursor := fmMain.WaitCursor;
    DoPatternSearch(view.gb, ActiveDBTab.TabView.kh,
                    //view.gb.iMinData, view.gb.jMinData,
                    //view.gb.iMaxData, view.gb.jMaxData,
                    //iMinQuickSearch, jMinQuickSearch,
                    //iMaxQuickSearch, jMaxQuickSearch,
                    view.gb.FLastRect.Top, view.gb.FLastRect.Left,
                    view.gb.FLastRect.Bottom, view.gb.FLastRect.Right,
                    NextPlayer(view.gt),
                    QuickSearchMsgProc,
                    ok);
  finally
    Screen.Cursor := crDefault;
  end;
  
  if not ok
    then
      begin
        ActiveDBTab.TabView.kh.Continuations.Clear;
        if Assigned(fmDBSearch) and Assigned(fmDBSearch.frDBPatternPanel)
          then fmDBSearch.frDBPatternPanel.frResults.ClearResults
          else view.frViewBoard.frDBPatternResult.ClearResults
      end
    else
      begin
        try
          searchGameTree := fmMain.ActiveView.gt.Root.Copy;
          s := fmMain.ActiveView.gt.StepsToNode;

          CurrentEntriesToCollection(ActiveDBTab.ViewBoard);

          // if no game found: select info view (better display and update status bar)
          // if selection from database tab: select thumbnail view,
          // if selection from another tab: prepare possible view of the database tab
          if ActiveDBTab.TabView.cl.Count = 0
            then
              if ActiveDBTab.TabView = ActiveView
                then fmMain.SelectView(vmInfo)
                else ActiveDBTab.TabView.si.ViewMode := vmInfo
            else
              if ActiveDBTab.TabView = ActiveView
                then //*// fmMain.SelectView(vmThumb)
                  begin
                    index := FindGameInCollection(searchGameTree, ActiveDBTab.TabView.cl);
                    ActiveDBTab.TabView.si.IndexTree := index;
                    ActiveDBTab.TabView.gt := ActiveDBTab.TabView.cl[index];
                    ActiveDBTab.TabView.GotoNode(ActiveDBTab.TabView.gt.Root.NodeAfterSteps(s));
                  end
                else ActiveDBTab.TabView.si.ViewMode := vmThumb;
        finally
          searchGameTree.FreeGameTree
        end;

       (*
        EndPatternSearch(fmMain.ActiveView, view.gb,
                         view.gb.iMinData, view.gb.jMinData,
                         view.gb.iMaxData, view.gb.jMaxData);
      *)
        ActiveDBTab.TabView.kh.SortContinuations(Settings.DBNextMove);
        if VarMarkup(view.si) = vmGhost
          then view.ShowNextOrVars(Enter);
        DisplayContinuations(view.gb, ActiveDBTab.TabView.kh,
                             //view.gb.iMinData, view.gb.jMinData);
                             //iMinQuickSearch, jMinQuickSearch);
                             Min(iMinQuickSearch, iMaxQuickSearch),
                             Min(jMinQuickSearch, jMaxQuickSearch));
        view.gb.Rectangle(0, 0, 0, 0, True);

        case PatternSearchMode(view) of
          psmQuickSearchDBWindow :
            begin
              fmDbSearch.frDBPatternPanel.frResults.DisplayResults(DBSearchContext.kh);
              s := FormatTimeString(MilliSecondsBetween(t0, Now));
              fmDbSearch.StatusBar.Panels[0].Text := s + ', ' + DbFormatNumberOfResults(DBSearchContext.kh.Size,
                                                                                        DBSearchContext.DBTab.Caption);
            end;
          psmQuickSearchSideBar :
            begin
              view.frViewBoard.frDBPatternResult.DisplayResults(ActiveDBTab.TabView.kh);
              view.QuickSearchStatusMessage(DbFormatNumberOfResults(ActiveDBTab.TabView.kh.Size,
                                                                    ActiveDBTab.Caption))
            end;
          else
            assert(False, 'Debug DBS')
        end;

(*
        CurrentEntriesToCollection(ActiveDBTab.ViewBoard);

        // if no game found: select info view (better display and update status bar)
        // if selection from database tab: select thumbnail view,
        // if selection from another tab: prepare possible view of the database tab
        if ActiveDBTab.TabView.cl.Count = 0
          then
            if ActiveDBTab.TabView = ActiveView
              then fmMain.SelectView(vmInfo)
              else ActiveDBTab.TabView.si.ViewMode := vmInfo
          else
            if ActiveDBTab.TabView = ActiveView
              then //*// fmMain.SelectView(vmThumb)
                begin
                  index := FindGameInCollection(searchGameTree, ActiveDBTab.TabView.cl);
                  ActiveDBTab.TabView.si.IndexTree := index;
                  ActiveDBTab.TabView.gt := ActiveDBTab.TabView.cl[index];
                  ActiveDBTab.TabView.GotoNode(ActiveDBTab.TabView.gt.Root.NodeAfterSteps(s));
                end
              else ActiveDBTab.TabView.si.ViewMode := vmThumb;
*)
      end
end;

procedure EndSearchSelection(view : TViewBoard;
                             iStart, jStart, iCurrent, jCurrent : integer);
begin
  case PatternSearchMode(view) of
    psmQuickSearchDBWindow, psmQuickSearchSideBar :
      begin
        view.si.DbQuickSearch := qsReady;
        iMinQuickSearch := iStart;
        jMinQuickSearch := jStart;
        iMaxQuickSearch := iCurrent;
        jMaxQuickSearch := jCurrent;
        QuickSearch(view)
      end;
    psmButtonSearchDBWindow :
      begin
        DoPrepareSearch(iStart, jStart, iCurrent, jCurrent)
      end;
    else
      assert(False, 'Debug DBS')
  end;
end;

// == Editing commands =======================================================

// -- Set current mark (not used anymore)

procedure DoCurrentMarkup(view : TViewBoard);
begin
  view.si.ModeInter := Settings.LastMarkup;
  //with fmMain do
  //   SendMessage(ToolBar.Handle, TB_PRESSBUTTON, ToolButtonNumber(tbMarkup), 1);
end;

// == Handling of mouse clicks ===============================================

var
  CurrentStatus : integer;
  dragCurrent   : boolean;

// -- Handling of mouse down event -------------------------------------------

procedure GobanMouseDown(view : TViewBoard;
                         X, Y : integer;
                         Button : TMouseButton;
                         Shift : TShiftState = []);
var
  r : TRect;
begin
  with view do
    begin
      if si.ModeInter = kimNOP
        then exit;

      //gb.HideTempMarks;

      // start pattern selection for DB search
      if (PatternSearchMode(view) <> psmNone) and (ssRight in Shift) then
        begin
          // Hide temp marks without hiding wildcards
          //gb.HideTempMarks;
          gb.Draw;
          
          if si.ModeInter <> kimPS
            then si.ModeInterBak := si.ModeInter;
          si.ModeInter := kimPS;

          // limit cursor inside main form
          r := fmMain.BoundsRect;
          r.Top := r.Top + 10;
          r.Right := r.Right - 10;
          ClipCursor(@r);

          // set cross shape cursor
          Screen.Cursor := crZone;
          frViewBoard.imGoban.OnMouseEnter := frViewBoard.imGobanMouseEnter;
          frViewBoard.imGoban.OnMouseLeave := frViewBoard.imGobanMouseLeave
        end;

      // erase possible previous rectangle
      if si.ModeInter in [kimZO, kimPS]
        then gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);

      // exit if not at valid position
      gb.xy2ij(X, Y, iCurrent, jCurrent);
      if not gb.IsBoardCoord(iCurrent, jCurrent)
        then exit;

      iStart := iCurrent;
      jStart := jCurrent;
      dragCurrent := False;

      // start dragging last move
      if (si.ModeInter = kimGE) and
        (gb.Board[iCurrent, jCurrent] <> Empty) and
        (gb.MoveNumber > 0) and
        (gb.GameBoard.TabNum[iCurrent, jCurrent] = gb.MoveNumber) // drag only last move
        then
          begin
            dragCurrent := True;
            exit
          end;

      // start dimmed and view rectangle selection (not used)
      if si.ModeInter in [kimVW, kimDD] then
        begin
          gb.Rectangle(iStart, jStart, iStart, jStart, True);
          exit
        end;

      // start pattern selection for DB search
      if si.ModeInter = kimPS then
        begin
          gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
          gb.Rectangle(iStart, jStart, iStart, jStart, True);
          exit
        end;

      // start rectangle selection for exporting position
      if si.ModeInter = kimZO then
        begin
          gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
          gb.Rectangle(iStart, jStart, iStart, jStart, True);
          fmExportPos.ShowZone(gb, iStart, jStart, iCurrent, jCurrent);
          exit
        end;

      // groupe status
      if si.ModeInter = kimGS then
        begin
          if gb.Board[iCurrent, jCurrent] = Empty
            then // nop
            else
              begin
                DoGroupStatus(view, iCurrent, jCurrent);
                ActiveView.si.ModeInter := ActiveView.si.ModeInterBeforeGS;
                Screen.Cursor := crDefault;
                exit
              end
        end;

      // apply click action on empty intersection
      if gb.Board[iCurrent, jCurrent] = Empty then
        begin
          ClickOnBoard(view, iCurrent, jCurrent, Button, Shift);

          if PatternSearchMode(view) <> psmNone
            then
              gb.Rectangle(0, 0, 0, 0, True);

          // click during quick search
          if (si.ModeInter = kimGE) and (si.DbQuickSearch = qsReady) then
            begin
              // click has been handled in ClickOnBoard
              // redraw current rectangle
              //gb.Rectangle(0, 0, 0, 0, True);
              QuickSearch(view)
            end;

          exit
        end;

      // apply click action on stone (all markups less AB and AW)
      if not (si.ModeInter in [kimAB, kimAW]) then
        begin
          ClickOnBoard(view, iCurrent, jCurrent, Button, Shift);
          exit
        end;

      // AB or AW mode on stone
      if not Settings.ExtendSetup
        then ClickOnBoard(view, iCurrent, jCurrent, Button, Shift)
        else
          // handle setup,swap,remove sequence
          if si.ModeInter = kimAB
            then
              begin
                si.ModeInter := kimAW;
                ClickOnBoard(view, iCurrent, jCurrent, Button, Shift);
                si.ModeInter := kimAB
              end
            else
              begin
                si.ModeInter := kimAB;
                ClickOnBoard(view, iCurrent, jCurrent, Button, Shift);
                si.ModeInter := kimAW
              end
    end
end;

// -- Handling of mouse move event -------------------------------------------

procedure GobanMouseMove(view : TViewBoard;
                         X, Y : integer;
                         Button : TMouseButton;
                         Shift : TShiftState = []);
var
  i, j : integer;
begin
  with view do
    case si.ModeInter of
      // ongoing dragging last move in game edit mode
      kimGE : if dragCurrent then
        begin
          gb.xy2ij(X, Y, i, j);

          if (i <> iCurrent) or (j <> jCurrent)
            then
              begin
                gb.Undo;
                iCurrent := i;
                jCurrent := j;
                gb.Play(i, j, ReverseColor(si.Player), CurrentStatus)
              end
        end;

      // ongoing markup drawing
      kimAB .. kimNU, kimTB, kimTW, kimWC : // exclude labels
        begin
          gb.xy2ij(X, Y, i, j);

          if (i <> iCurrent) or (j <> jCurrent)
            then
              begin
                iCurrent := i;
                jCurrent := j;
                ClickOnBoard(view, i, j, mbLeft, Shift); // todo : mbLeft default ?
              end
        end;

      // ongoing rectangle selection
      kimVW, kimDD, kimZO, kimPS :
        begin
          gb.xy2ij(X, Y, i, j);

          if gb.IsBoardCoord(iStart, jStart) and
             gb.IsBoardCoord(i, j) and
             ((i <> iCurrent) or (j <> jCurrent)) then
            begin
              gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
              iCurrent := i;
              jCurrent := j;
              gb.Rectangle(iStart, jStart, iCurrent, jCurrent, True);
              if si.ModeInter = kimZO
                then fmExportPos.ShowZone(gb, iStart, jStart, iCurrent, jCurrent)
            end
        end
    end
end;

// -- Handling of mouse up event ---------------------------------------------

procedure GobanMouseUp(view : TViewBoard;
                       X, Y : integer;
                       Button : TMouseButton;
                       Shift : TShiftState = []);
begin
  with view do
    begin
      // end dragging last move in game edit mode
      if (si.ModeInter = kimGE) and dragCurrent
        then
          begin
            if (CurrentStatus <> CgbOk) or not view.AllowModification
              then
                begin
                  gb.Undo;
                  gb.Play(iStart, jStart, ReverseColor(si.Player), CurrentStatus)
                end
              else
                begin
                  if si.Player = Black
                    then gt.PutProp(prW, ij2pv(iCurrent, jCurrent))
                    else gt.PutProp(prB, ij2pv(iCurrent, jCurrent));
                  si.FileSave := False
                end;
            exit
          end;

      // end view rectangle selection (not used)
      if si.ModeInter = kimVW then
        begin
          if not gb.IsBoardCoord(iStart, jStart)
            then exit;

          gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
          ApplyNode(view, Undo);
          gt.PutProp(prVW, ijkl2pv(iStart, jStart, iCurrent, jCurrent));
          ApplyNode(view, Enter);
          si.FileSave := False;
          exit
        end;

      // end dimmed rectangle selection (not used)
      if si.ModeInter = kimDD then
        begin
          if not gb.IsBoardCoord(iStart, jStart)
            then exit;

          gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
          ApplyNode(view, Undo);
          gt.PutProp(prDD, ijkl2pv(iStart, jStart, iCurrent, jCurrent));
          ApplyNode(view, Enter);
          si.FileSave := False;
          exit
        end;

      // end rectangle selection for exporting position
      if si.ModeInter = kimZO then
        begin
          if not gb.IsBoardCoord(iStart, jStart)
            then exit;

          fmExportPos.Capture(iStart, jStart, iCurrent, jCurrent);
          gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
          iStart := 0;
          jStart := 0;
          exit
        end;

      // end pattern selection for DB search
      if si.ModeInter = kimPS then
        begin
          ClipCursor(nil);
          si.ModeInter := si.ModeInterBak;
          Screen.Cursor := crDefault;
          frViewBoard.imGoban.OnMouseEnter := nil;
          frViewBoard.imGoban.OnMouseLeave := nil;

          EndSearchSelection(view, iStart, jStart, iCurrent, jCurrent);
          exit
        end;
    end
end;

// -- Processing of clicks on board ------------------------------------------

procedure ClickOnBoard(view : TViewBoard;
                       i, j : integer;
                       Button : TMouseButton;
                       Shift : TShiftState = []);
begin
  view.SetFocusOnGoban;
  //view.gb.HideTempMarks;

  case view.si.ModeInter of
    kimNOP : {nop};
    kimGE  : GameEditClick    (view, i, j, Button, Shift);
    kimAB  : InputABWE        (view, i, j, iff(ssLeft in Shift, Black, White));
    kimHB  : InputABWE        (view, i, j, Black);
    kimEB  : if view.gb.Board[i, j] = Black
               then InputABWE(view, i, j, Black);
    kimAW  : InputABWE        (view, i, j, iff(ssLeft in Shift, White, Black));
    kimAE  : InputABWE        (view, i, j, Empty);
    kimMA  : InputMarkup      (view, i, j, prMA);
    kimTR  : InputMarkup      (view, i, j, prTR);
    kimCR  : InputMarkup      (view, i, j, prCR);
    kimSQ  : InputMarkup      (view, i, j, prSQ);
    kimLE  : InputLetter      (view, i, j);
    kimNU  : InputMoveNumber  (view, i, j);
    kimLB  : InputLabel       (view, i, j);
    kimTB  : InputMarkup      (view, i, j, prTB);
    kimTW  : InputMarkup      (view, i, j, prTW);
    kimRG  : IntersectionGM   (view, i, j);
    kimPB  : IntersectionPB   (view, i, j);
    kimPF  : {nop};
    kimJO  : IntersectionJO   (view, i, j);
    kimTU  : IntersectionTutor(view, i, j);
    kimEG  : IntersectionGtp  (view, i, j);

    kimWC  : InputMarkup      (view, i, j, pr_W);
    //kimWC  : DoEditMarkTemp (view, i, j, pr_W)
  end
end;

// -- Processing of clicks on board in game edit mode ------------------------

// -- Entry point

procedure GameEditClickV1(view : TViewBoard;
                          i, j : integer;
                          Button : TMouseButton;
                          Shift : TShiftState);
begin
  if Shift = [ssLeft]
    then GameEditSingleClick(view, i, j)
    else
      if Shift = [ssLeft, ssCtrl]
        then GameEditCtrlClick(view, i, j)
end;

procedure GameEditClick(view : TViewBoard;
                        i, j : integer;
                        Button : TMouseButton;
                        Shift : TShiftState);
begin
  if Button = mbLeft
    then
      if ssCtrl in Shift
        then GameEditCtrlClick(view, i, j)
        else GameEditSingleClick(view, i, j)
end;

// -- Single click on board in game edit mode

function IsVariationMarkup(view : TViewBoard; i, j : integer) : boolean;
begin
  Result :=
    (VarMarkup(view.si) in [vmGhost, vmUpCase, vmDnCase]) and // markup mode
    (view.gb.IsBoardCoord(i, j)) and                          // valid coord
    (IsVariation(view.gt, ReverseColor(NextPlayer(view.gt)), i, j) <> nil)
end;

procedure GameEditSingleClick(view : TViewBoard; i, j : integer);
begin
  if Status.VarStyle = vsChildren
    then GameEditNextMove(view, i, j)
    else
      if not IsVariationMarkup(view, i, j)
        then GameEditNextMove(view, i, j)
        else GameEditNextSibling(view, i, j)
end;

// -- Control click on board in game edit mode

procedure GameEditCtrlClick(view : TViewBoard; i, j : integer);
begin
  if view.gb.Board[i, j] = Empty
    then
      if Status.VarStyle = vsSibling
        then
          if IsVariationMarkup(view, i, j)
            then GameEditNextMove(view, i, j)
            else GameEditNextSibling(view, i, j)
        else
          GameEditNextSibling(view, i, j)
    else
      GameEditClickOnStone(view, i, j)
end;

// -- Handling of a click on stone in game edit mode

procedure GameEditClickOnStone(view : TViewBoard; i, j : integer);
var
  n : integer;
  x : TGameTree;
  pr : TPropId;
  pv : string;
begin
  n := view.gb.MoveNumber;
  FindMove(view.gt, i, j, x, n);

  if x <> nil
    then view.GoToNode(x)
    else
      begin
        // it's a setup stone, go backward to find it
        x := view.gt;
        pr := iff(view.gb.Board[i,j] = Black, prAB, prAW);
        pv := ij2pv(i, j);

        // must be found, no need to test x.PrevNode
        while Pos(pv, x.GetProp(pr)) = 0 do
          x := x.PrevNode;

        // found
        view.GoToNode(x)
      end
end;

// -- Board editing commands -------------------------------------------------

// -- Black, White and Empty setup commands

procedure InputBWE(view : TViewBoard;
                   i, j : integer;
                   how, no1, no2 : TPropId);
var
  x, z, gt0 : TGameTree;
  pv : string;
begin
  with view do
    begin
      if not view.AllowModification
        then exit;

      if not gt.HasMove
        then ApplyNode(view, Undo)
        else
          begin
            x := TGameTree.Create;
            if gt.NextNode = nil
              then
                begin
                 gt.LinkNode(x);
                 ApplyNode(view, Leave);
                 gt0 := gt;
                 gt := x;
                 TV_LinkMoves(view, gt0)
                end
              else
                begin
                  z := gt.NextNode.LastVar;
                  z.LinkVar(x);
                  ApplyNode(view, Leave);
                  gt := x;
                  TV_LinkVars(view, z)
                end
          end;

      pv := ij2pv(i, j);
      gt.RemPropPack(no1, pv);
      gt.RemPropPack(no2, pv);
      if (how = prAE) and (gt = gt.Root)
        then // do not store AE property on initial position
        else gt.AddPropPack(how, pv);

      ApplyNode(view, Enter);

      si.FileSave := False
    end
end;

procedure InputBWE2(view : TViewBoard;
                    i, j : integer;
                    how, no1, no2 : TPropId);
var
  x, z, gt0 : TGameTree;
  pv : string;
begin
  if not view.AllowModification
    then exit;

  if not view.gt.HasMove
    then ApplyNode(view, Undo)
    else
      begin
        x := TGameTree.Create;
        if view.gt.NextNode = nil
          then
            begin
             view.gt.LinkNode(x);
             ApplyNode(view, Leave);
             gt0 := view.gt;
             view.gt := x;
             TV_LinkMoves(view, gt0)
            end
          else
            begin
              z := view.gt.NextNode.LastVar;
              z.LinkVar(x);
              ApplyNode(view, Leave);
              view.gt := x;
              TV_LinkVars(view, z)
            end
      end;

  pv := ij2pv(i, j);
  view.gt.RemPropPack(no1, pv);
  view.gt.RemPropPack(no2, pv);
  if (how = prAE) and (view.gt = view.gt.Root)
    then // do not store AE property on initial position
    else view.gt.AddPropPack(how, pv);

  ApplyNode(view, Enter);

  view.si.FileSave := False
end;

procedure InputABWE(view : TViewBoard; i, j, what : integer);
begin
  with view do
    case what of
      Black : if gb.Board[i, j] = Black
                then InputBWE(view, i, j, prAE, prAB, prAW)
                else InputBWE(view, i, j, prAB, prAW, prAE);
      White : if gb.Board[i, j] = White
                then InputBWE(view, i, j, prAE, prAB, prAW)
                else InputBWE(view, i, j, prAW, prAB, prAE);
      Empty : if gb.Board[i, j] = Empty
                then // Nop
                else InputBWE(view, i, j, prAE, prAB, prAW)
    end
end;

// -- Calling function for markup input

procedure InputMarkup(view : TViewBoard; i, j : integer; pr : TPropId);
begin
  view.DoEditMarkup(i, j, pr, ij2pv(i, j))
end;

// -- Letter markup input

procedure InputLetter(view : TViewBoard; i, j : integer);
begin
  view.DoEditMarkup(i, j, prL, ij2pv(i, j))
end;

// -- Input move number as label

procedure InputMoveNumber(view : TViewBoard; i, j : integer);
var
  x  : TGameTree;
  pv : string;
  n  : integer;
begin
  with view do
    if gb.Board[i, j] = Empty
    then // TODO: what if no move
    else
      begin
        n := gb.MoveNumber;
        FindMove(gt, i, j, x, n);
        if x = nil
          then // TODO: what if not found
          else
            begin
              pv := ijn2pv(i, j, n mod 1000);
              DoEditMarkup(i, j, prLB, pv)
            end
      end
end;

// -- Misc editing commands --------------------------------------------------

// -- Input of figure (not used for the time being)

procedure InputFigure(view : TViewBoard);
begin
  with view do
    if AllowModification then
      begin
        gt.PutProp(prFG, '[]');
        si.FileSave := False
      end
end;

// -- Input of node names

procedure InputNodeName(view : TViewBoard);
var
  s1, s2 : string;
begin
  with view do
    begin
      s1 := pv2str(gt.GetProp(prN));
      s2 := frViewBoard.edNodeName.Text;
      s2 := PutEscChar(CpEncode(s2, si.GameEncoding));

      if s1 <> s2 then
        if not AllowModification
          then frViewBoard.edNodeName.Text := s1
          else
            begin
              if s2 = ''
                then gt.RemProp(prN)
                else gt.PutProp(prN, str2pv(s2));
              si.FileSave := False
            end;

      //MainPanel_Update(view.frViewBoard, gt)
    end
end;

// -- Input of comments

procedure InputComments(view : TViewBoard);
var
  s1, s2 : string;
begin
  with view do
    begin
      s1 := pv2txt(gt.GetProp(prC));

      s2 := CpEncode(frViewBoard.mmComment.Text, si.GameEncoding);
      s2 := TrimRight(s2);
      s2 := PutEscChar(s2);

      if s1 <> s2 then
        if not AllowModification
          then frViewBoard.mmComment.Text := s1
          else
            begin
              if s2 = ''
                then gt.RemProp(prC)
                else gt.PutProp(prC, str2pv(s2));
              si.FileSave := False
            end;

    //MainPanel_Update(frViewBoard, gt)
  end
end;

// == Joseki commands ========================================================

procedure DoEnterJosekiTutor(var view : TViewBoard; path : string; trans : TCoordTrans);
var
  ok : boolean;
begin
  // test if joseki database is defined
  if Settings.joDataBase = '' then
    begin
      MessageDialog(msOk, imExclam, [U('Joseki database not defined'),
                                     U('See Options>Joseki')]);
      exit
    end;

  // open joseki database
  view.gb.CoordTrans := trans;
  DoMainOpenFile(Settings.joDataBase, 1, path, False, ok);
  if not ok then
    begin
      MessageDialog(msOk, imExclam, [U('Unable to read joseki database'),
                                     U('Verify Options>Joseki')]);
      exit
    end;

  // set mode
  fmMain.ActivePage.Caption := 'Joseki Tutor';
  view.si.ModeInter := kimTU;
  EnableCommands(view, mdTuto);
  SetTabIcon    (view, mdTuto);

  // reapply to update goban display
  view.ReApplyNode
end;

procedure DoCloseJosekiTutor(view : TViewBoard);
begin
  // avoid to store starting position
  if view.gt.PrevNode = nil
    then exit;

  fmMain.MRU_Tutor.Add('', Settings.joDataBase, 1,
                        PrintTreeInString(view.gt.MovesToNode),
                        view.gb.CoordTrans)
end;

// -- Processing of clicks on board in joseki tutor mode

procedure IntersectionTutor(view : TViewBoard; i, j : integer);
var
  tr : TCoordTrans;
  p, q : integer;
begin
  if (view.gt = nil) or (view.gt.NextNode = nil)
    then // no more continuation
    else
      if IsContinuationTr(view.gt, view.si.Player, i, j, view.gb.BoardSize, tr) <> nil
        then
          begin
            // undo
            ApplyNode(view, Leave);

            // new transform
            view.gb.CoordTrans := Compose(Inverse(tr), view.gb.CoordTrans);

            // new coordinates
            Transform(i, j, view.gb.BoardSize, tr, p, q);

            // go to next
            view.gt := IsContinuation(view.gt, view.si.Player, p, q);
            ApplyNode(view, Enter);
            TV_UpdateView(view)
          end
        else // should make a warning: no more follow up
end;

// == Fuseki commands ========================================================

procedure DoEnterFusekiTutor(var view : TViewBoard; path : string; trans : TCoordTrans);
var
  ok : boolean;
begin
  // test if fuseki database is defined
  if Settings.fuDatabase = '' then
    begin
      MessageDialog(msOk, imExclam, [U('Fuseki database not defined'),
                                     U('See Options>Fuseki')]);
      exit
    end;

  // open joseki database
  view.gb.CoordTrans := trans;
  DoMainOpenFile(Settings.fuDatabase, 1, path, False, ok);
  if not ok then
    begin
      MessageDialog(msOk, imExclam, [U('Unable to read fuseki library'),
                                     U('Verify Options>Fuseki')]);
      exit
    end;

  // set mode
  fmMain.ActivePage.Caption := 'Fuseki Library';
  view.si.ModeInter := kimFU;
  EnableCommands(view, mdFuse);
  SetTabIcon    (view, mdFuse);

  // reapply to update goban display
  view.ReApplyNode
end;

// == Engine game commands ===================================================

function FirstWord(const s : string) : string;
var
  i1, i2 : integer;
begin
  i1 := Pos(' ', s + ' ');
  i2 := Pos(#10, s);
  Result := LeftStr(s, Min(i1, i2) - 1);

  // todo
  Result := s
end;

// -- Score

procedure DisplayScore(view : TView; const x : string);
begin
  fmMain.WriteInStatusPanel(sbGlyph, 'ScoreEstimate');
  fmMain.WriteInStatusPanel(sbAnnotation, ' ' + FirstWord(x))
end;

procedure DoScoreEstimate(view : TViewBoard);
begin
  ScoreEstimate(view, DisplayScore)
end;

// -- Suggestion

procedure DisplaySuggestion(view : TView; const x : string);
var
  i, j : integer;
  coord : string;
begin
  coord := FirstWord(x);

  with view do
    begin
      // x is 'PASS' or standard coordinates
      if coord <> 'PASS' then
        begin
          // convert to i,j
          kor2ij(coord, gb.BoardSize, i, j);

          // display hint on goban
          gb.HideTempMarks;
          ShowNextOrVars(Enter);
          gb.ShowTempMark(i, j, mrkGH);
          Application.ProcessMessages
        end;

    // display suggestion in status bar
    fmMain.WriteInStatusPanel(sbGlyph, 'SuggestMove');
    fmMain.WriteInStatusPanel(sbAnnotation, ' ' + coord)
  end
end;

procedure DoSuggestMove(view : TViewBoard);
begin
  SuggestMove(view, DisplaySuggestion)
end;

// -- Influence

// Callback : x is (boardsize x boardsize) list of influence values

procedure DisplayInfluence(view : TView; const x : string);
var
  s : string;
  list : TStringDynArray;
  size, i, j, k : integer;
begin
  s := StringReplace(x, #10  , ' ', [rfReplaceAll]);
  s := StringReplace(s, '  ' , ' ', [rfReplaceAll]);
  s := StringReplace(s, '  ' , ' ', [rfReplaceAll]);
  s := Trim(s);
  Split(s, list, ' ');

  view.gb.HideTempMarks;
  view.ShowNextOrVars(Enter);
  size := view.gb.BoardSize;
  k := 0;

  for i := 1 to size do
    for j := 1 to size do
      begin
        case StrToInt(list[k]) of
           1,  2,  3{,  4} : view.gb.ShowTempMark(i, j, mrkTW);
          -1, -2, -3{, -4} : view.gb.ShowTempMark(i, j, mrkTB);
          else
            // nop
        end;
        inc(k)
      end;
end;

procedure DoInfluenceRegions(view : TViewBoard);
begin
  InfluenceRegions(view, DisplayInfluence)
end;

// -- Group status

procedure DisplayGroupStatus(view : TView; const x : string);
var
  status, coord : string;
  i, j, k : integer;
  requestVertex : integer;
begin
  // display status markups, they will be erased after each actions (HideTempMarks)
  // or click on goboard
  status := NthWord(x, 1);

  // find vertex after status and attack and defense points if critical
  if status = 'critical'
    then requestVertex := 4
    else requestVertex := 2;

  view.gb.HideTempMarks;
  view.ShowNextOrVars(Enter);
  k := requestVertex;
  repeat
    coord := NthWord(x, k);
    if coord = ''
      then break;

    inc(k);
    kor2ij(coord, view.gb.BoardSize, i, j);
    if status = 'alive'
      then view.gb.ShowTempMark(i, j, mrkGH);
    if status = 'dead'
      then view.gb.ShowTempMark(i, j, mrkBH);
    if status = 'critical'
      then view.gb.ShowTempMark(i, j, mrkCS);
  until False;

  fmMain.WriteInStatusPanel(sbGlyph, 'GroupStatus');
  fmMain.WriteInStatusPanel(sbAnnotation, ' ' + NthWord(x, requestVertex) +
                                        //' ' + TT(NthWord(x, 1)))
                                          ' ' + U(NthWord(x, 1)))
end;

procedure DoGroupStatus(view : TViewBoard; i, j : integer);
begin
  GroupStatus(view, DisplayGroupStatus, ij2kor(i, j, view.gb.BoardSize))
end;

// ---------------------------------------------------------------------------

end.

