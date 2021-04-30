// ---------------------------------------------------------------------------
// -- Drago -- Handling of problem and replay modes --------- UProblems.pas --
// ---------------------------------------------------------------------------

unit UProblems;

// ---------------------------------------------------------------------------

interface

uses
  Dialogs, Sysutils, TntClasses, Types, StdCtrls, Forms, Controls, Graphics,
  TntStdCtrls,
  UViewMain, UViewBoard, UfrViewBoard;

// problem status consts
type
  TProblemStatus = (psIgnore, psRunning, psFailure, psSuccess,
                    psAssisted, psFreeMode, psResign);

// Problem mode
procedure PbEnter            (view : TViewMain);
procedure PbLeave            (view : TViewBoard);
procedure DisplayProblemBoxes(gv : TfrViewBoard);
procedure UpdateResultBox    (gv : TfrViewBoard; statusPb, statusTry : TProblemStatus);
procedure RefreshResultBox   (gv : TfrViewBoard);
procedure PbResult           (view : TViewBoard);
procedure IntersectionPB     (view : TViewBoard; i, j : integer);
procedure DoFirstMoveDuringPb(view : TViewBoard);
procedure DoPrevMoveDuringPb (view : TViewBoard);
procedure DoNextGameDuringPb (view : TViewBoard);
procedure DoFirstMoveAfterPb (view : TViewBoard);
procedure DoPrevMoveAfterPb  (view : TViewBoard);
procedure DoNextGameAfterPb  (view : TViewBoard);
procedure UpdateProblemTimer (view : TViewBoard);

// Replay mode
procedure GmEnter            (view : TViewMain);
procedure GmLeave            (view : TViewBoard);
procedure GmResult           (view : TViewBoard);
procedure DisplayReplayBox   (view : TViewBoard);
procedure IntersectionGM     (view : TViewBoard; i, j : integer);
procedure PlayCorrectMove    (view : TViewBoard; mode : integer);

// Joseki mode
procedure JoLoad;
procedure JoEnter            (view : TViewMain);
procedure JoLeave            (view : TViewBoard);
procedure IntersectionJO     (view : TViewBoard; i, j : integer);
procedure DoNextGameAfterJo  (view : TViewBoard);

// ---------------------------------------------------------------------------

implementation

uses
  StrUtils,
  TntGraphics,
  Properties, UGameTree, Std, Ux2y, UApply, Main,
  Define, DefineUi, UActions, UMainUtil,
  UGcom, Translate, UfmReplay, UfmJoseki, UfmProblems, UMemo, UStatus,
  GameUtils, BoardUtils,
  UProblemUtil, UfmMsg, 
  ViewUtils, SpTBXDkPanels,
  UView;

// -- Forwards ---------------------------------------------------------------

procedure IntersectionJOResult(view : TViewBoard); forward;

// == Problem mode ===========================================================

// -- Display of problem and solutions panels --------------------------------

