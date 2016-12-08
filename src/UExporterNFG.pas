// ---------------------------------------------------------------------------
// -- Drago -- Number of FiGures to be exported ---------- UExporterNFG.pas --
// ---------------------------------------------------------------------------

unit UExporterNFG;

// ---------------------------------------------------------------------------

interface

uses UExporter;

type
  TExporterNFig = class(TExporter)
    nFigures : integer;
    constructor Create; override;
    destructor Destroy; override;
    function  Result : integer; override;
    procedure BeginDoc(var ok : boolean); override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi;

// ---------------------------------------------------------------------------

// -- Allocation

constructor TExporterNFig.Create;
begin
  FExportMode   := emNFig;
  FExportFigure := eiNON
end;

destructor TExporterNFig.Destroy;
begin
  inherited Destroy
end;

// -- Result

function TExporterNFig.Result : integer;
begin
  Result := nFigures
end;

// -- Document

procedure TExporterNFig.BeginDoc(var ok : boolean);
begin
  ok := True;
  nFigures := 0
end;

// ---------------------------------------------------------------------------

end.
