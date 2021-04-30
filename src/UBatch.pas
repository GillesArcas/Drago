// ---------------------------------------------------------------------------
// -- Drago -- Interpretation of batch files ------------------- UBatch.pas --
// ---------------------------------------------------------------------------

unit UBatch;

// ---------------------------------------------------------------------------

interface

type
  TLogProc = procedure(const s : string);

function TestingDirectory : string;
procedure ApplyBatch(batchName, reference, result : string; logProc : TLogProc;
                     out timing : int64);

// ---------------------------------------------------------------------------

implementation

uses
  Forms, Classes, Graphics, SysUtils, IniFiles, Math, StrUtils,
  ClassesEx, SysUtilsEx,
  Define, DefineUi, Std, UView, UContext, UGoban, UGameColl, SgfIo, UStatus,
  UGMisc, Crc32,
  ViewUtils, UGameTreeTests,
  UDragoIniFiles,
  UPrint,
  UImageExporterBMP,
  UImageExporterPDF,
  UImageExporterTXT,
  UImageExporterWMF,
  UExporter, UExporterRTF, UExporterPDF, UExporterTXT, UExporterHTM, UExporterIMG,
  UFactorization;

// ---------------------------------------------------------------------------

procedure BatchLoop     (view : TView; startIndex : integer) ; forward;
procedure ApplyBatchLine(view : TView; aLine : string; var continue : boolean); forward;
procedure ApplyConfig   (view : TView; line : string); forward;
procedure ApplyFunc     (view : TView; func, line : string); forward;
procedure AssignOutput  (name : string); forward;
procedure AppendToOutput(stringList : TStringList); forward;
procedure LogError(const s : string); forward;

// ---------------------------------------------------------------------------

var
  OutputFile : Text;
  InsideDefine : boolean = False;
  Batch : TStringList;
  LogProcedure : TLogProc;
  PartialTiming : int64;

// -- Interface --------------------------------------------------------------

function TestingDirectory : string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Testing\'
end;

procedure ApplyBatch(batchName, reference, result : string; logProc : TLogProc;
                     out timing : int64);
var
  view : TView;
  IniFile : TDragoIniFile;
  iniName, bakName : WideString;
begin
  iniName := DragoIniFileName;
  bakName := DragoIniFileName + '.bak';

  PartialTiming := -1;
  MilliTimer;

  // create and initialize working view
  view := TView.Create;
  view.Context := TContext.Create;
  view.gb := TGoban.Create;
  view.gt := nil;
  view.si.Default;

  // backup inifile
  DeleteFile(bakName);
  RenameFile(iniName, bakName);

  // initialize with default values and save temporary inifile
  IniFile := TDragoIniFile.Create(iniName);
  Settings.LoadIniFile(IniFile);
  Settings.SaveIniFile(IniFile);

  view.gb.BoardSettings(Settings.ShowHoshis,
                        Settings.CoordStyle,
                        Settings.NumOfMoveDigits,
                        trIdent,
                        Settings.ShowMoveMode,
                        Settings.NumberOfVisibleMoveNumbers);
  IniFile.Free;

  if reference <> ''
    then AssignOutput(reference)
    else AssignOutput(result);

  Batch := TStringList.Create;
  Batch.LoadFromFile(batchName);
  InsideDefine := False;
  LogProcedure := logProc;

  try
    BatchLoop(view, 0)
  finally
    Batch.Free;
    CloseFile(OutputFile);

    // free working view
    view.Context.Free;
    view.Free;

    // restore inifile
    DeleteFile(iniName);
    RenameFile(bakName, iniName);

    // restore settings
    IniFile := TDragoIniFile.Create(iniName);
    Settings.LoadIniFile(IniFile);
    IniFile.Free
  end;

  if PartialTiming < 0
    then timing := MilliTimer
    else timing := PartialTiming;
end;

// -- Interpretation loop ----------------------------------------------------

procedure BatchLoop(view : TView; startIndex : integer);
var
  i : integer;
  continue : boolean;
begin
  try
    for i := startIndex to Batch.Count - 1 do
      begin
        ApplyBatchLine(view, Batch[i], continue);
        if not continue
          then break
      end
  except
    on E: Exception do
      if Assigned(LogProcedure)
        then LogProcedure('** Batch interrupted ' + E.Message);
  end
end;

procedure ApplyBatchLine(view : TView; aLine : string; var continue : boolean);
var
  line : string;
