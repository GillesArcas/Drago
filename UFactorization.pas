unit UFactorization;

interface

uses
  ClassesEx, UGameColl;

type
  TCallBackInt = procedure(x : integer);
  TCallBackStr = procedure(s : WideString);

procedure CollectionFactorization(clIn, clOut : TGameColl;
                                  depth, nbUnique : integer;
                                  tewari : boolean;
                                  onStep : TCallBackInt;
                                  onError : TCallBackStr); overload;
procedure CollectionFactorization(theList : TWideStringList;
                                  clOut : TGameColl;
                                  depth, nbUnique : integer;
                                  tewari : boolean;
                                  onStep : TCallBackInt;
                                  onError : TCallBackStr); overload;

implementation

uses
  Classes, SysUtils,
  Define, Std, UGameTree, Properties, GameUtils, BoardUtils,
  UGMisc, SgfIo, UStatus, Ux2y,
  UView, UContext, UGoban, Translate, CodePages;

// -- Game providers : abstract origin of games to factorize -----------------

// Generic game provider

type
  TGameProvider = class
  private
    FReference : WideString;
  public
    OnError : TCallBackStr;
    function Next : TGameTree; virtual; abstract;
    function Count : integer; virtual; abstract;
    function Index : integer; virtual; abstract;
    property Reference : WideString read FReference;
  end;

// Game provider from collection

type
  TGameProviderFromCollection = class(TGameProvider)
  private
    FColl : TGameColl;
    FIndex : integer;
  public
    constructor Create(cl : TGameColl);
    function Next : TGameTree; override;
    function Count : integer; override;
    function Index : integer; override;
  end;

constructor TGameProviderFromCollection.Create(cl : TGameColl);
begin
  FColl := cl;
  FIndex := 1
end;

function TGameProviderFromCollection.Next : TGameTree;
var
  filename : WideString;
begin
  if FIndex > FColl.Count
    then Result := nil
    else
      begin
        Result := FColl[FIndex].Root;
        filename := FColl.FTree[FIndex].FFileName;

        if FColl.Count = 1
          then FReference := filename
          else FReference := WideFormat('%s - %d',
                                        [filename, FColl.FTree[FIndex].FIndex]);
        inc(FIndex)
      end
end;

function TGameProviderFromCollection.Count : integer;
begin
  Result := FColl.Count
end;

function TGameProviderFromCollection.Index : integer;
begin
  Result := FIndex
end;

// Game provider from list of file names

type
  TGameProviderFromNameList = class(TGameProvider)
  private
    FNameList : TWideStringList;
    FColl : TGameColl;
    FNameIndex, FGameIndex : integer;
  public
    constructor Create(nameList : TWideStringList);
    destructor Destroy; override;
    function Next : TGameTree; override;
    function Count : integer; override;
    function Index : integer; override;
  end;

constructor TGameProviderFromNameList.Create(nameList : TWideStringList);
begin
  FNameList := nameList;
  FColl := TGameColl.Create;
  FNameIndex := 0;
  FGameIndex := 1
end;

destructor TGameProviderFromNameList.Destroy;
begin
  FColl.Free;
  inherited
end;

function TGameProviderFromNameList.Next : TGameTree;
var
  nGames : integer;
  filename : WideString;
  s : string;
begin
  if FGameIndex <= FColl.Count
    then
      begin
        Result := FColl[FGameIndex].Root;
        filename := FColl.FTree[FGameIndex].FFileName;

        if FColl.Count = 1
          then FReference := filename
          else FReference := WideFormat('%s - %d',
                                        [filename, FColl.FTree[FGameIndex].FIndex]);
        inc(FGameIndex)
      end
    else
      if FNameIndex < FNameList.Count then
        begin
          ReadSgf(FColl, FNameList[FNameIndex], nGames,
                  Settings.LongPNames, Settings.AbortOnReadError);

          if (nGames = 0) or (SgfResult <> 0)
            then
              begin
                if Assigned(OnError)
                  then
                    begin
                      // same messages as for database
                      if nGames = 0
                        then s := U('Unable to process file')
                        else s := U('Unable to process file completely');
                      OnError(U(s) + ' ' + FNameList[FNameIndex])
                    end;

                inc(FNameIndex);
                Result := Next
              end
            else
              begin
                inc(FNameIndex);
                FGameIndex := 1;

                // recurse to get result
                Result := Next;
              end
        end
      else
        Result := nil
