// ---------------------------------------------------------------------------
// -- Drago -- Translated shortcuts ------------------------ UShortcuts.pas --
// ---------------------------------------------------------------------------

{
This unit gives new definitions to ShortCutToText and TextToShortCut functions.
This is done:
- 1st to handle and store in inifile English strings whatever the Delphi
  version is (mine is French)
- 2nd to enable translation of the shortcuts in menus, hints and shortcut
  setting dialog.
}

unit UShortcuts;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, StdCtrls, Consts, Menus;

// English forms
function EnShortCutToText(ShortCut: TShortCut): string;
function EnTextToShortCut(Text: string): TShortCut;
// Translated forms (with the current translation file, see Translate.pas)
function TrShortCutToText(ShortCut: TShortCut): string;
function TrTextToShortCut(Text: string): TShortCut;

// ---------------------------------------------------------------------------

implementation

uses
  WinUtils, Translate;

// -- English and French shortcut strings (from Consts.pas) ------------------
(*
const
  SmkcBkSp  = 'BkSp';
  SmkcTab   = 'Tab';
  SmkcEsc   = 'Esc';
  SmkcEnter = 'Enter';
  SmkcSpace = 'Space';
  SmkcPgUp  = 'PgUp';
  SmkcPgDn  = 'PgDn';
  SmkcEnd   = 'End';
  SmkcHome  = 'Home';
  SmkcLeft  = 'Left';
  SmkcUp    = 'Up';
  SmkcRight = 'Right';
  SmkcDown  = 'Down';
  SmkcIns   = 'Ins';
  SmkcDel   = 'Del';
  SmkcShift = 'Shift+';
  SmkcCtrl  = 'Ctrl+';
  SmkcAlt   = 'Alt+';
*)
// -- Definitions from Menus.pas (D5 pro) ------------------------------------

// Only difference is use of MyMenuKeyCaps function to make translation
// and <PATCH> ... </PATCH> to translate names of Shift, Ctrl and Alt when
// they are down alone.

// <QUOTE>

type
  TMenuKeyCap = (mkcBkSp, mkcTab, mkcEsc, mkcEnter, mkcSpace, mkcPgUp,
    mkcPgDn, mkcEnd, mkcHome, mkcLeft, mkcUp, mkcRight, mkcDown, mkcIns,
    mkcDel, mkcShift, mkcCtrl, mkcAlt);

var
  MenuKeyCaps: array[TMenuKeyCap] of string = (
    SmkcBkSp, SmkcTab, SmkcEsc, SmkcEnter, SmkcSpace, SmkcPgUp,
    SmkcPgDn, SmkcEnd, SmkcHome, SmkcLeft, SmkcUp, SmkcRight,
    SmkcDown, SmkcIns, SmkcDel, SmkcShift, SmkcCtrl, SmkcAlt);

// </QUOTE>

var
  DoTranslation : boolean = False;

function MyMenuKeyCaps(x : TMenuKeyCap) : string;
begin
  if not DoTranslation
    then Result := MenuKeyCaps[x]
    else Result := T(MenuKeyCaps[x])
end;

// <QUASIQUOTE>

function GetSpecialName(ShortCut: TShortCut): string;
var
  ScanCode: Integer;
  KeyName: array[0..255] of Char;
begin
  Result := '';
  ScanCode := MapVirtualKey(WordRec(ShortCut).Lo, 0) shl 16;
  if ScanCode <> 0 then
  begin
    GetKeyNameText(ScanCode, KeyName, SizeOf(KeyName));
    GetSpecialName := KeyName;
  end;
end;

function ShortCutToText(ShortCut: TShortCut): string;
var
  Name: string;
