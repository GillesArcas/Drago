// ---------------------------------------------------------------------------
// -- Drago -- Common ancestor view ----------------------------- UView.pas --
// ---------------------------------------------------------------------------

unit UView;

// ---------------------------------------------------------------------------

interface

uses
  Classes,
  Dialogs, //DEBUG
  Define, DefineUi, Properties, UContext, UGoban, UStatus, UInstStatus,
  UGameColl, UGameTree, UKombilo, UGtp;

type
  TView = class
  private
    function  Get_gb : TGoban;
    procedure Set_gb(x : TGoban);
    function  Get_si : TInstStatus;
    procedure Set_si(x : TInstStatus);
    function  Get_st : TStatus;
    function  Get_sa : TStatus;
    function  Get_cl : TGameColl;
    procedure Set_cl(x : TGameColl);
    function  Get_gt : TGameTree;
    procedure Set_gt(x : TGameTree);
    function  Get_kh : TKGameList;
    procedure Set_kh(x : TKGameList);
    function  Get_gtp : TGtp;
    procedure Set_gtp(x : TGtp);
    procedure GoFromTo1(gtTarget : TGameTree);
    procedure GoForward(moveNum : integer);
    procedure GoBackward(moveNum : integer);
  protected
    procedure AddNode(var done : boolean);
    procedure NewChild(i, j : integer; var done : boolean);
    procedure AddMove(i, j : integer;
                      var done : boolean;
                      isEngineMove : boolean = False); virtual;
    procedure AddVariation(i, j : integer; var done : boolean); virtual;
    procedure UndoMove(var done : boolean); virtual;
    procedure DeleteBranch(var done : boolean); virtual;
  public
    Context : TContext;
    LastVisitedNode : TGameTree;

    constructor Create(aOwner, aParent : TComponent;
                       aContext : TContext); overload; virtual; abstract;
    destructor Destroy; override;
    function  GetContext : TContext; virtual;
    procedure Initialize; virtual;

    function  IsFile : boolean;
    function  IsDir  : boolean;
    function  IsDB   : boolean;

    procedure ClearView; virtual;
    procedure ShowFileName(const s : WideString); virtual;
    procedure ShowSaveStatus(saved : boolean); virtual;
    procedure ShowReadOnlyStatus(rOnly : boolean); virtual;
    procedure UpdatePlayer(player : integer); virtual;
    procedure UpdateMoveNumber(number : integer); virtual;
    procedure UpdatePrisoners(nB, nW : integer); virtual;
    procedure StartTiming(timeLeft : real; stonesLeft : integer); overload; virtual;
    procedure StartTiming(player : integer; timeLeft : real; stonesLeft : integer); overload; virtual;
    procedure UpdateTiming(player : integer; value : string); overload; virtual;
    procedure UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer); overload; virtual;
    procedure UpdateTimeLeft(player : integer; timeLeft : real); virtual;
    procedure UpdateStonesLeft(player : integer; stonesLeft : integer); virtual;
    procedure UpdateNodeName(const s : string); virtual;
    procedure ClearComments; virtual;
    procedure UpdateComments(const s : string); virtual;
    procedure ShowGameIndex(n : integer); virtual;
    procedure ShowIgnoredProperty(const s : string); virtual;
    procedure AddAnnotation(const glyph, msg : string); virtual;
    procedure ShowGameResult(const pv : string); virtual;
    procedure ShowNextOrVars(mode : integer); virtual;
    procedure ResizeGoban; virtual;
    function  MessageDialog(dlg, img : integer;
                            msg : array of WideString) : integer; overload; virtual;
    function  MessageDialog(dlg, img : integer;
                            msg : array of WideString;
                            var warn : boolean) : integer; overload; virtual;
    function  AllowModification : boolean; virtual;

    procedure MoveForward; virtual;
    procedure MoveBackward; virtual;
    procedure MoveToChild(x : TGameTree); virtual;
    procedure MoveToSibling(x : TGameTree); virtual;
    procedure ReApplyNode;
    procedure MoveToStart(snMode : TStartNode  = snStrict); virtual;
    procedure MoveToEnd; virtual;
    procedure GoToMove(moveNum : integer;
                       lastQuiet : boolean;
                       snMode : TStartNode = snStrict);
    procedure GoToNode(gtTarget : TGameTree);
    procedure GoToPath(path : string; lastQuiet : boolean);
    procedure PrevNodeDepthFirst;
    procedure NextNodeDepthFirst;

    procedure CreateEvent(defaultHandicap : boolean = True);
    procedure ChangeEvent(n : integer;
                          seMode : TStartEvent = seMain;
                          snMode : TStartNode  = snStrict);
    procedure StartEvent(seMode : TStartEvent = seMain;
                         snMode : TStartNode  = snStrict;
                         path   : string      = ''); virtual;
    procedure StartDisplay(snMode : TStartNode = snStrict;
                           path   : string      = '');
    procedure ApplyQuiet(val : boolean);
    procedure DoFirstGame; virtual;
    procedure DoLastGame; virtual;
    procedure DoPrevGame; virtual;
    procedure DoNextGame; virtual;
    procedure SelectGame; virtual;
    procedure DoStartPos; virtual;
    procedure DoEndPos;   virtual;
    procedure DoPrevMove(snMode : TStartNode  = snStrict); virtual;
    procedure DoNextMove; virtual;
    procedure SelectMove; virtual;
    procedure WarnOnInvalidMove(status : integer); virtual;
    procedure DoNewMove(i, j : integer; isEngineMove : boolean = False);
    procedure DoNewVar(i, j : integer);
    procedure DoUndoMove;
    procedure DoDeleteBranch;
    procedure DoPromoteVariation;
    procedure DoDemoteVariation;
    procedure DoMakeMainBranch;
    procedure DoRemoveProperties(const propList : string; allGames : boolean);
    procedure DoEditMarkup(i, j  : integer; pr : TPropId; const v : string);

    property  cx  : TContext read GetContext;
    property  gb  : TGoban read Get_gb write Set_gb;
    property  cl  : TGameColl read Get_cl write Set_cl;
    property  gt  : TGameTree read Get_gt write Set_gt;
    property  kh  : TKGameList read Get_kh write Set_kh;
    property  gtp : TGtp read Get_gtp write Set_gtp;
    property  si  : TInstStatus read Get_si write Set_si;
    property  sa  : TStatus read Get_sa;
    property  st  : TStatus read Get_st;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Types,
  UApply,
  UMatchPattern,
  UGMisc, GameUtils,
  Ux2y, Translate;

