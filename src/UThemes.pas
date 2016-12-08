unit UThemes;

interface

uses
  Classes, SpTBXSkins;

procedure GetAvailableThemes(list : TStringList);
function  GetCurrentTheme : string;
procedure SetCurrentTheme(theme : string);

implementation

procedure GetAvailableThemes(list : TStringList);
begin
  list.Clear;
  SkinManager.SkinsList.GetSkinNames(list);
  list.Sort
end;

function GetCurrentTheme : string;
begin
  Result := SkinManager.CurrentSkinName
end;

procedure SetCurrentTheme(theme : string);
begin
  SkinManager.SetSkin(theme)
end;

end.
