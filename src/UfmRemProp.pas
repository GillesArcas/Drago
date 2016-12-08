unit UfmRemProp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SpTBXControls, StdCtrls, SpTBXEditors, SpTBXItem, TntForms,
  UViewBoard;

type
  TfmRemProp = class(TTntForm)
    SpTBXLabel1: TSpTBXLabel;
    edProperties: TSpTBXEdit;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    rgGames: TSpTBXRadioGroup;
    procedure btOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
  private
    function GetActiveView : TViewBoard;
  public
    class procedure Execute;
  end;

var
  fmRemProp: TfmRemProp;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, Translate, TranslateVcl, Main;

{$R *.dfm}

// -- Display request --------------------------------------------------------

class procedure TfmRemProp.Execute;
begin
  with TfmRemProp.Create(Application) do
    try
      // open only if current view is a TViewBoard
      if fmMain.ActiveView is TViewBoard
        then ShowModal
    finally
      Release
    end
end;

// -- Helpers ----------------------------------------------------------------

function TfmRemProp.GetActiveView : TViewBoard;
begin
  Result := fmMain.ActiveView as TViewBoard
end;

// ---------------------------------------------------------------------------

procedure TfmRemProp.FormCreate(Sender: TObject);
begin
  Caption := AppName + ' - ' + U('Remove properties');
  TranslateForm(self);
  (rgGames.Controls[0] as TSpTBXRadioButton).Top := 9;
  (rgGames.Controls[1] as TSpTBXRadioButton).Top := 9;
  rgGames.ItemIndex := 0
end;

// ---------------------------------------------------------------------------

procedure TfmRemProp.btOkClick(Sender: TObject);
begin
  GetActiveView.DoRemoveProperties(edProperties.Text, rgGames.ItemIndex = 1);
  Close
end;

procedure TfmRemProp.btCancelClick(Sender: TObject);
begin
  Close
end;

procedure TfmRemProp.btHelpClick(Sender: TObject);
begin
  //
end;

// ---------------------------------------------------------------------------

end.