// -- Allocation -------------------------------------------------------------

destructor TView.Destroy;
begin
  inherited Destroy
end;

procedure TView.Initialize;
begin
end;

// -- Accessors to context ---------------------------------------------------

function TView.GetContext : TContext;
begin
  Result := Context
end;

function TView.Get_gb : TGoban;
begin
  Result := Context.gb
end;

procedure TView.Set_gb(x : TGoban);
begin
  Context.gb := x
end;

function TView.Get_si : TInstStatus;
begin
  Result := Context.si
end;

procedure TView.Set_si(x : TInstStatus);
begin
  Context.si := x
end;

function TView.Get_st : TStatus;
begin
  Result := Settings
end;

function TView.Get_sa : TStatus;
begin
  Result := Status
end;

function TView.Get_cl : TGameColl;
begin
  Result := Context.cl
end;

procedure TView.Set_cl(x : TGameColl);
begin
  Context.cl := x
end;

function TView.Get_gt : TGameTree;
begin
  Result := Context.gt
end;

procedure TView.Set_gt(x : TGameTree);
begin
  Context.gt := x
end;

function TView.Get_kh : TKGameList;
begin
  Result := Context.kh
end;

procedure TView.Set_kh(x : TKGameList);
begin
  Context.kh := x
end;

function TView.Get_gtp : TGtp;
begin
  Result := Context.gtp
end;

