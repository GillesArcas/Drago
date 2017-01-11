// ---------------------------------------------------------------------------
// -- Drago -- Interface to database ------------------------ UDatabase.pas --
// ---------------------------------------------------------------------------

unit UDatabase;

// ---------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes,
  TntClasses, ClassesEx,
  DefineUi, UView, UGoban, UKombilo, Main,
  UGameTree;

type
  TDBCallBack = procedure(bar, mode, n, processed : integer);
  
type
  TSearchContext = class
    // db tab
    DBTab : TTabSheetEx;
    kh : TKGameList;
    // calling tab
    CallingTab : TTabSheetEx;
    CallingView : TViewMode;
    // calling game position;
    gt : TGameTree;
    // is pattern selected from thumbnail (init as false, set latter)
    IsThumbPattern : boolean;
    // timing
    t0 : double;
  end;


procedure CreateDatabase(dbName : string; var ok : boolean);
procedure UserMainOpenDatabase(sameTab : boolean);
procedure DoMainOpenDatabase( aName : string;
                                num : integer;
                               node : string;
                            sameTab : boolean;
                             var ok : boolean);
procedure AddListToDB(view : TView; fileList : TWideStringList; DBCallBack : TDBCallBack);
procedure CurrentEntriesToCollection(view : TView; aName : string = '';
                                     aNode : string = '';
                                     aIndx : integer = 1);
procedure DoPrepareSearch(i1, j1, i2, j2 : integer);
procedure DoPatternSearch(gbSrc : TGoban;
                          kh : TKGameList;
                          i1, j1, i2, j2 : integer;
                          nextPlayer: integer;
                          msgProc : TProcString;
                          var ok : boolean);
procedure EndPatternSearch(gvSrc : TView;
                           gbSrc : TGoban;
                           i1, j1, i2, j2 : integer);
function  ListOfPlayers(kh  : TKGameList) : TStringList;
function  ActiveDBTab : TTabSheetEx;
function  ActiveDB : TKGameList;
procedure DoResetDatabase;
procedure ListOfSignatures(gl : TKGameList; list : TStringList);
function  DatabaseExists(const dbName : WideString) : boolean;
procedure DisplayContinuations(gb : TGoban; gl : TKGameList; i1, j1 : integer);
function  DbFormatNumberOfResults(n : integer; dbName : WideString) : WideString;
function  FormatTimeString(time : double) : WideString;

var
  DBSearchContext : TSearchContext;

// ---------------------------------------------------------------------------

implementation

uses
  Controls, Forms,
  StrUtils, Math,
  Define, Std, Translate, UGameColl, Sgfio, UMainUtil, WinUtils,
  UDialogs, Ugmisc, UGCom, UfmMsg, UStatus, UViewBoard,
  UfmAddToDB, UViewMain, UfmDBSearch;

// -- Kombilo format string: definition and parsing --------------------------

function KombiloFormatString : string;
begin
  Result := '[[filename]]*[[pos]]*'
end;

procedure KombiloFormatParse(s : string; var filename : string;
                             var index    : integer;
                             var hits     : string;
                             keepOnlyOneHit : boolean);
var
  i, j, p : integer;
begin
  i := Pos('*', s);
  j := PosEx('*', s, i + 1);
  if i = 0 then
    begin
      filename := s;
      index := 1;
      exit
    end;
  filename := Copy(s, 1, i - 1);
  //if j = 0
  //   then j := Length(s);
  index := StrToIntDef(Copy(s, i + 1, j - i - 1), 1);
  hits  := Copy(s, j + 1, Length(s) - j - 1);

  if keepOnlyOneHit then
    begin
      p := Pos(',', hits);
      if p > 0
        then hits := Copy(hits, 1, p - 1)
    end;

  // add 1 as Drago collections are 1-based
  inc(index)
end;

// -- Test of database existence ---------------------------------------------

function DatabaseExists(const dbName : WideString) : boolean;
begin
  Result := {Wide}FileExists(dbName) and FileExists(dbName + '1')
                                     and FileExists(dbName + '2')
end;

// -- Creation of a new database ---------------------------------------------

procedure CreateDatabase(dbName : string; var ok : boolean);
var
  dbName1, dbName2 : string;
  r, r1, r2 : boolean;
  gl : TKGameList;
  p_op : TKProcessOptions;
