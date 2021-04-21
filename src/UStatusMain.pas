unit UStatusMain;

interface

uses
  SysUtils, IniFiles, ClassesEx;

type
  TStatusMain = class
  private
    class function NewInstance : TObject; override;
  public
    // -- Window settings --------------
    OneInstance     : boolean;
    MinimizeToTray  : boolean;
    fmMainPlace     : string;
    Maximized       : boolean;
    FmNewPlace      : string;
    FmInsertPlace   : string;
    FmOptionPlace   : string;
    FmExpPosPlace   : string;
    FmFreeHaPlace   : string;
    FmSearchPlace   : string;
    FmGtpPlace      : string;
    FirstRestore    : boolean;
    GtpMessages     : TWideStringList; // used to retrieve GTP messages when opening GTP window

    constructor Create;
    destructor Destroy; override;
    procedure LoadIniFile(iniFile : TMemIniFile);
    procedure SaveIniFile(iniFile : TMemIniFile);
    procedure LoadTabs(iniFile : TMemIniFile);
    procedure SaveTabs(iniFile : TMemIniFile);
  private
    procedure CleanDeadIniTabs(iniFile : TMemIniFile);
  end;

function StatusMain : TStatusMain;

const
  __OneInstance         = True;
  __MinimizeToTray      = False;

implementation

uses
  Classes, StrUtils,
  DefineUi, UActions, UfrCfgSpToolbars, UfrCfgShortcuts, UfmMsg, UStatus,
  UGCom, Main, UViewBoard, UThemes, UMainUtil, UInstStatus;

// == Implementation of application status ===================================
//
// -- Status is a singleton. First TStatus.Create creates the only instance,
// -- other calls to TStatus.Create will launch an exception.
//
// -- Created and freed in initialization and finalization sections.
// -- Tip from http://dn.codegear.com/article/22576

var
  TheSingleton : TObject = nil;

class function TStatusMain.NewInstance: TObject;
begin
  if Assigned(TheSingleton)
    then raise Exception.Create('Trying to create again a singleton...')
    else
      begin
        TheSingleton := inherited NewInstance;
        Result := TheSingleton
      end
end;

constructor TStatusMain.Create;
begin
  GtpMessages := TWideStringList.Create
end;

destructor TStatusMain.Destroy;
begin
  GtpMessages.Free;
  inherited
end;

// -- Access, destruction ----------------------------------------------------

// should be used for data not accessible to user
function StatusMain : TStatusMain;
begin
  Result := TheSingleton as TStatusMain
end;

procedure TStatusMain.LoadIniFile(iniFile : TMemIniFile);
var
  s : string;
  n : integer;
begin
  with iniFile do
    begin
      // window positions
      OneInstance     := ReadBool  ('Windows', 'OneInstance', __OneInstance);
      MinimizeToTray  := ReadBool  ('Windows', 'MinimizeToTray', __MinimizeToTray);
      fmMainPlace     := ReadString('Windows', 'Main', '');
      SetMainPlacement(fmMainPlace, Maximized);
      FirstRestore    := Maximized;
      FmNewPlace      := ReadString('Windows', 'New',    '');
      FmInsertPlace   := ReadString('Windows', 'Insert', '');
      FmOptionPlace   := ReadString('Windows', 'Options', '');
      FmExpPosPlace   := ReadString('Windows', 'ExpPos', '');
      FmFreeHaPlace   := ReadString('Windows', 'FreeHa', '');
      FmSearchPlace   := ReadString('Windows', 'Search', '');
      FmGtpPlace      := ReadString('Windows', 'Gtp',    '');
      s               := ReadString('View'   , 'Theme', 'Default');
      SetCurrentTheme(s);

      // update actions
      if Assigned(Actions) then
        begin
          n := ReadInteger('Options' , 'Markup', 6);
          Actions.SetModeInter(n); // select markup glyph if required
          Actions.SetModeInter(0); // start with play edit mode
        end;
    end;

  // load shortcuts and toolbars
  UfrCfgShortcuts.LoadFromIni(Actions.ActionList, iniFile);
  UfrCfgSpToolbars.LoadToolbarIniFile;
end;

procedure TStatusMain.SaveIniFile(iniFile : TMemIniFile);
begin
  with iniFile do
    begin
      // window positions
      WriteBool  ('Windows' , 'OneInstance', OneInstance);
      WriteBool  ('Windows' , 'MinimizeToTray', MinimizeToTray);
      WriteString('Windows' , 'Main'       , GetMainPlacement);
      WriteString('Windows' , 'New'        , FmNewPlace);
      WriteString('Windows' , 'Insert'     , FmInsertPlace);
      WriteString('Windows' , 'Options'    , FmOptionPlace);
      WriteString('Windows' , 'ExpPos'     , FmExpPosPlace);
      WriteString('Windows' , 'FreeHa'     , FmFreeHaPlace);
      WriteString('Windows' , 'Search'     , FmSearchPlace);
      WriteString('Windows' , 'Gtp'        , FmGtpPlace);
      WriteString('View'    , 'Theme'      , GetCurrentTheme);
    end;

  // save toolbars and shortcuts
  UfrCfgShortcuts.SaveToIni(Actions.ActionList, iniFile);
  UfrCfgSpToolbars.SaveToolbarIniFile

  // saved on disk by caller
