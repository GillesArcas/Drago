// ---------------------------------------------------------------------------
// -- Drago -- Board view ---------------------------------- UViewBoard.pas --
// ---------------------------------------------------------------------------

unit UViewBoard;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Types,
  Controls,
  Define, DefineUi, UGameTree, UContext,
  UViewMain,
  UfrViewBoard;

type
  TViewBoard = class(TViewMain)
  private
    ModeInterBefore : integer;
    procedure UpdateTreeView;
    procedure LoadListOfNodeNames;
  protected
    procedure SetVisible(x : boolean); override;
    procedure AddMove(i, j : integer;
                      var done : boolean;
                      isEngineMove : boolean = False); override;
    procedure AddVariation(i, j : integer; var done : boolean); override;
    procedure UndoMove(var done : boolean); override;
    procedure DeleteBranch(var done : boolean); override;
  public
    frViewBoard    : TfrViewBoard;
    AutoReplayNext : TDateTime;
    AutoReplayBL   : double;
    AutoReplayWL   : double;
    AutoReplayColor: integer;

    constructor Create(aOwner, aParent : TComponent;
                       aContext : TContext); override;
    destructor Destroy; override;
    function  UpdateView : boolean; override;
    procedure DoWhenShowing; override;
    procedure Translate; override;
    procedure EnterView; override;
    procedure ExitView; override;
    procedure AlignToClient(align : boolean); override;
    procedure ResizeGoban; override;
    procedure ClearView; override;
    function  UpdateInStatusBar : boolean;
    procedure UpdatePlayer(player : integer); override;
    procedure UpdateMoveNumber(number : integer); override;
    procedure UpdatePrisoners(nB, nW : integer); override;
    procedure StartTiming(timeLeft : real; stonesLeft : integer); overload; override;
    procedure StartTiming(player : integer; timeLeft : real; stonesLeft : integer); overload; override;
    procedure UpdateTiming(player : integer; value : string); overload; override;
    procedure UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer); overload; override;
    procedure UpdateTimeLeft(player : integer; timeLeft : real); override;
    procedure UpdateStonesLeft(player : integer; stonesLeft : integer); override;
    procedure UpdateNodeName(const s : string); override;
    procedure ClearComments; override;
    procedure UpdateComments(const s : string); override;
    procedure UpdateGameInformation;
    procedure ShowGameResult(const pv : string); override;
    procedure ShowNextOrVars(mode : integer); override;

    procedure MoveForward; override;
    procedure MoveBackward; override;
    procedure MoveToChild(x : TGameTree); override;
    procedure MoveToSibling(x : TGameTree); override;
    procedure ReApplyNode;
    procedure MoveToStart(snMode : TStartNode  = snStrict); override;
    procedure MoveToEnd; override;
    procedure GoToPath(path : string; lastQuiet : boolean);
    procedure DoRemoveProperties(const propList : string; allGames : boolean);

    procedure StartEvent(seMode : TStartEvent = seMain;
                         snMode : TStartNode  = snStrict;
                         path   : string      = ''); override;
    procedure DoNextGame; override;
    procedure SelectGame; override;
    procedure DoPrevMove(snMode : TStartNode = snStrict); override;
    procedure DoNextMove; override;
    procedure DoStartPos; override;
    procedure DoEndPos;   override;
    procedure SelectMove; override;
    procedure SetExportPositionMode(active : boolean); override;
    procedure WarnOnInvalidMove(status : integer); override;
    procedure AddNode(var done : boolean);

    // not from TView
    procedure Start;
    procedure SetFocusOnGoban;
    procedure UpdatePanes(gt : TGameTree);
    procedure ShowPane(pane : integer);
    procedure HidePane(pane : integer);
    procedure DoStartPosDuringGame;
    procedure DoPrevMoveDuringGame;
    procedure DoNextMoveDuringGame;
    procedure DoLastMoveDuringGame;

    procedure DoStartPosInherited;
    procedure DoEndPosInherited;
    procedure DoPrevMoveInherited(snMode : TStartNode  = snStrict);
    procedure DoNextMoveInherited;

    procedure MinimizeSplitter(Sender: TObject);

    procedure InitQuickSearch;
    procedure ExitQuickSearch;
    procedure HideQuickSearch;
    procedure QuickSearchStatusMessage(const s : WideString);

    procedure MoveToNodeName(const s : string; target : TObject);
  end;
  