end;

function TGameProviderFromNameList.Count : integer;
begin
  Result := FNameList.Count
end;

function TGameProviderFromNameList.Index : integer;
begin
  Result := FNameIndex
end;

// -- Packed games -----------------------------------------------------------
//
// Save memory by storing a game as a sequence of sgf coordinates. Enable to
// sort sequences and find common starting sequences.

type
  TPackedGame = class
  private
    FBoardSize : integer;
    FStartingPos : string;
    FPlayer : integer;
    FWinner : integer;
    FSequence : string;
    FAlternate : boolean;
    FReference : WideString;
    FSignature : string;
    FCoordTrans : TCoordTrans;
    function GetGameLength : integer;
  public
    constructor Create(gt : TGameTree);
    class function CreatePackedGame(gt : TGameTree; var retCode : integer) : TPackedGame;
    property Sequence : string read FSequence write FSequence;
    property StartingPos : string read FStartingPos write FStartingPos;
    property BoardSize : integer read FBoardSize;
    property Player : integer read FPlayer;
    property Winner : integer read FWinner;
    property GameLength : integer read GetGameLength;
    property Signature : string read FSignature;
    property Reference : WideString read FReference write FReference;
    property CoordTrans : TCoordTrans read FCoordTrans;
  end;

function  StartingPosition  (gt : TGameTree) : string; forward;
procedure GameTreeToSequence(gt : TGameTree;
                             coordTrans : TCoordTrans;
                             var sequence : string;
                             var alternate : boolean); forward;

constructor TPackedGame.Create(gt : TGameTree);
var
  pv : string;
begin
  pv := gt.Root.GetProp(prSZ);
  if pv = ''
    then FBoardSize := 19 // default
    else FBoardSize := pv2int(pv);

  FPlayer      := gt.Root.NextNode.Player;
  FWinner      := gt.Winner;
  FStartingPos := StartingPosition(gt);
  FSignature   := GameUtils.GetSignature(gt);

  if gt.HasProp([prAB, prAW])
    then FCoordTrans := trIdent
    else
      if Settings.FactorizeNormPos
        then FCoordTrans := TransformToFirstOctant(gt)
        else FCoordTrans := trIdent;

  GameTreeToSequence(gt, FCoordTrans, FSequence, FAlternate);
end;

class function TPackedGame.CreatePackedGame(gt : TGameTree; var retCode : integer) : TPackedGame;
begin
  Result := TPackedGame.Create(gt);

  if (not Result.FAlternate)
    then retCode := 1
    else
      if (Result.FBoardSize < 3) or (Result.FBoardSize > 19)
        then retCode := 2
        else retCode := 0;

  if retCode <> 0
    then FreeAndNil(Result);
end;

function TPackedGame.GetGameLength : integer;
begin
  Result := Length(sequence) div 2
end;

// Handicap handling:
// - detects missing HA property for default placement
// - removes HA property for free placement
// - inserts HA[?] when no or free handicap in position string to be sorted
//   after handicap games

function StartingPosition(gt : TGameTree) : string;
var
  view : TView;
  sB, sW, color, ha : string;
  boardsize, player : integer;
  isHandicap : boolean;
