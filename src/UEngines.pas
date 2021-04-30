// ---------------------------------------------------------------------------
// -- Drago -- Game engine interface ------------------------- UEngines.pas --
// ---------------------------------------------------------------------------

unit UEngines;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, StrUtils, Classes, Controls, Forms,
  UView, UViewBoard, UGoban, UGameTree, Ustatus, UGtp,
  EngineSettings;

type
  TOnReturnStr = procedure (view : TView; const x : string);

function  EngineArguments  (engine : TEngineSettings) : string; overload;
procedure DoMainNewEngineGame;
procedure StopEngine       (view : TViewBoard);
procedure AbortEngineMode  (view : TViewBoard);
procedure IntersectionGtp  (view : TViewBoard; i, j : integer);
procedure GtpUndo          (view : TViewBoard);
procedure ResignEG         (view : TViewBoard);
procedure EngineInformation(engineSettings : TEngineSettings;
                            var detected : boolean;
                            var ident : string);
procedure ScoreEstimate    (view : TView; aOnReturn : TOnReturnStr);
procedure SuggestMove      (view : TView; aOnReturn : TOnReturnStr);
procedure InfluenceRegions (view : TView; aOnReturn : TOnReturnStr);
procedure GroupStatus      (view : TView; aOnReturn : TOnReturnStr; const coord : string);
procedure DoPass           (view : TViewBoard);
procedure DoResign         (view : TViewBoard);
procedure EndOfTime        (view : TViewBoard);
procedure ApplyGameTimer   (view : TViewBoard);
procedure ShowGtpWindow;
function  IsOneEngineRunning : boolean;
procedure WaitWhileGtpActive(gtp : TGtp);

// ---------------------------------------------------------------------------

implementation

uses
  Types, DateUtils, TntIniFiles,
  DosCommand,
  Define, DefineUi, Std, Ux2y, Properties, Main, UActions, UGcom, UGmisc, UMainUtil,
  UfmNewEngineGame, UStatusMain, Sgfio,
  UfmFreeH, Translate, UfmGtp, UfmMsg, UViewBoardPanels, Counting,
  UViewMain;

// -- Forwards ---------------------------------------------------------------

procedure Trace               (const s : string); forward;
procedure GtpError            (view : TObject); forward;
procedure GtpCrash            (view : TObject); forward;
procedure WaitEngine          (view : TView; mode : boolean); forward;
procedure StartEngineGame     (view : TViewBoard); forward;
procedure StartEngineGame1    (view : TObject); forward;
procedure StartEngineGame2    (view : TObject); forward;
procedure StartEngineFirstMove(view : TObject); forward;
procedure CallbackFreeH       (view : TViewBoard); forward;
procedure ProcessMoveByUser   (view : TViewBoard; i, j : integer); forward;
procedure ProcessMoveByUser2  (view : TObject); forward;
procedure ProcessMoveByUser3  (view : TObject); forward;
procedure ProcessMoveByEngine (view : TObject); forward;
procedure GtpUndo2            (view : TObject); forward;
procedure EndGame             (view : TView); forward;
procedure EndGame2            (view : TObject); forward;
procedure EndGame3            (view : TObject); forward;
procedure NewEngineGameInfo   (view : TView); forward;
function  AB2korlist          (view : TViewBoard) : string; forward;
procedure FreeEngine          (view : TObject); forward;
procedure GetTimeSettings     (var mainTime, overTime, overStones : integer); forward;
procedure StartMainTimePeriod (view : TViewBoard); forward;
procedure StartOverTimePeriod (view : TViewBoard); forward;
procedure CheckOverTime       (view : TViewBoard); forward;
procedure LoseOnTime          (view : TViewBoard); forward;
procedure StopTiming          (view : TViewBoard); forward;

procedure ApplyTimeEventStartThinking(view : TViewBoard); forward;
procedure ApplyTimeEventEndThinking(view : TViewBoard); forward;
procedure InitializeOverTimePeriod(view : TViewBoard; player : integer); forward;
procedure CreateHideGtpWindow; forward;

// -- Processing of new game command -----------------------------------------

function ActiveView : TViewMain;
begin
  Result := fmMain.ActiveView
end;

// Starting sequence, update active view in main window
// StartEngineGame should set all view local parameters

procedure DoMainNewEngineGame;
var
  h : integer;
  x : TGameTree;
  ok : boolean;
  s : string;
