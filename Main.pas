// ---------------------------------------------------------------------------
// -- Drago -- Main form ----------------------------------------- Main.pas --
// ---------------------------------------------------------------------------

unit Main;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, ShellAPI, Types,
  SysUtils, Classes, Controls, Forms,
  ExtCtrls, Menus, StdCtrls, IniFiles,
  Commctrl, Graphics, ShellCtrls, AppEvnts,
  ComCtrls, ImgList,
  XPMan,
  UActions, TB2Item, TB2Dock, TB2Toolbar,
  TntForms, TntMenus, TntComCtrls, TntGraphics, TntSystem, SpTBXItem,
  DefineUi, UDragoIniFiles,
  UMRUList,
  UTabButton,
  CoolTrayIcon,
  UContext, Ustatus,
  UView, UViewMain, UViewBoard, UViewInfo, UViewThumb,
  BomeOneInstance, SpTBXDkPanels, UFullScreenToggler;

type
  TTabSheetEx = class;
  TListOfDBTabs = class;

  TfmMain = class(TTntForm)
    tmMemory          : TTimer;
    BtnImages         : TImageList;  // Image lists
    TabBtnImages      : TImageList;
    TabImages         : TImageList;
    GridImages        : TImageList;  // Edition
    pmEditMode        : TPopupMenu;
    pmMarkup          : TPopupMenu;
    pmTab1            : TPopupMenu;
    pmTab2: TPopupMenu;
    pmMarkupCross: TTntMenuItem;
    pmMarkupTriangle: TTntMenuItem;
    pmMarkupCircle: TTntMenuItem;
    pmMarkupSquare: TTntMenuItem;
    pmMarkupLetter: TTntMenuItem;
    pmMarkupNumber: TTntMenuItem;
    pmMarkupLabel: TTntMenuItem;
    N9: TTntMenuItem;
    pmBlackTerritory: TTntMenuItem;
    pmWhiteTerritory: TTntMenuItem;
    mnNewInTab: TTntMenuItem;
    mnOpenInTab: TTntMenuItem;
    mnOpenFolderInTab: TTntMenuItem;
    N15: TTntMenuItem;
    mnSave2: TTntMenuItem;
    mnSaveAs2: TTntMenuItem;
    N16: TTntMenuItem;
    mnCloseTab: TTntMenuItem;
    mnCloseAll2: TTntMenuItem;
    mnNew2: TTntMenuItem;
    mnOpen2: TTntMenuItem;
    mnOpenFolder2: TTntMenuItem;
    N17: TTntMenuItem;
    mnCloseAll3: TTntMenuItem;
    mnEditGameBlackFirst: TTntMenuItem;
    mnEditGameWhiteFirst: TTntMenuItem;
    ApplicationEvents: TApplicationEvents;
    DockTop: TSpTBXDock;
    ToolbarFile: TSpTBXToolbar;
    SpTBXItem1: TSpTBXItem;
    SpTBXItem2: TSpTBXItem;
    SpTBXItem3: TSpTBXItem;
    SpTBXItem4: TSpTBXItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    SpTBXItem5: TSpTBXItem;
    SpTBXItem6: TSpTBXItem;
    SpTBXSeparatorItem2: TSpTBXSeparatorItem;
    SpTBXItem7: TSpTBXItem;
    SpTBXItem8: TSpTBXItem;
    SpTBXItem9: TSpTBXItem;
    SpTBXSeparatorItem3: TSpTBXSeparatorItem;
    SpTBXItem10: TSpTBXItem;
    SpTBXItem11: TSpTBXItem;
    SpTBXItem12: TSpTBXItem;
    SpTBXSeparatorItem4: TSpTBXSeparatorItem;
    SpTBXItem13: TSpTBXItem;
    SpTBXMainMenu: TSpTBXToolbar;
    mnLibrary: TSpTBXItem;
    mnJoseki: TSpTBXItem;
    mnDatabase: TSpTBXSubmenuItem;
    SpTBXItem65: TSpTBXItem;
    SpTBXItem66: TSpTBXItem;
    mnEdition: TSpTBXSubmenuItem;
    SpTBXItem64: TSpTBXItem;
    SpTBXItem45: TSpTBXItem;
    SpTBXSeparatorItem14: TSpTBXSeparatorItem;
    mnFile: TSpTBXSubmenuItem;
    SpTBXItem14: TSpTBXItem;
    SpTBXItem18: TSpTBXItem;
    SpTBXItem17: TSpTBXItem;
    SpTBXItem16: TSpTBXItem;
    SpTBXItem15: TSpTBXItem;
    mnReadOnly: TSpTBXItem;
    SpTBXItem20: TSpTBXItem;
    SpTBXItem19: TSpTBXItem;
    SpTBXSeparatorItem5: TSpTBXSeparatorItem;
    mnCollections: TSpTBXSubmenuItem;
    SpTBXItem25: TSpTBXItem;
    SpTBXItem24: TSpTBXItem;
    SpTBXItem23: TSpTBXItem;
    SpTBXItem22: TSpTBXItem;
    SpTBXSeparatorItem6: TSpTBXSeparatorItem;
    SpTBXItem27: TSpTBXItem;
    SpTBXItem26: TSpTBXItem;
    SpTBXSeparatorItem8: TSpTBXSeparatorItem;
    SpTBXItem30: TSpTBXItem;
    SpTBXItem29: TSpTBXItem;
    SpTBXItem28: TSpTBXItem;
    SpTBXSeparatorItem7: TSpTBXSeparatorItem;
    SpTBXItem35: TSpTBXItem;
    SpTBXSeparatorItem9: TSpTBXSeparatorItem;
    mnFile1: TSpTBXItem;
    mnFile2: TSpTBXItem;
    mnFile3: TSpTBXItem;
    mnFile4: TSpTBXItem;
    mnView: TSpTBXSubmenuItem;
    SpTBXItem40: TSpTBXItem;
    SpTBXItem39: TSpTBXItem;
    SpTBXItem38: TSpTBXItem;
    SpTBXSeparatorItem10: TSpTBXSeparatorItem;
    SpTBXItem37: TSpTBXItem;
    SpTBXItem36: TSpTBXItem;
    mnNavigation: TSpTBXSubmenuItem;
    SpTBXItem54: TSpTBXItem;
    SpTBXItem53: TSpTBXItem;
    SpTBXItem52: TSpTBXItem;
    SpTBXItem51: TSpTBXItem;
    SpTBXItem50: TSpTBXItem;
    SpTBXSeparatorItem11: TSpTBXSeparatorItem;
    SpTBXItem59: TSpTBXItem;
    SpTBXItem58: TSpTBXItem;
    SpTBXItem57: TSpTBXItem;
    SpTBXItem56: TSpTBXItem;
    SpTBXItem55: TSpTBXItem;
    SpTBXSeparatorItem12: TSpTBXSeparatorItem;
    SpTBXItem63: TSpTBXItem;
    SpTBXItem62: TSpTBXItem;
    SpTBXItem61: TSpTBXItem;
    SpTBXSeparatorItem13: TSpTBXSeparatorItem;
    SpTBXItem60: TSpTBXItem;
    SpTBXSubmenuItem6: TSpTBXSubmenuItem;
    SpTBXItem41: TSpTBXItem;
    SpTBXItem67: TSpTBXItem;
    SpTBXItem68: TSpTBXItem;
    SpTBXItem69: TSpTBXItem;
    SpTBXItem70: TSpTBXItem;
    SpTBXSubmenuItem7: TSpTBXSubmenuItem;
    SpTBXSeparatorItem15: TSpTBXSeparatorItem;
    SpTBXItem71: TSpTBXItem;
    SpTBXItem72: TSpTBXItem;
    SpTBXItem73: TSpTBXItem;
    SpTBXItem74: TSpTBXItem;
    SpTBXItem75: TSpTBXItem;
    SpTBXItem76: TSpTBXItem;
    SpTBXItem77: TSpTBXItem;
    SpTBXSeparatorItem16: TSpTBXSeparatorItem;
    SpTBXItem78: TSpTBXItem;
    SpTBXItem79: TSpTBXItem;
    SpTBXItem84: TSpTBXItem;
    SpTBXSeparatorItem18: TSpTBXSeparatorItem;
    SpTBXItem85: TSpTBXItem;
    SpTBXSeparatorItem19: TSpTBXSeparatorItem;
    SpTBXItem86: TSpTBXItem;
    mnReplayGames: TSpTBXSubmenuItem;
    SpTBXItem42: TSpTBXItem;
    SpTBXItem87: TSpTBXItem;
    SpTBXItem88: TSpTBXItem;
    mnProblems: TSpTBXSubmenuItem;
    SpTBXItem44: TSpTBXItem;
    mnPbFreeMode: TSpTBXItem;
    SpTBXItem48: TSpTBXItem;
    SpTBXItem49: TSpTBXItem;
    SpTBXItem89: TSpTBXItem;
    mnEngineGame: TSpTBXSubmenuItem;
    SpTBXItem90: TSpTBXItem;
    SpTBXItem91: TSpTBXItem;
    SpTBXItem92: TSpTBXItem;
    SpTBXItem93: TSpTBXItem;
    SpTBXSeparatorItem20: TSpTBXSeparatorItem;
    SpTBXItem94: TSpTBXItem;
    SpTBXItem95: TSpTBXItem;
    SpTBXSeparatorItem21: TSpTBXSeparatorItem;
    SpTBXItem96: TSpTBXItem;
    mnHelp: TSpTBXSubmenuItem;
    SpTBXItem97: TSpTBXItem;
    SpTBXItem98: TSpTBXItem;
    SpTBXItem99: TSpTBXItem;
    SpTBXSeparatorItem22: TSpTBXSeparatorItem;
    SpTBXItem101: TSpTBXItem;
    mnPlayer: TSpTBXSubmenuItem;
    SpTBXItem100: TSpTBXItem;
    SpTBXItem102: TSpTBXItem;
    mnDebug: TSpTBXSubmenuItem;
    SpTBXItem104: TSpTBXItem;
    SpTBXItem105: TSpTBXItem;
    SpTBXItem106: TSpTBXItem;
    SpTBXItem107: TSpTBXItem;
    mnSaveCurrent: TSpTBXItem;
    SpTBXItem109: TSpTBXItem;
    SpTBXItem110: TSpTBXItem;
    SpTBXItem111: TSpTBXItem;
    mnResources: TSpTBXItem;
    ToolbarEdit: TSpTBXToolbar;
    SpTBXItem46: TSpTBXItem;
    SpTBXItem112: TSpTBXItem;
    tbCurrentMarkup: TSpTBXSubmenuItem;
    SpTBXItem113: TSpTBXItem;
    SpTBXItem114: TSpTBXItem;
    tbGameEdit: TSpTBXSubmenuItem;
    SpTBXItem115: TSpTBXItem;
    SpTBXItem116: TSpTBXItem;
    SpTBXItem117: TSpTBXItem;
    SpTBXItem118: TSpTBXItem;
    SpTBXItem119: TSpTBXItem;
    SpTBXItem120: TSpTBXItem;
    SpTBXItem121: TSpTBXItem;
    SpTBXItem122: TSpTBXItem;
    SpTBXSeparatorItem24: TSpTBXSeparatorItem;
    SpTBXItem123: TSpTBXItem;
    SpTBXItem124: TSpTBXItem;
    SpTBXItem125: TSpTBXItem;
    SpTBXItem126: TSpTBXItem;
    SpTBXSeparatorItem17: TSpTBXSeparatorItem;
    ToolbarNavigation: TSpTBXToolbar;
    SpTBXItem32: TSpTBXItem;
    SpTBXItem33: TSpTBXItem;
    SpTBXItem34: TSpTBXItem;
    SpTBXItem80: TSpTBXItem;
    SpTBXItem81: TSpTBXItem;
    SpTBXSeparatorItem23: TSpTBXSeparatorItem;
    SpTBXItem82: TSpTBXItem;
    SpTBXItem83: TSpTBXItem;
    SpTBXItem127: TSpTBXItem;
    SpTBXItem128: TSpTBXItem;
    SpTBXItem129: TSpTBXItem;
    SpTBXSeparatorItem25: TSpTBXSeparatorItem;
    tbPrevTarget: TSpTBXItem;
    tbAutoReplay: TSpTBXSubmenuItem;
    tbNextTarget: TSpTBXSubmenuItem;
    SpTBXItem43: TSpTBXItem;
    SpTBXItem47: TSpTBXItem;
    SpTBXSeparatorItem26: TSpTBXSeparatorItem;
    SpTBXItem131: TSpTBXItem;
    SpTBXItem132: TSpTBXItem;
    SpTBXItem133: TSpTBXItem;
    SpTBXItem134: TSpTBXItem;
    SpTBXItem31: TSpTBXItem;
    SpTBXItem135: TSpTBXItem;
    SpTBXItem136: TSpTBXItem;
    mnTestDivers: TSpTBXItem;
    MenuForShortcuts: TMainMenu;
    ActionsWithShortcut: TMenuItem;
    ToolbarView: TSpTBXToolbar;
    SpTBXItem103: TSpTBXItem;
    ToolbarMisc: TSpTBXToolbar;
    SpTBXItem130: TSpTBXItem;
    SpTBXItem137: TSpTBXItem;
    SpTBXItem138: TSpTBXItem;
    SpTBXItem139: TSpTBXItem;
    SpTBXSeparatorItem27: TSpTBXSeparatorItem;
    SpTBXItem140: TSpTBXItem;
    SpTBXItem141: TSpTBXItem;
    SpTBXItem142: TSpTBXItem;
    SpTBXItem143: TSpTBXItem;
    SpTBXItem144: TSpTBXItem;
    SpTBXItem145: TSpTBXItem;
    SpTBXItem146: TSpTBXItem;
    mnShowToolbars: TSpTBXSubmenuItem;
    SpTBXSeparatorItem28: TSpTBXSeparatorItem;
    mnShowTB_Misc: TSpTBXItem;
    mnShowTB_Edit: TSpTBXItem;
    mnShowTB_Navigation: TSpTBXItem;
    mnShowTB_View: TSpTBXItem;
    mnShowTB_File: TSpTBXItem;
    mnOptions: TSpTBXSubmenuItem;
    SpTBXItem147: TSpTBXItem;
    SpTBXItem148: TSpTBXItem;
    SpTBXSeparatorItem29: TSpTBXSeparatorItem;
    SpTBXItem152: TSpTBXItem;
    SpTBXItem153: TSpTBXItem;
    SpTBXItem154: TSpTBXItem;
    OneInstance: TOneInstance;
    MainPageControl: TTntPageControl;
    SpTBXItem108: TSpTBXItem;
    SpTBXItem149: TSpTBXItem;
    SpTBXItem150: TSpTBXItem;
    SpTBXSeparatorItem30: TSpTBXSeparatorItem;
    SpTBXItem156: TSpTBXItem;
    StatusBar: TTntStatusBar;
    SpTBXItem157: TSpTBXItem;
    Reloadcurrentfile1: TTntMenuItem;
    SpTBXItem151: TSpTBXItem;
    DockRight: TSpTBXDock;
    DockBottom: TSpTBXDock;
    DockLeft: TSpTBXDock;
    mnMakeGameTree: TSpTBXItem;
    SpTBXSeparatorItem31: TSpTBXSeparatorItem;
    mnTestEngine: TSpTBXItem;
    pmTrayIcon: TPopupMenu;
    Restore1: TTntMenuItem;
    Quit1: TTntMenuItem;
    SpTBXItem155: TSpTBXItem;
    SpTBXItem158: TSpTBXItem;
    SpTBXSeparatorItem32: TSpTBXSeparatorItem;
    btQuickSearch: TSpTBXItem;
    btMarkupWildcard: TSpTBXItem;
    SpTBXSeparatorItem33: TSpTBXSeparatorItem;
    SpTBXItem21: TSpTBXItem;
    SpTBXItem160: TSpTBXItem;
    SpTBXItem161: TSpTBXItem;
    SpTBXItem162: TSpTBXItem;
    SpTBXItem159: TSpTBXItem;
    SpTBXItem163: TSpTBXItem;
    SpTBXSeparatorItem34: TSpTBXSeparatorItem;
    SpTBXItem164: TSpTBXItem;
    SpTBXItem165: TSpTBXItem;

    // Files
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnFile1PrevClick(Sender: TObject);
    // Options
    procedure mnOptions0Click(Sender: TObject);
    // Debug
    procedure mnResourcesClick(Sender: TObject);
    procedure mnBenchReadClick(Sender: TObject);
    procedure mnBenchSpanClick(Sender: TObject);
    procedure mnSaveCurrentClick(Sender: TObject);
    procedure mnSpanCurrentClick(Sender: TObject);
    procedure mnListCurrentClick(Sender: TObject);
    // Experimental
    procedure mnJoSessionClick(Sender: TObject);
    procedure mnJoCancelClick(Sender: TObject);
    procedure mnJosekiClick(Sender: TObject);

    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
    Panel: TStatusPanel; const Rect: TRect);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure tmMemoryTimer(Sender: TObject);
    procedure mnTestEditingClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure mnTestTransClick(Sender: TObject);
    procedure TabSheetEnter(Sender: TObject);
    procedure TabSheetExit(Sender: TObject);
    procedure MainPageControlMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure FormDblClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure FormCanResize(Sender: TObject; var NewWidth,
    NewHeight: Integer; var Resize: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
    MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
    MousePos: TPoint; var Handled: Boolean);
    procedure PageControlDisableChanging(Sender: TObject;
    var AllowChange: Boolean);
    procedure mnTestGTPClick(Sender: TObject);
    procedure pmTab1Popup(Sender: TObject);
    procedure mnTutorClick(Sender: TObject);
    procedure mnJosekiIndexClick(Sender: TObject);
    procedure Create1Click(Sender: TObject);
    procedure mnFusekiSettingsClick(Sender: TObject);
    procedure mnJosekiSettingsClick(Sender: TObject);
    procedure MainPageControlMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
    procedure MainPageControlMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure mnDebugClick(Sender: TObject);
    procedure ApplicationEventsMessage(var Msg: tagMSG;
    var Handled: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure mnShowToolbarsClick(Sender: TObject);
    procedure mnShowTB_Click(Sender: TObject);
    procedure TntFormShow(Sender: TObject);
    procedure OneInstanceInstanceStarted(Sender: TObject;
      params: TStringList);
    procedure mnTestDiversClick(Sender: TObject);
    procedure MainPageControlDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure MainPageControlDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TntFormResize(Sender: TObject);
    procedure mnTestEngineClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MainPageControlChange(Sender: TObject);
    procedure mnFileClick(Sender: TObject);
  private
    TrayIcon : TCoolTrayIcon;
    CurrentViewMain  : TViewMain;
    CurrentViewBoard : TViewBoard;
    FullScreenToggler : TFullScreenToggler;
    procedure EnterTab         (tab : TTabSheetEx);
    procedure MenuMRUClick     (index : integer);
    procedure SetTabButtons;
    procedure WM_EndSession    (var msg : TWMEndSession); message WM_ENDSESSION;
    procedure WMDROPFILES      (var msg : TWMDROPFILES); message WM_DROPFILES;
    procedure WM_EXITSIZEMOVE  (var msg : TMessage); message WM_EXITSIZEMOVE;
    procedure WM_ENTERSIZEMOVE (var msg : TMessage); message WM_ENTERSIZEMOVE;
    procedure WM_SYSCOMMAND    (var msg : TWmSysCommand); message WM_SYSCOMMAND;
    procedure WM_GETMINMAXINFO (var msg : TWMGETMINMAXINFO); message wm_GetMinMaxInfo;
    procedure WMEraseBkgnd     (var msg : TWMEraseBkgnd); message  WM_ERASEBKGND;
    //procedure WMRButtonUp      (var Msg : TWMRButtonUp); message WM_RButtonUp;
    //procedure CMMouseEnter     (var msg: TMessage) ; message CM_MOUSEENTER;
    //procedure CMMouseLeave     (var msg: TMessage) ; message CM_MOUSELEAVE;
    procedure DoWithFormVisible(var msg : TMessage); message WM_USER+1;
    //procedure WndProc(var Message: TMessage); override;
    procedure ConfigureStatusBar;
    procedure StartLoading;
  public
    IniFile : TDragoIniFile;
    WaitCursor : integer;
    MRU_Tutor : TMRUList;
    TabButtonHandler : TTabButtonHandler;
    DBListOfTabs  : TListOfDBTabs;
    OnMessageRButtonUp : procedure;

    procedure Start;
    procedure RestoreWindow;
    procedure MainPanel_Lock;
    procedure MainPanel_Unlock;
    procedure UpdateMain;
    procedure UpdateViews;
    procedure UpdateBoards;
    procedure CreateTab(var ok : boolean);
    procedure CloseTab;
    procedure CreateView(tab : TTabSheetEx; viewMode : TViewMode);
    procedure SelectViewInner(tab : TTabSheetEx; viewMode : TViewMode);
    procedure SelectView(tab : TTabSheetEx; viewMode : TViewMode); overload;
    procedure SelectView(viewMode : TViewMode); overload;
    procedure InvalidateView(tab : TTabSheetEx; viewMode : TViewMode); overload;
    procedure InvalidateView(viewMode : TViewMode); overload;
    procedure WriteInStatusPanel(n : integer; s : WideString);
    procedure UpdateIniFile;
    procedure DoToggleFullScreen;
    //function  ToolButtonNumber(tb : TToolButton) : integer;
    procedure OnMessageBlocking(var Msg: TMsg; var Handled: Boolean);
    procedure BlockInput(x : boolean);
    function  IsOpenTab(tab : TTabSheetEx) : boolean;
    function  IsFileTab(tab : TTabSheetEx) : boolean;
    function  IsDirTab (tab : TTabSheetEx) : boolean;
    function  IsDBTab  (tab : TTabSheetEx) : boolean;

    function  GetPageCount : integer;
    function  GetActivePageIndex : integer;
    procedure SetActivePageIndex(i : integer);
    function  GetActivePage : TTabSheetEx;
    procedure SetActivePage(tab : TTabSheetEx);
    function  GetPage(i : integer) : TTabSheetEx;
    function  GetActiveView : TViewMain;
    function  GetActiveViewBoard : TViewBoard;
    property  PageCount : integer read GetPageCount;
    property  ActivePageIndex : integer read GetActivePageIndex write SetActivePageIndex;
    property  ActivePage : TTabSheetEx read GetActivePage write SetActivePage;
    property  Pages [i : integer] : TTabSheetEx read GetPage; default;
    property  ActiveView : TViewMain read GetActiveView write CurrentViewMain;
    property  ActiveViewBoard : TViewBoard read GetActiveViewBoard;
  end;

  TTabSheetEx = class(TTntTabSheet)
  private
    //function  GetCaption : WideString;
    //procedure SetCaption(s : WideString);
    //procedure SetImageIndex(i : integer);
  public
    ViewBoard : TViewBoard;
    ViewInfo  : TViewInfo;
    ViewThumb : TViewThumb;
    TabView   : TViewMain;      // current(board, info or thumb)

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    GetContext : TContext;

    property cx : TContext read GetContext;
    //property Caption : WideString read GetCaption write SetCaption;
    //property ImageIndex : integer write SetImageIndex;
  end;

  TListOfDBTabs = class
  private
    FList : TList;
  public
    OnChange : procedure(list : TStringlist) of object;
    constructor Create;
    destructor Destroy; override;
    procedure Push(obj : TObject);
    procedure Remove(obj : TObject);
    procedure Promote(caption : string);
    function Top : TObject;
    function Registered(tab : TTabSheetEx) : boolean;
    function ListOfCaptions : TStringList;
  end;

 var
  fmMain : TfmMain;
  MaximizedRect : TRect;

  LastActiveViewBoard : TViewBoard = nil;

procedure CallbackShowMove(i, j, num : integer);

// ---------------------------------------------------------------------------

implementation

uses
  Dialogs,
  Std, WinUtils, VclUtils, Ugcom, Translate, UMainUtil, UDialogs,
  Define,
  UProblems,
  UfmDebug, UEngines,
  SgfIo, UfmMsg, UGameTree, UfmOptions,
  UPrintStyles,
  UTreeView, Ugmisc, 
  UfmExportPos, UfmFreeH,
  UErrorHandler,
  UDatabase, UfmDBSearch,
  UStatusMain, UfmTesting,
  UfmGtp, UfmTest;

{$R *.DFM}

// -- Helpers for MainPageControl --------------------------------------------

function TfmMain.GetActivePageIndex : integer;
begin
  Result := MainPageControl.ActivePageIndex
end;

procedure TfmMain.SetActivePageIndex(i : integer);
begin
  MainPageControl.ActivePageIndex := i
end;

function TfmMain.GetPageCount : integer;
begin
  Result := MainPageControl.PageCount
end;

function TfmMain.GetActivePage : TTabSheetEx;
begin
  Result := MainPageControl.ActivePage as TTabSheetEx;
  //TODO : pagecontrol check :
  if Result = nil
    then MainPageControl.ActivePage := Pages[0]
end;

procedure TfmMain.SetActivePage(tab : TTabSheetEx);
begin
  MainPageControl.ActivePage := tab
end;

function TfmMain.GetPage(i : integer) : TTabSheetEx;
begin
  Result := MainPageControl.Pages[i] as TTabSheetEx
end;

// -- Implementation TTabSheetEx ---------------------------------------------

constructor TTabSheetEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  PageControl := AOwner as TPageControl;
  Font.Name   := 'Tahoma';
  ParentColor := True
end;

(*
function TTabSheetEx.GetCaption : WideString;
begin
  Result := inherited Caption
end;

procedure TTabSheetEx.SetCaption(s : WideString);
begin
  inherited Caption := s
end;

procedure TTabSheetEx.SetImageIndex(i : integer);
begin
  inherited ImageIndex := i
end;
*)

destructor TTabSheetEx.Destroy;
begin
  TabView.Context.Free;

  // free all views
  FreeAndNil(ViewBoard);
  FreeAndNil(ViewInfo);
  FreeAndNil(ViewThumb);

  inherited Destroy
end;

function TTabSheetEx.GetContext : TContext;
begin
  Result := ViewBoard.cx
end;

// -- Starting sequence ------------------------------------------------------

procedure TfmMain.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  Trayicon := TCoolTrayIcon.Create(Self);

  with TrayIcon do
    begin
      Hint := 'Drago';
      MinimizeToTray := True;
      ShowFormOnTrayIconClick := True;
      PersistentTrayIcon := False;
      PopupMenu := pmTrayIcon
    end;

  FullScreenToggler := TFullScreenToggler.Create
end;

procedure TfmMain.Start;
var
  cr : LongWord;
  ok : boolean;
  filename : string;
begin
  // alloc and init context (use GetLocalAppData if needed)
  IniFile := TDragoIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  //IniFile := TDragoIniFile.Create(GetCommonAppData + '\Drago.ini');
  Status.Default;
  CurrentViewMain  := nil;
  CurrentViewBoard := nil;

  // general global settings
  BorderStyle      := bsSizeable;
  AutoScroll       := False;
  DecimalSeparator := '.';
  Randomize;
  Graphics.DefFontData.Name := 'Tahoma';

  // fight against flickering
  DoubleBuffered   := True;
  MainPageControl.DoubleBuffered := True;
  StatusBar.DoubleBuffered := True;
  // see WM_ENTERSIZEMOVE for toolbar double buffering

  // load waiting cursor
  cr := LoadCursorFromFile(GetWindowsDirectory + '\cursors\hourgla3.ani');
  if cr = 0
    then WaitCursor := crHourGlass
    else
      begin
        Screen.Cursors[crWaiting] := cr;
        WaitCursor := crWaiting
      end;

  // load export cursor
  Screen.Cursors[crZone] := LoadCursor(HInstance, 'REDCRSS');

  // configure status bar
  ConfigureStatusBar;

  // hide Delphi/Tnt main menu, Menu := MainMenu to show
  //Menu := nil;
  ActionsWithShortcut.Visible := False;

  // hide MRU menus until set by MRU
  mnFile1.Visible := False;
  mnFile2.Visible := False;
  mnFile3.Visible := False;
  mnFile4.Visible := False;

  // hide wilcard action until pattern search
  Actions.acWildcard.Visible := False;

  // init MRU list for joseki tutor, read in LoadIniFile
  MRU_Tutor := TMRUList.Create;
  MRU_Tutor.DistinguishPath := True;

  // remove some navigation buttons (effective only for a first install)
  with toolbarNavigation do
    begin
      Items.Remove(tbPrevTarget);
      Items.Remove(tbNextTarget);
      Items.Remove(tbAutoReplay);
    end;

  // possibly update configuration and load settings
  Settings.UpdateIniFile(IniFile);
  Settings.LoadIniFile(IniFile);
  StatusMain.LoadIniFile(IniFile);

  // convert relative paths to absolute
  // does nothing if already absolute
  ConvertRelativePathsToAbsolute;

  // control some menus visibility
  mnJoseki.Visible     := False;
  mnLibrary.Visible    := Status.RunFromIDE;
  mnMakeGameTree.Visible := True;
  mnDebug.Visible      := Status.RunFromIDE;
  mnTestEngine.Visible := Status.RunFromIDE;

  // create tab close button handler
  SetTabButtons;

  // force display of MRU list
  if Settings.MRUList.Count > 0
    then SetMRU(Settings.MRUList[0].Folder, Settings.MRUList[0].Name);

  // creation of list of database tabs
  DBListOfTabs := TListOfDBTabs.Create;

  // game tree view initialization
  InitTreeViewModule;

  // load translation(before opening files, for error messages)
  SetLanguage(Settings.Language, ok, filename);
  if not ok
    then ShowMessage('File ' + filename + ' not found. No translation.');
  MainTranslate;
  Application.HelpFile := Status.AppPath + T(HlpFile);

  // apply application settings
  OneInstance.Active := StatusMain.OneInstance;
  TrayIcon.MinimizeToTray := StatusMain.MinimizeToTray;

  // apply loading file strategy
  StartLoading;

  if StatusMain.Maximized then
    begin
      WindowState := wsMaximized;
      StatusMain.Maximized := False
    end
end;

procedure TfmMain.OneInstanceInstanceStarted(Sender: TObject;
                                             params: TStringList);
var
  i : integer;
begin
  TrayIcon.ShowMainForm;
  for i := 0 to params.Count - 1 do
    DoMainOpen(params[i])
end;

procedure TfmMain.RestoreWindow;
begin
  TrayIcon.ShowMainForm
end;

// Status bar settings

procedure TfmMain.ConfigureStatusBar;
begin
  with StatusBar do
    begin
      // create 7 fields in status bar
      Panels.Add;
      Panels.Add;
      Panels.Add;
      Panels.Add;
      Panels.Add;
      Panels.Add;
      Panels.Add;

      // setting required for large fonts
      ClientHeight := Canvas.TextHeight('A') + 6;

      Panels[sbGameNumber].Width := Canvas.TextWidth(' 99999 / 99999 ');
      Panels[sbLastMove  ].Width := Canvas.TextWidth(' 999 mm A19 ');
      Panels[sbIgnored   ].Width := 100;
      Panels[sbReadOnly  ].Width := 22;
      Panels[sbGlyph     ].Width := 22;
      Panels[sbAnnotation].Width := 150;
      Panels[sbMoveStatus].Width := 150;

      Panels[sbGameNumber].Style := psText;
      Panels[sbLastMove  ].Style := psText;
      Panels[sbIgnored   ].Style := psOwnerDraw;
      Panels[sbReadOnly  ].Style := psOwnerDraw;
      Panels[sbGlyph     ].Style := psOwnerDraw;
      Panels[sbAnnotation].Style := psOwnerDraw;
      Panels[sbMoveStatus].Style := psOwnerDraw;

      Panels[sbGameNumber].Alignment := taCenter;
      Panels[sbLastMove  ].Alignment := taCenter;
    end
end;

// Loading file strategy

procedure TfmMain.StartLoading;
var
  i : integer;
begin
  // load last open files if required
  // - OpenLast must be true
  // - if one instance only         load files
  // - if several instances allowed load files only if first instance
  if Settings.OpenLast and (StatusMain.OneInstance or OneInstance.IsFirstInstance)
    then StatusMain.LoadTabs(IniFile);

  for i := 1 to ParamCount do
    DoMainOpen(ParamStr(i));

  // keep always one tab
  if PageCount = 0
    then DoMainNewDefaultFile(False);

  fmMain.SelectView(vmBoard)
end;

// -- Display of error messages when form visible ----------------------------
//
// process in OnShow not sufficient,
// tip from www.developpez.net/forums/showthread.php?t=469727&page=2

procedure TfmMain.TntFormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_USER+1, 0, 0);
end;

