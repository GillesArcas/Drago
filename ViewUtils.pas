// ---------------------------------------------------------------------------
// -- Drago -- Custom view utilities ------------------------ ViewUtils.pas --
// ---------------------------------------------------------------------------

unit ViewUtils;

// ---------------------------------------------------------------------------

interface

uses
  UView, Properties, Sgfio;

procedure DoSaveFile(view : Tview;
                     name : WideString;
                     mode : TSgfSaveMode;
                     out cancel : boolean;
                     matchFileName : boolean = False);

// navigation related commands
procedure GoToNextFG      (view : TView);
procedure MoveToEndOfFigure (view : TView);
procedure GoToNextMarkupOrComment (view : TView);
procedure Continuation    (view : TView; i, j : integer);
procedure DoNextVariation (view : TView);
procedure DoPrevVariation (view : TView);
function  IsMoveTarget    (view : TView) : boolean;
procedure DoPrevTarget    (view : TView);
procedure DoNextTarget    (view : TView);
procedure GameEditNextMove(view : TView; i, j : integer);
procedure GameEditNextSibling (view : TView; i, j : integer);
procedure DoEditMarkTemp  (view  : TView; i, j : integer; pr : TPropId);
procedure InsertPass      (view : TView);
procedure SelectPlayer    (view : TView; player : integer);
procedure RandomGames     (view : TView; n : integer);
procedure RandomGame      (view : TView);
procedure RandomEdit      (view : TView; nbEditOps : integer);
procedure RandomEditProp  (view : TView; nbEditOps : integer);
procedure TestMakeMainBranch(view : TView; nbEditOps : integer);

// ---------------------------------------------------------------------------

implementation

uses
  Types, Classes, SysUtils,
  Define, DefineUi, UGameTree,
  Ux2y, UStatus, Translate,
  URandom;

// -- Save commands ----------------------------------------------------------

procedure DoSaveFile(view : Tview;
                     name : WideString;
                     mode : TSgfSaveMode;
                     out cancel : boolean;
                     matchFileName : boolean = False);
begin
  PrintSGF(view.cl, name, mode, Settings.CompressList, Settings.SaveCompact,
           matchFileName);

  case sgfResult of
    ioErrorOk :
      view.si.FileSave := True;
    ioErrorReadOnly :
      view.MessageDialog(msOk, imExclam,
                         [U('Impossible to save.'),
                         WideFormat(U('File %s is read only.'), [name])])
    else
      view.MessageDialog(msOk, imExclam,
                         [WideFormat(U('Impossible to save %s.'), [name])])
  end;

  cancel := sgfResult <> ioErrorOk
end;

// == Navigation commands ====================================================

// -- Navigation to figures --------------------------------------------------

// Move to next node figure

procedure GoToNextFG(view : TView);
var
  ApplyQuietBack : boolean;
begin
  ApplyQuietBack := view.si.ApplyQuiet;
  view.ApplyQuiet(True);

  while (view.gt.NextNode <> nil) and not view.gt.HasProp(prFG) do
    view.MoveForward;

  view.ApplyQuiet(False);
  view.gb.Draw;
  view.ApplyQuiet(ApplyQuietBack)
end;

// Move to last node before figure

procedure MoveToEndOfFigure(view : TView);
var
  ApplyQuietBack : boolean;
begin
  ApplyQuietBack := view.si.ApplyQuiet;
  view.ApplyQuiet(True);

  while (view.gt.NextNode <> nil) and not view.gt.NextNode.HasProp(prFG) do
    view.MoveForward;

  view.ApplyQuiet(False);
  view.gb.Draw;
  view.ApplyQuiet(ApplyQuietBack)
end;

// -- Next markup or comment -------------------------------------------------

procedure GoToNextMarkupOrComment(view : TView);
var
  ApplyQuietBack : boolean;
