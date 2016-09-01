// ---------------------------------------------------------------------------
// -- Drago -- SQL request picker ------------------------ UDBSQLPicker.pas --
// ---------------------------------------------------------------------------

unit UDBSQLPicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, 
  UfrDBPickerCaption, TntForms;

type
  TDBSQLPicker = class(TFrame)
    Memo: TMemo;
    PickerCaption: TfrDBPickerCaption;
    procedure PickerCaptionClick(Sender: TObject);
  private
    FFullHeight : integer;
    procedure SetVisibility(aVisible : boolean);
  public
    procedure Default(aVisible : boolean);
    function GetRequest : string;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  VclUtils, Translate;

{$R *.dfm}

// -- Default configuration --------------------------------------------------

procedure TDBSQLPicker.Default(aVisible : boolean);
begin
  PickerCaption.CheckBox := True;
  PickerCaption.Caption := U('SQL...');

  AvoidFlickering([self]);
  FFullHeight := Height;
  Memo.Clear;

  PickerCaption.Checked := aVisible;
  PickerCaptionClick(nil);
  Invalidate;
end;

// -- Visibility -------------------------------------------------------------

procedure TDBSQLPicker.SetVisibility(aVisible : boolean);
begin
  Memo.Visible := aVisible
end;

procedure TDBSQLPicker.PickerCaptionClick(Sender: TObject);
begin
  if PickerCaption.Checked
    then
      begin
        Align := alClient;
        SetVisibility(True)
      end
    else
      begin
        Align := alTop;
        SetVisibility(False);
        Height := PickerCaption.Height
      end
end;

// -- Construction of request ------------------------------------------------

function TDBSQLPicker.GetRequest : string;
begin
  Result := Memo.Text
end;

// ---------------------------------------------------------------------------

end.
