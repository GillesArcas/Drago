// ---------------------------------------------------------------------------
// -- Drago -- Toolbars configuration dialog (SP) ---- UfrCfgSpToolbars.pas --
// ---------------------------------------------------------------------------
// SP: Silverpoint Development, SpTBXLib

unit UfrCfgSpToolbars;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ActnList,
  TB2Item, TB2Dock, Buttons, ExtCtrls,
  TntStdCtrls, TntClasses, TntComCtrls, TntActnList,
  SpTBXItem;

type
  TfrCfgSpToolbars = class(TFrame)
    btMoveUp: TSpeedButton;
    btMoveDn: TSpeedButton;
    btAddButton: TSpeedButton;
    btRemButton: TSpeedButton;
    Bevel2: TBevel;
    cbCategories: TTntComboBox;
    cbToolbars: TTntComboBox;
    lvToolbar: TTntListView;
    lvActions: TTntListView;
    Label1: TTntLabel;
    Label3: TTntLabel;
    Label2: TTntLabel;
    procedure cbCategoriesSelect(Sender: TObject);
    procedure cbToolbarsSelect(Sender: TObject);
    procedure btAddButtonClick(Sender: TObject);
    procedure btRemButtonClick(Sender: TObject);
    procedure ListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
                               State: TDragState; var Accept: Boolean);
    procedure cbCategoriesChange(Sender: TObject);
    procedure btMoveUpClick(Sender: TObject);
    procedure btMoveDnClick(Sender: TObject);
  private
    procedure InitActions (al : TTntActionList);
    procedure InitToolbars;
    function  FindToolbar(aCaption : WideString) : TSpTBXToolbar;
  public
    procedure Initialize(al : TTntActionList);
    procedure Finalize;
    procedure UpdateToolbars;
  end;

procedure SaveToolbarIniFile;
procedure LoadToolbarIniFile;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses 
  Std, UActions, Main, Translate, IniFiles, TntIniFiles;

// -- Forwards ---------------------------------------------------------------

procedure ClearToolbar(tb : TSpTBXToolbar); forward;
procedure AddToolbarItemByAction(tb : TSpTBXToolbar; acItem : TAction); forward;
procedure AddToolbarItemByName(tb : TSpTBXToolbar; acName : string); forward;
function  CompareToolbarAndActions(tb : TSpTBXToolbar; list : TList) : boolean; forward;

// -- Initialisation ---------------------------------------------------------

// -- Load all data

procedure TfrCfgSpToolbars.Initialize(al : TTntActionList);
begin
  InitActions(al);
  InitToolbars;
  //cbCategories.ItemIndex := 0;
  //cbToolbars.ItemIndex := 0;
end;

// -- Load category combo and list view

procedure TfrCfgSpToolbars.InitActions(al : TTntActionList);
begin
  GetCategories(al, cbCategories.Items, True);
  cbCategories.ItemIndex := 0;
  cbCategoriesSelect(nil)
end;

// -- Load toolbar combo and list view

procedure TfrCfgSpToolbars.InitToolbars;
var
  i, k : integer;
  tb : TSpTBXToolbar;
  sl : TTntStrings;
begin
  sl := cbToolbars.Items;

  with fmMain do
    for i := 0 To ComponentCount - 1 do
      if Components[i] is TSpTBXToolbar
        then
          begin
            tb := Components[i] as TSpTBXToolbar;
            if tb.MenuBar
              then continue;
            sl.AddObject(U(tb.Caption), TList.Create);
            for k := 0 to tb.Items.Count - 1 do
              if tb.Items[k] is TSpTBXSeparatorItem
                then (sl.Objects[sl.Count - 1] as TList).Add(nil)
                else (sl.Objects[sl.Count - 1] as TList).Add(tb.Items[k].Action);
          end;

  cbToolbars.ItemIndex := 0;
  cbToolbarsSelect(nil)
end;

// -- Finalisation -----------------------------------------------------------

procedure TfrCfgSpToolbars.Finalize;
var
  i : integer;
begin
  for i := 0 to cbCategories.Items.Count - 1 do
    (cbCategories.Items.Objects[i] as TList).Free;

  for i := 0 to cbToolbars.Items.Count - 1 do
    (cbToolbars.Items.Objects[i] as TList).Free;
end;

// -- Look for toolbar in main form using caption

function TfrCfgSpToolbars.FindToolbar(aCaption : WideString) : TSpTBXToolbar;
var
  k : integer;