begin
  ApplyQuietBack := view.si.ApplyQuiet;
  view.ApplyQuiet(True);

  while (view.gt.NextNode <> nil) and (not view.gt.HasProp([prC] + MarkupProps)) do
    view.MoveForward;

  view.ApplyQuiet(False);
  view.gb.Draw;
  view.ApplyQuiet(ApplyQuietBack);

  view.ReApplyNode
end;

// -- Moves to children and siblings -----------------------------------------

procedure Continuation(view : TView; i, j : integer);
begin
  view.MoveToChild(IsContinuation(view.gt, view.si.Player, i, j))
end;

procedure DoNextVariation(view : TView);
begin
  if view.gt.NextVar <> nil
    then view.MoveToSibling(view.gt.NextVar)
end;

procedure DoPrevVariation(view : TView);
begin
  if view.gt.PrevVar <> nil
    then view.MoveToSibling(view.gt.PrevVar)
end;

// -- Navigation to user defined targets -------------------------------------

function IsMoveTarget(view : TView) : boolean;
var
  i, typ, act : integer;
  pr : TPropId;
  pv, dum1, dum2, dum3 : string;
begin
  Result := True;

  // end of main line or variation is always considered as a target
  if view.gt.NextNode = nil
    then exit;

  // step done?
  if mtStep in Settings.MoveTargets then
    if view.si.MoveNumber = view.si.EndingMove
      then exit;

  // node?
  if mtStartVar in Settings.MoveTargets then
    if (view.gt.PrevVar <> nil) or (view.gt.PrevVar <> nil)
      then exit;

  // comment?
  if mtComment in Settings.MoveTargets then
    if view.gt.GetProp(prC) <> ''
      then exit;

  // figure?
  if mtFigure in Settings.MoveTargets then
    if view.gt.GetProp(prFG) <> ''
      then exit;

  // annotation?
  if mtAnnotation in Settings.MoveTargets then
    for i := 1 to view.gt.PropNumber do
      begin
        view.gt.NthProp(i, pr, pv);
        FindPropDef(pr, typ, act, dum1, dum2, dum3);
        if act = 2
          then exit
      end;

  Result := False
end;

// -- Moves to targets

procedure DoPrevTarget(view : TView);
var
  x : TGameTree;
begin
  view.si.EndingMove := view.si.MoveNumber - Settings.TargetStep;

  while True do
    begin
      x := view.gt;
      if mtEndVar in Settings.MoveTargets
        then view.PrevNodeDepthFirst
        else view.DoPrevMove;

      if x = view.gt
        then exit;

      if IsMoveTarget(view)
        then exit
    end
end;

procedure DoNextTarget(view : TView);
var
  x : TGameTree;
begin
  view.si.EndingMove := view.si.MoveNumber + Settings.TargetStep;

  while True do
    begin
      x := view.gt;
      if mtEndVar in Settings.MoveTargets
        then view.NextNodeDepthFirst
        else view.DoNextMove;

      if x = view.gt
        then exit;

      if IsMoveTarget(view)
        then exit
    end
end;

// -- Editing ----------------------------------------------------------------

// -- Creation of a new sibling

procedure DoNewSibling(view : TView; i, j : integer);
begin
  if view.gt.PrevNode = nil
    then view.MessageDialog(msOk, imDrago, [U('No move to add variation.')])
    else
      begin
        view.DoPrevMove;
        view.DoNewVar(i, j)
      end
end;

// -- Board commands ---------------------------------------------------------

// -- Goto to next move at (i,j), or create a next move or variation

procedure GameEditNextMove(view : TView; i, j : integer);
begin
  if (view.gt = nil) or (view.gt.NextNode = nil)
    then view.DoNewMove(i, j)
    else
      if IsContinuation(view.gt, view.si.Player, i, j) <> nil
        then Continuation(view, i, j)
        else view.DoNewVar(i, j)
end;

// -- Goto to sibling at (i,j), or create a next move or sibling

procedure GameEditNextSibling(view : TView; i, j : integer);
var
  x : TGameTree;