begin
  line := Trim(aLine);
  continue := True;

  if line = ''
    then exit;

  if line[1] = ';'
    then exit;

  if InsideDefine then
    begin
      if NthWord(line, 1) = 'EndDef'
        then InsideDefine := False;
      exit
    end;
    
  if NthWord(line, 1) = 'EndDef' then
    begin
      continue := False;
      exit
    end;

  if Pos('=', line) > 0
    then ApplyConfig(view, line)
    else ApplyFunc(view, NthWord(line, 1), line);

  Application.ProcessMessages
end;

// -- Interpretation of settings ---------------------------------------------

procedure ApplyConfigTry(view : TView; const section, key, value : string; var ok : boolean);
begin
  ok := True;

  if (section = 'New') and (key = 'Handicap')
    then Settings.Handicap := StrToIntDef(value, 0)
  else
  if (section = 'New') and (key = 'BoardSize')
    then Settings.BoardSize := StrToIntDef(value, 19)
  else
  if (section = 'Ascii') and (key = 'DrawEdge')
    then Settings.AscDrawEdge := (value = '1')
  else
  if (section = 'Goban') and (key = 'CoordStyle')
    then Settings.CoordStyle := StrToIntDef(value, 1)
  else
    ok := False;
end;

procedure ExtractSetting(const line : string;
                         out section, key, value : string;
                         out ok : boolean);
var
  leftside : string;
begin
  leftside := Trim(NthWord(line, 1, '='));
  section  := Trim(NthWord(leftside, 1, '.'));
  key      := Trim(NthWord(leftside, 2, '.'));
  value    := Trim(NthWord(line, 2, '='));
  ok := True;
end;

procedure ApplyConfig(view : TView; line : string);
var
  section, key, value : string;
  IniFile : TDragoIniFile;
  ok : boolean;
begin
  ExtractSetting(line, section, key, value, ok);

  if not ok
    then LogError('** Invalid setting: ' + line);

  ApplyConfigTry(view, section, key, value, ok);

  if not ok then
    begin
      IniFile := TDragoIniFile.Create(DragoIniFileName);
      IniFile.WriteString(section, key, value);
      IniFile.UpdateFile;
      Settings.LoadIniFile(IniFile);
      IniFile.Free
    end;

  view.gb.BoardSettings(Settings.ShowHoshis,
                        Settings.CoordStyle,
                        Settings.NumOfMoveDigits,
                        trIdent,
                        Settings.ShowMoveMode,
                        Settings.NumberOfVisibleMoveNumbers)
end;

// -- Interpretation of batch functions --------------------------------------

// 'LoadSgf'

procedure ApplyLoadSgf(view : TView; name : string);
var
  nReadGames : integer;
begin
  ReadSgf(view.cl, name, nReadGames,
          Settings.LongPNames, Settings.AbortOnReadError);
  view.gt := view.cl[1].Root;
  view.si.IndexTree := 1
end;

// 'LoadFolder'

procedure ApplyLoadFolder(view : TView; name : string);
begin
  ReadSgfFolder(view.cl, name, '*.sgf',
                Settings.LongPNames, Settings.AbortOnReadError, true, true)
end;

// 'CreateRandomColl'

procedure ApplyCreateRandomColl(view : TView; line : string);
const
  randSeed = 12345679;
var
  numTrees      : integer;
  nbEditOps     : integer;
  prDelTerminal : integer;
  prDelBranch   : integer;
  prAddVar      : integer;
begin
  numTrees      := NthInt(line, 2);
  nbEditOps     := NthInt(line, 3);
  prDelTerminal := NthInt(line, 4);
  prDelBranch   := NthInt(line, 5);
  prAddVar      := NthInt(line, 6);

  RandomGameColl(view.cl, numTrees, randSeed, nbEditOps, prDelTerminal,
                 prDelBranch, prAddVar)
end;

// 'NewGame'

procedure ApplyNewGame(view : TView);
begin
  view.CreateEvent;
  view.StartEvent
end;

// 'RandomGames'

procedure ApplyRandomGames(view : TView; n : integer);
begin
  view.cl.Clear;
  RandomGames(view, n);
end;

// 'RandomEdit'

procedure ApplyRandomEdit(view : TView; n : integer);
begin
  view.cl.Clear;
  RandomEdit(view, n);
end;

// 'RandomEditProp'

procedure ApplyRandomEditProp(view : TView; n : integer);
begin
  RandomEditProp(view, n);
end;

// 'MakeMainBranch'

procedure ApplyTestMakeMainBranch(view : TView; n : integer);
begin
  TestMakeMainBranch(view, n);
end;

// 'GotoLastMove'

procedure ApplyGotoLastMove(view : TView);
begin
  view.DoEndPos
end;

// 'SaveSgf'