begin
  gt := gt.Root;
  boardsize := BoardSizeOfGameTree(gt);
  player := gt.NextNode.Player;
  if (boardsize = 19) and (player = Black) and (not gt.HasProp([prAB, prAW])) then
    begin
      Result := '';//'PL[B]';
      exit
    end;

  // create and initialize working bare view
  view := TView.Create;
  view.Context := TContext.Create;
  view.gt := gt;
  view.gb := TGoban.Create;
  try
    view.MoveToStart;
    ExtractStoneSetting(sB, sW, view);

    if NextPlayer(view.gt) = Black
      then color := 'B'
      else color := 'W';

    // detect default handicap placement
    // compare with stone ordering given by ExtractStoneSetting
    isHandicap := False;
    if (boardsize = 19) and (sB <> '') and (sW = '')
      then
        case Length(sB) div 4 of
          2 : isHandicap := (sB = '[pd][dp]');
          3 : isHandicap := (sB = '[pd][dp][pp]');
          4 : isHandicap := (sB = '[dd][pd][dp][pp]');
          5 : isHandicap := (sB = '[dd][pd][jj][dp][pp]');
          6 : isHandicap := (sB = '[dd][pd][dj][pj][dp][pp]');
          7 : isHandicap := (sB = '[dd][pd][dj][jj][pj][dp][pp]');
          8 : isHandicap := (sB = '[dd][jd][pd][dj][pj][dp][jp][pp]');
          9 : isHandicap := (sB = '[dd][jd][pd][dj][jj][pj][dp][jp][pp]');
          else
            isHandicap := False
        end;

    if isHandicap
      then ha := Format('HA[%d]', [Length(sB) div 4])
      else ha := 'HA[?]';

    if isHandicap
      then color := 'B';

    //Result := Format('PL[%s]%sAB%sAW%s', [color, ha, sB, sW])
    Result := Format('%sAB%sAW%s', [ha, sB, sW])

  finally
    view.Context.Free;
    view.Free
  end
end;

// Extract sequence

procedure GameTreeToSequence(gt : TGameTree;
                             coordTrans : TCoordTrans;
                             var sequence : string;
                             var alternate : boolean);
var
  boardSize, player, prevPlayer, i, j, p, q : integer;
  pv : string;
begin
  gt := gt.Root.NextNode;
  player := gt.Player;
  boardSize := BoardSizeOfGameTree(gt);
  alternate := True;
  if player = Empty then
    begin
      sequence := '';
      exit
    end;

  pv := gt.GetProp(iff(player = Black, prB, prW));
  if coordTrans <> trIdent then
    begin
      pv2ij(pv, i, j);
      Transform(i, j, boardSize, coordTrans, p, q);
      pv := ij2pv(p, q)
    end;
  sequence := pv2str(pv);
  gt := gt.NextNode;

  while gt <> nil do
    begin
      prevPlayer := player;
      player := gt.Player;
      if (player = Empty) or (player  <> ReverseColor(prevPlayer)) then
        begin
          sequence := '';
          alternate := False;
          exit
        end;

      pv := gt.GetProp(iff(player = Black, prB, prW));
      if coordTrans <> trIdent then
        begin
          pv2ij(pv, i, j);
          Transform(i, j, boardSize, coordTrans, p, q);
          pv := ij2pv(p, q)
        end;
      sequence := sequence + pv2str(pv);

      gt := gt.NextNode
    end
end;

// Load collection in packed format

procedure LoadCollection(gameProvider : TGameProvider;
                         collectionList : TList;
                         onStep : TCallBackInt;
                         onError : TCallBackStr);
var
  gt : TGameTree;
  pg : TPackedGame;
  retCode : integer;
begin
  while True do
    begin
      gt := gameProvider.Next;
      if gt = nil
        then break;

      pg := TPackedGame.CreatePackedGame(gt, retCode);
      case retCode of
        1 : onError(U('Game ignored (some not alternative moves):') + ' ' + gameProvider.Reference);
        2 : onError(U('Game ignored (board size not handled):') + ' ' + gameProvider.Reference);
        else
          begin
            pg.Reference := gameProvider.Reference;
            collectionList.Add(pg)
          end
      end;

      if (gameProvider.Index mod 1000 = 1) and Assigned(onStep)
        then onStep(Round(100 * gameProvider.Index / gameProvider.Count))
    end
