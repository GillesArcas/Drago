unit EngineSettings;

// ---------------------------------------------------------------------------

interface

uses
  Classes, IniFiles, ClassesEx;

const
  EnginesConfig = 'engines.config';
  DefaultLevel  = 5;

type
  TEngineSettings = class
    FName : WideString;
    FPath : WideString;
    FRefEngine : string;
    FCustomArgs : string;
    FUsedForGame : boolean;
    FUsedForAnalysis : boolean;
    FLevel : integer;

    // connection argument
    FArgConnection        : string;

    // features available from command line arguments
    // read in engines.config with syntax arg:xxx
    FArgLevel             : string;
    FArgChineseRules      : string;
    FArgJapaneseRules     : string;
    FArgBoardSize         : string;
    FArgTimePerMove       : string;
    FArgTotalTime         : string;
    FArgOverTime          : string;

    // features available from special gtp commands
    // read in engines.config with syntax gtp:xxx
    FGtpLevel             : string;
    FGtpChineseRules      : string;
    FGtpJapaneseRules     : string;
    FGtpTimePerMove       : string;
    FGtpTotalTime         : string;

    // features available from gtp commands
    FAvailUndo            : boolean;
    FAvailFixedHandicap   : boolean;
    FAvailFreeHandicap    : boolean;
    FAvailScoreEstimate   : boolean;
    FAvailMoveSuggestion  : boolean;
    FAvailInfluenceRegion : boolean;
    FAvailGroupStatus     : boolean;
    FAvailTiming          : boolean;
    FAvailFinalScore      : boolean;
    FAvailDetailedResults : boolean;
    FAvailLoadSgf         : boolean;

    // more flags for command line arguments or special gtp commands
    FAvailLevel           : boolean;
    FAvailTotalTime       : boolean;
    FAvailTimePerMove     : boolean;
    FAvailOverTime        : boolean;
    FAvailChineseRules    : boolean;
    FAvailJapaneseRules   : boolean;

  private
    function  EncodeFeatures : integer;
    procedure DecodeFeatures(code : integer);
    procedure LoadIni(iniFile : TMemIniFile; index : integer;
                      usePortablePaths : boolean;
                      const appPath : WideString);
    procedure SaveIni(iniFile : TMemIniFile; index : integer;
                      usePortablePaths : boolean;
                      const appPath : WideString);
    function  MatchKey(boardsize, level : integer) : string;
  public
    constructor Create(const name : string = '');
    procedure LoadPlayingEngine(iniFile : TMemIniFile;
                                usePortablePaths : boolean;
                                const appPath : WideString);
    procedure LoadAnalysisEngine(iniFile : TMemIniFile;
                                 usePortablePaths : boolean;
                                 const appPath : WideString);
    procedure ReadPredefinedSettings(iniFile : TMemIniFile; const engineName : string); overload;
    procedure ReadPredefinedSettings(const appPath, engineName : string); overload;
    function  IsAvailable : boolean;
    function  IsConcerned(const value : string) : boolean;
    function  IsGtpTimeCommandRequired : boolean;
    procedure SetFeaturesFromString(const commands : string);
    procedure ReadMatch(iniFile : TMemIniFile;
                        boardsize, level : integer;
                        var engineColor, handicap : integer);
    procedure SaveMatch(iniFile : TMemIniFile;
                        boardsize, level : integer;
                        engineColor, handicap : integer;
                        engineWin : boolean);
  end;

  TEngineSettingList = class(TWideStringList)
  public
    destructor  Destroy; override;
    procedure Clear; override;
    procedure LoadIni(iniFile : TMemIniFile;
                      usePortablePaths : boolean; const appPath : WideString);
    procedure SaveIni(iniFile : TMemIniFile;
                      usePortablePaths : boolean; const appPath : WideString);
    function  IndexOfPlayingEngine(iniFile : TMemIniFile) : integer;
    function  Nth(index : integer) : TEngineSettings;
    procedure ToggleGameUsage(index : integer);
    procedure ToggleAnalysisUsage(index : integer);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Types, SysUtils, SysUtilsEx, StrUtils, Define, Std;

