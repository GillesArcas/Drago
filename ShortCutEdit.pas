// ---------------------------------------------------------------------------

// This file comes from Ini Translator open source freeware. It has been
// modified to cope with Drago needs and style.
//
//
// The original file can be downloaded at xxx.sourceforge.net.
// All credit and copyright is retained by Peter Thornqvist.

unit ShortCutEdit;

// ---------------------------------------------------------------------------

interface
uses
  Windows, Messages, SysUtils, Classes, StdCtrls, Consts;

type
  TShortCutEdit = class(TEdit) 
  private
    FKey : Word;
    FShift : TShiftState;
    function  GetShortCut: TShortCut;
    procedure SetShortCut(const Value: TShortCut);
  protected
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

  public
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property HotKey : TShortCut read GetShortCut write SetShortCut;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BorderStyle;
    property OnChange;
  end;

// ---------------------------------------------------------------------------

implementation

uses Menus, UShortcuts;

// -- Shortcut property access -----------------------------------------------

function TShortCutEdit.GetShortCut : TShortCut;
begin
  //Result := TextToShortCut(Text);
  Result := Menus.ShortCut(FKey, FShift)
end;

procedure TShortCutEdit.SetShortCut(const Value : TShortCut);
begin
  Text := TrShortCutToText(Value);
end;

// -- Editing functions ------------------------------------------------------

procedure TShortCutEdit.KeyDown(var Key : Word; Shift : TShiftState);
begin
  //inherited;
  FKey := Key;
  FShift := Shift;

  if (Shift = []) and ((Key = VK_BACK) or (Key = VK_ESCAPE)) then
    begin
      Text := '';
      Key := 0;
      exit
    end;

  if (Shift = []) and not (Key in [VK_PRIOR..VK_DOWN, VK_F1..VK_F24,
                                            VK_INSERT, VK_DELETE]) then
    begin
      Key := 0;
      exit
    end;

  if (Shift = [ssShift]) and not (Key in [VK_SHIFT, VK_PRIOR..VK_DOWN,
                                            VK_F1..VK_F24,
                                            VK_INSERT, VK_DELETE]) then
    begin
      Key := 0;
      exit
    end;

  if Key = VK_CONTROL
    then Exclude(Shift, ssCtrl);
  if Key = VK_SHIFT
    then Exclude(Shift, ssShift);
  if Key = VK_MENU
    then Exclude(Shift, ssAlt);

  HotKey := Menus.ShortCut(Key, Shift);
  SelStart := Length(Text);
  Key := 0
end;

procedure TShortCutEdit.KeyPress(var Key: Char);
begin
  inherited;
  Key := #0;
end;

procedure TShortCutEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  Menus.ShortCutToKey(Self.HotKey, Key, Shift);
  if (Key in [VK_CONTROL,VK_SHIFT,VK_MENU])
    then Key := 0;
  HotKey := Menus.ShortCut(Key, Shift);

  Key := 0
end;

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------

