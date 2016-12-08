// ---------------------------------------------------------------------------
// -- Drago -- Game related utilities ----------------------- GameUtils.pas --
// ---------------------------------------------------------------------------

unit GameUtils;

// ---------------------------------------------------------------------------

interface

uses
  Types,
  Define, UGameTree, UGameColl, BoardUtils;

function  NextPlayer(gt : TGameTree; defaultPlayer : integer = Empty) : integer;
function  StartNode(gt : TGameTree; mode : TStartNode = snStrict) : TGameTree;
function  BoardSizeOfGameTree(gt : TGameTree) : integer;
function  NumberOfOverTimeStones(gt : TGameTree) : integer;
function  OverTimePeriod(gt : TGameTree; stonesLeft : integer) : real;
function  GetSignature(gt : TGameTree) : string;
function  TransformToFirstOctant(gt : TGameTree) : TCoordTrans; overload;
function  IsContinuationTr(x : TGameTree;
                           player, i, j, dim : integer;
                           var tr : TCoordTrans) : TGameTree;
function  LengthOfGame(x : TGameTree) : integer;
function  IsPvValidCoord(const pv : string; boardSize : integer) : boolean;
function  FirstHit(hitString : string; gt : TGameTree) : string;
function  ExtractPathFromStr(gt : TGameTree; const path : string) : TGameTree;
procedure RemoveProperties(gt : TGameTree; const propList : string; var modified : boolean);
function  FindGameInCollection(gt : TGameTree; cl : TGameColl) : integer;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Classes,
  Properties, Std, Ux2y;

// -- Detection of next player -----------------------------------------------

function NextPlayer(gt : TGameTree; defaultPlayer : integer = Empty) : integer;
var
  pv : string;
begin
  if gt = nil
    then Result := Empty else
  if (gt.NextNode <> nil) and gt.NextNode.HasProp(prB)
    then Result := Black else
  if (gt.NextNode <> nil) and gt.NextNode.HasProp(prW)
    then Result := White else
  if gt.HasProp(prB)
    then Result := White else
  if gt.HasProp(prW)
    then Result := Black else
  if gt.HasProp(prPL) then
    begin
      pv := gt.GetProp(prPL);
      if Length(pv) < 3
        then Result := defaultPlayer        // invalid pv, use default
        else
          case upcase(pv[2]) of
            'B' : Result := Black;
            'W' : Result := White;
            else Result := defaultPlayer    // invalid pv, use default
          end
    end else
  if gt.HasProp(prHA) then
    begin
      if pv2int(gt.GetProp(prHA)) > 1
        then Result := White
        else Result := Black
    end else
  if gt = gt.Root
    then Result := Black
  else
    Result := defaultPlayer                 // not found, use default
end;

// -- Search for the initial node --------------------------------------------

// -- Initial node if the first node without move

function StartNodeStrict(gt : TGameTree) : TGameTree;
begin
  Result := gt.Root;
  if (Result.PropNumber = 0) and (Result.NextNode <> nil)
    and (not Result.NextNode.HasMove)
    then Result := Result.NextNode
end;

// -- Initial node if the last node without move

function StartNodeExtend(gt : TGameTree) : TGameTree;
var
  x, y : TGameTree;
  more : boolean;
begin
  x := gt.Root;
  more := True;

  while more do
    if x.NextNode = nil
      then more := False
      else
        begin
          y := x.NextNode;

          if not y.HasMove
            then x := y
            else more := False
        end;

  Result := x
end;

// -- Initial node

function StartNode(gt : TGameTree; mode : TStartNode = snStrict) : TGameTree;
begin
  if mode = snStrict
    then Result := StartNodeStrict(gt)
    else Result := StartNodeExtend(gt)
end;

// -- Detection of board size in a game tree ---------------------------------

function BoardSizeOfGameTree(gt : TGameTree) : integer;
var
  pv : string;
begin
  pv := gt.Root.GetProp(prSZ);
  if pv = ''
    then Result := 19 // default
    else
      begin
        Result := pv2int(pv);
        if not Within(Result, 3, 19)
          then Result := 19
      end
end;

// -- Search for number of over time stones ----------------------------------

// SGF over time property is not normalized, calculate the number of over time
// stones as the first Black over time stone value + 1, -1 if undefined