begin
  case WordRec(ShortCut).Lo of
    $08, $09:
    Name := MyMenuKeyCaps(TMenuKeyCap(Ord(mkcBkSp) + WordRec(ShortCut).Lo - $08));
    $0D: Name := MyMenuKeyCaps(mkcEnter);
    $1B: Name := MyMenuKeyCaps(mkcEsc);
    $20..$28:
    Name := MyMenuKeyCaps(TMenuKeyCap(Ord(mkcSpace) + WordRec(ShortCut).Lo - $20));
    $2D..$2E:
    Name := MyMenuKeyCaps(TMenuKeyCap(Ord(mkcIns) + WordRec(ShortCut).Lo - $2D));
    $30..$39: Name := Chr(WordRec(ShortCut).Lo - $30 + Ord('0'));
    $41..$5A: Name := Chr(WordRec(ShortCut).Lo - $41 + Ord('A'));
    $60..$69: Name := Chr(WordRec(ShortCut).Lo - $60 + Ord('0'));
    $70..$87: Name := 'F' + IntToStr(WordRec(ShortCut).Lo - $6F);
  else
    {PATCH}
    case ShortCut of
    $10 : Name := MyMenuKeyCaps(mkcShift);
    $11 : Name := MyMenuKeyCaps(mkcCtrl);
    $12 : Name := MyMenuKeyCaps(mkcAlt);
    else {/PATCH}Name := GetSpecialName(ShortCut)
    end
  end;
  if Name <> '' then
  begin
    Result := '';
    if ShortCut and scShift <> 0 then Result := Result + MyMenuKeyCaps(mkcShift);
    if ShortCut and scCtrl <> 0 then Result := Result + MyMenuKeyCaps(mkcCtrl);
    if ShortCut and scAlt <> 0 then Result := Result + MyMenuKeyCaps(mkcAlt);
    Result := Result + Name;
  end
  else Result := '';
end;

{ This function is *very* slow.  Use sparingly.  Return 0 if no VK code was
  found for the text }

function TextToShortCut(Text: string): TShortCut;

  { If the front of Text is equal to Front then remove the matching piece
    from Text and return True, otherwise return False }

  function CompareFront(var Text: string; const Front: string): Boolean;
  begin
    Result := False;
    if (Length(Text) >= Length(Front)) and
    (AnsiStrLIComp(PChar(Text), PChar(Front), Length(Front)) = 0) then
    begin
    Result := True;
    Delete(Text, 1, Length(Front));
    end;
  end;

var
  Key: TShortCut;
  Shift: TShortCut;
begin
  Result := 0;
  Shift := 0;
  while True do
  begin
    if CompareFront(Text, MyMenuKeyCaps(mkcShift)) then Shift := Shift or scShift
    else if CompareFront(Text, '^') then Shift := Shift or scCtrl
    else if CompareFront(Text, MyMenuKeyCaps(mkcCtrl)) then Shift := Shift or scCtrl
    else if CompareFront(Text, MyMenuKeyCaps(mkcAlt)) then Shift := Shift or scAlt
    else Break;
  end;
  if Text = ''
    then Exit;
  for Key := $08 to $255 do { Copy range from table in ShortCutToText }
    if AnsiCompareText(Text, ShortCutToText(Key)) = 0 then
      begin
        Result := Key or Shift;
        Exit;
      end;
end;

// </QUASIQUOTE>

// -- English shortcut to text conversions -----------------------------------

function EnShortCutToText(shortCut : TShortCut) : string;
begin
  DoTranslation := False;
  Result := ShortCutToText(shortCut)
end;

function EnTextToShortCut(text : string) : TShortCut;
begin
  DoTranslation := False;
  Result := TextToShortCut(text)
end;

// -- Shortcut to text conversions with translation --------------------------

function TrShortCutToText(shortCut : TShortCut) : string;
begin
  DoTranslation := True;
  Result := ShortCutToText(shortCut)
end;

function TrTextToShortCut(text : string) : TShortCut;
begin
  DoTranslation := True;
  Result := TextToShortCut(text)
end;

// ---------------------------------------------------------------------------

initialization
  OverwriteProcedure(@Menus.ShortCutToText, @TrShortCutToText)
end.