const
  resCaption1 : array[TProblemStatus] of string = ('', 'Running', 'Failure',
                                                   'Success', 'Assisted',
                                                   'Free mode', 'Resign');
  resCaption2 : array[TProblemStatus] of char   = (#0, 'F', 'D', 'C', 'G', 'F', 'I');

// -- Initial display

procedure DisplayProblemBoxes(gv : TfrViewBoard);
var
  w : integer;
  i : TProblemStatus;
begin
  with gv do
    begin
      dpProblems.Caption := U('Problems');
      lbPb1.Caption      := U('Number');
      lbPb2.Caption      := U('Reference');
      lbPb4.Caption      := U('Attempts');
      lbPb5.Caption      := U('Success');
      lbPb3.Caption      := U('Time');
      lbSol1.Caption     := U('Problem status');
      lbSol2.Caption     := U('Attempt status');
      lbPb3v.Caption     := '-';

      // calculate max width of status caption
      w := 0;
      for i := psRunning to psResign do
        w := max(w, WideCanvasTextWidth(lbSol3.Canvas, U(resCaption1[i])));

      // set left of glyphs
      if lbSol3.Left + w + 5 > lbSol5.Left then
        begin
          lbSol5.Left := lbSol3.Left + w + 5;
          lbSol6.Left := lbSol3.Left + w + 5
        end;

      // apply glyph visibility
      lbSol5.Visible := Settings.PbShowGlyphs;
      lbSol6.Visible := Settings.PbShowGlyphs;
    end
end;

// -- Update of problem panel

procedure ShowNumRef(view : TView; gv : TfrViewBoard);
var
  gtIndex, nTrials, nSuccess : integer;
begin
  gtIndex := view.si.ListProblems[view.si.PbIndex];

  gv.lbPb1v.Caption := Format('%d / %d',[view.si.PbIndex, view.si.PbNumber]);
  gv.lbPb2v.Caption := Format('%d / %d',[gtIndex, view.cl.Count]);

  ProblemStatistics(gtIndex, nTrials, nSuccess);
  gv.lbPb4v.Caption := Format('%d', [nTrials]);
  if nTrials = 0
    then gv.lbPb5v.Caption := Format('%d%%', [0])
    else gv.lbPb5v.Caption := Format('%d%%', [Round(100 * nSuccess / nTrials)]);
end;

procedure ShowTimer(view : TView; gv : TfrViewBoard);
begin
  gv.lbPb3v.Caption := IntToStr(view.si.pbChrono) + 's'
end;

// -- Update solution panel

function StatusColor(status : TProblemStatus) : TColor;
begin
  case status of
    psFailure : Result := clRed;
    psSuccess : Result := clGreen;
    psAssisted : Result := clBlue; //$0080FF;
    else Result := clBlack;
  end;
end;

procedure UpdateResultBox(gv : TfrViewBoard; statusPb, statusTry : TProblemStatus);
begin
  // update problem status and glyph
  if statusPb <> psIgnore then
    begin
      gv.lbSol3.Font.Color := StatusColor(statusPb);
      gv.lbSol3.Caption := U(resCaption1[statusPb]);
      gv.lbSol5.Caption := resCaption2[statusPb];
    end;

  // update try status and glyph
  if statusTry <> psIgnore then
    begin
      gv.lbSol4.Font.Color := StatusColor(statusTry);
      gv.lbSol4.Caption := U(resCaption1[statusTry]);
      gv.lbSol6.Caption := resCaption2[statusTry];
    end
end;

// -- Refresh of result box for translation
// Retrieve solution status by using wingding character invariant by translation

procedure RefreshResultBox(gv : TfrViewBoard);

  procedure Trad(i : TProblemStatus; lb : TTntLabel);
  begin
    if (i = psFailure) and (gv.View.si.MainMode = muFree)
      then lb.Caption := U('Free')
      else lb.Caption := U(resCaption1[i]);
  end;

begin
  Trad(TProblemStatus(Pos(gv.lbSol5.Caption[1], #0'FDCG?I') - 1), gv.lbSol3);
  Trad(TProblemStatus(Pos(gv.lbSol6.Caption[1], #0'FDCG?I') - 1), gv.lbSol4)
end;

// -- Start and exit of problem session --------------------------------------

// forwards
procedure PbNext (view : TViewBoard); forward;
procedure PbExit (view : TViewBoard); forward;
procedure PbStart(view : TViewBoard); forward;
procedure OpenProblemPanel(view : TViewBoard); forward;
procedure CloseProblemPanel(view : TViewBoard); forward;
function MessageDialogAfterPbSession(view : TViewBoard) : boolean; forward;

// -- Start

procedure PbEnter(view : TViewMain);
begin
  // set up session parameters and start
  if not TfmProblems.Execute
    then exit;

  with view do
    begin
      si.pbMarkup  := st.PbMarkup; // default settings can be modified
      si.pbMode    := st.PbMode;   // during session. So save.
      si.pbRndPos  := st.PbRndPos; // "
      si.pbRndCol  := st.PbRndCol; // "
      si.pbNumber  := st.PbNumber; // "

      si.MainMode  := muProblem;
      si.ModeInter := kimPB;
      si.ShowVar   := False;       // hide variations during problem

      EnableCommands(view, mdProb);
      fmMain.ActiveViewBoard.frViewBoard.mnShow.Enabled := False;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Close := False;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Minimize := False
    end;

  fmMain.SelectView(vmBoard);
  PbStart(fmMain.ActiveViewBoard)
end;

procedure PbStart(view : TViewBoard);
begin
  with view do
    begin
      SetTabIcon(view, mdProb);

      OpenProblemPanel(view);
      DisplayProblemBoxes(frViewBoard);

      SelectProblems(cl, si);
      si.pbIndex := 1;
      si.pbNumberOk := 0;
      PbNext(view)
    end
end;

// -- Exit

procedure PbLeave(view : TViewBoard);
begin
  if view.si.MainMode = muFree
    then PbToggleFreeMode(view);

  EnableCommands(view, mdEdit);
  fmMain.ActiveViewBoard.frViewBoard.mnShow.Enabled := True;
  fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Close := True;
  fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Minimize := True;

  SetTabIcon(view, mdEdit);
  CloseProblemPanel(view);
  view.si.MainMode  := muNavigation;
  view.si.ModeInter := kimGE;
  view.si.ShowVar   := True;
  view.si.FileSave  := True;                              // to be checked
  view.frViewBoard.tmProblem.Enabled := False;
  PbExit(view);
  view.ChangeEvent(view.si.ListProblems[view.si.pbIndex], seMain, snExtend)
end;

// -- Handling sidebar

procedure ShowReplayPanel(view : TViewBoard; dp : TSpTBXDockablePanel);
var
  inikey : string;
begin
  inikey := Format('%p-', [Pointer(view)]);

  with view.frViewBoard do
    begin
      SaveSideBar(fmMain.IniFile, inikey);

      // hide panels
      dpGameInfo.Visible   := False;
      dpTiming.Visible     := False;
      dpNodeName.Visible   := False;
      dpGameTree.Visible   := False;
      dpVariations.Visible := False;

      // show panel
      dp.Visible   := True
    end;
end;

procedure ClearSections(const prefix : string);
var
  sections : TTntStringList;
  i : integer;
begin
  sections := TTntStringList.Create;
  try
    fmMain.IniFile.ReadSections(sections);
    for i := 0 to sections.Count - 1 do
      if AnsiStartsStr(prefix, sections[i])
        then fmMain.IniFile.EraseSection(sections[i])
  finally
    sections.Free
  end
end;

procedure RestorePanels(view : TViewBoard);
var
  inikey : string;
begin
  inikey := Format('%p-', [Pointer(view)]);
  view.frViewBoard.LoadSideBar(fmMain.IniFile, inikey);
  ClearSections(inikey)
end;

//

procedure OpenProblemPanel(view : TViewBoard);
begin
  with view.frViewBoard do
    begin
      // adjust height of problem pane according to timer visibility
      dpProblems.FixedDockedSize := False;
      dpProblems.Resizable := True;
      if Settings.PbShowTimer
        then dpProblems.Height := lbPb3.Top + lbPb3.Height + 10
        else dpProblems.Height := lbPb3.Top + 0;
      dpProblems.Resizable := False;
      dpProblems.FixedDockedSize := True
    end;

  ShowReplayPanel(view, view.frViewBoard.dpProblems)
end;

procedure CloseProblemPanel(view : TViewBoard);
begin
  view.frViewBoard.dpProblems.Visible := False;
  RestorePanels(view)
end;

// -- Start and exit of current problem solving ------------------------------

// -- Start

procedure PbNext(view : TViewBoard);
var
  i : integer;
begin
  with view do
    begin
      ShowNumRef(view, frViewBoard);
      UpdateResultBox(frViewBoard, psRunning, psRunning); // first trial display
      frViewBoard.tmProblem.Enabled := True;
      si.pbChrono := 0;

      if si.pbRndPos
        then gb.CoordTrans := RandomTrans
        else gb.CoordTrans := trIdent;
      if si.pbRndCol
        then gb.ColorTrans := TColorTrans(Random(2))
        else gb.ColorTrans := ctIdent;

      i := si.ListProblems[si.pbIndex];
      cl[i] := cl[i].Root;
      gt := cl[i];

      ChangeEvent(si.ListProblems[si.pbIndex], seProblem, snExtend);

      si.pbUndo          := False;
      si.pbResign        := False;
      si.pbCountedResult := False;
      si.pbLastMoveKnown := True;
      si.myPbSolMarkup   := DetectMarkupMode(gt, si)
    end
end;

// -- Exit

procedure PbExit(view : TViewBoard);
begin
  with view do
    begin
      gb.CoordTrans := trIdent;
      gb.ColorTrans := ctIdent;
      gt := gt.Root
    end
end;

// -- Processing of a move in Problem mode -----------------------------------

procedure IntersectionPB(view : TViewBoard; i, j : integer);
var
  status : integer;
  x : TGameTree;
begin
  with view do
    begin
      if IsContinuation(gt, si.Player, i, j) = nil
        then
          if not gb.IsValid(i, j, si.Player, status)
            then WarnOnInvalidMove(status)
            else
              begin
                if gt.NextNode = nil // possible if event with no move
                  then DoNewMove(i, j)
                  else DoNewVar (i, j);

                si.pbLastMoveKnown := False;
                PbResult(view)
              end
        else
          begin
            // play user move at i,j
            si.pbLastMoveKnown := True;
            Continuation(view, i, j); // TR and BM will do the job
            PlayStoneSound;

            if gt.NextNode = nil
              then PbResult(view)
              else
                begin
                  if Settings.EnableSounds
                    then Sleep(300);

                  if Settings.PbPlayBothColors
                    then
                      begin
                        // wait for player
                      end
                    else
                      begin
                        // select and play program move
                        ApplyNode(view, Leave);
                        x := gt;
                        PbSelectNextMove(x, si);
                        gt := x;
                        ApplyNode(view, Enter);

                        PlayStoneSound;

                        if gt.NextNode = nil
                          then PbResult(view)
                      end
                end
          end
    end
end;

// -- Display the result of the current problem

const
  SolutionStatus : array[boolean, boolean] of TProblemStatus
                 = ((psFailure, psFailure),
                    (psSuccess, psAssisted));

procedure PbResult(view : TViewBoard);
var
  pbCorrect : boolean;
begin
  with view do
    begin
      frViewBoard.tmProblem.Enabled := False;
      pbCorrect := si.pbLastMoveKnown and (not si.pbResign)
                                      and IsARightSol(gb, gt, si);

      if not si.pbCountedResult then
        begin
          si.pbCountedResult := True;

          if pbCorrect and not si.pbUndo
            then inc(si.pbNumberOk);

          PbUpdateNth(si.IndexTree,
                      pbCorrect and not si.pbUndo,
                      si.pbMode = 1);

          si.pbPbCorrect := pbCorrect;
          si.pbPbUndo    := si.pbUndo
        end
      else
        begin
          if not si.pbPbCorrect and pbCorrect then
            begin
              si.pbPbCorrect := True;
              si.pbPbUndo    := True
            end
        end;

      if si.pbResign
        then UpdateResultBox(frViewBoard, psIgnore, psResign)
        else UpdateResultBox(frViewBoard,
                             SolutionStatus[si.pbPbCorrect, si.pbPbUndo],
                             SolutionStatus[pbCorrect     , si.pbUndo]);

      si.ModeInter := kimPF
      // Idle
    end
end;

procedure ExitResult(view : TViewBoard);
begin
  with view do
    begin
      si.ModeInter := kimPB;
      frViewBoard.tmProblem.Enabled := True
    end
end;

// -- Processing of commands for problem mode --------------------------------

// -- Commands during problem

procedure DoFirstMoveDuringPb(view : TViewBoard);
begin
  with view do
    begin
      if gt <> StartNode(gt) then
        begin
          si.pbUndo := True;
          MoveToStart(snExtend)
        end
    end
end;

procedure DoPrevMoveDuringPb(view : TViewBoard);
begin
  if view.gt = StartNode(view.gt)
    then Application.ProcessMessages
    else
      begin
        view.si.pbUndo := True;
        view.DoPrevMoveInherited(snExtend);
        view.DoPrevMoveInherited(snExtend)
      end
end;

procedure DoNextGameDuringPb(view : TViewBoard);
begin
  view.si.pbResign := True;
  if view.si.MainMode = muFree
    then PbToggleFreeMode(view);

  PbResult(view)
end;

// -- Commands after problem

procedure DoFirstMoveAfterPb(view : TViewBoard);
begin
  if not view.si.pbLastMoveKnown then
    begin
      view.DoUndoMove;
      view.si.pbLastMoveKnown := True
    end;
  view.ChangeEvent(view.si.ListProblems[view.si.pbIndex], seMain, snExtend);
  view.si.pbUndo := False;
  view.si.pbResign := False;
  UpdateResultBox(view.frViewBoard, psIgnore, psRunning); // next trials running
  ExitResult(view)
end;

procedure DoPrevMoveAfterPb(view : TViewBoard);
begin
  if not view.si.pbLastMoveKnown
    then
      begin
        view.DoUndoMove;
        view.si.pbLastMoveKnown := True
      end
    else
      if view.gt <> StartNode(view.gt) then
        begin
          view.DoPrevMoveInherited(snExtend);
          if Odd(view.gb.MoveNumber)
            then view.DoPrevMoveInherited(snExtend)
        end
      else Application.ProcessMessages;

  view.si.pbUndo := False;
  view.si.pbResign := False;
  UpdateResultBox(view.frViewBoard, psIgnore, psRunning); // next trials running
  ExitResult(view)
end;

procedure DoNextGameAfterPb(view : TViewBoard);
begin
  ExitResult(view);
  if view.si.pbIndex < view.si.pbNumber
    then
      begin
        PbExit(view);
        inc(view.si.pbIndex);
        PbNext(view)
      end
    else
      begin
        if MessageDialogAfterPbSession(view)
          then PbLeave(view)
          else
            begin
              PbLeave(view);
              PbEnter(view)
            end
      end
end;

function MessageDialogAfterPbSession(view : TViewBoard) : boolean;
var
  nProblems, nVisited, nTrials, nSuccess : integer;
  s : string;
begin
  CollectionStatistics(view.cl, nProblems, nVisited, nTrials, nSuccess);
  if nTrials = 0
    then s := '0.00%'
    else s := Format('%2.2f%%', [100.0 * nSuccess / nTrials]);

  Result := MessageDialog(msYesNo, imDrago,
                         [U('End of problem session.'),
                         '',
                          WideFormat(U('Session result: %d / %d'), [view.si.pbNumberOk,
                                                                    view.si.pbNumber]),
                          WideFormat(U('Collection score after session: %s'), [s]),
                          '',
                          U('More problems?')]) = mrNo
end;

// -- Problem timer event (triggered each second) ----------------------------

procedure UpdateProblemTimer(view : TViewBoard);
begin
  inc(view.si.pbChrono);
  ShowTimer(view, view.frViewBoard)
end;

// == Replay mode ============================================================

procedure GmStart(view : TViewBoard); forward;

// -- Start of replay session

procedure OpenReplayPanel(view : TViewBoard);
begin
  with view.frViewBoard do
    begin
      // adjust height of problem pane according to number of attempts
      dpReplayGame.FixedDockedSize := False;
      dpReplayGame.Resizable := True;
      if Settings.GmNbAttempts = 1
        then dpReplayGame.Height := lbGm5.Top
        else dpReplayGame.Height := lbGm5.Top + lbGm5.Height + 10;
      dpReplayGame.Resizable := False;
      dpReplayGame.FixedDockedSize := True
    end;

  ShowReplayPanel(view, view.frViewBoard.dpReplayGame)
end;

procedure DisplayReplayBox(view : TViewBoard);
const
  strPlayer : array[0 .. 3] of string = ('', 'Black', 'White', 'Both');
begin
  with view.frViewBoard do
    begin
      dpReplayGame.Caption := U('Game2');
      lbGm1 .Caption := U('Black');
      lbGm2 .Caption := U('White');
      lbGm3 .Caption := U('You');
      lbGm4 .Caption := U('Moves');
      lbGm5 .Caption := U('Hint');
      lbGm1v.Caption := pv2str(view.gt.Root.GetProp(prPB));
      lbGm2v.Caption := pv2str(view.gt.Root.GetProp(prPW));
      lbGm3v.Caption := U(strPlayer[view.si.gmPlayer]);
      lbGm4v.Caption := IntToStr(view.si.gmLength);
    end
end;

procedure GmEnter(view : TViewMain);
begin
  // set up session parameters and start
  if not TfmEnterGm.Execute
    then exit;

  with view do
    begin
      si.gmMode     := Settings.GmMode;    // default settings can be modified
      si.gmPlayer   := Settings.GmPlayer;  // during session. So save.
      si.gmPlay     := Settings.GmPlay;    // "
      si.gmNbFuseki := Settings.GmNbFuseki;// "

      si.MainMode   := muReplayGame;
      si.ModeInter  := kimRG;
      si.ShowVar    := False;       // hide variations during replay

      EnableCommands(view, mdGame);
      fmMain.ActiveViewBoard.frViewBoard.mnShow.Enabled := False;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Close := False;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Minimize := False
    end;

  fmMain.SelectView(vmBoard);
  GmStart(fmMain.ActiveView as TViewBoard)
end;

procedure GmStart(view : TViewBoard);
var
  n : integer;
begin
  with view do
    begin
      SetTabIcon(view, mdGame);
      OpenReplayPanel(view);

      UProblemUtil.SelectGame(cl, si, n);

      if Settings.GmPlay = 2
        then // nop, start from current position
        else view.ChangeEvent(n);
      si.gmLength := LengthOfGame(gt);

      DisplayReplayBox(view);
      frViewBoard.DrawReplayHint(0, 0);

      si.GmRightMoves := 0;
      si.GmWrongMoves := 0;
      si.GmLatestWrongMove := -1;

      if si.gmLength = 0
        then GmResult(view)
        else
          if (si.gmPlayer <> BOTH) and (si.gmPlayer <> si.player) then
            begin
              PlayStoneSound;
              si.ModeInter := kimGE; // hack to avoid considering as wrong ...
              view.DoNextMove;       // ... move in DoNextMoveDuringGame
              si.ModeInter := kimRG
            end
    end
end;

// -- End of replay session

procedure GmLeave(view : TViewBoard);
begin
  with view do
    begin
      EnableCommands(view, mdEdit);
      fmMain.ActiveViewBoard.frViewBoard.mnShow.Enabled := True;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Close := True;
      fmMain.ActiveViewBoard.frViewBoard.dpComments.Options.Minimize := True;
      SetTabIcon    (view, mdEdit);
      frViewBoard.dpReplayGame.Visible := False;
      RestorePanels(view);
      si.MainMode  := muNavigation;
      si.ModeInter := kimGE;
      si.ShowVar   := True;
      
      //MainPanel_Update(frViewBoard, gt)
    end
end;

procedure GmResult(view : TViewBoard);
var
  n, x : integer;
  s1, s2, s3 : WideString;
begin
  with view do
    begin
      n := si.gmRightMoves + si.gmWrongMoves;
      if n = 0
        then x := 0
        else x := Round(si.gmRightMoves * 100 / n);

      s1 := WideFormat(U('Score') + ' %d%% (%d / %d)', [x, si.gmRightMoves, n]);
      if si.GmPlay in [0, 2]
        then s2 := U('End of game')
        else s2 := U('End of fuseki');

      if si.GmPlay in [0, 2]
        then s3 := GtResultToString(gt);

      if (si.GmPlay = 1) or (s3 = '')
        then UfmMsg.MessageDialog(msOk, imDrago, [s2 + ' ! ' + s1])
        else UfmMsg.MessageDialog(msOk, imDrago, [s2 + ' ! ' + s3, s1]);

      GmUpdateNth(si.IndexTree, si.gmPlayer, si.gmPlay, x);
      GmLeave(view)
    end
end;

// -- Processing of a move in replay mode ------------------------------------

// -- Test end of game

procedure IntersectionGMResult(view : TViewBoard);
begin
  with view do
    if (gt.NextNode = nil) or                          // no more moves
       ((si.GmPlay = 1) and (gb.MoveNumber >= si.GmNbFuseki)) // fuseki
      then GmResult(view)
      else
        if (si.GmPlayer <> BOTH) and (si.GmPlayer <> si.Player)
          then
            begin
              PlayStoneSound;
              MoveForward;
              if ((si.GmPlay in [0, 2]) and (gt.NextNode = nil)) or
                 ((si.GmPlay = 1) and (gb.MoveNumber >= si.GmNbFuseki))
                then GmResult(view)
            end
end;

// -- Sequencing of displays for an incorrect move

procedure ReplayError(view : TViewBoard; i, j, mode : integer);
var
  status, iRef, jRef, d : integer;
begin
  with view do
    begin
      // play incorrect move and setup mark
      gb.Play(i, j, si.player, status);
      PlayStoneSound;
      si.ModeInter := kimNOP;
      gb.ShowTempMark(i, j, mrkBH);
      Application.ProcessMessages;

      // update score data
      if gb.MoveNumber <> si.GmLatestWrongMove then
        case mode of
          kimRG : inc(si.gmWrongMoves);
          kimJO : inc(si.joWrongMoves);
        end;
      si.GmLatestWrongMove := gb.MoveNumber;

      // update hint
      gt.NextNode.GetMoveCoordinates(iRef, jRef);
      d := Abs(i - iRef) + Abs(j - jRef);
      d := 100 - Min(100, d * 10);
      frViewBoard.DrawReplayHint(d, 100);
      Application.ProcessMessages;

      // wait
      Sleep(800);

      // remove incorrect move and mark
      gb.Undo;
      gb.HideTempMarks;
      Application.ProcessMessages;

      if Settings.GmNbAttempts = 1
        then PlayCorrectMove(view, mode)
        else
          begin
            si.ModeInter := mode;
            Actions.acNextMove.Enabled := True;
          end
    end
end;

procedure PlayCorrectMove(view : TViewBoard; mode : integer);
var
  i, j : integer;
begin
  with view do
    begin
      // play correct move and setup mark
      case mode of
        kimRG : MoveForward;
        kimJO : NextMoveRnd(view);
      end;
      PlayStoneSound;
      Application.ProcessMessages;
      gt.GetMoveCoordinates(i, j);
      gb.ShowTempMark(i, j, mrkGH);
      Application.ProcessMessages;
      frViewBoard.DrawReplayHint(0, 0);

      // wait
      Sleep(800);

      // remove mark and test end of game
      gb.HideTempMarks;
      si.ModeInter := mode;
      case mode of
        kimRG : IntersectionGMResult(view);
        kimJO : IntersectionJOResult(view)
      end
    end
end;

// -- Processing of user move

procedure IntersectionGM(view : TViewBoard; i, j : integer);
var
  status : integer;
begin
  with view do
    begin
      if (gt = nil) or (gt.NextNode = nil)
        then exit; // nop : possible if game with no move

      if not gb.IsValid(i, j, si.Player, status)
        then WarnOnInvalidMove(status)
        else
          if IsContinuation(gt, si.Player, i, j) = nil
            then ReplayError(view, i, j, kimRG)
            else
              begin
                Actions.acNextMove.Enabled := False;
                Continuation(view, i, j);

                if gb.MoveNumber <> si.GmLatestWrongMove 
                  then inc(si.gmRightMoves);
                frViewBoard.DrawReplayHint(0, 0);

                PlayStoneSound;
                if Settings.EnableSounds
                  then Sleep(300);
                IntersectionGMResult(view)
              end;
    end
end;

// == Joseki mode ============================================================

// -- Loading

procedure StoreNodeNum(gt : TGameTree);
// not used
// gt.Number stored in LoadTreeView
var
  x : TGameTree;
  n : integer;
begin
  if gt = nil then exit;
  n := 1;
  x := gt.NextNode;
  while x <> nil do
    begin
      StoreNodeNum(x);
      inc(n, x.Number);
      x := x.NextVar
    end;
  gt.Number := n
end;

procedure JoLoad;
begin
  //fmMain.gt := fmMain.gt.Root;
  //StoreNodeNum(fmMain.gt)
end;

// -- Start one joseki

procedure JoStartOne(view : TViewBoard);
begin
  view.gb.CoordTrans := RandomTrans;
  view.GotoMove(0, False);
  view.GotoPath(Settings.JoPath, False);

  if (Settings.joPlayer <> BOTH) and (Settings.joPlayer <> view.si.Player)
    then NextMoveRnd(view)
end;

// -- Start of joseki session

procedure JoEnter(view : TViewMain);
const
  strPlayer : array[0..3] of string = ('', 'Black', 'White', 'Both');
begin
  if fmEnterJo.ShowModal = 2 {idCancel}
    then exit;

  view.si.ModeInter := kimJO;
  Settings.joPath := view.gt.StepsToNode;
  EnableCommands(view, mdJski);
  view.si.joIndex := 1;

  (*
  ShowProblemBox(80, ['Partie', 'Black', 'White', 'You', 'Coups']);
  fmMain.lbPb1v.Caption := pv2str(GetProp(gt, prPB));
  fmMain.lbPb2v.Caption := pv2str(GetProp(gt, prPW));
  fmMain.lbPb3v.Caption := U(strPlayer[st.gmPlayer]);
  fmMain.lbPb4v.Caption := IntToStr(gmLength);
  *)
  view.si.joRightMoves := 0;
  view.si.joWrongMoves := 0;

  JoStartOne(view as TViewBoard)
end;

// -- End of joseki session

procedure JoLeave(view : TViewBoard);
begin
  //fmMain.tmProblem.Enabled := false;
  //ShowSolutionBox(false);
  //CloseProblemBox; // dans cet ordre
  view.si.ModeInter := kimGE;
  EnableCommands(view, mdEdit)
end;

procedure JoResult(view : TViewBoard);
var
  n, x : integer;
  s    : string;
begin
  n := view.si.joRightMoves + view.si.joWrongMoves;
  if n = 0
    then x := 0
    else x := (view.si.joRightMoves * 100 + 1) div n;
  s := Format('Score %d%% (%d / %d)', [x, view.si.joRightMoves, n]);
  ShowMessage('End of joseki ! ' + s);

  Actions.acNextGame.Enabled := True;
  //JoLeave(gb, gt, st)
end;

// -- Test end of joseki

procedure IntersectionJOResult(view : TViewBoard);
begin
  if view.gt.NextNode = nil
    then JoResult(view)
    else
      if (Settings.joPlayer <> BOTH) and (Settings.joPlayer <> view.si.player)
        then
          begin
            NextMoveRnd(view);
            if view.gt.NextNode = nil
              then JoResult(view)
          end
end;

// -- Processing of a move in Joseki mode ------------------------------------

procedure IntersectionJO(view : TViewBoard; i, j : integer);
var
  status : integer;
begin
  if IsContinuation(view.gt, view.si.Player, i, j) <> nil
    then
      begin
        inc(view.si.joRightMoves);
        Continuation(view, i, j);
        IntersectionJOResult(view);
        exit
      end;

  if not view.gb.IsValid(i, j, view.si.Player, status)
    then view.WarnOnInvalidMove(status)
    else ReplayError(view, i, j, kimJO)
end;

procedure DoNextGameAfterJo(view : TViewBoard);
begin
  //ExitResult(st);
  (*
  inc(indJoseki);
  if indJoseki <= st.joNumber
    then JoStartOne(gb, gt, st)
    else
      begin
        if MessageDlg('End of joseki session ! Score ' +
                        IntToStr(st.pbNumberOk) + ' sur ' +
                        IntToStr(si.pbNumber) + #13 +
                        'More Joseki ?',
                        mtCustom, [mbYes, mbNo], 0) = 7 {idNo}
          then JoLeave(gb, gt, st)
          else
            begin
              JoLeave(gb, gt, st);
              JoEnter(gb, gt, st)
            end
      end
  *)
end;

procedure DoFirstMoveDuringJoseki(view : TViewBoard);
begin
end;

procedure DoPrevMoveDuringJoseki(view : TViewBoard);
begin
end;

procedure DoNextMoveDuringJoseki(view : TViewBoard);
begin
end;

procedure DoLastMoveDuringJoseki(view : TViewBoard);
begin
end;

// ---------------------------------------------------------------------------

end.
