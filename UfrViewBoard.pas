// ---------------------------------------------------------------------------
// -- Drago -- Board view frame -------------------------- UfrViewBoard.pas --
// ---------------------------------------------------------------------------

unit UfrViewBoard;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  ExtCtrls, ComCtrls, TntStdCtrls, SpTBXControls, StdCtrls, Types, IniFiles,
  UfrVariations, Components,
  UViewMain, TB2Dock, SpTBXItem, SpTBXDkPanels, TB2Item,
  ImgList, TB2Toolbar, Menus, SpTBXEditors, USideBar, TntForms,
  UfrDBPatternResult, TntComCtrls;

type
  TfrViewBoard = class(TFrame)
    bvGoban: TBevel;
    imGoban: TImageEx;
    imImage: TImage;
    bvMain1: TBevel;
    bvMain2: TBevel;
    pnPlayers: TPanel;
    lbBlack: TTntLabel;
    lbBlackV: TTntLabel;
    lbWhite: TTntLabel;
    lbWhiteV: TTntLabel;
    pnImage: TPanel;
    edGobanFocus: TEdit;
    tmProblem: TTimer;
    tmAutoReplay: TTimer;
    tmEngine: TTimer;
    MultiDockLeft: TSpTBXMultiDock;
    MultiDockRight: TSpTBXMultiDock;
    VSplitter: TSpTBXSplitter;
    dpMain: TSpTBXDockablePanel;
    pnStatus: TSpTBXPanel;
    imPlayer: TImage;
    lbNextPlayer: TTntLabel;
    lbLastMove: TTntLabel;
    lbBlackPriso: TTntLabel;
    lbWhitePriso: TTntLabel;
    lbMoveNumberV: TTntLabel;
    lbBlackPrisoV: TTntLabel;
    lbWhitePrisoV: TTntLabel;
    lbPlayerV: TSpTBXLabel;
    mnShow: TSpTBXSubmenuItem;
    SpTBXRightAlignSpacerItem1: TSpTBXRightAlignSpacerItem;
    btMore: TSpTBXItem;
    dpProblems: TSpTBXDockablePanel;
    pnMain: TPanel;
    SideBarDock: TSpTBXMultiDock;
    dpVariations: TSpTBXDockablePanel;
    frVariations: TfrVariations;
    dpGameTree: TSpTBXDockablePanel;
    pnTree: TPanel;
    imTree: TImage;
    sbTreeH: TScrollBar;
    sbTreeV: TScrollBar;
    dpComments: TSpTBXDockablePanel;
    mmComment: TTntMemo;
    dpNodeName: TSpTBXDockablePanel;
    edNodeName: TTntEdit;
    dpTiming: TSpTBXDockablePanel;
    lbBLeft: TTntLabel;
    lbBLeftV: TTntLabel;
    imBlackStone: TImage;
    lbBlackStonesLeft: TLabel;
    lbWLeftV: TTntLabel;
    lbWLeft: TTntLabel;
    imWhiteStone: TImage;
    lbWhiteStonesLeft: TLabel;
    pbBlackStonesLeft: TSpTBXProgressBar;
    pbBlackTime: TSpTBXProgressBar;
    pbWhiteTime: TSpTBXProgressBar;
    pbWhiteStonesLeft: TSpTBXProgressBar;
    dpGameInfo: TSpTBXDockablePanel;
    Panel1: TPanel;
    pnGameInfoImages: TSpTBXPanel;
    imgBlack: TImage;
    imgWhite: TImage;
    lbGIBlack: TSpTBXLabel;
    lbGIWhite: TSpTBXLabel;
    lxGameInfo: TSpTBXListBox;
    mnSideBarSettings: TSpTBXItem;
    SpTBXItem2: TSpTBXItem;
    SpTBXItem3: TSpTBXItem;
    SpTBXItem4: TSpTBXItem;
    lbPb1: TTntLabel;
    lbPb2: TTntLabel;
    lbPb3: TTntLabel;
    lbPb1v: TTntLabel;
    lbPb2v: TTntLabel;
    lbPb3v: TTntLabel;
    lbSol4: TTntLabel;
    lbSol3: TTntLabel;
    lbSol1: TTntLabel;
    lbSol2: TTntLabel;
    lbPb4: TTntLabel;
    lbPb4v: TTntLabel;
    lbPb5: TTntLabel;
    lbPb5v: TTntLabel;
    lbSol6: TTntLabel;
    lbSol5: TTntLabel;
    dpReplayGame: TSpTBXDockablePanel;
    imGmHint: TImage;
    gbResult: TSpTBXDockablePanel;
    lbWhiteH: TTntLabel;
    lbTotW: TTntLabel;
    lbTotB: TTntLabel;
    lbTotal: TTntLabel;
    lbTerW: TTntLabel;
    lbTerritory: TTntLabel;
    lbTerB: TTntLabel;
    lbResult: TTntLabel;
    lbPriW: TTntLabel;
    lbPriso: TTntLabel;
    lbPriB: TTntLabel;
    lbKomiV: TTntLabel;
    lbKomi: TTntLabel;
    lbBlackH: TTntLabel;
    bvResult: TBevel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    gbResign: TSpTBXDockablePanel;
    lbResign: TTntLabel;
    lbGm1: TSpTBXLabel;
    lbGm2: TSpTBXLabel;
    lbGm3: TSpTBXLabel;
    lbGm4: TSpTBXLabel;
    lbGm1v: TSpTBXLabel;
    lbGm2v: TSpTBXLabel;
    lbGm3v: TSpTBXLabel;
    lbGm4v: TSpTBXLabel;
    lbGm5: TSpTBXLabel;
    imBlackTurn: TImage;
    imWhiteTurn: TImage;
    SpTBXItem1: TSpTBXItem;
    mnShowInCurrentTab: TSpTBXSubmenuItem;
    mnNodeName: TSpTBXItem;
    mnGameInfo: TSpTBXItem;
    mnTiming: TSpTBXItem;
    mnVariations: TSpTBXItem;
    mnGameTree: TSpTBXItem;
    mnComments: TSpTBXItem;
    dpPad: TSpTBXDockablePanel;
    dpQuickSearch: TSpTBXDockablePanel;
    frDBPatternResult: TfrDBPatternResult;
    btSearchSettings: TSpTBXItem;
    cbNodeName: TSpTBXComboBox;
    ToolButtonEx1: TToolButtonEx;
    ToolButtonEx2: TToolButtonEx;
    Panel2: TPanel;
    lbQuickSearch: TSpTBXLabel;
    Bevel3: TBevel;
    ImageListSideBar: TImageList;
    ilGradients: TImageList;
    constructor CreateFrame(aOwner, aParent : TComponent; aParentView : TViewMain);
    destructor Destroy; override;
    procedure FrameResize(Sender: TObject);
    procedure imGobanMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imGobanMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imGobanMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imGobanMouseEnter(Sender: TObject);
    procedure imGobanMouseLeave(Sender: TObject);
    procedure VSplitterCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure VSplitterMoved(Sender: TObject);
    procedure lbVariationClick(Sender: TObject);
    procedure tmProblemTimer(Sender: TObject);
    procedure edNodeNameChange(Sender: TObject);
    procedure mmCommentChange(Sender: TObject);
    procedure tmAutoReplayTimer(Sender: TObject);
    procedure pnTreeResize(Sender: TObject);
    procedure sbTreeHChange(Sender: TObject);
    procedure sbTreeVChange(Sender: TObject);
    procedure imTreeMouseDown(Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
    procedure mmCommentClick(Sender: TObject);
    procedure edNodeNameClick(Sender: TObject);
    procedure FrameMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FrameMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure tmEngineTimer(Sender: TObject);
    procedure dpMainDockChanged(Sender: TObject);
    procedure dpMainResize(Sender: TObject);
    procedure dpMainDrawCaptionPanel(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; const PaintStage: TSpTBXPaintStage;
      var PaintDefault: Boolean);
    procedure dpTimingResize(Sender: TObject);
    procedure mnTimingClick(Sender: TObject);
    procedure mnGameTreeClick(Sender: TObject);
    procedure mnNodeNameClick(Sender: TObject);
    procedure mnVariationsClick(Sender: TObject);
    procedure mnCommentsClick(Sender: TObject);
    procedure mnShowClick(Sender: TObject);
    procedure btMoreClick(Sender: TObject);
    procedure mnGameInfoClick(Sender: TObject);
    procedure CloseQueryCloseSideBarPanel(Sender: TObject; var CanClose: Boolean);
    procedure lxGameInfoDrawItemBackground(Sender: TObject;
      ACanvas: TCanvas; var ARect: TRect; Index: Integer;
      const State: TOwnerDrawState; const PaintStage: TSpTBXPaintStage;
      var PaintDefault: Boolean);
    procedure dpGameInfoResize(Sender: TObject);
    procedure cbNodeNameSelect(Sender: TObject);
    procedure dpQuickSearchClose(Sender: TObject);
  private
    LastWidth     : integer;
    LastHeight    : integer;
    IsPaneDocked  : boolean;
    FOnMinimizeSplitter : TNotifyEvent;
    procedure DoUpdateView;
    procedure DrawPlayer(img : TImage; bmp : TBitmap; default : integer);
    procedure AdjustPanelsFont;
    procedure InitSideBar;
    procedure InitSideBarLayout;
    function  OwnerView : TViewMain;
  public
    View : TViewMain;
    AllowResize   : boolean;
    MainPanelList : TList;
    SideBarLayout : TDockPanelLayout;
    procedure Start;
    procedure UpdateView(full : boolean = True);
    procedure Translate;
    procedure EnterView;
    procedure ExitView;
    procedure SaveIniFile(iniFile : TMemIniFile; section : string);
    procedure LoadIniFile(iniFile : TMemIniFile; section : string);
    procedure ResizeGoban;
    procedure ResizeAutoReplayBars;
    procedure SetEngineTimer(player : integer; state : boolean);
    procedure SetFocusOnGoban;
    procedure UpdatePlayer(player : integer);
    procedure UpdateMoveNumber(number : integer);
    procedure UpdatePrisoners(nB, nW : integer);
    procedure UpdateGameEnginePlayers;
    procedure UpdateGameEngineTurn(color : integer);
    procedure UpdateTiming(player : integer; const value : string); overload;
    procedure StartTiming(timeLeft : real; stonesLeft : integer); overload;
    procedure StartTiming(player : integer; timeLeft : real; stonesLeft : integer); overload;
    procedure UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer); overload;
    procedure UpdateTimeLeft(player : integer; timeLeft : real);
    procedure UpdateStonesLeft(player : integer; stonesLeft : integer);
    procedure UpdateNodeName(const s : string);
    procedure LoadListOfNodeNames(list : TStringList);
    procedure ClearComments;
    procedure UpdateComments(const s : string);
    procedure UpdateGameInfoPanel(bmpBlack, bmpWhite : TBitmap;
                                  infoStr : WideString);
    procedure ShowGameResult(const pv : string);
    procedure DrawReplayHint(ratioCorrect, ratioWrong : integer);
    procedure imGobanMouseDownNop(Sender : TObject;
                                   Button : TMouseButton;
                                   Shift  : TShiftState;
                                   X, Y   : Integer);
    procedure SaveSideBar(iniFile : TMemIniFile; section : string);
    procedure LoadSideBar(iniFile : TMemIniFile; section : string);
    procedure ShowPanelAtPos(dp : TSpTBXDockablePanel; pos : integer);
    procedure ShowPanelAtDefaultPos(dp : TSpTBXDockablePanel);
    procedure TogglePanel(dp : TSpTBXDockablePanel);
    procedure ShowQuickSearchPanel;
    //procedure HideQuickSearchPanel;
    procedure RequestHideQuickSearchPanel;
    procedure ProcessHideQuickSearchPanel;
    property OnMinimizeSplitter : TNotifyEvent read FOnMinimizeSplitter write FOnMinimizeSplitter;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  Dialogs, StrUtils,
  TntGraphics,
  Define, DefineUi, Std, Translate, UStatus, Main, UViewBoardPanels,
  UMainUtil, VclUtils, UGoban, UViewBoard, Ugcom, UActions, UView,
  UProblems, UAutoReplay, UTreeView, UGMisc, Ux2y, UStatusMain, UEngines,
  UBoardViewCanvas, UStones;