// -- Creation ---------------------------------------------------------------

constructor TEngineSettings.Create(const name : string = '');
begin
  FName            := name;
  FPath            := '';
  FCustomArgs      := '';
  FUsedForGame     := False;
  FUsedForAnalysis := False;
  FLevel           := DefaultLevel;
end;

// -- Feature helpers --------------------------------------------------------

// argument must have been obtained by using list_commands gtp command

procedure TEngineSettings.SetFeaturesFromString(const commands : string);
begin
  FAvailUndo            :=  Pos('undo'               , commands) > 0;
  FAvailFixedHandicap   := (Pos('fixed_handicap'     , commands) > 0) or
                           (Pos('set_free_handicap'  , commands) > 0);
  FAvailFreeHandicap    := (Pos('place_free_handicap', commands) > 0) and
                           (Pos('set_free_handicap'  , commands) > 0);
  FAvailScoreEstimate   :=  Pos('estimate_score'     , commands) > 0;
  FAvailMoveSuggestion  :=  Pos('reg_genmove'        , commands) > 0;
  FAvailInfluenceRegion :=  Pos('initial_influence'  , commands) > 0;
  FAvailGroupStatus     :=  Pos('dragon_status'      , commands) > 0;
  FAvailTiming          := (Pos('time_settings'      , commands) > 0) and
                           (Pos('time_left'          , commands) > 0);
  FAvailFinalScore      :=  Pos('final_score'        , commands) > 0;
  FAvailDetailedResults :=  Pos('final_status_list'  , commands) > 0;
  FAvailLoadSgf         :=  Pos('loadsgf'            , commands) > 0;
end;

function TEngineSettings.EncodeFeatures : integer;
begin
  Result := iff(FAvailUndo           , 1 shl  0, 0) +
            iff(FAvailFixedHandicap  , 1 shl  1, 0) +
            iff(FAvailFreeHandicap   , 1 shl  2, 0) +
            iff(FAvailScoreEstimate  , 1 shl  3, 0) +
            iff(FAvailMoveSuggestion , 1 shl  4, 0) +
            iff(FAvailInfluenceRegion, 1 shl  5, 0) +
            iff(FAvailGroupStatus    , 1 shl  6, 0) +
            iff(FAvailTiming         , 1 shl  7, 0) +
            iff(FAvailDetailedResults, 1 shl  8, 0) +
            iff(FAvailFinalScore     , 1 shl  9, 0) +
            iff(FAvailLoadSgf        , 1 shl 10, 0)
end;

procedure TEngineSettings.DecodeFeatures(code : integer);
begin
  FAvailUndo            := Odd(code shr  0);
  FAvailFixedHandicap   := Odd(code shr  1);
  FAvailFreeHandicap    := Odd(code shr  2);
  FAvailScoreEstimate   := Odd(code shr  3);
  FAvailMoveSuggestion  := Odd(code shr  4);
  FAvailInfluenceRegion := Odd(code shr  5);
  FAvailGroupStatus     := Odd(code shr  6);
  FAvailTiming          := Odd(code shr  7);
  FAvailDetailedResults := Odd(code shr  8);
  FAvailFinalScore      := Odd(code shr  9);
  FAvailLoadSgf         := Odd(code shr 10)
end;

// -- Access to predefined descriptions (engines.config) ---------------------

procedure ReadArgOrGtp(iniFile : TMemIniFile;
                       const engineName, key : string;
                       var arg, gtp : string);
var
  s : string;
begin
  arg := 'not.required';
  gtp := 'not.required';
  s   := iniFile.ReadString(engineName, key, 'not.handled');

  if s = 'not.required'
    then exit;

  if s = 'not.handled' then
    begin
      arg := 'not.handled';
      gtp := 'not.handled';
      exit
    end;

  if AnsiStartsStr('arg:', s)
    then arg := Copy(s, 5, MaxInt);

  if AnsiStartsStr('gtp:', s)
    then gtp := Copy(s, 5, MaxInt);
end;