end;

// Sort collection in packed format

function SortPackedGames(p1, p2 : pointer) : integer;
var
  packedGame1, packedGame2 : TPackedGame;
begin
  packedGame1 := TPackedGame(p1);
  packedGame2 := TPackedGame(p2);

  // sort on size (19 first then increasing order)
  if packedGame1.BoardSize <> packedGame2.BoardSize then
    begin
      if packedGame1.BoardSize = 19
        then Result := -1
        else
          if packedGame2.BoardSize = 19
            then Result := +1
            else Result := packedGame1.BoardSize - packedGame2.BoardSize;

      exit
    end;

  // sort on player (Black, White, None)
  if packedGame1.Player <> packedGame2.Player then
    begin
      if packedGame1.Player = Black
        then Result := -1
        else
          if packedGame2.Player = Black
            then Result := +1
            else Result := packedGame2.Player - packedGame1.Player;
            
      exit
    end;

  // sort on initial position
  if packedGame1.StartingPos <> packedGame2.StartingPos then
    begin
      if packedGame1.StartingPos < packedGame2.StartingPos
        then Result := -1
        else Result := +1;

      exit
    end;

  // sort on sequence
  if packedGame1.Sequence > packedGame2.Sequence
    then Result := +1
    else
      if packedGame1.Sequence < packedGame2.Sequence
        then Result := -1
        else Result := 0
end;

procedure SortCollection(collectionList : TList);
begin
  collectionList.Sort(SortPackedGames)
end;

// Reference sort for testing

procedure BubbleSort(collectionList : TList);
var
  i, j, comp : integer;
begin
  for i := 0 to collectionList.Count - 1 do
    for j := i + 1 to collectionList.Count - 1 do
      begin
        comp := SortPackedGames(collectionList[i], collectionList[j]);
        if comp > 0
           then collectionList.Exchange(i, j)
      end
end;

// ---------------------------------------------------------------------------

function DuplicatedGames(p1, p2 : pointer) : boolean;
var
  packedGame1, packedGame2 : TPackedGame;
begin
  packedGame1 := TPackedGame(p1);
  packedGame2 := TPackedGame(p2);

  Result := (packedGame1.BoardSize   = packedGame2.BoardSize)   and
            (packedGame1.Player      = packedGame2.Player)      and
            (packedGame1.StartingPos = packedGame2.StartingPos) and
            (packedGame1.Sequence    = packedGame2.Sequence)
end;

procedure RemoveDuplicates(collectionList : TList;
                           onStep : TCallBackInt;
                           onError : TCallBackStr);
var
  i : integer;
begin
  i := 0;
  while i < collectionList.Count - 1 do
    begin
      if DuplicatedGames(collectionList[i], collectionList[i + 1])
        then
          begin
            onError(U('Duplicate ignored') + ': ' + TPackedGame(collectionList[i + 1]).Reference);
            TPackedGame(collectionList[i + 1]).Free;
            collectionList.Delete(i + 1)
          end
        else
          begin
            // step only when no duplicate. This enables to remove multi duplicates
            inc(i)
          end
    end
end;

// Save collection list to file

procedure SaveToFileCollectionList(collectionList : TList; const filename : string);
var
  i : integer;
  list : TStringList;
begin
  list := TStringList.Create;
  for i := 0 to collectionList.Count - 1 do
    with TPackedGame(collectionList[i]) do
      list.Add(Format('SZ[%d]PL[%d]%s%s %s' , [BoardSize, Player, StartingPos, Sequence, Reference]));
  list.SaveToFile(filename);
  list.Free
end;

// ---------------------------------------------------------------------------