// -- Initialisation ---------------------------------------------------------

function TfrViewBoard.OwnerView : TViewMain;
begin
  Result := View
end;

constructor TfrViewBoard.CreateFrame(aOwner, aParent : TComponent;
                                      aParentView : TViewMain);
begin
  inherited Create(aOwner);

  Parent := aParent as TWinControl;
  View := aParentView;
  Align := alClient;
end;

destructor TfrViewBoard.Destroy;
begin
  MainPanelList.Free;
  SideBarLayout.Free;
  if Assigned(frDBPatternResult)
    then frDBPatternResult.Finalize;
    
  inherited Destroy
end;

procedure TfrViewBoard.Start;
var
  x : integer;
begin
  // block calls to FrameResize
  OnResize := nil;

  // fight against flickering
  AvoidFlickering([self, pnImage, pnMain, pnTree, mmComment]);
  dpMain.DoubleBuffered       := True;
  dpVariations.DoubleBuffered := True;
  dpGameTree.DoubleBuffered   := True;
  dpComments.DoubleBuffered   := True;

  frVariations.lbVariation.DoubleBuffered := True;
  frVariations.DoubleBuffered := True;
  frVariations.ParentBackground := False;

  MultiDockRight.DoubleBuffered := True;

  // erase captions
  pnImage.Caption := '';
  pnMain.Caption  := '';

  // align upper and lower bevels
  bvMain1.Align   := alTop;
  bvMain2.Align   := alBottom;
  bvMain2.Visible := False;

  // set position of vertical splitter
  if fmMain.PageCount = 1
    then
      if StatusMain.fmMainPlace = ''
        then x := MultiDockRight.Width // design size
        else x := ClientWidth - VSplitter.Width - NthInt(StatusMain.fmMainPlace, 11, ',')
    else
      with fmMain.ActiveViewBoard.frViewBoard do
        x := MultiDockRight.Width;
  MultiDockRight.Width := x; // call FrameResize

  // init main panel
  MainPanel_Init(self);

  // adjust position and size of dockable panels
  InitSideBar;

  IsPaneDocked    := True;
  pnImage.Align   := alClient;
  VSplitter.Visible := True;

  // align window background in main board panel
  imImage.Parent  := pnImage; // Call
  imImage.Align   := alClient;
  bvGoban.Parent  := pnImage;
  imGoban.Parent  := pnImage;

  // set dimension constraints
  pnMain.Constraints.MinHeight  := pnStatus.Height;
  //pnMain.Constraints.MinWidth   := pnStatus.Width;
  pnImage.Constraints.MinHeight := pnStatus.Height;
  pnImage.Constraints.MinWidth  := pnStatus.Width; // 220 - 5;

  // irrelevant(?)
  //Constraints.MinHeight         := pnStatus.Height;
  //Constraints.MinWidth          := 220 - 5 + pnStatus.Width + 20;

  // init timers and progress bars
  tmProblem.Enabled := False;
  tmAutoReplay.Enabled := False;
  pbBlackTime.Visible := False;
  pbWhiteTime.Visible := False;

  // save current dimensions
  LastWidth  := Width;
  LastHeight := Height;

  // init goban
  imGoban.OnMouseEnter := nil;
  imGoban.OnMouseLeave := nil;

  // allow resizing
  AllowResize := True;

  // set color of text panels
  InitSideBarLayout;
  {Do}UpdateView(False);

  Font.Style := [];