procedure TView.Set_gtp(x : TGtp);
begin
  Context.gtp := x
end;

// -- Content ----------------------------------------------------------------

function TView.IsFile : boolean;
begin
  Result := not (IsDir or IsDB)
end;

function TView.IsDir : boolean;
begin
  Result := si.FolderName <> ''
end;

function TView.IsDB : boolean;
begin
  Result := kh <> nil
end;

// -- Display ----------------------------------------------------------------

// default implementation for view updates

procedure TView.ClearView;
begin
end;

procedure TView.ShowFileName(const s : WideString);
begin
end;

procedure TView.ShowSaveStatus(saved : boolean);
begin
end;

procedure TView.ShowReadOnlyStatus(rOnly : boolean);
begin
end;

procedure TView.UpdatePlayer(player : integer);
begin
  si.Player := player
end;

procedure TView.UpdateMoveNumber(number : integer);
begin
  si.MoveNumber := number;
  si.CurrentPath := gt.StepsToNode
end;

procedure TView.UpdatePrisoners(nB, nW : integer);
begin
  si.BlackPrisoners := nB;
  si.WhitePrisoners := nW
end;

procedure TView.StartTiming(timeLeft : real; stonesLeft : integer);
begin
end;

procedure TView.StartTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
end;

procedure TView.UpdateTiming(player : integer; value : string);
begin
end;

procedure TView.UpdateTiming(player : integer; timeLeft : real; stonesLeft : integer);
begin
end;

procedure TView.UpdateTimeLeft(player : integer; timeLeft : real);
begin
end;

procedure TView.UpdateStonesLeft(player : integer; stonesLeft : integer);
begin
end;

procedure TView.UpdateNodeName(const s : string);
begin
end;

procedure TView.ClearComments;
begin
end;

procedure TView.UpdateComments(const s : string);
begin
end;

procedure TView.ShowGameIndex(n : integer);
begin
end;

procedure TView.ShowIgnoredProperty(const s : string);
begin
end;

procedure TView.AddAnnotation(const glyph, msg : string);
begin
end;

procedure TView.ShowGameResult(const pv : string);
begin
end;

procedure TView.ShowNextOrVars(mode : integer);
begin
end;

//TODO: should probably not be here
procedure TView.ResizeGoban;
begin
end;

function TView.MessageDialog(dlg, img : integer;
                             msg : array of WideString) : integer;
begin
  Result := 0
end;

function TView.MessageDialog(dlg, img : integer;
                             msg : array of WideString;
                             var warn : boolean) : integer;
begin
  Result := 0
end;

// -- Game events ------------------------------------------------------------

// Creation of new event

procedure TView.CreateEvent(defaultHandicap : boolean = True);
begin
  cl.Add(NewStartingPosition(defaultHandicap));
  cl.FileName[cl.Count] := si.FileName;
  si.IndexTree := cl.Count;
  if Status.NewInFile
    then // nop, do not modify filename
    else
      begin
        si.FolderName := '';
        si.DatabaseName := '';
        si.FileName  := '';
      end;

  // dont want to answer to a save request for an empty file
  if cl.Count = 1
    then si.FFileSave := True
    else si.FFileSave := False;

  gt := cl[si.IndexTree]; // Bind gt
  if st.Komi <> 0
    then gt.PutProp(prKM, real2pv(st.Komi));
  si.MainMode := muModification;
  si.ReadOnly := False
end;

// Event entry routine

procedure TView.ChangeEvent(n : integer;
                            seMode : TStartEvent = seMain;
                            snMode : TStartNode  = snStrict);
begin
  // patch for navigation among games after DB search
  if cl.Hits[n] <> ''
      then snMode := snHit;

  si.IndexTree := n;
  si.FileName  := cl.FileName[n];
  si.FileSave  := not cl.FTree[n].Modified;
  gt := cl[si.IndexTree].Root;

  case snMode of
    snStrict, snExtend :
      StartEvent(seMode, snMode);
    snHit :
      if cl.Hits[n] = ''
        then StartEvent(seMode, snStrict)
        else
          begin
            StartEvent(seMain, snStrict);
            GotoPath(FirstHit(cl.Hits[n], cl[n]), not kLastQuiet);
            ShowSearchPattern(gb, kh)
          end
  end