begin
  ok := True;

  // make names
  dbName1 := dbName + '1';
  dbName2 := dbName + '2';

  // delete previous, user is warned
  r  := (not FileExists(dbName )) or DeleteFile(dbName );
  r1 := (not FileExists(dbName1)) or DeleteFile(dbName1);
  r2 := (not FileExists(dbName2)) or DeleteFile(dbName2);

  // abort if unable to create
  if (not r) or (not r1) or (not r2) then
    begin
      if IsFileInUse(dbName)
        then MessageDialog(msOk, imExclam, [U('Unable to create database...')])
        else MessageDialog(msOk, imExclam, [U('Unable to create database...')]);
      ok := False;
      exit
    end;

  // create database
  p_op := TKProcessOptions.Create;
  if not Settings.DBCreateExtended
    then p_op.SetValue(poAlgos, ALGO_FINALPOS or ALGO_MOVELIST);

  try
    gl := TKGameList.Create(dbName, 'id', KombiloFormatString, p_op,
                            Settings.DBCache)
  except
    MessageDialog(msOk, imExclam, [U('Unable to create database...')]);
    p_op.Free;
    ok := False;
    exit
  end;

  p_op.Free;

  // mandatory (to be checked)
  gl.StartProcessing(True);
  gl.FinalizeProcessing;

  // release handle
  gl.Free;

  if Assigned(fmDBSearch)
    then fmDBSearch.ResetResultTabRef
end;

procedure UserCreateDatabase;
begin
end;

// -- Access to current database ---------------------------------------------

procedure FindDBTab(tabSrc : TTabSheetEx; var tabDB : TTabSheetEx);
begin
  if tabSrc.TabView.kh <> nil
    then tabDB := tabSrc
    else tabDB := fmMain.DBListOfTabs.Top as TTabSheetEx
end;

function ActiveDBTab : TTabSheetEx;
begin
  Result := fmMain.DBListOfTabs.Top as TTabSheetEx
end;

function ActiveDB : TKGameList;
var
  obj : TObject;
begin
  obj := fmMain.DBListOfTabs.Top;
  if obj = nil
    then Result := nil
    else Result := TTabSheetEx(obj).TabView.kh
end;

// -- Delayed access to collection from database -----------------------------
//
// cl are 1-based, kh are 0-based

type TDBDelayedAccess = class(TDelayedAccess)
  FKh : TKGameList;
  FKhIndex : integer;
  constructor Create(kh : TKGameList); overload;
  constructor Create(kh : TKGameList; khIndex : integer); overload;
  procedure DelayedAccess(clIndex : integer; ce : TCollElem); override;
end;

constructor TDBDelayedAccess.Create(kh : TKGameList);
begin
  FKh := kh;
  FKhIndex := -1
end;

constructor TDBDelayedAccess.Create(kh : TKGameList; khIndex : integer);
begin
  FKh := kh;
  FKhIndex := khIndex;
end;

procedure TDBDelayedAccess.DelayedAccess(clIndex : integer; ce : TCollElem);
var
  x : TGameTree;
  khIndex, index : integer;
  s, filename, hits : string;
begin
  if FKhIndex  < 0
    then khIndex := clIndex - 1
    else khIndex := FKhIndex;

  s := FKh.CurrentEntryAsString(khIndex);
  KombiloFormatParse(s, filename, index, hits, FKh.FKeepOnlyOneHit);

  s := FKh.GetSGF(khIndex);
  x := ReadSgfInString(s, True); // always accept long property names here

  ce.gtree    := x;
  ce.FFileName := filename;
  ce.FIndex    := index;
  ce.FHits     := hits
end;

// -- Adding a list of files to database -------------------------------------

// -- Processing flags

function ProcessingFlags(st : TStatus) : integer;
begin
  // detection of duplicates
  case st.DBDetectDuplicates of
    0 : Result := 0;
    1 : Result := CHECK_FOR_DUPLICATES;
    2 : Result := CHECK_FOR_DUPLICATES_STRICT
  end;

  // omission of duplicates
  if st.DBOmitDuplicates
    then Result := Result or OMIT_DUPLICATES;

  // omission of games with sgf errors
  if st.DBOmitSGFErrors
    then Result := Result or OMIT_GAMES_WITH_SGF_ERRORS
end;

// -- Errors messages

procedure AddToErrorList(fn : WideString; single : boolean; index, count, flag : integer);
var
  msg : string;
