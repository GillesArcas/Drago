// ---------------------------------------------------------------------------
// -- Drago -- New engine game form ------------------ UfmNewEngineGame.pas --
// ---------------------------------------------------------------------------

unit UfmNewEngineGame;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, TntIniFiles, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus,
  TB2Item, SpTBXControls, SpTBXItem, SpTBXEditors, TntForms, TntStdCtrls,
  DefineUi, EngineSettings, UTimePicker;

type
  TfmNewEngineGame = class(TTntForm)
    Label1: TLabel;
    gbTimeSettings: TSpTBXGroupBox;
    rbNoTime: TSpTBXRadioButton;
    rbTotalTime: TSpTBXRadioButton;
    rbTimePerMove: TSpTBXRadioButton;
    lbTotalTime: TSpTBXLabel;
    lbTimePerMove: TSpTBXLabel;
    rgScoring: TSpTBXRadioGroup;
    gbEngine: TSpTBXGroupBox;
    cbEngines: TTntComboBox;
    pnValues: TSpTBXGroupBox;
    cbBoardSize: TComboBox;
    cbHandicap: TComboBox;
    cbKomi: TComboBox;
    rbOverTime: TSpTBXRadioButton;
    pnOverTime: TPanel;
    SpTBXLabel7: TSpTBXLabel;
    dtOverStones: TDateTimePicker;
    SpTBXLabel6: TSpTBXLabel;
    SpTBXLabel5: TSpTBXLabel;
    cxShowGtpWindow: TSpTBXCheckBox;
    Panel1: TPanel;
    edMessage: TSpTBXEdit;
    gbStartPosition: TSpTBXGroupBox;
    rbNewGame: TSpTBXRadioButton;
    rbCurrentPosition: TSpTBXRadioButton;
    rbAutoHandicap: TSpTBXRadioButton;
    TntLabel1: TSpTBXLabel;
    rbEngineBlack: TSpTBXRadioButton;
    rbEngineWhite: TSpTBXRadioButton;
    tpTotalTime: TTimePicker;
    tpTimePerMove: TTimePicker;
    tpMainTime: TTimePicker;
    tpOverTime: TTimePicker;
    Label2: TSpTBXLabel;
    Label5: TSpTBXLabel;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    btMore: TSpTBXButton;
    SpTBXPopupMenu1: TSpTBXPopupMenu;
    mnEngineSettings: TSpTBXItem;
    mnMoreEngines: TSpTBXItem;
    SpTBXItem1: TSpTBXItem;
    cxFree: TSpTBXCheckBox;
    lbSize: TSpTBXLabel;
    lbHandicap: TSpTBXLabel;
    lbKomi: TSpTBXLabel;
    lbLevel: TSpTBXLabel;
    lbName: TSpTBXLabel;
    cbLevel: TTntComboBox;
    cxEngineOnlyTiming: TSpTBXCheckBox;
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure StartPositionClick(Sender: TObject);
    procedure cbHandicapChange(Sender: TObject);
    procedure cbBoardSizeChange(Sender: TObject);
    procedure cbLevelChange(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure btMoreEnginesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbEnginesChange(Sender: TObject);
    procedure SetupEngineList(iniFile : TTntMemIniFile);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimeButtonClick(Sender: TObject);
    procedure mnEngineSettingsClick(Sender: TObject);
    procedure rgScoringClick(Sender: TObject);
  private
    FEngineList : TEngineSettingList;
    AllFeaturesAvailable : boolean;
    btChineseRules : TSpTBXRadioButton;
    btJapaneseRules : TSpTBXRadioButton;
    TimingButtons : array[0 .. 3] of TSpTBXRadioButton;
    function  Enter : integer;
    procedure ApplySettings;
    procedure UpdateSettings;
    procedure UpdateForStartPosition(mode, size, level : integer);
    procedure DoUpdateForStartPosition(mode, size, handicap, engineColor : integer;
                                       komi : real);
    procedure SetupValuesForManualHandicap(size : integer);
    procedure SetupValuesForAutoHandicap(size, level : integer);
    procedure SetupValuesForCurrentPos;
    procedure EnableChangeValues(mode, handicap : integer);
    function  ValidateSize : boolean;
    procedure ConfigureForEngine;
    procedure MessageOut(const msg : string; msgColor : TColor);
    function  GetStartPositionMode : integer;
    function  GetTimingMode : TTimingMode;
    function  GetScoringMode : TScoring;
    function  GetHandicap : integer;
    procedure EnableTimingComponents(buttonChecked : TObject);
    //procedure WndProc(var Message : TMessage) ; override ;
    function  EnabledComponent(x : TObject) : boolean;
    procedure DisableWindow;
  public
    class function Execute : integer;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils,
  Define, Std, Properties, Translate, TranslateVcl, Main, UStatus,
  UGameTree, HtmlHelpAPI, UEngines,
  BoardUtils, UfmOptions, Counting, Ux2y, VclUtils;

{$R *.DFM}

// -- Utils ------------------------------------------------------------------

function SecondsToTime(n : integer) : TDateTime;
begin
  Result := n / (24 * 3600)
end;

function TimeToSeconds(time : TDateTime) : integer;
begin
  Result := Round(Frac(time) * 24 * 3600) 
end;

function TryKomiToFloat(const komi : string; out value : double) : boolean;
var
  formatSettings : TFormatSettings;
  s : string;
begin
  // make sure dot is used as the decimal separator in the komi string
  s := StringReplace(komi, ',', '.', []);

  // make sure dot is used as the decimal separator during conversion
  formatSettings.DecimalSeparator := '.';

  Result := TryStrToFloat(s, value, formatSettings)
end;

function KomiToFloat(const komi : string) : double;
var
  value : double;
begin
  TryKomiToFloat(komi, value);
  Result := value
end;

// -- Display request --------------------------------------------------------

class function TfmNewEngineGame.Execute : integer;
begin
  with TfmNewEngineGame.Create(Application) do
    try
      Result := Enter
    finally
      Release
    end
end;

procedure TfmNewEngineGame.FormCreate(Sender: TObject);
begin
  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;

  btJapaneseRules := rgScoring.Components[0] as TSpTBXRadioButton;
  btChineseRules  := rgScoring.Components[1] as TSpTBXRadioButton;

  // make array of timing buttons
  TimingButtons[0] := rbNoTime;
  TimingButtons[1] := rbTotalTime;
  TimingButtons[2] := rbTimePerMove;
  TimingButtons[3] := rbOverTime;

  // init tags of start position buttons to be used in click events
  rbNewGame.Tag := spSelect;
  rbCurrentPosition.Tag := spCurrent;
  rbAutoHandicap.Tag := spMatch;

  // set style of time pickers
  tpTotalTime  .HourStyle := True;
  tpTimePerMove.HourStyle := False;
  tpMainTime   .HourStyle := True;
  tpOverTime   .HourStyle := False;

  FEngineList := TEngineSettingList.Create;

  // this fixes a display problem with some resolutions and font settings
  tpTotalTime  .Width := dtOverStones.Width;
  tpTimePerMove.Width := dtOverStones.Width;
  tpMainTime   .Width := dtOverStones.Width;
  tpOverTime   .Width := dtOverStones.Width
end;

function TfmNewEngineGame.Enter : integer;
begin
  Caption := AppName + ' - ' + U('New engine game');
  TranslateForm(Self);

  // adjust some components after translation
  cxFree.Left := lbKomi.Left;
  cxFree.ClientWidth := cbKomi.Left + cbKomi.Width - lbKomi.Left;
  // idem
  cxShowGtpWindow.Left := rgScoring.Left + rgScoring.Width - cxShowGtpWindow.ClientWidth;

  ApplySettings;
  Result := ShowModal
end;

procedure TfmNewEngineGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FEngineList.Free
end;

// -- Interface with settings ------------------------------------------------

procedure TfmNewEngineGame.ApplySettings;
begin
  SetupEngineList(fmMain.IniFile);

  if FEngineList.Count = 0 then
    begin
      DisableWindow;
      MessageOut('No engine defined. Please select ''More...'' then ''More engines...''', clMaroon);
      exit
    end;

  if Settings.PlayingEngine.IsAvailable = False then
    begin
      DisableWindow;
      gbEngine .Enabled := True;
      cbEngines.Enabled := True;
      MessageOut('Current engine not found. Please select ''More...'' then ''Engine settings...'' and check path.', clMaroon);
      exit
    end;

  EnableControl(self, True);

  cxFree.Enabled := EnabledComponent(cxFree);
  cxFree.Checked := cxFree.Enabled and Settings.PlFree;

  // time settings
  SetNthRadioButton(TimingButtons, integer(Settings.PlTimingMode));
  TimeButtonClick  (TimingButtons[integer(Settings.PlTimingMode)]);
  tpTotalTime.Seconds   := Settings.PlTotalTime;
  tpTimePerMove.Seconds := Settings.PlTimePerMove;
  tpMainTime.Seconds    := Settings.PlMainTime div 60 * 60;
  tpOverTime.Seconds    := Settings.PlOverTime;
  dtOverStones.Time     := SecondsToTime(Settings.PlOverStones);
  cxEngineOnlyTiming.Checked := Settings.EngineOnlyTiming;

  ConfigureForEngine;
  Settings.Komi := Settings.KomiForEngine;

  SetComboValue(cbHandicap, IntToStr(Settings.Handicap));
  UpdateForStartPosition(Settings.PlStartPos, Settings.BoardSize, Settings.PlayingEngine.FLevel);
  SetNthRadioButton([rbNewGame, rbCurrentPosition, rbAutoHandicap],
                    integer(Settings.PlStartPos));

  //ConfigureForEngine;
end;

procedure TfmNewEngineGame.DisableWindow;
begin
  EnableControl(self, False);

  btCancel.Enabled  := True;
  btHelp.Enabled    := True;
  btMore.Enabled    := True;
  edMessage.Enabled := True
end;

procedure TfmNewEngineGame.UpdateSettings;
begin
  // save usage. Necessary if no playing engine was defined, and game starts
  // with first engine available
  FEngineList.Nth(cbEngines.ItemIndex).FUsedForGame := True;

  // save level if necessary
  if Settings.PlayingEngine.FAvailLevel
    then FEngineList.Nth(cbEngines.ItemIndex).FLevel := StrToIntDef(cbLevel.Text, DefaultLevel);

  // save whole engine list to save playing engine
  FEngineList.SaveIni(fmMain.IniFile, Settings.UsePortablePaths, Status.AppPath);

  // update playing engine
  Settings.PlayingEngine.LoadPlayingEngine(fmMain.IniFile, Settings.UsePortablePaths, Status.AppPath);

  with Settings do
    begin
      newInFile     := False;
      PlPlayer      := 1 + ord(rbEngineWhite.Checked);
      PlStartPos    := GetStartPositionMode;
      PlGame        := True;
      PlFree        := cxFree.Checked;
      PlTimingMode  := GetTimingMode;

      PlTotalTime   := tpTotalTime.Seconds;
      PlTimePerMove := tpTimePerMove.Seconds;
      PlMainTime    := tpMainTime.Seconds;
      PlOverTime    := tpOverTime.Seconds;
      PlOverStones  := TimeToSeconds(dtOverStones.Time);
      PlScoring     := GetScoringMode;
      EngineOnlyTiming := cxEngineOnlyTiming.Checked;

      case PlStartPos of
        spSelect :
          begin
            BoardSize := StrToInt(cbBoardSize.Text);
            Handicap  := StrToIntDef(cbHandicap.Items[cbHandicap.ItemIndex], 0);
            if Handicap = 0
              then Komi := KomiToFloat(cbKomi.Text);
          end;
        spCurrent :
          begin
            // handled in DoMainNewEngineGame
          end;
        spMatch :
          begin
            BoardSize := StrToInt(cbBoardSize.Text);
            Settings.PlayingEngine.ReadMatch(fmMain.IniFile, BoardSize, Settings.PlayingEngine.FLevel,
                                             plPlayer, handicap);
            if Handicap = 0
              then Komi := KomiToFloat(cbKomi.Text);
          end
      end;

      KomiForEngine := Komi
    end
end;

// -- Load list of engines and setup engines combo ---------------------------

procedure TfmNewEngineGame.SetupEngineList(iniFile : TTntMemIniFile);
var
  playingEngine : integer;
begin
  FEngineList.Clear;
  FEngineList.LoadIni(iniFile, False, Status.AppPath);
  cbEngines.Items.Assign(FEngineList);
  playingEngine := FEngineList.IndexOfPlayingEngine(iniFile);
  cbEngines.ItemIndex := playingEngine - 1; // engines are 1-based in inifile
end;

// -- Update dialog using settings of current playing engine ----------------- 

procedure TfmNewEngineGame.ConfigureForEngine;
var
  levelEnabled        : boolean;
  totalTimeEnabled    : boolean;
  timePerMoveEnabled  : boolean;
  overTimeEnabled     : boolean;
  chineseEnabled      : boolean;
  japaneseEnabled     : boolean;
  freeHandicapEnabled : boolean;
  i : integer;
begin
  // -- level

  levelEnabled := Settings.PlayingEngine.FAvailLevel;

  lbLevel.Enabled := levelEnabled;
  cbLevel.Enabled := levelEnabled;

  SetComboValue(cbLevel, iff(levelEnabled,
                             IntToStr(Settings.PlayingEngine.FLevel),
                             U('not defined')));
  // -- timing

  totalTimeEnabled   := Settings.PlayingEngine.FAvailTotalTime;
  timePerMoveEnabled := Settings.PlayingEngine.FAvailTimePerMove;
  overTimeEnabled    := Settings.PlayingEngine.FAvailOverTime;
  
  i := GetNthRadioButton(TimingButtons);
  EnableTimingComponents(TimingButtons[i]);
  
  // if checked button is disabled, check the first one
  if (i < 0) or (TimingButtons[i].Enabled = False)
    then rbNoTime.Checked := True;

  // -- rules

  chineseEnabled  := Settings.PlayingEngine.FAvailChineseRules;
  japaneseEnabled := Settings.PlayingEngine.FAvailJapaneseRules;

  btChineseRules.Enabled  := chineseEnabled;
  btJapaneseRules.Enabled := japaneseEnabled;

  // -- rule settings

  if chineseEnabled and japaneseEnabled
    then rgScoring.ItemIndex := integer(Settings.PlScoring)
    else
      if chineseEnabled
        then btChineseRules.Checked := True
        else
          if japaneseEnabled
            then btJapaneseRules.Checked := True
            else
              begin
                // may happen only if engines.config modified
                btChineseRules.Checked := False;
                btJapaneseRules.Checked := False
              end;

  // -- free handicap

  freeHandicapEnabled := Settings.PlayingEngine.FAvailFreeHandicap;
  cxFree.Enabled := EnabledComponent(cxFree);

  // -- all features available flag

  AllFeaturesAvailable := totalTimeEnabled and timePerMoveEnabled and
                          overTimeEnabled  and chineseEnabled     and
                          japaneseEnabled  and freeHandicapEnabled;
  if AllFeaturesAvailable
    then MessageOut('', clDkGray)
    else MessageOut('Not all functions are supported by the engine currently selected.',
                    clDkGray)
end;

// -- Update of size+handicap+komi panel -------------------------------------

procedure TfmNewEngineGame.UpdateForStartPosition(mode, size, level : integer);
begin
  case mode of
    spSelect :
      SetupValuesForManualHandicap(size);
    spCurrent :
      SetupValuesForCurrentPos;
    spMatch :
      SetupValuesForAutoHandicap(size, level);
    else
      // nop
  end
end;

// handicap is selected by user

procedure TfmNewEngineGame.SetupValuesForManualHandicap(size : integer);
var
  handicap, engineColor : integer;
  komi : real;
begin
  komi        := KomiValue;
  handicap    := Settings.Handicap;
  engineColor := Settings.PlPlayer;

  DoUpdateForStartPosition(spSelect, size, handicap, engineColor, komi)
end;

// settings from current game

procedure TfmNewEngineGame.SetupValuesForCurrentPos;
var
  size, handicap, engineColor : integer;
  komi : real;
begin
  size        := Settings.BoardSize;
  komi        := pv2real(fmMain.ActiveView.gt.Root.GetProp(prKM));
  handicap    := pv2int (fmMain.ActiveView.gt.Root.GetProp(prHA));
  engineColor := Settings.PlPlayer;

  DoUpdateForStartPosition(spCurrent, size, handicap, engineColor, komi);

  // todo : should not be there
  Settings.Handicap := handicap;
  Settings.Komi     := komi;
end;

// handicap is given by previous game

procedure TfmNewEngineGame.SetupValuesForAutoHandicap(size, level : integer);
var
  handicap, engineColor : integer;
  komi : real;
begin
  Settings.PlayingEngine.ReadMatch(fmMain.IniFile, size, level,
                                   engineColor, handicap);
  komi := KomiValue(Settings.PlScoring, handicap, Settings.Komi);

  DoUpdateForStartPosition(spMatch, size, handicap, engineColor, komi);
  rbEngineBlack.Enabled := engineColor = Black;
  rbEngineWhite.Enabled := engineColor = White;

  // todo : should not be there
  Settings.Handicap := handicap;
end;

// update proc

procedure TfmNewEngineGame.DoUpdateForStartPosition(mode, size, handicap, engineColor : integer;
                                                    komi : real);
begin
  SetComboValue(cbBoardSize, IntToStr(size));
  SetComboValue(cbKomi, FloatToStr(komi));
  SetComboValue(cbHandicap, IntToStr(handicap));
  rbEngineBlack.Checked := engineColor = Black;
  rbEngineWhite.Checked := engineColor = White;
  EnableChangeValues(mode, handicap)
end;

procedure TfmNewEngineGame.EnableChangeValues(mode, handicap : integer);
begin
  pnValues.Enabled      := mode in [spSelect, spMatch];
  lbSize.Enabled        := mode in [spSelect, spMatch];
  cbBoardSize.Enabled   := mode in [spSelect, spMatch];
  lbHandicap.Enabled    := mode in [spSelect];
  cbHandicap.Enabled    := mode in [spSelect];
  lbKomi.Enabled        := (mode in [spSelect, spMatch]) and ({Settings.H}handicap = 0);
  cbKomi.Enabled        := (mode in [spSelect, spMatch]) and ({Settings.H}handicap = 0);
  rbEngineBlack.Enabled := True;
  rbEngineWhite.Enabled := True;
  cxFree.Enabled        := EnabledComponent(cxFree);
end;

// -- Ok button --------------------------------------------------------------

function TfmNewEngineGame.ValidateSize : boolean;
var
  n : integer;
begin
  Result := TryStrToInt(cbBoardSize.Text, n);
  Result := Result and Within(n, 5, 19);
  if not Result
    then ActiveControl := cbBoardSize
end;

procedure TfmNewEngineGame.btOkClick(Sender : TObject);
var
  a : double;
begin
  if not ValidateSize
    then exit;

  if not TryKomiToFloat(cbKomi.Text, a) then
    begin
      if cbKomi.CanFocus
        then ActiveControl := cbKomi;
      exit
    end;

  UpdateSettings;

  if cxShowGtpWindow.Checked
    then ShowGtpWindow;

  ModalResult := mrOK
end;

// -- Cancel button ----------------------------------------------------------

procedure TfmNewEngineGame.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

// -- Help Button ------------------------------------------------------------

procedure TfmNewEngineGame.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_Engine)
end;

