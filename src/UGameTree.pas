// ---------------------------------------------------------------------------
// -- Drago -- Game tree implementation --------------------- UGameTree.pas --
// ---------------------------------------------------------------------------

unit UGameTree;

// ---------------------------------------------------------------------------

interface

uses
  Properties;

type
  TGetPropMode = (gpFirst, gpCat);

type
  TGameProp = record
    Pr : TPropId;
    Pv : string;
  end;

type
  TGameTree = class
  public
    Number  : integer; // used for game tree display
    Tag     : integer; // used for game tree display
    constructor Create; virtual;
    destructor Destroy; override;
    procedure FreeGameTree;
    function  NextNode : TGameTree;
    function  PrevNode : TGameTree;
    function  NextVar  : TGameTree;
    function  PrevVar  : TGameTree;
    function  Root     : TGameTree;
    function  LastNode : TGameTree;
    function  FirstVar : TGameTree;
    function  LastVar  : TGameTree;
    function  IsOnMainBranch : boolean;
    function  HasSibling : boolean;
    function  NextNodeDepthFirst : TGameTree;
    function  PrevNodeDepthFirst : TGameTree;
    function  LastNodeDepthFirst : TGameTree;
    function  NthNode(n : integer) : TGameTree;
    function  NumberOfNodes : integer;
    function  Depth : integer;
    function  Length : integer;
    procedure JoinNode(gt : TGameTree);
    procedure JoinVar(gt : TGameTree);
    procedure LinkNode(gt : TGameTree);
    procedure LinkVar(gt : TGameTree);
    procedure LinkChild(gt : TGameTree);
    procedure Detach;
    procedure Unlink;
    procedure UnlinkVar;
    procedure DeleteNode;
    function  MakeMainBranch : TGameTree;
    function  PromoteVariation : TGameTree;
    function  DemoteVariation : TGameTree;
    function  PropNumber : integer;
    function  NthPropId(n : integer) : TPropId;
    procedure NthProp(n : integer;
                      out pr : TPropId;
                      out pv : string;
                      expandRect : boolean = True);
    function  HasProp(pr : TPropId) : boolean; overload;
    function  HasProp(prs : TPropIds) : boolean; overload;
    function  GetProp(pr : TPropId) : string;
    procedure AddProp(pr : TPropId; const pv : string);
    procedure RemProp(pr : TPropId; all : boolean = True);
    procedure PutProp(pr : TPropId; const pv : string);
    procedure ClearProps;
    procedure CopyProps(source : TGameTree; prs : TPropIds = []);
    function  HasTreeProp(prs : TPropIds) : boolean;
    function  Player : integer;
    function  Winner : integer;
    procedure GetMove(out player, i, j : integer);
    procedure GetMoveCoordinates(out i, j : integer);
    function  HasMove : boolean;
    procedure AddPropPack(pr : TPropId; const pv : string);
    procedure RemPropPack(pr : TPropId; const pv : string);
    procedure RemValij(pr : TPropId; i, j : integer);
    function  ValueAtij(pr : TPropId; i, j : integer) : string;
    procedure UnpackProp(pr : TPropId);
    function  Copy : TGameTree;
    function  Equal(gt : TGameTree) : boolean;
    function  MovesToNode : TGameTree;
    function  StepsToNode : string;
    function  NodeAfterSteps(const path : string) : TGameTree;
  private
    FNextNode : TGameTree;
    FPrevNode : TGameTree;
    FNextVar : TGameTree;
    FPrevVar : TGameTree;
    FPropNumber : integer;
    FProperties : array of TGameProp;
    function  GetPropFirst(pr : TPropId) : string;
    function  GetPropCat(pr : TPropId) : string;
  end;

// Functions

function  NewMove       (player : integer; i, j : integer) : TGameTree;
procedure FindMove      (gt : TGameTree; i, j : integer; var x : TGameTree;
                                                         var n : integer);