begin
  with fmMain do
    for k := 0 To ComponentCount - 1 do
      if Components[k] is TSpTBXToolbar then
        begin
          Result := Components[k] as TSpTBXToolbar;
          if aCaption = U(Result.Caption)
            then exit
        end;

  // not found
  Result := nil
end;

// -- Update toolbars

procedure TfrCfgSpToolbars.UpdateToolbars;
var
  i, k : integer;
  tb : TSpTBXToolbar;
  sl : TList;
begin 
  for i := 0 to cbToolbars.Items.Count - 1 do
    begin
      tb := FindToolbar(cbToolbars.Items[i]);
      sl := cbToolbars.Items.Objects[i] as TList;

      if (tb = nil) or CompareToolbarAndActions(tb, sl)
        then continue;

      tb.BeginUpdate;

      // reset toolbar
      ClearToolbar(tb);

      // add buttons from actions
      for k := 0 to sl.Count - 1 do
        AddToolbarItemByAction(tb, sl[k]);

      tb.EndUpdate
    end
end;

// -- Category combobox events -----------------------------------------------

// -- Selection of a category

procedure TfrCfgSpToolbars.cbCategoriesSelect(Sender: TObject);
var
  i : integer;
  sl : TList;
  ac : TTntAction;
begin
  // fill action list view with category actions
  lvActions.Items.Clear;
  sl := cbCategories.Items.Objects[cbCategories.ItemIndex] as TList;

  // add separator as first item
  with lvActions.Items.Add do
    begin
      ImageIndex := 50;
      Caption    := '';
      SubItems.Add(U('(Separator)'))
    end;

  // add items from category
  for i := 0 to sl.Count - 1 do
    with lvActions.Items.Add do
      begin
        ac := TTntAction(sl.Items[i]);
        ImageIndex := ac.ImageIndex;
        Caption    := '';
        SubItems.Add(ac.Caption)
      end
end;

procedure TfrCfgSpToolbars.cbCategoriesChange(Sender: TObject);
begin
  //
end;

// -- Toolbar combobox events ------------------------------------------------

// -- Selection of a toolbar

procedure TfrCfgSpToolbars.cbToolbarsSelect(Sender: TObject);
var
  i  : integer;
  ac : TTntAction;
  li : TTntListItem;
  sl : TList;
begin
  // fill action list view with toolbar actions
  lvToolbar.Items.Clear;
  sl := cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList;

  for i := 0 to sl.Count - 1 do
    begin
      li := lvToolbar.Items.Add;
      ac := TTntAction(sl.Items[i]);
      if ac = nil
        then
          begin
            li.ImageIndex := 50;
            li.Caption := '';
            li.SubItems.Add(U('(Separator)'))
          end
        else
          begin
            li.ImageIndex := ac.ImageIndex;
            li.Caption := '';
            li.SubItems.Add(ac.Caption)
          end
    end
end;

// -- Action list view events ------------------------------------------------

// -- Category list view events ----------------------------------------------

procedure TfrCfgSpToolbars.ListViewDragDrop(Sender, Source: TObject;
                                            X, Y: Integer);
var
  DragItem, DropItem, CurrentItem : TListItem;
  iSrc, iDst : integer;
  item : TObject;
  list : TList;
begin
  list := cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList;

  if (Sender = lvToolbar) and (Source = lvActions) then
    // add action to toolbar
    with lvToolbar do
      begin
        Selected := GetItemAt(X, Y) as TTntListItem;
        btAddButtonClick(Sender);
      end;

  if (Sender = lvActions) and (Source = lvToolbar) then
    // remove action from toolbar
    with lvToolbar do
      begin
        //Selected := GetItemAt(X, Y) as TListItem;
        btRemButtonClick(Sender);
      end;

  if (Sender = lvToolbar) and (Source = lvToolbar) then
    // move action inside toolbar
    with lvToolbar do
      begin
        DropItem := GetItemAt(X, Y) as TListItem;;

        iSrc := Selected.Index;

        item := list[iSrc];
        list.Delete(iSrc);

        if DropItem = nil
          then list.Add(item)
          else list.Insert(DropItem.Index, item);
      end;

  // update toolbar list view
  //!//cbToolbarsSelect(Sender)
end;

procedure TfrCfgSpToolbars.ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
                                            State: TDragState; var Accept: Boolean);
begin
  Accept := True
end;

// -- Buttons ----------------------------------------------------------------

// -- Add

procedure TfrCfgSpToolbars.btAddButtonClick(Sender: TObject);
var
  iSrc, iTgt : integer;
  ac : TAction;
  sl : TList;
