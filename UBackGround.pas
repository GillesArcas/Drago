// ---------------------------------------------------------------------------
// -- Drago -- Class to draw backgrounds ------------------ UBackGround.pas --
// ---------------------------------------------------------------------------

unit UBackGround;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Graphics, IniFiles,
  DefineUi;

type
  TBackground = class
    Style     : TBackStyle;
    Color     : TColor;
    Image     : string;
    Bitmap    : TBitmap;
    PenColor  : TColor;
    MeanColor : TColor;
    Default   : TBackground;

    constructor Create(aDefault : TBackground);
    destructor  Destroy; override;
    procedure   Assign(source : TBackground);
    procedure   Update;
    procedure   Apply(canvas : TCanvas; rect : TRect);
    procedure   LoadIni(iniFile : TMemIniFile;
                        const section, prefixe : string;
                        defaultStyle : TBackStyle = bsDefaultTexture);
    procedure   SaveIni(iniFile : TMemIniFile;
                        const section, prefixe : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  UGraphic, UStatus, UfmMsg;

// ---------------------------------------------------------------------------

// -- Creation

constructor TBackground.Create(aDefault : TBackground);
begin
  inherited Create;

  Style   := bsColor;
  Color   := clWhite;
  if aDefault = nil
    then Image := ''
    else Image := aDefault.Image;
  Bitmap  := TBitmap.Create;
  Default := aDefault;

  PenColor  := VisibleContrast(Color);
  MeanColor := 0;
end;

// -- Destruction

destructor TBackground.Destroy;
begin
  Bitmap.Free;
  inherited
end;

// -- Assignment

procedure TBackground.Assign(source : TBackground);
begin
  Style   := source.Style;
  Color   := source.Color;
  Image   := source.Image;
  //Default := source.Default;

  Update
end;

// -- Update of internal data

function LoadImage(const name : string; bmp : TBitmap) : boolean;
begin
  Result := LoadImageToBmp(name, bmp);

  if (not Result) or (not Status.SymmetricTiling)
    then exit;

  SymmetricTile(bmp)
end;

procedure TBackground.Update;
var
  wStyle : TBackStyle;
  wColor : TColor;
  wImage : string;
begin
  if Style = bsAsGoban then wStyle := Default.Style else wStyle := Style;
  if Style = bsAsGoban then wColor := Default.Color else wColor := Color;
  if Style = bsAsGoban then wImage := Default.Image else wImage := Image;

  // update bitmap
  case wStyle of
    bsColor : ;
    bsDefaultTexture :
      if not LoadImage(Status.AppPath + 'Textures\wood01.jpg', Bitmap) then
        begin
          UfmMsg.MessageDialog(msOk, imDrago, ['Default texture not found']);
          Style := bsColor;
          Update
        end;
    bsCustomTexture  :
      if not LoadImage(wImage, Bitmap) then
        begin
          UfmMsg.MessageDialog(msOk, imDrago, ['Texture not found']);
          Style := bsColor;
          Update
        end
  end;

  // update mean color
  if wStyle in [bsColor, bsAsGoban]
    then MeanColor := wColor
    else MeanColor := UGraphic.MeanColor(Bitmap.Canvas, Bitmap.Width,
                                                        Bitmap.Height);
  // update text color
  PenColor := VisibleContrast(MeanColor)
end;

// -- Apply background

procedure TBackground.Apply(canvas : TCanvas; rect : TRect);
var
  wStyle  : TBackStyle;
  wColor  : TColor;
  wImage  : string;
  wBitmap : TBitmap;
begin
  // reset the brush
  //canvas.Brush.Bitmap := nil;

  if Style = bsAsGoban then wStyle := Default.Style else wStyle := Style;
  if Style = bsAsGoban then wColor := Default.Color else wColor := Color;
  if Style = bsAsGoban then wImage := Default.Image else wImage := Image;

  wBitmap := TBitmap.Create;
  if Style = bsAsGoban
    then wBitmap.Assign(Default.Bitmap)
    else wBitmap.Assign(Bitmap);

  // configure brush
  if wStyle = bsColor
    then canvas.Brush.Color  := wColor
    else canvas.Brush.Bitmap := wBitmap;

  // repaint
  canvas.FillRect(rect);

  canvas.Brush.Bitmap := nil;
  wBitmap.Free
end;

// -- Loading of ini file

procedure TBackground.LoadIni(iniFile : TMemIniFile;
                              const section, prefixe : string;
                              defaultStyle : TBackStyle = bsDefaultTexture);
var
  n : integer;
begin
  with iniFile do
    begin
      n     := ReadInteger(section, prefixe + 'Style', ord(defaultStyle));
      Style := TBackStyle(n);
      Color := ReadInteger(section, prefixe + 'Color', clWhite);
      Image := ReadString (section, prefixe + 'Image', Image)
    end;

  Update
end;

// -- Saving of ini file

procedure TBackground.SaveIni(iniFile : TMemIniFile;
                              const section, prefixe : string);
begin
  with iniFile do
    begin
      WriteInteger(section, prefixe + 'Style', integer(Style));
      WriteInteger(section, prefixe + 'Color', Color);
      WriteString (section, prefixe + 'Image', Image)
    end
end;

// ---------------------------------------------------------------------------

end.
