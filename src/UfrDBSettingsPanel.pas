unit UfrDBSettingsPanel;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  SpTBXItem, SpTBXControls, 
  Components, UDBBaseNamePicker;

type
  TfrDBSettingsPanel = class(TFrame)
    BaseNamePicker: TDBBaseNamePicker;
    rgPatternSearchView: TSpTBXRadioGroup;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    rgNextMove: TSpTBXRadioGroup;
    SpTBXGroupBox1: TSpTBXGroupBox;
    cbFixedColor: TSpTBXCheckBox;
    cbFixedPos: TSpTBXCheckBox;
    cxSearchVar: TSpTBXCheckBox;
    edMoveLimit: TIntEdit;
    Label11: TSpTBXLabel;
    procedure BaseNamePickersbOpenClick(Sender: TObject);
    procedure BaseNamePickercbNameChange(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
  public
    FOnTerminate : TNotifyEvent;
    constructor Create(aOwner: TComponent); override;
  private
    procedure Translate;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  HtmlHelpAPI, 
  Define, DefineUi, VclUtils, TranslateVcl, UDatabase, UStatus;

// ---------------------------------------------------------------------------

constructor TfrDBSettingsPanel.Create(aOwner: TComponent);
begin
  inherited;

  // fight against flickering
  AvoidFlickering([self]);

  // initialize
  BaseNamePicker.Default;
  LoadSettings;

  // translate
  Translate
end;

procedure TfrDBSettingsPanel.Translate;
var
  i : integer;
begin
  for i := 0 To ComponentCount - 1 do
    TranslateTComponent(Components[i])
end;

procedure TfrDBSettingsPanel.LoadSettings;
begin
  cbFixedColor.Checked := Settings.DBFixedColor;
  cbFixedPos.Checked   := Settings.DBFixedPos;
  cxSearchVar.Checked  := Settings.DBSearchVariations;
  edMoveLimit.Value    := Settings.DBMoveLimit;

  // remove alternate radio button if not set manually in config
  if Settings.DBNextMove <> pcAlternate
    then rgNextMove.Items.Delete(3);

  case Settings.DBNextMove of
    Black : rgNextMove.ItemIndex := 0;
    White : rgNextMove.ItemIndex := 2;
    pcBoth : rgNextMove.ItemIndex := 1;
    pcAlternate : rgNextMove.ItemIndex := 3;
  end;

  rgPatternSearchView.ItemIndex := integer(Settings.DBSearchView);
end;

procedure TfrDBSettingsPanel.SaveSettings;
begin
  Settings.DBFixedColor := cbFixedColor.Checked;
  Settings.DBFixedPos := cbFixedPos.Checked;
  Settings.DBSearchVariations := cxSearchVar.Checked;
  Settings.DBMoveLimit := edMoveLimit.Value;

  case rgNextMove.ItemIndex of
    0 : Settings.DBNextMove := Black;
    2 : Settings.DBNextMove := White;
    1 : Settings.DBNextMove := pcBoth;
    3 : Settings.DBNextMove := pcAlternate;
  end;

  Settings.DBSearchView := TDBSearchView(rgPatternSearchView.ItemIndex);
end;

procedure TfrDBSettingsPanel.BaseNamePickersbOpenClick(Sender: TObject);
begin
  DoResetDatabase;
  BaseNamePicker.sbOpenClick(Sender)
end;

procedure TfrDBSettingsPanel.BaseNamePickercbNameChange(Sender: TObject);
begin
  DoResetDatabase;
  BaseNamePicker.cbNameChange(Sender)
end;

procedure TfrDBSettingsPanel.btOkClick(Sender: TObject);
begin
  SaveSettings;

  if Assigned(FOnTerminate)
    then FOnTerminate(self)
end;

procedure TfrDBSettingsPanel.btCancelClick(Sender: TObject);
begin
  if Assigned(FOnTerminate)
    then FOnTerminate(self)
end;

procedure TfrDBSettingsPanel.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_Database);
end;

// ---------------------------------------------------------------------------

end.