// ---------------------------------------------------------------------------

implementation

uses
  Graphics, StrUtils,
  TntIniFiles,
  Std, Main, Ugmisc, UTreeView, UActions, SysUtilsEx, UnicodeUtils, ClassesEx,
  UViewBoardPanels, UGCom, Properties, UBoardViewCanvas,
  UProblems, UAutoReplay, UGraphic, UPrint, Ux2y,
  UGoban, UStatus, UMainUtil;

// -- Constructor ------------------------------------------------------------

constructor TViewBoard.Create(aOwner, aParent : TComponent;
                              aContext : TContext);
begin
  inherited Create;

  TabSheet := aParent as TTabSheetEx;
  Context := aContext;
  frViewBoard := TfrViewBoard.CreateFrame(aOwner, aParent, self);

  // avoid EComponentError
  frViewBoard.Name := '';

  //TODO: should be possible to have other types of parent
  assert(aParent is TTabSheetEx);

  frViewBoard.AllowResize := False
end;

// -- Destructor -------------------------------------------------------------

destructor TViewBoard.Destroy;
begin
  //gb.Free;
  frViewBoard.Free;

  inherited Destroy;
end;

// -- Initialisation ---------------------------------------------------------

procedure TViewBoard.Start;
begin
  // allocate instance data
  // todo: should be created with context but with transmitting image
  gb := TGoban.Create;
  //gb.SetBoardView(TBoardViewCanvas.Create(frViewBoard.imGoban.Canvas));
  gb.SetBoardView(TBoardViewCanvas.Create(frViewBoard.imGoban.Picture.Bitmap.Canvas));

  // init default view settings
  si.Default;

  // init instance data
  gt  := nil;
  gtp := nil;
  si.ParentView := self;
  gb.CBShowMove := CallbackShowMove;

  frViewBoard.Start;
  frViewBoard.OnMinimizeSplitter := MinimizeSplitter
end;

procedure TViewBoard.EnterView;
begin
  frViewBoard.EnterView
end;

procedure TViewBoard.ExitView;
begin
  frViewBoard.ExitView
end;

// -- Update after option dialog display -------------------------------------

function TViewBoard.UpdateView : boolean;
var
  rView : TRect;
begin
  if not inherited UpdateView
    then exit;

  // update goban
  with Settings do
    begin
      gb.ShowMoveMode := ShowMoveMode;
      gb.NumberOfVisibleMoveNumbers := NumberOfVisibleMoveNumbers;
      (gb.BoardView as TBoardViewCanvas).BoardSettings(BoardBack, BorderBack,
                                                       ThickEdge, ShowHoshis,
                                                       CoordStyle, StoneStyle,
                                                       LightSource, NumOfMoveDigits,
                                                       False)
    end;

  if not Settings.ZoomOnCorner
    then gb.SetView(1, 1, gb.BoardSize, gb.BoardSize)
    else
      begin
        DetectQuadrant(gt, rView);
        gb.SetView(rView.Top, rView.Left, rView.Bottom, rView.Right)
      end;
  //en test 10/06/2010 gb.SetDim(gb.BoardView.ExtWidth, gb.BoardView.ExtHeight);
  ResizeGoban;

  frViewBoard.UpdateView;
  UpdateGameInformation;

  // update variation marks
  ReApplyNode
end;

// -- Show frame -------------------------------------------------------------

procedure TViewBoard.DoWhenShowing;
begin
  // call common show routine
  inherited DoWhenShowing;

  // refresh board
  ReApplyNode;

  // force focus on goban (and avoid focus on edNodeName if any)
  SetFocusOnGoban
end;

procedure TViewBoard.SetVisible(x : boolean);
begin
  frViewBoard.Visible := x
end;

// -- Translation ------------------------------------------------------------

procedure TViewBoard.Translate;
begin
  frViewBoard.Translate;

  // translate variation panel, annotations
  ReApplyNode