begin
  Assert((not Status.RunFromIDE) or (ActiveView.gtp = nil));

  if (TfmNewEngineGame.Execute = mrCancel) or (not Settings.PlayingEngine.IsAvailable)
    then exit;

  if Settings.PlStartPos in [spSelect, spMatch]
    then
      if (not Settings.PlFree) or (Settings.Handicap < 2)
        then
          // no free placement
          begin
            DoMainNewFile(ActiveView.si.EngineTab and Settings.PlUseSameTab, True);
            Application.ProcessMessages;
            StartEngineGame(ActiveView as TViewBoard)
          end
        else
          // free placement
          begin
            // create view without handicap
            h := Settings.Handicap;
            Settings.Handicap := 0;
            DoMainNewFile(ActiveView.si.EngineTab and Settings.plUseSameTab, True);
            Settings.Handicap := h;

            if Settings.PlPlayer = Black
              then
                begin
                  // free handicap, engine sets stones
                  ActiveView.UpdatePlayer(White);
                  ActiveView.gt.Root.PutProp(prPL, '[W]');

                  StartEngineGame(ActiveView as TViewBoard)
                end
              else
                begin
                  // free handicap, player sets stones
                  Actions.acStartPos.Enabled := False;
                  Actions.acPrevMove.Enabled := False;
                  Actions.acUndoMove.Enabled := False;

                  TfmFreeH.Execute(ActiveView as TViewBoard, CallbackFreeH)
                end
          end
    else
      // start game from current position
      begin
        if not (ActiveView is TViewBoard) then
          begin
            ActiveView.MessageDialog(msOk, imExclam, [U('Please select board view before starting game.')]);
            exit
          end;

        with ActiveView do
          begin
            x := gt.MovesToNode;
            s := gt.StepsToNode;
            PrintWholeTree(Status.TmpPath + '\tmp.sgf', x, False, False);
            DoMainOpenFile(Status.TmpPath + '\tmp.sgf', 1, s, False, ok, True);
            ActiveView.si.FileSave := False;
            x.FreeGameTree
          end;

        StartEngineGame(ActiveView as TViewBoard)
      end;

  CreateHideGtpWindow
end;

// Callback for fmFreeH

procedure CallbackFreeH(view : TViewBoard);
begin
  view.UpdatePlayer(White);
  StartEngineGame(view)
end;

// Arguments

function UpdateArgument(const arg, value : string) : string; overload;
begin
  if (arg = 'not.required') or (arg = 'not.handled')
    then Result := ''
    else Result := ' ' + StringReplace(arg, '*', value, []);
end;

function UpdateArgument(const arg : string; value : integer) : string; overload;
begin
  Result := UpdateArgument(arg, IntToStr(value))
end;

function EngineArguments(engine : TEngineSettings) : string; overload;
begin
  if engine.FArgConnection <> 'not.required'
    then Result := engine.FArgConnection;

  if engine.FAvailLevel
    then Result := Result + UpdateArgument(engine.FArgLevel, engine.FLevel);
    
  Result := Result + UpdateArgument(engine.FArgBoardSize, Settings.BoardSize);

  if Settings.PlScoring = scChinese
    then Result := Result + ' ' + UpdateArgument(engine.FArgChineseRules, '');
  if Settings.PlScoring = scJapanese
    then Result := Result + ' ' + UpdateArgument(engine.FArgJapaneseRules, '');

  // timing
  case Settings.PlTimingMode of
    tmNo :
      ; // nop
    tmTotalTime :
      Result := Result + UpdateArgument(engine.FArgTotalTime, Settings.PlTotalTime);
    tmTimePerMove :
      Result := Result + UpdateArgument(engine.FArgTimePerMove, Settings.PlTimePerMove);
    tmOverTime :
      ; // nop
  end;

  // add custom arguments
  Result := Result + ' ' + engine.FCustomArgs
end;

function EngineArguments : string; overload;
begin
  Result := EngineArguments(Settings.PlayingEngine)
end;

// GTP request for new game

procedure StartEngineGame(view : TViewBoard);
var
  arguments : string;
  ok : boolean;
  h : integer;
  x : TGameTree;
begin
  with view do
    begin
      // set parameters proper to view
      si.EngineColor := Settings.PlPlayer;
      si.TimingMode  := Settings.PlTimingMode;

      gtp := TGtp.Create(view, Trace, GtpError, nil);
      arguments := EngineArguments;
      Trace(arguments);
      gtp.Start(Status.PlayingEngine.FPath, arguments, ok);

      if not ok then
        begin
          MessageDialog(msOk, imSad, [U('Current engine is unable to start...')]);
          Application.ProcessMEssages;
          gtp.Free;
          gtp := nil;
          exit
        end;

      // assign now error handlers. An error during gtp.Start have been caught
      // by testing the ok flag.
      gtp.OnGtpError := GtpError;
      gtp.OnGtpCrash := GtpCrash;

      NewEngineGameInfo(view);
      view.frViewBoard.UpdateGameEnginePlayers;
      view.UpdateGameInformation;
      si.MainMode  := muEngineGame;
      si.ModeInter := kimEG;

      EnableCommands(view, mdPlay);
      SetTabIcon    (view, mdPlay);
      (TabSheet as TTabSheetEx).Caption := Settings.PlayingEngine.FName;

      h := iff(Settings.PlStartPos in [spSelect, spMatch], Settings.Handicap, 0);
      if Status.PlStartPos = spCurrent
        then x := gt
        else x := nil;

      WaitEngine(view, True);
      gtp.NewGame(StartEngineGame1, Settings.BoardSize, h, KomiValue,
                  (si.EngineColor = Black),
                  Settings.PlFree, AB2korlist(view), x) ;

      if Assigned(fmGtp)
        then fmGtp.edSend.Text := ''
    end
end;

procedure SendGtpArgument(view : TView; const gtparg : string; value : integer);
var
  s : string;
