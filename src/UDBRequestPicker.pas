// ---------------------------------------------------------------------------
// -- Drago -- Field picker for database request ----- UDBRequestPicker.pas --
// ---------------------------------------------------------------------------

unit UDBRequestPicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Components, ExtCtrls,
  UfrDBPickerCaption, SpTBXControls, TntStdCtrls,
  SpTBXEditors, SpTBXItem, TntForms;

const
  ComboCount =  4;
  FieldCount = 10;

type
  TDBRequestPicker = class(TFrame)
    StringGrid: TControlStringgrid;
    Bevel3: TBevel;
    PickerCaption: TfrDBPickerCaption;
    btAdd: TSpTBXButton;
    btRemove: TSpTBXButton;
    btClear: TSpTBXButton;
    ComboBox1: TSpTBXComboBox;
    ComboBox2: TSpTBXComboBox;
    ComboBox3: TSpTBXComboBox;
    ComboBox4: TSpTBXComboBox;
    procedure ComboBox1Change(Sender: TObject);
    procedure StringGridTopLeftChanged(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure btRemoveClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure PickerCaptionClick(Sender: TObject);
    procedure StringGridKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
  private
    FFullHeight : integer;
    ComboBoxes : array[0 .. ComboCount - 1] of TSpTBXComboBox;
    FieldIndex : array[0 .. FieldCount - 1] of integer;
    procedure AdjustDimensions;
    procedure SetVisibility(aVisible : boolean);
    procedure ChangeRequest;
  public
    procedure Initialize;
    procedure Default(aVisible : boolean);
    function GetRequest : string;
  end;

//var
//  ifrRequestPicker: TifrRequestPicker;

// ---------------------------------------------------------------------------

implementation

uses Std, VclUtils, Translate, Properties, UfrDBRequestPanel;

{$R *.dfm}

const Properties : array[1 .. 14] of string = ('BR', 'DT', 'EV', 'HA', 'KM',
                                               'PB', 'PC', 'PW', 'RE', 'RO',
                                               'RU', 'SZ', 'US', 'WR');

// -- Initialization ---------------------------------------------------------

procedure TDBRequestPicker.Initialize;
var
  rect : TRect;
  i, j : integer;
begin
  StringGrid.DoubleBuffered := True;

  StringGrid.Top := 18;
  StringGrid.Left  := ComboBox1.Left + ComboBox1.Width;
  StringGrid.Width := ClientWidth - ComboBox1.Width - 2 * ComboBox1.Left + 2;
  StringGrid.ColWidths[0] := StringGrid.Width - 4;

  // use extra column to hide selection
  StringGrid.ColWidths[1] := 0;

  StringGrid.RowCount := ComboCount;
  StringGrid.DefaultRowHeight := 20;//ComboBox1.Height;
  StringGrid.Cells[0, 0] := '';

  // make list of combos
  ComboBoxes[0] := ComboBox1;
  ComboBoxes[1] := ComboBox2;
  ComboBoxes[2] := ComboBox3;
  ComboBoxes[3] := ComboBox4;
  
  for i := 0 to ComboCount - 1 do
    with ComboBoxes[i] do
      begin
        Tag   := i;
        Width := 100;
        rect  := StringGrid.CellRect(0, i);
        Top   := StringGrid.Top + Rect.Top + 2;
        Style := csDropDownList;

        Items.Add('--');
        for j := Low(Properties) to High(Properties) do
          Items.Add(U(FindPropText(Properties[j])));

        OnChange := ComboBox1Change;
        DropDownCount := Items.Count;
        ItemIndex := 0;

        Visible := i = 0
      end;

  StringGrid.RowCount := 1;

  AdjustDimensions
end;

// -- Default configuration --------------------------------------------------

procedure TDBRequestPicker.Default(aVisible : boolean);
begin
  PickerCaption.CheckBox := True;
  PickerCaption.Caption := U('More...');

  AvoidFlickering([self]);
  FFullHeight := Height;

  PickerCaption.Checked := aVisible;
  PickerCaptionClick(nil);
  Invalidate
end;

// adjust dim

procedure TDBRequestPicker.AdjustDimensions;
var
  n, y : integer;
begin
  // number of visible comboboxes
  n := Min(StringGrid.RowCount, ComboCount);

  // adjust height of stringgrid and select extra column to hide selection
  StringGrid.Col := 1;
  StringGrid.Height := ComboBoxes[n - 1].Top + ComboBox1.Height - ComboBox1.Top + 4;

  // adjust bevel around comboboxes and stringgrid
  Bevel3.BoundsRect := Rect(ComboBox1.Left - 1, StringGrid.Top,
                            StringGrid.Left + StringGrid.Width + 1 + 1,
                            StringGrid.Top + StringGrid.Height + 1 + 1);

  // adjust height of frame
  y := StringGrid.Top + StringGrid.Height + 8;
  Height := y + btAdd.Height + 8;
  FFullHeight := Height;

  // adjust buttons
  btAdd.Top := y;
  btRemove.Top := y;
  btClear.Top := y;

  Invalidate
end;

// -- Visibility -------------------------------------------------------------

procedure TDBRequestPicker.SetVisibility(aVisible : boolean);
begin
  StringGrid.Visible := aVisible;
  ComboBox1.Visible := aVisible;
  ComboBox2.Visible := aVisible and (StringGrid.RowCount >= 2);
  ComboBox3.Visible := aVisible and (StringGrid.RowCount >= 3);
  ComboBox4.Visible := aVisible and (StringGrid.RowCount >= 4);
  btAdd.Visible := aVisible;
  btRemove.Visible := aVisible;
  btClear.Visible := aVisible;
  Bevel3.Visible := aVisible;
  ChangeRequest
end;

procedure TDBRequestPicker.PickerCaptionClick(Sender: TObject);
begin
  inherited;

  if PickerCaption.Checked
    then
      begin
        Height := FFullHeight;
        SetVisibility(True)
      end
    else
      begin
        SetVisibility(False);
        Height := PickerCaption.Height
      end
end;

// -- Construction of request ------------------------------------------------

function TDBRequestPicker.GetRequest : string;
var
  i, n : integer;
  pn, pv, s : string;
begin
  Result := '';

  if not PickerCaption.Checked
    then exit;

  for i := 0 to StringGrid.RowCount - 1 do
    begin
      n := FieldIndex[i];
      if n = 0 // '--' entry
        then continue;

      pn := Properties[n];
      pv := StringGrid.Cells[0, i];

      s := pn + ' like ' + AnsiQuotedStr('%' + pv + '%', '''');

      if Result = ''
        then Result := s
        else Result := Result + ' AND ' + s
    end;

  if Result <> ''
    then Result := '(' + Result + ')'
end;

// -- Event handlers ---------------------------------------------------------

procedure TDBRequestPicker.ChangeRequest;
begin
  (Parent as TfrDBRequestPanel).ChangeRequest
end;

procedure TDBRequestPicker.ComboBox1Change(Sender: TObject);
var
  cb : TSpTBXComboBox;
begin
  inherited;
  cb := Sender as TSpTBXComboBox;

  FieldIndex[StringGrid.TopRow + cb.Tag] := cb.ItemIndex;
  ChangeRequest;
end;

procedure TDBRequestPicker.StringGridTopLeftChanged(Sender: TObject);
var
  i : integer;
begin
  inherited;
  for i := 0 to 3 do
    ComboBoxes[i].ItemIndex := FieldIndex[StringGrid.TopRow + i];
  ChangeRequest
end;

procedure TDBRequestPicker.StringGridKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ChangeRequest
end;

// -- Handling of field list -------------------------------------------------

procedure TDBRequestPicker.btAddClick(Sender: TObject);
begin
  inherited;

  with StringGrid do
    if RowCount < 9 then
      begin
        RowCount := RowCount + 1;
        if RowCount <= 4
          then ComboBoxes[RowCount - 1].Visible := True;
        Row := RowCount - 1;
        FieldIndex[Row] := 0;
        Cells[0, Row] := ''
      end;

  AdjustDimensions;
  ChangeRequest
end;

procedure TDBRequestPicker.btRemoveClick(Sender: TObject);
begin
  inherited;

  with StringGrid do
    if RowCount = 1
      then
        begin
          FieldIndex[0] := 0;
          ComboBoxes[0].ItemIndex := 0;
          Cells[0, 0] := '';
        end
      else
        begin
          if RowCount <= 4 then
            begin
              FieldIndex[RowCount - 1] := 0;
              ComboBoxes[RowCount - 1].ItemIndex := 0;
              Cells[0, RowCount - 1] := '';
              ComboBoxes[RowCount - 1].Visible := False;
            end;
          RowCount := RowCount - 1;
          Row := RowCount - 1;
        end;

  AdjustDimensions;
  ChangeRequest
end;

procedure TDBRequestPicker.btClearClick(Sender: TObject);
begin
  inherited;
  while StringGrid.RowCount > 1 do
    btRemoveClick(Sender);

  btRemoveClick(Sender)
end;

// ---------------------------------------------------------------------------

end.
