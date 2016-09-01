// ---------------------------------------------------------------------------
// -- Drago -- Helpers for problem and replay modes ------ UProblemUtil.pas --
// ---------------------------------------------------------------------------

unit UProblemUtil;

// ---------------------------------------------------------------------------

interface

uses
  Graphics, Classes, Dialogs, SysUtils,
  UViewBoard, UGoban, UGameColl, UGameTree, UInstStatus;

function  IsAProblemFile  (cl : TGameColl) : boolean;
function  IsAGameFile     (cl : TGameColl) : boolean;
procedure CollectionStatistics(cl : TGameColl;
                               var nProblems, nVisited, nTrials, nSuccess : integer);
procedure ProblemStatistics(gtIndex : integer;
                               var nTrials, nSuccess : integer);
procedure ResetCollectionStatistics(cl : TGameColl);
procedure SelectProblems  (cl : TGameColl; si : TInstStatus);
function  DetectMarkupMode(gt : TGameTree; si : TInstStatus) : integer;
function  DetectQuadrant  (x : TGameTree) : integer; overload;
procedure PbSelectNextMove(var gt : TGameTree; si : TInstStatus);
procedure PbHint          (view : TViewBoard);
procedure PbToggleFreeMode(view : TViewBoard);
function  IsARightMove    (si : TInstStatus; x : TGameTree) : Boolean;
function  IsARightSol     (gb : TGoban; gt : TGameTree; si : TInstStatus) : Boolean;
procedure SelectGame      (cl : TGameColl; si : TInstStatus; var n : integer);
function  GtResultToString(gt : TGameTree) : WideString;

// ---------------------------------------------------------------------------

implementation

uses
  Contnrs,
  Std, Define, DefineUi, Properties, Translate, Ux2y, Main, UMemo, Ustatus, 
  UGmisc, BoardUtils, UProblems, UActions;

// -- Verification of file content -------------------------------------------

// put some limitation
const
  MaxNumberOfAnalizedGames = 500;

function IsAProblem(gt : TGameTree) : boolean;
begin
  Result := True;

  while (gt <> nil) and (not gt.HasMove) do
    if gt.HasProp(prAW)
      then exit
      else gt := gt.NextNode;

  Result := False
end;

function IsAProblemFile(cl : TGameColl) : boolean;
var
  analyzed, n, i : integer;
begin
  analyzed := Min(cl.Count, MaxNumberOfAnalizedGames);
  n := 0;
  for i := 1 to analyzed do
    if IsAProblem(cl[i])
      then inc(n);
  Result := ((n * 100) / analyzed) > 90
end;

function IsAGameFile(cl : TGameColl) : boolean;
var
  analyzed, n, i : integer;
begin
  analyzed := Min(cl.Count, MaxNumberOfAnalizedGames);
  n := 0;
  for i := 1 to analyzed do
    if not IsAProblem(cl[i])
      then inc(n);
  Result := ((n * 100) / analyzed) > 90
end;

// -- Statistics on problem collection ---------------------------------------

procedure CollectionStatistics(cl : TGameColl;
                               var nProblems, nVisited, nTrials, nSuccess : integer);
var
  i, nOcc, nSucc : integer;
  s : string;
begin
  nProblems := cl.Count;
  nTrials := 0;
  nSuccess := 0;
  for i := 1 to nProblems do
    begin
      s := GetPbNth(i);
      nOcc := NthInt(s, 1);
      nSucc := NthInt(s, 2);
      if nOcc > 0
        then inc(nVisited);
      inc(nTrials, nOcc);
      inc(nSuccess, nSucc)
    end
end;

procedure ProblemStatistics(gtIndex : integer;
                            var nTrials, nSuccess : integer);
var
  s : string;
begin
  s := GetPbNth(gtIndex);
  nTrials := NthInt(s, 1);
  nSuccess := NthInt(s, 2)
end;

procedure ResetCollectionStatistics(cl : TGameColl);
var
  i : integer;
begin
  for i := 1 to cl.Count do
    SetPbNth(i, '0 0');
    
  pbProfile.UpdateFile
end;

// -- Selection of problems --------------------------------------------------

// -- Intermediate working data

var
  TabProblems : array of integer;

// -- Selection of problems in sequential mode from current