// -- Options button ---------------------------------------------------------

procedure TfmNewEngineGame.mnEngineSettingsClick(Sender: TObject);
begin
  TfmOptions.Execute(eoEngines);
  ApplySettings
end;

procedure TfmNewEngineGame.btMoreEnginesClick(Sender: TObject);
begin
  TfmOptions.Execute(eoEngines2);
  ApplySettings
end;

// -- Events -----------------------------------------------------------------

procedure TfmNewEngineGame.cbEnginesChange(Sender: TObject);
begin
  FEngineList.ToggleGameUsage(cbEngines.ItemIndex);
  FEngineList.SaveIni(fmMain.IniFile, Settings.UsePortablePaths, Status.AppPath);
  Settings.PlayingEngine.LoadPlayingEngine(fmMain.IniFile, Settings.UsePortablePaths, Status.AppPath);
  
  //ConfigureForEngine;
  ApplySettings
end;

procedure TfmNewEngineGame.StartPositionClick(Sender: TObject);
begin
  UpdateForStartPosition((Sender as TComponent).Tag,
                         StrToInt(cbBoardSize.Text), StrToIntDef(cbLevel.Text, 0))
end;

// time button events, used to control permission on time pickers

procedure TfmNewEngineGame.TimeButtonClick(Sender: TObject);
begin
  EnableTimingComponents(Sender)
