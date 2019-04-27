// ---------------------------------------------------------------------------
// -- Drago -- Input form for filename roots --------------- UfmExtract.pas --
// ---------------------------------------------------------------------------

unit UfmExtract;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, FileCtrl, Dlgs, CommDlg,
  TntForms, TntStdCtrls;

type
  TfmExtract = class(TTntForm)
    sbMore: TSpeedButton;
    Label2: TTntLabel;
    edRoot: TTntEdit;
    edName: TTntEdit;
    lbRoot: TTntLabel;
    btOk: TTntButton;
    btCancel: TTntButton;
    procedure sbMoreClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure edRootChange(Sender: TObject);
  private
    theCaption, theRoot, theExt : WideString;
    procedure UpdateRoot(const root : WideString);
    procedure SaveDialogShow(Sender: TObject);
  public
  end;

var
  fmExtract: TfmExtract;

function GetRoot(const fileName : WideString;
                 const aCaption : WideString;
                 const aExt     : WideString;
                 out   rootName : WideString) : boolean;
            
// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, SysUtilsEx,
  DefineUi, Translate, TranslateVcl, UDialogs, VclUtils;

{$R *.dfm}

// -- Calling function -------------------------------------------------------

function GetRoot(const fileName : WideString;
                 const aCaption : WideString;
                 const aExt     : WideString;
                 out   rootName : WideString) : boolean;
begin
  fmExtract := TfmExtract.Create(Application);
  TranslateForm(fmExtract);

  with fmExtract do
    begin
      Caption := AppName + ' - ' +  U(aCaption);
      theCaption := aCaption;
      theExt := aExt;
      UpdateRoot(fileName);
      if ShowModal = mrOk
        then Result := True
        else Result := False;
      rootName := theRoot;
      Release
    end
end;

// ---------------------------------------------------------------------------

procedure TfmExtract.UpdateRoot(const root : WideString);
begin
  theRoot := WideChangeFileExt(root, '');
  edRoot.Text := WideMinimizeName(theRoot,
                                  Canvas, edRoot.Width);
  edName.Text := WideMinimizeName(WideFormat('%s0000.%s', [theRoot, theExt]),
                                  Canvas, edName.Width)
end;

procedure TfmExtract.SaveDialogShow(Sender: TObject);
begin
  //SetDlgItemText(GetParent(SaveDialog.Handle), IDOK, 'OK')
  //SendMessage(GetParent(SaveDialog.Handle),
  //              CDM_SETCONTROLTEXT, IDOK, longint(PChar('OK')))
end;

procedure TfmExtract.sbMoreClick(Sender: TObject);
var
  filename : WideString;
begin
  if SaveDialog(theCaption,
                ExtractFilePath(theRoot),
                theRoot,
                'sgf',
                U('All files') + ' (*.*)|*.*',
                True,
                filename)
    then UpdateRoot(filename)
end;

procedure TfmExtract.edRootChange(Sender: TObject);
begin
  UpdateRoot(edRoot.Text)
end;

// -- Buttons ----------------------------------------------------------------

procedure TfmExtract.btOkClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfmExtract.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

// ---------------------------------------------------------------------------

end.
