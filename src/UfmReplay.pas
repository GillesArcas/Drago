// ---------------------------------------------------------------------------
// -- Drago -- Input form for replay mode ------------------- UfmReplay.pas --
// ---------------------------------------------------------------------------

unit UfmReplay;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls,
  TntForms, TntStdCtrls, SpTBXControls, SpTBXItem, SpTBXSkins;

type
  TfmEnterGm = class(TTntForm)
    rgMode: TSpTBXRadioGroup;
    rgPlayWith: TSpTBXRadioGroup;
    rgDepth: TSpTBXRadioGroup;
    btOk: TTntButton;
    btCancel: TTntButton;
    btHelp: TTntButton;
    rgNbAttempts: TSpTBXRadioGroup;
    lbFuseki: TSpTBXLabel;
    edFuseki: TEdit;
    UpDown: TUpDown;
    procedure FormShow     (Sender: TObject);
    procedure btOkClick    (Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure rgModeClick(Sender: TObject);
  private
    procedure ApplySettings;
    procedure UpdateSettings(nbFuseki : integer);
  public
    class function Execute : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, Std, Translate, TranslateVcl, UStatus, HtmlHelpAPI, VclUtils;

{$R *.DFM}

// ---------------------------------------------------------------------------

class function TfmEnterGm.Execute : boolean;
begin
  with TfmEnterGm.Create(Application) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure TfmEnterGm.FormShow(Sender : TObject);
begin
  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
  Caption   := AppName + ' - ' + U('Replay game');
  TranslateForm(Self);
  lbFuseki.Left := edFuseki.Left - lbFuseki.Width - 5;

  ApplySettings;

  rgMode.SkinType     := sknWindows;
  rgPlayWith.SkinType := sknWindows;
  rgDepth.SkinType    := sknWindows;
end;

// -- Settings

procedure TfmEnterGm.ApplySettings;
begin
  rgMode.ItemIndex       := Settings.GmMode;
  rgPlayWith.ItemIndex   := Settings.GmPlayer - 1;
  if (Settings.GmMode in [1, 2]) and (Settings.GmPlay = 2)
    then rgDepth.ItemIndex := 0
    else rgDepth.ItemIndex := Settings.GmPlay;
  edFuseki.Text          := IntToStr(Settings.GmNbFuseki);
  UpDown.Position        := Settings.GmNbFuseki;
  rgNbAttempts.ItemIndex := iff(Settings.GmNbAttempts = 1, 0, 1)
end;

procedure TfmEnterGm.UpdateSettings(nbFuseki : integer);
begin
  Settings.GmMode       := rgMode.ItemIndex;
  Settings.GmPlayer     := rgPlayWith.ItemIndex + 1;
  Settings.GmPlay       := rgDepth.ItemIndex;
  Settings.GmNbFuseki   := nbFuseki;
  Settings.GmNbAttempts := iff(rgNbAttempts.ItemIndex = 0, 1, MaxInt)
end;

procedure TfmEnterGm.rgModeClick(Sender: TObject);
var
  rb : TSpTBXRadioButton;
begin
  // 'From current position' button
  rb := rgDepth.Controls[2] as TSpTBXRadioButton;

  // if not current game, avoid current position
  if (rgMode.ItemIndex <> 0) and (rgDepth.ItemIndex = 2)
    then rgDepth.ItemIndex := 0;

  // enable only when replaying current game
  rb.Enabled := rgMode.ItemIndex = 0;

  // text is not grayed with Windows skin
  if rb.Enabled
    then rb.Font.Color := clBlack
    else rb.Font.Color := clGrayText;

  // add some information when greyed
  if rb.Enabled
    then rb.Caption := U('From current position')
    else rb.Caption := U('From current position (only for current game)')
end;

// -- Buttons

procedure TfmEnterGm.btOkClick(Sender : TObject);
var
  n : integer;
begin
  if not ValidateNumEdit(self, edFuseki, n)
    then exit;

  UpdateSettings(n);
  ModalResult := mrOK
end;

procedure TfmEnterGm.btCancelClick(Sender : TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmEnterGm.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_ModeGm)
end;

// ---------------------------------------------------------------------------

end.

