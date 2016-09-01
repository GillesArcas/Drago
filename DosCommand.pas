{
this component let you execute a dos program (exe, com or batch file) and catch
the ouput in order to put it in a memo or in a listbox, ...
  you can also send inputs.
  the cool thing of this component is that you do not need to wait the end of
the program to get back the output. it comes line by line.


 *********************************************************************
 ** maxime_collomb@yahoo.fr                                         **
 **                                                                 **
 **   for this component, i just translated C code                  **
 ** from Community.borland.com                                      **
 ** (http://www.vmlinux.org/jakov/community.borland.com/10387.html) **
 **                                                                 **
 **   if you have a good idea of improvement, please                **
 ** let me know (maxime_collomb@yahoo.fr).                          **
 **   if you improve this component, please send me a copy          **
 ** so i can put it on www.torry.net.                               **
 *********************************************************************

 History :
2008-01-11 : gal : CurrentDirectory, Synchronize OnTerminated, Execute with
                   status
                   Beware if a line received is not complete (OutputType = (
                   tBeginningOfLine) it will be sent again but completed.
2002-02-23 : tk


 ---------
 18-05-2001 : version 2.0
              - Now, catching the beginning of a line is allowed (usefull if the
                prog ask for an entry) => the method OnNewLine is modified
              - Now can send inputs
              - Add a couple of FreeMem for sa & sd [thanks Gary H. Blaikie]
 07-05-2001 : version 1.2
              - Sleep(1) is added to give others processes a chance
                [thanks Hans-Georg Rickers]
              - the loop that catch the outputs has been re-writen by
                Hans-Georg Rickers => no more broken lines
 30-04-2001 : version 1.1
              - function IsWinNT() is changed to
                (Win32Platform = VER_PLATFORM_WIN32_NT) [thanks Marc Scheuner]
              - empty lines appear in the redirected output
              - property OutputLines is added to redirect output directly to a
                memo, richedit, listbox, ... [thanks Jean-Fabien Connault]
              - a timer is added to offer the possibility of ending the process
                after XXX sec. after the beginning or YYY sec after the last
                output [thanks Jean-Fabien Connault]
              - managing process priorities flags in the CreateProcess
                thing [thanks Jean-Fabien Connault]
 20-04-2001 : version 1.0 on www.torry.net
 *******************************************************************
 How to use it :
 ---------------
  - just put the line of command in the property 'CommandLine'
  - execute the process with the method 'Execute'
  - if you want to stop the process before it has ended, use the method 'Stop'
  - if you want the process to stop by itself after XXX sec of activity,
    use the property 'MaxTimeAfterBeginning'
  - if you want the process to stop after XXX sec without an output,
    use the property 'MaxTimeAfterLastOutput'
  - to directly redirect outputs to a memo or a richedit, ...
    use the property 'OutputLines'
    (DosCommand1.OutputLnes := Memo1.Lines;)
  - you can access all the outputs of the last command with the property 'Lines'
  - you can change the priority of the process with the property 'Priority'
    value of Priority must be in [HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
    NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS]
  - you can have an event for each new line and for the end of the process
    with the events 'procedure OnNewLine(Sender: TObject; NewLine: string;
    OutputType: TOutputType);' and 'procedure OnTerminated(Sender: TObject);'
  - you can send inputs to the dos process with 'SendLine(Value: string;
    Eol: Boolean);'. Eol is here to determine if the program have to add a
    CR/LF at the end of the string.
 *******************************************************************
 How to call a dos function (win 9x/Me) :
 ----------------------------------------

 Example : Make a dir :
 ----------------------
  - if you want to get the result of a 'c:\dir /o:gen /l c:\windows\*.txt'
    for example, you need to make a batch file
    --the batch file : c:\mydir.bat
        @echo off
        dir /o:gen /l %1
        rem eof
    --in your code
        DosCommand.CommandLine := 'c:\mydir.bat c:\windows\*.txt';
        DosCommand.Execute;

  Example : Format a disk (win 9x/Me) :
  -------------------------
  --a batch file : c:\myformat.bat
      @echo off
      format %1
      rem eof
  --in your code
      var diskname: string;
      --
      DosCommand1.CommandLine := 'c:\myformat.bat a:';
      DosCommand1.Execute; //launch format process
      DosCommand1.SendLine('', True); //equivalent to press enter key
      DiskName := 'test';
      DosCommand1.SendLine(DiskName, True); //enter the name of the volume
 *******************************************************************}

