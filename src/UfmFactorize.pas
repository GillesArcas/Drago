unit UfmFactorize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SpTBXControls, StdCtrls, 
  TntForms, TntStdCtrls, SpTBXItem;

type
  TfmFactorize = class(TTntForm)
    btStart: TSpTBXButton;
    btClose: TSpTBXButton;
    ProgressBar: TSpTBXProgressBar;
    Bevel1: TBevel;
    cxTewari: TSpTBXCheckBox;
    ListBox: TTntMemo;
    rgReference: TSpTBXRadioGroup;
    rgSource: TSpTBXRadioGroup;
    btHelp: TSpTBXButton;
    SpTBXGroupBox1: TSpTBXGroupBox;
    SpTBXLabel1: TSpTBXLabel;
    edDepth: TTntEdit;
    edUnique: TTntEdit;
    SpTBXLabel2: TSpTBXLabel;
    cxNormPos: TSpTBXCheckBox;
    procedure btStartClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
  private
    procedure LoadSettings;
    procedure SaveSettings;
  public
    class function Execute : boolean;
  end;
  
implementation

uses
  DefineUi,
  ClassesEx, UStatus, UGCom, UfmSelectFiles, Main, Translate,
  TranslateVcl, VclUtils, HtmlHelpAPI,
  UfrSelectFiles;

{$R *.dfm}

var
  fmFactorize : TfmFactorize;

class function TfmFactorize.Execute : boolean;
begin
  fmFactorize := TfmFactorize.Create(nil);
  with fmFactorize do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure TfmFactorize.FormCreate(Sender: TObject);
begin
  LoadSettings;
  TranslateForm(Self);
  rgSource.ItemIndex := 0;
  ListBox.Lines.Clear;
  ListBox.Lines.Add(U('Only main branch is processed...')); 
  ListBox.Lines.Add(U('Move inversions are not detected...')) 
end;

procedure TfmFactorize.LoadSettings;
begin
  edDepth.Text := IntToStr(Settings.FactorizeDepth);
  edUnique.Text := IntToStr(Settings.FactorizeNbUnique);
  // cxTewari box is currently not visible
  cxTewari.Checked := Settings.FactorizeWithTewari;
  cxNormPos.Checked := Settings.FactorizeNormPos;
  rgReference.ItemIndex := Settings.FactorizeReference
end;

procedure TfmFactorize.SaveSettings;
begin
  Settings.FactorizeDepth := StrToIntDef(edDepth.Text, __FactorizeDepth);
  Settings.FactorizeNbUnique := StrToIntDef(edUnique.Text, __FactorizeNbUnique);
  Settings.FactorizeWithTewari := cxTewari.Checked;
  Settings.FactorizeNormPos := cxNormPos.Checked;
  Settings.FactorizeReference := rgReference.ItemIndex
end;

procedure OnStep(x : integer);
begin
  fmFactorize.ProgressBar.Position := x;
  Application.ProcessMessages
end;

procedure OnError(s : WideString);
begin
  fmFactorize.ListBox.Lines.Add(s);
  SendMessage(fmFactorize.ListBox.Handle, EM_LINESCROLL, 0, +1);
  Application.ProcessMessages
end;

procedure TfmFactorize.btStartClick(Sender: TObject);
var
  dummy : integer;
  fmSelectFiles : TfmSelectFiles;
  theList : TWideStringList;
begin
  if not ValidateNumEdit(self, edDepth, dummy)
    then exit;
  if not ValidateNumEdit(self, edUnique, dummy)
    then exit;

  SaveSettings;
  btStart.Enabled := False;
  btClose.Enabled := False;
  btHelp.Enabled := False;

  try
    case rgSource.ItemIndex of
      0 : // factorize games in current tab
        begin
          DoFactorizeCollection(fmMain.ActiveView.cl,
                                OnStep, OnError,
                                Settings.FactorizeDepth,
                                Settings.FactorizeNbUnique,
                                Settings.FactorizeWithTewari)
        end;
      1 : // select files and folders, then factorize
        begin
          fmSelectFiles := TfmSelectFiles.Create(nil);
          fmSelectFiles.InitialDir := Settings.FactorizeFolder;
          fmSelectFiles.ShowModal;
          if fmSelectFiles.ModalResult = mrCancel
            then theList := nil
            else
              begin
                theList := fmSelectFiles.frSelectFiles.ListOfSelectedFiles;
                //Settings.FactorizeFolder := WideExtractFilePath(theList [0])
                Settings.FactorizeFolder := fmSelectFiles.frSelectFiles.CurrentDir
              end;
          fmSelectFiles.Release;

          if theList = nil
            then exit;

          DoFactorizeCollection(theList,
                                OnStep, OnError,
                                Settings.FactorizeDepth,
                                Settings.FactorizeNbUnique,
                                Settings.FactorizeWithTewari);
          theList.Free;
          fmFactorize.ProgressBar.Position := 100;
        end;
      else
        // nop
    end
  finally
    btStart.Enabled := True;
    btClose.Enabled := True;
    btHelp.Enabled := True;
    //ModalResult := mrOk
  end
end;

procedure TfmFactorize.btCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmFactorize.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_Factorisation)
end;

end.