procedure SelectSequential(start, num, nTree : integer);
var
  i, j : integer;
begin
  j := start;
  for i := 1 to num do
    begin
      if j > nTree
        then j := 1;
      tabProblems[i] := j;
      inc(j)
    end
end;

procedure SelectSeqFromCurrent(cl : TGameColl; si : TInstStatus);
begin
  SelectSequential(si.IndexTree, si.pbNumber, cl.Count)
end;

// -- Selection of problems in sequential mode from memorized

procedure SelectSeq(cl : TGameColl; si : TInstStatus);
begin
  SelectSequential(PbGetLast + 1, si.pbNumber, cl.Count)
end;

// -- Selection of problems in random mode

procedure SelectAlea(cl : TGameColl; si : TInstStatus);
const
  default = 2;
  choosen = 1;
  possible = 0;
var
  n, i, mini, val, nChoosen, i1, i2, tmp : integer;
begin
  n := min(si.pbNumber, cl.Count);
  if n < si.pbNumber
    then ; // no warning until now
  si.pbNumber := n;

  // find the lowest number of occurrences
  mini := MaxInt;
  for i := 1 to cl.Count do
    begin
      tabProblems[i] := default;
      if PbNthOcc(i) < mini
        then mini := PbNthOcc(i)
    end;

  // select the ones less seen and mandatory, then nominate the following
  n := 0;
  nChoosen := 0;
  val := mini;
  while n < si.pbNumber do
    begin
      for i := 1 to cl.Count do
        if PbNthOcc(i) = val then
          begin
            inc(n);
            tabProblems[i] := possible
          end;
      if n < si.pbNumber then
        for i := 1 to cl.Count do
          if tabProblems[i] = possible then
            begin
              inc(nChoosen);
              tabProblems[i] := choosen
            end;
      inc(val)
    end;

  // select at random the remaining ones
  for i := 1 to si.pbNumber - nChoosen do
    begin
      repeat
        n := random(cl.Count) + 1
      until tabProblems[n] = possible;
      tabProblems[n] := choosen
    end;

  // make list of problems to solve
  n := 1;
  for i := 1 to cl.Count do
    if tabProblems[i] = choosen then
      begin
        tabProblems[n] := i;
        inc(n)
      end;

  // randomize the list
  for i := 1 to si.pbNumber do
    begin
      i1 := 1 + random(si.pbNumber);
      i2 := 1 + random(si.pbNumber);
      tmp := tabProblems[i1];
      tabProblems[i1] := tabProblems[i2];
      tabProblems[i2] := tmp
    end
end;

// -- Selection using failure ratio

// Selection temporary data

type
  TProblem = class
    index : integer;
    frequency : integer;
    success : double;
    rand : integer;
    constructor Create(i : integer);
  end;

constructor TProblem.Create(i : integer);
var
  s : string;
  nOcc, nSucc : integer;
begin
  s := GetPbNth(i);
  nOcc := NthInt(s, 1);
  nSucc := NthInt(s, 2);
  index := i;
  frequency := nOcc;
  // setting 100 as success ratio when the problem has not been visited
  // enables to separate problems never seen from 0% success problems
  if nOcc = 0
    then success := 100
    else success := nSucc / nOcc;
  rand := Random(1000)
end;

// Sorting functions

function SortOnFrequency(p1, p2 : pointer): integer;
var
  pb1, pb2 : TProblem;
begin
  pb1 := TProblem(p1);
  pb2 := TProblem(p2);

  if pb1.frequency < pb2.frequency
    then Result := -1
  else if pb1.frequency > pb2.frequency
    then Result := +1
  else if pb1.success < pb2.success
    then Result := -1
  else if pb1.success > pb2.success
    then Result := +1
  else if pb1.rand < pb2.rand
    then Result := -1
  else if pb1.rand > pb2.rand
    then Result := +1
    else Result := 0
end;

function SortOnSuccess(p1, p2 : pointer): integer;
var
  pb1, pb2 : TProblem;
begin
  pb1 := TProblem(p1);
  pb2 := TProblem(p2);

  if pb1.success < pb2.success
    then Result := -1
  else if pb1.success > pb2.success
    then Result := +1
  else if pb1.frequency < pb2.frequency
    then Result := -1
  else if pb1.frequency > pb2.frequency
    then Result := +1
  else if pb1.rand < pb2.rand
    then Result := -1
  else if pb1.rand > pb2.rand
    then Result := +1
    else Result := 0
