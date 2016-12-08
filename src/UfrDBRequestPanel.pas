// ---------------------------------------------------------------------------
// -- Drago -- Frame for game info search in DB ----- UfrDBRequestPanel.pas --
// ---------------------------------------------------------------------------

unit UfrDBRequestPanel;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Controls, Forms,
  StdCtrls, ExtCtrls,
  UDBDatePicker, UDBPlayerPicker,
  UDBResultPicker, UDBRequestPicker,
  UDBSQLPicker, TntForms;

type
  TfrDBRequestPanel = class(TFrame)
    ResultPicker: TDBResultPicker;
    RequestPicker: TDBRequestPicker;
    Bevel1: TBevel;
    DatePicker: TDBDatePicker;
    PlayerPicker: TDBPlayerPicker;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    SQLPicker: TDBSQLPicker;
  private
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Translate;
    procedure DoWhenUpdating;
    procedure DoWhenShowing;
    procedure InitSearch;
    procedure StartSearch;
    procedure TerminateSearch(Sender: TObject);
    procedure ChangeRequest;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  DefineUi, Std, VclUtils, TranslateVcl, UKombilo, UDatabase, Main;

// ---------------------------------------------------------------------------

constructor TfrDBRequestPanel.Create(aOwner: TComponent);
begin
  inherited;

  // fight against flickering
  AvoidFlickering([self, PlayerPicker, DatePicker, ResultPicker]);
  PlayerPicker.DoubleBuffered := True;

  // initialize
  RequestPicker.Initialize;

  // translate
  Translate
end;

destructor TfrDBRequestPanel.Destroy;
begin
  inherited;
end;

procedure TfrDBRequestPanel.Translate;
var
  i : integer;
begin
  for i := 0 To ComponentCount - 1 do
    if Components[i] = PlayerPicker
      then PlayerPicker.Translate
      else TranslateTComponent(Components[i])
end;

procedure TfrDBRequestPanel.DoWhenUpdating;
var
  kh : TKGameList;
  pl : TStringList;
begin
  //Application.ProcessMessages;
  kh := ActiveDB;

  pl := TStringList.Create;
  pl.Clear;

  SQLPicker.Default(False);
  PlayerPicker.Default(True, pl);
  DatePicker.Default(False);
  ResultPicker.Default(False);
  RequestPicker.Default(False);

  pl.Free;

  if Assigned(kh) then
    try
      //Screen.Cursor := fmMain.WaitCursor;
      pl := ListOfPlayers(kh);
      PlayerPicker.Default(True, pl);
    finally
      //Screen.Cursor := crDefault;
      pl.Free
    end
end;

// -- Update -----------------------------------------------------------------

procedure TfrDBRequestPanel.DoWhenShowing;
begin
end;

// -- Search start and terminate events --------------------------------------

procedure TfrDBRequestPanel.ChangeRequest;
var
  rq : string;
begin
  rq := join(' AND ', [PlayerPicker.GetRequest,
                       DatePicker.GetRequest,
                       ResultPicker.GetRequest,
                       RequestPicker.GetRequest]);

  if rq = ''
    then rq := '1';

  SQLPicker.Memo.Text := rq
end;

procedure TfrDBRequestPanel.InitSearch;
var
  rq : string;
begin
  // SQLPicker is always equal to the current request
  rq := SQLPicker.GetRequest;

  // this is checked by echoing the request submitted to db
  SQLPicker.Memo.Text := rq
end;

procedure TfrDBRequestPanel.StartSearch;
var
  rq : string;
begin
  // SQLPicker is always equal to the current request
  rq := SQLPicker.GetRequest;

  // search
  DBSearchContext.kh.GISearch(rq)
end;

procedure TfrDBRequestPanel.TerminateSearch(Sender: TObject);
begin
  CurrentEntriesToCollection(DBSearchContext.DBTab.ViewBoard);
  fmMain.InvalidateView(DBSearchContext.DBTab, vmAll);

  //ActiveDBTab.TabView.si.ViewMode := vmInfo
  fmMain.SelectView(ActiveDBTab, vmInfo)
end;

// ---------------------------------------------------------------------------

end.
