// ---------------------------------------------------------------------------
// -- Drago -- Information preview frame --------------- UfrPreviewInfo.pas --
// ---------------------------------------------------------------------------

unit UfrPreviewInfo;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, Types,
  VirtualTrees,
  DefineUi, UViewMain, ImgList, TB2Dock, SpTBXItem, SpTBXDkPanels;

const MaxCol = 13;

// -- Virtual node data ------------------------------------------------------

// Node data is declared with the maximum number of strings. The actual size
// and the actual number will depend on the configuration of the columns.

type
  TNodeData = record
    strings : array[0 .. MaxCol - 1] of WideString
  end;
  PNodeData = ^TNodeData;

// -- Form -------------------------------------------------------------------

type
  TfrPreviewInfo = class(TFrame)
    ImageList: TImageList;
    Bevel1: TBevel;
    InfoGrid: TVirtualStringTree;
    constructor Create(aOwner, aParent : TComponent; aParentView : TViewMain);
    destructor Destroy; override;
    procedure FrameEnter(Sender: TObject);
    procedure InfoGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure InfoGridClick(Sender: TObject);
    procedure InfoGridDblClick(Sender: TObject);
    procedure InfoGridFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure InfoGridHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure InfoGridCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure InfoGridBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure InfoGridColumnResize(Sender: TVTHeader;
      Column: TColumnIndex);
  private
    View : TViewMain;
    ViewMode : TViewMode;
    Sorted  : array[0 .. MaxCol - 1] of integer;
    StringGridEmpty : boolean;
    function  NumberToDisplay : integer;
    procedure ConfigGrid;
    procedure ConfigGridDef(infoCol : string);
    procedure ConfigGridPb;
    procedure ConfigGridGm;
    procedure ConfigGridApply(nCol : integer; width : array of integer;
                              caption : array of string);
    procedure StoreGridDesc;
    procedure UpdateCurrentGame(node: PVirtualNode);
    procedure GetDataForGame(index : integer; out data : TWideStringDynArray);
    procedure FocusOnIndex(index : integer);
  public
    procedure DoWhenUpdating;
    procedure DoWhenShowing;
    function  UpdateNodeData(node: PVirtualNode) : PNodeData;
    function  GameOnRow(i : integer) : integer;
    function  GameInNode(node: PVirtualNode) : integer;
    function  ClickOnItem : boolean;
    procedure FirstGame;
    procedure LastGame;
    procedure PrevGame;
    procedure NextGame;
    procedure GotoGame(n : integer);
    procedure GameInfo;
    procedure UpdateAll;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std, VclUtils, Translate, UGameTree, Main, Properties,
  UMemo, UfmMsg, UStatus, UGMisc, UfmGameInfo;

{$R *.dfm}

// -- Constructor ------------------------------------------------------------

constructor TfrPreviewInfo.Create(aOwner, aParent : TComponent;
                                  aParentView : TViewMain);
begin
  if aOwner <> nil
    then inherited Create(aOwner)
    else assert(False, 'should not be nil');

  Parent := aParent as TWinControl;
  View := aParentView;
  Align := alClient;
  
  // fight against flickering
  AvoidFlickering([self])
end;

destructor TfrPreviewInfo.Destroy;
begin
  inherited Destroy
end;

// -- Display and update -----------------------------------------------------

procedure TfrPreviewInfo.DoWhenUpdating;
begin
  // initialize view mode
  ViewMode := View.si.ViewMode;

  // empty grid
  InfoGrid.NodeDataSize := sizeof(TNodeData);
  InfoGrid.Clear;
  InfoGrid.RootNodeCount := 0;

  // initialize columns and node data size according to number of columns
  ConfigGrid;

  // initialize number of elements
  InfoGrid.RootNodeCount := NumberToDisplay
end;

procedure TfrPreviewInfo.FrameEnter(Sender: TObject);
begin
  DoWhenShowing
end;

procedure TfrPreviewInfo.DoWhenShowing;
var
  index : integer;
begin
  if View = nil
    then exit;

  index := View.si.IndexTree - 1;

  if (index < 0) or (index >= InfoGrid.RootNodeCount)
    then exit
    else FocusOnIndex(index)
end;

// -- Configuration of grid --------------------------------------------------

// -- Entry point

procedure TfrPreviewInfo.ConfigGrid;
begin
  case View.si.ViewMode of
    vmInfo   : ConfigGridDef(Status.InfoCol);
    vmInfoGm : ConfigGridGm;
    vmInfoPb : ConfigGridPb;
  end
end;

// -- Default mode

const
  k1stWidth = 40;

