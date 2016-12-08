unit UImageExporterWMF;

interface

uses
  Graphics, Classes,
  UGoban,
  UImageExporter;

type
  TExportedImageWMF = class(TExportedImage)
    FMetafile : TMetafile;
    destructor Destroy; override;
  end;

  TImageExporterWMF = class(TImageExporter)
    constructor Create();
    function ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage; override;
  end;

procedure ExportBoardToWMF  (gb : TGoban;
                             metafile : TMetaFile;
                             mmWidth, mmHeight, pxPerInch : integer);

implementation

uses
  SysUtils,
  UStatus,
  UBoardViewVector;

destructor TExportedImageWMF.Destroy;
begin
  FreeAndNil(FMetafile)
end;

constructor TImageExporterWMF.Create();
begin
  gbExporter := TGoban.Create();
end;

function TImageExporterWMF.ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage;
var
  metafile : TMetafile;
  mfCanvas : TMetaFileCanvas;
  exportedImage : TExportedImageWMF;
begin
  gbExporter.Assign(gb, True);
  metafile := TMetaFile.Create;

  metafile.Enhanced := False;
  metafile.Width  := pxSize;
  metafile.Height := pySize;
  mfCanvas := TMetaFileCanvas.Create(metafile, 0);
  mfCanvas.Font.Name := 'Arial';
  mfCanvas.Font.PixelsPerInch := pixPerInch;

  gbExporter.SetBoardView(TBoardViewVector.Create(mfCanvas));

  with gbExporter.BoardView as TBoardViewVector do
    BoardSettings(Settings.BoardBack,
                  Settings.BorderBack,
                  Settings.ThickEdge,
                  Settings.ShowHoshis,
                  Settings.CoordStyle,
                  Settings.StoneStyle,
                  Settings.LightSource,
                  Settings.NumOfMoveDigits,
                  False);

  gbExporter.SetDim(pxSize, pySize, 1000); // increase max diameter
  (gbExporter.BoardView as TBoardViewVector).AdjustFont;

  gbExporter.Silence := False;
  gbExporter.Draw;
  gbExporter.Silence := True;

  exportedImage := TExportedImageWMF.Create;
  exportedImage.FMetafile := Metafile;
  Result := exportedImage;

  mfCanvas.Free;
  //gbExporter.BoardView.Free
end;

procedure ExportBoardToWMF(gb : TGoban;
                           metafile : TMetaFile;
                           mmWidth, mmHeight, pxPerInch : integer);
var
  pxWidth, pxHeight : integer;
  imageExporter : TImageExporterWMF;
  exportedImage : TExportedImageWMF;
begin
  pxWidth  := round(mmWidth  * pxPerInch / 25.4);
  pxHeight := round(mmHeight * pxPerInch / 25.4);
  try
    imageExporter := TImageExporterWMF.Create();
    exportedImage := imageExporter.ExportImage(gb, pxWidth, pxHeight, pxPerInch) as TExportedImageWMF;
    metafile.Assign(exportedImage.FMetafile);
  finally
    imageExporter.Free;
    exportedImage.Free
  end
end;

end.
