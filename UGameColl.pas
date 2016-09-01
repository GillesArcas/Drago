// ---------------------------------------------------------------------------
// -- Drago -- Collections of game trees -------------------- UGameColl.pas --
// ---------------------------------------------------------------------------

unit UGameColl;

// ---------------------------------------------------------------------------

interface

uses
  UGameTree;

type

TCollElem = class;

TDelayedAccess = class
  procedure DelayedAccess(i : integer; collElem : TCollElem); virtual; abstract;
end;

TCollElem = class
  gtree : TGameTree;
  FIndex : integer;
  FHits  : string;
  FFileName : WideString;
  Modified : boolean;
  Delayed  : boolean;
  Access   : TDelayedAccess;
end;

// warning : TGamColl.Tree is 1-based and should be implicit. TGamColl.Trees is
// 0-based and is an attempt to migrate toward a more standard representation.

TGameColl = class
  maxTree : integer;
  FCount : integer;
  FTree : array of TCollElem;
  Folder : WideString;

  function  GetTree    (i : integer) : TGameTree;
  function  GetFilename(i : integer) : WideString;
  function  GetIndex   (i : integer) : integer;
  function  GetHits    (i : integer) : string;
  procedure SetTree    (i : integer; gt : TGameTree);
  procedure SetFilename(i : integer; x : WideString);
  procedure SetIndex   (i : integer; x : integer);
  procedure SetHits    (i : integer; x : string);

  property  Count : integer read FCount write FCount;
  property  Filename [i : integer] : WideString read GetFilename write SetFilename;
  // index of game inside collection
  property  Index    [i : integer] : integer read GetIndex write SetIndex;
  property  Hits     [i : integer] : string read GetHits write SetHits;
  property  Tree     [i : integer] : TGameTree read GetTree write SetTree; default;

  constructor Create;
  destructor Destroy; override;
  procedure Commit(i : integer);
  procedure Reset(i : integer);
  procedure Add(gt : TGameTree); overload;
  procedure Add(gt : TGameTree; filename : WideString; index : integer); overload;
  procedure Delete(i : integer);
  procedure AddDelayed(delayedAccess : TDelayedAccess);
  procedure Clear;
  procedure Assign(glist : TGameColl);
  procedure Append(glist : TGameColl);
  procedure Decant(x : TGameColl);
  function  IsModified : boolean;
  function  CollectionName : WideString;

  function  GetTree0(i : integer) : TGameTree;
  function  GetIndex0(i : integer) : integer;
  procedure SetIndex0(i : integer; x : integer);
  function  GetHits0(i : integer) : string;
  procedure SetHits0(i : integer; x : string);
  property  Trees [i : integer] : TGameTree read GetTree0;
  property  Index0 [i : integer] : integer read GetIndex0 write SetIndex0;
  property  Hits0 [i : integer]  : string read GetHits0 write SetHits0;
end;

// ---------------------------------------------------------------------------

implementation

// -- Creation and destruction -----------------------------------------------

constructor TGameColl.Create;
begin
  SetLength(FTree, 1001);
  maxTree := 1000;
  Count := 0;
  Folder := ''
end;

destructor TGameColl.Destroy;
begin
  Clear;
  Finalize(FTree);

  inherited Destroy
end;

// -- Clear ------------------------------------------------------------------

procedure TGameColl.Clear;
var
  i : integer;
begin
  for i := 1 to Count do
    begin
      if (not FTree[i].Delayed)
        then FTree[i].gtree.FreeGameTree;
      FTree[i].Access.Free
    end;

  for i := 1 to Count do
    FTree[i].Free;

  SetLength(FTree, 1001);
  maxTree := 1000;
  Count := 0
end;

// -- Access to data ---------------------------------------------------------

// -- Call of the delayed access function if required

procedure TGameColl.Commit(i : integer);
begin
  if FTree[i].Delayed then
    begin
      FTree[i].Access.DelayedAccess(i, FTree[i]);
      //FTree[i].Access.Free;
      FTree[i].Delayed := False
    end
end;

// -- 

procedure TGameColl.Reset(i : integer);
begin
  if not FTree[i].Delayed then
    begin
      FTree[i].gtree.FreeGameTree;
      FTree[i].gtree := nil;
      FTree[i].Delayed := True
    end
end;

// -- Access to game tree

function TGameColl.GetTree(i : integer) : TGameTree;
begin
  Commit(i);
  Result := FTree[i].gtree
end;

