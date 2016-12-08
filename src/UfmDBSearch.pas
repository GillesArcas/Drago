// ---------------------------------------------------------------------------
// -- Drago -- Non modal search window -------------------- UfmDBSearch.pas --
// ---------------------------------------------------------------------------

unit UfmDBSearch;

// ---------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Buttons,
  UActions, ExtCtrls, DateUtils,
  TntForms, TntComCtrls, TntSystem, TntStdCtrls, TntButtons, TntGraphics,
  DefineUi, UfrDBRequestPanel, UfrDBPatternPanel, UfrDBSignaturePanel,
  ImgList, TB2Item, SpTBXItem, TB2Dock, TB2Toolbar, ComCtrls,
  StdCtrls, UfrDBSettingsPanel,
  ToolWin,
  SpTBXControls, Menus, SpTBXTabs, SpTBXEditors, GIFImage;

type
  TfmDBSearch = class(TTntForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    ilParam: TImageList;
    Bevel3: TBevel;
    lbSearch: TTntLabel;
    StatusBar: TTntStatusBar;
    ToolbarDBSearch: TSpTBXToolbar;
    btHelpOld: TSpTBXItem;
    btResetOld: TSpTBXItem;
    btSignatureOld: TSpTBXItem;
    btInfo: TSpTBXItem;
    btPatternOld: TSpTBXItem;
    btSettingsOld: TSpTBXItem;
    pnBottom: TPanel;
    TabSetDBSearch: TSpTBXTabSet;
    btPattern: TSpTBXItem;
    btGameInfo: TSpTBXItem;
    btSignature: TSpTBXItem;
    btSearch1: TSpTBXButton;
    btMore: TSpTBXButton;
    SpTBXButton1: TSpTBXButton;
    btSettings1: TSpTBXButton;
    Panel1: TPanel;
    pnBottomOld: TPanel;
    bvViewResults: TBevel;
    lbViewResults: TTntLabel;
    sbViewBoard: TTntSpeedButton;
    sbViewInfo: TTntSpeedButton;
    sbViewThumb: TTntSpeedButton;
    sbClose: TTntSpeedButton;
    sbSettings: TTntSpeedButton;
    btSearchOld: TTntBitBtn;
    cbSearchIn: TTntComboBox;
    Bevel4: TBevel;
    Bevel6: TBevel;
    ToolbarBottom: TSpTBXToolbar;
    SpTBXSeparatorItem5: TSpTBXSeparatorItem;
    btSearch: TSpTBXSubmenuItem;
    btSearchResults: TSpTBXItem;
    btReset: TSpTBXItem;
    SpTBXSeparatorItem4: TSpTBXSeparatorItem;
    btSettings: TSpTBXItem;
    SpTBXSeparatorItem3: TSpTBXSeparatorItem;
    SpTBXSeparatorItem2: TSpTBXSeparatorItem;
    btHelp: TSpTBXItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    Bevel5: TBevel;
    btResults: TSpTBXSubmenuItem;
    SpTBXItem1: TSpTBXItem;
    SpTBXItem2: TSpTBXItem;
    SpTBXItem3: TSpTBXItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbPatternClick(Sender: TObject);
    procedure tbInfoClick(Sender: TObject);
    procedure tbSignatureClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbSearchInChange(Sender: TObject);
    procedure cbSearchInDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure tbResetClick(Sender: TObject);
    procedure sbViewBoardClick(Sender: TObject);
    procedure sbViewInfoClick(Sender: TObject);
    procedure sbViewThumbClick(Sender: TObject);
    procedure sbSettingsClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbHowToClick(Sender: TObject);
    procedure btSettingsOldClick(Sender: TObject);
    procedure btSettings1Click(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btSearchResultsClick(Sender: TObject);
    procedure btResetClick(Sender: TObject);
  private
    procedure SelectSearchInner(aSearchMode : TSearchMode);
    procedure Translate;
    procedure OnTerminateSettings(Sender: TObject);
    procedure OnTerminateSettingsModal(Sender: TObject);
    procedure DoStartSearch(reset : boolean);
    procedure OptimizeSearchButtons;
  public
    FSearchMode : TSearchMode;
    FPreviousSearchMode : TSearchMode;
    frDBPatternPanel   : TfrDBPatternPanel;
    frDBRequestPanel   : TfrDBRequestPanel;
    frDBSignaturePanel : TfrDBSignaturePanel;
    frDBSettingsPanel  : TfrDBSettingsPanel;
    class procedure Execute(aSearchMode : TSearchMode = smPattern);
    procedure SelectSearch(aSearchMode : TSearchMode);
    procedure DoUpdate;
    procedure DoUpdateWithList(listOfDBNames : TStringList);
    procedure DefineSearchContext;
    function  InitSearch : boolean;
    procedure StartSearch(var ok : boolean);
    procedure TerminateSearch(Sender: TObject);
    procedure Snapshot(i1, j1, i2, j2 : integer);
    procedure NotifyThumbnailChange(clear : boolean = False);
    procedure ClearCallingBoard;
    procedure ResetResultTabRef;
    procedure ShowStatusMsg(s : WideString);
    procedure SetModeInter(mode : integer);
  end;

var
  fmDBSearch : TfmDBSearch;

procedure SetModeInter(mode : integer);
function PatternSearchReady : boolean;

// ---------------------------------------------------------------------------

implementation

uses
  Define, Translate, TranslateVcl, UStatus, UDatabase, Main,
  UDBBaseNamePicker, UKombilo,
  UApply, HtmlHelpAPI, UStatusMain, VclUtils, UViewBoard,
  UfrDBPatternResult, UMainUtil, UGCom;

{$R *.dfm}

// -- Display request --------------------------------------------------------

class procedure TfmDBSearch.Execute(aSearchMode : TSearchMode = smPattern);
begin
  Application.ProcessMessages;
  
  if fmDBSearch = nil then // singleton
    try
      Screen.Cursor := fmMain.WaitCursor;
      fmDBSearch := TfmDBSearch.Create(Application);
      fmDBSearch.Hide;
      fmDBSearch.SelectSearchInner(ASearchMode);
      fmDBSearch.Show
    finally
      Screen.Cursor := crDefault
    end
  else
    if Assigned(fmDBSearch)
      then fmDBSearch.WindowState := wsNormal
end;

// -- Standard methods -------------------------------------------------------

// -- Creation of form

procedure TfmDBSearch.FormCreate(Sender: TObject);
var
  h : integer;
begin
  FSearchMode        := smNone;
  frDBPatternPanel   := nil;
  frDBRequestPanel   := nil;
  frDBSignaturePanel := nil;
  frDBSettingsPanel  := nil;
  DBSearchContext    := TSearchContext.Create;
  SetWinStrPosition(self, StatusMain.FmSearchPlace);
  
  // fight against flickering
  //DoubleBuffered := True;
  pnBottom.ParentBackground := False;

  // yes, xpman forces Transparent property to True
  lbSearch.Transparent := False;

  fmMain.DBListOfTabs.OnChange := DoUpdateWithList;
  cbSearchIn.ItemIndex := 0;

  Actions.acWildcard.Visible := True;
  Actions.acWildcard.Enabled := True;

  ResetResultTabRef;
  bvViewResults.SendToBack;

  h := 4;
  Bevel1.Visible := False; // false if lbSearch invisible
  Bevel1.Height := h;
  Bevel2.Height := 3;
  Bevel3.Height := h;
  Bevel3.Visible := False;
  Bevel4.Height := h;

  // subscribe to si.ModeInter observer (1 hard coded until now)
  fmMain.ActiveView.si.ObservedSetModeInter[1] := UfmDBSearch.SetModeInter;

  fmMain.ActiveView.si.DbSearchOpen := True;

  ToolbarDBSearch.Options := [tboDefault,tboImageAboveCaption];
  //ToolbarDBSearch.Options := [tboDefault];

  // resize bottom buttons, -5 required otherwise last button not seen
(*
  btSearch.CustomWidth   := SpTBXToolbar1.ClientWidth div 4 - 5;
  btSettings.CustomWidth := btSearch.CustomWidth;
  btResults.CustomWidth  := btSearch.CustomWidth;
  btHelp.CustomWidth     := btSearch.CustomWidth;
*)
  btResults.Visible      := False;
  btSearch.CustomWidth   := ToolbarBottom.ClientWidth div 3 - 5;
  btSettings.CustomWidth := btSearch.CustomWidth;
  btHelp.CustomWidth     := btSearch.CustomWidth;

  OptimizeSearchButtons;

  // try to fix possible lost of layout
  //Bevel6.Top := 45;
  //Panel1.Top := 48;

  //SelectSearch(smPattern)
end;

procedure TfmDBSearch.OptimizeSearchButtons;
// todo: CustomWidth value is -1 first time. This is not what is expected.
var
  x : array[0 .. 2] of TSpTBXItem;
  i, L, n : integer;
begin
  x[0] := btPattern;
  x[1] := btGameInfo;
  x[2] := btSignature;
  L := 0;
  n := 0;
  for i := 0 to 2 do
    if x[i].CustomWidth < (TabSetDBSearch.Width / 3)
      then
        begin
          x[i].Tag := 1;
          inc(n)
        end
      else inc(L, x[i].CustomWidth);
  if n > 0 then
    for i := 0 to 2 do
      if x[i].Tag = 1
        then x[i].CustomWidth := Round((TabSetDBSearch.Width - L) / n)
end;

// -- Destruction of form

procedure TfmDBSearch.FormDestroy(Sender: TObject);
begin
  FreeAndNil(frDBPatternPanel);
  FreeAndNil(frDBRequestPanel);
  FreeAndNil(frDBSignaturePanel);
  FreeAndNil(DBSearchContext);
  fmDBSearch := nil
end;

// -- Closing

procedure TfmDBSearch.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, mode : integer;
begin
  StatusMain.FmSearchPlace := GetWinStrPlacement(self);

  // store current search mode or previous one when in setting mode
  case FSearchMode of
    smPattern,
    smInfo,
    smSig :
      Settings.DBSearchMode := FSearchMode;
    smSettings :
      Settings.DBSearchMode := FPreviousSearchMode;
    smSettingsModal :
      // nop, keep current mode
  end;

  fmMain.DBListOfTabs.OnChange := nil;
  ClearCallingBoard;
  DoResetDatabase;
  fmMain.ActivePage.TabView.DoWhenShowing;
  Action := caFree;

  // hide possible wildcard markup button in toolbar
  //mode := fmMain.ActiveView.si.ModeInter;
  fmMain.ActiveView.si.ModeInter := Settings.LastMarkup;
  fmMain.ActiveView.si.ModeInter := kimGE;
  //fmMain.ActiveView.si.ModeInter := mode;

  // hide wildcard in popup menu
  Actions.acWildcard.Visible := False;
  Actions.acWildcard.Enabled := False;

  // unsubscribe to si.ModeInter observer (1 hard coded until now)
  // todo : what with tabs non active
  fmMain.ActiveView.si.ObservedSetModeInter[1] := nil;

  // todo : something
  //if Actions.acQuickSearch.Checked
  case PatternSearchMode(fmMain.ActiveView) of
    psmButtonSearchDBWindow,
    psmQuickSearchDBWindow :
      begin
        if fmMain.ActiveView is TViewBoard
          then (fmMain.ActiveView as TViewBoard).ExitQuickSearch;
        fmMain.ActiveView.si.DbQuickSearch := qsOff;
        Actions.acQuickSearch.Checked := False;

        // reset dbsearch open flag in all tabs
        for i := 0 to fmMain.PageCount - 1 do
          begin
            fmMain.Pages[i].cx.si.DbSearchOpen := False;
            fmMain.Pages[i].cx.si.DbQuickSearch := qsOff;
          end
      end;
    else
      begin
      end;
  end;
  fmMain.ActiveView.gb.Rectangle(0, 0, 0, 0, False);
  fmMain.ActiveView.gb.HideTempMarks;

  //fmMain.ActiveView.si.DbQuickSearch := qsOff;
  //fmMain.btQuickSearch.Checked := False;
  //Actions.acQuickSearch.Checked := False;
end; 

// -- Display

procedure TfmDBSearch.FormShow(Sender: TObject);
begin
  Translate;
  cbSearchIn.Font.Name := 'Tahoma'
end;

// -- Getting focus

procedure TfmDBSearch.FormActivate(Sender: TObject);
begin
  Actions.EnableEditShortcuts(False);
  DoUpdate
end;

// -- Translation

procedure TfmDBSearch.Translate;
var
  i : integer;
begin
  for i := 0 To ComponentCount - 1 do
    if Components[i] = frDBRequestPanel
      then frDBRequestPanel.Translate // avoid to translate player comboboxes
      else TranslateTComponent(Components[i]);

  TranslateComponent(ToolbarBottom);
  TranslateComponent(btSearchResults);
  TranslateComponent(btReset);
end;

// -- Update -----------------------------------------------------------------

// -- Update form

procedure TfmDBSearch.DoUpdate;
var
  list : TStringList;
begin
  list := fmMain.DBListOfTabs.ListOfCaptions;
  DoUpdateWithList(list);
  list.Free
end;

// -- Update DB names

procedure TfmDBSearch.DoUpdateWithList(listOfDBNames : TStringList);
var
  s, s2 : WideString;
begin
  case FSearchMode of
    smPattern  : s := U('Pattern search');
    smInfo     : s := U('Game information search');
    smSig      : s := U('Signature search');
    smSettings : s := U('Search settings');
    smSettingsModal : s := U('Search settings');
  end;

  // update form caption
  Caption := s;

  // update title label (to be removed if lbSearch is kept invisible)
  if listOfDBNames.Count = 0
    then s2 := U('No database loaded')
    else s2 := ExtractFileName(listOfDBNames[0]);
  lbSearch.Caption := ' ' + s + ' (' + s2 + ')';

  // update database name picker
  if FSearchMode in [smSettings, smSettingsModal]
    then frDbSettingsPanel.BaseNamePicker.DoUpdateWithList(listOfDBNames);

  // update search context
  DefineSearchContext
end;

// -- Selection of search mode -----------------------------------------------

procedure TfmDBSearch.SelectSearch(aSearchMode : TSearchMode);
begin
  try
    LockControl(self, True);
    SelectSearchInner(ASearchMode)
  finally
    LockControl(self, False)
  end
end;

procedure TfmDBSearch.SelectSearchInner(aSearchMode : TSearchMode);
var
  w, i : integer;
begin
  // leave if nothing to do
  if aSearchMode = FSearchMode
    then exit;

  // store search mode
  FPreviousSearchMode := FSearchMode;
  FSearchMode := aSearchMode;

  // free current search panel
  // inhibates OnACtivate (otherwise it will be launched)
  OnActivate := nil;
  FreeAndNil(frDBPatternPanel);
  FreeAndNil(frDBRequestPanel);
  FreeAndNil(frDBSignaturePanel);
  //FreeAndNil(frDBSettingsPanel);
  OnActivate := FormActivate;

  // alloc search panel
  case aSearchMode of
    smPattern :
      begin
        ToolbarDBSearch.Visible := False;
        TabSetDBSearch.Visible := True;
        pnBottom.Visible := True;
        frDBPatternPanel := TfrDBPatternPanel.Create(self);
        w := frDBPatternPanel.Width;
        frDBPatternPanel.Parent := self;
        frDBPatternPanel.Align := alClient;
        frDBPatternPanel.ScaleBy(frDBPatternPanel.Width, w);
        frDBPatternPanel.Initialize;
        frDBPatternPanel.DoWhenUpdating;
        TranslateTComponent(frDBPatternPanel)
      end;
    smInfo :
      begin
        ToolbarDBSearch.Visible := False;
        TabSetDBSearch.Visible := True;
        pnBottom.Visible := True;
        frDBRequestPanel := TfrDBRequestPanel.Create(self);
        w := frDBRequestPanel.Width;
        frDBRequestPanel.Parent := self;
        frDBRequestPanel.Align := alClient;
        frDBRequestPanel.ScaleBy(frDBRequestPanel.Width, w);
        frDBRequestPanel.DoWhenUpdating;
        frDBRequestPanel.Translate
      end;
    smSig :
      begin
        ToolbarDBSearch.Visible := False;
        TabSetDBSearch.Visible := True;
        pnBottom.Visible := True;
        frDBSignaturePanel := TfrDBSignaturePanel.Create(self);
        w := frDBSignaturePanel.Width;
        frDBSignaturePanel.Parent := self;
        frDBSignaturePanel.Align := alClient;
        frDBSignaturePanel.ScaleBy(frDBSignaturePanel.Width, w);
        TranslateTComponent(frDBSignaturePanel)
      end;
    smSettings, smSettingsModal :
      begin
        ToolbarDBSearch.Visible := False;
        TabSetDBSearch.Visible := False;
        pnBottom.Visible := False;
        if not Assigned(frDbSettingsPanel)
          then frDbSettingsPanel := TfrDbSettingsPanel.Create(self);

        if aSearchMode = smSettings
          then frDbSettingsPanel.FOnTerminate := OnTerminateSettings
          else frDbSettingsPanel.FOnTerminate := OnTerminateSettingsModal;

        w := frDbSettingsPanel.Width;
        frDbSettingsPanel.Parent := self;
        frDbSettingsPanel.Align := alClient;
        frDbSettingsPanel.ScaleBy(frDbSettingsPanel.Width, w);
        TranslateTComponent(frDbSettingsPanel)
      end;
    end;

  //if aSearchMode in [smPattern, smInfo, smSig]
  //  then FreeAndNil(frDBSettingsPanel);
(*
  // if quick search on, erase possible results in main window
  if Actions.acQuickSearch.Checked and (FSearchMode <> smSettingsModal) then
  //if Actions.acQuickSearch.Checked and not (FSearchMode in [smPattern, smSettingsModal]) then
    begin
      (fmMain.ActiveView as TViewBoard).HideQuickSearch;
      Actions.acQuickSearch.Checked := False
    end;
*)
  // if quick search on, erase possible results in main window
  if (fmMain.ActiveView is TViewBoard) and (aSearchMode in [smPattern, smInfo, smSig])
    then //(fmMain.ActiveView as TViewBoard).HideQuickSearch;
      for i := 0 to fmMain.PageCount - 1 do
        begin
          if fmMain.Pages[i].TabvIew is TViewBoard
            then (fmMain.Pages[i].TabvIew as TViewBoard).HideQuickSearch
        end;
(*
  if Actions.acQuickSearch.Checked and not (FSearchMode in [smPattern, smSettings, smSettingsModal]) then
    begin
      Actions.acQuickSearch.Checked := False
    end;
*)
  if (PatternSearchMode(fmMain.ActiveView) in [psmQuickSearchDBWindow, psmQuickSearchSideBar])
     and (FSearchMode in [smInfo, smSig]) then
    begin
        fmMain.ActiveView.si.DbQuickSearch := qsOff;
        Actions.acQuickSearch.Checked := False;
    end;

  // update captions
  DoUpdate
end;

procedure TfmDBSearch.OnTerminateSettings(Sender: TObject);
begin
  SelectSearch(FPreviousSearchMode)
end;

procedure TfmDBSearch.OnTerminateSettingsModal(Sender: TObject);
begin
(**)
  if fmMain.ActiveView is TViewBoard then
    with fmMain.ActiveView as TViewBoard do
      frViewBoard.frDBPatternResult.DisplayResults(ActiveDBTab.TabView.kh);
(**)      
  Close
end;

// -- Buttons

procedure TfmDBSearch.tbPatternClick(Sender: TObject);
begin
  SelectSearch(smPattern)
end;

procedure TfmDBSearch.tbInfoClick(Sender: TObject);
begin
  Application.ProcessMessages;
  SelectSearch(smInfo)
end;

procedure TfmDBSearch.tbSignatureClick(Sender: TObject);
begin
  SelectSearch(smSig)
end;

procedure TfmDBSearch.btSettingsOldClick(Sender: TObject);
begin
  SelectSearch(smSettings)
end;

procedure TfmDBSearch.btSettings1Click(Sender: TObject);
begin
  SelectSearch(smSettings)
end;

// -- Other toolbar buttons --------------------------------------------------

procedure TfmDBSearch.tbResetClick(Sender: TObject);
begin
  StatusBar.Panels[0].Text := '';
  DoResetDatabase
end;

procedure TfmDBSearch.btResetClick(Sender: TObject);
begin
  StatusBar.Panels[0].Text := '';
  DoResetDatabase
end;

procedure TfmDBSearch.tbHowToClick(Sender: TObject);
begin
  if Assigned(frDBPatternPanel)
    then HtmlHelpShowContext(IDH_Database_PatternSearch);
  if Assigned(frDBRequestPanel)
    then HtmlHelpShowContext(IDH_Database_InfoSearch);
  if Assigned(frDBSignaturePanel)
    then HtmlHelpShowContext(IDH_Database_SigSearch);
end;

procedure TfmDBSearch.btHelpClick(Sender: TObject);
begin
  if Assigned(frDBPatternPanel)
    then HtmlHelpShowContext(IDH_Database_PatternSearch);
  if Assigned(frDBRequestPanel)
    then HtmlHelpShowContext(IDH_Database_InfoSearch);
  if Assigned(frDBSignaturePanel)
    then HtmlHelpShowContext(IDH_Database_SigSearch);
end;

// -- Snapshot for pattern search --------------------------------------------

procedure TfmDBSearch.Snapshot(i1, j1, i2, j2 : integer);
begin
  if Assigned(frDBPatternPanel) then
    begin
      DefineSearchContext;
      DBSearchContext.IsThumbPattern := False;
      frDBPatternPanel.Capture(i1, j1, i2, j2);
      ResetResultTabRef;
    end
end;

// -- Definition of search context -------------------------------------------

procedure TfmDBSearch.DefineSearchContext;
var
  i : integer;
  found : boolean;
begin
  //active page can be nil if called when closing a tab
  if fmMain.ActivePage = nil
    then exit;

  with DBSearchContext do
    begin
      DBTab := ActiveDBTab;
      if Assigned(DBTab)
        then kh := DBTab.TabView.kh;
      CallingTab := fmMain.ActivePage;

      // check if calling tab is really available
      found := False;
      for i := 0 to fmMain.PageCount - 1 do
        if fmMain.Pages[i] = CallingTab then
          begin
            found := True;
            break
          end;
      // when closing a tab with a pattern selected and the search done, the
      // tab can still be considered active, but access launches a crash
      if not found
        then CallingTab := nil;

      if CallingTab = nil
        then CallingView := vmBoard
        else CallingView := CallingTab.TabView.si.ViewMode;

      if CallingTab = nil
        then gt := nil
        else gt := CallingTab.TabView.gt;
    end
end;

procedure TfmDBSearch.NotifyThumbnailChange(clear : boolean = False);
begin
  DBSearchContext.IsThumbPattern := False;
  assert(False, 'Obsolete');
  
  DefineSearchContext;
  DBSearchContext.IsThumbPattern := True;
  ClearCallingBoard;
  if clear and(FSearchMode = smSig)
    then frDBSignaturePanel.ClearPanel
end;

procedure TfmDBSearch.ClearCallingBoard;
begin
  // check if search called from tab
  if DBSearchContext.CallingTab <> nil then
    // check if tab still open
    if fmMain.IsOpenTab(DBSearchContext.CallingTab) then
      with DBSearchContext.CallingTab do
        begin
          ApplyNode(ViewBoard, Leave);
          //RemProp(gv.gt, pr_L);
          //ViewBoard.gt.RemProp(pr_W); // commented 4.12
          ApplyNode(ViewBoard, Redo);
          ViewBoard.gb.HideSearchMarks(True)
        end
end;

// -- Search -----------------------------------------------------------------

// -- Init search

function TfmDBSearch.InitSearch : boolean;
begin
  Result := False;
  if FSearchMode = smPattern
    then // nop, use context defined when capturing thumbnail
    else DefineSearchContext;

  if DBSearchContext.DBTab = nil then
    begin
      StatusBar.Panels[0].Text := U('No database loaded');
      exit
    end;

  Result := True;

  // lock search button
  btSearch.Enabled := False;

  // reset game list if required
  if Status.DBResetSearch
    then DBSearchContext.kh.Reset;

  ClearCallingBoard;
  ResetResultTabRef;
  DBSearchContext.t0 := Now;

  case FSearchMode of
    smPattern : frDBPatternPanel.InitSearch;
    smInfo    : frDBRequestPanel.InitSearch;
    smSig     : frDBSignaturePanel.InitSearch;
  end
end;

// -- Start search

procedure TfmDBSearch.StartSearch(var ok : boolean);
begin
  ok := True;
  
  case FSearchMode of
    smPattern : frDBPatternPanel.StartSearch(ok);
    smInfo    : frDBRequestPanel.StartSearch;
    smSig     : frDBSignaturePanel.StartSearch;
  end
end;

// -- Terminate search

procedure TfmDBSearch.TerminateSearch(Sender: TObject);
var
  s1, s2 : WideString;
  n1, n2 : integer;
begin
  if DBSearchContext.DBTab = nil
    then exit;

  // unlock search button
  btSearch.Enabled := True;

  // fill game collection in DB tab
  with DBSearchContext do
    begin
(*
      ** moved to each TerminateSearch **

      CurrentEntriesToCollection(DBTab.ViewBoard);
      fmMain.InvalidateView(DBTab, vmAll);
*)
(*
      if DBTab.TabView.si.ViewMode = vmBoard
        then fmMain.SelectView(DBTab, vmInfo)
        else fmMain.SelectView(DBTab, DBTab.TabView.si.ViewMode) // test
(**)
(*
      if DBTab.TabView.cl.Count = 0
        then fmMain.SelectView(DBTab, vmInfo)
        else
          if DBTab.TabView.si.ViewMode = vmBoard
            then
              if DBTab = CallingTab
                then fmMain.SelectView(DBTab, vmThumb)
                else fmMain.SelectView(DBTab, vmInfo)
            else fmMain.SelectView(DBTab, DBTab.TabView.si.ViewMode) // test
*)
(*
      if DBTab = CallingTab
        then // nop
        else
          if DBTab.TabView.cl.Count = 0
            then fmMain.SelectView(DBTab, vmInfo)
            else fmMain.SelectView(DBTab, vmThumb)
*)
    end;

  // call dedicated terminating function
  case FSearchMode of
    smPattern : frDBPatternPanel.TerminateSearch(Sender);
    smInfo    : frDBRequestPanel.TerminateSearch(Sender);
    smSig     : frDBSignaturePanel.TerminateSearch(Sender);
  end;

  // timing
  s1 := FormatTimeString(MilliSecondsBetween(DBSearchContext.t0, Now));

  // number of results
  n1 := DBSearchContext.kh.Size;
  n2 := DBSearchContext.kh.NumHits;
  //s2 := WideFormat(U('%d result(s)'), [n1]);
  //s2 := WideFormat(U('%d game(s) found in %s'), [n1, DBSearchContext.DBTab.Caption]);

  StatusBar.Panels[0].Text := s1 + ', ' + DbFormatNumberOfResults(DBSearchContext.kh.Size,
                                                                  DBSearchContext.DBTab.Caption);

  if n1 > 0 then
    begin
      lbViewResults.Caption := U('View results in tab');
      bvViewResults.Visible := True;
      bvViewResults.BoundsRect := Rect(sbViewBoard.Left - 2,
                                       sbViewBoard.Top - 2,
                                       sbSettings.Left - 2,
                                       sbViewBoard.Top + sbViewBoard.Height + 2)
    end;

  // update current view
  with fmMain.ActivePage do
    //TabView.DoWhenShowing
    // don't update view as this would erases temporary markups
    // but reset enabled commands
    EnableCommands(TabView, TabView.si.EnableMode)
end;

// -- Search button event

procedure TfmDBSearch.btSearchClick(Sender: TObject);
begin
  DoStartSearch(True)   // reset = True
end;

procedure TfmDBSearch.btSearchResultsClick(Sender: TObject);
begin
  DoStartSearch(False)  // reset = False
end;

procedure TfmDBSearch.DoStartSearch(reset : boolean);
var
  ok : boolean;
begin
  Status.DBResetSearch := reset;

  if InitSearch = False
    then exit;

  try
    Screen.Cursor := fmMain.WaitCursor;
    StartSearch(ok);
    if ok
      then TerminateSearch(nil)
  finally
    btSearch.Enabled := True;
    Screen.Cursor := crDefault;
    Status.DBIgnoreHits := False;
    Status.DBMovesFromHit := 0;
  end
end;

// -- SearchIn combo events --------------------------------------------------

// -- OnChange

procedure TfmDBSearch.cbSearchInChange(Sender: TObject);
begin
  if cbSearchIn.ItemIndex = 0
    then DoResetDatabase;
  Status.DBResetSearch := cbSearchIn.ItemIndex = 0
end;

// -- OnDrawItem

procedure TfmDBSearch.cbSearchInDrawItem(Control: TWinControl;
                         Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cb : TTntComboBox;
  x, y, x1, x2 : integer;
begin
  cb := Control as TTntComboBox;
  x := Rect.Left;
  y := Rect.Top +(cb.ItemHeight - ilParam.Height) div 2;
  x1 := x;
  x2 := x + ilParam.Width;

  with cb.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(Rect);
      Font.Color := clBlack;
    end;
  WideCanvasTextOut(cb.Canvas, Rect.Left + 28, Rect.Top, cb.Items[Index]);

  if cb = cbSearchIn then
    with ilParam do
      case Index of
        0 : Draw(cb.Canvas, x1, y, 0);
        1 : begin
              Draw(cb.Canvas, x1, y, 0);
              Draw(cb.Canvas, x2, y, 1)
            end
      end
end;

// -- Bottom buttons ---------------------------------------------------------

// -- Board view

procedure TfmDBSearch.sbViewBoardClick(Sender: TObject);
begin
  if Assigned(DBSearchContext.DBTab) then
    begin
      fmMain.ActivePage := DBSearchContext.DBTab;
      fmMain.SelectView(vmBoard);
      if True
        then DBSearchContext.DBTab.ViewBoard.ChangeEvent(1, seMain, snHit)
    end
end;

// -- Info view

procedure TfmDBSearch.sbViewInfoClick(Sender: TObject);
begin
  if Assigned(DBSearchContext.DBTab) then
    begin
      fmMain.ActivePage := DBSearchContext.DBTab;
      fmMain.SelectView(vmInfo)
    end
end;

// -- Thumbnail view

procedure TfmDBSearch.sbViewThumbClick(Sender: TObject);
begin
  if Assigned(DBSearchContext.DBTab) then
    begin
      fmMain.ActivePage := DBSearchContext.DBTab;
      fmMain.SelectView(vmThumb)
    end
end;

// -- Settings

procedure TfmDBSearch.sbSettingsClick(Sender: TObject);
begin
  Actions.acDatabaseSettings.Execute
end;

// -- Close

procedure TfmDBSearch.sbCloseClick(Sender: TObject);
begin
  Close
end;

// -- Update of si.ModeInter -------------------------------------------------

procedure TfmDBSearch.SetModeInter(mode : integer);
begin
  if Assigned(fmDBSearch.frDBPatternPanel) then
    begin
      (*
      with frDBPatternPanel.BoardThumb do
        UpdateButton(mode)
      *)
    end
end;

procedure SetModeInter(mode : integer);
begin
  if Assigned(fmDBSearch)
    then fmDBSearch.SetModeInter(mode)
end;

// -- Misc -------------------------------------------------------------------

procedure TfmDBSearch.ResetResultTabRef;
begin
  StatusBar.Panels[0].Text := '';
  lbViewResults.Caption := '';
  bvViewResults.Visible := False;
  Invalidate;

  if FSearchMode = smPattern
    then fmDBSearch.frDBPatternPanel.frResults.Initialize
end;

procedure TfmDBSearch.ShowStatusMsg(s : WideString);
begin
  StatusBar.Panels[0].Text := s;
  Application.ProcessMessages
end;

function PatternSearchReady : boolean;
begin
  Result := Assigned(fmDBSearch) and Assigned(fmDBSearch.frDBPatternPanel)
end;

// ---------------------------------------------------------------------------

end.