begin
  // exit if no item selected
  if lvActions.Selected = nil
    then exit;

  // find index of selected item
  iSrc := lvActions.Selected.Index;

  // find corresponding action
  // separator added at the top of the list, is added as null action
  sl := cbCategories.Items.Objects[cbCategories.ItemIndex] as TList;
  if iSrc = 0
    then ac := nil
    else ac := TAction(sl.Items[iSrc - 1]);

  // find index where to insert
  if lvToolbar.Selected = nil
    then iTgt := lvToolbar.Items.Count
    else iTgt := lvToolbar.Selected.Index;

  // insert in list of actions from current tool bar, avoid to duplicate
  // buttons in the same toolbar, but enables several separators (ac = nil)
  sl := cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList;
  if (sl.IndexOf(ac) < 0) or (ac = nil)
    then sl.Insert(iTgt, ac);

  // update toolbar list view
  //lvToolbar.Items.Clear;
  cbToolbarsSelect(Sender)
end;

// -- Remove

procedure TfrCfgSpToolbars.btRemButtonClick(Sender: TObject);
var
  i : integer;
  sl : TList;
begin
  // exit if no action selected in category list view
  if lvToolbar.Selected = nil
    then exit;

  // find index of selected item
  i := lvToolbar.Selected.Index;

  // delete in list of actions from current tool bar
  sl := cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList;
  sl.delete(i);

  // update toolbar list view
  //lvToolbar.Items.Clear;
  cbToolbarsSelect(Sender)
end;

// -- Move action up

procedure TfrCfgSpToolbars.btMoveUpClick(Sender: TObject);
var
  i : integer;
begin
  // exit if no action selected in category list view
  if lvToolbar.Selected = nil
    then exit;

  // find index of selected item, exit if first
  i := lvToolbar.Selected.Index;
  if i = 0
    then exit;

  // swap with previous in list of actions from current tool bar
  with cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList do
    Exchange(i, i - 1);

  // update toolbar list view
  cbToolbarsSelect(Sender);

  // select item to enable follow-up moves
  lvToolbar.Selected := lvToolbar.Items[i - 1]
end;

// -- Move action down

procedure TfrCfgSpToolbars.btMoveDnClick(Sender: TObject);
var
  i : integer;
begin
  // exit if no action selected in category list view
  if lvToolbar.Selected = nil
    then exit;

  // find index of selected item, exit if last
  i := lvToolbar.Selected.Index;
  if i = lvToolbar.Items.Count - 1 
    then exit;

  // swap with previous in list of actions from current tool bar
  with cbToolbars.Items.Objects[cbToolbars.ItemIndex] as TList do
    Exchange(i, i + 1);

  // update toolbar list view
  cbToolbarsSelect(Sender);

  // select item to enable follow-up moves
  lvToolbar.Selected := lvToolbar.Items[i + 1]
end;

// -- Saving and loading of toolbars configuration ---------------------------

procedure TBTntIniSavePositions(owner: TComponent; iniFile : TTntMemIniFile; section : string);
var
  tmpIni : TMemIniFile;
begin
  tmpIni := TMemIniFile.Create('');
  TBIniSavePositions(owner, tmpIni, section);
  CopyIniToTntIni(tmpIni, iniFile);
  tmpIni.Free;
end;

procedure TBTntIniLoadPositions(owner: TComponent; iniFile : TTntMemIniFile; section : string);
var
  tmpIni : TMemIniFile;
begin
  tmpIni := TMemIniFile.Create('');
  CopyTntIniToIni(iniFile, tmpIni, section);
  TBIniLoadPositions(owner, tmpIni, section);
  tmpIni.Free;
end;

// -- Saving

procedure SaveToolbarIniFile;
var
  i, k : integer;
  tb : TSpTBXToolbar;
  s : string;
begin
  TBTntIniSavePositions(fmMain, fmMain.IniFile, 'Toolbars-');

  with fmMain do
    for k := 0 To ComponentCount - 1 do
      if Components[k] is TSpTBXToolbar then
        begin
          tb := Components[k] as TSpTBXToolbar;
          if tb.MenuBar
            then continue;
          s := '';

          for i := 0 to tb.Items.Count - 1 do
            if tb.Items[i] is TSpTBXSeparatorItem
              then s := s + 'sep,'
              else
                if tb.Items[i].Action <> nil
                  then s := s + ExternalName(tb.Items[i].Action.Name) + ',';

          IniFile.WriteString('Toolbars-' + tb.Name, 'Buttons', s)
        end
end;

// -- Loading

function ListOfToolbars : TList;
var
  k : integer;
