// ---------------------------------------------------------------------------
// -- Drago -- Handling of main panel ---------------- UViewBoardPanels.pas --
// ---------------------------------------------------------------------------

unit UViewBoardPanels;

// ---------------------------------------------------------------------------

interface

uses
  Controls, StdCtrls, ExtCtrls, Classes, UfrViewBoard, UGameTree;

procedure MainPanel_Lock;
procedure MainPanel_Unlock;
procedure MainPanel_Init(gv : TfrViewBoard);
procedure MainPanel_Clear(gv : TfrViewBoard);
procedure MainPanel_Add(gv : TfrViewBoard; x : TControl; aVisible, aClient : boolean);
function  MainPanel_Top(gv : TfrViewBoard; x : TControl) : integer;
procedure MainPanel_Show(gv : TfrViewBoard; x : TControl);
procedure MainPanel_Hide(gv : TfrViewBoard; x : TControl);
procedure MainPanel_Update(gv : TfrViewBoard; gt : TGameTree);

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  SpTBXDkPanels,
  DefineUi, Properties, UMainUtil, UStatus, UGMisc;

// -- Display lock and unlock

procedure MainPanel_Lock;
begin
  LockMainWindow(True)
end;

procedure MainPanel_Unlock;
begin
  LockMainWindow(False)
end;

// -- Registering of panel components

procedure MainPanel_Init(gv : TfrViewBoard);
begin
  with gv do
    begin
      pnTree.ParentBackground    := False;
      //pnStatus.ParentBackground  := False;

      frVariations.DoubleBuffered := True;
      mmComment.DoubleBuffered   := True;

      MainPanel_Clear(gv);
      MainPanel_Add(gv, pnStatus     , True , False);
      MainPanel_Add(gv, pnPlayers    , False, False);
      MainPanel_Add(gv, dpProblems   , False, False);
      MainPanel_Add(gv, dpReplayGame , False, False);
      MainPanel_Add(gv, gbResult     , False, False);
      MainPanel_Add(gv, gbResign     , False, False);
      //MainPanel_Add(gv, dpQuickSearch, False, False);

      frVariations.Visible := True
    end
end;

// -- Clearing of list of components

procedure MainPanel_Clear(gv : TfrViewBoard);
begin
  gv.MainPanelList := TList.Create
end;

// -- Addition of a component to the main panel

procedure MainPanel_Add(gv : TfrViewBoard; x : TControl; aVisible, aClient : boolean);
begin
  gv.MainPanelList.Add(x);

  x.Visible := aVisible;
  x.Parent  := gv.pnMain;
  x.Top     := MainPanel_Top(gv, x);
  if aClient
    then x.Align := alClient
    else x.Align := alTop;

  if x is TPanel
    then (x as TPanel   ).ParentBackground := False;
  if x is TGroupBox
    then (x as TGroupBox).ParentBackground := False;

  if x is TWinControl
    then //(x as TWinControl).DoubleBuffered := True
end;

// -- Calculation of top of components with regard to visible components

function MainPanel_Top(gv : TfrViewBoard; x : TControl) : integer;
var
  top, i : integer;
begin
  top := 0;
  i := 0;

  while (i < gv.MainPanelList.Count) and (TControl(gv.MainPanelList[i]) <> x) do
    begin
      if TControl(gv.MainPanelList[i]).Visible
        then inc(top, TControl(gv.MainPanelList[i]).Height);
      inc(i)
    end;

  if i = gv.MainPanelList.Count
    then Result := -1
    else Result := top
end;

// -- Display of a component in main panel

procedure MainPanel_Show(gv : TfrViewBoard; x : TControl);
begin
  if x.Visible
    then exit;

  try
    MainPanel_Lock;
    x. Visible := True;
  finally
    MainPanel_Unlock
  end
end;

// -- Hiding a component in main panel

procedure MainPanel_Hide(gv : TfrViewBoard; x : TControl);
begin
  if not x.Visible
    then exit;

  try
    MainPanel_Lock;
    x.Visible := False;
  finally
    MainPanel_Unlock
  end
end;

// -- Visibility of panes in side bar ----------------------------------------

procedure ForceFixedSize(dp : TSpTBXDockablePanel; height : integer);
begin
  dp.FixedDockedSize := False;
  dp.Resizable := True;
  dp.EffectiveHeight := height;
  dp.Tag := height;
  dp.FixedDockedSize := True;
  dp.Resizable := False;
end;