// Extended game tree node to store statistics

type
  TGameTreeEx = class(TGameTree)
  public
    NGames : integer;
    property NBlackWins : integer read Number write Number;
    property NWhiteWins : integer read Tag write Tag;
    constructor Create; override;
    function NextNodeDepthFirst : TGameTree;
  end;

constructor TGameTreeEx.Create;
begin
  inherited Create;
  NGames := 0;
  NBlackWins := 0;
  NWhiteWins := 0
end;

// insert only main line

procedure UpdateNode(gt : TGameTree; aWinner : integer);
begin
  with gt as TGameTreeEx do
    begin
      //inc(NGames);
      NGames := NGames + 1;
      case aWinner of
        Black : NBlackWins := NBlackWins + 1;
        White : NWhiteWins := NWhiteWins + 1;
      end
    end
end;

// Create factorization

procedure InsertGame(result : TGameTree;
                     game : TPackedGame;
                     depth : integer;
                     onError : TCallBackStr);
var
  sequence, s : string;
  winner, move, player, i, j : integer;
  x : TGameTree;
begin
  depth := Min(depth, game.GameLength);
  sequence := game.Sequence;
  winner := game.Winner;

  result := result.Root;
  move := 0;
  UpdateNode(result, winner);

  while move < depth do
    begin
      inc(move);
      j := ord(sequence[2 * (move - 1) + 1]) - ord('a') + 1;
      i := ord(sequence[2 * (move - 1) + 2]) - ord('a') + 1;
      if game.Player = Black
        then player := (move + 1) mod 2 + 1
        else player := (move + 0) mod 2 + 1;

      if result.NextNode = nil
      then
        begin
          x := TGameTreeEx.Create;
          Result.LinkNode(x);
          x.PutProp(iff(player = Black, prB, prW), str2pv(Copy(sequence, 2 * (move - 1) + 1, 2)));
          UpdateNode(x, winner);
          result := result.NextNode;
        end
      else
        begin
          result := result.NextNode;
          x := IsVariation(result, result.Player, i, j);

          if x = nil
          then
            begin
              // move not found in game tree
              x := TGameTreeEx.Create;
              result.LastVar.LinkVar(x);
              x.PutProp(iff(player = Black, prB, prW), str2pv(Copy(sequence, 2 * (move - 1) + 1, 2)));
              UpdateNode(x, winner);
              result := x;
            end
          else
            begin
              result := x;
              UpdateNode(result, winner)
            end
        end
    end;

  // store reference or signature in last node, will be retrieved when
  // storing statistics, several references can be added on the node but
  // keep last one (will be output only when one game at the node)
  case Settings.FactorizeReference of
    0: ; // no reference
    1: s := ExtractFileName(game.Reference);
    2: s := game.Signature;
  end;
  if Settings.FactorizeReference in [1, 2]
    then result.PutProp(prN, str2pv(s))
end;

// Inserting length (number of moves)

function NumberOfCommonMoves(const s1, s2 : string) : integer; overload;
var
  i : integer;
begin
  for i := 1 to Min(Length(s1), Length(s2)) do
    if s1[i] <> s2[i] then
      begin
        // difference has been found, return number of previous move
        Result := (i - 1) div 2;
        exit
      end;

  // end of shorter string has been reached, return its number of moves
  Result := Min(Length(s1), Length(s2)) div 2
end;

function NumberOfCommonMoves(const seq : string;
                             index : integer;
                             list : TList) : integer; overload;
var
  len1, len2 : integer;
begin
  if index = 0
    then len1 := 0
    else len1 := NumberOfCommonMoves(seq, TPackedGame(list[index - 1]).Sequence);

  if index = list.Count - 1
    then len2 := 0
    else len2 := NumberOfCommonMoves(seq, TPackedGame(list[index + 1]).Sequence);

  Result := Max(len1, len2)
end;

