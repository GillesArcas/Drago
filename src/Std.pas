// ---------------------------------------------------------------------------
// -- Drago -- Additional common functions ------------------------ Std.pas --
// ---------------------------------------------------------------------------

{$n-}

unit Std;

// ---------------------------------------------------------------------------

interface

uses
  Classes, Types;

const
  CRLF = chr(13) + chr(10);

function  SecToTime  (x : real) : string;
function  TimeToSec  (s : string) : integer;
function  ElapsedTimeToStr(milli : double) : string;
function  TryStrToReal(const s : string; out x : real) : boolean;
function  iff        (b : boolean; x1, x2 : integer) : integer; overload;
function  iff        (b : boolean; x1, x2 : string) : string; overload;
function  iff        (b : boolean; x1, x2 : WideString) : WideString; overload;
function  iff        (b : boolean; x1, x2 : char) : char; overload;
function  iff        (b : boolean; x1, x2 : real) : real; overload;
function  ismaj      (c : char) : boolean;
function  ismin      (c : char) : boolean;
function  isnum      (c : char) : boolean;
function  min        (x, y : integer) : integer;
function  max        (x, y : integer) : integer;
function  MaxMin     (x, a, b : integer) : integer;
function  Within     (x, a, b : integer) : boolean; overload;
function  Within     (x, a, b : char   ) : boolean; overload;
procedure SortPair   (var x, y : integer);
function  InsideRect (x, y : integer; rect : TRect) : boolean;

//function  NthWord    (const s : string; n : integer; sep : char = ' ') : string;
function  NthWord    (const s : string; n : integer; const sep : string = ' ') : string;

function  NthInt     (const s : string; n : integer; sep : char = ' ') : integer;
function  NthFloat   (const s : string; n : integer; sep : char = ' ') : double;
function  Split      (const s : string; out A : TStringDynArray; sep : char = ' ') : integer;
function  Join       (const sep : string; strings : array of string;
                      ignoreEmpty : boolean = True) : string;
function  FileToString(const filename : WideString) : string;
procedure StringToFile(const filename, s : string);
function  File2String_ANSI_filename(filename : string) : string;
function  NthChar    (c : char; s : string; n : integer) : integer;
function  NthCharUnslashed (c : char; s : string; n : integer) : integer;
function  replace    (const s, src, dst : string) : string;
function  UTF8DecodeX(const s : string) : WideString;

function  MilliTimer : int64;
procedure ResetTrace;
procedure Trace      (s : string);

function  UniqueFileName(const path, ext : string) : string;

type TStringObject = class
  FString : string;
  constructor Create(const s : string);
  destructor Destroy; override;
end;

type
  TIntStack = class
    Items : array of integer;
    constructor Create;
    destructor  Destroy; override;
    procedure   Assign(x : TIntStack);
    function    Count : integer;
    procedure   Leave(n : integer);
    function    AtLeast(n : integer) : boolean;
    procedure   Push(i : integer);
    function    Pop : integer;
    function    Peek : integer;
    procedure   Inc(n : integer = 1);
  end;

type
  TStringStack = class
    Items : array of string;
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    Count : integer;
    procedure   Push(s : string);
    function    Pop : string;
    function    Peek : string;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, SysUtilsEx,
  StrUtils, DateUtils;

// -- Conversions ------------------------------------------------------------

function SecToTime(x : real) : string;
var
  sec, hr, min : integer;
begin
  sec := round(x);
  min := sec div 60;
  sec := sec mod 60;
  hr  := min div 60;
  min := min mod 60;
  Result := Format('%2.2d:%2.2d:%2.2d', [hr, min, sec])
end;

function TimeToSec(s : string) : integer;
var
  sec, hr, min : integer;
begin
  hr  := StrToIntDef(Copy(s, 1, 2), -1);
  min := StrToIntDef(Copy(s, 4, 2), -1);
  sec := StrToIntDef(Copy(s, 7, 2), -1);
  if (hr < 0) or (min < 0) or (sec < 0) or (s[3] <> ':') or (s[6] <> ':')
    then Result := -1
    else Result := hr * 3600 + min * 60 + sec
end;

// milliseconds -> hh:mm:ss

function ElapsedTimeToStr(milli : double) : string;
var
  x, h, m, s : integer;