unit DosCommand;

interface

uses
  Windows, Messages, SysUtils, Classes,
  Forms,
  ExtCtrls,
  TntWindows
  ;

type
  TCreatePipeError = class(Exception); //exception raised when a pipe cannot be created
  TCreateProcessError = class(Exception); //exception raised when the process cannot be created
  TOutputType = (otEntireLine, otBeginningOfLine); //to know if the newline is finished.
  TReturnCode = (rcCRLF, rcLF);

  TProcessTimer = class(TTimer) //timer for stopping the process after XXX sec
  private
    FSinceBeginning: Integer;
    FSinceLastOutput: Integer;
    procedure MyTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Beginning; //call this at the beginning of a process
    procedure NewOutput; //call this when a new output is received
    procedure Ending; //call this when the process is terminated
    property SinceBeginning: Integer read FSinceBeginning;
    property SinceLastOutput: Integer read FSinceLastOutput;
  end;

  TNewLineEvent = procedure(Sender: TObject; NewLine: string; OutputType: TOutputType) of object;
    //  これ(↓)は不要ではないか？。
  //TTerminateEvent = procedure(Sender: TObject; ExitCode: LongWord) of object;
  TTerminateEvent = procedure of object;

  TShowWindow = (swHIDE, swMAXIMIZE, swMINIMIZE, swRESTORE, swSHOW, swSHOWDEFAULT, swSHOWMAXIMIZED, swSHOWMINIMIZED, swSHOWMINNOACTIVE, swSHOWNA, swSHOWNOACTIVATE, swSHOWNORMAL);
  TCreationFlag = (fCREATE_DEFAULT_ERROR_MODE, fCREATE_NEW_CONSOLE, fCREATE_NEW_PROCESS_GROUP, fCREATE_SEPARATE_WOW_VDM, fCREATE_SHARED_WOW_VDM, fCREATE_SUSPENDED, fCREATE_UNICODE_ENVIRONMENT, fDEBUG_PROCESS, fDEBUG_ONLY_THIS_PROCESS, fDETACHED_PROCESS);

  TDosThreadStatus = ( dtsAllocatingMemory , dtsAllocateMemoryFail ,
                       dtsCreatingPipes    , dtsCreatePipesFail    ,
                       dtsCreatingProcess  , dtsCreateProcessFail  ,
                       dtsRunning          , dtsRunningError       ,
                       dtsSuccess,
                       dtsUserAborted,
                       dtsTimeOut );

  TDosCommand = class;

  TDosThread = class(TThread) //the thread that is waiting for outputs through the pipe
  private
    FOwner: TDosCommand;
    FCommandLine: WideString;
    FCurrentDirectory: WideString;
    FTimer: TProcessTimer;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FOnNewLine: TNewLineEvent;
    FOnTerminated: TTerminateEvent;
    FCreatePipeError: TCreatePipeError;
    FCreateProcessError: TCreateProcessError;
    FPriority: Integer;
    FShowWindow: TShowWindow;
    FCreationFlag: TCreationFlag;
    //
    FProcessInfo_SHARED: ^PROCESS_INFORMATION;
    FOutputStr: String;
    FOutputType: TOutputType;
    procedure FExecute;
  protected
    procedure Execute; override; //call this to create the process
    procedure AddString;
    procedure AddString_SHARED(Str: string; OutType: TOutputType);
  public
    pi: PROCESS_INFORMATION;
    InputLines_SHARED: TstringList;
    FLineBeginned: Boolean;
    FActive: Boolean;
    constructor Create( AOwner: TDosCommand );
    function IsAlive : boolean;
  end;

  TDosCommand = class(TComponent) //the component to put on a form
  private
    FTimer: TProcessTimer;
    FThread: TDosThread;
    FThreadStatus: TDosThreadStatus;
    FCommandLine: WideString;
    FCurrentDirectory: WideString;
    FLines_SHARED: TStringList;
    FInputLines_SHARED: TStringList;
    FOutputLines_SHARED: TStrings;
    FInputToOutput: Boolean;
    FOnNewLine: TNewLineEvent;
    FOnTerminated: TTerminateEvent;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FPriority: Integer; //[HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
                        // NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS]
    FShowWindow: TShowWindow;
    FCreationFlag: TCreationFlag;
    FExitCode: Integer;
    FStarted: Boolean;
    //
    //
    FProcessInfo_SHARED: PROCESS_INFORMATION;
    FReturnCode: TReturnCode;
    FOutputReturnCode: TReturnCode;
    FSync :TMultiReadExclusiveWriteSynchronizer;

    function GetPrompting:boolean;
    function GetActive:boolean;
    function GetSinceBeginning: Integer;
    function GetSinceLastOutput:integer;
    procedure SetOutputLines_SHARED(Value: TStrings);
  protected
    { D馗larations prot馮馥s }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override; //++ tk
    procedure Execute (var ok : boolean); //the user call this to execute the command
    function Execute2: Integer; //the user call this to execute the command
    procedure Stop; //the user can stop the process with this method
    procedure SendLine(Value: string; Eol: Boolean); //add a line in the input pipe
    function IsAlive : boolean;
    property OutputLines: TStrings read FOutputLines_SHARED write SetOutputLines_SHARED;
      //can be Lines_SHARED of a memo, a richedit, a listbox, ...
    property Lines: TStringList read FLines_SHARED;
       //if the user want to access all the outputs of a process, he can use this property
    property Priority: Integer read FPriority write FPriority; //priority of the process
    property Active: Boolean read GetActive;
    property Prompting:boolean read GetPrompting;
    property SinceBeginning: Integer read GetSinceBeginning;
    property SinceLastOutput:integer read GetSinceLastOutput;

    property ExitCode: Integer read FExitCode write FExitCode;
    property Started: Boolean read FStarted write FStarted;
    //
    //
    property ProcessInfo:PROCESS_INFORMATION read FProcessInfo_SHARED;
    property ThreadStatus:TDosThreadStatus read FThreadStatus write FThreadStatus;
    property Sync: TMultiReadExclusiveWriteSynchronizer read FSync;
  published
    property CommandLine: WideString read FCommandLine write FCommandLine;
      //command to execute
    property CurrentDirectory: WideString read FCurrentDirectory write FCurrentDirectory;
      //working directory for new process
    property OnNewLine: TNewLineEvent read FOnNewLine write FOnNewLine;
      //event for each new line that is received through the pipe
    property OnTerminated: TTerminateEvent read FOnTerminated write FOnTerminated;
      //event for the end of the process (normally, time out or by user (DosCommand.Stop;))
    property InputToOutput: Boolean read FInputToOutput write FInputToOutput;
      //check it if you want that the inputs appear also in the outputs
    property MaxTimeAfterBeginning: Integer read FMaxTimeAfterBeginning
      write FMaxTimeAfterBeginning; //maximum time of execution
    property MaxTimeAfterLastOutput: Integer read FMaxTimeAfterLastOutput
      write FMaxTimeAfterLastOutput; //maximum time of execution without an output
    property ShowWindow : TShowWindow read FShowWindow write FShowWindow;
      // window type
    property CreationFlag : TCreationFlag read FCreationFlag write FCreationFlag;
      // window type
    property ReturnCode: TReturnCode read FReturnCode write FReturnCode;
    property OutputReturnCode: TReturnCode read FOutputReturnCode;
    //==
  end;

