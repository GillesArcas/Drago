// ---------------------------------------------------------------------------
// C wrapper for LibKombilo
// ---------------------------------------------------------------------------

#ifndef __LIBKOMBILO_H__
#define __LIBKOMBILO_H__

#ifdef EXPORT
#define DLLCALL __declspec(dllexport) __stdcall
#else
#define DLLCALL __declspec(dllimport) __stdcall
#endif

// return values
#define KSTATUS int
#define KOK     0
#define KERR    1
#define KERRDB  2
#define KERRSGF 3

// process options
#define PO_PROCESSVARIATIONS             0
#define PO_SGFINDB                       1
#define PO_ROOTNODETAGS                  2
#define PO_ALGOS                         3
#define PO_ALGO_HASH_FULL_MAXNUMSTONES   4
#define PO_ALGO_HASH_CORNER_MAXNUMSTONES 5

// search options
#define SO_FIXEDCOLOR         0
#define SO_NEXTMOVE           1
#define SO_MOVELIMIT          2
#define SO_TRUSTHASHFULL      3
#define SO_SEARCHINVARIATIONS 4
#define SO_ALGOS              5

#define CATCH_ERR catch (...) { return KERR; }
#define CATCH_ERR_DB catch (DBError) { return KERRDB; }
#define CATCH_ERR_SGF catch (SGFError) { return KERRSGF; }

typedef void* PatternHandle;
typedef void* SearchOptionsHandle;
typedef void* ProcessOptionsHandle;
typedef void* GameListHandle;

#ifdef __cplusplus
extern "C" {
#endif

// -- Pattern

KSTATUS DLLCALL NewPattern (PatternHandle* handle,
                            int type,
                            int boardsize, int sX, int sY, char* iPos);
KSTATUS DLLCALL NewPatternAnchored (PatternHandle* handle,
                                    int left, int right, int top, int bottom, // 0-based
                                    int boardsize, int sX, int sY, char* iPos);
KSTATUS DLLCALL DeletePattern (PatternHandle handle);

// -- ProcessOptions

KSTATUS DLLCALL NewProcessOptions (ProcessOptionsHandle* handle);
KSTATUS DLLCALL DeleteProcessOptions (ProcessOptionsHandle handle);
KSTATUS DLLCALL ProcessOptionsGet (ProcessOptionsHandle handle, int option, int* value, char *strValue);
KSTATUS DLLCALL ProcessOptionsSet (ProcessOptionsHandle handle, int option, int value, char *strValue);

// -- SearchOptions

KSTATUS DLLCALL NewSearchOptions (SearchOptionsHandle* handle, int fixedColor, int nextMove, int moveLimit);
KSTATUS DLLCALL DeleteSearchOptions (SearchOptionsHandle handle);
KSTATUS DLLCALL SearchOptionsGet (SearchOptionsHandle handle, int option, int* value);
KSTATUS DLLCALL SearchOptionsSet (SearchOptionsHandle handle, int option, int value);

// -- GameList

// -- alloc
KSTATUS DLLCALL NewGameList(GameListHandle* handle, char* DBName, char* OrderBy, char* Format,
                            ProcessOptionsHandle p_options, int cache);
KSTATUS DLLCALL DeleteGameList (GameListHandle handle);

// -- processing sgf
KSTATUS DLLCALL GameListStartProcessing (GameListHandle handle, int ProcessVariations);
KSTATUS DLLCALL GameListFinalizeProcessing (GameListHandle handle);
KSTATUS DLLCALL GameListProcess (GameListHandle handle,
                                 char* sgf, char* path, char* fn,
                                 char* dbtree, int flags,
                                 int* result);
KSTATUS DLLCALL GameListProcessResults (GameListHandle handle, int i, int* result);

// --  pattern search
KSTATUS DLLCALL GameListSearch (GameListHandle handle,
                                PatternHandle  p,
                                SearchOptionsHandle so);
KSTATUS DLLCALL GameListlookupLabel (GameListHandle handle, char x, char y, char* label);
KSTATUS DLLCALL GameListlookupContinuation (GameListHandle handle,
                                            char x, char y,
                                            int* B, int* W, int* tB, int* tW,
                                            int* wB, int* lB, int* wW, int* lW);

// -- signature search
KSTATUS DLLCALL GameListSigSearch(GameListHandle handle, char* sig, int boardSize);
KSTATUS DLLCALL GameListGetSignature(GameListHandle handle, int i, char* sig);

// -- game info search
KSTATUS DLLCALL GameListGISearch (GameListHandle handle, char* sql);

// -- misc
KSTATUS DLLCALL GameListReset (GameListHandle handle);
KSTATUS DLLCALL GameListResetFormat (GameListHandle handle, char* orderBy, char* format);
KSTATUS DLLCALL GameListSize (GameListHandle handle, int* size);
KSTATUS DLLCALL GameListNumHits (GameListHandle handle,
                                 int* numHits, int* numSwitched, int *Bwins, int* Wwins);
KSTATUS DLLCALL GameListCurrentEntryAsString (GameListHandle handle, int i,
                                              int* size, char* str);
KSTATUS DLLCALL GameListGetSGF (GameListHandle handle, int i, int* size, char* str);
KSTATUS DLLCALL GameListGetCurrentProperty (GameListHandle handle, int i, char* tag,
                                            int* size, char* str);

// -- list of players
KSTATUS DLLCALL GameListPlSize (GameListHandle handle, int* plSize);
KSTATUS DLLCALL GameListPlEntry (GameListHandle handle, int i, int* size, char* str);

#ifdef __cplusplus
}
#endif
#endif