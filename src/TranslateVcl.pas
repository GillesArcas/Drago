// ---------------------------------------------------------------------------
// -- Drago -- Translation of VCL classes ---------------- TranslateVcl.pas --
// ---------------------------------------------------------------------------

unit TranslateVcl;

// ---------------------------------------------------------------------------

interface

uses
  Forms, Menus, StdCtrls, ExtCtrls, ComCtrls, Buttons, Sysutils, Dialogs,
  Classes, CheckLst, Grids, ActnList, StrUtils,
  TntStdCtrls, TntComCtrls, TntExtCtrls, TntButtons, TntActnList,
  TntCheckLst, TntForms, TntGrids, TntMenus,
  SpTBXControls, SpTBXItem, TntHeaderCtrl;

procedure TranslateForm(x : TForm); overload;
procedure TranslateForm(x : TTntForm); overload;
procedure TranslateComponent(x : TComponent);
procedure TranslateTComponent(x : TComponent);
procedure TranslateTSpTBXRadioButton(x : TSpTBXRadioButton);

// ---------------------------------------------------------------------------

implementation

uses
  Std, Translate, SpTBXDkPanels, SpTBXEditors;

// -- Translation of components ----------------------------------------------

// Summary:
//
// ActionList
// MenuItem
// Label
// LabeledEdit
// Button
// BitBtn
// SpeedButton
// ToolButton
// TabSheet
// GroupBox
// CheckBox
// RadioGroup
// RadioButton
// ComboBox
// CheckListBox
// StringGrid
// ListView
// HeaderControl
// SpTBXToolbar
// Component

// ---------------------------------------------------------------------------

// ActionList

procedure TranslateActionList(x : TActionList); overload;
var
  i : integer;
begin
  for i := 0 to x.ActionCount - 1 do
    with x.Actions[i] as TAction do
      begin
        Caption := T(Caption);
        Hint := T(Hint)
      end
end;

procedure TranslateActionList(x : TTntActionList); overload;
var
  i : integer;
begin
  for i := 0 to x.ActionCount - 1 do
    with x.Actions[i] as TAction do
      begin
        Caption := U(Caption);
        Hint := U(Hint)
      end
end;

// MenuItem

procedure TranslateMenuItem(x : TMenuItem); overload;
begin
  x.Caption := T(replace(x.Caption, '&', ''))
end;

procedure TranslateMenuItem(x : TTntMenuItem); overload;
begin
  x.Caption := U(replace(x.Caption, '&', ''))
end;

procedure TranslateMenuItem(x : TSpTBXSubMenuItem); overload;
begin
  x.Caption := U(replace(x.Caption, '&', ''))
end;

procedure TranslateMenuItem(x : TSpTBXItem); overload;
begin
  if x.Action = nil then
    begin
      x.Caption := U(replace(x.Caption, '&', ''));
      x.Hint:= U(x.Hint)
    end
end;

// -- Label

procedure TranslateLabel(x : TLabel); overload;
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateLabel(x : TTnTLabel); overload;
begin
  x.Caption := U(x.Caption)
end;

procedure TranslateLabel(x : TSpTBXLabel); overload;
begin
  x.Caption := U(x.Caption)
end;

// LabeledEdit

procedure TranslateLabeledEdit(x : TLabeledEdit);
begin
  x.EditLabel.Caption := T(x.EditLabel.Caption)
end;

// Button

procedure TranslateButton(x : TButton); overload;
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateButton(x : TTntButton); overload;
begin
  x.Caption := U(x.Caption)
end;

procedure TranslateButton(x : TSpTBXButton); overload;
begin
  x.Caption := U(x.Caption)
end;

// BitBtn

procedure TranslateBitBtn(x : TBitBtn); overload;
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateBitBtn(x : TTntBitBtn); overload;
begin
  x.Caption := U(x.Caption)
end;

// SpeedButton

procedure TranslateSpeedButton(x : TSpeedButton);
begin
  x.Caption := T(x.Caption);
  x.Hint := T(x.Hint)