procedure Register;

implementation

type TCharBuffer = array[0..MaxInt - 1] of Char;

const ShowWindowValues : array[0..11] of Integer = (SW_HIDE, SW_MAXIMIZE, SW_MINIMIZE, SW_RESTORE, SW_SHOW, SW_SHOWDEFAULT, SW_SHOWMAXIMIZED, SW_SHOWMINIMIZED, SW_SHOWMINNOACTIVE, SW_SHOWNA, SW_SHOWNOACTIVATE, SW_SHOWNORMAL);
const CreationFlagValues : array[0..9] of Integer = (CREATE_DEFAULT_ERROR_MODE, CREATE_NEW_CONSOLE, CREATE_NEW_PROCESS_GROUP, CREATE_SEPARATE_WOW_VDM, CREATE_SHARED_WOW_VDM, CREATE_SUSPENDED, CREATE_UNICODE_ENVIRONMENT, DEBUG_PROCESS, DEBUG_ONLY_THIS_PROCESS, DETACHED_PROCESS);

//------------------------------------------------------------------------------

// - TStartupInfoW is not defined in Windows.pas but is defined in TntWindows.pas
// - GetStartupInfoW is defined in Windows.pas but not using TStartupInfoW. It is
//   neither defined in TntWindows.pas and therefore is defined here.

