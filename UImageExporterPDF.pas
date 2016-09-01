unit UImageExporterPDF;

interface

uses
  Graphics, Classes,
  UGoban,
  UImageExporter;

type
  TExportedImagePDF = class(TExportedImage)
    textCanvas : TStringList;
    destructor Destroy; override;
  end;

  TImageExporterPDF = class(TImageExporter)
    bmp : TBitmap;
    constructor Create;
    destructor Destroy; override;
    function ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage; override;
  end;

procedure ExportBoardToPDF  (gb : TGoban;
                             pxWidth, pxHeight : integer;
                             textCanvas : TStringList;
                             out mmWidth, mmHeight : integer);

implementation

uses
  SysUtils,
  UStatus,
  UBoardViewScript;

destructor TExportedImagePDF.Destroy;
begin
  FreeAndNil(textCanvas)
end;

constructor TImageExporterPDF.Create;
var
  myBoardView : TBoardViewScript;
begin
  gbExporter := TGoban.Create();
  bmp := TBitmap.Create;
  myBoardView := TBoardViewScript.Create(bmp.Canvas);
  gbExporter.SetBoardView(myBoardView);
end;

destructor TImageExporterPDF.Destroy;
begin
  inherited;
  bmp.Free
end;

function TImageExporterPDF.ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage;
var
  textCanvas : TStringList;
  exportedImage : TExportedImagePDF;
  myBoardView : TBoardViewScript;
begin
  myBoardView := gbExporter.BoardView as TBoardViewScript;
  gbExporter.Assign(gb, True);

  textCanvas := TStringList.Create;

  (myBoardView as TBoardViewScript).ComCanvas := textCanvas;

  //with gbExporter.BoardView as TBoardViewMetric do
  myBoardView.BoardSettings(Settings.BoardBack,
                  Settings.BorderBack,
                  Settings.ThickEdge,
                  Settings.ShowHoshis,
                  Settings.CoordStyle,
                  Settings.StoneStyle,
                  Settings.LightSource,
                  Settings.NumOfMoveDigits,
                  False);

  myBoardView.Canvas.Font.PixelsPerInch := 72;
  gbExporter.SetDim(pxSize, pySize, 1000); // increase max diameter
  myBoardView.AdjustFont;

  textCanvas.Clear;
  textCanvas.Add(Format('%d %d', [myBoardView.ExtWidth, myBoardView.ExtHeight]));

  gbExporter.Silence := False;
  gbExporter.Draw;
  gbExporter.Silence := True;

  exportedImage := TExportedImagePDF.Create;
  exportedImage.textCanvas := textCanvas;

  exportedImage.mmWidth  := Round(25.4 * myBoardView.ExtWidth  / 72);
  exportedImage.mmHeight := Round(25.4 * myBoardView.ExtHeight / 72);

  Result := exportedImage
end;

procedure ExportBoardToPDF(gb : TGoban;
                           pxWidth, pxHeight : integer;
                           textCanvas : TStringList;
                           out mmWidth, mmHeight : integer);
var
  imageExporter : TImageExporterPDF;
  exportedImage : TExportedImagePDF;
begin
  try
    imageExporter := TImageExporterPDF.Create;
    exportedImage := imageExporter.ExportImage(gb, pxWidth, pxHeight, 72) as TExportedImagePDF;
    textCanvas.Assign(exportedImage.textCanvas);
  finally
    imageExporter.Free;
    exportedImage.Free
  end
end;

end.
 