procedure TfrPreviewInfo.ConfigGridDef(infoCol : string);
var
  n, i, w : integer;
  widthArray : array of integer;
  captionArray : array of string;
  noWidthDefined : boolean;
  pn : string;
begin
  // number of columns
  n := NthInt(infoCol, 1, ';');

  // something wrong, apply default
  if n = 0 then
    begin
      w := (ClientWidth - k1stWidth) div 5;

      ConfigGridApply(6,
                      [k1stWidth, w, w, w, w, w - 3],
                      ['#', 'PB', 'PW', 'PC', 'DT', 'RE']);

      Status.InfoCol := '5;PB;;PW;;PC;;DT;;RE;;';
      exit
    end;

  SetLength(widthArray, n + 1);
  SetLength(captionArray, n + 1);
  noWidthDefined := True;

  captionArray[0] := '#';
  widthArray[0] := k1stWidth;

  for i := 1 to n do
    begin
      pn := NthWord(infoCol, (i - 1) * 2 + 2, ';');
      w  := Nthint (infoCol, (i - 1) * 2 + 3, ';');
      if w <> 0
        then noWidthDefined := False;
      captionArray[i] := pn;
      widthArray[i] := w
    end;

  // use default width if no width defined
  if noWidthDefined then
    begin
      w := (ClientWidth - k1stWidth) div n;
      for i := 1 to n do
        widthArray[i] := w
    end;

  ConfigGridApply(n + 1, widthArray, captionArray)
end;

// -- Game replay mode

procedure TfrPreviewInfo.ConfigGridGm;
const
  W = 46;
var
  l : integer;
begin
  l := (Width - 9 * W) div 5;
  ConfigGridApply(13, [W, l, l, l, l, l, W, W, W, W, W, W, W],
                  ['', 'Black', 'White', 'Place', 'Date', 'Result',
                   '#', 'GB', 'GW', 'G', 'FB', 'FW', 'F'])
end;

// -- Problem mode

procedure TfrPreviewInfo.ConfigGridPb;
begin
  ConfigGridApply(4,
                 [k1stWidth, 100, 100, 100],
                 ['#', 'Trials', 'Success', '%'])
end;

// -- Apply routine

procedure TfrPreviewInfo.ConfigGridApply(nCol : integer;
                                         width : array of integer;
                                         caption : array of string);
var
  i : integer;
  col : TVirtualTreeColumn;
begin
  // avoid to handle column sizing event while configuring
  InfoGrid.OnColumnResize := nil;

  InfoGrid.NodeDataSize := nCol * sizeof(WideString);

  InfoGrid.Header.Columns.Clear;

  for i := 0 to nCol - 1 do
    begin
      with InfoGrid.Header do
        begin
          col := Columns.Add;
          col.Width := width[i];
          col.ImageIndex := iff(NumberToDisplay > Status.SortLimit, -1, 0);
          col.Spacing := 12;
          col.Options := [coAllowClick, coEnabled, coParentBidiMode,
                          coParentColor, coResizable, coShowDropMark, coVisible];
          if ViewMode = vmInfo
            then
              if i = 0
                then col.Text := caption[i]
                else col.Text := U(FindPropText(caption[i]))
            else col.Text := U(caption[i])
        end;

      Sorted[i] := 0
    end;

  // restore column sizing event
  InfoGrid.OnColumnResize := InfoGridColumnResize
end;

// -- Storage of grid config
//
// Note: Grid configuration is saved when a column is resized.

procedure TfrPreviewInfo.StoreGridDesc;
var
  desc, s : string;
  i : integer;
begin
  // save column settings only for default mode
  if ViewMode <> vmInfo
    then exit;

  desc := Settings.InfoCol;

  s := NthWord(desc, 1, ';');
  for i := 1 to InfoGrid.Header.Columns.Count - 1 do
    begin
      s := s + ';' + NthWord(desc, (i - 1) * 2 + 2, ';');
      s := s + ';' + IntToStr(InfoGrid.Header.Columns[i].Width)
    end;

  Settings.InfoCol := s
end;

// -- Access to SGF collection data ------------------------------------------

// -- Access to collection

procedure TfrPreviewInfo.GetDataForGame(index : integer;
                                        out data : TWideStringDynArray);
var
  gt : TGameTree;
  i, n, nOk : integer;
  pn, s, s1, s2 : string;