begin
  x := Round(milli);

  h := x div (1000 * 60 * 60);
  x := x mod (1000 * 60 * 60);
  m := x div (1000 * 60);
  x := x mod (1000 * 60);
  s := x div 1000;

  Result := Format('%d:%2.2d:%2.2d', [h, m, s])
end;

// TryStrToInt definition for D5

{$ifdef DELPHI5}

function TryStrToInt(const s : string; out n : integer) : boolean;
var
  e : integer;
begin
  val(s, n, e);
  TryStrToInt := e = 0
end;

{$endif}

function TryStrToReal(const s : string; out x : real) : boolean;
var
  e : integer;
begin
  val(s, x, e);
  TryStrToReal := e = 0
end;

// -- Immediate If -----------------------------------------------------------

function iff(b : boolean; x1, x2 : integer) : integer;
begin
  if b
    then Result := x1
    else Result := x2
end;

function iff(b : boolean; x1, x2 : string) : string;
begin
  if b
    then Result := x1
    else Result := x2
end;

function iff(b : boolean; x1, x2 : WideString) : WideString;
begin
  if b
    then Result := x1
    else Result := x2
end;

function iff(b : boolean; x1, x2 : char) : char;
begin
  if b
    then Result := x1
    else Result := x2
end;

function iff(b : boolean; x1, x2 : real) : real;
begin
  if b
    then Result := x1
    else Result := x2
end;

// -- Misc -------------------------------------------------------------------

function ismaj(c : char) : boolean;
begin
  ismaj := (c >= 'A') and (c <= 'Z')
end;

function ismin(c : char) : boolean;
begin
  ismin := (c >= 'a') and (c <= 'z')
end;

function isnum(c : char) : boolean;
begin
  isnum := (c >= '0') and (c <= '9')
end;

function min(x, y : integer) : integer;
begin
  if x < y then min := x else min := y
end;

function max(x, y : integer) : integer;
begin
  if x > y then max := x else max := y
end;

function Within(x, a, b : integer) : boolean;
begin
  Result := (x >= a) and (x <= b)
end;

function Within(x, a, b : char) : boolean;
begin
  Result := (x >= a) and (x <= b)
end;

function MaxMin(x, a, b : integer) : integer;
begin
  if x < a
    then Result := a
    else
      if x > b
        then Result := b
        else Result := x
end;

procedure SortPair(var x, y : integer);
var
  z : integer;
begin
  if x > y then
    begin
      z := x; x := y; y := z
    end
end;

// -- Rectangles -------------------------------------------------------------

function InsideRect(x, y : integer; rect : TRect) : boolean;
begin
  with rect do
    Result := (x >= left) and (x <= right) and
              (y >= top) and (y <= bottom)
end;

// -- Strings ----------------------------------------------------------------

function replace(const s, src, dst : string) : string;
var
  i, j : integer;
begin
  i := Pos(src, s);
  j := i + Length(src);
  if i = 0
    then Result := s
    else Result := Copy(s, 1, i - 1) +
                   dst +
                   Copy(s, j, Length(s) + 1 - i)
end;

// -- Nth word and integer extraction ----------------------------------------
(*
function NthWordIn(const s : string; n, p : integer; sep : char = ' ') : string;
var
  q : integer;
begin
  q := PosEx(sep, s, p);
  if q = 0
    then
      if n = 1
        then Result := Copy(s, p, MaxInt)
        else Result := ''
    else
      if n = 1
        then Result := Copy(s, p, q - p)
        else Result := NthWordIn(s, n - 1, q + 1, sep)
end;

function NthWord(const s : string; n : integer; sep : char = ' ') : string;
begin
  Result := NthWordIn(s, n, 1, sep)
end;
*)

// find nth word (1-based)
// sep if a space by default
// if sep is a space, consecutive spaces are considered as a separator and leading spaces are ignored
// if sep is not a space, it can be a string of any length

function NthWordSep(const s : string; n : integer; const sep : string) : string;
var
  m, p, q : integer;
begin
  m := 1;
  p := 1;
  q := 0;
  while True do
    begin
      q := PosEx(sep, s, p);
      if (q = 0) or (m = n)
        then break;
      inc(m);
      p := q + Length(sep)
    end;

  if q = 0
    then
      if m = n
        then Result := Copy(s, p, MaxInt)
        else Result := ''
    else
      if m = n
        then Result := Copy(s, p, q - p)