begin
  case flag of
    -1 :
      msg := 'Unable to process game';
    -2 :
      msg := 'Unable to process game completely';
    UNACCEPTABLE_BOARDSIZE :
      msg := 'Boardsize not handled';
    SGF_ERROR :
      msg := 'SGF error detected, game inserted';
    SGF_ERROR or NOT_INSERTED_INTO_DB :
      msg := 'SGF error detected, game not inserted';
    IS_DUPLICATE :
      msg := 'Duplicate detected';
    IS_DUPLICATE or NOT_INSERTED_INTO_DB :
      msg := 'Duplicate ignored'
  end;

  fmAddToDB.ReportError(U(msg), fn, single, index, count)
end;

// --

procedure AddListToDB(view : TView;
                      fileList : TWideStringList;
                      DBCallBack : TDBCallBack);
var
  i, k, nGames, processed, flags, r : integer;
  fn, name, path, sgf : WideString;
  cl : TGameColl;
  single : boolean;
begin
  if fileList.Count = 0
    then exit;

  // set processing flags
  flags := ProcessingFlags(Settings);

  DBCallBack(0, 0, fileList.Count, -1);

  cl := TGameColl.Create;

  view.kh.StartProcessing(Settings.DBProcessVariations);
  processed := 0;

  try
    for i := 0 to fileList.Count - 1 do
      begin
        fn   := fileList [i];
        path := ExtractFilePath(fn);
        name := ExtractFileName(fn);

        ReadSgf(cl, fn, nGames,
                Settings.LongPNames, Settings.AbortOnReadError);

        // handle Drago reading errors
        if nGames = 0 then
          begin
            AddToErrorList(fn, single, 0, 0, -1);
            Continue
          end;
        if sgfResult <> 0
          then AddToErrorList(fn, single, 0, 0, -2);

        single := cl.Count = 1;
        if single
          then DBCallBack(1, 2, 1, -1)         // just to count games
          else DBCallBack(1, 0, cl.Count, -1); // set progress bar

        for k := 1 to cl.Count do
          begin
            // get sgf string by reading from file or printing to string
            if single
              then sgf := FileToString(fn)
              else sgf := TreeToString(cl [k]);

            // process event and add it to collection or error list
            r := view.kh.Process(sgf, path, name, flags);

            // if error when parsing made by libkombilo, try parsing by Drago
            if (r = 0) and single then
              begin
                sgf := TreeToString(cl [k]);
                r := view.kh.Process(sgf, path, name, flags);
              end;

            if r = 0
              then AddToErrorList(fn, single, k, cl.Count, -1)
              else
                begin
                  r := view.kh.ProcessResults(0);

                  if (r and NOT_INSERTED_INTO_DB) = 0
                    then view.cl.AddDelayed(TDBDelayedAccess.Create(view.kh));

                  // handle libkombilo errors

                  if (r and UNACCEPTABLE_BOARDSIZE) <> 0
                    then AddToErrorList(fn, single, k, cl.Count, UNACCEPTABLE_BOARDSIZE);

                  if (r and SGF_ERROR) <> 0
                    then AddToErrorList(fn, single, k, cl.Count, SGF_ERROR or
                                            (r and NOT_INSERTED_INTO_DB));

                  if (r and IS_DUPLICATE) <> 0
                    then AddToErrorList(fn, single, k, cl.Count, IS_DUPLICATE or
                                            (r and NOT_INSERTED_INTO_DB))
                end;

            // update progress status
            inc(processed);
            if cl.Count > 1
              then DBCallBack(1, 1, k-1, processed);

            // test escape key
            if fmAddToDB.Abort
              then exit
          end;

        DBCallBack(0, 1, i+1, processed)
      end
  finally
    view.kh.FinalizeProcessing;
    cl.Free
  end
end;

// -- List of signatures in DB -----------------------------------------------

procedure ListOfSignatures(gl : TKGameList; list : TStringList);
var
  i : integer;
begin
  for i := 0 to gl.Size do
    list.Add(gl.GetSignature(i))
end;

// -- Loading of results into Drago structures -------------------------------

procedure CurrentEntriesToCollection0(view : TViewBoard);
var
  x : TGameColl;
  i, nReadGames, index : integer;
  s, currentReadGame, filename, hits : string;
begin
  view.cl.Clear;

  x := TGameColl.Create;
  currentReadGame := '';

  for i := 0 to view.kh.Size - 1 do
    begin
      s := view.kh.CurrentEntryAsString(i);
      //KombiloFormatParse(s, filename, index, hits);

      if filename <> currentReadGame then
        begin
          ReadSgf(x, filename, nReadGames,
                  Settings.LongPNames, Settings.AbortOnReadError);
          currentReadGame := filename
        end;

      view.cl.Add(x [index], filename, index);
      // avoid freeing games in cl
      x [index] := nil;
    end;

  x.Free
