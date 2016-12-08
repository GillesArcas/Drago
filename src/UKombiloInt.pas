// ---------------------------------------------------------------------------
// -- Delphi interface for Kombilo ------------------------ UKombiloInt.pas --
// ---------------------------------------------------------------------------

unit UKombiloInt;

// ---------------------------------------------------------------------------

interface

// ---------------------------------------------------------------------------

type TKStatus = (KOK=0, KERR, KERRDB, KERRSGF);

const
  // flags for GameListProcess
  CHECK_FOR_DUPLICATES        = 1; // check for duplicates using the signature
  CHECK_FOR_DUPLICATES_STRICT = 2; // check for duplicates using the final ...
  OMIT_DUPLICATES             = 4; // ... position (if ALGO_FINALPOS available)
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

// -- Pattern

type PatternHandle = cardinal;

function NewPattern        (var handle : PatternHandle;
                            patternType,
                            boardsize, sX, sY : integer;
                            iPos : PChar) : TKStatus; stdcall;
function NewPatternAnchored(var handle : PatternHandle;
                            left, right, top, bottom : integer; // 0-based
                            boardsize, sX, sY : integer;
                            iPos : PChar) : TKStatus; stdcall;
function DeletePattern     (handle : PatternHandle) : TKStatus; stdcall;

// -- ProcessOptions

type ProcessOptionsHandle = cardinal;

function NewProcessOptions(var handle : ProcessOptionsHandle) : TKStatus; stdcall;
function DeleteProcessOptions(handle : ProcessOptionsHandle) : TKStatus; stdcall;
function ProcessOptionsGet(handle : ProcessOptionsHandle; option : integer; var value : integer; strValue : PChar) : TKStatus; stdcall;
function ProcessOptionsSet(handle : ProcessOptionsHandle; option, value : integer; strValue : PChar) : TKStatus; stdcall;

// -- SearchOptions

type SearchOptionsHandle = Cardinal;

function NewSearchOptions(var handle : SearchOptionsHandle; fixedColor, nextMove, moveLimit : integer) : TKStatus; stdcall;
function DeleteSearchOptions(handle : SearchOptionsHandle) : TKStatus; stdcall;
function SearchOptionsGet(handle : SearchOptionsHandle; option : integer; var value : integer) : TKStatus; stdcall;
function SearchOptionsSet(handle : SearchOptionsHandle; option, value : integer) : TKStatus; stdcall;

// -- GameList

type GameListHandle = Cardinal;

// -- alloc
function NewGameList(var handle : GameListHandle;
                     DBName, OrderBy, Format : PChar;
                     p_options : ProcessOptionsHandle;
                     cache : integer) : TKStatus; stdcall;
function DeleteGameList(handle : GameListHandle) : TKStatus; stdcall;

// -- processing sgf
function GameListStartProcessing(handle : GameListHandle; ProcessVariations : integer) : TKStatus; stdcall;
function GameListFinalizeProcessing(handle : GameListHandle) : TKStatus; stdcall;
function GameListProcess(handle : GameListHandle;
                         sgf, path, fn, dbtree : PChar;
                         flags : integer; var result : integer) : TKStatus; stdcall;
function GameListProcessResults(handle : GameListHandle; i : integer; var res : integer) : TKStatus; stdcall;

// --  pattern search
function GameListSearch(handle : GameListHandle; p : PatternHandle;
                        so : SearchOptionsHandle) : TKStatus; stdcall;
function GameListlookupLabel(handle : GameListHandle; x, y : byte; var labl : char) : TKStatus; stdcall;
function GameListlookupContinuation(handle : GameListHandle; x, y : byte;
                                    var B, W, tB, tW, wB, lB, wW, lW : integer) : TKStatus; stdcall;

// -- signature search
function GameListSigSearch(handle : GameListHandle; sig : PChar; boardsize : integer) : TKStatus; stdcall;
function GameListGetSignature(handle : GameListHandle; i : integer; sig : PChar) : TKStatus; stdcall;

