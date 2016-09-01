// ---------------------------------------------------------------------------
// -- Drago -- Information preview frame ---------------- UfrPreviewInfo.pas--
// ---------------------------------------------------------------------------

unit UfrPreviewInfo;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ComCtrls, ExtCtrls, ImgList, Types,
  TntSystem, TntGraphics, TntGrids, TntComCtrls,
  Define, UContext, UTViewBoard;

const maxCol = 13;

type
  TfrPreviewInfo = class(TFrame)
    ImageList: TImageList;
    Bevel1: TBevel;
    ListView: TTntListView;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure FrameEnter(Sender: TObject);
    procedure StringGridDblClick(Sender: TObject);
    procedure StringGridClick(Sender: TObject);
    procedure ListViewCustomDrawItem(Sender: TCustomListView;
       Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
       Selected: Boolean);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewData(Sender: TObject; Item: TListItem);
  private
    ViewMode : TViewMode;
    Sorted  : array[0 .. maxCol - 1] of integer;
    StringGridEmpty : boolean;
    procedure DoWhenCreating;
    function  NumberToDisplay : integer;
    procedure ConfigGrid(cx : TContext);
    procedure ConfigGridDef(infoCol : string);
    procedure ConfigGridPb;
    procedure ConfigGridGm;
    procedure ConfigGridApply(nCol : integer; width : array of integer;
                              caption : array of string);
    procedure StoreGridDesc;
    procedure UpdateCurrentGame(newRow : integer);
    procedure SortIndex(Acol : integer);
  public
    xgv : Tgview; // pointer on current gview
    procedure DoWhenUpdating;
    procedure DoWhenShowing;
    procedure GetData(ARow : integer); overload;
    procedure GetData(item : TListItem); overload;
    function  GameOnRow(i : integer) : integer;
    function  ClickOnItem : boolean;
    function  SelectedGame : integer;
    procedure FirstGame;
    procedure LastGame;
    procedure PrevGame;
    procedure NextGame;
    procedure GotoGame(n : integer);
    procedure GameInfo(Sender : TObject);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std, Translate, Ugtree, Ux2y, Main, UTView, Ugcom, Properties, UMemo,
  UfmMsg;

{$R *.dfm}

// -- Note on caching --------------------------------------------------------

// We avoid to load the complete listview by accessing only to the info
// values from the cells to display.

const EnableCaching = True;

// -- Constructor ------------------------------------------------------------

constructor TfrPreviewInfo.Create(aOwner : TComponent);
begin
  if aOwner <> nil
    then inherited Create(aOwner);

  // fight against flickering
  AvoidFlickering([self, ListView]);

  //DoWhenCreating;
  //ShowTextDef;

  //ListView.OwnerData := True
end;

procedure TfrPreviewInfo.DoWhenCreating;
begin
  //StringGrid.ColCount := maxCol
end;

destructor TfrPreviewInfo.Destroy;
begin
  inherited Destroy
end;

// -- Display and update -----------------------------------------------------

