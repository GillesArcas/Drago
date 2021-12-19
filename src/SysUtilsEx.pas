unit SysUtilsEx;

interface

uses
  Classes, ClassesEx;

type
  TAddFileOption = (afCatPath, afIncludeFolders, afIncludeFiles);
  TAddFileOptions = set of TAddFileOption;

function WideIncludeTrailingPathDelimiter(const s : WideString) : WideString;
function WideExcludeTrailingPathDelimiter(const s : WideString) : WideString;
function WideExtractFilePath (const filename : WideString): WideString;
function WideExtractFileDir  (const filename : WideString): WideString;
function WideExtractFileName (const filename : WideString): WideString;
function WideExtractFileExt  (const filename : WideString): WideString;
function WideChangeFileExt   (const filename, extension : WideString) : WideString;
function WideExpandFileName  (const filename : WideString) : WideString;
function WideAbsolutePath    (const relPath, basePath: WideString): WideString;
function WideRelativePath    (const absPath, basePath: WideString): WideString;
function WideGetCurrentDir   () : WideString;
function WideDirectoryExists (const directory : WideString) : boolean;
function WideFileOpen        (const filename : WideString; mode: LongWord): integer;
function WideCopyFile        (const FromFile, ToFile: WideString; FailIfExists: Boolean): Boolean;
function WideDeleteFile      (const filename : WideString) : Boolean;
function WideRenameFile      (const oldName, newName : WideString) : Boolean;
function WideFileGetAttr     (const filename : WideString) : integer;
function WideFileExists      (const filename : WideString) : Boolean;
function WideApplicationExeName : WideString;

procedure AddFilesToList     (list : TStringList; path, filter : string); overload;
procedure AddFilesToList     (list : TStringList;
                              path : String;
                              options : TAddFileOptions;
                              const mask : string = '*.*'); overload;
procedure AddFolderToList    (list : TStringList;
                              path, mask : String;
                              subFolders : boolean = False);
procedure WideAddFilesToList (list : TWideStringList;
                              path : WideString;
                              options : TAddFileOptions;
                              const mask : WideString = '*.*');
procedure WideAddFolderToList(list : TWideStringList;
                              path, mask : WideString;
                              subFolders : boolean = False);

implementation

uses
  SysUtils
{$ifndef FPC},
  Windows,
  TntSysUtils,
  TntForms
{$endif}
  ;

{$ifndef FPC}

// -- File names

function WideIncludeTrailingPathDelimiter(const s : WideString) : WideString;
begin
  Result := TntSysUtils.WideIncludeTrailingPathDelimiter(s)
end;

function WideExcludeTrailingPathDelimiter(const s : WideString) : WideString;
begin
  Result := TntSysUtils.WideExcludeTrailingPathDelimiter(s)
end;

function WideExtractFilePath(const filename : WideString): WideString;
begin
  Result := TntSysUtils.WideExtractFilePath(filename)
end;

function WideExtractFileDir(const filename : WideString): WideString;
begin
  Result := TntSysUtils.WideExtractFileDir(filename)
end;

function WideExtractFileName(const filename : WideString): WideString;
begin
  Result := TntSysUtils.WideExtractFileName(filename)
end;

function WideExtractFileExt(const filename : WideString): WideString;
begin
  Result := TntSysUtils.WideExtractFileExt(filename)
end;

function WideChangeFileExt(const filename, extension : WideString): WideString;
begin
  Result := TntSysUtils.WideChangeFileExt(filename, extension)
end;

function WideExpandFileName(const filename : WideString): WideString;
begin
  Result := TntSysUtils.WideExpandFileName(filename)
end;

function PathRelativePathToW(pszPath: PWideChar; pszFrom: PWideChar; dwAttrFrom: DWORD;
                             pszTo: PWideChar; dwAtrTo: DWORD): LongBool; stdcall;
  external 'shlwapi.dll' name 'PathRelativePathToW';
function PathIsRelativeW(pszPath: PWideChar): LongBool; stdcall;
  external 'shlwapi.dll' name 'PathIsRelativeW';
function PathCanonicalizeW(lpszDst: PWideChar; lpszSrc: PWideChar): LongBool; stdcall;
  external 'shlwapi.dll' name 'PathCanonicalizeW';

function WideAbsolutePath(const relPath, basePath: WideString): WideString;
var
  Dst: array[0..MAX_PATH-1] of WideChar;