procedure ApplySaveSgf(view : TView);
var
  tmpName : string;
begin
  tmpName := Status.TmpPath + '\tmp.sgf';
  PrintSgf(view.cl, tmpName, ioRewrite, Settings.CompressList, Settings.SaveCompact);
  writeln(OutputFile, FileToString(tmpName))
end;

// 'ExportToAscii' : Export position to ascii

procedure ApplyExportToAscii(view : TView; line : string);
var
  iMin, jMin, iMax, jMax, x : integer;
  textCanvas : TStringList;
begin
  iMin := NthInt(line, 2);
  jMin := NthInt(line, 3);
  iMax := NthInt(line, 4);
  jMax := NthInt(line, 5);
  x    := iMin;

  iMin := IfThen(x = 0, 1, iMin);
  jMin := IfThen(x = 0, 1, jMin);
  iMax := IfThen(x = 0, view.gb.BoardSize, iMax);
  jMax := IfThen(x = 0, view.gb.BoardSize, jMax);

  view.gb.SetView(iMin, jMin, iMax, jMax);

  textCanvas := TStringList.Create;
  try
    ExportBoardToAscii(view.gb, Settings.PrExportPos, textCanvas);
    textCanvas.Add('');
    AppendToOutput(textCanvas);
  finally
    textCanvas.Free;
  end
end;

// 'ExportToRtf' : Export file to RTF

procedure ApplyExportToRtf(view : TView);
var
  list : TStringList;
  ok : boolean;
  filename : WideString;
  exporter : TExporterRTF;
begin
  filename := Status.TmpPath + '\tmp.rtf';
  exporter := TExporterRTF.Create(filename);
  exporter.FImageExporter := TImageExporterWMF.Create;

  PerformPreview(view,
                 ok,
                 exporter,
                 emExportRTF,
                 eiWMF);

  exporter.Free;

  list := TStringList.Create;
  list.LoadFromFile(filename);
  AppendToOutput(list);
  list.Free
end;

// 'ExportToPdf' : Export file to PDF

procedure ApplyExportToPdf(view : TView);
var
  list : TStringList;
  ok : boolean;
  filename : WideString;
  exporter : TExporterPDF;
begin
  filename := Status.TmpPath + '\tmp.pdf';
  exporter := TExporterPDF.Create(eiPDF, filename);
  exporter.FImageExporter := TImageExporterPDF.Create;

  PerformPreview(view,
                 ok,
                 exporter,
                 emExportPDF,
                 eiPDF);

  exporter.Free;

  list := TStringList.Create;
  list.LoadFromFile(filename);
  AppendToOutput(list);
  list.Free
end;

// 'ExportToTxt' : Export file to text

procedure ApplyExportToTxt(view : TView);
var
  list : TStringList;
  ok : boolean;
  filename : WideString;
  exporter : TExporterTXT;
begin
  filename := Status.TmpPath + '\tmp.txt';
  exporter := TExporterTXT.Create(Settings.PrExportFigure, filename);
  exporter.FImageExporter := TImageExporterTXT.Create(Settings.PrExportFigure);

  PerformPreview(view,
                 ok,
                 exporter,
                 emExportTXT,
                 Settings.PrExportFigure,
                 Settings.ShowMoveMode);

  exporter.Free;

  list := TStringList.Create;
  list.LoadFromFile(filename);
  AppendToOutput(list);
  list.Free
end;

// 'ExportToHtml' : Export file to html

procedure ApplyExportToX(view : TView; exporter : TExporter; filename : WideString);
var
  files : TWideStringList;
  list : TStringList;
  ok : boolean;
  i : integer;
  crc : LongWord;
begin
  // erase all files in temp folder
  files := TWideStringList.Create;
  WideAddFilesToList(files, Status.TmpPath, [afCatPath, afIncludeFiles], '*.*');
  for i := 0 to files.Count - 1 do
    WideDeleteFile(files[i]);

  PerformPreview(view,
                 ok,
                 exporter,
                 emExportHTM,
                 Settings.PrExportFigure,
                 Settings.ShowMoveMode);

  exporter.Free;
  list := TStringList.Create;

  if ExtractFileExt(filename) <> '' then
  begin
    // append html file to result string list
    list.LoadFromFile(filename);
    // delete html files, will remain only image files
    WideDeleteFile(filename)
  end;

  // append crc32 of image files to output
  files.Clear;
  WideAddFilesToList(files, Status.TmpPath, [afCatPath, afIncludeFiles], '*.*');
  for i := 0 to files.Count - 1 do
    begin
      crc := ComputeFileCRC32(files[i]); // no unicode names
      list.Add(Format('%x', [crc]))
    end;

  // remove generator name to avoid conflicts over different versions
  for i := list.Count - 1 downto 0 do
    if AnsiStartsStr('<meta name="generator"', list[i])
      then list.Delete(i);

  // flush to output list
  AppendToOutput(list);
  list.Free;
  files.Free
