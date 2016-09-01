// ---------------------------------------------------------------------------
// -- Drago -- Conversions --------------------------------------- Ux2y.pas --
// ---------------------------------------------------------------------------

unit Ux2y;

// ---------------------------------------------------------------------------

interface

const
  coordSgf = 'abcdefghijklmnopqrs';
  absKorsh = 'ABCDEFGHJKLMNOPQRST';

function  pv2str      (const pv : string) : string;
function  pv2strNoCRLF(const pv : string) : string;
function  str2pv      (const s : string)  : string;
function  pv2int      (const pv : string) : integer;
function  int2pv      (x : integer) : string;
function  pv2real     (const pv : string) : real;
function  real2pv     (x : real) : string;
procedure pv2ij       (const s : string; out i, j : integer);
procedure pv2ijs      (const s : string; out i, j : integer; out r : string);
function  ij2sgf      (i, j : integer) : string;
procedure sgf2ij      (const s : string; out i, j : integer);
function  ij2pv       (i, j : integer) : string;
function  ijs2pv      (i, j : integer; const s : string) : string;
function  ijn2pv      (i, j, n : integer) : string;
function  ijkl2pv     (i, j, k, l : integer) : string;
procedure pv2ijkl     (const pv : string; out i, j, k, l : integer);
procedure pv2ns       (const pv : string; out n : integer; out s : string);
function  ns2pv       (n : integer; const s : string) : string;
function  clist2list  (const pv : string) : string;
function  list2clist  (const pv : string) : string;
function  nthpv       (const pv : string; n : integer) : string;
procedure kor2ij      (const s : string; boardSize : integer; out i, j : integer); overload;
procedure kor2ij      (const s : string; boardSize : integer; out i, j : integer;
                                                              out ok   : boolean); overload;
function  ij2kor      (i, j : integer; boardSize : integer) : string;
function  kor2sgf     (const s : string; boardSize : integer) : string;
function  sgf2kor     (const s : string; boardSize : integer) : string;
function  gtp2sgf     (const s : string; boardSize : integer) : string;
function  sgf2gtp     (const s : string; boardSize : integer) : string;
function  CleanEscChar(const s : string) : string;
function  PutEscChar  (const s : string) : string;
function  pv2txt      (const pv : string) : string;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils, Math,
  Std;

// -- [s] --> s

function pv2str(const pv : string) : string;
begin
  Result := Copy(pv, 2, Length(pv) - 2)
end;

// -- [s#OD#OAt] --> s t

