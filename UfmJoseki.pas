// ---------------------------------------------------------------------------
// -- Drago -- Fiche d'entrée du mode Joseki ---------------- UFMJOSEKI.pas --
// ---------------------------------------------------------------------------

unit UfmJoseki;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TfmEnterJo = class(TForm)
    rgJouerAvec : TRadioGroup;
    GroupBox    : TGroupBox;
    UpDown      : TUpDown;
    Edit        : TEdit;
    btOk        : TButton;
    btAnnuler   : TButton;
    Label1: TLabel;
    procedure FormCreate     (Sender: TObject);
    procedure FormShow       (Sender: TObject);
    procedure btOkClick      (Sender: TObject);
    procedure btAnnulerClick (Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmEnterJo: TfmEnterJo;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, UStatus, Translate;

{$R *.DFM}

procedure TfmEnterJo.FormCreate (Sender : TObject);
   begin
      BorderIcons := [];
   end;

procedure TfmEnterJo.FormShow (Sender : TObject);
   begin
      Caption               := AppName + ' - ' + U('Rejouer joseki');
      rgJouerAvec.ItemIndex := Settings.joPlayer - 1;
      Edit.Text             := IntToStr (Settings.joNumber);
      UpDown.Position       := Settings.joNumber
   end;

procedure TfmEnterJo.btOkClick (Sender : TObject);
   begin
      Settings.joPlayer := rgJouerAvec.ItemIndex + 1;
      Settings.joNumber := StrToInt (Edit.Text);

      ModalResult := mrOK
   end;

procedure TfmEnterJo.btAnnulerClick (Sender : TObject);
   begin
      ModalResult := mrCancel
   end;

// ---------------------------------------------------------------------------

end.