end;

// Selection process

procedure SelectOnFrequencyAndSuccess(cl : TGameColl; si : TInstStatus);
var
  FrequencyList : TObjectList;
  SuccessList : TObjectList;
  ProblemList : TObjectList;
  nProblems, i, nFail, i1, i2 : integer;
begin
  FrequencyList := TObjectList.Create;
  SuccessList := TObjectList.Create;
  ProblemList := TObjectList.Create;

  // the frequency list owns the items
  FrequencyList.OwnsObjects := True;
  SuccessList.OwnsObjects := False;
  ProblemList.OwnsObjects := False;

  // input has already ensured a valid range
  nProblems := si.PbNumber;

  // construct and sort frequency and success lists
  for i := 1 to cl.Count do
    FrequencyList.Add(TProblem.Create(i));
  SuccessList.Assign(FrequencyList);
  // frequency list is sorted in increasing frequency order
  FrequencyList.Sort(SortOnFrequency);
  // success list is sorted in increasing success order
  SuccessList.Sort(SortOnSuccess);

  // calculate number of failed problems to try solving
  if Settings.PbUseFailureRatio
    then nFail := Round(nProblems * Settings.PbFailureRatio / 100.0)
    else nFail := 0;

  // add most often failed to problem list
  for i := 0 to nFail - 1 do
    if (SuccessList[i] as TProblem).success >= 1.0
      then break
      else ProblemList.Add(SuccessList[i]);

  // complete list of problem with less often visited
  i := 0;
  while ProblemList.Count < nProblems do
    begin
      while ProblemList.IndexOf(FrequencyList[i]) >= 0 do
        inc(i);

      ProblemList.Add(FrequencyList[i]);
      inc(i)
    end;

  {.$define Trace}
  {$ifdef Trace}
  Trace('Problem selection');
  for i := 0 to si.PbNumber - 1 do
    with (ProblemList[i] as TProblem) do
      if frequency = 0
        then Trace(Format('%d %d -', [index, frequency]))
        else Trace(Format('%d %d %2.2f', [index, frequency, success * 100]));
  Trace('SuccessList');
  for i := 0 to SuccessList.Count - 1 do
    with (SuccessList[i] as TProblem) do
      if frequency = 0
        then Trace(Format('%d %d -', [index, frequency]))
        else Trace(Format('%d %d %2.2f', [index, frequency, success * 100]));
  {$endif}

  // randomize the list
  for i := 0 to nProblems - 1 do
    begin
      i1 := Random(nProblems);
      i2 := Random(nProblems);
      ProblemList.Exchange(i1, i2)
    end;

  // fill output
  for i := 0 to nProblems - 1 do
    TabProblems[i + 1] := (ProblemList[i] as TProblem).index;

  // release working data
  FrequencyList.Free;
  SuccessList.Free;
  ProblemList.Free
end;

// -- Selection of the list of problems to be solved

procedure SelectProblems(cl : TGameColl; si : TInstStatus);
var
  i : integer;
begin
  SetLength(TabProblems, cl.Count + 1);

  case si.pbMode of
    0 : SelectSeqFromCurrent(cl, si);
    1 : SelectSeq(cl, si);
    2 : SelectOnFrequencyAndSuccess(cl, si)
  end;

  SetLength(si.ListProblems, si.pbNumber + 1);
  for i := 1 to si.pbNumber do
    si.ListProblems[i] := tabProblems[i];

  SetLength(TabProblems, 0)
end;

// -- Detection of the marking mode ------------------------------------------

procedure DetectMarkupMode2(gt : TGameTree; var nTR, nWV, nRIGHT : integer);
begin
  if gt <> nil then
    begin
      if (gt.NextNode = nil) and (Pos('RIGHT', {UpperCase}(gt.GetProp(prC))) > 0)
        then inc(nRIGHT);
      if gt.HasProp(prTR)
        then inc(nTR);
      if gt.HasProp(prWV)
        then inc(nWV);
      DetectMarkupMode2(gt.NextNode, nTR, nWV, nRIGHT);
      gt := gt.NextVar;
      while gt <> nil do
        begin
          DetectMarkupMode2(gt, nTR, nWV, nRIGHT);
          gt := gt.NextVar
        end
    end
