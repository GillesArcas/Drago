// ---------------------------------------------------------------------------
// -- DRAGO -- Project ------------------------------------------ DRAGO.DPR --
// ---------------------------------------------------------------------------

// TODO: save settings in user directory
// TODO: insert move
// TODO: figures are not centered in print preview or rtf preview
// TODO: fix "engine motor" caption (and change all translation files)

program Drago;

{$R 'UGraphic.res' 'UGraphic.rc'}

uses
  Forms,
  UStones in 'UStones.pas',
  Translate in 'Translate.pas',
  UGoban in 'UGoban.pas',
  UStatus in 'UStatus.pas',
  UGoBoard in 'UGoBoard.pas',
  UProblems in 'UProblems.pas',
  Sgfio in 'Sgfio.pas',
  UGameTree in 'UGameTree.pas',
  Properties in 'Properties.pas',
  UGcom in 'Ugcom.pas',
  UMemo in 'UMemo.pas',
  UGmisc in 'UGMisc.pas',
  DefineUi in 'DefineUi.pas',
  UApply in 'UApply.pas',
  UProblemUtil in 'UProblemUtil.pas',
  HtmlHelpAPI in 'HtmlHelpAPI.pas',
  UGraphic in 'UGraphic.pas',
  Main in 'Main.pas' {fmMain},
  UPrint in 'UPrint.pas',
  Preview in 'Preview.pas' {fmPreview},
  Std in 'Std.pas',
  UExporter in 'UExporter.pas',
  Pages in 'Pages.pas',
  UGtp in 'UGtp.pas',
  UPrintStyles in 'UPrintStyles.pas',
  Ux2y in 'Ux2y.pas',
  UTreeView in 'UTreeView.pas',
  WinUtils in 'WinUtils.pas',
  UfmFreeH in 'UfmFreeH.pas' {fmFreeH},
  UfmNew in 'UfmNew.pas' {fmNew},
  UfmDebug in 'UfmDebug.pas' {fmDebug},
  UfmLabel in 'UfmLabel.pas' {fmLabel},
  UfmExportPos in 'UfmExportPos.pas' {fmExportPos},
  UfmExtract in 'UfmExtract.pas' {fmExtract},
  UfmFavorites in 'UfmFavorites.pas' {fmFavorites},
  UfmGameInfo in 'UfmGameInfo.pas' {fmGameInfo},
  UfmInsert in 'UfmInsert.pas' {fmInsert},
  UfmMsg in 'UfmMsg.pas' {fmMsg},
  UfmOptions in 'UfmOptions.pas' {fmOptions},
  UfmPrint in 'UfmPrint.pas' {fmPrint},
  Components in 'Components.pas',
  UfmJoseki in 'UfmJoseki.pas' {fmEnterJo},
  UfrBackStyle in 'UfrBackStyle.pas' {frBackStyle: TFrame},
  UBackGround in 'UBackGround.pas',
  UMainUtil in 'UMainUtil.pas',
  UGameColl in 'UGameColl.pas',
  MyExtDlgs in 'myextdlgs.pas',
  UExporterDOC in 'UExporterDOC.pas',
  UExporterNFG in 'UExporterNFG.pas',
  UExporterRTF in 'UExporterRTF.pas',
  UExporterPRE in 'UExporterPRE.pas',
  UExporterIMG in 'UExporterIMG.pas',
  UAutoReplay in 'UAutoReplay.pas',
  UActions in 'UActions.pas' {Actions: TDataModule},
  ShortCutEdit in 'ShortCutEdit.pas',
  UfrCfgShortcuts in 'UfrCfgShortcuts.pas' {frCfgShortcuts: TFrame},
  UMRUList in 'UMRUList.pas',
  UfmUserSaveFolder in 'UfmUserSaveFolder.pas' {fmUserSaveFolder},
  UShortcuts in 'UShortcuts.pas',
  UfmReplay in 'UfmReplay.pas' {fmEnterGm},
  UErrorHandler in 'UErrorHandler.pas',
  UView in 'UView.pas',
  UfrPreviewInfo in 'UfrPreviewInfo.pas' {frPreviewInfo: TFrame},
  UDatabase in 'UDatabase.pas',
  UKombiloInt in 'UKombiloInt.pas',
  UfmAddToDB in 'UfmAddToDB.pas' {fmAddToDB},
  UfrDBRequestPanel in 'UfrDBRequestPanel.pas' {frDBRequestPanel: TFrame},
  UViewInfo in 'UViewInfo.pas' {ViewInfo: TFrame},
  UViewThumb in 'UViewThumb.pas' {ViewThumb: TFrame},
  UfrPreviewThumb in 'UfrPreviewThumb.pas' {frPreviewThumb: TFrame},
  UDBDatePicker in 'UDBDatePicker.pas' {DBDatePicker: TFrame},
  UDatePicker in 'UDatePicker.pas' {DatePicker: TFrame},
  UDBPlayerPicker in 'UDBPlayerPicker.pas' {DBPlayerPicker: TFrame},
  UTabButton in 'UTabButton.pas',
  UfrCfgInfoPreview in 'UfrCfgInfoPreview.pas' {frCfgInfoPreview: TFrame},
  UViewBoard in 'UViewBoard.pas',
  UfrVariations in 'UfrVariations.pas' {frVariations: TFrame},
  UContext in 'UContext.pas',
  UfmProblems in 'UfmProblems.pas' {fmProblems},
  UfrDBPatternPanel in 'UfrDBPatternPanel.pas' {frDBPatternPanel: TFrame},
  UMatchPattern in 'UMatchPattern.pas',
  UDBResultPicker in 'UDBResultPicker.pas' {DBResultPicker: TFrame},
  UDBRequestPicker in 'UDBRequestPicker.pas' {DBRequestPicker: TFrame},
  UDBBaseNamePicker in 'UDBBaseNamePicker.pas' {DBBaseNamePicker: TFrame},
  UfrBoardThumb in 'UfrBoardThumb.pas' {frBoardThumb: TFrame},
  UfrDBPatternResult in 'UfrDBPatternResult.pas' {frDBPatternResult: TFrame},
  UKombilo in 'UKombilo.pas',
  UfrDBSignaturePanel in 'UfrDBSignaturePanel.pas' {frDBSignaturePanel: TFrame},
  UfmDBSearch in 'UfmDBSearch.pas' {fmDBSearch},
  UDBSQLPicker in 'UDBSQLPicker.pas' {DBSQLPicker: TFrame},
  UfrDBPickerCaption in 'UfrDBPickerCaption.pas' {frDBPickerCaption: TFrame},
  UExporterHTM in 'UExporterHTM.pas',
  UfrCfgSpToolbars in 'UfrCfgSpToolbars.pas' {frCfgSpToolbars: TFrame},
  UBoardView in 'UBoardView.pas',
  UBookBoard in 'UBookBoard.pas',
  UThemes in 'UThemes.pas',
  UDialogs in 'UDialogs.pas',
  UInputQueryInt in 'UInputQueryInt.pas' {fmInputQueryInt},
  UnicodeUtils in 'UnicodeUtils.pas',
  MyTntExtDlgs in 'MyTntExtDlgs.pas',
  Counting in 'Counting.pas',
  UfrAdvanced in 'UfrAdvanced.pas' {frAdvanced: TFrame},
  FontMetrics in 'FontMetrics.pas',
  VclUtils in 'VclUtils.pas',
  GameUtils in 'GameUtils.pas',
  CodePages in 'CodePages.pas',
  UWelcome in 'UWelcome.pas' {fmWelcome},
  UFileAssoc in 'UFileAssoc.pas',
  UfmAbout in 'UfmAbout.pas' {fmAbout},
  UfrViewBoard in 'UfrViewBoard.pas' {frViewBoard: TFrame},
  UViewBoardPanels in 'UViewBoardPanels.pas',
  ViewUtils in 'ViewUtils.pas',
  UViewMain in 'UViewMain.pas',
  UStatusMain in 'UStatusMain.pas',
  TranslateVcl in 'TranslateVcl.pas',
  UBoardViewScript in 'UBoardViewScript.pas',
  UBoardViewVector in 'UBoardViewVector.pas',
  UBoardViewAscii in 'UBoardViewAscii.pas',
  UBatch in 'UBatch.pas',
  UExporterTXT in 'UExporterTXT.pas',
  UBoardViewCanvas in 'UBoardViewCanvas.pas',
  URandom in 'URandom.pas',
  SysUtilsEx in 'SysUtilsEx.pas',
  ClassesEx in 'ClassesEx.pas',
  UfrCfgGameEngines in 'UfrCfgGameEngines.pas' {frCfgGameEngines: TFrame},
  UInstStatus in 'UInstStatus.pas',
  Crc32 in 'crc32.pas',
  UGameTreeTests in 'UGameTreeTests.pas',
  UEngines in 'UEngines.pas',
  UfrCfgPredefinedEngines in 'UfrCfgPredefinedEngines.pas' {frCfgPredefinedEngines: TFrame},
  EngineSettings in 'EngineSettings.pas',
  UfmGtp in 'UfmGtp.pas' {fmGtp},
  UfmNewEngineGame in 'UfmNewEngineGame.pas' {fmNewEngineGame: TTntForm},
  USideBar in 'USideBar.pas',
  UfmRemProp in 'UfmRemProp.pas' {fmRemProp},
  UTimePicker in 'UTimePicker.pas' {TimePicker: TFrame},
  UfmAdditionalArguments in 'UfmAdditionalArguments.pas' {fmSpecialArguments},
  DosCommand in 'DosCommand.pas',
  UfmFactorize in 'UfmFactorize.pas' {fmFactorize},
  UfmTest in 'UfmTest.pas' {fmTest},
  UBoardViewMetric in 'UBoardViewMetric.pas',
  UfrSelectFiles in 'UfrSelectFiles.pas' {frSelectFiles: TFrame},
  UfmSelectFiles in 'UfmSelectFiles.pas' {fmSelectFiles},
  UFactorization in 'UFactorization.pas',
  UDragoIniFiles in 'UDragoIniFiles.pas',
  UfmCustomStones in 'UfmCustomStones.pas' {fmCustomStones},
  BoardUtils in 'BoardUtils.pas',
  UfrDBSettingsPanel in 'UfrDBSettingsPanel.pas' {frDBSettingsPanel: TFrame},
  UFullScreenToggler in 'UFullScreenToggler.pas',
  UExporterPDF in 'UExporterPDF.pas',
  UfmTesting in 'UfmTesting.pas' {fmTesting},
  Define in 'Define.pas',
  UImageExporter in 'UImageExporter.pas',
  UImageExporterBMP in 'UImageExporterBMP.pas',
  UImageExporterPDF in 'UImageExporterPDF.pas',
  UImageExporterWMF in 'UImageExporterWMF.pas',
  UImageExporterTXT in 'UImageExporterTXT.pas',
  CoolTrayIcon in '..\3rd\CoolTrayIcon\CoolTrayIcon.pas',
  SimpleTimer in '..\3rd\CoolTrayIcon\SimpleTimer.pas',
  hpdf in '..\3rd\HaruPDF\hpdf.pas',
  hpdf_consts in '..\3rd\HaruPDF\hpdf_consts.pas',
  hpdf_types in '..\3rd\HaruPDF\hpdf_types.pas',
  GIFImage in '..\3rd\GifImage\GIFImage.pas',
  pngextra in '..\3rd\PngImage\pngextra.pas',
  pngimage in '..\3rd\PngImage\pngimage.pas',
  pnglang in '..\3rd\PngImage\pnglang.pas',
  zlibpas in '..\3rd\PngImage\zlibpas.pas';

{$R *.RES}

// ---------------------------------------------------------------------------

procedure Uninstall;
var
  ok : boolean;
begin
  UnregisterAsso(Application.ExeName, '.sgf', 'Drago.Document', ok);
  UnregisterAsso(Application.ExeName, '.mgt', 'Drago.Document', ok);
end;

begin
  // beware memchk is not unicode enabled.
  // comment before release
  //MemChk;

  Application.Initialize;
  Application.ShowMainForm := False;

  // unregister association when uninstalling (see inno setup script)
  if (ParamCount >= 1) and (ParamStr(1) = '/uninstall') then
    begin
      Uninstall;
      exit
    end;

  // show user interface
  Application.Title := 'Drago';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TActions, Actions);
  WelcomeFirstTime;
  fmMain.Hide;
  fmMain.Start;
  fmMain.Show;
  Application.Run
end.

// ---------------------------------------------------------------------------


