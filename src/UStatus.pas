// ---------------------------------------------------------------------------
// -- Drago -- Status and settings ---------------------------- UStatus.pas --
// ---------------------------------------------------------------------------

unit UStatus;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils,
  Classes, ClassesEx,
  TntIniFiles,
  Define, DefineUi, UDragoIniFiles,
  {$ifndef FPC}UBackground{$else}UBackground_FPC{$endif},
  EngineSettings,
  UMRUList,
  CodePages;

// -- Global status and settings ---------------------------------------------

type
  TStatus = class

    // -- Status of application ----------------------------------------------

    AppPath             : WideString; // application path
    RunFromIDE          : boolean;    // is app running from IDE ?
    TmpPath             : string;     // temp file directory
    NewInFile           : boolean;    // new in current file
    LastTab             : integer;    // last option tab visited
    LastEditTab         : integer;    // last created tab (GobanNN)
    LastGotoGame        : integer;    // last input for goto game command
    LastGotoMove        : integer;    // last input for goto move command
    LastMarkup          : integer;    // last selected markup
    LastNewMode         : integer;    // 0: new file, 1: current file
    Debug               : boolean;    // debugging flag
    EnableGobanMouseDn  : boolean;    // protect against goban click while loading
    ErrMsgLogged        : boolean;    // are open error messages logged?
    ErrMsgLog           : TWideStringList; // list of open file errors when logged

    // -- Undocumented settings ----------------------------------------------

    WheelGoban          : boolean;    // mouse wheel always for go board
    KeybComment         : boolean;    // keyboard always for text boxes
    RepeatMove          : boolean;    // allow move repetition with button, obsolete
    RepeatTempo         : integer;    // repeat tempo, obsolete

    // -- Other settings -----------------------------------------------------

    AppFontName         : string;
    AppFontSize         : integer;
    Language            : string;     // language code from filename (Drago-Xy.lng)
    CreateEncoding      : TCodePage;  // encoding for new files
    DefaultEncoding     : TCodePage;  // default encoding for existing files

    // -- File settings ------------------------------------------------------

    MRUList             : TMRUList;
    UsePortablePaths    : boolean;
    OpenLast            : boolean;    // start with last files
    OpenNode            : boolean;    // start with last node
    LongPNames          : boolean;    // accept long property names
    DefaultProp         : boolean;    // create game with complete root properties
    PlayerProp          : boolean;    // change player with Pl property insertion
    SaveCompact         : boolean;    // compact lists of moves
    CompressList        : boolean;    // compress lists of intersections
    AbortOnReadError    : boolean;    // abort loading file on file error
    ShowPlacesBar       : boolean;    // open save dialogs with places bar
    OpenFileDef         : TOpenMode;  // default opening mode for files
    OpenFoldDef         : TOpenMode;  // default opening mode for folder
    EmptyLBAsL          : boolean;    // treat LB properties with no text as L properties
    FactorizeFolder     : WideString; // starting folder for file selection
    FactorizeDepth      : integer;    // depth of factorization
    FactorizeNbUnique   : integer;    // number of unique moves for each game in factorization
    FactorizeNormPos    : boolean;    // normalize position of first move
    FactorizeWithTewari : boolean;    // detect move inversions during factorization
    FactorizeReference  : integer;    // 0: none, 1: filename, 2: signature

    // -- Warnings -----------------------------------------------------------

    WarnFullScreen      : boolean;    // warn when toggling to full screen
    WarnDelBrch         : boolean;    // warn when deleting a whole branch
    WarnAtModif         : boolean;    // warn at first file modification
    WarnAtModifDB       : boolean;    // warn at first file modification in DB
    WarnAtReadOnly      : boolean;    // warn on modification in read only mode
    WarnInvMove         : boolean;    // warn on invalid move
    WarnOnResign        : boolean;    // warn when game engine resigns
    WarnOnPass          : boolean;    // warn when game engines passes
    WarnLoseOnTime      : boolean;    // warn when one player loses on time

    // -- Settings for board -------------------------------------------------

    StoneStyle          : integer;    // board graphic settings
    CustomBlackPath     : WideString;
    CustomWhitePath     : WideString;
    CustomLightSource   : TLightSource;
    BoardBack           : TBackground;
    BorderBack          : TBackground;
    CoordStyle          : integer;
    ShowMoveMode        : TShowMoveMode;
    NumberOfVisibleMoveNumbers : integer;
    NumOfMoveDigits     : integer;
    ZoomOnCorner        : boolean;
    ThickEdge           : boolean;
    ShowHoshis          : boolean;
    EnableAsBooks       : boolean;
    EnableAsBooksTmp    : boolean;    // used only in option dialog
    StartVarFromOne     : boolean;
    StartVarWithFig     : boolean;
    StartVarAndMain     : boolean;
    NumberVarFromRoot   : boolean;
    BoldTextOnBoard     : boolean;
    MaxBoardFontSize    : integer;    // max font size for board
    SymmetricTiling     : boolean;    // also used for other textures

    // -- Settings for index -------------------------------------------------

    ModePosIndex        : integer;
    NbMovesIndex        : integer;
    fmIndexTop          : integer;
    fmIndexLeft         : integer;
    GIdxRadius          : integer;    // stone radius in graphic index
    InfoCol             : string;     // description of info preview: num(;pn;w)*
    WarnWhenSort        : boolean;
    SortLimit           : integer;    // max number of records to be sorted

    // -- Settings for new game ----------------------------------------------

    BoardSize           : integer;
    Handicap            : integer;
    Komi                : real;
    KomiForEngine       : real;

    // -- Settings for navigation --------------------------------------------

    MoveTargets         : TMoveTargets;
    TargetStep          : integer;
    AutoDelay           : integer;    // time between 2 moves in ms
    AutoUseTimeProp     : boolean;    // use timing properties when available
    AutoStopAtTarget    : boolean;    // stop at move targets in autoreplay

    // -- Settings for edition -----------------------------------------------

    ExtendSetup         : boolean;    // extend stone setup sequence: set, swap, del

    // -- Settings for game tree ---------------------------------------------

    TreeBack            : TBackground;
    TvStoneStyle        : integer;
    TvInterH            : integer;
    TvInterV            : integer;
    TvRadius            : integer;
    TvMoveNumber        : TTvMoves;

    // -- Settings for moves -------------------------------------------------

    VarStyleDef         : TVarStyle;  // Default
    VarMarkupDef        : TVarMarkup; //   "
    VarStyleGame        : TVarStyle;  // ST property
    VarMarkupGame       : TVarMarkup; //   "

    // -- Settings for view --------------------------------------------------

    HookContent         : boolean;    // true if view updates follow resizing
    vwMoveInfo          : TViewPane;
    vwGameInfo          : TViewPane;
    vwNodeName          : TViewPane;
    vwComments          : TViewPane;
    vwTimeLeft          : TViewPane;
    vwTreeView          : TViewPane;
    vwVariation         : TViewPane;

    TabCloseBtn         : boolean;
    LightSource         : TLightSource;
    WinBackground       : TBackground;
    ComFontSize         : integer;
    TextPanelColor      : integer;
    GameInfoPaneFormat  : WideString;
    GameInfoPaneImgDisp : boolean;
    GameInfoPaneImgDir  : WideString;

    // -- Settings for database ----------------------------------------------

    // libkombilo settings
    DBCache             : integer;
    DBCreateExtended    : boolean;
    DBDetectDuplicates  : integer;
    DBOmitDuplicates    : boolean;
    DBOmitSGFErrors     : boolean;
    DBProcessVariations : boolean;
    DBSearchVariations  : boolean;
    DBFixedColor        : boolean;
    DBFixedPos          : boolean;
    DBNextMove          : integer;
    DBMoveLimit         : integer;

    // Drago settings
    DBOpenFolder        : WideString; // last folder where DB opened
    DBAddFolder         : WideString; // last folder for source files
    DBSearchView        : TDBSearchView;
    DBPatSplitter       : integer;
    DBResetSearch       : boolean;
    DBIgnoreHits        : boolean;
    DBMovesFromHit      : integer;
    DBSearchMode        : TSearchMode;

    // -- Sound options ------------------------------------------------------

    EnableSounds        : boolean;
    SoundStone          : WideString;
    SoundInvMove        : WideString;
    SoundEngineMove     : WideString;

    // -- Settings for replay mode -------------------------------------------

    GmMode              : integer;    // default selection mode
                                      // 0: loaded game, 1: sequential, 2: random
    GmPlayer            : integer;    // default player for engine
    GmPlay              : integer;    // default play mode
                                      // 0: full game, 1: fuseki, 2: fromCurrent
    GmNbFuseki          : integer;    // default moves in fuseki
    GmNbAttempts        : integer;    // nb attempts per move; 1: only one, MaxInt: unlimited

    // -- Settings for joseki mode -------------------------------------------

    joDataBase          : string;
    joLastNode          : string;
    joPlayer            : integer;    // player
    joNumber            : integer;    // number of joseki to play
    joPath              : string;     // path of starting position
    fuDatabase          : string;

    // -- Settings for problem mode ------------------------------------------

    PbMode              : integer;    // default selection mode
                                      // 0: seq current, 1: seq memo, 2: random
    PbMarkup            : integer;    // default markup of solutions
                                      // 0: uli, 1: gopb
    PbNumber            : integer;    // default number of problems
    PbRndPos            : boolean;    // default random position
    PbRndCol            : boolean;    // default random color
    PbUseFailureRatio   : boolean;    // use failure ratio
    PbFailureRatio      : integer;
    PbShowGlyphs        : boolean;    //
    PbShowTimer         : boolean;    //
    PbPlayBothColors    : boolean;

    // -- Game engine settings (PLay) ----------------------------------------

    // current engine description
    PlayingEngine       : TEngineSettings;
    AnalysisEngine      : TEngineSettings;

    // settings
    PlPlayer            : integer;    // color played by engine
    PlTimingMode        : TTimingMode;//
    PlTotalTime         : integer;    //
    PlTimePerMove       : integer;    //
    PlMainTime          : integer;    //
    PlOverTime          : integer;    //
    PlOverStones        : integer;    //
    PlStartPos          : integer;    // spNew, spCurrent, spMatch
    PlAskForSave        : boolean;    // ask for saving after game
    PlUseSameTab        : boolean;    // play games in same tab
    PlUndo              : TEngineUndo;// how is Undo allowed?
    PlFree              : boolean;    // free handicap placement
    PlScoring           : TScoring;   // scoring mode
    PlTimeOutDelay      : integer;    // tolerance for loosing on time
    EngineOnlyTiming    : boolean;    // free timing for user
    // status
    PlGame              : boolean;    // new file in Play mode

    // -- Printing settings --------------------------------------------------

    PrGames             : TPrGames;
    PrFrom              : integer;
    PrTo                : integer;
    PrFigures           : TFigures;
    PrInclStartPos      : boolean;
    PrPos               : integer;
    PrStep              : integer;
    PrLayout            : TLayout;
    PrFigPerLine        : integer;
    PrFigRatio          : integer;
    PrFirstFigAlone     : boolean;
    PrFirstFigRatio     : integer;
    PrInclInfos         : TPrInfos;
    PrInfosTopFmt       : string;
    PrInfosNameFmt      : string;
    PrInclComm          : boolean;
    PrRemindTitle       : boolean;
    PrRemindMoves       : boolean;
    PrInclVar           : boolean;
    PrInclTitle         : boolean;
    PrRelNum            : boolean;
    PrFmtMainTitle      : string;
    PrFmtVarTitle       : string;
    PrPrintHeader       : boolean;
    PrPrintFooter       : boolean;
    PrHeaderFormat      : string;
    PrFooterFormat      : string;
    PrPaperSize         : string;
    PrLandscape         : boolean;
    PrMargins           : string;
    PrFontName          : string;
    PrFontSize          : integer;
    PrStyles            : TStringList;
    PrExportGame        : TExportGame;
    PrExportFigure      : TExportFigure;
    PrExportPos         : TExportFigure;
    PrNumAsBooks        : boolean;
    PrExportPosDiam     : integer;
    PrDPI               : integer;
    PrCompressPDF       : boolean;
    PrQualityJPEG       : integer;
    // export to ASCII settings
    AscDrawEdge         : boolean;
    AscBlackChar        : char;
    AscWhiteChar        : char;
    AscHoshi            : char;
    // export to PDF settings
    PdfUseBoardColor    : boolean;
    PdfRadiusAdjust     : double;     // from 0 (default) to 1 (stones are touching)
    PdfFontSizeAdjust   : string;     // 'factor;factor for 1 char string'
                                      // actual size = factor * default size
    PdfCircleWidth      : double;
    PdfLineWidth        : double;
    PdfDblLineWidth     : double;
    PdfHoshiStoneRatio  : double;     // = hoshi / stone
    PdfExactWidthMm     : integer;    // exact width in millimeters
    PdfBoldTextOnBoard  : boolean;
    PdfAddedBorder      : string;     // 'N;W;S;E' % of board image size
    PdfMarksAdjust      : string;     // 'width;factor'
    PdfLineHeightAdjust : double;
    PdfTrueTypeFont     : string;
    PdfEmbedTTF         : boolean;
    // working data for printing
    AccumComment        : TStringList;  // list of accumulated comments
    IgnoreFG            : boolean;
    Exporting           : boolean;    // exporting flag

    // --

    class function NewInstance : TObject; override;
    //constructor Create;
    destructor  Destroy; override;
    procedure   DoWhenCreating;
    procedure   DoWhenDestroying;
    procedure   Default;

    procedure LoadIniFile(iniFile : TDragoIniFile);
    procedure SaveIniFile(iniFile : TDragoIniFile);
    procedure UpdateIniFile(iniFile : TTntMemIniFile);
    procedure Default_Database;

    function  VarStyle  : TVarStyle;
    procedure SetVariationFromST(pv : string);
  private
    procedure LoadGobanIniFile(iniFile : TDragoIniFile);
    procedure SaveGobanIniFile(iniFile : TDragoIniFile);
    procedure LoadTreeIniFile(iniFile : TDragoIniFile);
    procedure SaveTreeIniFile(iniFile : TDragoIniFile);
    procedure LoadIniFile_Database(iniFile : TDragoIniFile);
    procedure SaveIniFile_Database(iniFile : TDragoIniFile);
  end;

