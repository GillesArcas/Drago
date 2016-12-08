unit UImageExporterTXT;

interface

uses
  Classes,
  DefineUi,       // TODO: used for TExportFigure, should not
  UGoban,
  UImageExporter;

type
  TExportedImageTXT = class(TExportedImage) // TXT ????
    textCanvas : TStringList;
    destructor Destroy; override;
  end;

  TImageExporterTXT = class(TImageExporter)
    constructor Create(mode : TExportFigure);
    function ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage; override;
  end;

procedure ExportBoardToAscii(gb : TGoban;
                             mode : TExportFigure;
                             textCanvas : TStringList);

implementation

uses
  SysUtils,
  UStatus,
  UBoardViewAscii;

destructor TExportedImageTXT.Destroy;
begin
  FreeAndNil(textCanvas)
end;

constructor TImageExporterTXT.Create(mode : TExportFigure);
begin
  gbExporter := TGoban.Create();
  gbExporter.SetBoardView(TBoardViewAscii.Create(mode))
end;

function TImageExporterTXT.ExportImage(gb : TGoban; pxSize, pySize, pixPerInch : integer) : TExportedImage;
var
  textCanvas : TStringList;
  exportedImage : TExportedImageTXT;
begin
  gbExporter.Assign(gb);
  textCanvas := TStringList.Create;

  (gbExporter.BoardView as TBoardViewAscii).TextCanvas := textCanvas;

  with gbExporter.BoardView as TBoardViewAscii do
    BoardSettings(Settings.ShowHoshis,
                  Settings.CoordStyle,
                  Settings.NumOfMoveDigits,
                  gbExporter.BoardView.CoordTrans,
                  Settings.AscDrawEdge,
                  Settings.AscBlackChar,
                  Settings.AscWhiteChar,
                  Settings.AscHoshi);

  gbExporter.Silence := False;
  gbExporter.Draw;
  gbExporter.Silence := True;

  exportedImage := TExportedImageTXT.Create;
  exportedImage.textCanvas := textCanvas;

  Result := exportedImage
end;

procedure ExportBoardToAscii(gb : TGoban; mode : TExportFigure; textCanvas : TStringList);
var
  imageExporter : TImageExporterTXT;
  exportedImage : TExportedImageTXT;
begin
  try
    imageExporter := TImageExporterTXT.Create(mode);
    exportedImage := imageExporter.ExportImage(gb, 0, 0, 0) as TExportedImageTXT;
    textCanvas.Assign(exportedImage.TextCanvas);
  finally
    imageExporter.Free;
    exportedImage.Free
  end
end;

end.
