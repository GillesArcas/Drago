// ---------------------------------------------------------------------------
// -- Drago -- Auto replay mode --------------------------- UAutoReplay.pas --
// ---------------------------------------------------------------------------

unit UAutoReplay;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, DateUtils, StdCtrls, ComCtrls, Buttons, Types,
  UViewBoard;

procedure AutoReplayStart     (view : TViewBoard);
procedure AutoReplayStop      (view : TViewBoard);
procedure ResizeAutoReplayBars(view : TViewBoard);
procedure StartPosAutoReplay  (view : TViewBoard);
procedure LastMoveAutoReplay  (view : TViewBoard);
procedure NextMoveAutoReplay  (view : TViewBoard);
procedure PrevMoveAutoReplay  (view : TViewBoard);
procedure AutoReplaySetTimer  (view : TViewBoard);
procedure DoAutoReplayTimer   (view : TViewBoard);

procedure AutoReplaySetControls   (trackbar : TTrackBar;
                                   btLess, btMore : TSpeedButton;
                                   lbMin, lbMax, lbDelay : TLabel);
procedure AutoReplayUpdateControls(trackbar : TTrackBar;
                                   btLess, btMore : TSpeedButton;
                                   lbMin, lbMax, lbDelay : TLabel);
procedure AutoReplayLessClick     (trackbar : TTrackBar;
                                   btLess, btMore : TSpeedButton;
                                   lbMin, lbMax : TLabel);
procedure AutoReplayMoreClick     (trackbar : TTrackBar;
                                   btLess, btMore : TSpeedButton;
                                   lbMin, lbMax : TLabel);

// ---------------------------------------------------------------------------

implementation

uses
  Define, DefineUi, Std, Ux2y, Properties, UGameTree, Main, UMainUtil, UActions,
  UStatus, ViewUtils, UfmOptions;

// -- Start and stop auto replay ---------------------------------------------

procedure AutoReplayStart(view : TViewBoard);
begin
  with view do
    begin
      if (gt.NextNode = nil) and not (mtEndVar in st.MoveTargets)
        then
          begin
            Actions.acAutoReplay.Checked := False;
            exit
          end;

      frViewBoard.tmAutoReplay.Enabled := True;
      EnableCommands(view, mdAuto);
      si.ModeInter := kimAR;
      ResizeAutoReplayBars(view);

      frViewBoard.pbBlackTime.Visible := st.AutoUseTimeProp;
      frViewBoard.pbWhiteTime.Visible := st.AutoUseTimeProp;

      // set starting point for move to target
      si.EndingMove := si.MoveNumber + st.TargetStep;
      view.DoNextMove;
      //DoNextTarget(view);
      AutoReplaySetTimer(view)
    end
end;

procedure AutoReplayStop(view : TViewBoard);
begin
  with view do
    begin
      frViewBoard.tmAutoReplay.Enabled := False;
      EnableCommands(view, mdEdit);
      si.ModeInter := kimGE;
      frViewBoard.pbBlackTime.Visible := False;
      frViewBoard.pbWhiteTime.Visible := False
    end
end;

// -- Resizing of progress bars ----------------------------------------------

procedure ResizeAutoReplayBars(view : TViewBoard);
begin
  view.frViewBoard.ResizeAutoReplayBars
end;

// -- Handling of navigation commands in autoreplay mode ---------------------

procedure StartPosAutoReplay(view : TViewBoard);
begin
  view.DoStartPosInherited;
  view.AutoReplayNext := Now;
  AutoReplaySetTimer(view)
end;

procedure LastMoveAutoReplay(view : TViewBoard);
begin
  view.DoEndPosInherited;
  view.AutoReplayNext := Now;
  AutoReplaySetTimer(view)
end;

procedure NextMoveAutoReplay(view : TViewBoard);
begin
  view.DoNextMoveInherited;
  view.AutoReplayNext := Now;
  AutoReplaySetTimer(view)
end;

procedure PrevMoveAutoReplay(view : TViewBoard);
begin
  view.DoPrevMoveInherited;
  view.AutoReplayNext := Now;
  AutoReplaySetTimer(view)
end;

// == Auto replay timer event ================================================

// When a move has been played, the time to wait before playing next one is
// the difference between time left for previous move and time left for next
// move. The following function handles the various exception cases as well.

function TimeToWait(view : TViewBoard; pr : TPropId) : double;
var
  prev, next : TGameTree;
  v : string;
  t1, t2 : double;
begin
  Result := Settings.AutoDelay; // milliseconds

  prev := view.gt.PrevNode;
  next := view.gt.NextNode;

  if prev = nil
    // should not be, return default
    then exit;

  if next = nil
    // should not be, return default
    then exit;

  if not Settings.AutoUseTimeProp
    // don't use time prop
    then exit;

  // extract t1
  if prev.PrevNode = nil
    // current move if first move, extract t1 as time setting
    then v := prev.GetProp(prTM)
    // extract t1 as time left for previous move (pn = BL or WL)
    else v := prev.GetProp(pr);

  if (v = '') or not TryStrToFloat(pv2str(v), t1)
    // no t1, return default
    then exit;

  // extract t2 as time left for next move (pn = BL or WL)
  v := next.GetProp(pr);

  if (v = '') or not TryStrToFloat(pv2str(v), t2)
    // no t2, return default
    then exit;

  if t2 > t1
    // some problem in data, return default
    then exit
    // time to wait found, result milliseconds
    else Result := (t1 - t2) * 1000
end;

procedure AutoReplaySetTimer(view : TViewBoard);
var
  time2wait : double;
