// ---------------------------------------------------------------------------
// -- Drago -- Definition of constants ------------------------- Define.pas --
// ---------------------------------------------------------------------------

unit DefineUi;

// ---------------------------------------------------------------------------

interface

const

// Identification of application

  AppName    = 'Drago';
  AppVersion = '4.33';
  kEMail     = 'gilles_arcas@hotmail.com';
  kCopyright = 'Copyright ' + chr(169) + ' 2004-2021';

// Maximum number of move

  MaxMoveNumber = 100000;
  
// Complement to player colors

  Both  = 3;
  pcBoth      = 3;
  pcAlternate = 5;

  MaxBoardSize = 21;

const

// Statusbar panels

  sbGameNumber = 0;
  sbLastMove   = 1;
  sbIgnored    = 2;
  sbReadOnly   = 3;
  sbGlyph      = 4;
  sbAnnotation = 5;
  sbMoveStatus = 6;

// Intersection modes : it is important to preserve kimGB .. kimDD

  kimGE        =   0; // Game Edit mode
  kimGB        =  40; // Game edit Black first
  kimGW        =  41; // Game edit White first
  kimAB        =   1; // Add Black
  kimAW        =   2; // Add White
  kimAE        =   3; // Add Empty
  kimMA        =   5; // Add Cross (MArk property)
  kimTR        =   6; // Add TRiangle
  kimCR        =   7; // Add CiRcle
  kimSQ        =   8; // Add SQuare
  kimLE        =   9; // Add Letter
  kimNU        =  10; // Add NUmber
  kimLB        =  11; // Add LaBel
  kimTB        =  12; // Add Black Territory
  kimTW        =  13; // Add White Territory
  kimVW        =  14; // Visible
  kimDD        =  15; // Dimmed
  kimHB        =  24; // Add Black   (free handicap)
  kimEB        =  25; // Erase Black (free handicap)
  kimZO        =  16; // Zone
  kimPS        =  17; // Pattern Search
  kimWC        =  18; // Wildcard for pattern search
  kimGS        =  19; // Group status
  kimNOP       =  50; // Nop
  kimPB        = 100; // Problem
  kimPF        =1000; // Problem Finished
  kimRG        = 200; // Replay Game
  kimRGR       = 201; // Replay Game Rewind
  kimEG        = 250; // Engine Game
  kimEGR       = 251; // Engine Game Rewind
  kimJO        = 300; // Joseki
  kimTU        = 350; // Joseki tutor
  kimFU        = 400; // Fuseki
  kimAR        = 500; // Auto replay

  kimMarkups   = [kimMA .. kimTW, kimWC, kimVW];

// Using modes for saving

  muNavigation    = 0;
  muModification  = 1;
  muProblem       = 2;
  muFree          = 3;
  muReplayGame    = 4;
  muEngineGame    = 5;
  muJoseki        = 6;

// Application modes of properties

  Enter = 1;  {--> O}
  Leave = 2;  {O -->}
  Redo  = 3;  {O <--}
  Undo  = 4;  {<-- O}

// Modes for position display in index

  piInitial = 0;
  piFinal   = 1;
  piInter   = 2;
  piNext    = 3;
  piPrev    = 4;

// Key of help files in language files

  HlpFile   = '$HelpFile';