function  IsVariation   (gt : TGameTree; player, i, j : integer) : TGameTree;
function  IsContinuation(gt : TGameTree; player, i, j : integer) : TGameTree;
function  NormalizeMovesAtRoot(gt : TGameTree) : TGameTree;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils, Types,
  Define,
  Std,
  Ux2y;

// -- Allocation -------------------------------------------------------------

constructor TGameTree.Create;
begin
  Number    := -1;
  Tag       := -1;
  FNextNode := nil;
  FPrevNode := nil;
  FNextVar  := nil;
  FPrevVar  := nil;
  FPropNumber := 0;
  SetLength(FProperties, 1)
end;

destructor TGameTree.Destroy;
begin
  FPrevNode := nil;
  FNextNode := nil;
  FPrevVar  := nil;
  FNextVar  := nil;
end;

procedure TGameTree.FreeGameTree;
begin
  if self = nil
    then exit;

  if FNextNode <> nil
    then FNextNode.FreeGameTree;

  if FNextVar <> nil
    then FNextVar.FreeGameTree;
    
  Free
end;

// -- Accessors to tree structure --------------------------------------------

function TGameTree.PrevNode : TGameTree;
begin
  if self = nil
    then Result := nil
    else Result := FPrevNode
end;

function TGameTree.NextNode : TGameTree;
begin
  if self = nil
    then Result := nil
    else Result := FNextNode
end;

function TGameTree.Root : TGameTree;
begin
  Result := self;

  if self = nil
    then exit
    else
      while Result.FPrevNode <> nil
        do Result := Result.FPrevNode
end;

function TGameTree.LastNode : TGameTree;
begin
  Result := self;

  if self = nil
    then exit
    else
      while Result.FNextNode <> nil
        do Result := Result.FNextNode
end;

function TGameTree.PrevVar : TGameTree;
begin
  if self = nil
    then Result := nil
    else Result := FPrevVar
end;

function TGameTree.NextVar : TGameTree;
begin
  if self = nil
    then Result := nil
    else Result := FNextVar
end;

function TGameTree.FirstVar : TGameTree;
begin
  Result := self;

  if self = nil
    then exit
    else
      while Result.FPrevVar <> nil do
        Result := Result.FPrevVar
end;

function TGameTree.LastVar : TGameTree;
begin
  Result := self;

  if self = nil
    then exit
    else
      while Result.FNextVar <> nil do
        Result := Result.FNextVar
end;

// -- Game tree predicates ---------------------------------------------------

function TGameTree.IsOnMainBranch : boolean;
var
  gt : TGameTree;
begin
  gt := Self;

  while (gt.PrevVar = nil) and (gt.PrevNode <> nil) do
    gt := gt.PrevNode;

  Result := gt.PrevVar = nil
end;

function TGameTree.HasSibling : boolean;
begin
  if Self = nil
    then Result := False
    else Result := (FPrevVar <> nil) or (FNextVar <> nil)
end;

// -- Iterative depth first traversing ---------------------------------------

// Next, previous and last node in iterative depth first traversing

function TGameTree.NextNodeDepthFirst : TGameTree;
var
  gt : TGameTree;
begin
  gt := Self;

  if gt.FNextNode <> nil
    then Result := gt.FNextNode
    else
      begin
        while (gt.FNextVar = nil) and (gt.FPrevNode <> nil) do
          gt := gt.FPrevNode;

        Result := gt.FNextVar
      end
end;

function TGameTree.PrevNodeDepthFirst : TGameTree;
var
  gt : TGameTree;
begin
  gt := Self;

  if gt.FPrevVar = nil
    then Result := gt.FPrevNode
    else
      begin
        gt := gt.FPrevVar;

        while gt.FNextNode <> nil do
          begin
            gt := gt.FNextNode;
            while gt.FNextVar <> nil do
              gt := gt.FNextVar
          end;

        Result := gt
    end
end;

function TGameTree.LastNodeDepthFirst : TGameTree;
begin
  Result := Self;

  while Result.NextNodeDepthFirst <> nil do
    Result := Result.NextNodeDepthFirst