procedure TfmMain.DoWithFormVisible(var msg : TMessage); {message WM_USER+1;}
begin
  DisplayErrorMessages
end;

// -- Enabling of shortcuts with edit key (when coming from another form) ----

procedure TfmMain.FormActivate(Sender: TObject);
begin
  Actions.EnableEditShortcuts(True)
end;

// -- Update of interface (used after Options dialog) ------------------------

procedure TfmMain.UpdateMain;
var
  ok : boolean;
  filename : string;
begin
  // translate Main
  SetLanguage(Settings.Language, ok, filename);
  if not ok
    then ShowMessage('File ' + filename + ' not found. No translation.');
  MainTranslate;
  Application.HelpFile := Status.AppPath + T(HlpFile);

  // apply application settings
  OneInstance.Active := StatusMain.OneInstance;
  TrayIcon.MinimizeToTray := StatusMain.MinimizeToTray;

  // translate fmFreeH
  if UfmFreeH.IsOpen
    then fmFreeH.Translate;

  // translate fmExportPos
  if TfmExportPos.IsOpen
    then fmExportPos.Translate(Settings);

  // update fmExportPos thumbnail
  if TfmExportPos.IsOpen then
    with fmExportPos do
      Capture(mygb.iMinView, mygb.jMinView, mygb.iMaxView, mygb.jMaxView);

  // update stones for tree views
  TV_CreateStones(Settings);

  // update of all views (possibly delayed)
  UpdateViews;

  // update tab buttons
  SetTabButtons