// HTML Help tags - be sure to use the same in Help.hhp

  IDH_ModePb                  =  1000;
  IDH_ModeGm                  =  2000;
  IDH_Index                   =  3000;
  IDH_Options                 =  4000;
  IDH_SGF                     =  5000;
  IDH_Engine                  =  6000;
  IDH_Favoris                 =  7000;
  IDH_Print                   =  8000;
  IDH_ExpPos                  =  9000;
  IDH_Database                = 10000;
  IDH_Factorisation           = 10005;

  IDH_Database_Create         = 10010;
  IDH_Database_Update         = 10020;
  IDH_Database_PatternSearch  = 10030;
  IDH_Database_InfoSearch     = 10040;
  IDH_Database_SigSearch      = 10050;

  IDH_Options_Board           =  4010;
  IDH_Options_Stones          =  4015;
  IDH_Options_Moves           =  4020;
  IDH_Options_GTree           =  4030;
  IDH_Options_View            =  4040;
  IDH_Options_Preview         =  4050;
  IDH_Options_Panels          =  4060;
  IDH_Options_Shortcuts       =  4070;
  IDH_Options_Toolbars        =  4080;
  IDH_Options_Sounds          =  4090;
  IDH_Options_Files           =  4100;
  IDH_Options_Navigation      =  4110;
  IDH_Options_Edit            =  4120;
  IDH_Options_Database        =  4130;
  IDH_Options_Engine          =  4140;
  IDH_Options_Language        =  4150;
  IDH_Options_Advanced        =  4160;

  IDH_Print_GamesFig          =  8010;
  IDH_Print_Layout            =  8020;
  IDH_Print_Styles            =  8030;
  IDH_Print_Formats           =  8040;

const

// Constants for MessageDialog calls

  msOk          =  0;
  msOkCancel    =  1;
  msYesNo       =  2;
  msYesNoCancel =  3;
  imDrago       =  0;
  imExclam      =  1;
  imQuestion    =  2;
  imSad         =  3;

// Cursor

  crWaiting     =  1;
  crZone        =  3; // avoid a conflict with Preview.pas

// Modes for game starting position (sp : StartPos)

  spSelect      =  0;
  spCurrent     =  1;
  spMatch       =  2;
  spNew         =  3;
  spNone        =  4;

// Synonyms for readability

  engineWin     = True;

// Title printing formats

  stFmtMainTitle = 'Game \game - Figure \figure (\moves)';
  stFmtVarTitle  = 'Game \game - Diagram \figure';
  
// Usefull

  CRLF = ^M^J; //#$0D#$0A;

type

// Tab modes

  TViewMode     = (vmBoard=0, vmInfo, vmThumb,
                   vmInfoPS, vmThumbPS, // Info and thumb views with pattern search results
                   vmInfoPb, vmInfoGm,
                   vmAll);

  TSearchMode   = (smNone, smInfo, smSig, smPattern, smSettings, smSettingsModal);

// Activation modes of commands

  TEnablingMode = (mdNone, mdEdit, mdGame, mdProb, mdJski, mdPlay, mdExpo, mdTuto,
                   mdCrea, mdAuto, mdFuse, mdInfoView, mdThumbView);

// Styles for background display

  TWinStyle     = (wsColor, wsBitmap);
  TBackStyle    = (bsAsGoban, bsColor, bsDefaultTexture, bsCustomTexture);

// StartEvent modes

  TStartEvent   = (seMain, seMainSameTab, seIndex, sePrint, seProblem);

// Move targets

  TMoveTarget   = (mtStep, mtComment, mtStartVar, mtEndVar, mtFigure,
                   mtAnnotation);

  TMoveTargets  = set of TMoveTarget;

// Formats for printing/exporting

  TExportMode   = (emNFig,
                   emPrint,
                   emPreviewRTF, emExportRTF,
                   emPreviewHTM, emExportHTM,
                   emPreviewDOC, emExportDOC,
                   emPreviewPDF, emExportPDF,
                   emPreviewHPD, emExportHPD, // Haru PDF
                   emExportWMF , emExportIMG,
                   emPreviewTXT, emExportTXT
                   );

  TExportGame   = (egRTF, egHTM, egDOC, egPDF, egTXT);

  TExportFigure = (eiNON, // no figure
                   eiWMF, eiGIF, eiPNG, eiJPG, eiBMP, eiPDF,
                   eiRGG, // rec.games.go
                   eiSSL, // sensei's library
                   eiEMF, // not implemented
                   eiSGF, // flatten SGF
                   eiTRC  // ASCII trace mode
                   );

