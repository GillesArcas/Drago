
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  IniFiles,
  BoardUtils        in '..\src\BoardUtils.pas',
  ClassesEx         in '..\src\ClassesEx.pas',
  CodePages         in '..\src\CodePages.pas',
  Crc32             in '..\src\Crc32.pas',
  Define            in '..\src\Define.pas',
  DefineUi          in '..\src\DefineUi.pas',
  EngineSettings    in '..\src\EngineSettings.pas',
  FontMetrics       in '..\src\FontMetrics.pas',
  GameUtils         in '..\src\GameUtils.pas',
  Properties        in '..\src\Properties.pas',
  Sgfio             in '..\src\Sgfio.pas',
  Std               in '..\src\Std.pas',
  SysUtilsEx        in '..\src\SysUtilsEx.pas',
  Translate         in '..\src\Translate.pas',
  UApply            in '..\src\UApply.pas',
  UBackground_FPC   in '..\src\UBackground_FPC.pas',
  UBoardView        in '..\src\UBoardView.pas',
  UBoardViewAscii   in '..\src\UBoardViewAscii.pas',
  UBookBoard        in '..\src\UBookBoard.pas',
  UContext          in '..\src\UContext.pas',
  UDragoIniFiles    in '..\src\UDragoIniFiles.pas',
  UExporter         in '..\src\UExporter.pas',
  UExporterTXT      in '..\src\UExporterTXT.pas',
  UFactorization    in '..\src\UFactorization.pas',
  UGameColl         in '..\src\UGameColl.pas',
  UGameTree         in '..\src\UGameTree.pas',
  UGameTreeTests    in '..\src\UGameTreeTests.pas',
  UGMisc            in '..\src\UGMisc.pas',
  UGoban            in '..\src\UGoban.pas',
  UGoBoard          in '..\src\UGoBoard.pas',
  UGtp              in '..\src\UGtp.pas',
  UImageExporter    in '..\src\UImageExporter.pas',
  UImageExporterTXT in '..\src\UImageExporterTXT.pas',
  UInstStatus       in '..\src\UInstStatus.pas',
  UKombilo          in '..\src\UKombilo.pas',
  UKombiloInt       in '..\src\UKombiloInt.pas',
  UMatchPattern     in '..\src\UMatchPattern.pas',
  UMRUList          in '..\src\UMRUList.pas',
  UPrint            in '..\src\UPrint.pas',
  UPrintStyles      in '..\src\UPrintStyles.pas',
  URandom           in '..\src\URandom.pas',
  UStatus           in '..\src\UStatus.pas',
  UView             in '..\src\UView.pas',
  Ux2y              in '..\src\Ux2y.pas',
  UFileAssoc        in '..\src\UFileAssoc.pas',
  ViewUtils         in '..\src\ViewUtils.pas';
  
  
procedure ExportToTxt(view : TView; const filename : string);
var
  ok : boolean;
  exporter : TExporterTXT;
begin
  // TODO : could eiTRC be specified less than three times?
  exporter := TExporterTXT.Create(eiTRC, filename);
  exporter.FImageExporter := TImageExporterTXT.Create(eiTRC);

  PerformPreview(view,
                 ok,
                 exporter,
                 emExportTXT,
                 eiTRC,
                 Settings.ShowMoveMode);

  exporter.Free;
end;


procedure Main(iniName, file_in, file_out : string);
var
  view : TView;
  IniFile : TDragoIniFile;
  nGames : integer;
begin
  // create and initialize working view
  view := TView.Create;
  view.Context := TContext.Create;
  view.gb := TGoban.Create;
  view.gt := nil;
  view.si.Default;

  // initialize with default values
  IniFile := TDragoIniFile.Create(iniName);
  Settings.LoadIniFile(IniFile);
  IniFile.Free;

  view.gb.BoardSettings(Settings.ShowHoshis,
                        Settings.CoordStyle,
                        Settings.NumOfMoveDigits,
                        trIdent,
                        Settings.ShowMoveMode,
                        Settings.NumberOfVisibleMoveNumbers);

  ReadSgf(view.cl, file_in, nGames, True, False);
  view.gt := view.cl[1].Root;

  ExportToTxt(view, file_out)
end;

begin
  if ParamCount <> 3
    then writeln('Usage: SgfFactorize <inifile> <multigame sgf file> <trace text>')
    else Main(ParamStr(1), ParamStr(2), ParamStr(3))
end.

