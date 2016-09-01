unit UImageExporterBMP;

interface

uses
  Graphics,
  UGoban,
  UImageExporter;

type
  TExportedImageBMP = class(TExportedImage)
    bitmap : TBitmap;
    destructor Destroy; override;
  end;

  TImageExporterBMP = class(TImageExporter)
    constructor Create;
    function ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage; override;
  end;

procedure ExportBoardToBMP(gb : TGoban;
                           dest : TBitmap;
                           pxWidth, pxHeight : integer;
                           maxDiameter : integer = 61);

implementation

uses
  SysUtils,
  UStatus,
  UBoardViewMetric,
  UBoardViewCanvas;

destructor TExportedImageBMP.Destroy;
begin
  FreeAndNil(bitmap)
end;

constructor TImageExporterBMP.Create;
begin
  gbExporter := TGoban.Create;
  gbExporter.SetBoardView(TBoardViewCanvas.Create(nil)); // TODO: ViewCanvas here, ViewMetric below ??
end;

function TImageExporterBMP.ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage;
var
  bitmap : TBitmap;
  exportedImage : TExportedImageBMP;
begin
  gbExporter.Assign(gb, True);

  bitmap := TBitmap.Create;
  (gbExporter.BoardView as TBoardViewMetric).Canvas := bitmap.Canvas;

  with gbExporter.BoardView as TBoardViewMetric do
    BoardSettings(Settings.BoardBack,
                  Settings.BorderBack,
                  Settings.ThickEdge,
                  Settings.ShowHoshis,
                  Settings.CoordStyle,
                  Settings.StoneStyle,
                  Settings.LightSource,
                  Settings.NumOfMoveDigits,
                  False);

  gbExporter.SetDim(pxSize, pySize, 61);
  gbExporter.BoardView.AdjustToSize;

  bitmap.Width  := (gbExporter.BoardView as TBoardViewCanvas).ExtWidth;
  bitmap.Height := (gbExporter.BoardView as TBoardViewCanvas).ExtHeight;

  gbExporter.Silence := False;
  gbExporter.Draw;
  gbExporter.Silence := True;

  exportedImage := TExportedImageBMP.Create;
  exportedImage.bitmap := bitmap;

  Result := exportedImage
end;

procedure ExportBoardToBMP(gb : TGoban;
                           dest : TBitmap;
                           pxWidth, pxHeight : integer;
                           maxDiameter : integer = 61);
var
  imageExporter : TImageExporterBMP;
  exportedImage : TExportedImageBMP;
begin
  try
    imageExporter := TImageExporterBMP.Create();
    exportedImage := imageExporter.ExportImage(gb, pxWidth, pxHeight, 72) as TExportedImageBMP;
    dest.Assign(exportedImage.Bitmap);
  finally
    imageExporter.Free;
    exportedImage.Free
  end
end;

end.