end;

// -- Focus ------------------------------------------------------------------

procedure TViewBoard.SetFocusOnGoban;
begin
  frViewBoard.SetFocusOnGoban
end;

// -- Resizing ---------------------------------------------------------------

procedure TViewBoard.AlignToClient(align : boolean);
begin
  if align
    then frViewBoard.Align := alClient
    else frViewBoard.Align := alNone
end;

procedure TViewBoard.ResizeGoban;
begin
  frViewBoard.ResizeGoban
end;

// -- View update ------------------------------------------------------------

procedure TViewBoard.ClearView;
begin
  UpdateNodeName('');
  ClearComments;
  ClearStatusBar;
  HidePane(0);
  HidePane(1);
end;

procedure TViewBoard.MinimizeSplitter(Sender: TObject);
begin
  ReApplyNode;
  fmMain.StatusBar.Invalidate
end;

// Target of game status update

function TViewBoard.UpdateInStatusBar : boolean;
begin
  Result := frViewBoard.VSplitter.Minimized
end;

// Update move number

procedure TViewBoard.UpdateMoveNumber(number : integer);
begin
  inherited UpdateMoveNumber(number);

  if UpdateInStatusBar
    then StatusBarUpdateMoveNumber(number)
    else frViewBoard.UpdateMoveNumber(number)
end;

// Update player to play

procedure TViewBoard.UpdatePlayer(player : integer);
begin
  inherited UpdatePlayer(player);

  // should it be in TView?
  if (gb <> nil) and (gb.ColorTrans = ctReverse)
    then player := ReverseColor(player);

  if UpdateInStatusBar
    then StatusBarUpdatePlayer(player)
    else frViewBoard.UpdatePlayer(player)
end;

// Update numbers of prisoners

procedure TViewBoard.UpdatePrisoners(nB, nW : integer);
begin
  inherited UpdatePrisoners(nB, nW);

  if UpdateInStatusBar
    then StatusBarUpdatePrisoners(nB, nW)
    else frViewBoard.UpdatePrisoners(nB, nW)
end;

// Update timing

procedure TViewBoard.UpdateTiming(player : integer; value : string);
begin
  frViewBoard.UpdateTiming(player, value)
end;

procedure TViewBoard.StartTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
  frViewBoard.StartTiming(player, timeLeft, stonesLeft)
end;

procedure TViewBoard.StartTiming(timeLeft : real; stonesLeft : integer);
begin
  frViewBoard.StartTiming(timeLeft, stonesLeft)
end;

procedure TViewBoard.UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
  frViewBoard.UpdateTiming(player, timeLeft, stonesLeft)
end;

procedure TViewBoard.UpdateTimeLeft(player : integer; timeLeft : real);
begin
  frViewBoard.UpdateTimeLeft(player, timeLeft)
end;

procedure TViewBoard.UpdateStonesLeft(player : integer; stonesLeft : integer);
begin
  frViewBoard.UpdateStonesLeft(player, stonesLeft)
end;

// Update node name

procedure TViewBoard.UpdateNodeName(const s : string);
begin
  frViewBoard.UpdateNodeName(s)
end;

procedure TViewBoard.LoadListOfNodeNames;
var
  x : TGameTree;
  list : TStringList;
begin
  x := gt.Root;
  list := TStringList.Create;

  while x <> nil do
    begin
      if x.HasProp(prN)
        then list.AddObject(pv2str(x.GetProp(prN)), x);
      x := x.NextNodeDepthFirst
    end;

  frViewBoard.LoadListOfNodeNames(list);
  list.Free
end;

procedure TViewBoard.MoveToNodeName(const s : string; target : TObject);
begin
  GoToNode(target as TGameTree)
end;

// Update comments

procedure TViewBoard.ClearComments;
begin
  frViewBoard.ClearComments
end;

procedure TViewBoard.UpdateComments(const s : string);
begin
  frViewBoard.UpdateComments(s)
end;

// Panes
procedure TViewBoard.UpdatePanes(gt : TGameTree);
begin
  MainPanel_Update(frViewBoard, gt)
