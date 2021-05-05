// ---------------------------------------------------------------------------
// -- Delphi interface for Kombilo --------------------------- UKombilo.pas --
// ---------------------------------------------------------------------------

unit UKombilo;

// ---------------------------------------------------------------------------

interface

uses
  UKombiloInt, SysUtils, Classes;


// ---------------------------------------------------------------------------

const
  // flags for GameListProcess
  CHECK_FOR_DUPLICATES        = 1; // check for duplicates using the signature
  CHECK_FOR_DUPLICATES_STRICT = 2; // check for duplicates using the final ...
  OMIT_DUPLICATES             = 4; // ... position (if ALGO_FINAPOS available)
  OMIT_GAMES_WITH_SGF_ERRORS  = 8;

  // ProcessResults bits
  UNACCEPTABLE_BOARDSIZE      = 1; // (database not changed)
  SGF_ERROR                   = 2;
  // SGF error occurred when playing through the game
  // (and the rest of the concerning variation was not used).
  // Depending on OMIT_GAMES_WITH_SGF_ERRORS, everything before this node (and other variations,
  // if any) was inserted, or the database was not changed.
  IS_DUPLICATE                = 4;
  NOT_INSERTED_INTO_DB        = 8;
  INDEX_OUT_OF_RANGE          = 16;

  // algorithms
  ALGO_FINALPOS     = 1;
  ALGO_MOVELIST     = 2;
  ALGO_HASH_FULL    = 4;
  ALGO_HASH_CORNERS = 8;
  ALGO_INTERVALS    = 16;
  ALGO_HASH_CENTER  = 32;
  ALGO_HASH_SIDES   = 64;

  // pattern location
  CORNER_NW_PATTERN = 0;
  CORNER_NE_PATTERN = 1;
  CORNER_SW_PATTERN = 2;
  CORNER_SE_PATTERN = 3;
  SIDE_N_PATTERN    = 4;
  SIDE_W_PATTERN    = 5;
  SIDE_E_PATTERN    = 6;
  SIDE_S_PATTERN    = 7;
  CENTER_PATTERN    = 8;
  FULLBOARD_PATTERN = 9;

  // process options
  PO_PROCESSVARIATIONS             = 0;
  PO_SGFINDB                       = 1;
  PO_ROOTNODETAGS                  = 2;
  PO_ALGOS                         = 3;
  PO_ALGO_HASH_FULL_MAXNUMSTONES   = 4;
  PO_ALGO_HASH_CORNER_MAXNUMSTONES = 5;

  // search options
  SO_FIXEDCOLOR         = 0;
  SO_NEXTMOVE           = 1;
  SO_MOVELIMIT          = 2;
  SO_TRUSTHASHFULL      = 3;
  SO_SEARCHINVARIATIONS = 4;
  SO_ALGOS              = 5;

type
  TProcessOptions = (poProcessVariations = 0, poSgfInDB, poRootNodeTags, poAlgos,
                     poAlgo_hash_full_maxnumstones, poAlgo_hash_corner_maxnumstones);

  TSearchOptions = (soFixedColor = 0, soNextMove, soMoveLimit, soTrustHashFull,
                    soSearchInVariations, soAlgos);

// ---------------------------------------------------------------------------

type TKPattern = class
  Handle : PatternHandle;
  FPatternType, FLeft, FRight, FTop, FBottom : integer;
  FPattern : string;
  FSizeX, FSizeY : integer;
  constructor Create(patternType, boardsize, sX, sY : integer; iPos : string); overload;
  constructor Create(left, right, top, bottom : integer; // 1-based
                     boardsize, sX, sY : integer; iPos : string); overload;
  destructor Destroy; override;
end;

type TKProcessOptions = class
  Handle : ProcessOptionsHandle;
  constructor Create;
  destructor Destroy; //override;
  function GetValue(option : TProcessOptions) : integer;
  procedure SetValue(option : TProcessOptions; value : integer);
  function GetRootNodeTags : string;
  procedure SetRootNodeTags(value : string);
end;

type TKSearchOptions = class
  Handle : SearchOptionsHandle;
  constructor Create(fixedColor : boolean;
                     nextMove, moveLimit : integer); overload;
  destructor Destroy; override;
  function GetValue(option : TSearchOptions) : integer;
  procedure SetValue(option : TSearchOptions; value : integer);
end;


