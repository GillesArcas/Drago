// ---------------------------------------------------------------------------
// -- Drago -- Configuration of game info preview --- UfrCfgInfoPreview.pas --
// ---------------------------------------------------------------------------

unit UfrCfgInfoPreview;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, StdCtrls, ExtCtrls, Buttons, ComCtrls, TntStdCtrls,
  TntComCtrls;

type
  TfrCfgInfoPreview = class(TFrame)
    btAddButton: TSpeedButton;
    btRemButton: TSpeedButton;
    btMoveUp: TSpeedButton;
    btMoveDn: TSpeedButton;
    Bevel2: TBevel;
    Label3: TTntLabel;
    lvCurrentInfo: TTntListView;
    lvAvailInfo: TTntListView;
    constructor Create(aOwner: TComponent); override;
    procedure btMoveUpClick(Sender: TObject);
    procedure btAddButtonClick(Sender: TObject);
    procedure btRemButtonClick(Sender: TObject);
    procedure btMoveDnClick(Sender: TObject);
    procedure lbCurrentInfoDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure lbCurrentInfoDragOver(Sender, Source: TObject; X, Y: Integer;
    State: TDragState; var Accept: Boolean);
    procedure ListViewDragDrop(Sender, Source: TObject; X,
    Y: Integer);
    procedure ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
    State: TDragState; var Accept: Boolean);
  private
  public
    procedure Initialize(currentProperties : string);
    procedure Finalize  (var currentProperties : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses Std, Translate, Properties;

{$R *.dfm}

// ---------------------------------------------------------------------------

const AvailableInfo = 'BR;DT;EV;HA;KM;PB;PC;PW;RE;RO;RU;SZ;US;WR;';

constructor TfrCfgInfoPreview.Create(aOwner: TComponent);
var
  n, i : integer;
begin
  inherited Create(aOwner);

  lvAvailInfo.Columns[0].Width := lvAvailInfo.Width - 21;

  // fill left list view with available game info properties
  n := Length(AvailableInfo) div 3;
  lvAvailInfo.Items.Clear;
  for i := 1 to n do
    with lvAvailInfo.Items.Add do
      Caption := U(FindPropText(NthWord(AvailableInfo, i, ';')))
end;

procedure TfrCfgInfoPreview.Initialize(currentProperties : string);
var
  n, i : integer;
  pn : WideString;
begin
  lvCurrentInfo.Columns[0].Width := lvCurrentInfo.Width - 20;

  // fill right list view with current columns of game info preview
  n := NthInt(currentProperties, 1, ';');
  lvCurrentInfo.Items.Clear;
  for i := 1 to n do
    begin
      pn := U(FindPropText(NthWord(currentProperties, i * 2, ';')));
      with lvCurrentInfo.Items.Add do
        Caption := pn
    end;
end;

procedure TfrCfgInfoPreview.Finalize(var currentProperties : string);
var
  n, i, j : integer;
  pnref, pnlist, pn, tmpDescr : string;
begin
  // make list of property names from reference
  n := NthInt(currentProperties, 1, ';');
  pnref := '';
  for i := 1 to n do
    pnref := pnref + NthWord(currentProperties, 2 * i, ';');

  // make list of property names and column descriptor from list view
  n := lvCurrentInfo.Items.Count;
  pnlist := '';
  tmpDescr := IntToStr(n) + ';';
  for i := 0 to n - 1 do
    for j := 1 to Length(AvailableInfo) div 3 do
      begin
        pn := NthWord(AvailableInfo, j, ';');
        if U(FindPropText(pn)) = lvCurrentInfo.Items[i].Caption then
          begin
            pnlist := pnlist + pn;
            tmpDescr := tmpDescr + pn + ';;';
            break
          end
    end;

  // compare and store new descriptor if different
  if pnref = pnlist
    then // nop
    else currentProperties := tmpDescr
end;

// -- Buttons ----------------------------------------------------------------

// -- Add item

procedure TfrCfgInfoPreview.btAddButtonClick(Sender: TObject);
var
  i : integer;
begin
  // exit if no source item selected
  if lvAvailInfo.Selected = nil
    then exit;

  with lvCurrentInfo do
    begin
      // find target index
      if Selected = nil
        then i := Items.Count
        else i := Selected.Index;

      // insert new item with caption of source item
      Items.BeginUpdate;
      with Items.Insert(i) do
        Caption := lvAvailInfo.Selected.Caption;
      Items.EndUpdate
    end
end;

// -- Remove item

procedure TfrCfgInfoPreview.btRemButtonClick(Sender: TObject);
begin
  // exit if no item selected
  if lvCurrentInfo.Selected = nil
    then exit;

  // delete selected item
  with lvCurrentInfo do
    begin
      Items.BeginUpdate;
      Selected.Free;
      Items.EndUpdate
    end
end;

// -- Move item upward

//http://www.scalabium.com/faq/dct0154.htm
procedure ExchangeItems(lv : TTntListView; const i, j : Integer);
var
  x : TTntListItem;
begin
  lv.Items.BeginUpdate;
  try
    x := TTntListItem.Create(lv.Items);
    x.Assign(lv.Items[i]);
    lv.Items[i].Assign(lv.Items[j]);
    lv.Items[j].Assign(x);
    x.Free;
  finally
    lv.Items.EndUpdate
  end;
end;

//http://www.swissdelphicenter.ch/torry/showcode.php?id=445
function MoveListViewItem(lv : TTntListView; ItemFrom, ItemTo: Word): Boolean;
var
  Source, Target: TTntListItem;
begin
  Result := False;
  lv.Items.BeginUpdate;
  try
    Source := lv.Items[ItemFrom];
    Target := lv.Items.Insert(ItemTo);
    Target.Assign(Source);
    Source.Free;
    Result := True;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure TfrCfgInfoPreview.btMoveUpClick(Sender: TObject);
var
  i : integer;
begin
  // exit if no item selected
  if lvCurrentInfo.Selected = nil
    then exit;

  // find index of selected item, exit if first
  i := lvCurrentInfo.Selected.Index;
  if i = 0
    then exit;

  // swap selected item with previous
  ExchangeItems(lvCurrentInfo, i, i - 1);

  // select new position to enable follow-up moves
  lvCurrentInfo.ItemFocused := nil;
  lvCurrentInfo.Selected := lvCurrentInfo.Items[i - 1]
end;

// -- Move item downward

procedure TfrCfgInfoPreview.btMoveDnClick(Sender: TObject);
var
  i : integer;
begin
  // exit if no item selected
  if lvCurrentInfo.Selected = nil
    then exit;

  // find index of selected item, exit if first
  i := lvCurrentInfo.Selected.Index;
  if i = lvCurrentInfo.Items.Count - 1
    then exit;

  // swap with previous in list of actions from current tool bar
  ExchangeItems(lvCurrentInfo, i, i + 1);

  // select item to enable follow-up moves
  lvCurrentInfo.Selected := lvCurrentInfo.Items[i + 1]
end;

// -- Drag and drop

procedure TfrCfgInfoPreview.ListViewDragDrop(Sender, Source : TObject;
                                             X, Y : Integer);
var
  iSrc, iDst : integer;
  DropItem : TTntListItem;
  item : TTntListItem;
begin
  if (Sender = lvCurrentInfo) and (Source = lvAvailInfo) then
    // add item
    with lvCurrentInfo do
      begin
        Selected := GetItemAt(X, Y) as TTntListItem;
        btAddButtonClick(Sender)
      end;

  if (Sender = lvAvailInfo) and (Source = lvCurrentInfo) then
    // remove item
    btRemButtonClick(Sender);

  if (Sender = lvCurrentInfo) and (Source = lvCurrentInfo) then
    // move item inside current list of items
    with lvCurrentInfo do
      begin
        iSrc := Selected.Index;
        DropItem := GetItemAt(X, Y) as TTntListItem;
        if DropItem = nil
          then iDst := lvCurrentInfo.Items.Count
          else iDst := DropItem.Index;

        MoveListViewItem(lvCurrentInfo, iSrc, iDst);

        ItemFocused := nil;
        Selected := nil
      end;
end;

procedure TfrCfgInfoPreview.ListViewDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender = lvCurrentInfo) and (Source = lvAvailInfo)
    then Accept := lvCurrentInfo.Items.Count < lvAvailInfo.Items.Count
    else Accept := True
end;

// ---------------------------------------------------------------------------

procedure TfrCfgInfoPreview.lbCurrentInfoDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
(*
  if odSelected in State
    then
      with lbCurrentInfo.Canvas do
        begin
          Brush.Color := clLtGray;
          Pen.Color := clLtGray;
          Rectangle(Rect);
          TextOut(rect.Left + 4, rect.Top + 6, lbCurrentInfo.Items[index])
        end
    else
      with lbCurrentInfo.Canvas do
        begin
          Brush.Color := clWhite;
          Pen.Color := clLtGray;
          Rectangle(Rect);
          TextOut(rect.Left + 4, rect.Top + 6, lbCurrentInfo.Items[index])
        end
*)
end;

procedure TfrCfgInfoPreview.lbCurrentInfoDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := True
end;

// ---------------------------------------------------------------------------

end.
