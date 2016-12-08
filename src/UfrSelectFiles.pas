unit UfrSelectFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, TntStdCtrls, Grids, TntGrids, SpTBXItem, SpTBXControls,
  ClassesEx, ImgList, TntGraphics;

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
  TfrSelectFiles = class(TFrame)
    GroupBox2: TTntGroupBox;
    lbDummy: TLabel;
    lbPath: TTntLabel;
    btCheckAll: TTntButton;
    btClearAll: TTntButton;
    cbSubDirs: TSpTBXCheckBox;
    StringGrid: TTntStringGrid;
    edPath: TTntEdit;
    ImageList: TImageList;
    procedure edPathChange(Sender: TObject);
    procedure StringGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure StringGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btCheckAllClick(Sender: TObject);
    procedure btClearAllClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    FStringList : TWideStringList;
    FCurrentDir : WideString;
    FFolderDown : integer;
  public
    InitialDir : WideString;
    procedure FormCreate(Sender: TObject);
    destructor Destroy; override;
    procedure FrameShow(Sender: TObject);
    procedure ListOfUnits;
    procedure ListFolder(dir : WideString);
    function  CurrentDir : WideString;
    function  ListOfSelectedFiles : TWideStringList;
    procedure FolderUp;
    procedure AddToList(name : WideString; isDir, updateIndex : boolean);
    procedure RemFromList(name : WideString; isDir : boolean);
  end;

implementation

{$R *.dfm}

uses
  UStatus, UnicodeUtils, SysUtilsEx, WinUtils;

const
  clMinimizeName = $505050;

// -- Allocation -------------------------------------------------------------

procedure TfrSelectFiles.FormCreate(Sender: TObject);
begin
  // use a case insensitive string list to compare filenames in list and
  // directory
  FStringList := TWideStringList.Create;
  FStringList.CaseSensitive := False;

  // must keep same order as listbox
  FStringList.Sorted := False;

  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
end;

destructor TfrSelectFiles.Destroy;
begin
  FStringList.Free;
  inherited Destroy
end;

// -- Display when entering --------------------------------------------------

procedure TfrSelectFiles.FrameShow(Sender: TObject);
begin
  StringGrid.FixedCols := 2;
  StringGrid.ColWidths[0] := 18;
  StringGrid.ColWidths[1] := 18;
  StringGrid.ColWidths[2] := StringGrid.ClientWidth - (18 + 18);
  edPath.Visible := True;
  edPath.Font.Color := clBlack;

  ListFolder(InitialDir)
end;

// --

function TfrSelectFiles.CurrentDir : WideString;
begin
  Result := FCurrentDir
end;

// -- List of files

function TfrSelectFiles.ListOfSelectedFiles : TWideStringList;
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

procedure TfrSelectFiles.ListOfUnits;
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

procedure TfrSelectFiles.ListFolder(dir : WideString);
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

procedure TfrSelectFiles.FolderUp;
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

procedure TfrSelectFiles.edPathChange(Sender: TObject);
begin
  lbPath.Font.Color := clMinimizeName;
  lbPath.Caption := WideMinimizeName(edPath.Text, lbPath.Canvas, edPath.Width);

  if DirectoryExists(edPath.Text)
    then ListFolder(edPath.Text)
end;

// -- String grid events -----------------------------------------------------

// -- Mouse wheel down event

procedure TfrSelectFiles.StringGridMouseWheelDown(Sender: TObject;
                  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with StringGrid do
    if TopRow + VisibleRowCount < RowCount
      then TopRow := TopRow + 1
end;

// -- Mouse wheel up event

procedure TfrSelectFiles.StringGridMouseWheelUp(Sender: TObject;
                  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with StringGrid do
    if TopRow > 1
      then TopRow := TopRow - 1
end;

// -- Drawing of string grid cells

procedure TfrSelectFiles.StringGridDrawCell(Sender: TObject; ACol,
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

procedure TfrSelectFiles.StringGridMouseDown(Sender: TObject;
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

procedure TfrSelectFiles.StringGridMouseMove(Sender: TObject;
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

procedure TfrSelectFiles.btCheckAllClick(Sender: TObject);
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

procedure TfrSelectFiles.btClearAllClick(Sender: TObject);
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

procedure TfrSelectFiles.AddToList(name : WideString; isDir, updateIndex : boolean);
var
  i : integer;
begin
  if isDir
    then name := name + '\*.sgf';

  i := FStringList.IndexOf(name);
  if i >= 0
    then exit;
(*
  // keep FStringList and ListBox synchronized by removing lines added during
  // previous adding process
  if (FStringList.Count = 0) and (ListBox.Items.Count > 0)
    then ListBox.Clear;
*)
  FStringList.Add(name);
(*
  ListBox.Items.Add(WideMinimizeName(name, ListBox.Canvas, ListBox.ClientWidth));

  if updateIndex
    then ListBox.ItemIndex := ListBox.Count - 1
*)
end;

// -- Deleting an item

procedure TfrSelectFiles.RemFromList(name : WideString; isDir : boolean);
var
  i : integer;
begin
  if isDir
    then name := name + '\*.sgf';

  i := FStringList.IndexOf(name);
  if i < 0
    then exit;

  // ListBox.Items and FStringList are parallel, so can use same index
(*
  ListBox.Items.Delete(i);
*)
  FStringList.Delete(i)
end;

//

procedure TfrSelectFiles.FrameResize(Sender: TObject);
begin
  with StringGrid do
    ColWidths[2] := ClientWidth - (ColWidths[0] + ColWidths[1])
end;

end.