end;

procedure CurrentEntriesToCollection(view : TView;
                                    aName : string = '';
                                    aNode : string = '';
                                    aIndx : integer = 1);
var
  x : TGameTree;
  i, index : integer;
  s, filename : string;
begin
  view.cl.Clear;

  for i := 0 to view.kh.Size - 1 do
  //for i := 0 to min(10, view.kh.Size) - 1 do
    begin
      {$if 1=0}
      s := view.kh.CurrentEntryAsString(i);
      KombiloFormatParse(s, filename, index);

      s := view.kh.GetSGF(i);
      x := ReadSgfInString(s);

      view.cl.Add(x, filename, index);
      x := nil;
      {$else}
      view.cl.AddDelayed(TDBDelayedAccess.Create(view.kh))
      {$ifend}
    end;

  with view do
    begin
      // update game instance
      si.ParentView := view;
      if aName <> ''
        then si.DatabaseName := aName;
      si.FolderName := '';
      si.IndexTree := EnsureRange(aIndx, 1, cl.Count);
      if cl.Count > 0
        then si.FileName := cl.FileName[si.IndexTree]
        else si.FileName := '';
      si.FileSave  := True;
      //si.ReadOnly  := False;
      UpdatePlayer(Black);
      si.MainMode  := muNavigation;

      // bind gt
      if cl.Count > 0
        then gt := cl[si.IndexTree]
        else gt := nil;

      // start
      if cl.Count > 0
        then StartEvent(seMain, snStrict, aNode)
    end
end;

// -- Reset of database ------------------------------------------------------

procedure DoResetDatabase;
var
  activeViewBak : TViewMain;
begin
  if Assigned(DBSearchContext) then
    with DBSearchContext do
      if (DBTab = nil) or (not fmMain.DBListOfTabs.Registered(DBTab))
                       or (not TKGameList.Registered(kh))
        then // nop
        else
          begin
            kh.Reset;
            CurrentEntriesToCollection(DBTab.ViewBoard);
            fmMain.InvalidateView(DBTab, vmAll);

            // SelectView may lose the view, so save and restore
            activeViewBak := fmMain.ActiveView;
            fmMain.SelectView(DBTab, vmInfo);
            fmMain.ActiveView := activeViewBak
          end;

  if Assigned(fmDBSearch)
    then fmDBSearch.ResetResultTabRef;

  if Assigned(fmDBSearch)
    then fmDBSearch.cbSearchIn.ItemIndex := 0
end;

// -- Opening of database ----------------------------------------------------

procedure TerminateOpenDatabase(tab : TTabSheetEx;
                               view : TViewMain;
                                 kh : TKGameList;
                              aName : string;
                                num : integer;
                               node : string); forward;

// -- Opening entry point

procedure DoMainOpenDatabase( aName : string;
                                num : integer;
                               node : string;
                            sameTab : boolean; // not implemented
                             var ok : boolean);
var
  kh : TKGameList;
  n : integer;
  modified : boolean;
  d1, d2, d3 : double;
begin
  // test if already open
  n := IsOpenInTab('', aName, modified);
  if n >= 0 then
    begin
      fmMain.ActivePageIndex := n;
      ok := True;
      exit
    end;

  // test existence
  if not DatabaseExists(aName) then
    begin
      HandleOpenErrorMessage([U('Error opening database') + ' ' + aName]);
      ok := False;
      exit
    end;

  // create tab
  try
    LockMainWindow(True);
    fmMain.CreateTab(ok);
    Application.ProcessMessages;
  finally
    LockMainWindow(False)
  end;
  if not ok
    then exit;

  // open
  try
    Screen.Cursor := fmMain.WaitCursor;
    d1 := Now;
    kh := TKGameList.Create(aName, 'id', KombiloFormatString, nil,
                            Settings.DBCache);
    d2 := Now;
    //Screen.Cursor := crDefault;
    TerminateOpenDatabase(fmMain.ActivePage,
                          fmMain.ActiveView, kh, aName, num, node)
    ;d3 := Now;
    //fmMain.Caption := Format('%f %f %f %f %f', [d1, d2, d3, d2 - d1, d3 - d2]);
  except
    HandleOpenErrorMessage([U('Error opening database') + ' ' + aName]);
    ok := False
  end;
  Screen.Cursor := crDefault;
end;

procedure TerminateOpenDatabase(tab : TTabSheetEx;
                               view : TViewMain;
                                 kh : TKGameList;
                              aName : string;
                                num : integer;
                               node : string);