function InsertLength(collectionList : TList;
                      index, depth, unique : integer) : integer;
var
  seq : string;
  len, commonLen : integer;
begin
  with TPackedGame(collectionList[index]) do
    begin
      seq := Sequence;
      len := GameLength
    end;

  if unique = 0
    then Result := Min(len, depth)
    else
      begin
        commonLen := NumberOfCommonMoves(seq, index, collectionList);
        Result := Min(len, Max(depth, commonLen + unique))
      end
end;

// Unpack

function UnpackStartPos(x : TPackedGame) : TGameTreeEx;
var
  ab, aw : string;
  p1, p2 : integer;
begin
  p1 := Pos('AB', x.StartingPos);
  p2 := Pos('AW', x.StartingPos);
  ab := Copy(x.StartingPos, p1 + 2, p2 - p1 - 2);
  aw := Copy(x.StartingPos, p2 + 2, MaxInt);

  Result := TGameTreeEx.Create;
  Result.AddProp(prGM, '[1]');
  Result.AddProp(prSZ, int2pv(x.BoardSize));
  if ab <> ''
    then Result.PutProp(prAB, ab);
  if aw <> ''
    then Result.PutProp(prAW, aw);
end;

// Factorize

procedure Factorize(collectionList : TList;
                    clOut : TGameColl;
                    depth, unique : integer;
                    tewari : boolean;
                    onStep : TCallBackInt;
                    onError : TCallBackStr);
var
  x : TGameTreeEx;
  k : integer;
  factIndex : integer;
begin
  // if nothing to insert, create empty game and leave
  if collectionList.Count = 0 then
    begin
      x := TGameTreeEx.Create;
      x.AddProp(prGM, '[1]');
      clOut.Add(x);
      exit
    end;

  // create first empty game
  x := UnpackStartPos(TPackedGame(collectionList[0]));
  clOut.Add(x);

  // insert first game
  factIndex := 1;
  InsertGame(clOut[factIndex],
             collectionList[0],
             InsertLength(collectionList, 0, depth, unique), onError);

  for k := 1 to collectionList.Count - 1 do
    begin
      // create new event if necessary
      if TPackedGame(collectionList[k]).StartingPos <> TPackedGame(collectionList[k-1]).StartingPos then
        begin
          x := UnpackStartPos(TPackedGame(collectionList[k]));
          clOut.Add(x);
          factIndex := factIndex + 1;
        end;

      (*
      with TPackedGame(collectionList[k]) do
        if InsertLength(collectionList, k, depth, unique) = GameLength
          then onError(U('Partial duplicate detected:') + ' ' + Reference);
      *)
      InsertGame(clOut[factIndex],
                 collectionList[k],
                 InsertLength(collectionList, k, depth, unique), 
                 onError)
    end
end;

// Sort variations according to frequency

function SortFactorizationItems(Item1, Item2: Pointer): Integer;
var
  gt1, gt2 : TGameTreeEx;
begin
  gt1 := TGameTreeEx(Item1);
  gt2 := TGameTreeEx(Item2);

  Result := gt2.NGames - gt1.NGames
end;

procedure SortFactorization(gt : TGameTree);
var
  list : TList;
  x, y : TGameTree;
  i : integer;
begin
  list := TList.Create;

  while gt <> nil do
    begin
      if (gt.PrevVar = nil) and (gt.NextVar <> nil) then
        begin
          // fill the list to sort
          list.Clear;
          x := gt;
          while x <> nil do
            begin
              list.Add(x);
              y := x.NextVar;
              x.UnlinkVar;
              x := y
            end;

          // sort
          list.Sort(SortFactorizationItems);

          // make ordered list of vars
          for i := 0 to list.Count - 2 do
            begin
              gt := TGameTree(list[i]);
              gt.JoinVar(TGameTree(list[i+1]));
            end;

          gt := TGameTree(list[0]);
          gt.PrevNode.JoinNode(gt);
        end;

      gt := gt.NextNodeDepthFirst
    end;

  list.Free