end;

function DetectMarkupMode(gt : TGameTree; si : TInstStatus) : integer;
var
  nTR, nWV, nRIGHT : integer;
begin
  if si.pbMarkup <> 3 then
    begin
      Result := si.pbMarkup;
      exit
    end;

  nTR    := 0;
  nWV    := 0;
  nRIGHT := 0;
  DetectMarkupMode2(gt, nTR, nWV, nRIGHT);
  if nWV > 0
    then Result := 0          // Uligo
    else
      if nRIGHT > 0
        then Result := 1      // GoPb
        else
          if nTR > 0
            then Result := 0  // Uligo
            else Result := 2  // Default
end;

// -- Detection of the quadrant ----------------------------------------------

procedure SetExtrema(i, j : integer; var imin, jmin, imax, jmax : integer);
begin
  if i < imin then imin := i;
  if i > imax then imax := i;
  if j < jmin then jmin := j;
  if j > jmax then jmax := j
end;

procedure DetectMaxima(gt : TGameTree; var imin, jmin, imax, jmax : integer);
var
  player, i, j, k : integer;
  pv, x : string;
begin
  if gt <> nil then
    begin
      gt.GetMove(player, i, j);
      if player <> Empty
        then SetExtrema(i, j, imin, jmin, imax, jmax);

      pv := '';
      pv := pv + gt.GetProp(prAB);
      pv := pv + gt.GetProp(prAW);

      k := 1;
      x := nthpv(pv, k);

      while x <> '' do
        begin
          pv2ij(x, i, j);
          SetExtrema(i, j, imin, jmin, imax, jmax);
          inc(k);
          x := nthpv(pv, k)
        end;
      DetectMaxima(gt.NextNode, imin, jmin, imax, jmax);
      DetectMaxima(gt.NextVar , imin, jmin, imax, jmax)
    end
end;

function DetectQuadrant(x : TGameTree) : integer;
var
  pv : string;
  size, imin, jmin, imax, jmax : integer;
begin
  x := x.Root;
  pv := x.GetProp(prSZ);
  if pv = ''
    then size := 19
    else size := pv2int(pv);
  if size <> 19 then
    begin
      Result := -1;
      exit
    end;
  imin := 19;
  imax :=  1;
  jmin := 19;
  jmax :=  1;
  DetectMaxima(x, imin, jmin, imax, jmax);

  if (imax <= 10) and (jmax <= 10)
  then Result := 0 else
  if (imax <= 10) and (jmin >= 10)
  then Result := 1 else
  if (imin >= 10) and (jmin >= 10)
  then Result := 2 else
  if (imin >= 10) and (jmax <= 10)
  then Result := 3
  else Result := -1
end;

// -- Selection of opponent next move ----------------------------------------

function NumberOfCorrectFollowUp(x : TGameTree; si : TInstStatus) : integer;
var
  n : integer;
begin
  n := 0;
  x := x.NextNode;
  while x <> nil do
    begin
      if IsARightMove(si, x)
        then inc(n);
      x := x.NextVar
    end;
  NumberOfCorrectFollowUp := n
end;

procedure PbSelectNextMove(var gt : TGameTree; si : TInstStatus);
var
  Winning, Unsettled : TList;
  n : integer;
begin
  gt := gt.NextNode;
  Winning   := TList.Create;
  Unsettled := TList.Create;

  while gt <> nil do
    begin
      n := NumberOfCorrectFollowUp(gt, si);
      if n = 0
        then Winning.Add(gt)
        else Unsettled.Add(gt);
      gt := gt.NextVar
    end;
  //fmMain.mmComment.Lines.Add('Winning ' + IntToStr(Winning.Count));
  //fmMain.mmComment.Lines.Add('Unsettled ' + IntToStr(Unsettled.Count));
  if Winning.Count > 0
    then gt := Winning[random(Winning.Count)]
    else
      if Unsettled.Count > 0
        then gt := Unsettled[random(Unsettled.Count)]
        else ShowMessage('No follow up moves'); // ??
  Winning.Free;
  Unsettled.Free
end;

// -- Handling of hints ------------------------------------------------------

// -- Search for correct follow up moves