end;

procedure TfmMain.SetTabButtons;
begin
  if Settings.TabCloseBtn
    then
      if Assigned(TabButtonHandler)
        then // nop
        else
          begin
            TabButtonHandler := TTabButtonHandler.Create(MainPageControl,
                                                         TabImages,
                                                         TabBtnImages,
                                                         BtnImages);
            TabButtonHandler.Action := Actions.acClose
          end
    else
      if Assigned(TabButtonHandler)
        then
          begin
            TabButtonHandler.RemoveButtonsFromTabImageList;
            FreeAndNil(TabButtonHandler)
          end
        else // nop
end;

procedure TfmMain.UpdateBoards;
var
  i : integer;
begin
  // delayed update of all boards
  for i := 0 to PageCount - 1 do
    with Pages[i] do
      if ViewBoard <> nil
        then ViewBoard.ToBeUpdated := True;

  // update current board
  ActiveView.UpdateView
end;

procedure TfmMain.UpdateViews;
var
  i : integer;
begin
  // delayed update of all views
  for i := 0 to PageCount - 1 do
    with Pages[i] do
      begin
        if ViewBoard <> nil
          then ViewBoard.ToBeUpdated := True;
        if ViewInfo <> nil
          then ViewInfo.ToBeUpdated := True;
        if ViewThumb <> nil
          then ViewThumb.ToBeUpdated := True
      end;

  // update current view
  ActivePage.TabView.DoWhenShowing