end;

// Start of event

procedure TView.StartEvent(seMode : TStartEvent = seMain;
                           snMode : TStartNode  = snStrict;
                           path   : string      = '');
var
  pv : string;
  rView : TRect;
  n : integer;
begin
  // apply GM property only once
  pv := gt.Root.GetProp(prGM);
  if pv <> ''
    then ApplyGM(self, Enter, pv);

  // apply SZ property only once
  n := BoardSizeOfGameTree(gt);
  if n < 0 then
    begin
      MessageDialog(msOk, imExclam,
                    [U('Invalid board size')  + ' : ' + pv2str(pv),
                     U('Size will be set to 19.')]);
      n := 19
    end;

  st.BoardSize := n; //todo: check...

  // apply ST property only once
  pv := gt.Root.GetProp(prST);
  ApplyST(self, Enter, pv);

  // apply CA property (charset) if any, otherwise force to main code page
  pv := gt.Root.GetProp(prCA);
  ApplyCA(self, Enter, pv);

  Status.AccumComment.Clear;

  gb.SetSize(st.BoardSize);

  if st.ZoomOnCorner then
    begin
      DetectQuadrant(gt, rView);
      gb.SetView(rView.Top, rView.Left, rView.Bottom, rView.Right)
    end;

  case seMode of
    seMain    : ResizeGoban; // must be done after setting board size
    seMainSameTab : ResizeGoban;
    seProblem : ResizeGoban;
    seIndex   : ResizeGoban;
    sePrint   : gb.Resize(1000, 1000)
  end;

  StartDisplay(snMode, path)
end;

// Initial display of an event

procedure TView.StartDisplay(snMode : TStartNode = snStrict;
                             path   : string      = '');
var
  gt0 : TGameTree;
begin
  if (not si.ApplyQuiet) and si.HasTimeProp then
    begin
      UpdateTiming(Black, '-');
      UpdateTiming(White, '-')
    end;

  gt := gt.Root;
  gb.Clear;
  gb.DrawEmpty;

  gt0 := StartNode(gt, snMode);
  ApplyNode(self, Enter);
  while gt <> gt0 do
    MoveForward;

  if st.OpenLast and st.OpenNode and (path <> '')
    then GoToPath(path, not kLastQuiet)
end;

// Quiet mode

procedure TView.ApplyQuiet(val : boolean);
begin
  si.ApplyQuiet := val;
  gb.Silence    := val
end;

// -- Basic moves in game tree -----------------------------------------------

// existence of next move assumed

procedure TView.MoveForward;
begin
  MoveToChild(gt.NextNode)
end;

// existence of previous move assumed
// visibility of moves determined in TGoban.IsMoveNumberVisibleOnBoard

procedure TView.MoveBackward;
var
  i, j : integer;
begin
  ApplyNode(self, Undo);
  gt := gt.PrevNode;
  ApplyNode(self, Redo);

  if gb.ShowMoveMode = smNumberN then
    begin
      // force display of move number current - N
      gb.GameBoard.GetMovePosition(gb.GameBoard.MoveNumber - (gb.NumberOfVisibleMoveNumbers - 1), i, j);
      if i > 0
        then gb.ShowVertex(i, j)
    end
end;

// x is supposed to be a child of current game tree (next move or variation of next move)
// visibility of moves determined in TGoban.IsMoveNumberVisibleOnBoard

procedure TView.MoveToChild(x : TGameTree);
var
  i, j : integer;
begin
  ApplyNode(self, Leave);
  gt := x;
  ApplyNode(self, Enter);

  if gb.ShowMoveMode = smNumberN then
    begin
      // force display of move number in previous move
      gb.GameBoard.GetMovePosition(gb.GameBoard.MoveNumber - 1, i, j);
      gb.ShowVertex(i, j);
      // erase move number current - N
      gb.GameBoard.GetMovePosition(gb.GameBoard.MoveNumber - gb.NumberOfVisibleMoveNumbers, i, j);
      if i > 0
        then gb.ShowVertex(i, j, True, {ignoreMove}True)
    end;