// -- Default values for settings --------------------------------------------

const
  // Files
  __UsePortablePaths    = False;

  // Board
  __StoneStyle          = dsDefault;
  __CustomLightSource   = lsNone;
  __CoordStyle          = tcKorsch;
  __BoldTextOnBoard     = True;
  __MaxBoardFontSize    = 13;
  __NumOfMoveDigits     = 3;
  __ThickEdge           = True;
  __ShowHoshis          = True;
  __ZoomOnCorner        = False;
  __ShowMoveMode        = smNumber;
  __NumberOfVisibleMoveNumbers = 3;
  __EnableAsBooks       = False;
  __StartVarFromOne     = False;
  __StartVarWithFig     = False;
  __StartVarAndMain     = False;
  __NumberVarFromRoot   = False;
  __SymmetricTiling     = False;

  // User interface
  __HookContent         = False;
  __AnchorPanels        = True;
  __GameInfoPaneFormat  = '\PB \BR (B)\n\PW \WR (W)\n\PC, \DT\n\RE';
  __GameInfoPaneImgDisp = True;

  // Sound options
  __EnableSounds        = False;
  __SoundStone          = 'Default';
  __SoundInvMove        = 'Default';
  __SoundEngineMove     = 'Default';

  // Files
  __AbortOnReadError    = False;
  __ShowPlacesBar       = True;
  __EmptyLBAsL          = True;
  __FactorizeFolder     = '';
  __FactorizeDepth      = 20;
  __FactorizeNbUnique   = 0;
  __FactorizeNormPos    = True;
  __FactorizeWithTewari = False;
  __FactorizeReference  = 0;

  // Databases
  __DBNextMove          = Both;
  __DBFixedColor        = False;
  __DBFixedPos          = False;
  __DBMoveLimit         = 1000;
  __DBSearchView        = svDigest;

  // Warnings
  __WarnFullScreen      = True;
  __WarnDelBrch         = True;
  __WarnAtModif         = True;
  __WarnAtModifDB       = True;
  __WarnAtReadOnly      = True;
  __WarnInvMove         = True;
  __WarnOnPass          = True;
  __WarnOnResign        = True;
  __WarnLoseOnTime      = True;

  // Navigation
  __TargetStep          = 50;

  // Edition
  __ExtendSetup         = False;

  // Language
  __Language            = 'En';
  __CreateEncoding      = utf8;

  // PDF
  __PdfUseOldLib        = False;
  __PdfExactWidthMm     = 0;
  __PdfAddedBorder      = '0;0;0;0';
  __PdfUseBoardColor    = False;
  __PdfLineWidth        = 0.5;
  __PdfDblLineWidth     = 1.0;
  __PdfHoshiStoneRatio  = 0.05;
  __PdfRadiusAdjust     = 1.0;
  __PdfCircleWidth      = 0.5;
  __PdfMarksAdjust      = '0.5;1';
  __PdfFontSizeAdjust   = '1.0';
  __PdfBoldTextOnBoard  = False;
  __PdfLineHeightAdjust = 1.0;
  __PdfTrueTypeFont     = '';
  __PdfEmbedTTF         = False;

  // Playing
  __PlEnableUndo        = euNo;
  __PlTimingMode        = False;
  __PlTotalTime         = 3600;
  __PlTimePerMove       = 60;
  __PlMainTime          = 60;
  __PlOverTime          = 300;
  __PlOverStones        = 25;
  __PlTimeOutDelay      = 1000;
  __EngineOnlyTiming    = False;

  // Replay
  __GmNbAttempts        = 1;

  // Problems
  __PbFailureRatio      = 50;
  __PbUseFailureRatio   = False;
  __PbShowGlyphs        = False;
  __PbShowTimer         = False;
  __PbPlayBothColors    = False;