function NumberOfOverTimeStones(gt : TGameTree) : integer;
var
  pv : string;
begin
  Result := -1;
  gt := gt.Root;

  while gt <> nil do
    begin
      pv := gt.GetProp(prOB);
      if pv = ''
        then gt := gt.NextNode
        else
          begin
            Result := pv2int(pv);
            exit
          end
    end
end;

// Look for the first time left property with the given number of stones left
// starting at the current node.
// This will give the overtime period if called with the over moves value.

function OverTimePeriod(gt : TGameTree; stonesLeft : integer) : real;
var
  pv : string;
begin
  Result := -1;

  while gt <> nil do
    begin
      // get B or W stones left
      pv := gt.GetProp(prOB);
      if pv = ''
        then pv := gt.GetProp(prOW);

      if pv = ''
        then gt := gt.NextNode
        else
          if pv2int(pv) <> stonesLeft
            then gt := gt.NextNode
            else
              // stones left target found
              begin
                // get B or W time left
                pv := gt.GetProp(prBL);
                if pv = ''
                  then pv := gt.GetProp(prWL);

                // no time left associated with stones left, something wrong
                // with sgf, no need to continue
                if pv = ''
                  then Result := -1
                  else Result := pv2real(pv);

                exit
              end
    end
end;

// -- Signature calculation --------------------------------------------------

function GetSignature(gt : TGameTree) : string;
var
  n : integer;
  r0, r1, pv : string;
begin
  gt := gt.Root;
  r0 := '';
  r1 := '';
  n := 0;

  while gt <> nil do
    begin
      pv := gt.GetProp(prB);
      if pv = ''
        then pv := gt.GetProp(prW);

      if pv <> '' then
        begin
          inc(n);

          if n in [20, 40, 60]
            then r0 := r0 + pv2str(pv)
            else
              if n in [31, 51, 71]
                then r1 := r1 + pv2str(pv);

          if n = 71
            then break
        end;
        
      gt := gt.NextNode
    end;

  Result := r0 + r1;
  Result := Result + Copy('____________', 1, 12 - Length(Result))
end;

// -- Handling of coordinate transformations ---------------------------------

function TransformToFirstOctant(gt : TGameTree) : TCoordTrans;
var
  t : TCoordTrans;
  s : set of TCoordTrans;
  dim, i1, j1, i2, j2, i, j : integer;
begin
  dim := BoardSizeOfGameTree(gt);
  gt := gt.Root.NextNode;

  // if no move, return identity
  if gt = nil then
    begin
      Result := trIdent;
      exit
    end;

  gt.GetMoveCoordinates(i1, j1);

  // if no second move, return first possible transformation for first move
  if gt.NextNode = nil then
    begin
      Result := TransformToFirstOctant(i1, j1, dim);
      exit
    end;

  gt.NextNode.GetMoveCoordinates(i2, j2);

  // store transformations to normalize first move in standard octant
  s := [];
  for t := trIdent to trSymD270 do
    begin
      Transform(i1, j1, dim, t, i, j);
      if (i <= dim div 2 + 1) and (i + j > dim)
        then s := s + [t];
    end;

  // test transform candidates to send second move above second diagonal
  for Result := trIdent to trSymD270 do
    if Result in s then
      begin
        Transform(i2, j2, dim, Result, i, j);
        if (i + j <= dim + 1)
          then exit
      end;

  // second move cannot be above second diagonal, return first transform candidate
(*
  for Result := trIdent to trSymD270 do
    if Result in s
      then exit
*)
  for t := trIdent to trSymD270 do
    if t in s then
      begin
        Result := t;
        exit
      end
end;

// -- Search of an intersection with a variation or a follow up move with
// -- coordinate transforms

function IsVariationTr(x : TGameTree;
                       player, i, j, dim : integer;
                       var tr : TCoordTrans) : TGameTree;
var
  t : TCoordTrans;
  p, q : integer;
begin
  for t := trIdent to trSymD270 do
    begin
      tr := t;
      Transform(i, j, dim, tr, p, q);
      Result := IsVariation(x, player, p, q);
      if Result <> nil
        then exit
    end;
  Result := nil
end;

function IsContinuationTr(x : TGameTree;
                          player, i, j, dim : integer;
                          var tr : TCoordTrans) : TGameTree;
