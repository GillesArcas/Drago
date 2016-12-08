// ---------------------------------------------------------------------------
// -- Drago -- Welcome screen -------------------------------- UWelcome.pas --
// ---------------------------------------------------------------------------

unit UWelcome;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, TntStdCtrls, CheckLst, TntCheckLst,
  SpTBXEditors, SpTBXControls, SpTBXItem, jpeg;

type
  TfmWelcome = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btContinue: TButton;
    Bevel1: TBevel;
    gbFileAssoc: TTntGroupBox;
    cxSGFAsso: TTntCheckBox;
    cxMGTAsso: TTntCheckBox;
    GroupBox1: TSpTBXGroupBox;
    lbLanguages: TTntListBox;
    lbWelcome: TSpTBXLabel;
    procedure FormCreate(Sender: TObject);
    procedure lbLanguagesClick(Sender: TObject);
    procedure btContinueClick(Sender: TObject);
    procedure btContinueClick2(Sender: TObject);
  private
  public
  end;

var
  fmWelcome: TfmWelcome;

procedure WelcomeFirstTime;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  UDragoIniFiles,
  TntForms,
  DefineUi, Std, Translate, UStatus, UFileAssoc, UActions, SysUtilsEx, ClassesEx;

// ---------------------------------------------------------------------------

procedure WelcomeFirstTime;
begin
  if not WideFileExists(WideChangeFileExt(TntApplication.ExeName, '.ini')) then
     begin
        fmWelcome := TfmWelcome.Create(Application);
        fmWelcome.ShowModal;
        fmWelcome.Free
     end
end;

procedure TfmWelcome.FormCreate(Sender: TObject);
var
  languages : TWideStringList;
  i : integer;
begin
  Caption := AppName;

  // translations are registered in initialization section of Translate.pas
  languages := AllLanguages;
  for i := 0 to languages.Count - 1 do
    begin
      lbLanguages.Items.Add(UTF8DecodeX(languages[i]));
      if languages[i] = 'English'
        then lbLanguages.ItemIndex := i
    end;

  // show file assoc box only if registry has write access
  gbFileAssoc.Visible := HasRegistryWriteAccess;

  lbWelcome.Caption := 'Welcome in Drago'
end;

procedure TfmWelcome.lbLanguagesClick(Sender: TObject);
var
  ok : boolean;
  filename : string;
begin
  SetLanguage(LanguageCodeFromName(UTF8Encode(lbLanguages.Items[lbLanguages.ItemIndex])),
              ok, filename);
  if not ok
    then ShowMessage('File ' + filename + ' not found. No translation.');

  lbWelcome.Caption := U('Welcome in Drago')
end;

procedure TfmWelcome.btContinueClick(Sender: TObject);
var
  IniFile : TDragoIniFile;
  ok : boolean;
begin
  // create 
  IniFile := TDragoIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  CreateIniFile(IniFile);
  Actions.DefaultShortCut(Inifile);

  // handle language
  IniFile.WriteString('Options', 'Language',
                LanguageCodeFromName(UTF8Encode(lbLanguages.Items[lbLanguages.ItemIndex])));
  IniFile.UpdateFile;
  IniFile.Free;

  // handle associations
  ok := True;
  if cxSGFAsso.Checked
    then RegisterAsso(Application.ExeName, '.sgf', 'Drago.Document', 'Drago Document', ok);
  if cxMGTAsso.Checked
    then RegisterAsso(Application.ExeName, '.mgt', 'Drago.Document', 'Drago Document', ok);

  if ok
    then Close
    else
      begin
        lbWelcome.Font.Color := clRed;
        lbWelcome.Caption := U('Unable to update file association!') + ' '
                           + U('Check user rights.');
        btContinue.OnClick := btContinueClick2;
        cxSGFAsso.Checked := False;
        cxMGTAsso.Checked := False
      end
end;

procedure TfmWelcome.btContinueClick2(Sender: TObject);
begin
  Close
end;

// ---------------------------------------------------------------------------

end.