procedure GetStartupInfoW(var lpStartupInfo: TStartupInfoW); stdcall;
external kernel32 name 'GetStartupInfoW';

//------------------------------------------------------------------------------

constructor TProcessTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Enabled := False; //timer is off
  OnTimer := MyTimer;
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.MyTimer(Sender: TObject);
begin
  Inc(FSinceBeginning);
  Inc(FSinceLastOutput);
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Beginning;
begin
  Interval := 1000; //time is in sec
  FSinceBeginning := 0; //this is the beginning
  FSinceLastOutput := 0;
  Enabled := True; //set the timer on
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.NewOutput;
begin
  FSinceLastOutput := 0; //a new output has been caught
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Ending;
begin
  Enabled := False; //set the timer off
end;

//------------------------------------------------------------------------------

procedure TDosThread.FExecute;
const
  MaxBufSize = 1024;
var
  pBuf: ^TCharBuffer; //i/o buffer
  iBufSize: Cardinal;
  app_spawn: PWideChar;
  //si: STARTUPINFO;
  si : TStartupInfoW;
  sa: PSECURITYATTRIBUTES; //security information for pipes
  sd: PSECURITY_DESCRIPTOR;
  //pi: PROCESS_INFORMATION;
  newstdin, newstdout, read_stdout, write_stdin: THandle; //pipe handles
  Exit_Code: LongWord; //process exit code
  bread: LongWord; //bytes read
  avail: LongWord; //bytes available
  Str, Last: string;
  PStr: PChar;
  I, II: LongWord;
  eol, EndCR:boolean; // tk