end;

procedure ApplyExportToHtml(view : TView);
var
  filename : WideString;
  exporter : TExporterHTM;
begin
  filename := Status.TmpPath + '\tmp.html';
  exporter := TExporterHTM.Create(Settings.PrExportFigure, filename);
  exporter.FImageExporter := TImageExporterBMP.Create;
  ApplyExportToX(view, exporter, filename)
end;

procedure ApplyExportToImages(view : TView);
var
  filename : WideString;
  exporter : TExporterIMG;
begin
  filename := Status.TmpPath + '\tmp';
  exporter := TExporterIMG.Create(Settings.PrExportFigure, filename);

  case Settings.PrExportFigure of
    eiWMF : exporter.FImageExporter := TImageExporterWMF.Create;
    eiGIF : exporter.FImageExporter := TImageExporterBMP.Create;
    eiPNG : exporter.FImageExporter := TImageExporterBMP.Create;
    eiJPG : exporter.FImageExporter := TImageExporterBMP.Create;
    eiBMP : exporter.FImageExporter := TImageExporterBMP.Create;
    eiPDF : exporter.FImageExporter := TImageExporterPDF.Create;
  end;

  ApplyExportToX(view, exporter, filename)
end;

// 'SpanCollection'

procedure ApplySpanCollection(view : TView);
begin
  writeln(OutputFile, view.cl.Count);
  writeln(OutputFile, SpanCollection(view.cl))
end;

// 'TraverseCollectionAndProperties'

procedure ApplyTraverseCollectionAndProperties(view : TView);
var
  i, n : integer;
begin
  //OutputDebugString('SAMPLING ON');
  for i := 1 to 50 do
    n := TraverseCollectionAndProperties(view.cl);
  //OutputDebugString('SAMPLING OFF');
  writeln(OutputFile, view.cl.Count);
  writeln(OutputFile, n);
  Flush(OutputFile)
end;

// 'TestGameTreeAPI'

procedure ApplyTestGameTreeApi(n : integer);
begin
  writeln(OutputFile, TestGameTreeApi(n))
end;

// 'TestGameExtract'

procedure ApplyTestExtractGame(view : TView);
begin
  TestExtractGame(view.cl);
  view.gt := view.cl[1]
end;

// 'TestStringPath'

procedure ApplyTestStringPath(view : TView);
begin
  writeln(OutputFile, iff(TestStringPath(view.cl), 'Success', 'Failure'))
end;

// 'RandomMovesOnBoard' 'RandomOpsOnBoard'

procedure ApplyRandomMovesOnBoard1 (view : TView; n : integer);
begin
  RandomMovesOnBoard(view.gb.GameBoard, n)
end;

procedure ApplyRandomMovesOnBoard (view : TView; line : string);
var
  n : integer;
  prUndo : integer;
  enableIllegalMoves : integer;
begin
  n := NthInt(line, 2);
  prUndo := NthInt(line, 3);
  enableIllegalMoves := NthInt(line, 4);

  RandomMovesOnBoard(view.gb.GameBoard, n, prUndo, enableIllegalMoves = 1)
end;

// 'Factorize'

procedure OnStep(x : integer); begin end;
procedure OnError(s : WideString); begin end;

procedure ApplyFactorize (view : TView; line : string);
var
  clOut : TGameColl;
begin
  clOut := TGameColl.Create;
  CollectionFactorization(view.cl, clOut,
                          Settings.FactorizeDepth,
                          Settings.FactorizeNbUnique,
                          False,
                          OnStep, OnError);
                          //Settings.FactorizeNormPos
                          //Settings.FactorizeReference
  view.cl.Decant(clOut);
  clOut.Free
end;

// 'StartTimer'

procedure ApplyStartTimer;
begin
  // stop current timer
  Millitimer;
  // restart
  MilliTimer
end;

// 'StopTimer'

procedure ApplyStopTimer;
begin
  PartialTiming := MilliTimer
end;

// -- Dispatch ---------------------------------------------------------------

procedure GetStringArg(const line : string; out arg : string; out ok : boolean);
var
  i : integer;
begin
  i := Pos(' ', TrimLeft(line));
  if i = 0
    then ok := False
    else
      begin
        arg := Trim(Copy(line, i, MaxInt));
        ok := arg <> ''
      end
end;