function IsARightMoveMainLine(x : TGameTree) : Boolean;
begin
(*
  if x.PrevNode = StartNode(x)
    then Result := True
    else
      if (x.PrevNode = nil) or (x.PrevNode.PrevNode = nil)
        then
          Result := True
        else
          Result := (x.PrevVar = nil) and
                    IsARightMoveMainLine(x.PrevNode.PrevNode)
*)
  Result := x.IsOnMainBranch
end;

function IsARightMoveUligo(x : TGameTree) : boolean;
var
  y : TGameTree;
begin
  y := x;
  while (y <> nil) and not (y.HasProp(prTR) or y.HasProp(prWV))
    do y := y.PrevNode;
  if y <> nil
    then Result := False
    else
      if (x.NextNode = nil) or (x.NextNode.NextNode = nil)
        then Result := True
        else
          begin
            x := x.NextNode.NextNode;
            Result := False;
            while not Result and (x <> nil) do
              begin
                Result := IsARightMoveUligo(x);
                x := x.NextVar
              end
          end
end;

function IsARightMoveGoPb_Bug(x : TGameTree) : boolean;
var
  pv : string;
  r  : boolean;
begin
  if x.NextNode = nil
    then
      begin
        pv := x.GetProp(prC);
        Result := (pv <> '') and (Pos('RIGHT', pv) > 0)
      end
    else
      begin
        x := x.NextNode;
        {}
        r := False;
        while (not r) and (x <> nil) do
          begin
            r := IsARightMoveGoPb_Bug(x);
            x := x.NextVar
          end;
        Result := r
      end
end;

function IsAWrongMoveGoPb_Bug(x : TGameTree) : boolean;
var
  pv : string;
  r  : boolean;
begin
  if x.NextNode = nil
    then
      begin
        pv := x.GetProp(prC);
        Result := (pv = '') or (Pos('RIGHT', pv) = 0)
      end
    else
      begin
        x := x.NextNode;
        r := False;
        while (not r) and (x <> nil) do
          begin
            r := IsAWrongMoveGoPb_Bug(x);
            x := x.NextVar
          end;
        Result := r
      end
end;

function IsAWrongMoveGoPb(x : TGameTree) : boolean; forward;

function IsARightMoveGoPb(x : TGameTree) : boolean;
var
  pv : string;
  r  : boolean;
begin
  if x.NextNode = nil
    then
      begin
        pv := x.GetProp(prC);
        Result := (pv <> '') and (Pos('RIGHT', pv) > 0)
      end
    else
      begin
        x := x.NextNode;
        r := True;
        while r and (x <> nil) do
          begin
            r := r and IsAWrongMoveGoPb(x);
            x := x.NextVar
          end;
        Result := r
      end
end;

function IsAWrongMoveGoPb(x : TGameTree) : boolean;
var
  pv : string;
  r  : boolean;
begin
  if x.NextNode = nil
    then
      begin
        pv := x.GetProp(prC);
        Result := (pv <> '') and (Pos('RIGHT', pv) > 0)
      end
    else
      begin
        x := x.NextNode;
        r := False;
        while (not r) and (x <> nil) do
          begin
            r := r or IsARightMoveGoPb(x);
            x := x.NextVar
          end;
        Result := r
      end
end;

function IsARightMove(si : TInstStatus; x : TGameTree) : Boolean;
begin
  case si.myPbSolMarkup of
    0 : Result := IsARightMoveUligo   (x);
    1 : Result := IsARightMoveGoPb    (x);
    2 : Result := IsARightMoveMainLine(x)
    else
      Result := False
  end
end;

function IsARightSol(gb : TGoban; gt : TGameTree; si : TInstStatus) : Boolean;
begin
  if gb.MoveNumber = 0
    then Result := True
    else
      // test the last move by user
      if Odd(gb.MoveNumber)
        then Result := IsARightMove(si, gt)
        else Result := IsARightMove(si, gt.PrevNode)
end;

// -- Command (hints are erased with gb.HideTempMarks) 

procedure PbHint(view : TViewBoard);
var
  x : TGameTree;
  i, j, player : integer;
