unit UfmGtp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, 
  TntForms, TntStdCtrls, SpTBXItem, SpTBXControls, SpTBXEditors;

type
  TfmGtp = class(TTntForm)
    Panel1: TPanel;
    Memo: TTntMemo;
    lbWarning: TSpTBXLabel;
    Timer1: TTimer;
    btSend: TSpTBXButton;
    btSave: TSpTBXButton;
    btClear: TSpTBXButton;
    btClose: TSpTBXButton;
    edSend: TSpTBXEdit;
    procedure btSendClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
  public
    class procedure Execute(createVisible : boolean);
  end;

var
  fmGtp: TfmGtp;

implementation

uses
  DefineUi, Main, UDialogs, Translate, TranslateVcl, UActions, VclUtils,
  UStatusMain;

{$R *.dfm}

class procedure TfmGtp.Execute(createVisible : boolean);
begin
  fmGtp := TfmGtp.Create(nil);

  if createVisible
    then fmGtp.Show
end;

procedure TfmGtp.FormCreate(Sender: TObject);
begin
  Width := 400;
  Memo.Clear;
  Memo.Lines.AddStrings(StatusMain.GtpMessages)
end;

procedure TfmGtp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StatusMain.FmGtpPlace := GetWinStrPlacement(self);
  StatusMain.GtpMessages.Clear;
  StatusMain.GtpMessages.AddStrings(Memo.Lines);
  Actions.EnableEditShortcuts(True);
  Memo.Clear;
  Action := caFree;
  fmGtp := nil
end;

procedure TfmGtp.FormShow(Sender: TObject);
var
  lineCount : integer;
begin
  SetWinStrPlacement(self, StatusMain.FmGtpPlace);
  Caption := AppName + ' - ' + U('GTP window');
  TranslateForm(self);
  Timer1.Enabled := True;

  lineCount := SendMessage(Memo.Handle, EM_GETLINECOUNT, 0, 0);
  SendMessage(Memo.Handle, EM_LINESCROLL, 0, +lineCount)
end;

procedure TfmGtp.FormHide(Sender: TObject);
begin
  Timer1.Enabled := False
end;

procedure TfmGtp.FormActivate(Sender: TObject);
begin
  Actions.EnableEditShortcuts(False)
end;

procedure TfmGtp.btSendClick(Sender: TObject);
begin
  if Assigned(fmMain.ActiveView.gtp)
    then fmMain.ActiveView.gtp.Send(nil, edSend.Text)
end;

procedure TfmGtp.btClearClick(Sender: TObject);
begin
  Memo.Clear
end;

procedure TfmGtp.btSaveClick(Sender: TObject);
var
  filename : WideString;
begin
  if SaveDialog('Save as',
                ExtractFilePath(filename),
                ExtractFileName(filename),
                'txt',
                U('text files') + ' (*.txt)|*.txt',
                True,
                filename)
    then // continue
    else exit;

  Memo.Lines.SaveToFile(filename)
end;

procedure TfmGtp.edSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE
    then edSend.Text := '';
  if Key = VK_RETURN
    then btSendClick(nil);

  if (Key = VK_ESCAPE) or (Key = VK_RETURN)
    then Key := 0
end;

procedure TfmGtp.btCloseClick(Sender: TObject);
begin
  Close
end;

procedure TfmGtp.Timer1Timer(Sender: TObject);
begin
  edSend.Enabled := Assigned(fmMain.ActiveView) and Assigned(fmMain.ActiveView.gtp);
  btSend.Enabled := edSend.Enabled;

  if edSend.Enabled
    then edSend.Font.Color := clBlack
    else
      begin
        edSend.Text := U('No engine running')
      end
end;

end.