procedure TEngineSettings.ReadPredefinedSettings(iniFile : TMemIniFile; const engineName : string);
var
  dum : string;
begin
  FName             := engineName; // user name
  FRefEngine        := engineName; // link to engines.config data, cannot be changed
  FPath             := '';         // not yet known

  ReadArgOrGtp(iniFile, engineName, 'connection',     FArgConnection,    dum);
  ReadArgOrGtp(iniFile, engineName, 'level',          FArgLevel,         dum);
  ReadArgOrGtp(iniFile, engineName, 'boardsize',      FArgBoardSize,     dum);
  ReadArgOrGtp(iniFile, engineName, 'japanese.rules', FArgJapaneseRules, FGtpJapaneseRules);
  ReadArgOrGtp(iniFile, engineName, 'chinese.rules',  FArgChineseRules,  FGtpChineseRules);
  ReadArgOrGtp(iniFile, engineName, 'time.per.move',  FArgTimePerMove,   FGtpTimePerMove);
  ReadArgOrGtp(iniFile, engineName, 'total.time',     FArgTotalTime,     FGtpTotalTime);
  ReadArgOrGtp(iniFile, engineName, 'overtime',       FArgOverTime,      dum);
  ReadArgOrGtp(iniFile, engineName, 'additional',     FCustomArgs,       dum);
  if FCustomArgs = 'not.handled'
    then FCustomArgs := '';

  FAvailLevel         := (FArgLevel         <> 'not.handled');
  FAvailTotalTime     := (FArgTotalTime     <> 'not.handled') or
                         (FGtpTotalTime     <> 'not.handled');
  FAvailTimePerMove   := (FArgTimePerMove   <> 'not.handled') or
                         (FGtpTimePerMove   <> 'not.handled');
  FAvailOverTime      := (FArgOverTime      <> 'not.handled');
  FAvailChineseRules  := (FArgChineseRules  <> 'not.handled') or
                         (FGtpChineseRules  <> 'not.handled');
  FAvailJapaneseRules := (FArgJapaneseRules <> 'not.handled') or
                         (FGtpJapaneseRules <> 'not.handled');
end;

procedure TEngineSettings.ReadPredefinedSettings(const appPath, engineName : string);
var
  iniFile : TMemIniFile;
begin
  iniFile := TMemIniFile.Create(appPath + EnginesConfig);
  ReadPredefinedSettings(iniFile, engineName);
  iniFile.Free
end;

// -- Access to inifile descriptions (Drago.ini) -----------------------------

const
  geName          = 0;
  geRef           = 1;
  gePath          = 2;
  geCustomArgs    = 3;
  geFeatures      = 4;
  geUsedForGame   = 5;
  geUsedForScore  = 6;
  geLevel         = 7;
  geDescrLength   = 8;

// Parsing of string engine description

// Load description number "index" in inifile, for instance:
// 1=GNU Go 3.8;Gnu Go;D:\GnuGo\gnugo-3.8rc1.exe;;959;1;0

procedure TEngineSettings.LoadIni(iniFile : TMemIniFile;
                                  index : integer;
                                  usePortablePaths : boolean;
                                  const appPath : WideString);
var
  key, s : string;
  strings : TStringDynArray;
begin
  key := IntToStr(index);
  s := iniFile.ReadString('Engine', key, '');
  Split(s, strings, ';');
  SetLength(strings, geDescrLength);

  FName            := UTF8Decode(strings[geName]);
  FRefEngine       := strings[geRef];
  FPath            := UTF8Decode(strings[gePath]);
  if usePortablePaths
    then FPath := WideAbsolutePath(FPath, appPath);
  FCustomArgs      := strings[geCustomArgs];
  FUsedForGame     := strings[geUsedForGame] = '1';
  FUsedForAnalysis := strings[geUsedForScore] = '1';
  FLevel           := StrToIntDef(strings[geLevel], DefaultLevel);

  ReadPredefinedSettings(ExtractFilePath(iniFile.FileName), FRefEngine);
  DecodeFeatures(StrToIntDef(strings[geFeatures], 0));

  // must be set again as they are reset by ReadPredefinedSettings
  FName := UTF8Decode(strings[geName]);
  FPath := UTF8Decode(strings[gePath]);
  FCustomArgs := strings[geCustomArgs]