end;

// -- Tab creation -----------------------------------------------------------

procedure TfmMain.CreateTab(var ok : boolean);
var
  tab : TTabSheetEx;
  view : TViewBoard;
begin
  // create new tab in main PageControl
  try
    tab := TTabSheetEx.Create(MainPageControl)
  except
    MessageDialog(msOk, imExclam, [U('Unable to create tab')]);
    ok := False;
    exit
  end;

  // create game view and attach it to tab
  LastActiveViewBoard := ActiveViewBoard;
  try
    view := TViewBoard.Create(tab, tab, nil);
    view.Context := TContext.Create;
    view.ToBeUpdated := True;
    view.si.ObservedSetModeInter[0] := UActions.SetModeInter
  except
    tab.Free;
    MessageDialog(msOk, imExclam, [U('Unable to create tab')]);
    ok := False;
    exit
  end;

  // link from page to view
  tab.ViewBoard := view;
  tab.ViewInfo  := nil;
  tab.ViewThumb := nil;
  tab.TabView   := view;
  //tab.OnShow    := TabSheetEnter; appelé dans PAgeChange
  tab.OnExit    := TabSheetExit;
  tab.Caption   := '';

  // start new view
  view.Start;

  // set new view as main context
  CurrentViewMain  := view;
  CurrentViewBoard := view;

  // start new view
  //view.Start;

  // init as board
  view.si.ViewMode := vmBoard;

  // set active page
  if MainPageControl.Visible
    then ActivePage := tab;

  ok := True
