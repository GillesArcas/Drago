// ---------------------------------------------------------------------------
// -- Drago -- Input query form for integers ----------- UInputQueryInt.pas --
// ---------------------------------------------------------------------------

// Note: InputQuery(caption, prompt, n) is documented but not available in D7.

unit UInputQueryInt;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Components,
  TntForms, TntStdCtrls, SpTBXControls, SpTBXItem;

type
  TfmInputQueryInt = class(TTntForm)
    IntEdit1: TIntEdit;
    Label1: TSpTBXLabel;
    btOk: TTntButton;
    btCancel: TTntButton;
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure TntFormCreate(Sender: TObject);
  private
  public
  end;

//var
//  fmInputQueryInt: TfmInputQueryInt;

function InputQueryInt(const ACaption, APrompt: WideString;
                       var Value: Integer) : boolean;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses Translate, UStatus;

function InputQueryInt(const ACaption, APrompt: WideString;
                       var Value: Integer) : boolean;
begin
  with TfmInputQueryInt.Create(nil) do
    begin
      Caption := ACaption;
      Label1.Caption := APrompt;
      btOk.Caption := U('Ok');
      btCancel.Caption := U('Cancel'); 
      IntEdit1.Text := IntToStr(value);

      Result := ShowModal = mrOk;
      if Result
        then Value := StrToIntDef(IntEdit1.Text, 0);

      Release
    end
end;

procedure TfmInputQueryInt.TntFormCreate(Sender: TObject);
begin
  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
end;

procedure TfmInputQueryInt.btOkClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfmInputQueryInt.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------

