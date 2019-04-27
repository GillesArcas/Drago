// ---------------------------------------------------------------------------
// -- Drago -- Interface to some Windows API ----------------- WinUtils.pas --
// ---------------------------------------------------------------------------

unit WinUtils;

// ---------------------------------------------------------------------------

interface

uses
  Graphics, Classes,
  Types,
  ShlObj, ActiveX;

function  IsXP : boolean;
function  GetWindowsDirectory : string;
function  GetLocalAppData : string;
function  GetLocalAppDataW : WideString;
function  GetCommonAppData : string;
function  GetTempPath : string;
function  MkTempDir(const s : string) : string;
procedure RdTempDir(const dir : string);
function  GetLogicalDrives : string;
function  AvailPhysicalMem : int64;
function  MicroTimer : int64;
function  IsFileInUse(fileName: string) : boolean;
function  LoadCursorFromFile(curName : string) : LongWord;
function  IsOLEInstalled(name : string) : boolean;
function  IsOLERunning(name : string) : boolean;
procedure Sleep(ms : integer);
procedure OverwriteProcedure(OldProcedure, NewProcedure: pointer);

// ---------------------------------------------------------------------------

implementation

uses
  Windows, Messages, SysUtils, ComObj, ShellAPI,
  ShFolder;

// -- Search for Windows folder ----------------------------------------------

function GetWindowsDirectory : string;
var
  len : dword;
  dir : string;
begin
  SetLength(dir, MAX_PATH);
  len := Windows.GetWindowsDirectory(PChar(dir), MAX_PATH);
  SetLength(dir, len);

  Result := dir
end;

// -- Search for local and common application data folders -------------------

function GetLocalAppData : string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path : array[0 .. MAX_PATH] of char;
begin
  SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @path[0]);
  Result := path
end;

function GetLocalAppDataW : WideString;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path : array[0 .. MAX_PATH] of WideChar;
begin
  SHGetFolderPathW(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @path[0]);
  Result := path
end;

function GetCommonAppData : string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path : array[0 .. MAX_PATH] of char;
begin
  SHGetFolderPath(0, CSIDL_COMMON_APPDATA, 0, SHGFP_TYPE_CURRENT, @path[0]);
  Result := path
end;

// -- Search for Windows temporary folder ------------------------------------

function GetTempPath : string;
var
  len : dword;
  dir : string;
begin
  SetLength(dir, MAX_PATH);
  len := Windows.GetTempPath(MAX_PATH, PChar(dir));
  SetLength(dir, len);

  Result := dir
end;

// FPC : GetTempDir;


// -- Creation and destruction of temp folder --------------------------------

function MkTempDir(const s : string) : string;
var
  dir : string;
begin
  dir := GetTempPath;
  dir := IncludeTrailingPathDelimiter(dir) + s + '-Tmp-Files';
  if DirectoryExists(dir)
    then // nop
    else CreateDir(dir);

  Result := dir
end;

procedure RdTempDir(const dir : string);
var
  sr : TSearchRec;
begin
  if FindFirst(dir + '\*.*', faAnyFile, sr) = 0 then
    repeat
      DeleteFile(dir + '\' + sr.name);
    until FindNext(sr) <> 0;
  FindClose(sr);

  RemoveDir(dir)
end;

// -- Search for logical drive units -----------------------------------------
//
// Returns a string made of drive unit letters, e.g. 'ACD'

function GetLogicalDrives : string;
var
  buffer : array[0 .. 254] of char;
  i : integer;
begin
  FillChar(buffer, 255, 0);
  Windows.GetLogicalDriveStrings(254, buffer);
  Result := '';
  for i := 0 to 254 do
    if (buffer[i] >= 'A') and (buffer[i] <= 'Z')
      then Result := Result + buffer[i]
end;

// -- Memory -----------------------------------------------------------------

function AvailPhysicalMem : int64;
var
  memStatus : TMemoryStatus;
begin
  GlobalMemoryStatus(memStatus);
  Result := memStatus.dwAvailPhys
end;

// -- Microsecond timer ------------------------------------------------------

var
  MicroTimer_Start : int64 = -1;

function MicroTimer : int64;
var
  freq, t : int64;
begin
  QueryPerformanceCounter(t);

  if MicroTimer_Start < 0
    then
      begin
        Result := -1;
        MicroTimer_Start := t
      end
    else
      begin
        QueryPerformanceFrequency(freq);
        freq := freq div 1000000;

        Result := (t - MicroTimer_Start) div freq;
        MicroTimer_Start := -1
      end
end; 
        
// -- Test if a file is already used by another process ----------------------

// http://www.scalabium.com/faq/dct0066.htm

function IsFileInUse(fileName: string) : boolean;
var
  hFileRes: HFILE;
begin
  Result := False;

  if not FileExists(FileName)
    then exit;

  hFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);

  Result := (hFileRes = INVALID_HANDLE_VALUE);
  if not Result then
     CloseHandle(hFileRes)
