// ---------------------------------------------------------------------------
// -- Drago -- Shortcuts configuration dialog --------- UfrCfgShortcuts.pas --
// ---------------------------------------------------------------------------

unit UfrCfgShortcuts;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, TntIniFiles, Buttons, ExtCtrls, ActnList, 
  ShortCutEdit,
  TntComCtrls, TntActnList, TntStdCtrls;

type
  TfrCfgShortcuts = class(TFrame)
    lvActions: TTntListView;
    Bevel1: TBevel;
    edShortCutDesign: THotKey;
    Bevel2: TBevel;
    Label0: TTntLabel;
    Label1: TTntLabel;
    Label2: TTntLabel;
    lbAssignedTo1: TTntLabel;
    lbAssignedTo2: TTntLabel;
    Label3: TTntLabel;
    Label4: TTntLabel;
    cbCategories: TTntComboBox;
    btAssign: TTntButton;
    btClear: TTntButton;
    procedure cbCategoriesSelect(Sender: TObject);
    procedure btAssignClick(Sender: TObject);
    procedure lvActionsSelectItem(Sender: TObject; Item: TListItem;
    Selected: Boolean);
    procedure btClearClick(Sender: TObject);
    procedure edShortCutChange(Sender: TObject);
  private
    procedure InitActions (al : TTntActionList);
    function GetCurrentAction : TAction;
    function GetShortCutAssignee(ShortCut : TShortCut) : TTntAction;
  public
    edShortCut: TShortCutEdit;
    procedure Initialize(al : TTntActionList);
    procedure Finalize  (al : TActionList);
    procedure Update    (al : TActionList);
  end;

procedure SaveToIni  (al : TActionList; iniFile : TTntMemIniFile);
procedure LoadFromIni(al : TActionList; iniFile : TTntMemIniFile);
procedure UpdateMenuForShortcuts(al : TActionList);

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses Translate, UActions, Main, UShortcuts;

// -- Implementation note ----------------------------------------------------
//
// While in Option dialog, shortcuts are stored in the SecondaryShortCuts list
// in native form (ie given by compiler).
// All modification during dialog will be done in this list.
//
// -- Initialisation ---------------------------------------------------------

// -- Load all data

procedure TfrCfgShortcuts.Initialize(al : TTntActionList);
begin
  InitActions(al);

  // replace standard THotkey (bad display of arrows) with Thornqvist one
  edShortCutDesign.Visible := False;
  edShortCut            := TShortCutEdit.Create(self);
  edShortCut.Parent     := Self;
  edShortCut.Font.Size  := 9;
  edShortCut.BoundsRect := edShortCutDesign.BoundsRect;
  edShortCut.TabOrder   := edShortCutDesign.TabOrder;
  edShortCut.OnChange   := edShortCutChange;
  edShortCutChange(nil)
end;

// -- Load category combo and list view from action list

procedure TfrCfgShortcuts.InitActions(al : TTntActionList);
var
  i : integer;
begin
  // copy all shortcuts in SecondaryShortCuts list
  for i := 0 to al.ActionCount - 1 do
    with TAction(al.Actions[i]) do
      begin
        SecondaryShortCuts.Clear;
        SecondaryShortCuts.Add(EnShortCutToText(ShortCut))
      end;

  GetCategories(al, cbCategories.Items, False);
  cbCategories.ItemIndex := 0;
  cbCategoriesSelect(nil);
  edShortCut.HotKey := 0
end;

// -- Update and finalisation ------------------------------------------------

procedure TfrCfgShortcuts.Update(al : TActionList);
var
  i : integer;
begin
  for i := 0 to al.ActionCount - 1 do
    with TAction(al.Actions[i]) do
      ShortCut := EnTextToShortCut(SecondaryShortCuts[0]);

  UpdateMenuForShortcuts(al)
end;

procedure TfrCfgShortcuts.Finalize(al : TActionList);
var
  i : integer;
begin
  for i := 0 to al.ActionCount - 1 do
    with TAction(al.Actions[i]) do
      SecondaryShortCuts.Clear;

  for i := 0 to cbCategories.Items.Count - 1 do
    (cbCategories.Items.Objects[i] as TList).Free
end;

// -- Update of TMainMenu dedicated to shortcuts -----------------------------

// Shortcuts are in fact "TMainMenu shortcuts" and require a TMainMenu to
// work. As the main menu is replaced by a TSpTBXToolbar, it is required
// to hide a main menu populated with the actions with shortcut.

// ActionsWithShortcut is the TMenuItem storing menus associated with the
// actions with shortcuts.

procedure UpdateMenuForShortcuts(al : TActionList);
var
  i : integer;
  action : TAction;
  item : TMenuItem;
begin
  fmMain.ActionsWithShortcut.Clear;

  for i := 0 to al.ActionCount - 1 do
    begin
      action := TAction(al.Actions[i]);
      if action.Shortcut <> 0 then
        begin
          item := TMenuItem.Create(fmMain.ActionsWithShortcut);
          item.Caption := action.Caption;
          item.Action := action;
          fmMain.ActionsWithShortcut.Add(item)
        end
    end
end;

// -- Category combobox events -----------------------------------------------

// -- Selection of a category

