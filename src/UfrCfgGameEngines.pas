// ---------------------------------------------------------------------------
// -- Drago -- Engine settings frame ---------------- UfrCfgGameEngines.pas --
// ---------------------------------------------------------------------------

unit UfrCfgGameEngines;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, TntGrids, SpTBXControls, StdCtrls, TntStdCtrls, SpTBXItem,
  TntIniFiles, Buttons,
  EngineSettings, SpTBXEditors, ExtCtrls, CheckLst,
  TntCheckLst, ImgList;

type
  // see implementation for comments
  TSpTBXCheckListBox = class(SpTBXEditors.TSpTBXCheckListBox)
  private
    procedure CNDrawItem(var msg : TWMDrawItem); message CN_DRAWITEM;
  end;

type
  TfrCfgGameEngines = class(TFrame)
    gbGameEngine: TSpTBXGroupBox;
    SpTBXLabel1: TSpTBXLabel;
    edName: TTntEdit;
    SpTBXLabel3: TSpTBXLabel;
    btPath: TSpeedButton;
    lbPath: TSpTBXLabel;
    SpTBXGroupBox1: TSpTBXGroupBox;
    btAdd: TSpTBXButton;
    btDelete: TSpTBXButton;
    sg: TTntStringGrid;
    clAnalysisFeatures: TSpTBXCheckListBox;
    clPlayingFeatures: TSpTBXCheckListBox;
    SpTBXLabel4: TSpTBXLabel;
    SpTBXLabel5: TSpTBXLabel;
    ImageList: TImageList;
    SpTBXLabel6: TSpTBXLabel;
    cxUsedForGame: TSpTBXCheckBox;
    cxUsedForAnalysis: TSpTBXCheckBox;
    SpTBXLabel2: TSpTBXLabel;
    btParameters: TSpeedButton;
    edArgs: TSpTBXEdit;
    edPath: TTntEdit;
    procedure edNameChange(Sender: TObject);
    procedure cxUsedForGameClick(Sender: TObject);
    procedure cxUsedForAnalysisClick(Sender: TObject);
    procedure btPathClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgClick(Sender: TObject);
    procedure sgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btParametersClick(Sender: TObject);
  private
    FEngineList : TEngineSettingList;
    function  CurrentEngineSettings : TEngineSettings;
    procedure DisplayFeatures(engineSettings : TEngineSettings);
    procedure ResetFeatures;
    procedure DisplayEngineData(index : integer);
    procedure ToggleGameUsage(index : integer);
    procedure ToggleAnalysisUsage(index : integer);
    procedure sgClickExecute(ACol, ARow: Integer);
    procedure GetEngineInformation(fromPathInput : boolean);
    procedure SetPathEditBoxText(text : WideString);
  public
    procedure Initialize(iniFile : TTntMemIniFile);
    procedure Finalize;
    procedure UpdateIniFile(iniFile : TTntMemIniFile);
    procedure PredefineEngine(engineName : string);
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  Types, SysUtilsEx,
  TntGraphics,
  DefineUi, UfmAdditionalArguments, VclUtils, UfmMsg,
  Std, Translate, UDialogs, UStatus, UEngines;

// -- Initialization, finalization and update of frame -----------------------

procedure TfrCfgGameEngines.Initialize(iniFile : TTntMemIniFile);
var
  playingEngine, i : integer;
begin
  FEngineList := TEngineSettingList.Create;
  FEngineList.LoadIni(iniFile, Settings.UsePortablePaths, Status.AppPath);
  playingEngine := FEngineList.IndexOfPlayingEngine(iniFile);

  sg.RowCount := FEngineList.Count + 1;
  if FEngineList.Count <= 0
    then EnableControl(gbGameEngine, False)
    else
      begin
        sg.Row := playingEngine;
        DisplayEngineData(playingEngine - 1)
      end;

  sg.ColWidths[1] := sg.ClientWidth div 6;
  sg.ColWidths[2] := sg.ClientWidth div 6;
  sg.ColWidths[0] := sg.ClientWidth - sg.ClientWidth div 3;
  sg.Cells[0, 0] := '';
  sg.Cells[1, 0] := U('Game');
  sg.Cells[2, 0] := U('Analysis');

  // items must be disabled but not the whole box to keep the scrollbar
  // available
  for i := 0 to 8 do
    clPlayingFeatures.ItemEnabled[i] := False;
  for i := 0 to 3 do
    clAnalysisFeatures.ItemEnabled[i] := False