end;

// -- Tab closing ------------------------------------------------------------

procedure TfmMain.CloseTab;
var
  tab : TTabSheetEx;
begin
  // update list of DB tabs
  if IsDBTab(ActivePage)
    then DBListOfTabs.Remove(ActivePage);

  // stop game engine if any
  StopEngine(ActiveViewBoard);

  // save path when joseki tutor
  if ActiveView.si.ModeInter = kimTU
    then DoCloseJosekiTutor(ActiveViewBoard);

  // free tab
  tab := ActivePage;
  if ActivePageIndex < PageCount - 1
    then ActivePage := Pages[ActivePageIndex + 1]
    else ActivePage := Pages[ActivePageIndex - 1];
  tab.Free;

  // zero page should not occur
  if PageCount = 0
    then
      begin
        CurrentViewMain  := nil;
        CurrentViewBoard := nil
      end
    else TabSheetEnter(ActivePage)
end;

// -- Tab activation ---------------------------------------------------------

procedure TfmMain.TabSheetEnter(Sender : TObject);
var
  i : integer;
begin
  (Sender as TTabSheetEx).TabView.EnterView;
  EnterTab(Sender as TTabSheetEx);

  for i := 0 to PageCount - 1 do
    if Pages[i] <> Sender
      then //Pages[i].TabView.ExitView
end;

procedure TfmMain.TabSheetExit(Sender : TObject);
var
  tab : TTabSheet;
begin
  (Sender as TTabSheetEx).TabView.ExitView;
  tab := Sender as TTabSheet;
  //Caption := Format('Active page: %d', [tab.PageIndex]);
  if (Sender as TTabSheetEx).TabView.si.DbQuickSearch = qsReady
    then (Sender as TTabSheetEx).TabView.si.DbQuickSearch := qsOpen
end;

procedure TfmMain.EnterTab(tab : TTabSheetEx);
begin
  // entering in db tab
  if IsDBTab(tab) then
    begin
      // coming from another db tab
      if tab <> DBListOfTabs.Top then
        if Assigned(fmDBSearch) and (fmDBSearch.btSearch.Enabled = False)
          then
            begin
              // coming from another db tab while searching: return to search
              // db tab and leave
              ActivePage := DBListOfTabs.Top as TTabSheetEx;
              Application.ProcessMessages;
              exit
            end
          else DoResetDatabase;

      // update list of DB tabs
      DBListOfTabs.Push(tab);

      // refresh player list in search form
      if Assigned(fmDBSearch) and IsDBTab(tab) then
        with fmDBSearch do
          if (FSearchMode = smInfo) and
            (DBSearchContext.DBTab <> tab)
            then frDBRequestPanel.DoWhenUpdating
    end;

  // update context
  CurrentViewMain  := tab.TabView;
  CurrentViewBoard := tab.ViewBoard;

  // select view
  SelectView(tab, ActiveView.si.ViewMode);

  // refresh statusbar
  ActiveView.ReApplyNode;

  // force focus on goban (and avoid focus on edNodeName if any)
  ActiveViewBoard.SetFocusOnGoban;

  // set dbsearch open flag, used in ApplyNode to clear search markers
  ActiveView.si.DbSearchOpen := Assigned(fmDBSearch);
  Actions.acQuickSearch.Checked := ActiveView.si.DbQuickSearch in [qsOpen, qsReady];

  // refresh read only icon
  ActiveView.si.ReadOnly := ActiveView.si.ReadOnly
end;

// -- Content of tab ---------------------------------------------------------

function TfmMain.IsFileTab(tab : TTabSheetEx) : boolean;
begin
  Result := not (IsDirTab(tab) or IsDBTab(tab))
end;

function TfmMain.IsDirTab(tab : TTabSheetEx) : boolean;
begin
  Result := tab.TabView.si.FolderName <> ''
end;

function TfmMain.IsDBTab(tab : TTabSheetEx) : boolean;
begin
  Result := tab.TabView.kh <> nil
end;

// -- View Control -----------------------------------------------------------

procedure TfmMain.MainPageControlChange(Sender: TObject);
var
  handled : boolean;
begin
  //CurrentViewMain := (MainPageControl.ActivePage as TTabSheetEx).TabView;
  //Caption := Format('Active page: %d', [MainPageControl.ActivePageIndex]);
  TabSheetEnter(MainPageControl.ActivePage);
  Actions.acEnterTabExecute(Sender);
  Actions.ActionListExecute(Actions.acEnterTab, handled)
end;

function TfmMain.GetActiveView : TViewMain;
begin
  //Result := CurrentViewMain
  //Caption := Format('Active page: %d', [MainPageControl.ActivePageIndex]);
  Result := (MainPageControl.ActivePage as TTabSheetEx).TabView
end;

function TfmMain.GetActiveViewBoard : TViewBoard;
begin
  //Result := CurrentViewBoard
  Result := (MainPageControl.ActivePage as TTabSheetEx).ViewBoard
end;

// -- Creation of view

procedure TfmMain.CreateView(tab : TTabSheetEx; viewMode : TViewMode);
begin
  with tab do
    case viewMode of
      vmBoard :
        {nop}; // ViewBoard created with tab
      vmInfo, vmInfoPb, vmInfoGm :
        if ViewInfo = nil
          then ViewInfo := TViewInfo.Create(tab, tab, tab.ViewBoard.Context);
      vmThumb :
        if ViewThumb = nil
          then ViewThumb := TViewThumb.Create(tab, tab, tab.ViewBoard.Context);
    end;
end;

// -- Selection of view

procedure TfmMain.SelectView(viewMode : TViewMode);
begin
  SelectView(ActivePage, viewMode)
end;

procedure TfmMain.SelectView(tab : TTabSheetEx; viewMode : TViewMode);
begin
  try
    LockControl(tab, True);
    SelectViewInner(tab, viewMode)
  finally
    LockControl(tab, False)
  end
end;

procedure TfmMain.SelectViewInner(tab : TTabSheetEx; viewMode : TViewMode);
begin
  // avoid to open board or thumb views if no games
  if (viewMode in [vmBoard, vmThumb]) and (tab.ViewBoard.cl.Count = 0)
    then exit;

  with tab do
    begin
      // update view mode
      cx.si.ViewMode := viewMode;

      // update enabling mode
      if TfmExportPos.IsOpen
        then cx.si.EnableMode := mdExpo
        else
          case viewMode of
            vmBoard :
              case cx.si.MainMode of
                muNavigation, muModification :
                  cx.si.EnableMode := mdEdit;
                muProblem, muFree :
                  cx.si.EnableMode := mdProb;
                muReplayGame :
                  cx.si.EnableMode := mdGame;
                muEngineGame :
                  cx.si.EnableMode := mdPlay;
              end;
            vmInfo, vmInfoPb, vmInfoGm :
              cx.si.EnableMode := mdInfoView;
            vmThumb :
              cx.si.EnableMode := mdThumbView
          end;

      // hide current view if already allocated
      if TabView <> nil then
        begin
          // avoid calling TabSheetExit (because of visibility behaviour)
          OnExit := nil;
          TabView.Visible := False;
          OnExit := TabSheetExit
        end;

      // allocate if required
      CreateView(tab, cx.si.ViewMode);

      // set current view
      case cx.si.ViewMode of
        vmBoard :
          TabView := ViewBoard;
        vmInfo, vmInfoPb, vmInfoGm :
          TabView := ViewInfo;
        vmThumb :
          TabView := ViewThumb;
      end;
      CurrentViewMain := TabView;
      cx.si.ParentView := TabView; // important

      // info view is always updated when selected
      if viewMode in [vmInfo, vmInfoPb, vmInfoGm]
        then TabView.ToBeUpdated := True;

      // show current view
      TabView.Visible := True;
      TabView.DoWhenShowing;

      // force view to be updated for next info mode
      if viewMode in [vmInfoPb, vmInfoGm]
        then TabView.ToBeUpdated := True;

      // configure view for possible export position mode
      TabView.SetExportPositionMode(TfmExportPos.IsOpen);

      if Assigned(fmDBSearch) and (Assigned(fmDBSearch.frDBRequestPanel) or
                                   Assigned(fmDBSearch.frDBSignaturePanel))
        and (cx.si.DbQuickSearch in [qsOpen, qsReady])
        then ViewBoard.ExitQuickSearch
    end
