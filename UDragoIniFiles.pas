unit UDragoIniFiles;

interface

uses
  IniFiles;

(*
type
  TCustomSetting = class
    FSection : string;
    FIdent : string;
  end;

  TWideStringSetting = class(TCustomSetting)
  private
    FValue : WideString;
    FDefault : WideString;
  public
    constructor Create(const section, ident : string; const default : WideString);
    procedure Save;
    procedure Read;
    procedure Restore;
    property Value read FValue write FValue;
  end;
*)

type
  TDragoIniFile = class(TMemIniFile)
    function  ReadWideStr (const Section, Ident : string; const Default : WideString) : WideString;
    procedure WriteWideStr(const Section, Ident : string; const Value : WideString);
  end;

implementation

function TDragoIniFile.ReadWideStr(const Section, Ident : string; const Default : WideString) : WideString;
begin
  Result := UTF8Decode(ReadString(Section, Ident, UTF8Encode(Default)))
end;

procedure TDragoIniFile.WriteWideStr(const Section, Ident : string; const Value : WideString);
begin
  WriteString(Section, Ident, UTF8Encode(Value))
end;

end.