// Modes for game selection for printing

  TprGames      = (pgCurrent, pgAll, pgFromTo);

// Modes for printing figure selection

  TFigures      = (fgNone, fgLast, fgInter, fgPropFG, fgStep, fgMarkCom);

// Styles for game information printing

  TprInfos      = (inNone, inTop, inName);

// Styles for printing layout

  TLayout       = (loFigPerPage1, loFigPerPage2, loFigPerPage4);

// Modes for display of left panels

  TViewPane     = (vwNever, vwRequired, vwAlways);

// Styles for variation display

  TVarStyle     = (vsChildren, vsSibling, vsUndef);
  TVarMarkup    = (vmNone, vmGhost, vmUpCase, vmDnCase, vmUndef);//, vmAbsNone);

// Styles for move number display in game tree

  TTvMoves      = (tmNone, tmBorder, tmStones);

// Callbacks

  TProc         = procedure;
  TProcString   = procedure (const s : WideString);

// Undo mode for engine games

  TEngineUndo = (euNo, euYes, euCapture);

// Timing mode for Mogo

  TTimingMode = (tmNo, tmTotalTime, tmTimePerMove, tmOverTime);

// Scoring

  TScoring = (scJapanese, scChinese, scAGA);

// Modification and saving

  TOpenMode = (omEdit,        // edit mode: new moves and modify flag set up
               omReadOnly,    // read only: no new moves
               omFree,        // free mode: new moves, but modify flag not set
               omProtected);  // protected mode: warning when modifying

// Database dialog mode

  TDBMode = (dbCreate, dbAddTo);

// Modes for viewing pattern search result

  TDBSearchView = (svKombilo = 0, svFull, svDigest);

// Quick search status
  TQuickSearchStatus = (qsOff, qsOpen, qsReady);

// Modes for pattern search

  TPatternSearchMode = (
    psmNone,                  // no pattern search
    psmButtonSearchDBWindow,  // select and press search button
    psmQuickSearchDBWindow,   // quick search DB window open
    psmQuickSearchSideBar     // quick search results in sidebar
  );

// Sounds

  TSound = (sStone = 0, sInvMove, sEngineMove);

// Mode for information view

  TViewInfoMode = (imDefault, imProblem, imReplay);

// Code page

  TSaveEncoding = (seUnicode, seCurrent);

// Input parameter for option dialog (must be the names of options tabs)

const
  eoDefault    = '';
  eoBoard      = 'TabSheetBoard';
  eoEngines    = 'TabSheetEngines';
  eoEngines2   = 'TabSheetEngines2'; // used to go directly to predefined engines
  eoLibrary    = 'TabSheetLibrary';
  eoNavigation = 'TabSheetNavigation';
  eoView       = 'TabSheetView';
  eoSideBar    = 'TabSheetSideBar';
  eoIndex      = 'TabSheetIndex';
  eoDatabase   = 'TabSheetDatabase';
  eoToolbars   = 'TabSheetToolbars';
  eoLanguage   = 'TabSheetLanguage';
  eoGameTree   = 'TabSheetGameTree';
  eoAdvanced   = 'TabSheetAdvanced';

// Synonyms

const
  kLastQuiet = True;

// ---------------------------------------------------------------------------

implementation

uses TypInfo;

// not used, remains until now as an example of GetEnumName
// could be with GetEnumValue

type TDragoCommand = (dcUnknown, dcNew, dcOpen, dcSave, dcInsert);

function GetCommandFromName(name : string) : TDragoCommand;
  begin
    for Result := Low(TDragoCommand) to High(TDragoCommand) do
      if ('dc' + name) = GetEnumName(TypeInfo(TDragoCommand), ord(Result))
        then exit;

    Result := dcUnknown
  end;

// ---------------------------------------------------------------------------

end.