end;
                              
function TGameTreeEx.NextNodeDepthFirst : TGameTree;
var
  gt : TGameTree;
begin
  gt := self;

  if (gt.NextNode <> nil)
    then Result := gt.NextNode
    else
      begin
        while (gt.NextVar = nil) and (gt.PrevNode <> nil) do
          gt := gt.PrevNode;

        if gt.NextVar = nil
          then Result := nil
          else Result := gt.NextVar
      end
end;

function FormatStatistics(color, n, total, nb, nw : integer; const ref : string) : string;
var
  nbw, nx, nc, nr : integer;
  sc, sn, sbw : string;
begin
  nbw := nb + nw;
  nx := n - nbw;

  nr := Round(100 * n / total);
  if nr < 1
    then sn := Format('#:0.%%(%d)', [n])
    else sn := Format('#:%d%%(%d)', [nr, n]);

  if nbw = 0
    then sbw := ''
    else
      begin
        sc := iff(color = 1, 'B', 'W');
        nc := iff(color = 1, nb , nw );
        nr := Round(100 * nc / nbw);
        if nc = 0
          then sbw := '!:0%'
          else
            if nr = 0
              then sbw := '!:0.%'
              else sbw := Format('!:%d%%', [nr])
      end;

  if nbw = 0
    then Result := Format('%s ?:%d', [sn, nx])
    else
      if nx = 0
        then Result := Format('%s %s', [sn, sbw])
        else Result := Format('%s %s ?:%d', [sn, sbw, nx]);

  if ref = ''
    then Result := Format('[%s]', [Result])
    else Result := Format('[%s - %s]', [Result, ref])
end;

function TotalGamesInVars(gt : TGameTreeEx) : integer;
var
  x : TGameTreeEx;
begin
  x := TGameTreeEx(gt.FirstVar);
  Result := x.NGames;
  while x.NextVar <> nil do
    begin
      x := TGameTreeEx(x.NextVar);
      Result := Result + x.NGames
    end
end;

procedure SaveStatistics(gt : TGameTree);
var
  n, nb, nw, total : integer;
  ref : WideString;
  firstVar : TGameTreeEx;
begin
  // check if some games have been inserted
  if gt.Root.NextNode = nil
    then exit;

  while gt <> nil do
    begin
      n  := (gt as TGameTreeEx).NGames;
      assert(n > 0);

      // compute or retrieve total number of games for siblings
      // total is stored in NGames value of first variation, computed only
      // one time when processing first variation, retrieved otherwise
      firstVar := TGameTreeEx(gt.FirstVar);
      if gt = firstVar
        then firstVar.NGames := TotalGamesInVars(firstvar);
      total := firstVar.NGames;

      ref := '';
      if n = 1
        then
          if (gt.HasSibling = False) and (gt.PrevNode.PrevNode <> nil)
            then // nop, will add reference only when siblings, ie for the last
                 // not with variations
            else
              begin
                // retrieve and remove reference stored at last node when
                // inserting game
                ref := pv2str(gt.LastNode.GetProp(prN));
                gt.LastNode.RemProp(prN);
              end;

      if (n = 1) and (gt.HasSibling = False) and (gt.PrevNode.PrevNode <> nil)
        then // nop
        else
          begin
            nb := (gt as TGameTreeEx).NBlackWins;
            nw := (gt as TGameTreeEx).NWhiteWins;

            gt.PutProp(prN, FormatStatistics(gt.Player, n, total, nb, nw, ref))
          end;

      gt := gt.NextNodeDepthFirst
    end;
end;

// not used
procedure Prune(gt : TGameTree; minFreq : double);
var
  n, tot : integer;
  x : TGameTreeEx;
