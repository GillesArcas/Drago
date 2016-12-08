// ---------------------------------------------------------------------------
// -- Drago -- Dialog box with translation --------------------- UfmMsg.pas --
// ---------------------------------------------------------------------------

unit UfmMsg;

{
Displays a translated dialog box with the following API :

   MessageDialog(typeMessage, typeImage, [line1, line2, ...]);
   MessageDialog(typeMessage, typeImage, [line1, line2, ...], warn);

Button selection can be one of the following :

   msOk, msOkCancel, msYesNo, msYesNoCancel

Image selection can be one of the following :

   imDrago, imExclam, imQuestion, imSad

Returns one of the following values with respect to button settings :

   mrOk, mrCancel, mrYes, mrNo

These constants are defined in the Controls unit.

The second form of calling displays a check box with the following message:
"Don't show this message again". The state of the check box is returned in
the "warn" var parameter.
}

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Math, ExtCtrls, ImgList, Types,
  TntForms, TntStdCtrls, SpTBXControls, TntExtCtrls, SpTBXItem, TntGraphics;

type
  TfmMsg = class(TTntForm)
    Image: TImage;
    Button1: TTntButton;
    Button2: TTntButton;
    Button3: TTntButton;
    Bevel1: TTntBevel;
    Memo: TTntMemo;
    CheckBox: TSpTBXCheckBox;
    function MessageDlg(Dlg, Img : integer; Msg : array of WideString;
                         warn : boolean) : integer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TntFormCreate(Sender: TObject);
    procedure MemoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    typeDlg: integer;
    ButtonClick : Boolean;
  end;

var
  fmMsg: TfmMsg;

function MessageDialog(Dlg, Img : integer;
                       Msg : array of WideString) : integer; overload;
function MessageDialog(Dlg, Img : integer;
                       Msg : array of WideString;
                       var warn : boolean) : integer; overload;

// ---------------------------------------------------------------------------

implementation

{$R *.DFM}

uses
  DefineUi, Translate, TranslateVcl,
  UGraphic,
  UStatus;

// -- Calling functions

function MessageDialog(Dlg, Img : integer; Msg : array of WideString) : integer;
begin
  fmMsg := TfmMsg.Create(Application);
  Result := fmMsg.MessageDlg(Dlg, Img, Msg, False);
  fmMsg.Release;
  Application.ProcessMessages
end;

function MessageDialog(Dlg, Img : integer; Msg : array of WideString;
                        var warn : boolean) : integer;
begin
  fmMsg := TfmMsg.Create(nil);
  Result := fmMsg.MessageDlg(Dlg, Img, Msg, True);
  warn := not fmMsg.CheckBox.Checked;
  fmMsg.Release;
  Application.ProcessMessages
end;

// -- Internal function

procedure TfmMsg.TntFormCreate(Sender: TObject);
begin
  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
  TranslateForm(self);
end;

function TfmMsg.MessageDlg(Dlg, Img : integer;
                           Msg : array of WideString;
                           warn : boolean) : integer;
var
  Bitmap : TBitmap;
  i, d   : integer;
  wEsp, wBut, wMsg, wButs : integer;
  rsc    : string;
begin
  Color := clBtnFace;
  typeDlg := Dlg;
  Button1.Visible := True;
  Button1.Default := True;

  // set buttons according to style
  case Dlg of
    msOk :
      begin
        Button1.Caption := U('Ok');
        Button2.Visible := False;
        Button3.Visible := False;
      end;
    msOkCancel :
      begin
        Button1.Caption := U('Ok');
        Button2.Caption := U('Cancel');
        Button2.Visible := True;
        Button3.Visible := False;
        Button2.Cancel  := True;
      end;
    msYesNo :
      begin
        Button1.Caption := U('Yes');
        Button2.Caption := U('No');
        Button2.Visible := True;
        Button3.Visible := False;
        Button2.Cancel  := True;
      end;
    msYesNoCancel :
      begin
        Button1.Caption := U('Yes');
        Button2.Caption := U('No');
        Button3.Caption := U('Cancel');
        Button2.Visible := True;
        Button3.Visible := True;
        Button2.Cancel  := False;
        Button3.Cancel  := True
      end
  end;

  // set memo
  Memo.Clear;
  Memo.Tag    := Memo.Height;
  Memo.Height := Round(Length(msg) * -Memo.Font.Height * 1.25);
  wMsg := 0;
  for i := 0 to High(msg) do
    begin
      Memo.Lines.Add(msg[i]);
      //wMsg := max(wMsg, Canvas.TextWidth(msg[i]))
      wMsg := max(wMsg, WideCanvasTextWidth(Canvas, msg[i]))
    end;
  Memo.Width := Round(1.2 * wMsg);

  // calculate widths of buttons and spaces between buttons
  wBut := Button1.Width;                               // same for all
  wEsp := Button2.Left - Button1.Width - Button1.Left; // idem
  case typeDlg of
    msOk          : wButs := wBut;
    msOkCancel    : wButs := 2 * wBut + wEsp;
    msYesNo       : wButs := 2 * wBut + wEsp;
    msYesNoCancel : wButs := 3 * wBut + 2 * wEsp;
  end;

  Width := 2*Memo.Left + Max(Max(wButs, wMsg), CheckBox.Width);
  d := (Width - wButs) div 2;

  Button1.Left := d;
  Button2.Left := d + wEsp + wBut;
  Button3.Left := d + 2*wEsp + 2*wBut;

  //adjust height according to memo content
  if Length(msg) > 1
    then Height := Height + Memo.Height - Memo.Tag;

  // adjust height if no warning check box
  if not warn then
    begin
      button1.Anchors := [akTop];
      button2.Anchors := [akTop];
      button3.Anchors := [akTop];
      Bevel1.Visible := False;
      CheckBox.Visible := False;
      ClientHeight := Bevel1.Top - 1;
    end;

  // display image
  Bitmap := TBitmap.Create;
  case Img of
    imDrago    : rsc := 'MSGDRA';
    imExclam   : rsc := 'MSGEXC';
    imQuestion : rsc := 'MSGQUE';
    imSad      : rsc := 'MSGSAD'
  end;
  Bitmap.Handle := LoadBitmap(HInstance, PChar(rsc));
  Bitmap.Transparent     := True;
  Bitmap.TransparentMode := tmAuto;
  PseudoAntiAlias(Bitmap, 42, MeanColor(Canvas, 50, 50));
  Image.Picture.Assign(Bitmap);
  Bitmap.Free;

  ButtonClick := False;
  Result := ShowModal
end;

procedure TfmMsg.Button1Click(Sender: TObject);
begin
  ButtonClick := True;
  if typeDlg in [msOk, msOkCancel]
    then ModalResult := mrOk
    else ModalResult := mrYes
end;

procedure TfmMsg.Button2Click(Sender: TObject);
begin
  ButtonClick := True;
  if typeDlg in [msOk, msOkCancel]
    then ModalResult := mrCancel
    else ModalResult := mrNo
end;

procedure TfmMsg.Button3Click(Sender: TObject);
begin
  ButtonClick := True;
  ModalResult := mrCancel
end;

procedure TfmMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ButtonClick
    then // nop
    else
      if typeDlg = msYesNo
        then ModalResult := mrNo
        else ModalResult := mrCancel
end;

// ---------------------------------------------------------------------------

procedure TfmMsg.MemoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  lines : integer;
begin
  ActiveControl := nil;
  lines := SendMessage(Memo.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
  SendMessage(Memo.Handle, EM_LINESCROLL, 0, -lines)
end;

// ---------------------------------------------------------------------------

end.