function pv2strNoCRLF(const pv : string) : string;
begin
  if pv = ''
    then Result := ''
    else
      begin
        Result := Copy(pv, 2, Length(pv) - 2);
        if (Pos(#13, Result) = 0) or (Pos(#10, Result) = 0)
          then exit;
        Result := StringReplace(Result, #13 , ' ', [rfReplaceAll]);
        Result := StringReplace(Result, #10 , ' ', [rfReplaceAll]);
        while Pos('  ', Result) > 0 do
          Result := StringReplace(Result, '  ', ' ', [rfReplaceAll])
      end
end;

// -- s --> [s]

function str2pv(const s : string) : string;
begin
  Result := '[' + s +  ']'
end;

// -- [n] --> n

function pv2int(const pv : string) : integer;
begin
  Result := StrToIntDef(Trim(Copy(pv, 2, Length(pv) - 2)), 0)
end;

// -- n --> [n]

function int2pv(x : integer) : string;
begin
  Result := '[' + IntToStr(x) +  ']'
end;

// -- [r] --> r

function pv2real(const pv : string) : real;
begin
  Result := StrToFloatDef(Trim(Copy(pv, 2, Length(pv) - 2)), 0)
end;

// -- r --> [r]

function real2pv(x : real) : string;
begin
  Result := '[' + FloatToStr(x) +  ']'
end;

// -- [ab] --> (2,1)

procedure pv2ijV0(const s : string; out i, j : integer);
begin
  j := ord(s[2]) - ord('a') + 1;
  i := ord(s[3]) - ord('a') + 1;
end;

procedure pv2ij(const s : string; out i, j : integer);
var
  c1, c2 : char;
  k : integer;
begin
  c1 := #0;
  c2 := #0;
  for k := 2 to Length(s) - 1 do
    if s[k] > ' ' then
      if c1 = #0
        then c1 := s[k]
        else
          begin
            c2 := s[k];
            break
          end;
  if c1 = #0 then j := 100 else j := ord(c1) - ord('a') + 1;
  if c2 = #0 then i := 100 else i := ord(c2) - ord('a') + 1
end;

// -- [ab:s] --> (2,1,s)

procedure pv2ijs(const s : string; out i, j : integer; out r : string);
var
  p : integer;
begin
  pv2ij(s, i, j);
  p := Pos(':', s);
  if p = 0
    then r := ''
    else r := Copy(s, p + 1, Length(s) - p - 1)
end;

// -- (2,1) --> ab

function ij2sgf(i, j : integer) : string;
begin
  Result := chr(ord('a') - 1 + j) + chr(ord('a') - 1 + i)
end;

// -- ab --> (2,1)

procedure sgf2ij(const s : string; out i, j : integer);
begin
  j := ord(s[1]) - ord('a') + 1;
  i := ord(s[2]) - ord('a') + 1
end;

// -- (2,1) --> [ab]

function ij2pv(i, j : integer) : string;
var
  s : string;
begin
  s := '[';
  s := s + chr(ord('a') -  1 + j);
  s := s + chr(ord('a') -  1 + i);
  s := s + ']';

  Result := s
end;

// -- (2,1,string) --> [ab:string]

function ijs2pv(i, j : integer; const s : string) : string;
var
  r : string;
begin
  r := '[';
  r := r + chr(ord('a') -  1 + j);
  r := r + chr(ord('a') -  1 + i);
  r := r + ':' + s;
  r := r + ']';

  Result := r
end;

// -- (2,1,10) --> [ab:10]

function ijn2pv(i, j, n : integer) : string;
begin
  Result := ijs2pv(i, j, IntToStr(n))
end;

// -- (2,1,4,3) --> [ab:cd]

function ijkl2pv(i, j, k, l : integer) : string;
var
  x : integer;
  s : string;
begin
  if i > k then begin x := i; i := k; k := x end;
  if j > l then begin x := j; j := l; l := x end;
  s := '[';
  s := s + chr(ord('a') -  1 + j);
  s := s + chr(ord('a') -  1 + i);
  s := s + ':';
  s := s + chr(ord('a') -  1 + l);
  s := s + chr(ord('a') -  1 + k);
  s := s + ']';

  Result := s
end;

// -- [ab:cd] --> (2,1,4,3)

procedure pv2ijkl(const pv : string; out i, j, k, l : integer);
begin
  pv2ij(pv, i, j);
  pv2ij(Copy(pv, 4, 4), k, l)
end;

// -- [n:string] --> (n,string)

procedure pv2ns(const pv : string; out n : integer; out s : string);
var
  x : string;
  i : integer;
begin
  x := pv2str(pv);
  n := 0;
  s := '';
  i := Pos(':', x);
  if i = 0
    then exit;
  n := StrToIntDef(Trim(Copy(x, 1, i - 1)), 0);
  s := Copy(x, i + 1, Length(x))
end;

// -- (n,string) --> [n:string]

function ns2pv(n : integer; const s : string) : string;
begin
  Result := Format('[%d:%s]', [n, s])
end;

// -- [ab][aa:zz] --> [ab][aa]...[zz] (compressed list to list)

function clist2list(const pv : string) : string;
var
  k, i, j, i1, j1, i2, j2 : integer;
  s, x : string;
begin
  s := StringReplace(pv, ' ', '', [rfReplaceAll]);

  if (Pos(':', pv) = 0) and (Pos('[]', pv) = 0) then
    begin
      Result := s;
      exit
    end;

  Result := '';
  k := 1;
  x := nthpv(pv, k);
  while x <> '' do
    begin
      if x = '[]'
        then // nop
        else
          if x[4] <> ':'
            then Result := Result + x
            else
              begin
                pv2ij(x, i1, j1);
                pv2ij(Copy(x, 4, 4), i2, j2);
                for i := i1 to i2 do
                  for j := j1 to j2 do
                    Result := Result + ij2pv(i, j)
              end;
      inc(k);
      x := nthpv(pv, k)
    end;

  if Result = ''
    then Result := '[]'
end;

// -- [ab][aa]...[zz] --> [ab][aa:zz] (list to compressed list)

var
  mCmp : array[1 .. 19, 1 .. 19] of integer;

function IsCorner(i, j : integer) : boolean;
begin
  Result := ((i = 1) and (j = 1)) or
            ((i = 1) and (mCmp[1, j - 1] = 0)) or
            ((j = 1) and (mCmp[i - 1, 1] = 0)) or
            ((i > 1) and (j > 1) and (mCmp[i - 1, j - 1] = 0))
end;

function IsRectInside(i1, j1, i2, j2 : integer) : boolean;
var
  i, j : integer;
begin
  Result := False;

  for i := i1 to i2 do
    for j := j1 to j2 do
      if mCmp[i, j] = 0
        then exit;

  Result := True
end;

function list2clist2 : string;
var
  iC, jC, k, i, j, iM, jM, s, sM : integer;
begin
  // find first North-West corner
  iC := 0;
  jC := 0;
  for k := 1 to 19*19 do
    begin
      i := (k - 1) div 19 + 1;
      j := (k - 1) mod 19 + 1;

      if (mCmp[i, j] <> 0) and IsCorner(i, j) then
        begin
          iC := i;
          jC := j;
          break
        end
    end;

  // more corners?
  Result := '';
  if iC = 0
    then exit;

  // find biggest rectangle starting at iC, jC
  sM :=  1;
  iM := iC;
  jM := jC;
  for i := iC to 19 do
    for j := jC to 19 do
      if IsRectInside(iC, jC, i, j) then
        begin
          s := (i - iC + 1) * (j - jC + 1);
          if s > sM then
            begin
              iM := i;
              jM := j;
              sM := s
            end
        end;

  // erase rectangle
  for i := iC to iM do
    for j := jC to jM do
      mCmp[i, j] := 0;

  // result
  if (iC = iM) and (jC = jM)
    then Result := ij2pv(iC, jC)
    else Result := ijkl2pv(iC, jC, iM, jM)
end;

function list2clist(const pv : string) : string;
var
  i, j, k : integer;
  x, rec  : string;
begin
  // reset matrix
  for i := 1 to 19 do
    for j := 1 to 19 do
      mCmp[i, j] := 0;

  // mark matrix with intersections
  k := 1;
  x := nthpv(pv, k);
  while x <> '' do
    begin
      pv2ij(x, i, j);
      if InRange(i, Low(mCmp), High(mCmp)) and
         InRange(j, Low(mCmp), High(mCmp))
        then mCmp[i, j] := 1;
      inc(k);
      x := nthpv(pv, k)
    end;

  // launch
  Result := '';
  repeat
    rec := list2clist2;
    Result := Result + rec
  until rec = ''
end;

// -- Access to nth value

function nthpv(const pv : string; n : integer) : string;
var
  i1, i2 : integer;
begin
  {
  i1 := NthChar('[', pv, n);
  i2 := NthChar(']', pv, n);
  }
  i1 := NthCharUnslashed('[', pv, n);
  i2 := NthCharUnslashed(']', pv, n);

  if (i1 = 0) or (i2 = 0)
    then Result := ''
    else Result := Copy(pv, i1, i2 - i1 + 1)
end;

// -- C8 --> (12,3)

procedure kor2ij(const s : string; boardSize : integer; out i, j : integer);
begin
  j := Pos(UpperCase(s[1]), absKorsh);
  i := boardSize - StrToInt(Copy(s, 2, 2)) + 1
end;

procedure kor2ij(const s : string; boardSize : integer; out i, j : integer;
                                                        out ok   : boolean);
begin
  i  := 0;
  j  := 0;
  j  := Pos(UpperCase(s[1]), absKorsh);
  i  := boardSize - StrToIntDef(Copy(s, 2, 2), 0) + 1;

  ok := (i >= 1) and (i <= boardsize) and (j >= 1)
end;

// -- (12,3) --> C8

function ij2kor(i, j : integer; boardSize : integer) : string;
begin
  Result := absKorsh[j] + IntToStr(boardSize - i + 1)
end;

// -- C8 --> cl

function kor2sgf(const s : string; boardSize : integer) : string;
var
  i, j : integer;
begin
  kor2ij(s, boardSize, i, j);
  Result := coordSgf[j] + coordSgf[i]
end;

// -- cl --> C8

function sgf2kor(const s : string; boardSize : integer) : string;
begin
  Result := absKorsh[ord(s[1]) - ord('a') + 1] +
            IntToStr(boardSize - ord(s[2]) + ord('a'))
end;

// -- 'A19 B18 C17' --> aabbcc

function gtp2sgf(const s : string; boardSize : integer) : string;
var
  i, j, k, l : integer;
  x, kor : string;
begin
  Result := '';
  x := s;
  x := StringReplace(x, #$D, ' ', [rfReplaceAll]);
  x := StringReplace(x, #$A, ' ', [rfReplaceAll]);
  x := StringReplace(x, '  ', ' ', [rfReplaceAll]);
  x := Trim(x) + ' ';
  k := 1;
  while k < Length(x) do
    begin
      l := PosEx(' ', x, k);
      kor := Copy(x, k, l - k);
      // try to protect against a problem with MoGo (514 move game!)
      if Length(kor) >= 2 then
        begin
          kor2ij(kor, boardSize, i, j);
          Result := Result + coordSgf[j] + coordSgf[i]
        end;
      k := l + 1
    end
end;

// -- [aa][bb][cc] --> 'A19 B18 C17'

function sgf2gtp(const s : string; boardSize : integer) : string;
var
  k : integer;
  pv : string;
begin
  Result := '';
  k := 2;
  while k < Length(s) do
    begin
      pv := Copy(s, k, 2);
      Result := Result + sgf2kor(pv, boardSize) + ' ';
      inc(k, 4)
    end
end;

// -- [s] --> s' with line breaks normalized to CRLF
//                    removing of \\n
//                    removing of \

function pv2txt(const pv : string) : string;
begin
  Result := AdjustLineBreaks(pv2str(pv), tlbsCRLF);
  Result := StringReplace(Result, '\'#13#10 , '', [rfReplaceAll]);
  Result := CleanEscChar(Result)
end;

// -- Handle \ in property value

function CleanEscChar(const s : string) : string;
var
  r : string;
  i : integer;
begin
  r := '';
  i := 1;
  while i <= Length(s) do
    begin
      if s[i] <> '\'
        then r := r + s[i]
        else
          if i < Length(s) then
            begin
              inc(i);
              r := r + s[i]
            end;
      inc(i)
    end;

  Result := r
end;

function PutEscChar(const s : string) : string;
var
  r : string;
  i : integer;
begin
  r := '';
  i := 1;
  while i <= Length(s) do
    begin
      if not (s[i] in ['\',']'])
        then r := r + s[i]
        else r := r + '\' + s[i];
      inc(i)
    end;

  Result := r
end;

// ---------------------------------------------------------------------------

end.
