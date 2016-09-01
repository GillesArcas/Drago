// ---------------------------------------------------------------------------
// -- Drago -- Form for handling favorites --------------- UfmFavorites.pas --
// ---------------------------------------------------------------------------

unit UfmFavorites;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,
  TntForms, SpTBXControls, TntStdCtrls, SpTBXItem, TB2Item, Menus;

type
  TfmFavorites = class(TTntForm)
    btUp: TBitBtn;
    btDn: TBitBtn;
    Bevel1: TBevel;
    btOpen: TSpTBXButton;
    btClose: TSpTBXButton;
    btAddFile: TSpTBXButton;
    btRemove: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    btAddCurrent: TSpTBXButton;
    ListBox: TTntListBox;
    lbFullName: TTntLabel;
    SpTBXPopupMenu1: TSpTBXPopupMenu;
    btAddDatabase: TSpTBXItem;
    btAddFolder: TSpTBXItem;
    btAddGameFile: TSpTBXItem;
    procedure FormShow(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure btAddFileClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btUpClick(Sender: TObject);
    procedure btDnClick(Sender: TObject);
    procedure btRemoveClick(Sender: TObject);
    procedure btAddCurrentClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure btAddGameFileClick(Sender: TObject);
    procedure btAddFolderClick(Sender: TObject);
    procedure btAddDatabaseClick(Sender: TObject);
  private
    LastItem : integer;
    FullNames : TStringList;
    procedure AddFile(name : WideString);
  public
    class procedure Execute;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, SysUtilsEx,
  TntFileCtrl, UViewMain,
  DefineUi, Translate, TranslateVcl, Main, Ugcom, HtmlHelpAPI, UDialogs;

{$R *.dfm}

// -- Display request --------------------------------------------------------

class procedure TfmFavorites.Execute;
begin
  with TfmFavorites.Create(Application) do
    try
      FullNames := TStringList.Create;
      ShowModal
    finally
      FullNames.Free;
      Release
    end
end;

function ActiveView : TViewMain;
begin
  Result := fmMain.ActiveView
end;

// ---------------------------------------------------------------------------

// -- Opening of form and loading of favorites

function ShortName(name : WideString) : WideString;
begin
  if name[Length(name)] <> '\'
    then Result := WideExtractFileName(name)
    else
      begin
        // it's a folder
        Result := Copy(name, 1, Length(name) - 1);
        Result := WideExtractFileName(Result)
      end;
end;

procedure TfmFavorites.FormShow(Sender: TObject);
var
  i : integer;
  s : string;
begin
  Caption := AppName + ' - ' + U('Favorites');
  TranslateForm(Self);

  ListBox.Items.Clear;
  FullNames.Clear;
  
  with fmMain.IniFile do
    for i := 0 to MaxInt do
      begin
        s := ReadString('Favorites', IntToStr(i+1), '');
        if s = ''
          then break;
        ListBox.Items.Add(ShortName(UTF8Decode(s)));
        FullNames.Add(s)
    end;
  ListBox.ItemIndex := LastItem;
  ListBoxClick(Sender)
end;

// -- Close button: close form and save favorites

procedure TfmFavorites.btCloseClick(Sender: TObject);
var
  i : integer;
begin
  with fmMain.IniFile do
    begin
      // erase section and fill it again with current list
      EraseSection('Favorites');
      for i := 0 to FullNames.Count - 1 do
        WriteString('Favorites', IntToStr(i+1), FullNames[i]);

      UpdateFile
    end;
  Close
end;

// -- Cancel button

procedure TfmFavorites.btCancelClick(Sender: TObject);
begin
  Close
end;

// -- Open button

procedure TfmFavorites.btOpenClick(Sender: TObject);
var
  name : WideString;
begin
  if ListBox.ItemIndex = -1
    then exit;

  btCloseClick(Sender);

  name := lbFullName.Caption;

  if name[Length(name)] = '\'
    then DoMainOpenFolder(name, 1, '')
    else DoMainOpen('', name, 1, '')
end;

// -- Click in list: selection of favorite

procedure TfmFavorites.ListBoxClick(Sender: TObject);
var
  i : integer;
begin
  i := ListBox.ItemIndex;
  if i < 0
    then exit;

  lbFullName.Caption := UTF8Decode(FullNames[i]);
  LastItem := i
end;

// -- Double click in list: opening of favorite

procedure TfmFavorites.ListBoxDblClick(Sender: TObject);
begin
  ListBoxClick(Sender);
  btOpenClick(Sender)
end;

// -- Add buttons

procedure TfmFavorites.btAddFileClick(Sender: TObject);
var
  filename : WideString;
begin
//  if OpenDialog('Add favorite',
  if OpenFileOrDir('Add favorite',
                 WideExtractFilePath(ActiveView.si.FileName),
                 '',
                 'sgf',
                 U('SGF files') + ' (*.sgf)|*.sgf|' +
                 U('MGT files') + ' (*.mgt)|*.mgt|' +
                 U('All')       + '|*.*',
                 filename)
    then AddFile(filename)
end;

procedure TfmFavorites.btAddGameFileClick(Sender: TObject);
var
  filename : WideString;
begin
  if OpenDialog('Add favorite',
                WideExtractFilePath(ActiveView.si.FileName),
                '',
                'sgf',
                U('SGF files') + ' (*.sgf)|*.sgf|' +
                U('MGT files') + ' (*.mgt)|*.mgt|' +
                U('All')       + '|*.*',
                filename)
    then AddFile(filename)
end;

procedure TfmFavorites.btAddFolderClick(Sender: TObject);
var
  path : WideString;
begin
  path := WideExtractFilePath(ActiveView.si.FileName);
  if WideSelectDirectory(U('Add favorite'), '', path)
    then AddFile(WideIncludeTrailingPathDelimiter(path))
end;

procedure TfmFavorites.btAddDatabaseClick(Sender: TObject);
var
  filename : WideString;
begin
  if OpenDialog('Add favorite',
                ExtractFilePath(ActiveView.si.FileName),
                '',
                'db',
                U('Databases') + ' (*.db)|*.db|' +
                U('All')       + '|*.*',
                filename)
    then AddFile(filename)
end;

// -- Add current file button

procedure TfmFavorites.btAddCurrentClick(Sender: TObject);
var
  cancel : boolean;
begin
  if ActiveView.IsFile
    then
      begin
        SaveOrCancel(ActiveView, cancel);
        if cancel
          then // bye
          else AddFile(ActiveView.si.FileName)
      end;

  if ActiveView.IsDir
    then AddFile(WideIncludeTrailingPathDelimiter(ActiveView.si.FolderName));

  if ActiveView.IsDb
    then AddFile(ActiveView.si.DatabaseName)
end;

// -- Helper for adding favorite

procedure TfmFavorites.AddFile(name : WideString);
var
  s : string;
begin
  s := UTF8Encode(name);

  if FullNames.IndexOf(s) >= 0
    then exit;

  ListBox.Items.Add(ShortName(name));
  FullNames.Add(s);
  ListBox.ItemIndex := ListBox.Count - 1;

  lbFullName.Caption := name;
  LastItem := ListBox.ItemIndex
end;

// -- Up button

procedure TfmFavorites.btUpClick(Sender: TObject);
var
  i : integer;
begin
  with ListBox do
    begin
      i := ItemIndex;
      if i <= 0
        then exit;

      Items.Exchange(i, i - 1);
      FullNames.Exchange(i, i - 1);
      
      LastItem := ItemIndex
    end
end;

// -- Down button

procedure TfmFavorites.btDnClick(Sender: TObject);
var
  i : integer;
begin
  with ListBox do
    begin
      i := ItemIndex;
      if i = Count - 1
        then exit;

      Items.Exchange(i, i + 1);
      FullNames.Exchange(i, i + 1);

      LastItem := ItemIndex
    end
end;

// -- Remove button

procedure TfmFavorites.btRemoveClick(Sender: TObject);
var
  i : integer;
begin
  with ListBox do
    begin
      i := ItemIndex;
      Items.Delete(i);
      FullNames.Delete(i);
      if LastItem = Count
        then ItemIndex := Count - 1
        else ItemIndex := LastItem;
      lbFullName.Caption := '';
      ListBoxClick(Sender)
    end
end;

// -- Help button

procedure TfmFavorites.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_Favoris)
end;

// ---------------------------------------------------------------------------

end.