end;

// TODO: define constants
// 0: Resign, 1: Result

procedure TViewBoard.ShowPane(pane : integer);
begin
  assert(False);
  case pane of
    0 : MainPanel_Show(frViewBoard, frViewBoard.gbResign);
    1 : MainPanel_Show(frViewBoard, frViewBoard.gbResult);
  end
end;

procedure TViewBoard.HidePane(pane : integer);
begin
  case pane of
    0 : MainPanel_Hide(frViewBoard, frViewBoard.gbResign);
    1 : MainPanel_Hide(frViewBoard, frViewBoard.gbResult);
  end
end;

// Engine game results

procedure TViewBoard.ShowGameResult(const pv : string);
begin
  frViewBoard.ShowGameResult(pv)
end;

// Display of follow up moves or variations

procedure TViewBoard.ShowNextOrVars(mode : integer);
begin
  UGCom.ShowNextOrVars(self, mode)
end;

// Update tree view after moving from some place in game tree

procedure TViewBoard.UpdateTreeView;
begin
  TV_UpdateView(self)
end;

// Update of game information panel

function FindPlayerImage(name, default : WideString) : WideString;
var
  list : TWideStringList;
  syns : TTntMemIniFile;
  syn : WideString;
begin
  list := TWideStringList.Create;

  // hack to display Gnu Go image. For an engine game, the player name is
  // "Gnu Go" + version (or the name given by user) + level. To get the
  // image, the name has to be truncated.
  if AnsiStartsText('GNU Go', name)
    then name := 'GNU Go';

  // question marks will be stored in name in case of unicode problem and
  // they would be treated as jokers without the test.
  if (name <> '') and (name[1] <> '?')
    then WideAddFilesToList(list, Settings.GameInfoPaneImgDir, [afIncludeFiles, afCatPath], name + '*');

  case list.Count of
    0 :
      begin
        syns := TTntMemIniFile.Create(Settings.GameInfoPaneImgDir + '\synonyms.txt');
        syn := syns.ReadString('Players', name, '');
        if syn <> ''
          then Result := FindPlayerImage(syn, default)
          else
            if default = ''
              then Result := ''
              else Result := FindPlayerImage(default, '');
        syns.Free
      end;
    1 :
      Result := list[0];
    else
      Result := list[Random(list.Count)];
  end;

  list.Free;
end;

procedure TViewBoard.UpdateGameInformation;
var
  bmpBlack, bmpWhite : TBitmap;
  pv, s : WideString;
