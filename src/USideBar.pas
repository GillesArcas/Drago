// ---------------------------------------------------------------------------
// -- Drago -- Side bar handling ----------------------------- USideBar.pas --
// ---------------------------------------------------------------------------

unit USideBar;

// ---------------------------------------------------------------------------

interface

uses
  Classes, IniFiles,
  SpTBXDkPanels;

type
  TPanelDescriptor = class
  private
    FDp : TSpTBXDockablePanel;
    FName : string;
    FTop : integer;
    FHeight : integer;
    FVisible : boolean;
    FMinimized : boolean;
    FFixedSize : boolean;
    FDefaultOrder : integer;
    FPadding : boolean;
  public
    constructor Create(dp : TSpTBXDockablePanel);
    function IsResizable : boolean;
  end;

type
  TDockPanelLayout = class
  private
    FDock : TSpTBXMultiDock;
    FSupport : TComponent;
    FLayout : TList;
    procedure Clear;
    procedure GetLayout;
    procedure SetLayout;
    procedure SortLayout;
    function  NumberOfResizablePanels : integer;
    function  ResizableHeight : integer;
    procedure AdjustHeight(pd : TPanelDescriptor);
    procedure AdjustAllTops;
    procedure MakeSameHeight;
    procedure MakeProportionalPlaceFor(pd : TPanelDescriptor);
    procedure UseProportionalPlaceFrom(pd : TPanelDescriptor);
    function  PanelDescriptor(dp : TSpTBXDockablePanel) : TPanelDescriptor;
    procedure PutPanelAtPos(pd : TPanelDescriptor; pos : integer);
    function  Nth(i : integer) : TPanelDescriptor;
    function  DefaultPosition(dp : TSpTBXDockablePanel) : integer;
    procedure SaveToFile(filename : string);
    procedure UpdatePadding;
  public
    constructor Create(owner : TSpTBXMultiDock; support : TComponent);
    destructor Destroy; override;
    procedure InitLayout(adps : array of TSpTBXDockablePanel);
    procedure InitDefaultOrder(adps : array of TSpTBXDockablePanel);
    procedure InitFixedSize(adps : array of TSpTBXDockablePanel);
    procedure ShowPanelAtPos(dp : TSpTBXDockablePanel; pos : integer);
    procedure ShowPanelAtDefaultPos(dp : TSpTBXDockablePanel);
    procedure ChangeFixedSize(dp : TSpTBXDockablePanel; newSize : integer);
    procedure HidePanel(dp : TSpTBXDockablePanel);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Forms, Std;

// -- Panel descriptor -------------------------------------------------------

constructor TPanelDescriptor.Create(dp : TSpTBXDockablePanel);
begin
  FDp        := dp;
  FName      := dp.Name;
  FTop       := dp.DockPos;
  FHeight    := iff(dp.FixedDockedSize, dp.Tag, dp.EFfectiveHeight);
  FVisible   := dp.Visible;
  FMinimized := dp.Minimized;
  FFixedSize := dp.FixedDockedSize
end;

function TPanelDescriptor.IsResizable : boolean;
begin
  Result := FVisible and (not FMinimized) and (not FFixedSize)
end;

// -- TDockPanelLayout -------------------------------------------------------

// public
constructor TDockPanelLayout.Create(owner : TSpTBXMultiDock; support : TComponent);
begin
  FDock := owner;
  FSupport := support;
  FLayout := TList.Create;
end;

// public
destructor TDockPanelLayout.Destroy;
begin
  Clear;
  FLayout.Free
end;

// private
procedure TDockPanelLayout.Clear;
var
  i : integer;
begin
  for i := 0 to FLayout.Count - 1 do
    Nth(i).Free;
  FLayout.Clear
end;

// private
function TDockPanelLayout.Nth(i : integer) : TPanelDescriptor;
begin
  Result := TPanelDescriptor(FLayout[i])
end;

// private
function TDockPanelLayout.PanelDescriptor(dp : TSpTBXDockablePanel) : TPanelDescriptor;
var
  i : integer;
begin
  for i := 0 to FLayout.Count - 1 do
    if dp = Nth(i).FDp then
      begin
        Result := Nth(i);
        exit
      end;
  Result := nil
