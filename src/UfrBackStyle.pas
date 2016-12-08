// ---------------------------------------------------------------------------
// -- Drago -- Board background input frame -------------- UfrBackStyle.pas --
// ---------------------------------------------------------------------------

unit UfrBackStyle;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtDlgs, ExtCtrls,
  TntForms, TntStdCtrls,
  Components, MyTntExtDlgs, UBackground;

type
  TCallBack    = procedure of object;
  TColorDialog = class(TColorDialogSaveCustom);

  TfrBackStyle = class(TTntFrame)
    GroupBox: TTntGroupBox;
    ColorDialog: TColorDialog;
    Image1: TImage;
    Bevel1: TBevel;
    Button1: TTntRadioButton;
    Button2: TTntRadioButton;
    Button3: TTntRadioButton;
    Button4: TTntRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3MouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure Button2MouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure Button3KeyPress(Sender: TObject; var Key: Char);
    procedure Button2KeyPress(Sender: TObject; var Key: Char);
  private
    MyOpenPictureDialog: TTntOpenPictureDialog;
  public
    Background : TBackground;
    CallBack   : TCallBack;

    procedure Create(aCaption  : string;
                     aCallBack : TCallBack;
                     aDefault  : TBackground);
    procedure Show  (aBackground : TBackground);
    procedure Refresh;
    procedure Setup (aBackground : TBackground);
    procedure Enable(enabled : boolean);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Translate, VclUtils, DefineUi, Main, UStatus;

{$R *.dfm}

// ---------------------------------------------------------------------------

procedure TfrBackStyle.Create(aCaption  : string;
                              aCallBack : TCallBack;
                              aDefault  : TBackground);
begin
  Background := TBackground.Create(aDefault);
  CallBack   := aCallBack;

  GroupBox.Caption := U(aCaption);
  Button1.Caption  := U(Button1.Caption);
  Button2.Caption  := U(Button2.Caption);
  Button3.Caption  := U(Button3.Caption);
  Button4.Caption  := U(Button4.Caption);

  MyOpenPictureDialog := TTntOpenPictureDialog.Create(self);
  ColorDialog.IniFile := fmMain.IniFile;
end;

procedure TfrBackStyle.Show(aBackground : TBackground);
begin
  Background.Assign(aBackground);
  Background.Update;
  Background.Apply (Image1.Canvas, ControlRect(Image1));

  case Background.Style of
    bsDefaultTexture : Button1.Checked := True;
    bsCustomTexture  : Button2.Checked := True;
    bsColor          : Button3.Checked := True;
    bsAsGoban        : Button4.Checked := True
  end;
end;

procedure TfrBackStyle.Refresh;
begin
  Background.Update;
  Background.Apply(Image1.Canvas, ControlRect(Image1))
end;

procedure TfrBackStyle.Setup(aBackground : TBackground);
begin
  aBackground.Assign(Background)
end;

procedure TfrBackStyle.Enable(enabled : boolean);
begin
  Button1.Enabled := enabled;
  Button2.Enabled := enabled;
  Button3.Enabled := enabled;
  Button4.Enabled := enabled;
end;

// -- Handling of radio buttons ----------------------------------------------

// -- 'Default texture' button

procedure TfrBackStyle.Button1Click(Sender: TObject);
begin
  Background.Style := bsDefaultTexture;
  Background.Update;
  Background.Apply(Image1.Canvas, ControlRect(Image1));

  if Assigned(CallBack)
    then CallBack
end;

// -- 'Custom texture' button

function OpenPictureDialogFilter : WideString;
begin
  Result := U('All files')  + ' (*.bmp, *.jpg, *.gif, *.png)|*.bmp;*.jpg;*.gif;*.png|'
          + U('BMP files')  + ' (*.bmp)|*.bmp|'
          + U('JPEG files') + ' (*.jpg)|*.jpg|'
          + U('GIF files')  + ' (*.gif)|*.gif|'
          + U('PNG files')  + ' (*.png)|*.png';
end;

procedure TfrBackStyle.Button2MouseDown(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MyOpenPictureDialog.Title      := AppName + ' - ' + U('Select texture');
  MyOpenPictureDialog.Filter     := OpenPictureDialogFilter;
  MyOpenPictureDialog.InitialDir := ExtractFilePath(Background.Image);
  if Settings.ShowPlacesBar
    then MyOpenPictureDialog.OptionsEx := []
    else MyOpenPictureDialog.OptionsEx := [ofExNoPlacesBar];

  if not MyOpenPictureDialog.Execute
    then exit;

  Background.Style := bsCustomTexture;
  Background.Image := MyOpenPictureDialog.FileName;
  Background.Update;
  Background.Apply(Image1.Canvas, ControlRect(Image1));

  if Assigned(CallBack)
    then CallBack
end;

procedure TfrBackStyle.Button2KeyPress(Sender: TObject; var Key: Char);
begin
  Button2MouseDown(Sender, mbLeft, [ssLeft], 0, 0)
end;

// -- Color button

procedure TfrBackStyle.Button3MouseDown(Sender: TObject;
                                        Button: TMouseButton; 
                                        Shift: TShiftState; 
                                        X, Y: Integer);
begin
  ColorDialog.Color := Color;
  if not ColorDialog.Execute
    then exit;

  Background.Color := ColorDialog.Color;
  Background.Style := bsColor;
  Background.Update;
  Background.Apply(Image1.Canvas, ControlRect(Image1));

  if Assigned(CallBack)
    then CallBack
end;

procedure TfrBackStyle.Button3KeyPress(Sender: TObject; var Key: Char);
begin
  Button3MouseDown(Sender, mbLeft, [ssLeft], 0, 0)
end;

// -- 'As board' button

procedure TfrBackStyle.Button4Click(Sender: TObject);
begin
  Background.Style := bsAsGoban;
  Background.Update;
  Background.Apply(Image1.Canvas, ControlRect(Image1));

  if Assigned(CallBack)
    then CallBack
end;

// ---------------------------------------------------------------------------

end.