begin
  bmpBlack := TBitmap.Create;
  bmpWhite := TBitmap.Create;

  pv := pv2str(gt.Root.GetProp(prPB));
  s := FindPlayerImage(pv, 'DefaultBlack');
  if not LoadImageToBmp(s, bmpBlack)
    then FreeAndNil(bmpBlack);

  pv := pv2str(gt.Root.GetProp(prPW));
  s := FindPlayerImage(pv, 'DefaultWhite');
  if not LoadImageToBmp(s, bmpWhite)
    then FreeAndNil(bmpWhite);

  if gt.Root = nil
    then exit;

  s := UTF8Decode(ParseGameInfosName(gt.Root, UTF8Encode(Settings.GameInfoPaneFormat), si));
  s := WideReplaceStr(s, #$1F, '');
  frViewBoard.UpdateGameInfoPanel(bmpBlack, bmpWhite, s);

  bmpBlack.Free;
  bmpWhite.Free;
end;

// -- Commands ---------------------------------------------------------------

procedure TViewBoard.StartEvent(seMode : TStartEvent = seMain;
                                snMode : TStartNode  = snStrict;
                                path   : string      = '');
begin
  // experimental to fight against NthPropId bug
  // removed then restored ...
  // fix crash when two tabs with same file in ini file
  if not si.ApplyQuiet
    then LoadTreeView(self, gt, 0, 0, True);

  inherited StartEvent(seMode, snMode, path);

  if not si.ApplyQuiet then
    begin
      LoadTreeView(self, gt, 0, 0, True);
      UpdateGameInformation;
      //LoadListOfNodeNames;
      if seMode = seMain
        then UpdatePanes(gt);
    end;
end;

// Game navigation

procedure TViewBoard.DoNextGame;
begin
  case si.ModeInter of
    kimNOP:
      {nop};
    kimGE .. kimDD, kimZO :
      if si.MainMode <> muFree
        then inherited DoNextGame
        else DoNextGameDuringPb(self);
    kimPB :
      DoNextGameDuringPb(self);
    kimPF :
      DoNextGameAfterPb(self);
    kimJO :
      DoNextGameAfterJo(self)
  end
end;

procedure TViewBoard.SelectGame;
begin
  // set Status.LastGotoGame
  inherited SelectGame;

  ChangeEvent(Status.LastGotoGame)
end;

// Move navigation

procedure TViewBoard.DoStartPos;
begin
  case si.ModeInter of
    kimNOP: ; // nop
    kimGE .. kimDD, kimZO, kimTU, kimFU, kimWC :
      inherited DoStartPos;
    kimPB :
      DoFirstMoveDuringPb(self);
    kimPF :
      DoFirstMoveAfterPb(self);
    kimRG, kimRGR, kimEG, kimEGR :
      DoStartPosDuringGame;
    kimAR :
      StartPosAutoReplay(self)
  end
end;

procedure TViewBoard.DoEndPos;
begin
  case si.ModeInter of
    kimNOP:
      {nop};
    kimGE .. kimDD, kimZO, kimTU, kimFU, kimWC :
      begin
        //MilliTimer;
        inherited DoEndPos;
        //Trace(Format('Display page : %d', [MilliTimer]));
      end;
    kimPB :
      {nop};
    kimPF :
      {nop};
    kimRG, kimRGR, kimEG, kimEGR :
      DoLastMoveDuringGame;
    kimAR :
      LastMoveAutoReplay(self)
  end
end;

procedure TViewBoard.DoPrevMove(snMode : TStartNode  = snStrict);
begin
  case si.ModeInter of
    kimNOP: ; // nop
    kimGE .. kimDD, kimZO, kimTU, kimFU, kimWC :
      inherited DoPrevMove(snMode);
    kimPB :
      DoPrevMoveDuringPb(self);
    kimPF :
      DoPrevMoveAfterPb(self);
    kimRG, kimRGR, kimEG, kimEGR :
      DoPrevMoveDuringGame;
    kimAR :
      PrevMoveAutoReplay(self)
  end
end;

procedure TViewBoard.DoNextMove;
begin
  case si.ModeInter of
    kimNOP: ; // nop
    kimGE .. kimDD, kimZO, kimTU, kimFU, kimWC :
      inherited DoNextMove;
    kimPB : ; // nop
    kimPF : ; // nop
    kimRG, kimRGR, kimEG, kimEGR :
      DoNextMoveDuringGame;
    kimAR :
      NextMoveAutoReplay(self)
  end
end;

// -- Start position and previous move commands during replay game or engine game

procedure TViewBoard.DoStartPosDuringGame;
begin
  if gb.MoveNumber = 0
    then exit;

  if si.ModeInter = kimEG then
    begin
      Actions.acScoreEstimate.Enabled := False;
      Actions.acSuggestMove.Enabled   := False
    end;

  if si.ModeInter in [kimRG, kimEG] then
    begin
      si.CurrLastMove := gb.MoveNumber;
      si.ModeInter := iff(si.ModeInter = kimRG, kimRGR, kimEGR)
    end;

  Actions.acNextMove.Enabled := True;
  Actions.acEndPos.Enabled := True;
  
  inherited DoStartPos
end;

procedure TViewBoard.DoPrevMoveDuringGame;
begin
  if gb.MoveNumber = 0
    then exit;

  if si.ModeInter = kimEG then
    begin
      Actions.acScoreEstimate.Enabled := False;
      Actions.acSuggestMove.Enabled   := False
    end;

  if si.ModeInter in [kimRG, kimEG] then
    begin
      si.CurrLastMove := gb.MoveNumber;
      si.ModeInter := iff(si.ModeInter = kimRG, kimRGR, kimEGR)
    end;

  Actions.acNextMove.Enabled := True;
  Actions.acEndPos.Enabled := True;

  inherited DoPrevMove
end;

// -- Next move and end position commands during replay game or engine game

procedure TViewBoard.DoNextMoveDuringGame;
begin
  if si.ModeInter in [kimEG]
    then exit;

  if si.ModeInter = kimRG then
    begin
      Actions.acNextMove.Enabled := False;
      PlayCorrectMove(self, si.ModeInter);
      exit
    end;

  inherited DoNextMove;

  // test if last move played in replay or engine mode has been reached
  if gb.MoveNumber = si.CurrLastMove then
    begin
      si.ModeInter := iff(si.ModeInter = kimRGR, kimRG, kimEG);
      Actions.acNextMove.Enabled := False;
      Actions.acEndPos.Enabled   := False;

      // todo: what about other game analysis commands?
      Actions.acScoreEstimate.Enabled := True;
      Actions.acSuggestMove.Enabled   := True
    end
end;

procedure TViewBoard.DoLastMoveDuringGame;
begin
  if si.ModeInter in [kimRG, kimEG]
    then exit;

  GoToMove(si.CurrLastMove, not kLastQuiet);
  si.ModeInter := iff(si.ModeInter = kimRGR, kimRG, kimEG);

  Actions.acNextMove.Enabled      := False;
  Actions.acEndPos.Enabled        := False;
  Actions.acScoreEstimate.Enabled := True;
  Actions.acSuggestMove.Enabled   := True
end;

// -- Select move

procedure TViewBoard.SelectMove;
begin
  UserGotoMove(self)
end;

// -- Moves ------------------------------------------------------------------

// next move assumed

procedure TViewBoard.MoveForward;
begin
  inherited MoveForward;
  UpdateTreeView
end;

// previous move assumed

procedure TViewBoard.MoveBackward;
begin
  inherited MoveBackward;
  UpdateTreeView
end;

// x is supposed to be a child (next move or variation of next move)

procedure TViewBoard.MoveToChild(x : TGameTree);
begin
  inherited MoveToChild(x);
  UpdateTreeView
end;

// x is supposed to be a sibling (next var or variation of next var)

procedure TViewBoard.MoveToSibling(x : TGameTree);
begin
  inherited MoveToSibling(x);
  UpdateTreeView
end;

// "sur place" move, used to refresh view

procedure TViewBoard.ReApplyNode;
begin
  inherited ReApplyNode;
  UpdateTreeView
end;

// start position

procedure TViewBoard.MoveToStart(snMode : TStartNode  = snStrict);
begin
  inherited MoveToStart(snMode);
  UpdateTreeView
end;

// end position

procedure TViewBoard.MoveToEnd;
begin
  inherited MoveToEnd;
  UpdateTreeView
end;

procedure TViewBoard.GoToPath(path : string; lastQuiet : boolean);
begin
  inherited GotoPath(path, lastQuiet);

  if not lastQuiet
    then UpdateTreeView
end;

// -- Modification of game tree ----------------------------------------------

procedure TViewBoard.WarnOnInvalidMove(status : integer);
begin
  DragoPlaySound(sInvMove);
  inherited WarnOnInvalidMove(status)
end;

procedure TViewBoard.AddNode(var done : boolean);
var
  gt0 : TGameTree;
begin
  gt0 := gt;

  inherited AddNode(done);

  if done
    then TV_LinkMoves(self, gt0)
end;

procedure TViewBoard.AddMove(i, j : integer;
                             var done : boolean;
                             isEngineMove : boolean = False);
var
  gt0 : TGameTree;
begin
  gt0 := gt;

  //inherited AddMove(i, j, done, isEngineMove);
  inherited AddMove(i, j, done);

  if done then
    begin
      TV_LinkMoves(self, gt0);
      if gb.IsBoardCoord(i, j) then
        if not isEngineMove
          then DragoPlaySound(sStone)
          else DragoPlaySound(sEngineMove)
    end
end;

procedure TViewBoard.AddVariation(i, j : integer; var done : boolean);
var
  gt0 : TGameTree;
begin
  gt0 := gt.NextNode.LastVar;

  inherited AddVariation(i, j, done);

  if done then
    begin
      TV_LinkVars(self, gt0);
      if gb.IsBoardCoord(i, j)
        then DragoPlaySound(sStone);
      UpdatePanes(gt)
    end
end;

procedure TViewBoard.UndoMove(var done : boolean);
begin
  inherited UndoMove(done);

  if done then
    begin
      TV_DelMove(self);
      UpdatePanes(gt)
    end
end;

procedure TViewBoard.DeleteBranch(var done : boolean);
begin
  inherited DeleteBranch(done);

  if done then
    begin
      TV_DelMove(self);
      UpdatePanes(gt)
    end
end;

procedure TViewBoard.DoRemoveProperties(const propList : string; allGames : boolean);
begin
  inherited DoRemoveProperties(propList, allGames);
  UpdateTreeView
end;

// -- Settings for exporting position mode (TfmExportPos) --------------------

procedure TViewBoard.SetExportPositionMode(active : boolean);
var
  where : TPoint;
begin
  if active
    then
      begin
        where.x := frViewBoard.imGoban.Width  div 3;
        where.y := frViewBoard.imGoban.Height div 3;
        //Mouse.CursorPos := frViewBoard.imGoban.ClientToScreen(where);
        frViewBoard.imGoban.OnMouseEnter := frViewBoard.imGobanMouseEnter;
        frViewBoard.imGoban.OnMouseLeave := frViewBoard.imGobanMouseLeave;
        if si.ModeInter <> kimZO then
          begin
            ModeInterBefore := si.ModeInter;
            si.ModeInter := kimZO;
          end
      end
    else
      begin
        frViewBoard.imGoban.OnMouseLeave := nil;
        frViewBoard.imGoban.OnMouseEnter := nil;
        if si.ModeInter = kimZO
          then si.ModeInter := ModeInterBefore
      end
end;

// -- Limitation of behaviour to the one of base class -----------------------

procedure TViewBoard.DoStartPosInherited;
begin
  inherited DoStartPos
end;

procedure TViewBoard.DoEndPosInherited;
begin
  inherited DoEndPos
end;

procedure TViewBoard.DoNextMoveInherited;
begin
  inherited DoNextMove
end;

procedure TViewBoard.DoPrevMoveInherited(snMode : TStartNode  = snStrict);
begin
  inherited DoPrevMove(snMode)
end;

// -- Quick search -----------------------------------------------------------

procedure TViewBoard.InitQuickSearch;
begin
  si.DbQuickSearch := qsOpen;

  case PatternSearchMode(self) of
    psmQuickSearchSideBar :
      frViewBoard.ShowQuickSearchPanel;
    psmQuickSearchDBWindow :
      // erase rectangle drawn before pressing quick search button in search window
      gb.Rectangle(0, 0, 0, 0, False);
    else
      assert(False, 'Debug DBS')
  end;

  Actions.acWildcard.Visible := True;
  Actions.acWildcard.Enabled := True;
end;

//procedure TViewBoard.ExitQuickSearch;
//begin
//  frViewBoard.HideQuickSearchPanel;
//  Actions.acWildcard.Visible := False;
//  Actions.acWildcard.Enabled := False;
//  ReApplyNode;
//end;

procedure TViewBoard.ExitQuickSearch;
begin
  //fmMain.btQuickSearch.Checked := False;
  frViewBoard.ProcessHideQuickSearchPanel;
  Actions.acWildcard.Visible := False;
  Actions.acWildcard.Enabled := False;
  gb.Rectangle(0, 0, 0, 0, False);
  ReApplyNode;
  si.DbQuickSearch := qsOff;
  Actions.acQuickSearch.Checked := False
end;

procedure TViewBoard.HideQuickSearch;
begin
  frViewBoard.ProcessHideQuickSearchPanel;
  gb.Rectangle(0, 0, 0, 0, False);
  ReApplyNode;
end;

procedure TViewBoard.QuickSearchStatusMessage(const s : WideString);
begin
  frViewBoard.lbQuickSearch.Caption := s
end;

// ---------------------------------------------------------------------------

end.