procedure HasSomeFeatures(gt : TGameTree; var hasGameInfo,
                                              hasVariation,
                                              hasNodeName,
                                              hasComment,
                                              hasTimeProp : boolean);
var
  s : string;
begin
  // remove \n and \t from game information format
  s := StringReplace(Settings.GameInfoPaneFormat, '\n' , ' ', [rfReplaceAll]);
  s := StringReplace(s                          , '\t' , ' ', [rfReplaceAll]);

  gt := gt.Root;
  hasGameInfo  := (gt <> nil) and HasFormatProperty(s, gt);
  hasNodeName  := (gt <> nil) and gt.HasTreeProp([prN]);
  hasComment   := (gt <> nil) and gt.HasTreeProp([prC]);
  hasTimeProp  := (gt <> nil) and gt.HasTreeProp([prBL, prWL]);

  hasVariation := True;
  while gt <> nil do
    if gt.NextVar <> nil
      then exit
      else gt := gt.NextNode;
  hasVariation := False
end;

// Panel strategy
// - never close a panel: it may have been opened by user

procedure UpdateOne(gv : TfrViewBoard; x : TControl; visible : boolean);
var
  prevVisible : boolean;
begin
  prevVisible := x.Visible;
  x.Visible := x.Visible or visible;

  if (prevVisible = False) and x.Visible then
    begin
      if x = gv.dpGameInfo then
        begin
          // call to SideBar API does not work (bad panel dim) when starting
          // game engine, with GameInfo visible if required plus images.
          ForceFixedSize(gv.dpGameInfo,
                         gv.dpGameInfo.Options.TitleBarMaxSize + gv.Panel1.Height);
          //gv.SideBarLayout.ChangeFixedSize (gv.dpGameInfo,
          //              gv.dpGameInfo.Options.TitleBarMaxSize + gv.Panel1.Height);
        end;

      gv.ShowPanelAtDefaultPos(x as TSpTBXDockablePanel)
    end
end;

procedure MainPanel_Update(gv : TfrViewBoard; gt : TGameTree);
var
  hasGameInfo, hasVariation, hasNodeName, hasComment : boolean;
begin
  // update description of current event (used also by timing display)
  HasSomeFeatures(gt, hasGameInfo, hasVariation, hasNodeName, hasComment,
                      gv.View.si.HasTimeProp);

  with gv do
    try
      // nop if ApplyQuiet
      if View.si.ApplyQuiet
        then exit;
        
      //MainPanel_Lock;
      SideBarDock.BeginUpdate;

      // move information
      UpdateOne(gv, pnStatus,   (Settings.VwMoveInfo = vwAlways) or
                                (Settings.VwMoveInfo = vwRequired));
      // game information
      // keep panel hidden in problem mode
      UpdateOne(gv, dpGameInfo, (View.si.MainMode <> muProblem) and
                                ((Settings.VwGameInfo = vwAlways) or
                                 ((Settings.VwGameInfo = vwRequired) and hasGameInfo)));
      // node name
      // keep panel hidden in problem mode
      UpdateOne(gv, dpNodeName, (View.si.MainMode <> muProblem) and
                                ((Settings.VwNodeName = vwAlways) or
                                 ((Settings.VwNodeName = vwRequired) and hasNodeName)));
      // time
      // keep panel hidden in problem mode
      // ForceShowTime forces time display for engine games
      UpdateOne(gv, dpTiming,   (View.si.MainMode <> muProblem) and
                                 (View.si.ForceShowTime or
                                  (Settings.VwTimeLeft = vwAlways) or
                                  ((Settings.VwTimeLeft = vwRequired) and View.si.HasTimeProp)));
      // variations
      // ShowVar disables display of variations during problem and replay modes
      UpdateOne(gv, dpVariations, View.si.ShowVar and
                               ((Settings.VwVariation = vwAlways) or
                               ((Settings.VwVariation = vwRequired) and hasVariation)));

      // game tree
      // ShowVar disables display of variations during problem and replay modes
      UpdateOne(gv, dpGameTree, View.si.ShowVar and
                               ((Settings.VwTreeView = vwAlways) or
                               ((Settings.VwTreeView = vwRequired) and hasVariation)));
      // comments
      UpdateOne(gv, dpComments, (Settings.VwComments = vwAlways) or
                               ((Settings.VwComments = vwRequired) and hasComment))
    finally
      SideBarDock.EndUpdate;
      //MainPanel_Unlock
    end;
end;

// ---------------------------------------------------------------------------

end.
