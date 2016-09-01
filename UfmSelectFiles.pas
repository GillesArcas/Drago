unit UfmSelectFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  TntForms,
  UfrSelectFiles, SpTBXItem, SpTBXControls;

type
  TfmSelectFiles = class(TTntForm)
    frSelectFiles: TfrSelectFiles;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
  private
    procedure SetInitialDir(dir : WideString);
  public
    property InitialDir : WideString write SetInitialDir;
  end;

implementation

uses
  TranslateVcl;

{$R *.dfm}

procedure TfmSelectFiles.FormCreate(Sender: TObject);
begin
  frSelectFiles.FormCreate(Sender)
end;

procedure TfmSelectFiles.FormShow(Sender: TObject);
begin
  TranslateForm(Self);
  frSelectFiles.FrameShow(Sender);
  frSelectFiles.GroupBox2.Caption := ''
end;

procedure TfmSelectFiles.btOkClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfmSelectFiles.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmSelectFiles.SetInitialDir(dir : WideString);
begin
  frSelectFiles.InitialDir := dir
end;

end.
