unit UfmCustomStones;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, 
  StdCtrls, SpTBXEditors, SpTBXItem, SpTBXControls, ExtCtrls,
  TntForms, TntStdCtrls;

type
  TfmCustomStones = class(TTntForm)
    SpTBXLabel1: TSpTBXLabel;
    SpTBXLabel2: TSpTBXLabel;
    SpTBXLabel3: TSpTBXLabel;
    edBlackPath: TSpTBXEdit;
    edWhitePath: TSpTBXEdit;
    btSelectBlackPath: TSpTBXButton;
    btSelectWhitePath: TSpTBXButton;
    SpTBXLabel4: TSpTBXLabel;
    Bevel1: TBevel;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    Bevel2: TBevel;
    cbLightSource: TTntComboBox;
    procedure FormShow(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btSelectBlackPathClick(Sender: TObject);
    procedure btSelectWhitePathClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
  private
    procedure LoadSettings;
    procedure SaveSettings;
  public
    class function Execute : boolean;
  end;

implementation

{$R *.dfm}

uses
  Define, DefineUi,
  HtmlHelpAPI,
  UStatus, UDialogs, SysUtilsEx, Translate, TranslateVcl;

class function TfmCustomStones.Execute : boolean;
begin
  with TfmCustomStones.Create(nil) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure TfmCustomStones.LoadSettings;
begin
  edBlackPath.Text := Settings.CustomBlackPath;
  edWhitePath.Text := Settings.CustomWhitePath;
  cbLightSource.ItemIndex := integer(Settings.CustomLightSource)
end;

procedure TfmCustomStones.SaveSettings;
begin
  Settings.CustomBlackPath := edBlackPath.Text;
  Settings.CustomWhitePath := edWhitePath.Text;
  Settings.CustomLightSource := TLightSource(cbLightSource.ItemIndex);
end;

procedure TfmCustomStones.FormShow(Sender: TObject);
begin
  LoadSettings;
  TranslateForm(self)
end;

procedure TfmCustomStones.btOkClick(Sender: TObject);
begin
  SaveSettings;
  ModalResult := mrOk
end;

procedure TfmCustomStones.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmCustomStones.btSelectBlackPathClick(Sender: TObject);
var
  filename : WideString;
  filterIndex : integer;
begin
  filterIndex := 1;

  if OpenDialog('Select Black stone filename',
                WideExtractFilePath(edWhitePath.Text), '', '', //aName, aExt,
                U('PNG files') + ' (*.png)|*.png|',
                filterIndex,
                filename)
    then
      edBlackPath.Text := filename
end;

procedure TfmCustomStones.btSelectWhitePathClick(Sender: TObject);
var
  filename : WideString;
  filterIndex : integer;
begin
  filterIndex := 1;

  if OpenDialog('Select White stone filename',
                WideExtractFilePath(edBlackPath.Text), '', '', //aName, aExt,
                U('PNG files') + ' (*.png)|*.png|',
                filterIndex,
                filename)
    then
      edWhitePath.Text := filename
end;

procedure TfmCustomStones.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_Options_Stones)
end;

end.