(*
  MainPanel_Update(self, View.gt);
(**)

  // init imPlayer
  imPlayer.Canvas.brush.color := clLtGray;
  imPlayer.Canvas.FillRect(Rect(0, 0, 18, 18));
  lxGameInfo.Items.Text := '';
  //lxGameInfo.SetTabsStops;

  // init edNodeName
  edNodeName.clear;

  // init mmComment
  mmComment.Font.Size := Settings.ComFontSize;

  // init imTree
 //imTree.Width  := pnTree.Width  - sbTreeV.Width;
 //imTree.Height := pnTree.Height - sbTreeH.Height;
  imTree.Picture.Bitmap.Width  := imTree.Width;
  imTree.Picture.Bitmap.Height := imTree.Height;
  imTree.Canvas.FillRect(Rect(0, 0, imTree.Width, imTree.Height));

  // enable calls to FrameResize and resize
  OnResize := FrameResize;
  FrameResize(nil);

  //StatusBarQuickSearch.Panels.Add;
end;

// -- Update after option dialog display -------------------------------------

procedure TfrViewBoard.UpdateView(full : boolean = True);
begin
  // update view background
  Settings.WinBackground.Apply(imImage.Canvas, ControlRect(imImage));

  // update view
  //InitSideBarLayout;
(*
  MainPanel_Update(self, View.gt);
*)
  mmComment.Font.Size := Settings.ComFontSize;
  mmComment.Update;

  // set color of text panels
  DoUpdateView;
  //if Assigned(frDBPatternPanel)
  //  then frDBPatternPanel.Color := Settings.TextPanelColor;

  // update game tree
  if full
    then TV_Refresh(View as TViewBoard)
end;

procedure TfrViewBoard.DoUpdateView;
begin
  // set color of text panels
  pnStatus  .Color := Settings.TextPanelColor;
  gbResult  .Color := Settings.TextPanelColor;
  gbResign  .Color := Settings.TextPanelColor;
  pnPlayers .Color := Settings.TextPanelColor;
end;

// -- Translation ------------------------------------------------------------

// Must be translated explicitly as it is not reconstructed after changing
// language.

procedure TfrViewBoard.Translate;
var
  w, x : integer;
begin
  // player panel
  lbNextPlayer.Caption := U('Player');
  lbLastMove.Caption   := U('Last move');
  lbBlackPriso.Caption := U('Black prisoners');
  lbWhitePriso.Caption := U('White prisoners');

  w := Max(lbBlackPriso.Canvas.TextWidth('Black prisoners'),
           Max(lbBlackPriso.Width, lbWhitePriso.Width));
  x := lbNextPlayer.Left + w + imPlayer.Width + 5;

  lbPlayerV.Left       := x;
  lbMoveNumberV.Left   := x;
  lbBlackPrisoV.Left   := x;
  lbWhitePrisoV.Left   := x;
  imPlayer.Left        := x - imPlayer.Width - 5;
  UpdatePlayer(View.si.Player);

  // timing panel
  dpTiming.Caption     := U('Timing');
  lbBLeft.Caption      := U('Black');
  lbWLeft.Caption      := U('White');

  // node name panel
  dpNodeName.Caption   := U('Node name');

  // game info panel
  dpGameInfo.Caption   := U('Game information2');
  lbGIBlack.Caption    := U('Black');
  lbGIWhite.Caption    := U('White');

  // variation panel
  dpVariations.Caption := U('Variations');

  // game tree panel
  dpGameTree.Caption := U('Game tree');

  // comment panel
  dpComments.Caption := U('Comments');

  // problem boxes
  if View.si.MainMode in [muProblem, muFree] then
    begin
      DisplayProblemBoxes(self);
      RefreshResultBox(self)
    end;

  // engine box
  lbBlack.Caption := U('Black');
  lbWhite.Caption := U('White');
  if View.si.MainMode = muEngineGame then
    if View.si.EngineColor = Black
      then lbWhiteV.Caption := U('You')
      else lbBlackV.Caption := U('You');

  // replay box
  if View.si.MainMode = muReplayGame 
    then DisplayReplayBox(View as TViewBoard);

  // pattern search panel
  dpQuickSearch.Caption := U('Pattern search');

  // sidebar popup menu
  mnShowInCurrentTab.Caption := U('Show in current tab...');
  mnGameInfo.Caption   := U('Game information');
  mnNodeName.Caption   := U('Node name');
  mnTiming.Caption     := U('Timing');
  mnVariations.Caption := U('Variations');
  mnGameTree.Caption   := U('Game tree');
  mnComments.Caption   := U('Comments');
end;

// -- Focus ------------------------------------------------------------------

procedure TfrViewBoard.EnterView;
begin
  if dpMain.CurrentDock = nil
    then dpMain.Visible := True
end;

procedure TfrViewBoard.ExitView;
begin
  if dpMain.CurrentDock = nil
    then dpMain.Visible := False
end;

procedure TfrViewBoard.SetFocusOnGoban;
begin
  View.si.MouseWheelOnGoban := True;

  if Settings.KeybComment
    then // nop, do not change focus
    else
      if (fmMain.ActiveControl <> edGobanFocus) and edGobanFocus.CanFocus then
        begin
          // avoid cursor blinking in comments
          fmMain.ActiveControl := edGobanFocus;
          Actions.EnableEditShortcuts(True)
        end
end;

procedure TfrViewBoard.mmCommentClick(Sender: TObject);
begin
  View.si.MouseWheelOnGoban := False;
  Actions.EnableEditShortcuts(False)
end;

procedure TfrViewBoard.edNodeNameClick(Sender: TObject);
begin
  Actions.EnableEditShortcuts(False)
end;

// -- Resizing ---------------------------------------------------------------

procedure TfrViewBoard.VSplitterCanResize(Sender : TObject;
                                           var NewSize: Integer;
                                           var Accept: Boolean);
var
  newPnMainSize, newPnImageSize : integer;
begin
  if View.si.ModeInter = kimPS
    then Accept := False
    else
      begin
        newPnMainSize := NewSize;
        newPnImageSize := ClientWidth - (VSplitter.Width + newPnMainSize);
        Accept := (newPnImageSize >= pnImage.Constraints.MinWidth)
      end
end;

procedure TfrViewBoard.VSplitterMoved(Sender: TObject);
begin
  try
    LockControl(self, True);
    ResizeAutoReplayBars;
    ResizeGoban;

    if Assigned(OnMinimizeSPlitter)
      then OnMinimizeSPlitter(Sender)
  finally
    LockControl(self, False)
  end
end;

procedure TfrViewBoard.FrameResize(Sender: TObject);
var
  delta : integer;
begin
  //exit;
  //*//if not AllowResize
  //*//  then exit;

  LockMainWindow(True);
  try
    ParentBackground := True;

    delta := Width - LastWidth;

    if Height = LastHeight
      then
        begin
          if pnMain.Width + delta > pnMain.Constraints.MinWidth
            then frVariations.Invalidate
            else
              if pnImage.Width + delta > pnImage.Constraints.MinWidth
                then
                  begin
                    pnImage.Width := pnImage.Width + delta;
                    (*
                    ResizeGoban
                    *)
                  end
        end
      else
        if (pnImage.Width + delta > pnImage.Constraints.MinWidth) and
          (pnMain.Width - delta > pnMain.Constraints.MinWidth)
          then
            begin
              pnImage.Width := pnImage.Width + delta;
              (*
              ResizeGoban
              *)
            end;

    (**)
    ResizeGoban;
    (**)
    ResizeAutoReplayBars;
    LastWidth  := Width;
    LastHeight := Height;

    ParentBackground := False
  finally
    LockMainWindow(False)
  end
end;

procedure TfrViewBoard.ResizeGoban;
var
  gb : TGoban;
  aWidth, aHeight : integer;
begin
  // force dimensions of background image
  imImage.Width := pnImage.Width;
  imImage.Height := pnImage.Height;
  imImage.Picture.Bitmap.Width := pnImage.Width;
  imImage.Picture.Bitmap.Height := pnImage.Height;

  // update view background
  Settings.WinBackground.Apply(imImage.Canvas, ControlRect(imImage));

  gb := View.gb; 
  aWidth  := pnImage.Width - 4;
  aHeight := pnImage.Height - 4;

  gb.Resize(aWidth, aHeight);
  with gb.BoardView as TBoardViewCanvas do
    begin
      imGoban.Left   := (aWidth  - ExtWidth ) div 2 + 2;
      imGoban.Top    := (aHeight - ExtHeight) div 2 + 2;
      imGoban.Width  := ExtWidth;
      imGoban.Height := ExtHeight;
      imGoban.Picture.Bitmap.Width  := ExtWidth;
      imGoban.Picture.Bitmap.Height := ExtHeight;
    end;
  gb.Draw;
  View.ReApplyNode;

  bvGoban.Width  := imGoban.Width + 4;
  bvGoban.Height := imGoban.Height + 4;
  bvGoban.Top    := imGoban.Top - 2;
  bvGoban.Left   := imGoban.Left - 2
end;

procedure TfrViewBoard.dpTimingResize(Sender: TObject);
begin
  ResizeAutoReplayBars
end;

// -- Docking ----------------------------------------------------------------

procedure TfrViewBoard.dpMainDockChanged(Sender: TObject);
begin
  ResizeGoban;

  if dpMain.CurrentDock = MultiDockRight
    then
      begin
        dpMain.Align    := alRight;
        VSplitter.Align := alRight;
        pnImage.Align   := alCLient
      end;

  if dpMain.CurrentDock = MultiDockLeft
    then
      begin
        // it seems necessary to force splitter
        VSplitter.Visible := True;
        VSplitter.Left    := dpMain.Width;

        dpMain.Align      := alLeft;
        VSplitter.Align   := alLeft;
        pnImage.Align     := alCLient
      end
end;

procedure TfrViewBoard.dpMainResize(Sender: TObject);
var
  w : integer;
begin
  w := dpMain.ClientWidth;

  LockControl(SideBarDock, True);
  SideBarDock.BeginUpdate;
  try
    SideBarDock.Width := w;
(*
    dpMain.DefaultDockedSize := w;
    dpGameInfo.DefaultDockedSize := w;
    dpNodeName.DefaultDockedSize := w;
    dpTiming.DefaultDockedSize := w;
    dpVariations.DefaultDockedSize := w;
    dpGameTree.DefaultDockedSize := w;
    dpComments.DefaultDockedSize := w;
    dpReplayGame.DefaultDockedSize := w;
*)
  finally
    SideBarDock.EndUpdate;
    LockControl(SideBarDock, False)
  end
end;

// -- Persistence ------------------------------------------------------------

procedure TfrViewBoard.SaveIniFile(iniFile : TMemIniFile; section : string);
begin
  iniFile.WriteBool(section, 'VSpliterMiniMized', VSplitter.Minimized);
  if VSplitter.Minimized
    then VSplitter.Restore;

  SaveSideBar(inifile, section)
end;

procedure TfrViewBoard.LoadIniFile(iniFile : TMemIniFile; section : string);
begin
  LoadSideBar(inifile, section);

  // close quick search panel if it has been let open for some reason
  if dpQuickSearch.Visible
    then SideBarLayout.HidePanel(dpQuickSearch);

  ResizeGoban;
  VSplitter.Left := pnImage.Width;

  if iniFile.ReadBool(section, 'VSpliterMiniMized', False)
    then VSplitter.Minimize;

  //UpdateView
end;

// -- Drawing of gripper -----------------------------------------------------

procedure TfrViewBoard.dpMainDrawCaptionPanel(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; const PaintStage: TSpTBXPaintStage;
  var PaintDefault: Boolean);
const
  upColor = clWhite;
  dnColor = $A0A0A0;
  offsetY = 1;
var
  x1, x2, y : integer;
begin
  // The event is called several time in a row, with various coordinates,
  // including negative top left corner. As I have no way to erase completely
  // the rectangle with this various coordinates, I test as follow. Hope it
  // is ok.
  if ARect.Left >= -1
    then exit;
  if PaintStage = pstPrePaint
    then exit;

  x1 := ARect.Right - 25 - (dpMain.Width - 32);
  x2 := ARect.Right - 25 - 5;
  y  := offsetY;
  with ACanvas do
    begin
      MoveTo(x1, y + 0);
      Pen.Color := upColor;
      LineTo(x2, y + 0);
      MoveTo(x1, y + 1);
      Pen.Color := dnColor;//clScrollBar;
      LineTo(x2, y + 1);
      MoveTo(x1, y + 2);
      Pen.Color := dnColor;
      //LineTo(x2, y + 2);

      MoveTo(x1, y + 4);
      Pen.Color := upColor;
      LineTo(x2, y + 4);
      MoveTo(x1, y + 5);
      Pen.Color := dnColor;//clScrollBar;
      LineTo(x2, y + 5);
      MoveTo(x1, y + 6);
      Pen.Color := dnColor;
      //LineTo(x2, y + 6);
    end;

  PaintDefault := False
end;

// -- Mouse events -----------------------------------------------------------

procedure TfrViewBoard.FrameMouseWheelUp(Sender : TObject;
                                          Shift  : TShiftState;
                                          MousePos : TPoint;
                                          var Handled : Boolean);
begin
  Handled := true;

  if Settings.WheelGoban
    // wheel always for goban
    then Actions.acPrevMove.Execute
    // wheel depends on position
    else
      if View.si.MouseWheelOnGoban
        then Actions.acPrevMove.Execute
        else SendMessage(mmComment.Handle, EM_LINESCROLL, 0, -1)
end;

procedure TfrViewBoard.FrameMouseWheelDown(Sender : TObject;
                                            Shift  : TShiftState;
                                            MousePos : TPoint;
                                            var Handled : Boolean);
begin
  Handled := true;

  if Settings.WheelGoban
    // wheel always for goban
    then Actions.acNextMove.Execute
    // wheel depends on position
    else
      if View.si.MouseWheelOnGoban
        then Actions.acNextMove.Execute
        else SendMessage(mmComment.Handle, EM_LINESCROLL, 0, +1)
end;

// -- Board image events -----------------------------------------------------

procedure TfrViewBoard.imGobanMouseDown(Sender : TObject;
                                   Button : TMouseButton;
                                   Shift  : TShiftState;
                                   X, Y   : Integer);
begin
  if Status.EnableGobanMouseDn and ((Button = mbLeft) or (Button = mbRight))
                               and View.gb.InsideBoard(X, Y)
    then GobanMouseDown(View as TViewBoard, X, Y, Button, Shift)
end;

procedure TfrViewBoard.imGobanMouseDownNop(Sender : TObject;
                                           Button : TMouseButton;
                                           Shift  : TShiftState;
                                           X, Y   : Integer);
begin
  // nop
end;

procedure TfrViewBoard.imGobanMouseMove(Sender : TObject;
                                        Shift  : TShiftState;
                                        X, Y   : Integer);
begin
  SetFocusOnGoban;

  if View.gb.InsideBoard(X, Y) then
    begin
      if ssLeft in Shift
        then GobanMouseMove(View as TViewBoard, X, Y, mbLeft, Shift);
      if ssRight in Shift
        then GobanMouseMove(View as TViewBoard, X, Y, mbRight, Shift)
    end
end;

procedure TfrViewBoard.imGobanMouseUp(Sender : TObject;
                                      Button : TMouseButton;
                                      Shift  : TShiftState;
                                      X, Y   : Integer);
begin
  if True or View.gb.InsideBoard(X, Y) //and (ssLeft in Shift)
    then GobanMouseUp(View as TViewBoard, X, Y, Button, Shift)
end;

// called in fmMain OnMouseUp handler
procedure RButtonUpCallBack;
begin
  (fmMain.ActiveView as TViewBoard).frViewBoard.imGobanMouseUp(nil, mbRight, [], 0, 0)
end;

procedure TfrViewBoard.imGobanMouseEnter(Sender: TObject);
begin
  Screen.Cursor := crZone;
  fmMain.OnMessageRButtonUp := nil
end;

procedure TfrViewBoard.imGobanMouseLeave(Sender: TObject);
begin
  Screen.Cursor := crDefault;
  fmMain.OnMessageRButtonUp := RButtonUpCallBack
end;

// -- Variation list box events ----------------------------------------------

procedure TfrViewBoard.lbVariationClick(Sender: TObject);
begin
  LockControl(Sender as TWinControl, True);
  GotoVar(View as TViewBoard, (Sender as TTntListBox).ItemIndex);
  LockControl(Sender as TWinControl, False)
end;

// -- TreeView events --------------------------------------------------------

procedure TfrViewBoard.pnTreeResize(Sender: TObject);
begin
  TV_Update(View as TViewBoard, sbTreeV.Position, sbTreeH.Position);
end;

procedure TfrViewBoard.sbTreeHChange(Sender: TObject);
begin
  TV_Update(View as TViewBoard, sbTreeV.Position, sbTreeH.Position)
end;

procedure TfrViewBoard.sbTreeVChange(Sender: TObject);
begin
  TV_Update(View as TViewBoard, sbTreeV.Position, sbTreeH.Position)
end;

procedure TfrViewBoard.imTreeMouseDown(Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer);
begin
  SetFocusOnGoban;

  // TODO: should be handled with actions 
  if View.si.DbQuickSearch = qsReady
    then View.si.DbQuickSearch := qsOpen;

  TV_UpdatePointerXY(View as TViewBoard, X, Y)
end;

// -- Problem timer events ---------------------------------------------------

procedure TfrViewBoard.tmProblemTimer(Sender: TObject);
begin
  UProblems.UpdateProblemTimer(View as TViewBoard)
end;

// -- Node names and comments events -----------------------------------------

procedure TfrViewBoard.edNodeNameChange(Sender: TObject);
begin
  if Screen.ActiveControl = edNodeName
    then InputNodeName(View as TViewBoard)
end;

procedure TfrViewBoard.mmCommentChange(Sender: TObject);
begin
  if Screen.ActiveControl = mmComment
    then InputComments(View as TViewBoard)
end;

// -- Autoreplay events ------------------------------------------------------

procedure TfrViewBoard.tmAutoReplayTimer(Sender: TObject);
begin
  DoAutoReplayTimer(View as TViewBoard)
end;

// -- Resizing of timing progress bars ---------------------------------------

procedure TfrViewBoard.ResizeAutoReplayBars;
var
  x0, x1 : integer;
  showProgressBars : boolean;
begin
  x0 := lbBLeftV.Left + lbBLeftV.Canvas.TextWidth('00:00:00') + 5;
//x0 := lbPlayerV.Left;
  x1 := dpTiming.Width - 10;

  pbBlackTime.Left := x0;
  pbWhiteTime.Left := x0;
  pbBlackTime.Width := x1 - x0;
  pbWhiteTime.Width := x1 - x0;

  pbBlackStonesLeft.Left := x0;
  pbWhiteStonesLeft.Left := x0;
  pbBlackStonesLeft.Width := x1 - x0;
  pbWhiteStonesLeft.Width := x1 - x0;

  pbBlackTime.Visible := True;
  pbWhiteTime.Visible := True;

  // progress bars are visible only during engine games and replay mode (updated in UAutoReplay)
  showProgressBars          := (View.si.MainMode = muEngineGame);
  pbBlackTime.Visible       := showProgressBars;
  pbWhiteTime.Visible       := showProgressBars;
  pbBlackStonesLeft.Visible := showProgressBars;
  pbWhiteStonesLeft.Visible := showProgressBars;

  // align stones in timing panel with stone in player panel
  imBlackStone.Left := x0 - imBlackStone.Width - 11;
  imWhiteStone.Left := x0 - imWhiteStone.Width - 11;
end;

// -- Engine game events -----------------------------------------------------

procedure TfrViewBoard.SetEngineTimer(player : integer; state : boolean);
begin
end;

procedure TfrViewBoard.tmEngineTimer(Sender: TObject);
begin
  ApplyGameTimer(View as TViewBoard)
end;

// -- View update ------------------------------------------------------------

// Update player to play

procedure TfrViewBoard.UpdatePlayer(player : integer);
var
  s : WideString;
  stoneParams : TStoneParams;
  stone : TStone;
begin
  case player of
    Black : s := U('Black');
    White : s := U('White');
    else { nop }
  end;

  stoneParams := TStoneParams.Create;
  stoneParams.SetParams(dsDefault,
                        Settings.LightSource,
                        Settings.TextPanelColor,
                        Settings.CustomLightSource,
                        '',
                        '',
                        Settings.AppPath);
  stone := GetStone(player, 8, stoneParams);
  stoneParams.Free;

  imPlayer.Canvas.Brush.Color := Settings.TextPanelColor;
  imPlayer.Canvas.FillRect(rect(0, 0, imPlayer.Width, imPlayer.Height));

  stone.Draw(imPlayer.Canvas, 8, 8);
  //imPlayer.Repaint;
  lbPlayerV.Caption := s;
  lbPlayerV.Width := Min(lbPlayerV.Width, pnStatus.Width - lbPlayerV.Left - 5)
end;

// Update move number

procedure TfrViewBoard.UpdateMoveNumber(number : integer);
begin
  if number = 0
    then lbMoveNumberV.Caption := '-'
    else lbMoveNumberV.Caption := IntToStr(number)
end;

// Update numbers of prisoners

procedure TfrViewBoard.UpdatePrisoners(nB, nW : integer);
begin
  lbBlackPrisoV.Caption := IntToStr(nB);
  lbWhitePrisoV.Caption := IntToStr(nW)
end;

// Update game engine players

procedure TfrViewBoard.UpdateGameEnginePlayers;
begin
  MainPanel_Show(self, pnPlayers);
  lbBlackV.Left := lbPlayerV.Left;
  lbWhiteV.Left := lbPlayerV.Left;
  imBlackTurn.Left := imPlayer.Left;
  imWhiteTurn.Left := imPlayer.Left;

  if View.si.EngineColor = Black
    then
      begin
        lbBlackV.Caption := Settings.PlayingEngine.FName;
        lbWhiteV.Caption := U('You')
      end
    else
      begin
        lbBlackV.Caption := U('You');
        lbWhiteV.Caption := Settings.PlayingEngine.FName
      end;
end;

procedure TfrViewBoard.UpdateGameEngineTurn(color : integer);
begin
  imBlackTurn.Canvas.Brush.Color := pnPlayers.Color;
  imBlackTurn.Canvas.FillRect(Rect(0, 0, 16, 16));
  imWhiteTurn.Canvas.Brush.Color := pnPlayers.Color;
  imWhiteTurn.Canvas.FillRect(Rect(0, 0, 16, 16));

  if color = Black
    then
      if View.si.EngineColor = Black
        then ImageListSideBar.Draw(imBlackTurn.Canvas, 0, 0, 4)
        else ImageListSideBar.Draw(imBlackTurn.Canvas, 0, 0, 3)
    else
      if View.si.EngineColor = Black
        then ImageListSideBar.Draw(imWhiteTurn.Canvas, 0, 0, 3)
        else ImageListSideBar.Draw(imWhiteTurn.Canvas, 0, 0, 4)
end;

// Update timing

procedure TfrViewBoard.UpdateTiming(player : integer; const value : string);
begin
  if player = Black
    then lbBLeftV.Caption := value
    else lbWLeftV.Caption := value
end;

procedure TfrViewBoard.StartTiming(timeLeft : real; stonesLeft : integer);
begin
  StartTiming(Black, timeLeft, stonesLeft);
  StartTiming(White, timeLeft, stonesLeft);
end;

procedure TfrViewBoard.StartTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
  if player = Black
    then
      begin
        pbBlackTime.Min       := 0;
        pbBlackStonesLeft.Min := 0;
        pbBlackTime.Max       := Round(timeLeft);
        pbBlackStonesLeft.Max := stonesLeft;
        UpdateTiming(Black, timeLeft, stonesLeft);
      end
    else
      begin
        pbWhiteTime.Min       := 0;
        pbWhiteStonesLeft.Min := 0;
        pbWhiteTime.Max       := Round(timeLeft);
        pbWhiteStonesLeft.Max := stonesLeft;
        UpdateTiming(White, timeLeft, stonesLeft)
      end
end;

procedure TfrViewBoard.UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
  UpdateTimeLeft(player, timeLeft);
  (*if stonesLeft > -1
    then*) UpdateStonesLeft(player, stonesLeft)
end;

procedure TfrViewBoard.UpdateTimeLeft(player : integer; timeLeft : real);
var
  s : string;
begin
  // time left undefined if argument < 0
  s := iff(timeLeft < 0, '-', SecToTime(timeLeft));

  if player = Black
    then
      begin
        lbBLeftV.Caption := SecToTime(timeLeft);
        pbBlackTime.Position := Round(timeLeft);
      end
    else
      begin
        lbWLeftV.Caption := SecToTime(timeLeft);
        pbWhiteTime.Position := Round(timeLeft);
      end
end;

procedure TfrViewBoard.UpdateStonesLeft(player : integer; stonesLeft : integer);
var
  s : string;
begin
  // number of stones left undefined if argument < 0
  s := iff(stonesLeft < 0, '-', IntToStr(stonesLeft));

  if player = Black
    then
      begin
        // applying TM initializes progress bar max to 0, max is then set to
        // number of stones at the first OB property
        if stonesLeft < 0
          then pbBlackStonesLeft.Max := 0
          else
            if pbBlackStonesLeft.Max = 0 then
              begin
                pbBlackStonesLeft.Max := stonesLeft + 1;
                // devrait pas etre là, A VIRER
                //pbBlackTime.Max := Round(OverTimePeriod(View.gt, stonesLeft + 1))
              end;

        lbBlackStonesLeft.Caption := s;
        pbBlackStonesLeft.Position := stonesLeft;
      end
    else
      begin
        // ditto
        if stonesLeft < 0
          then pbWhiteStonesLeft.Max := 0
          else
            if pbWhiteStonesLeft.Max = 0 then
              begin
                pbWhiteStonesLeft.Max := stonesLeft + 1;
                // TODO: check and remove
                //pbWhiteTime.Max := Round(OverTimePeriod(View.gt, stonesLeft + 1))
              end;

        lbWhiteStonesLeft.Caption := s;
        pbWhiteStonesLeft.Position := stonesLeft
      end
end;

// Update node name

procedure TfrViewBoard.UpdateNodeName(const s : string);
begin
  edNodeName.Text := CPDecode(pv2txt(s), View.si.GameEncoding);
  cbNodeName.Text := CPDecode(pv2txt(s), View.si.GameEncoding);
end;

// Update node name combo box. List initialized in TViewBoard.LoadListOfNodeNames
// depth first order

procedure TfrViewBoard.LoadListOfNodeNames(list : TStringList);
var
  i : integer;
begin
  cbNodeName.Items.Clear;
  for i := 0 to list.Count - 1 do
    cbNodeName.Items.AddObject(list[i], list.Objects[i])
end;

procedure TfrViewBoard.cbNodeNameSelect(Sender: TObject);
var
  i : integer;
begin
  i := cbNodeName.Items.IndexOf(cbNodeName.Text);
  if i > -1
    then (OwnerView as TViewBoard).MoveToNodeName(cbNodeName.Text,
                                                   cbNodeName.Items.Objects[i])
end;

// Update comments

procedure TfrViewBoard.ClearComments;
begin
  mmComment.Clear
end;

procedure TfrViewBoard.UpdateComments(const s : string);
begin
  UpdateMemoComment(mmComment, CPDecode(pv2txt(s), View.si.GameEncoding))
end;

// Engine game result

procedure TfrViewBoard.ShowGameResult(const pv : string);
var
  l : TStringDynArray;
  s : WideString;
  w, d : integer;
begin
  Split(pv2str(pv), l, ':');

  if (Length(l) < 8) or                // result is an empty string
     (View.gb.ColorTrans = ctReverse)   // result is irrelevant
    then with gbResign do
      begin
        MainPanel_Show(self, gbResign);
        Caption          := U('Result');
        lbResign.Caption := 'No result'
      end
  else if l[7][3] = 'R'
    then with gbResign do
      begin
        MainPanel_Show(self, gbResign);
        Caption          := U('Result');
        lbResign.Caption := ResultToString(l[7])
      end
  else if l[7][3] = 'T'
    then with gbResign do
      begin
        MainPanel_Show(self, gbResign);
        Caption          := U('Result');
        lbResign.Caption := ResultToString(l[7])
      end
  else if l[0] = 'X'
    then with gbResign do
      begin
        MainPanel_Show(self, gbResign);
        Caption          := U('Result');
        lbResign.Caption := ResultToString(l[7])
      end
    else with gbResult do
      begin
        MainPanel_Show(self, gbResult);
        Caption          := U('Result');
        lbBlackH.Caption := U('Black');
        lbWhiteH.Caption := U('White');
        lbTerritory.Caption := U('Territory');
        if Status.plScoring = scJapanese
          then lbPriso.Caption  := U('Prisoners')
          else lbPriso.Caption  := U('Stones');

        if Settings.Handicap < 2
          then s := U('Komi')
          else
            case Settings.PlScoring of
              scJapanese : s := U('Komi');
              scChinese  : s := U('Komi') + ' (H+0.5)';
              scAGA      : s := U('Komi') + ' (H-0.5)'
            end;
        lbKomi.Caption := s;

        lbTotal.Caption  := U('Total');
        lbTerB.Caption   := l[0];
        lbTerW.Caption   := l[1];
        lbPriB.Caption   := l[2];
        lbPriW.Caption   := l[3];
        lbKomiV.Caption  := l[4];
        lbTotB.Caption   := l[5];
        lbTotW.Caption   := l[6];
        lbResult.Caption := ResultToString(l[7])
      end;

  // increase size of bevels when too small
  w := WideCanvasTextWidth(lbResult.Canvas, lbResult.Caption);
  d := lbResult.Left - bvResult.Left;
  if (lbResult.Left + w + d) > (bvResult.Left + bvResult.Width) then
    begin
      bvResult.Width := 2 * d + w;
      Bevel1.Width := bvResult.Width;
      Bevel2.Width := bvResult.Width
    end;

  // shift White related labels if too close from Black ones
  w := WideCanvasTextWidth(lbBlackH.Canvas, lbBlackH.Caption);
  d := lbBlackH.Left + w + 5;
  if d > lbWhiteH.Left then
    begin
      lbWhiteH.Left := d;
      lbTerW.Left   := d;
      lbPriW.Left   := d;
      lbKomiV.Left  := d;
      lbTotW.Left   := d
    end
end;

// Replay game hint drawing

procedure TfrViewBoard.DrawReplayHint(ratioCorrect, ratioWrong : integer);
var
  x0, y0, x1, w, h : integer;
  bmp : TBitmap;
begin
  with imGmHint.Canvas do
    begin
      x0 := 0;
      y0 := 0;
      w  := imGmHint.Width;
      h  := imGmHint.Height;
      Brush.Color := clWhite;
      FillRect(Rect(x0, y0, x0 + w, y0 + h));
      Pen.Color := clGray;
      Rectangle(Rect(x0, y0, x0 + w, y0 + h));

      if ratioWrong > 0
        then ilGradients.Draw(imGmHint.Canvas, 1, 1, 0);

      if ratioCorrect > 0
        then
          begin
            x1 := x0 + Round(ratioCorrect * w / 100) - 1;
            bmp := TBitmap.Create;
            bmp.Width := 62;
            bmp.Height := 6;
            ilGradients.GetBitmap(1, bmp);
            imGmHint.Canvas.CopyRect(Rect(1, 1, x1, 7), bmp.Canvas, Rect(0, 0, x1, 6));
            bmp.Free
          end
    end;
end;

// -- Update game information panel ------------------------------------------

// Target rectangle for player images

function TargetRect(srcW, srcH, dstW, dstH : integer) : TRect;
var
  w, h : integer;
begin
  // try to maximize width
  w := dstW;
  h := Round(w * srcH / srcW);

  if h <= dstH then
    begin
      Result.Left := 0;
      Result.Right := dstW - 1;
      Result.Top := (dstH - h) div 2;
      Result.Bottom := Result.Top + h - 1;
      exit
    end;

  // maximize height
  h := dstH;
  w := Round(h * srcW / srcH);

  Result.Left := (dstW - w) div 2;
  Result.Right := Result.Left + w - 1;
  Result.Top := 0;
  Result.Bottom := dstH - 1;
end;

procedure ProportionalStretchDraw(img : TImage; bmp : TBitmap);
var
  rect : TRect;
begin
  rect := TargetRect(bmp.Width, bmp.Height, img.Width, img.Height);
  img.Canvas.StretchDraw(rect, bmp)
end;

procedure TfrViewBoard.DrawPlayer(img : TImage; bmp : TBitmap; default : integer);
begin
  img.Canvas.Brush.Color := dpGameInfo.Color;
  img.Canvas.FillRect(Rect(0, 0, img.Width, img.Height));

  if bmp <> nil
    then ProportionalStretchDraw(img, bmp)
end;

procedure TfrViewBoard.UpdateGameInfoPanel(bmpBlack, bmpWhite : TBitmap;
                                            infoStr : WideString);
var
  s : string;
begin
  // show or hide image area
  if Settings.GameInfoPaneImgDisp and (not pnGameInfoImages.Visible) then
    begin
      pnGameInfoImages.Visible := True;
      lxGameInfo.Top := pnGameInfoImages.Top + pnGameInfoImages.Height;
    end;
  if (not Settings.GameInfoPaneImgDisp) and pnGameInfoImages.Visible then
    begin
      pnGameInfoImages.Visible := False;
      lxGameInfo.Top := 10
    end;

  // show images if required
  if Settings.GameInfoPaneImgDisp then
    begin
      DrawPlayer(imgBlack, bmpBlack, 0);
      DrawPlayer(imgWhite, bmpWhite, 1);
    end;

  s := UTF8Encode(infoStr);
  s := AnsiReplaceStr(s, '\n', #13);
  s := AnsiReplaceStr(s, '\t', #9);

  lxGameInfo.Items.Text := UTF8Decode(s);
  lxGameInfo.ClientHeight := lxGameInfo.Items.Count * lxGameInfo.ItemHeight;

  if Settings.GameInfoPaneImgDisp
    then Panel1.Height := pnGameInfoImages.Height + lxGameInfo.Height + 10
    else Panel1.Height := 10 + lxGameInfo.Height + 10;

  dpGameInfo.FixedDockedSize := False;
  dpGameInfo.Resizable := True;
  dpGameInfo.EffectiveHeight := dpGameInfo.Options.TitleBarMaxSize + Panel1.Height;
  dpGameInfo.Tag := dpGameInfo.EffectiveHeight;
  dpGameInfo.FixedDockedSize := True;
  dpGameInfo.Resizable := False;
end;

// -- Side bar ---------------------------------------------------------------

// -- Initialization of side bar at tab creation

procedure TfrViewBoard.InitSideBar;
begin
  SideBarLayout := TDockPanelLayout.Create(SideBarDock, self);
  SideBarLayout.InitDefaultOrder([dpGameInfo, dpNodeName, dpTiming, dpQuickSearch,
                                   dpVariations, dpGameTree, dpComments, dpPad]);

  // it can be difficult to fix the size at design time, so do it now
  dpTiming.FixedDockedSize := False;
  dpTiming.Height := 94;
  dpTiming.Height := imWhiteStone.Top + imWhiteStone.Height + 10;
  dpTiming.FixedDockedSize := True;

  SideBarLayout.InitFixedSize([dpGameInfo, dpNodeName, dpTiming]);

  // would be fine but doesn't work
  //dpGameInfo.CurrentDock := SideBarDock;
  //dpNodeName.CurrentDock := SideBarDock;
  //dpTiming.CurrentDock   := SideBarDock;

  // adjust font settings for dockable panels
  AdjustPanelsFont
end;

procedure TfrViewBoard.InitSideBarLayout;
var
  panels : array of TSpTBXDockablePanel;

  procedure Push(dp : TSpTBXDockablePanel);
  begin
    SetLength(panels, Length(panels) + 1);
    panels[Length(panels) - 1] := dp
  end;

begin
  // avoid showing (and messing) sidebar panels in training modes after options
  if dpProblems.Visible or dpReplayGame.Visible
    then exit;
    
  SetLength(panels, 0);

  if Settings.VwGameInfo = vwAlways
    then Push(dpGameInfo);
  if Settings.VwNodeName = vwAlways
    then Push(dpNodeName);
  if Settings.VwTimeLeft = vwAlways
    then Push(dpTiming);
  if Settings.VwVariation = vwAlways
    then Push(dpVariations);
  if Settings.VwTreeView = vwAlways
    then Push(dpGameTree);
  if Settings.VwComments = vwAlways
    then Push(dpComments);

  SideBarLayout.InitLayout(panels);
end;

// -- Initialization of panel title font

procedure TfrViewBoard.AdjustPanelsFont;

  procedure Adjust(dp : TSpTBXDockablePanel);
  begin
    dp.Options.RightAlignSpacer.FontSettings.Style := [];
    dp.Options.RightAlignSpacer.FontSettings.Color := $808080
  end;

  begin
  Adjust(dpGameInfo);
  Adjust(dpTiming);
  Adjust(dpNodeName);
  Adjust(dpVariations);
  Adjust(dpGameTree);
  Adjust(dpComments);
  Adjust(dpProblems);
  Adjust(dpReplayGame);
  Adjust(gbResult);
  Adjust(gbResign);
  Adjust(dpQuickSearch);
end;

// -- Persistence

procedure TfrViewBoard.SaveSideBar(iniFile : TMemIniFile; section : string);
begin
  SpTBIniSavePositions(self, inifile, section);
end;

procedure TfrViewBoard.LoadSideBar(iniFile : TMemIniFile; section : string);
begin
  SpTBIniLoadPositions(self, inifile, section);
  if dpGameInfo.Visible
    then (View as TViewBoard).UpdateGameInformation
end;

// -- Update of show menu check boxes

procedure TfrViewBoard.mnShowClick(Sender: TObject);
begin
  mnGameInfo.Checked   := dpGameInfo.Visible;
  mnNodeName.Checked   := dpNodeName.Visible;
  mnTiming.Checked     := dpTiming.Visible;
  mnVariations.Checked := dpVariations.Visible;
  mnGameTree.Checked   := dpGameTree.Visible;
  mnComments.Checked   := dpComments.Visible
end;

// -- Show menu events

procedure TfrViewBoard.mnGameInfoClick(Sender: TObject);
begin
  TogglePanel(dpGameInfo);
  if dpGameInfo.Visible
    then (View as TViewBoard).UpdateGameInformation
end;

procedure TfrViewBoard.mnNodeNameClick(Sender: TObject);
begin
  TogglePanel(dpNodeName)
end;

procedure TfrViewBoard.mnTimingClick(Sender: TObject);
begin
  TogglePanel(dpTiming)
end;

procedure TfrViewBoard.mnVariationsClick(Sender: TObject);
begin
  TogglePanel(dpVariations)
end;

procedure TfrViewBoard.mnGameTreeClick(Sender: TObject);
begin
  TogglePanel(dpGameTree)
end;

procedure TfrViewBoard.mnCommentsClick(Sender: TObject);
begin
  TogglePanel(dpComments)
end;

procedure TfrViewBoard.btMoreClick(Sender: TObject);
begin
  Actions.acSidebarSettings.Execute
end;

// -- Toggling visibility of panels

procedure TfrViewBoard.TogglePanel(dp : TSpTBXDockablePanel);
begin
  if dp.Visible
    then SideBarLayout.HidePanel(dp)
    else ShowPanelAtDefaultPos(dp)
end;

// -- Closing event

procedure TfrViewBoard.CloseQueryCloseSideBarPanel(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  SideBarLayout.HidePanel(Sender as TSpTBXDockablePanel)
end;

// -- Connection with side bar unit

procedure TfrViewBoard.ShowPanelAtPos(dp : TSpTBXDockablePanel; pos : integer);
begin
  SideBarLayout.ShowPanelAtPos(dp, pos)
end;

procedure TfrViewBoard.ShowPanelAtDefaultPos(dp : TSpTBXDockablePanel);
begin
  SideBarLayout.ShowPanelAtDefaultPos(dp)
end;

// ---------------------------------------------------------------------------

procedure TfrViewBoard.dpQuickSearchClose(Sender: TObject);
begin
  RequestHideQuickSearchPanel;
end;

procedure TfrViewBoard.RequestHideQuickSearchPanel;
begin
  (View as TViewBoard).ExitQuickSearch
end;

procedure TfrViewBoard.ShowQuickSearchPanel;
begin
  ShowPanelAtDefaultPos(dpQuickSearch);
  frDBPatternResult.Initialize;
  frDBPatternResult.PickerCaption.Visible := False;
  frDBPatternResult.pnViewButtons.Visible := False;
  frDBPatternResult.bvButtons.Visible := False;
  lbQuickSearch.Caption := ''
end;

procedure TfrViewBoard.ProcessHideQuickSearchPanel;
begin
  SideBarLayout.HidePanel(dpQuickSearch)
end;

// ---------------------------------------------------------------------------

procedure TfrViewBoard.lxGameInfoDrawItemBackground(Sender: TObject;
  ACanvas: TCanvas; var ARect: TRect; Index: Integer;
  const State: TOwnerDrawState; const PaintStage: TSpTBXPaintStage;
  var PaintDefault: Boolean);
begin
  PaintDefault := False;
  ACanvas.Brush.Color := clWhite;
  ACanvas.FrameRect(ARect)
end;

procedure TfrViewBoard.dpGameInfoResize(Sender: TObject);
begin
  Panel1.ClientWidth := Parent.Width;
  lxGameInfo.ClientWidth := Parent.Width;
end;

// ---------------------------------------------------------------------------

end.
