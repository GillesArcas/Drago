// ---------------------------------------------------------------------------
// -- Drago -- Frame for signature search in DB --- UfrDBSignaturePanel.pas --
// ---------------------------------------------------------------------------

unit UfrDBSignaturePanel;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, Buttons, ExtCtrls,
  TntForms,
  UfrBoardThumb, UKombilo,
  SpTBXControls, TntExtCtrls, SpTBXItem;

type
  TfrDBSignaturePanel = class(TTntFrame)
    BoardThumb: TfrBoardThumb;
    Panel2: TTntPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    edSig: TEdit;
    Label1: TSpTBXLabel;
    Label8: TSpTBXLabel;
    procedure BoardThumbbtCaptureClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure edSigChange(Sender: TObject);
  private
    kh : TKGameList;
    pnMainMinWidth, pnMainMaxWidth, pnMainMinHeight : integer;
    Edits : array[1 .. 6] of TEdit;
  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;
    procedure Capture(i1, j1, i2, j2 : integer); overload;
    procedure UpdateSignatureEdits(coord : string; var moveNum : integer);
    procedure InitSearch;
    procedure StartSearch;
    procedure TerminateSearch(Sender: TObject);
    procedure ClearPanel;
    function  GetSigFromEdits : string;
    procedure SetEditsFromSig(sig : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, VclUtils, TranslateVcl, Main, UDatabase,
  UBoardViewCanvas,
  UfmDBSearch, UGoban, GameUtils;

{$R *.dfm}

// -- Creation of frame ------------------------------------------------------

constructor TfrDBSignaturePanel.Create(aOwner : TComponent);
var
  i, gbCoordStyle : integer;
begin
  inherited Create(aOwner);
  Name := '';

  // fight against flickering
  AvoidFlickering([self]);

  kh := nil;

  BoardThumb.Initialize(smSig);
  BoardThumb.Height := Width + 10;
  BoardThumb.imGoban.OnMouseEnter := nil;
  BoardThumb.imGoban.OnMouseLeave := nil;
  BoardThumb.imGoban.OnMouseDown := BoardThumb.imGobanMouseDownSignature;

  // store TEdit references for easier access and clear
  Edits[1] := Edit1;
  Edits[2] := Edit2;
  Edits[3] := Edit3;
  Edits[4] := Edit4;
  Edits[5] := Edit5;
  Edits[6] := Edit6;
  for i := 1 to 6 do
    Edits[i].OnChange := EditChange;
  ClearPanel;

  // necessary to update mean and pen colors
  (BoardThumb.mygb.BoardView as TBoardViewCanvas).BoardBack.Update;
  BoardThumb.mygb.BoardView.CoordStyle := fmMain.ActiveView.gb.BoardView.CoordStyle;

  TranslateTComponent(self);
end;

// -- Destruction of frame ---------------------------------------------------

destructor TfrDBSignaturePanel.Destroy;
begin
  BoardThumb.Finalize;
  inherited Destroy
end;

// -- Clear and capture ------------------------------------------------------

procedure TfrDBSignaturePanel.ClearPanel;
begin
  edSig.Text := '____________';
  SetEditsFromSig(edSig.Text)
end;

procedure TfrDBSignaturePanel.Capture(i1, j1, i2, j2 : integer);
begin
  //BoardThumb.Capture(fmMain.ActiveView.gb, i1, j1, i2, j2)
end;

procedure TfrDBSignaturePanel.BoardThumbbtCaptureClick(Sender: TObject);
var
  sig : string;
begin
  sig := GetSignature(fmMain.ActiveView.gt);

  BoardThumb.DrawSigOnBoard(sig);
  SetEditsFromSig(sig);
  edSig.Text := sig
end;

// -- Edit handlers ----------------------------------------------------------

procedure TfrDBSignaturePanel.EditChange(Sender: TObject);
var
  ed : TEdit;
  sig : string;
begin
  edSig.OnChange := nil;

  ed := Sender as TEdit;
  //ed.Text := Copy(ed.Text + '__', 1, 2);
  //if Length(ed.Text) = 2 then
    begin
      sig := GetSigFromEdits;
      edSig.Text := sig;
      BoardThumb.DrawSigOnBoard(sig)
    end;

  edSig.OnChange := edSigChange
end;

procedure TfrDBSignaturePanel.edSigChange(Sender: TObject);
var
  i : integer;
begin
  for i := 1 to 6 do
    Edits[i].OnChange := nil;

  BoardThumb.DrawSigOnBoard(edSig.Text);
  SetEditsFromSig(edSig.Text);

  for i := 1 to 6 do
    Edits[i].OnChange := EditChange;
end;

// -- Update of edits after clicking on goban

procedure TfrDBSignaturePanel.UpdateSignatureEdits(coord : string; var moveNum : integer);
var
  i : integer;
begin
  for i := 1 to 6 do
    if Edits[i].Text = coord
      then exit;
      
  for i := 1 to 6 do
    if Edits[i] = Screen.ActiveControl then
      begin
        Edits[i].Text := coord;
        case i of
          1 : moveNum := 20;
          2 : moveNum := 40;
          3 : moveNum := 60;
          4 : moveNum := 31;
          5 : moveNum := 51;
          6 : moveNum := 71
        end;
        if i < 6
          then Edits[i + 1].SetFocus;
        //break
        exit
      end;

  // no edit was found as the active control, set first one and recurse
  fmDBSearch.SetFocusedControl(Edits[1]);
  UpdateSignatureEdits(coord, moveNum)
end;

// -- Edits from/to string conversions ---------------------------------------

function TfrDBSignaturePanel.GetSigFromEdits : string;
var
  k : integer;
begin
  Result := '';

  for k := 1 to 6 do
    if Length(Edits[k].Text) < 2
      then Result := Result + '__'
      else Result := Result + Edits[k].Text
end;

procedure TfrDBSignaturePanel.SetEditsFromSig(sig : string);
var
  k : integer;
begin
  for k := 0 to 5 do
    if Length(sig) < k * 2 + 2
      then Edits[k + 1].Text := '__'
      else Edits[k + 1].Text := Copy(sig, k * 2 + 1, 2)
end;

// -- Search start and terminate events --------------------------------------

procedure TfrDBSignaturePanel.InitSearch;
begin
end;

procedure TfrDBSignaturePanel.StartSearch;
begin
  DBSearchContext.kh.SigSearch(GetSigFromEdits, 19); // TODO: handle dim
end;

procedure TfrDBSignaturePanel.TerminateSearch(Sender: TObject);
begin
  CurrentEntriesToCollection(DBSearchContext.DBTab.ViewBoard);
  fmMain.InvalidateView(DBSearchContext.DBTab, vmAll);

  //ActiveDBTab.TabView.si.ViewMode := vmInfo
  fmMain.SelectView(ActiveDBTab, vmInfo)
end;

// ---------------------------------------------------------------------------

end.