end;

// Nth node, 0-based, returns LastNodeDepthFirst if n >= NumberOfNodes

function TGameTree.NthNode(n : integer) : TGameTree;
var
  i : integer;
  gt : TGameTree;
begin
  Result := Self;

  for i := 0 to n - 1 do
    begin
      gt := Result.NextNodeDepthFirst;
      if gt = nil
        then exit
        else Result := gt
    end
end;

// -- Metrics (consider all nodes, not only move properties) -----------------

// Number of nodes

function TGameTree.NumberOfNodes : integer;
var
  gt : TGameTree;
begin
  Result := 0;
  gt := Self;

  while gt <> nil do
    begin
      inc(Result);
      gt := gt.NextNodeDepthFirst
    end
end;

// Depth (number of nodes from root)

function TGameTree.Depth : integer;
var
  gt : TGameTree;
begin
  if Self = nil
    then Result := -1
    else
      begin
        Result := 0;
        gt := Self;
        while gt.PrevNode <> nil do
          begin
            gt := gt.PrevNode;
            inc(Result)
          end
      end
end;

// Length (number of nodes from root to end of current variation)

function TGameTree.Length : integer;
var
  gt : TGameTree;
begin
  if Self = nil
    then Result := 0
    else
      begin
        Result := Depth;
        gt := Self;
        while gt.NextNode <> nil do
          begin
            gt := gt.NextNode;
            inc(Result)
          end
      end
end;

// -- Constructors -----------------------------------------------------------

procedure TGameTree.JoinNode(gt : TGameTree);
begin
  if self <> nil
    then self.FNextNode := gt;

  if gt <> nil
    then gt.FPrevNode := self
end;

procedure TGameTree.JoinVar(gt : TGameTree);
begin
  if self <> nil
    then self.FNextVar := gt;

  if gt <> nil
    then gt.FPrevVar := self
end;

procedure TGameTree.LinkNode(gt : TGameTree);
begin
  if gt = nil
    then FNextNode := nil
    else
      begin
        gt := gt.FirstVar;
        FNextNode := gt;
        
        while gt <> nil do
          begin
            gt.FPrevNode := Self;
            gt := gt.FNextVar
          end
      end
end;

procedure TGameTree.LinkVar(gt : TGameTree);
begin
  if gt = nil
    then self.FNextVar := nil
    else
      begin
        gt := gt.FirstVar;

        self.FNextVar := gt;
        gt.FPrevVar := self;

        while gt <> nil do
          begin
            gt.FPrevNode := self.FPrevNode;
            gt := gt.FNextVar
          end
      end
end;

procedure TGameTree.LinkChild(gt : TGameTree);
begin
  if FNextNode = nil
    then LinkNode(gt)
    else FNextNode.LastVar.LinkVar(gt)
end;

procedure TGameTree.Detach;
var
  prev, gt : TGameTree;
begin
  prev := FPrevNode;

  gt := Self;
  while gt <> nil do
    begin
      gt.FPrevNode := nil;
      gt := gt.FNextVar
    end;

  if FPrevVar = nil
    then prev.FNextNode := nil
    else
      begin
        FPrevVar.FNextVar := nil;
        FPrevVar := nil
      end
end;

procedure TGameTree.Unlink;
begin
  if FPrevVar <> nil
    then FPrevVar.FNextVar := FNextVar;

  if FNextVar <> nil
    then FNextVar.FPrevVar := FPrevVar;

  if (FPrevNode <> nil) and (FPrevVar = nil)
    then FPrevNode.FNextNode := FNextVar;

  FPrevNode := nil;
  FPrevVar := nil;
  FNextVar := nil
end;

procedure TGameTree.UnlinkVar;
begin
  if FPrevVar <> nil
    then FPrevVar.FNextVar := FNextVar;

  if FNextVar <> nil
    then FNextVar.FPrevVar := FPrevVar;

  FPrevVar := nil;
  FNextVar := nil
