// ---------------------------------------------------------------------------
// -- Code pages -------------------------------------------- CodePages.pas --
// ---------------------------------------------------------------------------

unit CodePages;

// ---------------------------------------------------------------------------

interface

uses
  Classes, SysUtils;

// -- References -------------------------------------------------------------

(*
[1] www.iana.org/assignments/character-sets
[2] msdn2.microsoft.com/en-us/library/ms776446.aspx : Code Page Identifiers
[3] libiconv source code
[4] www.gnu.org/software/libiconv/
[5] www.yunqa.de/delphi/doku.php/products/converters/encodings : DIConverters
[6] osdir.com/ml/printing.groff.general/2005-12/msg00061.html

// -- Notes ------------------------------------------------------------------

GBK vs CP936
------------
- According to [3] and contrary to [1], CP936 is not an alias of GBK
- According to [2], neither GBK nor CP936 have Windows Id

GB2312, EUC-CN
--------------
- According to [2], Windows Id of GB2312 is 936
- GB2312 is available but not mentionned in [4] nor [5]
- A file tagged as GB2312 by MultiGo:4.4.1 is incorrectly displayed
- According to [6], " chinese-euc is an alias for GB2312. I looked it up in
  the XEmacs sources "
- Neither chinese-euc nor euc-cn are mentionned in [1], but euc-cn is available
  in [5]
- According to what precedes, EUC-CN is made preferred, with GB2312 as alias,
  and 936 as Windows Id

SHIFT_JIS, Windows-31J
----------------------
- Windows-31J is a superset of SHIFT_JIS but not available in [5]. As it is
  used by smile_ace, it is set as an alias of SHIFT_JIS

Right to Left
-------------
- Right to Left codepages are not implemented (Arabic and Hebrew).

*)

// -- Internal identifiers (names used in DIConverters) ----------------------

type
  TCodePage = (
    cpDefault,
    iso8859_4,
    cp1257,
    euc_cn,
    gb18030,
    hzgb2312,
    big5,
    iso8859_5,
    cp1251,
    iso8859_7,
    cp1253,
    iso8859_2,
    cp1250,
    iso8859_1,
    cp1252,
    eucjp,
    shift_jis,
    cp949,
    euckr,
    iso_2022_kr,
    cp874,
    iso8859_9,
    cp1254,
    cp1258,
    utf8,
    cpUnknown
  );

// -- API

function  CPIdToName(cp : TCodePage) : string;
function  CPNameToId(const name : string) : TCodePage;
function  CPIdToDescr(cp : TCodePage) : string;
function  CPIdToWinId(cp : TCodePage) : integer;
function  mbtows(const s : string; cp : TCodePage) : WideString;
function  wstomb(const s : WideString; cp : TCodePage) : string;
function  CurrentCodePage : TCodePage;
function  IsMultiByte(cp : TCodePage) : boolean; overload;
procedure AppendCharsetNames(list : TStrings);
function  CodePageFromLanguageId(language : string) : TCodePage;

// ---------------------------------------------------------------------------

implementation

uses
  Windows, Std;

// -- Encoding data ----------------------------------------------------------

type

  TCodePageData =
    record
      nm : string;                          // Preferred name (RFC 1345 or IANA)
      al : string;                          // Aliases (comma separated)
      cp : TCodePage;                       // Internal identifier
      wi : integer;                         // Windows identifier
      mb : boolean;                         // is multi byte
      ui : string;                          // User interface name
    end;

const
  CodePageData : array[TCodePage] of TCodePageData =