end;

function NthWordEsp(const s : string; n : integer) : string;
var
  m, p, q : integer;
begin
  m := 1;
  p := 1;
  while (p <= Length(s)) and (s[p] = ' ') do
    inc(p);

  while p <= Length(s) do
    begin
      // p is on a non space character
      q := PosEx(' ', s, p);
      if (q = 0) or (m = n)
        then break;
      while (q <= Length(s)) and (s[q] = ' ') do
        inc(q);
      inc(m);
      p := q
    end;

  if p > Length(s)
    then Result := ''
    else
      if q = 0
        then
          if m = n
            then Result := Copy(s, p, MaxInt)
            else Result := ''
        else
          if m = n
            then Result := Copy(s, p, q - p)
end;

function NthWord(const s : string; n : integer; const sep : string = ' ') : string;
begin
  if n < 1
    then Result := ''
    else
      if sep = ' '
        then Result := NthWordEsp(s, n)
        else Result := NthWordSep(s, n, sep)
end;

function NthInt(const s : string; n : integer; sep : char = ' ') : integer;
begin
  Result := StrToIntDef(NthWord(s, n, sep), 0)
end;

function NthFloat(const s : string; n : integer; sep : char = ' ') : double;
begin
  Result := StrToFloatDef(NthWord(s, n, sep), 0)
end;

// -- Extraction of strings --------------------------------------------------
// Credit : http://www.developpez.net/forums/showthread.php?t=325026&page=2 (ExplodeLazy)

function Split(const s : string; out A : TStringDynArray; sep : char = ' ') : integer;
var
  i, j, k: integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
    if s[i] = sep
      then Inc(Result);

  if (s = '') or (s[Length(s)] = sep)
    then SetLength(A, Result)
    else SetLength(A, Result + 1);

  k := 1;
  j := 0;
  for i := 1 to Length(s) do
    if s[i] = sep then
      begin
        if k <> i
          then A[j] := Copy(s, k, i - k);
        Inc(j);
        k := i + 1;
      end;

  if k <= Length(s)
    then A[j] := Copy(s, k, MaxInt)
end;

// -- Join a list of strings adding a separator in between

function Join(const sep : string; strings : array of string;
               ignoreEmpty : boolean = True) : string;
var
  n, i : integer;
begin
  Result := '';
  n := 0;

  for i := 0 to High(strings) do
    if (not ignoreEmpty) or (strings[i] <> '') then
      begin
        if n = 0
          then n := 1
          else Result := Result + sep;
        Result := Result + strings[i]
      end
end;

// -- Read file into string --------------------------------------------------

function File2String_ANSI_filename(filename : string) : string;
var
  stream : TFileStream;
  s : string;
begin
  stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    stream.Position := 0;
    SetLength(s, stream.Size);
    stream.ReadBuffer(s[1], stream.Size)
  finally
    stream.Free
  end;
  Result := s
end;

function FileToString(const filename : WideString) : string;
var
  f : integer;
  n : integer;
  buffer : PChar;
begin
  // open file
  f := WideFileOpen(filename, fmOpenRead or fmShareDenyNone);

  // return if file not open
  if f < 0
    then exit;

  // get size
  n := FileSeek(f, 0, 2);

  // allocation is not tested
  GetMem(buffer, n + 1);

  FileSeek(f, 0, 0);
  n := FileRead(f, buffer^, n);

  FileClose(f);

  buffer[n] := #0;

  Result := buffer;

  FreeMem(buffer)
end;

procedure StringToFile(const filename, s : string);
var
  f : Text;
begin
  AssignFile(f, filename);
  Rewrite(f);
  Write(f, s);
  CloseFile(f)
end;

// -- Nth char extraction ----------------------------------------------------

function NthChar(c : char; s : string; n : integer) : integer;
var
  i, k : integer;
begin
  Result := 0;
  k := 0;
  for i := 1 to Length(s) do
    begin
      if s[i] = c
        then inc(k);
      if k = n then
        begin
          Result := i;
          exit
        end
    end
end;

function NthCharUnslashed(c : char; s : string; n : integer) : integer;
var
  i, k : integer;