end;

// -- Invalidation of view

procedure TfmMain.InvalidateView(tab : TTabSheetEx; viewMode : TViewMode);
begin
  with tab do
    case viewMode of
      vmBoard :
        ViewBoard.ToBeUpdated := True;
      vmInfo, vmInfoPb, vmInfoGm :
        if ViewInfo <> nil
          then ViewInfo.ToBeUpdated := True;
      vmThumb :
        if ViewThumb <> nil
          then ViewThumb.ToBeUpdated := True;
      vmAll :
        begin
          InvalidateView(tab, vmBoard);
          InvalidateView(tab, vmInfo);
          InvalidateView(tab, vmThumb);
        end
    end
end;

procedure TfmMain.InvalidateView(viewMode : TViewMode);
begin
  InvalidateView(ActivePage, viewMode)
end;

// -- Event handler used to disable page change during free handicap setting -

procedure TfmMain.PageControlDisableChanging(Sender: TObject;
                                              var AllowChange: Boolean);
begin
  AllowChange := False
end;

// -- PageControl helpers ----------------------------------------------------

function TfmMain.IsOpenTab(tab : TTabSheetEx) : boolean;
var
  i : integer;
begin
  Result := True;

  for i := 0 to PageCount - 1 do
    if Pages[i] = tab
      then exit;

  Result := False
end;

// -- Tab bar events ---------------------------------------------------------

procedure TfmMain.MainPageControlMouseMove(Sender: TObject;
                                        Shift: TShiftState;
                                        X, Y: Integer);
begin
  if Assigned(TabButtonHandler)
    then TabButtonHandler.MouseMove(Shift, X, Y)
end;

// -- Single click on tab

procedure TfmMain.MainPageControlMouseDown(Sender: TObject;
                                        Button: TMouseButton;
                                        Shift: TShiftState; X, Y: Integer);
var
  rect : TRect;
  point : TPoint;
begin
  if Button = mbRight
    then
      begin
        rect := MainPageControl.TabRect(ActivePageIndex);
        point.x := X;
        point.y := Y;
        if not PtInRect(rect, point)
          then exit;
        point := MainPageControl.ClientToScreen(point);
        pmTab1.Popup(point.x, point.y)
      end
    else
      begin
        if Assigned(TabButtonHandler) and TabButtonHandler.IsOnButton(X, Y)
          then TabButtonHandler.MouseDown(Shift, X, Y)
          else MainPageControl.BeginDrag(False)
      end
end;

procedure TfmMain.MainPageControlMouseUp(Sender: TObject;
                                      Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(TabButtonHandler)
    then TabButtonHandler.MouseUp(Shift, X, Y)
end;

procedure TfmMain.pmTab1Popup(Sender: TObject);
begin
  with ActivePage.TabView do
    begin
      mnNewInTab.Enabled  := si.MainMode in [muNavigation, muModification];
      mnOpenInTab.Enabled := mnNewInTab.Enabled
    end
end;

// -- Tab reordering
//
// http://delphi.about.com/cs/adptips2004/a/bltip0304_3.htm

procedure TfmMain.MainPageControlDragDrop(Sender, Source: TObject;
                                           X, Y: Integer);
var
  rect : TRect;
  j : Integer;
begin
  TabButtonHandler.Action := Actions.acClose;

  for j := 0 to MainPageControl.PageCount - 1 do
    begin
      rect := MainPageControl.TabRect(j);

      if PtInRect(rect, Point(X, Y)) then
        begin
          if MainPageControl.ActivePage.PageIndex <> j
            then MainPageControl.ActivePage.PageIndex := j;
          exit
        end
    end
end;

procedure TfmMain.MainPageControlDragOver(Sender, Source: TObject;
                                          X, Y: Integer;
                                          State: TDragState;
                                          var Accept: Boolean);
begin
  TabButtonHandler.Action := nil;
  Accept := True
end;

// -- Single click on tab bar outside captions

procedure TfmMain.FormMouseDown(Sender: TObject;
                                Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
var
  point : TPoint;
begin
  if Button = mbRight then
    begin
      point.x := X;
      point.y := Y;
      point := ClientToScreen(point);
      pmTab2.Popup(point.x, point.y)
    end
end;

// -- Double click on tab bar where no tab

procedure TfmMain.FormDblClick(Sender: TObject);
begin
  UserMainNewFile(False)
end;

// -- Full screen mode -------------------------------------------------------

procedure TfmMain.DoToggleFullScreen;
begin
  FullScreenToggler.Execute
end;

// -- Error handler ----------------------------------------------------------

procedure TfmMain.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  ApplicationErrorHandler(Sender, E)
end;

// -- Message handler --------------------------------------------------------

procedure TfmMain.ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  case Msg.message of
    WM_RBUTTONUP :
      if Assigned(OnMessageRButtonUp)
        then OnMessageRButtonUp;
  end
end;

// this one doesn't work... why?

(*
procedure TfmMain.WMRButtonUp(var msg : TWMRButtonUp);
begin
  if Assigned(OnMessageRButtonUp)
    then OnMessageRButtonUp
end;
*)

// -- OnMessage handler blocking keyboard and mouse --------------------------
// -- not used

procedure TfmMain.OnMessageBlocking(var Msg: TMsg; var Handled: Boolean);
begin
  case msg.Message of
    WM_KEYFIRST .. WM_KEYLAST, WM_MOUSEFIRST .. WM_MOUSELAST:
      Handled := True
  end
end;

procedure TfmMain.BlockInput(x : boolean);
begin
  if x
    then Application.OnMessage := OnMessageBlocking
    else Application.OnMessage := nil
end;

// -- Mouse events -----------------------------------------------------------

procedure TfmMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
                                     MousePos: TPoint; var Handled: Boolean);
begin
  with ActivePage do
    case cx.si.ViewMode of
      vmBoard :
        ActiveViewBoard.frViewBoard.FrameMouseWheelDown(Sender, Shift, MousePos, Handled);
      vmInfo : ;
      vmThumb :
        ViewThumb.frPreviewThumb.FrameMouseWheelDown(Sender, Shift, MousePos, Handled);
    end
end;

procedure TfmMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
                                   MousePos: TPoint; var Handled: Boolean);
begin
  with ActivePage do
    case cx.si.ViewMode of
      vmBoard :
        ActiveViewBoard.frViewBoard.FrameMouseWheelUp(Sender, Shift, MousePos, Handled);
      vmInfo : ;
      vmThumb :
        ViewThumb.frPreviewThumb.FrameMouseWheelUp(Sender, Shift, MousePos, Handled);
    end
end;

// -- Resizing events --------------------------------------------------------

procedure TfmMain.WM_SYSCOMMAND(var msg : TWmSysCommand);
var
  right, bottom : integer;
begin
  if (msg.cmdtype and $FFF0) = SC_RESTORE
    then
      begin
        WindowState := wsNormal;
        msg.result := 0;
        if StatusMain.FirstRestore then
          begin
            Left   := NthInt(StatusMain.FmMainPlace,  7, ',');
            Top    := NthInt(StatusMain.FmMainPlace,  8, ',');
            right  := NthInt(StatusMain.FmMainPlace,  9, ',');
            bottom := NthInt(StatusMain.FmMainPlace, 10, ',');
            SetBounds(Left, Top, right - Left + 1, bottom - Top + 1);
            StatusMain.FirstRestore := False;
          end
      end
    else
      inherited
end;

// -- Dimension limit message

procedure TfmMain.WM_GETMINMAXINFO(var msg : TWMGETMINMAXINFO);
begin
// not used
(*
  with msg.minmaxinfo^ do
    with MaximizedRect do
      begin
        Left   := ptmaxposition.x;
        Top    := ptmaxposition.y;
        Right  := ptmaxsize.x;
        Bottom := ptmaxsize.y
      end
*)
end;

// -- Entering sizing or moving mode message

procedure TfmMain.WM_ENTERSIZEMOVE(var msg : TMessage);
begin
  inherited;

  // when double buffered when starting, the buttons keep white and change to
  // grey only when resizing. As it seems there is no way to fix that (with
  // invalidate, repaint, ...), it is better to double buffer here.
  (*
  toolbarFile      .DoubleBuffered := True;
  toolbarNavigation.DoubleBuffered := True;
  toolbarEdit      .DoubleBuffered := True;
  toolbarMisc      .DoubleBuffered := True;
  *)

  if Settings.HookContent
    then exit
    else
      with ActivePage do
        TabView.AlignToClient(False)
end;

// -- Exiting sizing or moving mode message

procedure TfmMain.WM_EXITSIZEMOVE(var msg : TMessage);
begin
  inherited;

  if Settings.HookContent
    then exit
    else
      with ActivePage do
        TabView.AlignToClient(True)
end;

// see http://www.ibrtses.com/delphi/imageflicker.html
procedure TfmMain.WMEraseBkgnd(var msg : TWMEraseBkgnd);
begin
  msg.result := 1
end;

// -- Resizing limits

procedure TfmMain.FormCanResize(Sender: TObject;
                      var NewWidth, NewHeight: Integer;
                      var Resize: Boolean);