end;

// Sort list of panels according to top position

function PanelCompare(p1, p2 : pointer) : integer;
var
  pd1, pd2 : TPanelDescriptor;
begin
  pd1 := TPanelDescriptor(p1);
  pd2 := TPanelDescriptor(p2);

  if pd1.FTop = pd2.FTop
    then Result := pd1.FDefaultOrder - pd2.FDefaultOrder
    else Result := pd1.FTop - pd2.FTop
end;

// private
procedure TDockPanelLayout.SortLayout;
begin
  FLayout.Sort(PanelCompare)
end;

// private
procedure TDockPanelLayout.GetLayout;
var
  i : integer;
begin
  for i := 0 to FLayout.Count - 1 do
    begin
      Nth(i).FTop     := Nth(i).FDp.DockPos;
      Nth(i).FHeight  := iff(Nth(i).FFixedSize,
                             Nth(i).FDp.Tag,
                             Nth(i).FDp.Height);
      Nth(i).FVisible := Nth(i).FDp.Visible
    end
end;

// Although it is the recommended way, it does not give always the expected result.
// At creation of sidebar for instance, order is wrong (2009/06/28)
{.$define StandardSetLayout}

// alternate solution ...
{$define IniFileSetLayout}

{$ifdef StandardSetLayout}
// private
procedure TDockPanelLayout.SetLayout;
var
  i, h : integer;
  pd : TPanelDescriptor;
begin
  LockControl(FDock, True);
  FDock.BeginUpdate;

  try
    for i := 0 to FLayout.Count - 1 do
      begin
        pd := Nth(i);
        h := iff(pd.FFixedSize, pd.FDp.Tag, pd.FHeight);

        pd.FDp.DockPos := pd.FTop;
        pd.FDp.Height  := h;
        pd.FDp.Visible := pd.FVisible
      end;
    FDock.UpdateDockablePanelsDockPos;
  finally
    FDock.EndUpdate;
    LockControl(FDock, False)
  end;
end;
{$endif}

{$ifdef IniFileSetLayout}
// private
procedure TDockPanelLayout.SetLayout;
var
  FInifile : TMemIniFile;
  i, h : integer;
  pd : TPanelDescriptor;
  ini_name : String;
begin
  // name is irrelevant as meminifile is not updated ie not saved on disk 
  ini_name := '';

  FInifile := TMemIniFile.Create(ini_name);
  SpTBIniSavePositions(FSupport, FInifile, '');

  for i := 0 to FLayout.Count - 1 do
    begin
      pd := Nth(i);
      h := iff(pd.FFixedSize, pd.FDp.Tag, pd.FHeight);

      FInifile.WriteInteger(pd.FName, 'DockPos', pd.FTop);
      FInifile.WriteInteger(pd.FName, 'ClientHeight', h);
      FInifile.WriteBool   (pd.FName, 'Visible', pd.FVisible);
    end;

  SpTBIniLoadPositions(FSupport, FInifile, '');
  FIniFile.Free
end;
{$endif}

// last panel must be the padding panel

// public
procedure TDockPanelLayout.InitDefaultOrder(adps : array of TSpTBXDockablePanel);
var
  i : integer;
  pd : TPanelDescriptor;
begin
  Clear;
  for i := 0 to High(adps) do
    begin
      pd := TPanelDescriptor.Create(adps[i]);
      pd.FDefaultOrder := i;
      pd.FVisible := False;
      pd.FPadding := (i = High(adps));
      FLayout.Add(pd)
    end
end;

// public
procedure TDockPanelLayout.InitFixedSize(adps : array of TSpTBXDockablePanel);
var
  i : integer;
  //pd : TPanelDescriptor;
begin
  for i := 0 to High(adps) do
    begin
      //pd := PanelDescriptor(adps[i]);
      adps[i].Tag := adps[i].Height;
      adps[i].FixedDockedSize := True
    end
end;

// public
procedure TDockPanelLayout.InitLayout(adps : array of TSpTBXDockablePanel);
var
  i : integer;