begin
  view.si.pbUndo := True;
  view.gb.HideTempMarks;

  with view do
    if Odd(gb.MoveNumber)
      then
        if gt.NextNode = nil
          then
            begin
              // it is a last move played by opponent (program or player)
              gt.GetMoveCoordinates(i, j);
              if si.pbLastMoveKnown
                then gb.ShowTempMark(i, j, mrkGH)
                else gb.ShowTempMark(i, j, mrkBH)
            end
          else
            begin
              // played by player (opponent in two player mode, experimental)
              x := gt.NextNode;
              while x <> nil do
                begin
                  //if IsARightMove(si, x) then
                    begin
                      x.GetMoveCoordinates(i, j);
                      if gb.IsBoardCoord(i, j)
                        then gb.ShowTempMark(i, j, mrkCS)
                    end;
                x := x.NextVar
              end
            end
      else
        if (gb.MoveNumber >= 2) and not IsARightMove(si, gt.PrevNode)
          then // too late
            begin
              gt.PrevNode.GetMoveCoordinates(i, j);
              gb.ShowTempMark(i, j, mrkBH)
            end
          else
            begin
              x := gt.NextNode;
              while x <> nil do
                begin
                  if IsARightMove(si, x) then
                    begin
                      x.GetMove(player, i, j);
                      player := ColorTransform(player, gb.ColorTrans);
                      if gb.IsBoardCoord(i, j)
                        then gb.ShowTempMark(i, j, mrkPHv[player])
                    end;
                x := x.NextVar
              end
            end;

  view.frViewBoard.imGoban.Invalidate
end;

// -- Handling of free mode --------------------------------------------------

procedure PbToggleFreeMode(view : TViewBoard);
begin
  with view do
    if si.MainMode = muProblem
      then
        begin
          si.MainMode  := muFree;
          si.ModeInterBak := si.ModeInter;
          si.ModeInter := kimGE;
          si.pbUndo := True;
          si.PbBackRoot := cl[si.IndexTree].Root;
          si.PbBackPath := gt.StepsToNode;
          cl[si.IndexTree] := gt.MovesToNode;
          gt := cl[si.IndexTree].LastNode;
          UpdateResultBox(frViewBoard, psIgnore, psFreeMode);
          Actions.acPbToggleFreeMode.Caption := U('Problem mode');
          Actions.acPbToggleFreeMode.Hint    := U('Problem mode')
        end
      else
        begin
          gt.Root.FreeGameTree;
          cl[si.IndexTree] := si.PbBackRoot;
          gt := si.PbBackRoot;
          StartDisplay(snExtend, si.PbBackPath);
          si.MainMode := muProblem;
          si.ModeInter := si.ModeInterBak;
          UpdateResultBox(frViewBoard, psIgnore, psRunning);
          Actions.acPbToggleFreeMode.Caption := U('Free mode');
          Actions.acPbToggleFreeMode.Hint    := U('Free mode')
        end
end;

// -- Selection of game ------------------------------------------------------

procedure GmSelectCurrent(var k : integer);
begin
  k := fmMain.ActiveView.si.IndexTree
end;

procedure GmSelectSeq(var k : integer);
begin
  k := GmGetLast + 1;
  GmSetLast(k)
end;

procedure GmSelectAlea(cl : TGameColl; var k : integer);
var
  gmListTmp  : array of integer;
  mini, i, n : integer;
begin
  SetLength(gmListTmp, cl.Count + 1);

  // search for min
  mini := 10000;
  for i := 1 to gmNumber do
    mini := Min(mini, GmNthOcc(i));

  // store less seen
  n := 0;
  for i := 1 to gmNumber do
    if GmNthOcc(i) = mini then
      begin
        inc(n);
        gmListTmp[n] := i
      end;

  // select at random
  k := gmListTmp[random(n) + 1]
end;

// -- Entry point

procedure SelectGame(cl : TGameColl; si : TInstStatus; var n : integer);
begin
  case si.gmMode of
    0 : GmSelectCurrent(n);
    1 : GmSelectSeq    (n);
    2 : GmSelectAlea   (cl, n)
  end
end;

// -- Construction of game result string -------------------------------------

function GtResultToString(gt : TGameTree) : WideString;
var
  pv : WideString;
begin
  pv := gt.Root.GetProp(prRE);
  if pv = ''
    then Result := ''
    else Result := ResultToString(pv2str(pv))
end;

// ---------------------------------------------------------------------------

end.
