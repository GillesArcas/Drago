// ---------------------------------------------------------------------------
// -- Drago -- Form to create and add to database ---------- UfmAddToDB.pas --
// ---------------------------------------------------------------------------

unit UfmAddToDB;

// ---------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, FileCtrl, DateUtils,
  Buttons, ImgList, Grids,
  TntForms, TntStdCtrls, TntGraphics, TntClasses, ClassesEx,
  DefineUi, SpTBXControls, TntGrids, SpTBXItem;

const
  imCheckBox  = 0;
  imCheckBox2 = 1;
  imDocument  = 2;
  imFolder    = 3;
  imFolder2   = 4;
  imUnit      = 5;
  imUnit2     = 6;
  imFolderUp  = 7;
  imFolderUp2 = 8;

type
  TfmAddToDB = class(TTntForm)
    ProgressBar1: TProgressBar;
    ImageList: TImageList;
    ProgressBar2: TProgressBar;
    btStart: TTntButton;
    btClose: TTntButton;
    btHelp: TTntButton;
    btOptions: TTntButton;
    gbDBName: TTntGroupBox;
    sbDBName: TSpeedButton;
    GroupBox2: TTntGroupBox;
    lbDummy: TLabel;
    btCheckAll: TTntButton;
    btClearAll: TTntButton;
    cbSubDirs: TSpTBXCheckBox;
    lbDBName: TTntLabel;
    ListBox: TTntListBox;
    StringGrid: TTntStringGrid;
    lbPath: TTntLabel;
    edPath: TTntEdit;
    edDBName: TTntEdit;
    procedure FormShow(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure sbDBNameClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; State: TGridDrawState);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
    procedure StringGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
    MousePos: TPoint; var Handled: Boolean);
    procedure StringGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
    MousePos: TPoint; var Handled: Boolean);
    procedure btClearAllClick(Sender: TObject);
    procedure btCheckAllClick(Sender: TObject);
    procedure edDBNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btOptionsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure edPathChange(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
  private
    FName : WideString;
    fmode : TDBMode;
    FCurrentDir : WideString;
    FFolderDown : integer;
    FStringList : TWideStringList;
    StartPushed, UnderProcessing : boolean;
    procedure FormShowToCreate;
    procedure FormShowToAdd;
    procedure SaveListBox;
  public
    Abort : boolean;
    class procedure Execute(mode : TDBMode);
    destructor Destroy; override;
    procedure ListOfUnits;
    procedure ListFolder(dir : WideString);
    procedure FolderUp;
    procedure AddToList  (name : WideString; isDir, updateIndex : boolean);
    procedure RemFromList(name : WideString; isDir : boolean);
    function  ListOfSelectedFiles : TWideStringList;
    procedure WarningLabel(msg : WideString);
    procedure AddMessage(msg : WideString);
    procedure ReportError(msg, fn : WideString; single : boolean; index, count : integer);
  end;

var
  fmAddToDB: TfmAddToDB;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtilsEx,
  Define, Std, Main, UStatus, UDatabase, Translate, TranslateVCL, WinUtils, UActions,
  UGCom, HtmlHelpAPI, UfmMsg, UDialogs, UnicodeUtils, VclUtils, UViewMain;

{$R *.dfm}

const
  clMinimizeName = $505050;

function ActiveView : TViewMain;
begin
  result := fmMain.ActiveView
end;

// -- Display request --------------------------------------------------------

class procedure TfmAddToDB.Execute(mode : TDBMode);
begin
  if (mode = dbAddTo) and (ActiveView.kh = nil)
    then exit;

  fmAddToDB := TfmAddToDB.Create(Application);

  with fmAddToDB do
    try
      TranslateForm(fmAddToDB);
      FMode := mode;
      ShowModal;
      if StartPushed then
        begin
          // form is closed after completion
          fmMain.InvalidateView(vmAll);
          fmMain.SelectView(vmInfo);
          if ActiveView.cl.Count = 0
            then ActiveView.si.IndexTree := 0
            else ActiveView.si.IndexTree := 1
        end
    finally
      Release
    end
end;

// -- Allocation -------------------------------------------------------------

procedure TfmAddToDB.FormCreate(Sender: TObject);
begin
  // use a case insensitive string list to compare filenames in list and
  // directory
  FStringList := TWideStringList.Create;
  FStringList.CaseSensitive := False;

  // must keep same order as listbox
  FStringList.Sorted := False;

  // used to close correctly
  StartPushed := False;

  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
end;

destructor TfmAddToDB.Destroy;
begin
  FStringList.Free;
  inherited
end;

// -- Display when entering --------------------------------------------------

procedure TfmAddToDB.FormShow(Sender: TObject);
begin
  StringGrid.FixedCols := 2;
  StringGrid.ColWidths[0] := 18;
  StringGrid.ColWidths[1] := 18;
  StringGrid.ColWidths[2] := StringGrid.ClientWidth - (18 + 18);
  edPath.Visible := True;
  edPath.Font.Color := clBlack;
  btClose.Caption := U('Close');

  case FMode of
    dbCreate : FormShowToCreate;
    dbAddTo  : FormShowToAdd;
  end;

  //TODO: UNICODE DBAddFolder
  ListFolder(Settings.DBAddFolder)
end;

procedure TfmAddToDB.FormShowToCreate;
begin
  Caption := U('Create database...');
  gbDBName.Caption := U('Save as...');
  edDBName.Text    := '';
  lbDBName.Caption := '';
  edDBName.Enabled := True;
  sbDBName.Enabled := True
end;

procedure TfmAddToDB.FormShowToAdd;
begin
  Caption := U('Add to database...');
  gbDBName.Caption := U('Add to...');
  edDBName.Text    := ActiveView.si.DatabaseName;
  lbDBName.Caption := ActiveView.si.DatabaseName;
  edDBName.Enabled := False;
  sbDBName.Enabled := False
end;

// -- Handling of database name ----------------------------------------------

procedure TfmAddToDB.edDBNameChange(Sender: TObject);
begin
  FName := edDBName.Text;
  lbDBName.Font.Color := clMinimizeName;
  lbDBName.Caption := WideMinimizeName(edDBName.Text, lbDBName.Canvas,
                                       edDBName.Width + sbDBName.Width)
end;

procedure TfmAddToDB.sbDBNameClick(Sender: TObject);
var
  fileName : WideString;
begin
  if SaveDialog('Save database as',
                WideExtractFilePath(Settings.DBOpenFolder),
                '',
                'db',
                U('Database files') + ' (*.db)|*.db|',
                False,
                fileName)
    then edDBName.Text := fileName
end;

// -- Start event ------------------------------------------------------------

// -- Globals: dialog is modal, no possible conflict

var
  StartTime : double;
  FileCount : integer;
  PartialFileCount : integer; // number of files open so far
  PartialGameCount : integer; // number of games in files open so far

// -- Callback for progress display
//
// bar: 0, upper, 1, lower
// mode: 0, reset bar, 1, step

procedure UpdateDBProgressBar(bar, mode, n, processed : integer);
var
  t1, t2, totalGameEstimate, processedRatio : double;
begin
  with fmAddToDB do
    begin
      case mode of
        0 :
          begin
            if bar = 0 then
              begin
                ProgressBar1.Min := 0;
                ProgressBar1.Max := n
              end;
            ProgressBar2.Min := 0;
            ProgressBar2.Max := n
          end;
        1 :
          begin
            if bar = 0 then
              begin
                ProgressBar1.Position := n;
                ProgressBar2.Max := ProgressBar1.Max
              end;
            ProgressBar2.Position := n
          end;
      else
        // does nothing
      end;

      if (bar = 1) and ((mode = 0) or (mode = 2)) then
        begin
          inc(PartialFileCount);
          inc(PartialGameCount, n)
        end;

      if (processed > 0) and (processed mod 1000 = 0) then
        begin
          t1 := MilliSecondsBetween(StartTime, Now);

          // estimate not used...
          //totalGameEstimate := PartialGameCount + (FileCount - PartialFileCount) * (PartialGameCount / PartialFileCount);
          //processedRatio := processed / totalGameEstimate;
          //t2 := t1 / processedRatio;

          AddMessage(WideFormat(U('%d games processed, %s elapsed'),
                     [processed, ElapsedTimeToStr(t1)]));
        end;

      if processed mod 50 = 0
        then Application.ProcessMessages
        end
end;

// -- Event

procedure TfmAddToDB.btStartClick(Sender: TObject);
var
  fileList : TWideStringList;
  ok, dummy : boolean;
  T1 : double;
  n : integer;
begin
  // update FName (edDBName.Text is ok either from InputDialog or edDBName)
  FName := edDBName.Text;

  // check database name
  if FName = '' then
    begin
      ActiveControl := edDBName;
      lbDBName.Font.Color := clRed;
      lbDBName.Caption := U('Please give database name...');
      exit
    end;

  // add path if none
  FName := WideExpandFileName(FName);
  edDBName.Text := FName;

  // add extension if none
  if WideExtractFileExt(FName) = '' then
    begin
      FName := FName + '.db';
      edDBName.Text := FName
    end;

  // create if requested, and open it (append mode called from DB tab)
  if (FMode = dbCreate) and (IsOpenInTab('', FName, dummy) >= 0) then
    begin
      WarningLabel(U('Database open, please close first...'));
      exit
    end;

  // check if database already exists
  if DatabaseExists(FName) and (FMode = dbCreate) then
    if MessageDialog(msYesNo, imQuestion,
                     [WideFormat(U('%s already exists.'), [FName]),
                      U('Do you want to overwrite it?')]) = mrNo
      then exit;

  // create if requested, and open it (append mode called from DB tab)
  ok := True;
  if FMode = dbCreate then
    begin
      //TODO: UNICODE
      CreateDatabase(FName, ok);
      if ok
        then DoMainOpenDatabase(FName, 1, '', False, ok)
    end;

  // exit on open error
  if not ok
    then exit;

  // add files
  fileList := ListOfSelectedFiles;
  AddMessage(WideFormat(U('%d file(s) to process'), [fileList.Count]));
  ProgressBar1.Max := fileList.Count;
  ProgressBar2.Max := fileList.Count;
  ProgressBar1.Step := 1;
  ProgressBar2.Step := 1;
  FileCount := fileList.Count;
  PartialFileCount := 0;
  PartialGameCount := 0;

  // set up processing context
  UnderProcessing := True;
  btClose.Caption := U('Abort');
  if FMode = dbCreate
    then btStart.Enabled := False;
  Abort := False;
  StartPushed := True;
  StartTime := Now;

  // process
  AddListToDB(ActiveView, fileList, UpdateDBProgressBar);

  // restore selection context
  T1 := Now;
  UnderProcessing := False;
  btClose.Caption := U('Close');
  n := iff(abort, ProgressBar1.Position, fileList.Count);

  if abort
    then AddMessage('**** ' + U('Operation aborted by user'));

  AddMessage(WideFormat(U('%d file(s) processed, %s elapsed'),
                        [n, ElapsedTimeToStr(MilliSecondsBetween(StartTime, T1))]));
  ProgressBar1.Position := 0;
  ProgressBar2.Position := 0;

  // release working data and save path
  fileList.Free;
  Settings.DBAddFolder := edPath.Text;

  // start new event to restore tab if app is closed immediately
  if ActiveView.cl.Count > 0
    then ActiveView.ChangeEvent(1, seMain, snHit)
end;

// -- Esc

procedure TfmAddToDB.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key of
    VK_ESCAPE : Abort := True;
    ord('S')  : if ssCtrl in Shift
                  then SaveListBox
  end
end;

// -- Other buttons ----------------------------------------------------------

// -- Help

procedure TfmAddToDB.btHelpClick(Sender: TObject);
begin
  case FMode of
    dbCreate : HtmlHelpShowContext(IDH_Database_Create);
    dbAddTo  : HtmlHelpShowContext(IDH_Database_Update)
  end
end;

// -- Settings

procedure TfmAddToDB.btOptionsClick(Sender: TObject);
begin
  Actions.acDatabaseSettings.Execute
end;

// -- Closing

procedure TfmAddToDB.btCloseClick(Sender: TObject);
begin
  if UnderProcessing
    then Abort := True
    else ModalResult := mrOk
end;

// -- Warning label ----------------------------------------------------------

procedure TfmAddToDB.WarningLabel(msg : WideString);
var
  s : WideString;
  i : integer;
begin
  s := lbDBName.Caption;
  lbDBName.Font.Color := clRed;
  lbDBName.Caption := msg;
  for i := 1 to 30 do
    begin
      Application.ProcessMessages;
      Sleep(100)
    end;
  lbDBName.Font.Color := clMinimizeName;
  lbDBName.Caption := s
end;

// -- Adding messages to listbox ---------------------------------------------

// -- Adding simple message

procedure TfmAddToDB.AddMessage(msg : WideString);
begin
  ListBox.Items.Add(msg);
  ListBox.ItemIndex := ListBox.Count - 1
end;

// -- Adding error message

procedure TfmAddToDB.ReportError(msg, fn : WideString; single : boolean; index, count : integer);
var
  s : WideString;
begin
  if single
    then s := fn
    else s := Format('%s (%d/%d)', [fn, index, count]);
  s := WideMinimizeName(s, ListBox.Canvas, ListBox.ClientWidth - 5);

  AddMessage('** ' + msg + ':');
  AddMessage(s)
end;

// -- Writing in listbox -----------------------------------------------------

procedure TfmAddToDB.ListBoxDrawItem(Control: TWinControl; Index: Integer;
                                     Rect: TRect; State: TOwnerDrawState);
var
  s : WideString;
begin
  with ListBox.Canvas do
    begin
      Brush.Color := clWhite;
      FrameRect(Rect);

      s := ListBox.Items[Index];

      // rustic color selection
      case s[1] of
        '*' : Font.Color := clRed;
        ' ' : Font.Color := clHotLight;
        '0' .. '9' : Font.Color := clBlue
        else Font.Color := clBlack
      end
    end;

  WideCanvasTextOut(ListBox.Canvas, Rect.Left + 4, Rect.Top + 0, s)
end;

// -- Saving listbox content -------------------------------------------------

procedure TfmAddToDB.SaveListBox;
var
  fileName : WideString;
begin
  if SaveDialog('Save logfile',
                Status.AppPath,
                '',
                'txt',
                U('Text files') + ' (*.txt)|*.txt|',
                True,
                fileName)
    then ListBox.Items.SaveToFile(FileName)
end;

// == Handling of file/folder picker =========================================

// -- List of files

function TfmAddToDB.ListOfSelectedFiles : TWideStringList;
var
  i : integer;
  path, name : WideString;
begin
  Result := TWideStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  for i := 0 to FStringList.Count - 1 do
    if WidePos('*', FStringList[i], 1) = 0
      then Result.Add(FStringList[i])
      else
        begin
          path := WideExtractFilePath(FStringList[i]);
          name := WideExtractFileName(FStringList[i]);
          WideAddFolderToList(Result, path, name, cbSubDirs.Checked)
        end
end;

// -- List of units

procedure TfmAddToDB.ListOfUnits;
var
  units : string;
  i : integer;
begin
  FCurrentDir := '';
  FFolderDown := -1;
  edPath.Text := '';
  units := GetLogicalDrives;

  StringGrid.RowCount := Length(units);

  for i := 0 to Length(units) - 1 do
    begin
      StringGrid.Cells[0, i] := '-';
      StringGrid.Cells[1, i] := 'Unit';
      StringGrid.Cells[2, i] := units[i + 1] + ':'
    end
end;

// - List of folder

procedure ListOfFiles(path : WideString;
                      filter : string;
                      attrib : integer;
                      list : TWideStringList);
begin
  WideAddFilesToList(list, path, [afIncludeFiles], filter)
end;

procedure ListOfFolders(path : WideString;
                        filter : string;
                        attrib : integer;
                        list : TWideStringList);
begin
  WideAddFilesToList(list, path, [afIncludeFolders], filter)
end;

procedure TfmAddToDB.ListFolder(dir : WideString);
var
  n, i : integer;
  list : TWideStringList;
begin
  if WideDirectoryExists(dir)
    then FCurrentDir := dir
    else FCurrentDir := Status.AppPath;

  FFolderDown := -1;
  edPath.Text := FCurrentDir;

  list := TWideStringList.Create;
  list.Sorted := True;
  n := 0;
  StringGrid.RowCount := n + 1;

  StringGrid.Cells[0, 0] := '-';
  StringGrid.Cells[1, 0] := 'FolderUp';
  StringGrid.Cells[2, 0] := '..';

  // add folders to folder view
  list.Clear;
  WideAddFilesToList(list, FCurrentDir + '\', [afIncludeFolders], '*.*');

  for i:= 0 to list.Count - 1 do
    if (list[i] <> '.') and (list[i] <> '..') then
        begin
          inc(n);
          StringGrid.RowCount := n + 1;

          if FStringList.IndexOf(FCurrentDir + '\' + list[i] + '\*.sgf') < 0
            then StringGrid.Cells[0, n] := 'O'
            else StringGrid.Cells[0, n] := 'X';
          StringGrid.Cells[1, n] := 'Folder';
          StringGrid.Cells[2, n] := list[i]
        end;

  // add files to folder view
  list.Clear;
  WideAddFilesToList(list, FCurrentDir + '\', [afIncludeFiles], '*.sgf');

  for i:= 0 to list.Count - 1 do
    begin
      inc(n);
      StringGrid.RowCount := n + 1;

      if FStringList.IndexOf(FCurrentDir + '\' + list[i]) < 0
        then StringGrid.Cells[0, n] := 'O'
        else StringGrid.Cells[0, n] := 'X';
      StringGrid.Cells[1, n] := 'Document';
      StringGrid.Cells[2, n] := list[i]
    end;

  // adjust last col width according to presence of vertical scrollbar
  StringGrid.ColWidths[2] := StringGrid.ClientWidth - (18 + 18);

  list.Free
end;

// -- Moving up one level

function RevPos(c : WideChar; const str : WideString) : integer;
begin
  Result := Length(str);
  while (Result > 0) and (str[Result] <> c) do
    dec(Result)
end;

procedure TfmAddToDB.FolderUp;
var
  s : WideString;
  i : integer;
begin
  s := WideExcludeTrailingPathDelimiter(FCurrentDir);

  i := RevPos('/', s);
  if i = 0
    then i := RevPos('\', s);

  if i = 0
    then ListOfUnits
    else ListFolder(Copy(s, 1, i - 1))
end;

// -- Edit box events --------------------------------------------------------

procedure TfmAddToDB.edPathChange(Sender: TObject);
begin
  lbPath.Font.Color := clMinimizeName;
  lbPath.Caption := WideMinimizeName(edPath.Text, lbPath.Canvas, edPath.Width);

  if DirectoryExists(edPath.Text)
    then ListFolder(edPath.Text)
end;

// -- String grid events -----------------------------------------------------

// -- Mouse wheel down event

procedure TfmAddToDB.StringGridMouseWheelDown(Sender: TObject;
                  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with StringGrid do
    if TopRow + VisibleRowCount < RowCount
      then TopRow := TopRow + 1
end;

// -- Mouse wheel up event

procedure TfmAddToDB.StringGridMouseWheelUp(Sender: TObject;
                  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with StringGrid do
    if TopRow > 1
      then TopRow := TopRow - 1
end;

// -- Drawing of string grid cells

procedure TfmAddToDB.StringGridDrawCell(Sender: TObject; ACol,
                  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  val : WideString;
  index : integer;
begin
  val := StringGrid.Cells[ACol, ARow];

  StringGrid.Canvas.Brush.Color := clWhite;
  StringGrid.Canvas.FillRect(rect);

  case ACol of
  0 : // checkbox
    begin
      case val[1] of
        'O' : index := imCheckBox;
        'X' : index := imCheckBox2;
        else exit
      end;
      ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, index)
    end;
  1 : // folder icon
    begin
      if val = 'FolderUp'
        then index := imFolderUp
      else if val = 'Unit'
        then index := imUnit
      else if val = 'Folder'
        then index := imFolder
        else index := imDocument;
      ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, index)
    end;
  2 : // folder of file name
    begin
      WideCanvasTextOut(StringGrid.Canvas, rect.Left + 4, rect.Top + 2, val)
    end
  end
end;

// -- Clicking on the string grid

procedure TfmAddToDB.StringGridMouseDown(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col, row : integer;
  Val : string;
begin
  StringGrid.MouseToCell(X, Y, col, row);
  if (col < 0) or (row < 0)
    then exit;

  val := StringGrid.Cells[col, row];

  // checkbox
  if col = 0 then
    begin
      case val[1] of
      '-' : exit;
      'O' :
        begin
          StringGrid.Cells[col, row] := 'X';
          AddToList(FCurrentDir + '\' + StringGrid.Cells[2, row],
                          StringGrid.Cells[1, row] = 'Folder', True)
        end;
      'X' :
        begin
          StringGrid.Cells[col, row] := 'O';
          RemFromList(FCurrentDir + '\' + StringGrid.Cells[2, row],
                          StringGrid.Cells[1, row] = 'Folder')
        end
      end
    end;

  // folder icon
  if col = 1 then
    begin
      if val = 'FolderUp'
        then FolderUp
      else if val = 'Unit'
        then ListFolder(WideIncludeTrailingPathDelimiter(StringGrid.Cells[2, row]))
      else if val = 'Folder'
        then ListFolder(WideIncludeTrailingPathDelimiter(FCurrentDir) + StringGrid.Cells[2, row]);
    end
end;

// -- Moving the mouse over the grid : handle focus on buttons

procedure TfmAddToDB.StringGridMouseMove(Sender: TObject;
                                         Shift: TShiftState; X, Y: Integer);
var
  col, row : integer;
  rect : TRect;
begin
  StringGrid.MouseToCell(X, Y, col, row);

  // no folder icon down
  if FFolderDown < 0
    then
      begin
        if (col = 1) and (StringGrid.Cells[1, row] = 'FolderUp') then
          begin
            rect := StringGrid.CellRect(col, row);
            StringGrid.Canvas.Brush.Color := clWhite;
            StringGrid.Canvas.FillRect(rect);
            ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, imFolderUp2);
            FFolderDown := row
          end;
        if (col = 1) and (StringGrid.Cells[1, row] = 'Folder') then
          begin
            rect := StringGrid.CellRect(col, row);
            StringGrid.Canvas.Brush.Color := clWhite;
            StringGrid.Canvas.FillRect(rect);
            ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, imFolder2);
            FFolderDown := row
          end
      end
  else
    begin
      if (FFolderDown = row) and (col = 1)
        then exit;
      if StringGrid.Cells[1, FFolderDown] = 'FolderUp' then
        begin
          rect := StringGrid.CellRect(1, FFolderDown);
          StringGrid.Canvas.Brush.Color := clWhite;
          StringGrid.Canvas.FillRect(rect);
          ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, imFolderUp);
          FFolderDown := -1;
          exit
        end;
      if StringGrid.Cells[1, FFolderDown] = 'Folder' then
        begin
          rect := StringGrid.CellRect(1, FFolderDown);
          StringGrid.Canvas.Brush.Color := clWhite;
          StringGrid.Canvas.FillRect(rect);
          ImageList.Draw(StringGrid.Canvas, rect.Left, rect.Top, imFolder);
          FFolderDown := -1
        end
    end
end;

// -- Button events ----------------------------------------------------------

// -- Check all button

procedure TfmAddToDB.btCheckAllClick(Sender: TObject);
var
  row : integer;
  typ : string;
begin
  for row := 1 to StringGrid.RowCount - 1 do
    begin
      typ := StringGrid.Cells[1, row];

      if (typ = 'Folder') or (typ = 'Document') then
        begin
          StringGrid.Cells[0, row] := 'X';
          AddToList(FCurrentDir + '\' + StringGrid.Cells[2, row],
                    StringGrid.Cells[1, row] = 'Folder',
                    row = StringGrid.RowCount - 1)
        end
    end
end;

// -- Clear all button

procedure TfmAddToDB.btClearAllClick(Sender: TObject);
var
  row : integer;
  typ : string;
begin
  for row := 1 to StringGrid.RowCount - 1 do
    begin
      typ := StringGrid.Cells[1, row];

      if (typ = 'Folder') or (typ = 'Document') then
        begin
          StringGrid.Cells[0, row] := 'O';
          RemFromList(FCurrentDir + '\' + StringGrid.Cells[2, row],
                      StringGrid.Cells[1, row] = 'Folder')
        end
    end
end;

// -- Operations on list -----------------------------------------------------

// -- Adding an item

procedure TfmAddToDB.AddToList(name : WideString; isDir, updateIndex : boolean);
var
  i : integer;
begin
  if isDir
    then name := name + '\*.sgf';

  i := FStringList.IndexOf(name);
  if i >= 0
    then exit;

  // keep FStringList and ListBox synchronized by removing lines added during
  // previous adding process
  if (FStringList.Count = 0) and (ListBox.Items.Count > 0)
    then ListBox.Clear;

  FStringList.Add(name);
  ListBox.Items.Add(WideMinimizeName(name, ListBox.Canvas, ListBox.ClientWidth));

  if updateIndex
    then ListBox.ItemIndex := ListBox.Count - 1
end;

// -- Deleting an item

procedure TfmAddToDB.RemFromList(name : WideString; isDir : boolean);
var
  i : integer;
begin
  if isDir
    then name := name + '\*.sgf';

  i := FStringList.IndexOf(name);
  if i < 0
    then exit;

  // ListBox.Items and FStringList are parallel, so can use same index
  ListBox.Items.Delete(i);
  FStringList.Delete(i)
end;

// ---------------------------------------------------------------------------

end.