// ---------------------------------------------------------------------------

procedure CreateIniFile(IniFile : TDragoIniFile);
function Status : TStatus;
function Settings : TStatus;
function AppRelativePath(const path : WideString) : WideString;
function AppAbsolutePath(const path : WideString) : WideString;

function SettingsDirectory : WideString;
function DragoIniFileName : WideString;

// ---------------------------------------------------------------------------

implementation

uses
  {$ifndef FPC}
  WinUtils,
  TntForms,
  {$endif}
  TntSysUtils, TntSystem,
  Std, SysUtilsEx, UPrintStyles;

// ---------------------------------------------------------------------------
// defined in module initialization

var
  startingDir : WideString;

// Names
// TODO: check versus functions in UDragoIniFiles

function UserDir : WideString;
begin
  Result := GetLocalAppDataW + '\Drago'
end;

function SettingsDirectory : WideString;
// In case of portable install: return the calling directory by detecting the
// file DragoPortable.ini (which is added by the install)
// In case of standard install: return the path LOCALAPPDATA\Drago making sure
// it exists.
var
  userDir, exeDir : WideString;
begin
  userDir := GetLocalAppDataW + '\Drago';
  exeDir := WideExtractFilePath(WideParamStr(0));
  if WideFileExists(exeDir + '\DragoPortable.ini')
    then Result := exeDir
    else                                            
      begin
          WideForceDirectories(userDir);
          Result := userDir
      end
end;

function DragoIniFileName : WideString;
begin
  Result := SettingsDirectory + '\Drago.ini'
end;

function IniFullName(const basename : string) : WideString;
begin
  Result := UserDir + '\' + basename
end;

// == Implementation of application status ===================================
//
// -- Status is a singleton. First TStatus.Create creates the only instance,
// -- other calls to TStatus.Create will launch an exception.
//
// -- Created and freed in initialization and finalization sections.
// -- Tip from http://dn.codegear.com/article/22576

var
  TheSingleton : TObject = nil;

class function TStatus.NewInstance: TObject;
begin
  if Assigned(TheSingleton)
    then raise Exception.Create('Trying to create again a singleton...')
    else
      begin
        TheSingleton := inherited NewInstance;
        Result := TheSingleton;

        (TheSingleton as TStatus).DoWhenCreating;
      end
end;

// -- Access, destruction ----------------------------------------------------

//TODO: use Settings. when relevant

// should be used for data not accessible to user
function Status : TStatus;
begin
  Result := TheSingleton as TStatus
end;

// should be used for data accessible to user (saved in ini file)
function Settings : TStatus;
begin
  Result := TheSingleton as TStatus
end;

destructor TStatus.Destroy;
begin
  DoWhenDestroying
end;

// -- Construction and destruction of status data ----------------------------

procedure TStatus.DoWhenCreating;
begin
  AccumComment   := TStringList.Create;
  prStyles       := TStringList.Create;
  MRUList        := TMRUList.Create;
  BoardBack      := TBackground.Create(nil);
  WinBackground  := TBackground.Create(BoardBack);
  BorderBack     := TBackground.Create(BoardBack);
  TreeBack       := TBackground.Create(BoardBack);
  ErrMsgLog      := TWideStringList.Create;
  PlayingEngine  := TEngineSettings.Create;
  AnalysisEngine := TEngineSettings.Create
end;

procedure TStatus.DoWhenDestroying;
begin
  AccumComment.Free;
  prStyles.Free;
  MRUList.Free;
  WinBackground.Free;
  BoardBack.Free;
  BorderBack.Free;
  TreeBack.Free;
  //PanelStones.Free;
  ErrMsgLog.Free;
  PlayingEngine.Free;
  AnalysisEngine.Free
end;

// -- Status initialisation --------------------------------------------------
//
// -- Must be done for every field not read in inifile

procedure TStatus.Default;
begin
  AppPath      := startingDir + '\';
  RunFromIDE   := {$ifdef FPC} False {$else} DebugHook <> 0 {$endif};
  TmpPath      := {$ifdef FPC} AppPath {$else} MkTempDir(AppName) {$endif};
  LastEditTab  := 0;
  LastTab      := 0;
  TabCloseBtn  := True;
  LastGotoGame := 1;
  LastGotoMove := 1;
  LastNewMode  := 0;
  AppFontName  := 'Tahoma';
  AppFontSize  := 8;
  Language     := 'En';
  BoardSize    := 19;
  Handicap     := 0;
  Komi         := 0;
  NewInFile    := False;
  DefaultProp  := True;
  PlayerProp   := False;
  Debug        := False;
  EnableGobanMouseDn := True;
  OpenFileDef  := omEdit;
  OpenFoldDef  := omEdit;
  ErrMsgLogged := False;

  CoordStyle        := 1;
  EnableAsBooks     := True;
  StartVarFromOne   := False;
  StartVarWithFig   := False;
  StartVarAndMain   := False;
  OpenLast          := True;
  saveCompact       := False;
  ModePosIndex      := piInitial;
  NbMovesIndex      := 20;
  CustomBlackPath   := AppPath + 'Stones\SenteGoban\BlackStone7.png';
  CustomWhitePath   := AppPath + 'Stones\SenteGoban\WhiteStone7-0.png';

  BoardBack.Image     := AppPath + 'Textures\wood01.jpg';
  WinBackground.Image := BoardBack.Image;
  BorderBack.Image    := BoardBack.Image;
  TreeBack.Image      := BoardBack.Image;

  ZoomOnCorner := False;
  gmMode       := 0;
  gmPlayer     := Black;
  gmPlay       := 0;
  gmNbFuseki   := 30;

  DBCache      := 0;
  DBOpenFolder := AppPath;
  DBAddFolder  := AppPath;
  DBfixedColor := False;
  DBnextMove   := Both;
  DBmoveLimit  := 1000;
  DBResetSearch:= True;

  joDataBase   := '';
  joPlayer     := Black;
  joNumber     := 10;

  PbMarkup     := 3; // autodetect
  PbMode       := 2; // random
  PbNumber     := 10;
  PbRndPos     := False;
  PbRndCol     := False;

  PlPlayer     := Black;
  PlStartPos   := 0; // new game
  PlGame       := False;
  PlScoring    := scJapanese;
  PlUseSameTab := True;
  EngineOnlyTiming := __EngineOnlyTiming;

  Exporting    := False;
  IgnoreFG     := True;