begin
  if PageCount = 0
    then exit // Resize := False
    else Resize := (NewWidth > 400) and (NewHeight > 300)
end;

procedure TfmMain.TntFormResize(Sender: TObject);
begin
  with StatusBar do
    begin
      Panels[sbAnnotation].Width := ClientWidth - Panels[sbGameNumber].Width
                                                - Panels[sbLastMove].Width
                                                - Panels[sbIgnored].Width
                                                - Panels[sbGlyph].Width
                                                - Panels[sbMoveStatus].Width
    end
end;

// -- Main panel handling ----------------------------------------------------

// -- Locking of main panel (?) to avoid flickering (currently not used)

var
  MainPanel_LockNum : integer = 0;

procedure TfmMain.MainPanel_Lock;
begin
  if MainPanel_LockNum = 0
    then LockWindowUpdate(Handle);

  inc(MainPanel_LockNum)
end;

procedure TfmMain.MainPanel_Unlock;
begin
  dec(MainPanel_LockNum);

  if MainPanel_LockNum = 0
    then LockWindowUpdate(0)
end;

// -- Main form update -------------------------------------------------------
//
// At one time, TV_Refresh has been used to avoid a bad effect in the TreeView
// (commented since 1.40)

procedure TfmMain.FormPaint(Sender: TObject);
begin
  //TV_Refresh(gb, gt, st)
  ControlStyle := ControlStyle + [csOpaque];
  StatusBar.Repaint;
end;

// -- Status bar drawing event (to display centered or bold) -----------------

procedure TfmMain.StatusBarDrawPanel(StatusBar : TStatusBar;
                                     Panel     : TStatusPanel;
                                     const Rect: TRect);
var
  wPanel : TTntStatusPanel;
  glyph : integer;
begin
  wPanel := Panel as TTntStatusPanel;

  with self.StatusBar do
    begin
      // erase panel
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect);

      if wPanel = Panels[sbIgnored] then
        begin
          if wPanel.Text <> ''
            then
              begin
                Canvas.Font.Style := [];
                WideCanvasTextOut(Canvas, Rect.Left, Rect.Top, wPanel.Text)
              end
        end;

      if wPanel = Panels[sbGlyph] then
        begin
          glyph := 0;
          if wPanel.Text = 'Annotation'
            then glyph := 38;
          if wPanel.Text = 'Pass'
            then glyph := 61;
          if wPanel.Text = 'ScoreEstimate'
            then glyph := 55;
          if wPanel.Text = 'SuggestMove'
            then glyph := 72;
          if wPanel.Text = 'GroupStatus'
            then glyph := 111;

          if glyph > 0
            then Actions.ImageList.Draw(self.StatusBar.Canvas, Rect.Left, Rect.Top, glyph)
        end;

      if wPanel = Panels[sbReadOnly] then
        begin
          glyph := 0;
          if wPanel.Text = 'ReadOnly'
            then glyph := 68;

          if glyph > 0
            then Actions.ImageList.Draw(self.StatusBar.Canvas, Rect.Left, Rect.Top, glyph)
        end;

      if wPanel = Panels[sbAnnotation] then
        begin
          Canvas.Font.Style := [];
          WideCanvasTextOut(Canvas, Rect.Left, Rect.Top, wPanel.Text)
        end;

      if wPanel = Panels[sbMoveStatus] then
        begin
          StatusBarDrawGameInfo(StatusBar, Panel, Rect);
        end
    end
end;

procedure TfmMain.WriteInStatusPanel(n : integer; s : WideString);
begin
  StatusBar.Panels[n].Text := s;
  //StatusBar.Repaint
end;

// -- Callback functions to display move numbers in status bar ---------------
//
// Used by TGoban to display a move number when there is a markup
// Display only last move

procedure CallbackShowMovePrint(i, j, num : integer);
begin
  with fmMain do
    begin
      StatusBar.Panels[sbAnnotation].Text := U(ActiveView.gb.OverMoveString)
    end
end;

procedure CallbackShowMove(i, j, num : integer);
var
  s : WideString;
begin
  with fmMain.ActiveView do
    if gb.ShowMoveMode = smBook
      then CallbackShowMovePrint(i, j, num)
      //then s := U(gb.OverMoveString)
      else
        begin
          s := WideFormat(U('%d at %s'),
                          [num, CoordString(i, j, gb.BoardSize,
                                            Settings.CoordStyle < 2)]);
        end;

  fmMain.StatusBar.Panels[sbLastMove].Text := s
end;

// -- Keyboard handling ------------------------------------------------------

// -- Data for easter eggs

const
  // first letter must be unique
  sEgg1 = 'DBG'; // show debug menu
  sEgg2 = 'GTP'; // show gtp console
  sEgg3 = 'MEM'; // show memory
  sEgg4 = 'BUG'; // cause an error
  sEgg5 = 'SHC'; // display a menu with all shortcuts
  sEgg6 = 'RPS'; // reset print settings for current language

var
  nEgg : integer = 1;
  sEgg : string  = '';

// -- Key down event
//
// Warning : if one of the codes does not trigger, close all applications. One
// of them could trap the ctr-shift-key. This is the case with ZenCoding in
// Notepad++ which traps ctrl-shift-a and ctrl-shift-d.

procedure TfmMain.FormKeyDown(Sender: TObject; var Key: Word;
                              Shift: TShiftState);
begin
  // waiting for Ctrl-Shift-XXX
  if Shift = [ssCtrl, ssShift]
    then
      if nEgg = 1
        then
          case Key of
            ord('D') : begin sEgg := sEgg1; nEgg := 2 end;
            ord('G') : begin sEgg := sEgg2; nEgg := 2 end;
            ord('M') : begin sEgg := sEgg3; nEgg := 2 end;
            ord('B') : begin sEgg := sEgg4; nEgg := 2 end;
            ord('S') : begin sEgg := sEgg5; nEgg := 2 end;
            ord('R') : begin sEgg := sEgg6; nEgg := 2 end;
          end
        else
          if Key <> ord(sEgg[nEgg])
            then nEgg := 1
            else
              if nEgg < Length(sEgg)
                then inc(nEgg)
                else
                  begin
                    nEgg := 1;
                    if sEgg = sEgg6
                      then
                        begin
                          CreatePrintIniFile(IniFile);
                          Settings.LoadIniFile(IniFile);
                          StatusMain.LoadIniFile(IniFile)
                        end
                      else DoDebug(sEgg)
                  end
end;

// -- Close event ------------------------------------------------------------

// not used
procedure TfmMain.WM_EndSession(var msg : TWMEndSession);
begin
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  cancel : boolean;
  i : integer;
  view : TViewBoard;
begin
  VerifyAndSaveAllViews(cancel);
  CanClose := not cancel;

  if cancel
    then exit;

  for i := 0 to PageCount - 1 do
    begin
      view := Pages[i].ViewBoard;
      assert(view <> nil);

      if (view <> nil) and (view.si.MainMode in [muProblem, muFree])
        then PbLeave(view);

      if (view <> nil) and (view.si.MainMode = muReplayGame)
        then GmLeave(view);

      if (view <> nil) and (view.gtp <> nil) then
        begin
          view.gtp.Stop(nil);
          WaitWhileGtpActive(view.gtp)
        end;

      if view.si.ModeInter = kimTU
        then DoCloseJosekiTutor(view)
    end;

  if TfmExportPos.IsOpen
    then fmExportPos.Close;

  if UfmFreeH.IsOpen
    then fmFreeH.FmClose;

  if Assigned(fmDBSearch)
    then fmDBSearch.Close;

  if Assigned(fmGtp)
    then fmGtp.Close;

  if Assigned(fmDebug)
    then fmDebug.Close;

  // convert absolute paths to relative paths before saving config if required
  // otherwise convert to absolute any relative paths remaining in config
  if Settings.UsePortablePaths
    then ConvertAbsolutePathsToRelative
    else ConvertRelativePathsToAbsolute;

  Actions.EnableEditShortcuts(True);
  Settings.SaveIniFile(IniFile);
  StatusMain.SaveTabs(IniFile);
  StatusMain.SaveIniFile(IniFile);
  UpdateIniFile;

  if OneInstance.IsFirstInstance
    then RdTempDir(Status.TmpPath);

  IniFile.Free;
  MRU_Tutor.Free;
  DBListOfTabs.Free;
  FreeAndNil(TabButtonHandler);
  TrayIcon.Free;
  FullScreenToggler.Free
end;

// -- Update settings on disk ------------------------------------------------

procedure TfmMain.UpdateIniFile;
begin
  try
    iniFile.UpdateFile
  except
    MessageDialog(msOk, imExclam, ['Something wrong when writing to Drago.ini',
                                   'Check Drago.ini permissions'])
  end
end;

// -- File related events ----------------------------------------------------

procedure TfmMain.mnFileClick(Sender: TObject);
begin
  mnReadOnly.Checked := ActiveView.si.ReadOnly
end;

procedure TfmMain.MenuMRUClick(index : integer);
begin
  LogErrorMessages;
  with Settings.MRUList[index] do
    DoMainOpen(Folder, Name, Index, Path);
  DisplayErrorMessages
end;

// MRU menu tags are set at design time
// All MRU menus use mnFile1 click event

