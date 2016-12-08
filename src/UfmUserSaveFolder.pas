// ---------------------------------------------------------------------------
// -- Drago -- Save folder dialog ------------------- UfmUserSaveFolder.pas --
// ---------------------------------------------------------------------------

unit UfmUserSaveFolder;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, ClassesEx, Controls, Forms, ExtCtrls,
  TntForms, TntGraphics, SpTBXControls, TntStdCtrls,
  UViewMain, TntCheckLst, SpTBXItem, StdCtrls, CheckLst;

type
  TfmUserSaveFolder = class(TTntForm)
    Bevel2: TBevel;
    btSelect: TTntButton;
    btUnselect: TTntButton;
    btOk: TTntButton;
    btCancel: TTntButton;
    btHelp: TTntButton;
    btIgnore: TTntButton;
    lbFolder: TSpTBXLabel;
    Label2: TSpTBXLabel;
    CheckListBox: TTntCheckListBox;
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure btSelectClick(Sender: TObject);
    procedure btUnselectClick(Sender: TObject);
    procedure btIgnoreClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FolderName : WideString;
    MyView : TViewMain;
  public
    class procedure Execute(view : TViewMain; list : TWideStringList; var result : integer);
  end;

var
  fmUserSaveFolder: TfmUserSaveFolder;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  SysUtilsEx,
  Translate, TranslateVcl, SgfIo, UnicodeUtils, UStatus;

// -- Display entry point ----------------------------------------------------

class procedure TfmUserSaveFolder.Execute(view : TViewMain; list : TWideStringList; var result : integer);
var
  s : WideString;
  i : integer;
begin
  fmUserSaveFolder := TfmUserSaveFolder.Create(Application);

  with fmUserSaveFolder do
    begin
      FolderName := WideExtractFilePath(list[0]);
      s := U('Files modified in folder') + ' ';

      // lbFolder.Canvas is not available, so use form canvas
      lbFolder.Caption := s + WideMinimizeName(FolderName, Canvas,
                                CheckListBox.Width - WideCanvasTextWidth(Canvas, s));

      MyView := view;
      for i := 0 to list.Count - 1 do
        CheckListBox.Items.Add(WideExtractFileName(list[i]));
      TranslateForm(fmUserSaveFolder);

      result := ShowModal
    end
end;

procedure TfmUserSaveFolder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree
end;

// -- Button click handling --------------------------------------------------

// -- Select all button

procedure TfmUserSaveFolder.btSelectClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to CheckListBox.Items.Count - 1 do
    CheckListBox.Checked[i] := True
end;

// -- Unselect all button

procedure TfmUserSaveFolder.btUnselectClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to CheckListBox.Items.Count - 1 do
    CheckListBox.Checked[i] := False
end;

// -- Ignore button

procedure TfmUserSaveFolder.btIgnoreClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

// -- Cancel button

procedure TfmUserSaveFolder.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

// -- Ok button

procedure TfmUserSaveFolder.btOkClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to CheckListBox.Items.Count - 1 do
    if CheckListBox.Checked[i]
      then PrintSGF(MyView.cl, FolderName + CheckListBox.Items[i],
                    ioRewrite, Settings.CompressList, Settings.SaveCompact,
                    True);

  ModalResult := mrOk
end;

// ---------------------------------------------------------------------------

end.