end;

// -- Handling of variation display modes (ST property) ----------------------

function TStatus.VarStyle : TVarStyle;
begin
  if VarStyleGame = vsUndef
    then Result := VarStyleDef
    else Result := VarStyleGame
end;

procedure TStatus.SetVariationFromST(pv : string);
var
  n : integer;
begin
  // Anticipate
  VarStyleGame  := vsUndef;
  VarMarkupGame := vmUndef;

  // no ST property
  if pv = ''
    then exit;

  // clean ST property
  pv := Trim(Copy(pv, 2, Length(pv) - 2));  // del brackets and spaces

  if not TryStrToInt(pv, n) or not Within(n, 0, 3)
    then exit;                                          // should warn

  if n mod 2 = 0
    then VarStyleGame := vsChildren
    else VarStyleGame := vsSibling;

  if n div 2 = 0
    then
      if VarMarkupDef in [vmGhost, vmUpCase, vmDnCase]
        then VarMarkupGame := VarMarkupDef
        else VarMarkupGame := vmGhost      // as we have to choose one
    else VarMarkupGame := vmNone
end;

// -- Creation (when installing) of Ini file ---------------------------------

procedure CreateIniFile(IniFile : TDragoIniFile);
begin
  with IniFile do
    begin
      // create sections to get them in order
      WriteString('Drago'   , 'Version', AppVersion);
      WriteString('Windows' , 'Tmp', '');
      DeleteKey  ('Windows' , 'Tmp');
      WriteString('View'    , 'Tmp', '');
      DeleteKey  ('View'    , 'Tmp');
      WriteString('Goban'   , 'Tmp', '');
      DeleteKey  ('Goban'   , 'Tmp');
      WriteString('Options' , 'Tmp', '');
      DeleteKey  ('Options' , 'Tmp');
      WriteString('Files'   , 'Tmp', '');
      DeleteKey  ('Files'   , 'Tmp');
      WriteString('New'     , 'Tmp', '');
      DeleteKey  ('New'     , 'Tmp');
      WriteString('Index'   , 'Tmp', '');
      DeleteKey  ('Index'   , 'Tmp');
      WriteString('Games'   , 'Tmp', '');
      DeleteKey  ('Games'   , 'Tmp');
      WriteString('Problems', 'Tmp', '');
      DeleteKey  ('Problems', 'Tmp');
      WriteString('Engine'  , 'Tmp', '');
      DeleteKey  ('Engine'  , 'Tmp');
      WriteString('Print'   , 'Tmp', '');
      DeleteKey  ('Print'   , 'Tmp');
      // store printing styles
      CreatePrintIniFile(IniFile);
    end
end;

// -- Saving and loading of go board settings --------------------------------

procedure TStatus.LoadGobanIniFile(iniFile : TDragoIniFile);
var
  n : integer;
begin
  BoardBack.LoadIni (iniFile, 'Goban', 'Board');
  BorderBack.LoadIni(iniFile, 'Goban', 'Border');

  with iniFile do
    begin
      StoneStyle       := ReadInteger('Goban', 'StoneStyle'       , __StoneStyle);
      CustomBlackPath  := ReadWideStr('Board', 'CustomBlackPath'  , CustomBlackPath);
      CustomWhitePath  := ReadWideStr('Board', 'CustomWhitePath'  , CustomWhitePath);
      n                := ReadInteger('Board', 'CustomLightSource', ord(__CustomLightSource));
      CustomLightSource:= TLightSource(n);
      CoordStyle       := ReadInteger('Goban', 'CoordStyle'       , __CoordStyle);
      NumOfMoveDigits  := ReadInteger('Board', 'NumOfMoveDigits'  , __NumOfMoveDigits);
      n                := ReadInteger('Board', 'ShowMoveMode'     , ord(__ShowMoveMode));
      ShowMoveMode     := TShowMoveMode(n);
      NumberOfVisibleMoveNumbers := ReadInteger('Board', 'NumberOfVisibleMoveNumbers', ord(__NumberOfVisibleMoveNumbers));
      ZoomOnCorner     := ReadBool   ('Goban', 'ZoomOnCorner'     , __ZoomOnCorner);
      ThickEdge        := ReadBool   ('Goban', 'ThickEdge'        , __ThickEdge);
      ShowHoshis       := ReadBool   ('Goban', 'ShowHoshis'       , __ShowHoshis);
      EnableAsBooks    := ReadBool   ('Board', 'EnableAsBooks'    , __EnableAsBooks);
      StartVarFromOne  := ReadBool   ('Board', 'StartVarFromOne'  , __StartVarFromOne);
      StartVarWithFig  := ReadBool   ('Board', 'StartVarWithFig'  , __StartVarWithFig);
      StartVarAndMain  := ReadBool   ('Board', 'StartVarAndMain'  , __StartVarAndMain);
      NumberVarFromRoot:= ReadBool   ('Board', 'NumberVarFromRoot', __NumberVarFromRoot);
      BoldTextOnBoard  := ReadBool   ('Board', 'BoldTextOnBoard'  , __BoldTextOnBoard);
      MaxBoardFontSize := ReadInteger('Board', 'MaxBoardFontSize' , __MaxBoardFontSize);
      SymmetricTiling  := ReadBool   ('Board', 'SymmetricTiling'  , __SymmetricTiling);
    end
end;

procedure TStatus.SaveGobanIniFile(iniFile : TDragoIniFile);
begin
  BoardBack.SaveIni (iniFile, 'Goban', 'Board');
  BorderBack.SaveIni(iniFile, 'Goban', 'Border');

  with iniFile do
    begin
      WriteInteger('Goban', 'StoneStyle'       , StoneStyle);
      WriteWideStr('Board', 'CustomBlackPath'  , CustomBlackPath);
      WriteWideStr('Board', 'CustomWhitePath'  , CustomWhitePath);
      WriteInteger('Board', 'CustomLightSource', ord(CustomLightSource));
      WriteInteger('Goban', 'CoordStyle'       , CoordStyle);
      WriteInteger('Board', 'NumOfMoveDigits'  , NumOfMoveDigits);
      WriteInteger('Board', 'ShowMoveMode'     , ord(ShowMoveMode));
      WriteInteger('Board', 'NumberOfVisibleMoveNumbers', ord(NumberOfVisibleMoveNumbers));
      WriteBool   ('Goban', 'ZoomOnCorner'     , ZoomOnCorner);
      WriteBool   ('Goban', 'ThickEdge'        , ThickEdge);
      WriteBool   ('Goban', 'ShowHoshis'       , ShowHoshis);
      WriteBool   ('Board', 'EnableAsBooks'    , EnableAsBooks);
      WriteBool   ('Board', 'StartVarFromOne'  , StartVarFromOne);
      WriteBool   ('Board', 'StartVarWithFig'  , StartVarWithFig);
      WriteBool   ('Board', 'StartVarAndMain'  , StartVarAndMain);
      WriteBool   ('Board', 'NumberVarFromRoot', NumberVarFromRoot);
      WriteBool   ('Board', 'BoldTextOnBoard'  , BoldTextOnBoard);
      WriteInteger('Board', 'MaxBoardFontSize' , MaxBoardFontSize);
      WriteBool   ('Board', 'SymmetricTiling'  , SymmetricTiling);
     end
end;

// -- Saving and loading of game tree settings -------------------------------

procedure TStatus.LoadTreeIniFile(iniFile : TDragoIniFile);
const
  section = 'Tree';
begin
  TreeBack.LoadIni(iniFile, section, '', bsColor);

  with iniFile do
    begin
      TvStoneStyle := ReadInteger(section, 'StoneStyle'  , dsDefault);
      TvRadius     := ReadInteger(section, 'Radius'      , 8);
      TvInterH     := 3 * TvRadius;
      TvInterV     := 3 * TvRadius;
      TvMoveNumber := TTvMoves(ReadInteger(section, 'MoveNumbers' , 1));
    end
end;

procedure TStatus.SaveTreeIniFile(iniFile : TDragoIniFile);
const
  section = 'Tree';