procedure GetIntArg(const line : string; out n : integer; out ok : boolean);
var
  s : string;
begin
  GetStringArg(line, s, ok);
  if ok
    then ok := TryStrToInt(s, n)
end;

procedure ApplyFunc(view : TView; func, line : string);
var
  ok : boolean;
  s : string;
  n, index : integer;
begin
  if func = 'Define' then
    begin
      InsideDefine := True;
      exit
    end;
  if func = 'NewGame' then
    begin
      ApplyNewGame(view);
      exit
    end;
  if func = 'CreateRandomColl' then
    begin
      ApplyCreateRandomColl(view, line);
      exit
    end;
  if func = 'RandomGames' then
    begin
      GetIntArg(line, n, ok);
      if ok
        then ApplyRandomGames(view, n)
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'RandomEdit' then
    begin
      GetIntArg(line, n, ok);
      if ok
        then ApplyRandomEdit(view, n)
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'RandomEditProp' then
    begin
      GetIntArg(line, n, ok);
      if ok
        then ApplyRandomEditProp(view, n)
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'TestMakeMainBranch' then
    begin
      GetIntArg(line, n, ok);
      if ok
        then ApplyTestMakeMainBranch(view, n)
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'LoadSgf' then
    begin
      GetStringArg(line, s, ok);
      if ok
        then
          begin
            // folder path is relative to /.../Drago/Testing directory
            s := TestingDirectory() + s;
            ApplyLoadSgf(view, s)
          end
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'LoadFolder' then
    begin
      GetStringArg(line, s, ok);
      if ok
        then
          begin
            // folder path is relative to /.../Drago/Testing directory
            s := TestingDirectory() + s;
            ApplyLoadFolder(view, s)
          end
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'GotoLastMove' then
    begin
      ApplyGotoLastMove(view);
      exit
    end;
  if func = 'SpanCollection' then
    begin
      ApplySpanCollection(view);
      exit
    end;
  if func = 'TraverseCollectionAndProperties' then
    begin
      ApplyTraverseCollectionAndProperties(view);
      exit
    end;
  if func = 'TestGameTreeApi' then
    begin
      GetIntArg(line, n, ok);
      if ok
        then ApplyTestGameTreeApi(n)
        else LogError('** Invalid call : ' + line);
      exit
    end;
  if func = 'TestExtractGame' then
    begin
      ApplyTestExtractGame(view);
      exit
    end;
  if func = 'TestStringPath' then
    begin
      ApplyTestStringPath(view);
      exit
    end;
  if func = 'SaveSgf' then
    begin
      ApplySaveSgf(view);
      exit
    end;
  if func = 'ExportToTxt' then
    begin
      ApplyExportToTxt(view);
      exit
    end;
  if func = 'ExportToRtf' then
    begin
      ApplyExportToRtf(view);
      exit
    end;
  if func = 'ExportToPdf' then
    begin
      ApplyExportToPdf(view);
      exit
    end;
  if func = 'ExportToAscii' then
    begin
      ApplyExportToAscii(view, line);
      exit
    end;
  if func = 'ExportToHtml' then
    begin
      ApplyExportToHtml(view);
      exit
    end;
  if func = 'ExportToImages' then
    begin
      ApplyExportToImages(view);
      exit
    end;
  if func = 'RandomMovesOnBoard' then
    begin
      ApplyRandomMovesOnBoard(view, line);
      exit
    end;
  if func = 'Factorize' then
    begin
      ApplyFactorize(view, line);
      exit
    end;
  if func = 'StartTimer' then
    begin
      ApplyStartTimer;
      exit
    end;
  if func = 'StopTimer' then
    begin
      ApplyStopTimer;
      exit
    end;

  // search name in user defined functions
  index := Batch.IndexOf('Define ' + func);

  if index < 0
    then LogError('** Undefined function: ' + func)
    else BatchLoop(view, index + 1)
end;

// -- Helpers ----------------------------------------------------------------

procedure AssignOutput(name : string);
begin
  AssignFile(OutputFile, name);
  Rewrite(OutputFile);
  CloseFile(OutputFile);
  AssignFile(OutputFile, name);
  Append(OutputFile)
end;

procedure AppendToOutput(stringList : TStringList);
var
  i : integer;
  s : string;
begin
  for i := 0 to stringList.Count - 1 do
    begin
      s := stringList[i];
      Writeln(OutputFile, s);
    end
end;

procedure LogError(const s : string);
begin
  if Assigned(LogProcedure)
    then LogProcedure(s);
  raise Exception.Create('')
end;

// ---------------------------------------------------------------------------

end.
 