begin
  // check if some games have been inserted
  if gt.Root.NextNode = nil
    then exit;

  while gt <> nil do
    begin
      n  := (gt as TGameTreeEx).NGames;
      assert(n > 0);

      if not gt.HasSibling
        then // nop
        else
          //if (gt.PrevVar = nil) and (gt.NextVar <> nil) then
          begin
            x := TGameTreeEx(gt.FirstVar);
            tot := TotalGamesInVars(x);
            if n / tot < minFreq then
              begin
                x := TGameTreeEx(gt);
                gt := gt.PrevNodeDepthFirst;
                x.Detach;
                x.FreeGameTree
              end
          end;

      gt := gt.NextNodeDepthFirst
    end;
end;

// Help comment

function HelpComment : string;
var
  s : WideString;
begin
  s := '#: ' + U('percentage and number of games in variation') + CRLF +
       '!: ' + U('winning percentage of move') + CRLF +
       '?: ' + U('number of unknown results');
  Result := PutEscChar(CpEncode(s, utf8))
end;

procedure AddHelpComment(gt : TGameTree);
var
  nn : string;
begin
  nn := gt.GetProp(prN);
  gt.RemProp(prN);
  
  gt.AddProp(prCA, str2pv('UTF-8'));
  gt.AddProp(prN , nn);
  gt.AddProp(prC, str2pv(HelpComment))
end;

// Entry point

procedure CollectionFactorization(gameProvider : TGameProvider;
                                  clOut : TGameColl;
                                  depth, nbUnique : integer;
                                  tewari : boolean;
                                  onStep : TCallBackInt;
                                  onTrace : TCallBackStr); overload;
var
  gt : TGameTree;
  i, k : integer;
  t1 : int64;
  collectionList : TList;
begin
  MilliTimer; // start timer

  collectionList := TList.Create;
  LoadCollection(gameProvider, collectionList, onStep, onTrace);
  SortCollection(collectionList);
  RemoveDuplicates(collectionList, onStep, onTrace);

  Factorize(collectionList, clOut, depth, nbUnique, tewari, onStep, onTrace);

  for i := 1 to clOut.Count do
    begin
      gt := clOut[i].Root;
      SortFactorization(gt);
      //Prune(gt, 0.1);
      SaveStatistics(gt);
    end;

  AddHelpComment(clOut[1].Root);

  t1 := MilliTimer;
  onTrace(U('Game tree ready.'));
  onTrace(WideFormat('%s: %d', [U('Number of games'), collectionList.Count]));

  // there is a problem with WideFormat and %1.2f, do it other way
  onTrace(U('Elapsed time (seconds)') + ': ' + Format('%1.2f', [1.0 * t1 / 1000.0]));

  for k := 0 to collectionList.Count - 1 do
    TPackedGame(collectionList[k]).Free;
  collectionList.Clear;
  collectionList.Free
end;

procedure CollectionFactorization(clIn, clOut : TGameColl;
                                  depth, nbUnique : integer;
                                  tewari : boolean;
                                  onStep : TCallBackInt;
                                  onError : TCallBackStr);
var
  gameProvider : TGameProvider;
begin
  assert(tewari = False);
  gameProvider := TGameProviderFromCollection.Create(clIn);
  CollectionFactorization(gameProvider, clOut, depth, nbUnique, False,
                          onStep, onError);
  gameProvider.Free;
end;

procedure CollectionFactorization(theList : TWideStringList;
                                  clOut : TGameColl;
                                  depth, nbUnique : integer;
                                  tewari : boolean;
                                  onStep : TCallBackInt;
                                  onError : TCallBackStr);
var
  gameProvider : TGameProvider;
begin
  assert(tewari = False);
  gameProvider := TGameProviderFromNameList.Create(theList);
  GameProvider.OnError := onError;
  CollectionFactorization(gameProvider, clOut, depth, nbUnique, False,
                          onStep, onError);
  gameProvider.Free;
end;

// ---------------------------------------------------------------------------

end.