type

  TKContinuation = class
    labl : char;
    i  : integer;
    j  : integer;
    B  : integer; // number of all black continuations
    W  : integer; //
    tB : integer; // black plays after tenuki
    tW : integer; //
    wB : integer; // black wins (where cont. is B)
    lB : integer; // black loses (where cont. is B)
    wW : integer; // black wins (where cont. is W)
    lW : integer; // black loses (where cont. is W)
  end;

  TKContList = class(TList)
    destructor Destroy; override;
    procedure Clear; override;
  end;

  TKGameList = class
  private
    Handle : GameListHandle;
  public
    Continuations : TKContList;
    NbMatches : integer;
    FPatternType, FLeft, FRight, FTop, FBottom : integer;
    LastPattern : string;
    LastSizeX, LastSizeY : integer;
    FKeepOnlyOneHit : boolean;

    // -- alloc
    constructor Create(DBName : WideString; OrderBy, Format : string;
                       ProcessOptions : TKProcessOptions = nil;
                       cache : integer = 0);
    destructor Destroy; override;
    // -- processing sgf
    procedure StartProcessing(ProcessVariations : boolean);
    procedure FinalizeProcessing;
    function  Process(sgf, path, fn : string; flags : integer) : integer;
    function  ProcessResults(i : integer) : integer;
    // --  pattern search
    procedure Search(pat : TKPattern; so : TKSearchOptions);
    function  LookupLabel(x, y : integer) : char;
    procedure LookupContinuation(x, y : integer;
                                 var B, W, tB, tW, wB, lB, wW, lW : integer);
    // -- signature search
    procedure SigSearch(sig : string; boardsize : integer);
    function  GetSignature(i : integer) : string;
    // -- game info search
    procedure GISearch(sql : string);
    // -- misc
    procedure Reset;
    function  Size : integer;
    function  NumHits : integer;
    procedure StatHits(var numHits, numSwitched, Bwins, Wwins : integer);
    function  CurrentEntryAsString(i : integer) : string;
    function  GetSGF(i : integer) : string;
    function  GetCurrentProperty(i : integer; tag : string) : string;
    // -- list of players
    function  PlSize : integer;
    function  PlEntry(i : integer) : string;

    // extended
    procedure SortContinuations(mode : integer);
    procedure ListOfProperties(list : TStringList; tag : string);
    class function Registered(x : TKGameList) : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std;

// -- string passing mechanism

type TStringFunc = (sfSGF, sfPlayer, sfEntry, sfProperty);

function StringPassing(Handle : GameListHandle;
                       func : TStringFunc; i : integer; s : string) : string;
const
  SizeBuf = 4000;
var
  chars : array[0 .. SizeBuf] of char;
  pchars : PChar;
  size : integer;
  r : TKStatus;
begin
  size := SizeBuf;
  case func of
    sfSGF      : r := GameListGetSGF(Handle, i, size, @chars);
    sfPlayer   : r := GameListPlEntry(Handle, i, size, @chars);
    sfEntry    : r := GameListCurrentEntryAsString(Handle, i, size, @chars);
    sfProperty : r := GameListGetCurrentProperty(Handle, i, PChar(s), size, @chars);
  end;
  if r <> KOK
    then // TODO : what if error
    else
      if size <= SizeBuf
        then Result := PChar(@chars)
        else
          try
            GetMem(pchars, size);
            case func of
              sfSGF      : r := GameListGetSGF(Handle, i, size, pchars);
              sfPlayer   : r := GameListPlEntry(Handle, i, size, pchars);
              sfEntry    : r := GameListCurrentEntryAsString(Handle, i, size, pchars);
              sfProperty : r := GameListGetCurrentProperty(Handle, i, PChar(s), size, pchars);
            end;
            if r <> KOK
              then // TODO: what if error
              else Result := pchars
          finally
            FreeMem(pchars)
          end
end;

// -- TKombiloPattern

constructor TKPattern.Create(patternType, boardsize, sX, sY : integer;
                             iPos : string);
var
  r : TKStatus;
begin
  FPatternType := patternType;
  FLeft    := 0;
  FRight   := 0;
  FTop     := 0;
  FBottom  := 0;
  FPattern := iPos;
  FSizeX   := sX;
  FSizeY   := sY;
  r := NewPattern(Handle, patternType, boardsize, sX, sY, PChar(iPos))
end;

constructor TKPattern.Create(left, right, top, bottom : integer; // 1-based
                             boardsize, sX, sY : integer;
                             iPos : string);
