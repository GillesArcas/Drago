program SgfFactorize;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  IniFiles,
  ClassesEx         in '..\src\ClassesEx.pas',
  CodePages         in '..\src\CodePages.pas',
  Crc32             in '..\src\Crc32.pas',
  Define            in '..\src\Define.pas',
  DefineUi          in '..\src\DefineUi.pas',
  EngineSettings    in '..\src\EngineSettings.pas',
  GameUtils         in '..\src\GameUtils.pas',
  Properties        in '..\src\Properties.pas',
  Sgfio             in '..\src\Sgfio.pas',
  Std               in '..\src\Std.pas',
  Ux2y              in '..\src\Ux2y.pas',
  SysUtilsEx        in '..\src\SysUtilsEx.pas',
  Translate         in '..\src\Translate.pas',
  UApply            in '..\src\UApply.pas',
  BoardUtils        in '..\src\BoardUtils.pas',
  UBoardView        in '..\src\UBoardView.pas',
  UBookBoard        in '..\src\UBookBoard.pas',
  UContext          in '..\src\UContext.pas',
  UDragoIniFiles    in '..\src\UDragoIniFiles.pas',
  UFactorization    in '..\src\UFactorization.pas',
  UGameTreeTests    in '..\src\UGameTreeTests.pas',
  UGameTree         in '..\src\UGameTree.pas',
  UGameColl         in '..\src\UGameColl.pas',
  UGmisc            in '..\src\UGmisc.pas',
  UGoban            in '..\src\UGoban.pas',
  UGoBoard          in '..\src\UGoBoard.pas',
  UGtp              in '..\src\UGtp.pas',
  UInstStatus       in '..\src\UInstStatus.pas',
  UKombilo          in '..\src\UKombilo.pas',
  UKombiloInt       in '..\src\UKombiloInt.pas',
  UMatchPattern     in '..\src\UMatchPattern.pas',
  UMRUList          in '..\src\UMRUList.pas',
  UPrintStyles      in '..\src\UPrintStyles.pas',
  URandom           in '..\src\URandom.pas',
  UStatus           in '..\src\UStatus.pas',
  UView             in '..\src\UView.pas';

procedure OnStep(x : integer);
begin
  writeln ('Step ', x)
end;

procedure OnError(s : WideString);
begin
  writeln(s)
end;


procedure Main(nameIn, nameOut : WideString);
var
  clIn, clOut : TGameColl;
  nGames : integer;
begin
  Settings.FactorizeNormPos := True;

  clIn := TGameColl.Create;
  clOut := TGameColl.Create;

  ReadSgf(clIn, nameIn, nGames, True, False);

  CollectionFactorization(clIn, clOut,
                          20, 0,    // depth, nbUnique
                          False,   // tewari
                          OnStep,  // onStep
                          OnError  // onError
                          );

  PrintSGF(clOut, nameOut,
           ioRewrite,
           False, True)
end;

begin
  writeln(ParamCount);
  if ParamCount <> 2
    then writeln('Usage: SgfFactorize <multigame sgf file> <factorized sgf file>')
  else
    Main(ParamStr(1), ParamStr(2))
end.