procedure TfrCfgShortcuts.cbCategoriesSelect(Sender: TObject);
var
  i : integer;
  sl : TList;
  ac : TTntAction;
begin
  // fill action list view with current category actions
  lvActions.Items.Clear;
  sl := cbCategories.Items.Objects[cbCategories.ItemIndex] as TList;

  // add items from category
  for i := 0 to sl.Count - 1 do
    with lvActions.Items.Add do
      begin
        ac := TTntAction(sl.Items[i]);
        ImageIndex := ac.ImageIndex;
        Caption    := '';
        SubItems.Add(ac.Caption);
        SubItems.Add(TrShortCutToText(EnTextToShortCut(ac.SecondaryShortcuts[0])))
      end;

  // erase edit area
  edShortCut.HotKey := 0;
  lbAssignedTo1.Caption := '';
  lbAssignedTo2.Caption := ''
end;

// -- Action list view events ------------------------------------------------

procedure TfrCfgShortcuts.lvActionsSelectItem(Sender : TObject;
                                              Item : TListItem; Selected : Boolean);
var
  sl : TList;
begin
  if not Selected
    then exit;

  sl := cbCategories.Items.Objects[cbCategories.ItemIndex] as TList;

  with TAction(sl.Items[Item.Index]) do
    edShortCut.HotKey := TextToShortCut(SecondaryShortcuts[0])
end;

function TfrCfgShortcuts.GetShortCutAssignee(ShortCut : TShortCut) : TTntAction;
var
  i, k : integer;
  sl : TList;
begin
  Result := nil;
  if ShortCut = 0
    then exit;

  for i := 0 to cbCategories.Items.Count - 1 do
    begin
      sl := cbCategories.Items.Objects[i] as TList;

      for k := 0 to sl.Count - 1 do
        begin
          Result := TTntAction(sl[k]);

          if TextToShortCut(Result.SecondaryShortcuts[0]) = ShortCut
            then exit
        end
    end;
    
  Result := nil
end;

// -- Shortcut edit events ---------------------------------------------------

procedure TfrCfgShortcuts.edShortCutChange(Sender: TObject);
var
  ac : TTntAction;
begin
  if edShortCut.HotKey = 0
    then
      begin
        lbAssignedTo1.Caption := '';
        lbAssignedTo2.Caption := ''
      end
    else
      begin
        lbAssignedTo1.Caption := U('Assigned to:');

        ac := GetShortCutAssignee(edShortCut.HotKey);
        if ac = nil
          then lbAssignedTo2.Caption := U('(none)')
          else lbAssignedTo2.Caption := ac.Caption
      end
end;

// -- Buttons ----------------------------------------------------------------

// -- Assign

procedure TfrCfgShortcuts.btAssignClick(Sender: TObject);
var
  ac : TAction;
  sel : integer;
begin
  if lvActions.Selected = nil
    then exit;

  ac := GetShortCutAssignee(edShortCut.HotKey);
  if ac <> nil
    then ac.SecondaryShortcuts[0] := EnShortCutToText(0);

  with GetCurrentAction do
    SecondaryShortcuts[0] := EnShortCutToText(edShortCut.HotKey);

  sel := lvActions.Selected.Index;
  cbCategoriesSelect(nil);
  lvActions.Items[sel].MakeVisible(False)

  //note: TopItem cannot be set
  //      see http://qc.borland.com/wc/qcmain.aspx?d=27348
end;

// -- Clear

procedure TfrCfgShortcuts.btClearClick(Sender: TObject);
var
  sel : integer;
begin
  if lvActions.Selected = nil
    then exit;

  edShortCut.HotKey := 0;

  with GetCurrentAction do
    SecondaryShortcuts[0] := EnShortCutToText(0);

  sel := lvActions.Selected.Index;
  cbCategoriesSelect(nil);
  lvActions.Items[sel].MakeVisible(False)
end;

// -- Saving and loading of shortcuts to inifiles ----------------------------

// -- Saving

procedure SaveToIni(al : TActionList; iniFile : TTntMemIniFile);
var
  i : integer;
begin
  for i := 0 to al.ActionCount - 1 do
    with TAction(al[i]) do
      if ShortCut = 0
        then iniFile.DeleteKey  ('Shortcuts', ExternalName(Name))
        else iniFile.WriteString('Shortcuts', ExternalName(Name),
                                 EnShortCutToText(ShortCut))
end;

// -- Loading

procedure LoadFromIni(al : TActionList; iniFile : TTntMemIniFile);
var
  i : integer;
  s : string;
begin
  for i := 0 to al.ActionCount - 1 do
    with TTntAction(al[i]) do
      begin
        s := iniFile.ReadString('Shortcuts', ExternalName(Name), '');
        if s <> ''
          then ShortCut := EnTextToShortcut(s)
      end;

  UpdateMenuForShortcuts(al)
end;

// ---------------------------------------------------------------------------

function TfrCfgShortcuts.GetCurrentAction : TAction;
var
  k : integer;
  sl : TList;
begin
  Result := nil;

  if lvActions.Selected = nil
    then exit
    else k := lvActions.Selected.Index;

  sl := cbCategories.Items.Objects[cbCategories.ItemIndex] as TList;

  Result := TACtion(sl[k])
end;

// ---------------------------------------------------------------------------

end.