begin
  if PathIsRelativeW(PWideChar(relPath))
    then
      begin
        PathCanonicalizeW(@dst[0], PWideChar(WideIncludeTrailingBackslash(basePath) + relPath));
        Result := dst
      end
    else Result := relPath
end;

function WideRelativePath(const absPath, basePath: WideString): WideString;
var
  path: array[0 .. MAX_PATH - 1] of WideChar;
begin
  if PathIsRelativeW(PWideChar(absPath))
    then Result := absPath
    else
      begin
        PathRelativePathToW(@path[0], PWideChar(basePath),
                            FILE_ATTRIBUTE_DIRECTORY, PWideChar(absPath), 0);
        Result := path;
        
        if (Length(Result) > 1) and (Result[1] = '\')
          // sub folder of application folder
          then Result := '.' + Result
      end
end;

function WideGetCurrentDir() : WideString;
begin
  Result := TntSysUtils.WideGetCurrentDir()
end;

// -- Existence of directory (unicode filename)

function WideDirectoryExists(const directory : WideString) : boolean;
var
  code: Cardinal;
begin
  code := GetFileAttributesW(Pointer(directory));
  Result := (code <> $FFFFFFFF) and (code and FILE_ATTRIBUTE_DIRECTORY <> 0);
end;

// -- File operations

function WideFileOpen(const FileName: WideString; Mode: LongWord): Integer;
begin
  Result := TntSysUtils.WideFileOpen(FileName, Mode)
end;

function WideCopyFile(const FromFile, ToFile: WideString; FailIfExists: Boolean): Boolean;
begin
  Result := TntSysUtils.WideCopyFile(FromFile, ToFile, FailIfExists)
end;

function WideDeleteFile(const filename : WideString) : Boolean;
begin
  Result := TntSysUtils.WideDeleteFile(filename)
end;

function WideRenameFile(const oldName, newName : WideString) : Boolean;
begin
  Result := TntSysUtils.WideRenameFile(oldName, newName)
end;

function WideFileGetAttr(const filename : WideString) : integer;
begin
  Result := TntSysUtils.WideFileGetAttr(filename)
end;

function WideFileExists(const filename : WideString) : Boolean;
begin
  Result := TntSysUtils.WideFileExists(filename)
end;

function WideApplicationExeName : WideString;
begin
  Result := TntApplication.ExeName
end;

{$else}

// -- File names

function WideIncludeTrailingPathDelimiter(const s : WideString) : WideString;
begin
  Result := IncludeTrailingPathDelimiter(s)
end;

function WideExcludeTrailingPathDelimiter(const s : WideString) : WideString;
begin
  Result := IncludeTrailingPathDelimiter(s)
end;

function WideExtractFilePath(const filename : WideString): WideString;
begin
  Result := ExtractFilePath(filename)
end;

function WideExtractFileDir(const filename : WideString): WideString;
begin
  Result := ExtractFileDir(filename)
end;

function WideExtractFileName(const filename : WideString): WideString;
begin
  Result := ExtractFileName(filename)
end;

function WideExtractFileExt(const filename : WideString): WideString;
begin
  Result := ExtractFileExt(filename)
end;

function WideChangeFileExt(const filename, extension : WideString): WideString;
begin
  Result := ChangeFileExt(filename, extension)
end;

function WideExpandFileName(const filename : WideString): WideString;
begin
  Result := ExpandFileName(filename)
end;

function WideAbsolutePath(const relPath, basePath: WideString): WideString;
begin
  Assert(False, 'To be implemented');
  Result := ''
end;

function WideRelativePath(const absPath, basePath: WideString): WideString;
begin
  Assert(False, 'To be implemented');
  Result := ''
end;

function WideGetCurrentDir() : WideString;
begin
  Result := GetCurrentDir()
end;

// -- Existence of directory (unicode filename)

function WideDirectoryExists(const directory : WideString) : boolean;
begin
  Result := DirectoryExists(directory)
end;

// -- File operations

function WideFileOpen(const FileName: WideString; Mode: LongWord): Integer;
begin
  Result := SysUtils.FileOpen(FileName, Mode)
end;

function WideCopyFile(const FromFile, ToFile: WideString; FailIfExists: Boolean): Boolean;
begin
  Assert(False)
end;

function WideDeleteFile(const filename : WideString) : Boolean;
begin
  Result := DeleteFile(filename)
end;

function WideRenameFile(const oldName, newName : WideString) : Boolean;
begin
  Result := WideRenameFile(oldName, newName)
end;

function WideFileGetAttr(const filename : WideString) : integer;
begin
  Result := FileGetAttr(filename)
end;

function WideFileExists(const filename : WideString) : Boolean;
begin
  Result := FileExists(filename)
end;

function WideApplicationExeName : WideString;
begin
  Result := Application.ExeName
end;

{$endif}

// -- Search

procedure AddFilesToList(List : TStringList; path, filter : string);
var
  sr        : TSearchRec;
  FileAttrs : integer;
begin
  path := IncludeTrailingPathDelimiter(path);
  FileAttrs := faAnyFile;
  if FindFirst(path + filter, FileAttrs, sr) = 0 then
    repeat
      List.Add(path + sr.Name)
    until FindNext(sr) <> 0;
  SysUtils.FindClose(sr)
end;

procedure AddFilesToList(list : TStringList;
                         path : string;
                         options : TAddFileOptions;
                         const mask : string = '*.*');
var
  sr : TSearchRec;
  FileAttrs : integer;
  isDir : boolean;
begin
  path := IncludeTrailingPathDelimiter(path);
  FileAttrs := faAnyFile;

  if FindFirst(path + mask, FileAttrs, sr) = 0 then
    try
      repeat
        isDir := DirectoryExists(sr.Name) and (sr.Name <> '.') and (sr.Name <> '..');
        if (isDir and (afIncludeFolders in options)) or
           ((not isDir) and (afIncludeFiles in options))
          then
            if afCatPath in options
              then list.Add(path + sr.Name)
              else list.Add(sr.Name)
      until FindNext(sr) <> 0;
    finally
      SysUtils.FindClose(sr)
    end
end;

procedure AddFolderToList(list : TStringList;
                          path, mask : string;
                          subFolders : boolean = False);
var
  listFolders : TStringList;
  i : integer;
begin
  path := IncludeTrailingPathDelimiter(path);
  AddFilesToList(list, path, [afIncludeFiles, afCatPath], mask);

  if subFolders then
    begin
      listFolders := TStringList.Create;
      AddFilesToList(listFolders, path, [afIncludeFolders], '');//'*.*');

      for i := 0 to listFolders.Count - 1 do
        if (listFolders[i] <> '.') and (listFolders[i] <> '..')
          then AddFolderToList(list, path + listFolders[i], mask, subFolders);

      listFolders.Free
    end
end;

{$ifndef FPC}

procedure WideAddFilesToList(list : TWideStringList;
                             path : WideString;
                             options : TAddFileOptions;
                             const mask : WideString = '*.*');
var
  wfd : TWin32FindDataW;
  hFile : THandle;
  isDir : boolean;
begin
  path := WideIncludeTrailingPathDelimiter(path);

  hFile := FindFirstFileW(PWideChar(path + mask), wfd);

  if hFile <> INVALID_HANDLE_VALUE then
  try
    repeat
      isDir := (wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY;
      if (isDir and (afIncludeFolders in options)) or
         ((not isDir) and (afIncludeFiles in options))
        then
          if afCatPath in options
            then list.Add(path + wfd.cFileName)
            else list.Add(wfd.cFileName)
    until FindNextFileW(hFile, wfd) = False;
  finally
    Windows.FindClose(hFile)
  end
end;

procedure WideAddFolderToList(list : TWideStringList;
                              path, mask : WideString;
                              subFolders : boolean = False);
var
  listFolders : TWideStringList;
  i : integer;
begin
  path := WideIncludeTrailingPathDelimiter(path);
  WideAddFilesToList(list, path, [afIncludeFiles, afCatPath], mask);

  if subFolders then
    begin
      listFolders := TWideStringList.Create;
      WideAddFilesToList(listFolders, path, [afIncludeFolders], '*.*');

      for i := 0 to listFolders.Count - 1 do
        if (listFolders[i] <> '.') and (listFolders[i] <> '..')
          then WideAddFolderToList(list, path + listFolders[i], mask, subFolders);

      listFolders.Free
    end
end;

{$else}

procedure WideAddFilesToList(list : TWideStringList;
                             path : WideString;
                             options : TAddFileOptions;
                             const mask : WideString = '*.*');
begin
  AddFilesToList(list, path, options, mask)
end;

procedure WideAddFolderToList(list : TWideStringList;
                              path, mask : WideString;
                              subFolders : boolean = False);
begin
  AddFolderToList(list, path, mask, subFolders)
end;

{$endif}

end.