begin
  TreeBack.SaveIni(iniFile, section, '');

  with iniFile do
    begin
      WriteInteger(section, 'StoneStyle'  , TvStoneStyle);
      WriteInteger(section, 'Radius'      , TvRadius);
      WriteInteger(section, 'MoveNumbers' , ord(TvMoveNumber));
     end
end;

// -- Saving and loading of database settings --------------------------------

procedure TStatus.Default_Database;
begin
  DBCache             := 100;
  DBCreateExtended    := False;
  DBMoveLimit         := 1000;
  DBDetectDuplicates  := 2;
  DBOmitDuplicates    := True;
  DBOmitSGFErrors     := False;
  DBProcessVariations := True;
  DBSearchVariations  := True
end;

procedure TStatus.LoadIniFile_Database(iniFile : TDragoIniFile);
const
  section = 'Database';
var
  n : integer;
begin
  with iniFile do
    begin
      // libkombilo
      DBCache             := ReadInteger(section, 'Cache'       , 100);
      DBCreateExtended    := ReadBool   (section, 'CreateExtended'   , False);
      DBDetectDuplicates  := ReadInteger(section, 'DetectDuplicates' , 2);
      DBOmitDuplicates    := ReadBool   (section, 'OmitDuplicates'   , True);
      DBOmitSGFErrors     := ReadBool   (section, 'OmitSGFErrors'    , False);
      DBProcessVariations := ReadBool   (section, 'ProcessVariations', True);
      DBSearchVariations  := ReadBool   (section, 'SearchVariations' , True);
      DBNextMove          := ReadInteger(section, 'NextMove'    , __DBNextMove);
      DBFixedColor        := ReadBool   (section, 'FixedColor'  , __DBFixedColor);
      DBFixedPos          := ReadBool   (section, 'FixedPos'    , __DBFixedPos);
      DBMoveLimit         := ReadInteger(section, 'MoveLimit'   , __DBMoveLimit);
      // drago
      DBOpenFolder        := ReadWideStr(section, 'OpenFolder'  , AppPath);
      DBAddFolder         := ReadWideStr(section, 'AddFolder'   , AppPath);
      n                   := ReadInteger(section, 'SearchView'  , integer(__DBSearchView));
      DBSearchView        := TDBSearchView(n);
      DBPatSplitter       := ReadInteger(section, 'PatSplitter' , -1);
      n                   := ReadInteger(section, 'SearchMode'  , integer(smPattern));
      DBSearchMode        := TSearchMode(n)
    end
end;

procedure TStatus.SaveIniFile_Database(iniFile : TDragoIniFile);
const
  section = 'Database';
begin
  with iniFile do
    begin
      // libkombilo
      WriteInteger(section, 'Cache'            , DBCache);
      WriteBool   (section, 'CreateExtended'   , DBCreateExtended);
      WriteInteger(section, 'DetectDuplicates' , DBDetectDuplicates);
      WriteBool   (section, 'OmitDuplicates'   , DBOmitDuplicates);
      WriteBool   (section, 'OmitSGFErrors'    , DBOmitSGFErrors);
      WriteBool   (section, 'ProcessVariations', DBProcessVariations);
      WriteBool   (section, 'SearchVariations' , DBSearchVariations);
      WriteInteger(section, 'NextMove'         , DBNextMove);
      WriteBool   (section, 'FixedColor'       , DBFixedColor);
      WriteBool   (section, 'FixedPos'         , DBFixedPos);
      WriteInteger(section, 'MoveLimit'        , DBMoveLimit);
      // drago
      WriteWideStr(section, 'OpenFolder'       , DBOpenFolder);
      WriteWideStr(section, 'AddFolder'        , DBAddFolder);
      WriteInteger(section, 'SearchView'       , integer(DBSearchView));
      WriteInteger(section, 'PatSplitter'      , DBPatSplitter);
      WriteInteger(section, 'SearchMode'       , integer(DBSearchMode))
    end
end;

// -- Utilities for loading and saving move targets --------------------------

function MoveTargetsToInt(s : TMoveTargets) : integer;
var
  i : TMoveTarget;
begin
  Result := 0;
  for i := Low(TMoveTarget) to High(TMoveTarget) do
    if i in s
      then inc(Result, 1 shl integer(i))
end;

function IntToMoveTargets(n : integer) : TMoveTargets;
var
  i : TMoveTarget;
begin
  Result := [];
  for i := Low(TMoveTarget) to High(TMoveTarget) do
    if  n and (1 shl integer(i)) <> 0
      then Include(Result, i)
end;

// -- Loading and saving of ini file -----------------------------------------

procedure TStatus.LoadIniFile(iniFile : TDragoIniFile);
var
  s : string;
  n : integer;