begin
  for i := 0 to FLayout.Count - 1 do
    begin
      Nth(i).FVisible := False;
      Nth(i).FDp.Visible := False
    end;

  for i := 0 to High(adps) do
    begin
      PanelDescriptor(adps[i]).FVisible := True;
      PanelDescriptor(adps[i]).FDp.Visible := True
    end;

  // must keep order of panels, do not sort
  GetLayout;
  UpdatePadding;
  MakeSameHeight;
  AdjustAllTops;
  SetLayout;
end;

// private
function TDockPanelLayout.DefaultPosition(dp : TSpTBXDockablePanel) : integer;
var
  defPos, i : integer;
begin
  GetLayout;
  SortLayout;
  defPos := PanelDescriptor(dp).FDefaultOrder;
  Result := FLayout.Count - 1;

  for i := 0 to FLayout.Count - 1 do
    if Nth(i).FVisible and (dp <> Nth(i).FDp) and (Nth(i).FDefaultOrder > defPos) then
      begin
        Result := i;
        break
      end
end;

// private
procedure TDockPanelLayout.PutPanelAtPos(pd : TPanelDescriptor; pos : integer);
var
  index : integer;
begin
  // find index of dp in list
  index := FLayout.IndexOf(pd);

  // put dp at correct place
  if pos = index
    then // nop
    else
      if pos < index
        then
          begin
            FLayout.Delete(index);
            FLayout.Insert(pos, pd)
          end
        else
          begin
            FLayout.Insert(pos, pd);
            FLayout.Delete(index)
          end;
end;

// private
procedure TDockPanelLayout.AdjustAllTops;
var
  i, y : integer;
  pd : TPanelDescriptor;
begin
  // adjust top of all visible dp
  y := 0;
  for i := 0 to FLayout.Count - 1 do
    begin
      pd := Nth(i);
      if (pd.FVisible = False)
        then continue;

      pd.FTop := y;
      inc(y, pd.FHeight)
    end
end;

// private
procedure TDockPanelLayout.UpdatePadding;
var
  n, i : integer;
begin
  n := 0;

  for i := 0 to FLayout.Count - 1 do
    if Nth(i).IsResizable and (not Nth(i).FPadding)
      then inc(n);

  for i := 0 to FLayout.Count - 1 do
    if Nth(i).FPadding
      then Nth(i).FVisible := (n = 0)
end;

// private
function TDockPanelLayout.NumberOfResizablePanels : integer;
var
  i : integer;
begin
  // calculate number of dp visible, not minimized and not fixed sized
  Result := 0;
  for i := 0 to FLayout.Count - 1 do
    if Nth(i).IsResizable
      then inc(Result)
end;

// private
function TDockPanelLayout.ResizableHeight : integer;
var
  i : integer;
begin
  // calculate height of all dp visible and not minimized
  Result := 0;
  for i := 0 to FLayout.Count - 1 do
    if Nth(i).IsResizable
      then inc(Result, Nth(i).FHeight)
end;

// private
procedure TDockPanelLayout.AdjustHeight(pd : TPanelDescriptor);
begin
  if pd.FFixedSize
    then exit
    else pd.FHeight := Round((ResizableHeight - pd.FHeight) / NumberOfResizablePanels)
end;

// private
procedure TDockPanelLayout.MakeSameHeight;
var
  i, nTot, hTot : integer;
  pd : TPanelDescriptor;
begin
  // calculate number of dp visible, not minimized and not fixed sized
  nTot := NumberOfResizablePanels;

  // calculate size of all dp visible, minimized and fixed sized
  hTot := 0;
  for i := 0 to FLayout.Count - 1 do
    begin
      pd := Nth(i);
      if pd.FVisible and(pd.FMinimized or pd.FFixedSize)
        then inc(hTot, pd.FHeight)
    end;

  // adjust size of all dp visible, not minimized and not fixed sized
  hTot := FDock.ClientHeight - hTot;

  for i := 0 to FLayout.Count - 1 do
    begin
      pd := Nth(i);
      if pd.FVisible and (not pd.FMinimized) and (not pd.FFixedSize)
        then pd.FHeight := Trunc(hTot / nTot)
    end
end;

// private
procedure TDockPanelLayout.MakeProportionalPlaceFor(pd : TPanelDescriptor);
var
  i, hTot : integer;
  pd2 : TPanelDescriptor;
  coef : real;