procedure TfmMain.mnFile1PrevClick(Sender: TObject);
begin
  MenuMRUClick((Sender as TSpTBXItem).Tag)
end;

procedure TfmMain.WMDROPFILES(var msg : TWMDROPFILES);
var
  buffer : array[0 .. MAX_PATH] of char;
  count, i : Integer;
begin
  inherited;

  try
    count := DragQueryFile(msg.Drop, $FFFFFFFF, buffer, MAX_PATH);
    for i := 0 to count - 1 do
      begin
        DragQueryFile(msg.Drop, i, buffer, MAX_PATH);
        DoMainOpen(buffer)
      end
  finally
    DragFinish(msg.Drop)
  end
end;

// -- View events ------------------------------------------------------------

// -- Settings of checkboxes for showing toolbars

procedure TfmMain.mnShowToolbarsClick(Sender: TObject);
begin
  mnShowTB_File.Checked := ToolBarFile.Visible;
  mnShowTB_View.Checked := ToolBarView.Visible;
  mnShowTB_Navigation.Checked := ToolBarNavigation.Visible;
  mnShowTB_Edit.Checked := ToolBarEdit.Visible;
  mnShowTB_Misc.Checked := ToolBarMisc.Visible;
end;

// -- Common handler to all view toolbar menus

procedure TfmMain.mnShowTB_Click(Sender: TObject);
var
  menu : TSpTBXItem;
  name : string;
  tb : TSpTBXToolbar;
begin
  menu := Sender as TSpTBXItem;
  menu.Checked := not menu.Checked;
  name := NthWord(menu.Name, 2, '_');
  tb := FindComponent('Toolbar' + name) as TSpTBXToolbar;
  tb.Visible := menu.Checked
end;

// == Implementation of TListOfDBTabs ========================================

constructor TListOfDBTabs.Create;
begin
  FList := TList.Create
end;

destructor TListOfDBTabs.Destroy;
begin
  FList.Free;
  inherited Destroy
end;

procedure TListOfDBTabs.Push(obj : TObject);
var
  list : TStringList;
begin
  if FLIst.IndexOf(obj) >= 0
    then FList.Remove(obj);
  FList.Insert(0, obj);

  if Assigned(OnChange) then
    begin
      list := ListOfCaptions;
      OnChange(list);
      list.Free
    end
end;

procedure TListOfDBTabs.Remove(obj : TObject);
var
  list : TStringList;
begin
  if FLIst.IndexOf(obj) >= 0
    then FList.Remove(obj);

  if Assigned(OnChange) then
    begin
      list := ListOfCaptions;
      OnChange(list);
      list.Free
    end
end;

procedure TListOfDBTabs.Promote(caption : string);
var
  i : integer;
begin
  for i := 0 to FList.Count - 1 do
    if caption = ExtractFilename(TTabSheetEx(FList[i]).TabView.si.DatabaseName)
      then Push(FList[i])
end;

function TListOfDBTabs.Top : TObject;
begin
  if FList.Count = 0
    then Result := nil
    else Result := FList[0]
end;

function TListOfDBTabs.Registered(tab : TTabSheetEx) : boolean;
begin
  Result := FList.IndexOf(tab) >= 0
end;

function TListOfDBTabs.ListOfCaptions : TStringList;
var
  i : integer;
begin
  // must be freed by caller
  Result := TStringList.Create;

  for i := 0 to FList.Count - 1 do
    Result.Add(TTabSheetEx(FList[i]).TabView.si.DatabaseName)
end;

// -- Navigation events ------------------------------------------------------

// Note: previous versions implements repeating previous and next moves while
// keeping buttons down. This feature is not available with ToolBar2000 and
// handlers are removed since version 2.20.

// -- Editing related events -------------------------------------------------

// -- Tools buttons

(*
function TfmMain.ToolButtonNumber(tb : TToolButton) : integer;
begin
  for Result := 0 to Toolbar.ButtonCount - 1 do
    if Toolbar.Buttons[Result] = tb
      then exit;
  Result := -1
end;
*)

(* still here for reference

procedure TfmMain.tbMarkupClick(Sender: TObject);
begin
  // EN TEST
  gv.si.ModeInter := Settings.LastMarkup;
  SendMessage(ToolBar.Handle, TB_PRESSBUTTON, ToolButtonNumber(tbMarkup), 1);
  {
  SendMessage(ToolBar.Handle, TB_PRESSBUTTON, 26, 1);
  Application.ProcessMessages;
  tbPlay.Down   := False;
  tbNoir.Down   := False;
  tbBlanc.Down  := False;
  SendMessage(ToolBar.Handle, TB_PRESSBUTTON, 26, 0);
  SendMessage(ToolBar.Handle, TB_PRESSBUTTON, 26, 1);
  }
end;

*)

// -- Libraries --------------------------------------------------------------

procedure TfmMain.mnJosekiIndexClick(Sender: TObject);
begin
  //TfmIndex.Execute(gv, gxmVar)
end;

procedure TfmMain.Create1Click(Sender: TObject);
begin
  //TfmMakeFusekiDB.Execute
end;

procedure TfmMain.mnFusekiSettingsClick(Sender: TObject);
begin
  TfmOptions.Execute(eoLibrary)
end;

procedure TfmMain.mnJosekiSettingsClick(Sender: TObject);
begin
  TfmOptions.Execute(eoLibrary)
end;

// -- 'Joseki' menu ----------------------------------------------------------

procedure TfmMain.mnJosekiClick(Sender: TObject);
begin
  JoLoad
end;

procedure TfmMain.mnJoSessionClick(Sender: TObject);
begin
  JoEnter(ActiveViewBoard)
end;

procedure TfmMain.mnTutorClick(Sender: TObject);
begin
  //DoEnterJosekiTutor(ActiveViewBoard, '', trIdent)
end;

procedure TfmMain.mnJoCancelClick(Sender: TObject);
begin
  UserMainCloseFile;
  exit;

  if ActiveView.si.ModeInter = kimTU
    then
      begin
        ActiveView.si.ModeInter := kimGE;
        EnableCommands(ActiveViewBoard, mdEdit)
      end
    else JoLeave(ActiveViewBoard)
end;

// -- 'Options' menu ---------------------------------------------------------

// not implemented as an action to avoid glyph in menu bar

procedure TfmMain.mnOptions0Click(Sender: TObject);
begin
  TfmOptions.Execute(eoDefault)
end;

// -- 'Debug' commands -------------------------------------------------------

procedure TfmMain.mnDebugClick(Sender: TObject);
begin
  if not Assigned(fmDebug)
    then fmDebug := TfmDebug.Create(Application)
end;

// -- Display of available memory (Ctrl-Shift-MEM easter egg)

procedure TfmMain.tmMemoryTimer(Sender: TObject);
var
  bytes : Cardinal;
begin
  bytes := AllocMemSize;
  //bytes := TGameTree.InstanceSize;
  //bytes := AvailPhysicalMem;

  Caption := Format('%s - Bytes : %1.0n', [AppName, Bytes*1.0]);
end;

// -- 'Debug' menu

procedure TfmMain.mnResourcesClick(Sender: TObject);
begin
  Resources(ActiveView.cl)
end;

procedure TfmMain.mnBenchReadClick(Sender: TObject);
begin
  BenchRead(ActiveView.cl)
end;

procedure TfmMain.mnBenchSpanClick(Sender: TObject);
var
  filename : WideString;
begin
  if OpenDialog('Bench span tree',
                ExtractFilePath(ActiveView.si.FileName),
                '',
                'sms',
                U('SMS files (*.sms)') + '|*.sms',
                filename)
    then BenchSpan(ActiveView.cl, filename)
end;

procedure TfmMain.mnListCurrentClick(Sender: TObject);
begin
  PrintCurrentTree(Status.TmpPath + '\tmp.sgf', ActiveView.gt);
  fmDebug.Memo.Lines.LoadFromFile(Status.TmpPath + '\tmp.sgf');
  fmDebug.Show
end;

procedure TfmMain.mnSaveCurrentClick(Sender: TObject);
begin
  PrintCurrentTree(Status.AppPath + 'tmp.sgf', ActiveView.gt.Root)
end;

procedure TfmMain.mnSpanCurrentClick(Sender: TObject);
begin
  SpanCurrent
end;

procedure TfmMain.mnTestEditingClick(Sender: TObject);
begin
  Test_Editing
  //Test_RandomGame
end;

procedure TfmMain.mnTestTransClick(Sender: TObject);
begin
  Test_Trans
end;

procedure TfmMain.mnTestGTPClick(Sender: TObject);
begin
  Test_GTP
end;

// ---------------------------------------------------------------------------

procedure TfmMain.mnTestDiversClick(Sender: TObject);
begin
  //MilliTimer;
  //ApplyBatch('d:\gilles\go\drago\Reference.batch');
  //ApplyBatch('d:\gilles\go\drago\Sample.batch');
  //ShowMessage(Format('Timing batch: %d', [MilliTimer]))
  TfmTesting.Execute
end;

procedure TfmMain.mnTestEngineClick(Sender: TObject);
begin
  fmTest.Execute
end;

// ---------------------------------------------------------------------------

end.