begin
  view.kh := kh;
  kh.FKeepOnlyOneHit := True;

  // read
  CurrentEntriesToCollection(view, aName, node, num);

  SetTabIcon(tab, view, mdEdit);
  fmMain.SelectView(tab, vmInfo);

  // update list of DB tabs
  if tab.TabView.kh <> nil
    then fmMain.DBListOfTabs.Push(tab);

  if Assigned(fmDBSearch)
    then fmDBSearch.ResetResultTabRef
end;

// -- Open database user command

procedure UserMainOpenDatabase(sameTab : boolean);
var
  cancel, ok : boolean;
  filename : WideString;
begin
  ok := OpenDialog('Open database',
                   ExtractFilePath(Status.DBOpenFolder), '', 'db',
                   U('Database files') + ' (*.db)|*.db|',
                   filename);

  if not ok
    then exit;

  // protect against clicking on goban during loading
  Status.EnableGobanMouseDn := False;

  DoMainOpenDatabase(filename, 1, '', sameTab, ok);
  Status.DBOpenFolder := ExtractFilePath(filename);

  // process possible clicks on goban in protected context
  Application.ProcessMessages;

  // restore
  Status.EnableGobanMouseDn := True
end;

// -- Pattern search ---------------------------------------------------------

// -- Entering in pattern search mode

procedure DoPrepareSearch(i1, j1, i2, j2 : integer);
begin
  // capture thumbnail image
  if Assigned(fmDBSearch)
    then fmDBSearch.Snapshot(i1, j1, i2, j2)
end;

// -- Kombilo search rectangle strategy

procedure FindSearchRectangle(gb : TGoban; var patternType, i1, j1, i2, j2 : integer);
begin
  if (i1 = 1) and (j1 = 1) and (i2 = gb.BoardSize) and (j2 = gb.BoardSize)
    then patternType := FULLBOARD_PATTERN
  else if ((i1 = 1) and (j1 = 1)) or
          ((i1 = 1) and (j2 = gb.BoardSize)) or
          ((i2 = gb.BoardSize) and (j1 = 1)) or
          ((i2 = gb.BoardSize) and (j2 = gb.BoardSize)) or // corner
          Settings.DBFixedPos                              // or fixedAnchor
    then                                             // so no translation occurs
      begin
        j2 := j1;
        i2 := i1;
        patternType := -1
      end
  else if i1 = 1
    then patternType := SIDE_N_PATTERN  // translation along the edge only
  else if i2 = gb.BoardSize
    then patternType := SIDE_S_PATTERN
  else if j1 = 1
    then patternType := SIDE_W_PATTERN
  else if j2 = gb.BoardSize
    then patternType := SIDE_E_PATTERN
  else
    patternType := CENTER_PATTERN
end;

// -- Construction of the pattern string

function GetPatternString(gb : TGoban; i1, j1, i2, j2 : integer) : string;
var
  i, j : integer;
begin
  Result := '';

  for i := i1 to i2 do
    for j := j1 to j2 do
      case gb.Board [i, j] of
        Black : Result := Result + iff(gb.IsWildcard(i, j), 'x', 'X');
        White : Result := Result + iff(gb.IsWildcard(i, j), 'o', 'O');
        else    Result := Result + iff(gb.IsWildcard(i, j), '*', '.');
      end
end;

// -- Filter for pathological patterns (0 and 1 stones are not handled)

// not used
function AllowedPattern(s : string; patternType : integer) : integer;
var
  i, n : integer;
begin
  if patternType <> CENTER_PATTERN
    then Result := 1000
    else
      begin
        n := 0;
        for i := 1 to Length(s) do
          if s [i] in ['O', 'X']
            then inc(n);
        Result := n
      end
end;

function NbStonesInPattern(const s : string) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
    if s[i] in ['O', 'X']
      then inc(Result)
end;

// -- Searching

procedure DoPatternSearch(gbSrc : TGoban;
                          kh : TKGameList;
                          i1, j1, i2, j2 : integer;
                          nextPlayer: integer;
                          msgProc : TProcString;
                          var ok : boolean);
var
  patternType, w, h, n, nextMove : integer;
  pattern : string;
  pat : TKPattern;
  so : TKSearchOptions;