begin
  if (gtparg = 'not.required') or (gtparg = 'not.handled')
    then StartEngineGame2(view)
    else
      begin
        s := StringReplace(gtparg, '*', IntToStr(value), []);
        with view as TView do
          gtp.SendAndIgnoreResult(StartEngineGame2, s)
      end
end;

procedure StartEngineGame1(view : TObject);
begin
  // send dedicated timing gtp commands
  case Settings.PlTimingMode of
    tmNo :
      StartEngineGame2(view);
    tmTotalTime :
      SendGtpArgument(view as TView, Settings.PlayingEngine.FGtpTotalTime,
                                     Settings.PlTotalTime);
    tmTimePerMove :
      SendGtpArgument(view as TView, Settings.PlayingEngine.FGtpTimePerMove,
                                     Settings.PlTimePerMove);
    tmOverTime :
      StartEngineGame2(view)
  end
end;

// Send time settings if required

procedure StartEngineGame2(view : TObject);
var
  viewBoard : TViewBoard;
  mainTime, overTime, overStones : integer;
begin
  viewBoard := view as TViewBoard;

  if Settings.PlTimingMode = tmNo
    then
      begin
        viewBoard.si.ForceShowTime := False;
        viewBoard.frViewBoard.dpTiming.Visible := False;
        viewBoard.UpdatePanes(viewBoard.gt)
      end
    else StartMainTimePeriod(viewBoard);

  // send time settings to engine if required
  if Settings.PlTimingMode = tmNo
    then StartEngineFirstMove(view)
    else
      // avoid sending gtp time command if not required (mogo doesn't seem to like that)
      if (Settings.PlTimingMode = tmTimePerMove)
          and (Settings.PlayingEngine.IsGtpTimeCommandRequired = False)
        then StartEngineFirstMove(view)
        else
          begin
            GetTimeSettings(mainTime, overTime, overStones);
            viewBoard.gtp.TimeSettings(StartEngineFirstMove,
                                       mainTime, overTime, overStones)
          end
end;

// Play first move: all game settings done, either wait for user move, or ask to engine

procedure StartEngineFirstMove(view : TObject);
var
  viewBoard : TViewBoard;
begin
  viewBoard := view as TViewBoard;

  with viewBoard do
    if si.EngineColor = si.Player
      then gtp.PlayFirst(ProcessMoveByEngine, 'bw'[si.Player])
      else WaitEngine(viewBoard, False);

  if Settings.PlTimingMode = tmTimePerMove
    then
      begin
        StartOverTimePeriod(viewBoard);
        InitializeOverTimePeriod(viewBoard, ReverseColor(viewBoard.si.TimedPlayer));
      end
    else
      begin
        ApplyTimeEventStartThinking(viewBoard)
      end
end;

// List of Korsheld coordinates for handicap stones

function AB2korlist(view : TViewBoard) : string;
var
  pv, x : string;
  i : integer;
begin
  pv := view.gt.Root.GetProp(prAB);
  Result := '';

  for i := 0 to Length(pv) div 4 - 1 do
    begin
      x := Copy(pv, i * 4 + 2, 2);
      Result := Result + sgf2kor(x, view.gb.BoardSize) + ' '
    end
end;

// -- Update of root properties ----------------------------------------------

// Input : Value contains possibly a position (SZ, HA, AB, AW, PL)
//                        possibly default properties for new game (GM, FF, AP)
// Update labels of player panel

procedure NewEngineGameInfo(view : TView);
var
  rt : TGameTree;
  sB, sW, sP : string;
  sE, sU : string;
begin
  // work on root
  rt := view.gt.Root;

  sB := rt.GetProp(prAB);
  sW := rt.GetProp(prAW);
  sP := rt.GetProp(prPL);
  rt.RemProp(prAB);
  rt.RemProp(prAW);
  rt.RemProp(prPL);

  if KomiValue <> 0
    then rt.PutProp(prKM, real2pv(KomiValue));

  if Settings.PlayingEngine.FAvailLevel
    then sE := Settings.PlayingEngine.FName + ':level ' + IntToStr(Settings.PlayingEngine.FLevel)
    else sE := Settings.PlayingEngine.FName;

  // note 1: to display correctly the user player string for non ascii languages,
  // the code page used for new games should be able to handle the translation
  // (utf8 for instance).
  // note 2: MainEncode/MainDecode use Settings.DefaultEncoding
  sU := MainEncode(U('User'));

  if view.si.EngineColor = Black
    then
      begin
        rt.AddProp(prPB, '[' + sE + ']');
        rt.AddProp(prPW, '[' + sU + ']');
      end
    else
      begin
        rt.AddProp(prPB, '[' + sU + ']');
        rt.AddProp(prPW, '[' + sE + ']');
      end;
  rt.AddProp(prDT, str2pv(FormatDateTime('yyyy"-"mm"-"dd', Date)));

  if sB <> '' then rt.AddProp(prAB, sB);
  if sW <> '' then rt.AddProp(prAW, sW);
  if sP <> '' then rt.AddProp(prPL, sP)
end;

// -- Processing of user move ------------------------------------------------

// -- Update of interface while waiting