procedure TGameColl.SetTree(i : integer; gt : TGameTree);
begin
  FTree[i].gtree := gt
end;

// -- Access to filename

function TGameColl.GetFilename(i : integer) : WideString;
begin
  Commit(i);
  Result := FTree[i].FFilename
end;

procedure TGameColl.SetFilename(i : integer; x : WideString);
begin
  FTree[i].FFilename := x
end;

// -- Access to index

function TGameColl.GetIndex(i : integer) : integer;
begin
  Commit(i);
  Result := FTree[i].FIndex
end;

procedure TGameColl.SetIndex(i : integer; x : integer);
begin
  FTree[i].FIndex := x
end;

// -- Access to hits

function TGameColl.GetHits(i : integer) : string;
begin
  Commit(i);
  Result := FTree[i].FHits
end;

procedure TGameColl.SetHits(i : integer; x : string);
begin
  FTree[i].FHits := x
end;

// -- Additions --------------------------------------------------------------

procedure TGameColl.Add(gt : TGameTree);
begin
  if Count = maxTree then
    begin
      maxTree := maxTree + 1000;
      SetLength(FTree, 1 + maxTree)
    end;
  Count := Count + 1;

  FTree[Count] := TCollElem.Create;
  FTree[Count].gtree := gt;
  FTree[Count].FIndex := -1;
  FTree[Count].FHits := '';
  FTree[Count].FFileName := '';
  FTree[Count].Modified := False;
  FTree[Count].Delayed  := False
end;

procedure TGameColl.Add(gt : TGameTree; filename : WideString; index : integer);
begin
  Add(gt);
  FTree[Count].FFileName := filename;
  FTree[Count].FIndex := index
end;

procedure TGameColl.AddDelayed(delayedAccess : TDelayedAccess);
begin
  Add(nil);
  FTree[Count].Delayed := True;
  FTree[Count].Access  := delayedAccess
end;

procedure TGameColl.Delete(i : integer);
var
  j : integer;
begin
  if (i < 1) or (i > Count)
    then exit;

  FTree[i].gtree.FreeGameTree;
  FTree[i].gtree := nil;
  FTree[i].Free;

  for j := i + 1 to Count do
    FTree[j - 1] := FTree[j];

  Count := Count - 1
end;

// -- Assign and append ------------------------------------------------------
//
// handle only gt and not other attributes

procedure TGameColl.Assign(glist : TGameColl);
begin
  Clear;
  Append(glist);
  Folder := glist.Folder
end;

procedure TGameColl.Append(glist : TGameColl);
var
  i : integer;
begin
  for i := 1 to glist.Count do
    Add(glist[i])
end;

// decant (transvase?) content of x into object 

procedure TGameColl.Decant(x : TGameColl);
begin
  Clear;

  MaxTree := x.MaxTree;
  Count   := x.Count;
  FTree   := Copy(x.FTree);
  Folder  := x.Folder;
  
  SetLength(x.FTree, 0);
  x.MaxTree := 0;
  x.Count := 0
end;

// -- Predicates -------------------------------------------------------------

function TGameColl.IsModified : boolean;
var
  i : integer;
begin
  Result := False;
  for i := 1 to Count do
    if FTree[i].Modified then
      begin
        Result := True;
        exit
      end
end;

// -- Collection file name ---------------------------------------------------
//
// If several names in collection, returns '' else return the unique file name
// TODO: check why only first filename is tested

// not used
function TGameColl.CollectionName : WideString;
var
  s : WideString;
  i : integer;
begin
  Result := '';
  if Count = 0
    then exit
    else s := Filename[1];

  Result := '';
  for i := 2 to Count do
    if Filename[i] <> s
      then exit;

  Result := s
end;

// -- 0-based properties -----------------------------------------------------
//
// Experimental

function TGameColl.GetTree0(i : integer) : TGameTree;
begin
  Result := GetTree(i + 1)
end;

// -- Access to index

function TGameColl.GetIndex0(i : integer) : integer;
begin
  Commit(i+1);
  Result := FTree[i+1].FIndex
end;

procedure TGameColl.SetIndex0(i : integer; x : integer);
begin
  FTree[i+1].FIndex := x
end;

// -- Access to hits

function TGameColl.GetHits0(i : integer) : string;
begin
  Commit(i+1);
  Result := FTree[i+1].FHits
end;

procedure TGameColl.SetHits0(i : integer; x : string);
begin
  FTree[i+1].FHits := x
end;

// ---------------------------------------------------------------------------

end.