begin
  gt := View.cl[index]; //todo: root ?

  case ViewMode of
    vmInfo : // Game information view
      begin
        SetLength(data, NthInt(Status.InfoCol, 1, ';') + 1);
        data[0] := Format('%5d', [index]);

        for i := 1 to NthInt(Status.InfoCol, 1, ';') do
          begin
            pn := NthWord(Status.InfoCol, i * 2, ';');
            data[i] := DecodeProperty(PropertyIndex(pn), gt, View.si)
          end
        end;

    vmInfoGm : // Replay
      begin
        SetLength(data, 13);
        data[0] := Format('%5d', [index]);

        s := '5;PB;;PW;;PC;;DT;;RE;;';
        for i := 1 to NthInt(s, 1, ';') do
          begin
            pn := NthWord(s, i * 2, ';');
            data[i] := DecodeProperty(PropertyIndex(pn), gt, View.si)
          end;
        s := GetGmNth(index);
        for i := 1 to 7 do
          data[5 + i] := Format('%4s', [NthWord(s, i, ' ')])
      end;

    vmInfoPb : // Problems
      begin
        SetLength(data, 4);
        data[0] := Format('%5d', [index]);

        s := GetPbNth(index);
        s1 := NthWord(s, 1, ' ');
        s2 := NthWord(s, 2, ' ');
        n   := StrToIntDef(s1, 0);
        nOk := StrToIntDef(s2, 0);

        data[1] := Format('%4s', [s1]);
        data[2] := Format('%4s', [s2]);
        if n = 0
          then data[3] := Format('%4s', [''])
          else data[3] := Format('%4s', [IntToStr(nOk * 100 div n)])
      end
  end;

  //View.cl.Reset(index)
end;

// -- Update of VTV data

function TfrPreviewInfo.UpdateNodeData(node: PVirtualNode) : PNodeData;
var
  data : PNodeData;
  strings : TWideStringDynArray;
  i : integer;
begin
  data := InfoGrid.GetNodeData(node);

  if Assigned(data) and (data.Strings[0] = '') then
    begin
      GetDataForGame(node.Index + 1, strings);
      for i := 0 to High(strings) do
        data.Strings[i] := strings[i]
    end;

  Result := data
end;

// -- Events -----------------------------------------------------------------

// -- Get text event

procedure TfrPreviewInfo.InfoGridGetText(Sender: TBaseVirtualTree;
                                         Node: PVirtualNode;
                                         Column: TColumnIndex;
                                         TextType: TVSTTextType;
                                         var CellText: WideString);
var
  data : PNodeData;
begin
  if Column < 0
    then exit;

  data := UpdateNodeData(Node);

  if data = nil
    then CellText := ''
    else CellText := data.Strings[Column]
end;

// -- Freeing event

procedure TfrPreviewInfo.InfoGridFreeNode(Sender: TBaseVirtualTree;
                                          Node: PVirtualNode);
var
  data : PNodeData;
  i : integer;
begin
  if Node = nil
    then exit;

  data := InfoGrid.GetNodeData(node);
  if data <> nil then
    begin
      for i := 0 to InfoGrid.Header.Columns.Count - 1 do
        Finalize(data.Strings[i])
    end
end;

// -- Drawing

procedure TfrPreviewInfo.InfoGridBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
begin
  if Odd(Node.Index)
    then TargetCanvas.Brush.Color := $FAFAFA
    else TargetCanvas.Brush.Color := clWindow;
    
  TargetCanvas.FillRect(CellRect)
end;

procedure TfrPreviewInfo.InfoGridColumnResize(Sender: TVTHeader;
  Column: TColumnIndex);
begin
  StoreGridDesc
end;

// -- Actions ----------------------------------------------------------------

procedure TfrPreviewInfo.UpdateCurrentGame(node: PVirtualNode);
var
  index : integer;
begin
  index := GameInNode(node);

  View.si.IndexTree := index;
  View.gt := View.cl[index];
  View.si.FileName  := View.cl.FileName[index];

  InfoGrid.FocusedNode := node;
  InfoGrid.Selected[node] := True
end;

// -- Control of click position

function TfrPreviewInfo.ClickOnItem : boolean;
var
  where : TPoint;
begin
  where  := InfoGrid.ScreenToClient(Mouse.CursorPos);
  Result := InfoGrid.GetNodeAt(where.X, where.Y) <> nil
end;

// -- Click on row

procedure TfrPreviewInfo.InfoGridClick(Sender: TObject);
var
  k : integer;
begin
  if not ClickOnItem
    then exit;

  UpdateCurrentGame(InfoGrid.FocusedNode);
  k := GameInNode(InfoGrid.FocusedNode);

  if Within(k, 1, View.cl.Count)
    then View.UpdateGameOnBoard(k)
end;

// -- Double click on row

procedure TfrPreviewInfo.InfoGridDblClick(Sender: TObject);
var
  k : integer;