end;

procedure TfrCfgGameEngines.Finalize;
begin
  FEngineList.Free
end;

procedure TfrCfgGameEngines.UpdateIniFile(iniFile : TTntMemIniFile);
begin
  FEngineList.SaveIni(iniFile, Settings.UsePortablePaths, Status.AppPath)
end;

// -- Access to engine settings ----------------------------------------------

function TfrCfgGameEngines.CurrentEngineSettings : TEngineSettings;
var
  i : integer;
begin
  i := sg.Row - 1;
  if not Within(i, 0, FEngineList.Count - 1)
    then Result := nil
    else Result := FEngineList.Nth(i)
end;

// -- Clicking on string grid ------------------------------------------------

// goRowSelect is used to select and display the complete row. In that case,
// sg.ACol is always 0 after clicking and OnMouseDown must be used to toggle
// radio buttons on col 1 and 2.

// not used
procedure TfrCfgGameEngines.sgClick(Sender: TObject);
begin
  sgClickExecute(sg.Col, sg.Row)
end;

procedure TfrCfgGameEngines.sgMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow : Longint;
begin
  sg.MouseToCell(X, Y, ACol, ARow);
  sgClickExecute(ACol, ARow)
end;

procedure TfrCfgGameEngines.sgClickExecute(ACol, ARow: Integer);
begin
  if ARow = 0
    then exit;
    
  DisplayEngineData(ARow - 1);

  case ACol of
    0 : sg.Invalidate;
    1 : ToggleGameUsage(ARow - 1);
    2 : ToggleAnalysisUsage(ARow - 1)
  end
end;

procedure SetCheckBoxIgnoringOnClick(cx : TSpTBXCheckBox; value : boolean);
var
  onClick : TNotifyEvent;
begin
  onClick    := cx.OnClick;
  cx.OnClick := nil;
  cx.Checked := value;
  cx.OnClick := onClick
end;

procedure TfrCfgGameEngines.DisplayEngineData(index : integer);
var
  name, path, customArgs : WideString;
  usedForGame, usedForAnalysis : boolean;
begin          
  if not Within(index, 0, FEngineList.Count - 1)
    then exit;

  with FEngineList.Nth(index) do
    begin
      name := FName;
      path := FPath;
      customArgs := FCustomArgs;
      usedForGame := FUsedForGame;
      usedForAnalysis := FUsedForAnalysis
    end;

  edName.Text := name;
  SetPathEditBoxText(path);
  edArgs.Text := EngineArguments(CurrentEngineSettings);

  SetCheckBoxIgnoringOnClick(cxUsedForGame, usedForGame);
  SetCheckBoxIgnoringOnClick(cxUsedForAnalysis, usedForAnalysis);

  DisplayFeatures(FEngineList.Nth(index))
end;

// -- Usage check box events -------------------------------------------------

procedure TfrCfgGameEngines.cxUsedForGameClick(Sender: TObject);
begin
  ToggleGameUsage(sg.Row - 1)
end;

procedure TfrCfgGameEngines.cxUsedForAnalysisClick(Sender: TObject);
begin
  ToggleAnalysisUsage(sg.Row - 1)
end;

procedure TfrCfgGameEngines.ToggleGameUsage(index : integer);
begin
  FEngineList.ToggleGameUsage(index);
  SetCheckBoxIgnoringOnClick(cxUsedForGame, FEngineList.Nth(index).FUsedForGame);
  sg.Invalidate
end;

procedure TfrCfgGameEngines.ToggleAnalysisUsage(index : integer);
begin
  FEngineList.ToggleAnalysisUsage(index);
  SetCheckBoxIgnoringOnClick(cxUsedForAnalysis, FEngineList.Nth(index).FUsedForAnalysis);
  sg.Invalidate
end;

// -- Drawing of string grid -------------------------------------------------