procedure WaitEngine(view : TView; mode : boolean);
begin
  Actions.acStartPos.Enabled := not mode;
  Actions.acPrevMove.Enabled := not mode;
  Actions.acUndoMove.Enabled := not mode;

  if mode
    then
      begin
        view.si.ModeInterBak := view.si.ModeInter;
        view.si.ModeInter    := kimNOP
      end
    else view.si.ModeInter := view.si.ModeInterBak;

  if mode
    then Screen.Cursor := fmMain.WaitCursor
    else Screen.Cursor := crDefault
end;

// -- Detection of a pass move

function HasApassMove(gb : TGoban; gt : TGameTree) : boolean;
var
  player, i, j : integer;
begin
  gt.GetMove(player, i, j);
  Result := (player <> Empty) and (i = gb.BoardSize + 1)
                              and (j = gb.BoardSize + 1)
end;

// -- Detection of capture

function IsUndoAllowed(view : TView) : boolean;
begin
  if not Settings.PlayingEngine.FAvailUndo
    then Result := False
    else
      with view do
        if gt.PrevNode = nil
          then Result := False
          else
            case Settings.plUndo of
              euNo      : Result := False;
              euYes     : Result := True;
              euCapture : Result := gb.GameBoard.JustCaptured
              else        Result := False
            end
end;

// -- Processing of user move

procedure IntersectionGtp(view : TViewBoard; i, j : integer);
begin
  ProcessMoveByUser(view, i, j)
end;

procedure ProcessMoveByUser(view : TViewBoard; i, j : integer);
var
  status : integer;
  s, player : string;
begin
  // user has finished thinking and has just played
  ApplyTimeEventEndThinking(view);

  with view do
    if not gb.IsValid(i, j, si.Player, status)
      then WarnOnInvalidMove(status)
      else
        if i > gb.BoardSize  // user pass
          then
            if HasApassMove(gb, gt)
              then
                begin
                  DoNewMove(gb.BoardSize + 1, gb.BoardSize + 1);
                  EndGame(view)
                end
              else
                begin
                  CheckOverTime(view);
                  player := 'bw'[si.Player];
                  DoNewMove(i, j);
                  WaitEngine(view, True);
                  gtp.ClientPlay(ProcessMoveByUser2, player, 'pass')
                end
          else
            begin
              CheckOverTime(view);
              player := 'bw'[si.Player];
              DoNewMove(i, j);
              s := CoordString(i, j, gb.BoardSize, True);
              WaitEngine(view, True);
              gtp.ClientPlay(ProcessMoveByUser2, player, s);
            end
end;

procedure ProcessMoveByUser2(view : TObject);
begin
  if Settings.PlTimingMode = tmNo
    then ProcessMoveByUser3(view)
    else
      // avoid sending gtp time command if not required
      if (Settings.PlTimingMode = tmTimePerMove)
          and (Settings.PlayingEngine.IsGtpTimeCommandRequired = False)
        then ProcessMoveByUser3(view)
        else
          with view as TViewBoard do
            if si.Player = Black
              then gtp.TimeLeft(ProcessMoveByUser3, 'b', si.BlackTimeLeft div 1000, si.BlackStonesLeft)
              else gtp.TimeLeft(ProcessMoveByUser3, 'w', si.WhiteTimeLeft div 1000, si.WhiteStonesLeft)
end;

procedure ProcessMoveByUser3(view : TObject);
begin
  with view as TViewBoard do
    gtp.EnginePlay(ProcessMoveByEngine, 'bw'[si.Player]);

  // engine starts thinking
  ApplyTimeEventStartThinking(view as TViewBoard)
end;

// -- Processing of engine move

procedure ProcessMoveByEngine(view : TObject);
var
  i, j : integer;
begin
  // engine has finished to think and has played
  ApplyTimeEventEndThinking(view as TViewBoard);

  WaitEngine(view as TViewBoard, False);

  with view as TViewBoard do
    if UpperCase(gtp.OutputString) = 'PASS'
      then
        begin
          // engine has passed
          if Settings.WarnOnPass
            then
              UfmMsg.MessageDialog(msOk,
                                   imExclam,
                                   [iff(si.EngineColor = Black, U('Black has passed'),
                                                                U('White has passed'))],
                                   Settings.WarnOnPass);
                             
          if HasApassMove(gb, gt)
            then
              begin
                DoNewMove(gb.BoardSize + 1, gb.BoardSize + 1);
                EndGame(view as TViewBoard)
              end
            else
              begin
                DoNewMove(gb.BoardSize + 1, gb.BoardSize + 1);
                // user to play now
                ApplyTimeEventStartThinking(view as TViewBoard);
              end
        end
      else
    if UpperCase(gtp.OutputString) = 'RESIGN'
      then
        begin
          // engine has resigned
          if Settings.WarnOnResign
            then
              UfmMsg.MessageDialog(msOk,
                                   imExclam,
                                   [iff(si.EngineColor = Black, U('Black resigns'),
                                                                U('White resigns'))],
                                   Settings.WarnOnResign);

          ResignEG(view as TViewBoard)
        end
      else
        begin
          gtp.OutputString := Copy(gtp.OutputString, 1, 3);
          kor2ij(gtp.OutputString, gb.BoardSize, i, j);

          CheckOverTime(view as TViewBoard);
          DoNewMove(i, j, True);

          Actions.acUndoMove.Enabled := IsUndoAllowed(view as TViewBoard);

          // user to play now
          ApplyTimeEventStartThinking(view as TViewBoard);
        end