begin
  tr := trIdent;

  if x = nil
    then Result := nil
    else Result := IsVariationTr(x.NextNode, player, i, j, dim, tr)
end;

// -- Number of moves in a game ----------------------------------------------

function LengthOfGame(x : TGameTree) : integer;
var
  n : integer;
begin
  x := StartNode(x);
  n := 0;
  while x.NextNode <> nil do
    begin
      x := x.NextNode;
      if x.HasMove
        then inc(n)
    end;
  Result := n
end;

// -- SGF property value is valid coordinates ([ab]) -------------------------

function IsPvValidCoord(const pv : string; boardSize : integer) : boolean;
begin
  Result := (Length(pv) = 4) and
             Within(pv[2], 'a', Chr(Ord('a') + boardSize - 1)) and
             Within(pv[3], 'a', Chr(Ord('a') + boardSize - 1))
end;

// -- Hit string parsing -----------------------------------------------------

function IsKombiloLabel(c : char) : boolean;
begin
  case c of
    '0'..'9' : Result := False;
    'A'..'Z' : Result := True;
    'a'..'z' : Result := True;
    '?'      : Result := True;
    else       Result := False
  end
end;

function FirstHit(hitString : string; gt : TGameTree) : string;
begin
  Result := NthWord(hitString, 1, ',');
  if Result = ''
    then exit;

  // ignore final dash if any
  if Result[Length(Result)] = '-'
    then Result := Copy(Result, 1, Length(Result) - 1);

  // ignore final alpha character if any (assume only one)
  if IsKombiloLabel(Result[Length(Result)])
    then Result := Copy(Result, 1, Length(Result) - 1);

  // convert path to Drago format
  Result := StringReplace(Result, '-', ';', [rfReplaceAll])
end;

function FirstLabel(hitString : string) : char;
var
  i : integer;
begin
  i := Pos(',', hitString);
  if i > 0
    then dec(i)
    else i := Length(hitString);
  if hitString[i] = '-'
    then dec(i);

  Result := hitString[i]
end;

// -- Create a TGameTree from TGameTree and path -----------------------------
//
// Classes unit is declared for TStringList

function ExtractPathFromStrInner(gt : TGameTree; l : TStringList) : TGameTree;
var
  i, n, k : integer;
begin
  Result := gt;

  for i := 0 to l.Count - 1 do
    begin
      n := StrToInt(l[i]);

      if i mod 2 = 0
        then
          // go forward n moves
           for k := 1 to n do
             if Result.NextNode = nil
               then exit // go as far as possible
               else Result := Result.NextNode
         else
           // go forward n variations
           for k := 1 to n do
             if Result.NextVar = nil
               then exit // go as far as possible
               else Result := Result.NextVar
    end
end;

function ExtractPathFromStr(gt : TGameTree; const path : string) : TGameTree;
var
  l : TStringList;
begin
  l := TStringList.Create;
  ExtractStrings([';'], [], PChar(path), l);

  gt := gt.Root;
  gt := ExtractPathFromStrInner(gt, l);

  Result := gt.MovesToNode;

  l.Free
end;

// -- Removing a list of SGF properties --------------------------------------

procedure RemoveProperties(gt : TGameTree; const propList : string; var modified : boolean);
var
  propNames : TStringDynArray;
  propIds : array of TPropId;
  i : integer;
begin
  Split(propList, propNames, ',');
  SetLength(propIds, Length(propNames));

  for i := 0 to High(propNames) do
    propIds[i] := PropertyId(propNames[i]);

  modified := False;
  gt := gt.Root;

  while gt <> nil do
    begin
      for i := 0 to High(propIds) do
        if gt.HasProp(propIds[i]) then
          begin
            gt.RemProp(propIds[i]);
            modified := True
          end;
      gt := gt.NextNodeDepthFirst
    end
end;

// -- Find a game in a collection --------------------------------------------

function FindGameInCollection(gt : TGameTree; cl : TGameColl) : integer;
var
  i : integer;
begin
  for i := 1 to cl.Count do
    if gt.Equal(cl[i]) then
      begin
        Result := i;
        exit
      end;
  Result := -1
end;

// ---------------------------------------------------------------------------

end.