end;

procedure TGameTree.DeleteNode;
var
  nxtNode, prvVar : TGameTree;
begin
  if Self = nil
    then exit;

  nxtNode := Self.FNextNode;
  prvVar  := Self.FPrevVar;

  prevNode.LinkNode(nextNode);

  if prvVar <> nil
    then prvVar.LinkVar(nxtNode);
end;

// -- Reordering branches ----------------------------------------------------

function TGameTree.MakeMainBranch : TGameTree;
var
  y, z : TGameTree;
begin
  y := Self;
  while y <> nil do
    begin
      if y.PrevVar <> nil then
        begin
          y.PrevVar.JoinVar(y.NextVar);
          y.JoinVar(y.FirstVar);
          y.FPrevVar := nil
        end;
      if y.PrevNode <> nil
        then y.PrevNode.LinkNode(y);
      Result := y;
      y := y.PrevNode
    end
end;

function TGameTree.PromoteVariation : TGameTree;
var
  prev, prv2, next : TGameTree;
begin
  prev := Self.FPrevVar;
  prv2 := prev.FPrevVar;
  next := Self.FNextVar;
  prv2.JoinVar(Self);
  Self.JoinVar(prev);
  prev.JoinVar(next);
  Self.PrevNode.FNextNode := Self.FirstVar;
  Result := Self
end;

function TGameTree.DemoteVariation : TGameTree;
var
  prev, next, nxt2 : TGameTree;
begin
  prev := Self.FPrevVar;
  next := Self.FNextVar;
  nxt2 := next.FNextVar;
  prev.JoinVar(next);
  next.JoinVar(Self);
  Self.JoinVar(nxt2);
  Self.PrevNode.FNextNode := Self.FirstVar;
  Result := Self
end;

// -- Properties -------------------------------------------------------------

function TGameTree.PropNumber : integer;
begin
  if Self = nil
    then Result := 0
    else Result := FPropNumber
end;

// Access to nth property, 1-based

function TGameTree.NthPropId(n : integer) : TPropId;
begin
  if Self = nil
    then Result := prNone
    else
      if n > FPropNumber
        then Result := prNone
        else Result := FProperties[n - 1].Pr
end;

procedure TGameTree.NthProp(n : integer;
                            out pr : TPropId;
                            out pv : string;
                            expandRect : boolean = True);
begin
  pr := prNone;
  pv := '';

  if Self = nil
    then exit
    else
      if n > FPropNumber
        then exit
        else
          begin
            pr := FProperties[n - 1].Pr;
            pv := FProperties[n - 1].Pv;
            if expandRect and CanBeCompressed(pr)
              then pv := clist2list(pv)
          end
end;

// Test for property in node

function TGameTree.HasProp(pr : TPropId) : boolean;
var
  i : integer;
begin
  if Self = nil
    then Result := False
    else
      begin
        for i := 1 to PropNumber do
          if NthPropId(i) = pr then
            begin
              Result := True;
              exit
            end;
        Result := False
      end
end;

function TGameTree.HasProp(prs : TPropIds) : boolean;
var
  i : integer;
begin
  if Self = nil
    then Result := False
    else
      begin
        for i := 1 to PropNumber do
          if NthPropId(i) in prs then
            begin
              Result := True;
              exit
            end;
        Result := False
      end
end;

// Search for property in node

function TGameTree.GetProp(pr : TPropId) : string;
begin
  if Self = nil
    then Result := ''
    else
      if CatenateValues(pr)
        then Result := GetPropCat(pr)
        else Result := GetPropFirst(pr)
end;

function TGameTree.GetPropFirst(pr : TPropId) : string;
var
  i : integer;
  pr2 : TPropId;
  pv : string;
begin
  Result := '';

  for i := 1 to PropNumber do
    begin
      NthProp(i, pr2, pv);
      // keep first occurrence
      if pr2 = pr then
        begin
          Result := pv;
          exit
        end
    end
