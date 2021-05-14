// ---------------------------------------------------------------------------
// C wrapper for LibKombilo
// ---------------------------------------------------------------------------

//#include <windows.h>

#define WINAPI              __stdcall
#define HINSTANCE void*

#include "search.h"

//#include <strings.h>
#include <cstring>
#include <stdio.h>

#define EXPORT
#include "LibKombiloWrapper.h"

extern "C" {

// -- Pattern ----------------------------------------------------------------

KSTATUS DLLCALL NewPattern (PatternHandle* handle,
                            int type,
                            int boardsize, int sX, int sY, char* iPos)
{
    try {
        Pattern* pat = new Pattern(type, boardsize, sX, sY, iPos);
        *handle = (Pattern*)pat;
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL NewPatternAnchored (PatternHandle* handle,
                                    int left, int right, int top, int bottom,
                                    int boardsize, int sX, int sY, char* iPos)
{
    try {
        std::vector<MoveNC> cont;
        cont.clear();
        Pattern* pat = new Pattern(left, right, top, bottom, boardsize, sX, sY, iPos, cont);
        *handle = (Pattern*)pat;
        return KOK;
     }
    CATCH_ERR
}

KSTATUS DLLCALL DeletePattern (PatternHandle handle)
{
    try {
        delete (Pattern*)handle;
        return KOK;
    }
    CATCH_ERR
}

// -- ProcessOptions ---------------------------------------------------------

KSTATUS DLLCALL NewProcessOptions (ProcessOptionsHandle* handle)
{
    try {
        ProcessOptions* po = new ProcessOptions;
        *handle = (ProcessOptions*)po;
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL DeleteProcessOptions (ProcessOptionsHandle handle)
{
    try {
        delete (ProcessOptions*)handle;
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL ProcessOptionsGet (ProcessOptionsHandle handle, int option, int *value, char *strValue)
{
    try {
        ProcessOptions* po = (ProcessOptions*)handle;

        switch (option) {
            case PO_PROCESSVARIATIONS: *value = po->processVariations; break;
            case PO_SGFINDB: *value = po->sgfInDB; break;
            ////case PO_ROOTNODETAGS: strcpy(strValue, po->rootNodeTags.c_str()); break;
            case PO_ALGOS: *value = po->algos; break;
            case PO_ALGO_HASH_FULL_MAXNUMSTONES: *value = po->algo_hash_full_maxNumStones; break;
            case PO_ALGO_HASH_CORNER_MAXNUMSTONES: *value = po->algo_hash_corner_maxNumStones; break;
            default: return KERR;
        }
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL ProcessOptionsSet (ProcessOptionsHandle handle, int option, int value, char *strValue)
{
    try {
        ProcessOptions* po = (ProcessOptions*)handle;

        switch (option) {
            case PO_PROCESSVARIATIONS: po->processVariations = value; break;
            case PO_SGFINDB: po->sgfInDB = value; break;
            case PO_ROOTNODETAGS: po->rootNodeTags = value; break;
            case PO_ALGOS: po->algos = value; break;
            case PO_ALGO_HASH_FULL_MAXNUMSTONES: po->algo_hash_full_maxNumStones = value; break;
            case PO_ALGO_HASH_CORNER_MAXNUMSTONES: po->algo_hash_corner_maxNumStones = value; break;
            default: return KERR;
        }
        return KOK;
    }
    CATCH_ERR
}

// -- SearchOptions ----------------------------------------------------------

KSTATUS DLLCALL NewSearchOptions (SearchOptionsHandle* handle, int fixedColor, int nextMove, int moveLimit)
{
    try {
        SearchOptions* so = new SearchOptions(fixedColor, nextMove, moveLimit);
        *handle = (SearchOptions*)so;
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL DeleteSearchOptions (SearchOptionsHandle handle)
{
    try {
        delete (SearchOptions*)handle;
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL SearchOptionsGet (SearchOptionsHandle handle, int option, int* value)
{
    try {
        SearchOptions* so = (SearchOptions*)handle;

        switch (option) {
            case SO_FIXEDCOLOR        : *value = so->fixedColor; break;
            case SO_NEXTMOVE          : *value = so->nextMove; break;
            case SO_MOVELIMIT         : *value = so->moveLimit; break;
            case SO_TRUSTHASHFULL     : *value = so->trustHashFull; break;
            case SO_SEARCHINVARIATIONS: *value = so->searchInVariations; break;
            case SO_ALGOS             : *value = so->algos; break;
            default : return KERR;
        }
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL SearchOptionsSet (SearchOptionsHandle handle, int option, int value)
{
    try {
        SearchOptions* so = (SearchOptions*)handle;

        switch (option) {
            case SO_FIXEDCOLOR        : so->fixedColor = value; break;
            case SO_NEXTMOVE          : so->nextMove = value; break;
            case SO_MOVELIMIT         : so->moveLimit = value; break;
            case SO_TRUSTHASHFULL     : so->trustHashFull = value; break;
            case SO_SEARCHINVARIATIONS: so->searchInVariations = value; break;
            case SO_ALGOS             : so->algos = value; break;
            default : return KERR;
        }
        return KOK;
    }
    CATCH_ERR
}

// -- GameList ---------------------------------------------------------------

// -- allocation

KSTATUS DLLCALL NewGameList(GameListHandle* handle, char* DBName, char* OrderBy, char* Format,
                            ProcessOptionsHandle p_options, int cache)
{
    try {
        if (cache == 0) {
            GameList* gl = new GameList(DBName, OrderBy, Format, (ProcessOptions*)p_options);
            *handle = (GameListHandle*)gl;
        } else {
            GameList* gl = new GameList(DBName, OrderBy, Format, (ProcessOptions*)p_options, cache);
            *handle = (GameListHandle*)gl;
        }
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL DeleteGameList (GameListHandle handle)
{
    try {
        delete (GameList*)handle;
        return KOK;
    }
    CATCH_ERR
}

// -- processing SGF games

KSTATUS DLLCALL GameListStartProcessing (GameListHandle handle, int ProcessVariations)
{
    try {
        ((GameList*)handle)->start_processing(ProcessVariations);
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListFinalizeProcessing (GameListHandle handle)
{
    try {
        ((GameList*)handle)->finalize_processing();
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListProcess (GameListHandle handle,
                                 char* sgf, char* path, char* fn,
                                 char* dbtree, int flags,
                                 int* result)
{
    try {
        *result = ((GameList*)handle)->process(sgf, path, fn, 0, flags);
        if (*result == 0)
            return KERR;
        else
            return KOK;
    }
    CATCH_ERR_SGF
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListProcessResults (GameListHandle handle, int i, int* result)
{
    try {
        *result = ((GameList*)handle)->process_results (i);
        return KOK;
    }
    CATCH_ERR
}

// -- pattern search

KSTATUS DLLCALL GameListSearch (GameListHandle handle,
                                PatternHandle  p,
                                SearchOptionsHandle so)
{
    try {
        ((GameList*)handle)->search(*(Pattern*)p, (SearchOptions*)so);
        return KOK;
    }
    //CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListlookupLabel (GameListHandle handle, char x, char y, char* label)
{
    try {
        *label = ((GameList*)handle)->lookupLabel(x, y);
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL GameListlookupContinuation (GameListHandle handle,
                                            char x, char y,
                                            int* B, int* W, int* tB, int* tW,
                                            int* wB, int* lB, int* wW, int* lW)
{
    try {
        Continuation cont = ((GameList*)handle)->lookupContinuation(x, y);
        *B = cont.B;
        *W = cont.W;
        *tB = cont.tB;
        *tW = cont.tW;
        *wB = cont.wB;
        *lB = cont.lB;
        *wW = cont.wW;
        *lW = cont.lW;
        return KOK;
    }
    CATCH_ERR
}

// -- signature search

KSTATUS DLLCALL GameListSigSearch(GameListHandle handle, char* sig, int boardSize)
{
    try {
        ((GameList*)handle)->sigsearch(sig, boardSize);
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListGetSignature(GameListHandle handle, int i, char* sig)
{
    try {
        std::string s = ((GameList*)handle)->getSignature(i);
        ////strcpy(sig, s.c_str());
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

// -- game info search

KSTATUS DLLCALL GameListGISearch (GameListHandle handle, char* sql)
{
    try {
        ((GameList*)handle)->gisearch(sql);
        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

// -- tagging

// todo

// -- duplicates

// todo

// -- misc

KSTATUS DLLCALL GameListReset (GameListHandle handle)
{
    try {
        ((GameList*)handle)->reset();
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL GameListResetFormat (GameListHandle handle, char* orderBy, char* format)
{
    try {
        ((GameList*)handle)->resetFormat(orderBy, format);
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL GameListSize (GameListHandle handle, int* size)
{
    try {
        *size = ((GameList*)handle)->size();
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL GameListNumHits (GameListHandle handle,
                                 int* numHits, int* numSwitched,
                                 int *Bwins, int* Wwins)
{
    try {
        *numHits     = ((GameList*)handle)->numHits();
        *numSwitched = ((GameList*)handle)->num_switched;
        *Bwins       = ((GameList*)handle)->Bwins;
        *Wwins       = ((GameList*)handle)->Wwins;
        return KOK;
    }
    CATCH_ERR
}

// not implemented: resultsStr

KSTATUS DLLCALL GameListCurrentEntryAsString (GameListHandle handle,
                                              int i, int* size, char* str)
{
    try {
        std::string s = ((GameList*)handle)->currentEntryAsString(i);

        if (s.length() < *size)
            strcpy(str, s.c_str());
        else
            *size = s.length() + 1;

        return KOK;
    }
    CATCH_ERR
}

// not implemented: currentEntriesAsStrings

KSTATUS DLLCALL GameListGetSGF (GameListHandle handle, int i, int* size, char* str)
{
    try {
        std::string s = ((GameList*)handle)->getSGF(i);

        if (s.length() < *size)
            strcpy(str, s.c_str());
        else
            *size = s.length() + 1;

        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

KSTATUS DLLCALL GameListGetCurrentProperty (GameListHandle handle,
                                            int i, char* tag,
                                            int* size, char* str)
{
    try {
        std::string s = ((GameList*)handle)->getCurrentProperty(i, tag);

        if (s.length() < *size)
            strcpy(str, s.c_str());
        else
            *size = s.length() + 1;

        return KOK;
    }
    CATCH_ERR_DB
    CATCH_ERR
}

// -- list of players

KSTATUS DLLCALL GameListPlSize (GameListHandle handle, int* plSize)
{
    try {
        *plSize = ((GameList*)handle)->plSize();
        return KOK;
    }
    CATCH_ERR
}

KSTATUS DLLCALL GameListPlEntry (GameListHandle handle, int i, int* size, char* str)
{
    try {
        std::string s = ((GameList*)handle)->plEntry(i);

        if (s.length() < *size)
            strcpy(str, s.c_str());
        else
            *size = s.length() + 1;

        return KOK;
    }
    CATCH_ERR
}

} // extern "C"

int WINAPI DllEntryPoint (HINSTANCE hinst, unsigned long reason, void* lpReserved)
{
    return 1;
}

// ---------------------------------------------------------------------------