begin
  Result := 0;
  k := 0;
  for i := 1 to Length(s) do
    begin
      if (s[i] = c) and ((i = 1) or (s[i-1] <> '\'))
         then inc(k);
      if k = n then
        begin
          Result := i;
          exit
        end
    end
end;

// -- Extraction of file name components -------------------------------------

function ExtractName(filename, component : string) : string;
begin
  //TODO
end;

// -- Creation of unique random filename -------------------------------------
//
// Avoid Windows GetTempFileName

function UniqueFileName(const path, ext : string) : string;
var
  i : integer;
  filename : string;
begin
  repeat
    filename := IncludeTrailingPathDelimiter(path);
    for i := 1 to 8 do
      filename := filename + chr(ord('A') + random(26));
    filename := filename + ext;
    if not FileExists(filename) then
      begin
        Result := filename;
        exit
      end
  until False
end;

// -- Protected version of UTF8Decode (avoid empty strings when not UTF8) ----

function UTF8DecodeX(const s : string) : WideString;
begin
  Result := UTF8Decode(s);
  if Result = ''
    then Result := s
end;

// -- Millisecond timer ------------------------------------------------------

var
  MilliTimer_Start : TDateTime = -1;

function MilliTimer : int64;
var
  t : TDateTime;
begin
  t := Now;

  if MilliTimer_Start < 0
    then
      begin
        Result := -1;
        MilliTimer_Start := t
      end
    else
      begin
        Result := MilliSecondsBetween(t, MilliTimer_Start);
        MilliTimer_Start := -1
      end
end;

// -- Tracing for debug ------------------------------------------------------

procedure ResetTrace;
// Development only. Exe must be called from Ansi name directory.
var
  fname : string;
  f : text;
begin
  fname := ChangeFileExt(ParamStr(0), '.log');
  assign(f, fname);
  rewrite(f);
  close(f)
end;

procedure Trace(s : string);
// Development only. Exe must be called from Ansi name directory.
var
  fname : string;
  f : text;
begin
  fname := ChangeFileExt(ParamStr(0), '.log');
  assign(f, fname);
  if not FileExists(fname)
    then rewrite(f)
    else append(f);
  writeln(f, s);
  close(f)
end;

// -- String object ----------------------------------------------------------

constructor TStringObject.Create(const s : string);
begin
  inherited Create;
  FString := s
end;

destructor TStringObject.Destroy;
begin
  Finalize(FString)
end;

// -- Integer stack class ----------------------------------------------------

constructor TIntStack.Create;
begin
  inherited;
  SetLength(Items, 0)
end;

destructor TIntStack.Destroy;
begin
  SetLength(Items, 0);
  inherited
end;

procedure TIntStack.Assign(x : TIntStack);
begin
  Items := Copy(x.Items)
end;

procedure TIntStack.Leave(n : integer);
begin
  while AtLeast(n + 1) do Pop
end;

procedure TIntStack.Push(i : integer);
begin
  SetLength(Items, Length(Items) + 1);
  Items[High(Items)] := i
end;

function TIntStack.Pop : integer;
begin
  Result := Items[High(Items)];
  SetLength(Items, Length(Items) - 1)
end;

function TIntStack.Peek : integer;
begin
  Result := Items[High(Items)]
end;

function TIntStack.Count : integer;
begin
  Result := Length(Items)
end;

function TIntStack.AtLeast(n : integer) : boolean;
begin
  Result := Length(Items) >= n
end;

procedure TIntStack.Inc(n : integer = 1);
begin
  Items[High(Items)] := Items[High(Items)] + n
end;

// -- String stack class -----------------------------------------------------

constructor TStringStack.Create;
begin
  inherited;
  Clear
end;

destructor TStringStack.Destroy;
begin
  Clear;
  // Finalize(Items); ??
  inherited
end;

procedure TStringStack.Clear;
begin
  SetLength(Items, 0)
end;

function TStringStack.Count : integer;
begin
  Result := Length(Items)
end;

procedure TStringStack.Push(s : string);
begin
  SetLength(Items, Length(Items) + 1);
  Items[High(Items)] := s
end;

function TStringStack.Pop : string;
begin
  Result := Items[High(Items)];
  SetLength(Items, Length(Items) - 1)
end;

function TStringStack.Peek : string;
begin
  Result := Items[High(Items)]
end;

// ---------------------------------------------------------------------------

end.

