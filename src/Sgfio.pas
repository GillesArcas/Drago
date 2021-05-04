// ---------------------------------------------------------------------------
// -- Drago -- Reading and printing ----------------------------- Sgfio.pas --
// ---------------------------------------------------------------------------

unit Sgfio;

// ---------------------------------------------------------------------------

interface

uses
  Classes,
  UGameTree, UGameColl;

// Saving modes
type
  TSgfSaveMode = (ioRewrite, ioAppend);

// File errors
const
  ioErrorOk           =  0;
  ioNotOpen           =  1;
  ioFirstGameNotFound =  2;
  ioSemiNotFound      =  3;
  ioIllegalChar       =  4;
  ioAlloc             =  5;
  ioPropName          =  6;
  ioBracketNotFound   =  7;
  ioErrorReadOnly     =  8;
  ioUnexpectedEof     =  9;
  ioNotSaved          = 10;

  ioErrorMsg : array[0 .. 10] of string = (
    'Ok',
    'File not open',
    'First game not found',
    'Semicolon not found after parenthesis',
    'Illegal character',
    'Memory error',
    'Invalid property name',
    'Bracket not found',
    'Read only file',
    'Unexpected end of file',
    'File not saved');

var
  sgfResult : integer;
  sgfLog    : TStringList;
  LineNumber: integer; // error line

procedure ReadSgf(cl : TGameColl;
                  const name : WideString;
                  var nGames : integer;
                  acceptLongPropertyNames : boolean;
                  abortOnError : boolean;
                  avoidMoveAtRoot : boolean = True);
procedure ReadSgfAppend(cl : TGameColl;
                        const name : WideString;
                        var nGames : integer;
                        acceptLongPropertyNames : boolean;
                        abortOnError : boolean;
                        avoidMoveAtRoot : boolean = True);
procedure ReadSgfFolder(cl : TGameColl;
                        const path : WideString;
                        const filter : string;
                        aLongPNames : boolean;
                        abordOnReadError : boolean;
                        avoidMoveAtRoot : boolean = True;
                        subFolders : boolean = False);
function  ReadSgfInString(const s : string;
                          aLongPNames : boolean = True;
                          abortOnReadError : boolean = False) : TGameTree;
procedure PrintSGF(cl : TGameColl;
                   name : string;
                   mode : TSgfSaveMode;
                   aCompressList : boolean;
                   aSaveCompact  : boolean;
                   matchFileName  : boolean = False); overload;
procedure PrintSGF(cl : TGameColl;
                   name : WideString;
                   mode : TSgfSaveMode;
                   aCompressList : boolean;
                   aSaveCompact  : boolean;
                   matchFileName : boolean = False); overload;

procedure PrintWholeTree(name : WideString; gt : TGameTree;
                         aCompressList : boolean;
                         aSaveCompact  : boolean);
procedure PrintCurrentTree(name : string; gt : TGameTree);
function  PrintTreeInString(gt : TGameTree) : string;
function  TreeToString(gt : TGameTree) : string;
function NodeToString(x : TGameTree) : string;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, SysUtilsEx, ClassesEx,
  Std, WinUtils, UnicodeUtils, Ux2y, Properties;

// == Reading of SGF format ==================================================

// -- Forwards ---------------------------------------------------------------

//function  OpenSgf(name : string) : boolean; forward;
procedure CloseSgf; forward;
function  ReadList(var x : TGameTree) : boolean; forward;

// -- Settings ---------------------------------------------------------------

var
  StrictChecking : boolean;
  AcceptLongPropNames : boolean;

// -- Error function ---------------------------------------------------------

function ReadError(n : integer) : TGameTree;
begin
  sgfResult := n;
  Result := nil;
  Abort
end;

// -- Handling of the character stream ---------------------------------------

var
  InputText : PChar;
  InputPtr  : PChar;

function OpenSgf(const name : WideString) : boolean;
var
  f : integer;
  n : integer;
begin
  Result     := False;
  LineNumber := 0;
  InputText  := nil;

  // does not read on input
  if name = ''
    then exit;

  // open file (fmShareDenyNone required for opening from IE)
  f := WideFileOpen(name, fmOpenRead or fmShareDenyNone);

  // return if file not open
  if f < 0
    then exit;

  // get size by setting position at end of file
  n := FileSeek(f, 0, 2);

  // allocation is not tested
  GetMem(InputText, n + 1);

  FileSeek(f, 0, 0);
  n := FileRead(f, InputText^, n);

  // reading problem
  //if IoResult <> 0
  //  then exit;

  FileClose(f);

  InputText[n] := ^Z;
  InputPtr := InputText;
  LineNumber := 1;
  Result := True