end;

// x is supposed to be a sibling of current game tree (next var or variation of next var)

procedure TView.MoveToSibling(x : TGameTree);
begin
  ApplyNode(self, Undo);
  gt := x;
  ApplyNode(self, Enter)
end;

// "sur place" move, used to refresh view

procedure TView.ReApplyNode;
begin
  ApplyNode(self, Leave);
  ApplyNode(self, Redo)
end;

// start position

procedure TView.MoveToStart(snMode : TStartNode  = snStrict);
begin
  StartDisplay(snMode)
end;

// end position

procedure TView.MoveToEnd;
begin
  GoToMove(MaxInt, not kLastQuiet)
end;

// -- Navigating to a move by number -----------------------------------------

procedure TView.GoForward(moveNum : integer);
begin
  while (gt <> nil) and (gt.NextNode <> nil)
                    and (gb.MoveNumber < moveNum) do
    MoveForward
end;

procedure TView.GoBackward(moveNum : integer);
begin
  while (gt <> nil) and (gt.PrevNode <> nil)
                    and (gb.MoveNumber > moveNum) do
    MoveBackward
end;

procedure TView.GoToMove(moveNum : integer;
                         lastQuiet : boolean;
                         snMode : TStartNode = snStrict);
var
  applyQuietBack : boolean;
begin
  applyQuietBack := si.ApplyQuiet;
  ApplyQuiet(True);

  if moveNum < 0
    then moveNum := gt.Length - (-moveNum) + 1;

  if moveNum > gb.MoveNumber
    then GoForward(moveNum)
    else GoBackward(moveNum);

  ApplyQuiet(False);
  gb.Draw;
  ApplyQuiet(applyQuietBack);

  // reapply last node if required to update UI
  if not lastQuiet
    then ReApplyNode
end;

// -- Navigation from move to move -------------------------------------------

procedure TView.GoToNode(gtTarget : TGameTree);
begin
  ApplyQuiet(True);
  StartDisplay;
  GoFromTo1(gtTarget);
  ApplyQuiet(False);
  gb.Draw;
  ReApplyNode;

  // move backward and come back to update timing display
  if gt.PrevNode <> nil then
    begin
      MoveBackward;
      MoveToChild(gtTarget)
    end
end;

procedure TView.GoFromTo1(gtTarget : TGameTree);
begin
  if gtTarget.PrevNode <> nil then
    begin
      GoFromTo1(gtTarget.PrevNode);
      MoveToChild(gtTarget)
    end
end;

// -- Move along a path (absolute) -------------------------------------------

// path : n1;n2;...
// odd  : number of moves forward
// even : number of the variation to select
// the board is not reset

procedure TView.GoToPath(path : string; lastQuiet : boolean);
var
  x : TGameTree;
begin
  x := gt.NodeAfterSteps(path);
  GoToNode(x);

  if not lastQuiet
    then ReApplyNode
end;

// -- Depth first navigation -------------------------------------------------

procedure TView.PrevNodeDepthFirst;
var
  x : TGameTree;
begin
  x := gt.PrevNodeDepthFirst;

  if x = gt.PrevNode
    then DoPrevMove
    else GoToNode(x)
end;

procedure TView.NextNodeDepthFirst;
var
  x : TGameTree;
begin
  x := gt.NextNodeDepthFirst;

  if x = gt.NextNode
    then DoNextMove
    else GoToNode(x)
end;

// -- Modification of game tree ----------------------------------------------

function TView.AllowModification : boolean;
begin
  Result := True
end;

// warning on invalid move

procedure TView.WarnOnInvalidMove(status : integer);
begin
  if not st.WarnInvMove
    then // nop
    else MessageDialog(msOk, imExclam, [U(CgbErrorMsg[status])],
                       st.WarnInvMove)