end;

// -- Loading of cursor ------------------------------------------------------

function LoadCursorFromFile(curName : string) : LongWord;
begin
  Result := Windows.LoadCursorFromFile(PChar(curName))
end;

// -- Detection of OLE processes ---------------------------------------------

function IsOLEInstalled(name : string) : boolean;
var
  ClassID : TCLSID;
begin
  Result := CLSIDFromProgID(PWideChar(WideString(name)), ClassID) = S_OK
end;

function IsOLERunning(name : string) : boolean;
var
  ClassID : TCLSID;
  unknown : IUnknown;
begin
  try
    ClassID := ProgIDToClassID(name);
    Result := GetActiveObject(ClassID, nil, unknown) = S_OK
  except
    Result := False
  end;
end;

// -- Hooking a function -----------------------------------------------------

// -- Call : OverwriteProcedure(@ShortcutToText, @MyShortcutToText)

procedure OverwriteProcedure(OldProcedure, NewProcedure : pointer);
var
  x: pchar;
  y: integer;
  ov2, ov: cardinal;
begin
  x := PChar(OldProcedure);
  if not VirtualProtect(Pointer(x), 5, PAGE_EXECUTE_READWRITE, @ov) then
    RaiseLastOSError;

  x[0] := char($E9);
  y := integer(NewProcedure) - integer(OldProcedure) - 5;
  x[1] := char(y and 255);
  x[2] := char((y shr 8) and 255);
  x[3] := char((y shr 16) and 255);
  x[4] := char((y shr 24) and 255);

  if not VirtualProtect(Pointer(x), 5, ov, @ov2) then
    RaiseLastOSError;
end;

// -- Select folder ----------------------------------------------------------

(*
//http://www.cryer.co.uk/brian/delphi/howto_browseforfolder.htm

var
  lg_StartFolder: String;

//functions
//no need to declare these anywhere at the top of the unit
function BrowseForFolderCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
     SendMessage(Wnd,BFFM_SETSELECTION, 1, Integer(@lg_StartFolder[1]));
  result := 0;
end;

function BrowseForFolder(const browseTitle: String;
        const initialFolder: String =''): String;
var
  browse_info: TBrowseInfo;
  folder: array[0..MAX_PATH] of char;
  find_context: PItemIDList;
begin
  FillChar(browse_info,SizeOf(browse_info),#0);
  lg_StartFolder := initialFolder;
  browse_info.pszDisplayName := @folder[0];
  browse_info.lpszTitle := PChar(browseTitle);
  browse_info.ulFlags := BIF_RETURNONLYFSDIRS;
  browse_info.hwndOwner := Application.Handle;
  if initialFolder <> '' then
    browse_info.lpfn := BrowseForFolderCallBack;
  find_context := SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
    result := folder
    else
    result := '';
    GlobalFreePtr(find_context);
  end
  else
    result := '';
end;
*)

// -- Detection of OS version ------------------------------------------------

(*
http://www.delphidabbler.com/articles?article=23

Major Version | Minor Version | Windows 9x Platform | Windows NT Platform
4             | 0             | Windows 95          | Windows NT 4
4             | 10            | Windows 98          | -
4             | 90            | Windows Me          | -
5             | 0             | -                   | Windows 2000
5             | 1             | -                   | Windows XP
5             | 2             | -                   | Windows Server 2003
*)

function IsXP : boolean;
begin
  Result := (Win32Platform = VER_PLATFORM_WIN32_NT) and
            (Win32MajorVersion = 5) and
            (Win32MinorVersion = 1)
end;

// -- Tempo ------------------------------------------------------------------

procedure Sleep(ms : integer);
begin
  Windows.Sleep(ms)
end;

// ---------------------------------------------------------------------------

end.