begin
  // set separator (for batch execution from dpr)
  DecimalSeparator := '.';

  with iniFile do
    begin
      // -- Files ------------------------------------------------------

      MRUList.LoadFromIni(iniFile, 'MRU');

      UsePortablePaths    := ReadBool   ('Options' , 'UsePortablePaths', __UsePortablePaths);
      OpenLast            := ReadBool   ('Options' , 'OpenLast'        , True );
      OpenNode            := ReadBool   ('Options' , 'OpenNode'        , True );
      SaveCompact         := ReadBool   ('Options' , 'SaveCompact'     , True );
      DefaultProp         := ReadBool   ('Options' , 'DefaultProp'     , True );
      PlayerProp          := ReadBool   ('Options' , 'PlayerProp'      , False);
      CompressList        := ReadBool   ('Options' , 'CompressList'    , False);
      LongPNames          := ReadBool   ('Options' , 'LongPNames'      , True);
      AbortOnReadError    := ReadBool   ('Options' , 'AbortOnReadError', __AbortOnReadError);
      ShowPlacesBar       := ReadBool   ('Options' , 'ShowPlacesBar'   , __ShowPlacesBar);
      OpenFileDef         := TOpenMode(ReadInteger('Options', 'OpenFileDef', integer(omEdit)));
      OpenFoldDef         := TOpenMode(ReadInteger('Options', 'OpenFoldDef', integer(omEdit)));
      EmptyLBAsL          := ReadBool   ('Options' , 'EmptyLBAsL'      , __EmptyLBAsL);
      FactorizeFolder     := ReadWideStr('Options' , 'FactorizeFolder' , __FactorizeFolder);
      FactorizeDepth      := ReadInteger('Options' , 'FactorizeDepth'  , __FactorizeDepth);
      FactorizeNbUnique   := ReadInteger('Options' , 'FactorizeNbUnique', __FactorizeNbUnique);
      FactorizeNormPos    := ReadBool   ('Options' , 'FactorizeNormPos', __FactorizeNormPos);
      FactorizeWithTewari := ReadBool   ('Options' , 'FactorizeWithTewari', __FactorizeWithTewari);
      FactorizeReference  := ReadInteger('Options' , 'FactorizeReference', __FactorizeReference);

      // -- Settings for editing ---------------------------------------

      n             := ReadInteger('Options' , 'Markup', 6);
      LastMarkup    := n;
      ExtendSetup   := ReadBool('Edit', 'ExtendSetup', __ExtendSetup);

      // -- Settings for go board --------------------------------------

      LoadGobanIniFile(iniFile);

      // -- Settings for navigation ------------------------------------

      n               := MoveTargetsToInt([mtStartVar, mtComment]);
      n               := ReadInteger('Navigation', 'MoveTargets', n);
      MoveTargets     := IntToMoveTargets(n);
      TargetStep      := ReadInteger('Navigation', 'TargetStep', __TargetStep);
      AutoDelay       := ReadInteger('AutoReplay', 'Delay', 900);
      AutoUseTimeProp := ReadBool   ('AutoReplay', 'UseTimeProp', True);
      AutoStopAtTarget:= ReadBool   ('AutoReplay', 'StopAtTarget', False);

      // -- Settings for game tree -------------------------------------

      LoadTreeIniFile(iniFile);

      // -- Settings for move display ----------------------------------

      n            := ReadInteger('Options' , 'VarStyle'     , ord(vsChildren));
      VarStyleDef  := TVarStyle(n);
      n            := ReadInteger('Options' , 'VarMarkup'    , ord(vmNone));
      VarMarkupDef := TVarMarkup(n);

      // -- Settings for view display ----------------------------------

      TabCloseBtn  := ReadBool   ('View'    , 'TabCloseBtn'  , True);
      n            := ReadInteger('View'    , 'LightSource'  , ord(lsTopRight));
      LightSource  := TLightSource(n);
      HookContent  := ReadBool   ('View'    , 'HookContent'  , __HookContent);
      n            := ReadInteger('View'    , 'GameInfo'     , ord(vwRequired));
      vwGameInfo   := TViewPane(n);
      n            := ReadInteger('View'    , 'TimeLeft'     , ord(vwRequired));
      vwMoveInfo   := TViewPane(n);
      n            := ReadInteger('View'    , 'TimeLeft'     , ord(vwRequired));
      vwTimeLeft   := TViewPane(n);
      n            := ReadInteger('View'    , 'NodeName'     , ord(vwRequired));
      vwNodeName   := TViewPane(n);
      n            := ReadInteger('View'    , 'Variations'   , ord(vwAlways));
      vwVariation  := TViewPane(n);
      n            := ReadInteger('View'    , 'TreeView'     , ord(vwAlways));
      vwTreeView   := TViewPane(n);
      n            := ReadInteger('View'    , 'Comment'      , ord(vwAlways));
      vwComments   := TViewPane(n);

      WinBackground.LoadIni(iniFile, 'View', 'Win', bsColor);

      ComFontSize     := ReadInteger('View'     , 'ComFontSize'   , 8);
      TextPanelColor  := ReadInteger('View'     , 'TextPanelColor', $FFFFFF); // clWhite
      GameInfoPaneFormat  := UTF8Decode(ReadString('View'  , 'GameInfoPaneFormat', __GameInfoPaneFormat));
      GameInfoPaneImgDisp := ReadBool  ('View'  , 'GameInfoPaneImgDisplay', __GameInfoPaneImgDisp);

      s := ReadString('View'  , 'GameInfoPaneImgDir', '');
      if s = ''
        then GameInfoPaneImgDir := AppPath + '/Players'
        else GameInfoPaneImgDir := UTF8Decode(s);

      // -- Sound options ----------------------------------------------

      EnableSounds    := ReadBool   ('Sounds'   , 'Enable'         , __EnableSounds);
      SoundStone      := ReadString ('Sounds'   , 'Stone'          , __SoundStone);
      SoundInvMove    := ReadString ('Sounds'   , 'InvMove'        , __SoundInvMove);
      SoundEngineMove := ReadString ('Sounds'   , 'EngineMove'     , __SoundEngineMove);

      // -- Index configuration ----------------------------------------

      ModePosIndex    := ReadInteger('Index'    , 'ModePos'        ,  piFinal);
      NbMovesIndex    := ReadInteger('Index'    , 'NbMoves'        ,  20);
      GIdxRadius      := ReadInteger('Index'    , 'GraphRadius'    ,  3);
      InfoCol         := ReadString ('Preview'  , 'InfoCol'        , '');
      WarnWhenSort    := ReadBool   ('Preview'  , 'WarnWhenSort'   , True);
      SortLimit       := ReadInteger('Preview'  , 'SortLimit'      , 1000);

      // -- Settings of replay mode ------------------------------------

      GmMode          := ReadInteger('Games'   , 'Selection'       ,   2);
      GmPlayer        := ReadInteger('Games'   , 'Player'          , Black);
      GmPlay          := ReadInteger('Games'   , 'Mode'            ,   0);
      GmNbFuseki      := ReadInteger('Games'   , 'Fuseki'          ,  30);
      GmNbAttempts    := ReadInteger('Games'   , 'NbAttempts'      , __GmNbAttempts);

      // -- Settings of joseki mode ------------------------------------

      joPlayer        := ReadInteger('Joseki'  , 'Play with'       , Black);
      joNumber        := ReadInteger('Joseki'  , 'Joseki number'   ,  10);
      joDatabase      := ReadString ('Joseki'  , 'Database'        , '');
      joLastNode      := ReadString ('Files'   , 'JosekiNode'      , '');
      fuDatabase      := ReadString ('Fuseki'  , 'Database'        , '');

      // -- Settings of problem mode -----------------------------------

      PbMode              := ReadInteger('Problems', 'Selection'       ,   2);
      PbMarkup            := ReadInteger('Problems', 'Solution'        ,   3);
      PbNumber            := ReadInteger('Problems', 'Number'          ,  10);
      PbRndPos            := ReadBool   ('Problems', 'RandPos'         , True);
      PbRndCol            := ReadBool   ('Problems', 'RandCol'         , True);
      PbFailureRatio      := ReadInteger('Problems', 'FailureRatio'    , __PbFailureRatio);
      PbUseFailureRatio   := ReadBool   ('Problems', 'UseFailureRatio' , __PbUseFailureRatio);
      PbShowGlyphs        := ReadBool   ('Problems', 'ShowGlyphs'      , __PbShowGlyphs);
      PbShowTimer         := ReadBool   ('Problems', 'ShowTimer'       , __PbShowTimer);
      PbPlayBothColors    := ReadBool   ('Problems', 'PlayBothColors'  , __PbPlayBothColors);

      // -- Settings of engine mode (PLay) -----------------------------

      PlayingEngine.LoadPlayingEngine(iniFile, UsePortablePaths, AppPath);
      AnalysisEngine.LoadAnalysisEngine(iniFile, UsePortablePaths, AppPath);

      PlPlayer            := ReadInteger('Engine'  , 'Player'          , Black);
      n                   := Readinteger('Engine'  , 'TimingMode'      , Ord(__PlTimingMode));
      PlTimingMode        := TTimingMode(n);
      PlMainTime          := ReadInteger('Engine'  , 'MainTime'        , __PlMainTime);
      PlOverTime          := ReadInteger('Engine'  , 'OverTime'        , __PlOverTime);
      PlOverStones        := ReadInteger('Engine'  , 'OverStones'      , __PlOverStones);
      PlTotalTime         := ReadInteger('Engine'  , 'TotalTime'       , __PlTotalTime);
      PlTimePerMove       := ReadInteger('Engine'  , 'TimePerMove'     , __PlTimePerMove);
      PlAskForSave        := ReadBool   ('Engine'  , 'AskForSave'      , False);
      PlStartPos          := ReadInteger('Engine'  , 'StartPos'        ,   0);
      n                   := ReadInteger('Engine'  , 'Scoring'         ,   0);
      PlScoring           := TScoring   (n);
      n                   := ReadInteger('Engine'  , 'Undo'            , Ord(euNo));
      PlUndo              := TEngineUndo(n);
      PlFree              := ReadBool   ('Engine'  , 'Free'            , False);
      PlTimeOutDelay      := ReadInteger('Engine'  , 'TimeOutDelay'    , __PlTimeOutDelay);

      // -- Warnings ---------------------------------------------------

      WarnFullScreen      := ReadBool   ('Options' , 'WarnFullScreen'  , __WarnFullScreen);
      WarnAtModif         := ReadBool   ('Options' , 'WarnAtModif'     , __WarnAtModif  );
      WarnAtModifDB       := ReadBool   ('Options' , 'WarnAtModifDB'   , __WarnAtModifDB);
      WarnDelBrch         := ReadBool   ('Options' , 'WarnDelBrch'     , __WarnDelBrch  );
      WarnInvMove         := ReadBool   ('Options' , 'WarnInvMove'     , __WarnInvMove  );
      WarnOnPass          := ReadBool   ('Options' , 'WarnOnPass'      , __WarnOnPass   );
      WarnOnResign        := ReadBool   ('Options' , 'WarnOnResign'    , __WarnOnResign );
      WarnLoseOnTime      := ReadBool   ('Options' , 'WarnLoseOnTime'  , __WarnLoseOnTime);

      // -- Settings for database --------------------------------------

      LoadIniFile_Database(iniFile);

      // -- Misc settings ----------------------------------------------

      Language            := ReadString ('Options' , 'Language'      , __Language);
      n                   := ReadInteger('Options' , 'CreateEncoding', integer(__CreateEncoding));
      CreateEncoding      := TCodePage(n);
      n                   := ReadInteger('Options' , 'Encoding'      ,   0);
      DefaultEncoding     := TCodePage(n);
      lastTab             := ReadInteger('Options' , 'LastTab'       ,   0);
      BoardSize           := ReadInteger('New'     , 'BoardSize'     ,  19);
      Handicap            := ReadInteger('New'     , 'Handicap'      ,   0);
      s                   := ReadString ('New'     , 'Komi'          , '5.5');
      s                   := StringReplace(s, ',', '.', []);
      KomiForEngine       := StrToFloatDef(s, 5.5);

      // -- PDF options ------------------------------------------------

      PdfUseBoardColor    := ReadBool   ('PDF', 'UseBoardColor'   , __PdfUseBoardColor);
      PdfRadiusAdjust     := ReadFloat  ('PDF', 'RadiusAdjust'    , __PdfRadiusAdjust);
      PdfFontSizeAdjust   := ReadString ('PDF', 'FontSizeAdjust'  , __PdfFontSizeAdjust);
      PdfCircleWidth      := ReadFloat  ('PDF', 'CircleWidth'     , __PdfCircleWidth);
      PdfLineWidth        := ReadFloat  ('PDF', 'LineWidth'       , __PdfLineWidth);
      PdfDblLineWidth     := ReadFloat  ('PDF', 'DblLineWidth'    , __PdfDblLineWidth);
      PdfHoshiStoneRatio  := ReadFloat  ('PDF', 'HoshiStoneRatio' , __PdfHoshiStoneRatio);
      PdfExactWidthMm     := ReadInteger('PDF', 'ExactWidthMm'    , __PdfExactWidthMm);
      PdfAddedBorder      := ReadString ('PDF', 'AddedBorder'     , __PdfAddedBorder);
      PdfBoldTextOnBoard  := ReadBool   ('PDF', 'BoldTextOnBoard' , __PdfBoldTextOnBoard);
      PdfMarksAdjust      := ReadString ('PDF', 'MarksAdjust'     , __PdfMarksAdjust);
      PdfLineHeightAdjust := ReadFloat  ('PDF', 'LineHeightAdjust', __PdfLineHeightAdjust);
      PdfTrueTypeFont     := ReadString ('PDF', 'TrueTypeFont'    , __PdfTrueTypeFont);
      PdfEmbedTTF         := ReadBool   ('PDF', 'EmbedTTF'        , __PdfEmbedTTF);

      // -- Undocumented settings --------------------------------------

      WheelGoban   := ReadBool   ('Options' , 'WheelGoban'   , False);
      KeybComment  := ReadBool   ('Options' , 'KeybComment'  , False);
      RepeatMove   := ReadBool   ('Options' , 'RepeatMove'   , True);
      RepeatTempo  := ReadInteger('Options' , 'RepeatTempo'  , 400);
    end;

  // load printing configuration
  LoadPrintIniFile(iniFile);

  //SetFileName(Files[1]);
  (* A_VOIR
  if not openLast
    then fmMain.ActiveView.si.FileName := ''
    else fmMain.ActiveView.si.FileName := Files[1];
  *)

  // load MRU lists
  //fmMain.MRU_Tutor.LoadFromIni(iniFile, 'MRU-Tutor');