end;

procedure TranslateTntSpeedButton(x : TTntSpeedButton);
begin
  x.Caption := U(x.Caption);
  x.Hint := U(x.Hint)
end;

// ToolButton

procedure TranslateToolButton(x : TToolButton); overload;
begin
  x.Caption := T(x.Caption);
  x.Hint := T(x.Hint)
end;

procedure TranslateToolButton(x : TTntToolButton); overload;
begin
  x.Caption := U(x.Caption);
  x.Hint := U(x.Hint)
end;

// TabSheet

procedure TranslateTTabSheet(x : TTabSheet);
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateTTntTabSheet(x : TTntTabSheet);
begin
  x.Caption := U(x.Caption)
end;

// DockablePanel

procedure TranslateDockablePanel(x : TSpTBXDockablePanel);
begin
  x.Caption := U(x.Caption)
end;

// GroupBox

procedure TranslateGroupBox(x : TGroupBox); overload;
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateGroupBox(x : TTntGroupBox); overload;
begin
  x.Caption := U(x.Caption)
end;

procedure TranslateGroupBox(x : TSpTBXGroupBox); overload;
begin
  x.Caption := U(x.Caption)
end;

// CheckBox

procedure TranslateTCheckBox(x : TCheckBox);
begin
  x.Caption := T(x.Caption)
end;

procedure TranslateTTntCheckBox(x : TTntCheckBox);
begin
  x.Caption := U(x.Caption)
end;

procedure TranslateTSpTBXCheckBox(x : TSpTBXCheckBox);
begin
  x.Caption := U(x.Caption)
end;

// RadioGroup

procedure TranslateTRadioGroup(x : TRadioGroup);
var
  i : integer;
begin
  x.Caption := T(x.Caption);
  for i := 0 to x.Items.Count - 1
    do x.Items[i] := T(x.Items[i])
end;

procedure TranslateTTntRadioGroup(x : TTntRadioGroup);
var
  i : integer;
begin
  x.Caption := U(x.Caption);
  for i := 0 to x.Items.Count - 1
    do x.Items[i] := U(x.Items[i])
end;

procedure TranslateTSpTBXRadioGroup(x : TSpTBXRadioGroup);
var
  i : integer;
begin
  x.Caption := U(x.Caption);
  for i := 0 to x.Items.Count - 1
    do x.Items[i] := U(x.Items[i])
end;

// RadioButton

procedure TranslateTRadioButton(x : TRadioButton);
begin
  x.Caption := T(x.Caption);
end;

procedure TranslateTTntRadioButton(x : TTntRadioButton);
begin
  x.Caption := U(x.Caption);
end;

procedure TranslateTSpTBXRadioButton(x : TSpTBXRadioButton);
begin
  x.Caption := U(x.Caption);
end;

// ComboBox

procedure TranslateTComboBox(x : TComboBox);
var
  n, i : integer;
begin
  n := x.ItemIndex;

  for i := 0 to x.Items.Count - 1 do
    if x.Items[i] <> ''
      then x.Items[i] := T(x.Items[i]);

  x.ItemIndex := n
end;

procedure TranslateTTntComboBox(x : TTntComboBox);
var
  n, i : integer;
begin
  n := x.ItemIndex;

  for i := 0 to x.Items.Count - 1 do
    if x.Items[i] <> ''
      then x.Items[i] := U(x.Items[i]);

  x.ItemIndex := n
end;

// CheckListBox

procedure TranslateTCheckListBox(x : TCheckListBox);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    if x.Items[i] <> ''
      then x.Items[i] := T(x.Items[i])
end;

procedure TranslateTTntCheckListBox(x : TTntCheckListBox);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    if x.Items[i] <> ''
      then x.Items[i] := U(x.Items[i])
end;

procedure TranslateTSpTBXCheckListBox(x : TSpTBXCheckListBox);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    if x.Items[i] <> ''
      then x.Items[i] := U(x.Items[i])
end;

// StringGrid