end;

// -- Processing of Undo -----------------------------------------------------

procedure GtpUndo(view : TViewBoard);
begin
  if IsUndoAllowed(view)
    then view.gtp.Undo(GtpUndo2)
end;

procedure GtpUndo2(view : TObject);
begin
  (view as TViewBoard).DoUndoMove;
  (view as TViewBoard).DoUndoMove;

  Actions.acUndoMove.Enabled := IsUndoAllowed(view as TViewBoard)
end;

// -- End of game process ----------------------------------------------------

// -- Update auto handicap

procedure UpdateMatch(iniFile : TTntMemIniFile;
                      engineColor, handi : integer; engineWin : boolean);
begin
  Settings.PlayingEngine.SaveMatch(iniFile, Settings.BoardSize,
                                   Settings.PlayingEngine.FLevel,
                                   engineColor, handi, engineWin)
end;

// -- Constructs a _R property interpreted in Apply

procedure EndGame(view : TView);
begin
  WaitEngine(view, True);
  if Settings.PlayingEngine.FAvailFinalScore
    then view.gtp.FinalScore(EndGame2)
    else EndGame2(view)
end;

procedure EndGame2(view : TObject);
begin
  if Settings.PlayingEngine.FAvailDetailedResults
    then (view as TViewBoard).gtp.FinalStatus(EndGame3)
    else EndGame3(view as TViewBoard)
end;

procedure EndGame3(view : TObject);
var
  viewBoard : TViewBoard;
  alive, dead, seki, sTB, sTW : string;
  sgfResult, detailedResult : string;
  tB, tW, pB, pW : integer;
  x : TGameTree;
begin
  viewBoard := view as TViewBoard;

  WaitEngine(viewBoard, False);
  sgfResult := viewBoard.gtp.GameResult;
  dead   := viewBoard.gtp.DeadList;
  StopEngine(viewBoard);

  with viewBoard do
    begin
      DoUndoMove;             // Delete last node

      //gt.RemProp(prB);      // Remove one more pass
      //gt.RemProp(prW);      // idem

      // copy the last node with the pass move, remove the pass move and use
      // the node to store the game result. just removing the pass move creates
      // a move numbering problem (report 20160502-GerhardSuttner)
      x := gt.Copy;
      x.RemProp(prB);
      x.RemProp(prW);
      DoUndoMove;
      gt.LinkNode(x);
      gt := gt.NextNode;

      if sgfResult <> ''
        then gt.Root.AddProp(prRE, str2pv(sgfResult));

      if not Settings.PlayingEngine.FAvailDetailedResults
        then gt.AddProp(pr_R, Format('[X:X:X:X:X:X:X:%s]', [sgfResult]))
        else
          begin
            alive := gtp2sgf(alive, gb.BoardSize);
            dead  := gtp2sgf(dead , gb.BoardSize);

            if Status.PlScoring = scJapanese
              then TerritoryCounting(gb, dead,
                                     si.FBlackPriso, si.FWhitePriso,
                                     sTB, sTW, sgfResult, detailedResult)
              else AreaCounting     (gb, dead,
                                     sTB, sTW, sgfResult, detailedResult);

            // add Drago result at root if available and no engine result
            if (gt.Root.GetProp(prRE) = '') and (sgfResult <> '')
              then gt.Root.AddProp(prRE, str2pv(sgfResult));

            // add territory points on last node
            if sTB <> ''
              then gt.PutProp(prTB, sTB);
            if sTW <> ''
              then gt.PutProp(prTW, sTW);

            gt.AddProp(pr_R, detailedResult)
          end;

      ReApplyNode;

      if Settings.plStartPos = spMatch then
        if ((sgfResult[1] = 'B') and (si.EngineColor = Black)) or
           ((sgfResult[1] = 'W') and (si.EngineColor = White))
          then UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, engineWin)
          else UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, not engineWin)
    end;
end;

// -- Handling of resignation command ----------------------------------------

procedure ResignEG(view : TViewBoard);
var
  s : string;
begin
  with view do
    begin
      if si.Player = White
        then s := 'B+R'
        else s := 'W+R';

      gt.Root.AddProp(prRE, str2pv(s));
      gt.AddProp(pr_R, Format('[0:0:0:0:0:0:0:%s]', [s]));
      ReApplyNode;

      if Settings.plStartPos = spMatch
        then
          if si.Player = si.EngineColor
            then UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, not engineWin)
            else UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, engineWin);

      StopEngine(view)
    end
end;

// -- Handling of timing -----------------------------------------------------