begin
  // calculate size of all resizable dp (except parameter)
  hTot := ResizableHeight - iff(pd.IsResizable, pd.FHeight, 0);

  // adjust size of all resizable dp (except parameter)
  if hTot = 0
    then coef := 1
    else coef := 1 - pd.FHeight / hTot;

  for i := 0 to FLayout.Count - 1 do
    begin
      pd2 := Nth(i);
      if (pd2 <> pd) and pd2.IsResizable
        then pd2.FHeight := Round(pd2.FHeight * coef)
    end;
end;

// private
procedure TDockPanelLayout.UseProportionalPlaceFrom(pd : TPanelDescriptor);
var
  i, hTot : integer;
  pd2 : TPanelDescriptor;
  coef : real;
begin
  // calculate size of all resizable dp (including parameter)
  hTot := ResizableHeight + iff(not pd.IsResizable, pd.FHeight, 0);

  // adjust size of all resizable dps (except the one in argument)
  if (hTot = 0) or (hTot = pd.FHeight)
    then coef := 1
    else coef := hTot / (hTot - pd.FHeight);

  for i := 0 to FLayout.Count - 1 do
    begin
      pd2 := Nth(i);
      if (pd2 <> pd) and pd2.IsResizable
        then pd2.FHeight := Round(pd2.FHeight * coef)
    end;
end;

// public
procedure TDockPanelLayout.ShowPanelAtPos(dp : TSpTBXDockablePanel; pos : integer);
var
  pd : TPanelDescriptor;
begin
  // capture layout
  GetLayout;
  SortLayout;

  pd := PanelDescriptor(dp);
  pd.FVisible := True;

  // put dp at correct place
  PutPanelAtPos(pd, pos);

  // update padding panel (visible if sizable panels are not visible)
  UpdatePadding;

  // call height adjustment strategy
  AdjustHeight(pd);

  // make some place and adjust top of all visible dp
  MakeProportionalPlaceFor(pd);
  AdjustAllTops;

  // update layout
  SetLayout
end;

// public
procedure TDockPanelLayout.ShowPanelAtDefaultPos(dp : TSpTBXDockablePanel);
begin
  ShowPanelAtPos(dp, DefaultPosition(dp))
end;

// public
procedure TDockPanelLayout.ChangeFixedSize(dp : TSpTBXDockablePanel; newSize : integer);
var
  pd : TPanelDescriptor;
begin
  // capture layout
  GetLayout;
  SortLayout;

  // set to new size
  pd := PanelDescriptor(dp);
  pd.FHeight := newSize;
  pd.FDp.Tag := newSize;
  pd.FDp.Height := newSize;

  // make some place and adjust top of all visible dp
  MakeProportionalPlaceFor(pd);
  AdjustAllTops;

  // update layout
  SetLayout
end;

// public
procedure TDockPanelLayout.HidePanel(dp : TSpTBXDockablePanel);
begin
  if not dp.Visible
    then exit;
    
  // capture layout
  GetLayout;
  SortLayout;

  // hide in layout
  PanelDescriptor(dp).FVisible := False;

  // adjust padding and tops
  UseProportionalPlaceFrom(PanelDescriptor(dp));
  AdjustAllTops;

  // update layout
  SetLayout
end;

// private
procedure TDockPanelLayout.SaveToFile(filename : string);
var
  f : Text;
  i : integer;
  pd : TPanelDescriptor;
begin
  assign(f, filename);
  rewrite(f);

  writeln(f, 'Dock height : ', FDock.Height);
  writeln(f);
  for i := 0 to FLayout.Count - 1 do
    begin
      pd := Nth(i);
      writeln(f, 'Panel #   : ', i);
      writeln(f, 'Name      : ', pd.FName);
      writeln(f, 'Top       : ', pd.FTop);
      writeln(f, 'Height    : ', pd.FHeight);
      writeln(f, 'Visible   : ', pd.FVisible);
      writeln(f ,'Mimized   : ', pd.FMinimized);
      writeln(f, 'FixedSize : ', pd.FFixedSize);
      writeln(f);
     end;
  close(f)
end;

// ---------------------------------------------------------------------------

end.