procedure TfrPreviewInfo.DoWhenUpdating;
var k : integer;
begin
  // link with context and store view mode
  xgv := ((Parent as TView).Tab as TTabSheetEx).gv;
  ViewMode := xgv.si.ViewMode;

  // settings of string grid
  MilliTimer;
  ListView.Clear; // TODO very time consuming
  (*
  for k := NumberToDisplay - 1 downto 0 do
    begin
      ListView.Selected := ListView.Items[k];
      ListView.DeleteSelected
    end;
  (**)
  (*
  ListView.Free;
  ListView := TTntListView.Create(self);
  ListView.Parent := self;
  ListView.Visible := True;
  ListView.Align := alClient;
  ListView.ViewStyle := vsReport;
  ListView.OwnerData := False;
  ListView.OnCustomDrawItem := ListViewCustomDrawItem;
  (**)
  Trace(Format('Clear list view : %d', [MilliTimer]));

  ConfigGrid(xgv.Context);

  // initialize 1st cell in row (to be tested when caching)
  if ListView.OwnerData then
    begin
      ListView.Items.Count := NumberToDisplay;
      exit
    end;
    
  for k := 1 to NumberToDisplay do
    with ListView.Items.Add do
    if EnableCaching
      then Caption := ''
      else GetData(k - 1)
end;

procedure TfrPreviewInfo.FrameEnter(Sender: TObject);
begin
  DoWhenShowing
end;

(*
procedure ScrollListItem(List:TListView; Item:TListItem);
begin
  if List.TopItem <> Item then
    List.Scroll(0, List.TopItem.Position.Y - Item.Position.TopItem.Y);
end;
*)

procedure TfrPreviewInfo.DoWhenShowing;
var i, n : integer;
begin
  if xgv = nil
    then exit;

  i := xgv.si.IndexTree - 1;
  if (i < 0) or (i > ListView.Items.Count - 1)
    then exit;

  (* help is wrong: TopItem is read only
  n := ListView.VisibleRowCount;
  if n = 0
    then ListView.TopItem := ListView.Items[i]
    else ListView.TopItem := ListView.Items[(i div n) * n];
  *)

  ListView.Items[i].Selected := True;
  ListView.Items[i].MakeVisible(True);

  // it's necessary to give focus to the view, otherwise selecting and item
  // after scrolling, just after displaying, does not select the right item.
  fmMain.SetFocusedControl(ListView);

  // note that this not equivalent to the next (which can give an impossible
  // to focus error
  //ListView.SetFocus;

  // not necessary
  //ListView.Items[i].Focused := True;

  // not necessary
  //if ListView.Visible and ListView.Enabled and ListView.CanFocus
  //  and (Parent <> nil)
  //  then ListView.SetFocus;
end;

// -- Settings of grid -------------------------------------------------------

procedure TfrPreviewInfo.ConfigGrid(cx : TContext);
begin
  case cx.si.ViewMode of
    vmInfo   : ConfigGridDef(cx.st.InfoCol);
    vmInfoGm : ConfigGridGm;
    vmInfoPb : ConfigGridPb;
  end
end;

// -- Default mode

const k1stWidth = 40;

procedure TfrPreviewInfo.ConfigGridDef(infoCol : string);
var
  n, l, i, w : integer;
  widthArray : array of integer;
  captionArray : array of string;
  atLessOneNot0 : boolean;
  pn : string;
begin
  n := NthInt(infoCol, 1, ';');
  if n = 0
    then
      begin
        // something wrong
        l := (ClientWidth - k1stWidth) div 5;

        ConfigGridApply(6,
                        [k1stWidth, l, l, l, l, l - 3],
                        ['#', 'PB', 'PW', 'PC', 'DT', 'RE']);

        xgv.st.InfoCol := '5;PB;;PW;;PC;;DT;;RE;;'
      end
    else
      begin
        l := (ClientWidth - k1stWidth) div n;

        SetLength(widthArray, n + 1);
        SetLength(captionArray, n + 1);
        atLessOneNot0 := False;

        captionArray[0] := '#';
        widthArray[0] := k1stWidth;

        for i := 1 to n do
          begin
            pn := NthWord(infoCol, (i - 1) * 2 + 2, ';');
            w  := Nthint (infoCol, (i - 1) * 2 + 3, ';');
            if w <> 0
              then atLessOneNot0 := True;
            captionArray[i] := pn;
            widthArray[i] := w
          end;

        if not atLessOneNot0 then
          for i := 1 to n do
            widthArray[i] := l;

        ConfigGridApply(n + 1, widthArray, captionArray)
      end
end;

// -- Problem mode

procedure TfrPreviewInfo.ConfigGridPb;
begin
  ConfigGridApply(4,
                 [30, 100, 100, 100],
                 ['#', 'Trials', 'Success', '%'])
end;

// -- Game replay mode

procedure TfrPreviewInfo.ConfigGridGm;
var l : integer;
begin
  l := (Width - 30 - 30 - 7*32) div 5;
  ConfigGridApply(13, [30, l, l, l, l, l, 32, 32, 32, 32, 32, 32, 30],
                  ['', 'Black', 'White', 'Place', 'Date', 'Result',
                   '#', 'GB', 'GW', 'G', 'FB', 'FW', 'F'])
end;

// -- Generic routine

procedure TfrPreviewInfo.ConfigGridApply(nCol : integer;
                                         width : array of integer;
                                         caption : array of string);
var
  i, w : integer;
  col : TTntListColumn;
begin
  ListView.Columns.Clear;

  for i := 0 to nCol - 1 do
    begin
      if i = 0
        then w := width[i] + 4
        else w := width[i] + 1;

      with ListView.Columns do
        begin
          col := Add;
          col.Width := w;
          col.ImageIndex := iff(NumberToDisplay > fmMain.st.SortLimit, -1, 0);

          if ViewMode = vmInfo
            then
              if i = 0
                then col.Caption := caption[i]
                else col.Caption := U(FindPropText(caption[i]))
            else col.Caption := U(caption[i])
        end;

      Sorted[i] := 0
    end
end;

// -- Storage of grid config

procedure TfrPreviewInfo.StoreGridDesc;
var
  desc, s : string;
  i : integer;
begin
  // save column settings only for default mode
  if ViewMode <> vmInfo
    then exit;

  desc := xgv.st.InfoCol;

  s := NthWord(desc, 1, ';');
  for i := 1 to ListView.Columns.Count - 1 do
    begin
      s := s + ';' + NthWord(desc, (i - 1) * 2 + 2, ';');
      s := s + ';' + IntToStr(ListView.Columns[i].Width)
    end;

  xgv.st.InfoCol := s
end;

// -- Draw cell event --------------------------------------------------------
//
// -- Owner draw enables caching

procedure TfrPreviewInfo.ListViewCustomDrawItem(Sender: TCustomListView;
          Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  // fill cells in row if required
  GetData(Item.Index);

  if Item.Selected
    then ListView.Canvas.Brush.Color := $B4B4B4
    else
      if Odd(Item.Index)
        then ListView.Canvas.Brush.Color := $FAFAFA
        else ListView.Canvas.Brush.Color := clWindow
end;

// -- Caching routine

procedure TfrPreviewInfo.ListViewData(Sender: TObject; Item: TListItem);
begin
  //Trace(Format('call item %d (%s)', [item.Index, item.Caption]));
  if item.Caption <> ''
    then exit;

  GetData(item)
  //;Trace(Format('data item %d (%s)', [item.Index, item.Caption]));
end;

procedure TfrPreviewInfo.GetData(item : TListItem);
var
  gt : Tgtree;
  i, n, nOk : integer;
  pn, s, s1, s2 : string;
  ARow : integer;
begin
  ARow := item.Index;

  // time to fill row, start with column creation
  for i := 0 to ListView.Columns.Count - 2 do
    item.SubItems.Add('');

  item.Caption := Format('%5d', [ARow + 1]);
  item.ImageIndex := -1;

  gt := xgv.cl[ARow + 1];

  case ViewMode of
    vmInfo :
      for i := 1 to NthInt(xgv.st.InfoCol, 1, ';') do
        begin
          pn := NthWord(xgv.st.InfoCol, i * 2, ';');
          item.SubItems[i - 1] := CPToWideString(pv2str(GetProp(gt, pn)))
        end;
    vmInfoGm :
      begin
        s := '5;PB;;PW;;PC;;DT;;RE;;';
        for i := 1 to NthInt(s, 1, ';') do
          begin
            pn := NthWord(s, i * 2, ';');
            item.SubItems[i - 1] := pv2strNoCRLF(GetProp(gt, pn))
          end;
        s := GetGmNth(ARow + 1);
        for i := 1 to 7 do
          item.SubItems[5+i - 1] := Format('%4s', [NthWord(s, i, ' ')])
      end;
    vmInfoPb :
      begin
        s := GetPbNth(ARow + 1);
        s1 := NthWord(s, 1, ' ');
        s2 := NthWord(s, 2, ' ');
        n   := StrToIntDef(s1, 0);
        nOk := StrToIntDef(s2, 0);

        item.SubItems[0] := Format('%4s', [s1]);
        item.SubItems[1] := Format('%4s', [s2]);
        if n = 0
          then item.SubItems[2] := Format('%4s', [''])
          else item.SubItems[3] := Format('%4s', [IntToStr(nOk * 100 div n)])
      end
  end
end;

procedure TfrPreviewInfo.GetData(ARow : integer);
var
  item : TTntListItem;
begin
  // use boolean to detect empty stringgrid (rowcount seems to refuse to be 0)
  // and avoid problems with caching on the extra row when should be empty.
  if StringGridEmpty
    then exit;

  if ARow + 1 > xgv.cl.nTree
    then exit;

  // test first column, if not empty there is nothing to do
  item := ListView.Items[ARow];
  if item.Caption  <> ''
    then exit;

  GetData(item)
end;

// -- Actions ----------------------------------------------------------------

procedure TfrPreviewInfo.UpdateCurrentGame(newRow : integer);
begin
  ListView.Items[newRow].Selected := True;
  ListView.Items[newRow].Focused  := True;
  GetData(newRow);
  xgv.si.IndexTree := GameOnRow(newRow);
  xgv.si.FileName  := xgv.cl.FileName[xgv.si.IndexTree];

  ListView.Update
end;

// -- Control of click position

function TfrPreviewInfo.ClickOnItem : boolean;
var
  where : TPoint;
begin
  where  := ListView.ScreenToClient(Mouse.CursorPos);
  Result := ListView.GetItemAt(where.X, where.Y) <> nil
end;

// -- Click on grid

procedure TfrPreviewInfo.StringGridClick(Sender: TObject);
begin
  if not ClickOnItem
    then exit;

  UpdateCurrentGame(ListView.ItemIndex);
end;

procedure TfrPreviewInfo.ListViewSelectItem(Sender: TObject;
                                           Item: TListItem; Selected: Boolean);
begin
  if ListView.ItemIndex >= 0
     then UpdateCurrentGame(ListView.ItemIndex)
end;

// -- Double click

procedure TfrPreviewInfo.StringGridDblClick(Sender: TObject);
var i : integer;
begin
  if not ClickOnItem
    then exit;

  ListView.ItemIndex := ListView.Selected.Index;
  i := SelectedGame;

  if i <= xgv.cl.nTree then
    begin
      ChangeEvent(xgv, i, seMain, snHit);
      fmMain.SelectView(vmBoard)
    end
end;

// -- Navigation between games

procedure TfrPreviewInfo.FirstGame;
begin
  UpdateCurrentGame(0)
end;

procedure TfrPreviewInfo.LastGame;
begin
  UpdateCurrentGame(ListView.Items.Count - 1)
end;

procedure TfrPreviewInfo.PrevGame;
begin
  if ListView.ItemIndex > 0
    then UpdateCurrentGame(ListView.ItemIndex - 1)
end;

procedure TfrPreviewInfo.NextGame;
begin
  if ListView.ItemIndex < NumberToDisplay - 1
    then UpdateCurrentGame(ListView.ItemIndex + 1)
end;

procedure TfrPreviewInfo.GotoGame(n : integer);
begin
  UpdateCurrentGame(n - 1)
end;

// -- Game information

procedure TfrPreviewInfo.GameInfo(Sender : TObject);
begin
end;

// -- Helpers ----------------------------------------------------------------

function TfrPreviewInfo.NumberToDisplay : integer;
begin
  Result := xgv.cl.nTree
end;

function TfrPreviewInfo.GameOnRow(i : integer) : integer;
begin
  Result := StrToIntDef(Trim(ListView.Items[i].Caption), 1)
end;

function TfrPreviewInfo.SelectedGame : integer;
begin
  Result := GameOnRow(ListView.ItemIndex)
end;

// -- Sort -------------------------------------------------------------------

procedure TfrPreviewInfo.ListViewColumnClick(Sender: TObject; Column: TListColumn);
begin
  if (NumberToDisplay > fmMain.st.SortLimit) and fmMain.st.WarnWhenSort then
    begin
      MessageDialog(msOk, imExclam,
                    [WideFormat(U('Sorting is not enabled over %d records.'),
                                [fmMain.st.SortLimit]),
                     U('See Options | Preview to change this setting.')],
                     fmMain.st.WarnWhenSort);
      exit
    end;

  SortIndex(Column.Index)
end;

procedure Reverse(list : TStringList);
var i : integer;
begin
   with list do
      begin
         for i := 0 to Count - 1 do
            if i >= Count - 1 - i
               then exit
               else Exchange(i, Count - 1 - i)
      end
end;

function CustomSortProc(item1, item2: TListItem; paramSort: integer): integer; stdcall;
begin
  Result := CompareText(item1.SubItems[paramSort],item2.SubItems[paramSort]);
end;

//procedure TForm1.Button1Click(Sender: TObject);
//begin
//  ListView1.CustomSort(@CustomSortProc, 0);
//end;

procedure TfrPreviewInfo.SortIndex(Acol : integer);
var
  list : TStringList;
  i, k : integer;
  s : string;
begin
  ListView.CustomSort(@CustomSortProc, Acol);
   (*
   list := TStringList.Create;

   for i := 0 to NumberToDisplay - 1 do
      begin
         GetData(i);
         s := StringGrid.Cells[Acol, i];

         // if s empty, add last ascii char to move empty strings to the end
         if (Trim(s) = '') and (Sorted[Acol] <= 0)
            then s := #255;

         list.Add(s + '@' + StringGrid.Rows[i].Text)
      end;

   list.Sort;

   for i := 0 to maxCol - 1 do
      if i <> Acol then Sorted[i] := 0;

   if Sorted[Acol] <= 0
      then Sorted[Acol] := 1
      else
         begin
            Sorted[Acol] := -1;
            Reverse(list)
         end;

   for i := 0 to NumberToDisplay - 1 do
      begin
         k := Pos('@', list[i]);
         s := Copy(list[i], k + 1, 10000);
         StringGrid.Rows[i].Text := s
      end;

   list.Free;

   //ActiveControl := StringGrid TOFIX
   *)
end;

// ---------------------------------------------------------------------------

begin
  // Avoid exception class EClassNotFound with message 'Class TStringGrid not found'
  // when changing StringGrid : TStringGrid to TTntStringGrid
  //RegisterClass(TStringGrid);
end.