end;

procedure TfmNewEngineGame.EnableTimingComponents(buttonChecked : TObject);
var
  totalTimeEnabled    : boolean;
  timePerMoveEnabled  : boolean;
  overTimeEnabled     : boolean;
begin
  // status per feature
  totalTimeEnabled   := Settings.PlayingEngine.FAvailTotalTime;
  timePerMoveEnabled := Settings.PlayingEngine.FAvailTimePerMove;
  overTimeEnabled    := Settings.PlayingEngine.FAvailOverTime;

  // total time components
  rbTotalTime.Enabled := totalTimeEnabled;
  tpTotalTime.Enabled := totalTimeEnabled and (buttonChecked = rbTotalTime);
  lbTotalTime.Enabled := totalTimeEnabled and (buttonChecked = rbTotalTime);

  // time per move components
  rbTimePerMove.Enabled := timePerMoveEnabled;
  tpTimePerMove.Enabled := timePerMoveEnabled and (buttonChecked = rbTimePerMove);
  lbTimePerMove.Enabled := timePerMoveEnabled and (buttonChecked = rbTimePerMove);

  // over time components
  rbOverTime.Enabled := overTimeEnabled;
  EnableControl(pnOverTime, overTimeEnabled  and (buttonChecked = rbOverTime));
end;