end;

// Creation of new follow-up node

procedure TView.AddNode(var done : boolean);
var
  x : TGameTree;
begin
  done := False;

  if not AllowModification
    then exit;

  x := TGameTree.Create;

  if x = nil
    then exit;

  gt.LinkChild(x);
  MoveToChild(x);

  si.FileSave := False;
  done := True
end;

// Creation of new follow-up move

procedure TView.NewChild(i, j : integer; var done : boolean);
var
  moveStatus : integer;
  x : TGameTree;
begin
  done := False;

  if not gb.IsValid(i, j, si.Player, moveStatus) then
    begin
      WarnOnInvalidMove(moveStatus);
      exit
    end;

  if not AllowModification
    then exit;

  x := NewMove(si.player, i, j);

  if x = nil
    then exit;

  gt.LinkChild(x);
  MoveToChild(x);

  si.FileSave := False;
  done := True
end;

procedure TView.AddMove(i, j : integer;
                        var done : boolean;
                        isEngineMove : boolean = False);
begin
  NewChild(i, j, done)
end;

procedure TView.AddVariation(i, j : integer; var done : boolean);
begin
  NewChild(i, j, done)
end;

// Undo move

procedure TView.UndoMove(var done : boolean);
var
  x, y : TGameTree;
begin
  done := False;

  if gt = nil
    then exit;

  if (gt.NextNode <> nil) and
     (MessageDialog(msOk, imDrago, [U('Move impossible to cancel')]) = 1{mrOk})
    then exit;

  if (not gt.HasMove) and
     (MessageDialog(msOk, imDrago, [U('Move impossible to cancel')]) = 1{mrOk})
    then exit;

  if not AllowModification()
     then exit;

  x := gt.PrevNode;
  gt.Unlink;
  //gt.RemoveAsBranch;
  ApplyNode(self, Undo);
  y := gt;
  y.Free;
  if x = nil
    then cl[si.indexTree] := x;

  gt := x;

  ApplyNode(self, Redo);

  si.FileSave := False;
  done := True
end;

// Delete branch

procedure TView.DeleteBranch(var done : boolean);
var
  x : TGameTree;
  pv : string;
begin
  done := False;

  if gt = nil
    then exit;

  if not AllowModification()
    then exit;

  if st.WarnDelBrch
    then
      if MessageDialog(msOkCancel, imQuestion, [U('Delete whole branch.'),
                                                U('Do you want to proceed?')],
                       st.WarnDelBrch)
         = 2{mrCancel}
        then exit;

  x := gt.PrevNode;
  gt.Unlink;
  if x = nil then
    begin
     // create new node and set root sgf properties (preserving size)
     x := NewStartingPosition(False);
     x.RemProp(prSZ);
     pv := gt.GetProp(prSZ);
     if pv <> ''
       then x.AddProp(prSZ, pv);

      cl[si.IndexTree] := x;
      //gt := x
    end;

  ApplyNode(self, Undo);
  gt.NextNode.FreeGameTree;
  gt.Free;
  gt := x;
  ApplyNode(self, Redo);

  si.FileSave := False;
  done := True
end;

// Markup input

procedure TView.DoEditMarkup(i, j  : integer; pr : TPropId; const v : string);
const
  lpr : array[1 .. 10] of TPropId = (prCR, prL , prLB, prM , prMA,
                                     prSQ, prTR, prTB, prTW, pr_W);
var
  k, ii, jj : integer;
  pv, sOld, sNew : string;
begin
  if (pr <> pr_W) and (not AllowModification())
    then exit;

  pv := gt.ValueAtij(pr, i, j);

  ApplyNode(self, Undo);

  // remove all marks at i,j
  for k := 1 to High(lpr) do
    gt.RemValij(lpr[k], i, j);

  if pr <> prLB
    then
      if pv = ''
        then gt.AddPropPack(pr, v)
        else // nop
    else
      begin
        pv2ijs(pv, ii, jj, sOld);
        pv2ijs( v, ii, jj, sNew);
        if (sNew = '') or (sNew = sOld)
          then // nop
          else gt.AddPropPack(pr, v)
      end;

  ApplyNode(self, Enter);

  if pr <> pr_W
    then si.FileSave := False