procedure GetTimeSettings(var mainTime, overTime, overStones : integer);
begin
  case Settings.PlTimingMode of
    tmNo :
      begin
        mainTime   := MaxInt;
        overTime   := MaxInt;
        overStones := MaxInt;
      end;
    tmTotalTime :
      begin
        mainTime   := Settings.PlTotalTime;
        overTime   := 0;
        overStones := 0;
      end;
    tmTimePerMove :
      begin
        mainTime   := 0;
        overTime   := Settings.PlTimePerMove;
        overStones := 1;
      end;
    tmOverTime :
      begin
        mainTime   := Settings.PlMainTime;
        overTime   := Settings.PlOverTime;
        overStones := Settings.PlOverStones;
      end
  end;
end;

procedure StartMainTimePeriod(view : TViewBoard);
var
  mainTime, overTime, overStones : integer;
begin
  GetTimeSettings(mainTime, overTime, overStones);

  with view do
    begin
      si.TimedPlayer     := si.Player;

      si.BlackTimeLeft   := mainTime * 1000;
      si.WhiteTimeLeft   := mainTime * 1000;

      si.BlackStonesLeft := -1;
      si.WhiteStonesLeft := -1;

      // display timing panel (dpTiming) by setting flag tested in UpdatePanes
      si.ForceShowTime := True;
      UpdatePanes(gt);

      case Settings.PlTimingMode of
        tmNo          : StartTiming(-1, -1);
        tmTotalTime   : StartTiming(mainTime, -1);
        tmTimePerMove : StartTiming(overTime, +1);
        tmOverTime    : StartTiming(mainTime, -1);
      end;

      //frViewBoard.pbBlackTime.Visible := True;
      //frViewBoard.pbWhiteTime.Visible := True;
      frViewBoard.tmEngine.Enabled := Settings.PlTimingMode <> tmNo;
      frViewBoard.ResizeAutoReplayBars
    end;
end;

// Initialize over time period

procedure InitializeOverTimePeriod(view : TViewBoard; player : integer);
var
  mainTime, overTime, overStones : integer;
begin
  GetTimeSettings(mainTime, overTime, overStones);
  with view do
    case player of
      Black :
        begin
          si.BlackTimeLeft   := overTime * 1000;
          si.BlackStonesLeft := overStones;
          StartTiming(Black, overTime, overStones);
        end;
      White :
        begin
          si.WhiteTimeLeft   := overTime * 1000;
          si.WhiteStonesLeft := overStones;
          StartTiming(White, overTime, overStones);
        end
    end
end;

procedure StartOverTimePeriod(view : TViewBoard);
begin
  InitializeOverTimePeriod(view, view.si.TimedPlayer);
  ApplyTimeEventStartThinking(view)
end;

procedure CheckOverTime(view : TViewBoard);
begin
  with view do
    case si.TimedPlayer of
      Black :
        if si.BlackStonesLeft > 0 then
          begin
            si.BlackStonesLeft := si.BlackStonesLeft - 1;
            if si.BlackStonesLeft = 0
              then StartOverTimePeriod(view)
              else UpdateTiming(Black, si.BlackTimeLeft div 1000, si.BlackStonesLeft)
          end;
      White :
        if si.WhiteStonesLeft > 0 then
          begin
            si.WhiteStonesLeft := si.WhiteStonesLeft - 1;
            if si.WhiteStonesLeft = 0
              then StartOverTimePeriod(view)
              else UpdateTiming(White, si.WhiteTimeLeft div 1000, si.WhiteStonesLeft)
          end
      end
end;

// start thinking event

procedure ApplyTimeEventStartThinking(view : TViewBoard);
begin
  with view do
    begin
      frViewBoard.tmEngine.Enabled := Settings.PlTimingMode <> tmNo;
      si.TimedPlayer := si.Player;
      case si.TimedPlayer of
        Black :
          begin
            si.BlackTimeStart := Now;
            si.BlackTimeLeftStart := si.BlackTimeLeft;
            frViewBoard.UpdateGameEngineTurn(Black)
          end;
        White :
          begin
            si.WhiteTimeStart := Now;
            si.WhiteTimeLeftStart := si.WhiteTimeLeft;
            frViewBoard.UpdateGameEngineTurn(White)
          end
      end
    end
end;

// continue thinking event

procedure UpdateTimeLeftNow(view : TViewBoard);
begin
  if Status.EngineOnlyTiming and (view.si.TimedPlayer <> Status.PlPlayer)
    then exit;

  with view do
    case si.TimedPlayer of
      Black :
        si.BlackTimeLeft := si.BlackTimeLeftStart - MilliSecondsBetween(Now, si.BlackTimeStart);
      White :
        si.WhiteTimeLeft := si.WhiteTimeLeftStart - MilliSecondsBetween(Now, si.WhiteTimeStart);
    end
end;

// end thinking event

procedure ApplyTimeEventEndThinking(view : TViewBoard);
begin
  UpdateTimeLeftNow(view);
  view.frViewBoard.tmEngine.Enabled := False
end;

// game timer event

procedure ApplyGameTimer(view : TViewBoard);
var
  tolerance : integer;
begin
  // add some delay to take into account time for messages and so on
  tolerance := Settings.PlTimeOutDelay;

  UpdateTimeLeftNow(view);

  with view do
    case si.TimedPlayer of
      Black :
        begin
          if si.BlackTimeLeft + tolerance <= 0
            then EndOfTime(view)
            else UpdateTiming(Black, si.BlackTimeLeft div 1000, si.BlackStonesLeft)
        end;
      White :
        begin
          if si.WhiteTimeLeft + tolerance <= 0
            then EndOfTime(view)
            else UpdateTiming(White, si.WhiteTimeLeft div 1000, si.WhiteStonesLeft)
        end
    end
