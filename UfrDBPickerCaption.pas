// ---------------------------------------------------------------------------
// -- Drago -- Caption frame for DB pickers -------- UfrDBPickerCaption.pas --
// ---------------------------------------------------------------------------

unit UfrDBPickerCaption;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls,
  TntForms, TntStdCtrls, TntSystem, TntGraphics;

type
  TfrDBPickerCaption = class(TTntFrame)
    Bevel1: TBevel;
    CheckBox1: TCheckBox;
    Label1: TTntLabel;
  private
    OnClickOnCheck : TNotifyEvent;
  public
    procedure SetCaption(s : WideString);
    procedure SetCheckBox(x : boolean);
    function  GetChecked : boolean;
    procedure SetChecked(x : boolean);
    property CheckBox : boolean write SetCheckBox default False;
    property Caption : WideString write SetCaption;
    property Checked : boolean read GetChecked write SetChecked;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

procedure TfrDBPickerCaption.SetCheckBox(x : boolean);
begin
  CheckBox1.Visible := x;
  CheckBox1.Left := 2;
  CheckBox1.Top := 0;
  if x
    then Label1.Left := CheckBox1.Left + CheckBox1.Width + 2 //17
    else Label1.Left := 10
end;

procedure TfrDBPickerCaption.SetCaption(s : WideString);
begin
  ParentBackground := False;
  ParentColor := False;
  Color := $F7F7F7;
  Label1.Transparent := False;
  Label1.Font.Color := $D54600;
  Label1.Caption := s;
  Label1.Width := WideCanvasTextWidth(Label1.Canvas, s);

  if CheckBox1.Visible then
    begin
      Bevel1.Align := alNone;
      Bevel1.Left := Label1.Left + Label1.Width;
      Bevel1.Width := Width - (Label1.Left + Label1.Width)
    end
end;

function TfrDBPickerCaption.GetChecked : boolean;
begin
  Result := CheckBox1.Checked
end;

procedure TfrDBPickerCaption.SetChecked(x : boolean);
begin
  CheckBox1.Checked := x
end;

// ---------------------------------------------------------------------------

end.