// -- game info search
function GameListGISearch(handle : GameListHandle; sql : PChar) : TKStatus; stdcall;

// -- misc
function GameListReset(handle : GameListHandle) : TKStatus; stdcall;
function GameListSize(handle : GameListHandle; var size : integer) : TKStatus; stdcall;
function GameListNumHits(handle : GameListHandle;
                         var numHits, numSwitched, Bwins, Wwins : integer) : TKStatus; stdcall;
function GameListCurrentEntryAsString(handle : GameListHandle; i : integer; var size : integer; str : PChar) : TKStatus; stdcall;
function GameListGetSGF(handle : GameListHandle; i : integer; var size : integer; str : PChar) : TKStatus; stdcall;
function GameListGetCurrentProperty(handle : GameListHandle; i : integer; tag : PChar; var size : integer; str : PChar) : TKStatus; stdcall;

// -- list of players
function GameListPlSize(handle : GameListHandle; var plSize : integer) : TKStatus; stdcall;
function GameListPlEntry(handle : GameListHandle; i : integer; var size : integer; str : PChar) : TKStatus; stdcall;

// ---------------------------------------------------------------------------

implementation

// -- Implementation of external functions -----------------------------------

const DLLName = 'LibKombilo.dll';

// -- Pattern
function NewPattern; external DLLName name 'NewPattern@24';
function NewPatternAnchored; external DLLName name 'NewPatternAnchored@36';
function DeletePattern; external DLLName name 'DeletePattern@4';

// -- ProcessOptions
function NewProcessOptions; external DLLName name 'NewProcessOptions@4';
function DeleteProcessOptions; external DLLName name 'DeleteProcessOptions@4';
function ProcessOptionsGet; external DLLName name 'ProcessOptionsGet@16';
function ProcessOptionsSet; external DLLName name 'ProcessOptionsSet@16';

// -- SearchOptions
function NewSearchOptions; external DLLName name 'NewSearchOptions@16';
function DeleteSearchOptions; external DLLName name 'DeleteSearchOptions@4';
function SearchOptionsGet; external DLLName name 'SearchOptionsGet@12';
function SearchOptionsSet; external DLLName name 'SearchOptionsSet@12';

// -- GameList
// -- alloc
function NewGameList; external DLLName name 'NewGameList@24';
function DeleteGameList; external DLLName name 'DeleteGameList@4';
// -- processing sgf
function GameListStartProcessing; external DLLName name 'GameListStartProcessing@8';
function GameListFinalizeProcessing; external DLLName name 'GameListFinalizeProcessing@4';
function GameListProcess; external DLLName name 'GameListProcess@28';
function GameListProcessResults; external DLLName name 'GameListProcessResults@12';
// --  pattern search
function GameListSearch; external DLLName name 'GameListSearch@12';
function GameListlookupLabel; external DLLName name 'GameListlookupLabel@16';
function GameListlookupContinuation; external DLLName name 'GameListlookupContinuation@44';
// -- signature search
function GameListSigSearch; external DLLName name 'GameListSigSearch@12';
function GameListGetSignature; external DLLName name 'GameListGetSignature@12';
// -- game info search
function GameListGISearch; external DLLName name 'GameListGISearch@8';
// -- misc
function GameListReset; external DLLName name 'GameListReset@4';
function GameListSize; external DLLName name 'GameListSize@8';
function GameListNumHits; external DLLName name 'GameListNumHits@20';
function GameListCurrentEntryAsString; external DLLName name 'GameListCurrentEntryAsString@16';
function GameListGetSGF; external DLLName name 'GameListGetSGF@16';
function GameListGetCurrentProperty; external DLLName name 'GameListGetCurrentProperty@20';
// -- list of players
function GameListPlSize; external DLLName name 'GameListPlSize@8';
function GameListPlEntry; external DLLName name 'GameListPlEntry@16';

// ---------------------------------------------------------------------------

end.