begin //FExecute
  try /// for free self
  Exit_Code := 0;
  FOwner.Started := False;
  FOwner.ThreadStatus := dtsAllocatingMemory;
  GetMem(sa, sizeof(SECURITY_ATTRIBUTES));
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then begin //initialize security descriptor (Windows NT)
    GetMem(sd, sizeof(SECURITY_DESCRIPTOR));
    InitializeSecurityDescriptor(sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(sd, true, nil, false);
    sa.lpSecurityDescriptor := sd;
  end else begin
    sa.lpSecurityDescriptor := nil;
    sd := nil;
  end;
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := true; //allow inheritable handles
  iBufSize := MaxBufSize;
  pBuf := AllocMem(iBufSize); // Reserve and init Buffer
  try /// memory allocated

  FOwner.ThreadStatus := dtsCreatingPipes;
  if not (CreatePipe(newstdin, write_stdin, sa, 0)) then //create stdin pipe
  begin
    raise FCreatePipeError;
    Exit;
  end;
  if not (CreatePipe(read_stdout, newstdout, sa, 0)) then //create stdout pipe
  begin
    CloseHandle(newstdin);
    CloseHandle(write_stdin);
    raise FCreateProcessError;  //  先に raise してはならない。
    Exit;
  end;
  try /// handles for pipes

  FOwner.ThreadStatus := dtsCreatingProcess;
  GetStartupInfoW(si); //set startupinfo for the spawned process
     {The dwFlags member tells CreateProcess how to make the process.
     STARTF_USESTDHANDLES validates the hStd* members. STARTF_USESHOWWINDOW
 validates the wShowWindow member.}
  si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  si.wShowWindow := ShowWindowValues[Ord(FShowWindow)]; //SW_SHOW; //SW_HIDE; //SW_SHOWMINIMIZED;
  si.hStdOutput := newstdout;
  si.hStdError := newstdout; //set the new handles for the child process
  si.hStdInput := newstdin;
  app_spawn := PWideChar(FCommandLine);
    //spawn the child process
  if not (CreateProcessW(nil,
                        app_spawn, 
                        nil, 
                        nil, 
                        TRUE,
                        {CREATE_NEW_CONSOLE}{DETACHED_PROCESS}
                        CreationFlagValues[Ord(FCreationFlag)] or FPriority,
                        nil,
                        //nil,
                        PWideChar (FCurrentDirectory),
                        si,
                        pi)) then
  begin
        //  例外を受け取る場所が無い。
        //  スレッドの exitcode に入れるべき？。
    //FCreateProcessError := TCreateProcessError.Create(string(app_spawn)
    //  + ' doesn''t exist.');
    //raise FCreateProcessError;
    Exit;
  end;
  FTimer.Beginning; //turn the timer on
  Exit_Code := STILL_ACTIVE;
  try /// handles of process
    FOwner.Started := True;
    FOwner.ThreadStatus := dtsRunning;
    Last := ''; // Buffer to save last output without finished with CRLF
    FLineBeginned := False;
    EndCR := False;

    repeat //main program loop
            //  生きていれば STILL_ACTIVE 死んでいれば終了コードがただちに返る。
            //  死んでいてもパイプのデータは有効。
      GetExitCodeProcess(pi.hProcess, Exit_Code); //while the process is running
            //  出力パイプから pBuf に取り込む。
      PeekNamedPipe(read_stdout, pBuf, iBufSize, @bread, @avail, nil);
      //check to see if there is any data to read from stdout
            //  出力があれば
      if (bread <> 0) then begin
        if (iBufSize < avail) then begin // If BufferSize too small then rezize
          iBufSize := avail;
          ReallocMem(pBuf, iBufSize);
        end;
        FillChar(pBuf^, iBufSize, #0); //empty the buffer
        ReadFile(read_stdout, pBuf^, iBufSize, bread, nil); //read the stdout pipe
        Str := Last; //take the begin of the line (if exists)
        i := 0;
        while ((i < bread) and not (Terminated)) do
        begin
          case pBuf^[i] of
            #0: Inc(i);
            #10, #13:
              begin
                Inc(i);
                if not (EndCR and (pBuf^[i - 1] = #10)) then
                begin
                  if (i < bread) and (pBuf^[i - 1] = #13) and (pBuf^[i] = #10) then
                  begin
                    Inc(i);
                    FOwner.FOutputReturnCode := rcCRLF;
                    //Str := Str + #13#10;
                  end
                  else
                  begin
                    FOwner.FOutputReturnCode := rcLF;
                    //Str := Str + #10;
                  end;
                  //so we don't test the #10 on the next step of the loop
                  //FTimer.NewOutput; //a new ouput has been caught
                  AddString_SHARED(Str, otEntireLine);
                  Str := '';
                end;
              end;
          else
            begin
              Str := Str + pBuf^[i]; //add a character
              Inc(i);
            end;
          end;
        end;
        EndCR := (pBuf^[i - 1] = #13);
        Last := Str; // no CRLF found in the rest, maybe in the next output
        if (Last <> '') then begin
          AddString_SHARED(Last, otBeginningOfLine);
        end;
            //  出力が無い場合。
      end
      else
      begin
      //send Lines in input (if exist)
        //FOwner.sync.beginWrite ;
        try
          while ((InputLines_SHARED.Count > 0) and not (Terminated)) do
          begin
            	//	enough size?
            II := Length(InputLines_SHARED[0]);
            if (iBufSize < II) then
              iBufSize := II;
            FillChar(pBuf^, iBufSize, #0); //clear the buffer
            eol := (Pos(#13#10, InputLines_SHARED[0]) = II - 1) or (Pos(#10, InputLines_SHARED[0]) = II);
            for I := 0 to II - 1 do
              pBuf^[I]:=InputLines_SHARED[0][I + 1];
            WriteFile(write_stdin, pBuf^, II, bread, nil); //send it to stdin
            if FOwner.FInputToOutput then //if we have to output the inputs
            begin
              if FLineBeginned then
                Last := Last + InputLines_SHARED[0]
              else
                Last := InputLines_SHARED[0];
              if eol then
              begin
                AddString_SHARED(Last, otEntireLine);
                Last := '';
              end
              else
                AddString_SHARED(Last, otBeginningOfLine);
            end;
            InputLines_SHARED.Delete(0); //delete the line that has been send
          end;
        finally
          //FOwner.sync.EndWrite ;
        end;
      end;

      Sleep(1); // Give other processes a chance

      if Exit_Code <> STILL_ACTIVE then begin
        FOwner.ThreadStatus := dtsSuccess;
        FOwner.FExitCode := Exit_Code;
        //ReturnValue := Exit_Code;
        break;
      end;

      if Terminated then begin //the user has decided to stop the process
        FOwner.ThreadStatus := dtsUserAborted;
        break;
      end;

      if ((FMaxTimeAfterBeginning < FTimer.FSinceBeginning)
      and (FMaxTimeAfterBeginning > 0)) //time out
      or ((FMaxTimeAfterLastOutput < FTimer.FSinceLastOutput)
      and (FMaxTimeAfterLastOutput > 0))
      then begin
        FOwner.ThreadStatus := dtsTimeOut;
        break;
      end;

    until (Exit_Code <> STILL_ACTIVE); //process terminated (normally)

    if (Last <> '') then // If not empty flush last output
      AddString_SHARED(Last, otBeginningOfLine);

  finally /// handles of process
    if (Exit_Code = STILL_ACTIVE) then
      TerminateProcess(pi.hProcess, 0);
    FTimer.Ending; //turn the timer off
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
  end;
  finally /// handles for pipes
    CloseHandle(newstdin); //clean stuff up
    CloseHandle(newstdout);
    CloseHandle(read_stdout);
    CloseHandle(write_stdin);
  end;
  finally /// memory(1)
    FreeMem(pBuf);
    if (Win32Platform = VER_PLATFORM_WIN32_NT) then
      FreeMem(sd);
    FreeMem(sa);
  end;
  finally /// free self
    if Assigned(FOnTerminated) then
      //FOnTerminated(FOwner, Exit_Code);
      Synchronize (FOnTerminated);
    case FOwner.ThreadStatus of
    dtsAllocatingMemory:
      begin
        FOwner.ThreadStatus := dtsAllocateMemoryFail ;
        FOwner.FExitCode := GetLastError;
      end;
    dtsCreatingPipes:
      begin
        FOwner.ThreadStatus := dtsCreatePipesFail ;
        FOwner.FExitCode := GetLastError;
      end;
    dtsCreatingProcess:
      begin
        FOwner.ThreadStatus := dtsCreateProcessFail ;
        FOwner.FExitCode := GetLastError;
      end;
    dtsRunning:
      begin
        FOwner.ThreadStatus := dtsRunningError ;
        FOwner.FExitCode := GetLastError;
      end;
    end;
    FreeOnTerminate := true;
    FActive := False;
    terminate;
  end;
end;

function TDosThread.IsALive : boolean;
var
  Exit_Code: LongWord; //process exit code
begin
  GetExitCodeProcess (pi.hProcess, Exit_Code);
  Result := Exit_Code = STILL_ACTIVE
end;

//------------------------------------------------------------------------------

procedure TDosThread.Execute;
begin
  try
    FExecute;
  except
    on E: TCreatePipeError do Application.ShowException(E);
    on E: TCreateProcessError do Application.ShowException(E);
  end;
end;

//------------------------------------------------------------------------------

procedure TDosThread.AddString_SHARED(Str: string; OutType: TOutputType);
begin
  try
    FOwner.Lines.Add(str);  // ??
    FTimer.NewOutput; //a new ouput has been caught
    FOutputStr := Str;
    FOutputType := OutType;
    Synchronize(AddString);
  except
  end;
end;

procedure TDosThread.AddString;
begin
    if Assigned(FOwner.OutputLines) then
    begin
      FOwner.OutputLines.BeginUpdate;
      try
        if FOwner.OutputLines.Count = 0 then
        begin
          if (FOutputType = otEntireLine) then
            FOwner.OutputLines.Add(FOutputStr)
          else
            FOwner.OutputLines.Text := FOutputStr;
        end
        else
        begin
          // change the way to add by last addstring type
          if FLineBeginned then
            FOwner.OutputLines[FOwner.OutputLines.Count - 1] := FOutputStr
          else
            FOwner.OutputLines.Add(FOutputStr);
        end;
      finally
        FOwner.OutputLines.EndUpdate;
      end;
    end;
    FLineBeginned := (FOutputType = otBeginningOfLine);
  if Assigned(FOnNewLine) then
    FOnNewLine(FOwner, FOutputStr, FOutputType);
end;


//------------------------------------------------------------------------------

    //
    //  AOwner:TDosCommand を一つだけ受け取ったほうがよい。
    //  
constructor TDosThread.Create( AOwner: TDosCommand ); 
begin
  FOwner := AOwner;
  FCommandline := FOwner.CommandLine;   // copy.  not shared;
  FCurrentDirectory := FOwner.CurrentDirectory;   // copy.  not shared;
  InputLines_SHARED := FOwner.FInputLines_SHARED;
  InputLines_SHARED.Clear;
  //FInputToOutput := FOwner.InputToOutput;
  FOnNewLine := FOwner.FOnNewLine;
  FOnTerminated := FOwner.FOnTerminated;
  FTimer := FOwner.FTimer;  // can access private!!
  FMaxTimeAfterBeginning := FOwner.FMaxTimeAfterBeginning;
  FMaxTimeAfterLastOutput := FOwner.FMaxTimeAfterLastOutput;
  FPriority := FOwner.FPriority;
  FShowWindow := FOwner.FShowWindow;
  FCreationFlag := FOwner.FCreationFlag;
  FLineBeginned := False;
  FProcessInfo_SHARED := @FOwner.FProcessInfo_SHARED;
  FActive := True;
  
  inherited Create(False);  //  ただちに実行。
end;

//------------------------------------------------------------------------------

constructor TDosCommand.Create(AOwner: TComponent);
begin
  inherited;
  FLines_SHARED := TStringList.Create;
  FLines_SHARED.Clear;
  FInputLines_SHARED := TStringList.Create;
  FInputLines_SHARED.Clear;
  FSync := TMultiReadExclusiveWriteSynchronizer.Create;

  FCommandLine := '';
  CurrentDirectory := '';
  FTimer := nil;
  FMaxTimeAfterBeginning := 0;
  FMaxTimeAfterLastOutput := 0;
  FPriority := NORMAL_PRIORITY_CLASS;
  FShowWindow := swHide;
  FCreationFlag := fCREATE_NEW_CONSOLE;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.SetOutputLines_SHARED(Value: TStrings);
begin
  Sync.beginWrite ; try
  if (FOutputLines_SHARED <> Value) then begin
    FOutputLines_SHARED := Value;
  end;
  finally Sync.EndWrite ; end;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Execute (var ok : boolean);
begin
  if FCommandLine = ''
    then ok := False
    else
      begin
        Stop;
        if (FTimer = nil) then //create the timer (first call to execute)
          FTimer := TProcessTimer.Create(self);
        FLines_SHARED.Clear; //clear old outputs
        FThread := TDosThread.Create (Self);
        Sleep (500);
        ok := Started
      end;
end;

//------------------------------------------------------------------------------

    //
    //  WaitFor では親スレッドが止まってしまう？
    //  
    //  Apollo では起動中に[ｘ]で終了しても、mainloop を終了しない。
    //  
    //

function TDosCommand.Execute2: Integer;
var
  ok : boolean;
begin
  Execute (ok);
  while Self.Active do
    Application.ProcessMessages;
  Result := FExitCode;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Stop;
begin
  if (FThread <> nil) then
  begin
    FThread.FreeOnTerminate := true;
    FThread.Terminate; //terminate the process
    FThread := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.SendLine(Value: string; Eol: Boolean);
//const
  //EolCh: array[Boolean] of Char = (' ', '_');
var
  i, sp, L: Integer;
  Str: String;
begin
//  Sync.BeginWrite ;
  try
    if (FThread <> nil) then
    begin
      if Eol then
      begin
        if FReturnCode = rcCRLF then
          Value := Value + #13#10
        else
          Value := Value + #10;
      end;
{      L := Length(Value);
      i := 1;
      sp := i;
      while i <= L do
      begin
        case Value[i] of
        #13:
          begin
            if (i < L) and (Value[i + 1] = #10) then
              Inc(i);
            Str := Copy(Value, sp, i - sp + 1);
            FInputLines_SHARED.Add(Str);
            Inc(i);
            sp := i;
          end;
        #10:
          begin
            Str := Copy(Value, sp, i - sp + 1);
            FInputLines_SHARED.Add(Str);
            Inc(i);
            sp := i;
          end;
        else
          Inc(i);
        end;
      end;
      Str := Copy(Value, sp, i - sp + 1);
      FInputLines_SHARED.Add(Str);
}
      FInputLines_SHARED.Add(Value);
      //FThread.InputLines_SHARED.Add(EolCh[Eol] + Value);
    end;
  finally
  end;
end;

//------------------------------------------------------------------------------

destructor TDosCommand.Destroy;
begin
  if FThread <> nil then Stop;
  if FTimer <> nil then FTimer.free;
  FSync.Free;
  FInputLines_SHARED.free;
  FLines_SHARED.free;
  inherited;
end;

function TDosCommand.GetPrompting:boolean;
begin
  //result := Active ; // and ( FTimer.FSinceLastOutput > 3 );
  result := Active and (( FTimer.FSinceLastOutput > 3 ) or FThread.FLineBeginned);
end;

function TDosCommand.GetActive:boolean;
begin
  result := ( FThread <> nil ) and ( FThread.FActive )
             and (not FThread.Terminated)
end;

function TDosCommand.GetSinceLastOutput:integer;
begin
  result := -1;
  if GetActive then result := FTimer.FSinceLastOutput;
end;

function TDosCommand.GetSinceBeginning:integer;
begin
  result := -1;
  if GetActive then result := FTimer.FSinceBeginning;
end;

function TDosCommand.IsAlive : boolean;
begin
  Result := FThread.IsAlive
end;

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('Samples', [TDosCommand]);
  //RegisterComponents('RDE', [TDosCommand]);
end;

//------------------------------------------------------------------------------
end.