end;

function FloatToString(x : double; prec : integer = 3) : string;
begin
  Result := FloatToStrF(x, ffGeneral, prec, 1);
  Result := StringReplace(Result, ',', '.', []);
end;

procedure TStatus.SaveIniFile(iniFile : TDragoIniFile);
var
  s : string;
begin
  with iniFile do
    begin
      // -- Files ------------------------------------------------------

      MRUList.SaveToIni(iniFile, 'MRU');

      WriteBool   ('Options' , 'UsePortablePaths', UsePortablePaths);
      WriteBool   ('Options' , 'OpenLast'        , OpenLast);
      WriteBool   ('Options' , 'OpenNode'        , OpenNode);
      WriteBool   ('Options' , 'SaveCompact'     , SaveCompact);
      WriteBool   ('Options' , 'DefaultProp'     , DefaultProp);
      WriteBool   ('Options' , 'PlayerProp'      , PlayerProp);
      WriteBool   ('Options' , 'CompressList'    , CompressList);
      WriteBool   ('Options' , 'LongPNames'      , LongPNames);
      WriteBool   ('Options' , 'AbortOnReadError', AbortOnReadError);
      WriteBool   ('Options' , 'ShowPlacesBar'   , ShowPlacesBar);
      WriteInteger('Options' , 'OpenFileDef'     , integer(OpenFileDef));
      WriteInteger('Options' , 'OpenFoldDef'     , integer(OpenFoldDef));
      WriteBool   ('Options' , 'EmptyLBAsL'      , EmptyLBAsL);
      WriteWideStr('Options' , 'FactorizeFolder' , FactorizeFolder);
      WriteInteger('Options' , 'FactorizeDepth'  , FactorizeDepth);
      WriteInteger('Options' , 'FactorizeNbUnique', FactorizeNbUnique);
      WriteBool   ('Options' , 'FactorizeNormPos', FactorizeNormPos);
      WriteInteger('Options' , 'FactorizeReference', FactorizeReference);

      // -- Editing options --------------------------------------------

      WriteInteger('Options' , 'Markup'     , LastMarkup);

      // -- Go board options -------------------------------------------

      SaveGobanIniFile(iniFile);

      // -- Navigation options -----------------------------------------

      WriteInteger('Navigation', 'MoveTargets'   , MoveTargetsToInt(MoveTargets));
      WriteInteger('Navigation', 'TargetStep'    , TargetStep);
      WriteInteger('AutoReplay', 'Delay'         , AutoDelay);
      WriteBool   ('AutoReplay', 'UseTimeProp'   , AutoUseTimeProp);
      WriteBool   ('AutoReplay', 'StopAtTarget'  , AutoStopAtTarget);

      // -- Settings for edition ---------------------------------------

      WriteBool   ('Edit'      , 'ExtendSetup'   , ExtendSetup);

      // -- Tree view options ------------------------------------------

      SaveTreeIniFile(iniFile);

      // -- Move options -----------------------------------------------

      WriteInteger('Options' , 'VarStyle'        , ord(VarStyleDef));
      WriteInteger('Options' , 'VarMarkup'       , ord(VarMarkupDef));

      // -- View options -----------------------------------------------

      WriteBool   ('View'    , 'TabCloseBtn'     , TabCloseBtn);
      WriteInteger('View'    , 'LightSource'     , ord(LightSource));
      WriteBool   ('View'    , 'HookContent'     , HookContent);
      WriteInteger('View'    , 'GameInfo'        , ord(vwGameInfo));
      WriteInteger('View'    , 'MoveInfo'        , ord(vwMoveInfo));
      WriteInteger('View'    , 'TimeLeft'        , ord(vwTimeLeft));
      WriteInteger('View'    , 'NodeName'        , ord(vwNodeName));
      WriteInteger('View'    , 'Variations'      , ord(vwVariation));
      WriteInteger('View'    , 'TreeView'        , ord(vwTreeView));
      WriteInteger('View'    , 'Comment'         , ord(vwComments));
      WinBackground.SaveIni(iniFile, 'View', 'Win');
      WriteInteger('View'    , 'ComFontSize'     , ComFontSize);
      WriteInteger('View'    , 'TextPanelColor'  , TextPanelColor);
      WriteString ('View'    , 'GameInfoPaneFormat', UTF8Encode(GameInfoPaneFormat));
      WriteBool   ('View'    , 'GameInfoPaneImgDisplay', GameInfoPaneImgDisp);
      WriteString ('View'    , 'GameInfoPaneImgDir', UTF8Encode(GameInfoPaneImgDir));

      // -- Sound options ----------------------------------------------

      WriteBool   ('Sounds'  , 'Enable'          , EnableSounds);
      WriteString ('Sounds'  , 'Stone'           , SoundStone);
      WriteString ('Sounds'  , 'InvMove'         , SoundInvMove);
      WriteString ('Sounds'  , 'EngineMove'      , SoundEngineMove);

      // -- Index options ----------------------------------------------

      WriteInteger('Index'   , 'ModePos'         , ModePosIndex);
      WriteInteger('Index'   , 'NbMoves'         , NbMovesIndex);
      WriteInteger('Index'   , 'GraphRadius'     , GIdxRadius);
      WriteString ('Preview' , 'InfoCol'         , InfoCol);
      WriteBool   ('Preview' , 'WarnWhenSort'    , WarnWhenSort);
      WriteInteger('Preview' , 'SortLimit'       , SortLimit);

      // -- Replay mode options ----------------------------------------

      WriteInteger('Games'   , 'Selection'       , GmMode);
      WriteInteger('Games'   , 'Player'          , GmPlayer);
      WriteInteger('Games'   , 'Mode'            , GmPlay);
      WriteInteger('Games'   , 'Fuseki'          , GmNbFuseki);
      WriteInteger('Games'   , 'NbAttempts'      , GmNbAttempts);

      // -- Joseki mode options ----------------------------------------

      WriteInteger('Joseki'  , 'Play with'       , joPlayer);
      WriteInteger('Joseki'  , 'JosekiNumber'    , joNumber);
      WriteString ('Joseki'  , 'Database'        , joDatabase);
      WriteString ('Fuseki'  , 'Database'        , fuDatabase);

      // -- Problem mode options ---------------------------------------

      WriteInteger('Problems', 'Selection'       , PbMode);
      WriteInteger('Problems', 'Solution'        , PbMarkup);
      WriteInteger('Problems', 'Number'          , PbNumber);
      WriteBool   ('Problems', 'RandPos'         , PbRndPos);
      WriteBool   ('Problems', 'RandCol'         , PbRndCol);
      WriteInteger('Problems', 'FailureRatio'    , PbFailureRatio);
      WriteBool   ('Problems', 'UseFailureRatio' , PbUseFailureRatio);
      WriteBool   ('Problems', 'ShowGlyphs'      , PbShowGlyphs);
      WriteBool   ('Problems', 'ShowTimer'       , PbShowTimer);

      // -- Engine game settings (Play) --------------------------------

      WriteInteger('Engine'  , 'Player'          , PlPlayer);
      WriteInteger('Engine'  , 'TotalTime'       , PlTotalTime);
      WriteInteger('Engine'  , 'TimePerMove'     , PlTimePerMove);
      WriteInteger('Engine'  , 'TimingMode'      , Ord(PlTimingMode));
      WriteInteger('Engine'  , 'MainTime'        , PlMainTime);
      WriteInteger('Engine'  , 'OverTime'        , PlOverTime);
      WriteInteger('Engine'  , 'OverStones'      , PlOverStones);
      WriteBool   ('Engine'  , 'AskForSave'      , PlAskForSave);
      WriteInteger('Engine'  , 'StartPos'        , PlStartPos);
      WriteInteger('Engine'  , 'Scoring'         , Ord(PlScoring));
      WriteInteger('Engine'  , 'Undo'            , Ord(PlUndo));
      WriteBool   ('Engine'  , 'Free'            , PlFree);

      // -- Warnings ---------------------------------------------------

      WriteBool   ('Options' , 'WarnFullScreen'  , WarnFullScreen);
      WriteBool   ('Options' , 'WarnDelBrch'     , WarnDelBrch);
      WriteBool   ('Options' , 'WarnAtModif'     , WarnAtModif);
      WriteBool   ('Options' , 'WarnAtModifDB'   , WarnAtModifDB);
      WriteBool   ('Options' , 'WarnInvMove'     , WarnInvMove);
      WriteBool   ('Options' , 'WarnOnPass'      , WarnOnPass);
      WriteBool   ('Options' , 'WarnOnResign'    , WarnOnResign);
      WriteBool   ('Options' , 'WarnLoseOnTime'  , WarnLoseOnTime);

      // -- Settings for database --------------------------------------

      SaveIniFile_Database(iniFile);

      // -- PDF options ------------------------------------------------

      WriteBool   ('PDF', 'UseBoardColor'   , PdfUseBoardColor);
      WriteString ('PDF', 'RadiusAdjust'    , FloatToString(PdfRadiusAdjust));
      WriteString ('PDF', 'FontSizeAdjust'  , PdfFontSizeAdjust);
      WriteString ('PDF', 'CircleWidth'     , FloatToString(PdfCircleWidth));
      WriteString ('PDF', 'LineWidth'       , FloatToString(PdfLineWidth));
      WriteString ('PDF', 'DblLineWidth'    , FloatToString(PdfDblLineWidth));
      WriteString ('PDF', 'HoshiStoneRatio' , FloatToString(PdfHoshiStoneRatio));
      WriteInteger('PDF', 'ExactWidthMm'    , PdfExactWidthMm);
      WriteBool   ('PDF', 'BoldTextOnBoard' , PdfBoldTextOnBoard);
      WriteString ('PDF', 'AddedBorder'     , PdfAddedBorder);
      WriteString ('PDF', 'MarksAdjust'     , PdfMarksAdjust);
      WriteString ('PDF', 'LineHeightAdjust', FloatToString(PdfLineHeightAdjust));
      WriteString ('PDF', 'TrueTypeFont'    , PdfTrueTypeFont);
      WriteBool   ('PDF', 'EmbedTTF'        , PdfEmbedTTF);

      // -- Other options ----------------------------------------------

      WriteString ('Options' , 'Language'    , Language);
      WriteInteger('Options' , 'Encoding'    , integer(DefaultEncoding));
      WriteInteger('Options' , 'CreateEncoding', integer(CreateEncoding));
      WriteInteger('Options' , 'LastTab'     , lastTab);
      //WriteBool   ('Options' , 'WheelGoban' , WheelGoban);
      //WriteBool   ('Options' , 'KeybComment', KeybComment);
      WriteInteger('New'     , 'BoardSize'   , BoardSize);
      WriteInteger('New'     , 'Handicap'    , Handicap);
      s := FloatToStr(KomiForEngine);
      s := StringReplace(s, ',', '.', []);
      WriteString ('New'     , 'Komi'       , s);

      SavePrintIniFile(iniFile)
    end

  // saved on disk by caller