((cp:cpDefault;
  ui:'System default code page'),

 (nm:'ISO-8859-4';
  al:'ISO_8859-4,Latin4';
  cp:iso8859_4;
  wi:28594;
  mb:False;
  ui:'Baltic, iso-8859-4'),

 (nm:'windows-1257';
  cp:cp1257;
  wi:1257;
  mb:False;
  ui:'Baltic, windows-1257'),

 (nm:'EUC-CN';
  al:'GB2312';
  cp:euc_cn;
  wi:936;
  mb:True;
  ui:'Chinese Simplified, GB2312'),

 (nm:'GB18030';
  cp:gb18030;
  wi:54936;
  mb:True;
  ui:'Chinese Simplified, GB18030'),

 (nm:'HZ-GB-2312';
  al:'HZ';
  cp:hzgb2312;
  wi:52936;
  mb:True;
  ui:'Chinese Simplified, HZ-GB-2312'),

 (nm:'Big5';
  cp:big5;
  wi:950;
  mb:True;
  ui:'Chinese Traditional, Big5'),

 (nm:'ISO-8859-5';
  al:'ISO_8859-5,cyrillic';
  cp:iso8859_5;
  wi:28595;
  mb:False;
  ui:'Cyrillic, iso-8859-5'),

 (nm:'windows-1251';
  cp:cp1251;
  wi:1251;
  mb:False;
  ui:'Cyrillic, windows-1251'),

 (nm:'ISO-8859-7';
  al:'ISO_8859-7,greek';
  cp:iso8859_7;
  wi:28597;
  mb:False;
  ui:'Greek, iso-8859-7'),

 (nm:'windows-1253';
  cp:cp1253;
  wi:1253;
  mb:False;
  ui:'Greek, windows-1253'),

 (nm:'ISO-8859-2';
  al:'ISO_8859-2,Latin2';
  cp:iso8859_2;
  wi:28592;
  mb:False;
  ui:'Central European, iso-8859-2'),

 (nm:'windows-1250';                      
  cp:cp1250;
  wi:1250;
  mb:False;
  ui:'Central European, windows-1250'),

 (nm:'ISO-8859-1';
  al:'ISO_8859-1,Latin1';
  cp:iso8859_1;
  wi:28591;
  mb:False;
  ui:'Western European, iso-8859-1'),

 (nm:'windows-1252';
  cp:cp1252;
  wi:1252;
  mb:False;
  ui:'Western European, windows-1252'),

 (nm:'EUC-JP';
  cp:eucjp;
  wi:51932;
  mb:True;
  ui:'Japanese, EUC-JP'),

 (nm:'Shift_JIS';
  al:'Windows-31J,Shift-JIS';
  cp:shift_jis;
  wi:932;
  mb:True;
  ui:'Japanese, Shift-JIS'),

 (nm:'CP949';
  cp:cp949;
  wi:949;
  mb:True;
  ui:'Korean, CP949'),

 (nm:'EUC-KR';
  cp:euckr;
  wi:51949;
  mb:True;
  ui:'Korean, EUC-KR'),

 (nm:'ISO-2022-KR';
  cp:iso_2022_kr;
  wi:50225;
  mb:True;
  ui:'Korean, iso-2022-kr'),

 (nm:'windows-874';
  cp:cp874;
  wi:874;
  mb:True;
  ui:'Thai, windows-874'),

 (nm:'ISO-8859-9';
  al:'ISO_8859-9,Latin5';
  cp:iso8859_9;
  wi:28599;
  mb:False;
  ui:'Turkish, iso-8859-9'),

 (nm:'windows-1254';
  cp:cp1254;
  wi:1254;
  mb:False;
  ui:'Turkish, windows-1254'),

 (nm:'windows-1258';
  cp:cp1258;
  wi:1258;
  mb:True;
  ui:'Vietnamese, windows-1258'),

 (nm:'UTF-8';
  cp:utf8;
  wi:65001;
  mb:True;
  ui:'Unicode, UTF-8'),

 (cp:cpUnknown)
);

type
  TCodePageObject = class
    cp : TCodePage
  end;

// -- Runtime encoding data --------------------------------------------------

var
  CodePageNames : TStringList;

procedure Initialize;
var
  cp : TCodePage;
  cpo : TCodePageObject;
  i : integer;
  s : string;
begin
  // create list of code page names
  CodePageNames := TStringList.Create;
  CodePageNames.Sorted := True;
  CodePageNames.CaseSensitive := False;

  for cp := Low(TCodePage) to High(TCodePage) do
    begin
      // check whether records are in enum order 
      assert(cp = CodePageData[cp].cp);

      // add preferred name to the list of names
      cpo := TCodePageObject.Create;
      cpo.cp := cp;
      CodePageNames.AddObject(CodePageData[cp].nm, cpo);

      // add aliases if any
      i := 1;
      repeat
        s := NthWord(CodePageData[cp].al, i, ',');
        if s = ''
          then break;
        cpo := TCodePageObject.Create;
        cpo.cp := cp;
        CodePageNames.AddObject(s, cpo);
        inc(i)
      until False
    end
