// ---------------------------------------------------------------------------
// -- Drago -- Instance status ---------------------------- UInstStatus.pas --
// ---------------------------------------------------------------------------

unit UInstStatus;

// ---------------------------------------------------------------------------

interface

uses
  IniFiles,
  DefineUi, CodePages, Std, UGameTree;


type
  TTreeMat = array of array of TGameTree;
  TSetModeInter = procedure(mode : integer);

  TInstStatus = class
    ViewMode      : TViewMode;
    ParentView    : TObject;
    GameEncoding  : TCodePage;          // encoding for game (CA property)
    Fplayer       : integer;
    Fnumber       : integer;
    FBlackPriso   : integer;
    FWhitePriso   : integer;
    GobanNumber   : integer;            // goban number (GobanNN) for newly created tab
    DatabaseName  : WideString;
    FolderName    : WideString;
    FFileName     : WideString;
    FFileSave     : boolean;
    FReadOnly     : boolean;
    FIndexTree    : integer;
    CurrentPath   : string;
    MainMode      : integer;
    FModeInter    : integer;
    ModeInterBak  : integer;            // used by WaitEngine
    ModeInterBeforeGS : integer;        // used by group status
    EnableMode    : TEnablingMode;
    HasTimeProp   : boolean;
    CurrLastMove  : integer;            // last move played in ReplayGame or EngineGame mode
    ApplyQuiet    : boolean;            // flag to prevent access to GUI
    ShowVar       : boolean;            // used to hide variations
    ForceShowTime : boolean;            // used to force display of timing
    EndingMove    : integer;            // ending point for target moves by step
    MouseWheelOnGoban : boolean;
    StackFG       : TStringStack;
    EngineTab     : boolean;

    // tree view
    TVmat         : TTreeMat;
    TVheight      : integer;
    TVwidth       : integer;
    nStoneW       : integer;
    nStoneH       : integer;
    TVi0          : integer;
    TVj0          : integer;
    TVi1          : integer;
    TVj1          : integer;
    TextFontB     : integer;
    TVoffsetH     : integer;
    TVoffsetV     : integer;
    TvLastMarked  : TGameTree;

    // replay
    GmMode            : integer;        // selection mode      for current session
    GmPlayer          : integer;        // color of engine     "
    GmPlay            : integer;        // play or fuseki mode "
    GmNbFuseki        : integer;        // moves in fuseki     "
    GmLength          : integer;
    GmRightMoves      : integer;
    GmWrongMoves      : integer;
    GmLatestWrongMove : integer;        // used to avoid couting twice a wrong move

    // problems
    pbMarkup          : integer;        // markup of solutions for current session
    pbMode            : integer;        // selection mode      "
    pbNumber          : integer;        // number of problems  "
    pbRndPos          : boolean;        // random position     "
    pbRndCol          : boolean;        // random color        "
    ListProblems      : array of integer;
    pbIndex           : integer;
    pbChrono          : integer;
    pbNumberOk        : integer;        // number of correct problem in session
    pbUndo            : boolean;
    pbResign          : boolean;
    pbPbUndo          : boolean;
    pbPbCorrect       : boolean;
    pbLastMoveKnown   : boolean;
    pbCountedResult   : boolean;
    myPbSolMarkup     : integer;
    PbBackRoot        : TGameTree;      // free mode position backup
    PbBackPath        : string;         // "

    // engines
    EngineColor        : integer;
    TimingMode         : TTimingMode;
    TimedPlayer        : integer;
    BlackTimeStart     : TDateTime;
    WhiteTimeStart     : TDateTime;
    BlackTimeLeftStart : integer;       // time left when starting a move
    WhiteTimeLeftStart : integer;
    BlackTimeLeft      : integer;       // time left at any moment
    WhiteTimeLeft      : integer;
    BlackStonesLeft    : integer;
    WhiteStonesLeft    : integer;

    // josekis
    joIndex       : integer;
    joRightMoves  : integer;
    joWrongMoves  : integer;

    //database
    dbLastRequest : string;
    DbQuickSearch : TQuickSearchStatus;

    // todo : not used currently (check UApply), remove ?
    DbSearchOpen  : boolean;            // set when opening tab with DbSearch open
                                        // closed by DbSearch

    // observer (0: Actions, 1: fmDBSearch, hard coded until now)
    ObservedSetModeInter : array[0 .. 1] of TSetModeInter;

    constructor Create;
    destructor  Destroy; override;
    procedure SetPlayer    (player : integer);
    procedure SetMoveNumber(number : integer);
    procedure SetBlackPrisoners(n : integer);
    procedure SetWhitePrisoners(n : integer);
    procedure SetFileName  (argName : WideString);
    procedure SetIndexTree (n : integer);
    procedure SetFileSave  (val : boolean);
    procedure SetModeInter (mode : integer);
    procedure SetReadOnly  (mode : boolean);
    
    property  Player     : integer read Fplayer     write SetPlayer;
    property  MoveNumber : integer read Fnumber     write SetMoveNumber;
    property  BlackPrisoners : integer read FBlackPriso write SetBlackPrisoners;
    property  WhitePrisoners : integer read FWhitePriso write SetWhitePrisoners;
    property  FileName   : WideString read FfileName write SetFileName;
    property  ReadOnly   : boolean read FReadOnly   write SetReadOnly;
    property  IndexTree  : integer read FIndexTree  write SetIndexTree;
    property  FileSave   : boolean read FfileSave   write SetFileSave;
    property  ModeInter  : integer read FModeInter  write SetModeInter;

    procedure Default;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  Define, UView, UStatus;

