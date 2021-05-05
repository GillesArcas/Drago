// ---------------------------------------------------------------------------
// -- Drago -- New file form ----------------------------------- UfmNew.pas --
// ---------------------------------------------------------------------------

unit UfmNew;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Controls, Forms, IniFiles, StdCtrls, ExtCtrls, ComCtrls,
  SpTBXControls, SpTBXItem, TntForms, TntStdCtrls;

type
  TfmNew = class(TTntForm)
    btOk: TTntButton;
    btCancel: TTntButton;
    btHelp: TTntButton;
    Label1: TLabel;
    pnValues: TSpTBXGroupBox;
    Bevel1: TBevel;
    lbSize: TTntLabel;
    lbHandicap: TTntLabel;
    lbKomi: TTntLabel;
    cbSize: TComboBox;
    cbHandicap: TComboBox;
    cbKomi: TComboBox;
    ckFree: TTntCheckBox;
    rgCreateIn: TSpTBXRadioGroup;
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure cbHandicapChange(Sender: TObject);
    procedure cbSizeChange(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure fmNewCreate(Sender: TObject);
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
    procedure TntFormShow(Sender: TObject);
  private
    function  Enter : integer;
    procedure SetupValues(size : integer);
    function  ValidateSize : boolean;
  public
    class function Execute : integer;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  DefineUi, Std, Translate, UStatus, TranslateVcl, BoardUtils, UStatusMain,
  Counting, VclUtils;

{$R *.DFM}

// -- Display request --------------------------------------------------------

class function TfmNew.Execute : integer;
begin
  with TfmNew.Create(Application) do
    try
      Result := Enter
    finally
      Release
    end
end;

procedure TfmNew.fmNewCreate(Sender: TObject);
begin
  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
end;

function TfmNew.Enter : integer;
begin
  Top := 200;
  Left := 200;
  Caption := AppName + ' - ' + U('New');
  TranslateForm(Self);
  SetupValues(Settings.BoardSize);
  cbHandicap.ItemIndex := 0;
  cbKomi.ItemIndex     := 0;
  ckFree.Checked       := False;
  ckFree.Enabled       := False;
  rgCreateIn.ItemIndex := 0; // st.LastNewMode
  btHelp.Visible       := False;

  Result := ShowModal
end;

procedure TfmNew.TntFormShow(Sender: TObject);
begin
  SetWinStrPosition(self, StatusMain.FmNewPlace);
end;

// -- Close windows ----------------------------------------------------------

procedure TfmNew.TntFormClose(Sender: TObject; var Action: TCloseAction);
begin
  StatusMain.FmNewPlace := GetWinStrPlacement(self)
end;

// -- Update of size+handicap+komi panel -------------------------------------

procedure TfmNew.SetupValues(size : integer);
begin
  Settings.Handicap := cbHandicap.ItemIndex;
  cbHandicap.ItemIndex := 0;
  SetComboValue(cbKomi, FloatToStr(KomiValue));
  cbSize.Text := IntToStr(size)
end;

// -- Ok button --------------------------------------------------------------

function TfmNew.ValidateSize : boolean;
var
  n : integer;
begin
  Result := TryStrToInt(cbSize.Text, n);
  Result := Result and Within(n, 5, 19);
  if not Result
    then ActiveControl := cbSize
end;

procedure TfmNew.btOkClick(Sender : TObject);
var
  a : single;
begin
  if not ValidateSize
    then exit;

  if not TryStrToFloat(cbKomi.Text, a) then
    begin
      if cbKomi.CanFocus
        then ActiveControl := cbKomi;
      exit
    end;

  with Settings do
    begin
      BoardSize   := StrToInt(cbSize.Text);
      Handicap    := StrToInt(cbHandicap.Items[cbHandicap.ItemIndex]);
      Komi        := StrToFloat(cbKomi.Text);
      newInFile   := rgCreateIn.ItemIndex <> 0;
      PlFree      := ckFree.Checked;
      PlGame      := False;
      LastNewMode := rgCreateIn.ItemIndex
    end;

  ModalResult := mrOK
end;

// -- Cancel button ----------------------------------------------------------

procedure TfmNew.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

// -- Help Button ------------------------------------------------------------

procedure TfmNew.btHelpClick(Sender: TObject);
begin
end;

// -- Handling of events -----------------------------------------------------

procedure TfmNew.cbSizeChange(Sender: TObject);
begin
  if not ValidateSize
    then exit;
      
  cbHandicapChange(Sender);
end;

procedure TfmNew.cbHandicapChange(Sender: TObject);
begin
  cbHandicap.ItemIndex := Min(cbHandicap.ItemIndex, MaxHandicap(StrToInt(cbSize.Text)));

  ckFree.Enabled := cbHandicap.ItemIndex > 1
end;

// ---------------------------------------------------------------------------

end.
