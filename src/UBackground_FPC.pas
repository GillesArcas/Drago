unit UBackGround_FPC;

interface

uses
  IniFiles, DefineUi;

type
  TBackGround = class
    Image     : string;
    constructor Create(aDefault : TBackground);
    procedure   LoadIni(iniFile : TMemIniFile;
                        const section, prefixe : string;
                        defaultStyle : TBackStyle = bsDefaultTexture);
    procedure   SaveIni(iniFile : TMemIniFile;
                        const section, prefixe : string);
  end;

implementation

constructor TBackground.Create(aDefault : TBackground);
begin
  assert(False)
end;

procedure TBackground.LoadIni(iniFile : TMemIniFile;
                              const section, prefixe : string;
                              defaultStyle : TBackStyle = bsDefaultTexture);
begin
end;

procedure TBackground.SaveIni(iniFile : TMemIniFile;
                              const section, prefixe : string);
begin
end;

end.