end;

procedure Finalize;
begin
  CodePageNames.Free
end;

// -- TCodePage name/value conversions ---------------------------------------

function CPIdToName(cp : TCodePage) : string;
begin
  Result := CodePageData[cp].nm
end;

function CPNameToId(const name : string) : TCodePage;
var
  i : integer;
begin
  i := CodePageNames.IndexOf(name);
  if i < 0
    then Result := cpUnknown
    else Result := (CodePageNames.Objects[i] as TCodePageObject).cp
end;

function CPIdToDescr(cp : TCodePage) : string;
begin
  Result := CodePageData[cp].ui
end;

// -- TCodePage Win Id/Id conversion -----------------------------------------

var
  // todo : id cache not used
  CPWinIdToId_Cache_WinId : integer = -1;
  CPWinIdToId_Cache_Id    : TCodePage;

function CPWinIdToId(winId : integer) : TCodePage;
begin
  if winId = CPWinIdToId_Cache_WinId
    then Result := CPWinIdToId_Cache_Id
    else
      begin
        for Result := Low(TCodePage) to High(TCodePage) do
          if winId = CodePageData[Result].wi
            then exit;

        Result := cpUnknown
      end
end;

function CPIdToWinId(cp : TCodePage) : integer;
begin
  Result := CodePageData[cp].wi
end;

// -- Current code page Id ---------------------------------------------------

function CurrentCodePage : TCodePage;
begin
  Result := CPWinIdToId(GetACP)
end;

// -- Multibyte predicate ----------------------------------------------------

function IsMultiByte(cp : UINT) : boolean; overload;
var
  AnsiCPInfo: TCPInfo;
begin
  GetCPInfo(cp, AnsiCPInfo);
  Result := AnsiCPInfo.LeadByte[0] <> 0
end;

function IsMultiByte(cp : TCodePage) : boolean; overload;
begin
  Result := IsMultiByte(CodePageData[cp].wi)
  //Result := CodePageData[cp].mb
end;

// -- List of user interface names -------------------------------------------

procedure AppendCharsetNames(list : TStrings);
var
  cp : TCodePage;
begin
  // avoid cpUnknown, but keep cpDefault
  for cp := Low(TCodePage) to Pred(High(TCodePage)) do
    list.Add(CodePageData[cp].ui)
end;

// -- Multibyte to widestring conversion -------------------------------------

function StringToWideString(const s: AnsiString; codePage: Word): WideString;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), - 1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]),
        - 1, PWideChar(@Result[1]), l - 1);
  end;
end;

function mbtows(const s : string; cp : TCodePage) : WideString;
begin
  Result := StringToWideString(s, CodePageData[cp].wi)
end;

// -- Widestring to multibyte conversion -------------------------------------

function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], - 1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], - 1, @Result[1], l - 1, nil, nil);
  end;
end;

function wstomb(const s : WideString; cp : TCodePage) : string;
begin
  Result := WideStringToString(s, CodePageData[cp].wi)
end;

// ---------------------------------------------------------------------------

// This conversion is required with harupdf when using a translation with a
// a code page different from the current system one. Think about a better
// way when additional translation required.

//http://www.science.co.il/Language/Locale-Codes.asp?s=codepage

function CodePageFromLanguageId(language : string) : TCodePage;
var
  cp : integer;
begin
  language := UpperCase(language);
  if language = 'CN' then cp :=  936 else
  if language = 'CZ' then cp := 1250 else
  if language = 'DE' then cp := 1252 else
  if language = 'EN' then cp := 1252 else
  if language = 'ES' then cp := 1252 else
  if language = 'FR' then cp := 1252 else
  if language = 'HU' then cp := 1250 else
  if language = 'RU' then cp := 1251 else
  if language = 'SK' then cp := 1250;

  case cp of
     936 : Result := euc_cn;
    1250 : Result := cp1250;
    1251 : Result := cp1251;
    1252 : Result := cp1252;
    else   Result := CurrentCodePage
  end
end;

// ---------------------------------------------------------------------------

initialization
  Initialize
finalization
  Finalize
end.