begin
  Result := TList.Create;
  with fmMain do
    for k := 0 To ComponentCount - 1 do
      if Components[k] is TSpTBXToolbar
        then Result.Add(Components[k])
end;

procedure LoadToolbarIniFile;
var
  i, k : integer;
  tb : TSpTBXToolbar;
  s, ac : string;
  list : TList;
begin
  TBTntIniLoadPositions(fmMain, fmMain.IniFile, 'Toolbars-');

  list := ListOfToolbars;

  with fmMain do
    for k := 0 To list.Count - 1 do
      begin
        tb := TSpTBXToolbar(list[k]);
        if tb.MenuBar
          then continue;
        s := IniFile.ReadString('Toolbars-' + tb.Name, 'Buttons', '');
        if s = '' then
          begin
            if tb = ToolbarMisc
              then tb.DockPos := ToolbarNavigation.Left + ToolbarNavigation.Width;
            continue;
          end;

        ClearToolbar(tb);

        i := 0;
        repeat
          inc(i);
          ac := NthWord(s, i, ',');
          if ac = ''
            then break
            else AddToolbarItemByName(tb, InternalName(ac))
        until False
      end;

  list.Free
end;

// -- Utilities --------------------------------------------------------------

// -- Clear toobar while preserving some buttons

procedure ClearToolbar(tb : TSpTBXToolbar);
begin
  if tb = fmMain.ToolbarFile then
    with fmMain do
      begin
        tb.Items.Remove(btQuickSearch);        // preserve auto check
      end;
  if tb = fmMain.ToolbarNavigation then
    with fmMain do
      begin
        tb.Items.Remove(tbNextTarget);         // preserve drop down
        tb.Items.Remove(tbAutoReplay);         // preserve drop down
      end;
  if tb = fmMain.ToolbarEdit then
    with fmMain do
      begin
        tb.Items.Remove(tbGameEdit);          // preserve drop down
        tb.Items.Remove(tbCurrentMarkup)      // preserve drop down
      end;

  tb.Items.Clear
end;

// -- Add toolbar item giving the pointer of associated action

procedure AddToolbarItemByAction(tb : TSpTBXToolbar; acItem : TAction);
var
  item : TSpTBXItem;
begin
  if acItem = nil
    then tb.Items.Add(TSpTBXSeparatorItem.Create(tb))
  else if acItem = Actions.acQuickSearch
    then tb.Items.Add(fmMain.btQuickSearch)      // restore auto check
  else if acItem = Actions.acNextTarget
    then tb.Items.Add(fmMain.tbNextTarget)       // restore drop down
  else if acItem = Actions.acAutoReplay
    then tb.Items.Add(fmMain.tbAutoReplay)       // restore drop down
  else if acItem = Actions.acGameEdit
    then tb.Items.Add(fmMain.tbGameEdit)        // restore drop down
  else if acItem = Actions.acMarkup
    then tb.Items.Add(fmMain.tbCurrentMarkup)   // restore drop down
  else
    begin
      item := TSpTBXItem.Create(tb);
      item.Action := acItem;
      item.Images := Actions.ImageList;
      tb.Items.Add(item);
    end
end;

// -- Add toolbar item giving the name of associated action

procedure AddToolbarItemByName(tb : TSpTBXToolbar; acName : string);
begin
  if acName = 'sep'
    then AddToolbarItemByAction(tb, nil)
    else AddToolbarItemByAction(tb, TAction(Actions.FindComponent(acName)))
end;

// -- Compare toolbar and list of actions

function CompareToolbarAndActions(tb : TSpTBXToolbar; list : TList) : boolean;
var
  i : integer;
  ac : TAction;
begin
  Result := False;

  if tb.Items.Count <> list.Count
    then exit;

  for i := 0 to list.Count - 1 do
    begin
      ac := TAction(list[i]);

      if (ac = nil) and (not (tb.Items[i] is TSpTBXSeparatorItem))
        then exit
      else if (ac = Actions.acNextTarget) and (tb.Items[i] <> fmMain.tbNextTarget)
        then exit
      else if (ac = Actions.acAutoReplay) and (tb.Items[i] <> fmMain.tbAutoReplay)
        then exit
      else if (ac = Actions.acGameEdit) and (tb.Items[i] <> fmMain.tbGameEdit)
        then exit
      else if (ac = Actions.acMarkup) and (tb.Items[i] <> fmMain.tbCurrentMarkup)
        then exit
      else if ac <> tb.Items[i].Action
        then exit
    end;

  Result := True
end;

// ---------------------------------------------------------------------------

end.
