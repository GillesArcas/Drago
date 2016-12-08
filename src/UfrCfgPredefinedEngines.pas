unit UfrCfgPredefinedEngines;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, SpTBXControls, SpTBXItem, StdCtrls, Grids,
  UfrCfgGameEngines, ExtCtrls, Buttons;

type
  TfrCfgPredefinedEngines = class(TFrame)
    SpTBXLabel2: TSpTBXLabel;
    StringGrid: TStringGrid;
    lbMessage: TSpTBXLabel;
    btOpenBrowser: TSpTBXRadioButton;
    btAlreadyInstalled: TSpTBXRadioButton;
    Bevel1: TBevel;
    SpTBXLabel1: TSpTBXLabel;
    SpTBXLabel3: TSpTBXLabel;
    procedure btOkClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure SpTBXLabel3Click(Sender: TObject);
  private
    GameEngineTab : TfrCfgGameEngines;
  public
    procedure Initialize(frCfgGameEngines : TfrCfgGameEngines);
  end;

implementation

uses
  IniFiles, ShellAPI,
  UStatus, EngineSettings, Translate;

{$R *.dfm}

procedure TfrCfgPredefinedEngines.Initialize(frCfgGameEngines : TfrCfgGameEngines);
var
  iniFile : TIniFile;
  list : TStringList;
  i : integer;
begin
  GameEngineTab := frCfgGameEngines;

  StringGrid.ColWidths[0] := 100;
  StringGrid.ColWidths[1] := StringGrid.Width - StringGrid.ColWidths[0] - 6;
  btOpenBrowser.Checked := True;
  lbMessage.Width := ClientWidth - 2 * lbMessage.Left; 

  // check if engine configuration file exists
  if not FileExists(Status.AppPath + EnginesConfig) then
    begin
      lbMessage.Font.Color := clRed;
      lbMessage.Caption := U('Engine configuration file missing. Please check installation.')
    end;

  // read sections (ie engine names) in engine configuration file
  iniFile := TIniFile.Create(Status.AppPath + EnginesConfig);
  list := TStringList.Create;
  iniFile.ReadSections(list);

  // load string grid with engine names and url
  StringGrid.RowCount := list.Count;
  for i := 0 to list.Count - 1 do
    begin
      StringGrid.Cells[0, i] := list[i];
      StringGrid.Cells[1, i] := iniFile.ReadString(list[i], 'url', '');
    end;

  iniFile.Free;
  list.Free
end;

procedure TfrCfgPredefinedEngines.btOkClick(Sender: TObject);
var
  engineName, engineUrl : string;
begin
  engineName := StringGrid.Cells[0, StringGrid.Row];
  engineUrl  := StringGrid.Cells[1, StringGrid.Row];

  if btOpenBrowser.Checked
    then ShellExecute(0, 'open', PChar(engineUrl), nil, nil, 1 {SW_SHOWNORMAL});

  GameEngineTab.PredefineEngine(engineName);
  //GameEngineTab.btExecutableClick(Sender)
end;

procedure TfrCfgPredefinedEngines.btCancelClick(Sender: TObject);
begin
  //
end;

procedure TfrCfgPredefinedEngines.SpTBXLabel3Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('NotePad'), PChar('engines.config'), nil, SW_SHOW)
end;

end.