procedure TfmNewEngineGame.cbLevelChange(Sender: TObject);
begin
  if GetStartPositionMode = spMatch
    then UpdateForStartPosition(spMatch, StrToInt(cbBoardSize.Text)
                                       , StrToIntDef(cbLevel.Text, 0))
end;

procedure TfmNewEngineGame.cbBoardSizeChange(Sender: TObject);
begin
  if not ValidateSize
    then exit;
      
  cbHandicapChange(Sender);

  if GetStartPositionMode = spMatch
    then UpdateForStartPosition(spMatch, StrToInt(cbBoardSize.Text)
                                       , StrToIntDef(cbLevel.Text, 0))
end;

procedure TfmNewEngineGame.cbHandicapChange(Sender: TObject);
begin
  cbHandicap.ItemIndex := Min(GetHandicap, MaxHandicap(StrToInt(cbBoardSize.Text)));

  cxFree.Enabled := EnabledComponent(cxFree);

  cbKomi.Enabled := GetHandicap = 0;

  if GetHandicap = 0
    then SetComboValue(cbKomi, FloatToStr(Settings.Komi))
    else SetComboValue(cbKomi, FloatToStr(KomiValue(GetScoringMode, GetHandicap, Settings.Komi)))
end;

procedure TfmNewEngineGame.rgScoringClick(Sender: TObject);
begin
  if GetHandicap = 0
    then // nop
    else SetComboValue(cbKomi, FloatToStr(KomiValue(GetScoringMode, GetHandicap, Settings.Komi)))