procedure TranslateTStringGrid(x : TStringGrid);
var
  i, j : integer;
begin
  for i := 0 to x.RowCount - 1 do
    for j := 0 to x.ColCount - 1 do
      if x.Cells[j, i] <> ''
        then x.Cells[j, i] := T(x.Cells[j, i])
end;

procedure TranslateTTntStringGrid(x : TTntStringGrid);
var
  i, j : integer;
begin
  for i := 0 to x.RowCount - 1 do
    for j := 0 to x.ColCount - 1 do
      if x.Cells[j, i] <> ''
        then x.Cells[j, i] := U(x.Cells[j, i])
end;

// ListView

procedure TranslateTListView(x : TListView);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    if x.Items.Item[i].Caption <> ''
      then x.Items.Item[i].Caption := T(x.Items.Item[i].Caption)
end;

procedure TranslateTTntListView(x : TTntListView);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    if x.Items.Item[i].Caption <> ''
      then x.Items.Item[i].Caption := U(x.Items.Item[i].Caption)
end;

// HeaderControl

procedure TranslateTTntHeaderControl(x : TTntHeaderControl);
var
  i : integer;
begin
  for i := 0 to x.Sections.Count - 1 do
    if x.Sections.Items[i].Text <> ''
      then x.Sections.Items[i].Text := U(x.Sections.Items[i].Text)
end;

// SpTBXToolbar, SpTBXItem

procedure TranslateTSpTBXToolbar(x : TSpTBXToolbar);
var
  i : integer;
begin
  for i := 0 to x.Items.Count - 1 do
    TranslateComponent(x.Items[i])
end;

procedure TranslateTSpTBXLabelItem(x : TSpTBXLabelItem);
var
  i : integer;
begin
  x.Caption := U(x.Caption);
  x.Hint := U(x.Hint);
end;

procedure TranslateTSpTBXItem(x : TSpTBXItem);
var
  i : integer;
begin
  x.Caption := U(x.Caption);
  x.Hint := U(x.Hint);
end;

// Component