begin
  if not ClickOnItem
    then exit;

  UpdateCurrentGame(InfoGrid.FocusedNode);
  k := GameInNode(InfoGrid.FocusedNode);

  if Within(k, 1, View.cl.Count)
    then View.ShowGameOnBoard(k)
end;

// -- Navigation between games

procedure TfrPreviewInfo.FirstGame;
begin
  UpdateCurrentGame(InfoGrid.GetFirst)
end;

procedure TfrPreviewInfo.LastGame;
begin
  UpdateCurrentGame(InfoGrid.GetLast)
end;

procedure TfrPreviewInfo.PrevGame;
begin
  with InfoGrid do
    if GetPrevious(FocusedNode) <> nil
      then UpdateCurrentGame(GetPrevious(FocusedNode))
end;

procedure TfrPreviewInfo.NextGame;
begin
  with InfoGrid do
    if GetNext(FocusedNode) <> nil
      then UpdateCurrentGame(GetNext(FocusedNode))
end;

procedure TfrPreviewInfo.GotoGame(n : integer);
begin
  FocusOnIndex(n - 1)
end;

// -- Call to game info dialogue

procedure TfrPreviewInfo.GameInfo;
var
  r : boolean;
  data : PNodeData;
begin
  r := TfmGameInfo.Execute(View.gt, not View.si.ReadOnly);
  if not r
    then exit;

  // force update of the current node
  data := InfoGrid.GetNodeData(InfoGrid.FocusedNode);
  data.Strings[0] := ''
end;

// -- Sort -------------------------------------------------------------------

// -- Header click event

procedure TfrPreviewInfo.InfoGridHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
  X,Y: Integer);
begin
  // handle sorting limitation
  if (NumberToDisplay > Settings.SortLimit) and Settings.WarnWhenSort then
    begin
      MessageDialog(msOk, imExclam,
                    [WideFormat(U('Sorting is not enabled over %d records.'),
                                [Settings.SortLimit]),
                     U('See Options | Preview to change this setting.')],
                     Settings.WarnWhenSort);
      exit
    end;

  // update all records in grid
  UpdateAll;

  // change sorting direction (0: not sorted, -1: descending, 1: ascending)
  if Sorted[Column] <= 0
    then InfoGrid.SortTree(Column, sdAscending, False)
    else InfoGrid.SortTree(Column, sdDescending, False);

  // store new sorting direction
  Sorted[Column] := iff(Sorted[Column] <= 0, 1, -1)
end;

// -- Comparison of nodes

procedure TfrPreviewInfo.InfoGridCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  data1, data2 : PNodeData;
begin
  data1 := PNodeData(Sender.GetNodeData(Node1));
  data2 := PNodeData(Sender.GetNodeData(Node2));

  Result := WideCompareStr(data1.strings[Column], data2.strings[Column])
end;

// -- Helpers ----------------------------------------------------------------

function TfrPreviewInfo.NumberToDisplay : integer;
begin
  Result := View.cl.Count
end;

function TfrPreviewInfo.GameOnRow(i : integer) : integer;
begin
  //Result := StrToIntDef(Trim (InfoGrid.Items[i].Caption), 1)
end;

function TfrPreviewInfo.GameInNode (node: PVirtualNode) : integer;
var
  data : PNodeData;
begin
  data := UpdateNodeData (Node);

  if data = nil
    then Result := 0
    else Result := StrToIntDef (Trim (data.Strings[0]), 1)
end;

// -- Focusing a node giving its index

// Notes:
// . It seems there is no way to avoid iterating from the root
// . fmMain.SetFocusedControl is not equivalent to InfoGrid.SetFocus (which
//   can give an "impossible to focus" error

procedure TfrPreviewInfo.FocusOnIndex (index : integer);
var
  node : PVirtualNode;
begin
  node := InfoGrid.GetFirst;
  while Assigned (node) and (node.Index < index) do
    node := InfoGrid.GetNextNoInit (node);

  if Assigned (node) and (node.Index = index) then
    begin
      InfoGrid.FocusedNode := node;
      fmMain.SetFocusedControl (InfoGrid);
      InfoGrid.ScrollIntoView (node, True);
      InfoGrid.Selected[node] := True
    end;
end;

// -- Updating of all nodes

procedure TfrPreviewInfo.UpdateAll;
var
  node : PVirtualNode;
begin
  node := InfoGrid.GetFirst;
  while Assigned (node) do
    begin
      UpdateNodeData (node);
      node := InfoGrid.GetNext (node)
    end
end;

// ---------------------------------------------------------------------------

end.