// ---------------------------------------------------------------------------

constructor TInstStatus.Create;
begin
  inherited;
  StackFG := TStringStack.Create
end;

destructor TInstStatus.Destroy;
begin
  StackFG.Free
end;

procedure TInstStatus.Default;
begin
  ParentView    := nil;
  FPlayer       := Black;
  FFileName     := '';
  FIndexTree    := 0;
  FFileSave     := True;
  ReadOnly      := False;
  MainMode      := muNavigation;
  EnableMode    := mdEdit;
  ModeInter     := kimGE;
  HasTimeProp   := False;
  PbBackRoot    := nil;
  PbBackPath    := '';
  ApplyQuiet    := False;
  ShowVar       := True;
  ForceShowTime := False;
  MouseWheelOnGoban := True;
  TvLastMarked  := nil;
  // problems
  SetLength(ListProblems, 0);
  pbNumberOk    := 0;
  // db
  DbLastRequest := '';
  DbQuickSearch := qsOff
end;

// -- Update of player panel -------------------------------------------------

// -- Update player color

procedure TInstStatus.SetPlayer(player : integer);
begin
  FPlayer := player;
end;

// -- Update move number

procedure TInstStatus.SetMoveNumber(number : integer);
begin
  Fnumber := number;
end;

// -- Update prisoner numbers

procedure TInstStatus.SetBlackPrisoners(n : integer);
begin
  FBlackPriso := n;
end;

procedure TInstStatus.SetWhitePrisoners(n : integer);
begin
  FWhitePriso := n;
end;

// -- Update filename

procedure TInstStatus.SetFileName(argName : WideString);
begin
  FFileName := argName;

  if Assigned(ParentView)
    then (ParentView as TView).ShowFileName(argName)
end;

// -- Update game index

procedure TInstStatus.SetIndexTree(n : integer);
begin
  if (FFileName <> '') and (Settings.MRUList.Count > 0)
    then Settings.MRUList[0].Index := n;

  FIndexTree := n;

  if Assigned(ParentView)
    then (ParentView as TView).ShowGameIndex(n)
end;

// -- Update modification flag

procedure TInstStatus.SetFileSave(val : boolean);
begin
  if not (MainMode in [muNavigation, muModification, muEngineGame]) or
     not Assigned(ParentView)
    then exit;

  // DB can never be saved
  if DatabaseName <> ''
    then val := True;

  FFileSave := val;

  with ParentView as TView do
    if Assigned(cl) and (Length(cl.FTree) > IndexTree)
      and Assigned(cl.FTree[IndexTree])
      then cl.FTree[IndexTree].Modified := not val;

  (ParentView as TView).ShowSaveStatus(val)
end;

// -- Update intersection mode

procedure TInstStatus.SetModeInter(mode : integer);
var
  i : integer;
begin
  case mode of
    kimGB : FModeInter := kimGE;
    kimGW : FModeInter := kimGE;
    else    FModeInter := mode
  end;

  for i := 0 to High(ObservedSetModeInter) do
    if Assigned(ObservedSetModeInter[i])
      then ObservedSetModeInter[i](mode)
end;

// -- Update modification mode

procedure TInstStatus.SetReadOnly(mode : boolean);
begin
  FReadOnly := mode;
  if Assigned(ParentView)
    then (ParentView as TView).ShowReadOnlyStatus(mode)
end;

// ---------------------------------------------------------------------------

end.