end;

// Index of user engines

function IndexOfUserEngine(iniFile : TMemIniFile; const key : string) : integer;
begin
  Result := iniFile.ReadInteger('Engine', 'Count', 0);

  // no engines defined, return undefine value
  if Result = 0
    then exit;

  Result := iniFile.ReadInteger('Engine', key, 0);

  // some engines are defined, but not the playing engine, return the first one
  if Result = 0
    then Result := 1
end;

// Load playing and analysis engines

procedure TEngineSettings.LoadPlayingEngine(iniFile : TMemIniFile;
                                            usePortablePaths : boolean;
                                            const appPath : WideString);
var
  index : integer;
begin
  index := IndexOfUserEngine(iniFile, 'PlayingEngine');
  if index = 0
    then FUsedForGame := False
    else LoadIni(iniFile, index, usePortablePaths, appPath)
end;

procedure TEngineSettings.LoadAnalysisEngine(iniFile : TMemIniFile;
                                             usePortablePaths : boolean;
                                             const appPath : WideString);
var
  index : integer;
begin
  index := IndexOfUserEngine(iniFile, 'AnalysisEngine');
  if index = 0
    then FUsedForAnalysis := False
    else LoadIni(iniFile, index, usePortablePaths, appPath)
end;

// Test availability (only by testing path)

function TEngineSettings.IsAvailable : boolean;
begin
  Result := WideFileExists(FPath)
end;

// Construction of string engine description

procedure TEngineSettings.SaveIni(iniFile : TMemIniFile;
                                  index : integer;
                                  usePortablePaths : boolean;
                                  const appPath : WideString);
var
  key, s : string;
  strings : TStringDynArray;
begin
  SetLength(strings, geDescrLength);

  strings[geName]         := UTF8Encode(FName);
  strings[geRef]          := FRefEngine;
  if usePortablePaths
    then strings[gePath] := WideRelativePath(UTF8Encode(FPath), appPath)
    else strings[gePath] := WideAbsolutePath(UTF8Encode(FPath), appPath);
  strings[geCustomArgs]   := FCustomArgs;
  strings[geUsedForGame]  := iff(FUsedForGame, '1', '0');
  strings[geUsedForScore] := iff(FUsedForAnalysis, '1', '0');
  strings[geFeatures]     := IntToStr(EncodeFeatures);
  strings[geLevel]        := IntToStr(FLevel);

  s := Join(';', strings, False);
  key := IntToStr(index);
  iniFile.WriteString('Engine', key, s);

  if FUsedForGame
    then iniFile.WriteInteger('Engine', 'PlayingEngine', index);
  if FUsedForAnalysis
    then iniFile.WriteInteger('Engine', 'AnalysisEngine', index);
end;

// -- Auto handicap helpers --------------------------------------------------

// Save or retry from inifile player and handicap for engine, boardsize, level

procedure TEngineSettings.ReadMatch(iniFile : TMemIniFile;
                                    boardsize, level : integer;
                                    var engineColor, handicap : integer);
var
  key, s : string;
begin
  key := MatchKey(boardsize, level);

  s := iniFile.ReadString('Engine', key, '');
  if s = ''
    then
      begin
        engineColor := Black;
        handicap := 0
      end
    else
      begin
        engineColor := NthInt(s, 1, ',');
        handicap := NthInt(s, 2, ',')
      end
end;

procedure TEngineSettings.SaveMatch(iniFile : TMemIniFile;
                                    boardsize, level : integer;
                                    engineColor, handicap : integer;
                                    engineWin : boolean);
var
  key : string;

  procedure DoUpdateMatch(key : string; color, handi : integer);
  begin
    iniFile.WriteString('Engine', key, Format('%d,%d', [color, handi]))
  end;

