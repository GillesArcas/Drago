unit UGameTreeTests;

interface

uses
  UGameColl, UGameTree, UGoBoard;

function RandomGameTree (randSeed      : integer;
                         nbEditOps     : integer;
                         prDelTerminal : integer;
                         prDelBranch   : integer;
                         prAddVar      : integer) : TGameTree;
procedure RandomGameColl(cl : TGameColl;
                         numTrees      : integer;
                         randSeed      : integer;
                         nbEditOps     : integer;
                         prDelTerminal : integer;
                         prDelBranch   : integer;
                         prAddVar      : integer);

procedure TestExtractGame(cl : TGameColl);
function  TestStringPath(cl : TGameColl) : boolean;
procedure RandomMovesOnBoard(gb : TGoBoard;
                             n : integer;
                             prUndo : integer = 0;
                             enableIllegaleMoves : boolean = False);

implementation

uses
  Classes,
  URandom;

// Random edit

// nbEditOps      number of editing operations
// prDelTerminal  probability to delete a terminal node
// prDelBranch    probability to delete a non terminal node
// prAddVar       probability to add a variation

procedure DeleteNode(gt : TGameTree);
begin
  gt.Unlink;
  gt.FreeGameTree
end;

function RandomGameTree(randSeed      : integer;
                        nbEditOps     : integer;
                        prDelTerminal : integer;
                        prDelBranch   : integer;
                        prAddVar      : integer) : TGameTree;
var
  gt : TGameTree;
  k, i, n : integer;
  x : TGameTree;
begin
  URandom.RandSeed := randSeed;
  gt := TGameTree.Create;

  for k := 1 to nbEditOps do
    begin
      n := gt.NumberOfNodes;
      i := URandom.Random(n);
      x := gt.NthNode(i);

      if (URandom.Random(100) < prDelBranch) and (x.PrevNode <> nil)
        then DeleteNode(x)
        else
          if x.NextNode = nil
            then
              // terminal node
              if (URandom.Random(100) < prDelTerminal) and (x.PrevNode <> nil)
                then
                  begin
                    if (x.NextVar = nil) and (x.PrevVar = nil)
                      then DeleteNode(x)
                  end
                else x.LinkNode(TGameTree.Create)
            else
              // non terminal node
              if URandom.Random(100) < prAddVar
                then x.LinkChild(TGameTree.Create)
    end;
    
  Result := gt
end;

procedure RandomGameColl(cl : TGameColl;
                         numTrees      : integer;
                         randSeed      : integer;
                         nbEditOps     : integer;
                         prDelTerminal : integer;
                         prDelBranch   : integer;
                         prAddVar      : integer);
var
  i, seed : integer;
begin
  seed := randSeed;
  cl.Clear;
  for i := 1 to numTrees do
    begin
      cl.Add(RandomGameTree(seed, nbEditOps, prDelTerminal, prDelBranch, prAddVar));
      seed := URandom.RandSeed
    end
end;

procedure TestExtractGame(cl : TGameColl);
var
  i, n, n1, n2 : integer;
  gt : TGameTree;
begin
  URandom.RandSeed := 123456789;

  for i := 1 to cl.Count do
  begin
    gt := cl[i].Root;
    if gt = nil
      then continue;

    n1 := gt.NumberOfNodes;
    n := URandom.Random(n1);

    gt := gt.NthNode(n).MovesToNode;
    cl[i].FreeGameTree;
    cl[i] := gt
  end
end;

function TestStringPath(cl : TGameColl) : boolean;
var
  i : integer;
  gt, x : TGameTree;
begin
  URandom.RandSeed := 123456789;
  Result := True;

  for i := 1 to cl.Count do
  begin
    gt := cl[i].Root;

    while gt <> nil do
      begin
        //x := FollowPath(y, gt.StepPath);
        x := gt.Root.NodeAfterSteps(gt.StepsToNode);
        Result := Result and(x = gt);
        if Result = False
          then exit;
        gt := gt.NextNodeDepthFirst
      end
  end
end;

// n                   number of editing operations
// prUndo              probability of undos
// enableIllegaleMoves true if illegal moves are enabled

procedure RandomMovesOnBoard(gb : TGoBoard;
                             n : integer;
                             prUndo : integer = 0;
                             enableIllegaleMoves : boolean = False);
var
  k, i, j, color, status : integer;
  prisos : TChain;
begin
  URandom.RandSeed := 123456789;
  gb.Clear;

  for k := 1 to n do
    begin
      if (prUndo > 0) and URandom.RandomBoolean(prUndo/100)
        then gb.Undo(i, j, color, prisos, status)
        else
          begin
            repeat
              i := 1 + URandom.Random(19);
              j := 1 + URandom.Random(19);
              color := 1 + URandom.Random(2)
            until enableIllegaleMoves or gb.IsValid(i, j, color, status);

            gb.Play(i, j, color, prisos, status)
          end
    end;
end;

end.
