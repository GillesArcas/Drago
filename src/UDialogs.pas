// ---------------------------------------------------------------------------
// -- Drago -- Calls to common dialogs ----------------------- UDialogs.pas --
// ---------------------------------------------------------------------------

unit UDialogs;

// ---------------------------------------------------------------------------

interface

uses
  Forms, Dialogs,
  TntDialogs, TntClasses,
  Translate;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    out aFileName : WideString) : boolean; overload;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    aFilterIndex : integer;
                    out aFileName : WideString) : boolean; overload;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    aFiles : TTntStringList) : boolean; overload;

function OpenFileOrDir(const aTitle, aDir, aName, aExt, aFilter : WideString;
                       out aFileName : WideString) : boolean;
                        
function SaveDialog(const aTitle : string;
                    const aDir, aName, aExt, aFilter : WideString;
                    overwritePrompt : boolean;
                    var aFileName : WideString) : boolean; overload;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, UStatus, SysUtilsEx;

// -- Open dialogs -----------------------------------------------------------

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    aFilterIndex : integer;
                    multiSelect : boolean;
                    fileOrDir : boolean;
                    out aFileName : WideString;
                    aFiles : TTntStringList) : boolean; overload;
var
  openDialog : TTntOpenDialog;
begin
  openDialog := TTntOpenDialog.Create(nil);

  with openDialog do
    try
      Title      := AppName + ' - ' + U(aTitle);
      InitialDir := aDir;
      if fileOrDir
        then FileName := 'Select folder or file'
        else FileName := aName;
      Filter      := aFilter;
      FilterIndex := aFilterIndex;
      DefaultExt  := aExt;

      Options := [ofEnableSizing, ofPathMustExist, ofHideReadOnly];
      if multiSelect
        then Options := Options + [ofAllowMultiSelect];

      if Settings.ShowPlacesBar
        then OptionsEx := []
        else OptionsEx := [ofExNoPlacesBar];

      Result := Execute;

      if Result = False
        then aFileName := ''
        else
          if WideExtractFileName(FileName) <> 'Select folder or file.sgf'
            then aFileName := FileName
            else aFileName := WideExtractFilePath(FileName);

      // beware the content of the list may be truncated when too much files
      // true with TOpenDialog as well
      if Result and multiSelect
        then aFiles.AddStrings(Files);

      // erase dialog ghost
      Application.ProcessMessages
    finally
      Free
    end
end;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    out aFileName : WideString) : boolean;
begin
  Result := OpenDialog(aTitle, aDir, aName, aExt, aFilter, 0, False, False, aFileName, nil)
end;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    aFilterIndex : integer;
                    out aFileName : WideString) : boolean;
begin
  Result := OpenDialog(aTitle, aDir, aName, aExt, aFilter, aFilterIndex, False, False, aFileName, nil)
end;

function OpenDialog(const aTitle, aDir, aName, aExt, aFilter : WideString;
                    aFiles : TTntStringList) : boolean;
var
  tmp : WideString;
begin
  Result := OpenDialog(aTitle, aDir, aName, aExt, aFilter, 0, True, False, tmp, aFiles)
end;

function OpenFileOrDir(const aTitle, aDir, aName, aExt, aFilter : WideString;
                       out aFileName : WideString) : boolean;
begin
  Result := OpenDialog(aTitle, aDir, aName, aExt, aFilter, 0, False, True, aFileName, nil)
end;

// -- Save dialogs -----------------------------------------------------------

function SaveDialog(const aTitle : string;
                    const aDir, aName, aExt, aFilter : WideString;
                    overwritePrompt : boolean;
                    var aFileName : WideString) : boolean;
var
  saveDialog : TTntSaveDialog;
begin
  saveDialog := TTntSaveDialog.Create(nil);

  with saveDialog do
    try
      Title      := AppName + ' - ' + U(aTitle);
      InitialDir := aDir;
      FileName   := aName;
      Filter     := aFilter;
      DefaultExt := aExt;

      if overwritePrompt
        then Options := [ofEnableSizing, ofPathMustExist, ofOverwritePrompt]
        else Options := [ofEnableSizing, ofPathMustExist];

      if Settings.ShowPlacesBar
        then OptionsEx := []
        else OptionsEx := [ofExNoPlacesBar];

      Result := Execute;

      if Result
        then aFileName := FileName
        else aFileName := '';

      // erase dialog ghost
      Application.ProcessMessages
    finally
      saveDialog.Free
    end
end;

// -- Modification of file ext in dialog -------------------------------------
//
// This was used at one time in fmPrint to change the extension of the file
// name when selecting a different extension. Perhaps worth to remind.

{$ifdef useit}

procedure TfmPrint.SaveDialogTypeChange(Sender: TObject);
var
  s : string;
begin
  s := ExtractFileName(SaveDialog.Filename);
  if Pos('wmf', SaveDialog.Filter) > 0
    then
      case SaveDialog.FilterIndex of
        1 : s := ChangeFileExt(s, '.wmf');
        2 : s := ChangeFileExt(s, '.gif');
      end
    else
      case SaveDialog.FilterIndex of
        1 : s := ChangeFileExt(s, '.rtf');
        2 : s := ChangeFileExt(s, '.htm');
      end;
  SetDlgItemText(GetParent(SaveDialog.Handle), cmb13, PChar(s))
end;

{$endif}

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------