begin
  key := MatchKey(boardsize, level);

  if engineWin
    then
      if engineColor = White
        then DoUpdateMatch(key, White, Min(handicap + 1, 9)) // check 5x5
        else
          if handicap = 0
            then DoUpdateMatch(key, White, 0)
            else DoUpdateMatch(key, Black, handicap - 1)
    else
      if engineColor = Black
        then DoUpdateMatch(key, Black, Min(handicap + 1, 9)) // check 5x5
        else
          if handicap = 0
            then DoUpdateMatch(key, Black, 0)
            else DoUpdateMatch(key, White, handicap - 1)

end;

// helpers

function TEngineSettings.MatchKey(boardsize, level : integer) : string;
var
  slevel : string;
begin
  if FAvailLevel
    then slevel := IntToStr(level)
    else slevel := '';

  Result := Join(',', [FName, IntToStr(boardsize), slevel])
end;

// -- Testing values ---------------------------------------------------------

function TEngineSettings.IsConcerned(const value : string) : boolean;
begin
  Result := (value <> 'not.handled') and (value <> 'not.required')
end;

function TEngineSettings.IsGtpTimeCommandRequired  : boolean;
begin
  Result := (FGtpTimePerMove <> 'not.handled')
            and (FRefEngine <> 'MoGo')
            and (FRefEngine <> 'Fuego')
end;

// -- TEngineSettingList -----------------------------------------------------

destructor TEngineSettingList.Destroy;
begin
  Clear;
  inherited Destroy
end;

procedure TEngineSettingList.Clear;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    Nth(i).Free;

  inherited
end;

function TEngineSettingList.Nth(index : integer) : TEngineSettings;
begin
  Result := Objects[index] as TEngineSettings
end;

// Read the list of engine descriptions in inifile

procedure TEngineSettingList.LoadIni(iniFile : TMemIniFile;
                                     usePortablePaths : boolean;
                                     const appPath : WideString);
var
  n, i : integer;
  engineSettings : TEngineSettings;
begin
  n := iniFile.ReadInteger('Engine', 'Count', 0);

  Clear;
  for i := 1 to n do
    begin
      engineSettings := TEngineSettings.Create;
      engineSettings.LoadIni(iniFile, i, usePortablePaths, appPath);
      AddObject(engineSettings.FName, engineSettings)
    end
end;

procedure TEngineSettingList.SaveIni(iniFile : TMemIniFile;
                                     usePortablePaths : boolean;
                                     const appPath : WideString);
var
  n, i : integer;
begin
  // clean up
  n := iniFile.ReadInteger('Engine', 'Count', 0);
  for i := 1 to n do
    iniFile.DeleteKey('Engine', IntToStr(i));
  iniFile.DeleteKey('Engine', 'PlayingEngine');
  iniFile.DeleteKey('Engine', 'AnalysisEngine');

  // save
  iniFile.WriteInteger('Engine', 'Count', Count);
  for i := 0 to Count - 1 do
    Nth(i).SaveIni(iniFile, i + 1, usePortablePaths, appPath)
end;

function TEngineSettingList.IndexOfPlayingEngine(iniFile : TMemIniFile) : integer;
begin
  Result := IndexOfUserEngine(iniFile, 'PlayingEngine')
end;

procedure TEngineSettingList.ToggleGameUsage(index : integer);
var
  newUsage : boolean;
  i : integer;
begin
  // set new usage
  newUsage := not Nth(index).FUsedForGame;
  Nth(index).FUsedForGame := newUsage;

  // reset all other engines if current engine will be used
  if newUsage then
    for i := 0 to Count - 1 do
      if i <> index
        then Nth(i).FUsedForGame := False
end;

procedure TEngineSettingList.ToggleAnalysisUsage(index : integer);
var
  newUsage : boolean;
  i : integer;
begin
  // set new usage
  newUsage := not Nth(index).FUsedForAnalysis;
  Nth(index).FUsedForAnalysis := newUsage;

  // reset all other engines if current engine will be used
  if newUsage then
    for i := 0 to Count - 1 do
      if i <> index
        then Nth(i).FUsedForAnalysis := False
end;

end.
