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
procedure RawProcessMessages;
function  MicroTimer : int64;
function  IsFileInUse(fileName: string) : boolean;
function  LoadCursorFromFile(curName : string) : LongWord;
function  IsOLEInstalled(name : string) : boolean;
function  IsOLERunning(name : string) : boolean;
procedure Sleep(ms : integer);
procedure MakeNumericOnly(Handle: THandle);
function  IsMetafileCanvas(canvas : TCanvas) : boolean;
procedure CancelXPMan(x : TComponent);
procedure OverwriteProcedure(OldProcedure, NewProcedure: pointer);
function  Sto_ShellExecute(const FileName, Parameters: String; var ExitCode: DWORD;
                           const Wait: DWORD = 0; const Hide: Boolean = False): Boolean;

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

// -- Console process messages -----------------------------------------------

function RawProcessMessage(var msg : TMsg) : boolean;
begin
  Result := False;

  if PeekMessage(msg, 0, 0, 0, PM_REMOVE)
    then
      if msg.Message = WM_QUIT
        then Result := False
        else
          begin
            Result := True;
            TranslateMessage(msg);
            DispatchMessage(msg)
          end
end;

procedure RawProcessMessages;
var
  msg : TMsg;
begin
  while RawProcessMessage(msg) do {loop}
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

// -- Misc -------------------------------------------------------------------
// ES_RIGHT available

procedure MakeNumericOnly(Handle: THandle);
begin
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) or ES_NUMBER);
end;

function IsMetafileCanvas(canvas : TCanvas) : boolean;
var
  x : integer;
begin
  x := GetDeviceCaps(canvas.Handle, TECHNOLOGY);
  Result := (x and DT_METAFILE) = DT_METAFILE
end;

procedure CancelXPMan(x : TComponent);
var
  i : integer;
begin
  with x do
    begin
      for i := 0 To ComponentCount - 1 do
        begin
          (*
          //if Components[i] is TWinControl
          //   then SetWindowTheme(TWinControl(Components[i]).Handle, nil, ' ');
          if Components[i] is TButton
            then SetWindowTheme(TButton(Components[i]).Handle, nil, ' ');
          if Components[i] is TPanel
            then
              if TPanel(Components[i]).Name = 'OpenPictureDialog'
                then
                else SetWindowTheme(TPanel(Components[i]).Handle, nil, ' ');
          CancelXPMan(Components[i])
          *)
        end
    end
end;

// -- Interface to ShellExecute ----------------------------------------------

(*
procedure ShellExecuteModal(exeFile, args, dir : string; var exitCode : integer);
var
  SEInfo : TShellExecuteInfo;
  exitValue : DWORD;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);

  with SEInfo do
    begin
      fMask := SEE_MASK_NOCLOSEPROCESS;
      Wnd := Application.Handle;
      lpFile := PChar(exeFile);
      lpParameters := PChar(args);
      lpDirectory := PChar(dir);
      nShow := SW_SHOWNORMAL
    end;

  if not ShellExecuteEx(@SEInfo)
    then exitCode := -1
    else
      begin
        repeat
          //Application.ProcessMessages;
          GetExitCodeProcess(SEInfo.hProcess, exitValue);
        until (ExitCode <> STILL_ACTIVE) or Application.Terminated;

        exitCode := exitValue
      end
end;
*)

function Sto_ShellExecute(const FileName, Parameters: String; var ExitCode: DWORD;
  const Wait: DWORD = 0; const Hide: Boolean = False): Boolean;
var
  myInfo: SHELLEXECUTEINFO;
  iWaitRes: DWORD;
begin
  // prepare SHELLEXECUTEINFO structure
  ZeroMemory(@myInfo, SizeOf(SHELLEXECUTEINFO));
  myInfo.cbSize := SizeOf(SHELLEXECUTEINFO);
  myInfo.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI;
  myInfo.lpFile := PChar(FileName);
  myInfo.lpParameters := PChar(Parameters);
  if Hide then
    myInfo.nShow := SW_HIDE
  else
    myInfo.nShow := SW_SHOWNORMAL;
  // start file
  ExitCode := 0;
  //!!Result := ShellExecuteEx(@myInfo);
  // if process could be started
  if Result then
  begin
    // wait on process ?
    if (Wait > 0) then
    begin
    iWaitRes := WaitForSingleObject(myInfo.hProcess, Wait);
    // timeout reached ?
    if (iWaitRes = WAIT_TIMEOUT) then
    begin
        Result := False;
        TerminateProcess(myInfo.hProcess, 0);
    end;
    // get the exitcode
    GetExitCodeProcess(myInfo.hProcess, ExitCode);
    end;
    // close handle, because SEE_MASK_NOCLOSEPROCESS was set
    CloseHandle(myInfo.hProcess);
  end;
end;

// --

// V1 by Pat Ritchey, V2 by P.Below
function WinExecAndWait32(CommandLine: string; ShowWindow: Word): DWORD;
 
  procedure WaitFor(ProcessHandle: THandle);
  var
    msg: TMsg;
    ret: DWORD;
  begin
    repeat
      ret := MsgWaitForMultipleObjects(
               1,             { 1 handle to wait on }
               ProcessHandle, { the handle }
               False,         { wake on any event }
               INFINITE,      { wait without timeout }
               QS_PAINT or    { wake on paint messages }
               QS_SENDMESSAGE { or messages from other threads }
               );
      if ret = WAIT_FAILED then Exit; { can do little here }
      if ret = (WAIT_OBJECT_0 + 1) then
      begin
        { Woke on a message, process paint messages only. Calling
          PeekMessage gets messages send from other threads processed. }
        while PeekMessage(msg, 0, WM_PAINT, WM_PAINT, PM_REMOVE) do
          DispatchMessage(msg)
      end
    until ret = WAIT_OBJECT_0
  end;
 
var
  zAppName: array[0..512] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  StrPCopy(zAppName, CommandLine);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := ShowWindow;
  if not CreateProcess(nil,
    zAppName,             { pointer to command line string }
    nil,                  { pointer to process security attributes }
    nil,                  { pointer to thread security attributes }
    False,                { handle inheritance flag }
    CREATE_NEW_CONSOLE or { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,                  { pointer to new environment block }
    nil,                  { pointer to current directory name }
    StartupInfo,          { pointer to STARTUPINFO }
    ProcessInfo)          { pointer to PROCESS_INF }
  then
    Result := DWORD(-1)   { failed, GetLastError has error code }
  else
  begin
     WaitFor(ProcessInfo.hProcess);
     GetExitCodeProcess(ProcessInfo.hProcess, Result);
     CloseHandle(ProcessInfo.hProcess);
     CloseHandle(ProcessInfo.hThread)
  end
end;

// ---------------------------------------------------------------------------

end.

// -- Version number ---------------------------------------------------------
// -- not used

function Version : string;
var
  S         : string;
  n, Len    : DWORD;
  Buf, Value: PChar;
begin
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n) * 2;
  if n = 0
    then Result := ''
    else
      begin
        Buf := AllocMem(n);
        GetFileVersionInfo(PChar(S), 0, n, Buf);
        if VerQueryValue(Buf,
                    PChar('StringFileInfo\040904E4\' +
                      //'Version du fichier'),
                      'Organisation'),
                    Pointer(Value), Len)
          then Result := Value
          else Result := '';
        FreeMem(Buf, n)
      end
end;

// ---------------------------------------------------------------------------