begin
  if gbSrc.FLastRect.Top < 0 then
    begin
      msgProc(U('No search rectangle defined.'));
      ok := False;
      exit;
    end;

  // make pattern string
  pattern := GetPatternString(gbSrc, i1, j1, i2, j2);

  // set dim and anchors
  w := j2 - j1 + 1;
  h := i2 - i1 + 1;
  FindSearchRectangle(gbSrc, patternType, i1, j1, i2, j2);

  // filter pathological patterns (center empty or single stone patterns)
  if patternType <> CENTER_PATTERN
    then ok := True
    else
      begin
        n := NbStonesInPattern(pattern);
        ok := n > 1;
        case n of
          0 : msgProc(U('No search for center empty patterns.'));
          1 : msgProc(U('No search for center single stone patterns.'));
        end
      end;
  if not ok
    then exit;

  // conversion from value handled by Drago (both = 3) to value handled by
  // libkombilo (both = 0)
  case Settings.DBNextMove of
    Black : nextMove := Black;
    White : nextMove := White;
    pcBoth  : nextMove := 0;
    pcAlternate : nextMove := nextPlayer
  end;

  // prepare search
  so := TKSearchOptions.Create(Settings.DBFixedColor,
                               nextMove,
                               Settings.DBMoveLimit);
  so.SetValue(soSearchInVariations, iff(Settings.DBSearchVariations, 1, 0));

  if patternType >= 0
    then pat := TKPattern.Create(patternType,    gbSrc.BoardSize, w, h, pattern)
    else pat := TKPattern.Create(j1, j1, i1, i1, gbSrc.BoardSize, w, h, pattern);

  // search and make game list
  kh.Continuations.Clear; // todo : check
  kh.Search(pat, so);
  pat.Free;
  so.Free;
end;

// -- Display of continuations on board

procedure DisplayContinuations(gb : TGoban; gl : TKGameList; i1, j1 : integer);
var
  k, nB, nW, color : integer;
begin
  for k := 0 to gl.Continuations.Count - 1 do
    with TKContinuation(gl.Continuations.Items [k]) do
      begin
        nB := B; // number of Black continuations
        nW := W; // number of White continuations
        if nB = 0
          then color := $FFFFFF // white
          else
            if nW = 0
              then color := $000000  // black
              else color := $808080; // grey

        gb.ShowTempMark(i1 + i, j1 + j, mrkTxt, labl, color)
      end
end;

// -- Display of pattern search results

procedure EndPatternSearch(gvSrc : TView;
                           gbSrc : TGoban;
                           i1, j1, i2, j2 : integer);
var
  kh : TKGameList;
begin
  // set working data
  kh := DBSearchContext.kh;

  // compute list of continuations
  kh.SortContinuations(Settings.DBNextMove);

  // remove possible wildcard property(entered by user)
  // gvSrc.gt can be nil if position selected in DB tab and no solution
(*
  if gvSrc.gt <> nil
    then gvSrc.gt.RemProp(pr_W);
*)    
(*
  // set labels on thumbnail
  DisplayContinuations(gbSrc, kh, i1, j1);
*)
  // exit if main board not concerned
  with DBSearchContext do
    if //DB// (DBTab = CallingTab) or
       (CallingTab <> fmMain.ActivePage) or
       IsThumbPattern
      then exit;

  // set labels on board if required
  if VarMarkup(gvSrc.si) = vmGhost
    then gvSrc.ShowNextOrVars(Enter);
  DisplayContinuations(gvSrc.gb, kh, i1, j1);
  with gvSrc.gb do
    Rectangle(FLastRect.Top, FLastRect.Left, FLastRect.Bottom, FLastRect.Right, True)
end;

// ---------------------------------------------------------------------------

function ListOfPlayers(kh  : TKGameList) : TStringList;
var
  i : integer;
begin
  Result := TStringList.Create;

  for i := 0 to kh.PlSize do
    Result.Add(kh.PlEntry(i));
end;

function DbFormatNumberOfResults(n : integer; dbName : WideString) : WideString;
begin
  case n of
    0 : Result := WideFormat(U('No game found in %s'), [dbName]);
    1 : Result := WideFormat(U('1 game found in %s'), [dbName]);
    else
      Result := WideFormat(U('%d games found in %s'), [n, dbName]);
  end
end;

function FormatTimeString(time : double) : WideString;
var
  x : integer;
begin
  x := Round(time);

  if x < 1000
    then Result := WideFormat(U('%d ms.'), [x])
    else
      if x < 60000
        then Result := WideFormat(U('%2.2f seconds'), [x / 1000])
        else Result := ElapsedTimeToStr(time)
end;

// ---------------------------------------------------------------------------

end.