end;

function TGameTree.GetPropCat(pr : TPropId) : string;
var
  i : integer;
  pr2 : TPropId;
  pv : string;
begin
  Result := '';

  for i := 1 to PropNumber do
    begin
      NthProp(i, pr2, pv);
      // cat when several occurrences X[]...X[]
      if pr2 = pr
        then Result := Result + pv
    end
end;

// Addition of a property

procedure TGameTree.AddProp(pr : TPropId; const pv : string);
begin
  if System.Length(FProperties) = FPropNumber
	  then SetLength(FProperties, FPropNumber * 2);

  FProperties[FPropNumber].Pr := pr;
  FProperties[FPropNumber].Pv := pv;

  inc(FPropNumber)
end;

// Remove one property

procedure TGameTree.RemProp(pr : TPropId; all : boolean = True);
var
  propNumberBak, i, k : integer;
begin
  propNumberBak := FPropNumber;

  // remove
  for i := 0 to propNumberBak - 1 do
    if FProperties[i].Pr = pr
      then
        begin
          FProperties[i].Pr := prNone;
          dec(FPropNumber);
          if not all
            then break
        end;

  // pack
  for i := 0 to propNumberBak - 1 do
    if FProperties[i].Pr <> prNone
      then
        begin
          k := i;
          while (k > 0) and (FProperties[k - 1].Pr = prNone) do
            begin
              FProperties[k - 1] := FProperties[k];
              FProperties[k].Pr := prNone;
              dec(k)
            end
        end
end;

// Add a property with unicity

procedure TGameTree.PutProp(pr : TPropId; const pv : string);
begin
  RemProp(pr);
  AddProp(pr, pv)
end;

// Remove all properties

procedure TGameTree.ClearProps;
begin
  FPropNumber := 0
end;

// Copy properties (all if prs empty)

procedure TGameTree.CopyProps(source : TGameTree; prs : TPropIds = []);
var
  i : integer;
  pr : TPropId;
  pv : string;
begin
  FPropNumber := 0;

  if source = nil
    then exit;

  for i := 1 to source.PropNumber do
    begin
      source.NthProp(i, pr, pv);

      if (prs = []) or (pr in prs)
        then AddProp(pr, pv)
    end
end;

// Global detection of properties

function TGameTree.HasTreeProp(prs : TPropIds) : boolean;
var
  gt : TGameTree;
begin
  Result := True;
  gt := Self;

  while gt <> nil do
    begin
      if gt.HasProp(prs)
        then exit;
      gt := gt.NextNodeDepthFirst
    end;

  Result := False
end;

// Moves

function TGameTree.Player : integer;
var
  pv : string;
begin
  pv := GetProp(prB);
  if pv <> '' then
    begin
      Result := Black;
      exit
    end;

  pv := GetProp(prW);
  if pv <> '' then
    begin
      Result := White;
      exit
    end;

  Result := Empty
end;

procedure TGameTree.GetMove(out player, i, j : integer);
var
  pv : string;
begin
  i := 0;
  j := 0;

  pv := GetProp(prB);
  if pv <> ''
    then player := Black
    else
      begin
        pv := GetProp(prW);
        if pv <> ''
          then player := White
          else player := Empty
      end;

  if pv <> ''
    then
      if pv = '[]' // pass
        then i := 0
        else pv2ij(pv, i, j)
end;

procedure TGameTree.GetMoveCoordinates(out i, j : integer);
var
  pv : string;
begin
  i := 0;
  j := 0;

  pv := GetProp(prB);
  if pv = ''
    then pv := GetProp(prW);

  if pv <> ''
    then
      if pv = '[]' // pass
        then i := 0
        else pv2ij(pv, i, j)
end;

// Moves, winner

function TGameTree.HasMove : boolean;
begin
  if Self = nil
    then Result := False
    else Result := HasProp([prB, prW])
end;

function TGameTree.Winner : integer;
var
  pv, s : string;
