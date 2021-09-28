// ---------------------------------------------------------------------------
// -- Drago -- Translations --------------------------------- Translate.pas --
// ---------------------------------------------------------------------------

unit Translate;

// ---------------------------------------------------------------------------

interface

uses
  Classes, StrUtils,
  ClassesEx, UnicodeUtils;

function  AllLanguages : TWideStringList;
function  LanguageCodeFromName(name : string) : string;
function  LanguageNameFromCode(code : string) : string;
procedure SetLanguage(code : string; var ok : boolean; var filename : string);
function  T(const s : string) : string;
function  TT(const s : string) : string;
function  U(const s : string) : WideString; overload;
function  U(const s : WideString) : WideString; overload;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, TntClasses,
  Std, SysUtilsEx;

// -- Declaration of class TKeyValueList -------------------------------------

type TKeyValueList = class(TTntStringList)
  destructor Destroy; override;
  procedure LoadFromFile(const filename : WideString); override;
  function Value(const s : string) : string;
  procedure Clear; override;
end;

// -- Translation data -------------------------------------------------------

var
  lng_path        : WideString;      // language file directory
  lng_files       : TWideStringList; // list of .lng filenames
  lng_names       : TWideStringList; // list of language names
  cur_translation : TKeyValueList;   // current translation list
  eng_translation : TKeyValueList;   // English default translation

// -- Language registration --------------------------------------------------
//
// called once in initialization section

procedure RegisterLanguages;
var
  tmp_translation : TWideStringList;
  i : integer;
begin
  // get calling path
  lng_path := WideExtractFilePath(WideApplicationExeName) + 'Languages\';

  // init global translation data
  lng_files        := TWideStringList.Create;
  lng_names        := TWideStringList.Create;
  cur_translation  := TKeyValueList.Create;
  eng_translation  := TKeyValueList.Create;
  lng_names.Sorted := True;  // list of language names sorted
  lng_files.Sorted := False; // list of translation files not sorted but
                             // parallel to list of language names
  // init working string list
  tmp_translation  := TWideStringList.Create;

  // find .lng files
  //WideAddFilesToList(lng_files, lng_path, [afIncludeFiles, afCatPath], 'Drago-*.lng');
  WideAddFilesToList(lng_files, lng_path, [afIncludeFiles], 'Drago-*.lng');

  // make the sorted list of "language name"|"file name"
  for i := 0 to lng_files.Count - 1 do
    begin
      tmp_translation.LoadFromFile(lng_path + lng_files[i]);
      lng_names.Add(tmp_translation.Values['$Language'] + '|' + lng_files[i])
    end;

  // list of language names is now sorted
  // removing sorted flag is required to modify items
  lng_names.Sorted := False;
  // remove now file names and add them to the list of file names
  lng_files.Clear;
  for i := 0 to lng_names.Count - 1 do
    begin
      lng_files.Add(NthWord(lng_names[i], 2, '|'));
      lng_names[i] := NthWord(lng_names[i], 1, '|')
    end;

  // free working data
  tmp_translation.Free;

  // load English default translation
  try
    cur_translation.LoadFromFile(lng_path + 'Drago-En.lng');
    eng_translation.LoadFromFile(lng_path + 'Drago-En.lng')
  except
    // todo: something
  end
end;

function AllLanguages : TWideStringList;
begin
  Result := lng_names
end;

function LanguageCodeFromName(name : string) : string;
var
  filename  : string;
  i, i1, i2 : integer;
begin
  Result := 'En'; // by default

  // search language name applying same conversion as when loading language combo
  for i := 0 to lng_names.Count - 1 do
    //if name = UTF8DecodeX(lng_names[i])
    if name = lng_names[i]
      then break;

  if i = lng_names.Count
    then exit;

  filename := lng_files[i];
  // first character of country code in filename
  i1 := Pos('-', filename) + 1;
  // last character of country code in filename
  i2 := Pos('.', filename) - 1;
  Result := Copy(filename, i1, i2 - i1 + 1)
end;

function LanguageNameFromCode(code : string) : string;
var
  filename : WideString;
begin
  filename := 'Drago-' + code + '.lng';
  Result := lng_names[lng_files.IndexOf(filename)]
end;

procedure SetLanguage(code : string; var ok : boolean; var filename : string);
begin
  filename := 'Drago-' + code + '.lng';
  try
    cur_translation.LoadFromFile(lng_path + filename);
    ok := True
  except
    ok := False
  end
end;

// -- Translation of a string ------------------------------------------------

function T(const s : string) : string;
begin
  // translate string as it is
  Result := cur_translation.Value(s);
  if Result <> ''
    then exit;

  // translate string without trailing ellipsis
  if RightStr(s, 3) = '...'
    then Result := T(LeftStr(s, Length(s) - 3)) + '...';
  if Result <> ''
    then exit;

  // translate string into English
  Result := eng_translation.Value(s);
  if Result <> ''
    then exit;

  // last solution: return string itself
  Result := s
end;

// UTF-8 version

function U(const s : string) : WideString; overload;
begin
  Result := UTF8DecodeX(T(s))
end;

function U(const s : WideString) : WideString; overload;
begin
  Result := UTF8DecodeX(T(UTF8Encode(s)))
end;

// Same a T(), used to remind of adding the translation to lng files

function TT(const s : string) : string;
begin
  Result := T(s)
end;

// -- Implementation of TKeyValueList ----------------------------------------

// -- TKeyValueList

destructor TKeyValueList.Destroy;
begin
  Clear;
  inherited
end;

procedure TKeyValueList.Clear;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    (Objects[i] as TStringObject).Free;

  inherited
end;

procedure TKeyValueList.LoadFromFile(const filename : WideString);
// load a language file into a dictionary
var
  tmp : TStringList;
  i : integer;
  name, s, key, val : string;
begin
  if IsAnsiString(filename)
    then name := filename
    else name := CopyFileToAnsiNameTmpFile(filename);

  Clear;
  Sorted := True;

  tmp := TStringList.Create;
  tmp.LoadFromFile(name);

  for i := 0 to tmp.Count - 1 do
    begin
      s := tmp[i];

      // ignore empty lines or commented lines (1st char = ';')
      if (s = '') or (Pos(';', s) = 1)
        then continue;

      key := NthWord(s, 1, '=');
      val := NthWord(s, 2, '=');
      // check for duplicated keys
      assert(IndexOf(key) < 0, 'Duplicated key ' + filename + ' ' + key + IntToStr(i));

      AddObject(key, TStringObject.Create(val))
    end;

  tmp.Free
end;

function TKeyValueList.Value(const s : string) : string;
var
  i : integer;
begin
  i := IndexOf(s);
  if i < 0
    then Result := ''
    else Result := (Objects[i] as TStringObject).FString
end;

// ---------------------------------------------------------------------------

initialization
  RegisterLanguages
finalization
  lng_files.Free;
  lng_names.Free;
  cur_translation.Free;
  eng_translation.Free
end.