var
  r : TKStatus;
begin
  FPatternType := -1;
  FLeft    := left;
  FRight   := right;
  FTop     := top;
  FBottom  := bottom;
  FPattern := iPos;
  FSizeX   := sX;
  FSizeY   := sY;
  r := NewPatternAnchored(Handle, left-1, right-1, top-1, bottom-1, boardsize,
                          sX, sY, PChar(iPos))
end;

destructor TKPattern.Destroy;
var
  r : TKStatus;
begin
  r := DeletePattern(Handle)
end;

// -- TKProcessOptions

constructor TKProcessOptions.Create;
var
  r : TKStatus;
begin
  r := NewProcessOptions(Handle)
end;

destructor TKProcessOptions.Destroy;
var
  r : TKStatus;
begin
  r := DeleteProcessOptions(Handle)
end;

function TKProcessOptions.GetValue(option : TProcessOptions) : integer;
var
  r : TKStatus;
begin
  r := ProcessOptionsGet(Handle, integer(option), Result, nil)
end;

procedure TKProcessOptions.SetValue(option : TProcessOptions; value : integer);
var
  r : TKStatus;
begin
  r := ProcessOptionsSet(Handle, integer(option), value, '')
end;

function TKProcessOptions.GetRootNodeTags : string;
var
  r : TKStatus;
  value : array[0 .. 1000] of char;
  dummy : integer;
begin
  r := ProcessOptionsGet(Handle, integer(poRootNodeTags), dummy, @value);
  Result := PChar(@value)
end;

procedure TKProcessOptions.SetRootNodeTags(value : string);
var
  r : TKStatus;
begin
  r := ProcessOptionsSet(Handle, integer(poRootNodeTags), 0, PChar(value))
end;

// -- TKSearchOptions

constructor TKSearchOptions.Create(fixedColor : boolean;
                                   nextMove, moveLimit : integer);
var
  r : TKStatus;
  fixed : integer;
begin
  if fixedColor
    then fixed := 1
    else fixed := 0;

  r := NewSearchOptions(Handle, fixed, nextMove, moveLimit)
end;

destructor TKSearchOptions.Destroy;
var
  r : TKStatus;
begin
  r := DeleteSearchOptions(Handle)
end;

function TKSearchOptions.GetValue(option : TSearchOptions) : integer;
var
  r : TKStatus;
begin
  r := SearchOptionsGet(Handle, integer(option), Result)
end;

procedure TKSearchOptions.SetValue(option : TSearchOptions; value : integer);
var
  r : TKStatus;
begin
  r := SearchOptionsSet(Handle, integer(option), value)
end;

// -- TKombiloGameList -------------------------------------------------------

// -- list of current TKombiloGameList
// -- alloc in initialize and finalize sections

var
  RegisterdKombiloGameList : TList = nil;

// -- alloc

constructor TKGameList.Create(DBName : WideString; OrderBy, Format : string;
                              ProcessOptions : TKProcessOptions = nil;
                              cache : integer = 0);
var
  r : TKStatus;
  po, s : string;
  name : AnsiString;
begin
  //<debug>
  (*
  if ProcessOptions = nil
    then po := '0'
    else IntToStr(ProcessOptions.Handle);
  s := SysUtils.Format('Calling NewGameList(%s %s %s %s %d)',
                [DBName, OrderBy, Format, po, cache]);
  Trace(s);
  *)
  //</debug>

  // encode to UTF8 for sqlite3_open
  name := UTF8Encode(DBName);

  if ProcessOptions = nil
    then r := NewGameList(Handle, PChar(name),
                          PChar(OrderBy),
                          PChar(Format), 0, cache)
    else r := NewGameList(Handle,
                          PChar(name),
                          PChar(OrderBy),
                          PChar(Format), ProcessOptions.Handle, cache);
  //<debug>
  (*
  Trace(SysUtils.Format('Return from NewGameList (error: %d)', [integer(r)]));
  *)
  //</debug>

  if r <> KOK then
    begin
      if ProcessOptions = nil
        then po := '0'
        else IntToStr(ProcessOptions.Handle);
      s := SysUtils.Format('Error NewGameList %d: (%s %s %s %s %d)',
                           [integer(r), DBName, OrderBy, Format, po, cache]);
      raise Exception.Create(s)
    end;

  Continuations := TKContList.Create;
  FKeepOnlyOneHit := False;

  // register
  RegisterdKombiloGameList.Add(self)