end;

procedure EndOfTime(view : TViewBoard);
begin
  if (Settings.PlTimingMode = tmOverTime) and (Settings.PlOverTime = 0)
    then LoseOnTime(view)
    else
      case view.si.TimedPlayer of
        Black :
          if (Settings.PlTimingMode in [tmTimePerMove, tmOverTime]) and (view.si.BlackStonesLeft <= 0)
            then StartOverTimePeriod(view)
            else LoseOnTime(view);
        White :
          if (Settings.PlTimingMode in [tmTimePerMove, tmOverTime]) and (view.si.WhiteStonesLeft <= 0)
            then StartOverTimePeriod(view)
            else LoseOnTime(view)
      end
end;

procedure LoseOnTime(view : TViewBoard);
var
  s : string;
begin
  with view do
    begin
      case si.TimedPlayer of
        White : s := 'B+T';
        Black : s := 'W+T';
      else
          s := '' // ?
      end;

      gt.Root.AddProp(prRE, str2pv(s));
      gt.AddProp(pr_R, Format('[0:0:0:0:0:0:0:%s]', [s]));
      ReApplyNode;

      if Settings.plStartPos = spMatch
        then
          if si.Player = si.EngineColor
            then UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, not engineWin)
            else UpdateMatch(fmMain.IniFile, si.EngineColor, Settings.Handicap, engineWin);

      StopEngine(view)
    end;

  if Settings.WarnLoseOnTime
    then
      UfmMsg.MessageDialog(msOk,
                          imExclam,
                          [iff(view.si.TimedPlayer = Black, U('Black loses on time'),
                                                            U('White loses on time'))],
                          Settings.WarnLoseOnTime)
end;

procedure StopTiming(view : TViewBoard);
begin
  with view do
    begin
      si.ForceShowTime                := False;
      frViewBoard.pbBlackTime.Visible := False;
      frViewBoard.pbWhiteTime.Visible := False;
      frViewBoard.tmEngine.Enabled    := False
    end
end;

// -- Exit of engine mode ----------------------------------------------------

procedure ExitEngineMode(view : TViewBoard);
begin
  StopTiming(view);
  Screen.Cursor := crDefault;
  MainPanel_Hide(view.frViewBoard, view.frViewBoard.pnPlayers);
  EnableCommands(view, mdEdit);
  view.si.MainMode := muModification;
  SetTabIcon    (view, mdCrea);
  //view.TabSheet.Caption := 'Goban' + IntToStr(Status.LastEditTab);
  //TODO: clarify, only use for view.TabName
  (view.TabSheet as TTabSheetEx).Caption := view.TabName;
  view.si.ModeInter := kimGE
end;

procedure FreeEngine(view : TObject);
begin
  (view as TView).gtp.Free;
  (view as TView).gtp := nil
end;

procedure StopEngine(view : TViewBoard);
begin
  if view.gtp = nil
    then exit;

  ExitEngineMode(view);
  view.gtp.Stop(FreeEngine)
end;

procedure AbortEngineMode(view : TViewBoard);
begin
  ExitEngineMode(view);
  view.gtp.Free;
  view.gtp := nil
end;

procedure GtpError(view : TObject);
var
  s : WideString;
begin
  s := WideFormat('%s : %s %s : %s',
                  [U('Game aborted'),
                   U('Error'),
                   Settings.PlayingEngine.FName,
                  (view as TViewBoard).gtp.OutputString]);
  MessageDialog(msOk, imDrago, s);
  AbortEngineMode(view as TViewBoard);
  //!//raise Exception.Create(s)
end;

procedure GtpCrash(view : TObject);
var
  s : WideString;
begin
  AbortEngineMode(view as TViewBoard) ;
  s := U('Abnormal termination of game engine');
  MessageDialog(msOk, imDrago, s);
  //!//raise Exception.Create(s)
end;

// -- Gtp functions harness -------------------------------------------------

function GtpResult(gtp : TGtp) : string;
var
  i1, i2 : integer;
