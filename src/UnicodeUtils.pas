unit UnicodeUtils;

// ---------------------------------------------------------------------------

interface

uses
  Types, Windows, StrUtils;

function IsAnsiString(const s : WideString) : boolean;
function WidePos(const F: WideString; const S: WideString; const StartIndex: Integer): Integer;
function WideReplaceStr(const s : WideString; const old, new : string) : WideString;
function CopyFileToAnsiNameTmpFile(name : WideString; tmpPath : string) : string;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtilsEx;

// -- Ansi string test -------------------------------------------------------

function IsAnsiString(const s : WideString) : boolean;
var
  i : integer;
begin
  Result := False;

  for i := 1 to Length(s) do
    if integer(s[i]) > 127//255
      then exit;

  Result := True
end;

// -- WidePos ----------------------------------------------------------------
//
// -- extracted from cUnicode.pas, fundementals.sourceforge.net, David J Butler

function WidePMatch(const M: WideString; const P: PWideChar): Boolean;
var
  I, L : Integer;
  Q, R : PWideChar;
begin
  L := Length(M);
  if L = 0 then
    begin
      Result := False;
      exit;
    end;
  R := Pointer(M);
  Q := P;
  For I := 1 to L do
    if R^ <> Q^ then
      begin
        Result := False;
        exit;
      end else
      begin
        Inc(R);
        Inc(Q);
      end;
  Result := True;
end;

function WidePos(const F: WideString; const S: WideString; const StartIndex: Integer): Integer;
var
  P : PWideChar;
  I, L : Integer;
begin
  L := Length(S);
  if (StartIndex > L) or (StartIndex < 1) then
    begin
      Result := 0;
      exit;
    end;
  P := Pointer(S);
  Inc(P, StartIndex - 1);
  For I := StartIndex to L do
    if WidePMatch(F, P) then
      begin
        Result := I;
        exit;
      end
    else
      Inc(P);
  Result := 0;
end;

// -- WideReplaceStr ---------------------------------------------------------
//
// partial implementation

function WideReplaceStr(const s : WideString; const old, new : string) : WideString;
var
  s2 : AnsiString;
begin
  s2 := UTF8Encode(s);
  s2 := AnsiReplaceStr(s2, old, new);

  Result := UTF8Decode(s2)
end;

// -- WideCopy (is it useful?) -----------------------------------------------

function WideCopy(const s : WideString; index, count: Integer) : WideString;
begin
  Result := RightStr(LeftStr(s, index + count - 1), count)
end;

// ---------------------------------------------------------------------------

function CopyFileToAnsiNameTmpFile(name : WideString; tmpPath : string) : string;
begin
  Result := tmpPath + '\tmp' + WideExtractFileExt(name);
  WideCopyFile(name, Result, False)
end;

end.