end;

destructor TKGameList.Destroy;
var
  r : TKStatus;
begin
  r := DeleteGameList(Handle);
  FreeAndNil(Continuations);

  // register
  RegisterdKombiloGameList.Remove(self)
end;

class function TKGameList.Registered(x : TKGameList) : boolean;
begin
  Result := RegisterdKombiloGameList.IndexOf(x) > -1
end;

// -- processing sgf (parameter override always default from ProcessOptions)

procedure TKGameList.StartProcessing(ProcessVariations : boolean);
var
  r : TKStatus;
begin
  if ProcessVariations
    then r := GameListStartProcessing(Handle, 1)
    else r := GameListStartProcessing(Handle, 0)
end;

procedure TKGameList.FinalizeProcessing;
var
  r : TKStatus;
begin
  r := GameListFinalizeProcessing(Handle)
end;

// 0 if error, number of games processed otherwise

function TKGameList.Process(sgf, path, fn : string;
                            flags : integer) : integer;
var
  r : TKStatus;
begin
  r := GameListProcess(Handle, PChar(sgf), PChar(path), PChar(fn), '',
                       flags, Result)
end;

function TKGameList.ProcessResults(i : integer) : integer;
var
  r : TKStatus;
begin
  r := GameListProcessResults(Handle, i, Result)
end;

// -- pattern search

procedure TKGameList.Search(pat : TKPattern; so : TKSearchOptions);
var
  r : TKStatus;
  labl : char;
  i, j, B, W, tB, tW, wB, lB, wW, lW : integer;
  cont : TKContinuation;
  //
  t1, t2, t3, t4 : int64;
  //
begin
  // save search parameters
  FPatternType := pat.FPatternType;
  FLeft        := pat.FLeft;
  FRight       := pat.FRight;
  FTop         := pat.FTop;
  FBottom      := pat.FBottom;
  LastPattern  := pat.FPattern;
  LastSizeX    := pat.FSizeX;
  LastSizeY    := pat.FSizeY;

  //t1 := MilliTimer;
  r := GameListSearch(Handle, pat.Handle, so.Handle);
  //t2 := MilliTimer;
  t3 := MilliTimer;

  Continuations.Clear;
  NbMatches := 0;

  for i := 0 to pat.FSizeY - 1 do
    for j := 0 to pat.FSizeX - 1 do
      begin
        labl := LookupLabel(j, i);
        LookupContinuation(j, i, B, W, tB, tW, wB, lB, wW, lW);

        // no continuation at point i, j of pattern
        if (B = 0) and (W = 0)
          then continue;

        cont := TKContinuation.Create;
        cont.labl := labl;
        cont.i  := i;
        cont.j  := j;
        cont.B  := B;
        cont.W  := W;
        cont.tB := tB;
        cont.tW := tW;
        cont.wB := wB;
        cont.lB := lB;
        cont.wW := wW;
        cont.lW := lW;
        Continuations.Add(cont);
        inc(NbMatches, B + W)
      end;

  t4 := MilliTimer;
(*
  Trace(Format('%8d %8d', [t2 - t1, t4 - t3]));
*)
end;

function TKGameList.LookupLabel(x, y : integer) : char;
var
  r : TKStatus;
  labl : char;
begin
  r := GameListLookupLabel(Handle, x, y, labl);
  Result := labl
end;

procedure TKGameList.LookupContinuation(x, y : integer;
                                        var B, W, tB, tW, wB, lB, wW, lW : integer);
var
  r : TKStatus;
begin
  r := GameListLookupContinuation(Handle, x, y, B, W, tB, tW, wB, lB, wW, lW);
  if r <> KOK  then
    begin
      B := 0; W := 0; tB := 0; tW := 0; wB := 0; lB := 0; wW := 0; lW := 0
    end
end;

// -- signature search

procedure TKGameList.SigSearch(sig : string; boardsize : integer);
var
  r : TKStatus;
begin
  r := GameListSigSearch(Handle, PChar(sig), boardsize)
end;

function TKGameList.GetSignature(i : integer) : string;
var
  r : TKStatus;
  sig : array[0 .. 12] of char;
begin
  r := GameListGetSignature(Handle, i, @sig);
  Result := PChar(@sig)
end;

// -- game info search

procedure TKGameList.GISearch(sql : string);
var
  r : TKStatus;