begin
  if view.gt = nil
    then view.DoNewMove(i, j)
    else
      begin
        x := IsVariation(view.gt.FirstVar, ReverseColor(view.si.Player), i, j);

        if x = nil
          then DoNewSibling(view, i, j)
          else view.MoveToSibling(x)
      end
end;

// -- Markup input

procedure DoEditMarkTemp(view  : TView; i, j : integer; pr : TPropId);
var
  mrk : integer;
begin
  case pr of
    pr_W : mrk := mrkWC;
  else
    exit
  end;

  if view.gb.BoardMarks2[i, j].FMark = mrk
    then
      begin
        view.gb.BoardMarks2[i, j].FMark := mrkNo;
        view.gb.ShowVertex(i, j)
      end
    else view.gb.ShowTempMark(i, j, mrk)
end;

// -- Pass insertion

procedure InsertPass(view : TView);
begin
  GameEditNextMove(view, view.gb.BoardSize + 1, view.gb.BoardSize + 1)
end;

// -- Misc editing commands --------------------------------------------------

// -- Player selection command

procedure SelectPlayer(view : TView; player : integer);
const
  BW = 'BW';
begin
  view.UpdatePlayer(player);

  if Settings.PlayerProp and view.AllowModification() then
    begin
      view.gt.PutProp(prPL, '[' + BW[player] + ']');
      view.si.FileSave := False
    end
end;

// -- Testing ----------------------------------------------------------------

procedure RandomGames(view : TView; n : integer);
var
  i : integer;
begin
  view.cl.Clear;
  URandom.RandSeed := 123456789;

  for i := 1 to n do
    RandomGame(view)
end;

procedure RandomGame(view : TView);
var
  k, i, j, n, status, nValid : integer;
  valid : array[1 .. 361, 1 .. 2] of integer;
begin
  view.CreateEvent;
  view.StartEvent;

  for k := 1 to 2000 do
    begin
      nValid := 0;
      for i := 1 to 19 do
        for j := 1 to 19 do
          if view.gb.IsValid(i, j, view.si.Player, status) then
            begin
              inc(nValid);
              valid[nValid, 1] := i;
              valid[nValid, 2] := j
            end;

      if nValid = 0
        then break;

      n := 1 + URandom.Random(nValid);
      i := valid[n, 1];
      j := valid[n, 2];
      view.DoNewMove(i, j)
    end
end;

procedure FreeBranch2(gt : TGameTree; listOfNodes : TList);
begin
  if gt <> nil then
    begin
      FreeBranch2(gt.NextNode, listOfNodes);
      FreeBranch2(gt.NextVar, listOfNodes);
      listOfNodes.Delete(listOfNodes.indexOf(gt));
    end
end;

procedure FreeBranch(gt : TGameTree; listOfNodes : TList);
begin
  if gt.NextNode <> nil
    then FreeBranch2(gt.NextNode, listOfNodes);
  listOfNodes.Delete(listOfNodes.indexOf(gt));
end;

procedure RandomEdit(view : TView; nbEditOps : integer);
const
  prDelTerminal = 5;    // probability to delete a terminal node
  prDelBranch = 2;      // probability to delete a non terminal node
  prAddVar = 5;         // probability to add a variation
var
  nodes : TList;
  k, i, j, n, status : integer;
  x : TGameTree;