procedure TranslateComponent(x : TComponent);
begin
  // order of tests is relevant

  // ActionList
  if x is TActionList
    then TranslateActionList(TActionList(x))
    else
  if x is TTntActionList
    then TranslateActionList(TTntActionList(x))
    else
  // MenuItem
  if x is TTntMenuItem
    then TranslateMenuItem(TTntMenuItem(x))
    else
  if x is TMenuItem
    then TranslateMenuItem(TMenuItem(x))
    else
  if x is TSpTBXSubMenuItem
    then TranslateMenuItem(TSpTBXSubMenuItem(x))
    else
  if x is TSpTBXItem
    then TranslateMenuItem(TSpTBXItem(x))
    else
  // TLabel
  if x is TTntLabel
    then TranslateLabel(TTntLabel(x))
    else
  if x is TSpTBXLabel
    then TranslateLabel(TSpTBXLabel(x))
    else
  if x is TLabel
    then TranslateLabel(TLabel(x))
    else
  // TLabeledEdit
  if x is TLabeledEdit
    then TranslateLabeledEdit(TLabeledEdit(x))
    else
  // BitBtn
  if x is TTntBitBtn
    then TranslateBitBtn(TTntBitBtn(x))
    else
  if x is TBitBtn
    then TranslateBitBtn(TBitBtn(x))
    else
  // Button
  if x is TTntButton
    then TranslateButton(TTntButton(x))
    else
  if x is TSpTBXButton
    then TranslateButton(TSpTBXButton(x))
    else
  if x is TButton
    then TranslateButton(TButton(x))
    else
  // SpeedButton
  if x is TTntSpeedButton
    then TranslateTntSpeedButton(TTntSpeedButton(x))
    else
  if x is TSpeedButton
    then TranslateSpeedButton(TSpeedButton(x))
    else
  // ToolButton
  if x is TTntToolButton
    then TranslateToolButton(TTntToolButton(x))
    else
  if x is TToolButton
    then TranslateToolButton(TToolButton(x))
    else
  // TCheckBox
  if x is TCheckBox
    then TranslateTCheckBox(TCheckBox(x))
    else
  if x is TSpTBXCheckBox
    then TranslateTSpTBXCheckBox(TSpTBXCheckBox(x))
    else
  if x is TTntCheckBox
    then TranslateTTntCheckBox(TTntCheckBox(x))
    else
  // TComboBox
  if x is TTntComboBox
    then TranslateTTntComboBox(TTntComboBox(x))
    else
  if x is TComboBox
    then TranslateTComboBox(TComboBox(x))
    else
  // DockablePanel
  if x is TSpTBXDockablePanel
    then TranslateDockablePanel(x as TSpTBXDockablePanel)
    else
  // GroupBox
  if x is TGroupBox
    then TranslateGroupBox(TGroupBox(x))
    else
  if x is TTntGroupBox
    then TranslateGroupBox(TTntGroupBox(x))
    else
  if x is TSpTBXGroupBox
    then TranslateGroupBox(TSpTBXGroupBox(x))
    else
  // TRadioGroup
  if x is TRadioGroup
    then TranslateTRadioGroup(TRadioGroup(x))
    else
  if x is TTntRadioGroup
    then TranslateTTntRadioGroup(TTntRadioGroup(x))
    else
  if x is TSpTBXRadioGroup
    then TranslateTSpTBXRadioGroup(TSpTBXRadioGroup(x))
    else
  // RadioButton
  if x is TSpTBXRadioButton
    then TranslateTSpTBXRadioButton(TSpTBXRadioButton(x))
    else
  if x is TTntRadioButton
    then TranslateTTntRadioButton(TTntRadioButton(x))
    else
  if x is TRadioButton
    then TranslateTRadioButton(TRadioButton(x))
    else
  // TCheckList
  if x is TSpTBXCheckListBox
    then TranslateTSpTBXCheckListBox(TSpTBXCheckListBox(x))
    else
  if x is TTntCheckListBox
    then TranslateTTntCheckListBox(TTntCheckListBox(x))
    else
  if x is TCheckListBox
    then TranslateTCheckListBox(TCheckListBox(x))
    else
  // TListView
  if x is TListView
    then TranslateTListView(TListView(x))
    else
  if x is TTntListView
    then TranslateTTntListView(TTntListView(x))
    else
  // TStringGrid
  if x is TTntStringGrid
    then TranslateTTntStringGrid(TTntStringGrid(x))
    else
  if x is TStringGrid
    then TranslateTStringGrid(TStringGrid(x))
    else
  // TTabSheet
  if x is TTntTabSheet
    then TranslateTTntTabSheet(TTntTabSheet(x))
    else
  if x is TTabSheet
    then TranslateTTabSheet(TTabSheet(x))
    else
  // HeaderControl
  if x is TTntHeaderControl
    then TranslateTTntHeaderControl(x as TTntHeaderControl)
    else
  // SpTBXToolbar
  if x is TSpTBXToolbar
    then TranslateTSpTBXToolbar(x as TSpTBXToolbar)
    else
  // SpTBXItem
  if x is TSpTBXItem
    then TranslateTSpTBXItem(x as TSpTBXItem)
    else
  if x is TSpTBXLabelItem
    then TranslateTSpTBXLabelItem(x as TSpTBXLabelItem)
    else
  // Frame
  if x is TFrame
    then TranslateTComponent(x)
    else
  if x is TTntFrame
    then TranslateTComponent(x)
    else
  if True
    then TranslateTComponent(x)
end;

procedure TranslateTComponent(x : TComponent);
var
  i : integer;
begin
  for i := 0 To x.ComponentCount - 1 do
    TranslateComponent(x.Components[i])
end;

// TForm

procedure TranslateForm(x : TForm);
begin
  x.Caption := U(x.Caption);
  TranslateTComponent(x)
end;

procedure TranslateForm(x : TTntForm);
begin
  x.Caption := U(x.Caption);
  TranslateTComponent(x)
end;

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------


