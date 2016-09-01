// ---------------------------------------------------------------------------
// -- Drago -- Database picker ---------------------- UDBBaseNamePicker.pas --
// ---------------------------------------------------------------------------

unit UDBBaseNamePicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Forms, Controls, Buttons, StdCtrls, ExtCtrls,
  TntForms, TntButtons, SpTBXControls, SpTBXItem;

type
  TDBBaseNamePicker = class(TFrame)
    SpTBXGroupBox1: TSpTBXGroupBox;
    cbName: TComboBox;
    sbOpen: TTntSpeedButton;
    lbName: TSpTBXLabel;
    procedure sbOpenClick(Sender: TObject);
    procedure sbNewClick(Sender: TObject);
    procedure cbNameChange(Sender: TObject);
  public
    procedure Default;
    procedure DoUpdate;
    procedure DoUpdateWithList(listOfDBTabs : TStringList);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Graphics,
  DefineUi, VclUtils, Translate, UActions, Main, UfmDBSearch, UnicodeUtils;

{$R *.dfm}

// -- Default configuration --------------------------------------------------

procedure TDBBaseNamePicker.Default;
begin
  AvoidFlickering([self]);
  Invalidate;
end;

// -- Update -----------------------------------------------------------------

procedure TDBBaseNamePicker.DoUpdate;
var
  list : TStringList;
begin
  list := fmMain.DBListOfTabs.ListOfCaptions;
  DoUpdateWithList(list);
  list.Free
end;

function WideMinimizeNameNC(name : WideString; font : TFont; width : integer) : WideString;
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.Canvas.Font.Assign(font);
  Result := WideMinimizeName(name, bmp.Canvas, width);
  bmp.Free
end;

procedure TDBBaseNamePicker.DoUpdateWithList(listOfDBTabs : TStringList);
var
  i : integer;
begin
  cbName.Clear;
  
  if listOfDBTabs.Count = 0
    then
      begin
        cbName.Text := '';
        lbName.Font.Color := clRed;
        lbName.Caption := U('No database loaded... Load or create.')
      end
    else
      begin
        for i := 0 to listOfDBTabs.Count - 1 do
          cbName.Items.Add(ExtractFileName(listOfDBTabs[i]));
        cbName.ItemIndex := 0;
        lbName.Font.Color := clBlack;
        lbName.Caption := WideMinimizeNameNC(listOfDBTabs[0],
                                             lbName.Font,
                                             ClientWidth - 2 * lbName.Left);
        // freed by caller
        //listOfDBTabs.Free;
        Invalidate
      end
end;

procedure TDBBaseNamePicker.cbNameChange(Sender: TObject);
begin
  fmMain.DBListOfTabs.Promote(cbName.Text);
  with fmDBSearch do
    if FSearchMode = smInfo
      then frDBRequestPanel.DoWhenUpdating
end;

// -- Button events ----------------------------------------------------------

procedure TDBBaseNamePicker.sbOpenClick(Sender: TObject);
begin
  Actions.acOpenDatabase.Execute
end;

procedure TDBBaseNamePicker.sbNewClick(Sender: TObject);
begin
  Actions.acCreateDatabase.Execute
end;

// ---------------------------------------------------------------------------

end.