begin
  r := GameListGISearch(Handle, PChar(sql))
end;

// -- misc

procedure TKGameList.Reset;
var
  r : TKStatus;
begin
  r := GameListReset(Handle)
end;

function TKGameList.Size : integer;
var
  r : TKStatus;
begin
  r := GameListSize(Handle, Result)
end;

function TKGameList.NumHits : integer;
var
  r : TKStatus;
  x, y, z : integer;
begin
  r := GameListNumHits(Handle, Result, x, y, z)
end;

procedure TKGameList.StatHits(var numHits, numSwitched, Bwins, Wwins : integer);
var
  r : TKStatus;
begin
  r := GameListNumHits(Handle, numHits, numSwitched, Bwins, Wwins)
end;

function TKGameList.CurrentEntryAsString(i : integer) : string;
begin
  Result := StringPassing(Handle, sfEntry, i, '')
end;

function TKGameList.GetSGF(i : integer) : string;
begin
  Result := StringPassing(Handle, sfSGF, i, '')
end;

function TKGameList.GetCurrentProperty(i : integer; tag : string) : string;
begin
  Result := StringPassing(Handle, sfProperty, i, tag)
end;

// -- list of players

function TKGameList.PlSize : integer;
var
  r : TKStatus;
  n : integer;
begin
  r := GameListPlSize(Handle, n);
  Result := n;
end;

function TKGameList.PlEntry(i : integer) : string;
begin
  Result := StringPassing(Handle, sfPlayer, i, '')
end;

// == Extension ==============================================================

// -- List of properties -----------------------------------------------------

procedure TKGameList.ListOfProperties(list : TStringList; tag : string);
var
  i : integer;
begin
  list.Clear;
  list.Sorted := True;
  list.Duplicates := dupIgnore;

  for i := 0 to Size - 1 do
    list.Add(GetCurrentProperty(i, tag))
end;

// -- List of continuations --------------------------------------------------

// -- TKContList

destructor TKContList.Destroy;
begin
  Clear;
  inherited Destroy
end;

procedure TKContList.Clear;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    TKContinuation(Items[i]).Free;
  inherited Clear
end;

// -- Forwards

function CompareCont_White(cont1, cont2 : pointer) : integer; forward;
function CompareCont_Black(cont1, cont2 : pointer) : integer; forward;
function CompareCont_Both (cont1, cont2 : pointer) : integer; forward;

// -- List function

procedure TKGameList.SortContinuations(mode : integer);
begin
  case mode of
    1 : Continuations.Sort(CompareCont_Black);
    2 : Continuations.Sort(CompareCont_White);
    3 : Continuations.Sort(CompareCont_Both)
  end
end;

// -- Compare number of continuations for both colors

function CompareCont_Both(cont1, cont2 : pointer) : integer;
var
  n1, n2 : integer;
begin
  with TKContinuation(cont1) do n1 := B + W;
  with TKContinuation(cont2) do n2 := B + W;

  Result := n2 - n1
end;

// -- Compare number of continuations for Black, if not null, White otherwise

function CompareCont_Black(cont1, cont2 : pointer) : integer;
var
  n1, n2, p1, p2 : integer;
begin
  with TKContinuation(cont1) do n1 := B;
  with TKContinuation(cont2) do n2 := B;
  with TKContinuation(cont1) do p1 := W;
  with TKContinuation(cont2) do p2 := W;

  if (n1 > 0) and (n2 > 0)
    then Result := n2 - n1
    else
      if n1 > 0
        then Result := -1
        else
          if n2 > 0
            then Result := 1
            else Result := p2 - p1
end;

// -- Compare number of continuations for White, if not null, Black otherwise

function CompareCont_White(cont1, cont2 : pointer) : integer;
var
  n1, n2, p1, p2 : integer;
begin
  with TKContinuation(cont1) do n1 := W;
  with TKContinuation(cont2) do n2 := W;
  with TKContinuation(cont1) do p1 := B;
  with TKContinuation(cont2) do p2 := B;

  if (n1 > 0) and (n2 > 0)
    then Result := n2 - n1
    else
      if n1 > 0
        then Result := -1
        else
          if n2 > 0
            then Result := 1
            else Result := p2 - p1
end;

// ---------------------------------------------------------------------------

initialization
  RegisterdKombiloGameList := TList.Create
finalization
  RegisterdKombiloGameList.Free
end.
