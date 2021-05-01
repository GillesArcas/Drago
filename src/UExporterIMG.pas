// ---------------------------------------------------------------------------
// -- Drago -- Export image module ----------------------- UExporterIMG.pas --
// ---------------------------------------------------------------------------

unit UExporterIMG;

// ---------------------------------------------------------------------------

interface

uses
  Classes, Graphics, SysUtils,
  Clipbrd, Jpeg, GifImage, PngImage,
  DefineUi, UExporter;

type
  TExporterIMG = class(TExporter)
    FileName : string;
    constructor Create(aExportFigure : TExportFigure; aFileName : string); override;
    destructor Destroy; override;
    procedure SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer); override;
    function  PrinterPxPerInchX : integer; override;
    function  PrinterPxPerInchY : integer; override;
    procedure DrawImagesAcrossCols(n : integer); override;
  end;

procedure ExportIMG(bitmap   : TBitmap;
                    metafile : TMetafile;
                    comCanvas: TStringList;
                    mode     : TExportFigure;
                    pxPerInchX : integer;
                    imgName  : WideString);

procedure ExportImage(bitmap   : TBitmap;
                      metafile : TMetafile;
                      comCanvas: TStringList;
                      mode     : TExportFigure;
                      fileName : string;
                      pxPerInchX : integer;
                      number   : integer;
                      var imgName  : string);
                   
// ---------------------------------------------------------------------------

implementation

uses
  UStatus, UGraphic, UfmMsg, Translate, SysUtilsEx,
  UExporterPDF,
  UImageExporterBMP,
  UImageExporterPDF,
  UImageExporterWMF;

// -- Allocation

constructor TExporterIMG.Create(aExportFigure : TExportFigure; aFileName : string);
begin
  FExportMode   := emExportIMG;
  FExportFigure := aExportFigure;
  FileName := aFileName;
  PaperSize.cx := 210;
  PaperSize.cy := 297; // always export to A4
  nFigures := 0;
end;

destructor TExporterIMG.Destroy;
begin
  inherited Destroy
end;

procedure TExporterIMG.SetPageMargins(mmLeft, mmTop, mmRight, mmBottom : integer);
begin
  PageMargins := Rect(mmLeft, mmTop, mmRight, mmBottom)
end;

function TExporterIMG.PrinterPxPerInchX : integer;
begin
  Result := 360
end;

function TExporterIMG.PrinterPxPerInchY : integer;
begin
  Result := 360
end;

procedure TExporterIMG.DrawImagesAcrossCols(n : integer);
var
  i : integer;
  name : string;
  bitmap : TBitmap;
  metafile : TMetafile;
  comCanvas : TStringList;
begin
  for i := 0 to n - 1 do
    begin
      bitmap := nil;
      metafile := nil;
      comCanvas := nil;
      case FExportFigure of
        eiWMF : metafile := (FExportImg[i] as TExportedImageWMF).FMetafile;
        eiGIF : bitmap   := (FExportImg[i] as TExportedImageBMP).Bitmap;
        eiPNG : bitmap   := (FExportImg[i] as TExportedImageBMP).Bitmap;
        eiJPG : bitmap   := (FExportImg[i] as TExportedImageBMP).Bitmap;
        eiBMP : bitmap   := (FExportImg[i] as TExportedImageBMP).Bitmap;
        eiPDF : comCanvas:= (FExportImg[i] as TExportedImagePDF).textCanvas;
      end;

      ExportImage(bitmap, metafile, comCanvas,
                  fExportFigure, fileName,
                  PrinterPxPerInchX, nFigures, name);
      inc(nFigures)
    end
end;

// ---------------------------------------------------------------------------

procedure ExportIMG(bitmap   : TBitmap;
                    metafile : TMetafile;
                    comCanvas: TStringList;
                    mode     : TExportFigure;
                    pxPerInchX : integer;
                    imgName  : WideString);
var
  imgNameArg : WideString;
  pxWidth, pxHeight, mmWidth, mmHeight : integer;
  gif : TGIFImage;
  png : TPNGObject;
  jpg : TJPEGImage;
begin
  imgNameArg := imgName;
  if imgName <> AnsiString(imgName)
    then imgName := Settings.TmpPath + '\tmp' + WideExtractFileExt(imgName);

  try
    try
      case mode of

        // WMF
        eiWMF : begin
          pxWidth  := Metafile.Width;
          pxHeight := Metafile.Height;
          mmWidth  := round(pxWidth  * 25.4 / pxPerInchX);
          mmHeight := round(pxHeight * 25.4 / pxPerInchX);
          Metafile.MMWidth  := mmWidth  * 100;
          Metafile.MMHeight := mmHeight * 100;
          Metafile.Palette := 0;
          if imgName = ''
            then ClipBoard.Assign(Metafile)
            else Metafile.SaveToFile(imgName)
        end;

        // EMF
        eiEMF : begin
        {
        not handled, size not controlled
        }
        end;

        // GIF
        eiGIF : begin
          gif := TGIFImage.Create;

          if ColorNumber(bitmap) <= 256
            then gif.ColorReduction := rmNone
            else gif.ColorReduction := rmQuantize;

          gif.Assign(bitmap);
          if imgName = ''
            then // nop
            else gif.SaveToFile(imgName)
        end;

        // PNG
        eiPNG : begin
          png := TPNGObject.Create;
          png.Assign(bitmap);
          png.CompressionLevel := 9;
          if imgName = ''
            then //nop
            else png.SaveToFile(imgName)
        end;

        // JPG
        eiJPG : begin
          jpg := TJPEGImage.Create;
          jpg.CompressionQuality := Status.prQualityJPEG;
          jpg.Assign(bitmap);
          if imgName = ''
            then //nop
            else jpg.SaveToFile(imgName)
        end;

        // BMP
        eiBMP : begin
          if imgName = ''
            then ClipBoard.Assign(Bitmap)
            else Bitmap.SaveToFile(imgName)
        end;

        // PDF
        eiPDF : begin
          UExporterPDF.ExportImagePDF(comCanvas, imgName)
        end
      end;

      if imgNameArg <> AnsiString(imgNameArg)
        then WideCopyFile(imgName, imgNameArg, False)
    except
      if imgName = ''
        then MessageDialog(msOk, imSad, [U('Problem while copying in clipboard')])
        else MessageDialog(msOk, imSad, [U('Problem while saving image')])
    end
  finally
    case mode of
      eiWMF : ;
      eiGIF : gif.Free;
      eiPNG : png.Free;
      eiJPG : jpg.Free;
      eiBMP : ;
    end
  end
end;

procedure ExportImage(bitmap   : TBitmap;
                      metafile : TMetafile;
                      comCanvas: TStringList;
                      mode     : TExportFigure;
                      fileName : string;
                      pxPerInchX : integer;
                      number   : integer;
                      var imgName : string);
begin
  imgName := ChangeFileExt(fileName, '');

  case mode of
    eiWMF : imgName := Format('%s%4.4d.wmf', [imgName, number]);
    eiGIF : imgName := Format('%s%4.4d.gif', [imgName, number]);
    eiPNG : imgName := Format('%s%4.4d.png', [imgName, number]);
    eiJPG : imgName := Format('%s%4.4d.jpg', [imgName, number]);
    eiBMP : imgName := Format('%s%4.4d.bmp', [imgName, number]);
    eiPDF : imgName := Format('%s%4.4d.pdf', [imgName, number]);
  end;

  ExportIMG(bitmap, metafile, comCanvas, mode, pxPerInchX, imgName)
end;

// ---------------------------------------------------------------------------

end.