end;

// == Default implementation of actions ======================================

// -- Navigation in file -----------------------------------------------------

// -- First and last game in file

procedure TView.DoFirstGame;
begin
  if si.IndexTree <> 1
    then ChangeEvent(1)
end;

procedure TView.DoLastGame;
begin
  if si.IndexTree <> cl.Count
    then ChangeEvent(cl.Count)
end;

// -- Next and previous game in file

procedure TView.DoPrevGame;
begin
  if si.IndexTree > 1
    then ChangeEvent(si.IndexTree - 1)
end;

procedure TView.DoNextGame;
begin
  if si.IndexTree < cl.Count
    then ChangeEvent(si.IndexTree + 1)
end;

procedure TView.SelectGame;
begin
end;

// -- Navigation in game -----------------------------------------------------

// -- Start and end position

procedure TView.DoStartPos;
begin
  MoveToStart
end;

procedure TView.DoEndPos;
begin
  MoveToEnd
end;

// -- Previous and next move

procedure TView.DoPrevMove(snMode : TStartNode  = snStrict);
begin
  if (gt = nil) or (gt = StartNode(gt, snMode))
    then exit
    else MoveBackward
end;

procedure TView.DoNextMove;
begin
  if (gt = nil) or (gt.NextNode = nil)
    then exit
    else MoveForward
end;

procedure TView.SelectMove;
begin
end;

// -- Editing ----------------------------------------------------------------

procedure TView.DoNewMove(i, j : integer; isEngineMove : boolean = False);
var
  done : boolean;
begin
  AddMove(i, j, done, isEngineMove)
end;

procedure TView.DoNewVar(i, j : integer);
var
  done : boolean;
begin
  AddVariation(i, j, done)
end;

procedure TView.DoUndoMove;
var
  done : boolean;
begin
  UndoMove(done)
end;

procedure TView.DoDeleteBranch;
var
  done : boolean;
begin
  DeleteBranch(done)
end;

// Branch reordering

procedure TView.DoMakeMainBranch;
var
  gtCurrent : TGameTree;
  n1,n2 : integer; //DEBUG
begin
  if gt.IsOnMainBranch
    then exit;

  gtCurrent := gt;
  n1 := gt.Root.NumberOfNodes;
  cl[si.IndexTree] := gt.MakeMainBranch;
  gt := cl[si.IndexTree];
  n2 := gt.Root.NumberOfNodes;
  if n1 <> n2
    then ShowMessage('aie');
  si.FileSave := False;
  StartEvent;
  while gt <> gtCurrent do
    DoNextMove
end;

procedure TView.DoPromoteVariation;
var
  gtCurrent : TGameTree;
begin
  if gt.PrevVar = nil
    then exit;

  gtCurrent := gt;
  cl[si.IndexTree] := gt.PromoteVariation.Root;
  gt := cl[si.IndexTree];
  si.FileSave := False;
  StartEvent;
  GoToNode(gtCurrent)
end;

procedure TView.DoDemoteVariation;
var
  gtCurrent : TGameTree;
begin
  if gt.NextVar = nil
    then exit;

  gtCurrent := gt;
  cl[si.IndexTree] := gt.DemoteVariation.Root;
  gt := cl[si.IndexTree];
  si.FileSave := False;
  StartEvent;
  GoToNode(gtCurrent)
end;

// Removing properties

procedure TView.DoRemoveProperties(const propList : string; allGames : boolean);
var
  modified : boolean;
  i : integer;
begin
  if allGames = False
    then RemoveProperties(gt, propList, modified)
    else
      for i := 1 to cl.Count do
        RemoveProperties(cl[i], propList, modified);

  if modified
    then si.FileSave := False
end;

// ---------------------------------------------------------------------------

end.