begin
  pv := Root.GetProp(prRE);
  if pv = ''
    then Result := Empty
    else
      begin
        s := pv2str(pv);
        if System.Length(s) = 0
          then Result := Empty
          else
            case s[1] of
              'B', 'b' : Result := Black;
              'W', 'w' : Result := White;
              else  Result := Empty
            end
      end
end;

// -- Adding and removing packed properties ----------------------------------

procedure TGameTree.AddPropPack(pr : TPropId; const pv : string);
begin
  PutProp(pr, GetProp(pr) + pv)
end;

procedure TGameTree.RemPropPack(pr : TPropId; const pv : string);
var
  s : string;
begin
  s := GetProp(pr);
  s := AnsiReplaceStr(s, pv, '');
  if s = ''
    then RemProp(pr)
    else PutProp(pr, s)
end;

procedure TGameTree.RemValij(pr : TPropId; i, j : integer);
var
  pv : string;
begin
  pv := ValueAtij(pr, i, j);

  if pv <> ''
    then RemPropPack(pr, pv)
end;

function TGameTree.ValueAtij(pr : TPropId; i, j : integer) : string;
var
  s, x : string;
  p, q : integer;
begin
  s := GetProp(pr);
  x := '[' + ij2sgf(i, j); // '[ab'
  p := Pos(x, s);
  if p = 0
    then Result := ''
    else
      begin
        q := PosEx(']', s, p + 3);
        Result := System.Copy(s, p, q - p + 1)
      end
end;

// Unpack property: AB[ab][cd][ef] --> AB[ab]AB[cd]AB[ef]

procedure TGameTree.UnpackProp(pr : TPropId);
var
  pv, x : string;
  k : integer;
begin
  pv := GetProp(pr);
  if pv <> '' then
    begin
      RemProp(pr);
      k := 1;
      x := nthpv(pv, k);
      while x <> '' do
        begin
          AddProp(pr, x);
          inc(k);
          x := nthpv(pv, k)
        end
    end
end;

// -- Copy -------------------------------------------------------------------

function TGameTree.Copy : TGameTree;
var
  gt : TGameTree;
begin
  if Self = nil
    then Result := nil
    else
      begin
        Result := TGameTree.Create;
        Result.CopyProps(Self);

        gt := NextNode;
        while gt <> nil do
          begin
            Result.LinkChild(gt.Copy);
            gt := gt.NextVar
          end
      end
end;

// -- Equality ---------------------------------------------------------------

function TGameTree.Equal(gt : TGameTree) : boolean;
var
  gt1, gt2 : TGameTree;
  i : integer;
  pr1, pr2 : TPropId;
  pv1, pv2 : string;
begin
  gt1 := Self;
  gt2 := gt;

  Result := (gt1 = gt2);
  if Result
    then exit;

  while True do
    begin
      for i := 1 to gt1.PropNumber do
        begin
          gt1.NthProp(i, pr1, pv1);
          gt2.NthProp(i, pr2, pv2);
          Result := (pr1 = pr2) and (pv1 = pv2);
          if not Result
            then exit
        end;
      gt1 := gt1.NextNodeDepthFirst;
      gt2 := gt2.NextNodeDepthFirst;
      Result := (gt1 = nil) and (gt2 = nil);
      if Result
        then exit;
      Result := (gt1 <> nil) and (gt2 <> nil);
      if not Result
        then exit
    end
end;

// -- Moves ------------------------------------------------------------------

// Creation of a node with move

function NewMove(player : integer; i, j : integer) : TGameTree;
begin
  Result := TGameTree.Create;

  if Result <> nil
    then
      if player = Black
        then Result.AddProp(prB, ij2pv(i, j))
        else Result.AddProp(prW, ij2pv(i, j))
end;

// Search a move at coordinates
//
// Note: n must be initialized with the number of the starting move

procedure FindMove(gt : TGameTree; i, j : integer; var x : TGameTree;
                   var n : integer);