end;

function OpenSgfString(const s : string) : boolean;
var
  n, i : integer;
  p : PChar;
begin
  Result     := False;
  LineNumber := 0;
  InputText  := nil;

  n := Length(s);
  p := PChar(s);

  // allocation is not tested
  GetMem(InputText, n + 1);

  // 1. by hand
  //for i := 0 to n - 1 do
  //  InputText[i] := p[i]; //s[i + 1];

  // 2. crash when freeing ...
  //System.Move(Pointer(p), Pointer(InputText), n);

  // 3. this one seems ok
  StrLCopy(InputText, p, n);

  InputText[n] := ^Z;

  InputPtr := InputText;
  LineNumber := 1;
  Result := True
end;

procedure CloseSgf;
begin
  FreeMem(InputText)
end;

procedure ReadChar(var c : char);
begin
  repeat
    c := InputPtr^;
    inc(InputPtr);
    if c = #10
      then inc(LineNumber);
    if c in [#10, #13, #9]
      then c := ' '
  until (c >= ' ') or (c = ^Z)
end;

procedure UnReadChar;
begin
  dec(InputPtr)
end;

procedure FindChar(var c : char; x : char);
begin
  repeat
    ReadChar(c)
  until (c = ^Z) or (c = x)
end;

procedure FindValidChar(var c : char);
begin
  repeat
    ReadChar(c)
  until (c = ^Z) or (c > ' ')
end;

// -- Reading of property lists ----------------------------------------------

const
  kStrBufferSize = 65536; // 64k

var
  strBuffer : PChar;

// -- Read a property name
//
// c is the first char of property name
// read pointer on next char
// returns the normalized form with two characters.
// if not found, returns empty string or trigger exception

procedure GetPn(var pn : ShortString; c : char);
begin
  pn := '';

  repeat
    if IsMaj(c)
      then pn := pn + c                         // trunc if overflow
      else
        if IsMin(c)
          then // nop                           // ignore lowercase
          else
            if StrictChecking
              then ReadError(ioIllegalChar)     // illegal character
              else exit;                        // return empty property name

    c := inputPtr^;
    if c = #10
      then inc(LineNumber);
    if (c <= ' ') or (c in [';', '(', ')', '['])
      then break;
    inc(inputPtr)
  until False
end;

// -- Read a property value
//
// Note: A property value can be empty.

function GetPv : PChar;
var
  p : PChar;
  c : char;
begin
  p := inputPtr - 1;
  repeat
    c := inputPtr^;
    case c of
      #10 : inc(LineNumber);
      ^Z  : ReadError(ioBracketNotFound);              //  ']' not found
      '\' :
         begin
           inc(inputPtr);                    // Ignore slashed character
           if inputPtr^ = #10
             then inc(LineNumber)
         end
      end;
    inc(inputPtr);
  until c = ']';

  if (inputPtr - p) < kStrBufferSize
    then StrLCopy(strBuffer, p, inputPtr - p)
    else
      begin
        StrLCopy(strBuffer, p, kStrBufferSize - 2);          // Trunc pv
        strBuffer[kStrBufferSize - 2] := ']';
        strBuffer[kStrBufferSize - 1] := #0
      end;
  Result := strBuffer
end;

// -- Read a property

procedure GetProp(var c : char; var pn : shortstring; var pvs : string);
var
  pv : string;
begin
  pvs := '';

  // get valid property name
  repeat
    GetPn(pn, c);
    if pn = '' then
      begin
        FindValidChar(c);
        if c in [';', '(', ')', '[']
          then
            begin
              UnReadChar;
              exit
            end
      end
  until pn <> '';

  // get property values
  repeat
    FindValidChar(c);
    if c <> '['
      then break;
    pv := GetPv;
    pvs := pvs + pv
  until False;

  if c > ' '
    then UnReadChar
end;

// -- Read a list of properties
//
// Note: A property list can be empty.

procedure GetNode(node : TGameTree);
var
  pn : shortstring;
  pv : string;
  c : char;
begin
  repeat
    FindValidChar(c);
    case c of
      ^Z, '(', ')', ';' :
        break;
      '[' :
        if StrictChecking
          then ReadError(ioIllegalChar)          // launch error
          else // nop                            // ignore
      else
        begin
          GetProp(c, pn, pv);

          if pn = '' then
            if StrictChecking
              then ReadError(ioPropName)         // launch error
              else ; // nop                      // return empty property name

          if pv <> ''
            then node.AddProp(PropertyIndex(pn), pv) // accept empty value
        end
    end
  until False;

  if c > ' '
    then UnReadChar
end;

// -- Read game tree ---------------------------------------------------------

// Forwards

function ReadVar1  : TGameTree; forward;
function ReadVar   : TGameTree; forward;
function ReadTree2 : TGameTree; forward;
function ReadTree1 : TGameTree; forward;
function ReadTree  : TGameTree; forward;

// -- Read node after semicolon

function ReadNode : TGameTree;
var
  x : TGameTree;
begin
  x := TGameTree.Create;

  if x = nil
    then Result := ReadError(ioAlloc)        // error allocating node
    else
      try
        GetNode(x);
        Result := x;
      except
        Result := nil;
        x.Free
      end
end;

// -- Read variations after first variation

function ReadVar1 : TGameTree;
var
  c : char;
begin
  FindValidChar(c);

  case c of
    ')': Result := nil;
    '(': Result := ReadVar;
    ^Z : Result := ReadError(ioUnexpectedEof)
    else Result := ReadError(ioIllegalChar)
  end
end;

// -- Read variation after first parenthesis

function ReadVar : TGameTree;
var
  x, y : TGameTree;
begin
  x := ReadTree;
  if x = nil                                            // empty variation
    then Result := ReadVar1
    else
      begin
        try
          y := ReadVar1;
        except
          x.FreeGameTree;
          raise
        end;
        x.LinkVar(y);
        Result := x
      end
end;

// -- Read list after first node

function ReadTree2 : TGameTree;
var
  c : char;
begin
  FindValidChar(c);

  case c of
    ')': Result := nil;
    ';': Result := ReadTree1;
    '(': Result := ReadVar;
    ^Z : Result := ReadError(ioUnexpectedEof)
    else Result := ReadError(ioIllegalChar)
  end
end;

// -- Read list after first ";"

function ReadTree1 : TGameTree;
var
  x, y : TGameTree;
begin
  x := ReadNode;
  try
    y := ReadTree2;
  except
    x.FreeGameTree;
    raise
  end;
  x.LinkNode(y);
  Result := x
end;

// -- Read list after first parenthesis

function ReadTree : TGameTree;
var
  c : char;
begin
  FindValidChar(c);
  if c = ')'
    then Result := nil
    else
      if c = ';'
        then Result := ReadTree1
        else
          if False
            then Result := ReadError(ioSemiNotFound) // no ';' after '('
            else
              begin
                UnReadChar;
                Result := ReadTree1
              end
end;

// -- Read list

// Ignore all before first parenthesis

function ReadListV1 : TGameTree;
var
  c : char;
begin
  FindChar(c, '(');
  if c = ^Z
    then Result := nil
    else Result := ReadTree.Root
end;

// Ignore all before first parenthesis followed by ; or )

function ReadList(var x : TGameTree) : boolean;
var
  c : char;
  y : TGameTree;
begin
  Result := False;
  repeat
    FindChar(c, '(');
    if c = ^Z
      then exit;
    FindValidChar(c)
  until (c = ';') or (c = ')');

  Result := True;
  if c = ')'
    then x := nil
    else
      begin
        y := ReadTree1;
        if y = nil
          then x := nil
          else x := y.Root
      end
  (*
  if c = ')'
    then x := nil
    else
      try
        x := ReadTree1.Root
      except
        if SgfResult in [ioSemiNotFound, ioIllegalChar,
                             ioPropName, ioBracketNotFound]
          then x := nil
          else raise
      end
  *)
end;

// -- Read file

procedure ReadSgf(cl : TGameColl;
                  const name : WideString;
                  var nGames : integer;
                  acceptLongPropertyNames : boolean;
                  abortOnError : boolean;
                  avoidMoveAtRoot : boolean = True);
var
  x : TGameTree;
begin
  AcceptLongPropNames := acceptLongPropertyNames;
  StrictChecking := abortOnError;

  //MilliTimer;
  sgfResult := 0;                              // Anticipate result
  nGames    := 0;
  SgfLog.Clear;

  try
    try
      if not OpenSgf(name)
        then ReadError(ioNotOpen);             // Error when opening

      if not ReadList(x)                       // Read 1st game
        then ReadError(ioFirstGameNotFound);   // 1st game not found

      cl.Clear;                                // 1st game ok, free

      repeat
        if x = nil
          then x := TGameTree.Create
          else
            if avoidMoveAtRoot and x.HasMove
              then x := NormalizeMovesAtRoot(x);
              
        inc(nGames);
        cl.Add(x);
        cl.FileName[cl.Count] := name;
        cl.Index[cl.Count] := cl.Count
      until not ReadList(x)                    // read following games
    except
      on EAbort do
    end;
  finally
    CloseSgf;
    if ioResult <> 0
      then // error already handled
  end
end;

// -- Read folder ------------------------------------------------------------

procedure ReadSgfAppend(cl : TGameColl;
                        const name : WideString;
                        var nGames : integer;
                        acceptLongPropertyNames : boolean;
                        abortOnError : boolean;
                        avoidMoveAtRoot : boolean = True);
var
  x : TGameColl;
  j : integer;
begin
  // alloc working game collection
  x := TGameColl.Create;

  try
    // read file
    ReadSgf(x, name, nGames, acceptLongPropertyNames, abortOnError, avoidMoveAtRoot);
    if nGames = 0
      then exit;

    // append file
    for j := 1 to x.Count do
      begin
        cl.Add(x[j]);
        x[j] := nil;
        cl.FileName[cl.Count] := name;
        cl.Index[cl.Count] := j
      end;
  finally
    x.Free
  end
end;

procedure ReadSgfFolder(cl : TGameColl;
                        const path : WideString;
                        const filter : string;
                        aLongPNames : boolean;
                        abordOnReadError : boolean;
                        avoidMoveAtRoot : boolean = True;
                        subFolders : boolean = False);
var
  list : TWideStringList;
  i, nReadGames : integer;
begin
  // set folder name in collection, empty if collection read from single file
  cl.Folder := path;

  // alloc and load list of file names
  list := TWideStringList.Create;
  if not subFolders
    then WideAddFilesToList(list, path, [afIncludeFiles, afCatPath], filter)
    else WideAddFolderToList(list, path, filter, True);

  // scan files
  for i := 0 to list.Count - 1 do
    ReadSgfAppend(cl, list[i], nReadGames, aLongPNames, abordOnReadError, avoidMoveAtRoot);

  // free working data
  list.Free;
end;

// -- Reading in string ------------------------------------------------------

function  ReadSgfInString(const s : string;
                          aLongPNames : boolean = True;
                          abortOnReadError : boolean = False) : TGameTree;
var
  x : TGameTree;
begin
  AcceptLongPropNames := aLongPNames;
  StrictChecking := abortOnReadError;

  if not OpenSgfString(s)
    then Result := nil
    else
      try
        if not ReadList(x)
          then Result := nil
          else Result := x;
        CloseSgf
      except
        Result := nil
      end;

  if (Result = nil) or Result.HasMove then
    begin
      x := TGameTree.Create;
      x.LinkNode(Result);
      Result := x
    end
end;

// == Printing of SGF format =================================================

// -- Local copy of settings -------------------------------------------------

var
  CompressList : boolean;
  SaveCompact  : boolean;
  NumPrintedProp : integer;

// -- Conversion to string ---------------------------------------------------

// Formatting property values to avoid long lines

function FormatProperty(const pn, pv : string; maxLen : integer) : string;
var
  x, line : string;
  k : integer;
begin
  if Length(pv) <= maxLen
    then Result := pn+pv
    else
      begin
        Result := '';
        line := ''; //pn;
        k := 1;
        x := nthpv(pv, k);

        while x <> '' do
          begin
            if Length(line) + Length(x) <= maxLen
              then line := line + x
              else
                if line = ''
                  then
                    begin
                      if Result = ''
                        then Result := x
                        else Result := Result + CRLF + x
                    end
                  else
                    begin
                      if Result = ''
                        then Result := line
                        else Result := Result + CRLF + line;
                      line := x
                    end;

            inc(k);
            x := nthpv(pv, k)
          end;

        if line = ''
          then Result := pn + Result
          else Result := pn + Result + CRLF + line
      end
end;

// Single property to string

function PropToString(x : TGameTree; i : integer) : string;
var
  pr : TPropId;
  pv : string;
begin
  x.NthProp(i, pr, pv, False);

  if pr in RuntimeProps
    then Result := '' // nop, reserved Drago runtime
    else
      begin
        if CanBeCompressed(pr)
          then
            if CompressList
              then
                if Pos(':', pv) > 0
                  then // nop, assumed already compressed
                  else pv := list2clist(pv)
              else
                pv := clist2list(pv);

        Result := FormatProperty(PropertyName(pr), pv, 65)
      end
end;

// Node to string

function NodeToString(x : TGameTree) : string;
var
  i : integer;
begin
  Result := ';';

  for i := 1 to x.PropNumber do
    Result := Result + PropToString(x, i)
end;

// -- Printing ---------------------------------------------------------------

// Note: using TFileStream or handle functions  (FileCreate, FileWrite) gives
// the same timing ... 3 times slower than TextFile. The difficulty is that
// TFileStream or handle functions support Unicode filenames but TextFile
// does not.

// Print one property

procedure PrintProp(var f : text; x : TGameTree; i : integer);
begin
  write(f, PropToString(x, i))
end;

// Print node one property per line

procedure PrintNodeRaw_V1(var f : text; x : TGameTree);
var
  n, i : integer;
begin
  write(f, ';');
  n := x.PropNumber;
  for i := 1 to n do
    begin
      PrintProp(f, x, i);
      writeln(f)
    end
end;

function PrintNodeRawToString(x : TGameTree) : string;
var
  i : integer;
  lineBreak : string;
begin
  lineBreak := AdjustLineBreaks(#13#10);
  Result := ';';

  for i := 1 to x.PropNumber do
    Result := Result + PropToString(x, i) + lineBreak
end;

procedure PrintNodeRaw(var f : text; x : TGameTree);
begin
  write(f, PrintNodeRawToString(x))
end;

// Print node with several moves per line

procedure PrintNodeCompact_V1(var f : text; x : TGameTree);
var
  i, n : integer;
  pr : TPropId;
  pv : string;
begin
  n := x.PropNumber;
  if (n = 1) and x.HasMove
    then
      begin
        if {(NumPrintedProp = 0) or} (NumPrintedProp = 10) then
          begin
            writeln(f);
            NumPrintedProp := 0
          end;
        x.NthProp(1, pr, pv, False);
        write(f, ';', PropertyName(pr), pv);
        inc(numPrintedProp)
      end
    else
      begin
        if NumPrintedProp > 0
          then writeln(f);
        write(f, ';');
        for i := 1 to n do
          PrintProp(f, x, i);
        //writeln(f);
        NumPrintedProp := 0
      end
end;

function PrintNodeCompactToString(x : TGameTree) : string;
var
  i, n : integer;
  pr : TPropId;
  pv : string;
  lineBreak : string;
begin
  lineBreak := AdjustLineBreaks(#13#10);
  Result := '';

  n := x.PropNumber;
  if (n = 1) and x.HasMove
    then
      begin
        if {(NumPrintedProp = 0) or} (NumPrintedProp = 10) then
          begin
            Result := Result + lineBreak;
            NumPrintedProp := 0
          end;
        x.NthProp(1, pr, pv, False);
        Result := Result + ';' + PropertyName(pr) + pv;
        inc(numPrintedProp)
      end
    else
      begin
        if NumPrintedProp > 0
          then Result := Result + lineBreak;
        Result := Result + ';';
        for i := 1 to n do
          Result := Result + PropToString(x, i);
        //Result := Result + lineBreak;
        NumPrintedProp := 0
      end
end;

procedure PrintNodeCompact(var f : text; x : TGameTree);
begin
  write(f, PrintNodeCompactToString(x))
end;

// Print node

procedure PrintNode(var f : text; x : TGameTree);
begin
  if saveCompact
    then PrintNodeCompact(f, x)
    else PrintNodeRaw    (f, x)
end;

procedure PrintTree1(var f : text; x : TGameTree);
begin
  if x = nil
    then // nop
    else
      if x.NextVar = nil
        then
          begin
            PrintNode (f, x);
            PrintTree1(f, x.NextNode)
          end
        else
          repeat
            //if NumPrintedProp > 0
            //   then writeln(f);
            NumPrintedProp := 0;
            writeln(f);
            write(f, '(');
            PrintNode (f, x);
            PrintTree1(f, x.NextNode);
            //if NumPrintedProp > 0
            //   then writeln(f);
            //NumPrintedProp := 0;
            write(f, ')');
            x := x.NextVar
          until x = nil
end;

procedure PrintTree(var f : text; x : TGameTree);
begin
  write(f, '(');
  NumPrintedProp := 0;
  PrintTree1(f, x);
  writeln(f, ')')
end;

// -- Skip dummy first node

procedure PrintOne(var f : text; x : TGameTree);
begin
  //writeln(f, TreeToString(x));
  //exit;
  x := x.Root;
  if x.PropNumber = 0
    then PrintTree(f, x.NextNode)
    else PrintTree(f, x)
end;

// -- API --------------------------------------------------------------------

// Print complete collection

procedure PrintSGF(cl : TGameColl;
                   name : string;
                   mode : TSgfSaveMode;
                   aCompressList : boolean;
                   aSaveCompact  : boolean;
                   matchFileName : boolean = False);
// mode = ioRewrite or ioAppend
var
  f : text;
  i : integer;
begin
  CompressList := aCompressList;
  SaveCompact  := aSaveCompact;

  sgfResult := ioErrorOk;
  if FileExists(name) and ((FileGetAttr(name) and faReadOnly) <> 0) then
    begin
      sgfResult := ioErrorReadOnly;
      exit
    end;

  assign(f, name);
  if (mode = ioRewrite) or not FileExists(name)
    then rewrite(f)
    else append(f);
  for i := 1 to cl.Count do
    if (not matchFileName) or (name = cl.Filename[i])
      then PrintOne(f, cl[i]);
  close(f);
end;

// Print single tree from root

procedure PrintWholeTree(name : WideString;
                         gt : TGameTree;
                         aCompressList : boolean;
                         aSaveCompact  : boolean);
var
  f : text;
  nameArg : WideString;
begin
  CompressList := aCompressList;
  SaveCompact := aSaveCompact;
  nameArg := name;

  if not IsAnsiString(nameArg)
    then name := DragoTempPath + 'tmp.sgf';

  assign(f, name);
  rewrite(f);
  PrintOne(f, gt.Root);
  close(f);

  if not IsAnsiString(nameArg)
    then
      if not WideCopyFile(name, nameArg, False)
        then sgfResult := ioNotSaved
end;

// Print single tree from current node (used currently for debug)

procedure PrintCurrentTree(name : string; gt : TGameTree);
var
  f : text;
begin
  CompressList := False;
  SaveCompact  := False;

  assign(f, name);
  rewrite(f);
  PrintTree(f, gt); // TODO : unicode
  close(f)
end;

// -- Print in string --------------------------------------------------------

// -- main line, main properties

function PrintTreeInString(gt : TGameTree) : string;
var
  pr : TPropId;
  pv : string;
  i : integer;
begin
  Result := '(';
  gt := gt.Root;

  while gt <> nil do
    begin
      for i := 1 to gt.PropNumber do
        begin
          gt.NthProp(i, pr, pv);
          if pr = prB
            then Result := Result + ';B' + pv
          else if pr = prW
            then Result := Result + ';W' + pv
          else if (pr = prSZ) or
                  (pr = prAB) or (pr = prAW) or (pr = prAE)
            then Result := Result + ';' + PropertyName(pr) + pv
        end;
      gt := gt.NextNode
    end;

  Result := Result + ')'
end;

// -- whole tree

function TreeToString2(x : TGameTree) : string;
begin
  if x = nil
    then Result := ''
    else
      if x.NextVar = nil
        then Result := NodeToString(x) + TreeToString2(x.NextNode)
        else
          begin
            Result := '';
            repeat
              Result := Result + '(' + NodeToString(x)
                                     + TreeToString2(x.NextNode) + ')';
              x := x.NextVar
            until x = nil
          end
end;

function TreeToString(gt : TGameTree) : string;
begin
  gt := gt.Root;
  if gt.PropNumber = 0
    then gt := gt.NextNode;

  Result := '(' + TreeToString2(gt) + ')'
end;

// -- Unicode filename functions ---------------------------------------------

procedure PrintSGF(cl : TGameColl;
                   name : WideString;
                   mode : TSgfSaveMode;
                   aCompressList : boolean;
                   aSaveCompact  : boolean;
                   matchFileName : boolean = False);
var
  tmpName : string;
begin
  if IsAnsiString(name)
    then PrintSgf(cl, string(name), mode, aCompressList, aSaveCompact,
                  matchFileName)
    else
      begin
        tmpName := DragoTempPath + 'tmp.sgf';

        PrintSgf(cl, tmpName, mode, aCompressList, aSaveCompact,
                 matchFileName);

        if sgfResult <> ioErrorOk
          then exit;

        if not WideCopyFile(tmpName, name, False)
          then sgfResult := ioNotSaved
      end
end;

// ---------------------------------------------------------------------------

initialization
  strBuffer := StrAlloc(kStrBufferSize);
  sgfLog    := TStringList.Create
finalization
  sgfLog.Free
end.