end;

// -- Loading and saving tabs ------------------------------------------------

procedure TStatusMain.LoadTabs(iniFile : TMemIniFile);
var
  i, n1, n2, index, l1, l2, l3, l4, view, side : integer;
  section, path : AnsiString;
  folder, name : WideString;
  ok : boolean;
begin
  n1 := iniFile.ReadInteger('Windows', 'TabCount', 0);
  n2 := iniFile.ReadInteger('Windows', 'ActiveTab', 0);

  // log open error messages during startup
  Status.ErrMsgLogged := True;

  for i := 0 to n1 - 1 do
    begin
      section := 'Tab' + IntToStr(i);

      with iniFile do
        begin
          folder := Utf8Decode(ReadString(section, 'Folder', ''));
          name   := Utf8Decode(ReadString(section, 'File'  , ''));
          index  := ReadInteger(section, 'Game', 1);
          path   := ReadString (section, 'Path', '');
          view   := ReadInteger(section, 'View', 0);

          // convert relative paths to absolute
          // does nothing if already absolute
          folder := AppAbsolutePath(folder);
          name   := AppAbsolutePath(name);
        end;

      DoMainOpen(folder, name, index, path, False, ok);

      // update panels
      if ok and (fmMain.ActiveView is TViewBoard)
        then fmMain.ActiveViewBoard.frViewBoard.LoadIniFile(iniFile, section);

      (* Cache TODO
      // open right view
      if ok then
        with fmMain do
          SelectView(gv.Tab as TTabSheetEx, TViewMode(view))
      *)
    end;

  if n2 < fmMain.PageCount
    then fmMain.ActivePageIndex := n2
    else fmMain.ActivePageIndex := 0;
  //fmMain.SelectView(vmBoard)
end;

function TabToBeSaved(si : TInstStatus) : boolean;
begin
  result := (si.FileName <> '') and (si.ModeInter <> kimTU)
end;

procedure TStatusMain.SaveTabs(iniFile : TMemIniFile);
var
  i, count, activeIndex, vm : integer;
  view : TViewBoard;
  section : AnsiString;
  name : WideString;
begin
  count := 0;
  activeIndex := 0;

  for i := 0 to fmMain.PageCount - 1 do
    begin
      view := fmMain.Pages[i].ViewBoard;

      if TabToBeSaved(view.si) then
        begin
          section := 'Tab' + IntToStr(count);

          if view.si.ViewMode in [vmInfoGm, vmInfoPb]
            then vm := integer(vmBoard)
            else vm := integer(view.si.ViewMode);

          with iniFile do
            begin
              WriteString (section, 'Folder'   , Utf8Encode(view.si.FolderName));
              if view.si.DatabaseName = ''
                then name := view.si.FileName
                else name := view.si.DatabaseName;
              // convert absolute paths to relative paths if required
              // otherwise convert to absolute possible relative paths
              if Settings.UsePortablePaths
                then name := AppRelativePath(name)
                else name := AppAbsolutePath(name);
              WriteString (section, 'File'     , Utf8Encode(name));
              WriteInteger(section, 'Game'     , view.si.IndexTree);
              WriteString (section, 'Path'     , view.si.CurrentPath);
              WriteInteger(section, 'View'     , vm);
            end;

          view.frViewBoard.SaveIniFile(iniFile, section);

          if i = fmMain.ActivePageIndex
            then activeIndex := count;
          inc(count)
        end
    end;

  iniFile.WriteInteger('Windows', 'TabCount', count);
  iniFile.WriteInteger('Windows', 'ActiveTab', activeIndex);

  CleanDeadIniTabs(iniFile)
end;

procedure TStatusMain.CleanDeadIniTabs(iniFile : TMemIniFile);
var
  listOfSections : TStringList;
  i, k, count : integer;
  section : AnsiString;
begin
  listOfSections := TStringList.Create;

  try
    iniFile.ReadSections(listOfSections);
    count := iniFile.ReadInteger('Windows', 'TabCount', 0);

    i := count;
    while True do
      begin
        section := 'Tab' + IntToStr(i);

        if iniFile.SectionExists(section) = False
          then break;

        for k := 0 to listOfSections.Count - 1 do
          if AnsiStartsStr(section, listOfSections[k])
            then iniFile.EraseSection(listOfSections[k]);

        inc(i)
      end
  finally
    listOfSections.Free
  end
end;

initialization
  TStatusMain.Create;
finalization
  StatusMain.Free
end.