begin
  with view do
    begin
    // extract move and time properties from node
    if view.gt.GetProp(prB) <> ''
      // handle Black move
      then time2wait := TimeToWait(view, prWL)
      else
        if view.gt.GetProp(prW) <> ''
          // handle White move
          then time2wait := TimeToWait(view, prBL)
          else
            // no moves at node, go to next and continue
            begin
              view.DoNextMove;
              //DoNextTarget(view);
              exit
            end;

    if view.gt.GetProp(prW) <> ''
      then AutoReplayColor := Black
      else AutoReplayColor := White;

    AutoReplayNext := IncMilliSecond(Now, Round(time2wait));
    frViewBoard.pbBlackTime.Position := 0;
    frViewBoard.pbWhiteTime.Position := 0;
    frViewBoard.pbBlackTime.Max := MilliSecondsBetween(AutoReplayNext, Now);
    frViewBoard.pbWhiteTime.Max := MilliSecondsBetween(AutoReplayNext, Now)
  end
end;

// -- TViewBoard timer event (every 50ms)

procedure DoAutoReplayTimer(view : TViewBoard);
var
  t1, t2 : double;
begin
  // exit when not the current view
  if view <> fmMain.ActiveView
    then exit;

  // exit if option dialog opened
  if UfmOptions.IsOpen
    then exit;

  with view do
    begin
      // test if next move available
      if (gt.NextNode = nil) or
         (Settings.AutoStopAtTarget and IsMoveTarget(view)) then
        begin
          Actions.acAutoReplay.Checked := False;
          AutoReplayStop(view);
          exit
        end;

      frViewBoard.pbBlackTime.Visible := Settings.AutoUseTimeProp;
      frViewBoard.pbWhiteTime.Visible := Settings.AutoUseTimeProp;

      if AutoReplayColor = Black
        then frViewBoard.pbBlackTime.Position := frViewBoard.pbBlackTime.Max - MilliSecondsBetween(AutoReplayNext, Now)
        else frViewBoard.pbWhiteTime.Position := frViewBoard.pbWhiteTime.Max - MilliSecondsBetween(AutoReplayNext, Now);

      // exit when waiting between moves
      t1 := Now;
      t2 := AutoReplayNext;
      if CompareDateTime(t1, t2) = LessThanValue
        then exit;

      // time to go to next move
      view.DoNextMove;
      //DoNextTarget(view);

      AutoReplaySetTimer(view)
    end
end;

// == Handling of events in option dialog ====================================

function AutoReplayDelayCaption(position, interval : integer) : string;
begin
  if interval = 0
    then
      // 0-1
      if position = 0
        then Result := '0s'
        else
          if position = 100
            then Result := '1s'
            else Result := Format('%dms', [position * 10])
    else
      // 1-10
      if position = 100
        then Result := '1s'
        else
          if Position = 1000
            then Result := '10s'
            else Result := Format('%0.1fs', [position / 100])
end;

procedure DisplayDelayCaption(trackbar : TTrackBar; lbDelay : TLabel);
begin
  lbDelay.Caption := AutoReplayDelayCaption(trackbar.Position, trackbar.Tag);
  lbDelay.Left    := trackbar.Left + trackbar.Width div 2
                     - lbDelay.Canvas.TextWidth(lbDelay.Caption) div 2
end;

procedure AutoReplaySetControls(trackbar : TTrackBar;
                                btLess, btMore : TSpeedButton;
                                lbMin, lbMax, lbDelay : TLabel);
begin
  if Settings.AutoDelay <= 1000
    then
      begin
        // use trackbar.Tag to remind delay interval (0-1 or 1-10)
        trackbar.Tag := 0;

        lbMin.Caption := '0s';
        lbMax.Caption := '1s';

        trackbar.Min := 0;
        trackbar.Max := 100;
        trackbar.Frequency := 10
      end
    else
      begin
        trackbar.Tag := 1;

        lbMin.Caption := '1s';
        lbMax.Caption := '10s';

        trackbar.Min := 100;
        trackbar.Max := 1000;
        trackbar.Frequency := 100
      end;

  btLess.Visible := False;
  btMore.Visible := False;
  trackbar.Position := Settings.AutoDelay div 10;

  DisplayDelayCaption(trackbar, lbDelay)
end;

procedure AutoReplayLessClick(trackbar : TTrackBar;
                              btLess, btMore : TSpeedButton;
                              lbMin, lbMax : TLabel);
begin
  trackbar.Tag := 0;

  btLess.Visible := False;
  btMore.Visible := True;

  lbMin.Caption := '0s';
  lbMax.Caption := '1s';

  trackbar.Min := 0;
  trackbar.Max := 100;
  trackbar.Position := 100;
  trackbar.Frequency := 10;
end;

procedure AutoReplayMoreClick(trackbar : TTrackBar;
                              btLess, btMore : TSpeedButton;
                              lbMin, lbMax : TLabel);
begin
  trackbar.Tag := 1;

  btLess.Visible := True;
  btMore.Visible := False;

  lbMin.Caption := '1s';
  lbMax.Caption := '10s';

  trackbar.Min := 100;
  trackbar.Max := 1000;
  trackbar.Position := 100;
  trackbar.Frequency := 100;
end;

procedure AutoReplayUpdateControls(trackbar : TTrackBar;
                                   btLess, btMore : TSpeedButton;
                                   lbMin, lbMax, lbDelay : TLabel);
begin
  with trackbar do
    begin
      btMore.Visible := (Tag = 0) and (Position = Max);
      btLess.Visible := (Tag = 1) and (Position = Min);

      DisplayDelayCaption(trackbar, lbDelay)
    end
end;

// ---------------------------------------------------------------------------

end.
