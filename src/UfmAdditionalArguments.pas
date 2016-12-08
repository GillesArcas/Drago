unit UfmAdditionalArguments;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Dialogs,
  Forms,
  TntForms, SpTBXControls, StdCtrls, SpTBXEditors, SpTBXItem,
  EngineSettings;

type
  TfmAdditionalArguments = class(TTntForm)
    edAddtionalArgs: TSpTBXEdit;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    lbCustom: TSpTBXLabel;
    edArgs: TSpTBXEdit;
    SpTBXLabel1: TSpTBXLabel;
    SpTBXLabel2: TSpTBXLabel;
    procedure edAddtionalArgsChange(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FEngineSettings : TEngineSettings;
  public
    class function Execute(engineSettings : TEngineSettings) : boolean;
  end;

implementation

{$R *.dfm}

uses
  DefineUi, UEngines, Translate, TranslateVcl;

// -- Display request --------------------------------------------------------

class function TfmAdditionalArguments.Execute(engineSettings : TEngineSettings) : boolean;
var
  customArgsBak : string;
begin
  with TfmAdditionalArguments.Create(Application) do
    try
      customArgsBak := engineSettings.FCustomArgs;
      FEngineSettings := engineSettings;
      edArgs.Text := EngineArguments(FEngineSettings);
      edAddtionalArgs.Text := engineSettings.FCustomArgs;
      Result := ShowModal = mrOk;
      if Result = False
        then engineSettings.FCustomArgs := customArgsBak
    finally
      Release;
      Application.ProcessMessages
    end
end;

procedure TfmAdditionalArguments.edAddtionalArgsChange(Sender: TObject);
begin
  FEngineSettings.FCustomArgs := edAddtionalArgs.Text;
  edArgs.Text := EngineArguments(FEngineSettings);
end;

procedure TfmAdditionalArguments.btOkClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfmAdditionalArguments.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmAdditionalArguments.FormShow(Sender: TObject);
begin
  Caption := AppName + ' - ' + U('Additional parameters');
  TranslateForm(Self)
end;

end.