end;

// -- Handling of version updates --------------------------------------------

function VersionBelow(v1, v2 : string) : boolean;
var
  n11, n12, n13, n21, n22, n23 : integer;
begin
  v1 := NthWord(v1, 1);
  v2 := NthWord(v2, 1);

  n11 := StrToIntDef(NthWord(v1, 1, '.'), 0);
  n12 := StrToIntDef(NthWord(v1, 2, '.'), 0);
  n13 := StrToIntDef(NthWord(v1, 3, '.'), 0);
  n21 := StrToIntDef(NthWord(v2, 1, '.'), 0);
  n22 := StrToIntDef(NthWord(v2, 2, '.'), 0);
  n23 := StrToIntDef(NthWord(v2, 3, '.'), 0);

  Result := (n11 < n21) or (n12 < n22) or (n13 < n23)
end;

procedure TStatus.UpdateIniFile(iniFile : TTntMemIniFile);
var
  version : string;
  x : boolean;
begin
  // get version string
  version := iniFile.ReadString('Drago', 'Version', '');

  // exit if no version update
  if version = AppVersion
    then exit;

  // store current version
  iniFile.WriteString('Drago', 'Version', AppVersion);

  // previous version under 3.10
  if VersionBelow(version, '3.10') then
    begin
      x := iniFile.ReadBool('Options', 'NoPlacesBar', False);
      iniFile.WriteBool('Options', 'ShowPlacesBar', not x);
      iniFile.UpdateFile
    end
end;

// ---------------------------------------------------------------------------

function AppRelativePath(const path : WideString) : WideString;
begin
  Result := WideRelativePath(path, Status.AppPath)
end;

function AppAbsolutePath(const path : WideString) : WideString;
begin
  if path = ''
    then Result := ''
    else Result := WideAbsolutePath(path, Status.AppPath)
end;

// ---------------------------------------------------------------------------

initialization
  // TODO: remove startingDir ?
  startingDir := WideExtractFilePath(WideApplicationExeName);
  TStatus.Create;
finalization
  Status.Free
end.