end;

// -- Helpers ----------------------------------------------------------------

procedure TfmNewEngineGame.MessageOut(const msg : string; msgColor : TColor);
begin
  edMessage.Font.Color := msgColor;
  edMessage.Text := '   ' + U(msg)
end;

function TfmNewEngineGame.GetStartPositionMode : integer;
begin
  Result := GetNthRadioButton([rbNewGame, rbCurrentPosition, rbAutoHandicap])
end;

function TfmNewEngineGame.GetTimingMode : TTimingMode;
begin
  Result := TTimingMode(GetNthRadioButton(TimingButtons))
end;

function TfmNewEngineGame.GetScoringMode : TScoring;
begin
  Result := TScoring(rgScoring.ItemIndex)
end;

function TfmNewEngineGame.GetHandicap : integer;
begin
  Result := cbHandicap.ItemIndex
end;

function TfmNewEngineGame.EnabledComponent(x : TObject) : boolean;
begin
  if x = cxFree then
    begin
      Result := (GetStartPositionMode in [0, 2]) and
                Settings.PlayingEngine.FAvailFreeHandicap and
                (cbHandicap.ItemIndex > 1) and
                (StrToIntDef(cbHandicap.Text, 0) > 1);
      exit
    end;
end;

// ---------------------------------------------------------------------------

end.
