unit UnicodeUtils;

// ---------------------------------------------------------------------------

interface

uses
  Types, Graphics, Windows, StrUtils, TntGraphics;

function IsAnsiString(const s : WideString) : boolean;
function WideMinimizeName(const Filename: WideString;
                          Canvas: TCanvas;
                          MaxLen: Integer): WideString;
function WidePos(const F: WideString; const S: WideString; const StartIndex: Integer): Integer;
function WideReplaceStr(const s : WideString; const old, new : string) : WideString;

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

// -- WideMinimizeName -- (using MFC) ----------------------------------------

{.$define WideMinimizeNameMFC}
{$ifdef WideMinimizeNameMFC}

function WideMinimizeName(const Filename: WideString;
                          Canvas: TCanvas;
                          MaxLen: Integer): WideString;
var
  can : TCanvas;
  s : string;
  rect : TRect;
  r : integer;
begin
  can := TCanvas.Create;
  can.Font.Assign(Canvas.Font);
  s := UTF8Encode(Filename);
  rect.Left := 0;
  rect.Top := 0;
  rect.Right := MaxLen;
  rect.Bottom := can.Font.Height;
  r := DrawText(Canvas.Handle, PAnsiChar(s), Length(s),
                rect,
                DT_PATH_ELLIPSIS or DT_MODIFYSTRING);

  if r = 0
    then Result := Filename
    else Result := UTF8Decode(s);

  can.Free
end;

// -- WideMinimizeName -- (adapted from FileCtrl.pas in VCL source files) ----

{$else}

procedure CutFirstDirectory(var S: WideString);
var
  Root: Boolean;
  P: Integer;
begin
  if S = '\' then
    S := ''
  else
  begin
    if S[1] = '\' then
    begin
      Root := True;
      Delete(S, 1, 1);
    end
    else
      Root := False;
    if S[1] = '.' then
      Delete(S, 1, 4);
    P := WidePos('\',S,1);
    if P <> 0 then
    begin
      Delete(S, 1, P);
      S := '...\' + S;
    end
    else
      S := '';
    if Root then
      S := '\' + S;
  end;
end;

function WideMinimizeName(const Filename: WideString; Canvas: TCanvas;
  MaxLen: Integer): WideString;
var
  Drive: WideString;
  Dir: WideString;
  Name: WideString;
begin
  Result := FileName;
  Dir := WideExtractFilePath(Result);
  Name := WideExtractFileName(Result);

  if (Length(Dir) >= 2) and (Dir[2] = ':') then
  begin
    Drive := Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive := '';
  while ((Dir <> '') or (Drive <> '')) and
         (WideCanvasTextWidth(Canvas, Result) > MaxLen) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then
      Drive := ''
    else
      CutFirstDirectory(Dir);
    Result := Drive + Dir + Name;
  end;
end;

{$endif}

// -- WideCopy (is it useful?) -----------------------------------------------

function WideCopy(const s : WideString; index, count: Integer) : WideString;
begin
  Result := RightStr(LeftStr(s, index + count - 1), count)
end;

// ---------------------------------------------------------------------------

end.