begin
  view.cl.Clear;
  URandom.RandSeed := 123456789;
  view.CreateEvent;
  view.StartEvent;

  nodes := TList.Create;
  nodes.Add(view.gt);

  for k := 1 to nbEditOps do
    begin
      n := URandom.Random(nodes.Count);
      x := TGameTree(nodes.Items[n]);

      view.GoToNode(x);

      repeat
        i := URandom.Random(19) + 1;
        j := URandom.Random(19) + 1
      until view.gb.IsValid(i, j, view.si.Player, status);

      if (URandom.Random(100) < prDelBranch) and (view.gt.PrevNode <> nil)
        then
          begin
            FreeBranch(view.gt, nodes);
            view.DoDeleteBranch
          end
        else
          if view.gt.NextNode = nil
            then
              begin
                // terminal node
                if (URandom.Random(100) < prDelTerminal) and (view.gt.PrevNode <> nil)
                  then
                    begin
                      nodes.Delete(nodes.indexOf(view.gt));
                      view.DoUndoMove
                    end
                  else
                    begin
                      view.DoNewMove(i, j);
                      nodes.Add(view.gt)
                    end
              end
            else
              begin
                // non terminal node
                if URandom.Random(100) < prAddVar then
                  begin
                    view.DoNewVar(i, j);
                    nodes.Add(view.gt)
                  end
              end
    end;

  nodes.Free
end;

function RandomString(len : integer) : string;
var
  i : integer;
begin
  if len <= 0
    then exit;
  SetLength(Result, len);
  for i := 1 to len do
    Result[i] := Chr(URandom.Random(26) + 65);
end;

function RandomProperty() : TPropId;
begin
  Result := 1 + URandom.Random(prNum);
end;

procedure RandomEditProp(view : TView; nbEditOps : integer);
const
  prAddMove  = 5;
  prAddComm  = 10;
  prAddLong  = 5;
  prAddOther = 75;
var
  nodes : TList;
  k, i, j, n, status, r : integer;
  x : TGameTree;
  s, s2, pv : string;
  pr : TPropId;
begin
  URandom.RandSeed := 123456789;
  
  // make list of all nodes in game tree
  nodes := TList.Create;
  x := view.gt.Root;
  while x <> nil do
    begin
      nodes.Add(x);
      x := x.NextNodeDepthFirst
    end;

  for k := 1 to nbEditOps do
    begin
      n := URandom.Random(nodes.Count);
      x := TGameTree(nodes.Items[n]);

      view.GoToNode(x);

      repeat
        i := URandom.Random(19) + 1;
        j := URandom.Random(19) + 1
      until view.gb.IsValid(i, j, view.si.Player, status);

      r := URandom.Random(100);

      if r < prAddMove then
        begin
          if not x.HasMove then
            if URandom.Random(2) = 0
              then x.AddProp(prB, ij2pv(i, j))
              else x.AddProp(prW, ij2pv(i, j));
          continue
        end;
      if r < prAddMove + prAddComm then
        begin
          s := RandomString(URandom.Random(50));
          x.AddProp(prC, str2pv(s));
          continue
        end;
      (*
      if r < prAddMove + prAddComm + prAddLong then
        begin
          s  := RandomString(URandom.Random(10) + 1);
          s2 := RandomString(URandom.Random(50));
          x.AddProp(PropertyIndex(s), ij2pv(i, j));
          continue
        end;
      *)
      if r < prAddMove + prAddComm + prAddLong + prAddOther then
        begin
          x.AddProp(RandomProperty(), ij2pv(i, j));
          continue
        end;
      if (r < 100) and (x.PropNumber > 0) then
        begin
          n := 1 + URandom.Random(x.PropNumber);
          x.NthProp(n, pr, pv);
          x.RemProp(pr)
        end
    end;

  nodes.Free
end;

procedure TestMakeMainBranch(view : TView; nbEditOps : integer);
var
  nodes : TList;
  k, i, j, n, status, r : integer;
  x : TGameTree;
  s, s2, pv : string;
  pr : TPropId;
begin
  URandom.RandSeed := 123456789;
  
  // make list of all nodes in game tree
  nodes := TList.Create;
  x := view.gt.Root;
  while x <> nil do
    begin
      nodes.Add(x);
      x := x.NextNodeDepthFirst
    end;

  for k := 1 to nbEditOps do
    begin
      n := URandom.Random(nodes.Count);
      x := TGameTree(nodes.Items[n]);
      i := x.Depth;

      view.GoToNode(x);
      view.DoMakeMainBranch
    end
end;

// ---------------------------------------------------------------------------

end.