var
  player, i2, j2 : integer;
begin
  x := gt;

  repeat
    x.GetMove(player, i2, j2);

    if player <> Empty
      then
        if (i2 = i) and (j2 = j)
          then exit
          else dec(n);

    x := x.PrevNode

  until x = nil
end;

// Search move at current node or variations of current node

function IsVariation(gt : TGameTree; player, i, j : integer) : TGameTree;
var
  player2, i2, j2 : integer;
begin
  Result := nil;
  gt := gt.FirstVar;

  while gt <> nil do
    begin
	  gt.GetMove(player2, i2, j2);

      if (player2 = player) and (i2 = i) and (j2 = j) then
        begin
          Result := gt;
          exit
        end;

      gt := gt.NextVar
    end
end;

function IsContinuation(gt : TGameTree; player, i, j : integer) : TGameTree;
begin
  if gt = nil
    then Result := nil
    else Result := IsVariation(gt.NextNode, player, i, j)
end;

function NormalizeMovesAtRoot(gt : TGameTree) : TGameTree;
var
  x : TGameTree;
  i : integer;
  pr : TPropId;
  pv : string;
begin
  // avoid moves at root by creating an additional node

  x := TGameTree.Create;
  x.CopyProps(gt);
  gt.ClearProps;
  for i := 1 to x.PropNumber do
    begin
      x.NthProp(i, pr, pv);
      if pr in [prB, prW]
        then gt.AddProp(pr, pv);
    end;
  x.RemProp(prB);
  x.RemProp(prW);

  x.LinkNode(gt);
  Result := x
end;

// -- Extraction of a sub tree below a node ----------------------------------

function CopyNodeForPath(gt : TGameTree) : TGameTree;
begin
  Result := TGameTree.Create;
  Result.CopyProps(gt, [prSZ, prKM, prB, prW, prAB, prAW]);
  Result.UnpackProp(prAB);
  Result.UnpackProp(prAW)
end;

function TGameTree.MovesToNode : TGameTree;
var
  gt, x : TGameTree;
begin
  Result := nil;
  gt := Self;

  while gt <> nil do
    begin
      x := CopyNodeForPath(gt);
      x.LinkNode(Result);
      Result := x;
      gt := gt.PrevNode
    end;

  // Result = Result.Root
end;

// -- Step paths -------------------------------------------------------------

// path : n1;n2;...
// odd  : number of moves forward
// even : number of the variation to select

function TGameTree.StepsToNode : string;
var
  gt : TGameTree;
  nNodes, nVars : integer;
begin
  gt := Self;
  Result := '';

  while (gt.PrevVar <> nil) or (gt.PrevNode <> nil) do
    begin
      nVars := 0;
      while gt.PrevVar <> nil do
        begin
          inc(nVars);
          gt := gt.PrevVar
        end;

      nNodes := 0;
      while (gt.PrevNode <> nil) and (gt.PrevVar = nil) do
        begin
          inc(nNodes);
          gt := gt.PrevNode
        end;

      if nVars = 0
        then Result := Format('%d', [nNodes])
        else
          if Result = ''
            then Result := Format('%d;%d', [nNodes, nVars])
            else Result := Format('%d;%d;%s', [nNodes, nVars, Result])
    end;

  if Result = ''
    then Result := '0'
end;

function TGameTree.NodeAfterSteps(const path : string) : TGameTree;
var
  steps : TStringDynArray;
  i, n, k : integer;
begin
  Split(path, steps, ';');
  Result := Self;

  for i := 0 to High(steps) do
    begin
      n := StrToInt(steps[i]);
      if i mod 2 = 0
        then
          // find move
          for k := 1 to n do
            if Result.NextNode = nil
              then exit // go as far as possible
              else Result := Result.NextNode
        else
          // find var
          for k := 1 to n do
            if Result.NextVar = nil
              then exit // go as far as possible
              else Result := Result.NextVar
    end
end;

// ---------------------------------------------------------------------------

end.