procedure TfrCfgGameEngines.sgDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  name, s : WideString;
  useForGame, useForAnalysis : boolean;
  image : integer;
begin
  if not Within(ARow, 0, FEngineList.Count)
    then exit;

  if gdSelected in State
    then sg.Canvas.Brush.Color := $F0F0F0
    else sg.Canvas.Brush.Color := clWhite;
  sg.Canvas.FillRect(rect);

  if ARow = 0
    then s := sg.Cells[ACol, ARow]
    else
      with FEngineList.Nth(ARow - 1) do
        begin
          name           := FName;
          useForGame     := FUsedForGame;
          useForAnalysis := FUsedForAnalysis;
          s := name
        end;

  if (ACol = 0) or (ARow = 0)
    then WideCanvasTextOut(sg.Canvas, Rect.Left + 5, Rect.Top + 5, s)
    else
      begin
        if ((ACol = 1) and useForGame) or ((ACol = 2) and useForAnalysis)
          then image := 1
          else image := 0;

        ImageList.Draw(sg.Canvas, Rect.Left + 5, Rect.Top + 3, image)
      end
end;

// -- Buttons associated with list of engines --------------------------------

procedure TfrCfgGameEngines.btAddClick(Sender: TObject);
begin
  // handled in fmOptions
end;

procedure TfrCfgGameEngines.btDeleteClick(Sender: TObject);
var
  index : integer;
  wasUsedForGame, wasUsedForAnalysis : boolean;
begin
  index := sg.Row - 1;
  if not Within(index, 0, FEngineList.Count - 1)
    then exit;

  wasUsedForGame     := FEngineList.Nth(index).FUsedForGame;
  wasUsedForAnalysis := FEngineList.Nth(index).FUsedForAnalysis;

  edName.Text := '';
  SetPathEditBoxText('');
  FEngineList.Nth(index).Free;
  FEngineList.Delete(index);
  EnableControl(gbGameEngine, FEngineList.Count > 0);
  ResetFeatures;

  sg.RowCount := sg.RowCount - 1;

  if wasUsedForGame and (sg.RowCount > 1)
    then FEngineList.Nth(0).FUsedForGame := True;
  if wasUsedForAnalysis and (sg.RowCount > 1)
    then FEngineList.Nth(0).FUsedForAnalysis := True;

  //sg.Invalidate;
  SetCheckBoxIgnoringOnClick(cxUsedForGame, False);
  SetCheckBoxIgnoringOnClick(cxUsedForAnalysis, False);
  DisplayEngineData(sg.Row - 1)
end;

procedure TfrCfgGameEngines.PredefineEngine(engineName : string);
var
  engineSettings : TEngineSettings;
begin
  // create and initialize new engine settings instance
  engineSettings := TEngineSettings.Create;
  engineSettings.ReadPredefinedSettings(Status.AppPath, engineName);
  FEngineList.AddObject(engineName, engineSettings);
  EnableControl(gbGameEngine, True);

  // add row to grid
  sg.RowCount := sg.RowCount + 1;
  sg.Row := sg.RowCount - 1;
  sg.Invalidate;

  // update display
  edName.Text := engineName;
  SetPathEditBoxText('');
  edArgs.Text := EngineArguments(CurrentEngineSettings);
  edArgs.Enabled := False;

  if sg.RowCount = 2 then
    begin
      // only one engine
      FEngineList.Nth(0).FUsedForGame := True;
      FEngineList.Nth(0).FUsedForAnalysis := True;
    end;

  SetCheckBoxIgnoringOnClick(cxUsedForGame, FEngineList.Nth(sg.Row - 1).FUsedForGame);
  SetCheckBoxIgnoringOnClick(cxUsedForAnalysis, FEngineList.Nth(sg.Row - 1).FUsedForAnalysis);

  ResetFeatures
end;

// ---------------------------------------------------------------------------

procedure TfrCfgGameEngines.edNameChange(Sender: TObject);
begin
  if CurrentEngineSettings <> nil
    then CurrentEngineSettings.FName := edName.Text;
  if sg.RowCount > 0
    then sg.Cells[0, sg.Row] := edName.Text
end;

