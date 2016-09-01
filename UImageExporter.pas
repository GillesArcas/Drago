unit UImageExporter;

interface

uses
  UGoban;

type
  TExportedImage = class
    mmWidth, mmHeight : integer;
  end;

  TImageExporter = class
    gbExporter : TGoban;
    constructor Create;
    destructor Destroy; override;
    function ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage; virtual; abstract;
  end;

implementation

constructor TImageExporter.Create;
begin
  gbExporter := TGoban.Create;
end;

destructor TImageExporter.Destroy;
begin
  gbExporter.Free
end;

end.
 