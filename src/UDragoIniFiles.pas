unit UDragoIniFiles;

interface

uses
  TntIniFiles;

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
  TDragoIniFile = class(TTntMemIniFile)
  public
    constructor Create(iniName: WideString); overload;
    function  ReadWideStr (const Section, Ident : string; const Default : WideString) : WideString;
    procedure WriteWideStr(const Section, Ident : string; const Value : WideString);
  end;

implementation

uses
  WinUtils, TntWindows, TntSysUtils;

constructor TDragoIniFile.Create(iniName: WideString);
begin
  inherited Create(iniName);
  //WideForceDirectories(DragoIniDirName)
end;

function TDragoIniFile.ReadWideStr(const Section, Ident : string; const Default : WideString) : WideString;
begin
  //Result := UTF8Decode(ReadString(Section, Ident, UTF8Encode(Default)))
  Result := ReadString(Section, Ident, Default)
end;

procedure TDragoIniFile.WriteWideStr(const Section, Ident : string; const Value : WideString);
begin
  //WriteString(Section, Ident, UTF8Encode(Value))
  WriteString(Section, Ident, Value)
end;

end.