begin
  i1 := Pos(' ', gtp.OutputString + ' ');
  i2 := Pos(#10, gtp.OutputString);
  Result := LeftStr(gtp.OutputString, Min(i1, i2) - 1)
end;

procedure PrepareGtpFunction(engineSettings : TEngineSettings;
                             view : TView;
                             var gtp : TGtp);
var
  arguments : string;
  ok : boolean;
begin
  gtp := TGtp.Create(nil, Trace, nil, nil);
  gtp.DosCommand.OnTerminated := nil;
  arguments := EngineArguments(engineSettings);
  Trace(arguments);
  gtp.Start(engineSettings.FPath, arguments, ok);

  if not ok
    then FreeAndNil(gtp)
    else
      begin
        gtp.Context := gtp;
        Screen.Cursor := fmMain.WaitCursor
      end
end;

procedure TerminateGtpFunction(gtp : TGtp);
begin
  gtp.Free;
  Screen.Cursor := crDefault
end;

procedure StopGtp(x : TObject);
begin
  (x as TGtp).Stop
end;

procedure WaitWhileGtpActive(gtp : TGtp);
begin
  while gtp.Active do
    begin
      Application.ProcessMessages;
      Sleep(10)
    end
end;

// -- Engine information -----------------------------------------------------

(*
Engine command line is actually tested with the following function when
setting path and additional arguments. Two cases of failure are handled.
- First one is the case when engine starts and waits because it is not in
GTP mode (eg gnugo without --mode gtp argument). This is handled with a
time out.
- Second one is the case when engine stops immediately because of unknown
argument (eg gnugo). This is handled by testing the returned name with the
hope no engine will return an empty name.
*)

procedure EngineInformation(engineSettings : TEngineSettings;
                            var detected : boolean;
                            var ident : string);
var
  gtp : TGtp;
begin
  PrepareGtpFunction(engineSettings, nil, gtp);
  detected := Assigned(gtp);
  ident := '';
  if Assigned(gtp) then
    try
      gtp.DosCommand.MaxTimeAfterBeginning := 10; // 10s timeout
      gtp.Info(StopGtp);
      WaitWhileGtpActive(gtp);

      if Length(gtp.FInfoVersion) > 10
        then ident := gtp.FInfoName
        else ident := gtp.FInfoName + ' ' + gtp.FInfoVersion;

      engineSettings.SetFeaturesFromString(gtp.FInfoCommands)
    finally
      TerminateGtpFunction(gtp)
    end
end;

// -- Analysis functions -----------------------------------------------------

// Score estimate

procedure ScoreEstimate(view : TView; aOnReturn : TOnReturnStr);
var
  gtp : TGtp;
begin
  PrepareGtpFunction(Settings.AnalysisEngine, view, gtp);
  if Assigned(gtp) then
    try
      gtp.ScoreEstimate(StopGtp, view.gt);
      WaitWhileGtpActive(gtp);
      aOnReturn(nil, GtpResult(gtp))
    finally
      TerminateGtpFunction(gtp)
    end
end;

// Move suggestion

procedure SuggestMove(view : TView; aOnReturn : TOnReturnStr);
var
  gtp : TGtp;
begin
  PrepareGtpFunction(Settings.AnalysisEngine, view, gtp);
  if Assigned(gtp) then
    try
      gtp.SuggestMove(StopGtp, 'bw'[view.si.Player], view.gt);
      WaitWhileGtpActive(gtp);
      aOnReturn(view, GtpResult(gtp))
    finally
      TerminateGtpFunction(gtp)
    end
end;

// Influence regions

procedure InfluenceRegions(view : TView; aOnReturn : TOnReturnStr);
var
  gtp : TGtp;
begin
  PrepareGtpFunction(Settings.AnalysisEngine, view, gtp);
  if Assigned(gtp) then
    try
      gtp.InfluenceRegions(StopGtp, 'bw'[view.si.Player], view.gt);
      WaitWhileGtpActive(gtp);
      aOnReturn(view, gtp.OutputString)
    finally
      TerminateGtpFunction(gtp)
    end
end;

// Group status

procedure GroupStatus(view : TView; aOnReturn : TOnReturnStr; const coord : string);
var
  gtp : TGtp;
begin
  PrepareGtpFunction(Settings.AnalysisEngine, view, gtp);
  if Assigned(gtp) then
    try
      gtp.GroupStatus(StopGtp, coord, view.gt);
      WaitWhileGtpActive(gtp);
      aOnReturn(view, gtp.OutputString)
    finally
      TerminateGtpFunction(gtp)
    end
end;

// -- Other commands ---------------------------------------------------------

// -- Pass

procedure DoPass(view : TViewBoard);
begin
  ProcessMoveByUser(view, view.gb.BoardSize + 1, view.gb.BoardSize + 1)
end;

// -- Resignation

procedure DoResign(view : TViewBoard);
begin
  if MessageDialog(msOkCancel,
                   imQuestion,
                   [U('Do you really want to resign?')]) = mrCancel
    then exit;

  ResignEG(view)
end;

// -- Tracing ----------------------------------------------------------------

procedure Trace(const s : string);
var
  s2 : string;
begin
  s2 := TrimRight(s);
  s2 := StringReplace(s2, #10 , ' ', [rfReplaceAll]);
  if Assigned(fmGtp)
    then fmGtp.Memo.Lines.Add(s2)
    else StatusMain.GtpMessages.Add(s2)
end;

procedure CreateHideGtpWindow;
begin
  if not Assigned(fmGtp)
    then TfmGtp.Execute(False)
end;

procedure ShowGtpWindow;
begin
  if not Assigned(fmGtp)
    then TfmGtp.Execute(True)
    else fmGtp.Show
end;

// -- Misc

function IsOneEngineRunning : boolean;
var
  i : integer;
begin
  // look at every views to detect running engine
  Result := True;

  for i := 0 to fmMain.PageCount - 1 do
    with fmMain.Pages[i].TabView do
      if si.EnableMode = mdPlay
        then exit;

  Result := False
end;

// ---------------------------------------------------------------------------

end.