procedure TfrCfgGameEngines.SetPathEditBoxText(text : WideString);
begin
  if text = ''
    then
      begin
        edPath.Font.Color := clRed;
        edPath.Text := U('Select engine path');
        lbPath.Caption := ''
      end
    else
      begin
        edPath.Font.Color := clBlack;
        edPath.Text := text;
        lbPath.Caption := WideMinimizeLabel(lbPath, edPath.Text)
      end
end;

// --- Path and additional parameters input ----------------------------------

procedure TfrCfgGameEngines.btPathClick(Sender: TObject);
var
  sPath, sName, filename : WideString;
begin
  if CurrentEngineSettings = nil
    then exit;

  if Settings.PlayingEngine.FPath <> ''
    then
      begin
        sPath := WideExtractFilePath(Settings.PlayingEngine.FPath);
        sName := WideExtractFileName(Settings.PlayingEngine.FPath)
      end
    else
      begin
        sPath := Status.AppPath;
        sName := ''
      end;

  if not OpenDialog('Game engine', sPath, sName, 'exe',
                    U('Application') + ' (*.exe)|*.exe',
                    filename)
    then exit;

  SetPathEditBoxText(filename);
  CurrentEngineSettings.FPath := filename;
  GetEngineInformation(True)
end;

procedure TfrCfgGameEngines.btParametersClick(Sender: TObject);
begin
  if CurrentEngineSettings = nil
    then exit;

  if not TfmAdditionalArguments.Execute(CurrentEngineSettings)
    then exit;

  edArgs.Text := EngineArguments(CurrentEngineSettings);
  GetEngineInformation(False)
end;

procedure TfrCfgGameEngines.GetEngineInformation(fromPathInput : boolean);
var
  detected : boolean;
  ident : string;
begin
  // look for features and ident (name + version)
  EngineInformation(CurrentEngineSettings, detected, ident);

  if not detected
    then
      begin
        ResetFeatures;
        edName.Text := '';
        MessageDialog(msOk, imExclam,
                      [U('Engine not able to start. Check path or parameters.')])
      end
    else
      begin
        if fromPathInput or (edName.Text = '')
          then edName.Text := ident;
        DisplayFeatures(CurrentEngineSettings)
      end
end;

// -- Handling of lists of features ------------------------------------------

procedure TfrCfgGameEngines.DisplayFeatures(engineSettings : TEngineSettings);
begin
  with engineSettings do
    begin
      clPlayingFeatures.Checked[0]  := FAvailChineseRules;
      clPlayingFeatures.Checked[1]  := FAvailJapaneseRules;
      clPlayingFeatures.Checked[2]  := FAvailFixedHandicap;
      clPlayingFeatures.Checked[3]  := FAvailFreeHandicap;
      clPlayingFeatures.Checked[4]  := FAvailTimePerMove;
      clPlayingFeatures.Checked[5]  := FAvailTotalTime;
      clPlayingFeatures.Checked[6]  := FAvailOverTime;
      clPlayingFeatures.Checked[7]  := FAvailUndo;
      clPlayingFeatures.Checked[8]  := FAvailDetailedResults;

      clAnalysisFeatures.Checked[0] := FAvailScoreEstimate;
      clAnalysisFeatures.Checked[1] := FAvailMoveSuggestion;
      clAnalysisFeatures.Checked[2] := FAvailInfluenceRegion;
      clAnalysisFeatures.Checked[3] := FAvailGroupStatus;
    end
end;

procedure TfrCfgGameEngines.ResetFeatures;
var
  i : integer;
begin
  for i := 0 to 8 do
    clPlayingFeatures.Checked[i] := False;

  for i := 0 to 3 do
    clAnalysisFeatures.Checked[i] := False
end;

// TSpTBXCheckListBox is subclassed to redefine CNDrawItem and get rid of
// focus and selection rectangles. Could have been done with OnDrawItem but
// Russian characters are not rendered correctly.

procedure TSpTBXCheckListBox.CNDrawItem(var msg : TWMDrawItem);
begin
  with msg do
    DrawItemStruct.itemState := DrawItemStruct.itemState
                                and (not ODS_FOCUS)
                                and (not ODS_SELECTED);
  inherited
end;

// ---------------------------------------------------------------------------

end.
