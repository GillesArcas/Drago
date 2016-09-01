// ---------------------------------------------------------------------------
// -- Drago -- All about drawing stones on canvas ------------- UStones.pas --
// ---------------------------------------------------------------------------

unit UStones;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Types, Graphics,
  PngImage,
  Define;

type
  TStoneParams = class
    FStyle : integer;
    FLightSource : TLightSource;
    FBackColor   : integer;
    FCustomLightSource : TLightSource;
    FBlackFilter : WideString;
    FWhiteFilter : WideString;
    FAppPath : WideString;
    constructor Create;
    procedure SetParams(style : integer;
                        lightSource : TLightSource;
                        backColor : integer;
                        customLightSource : TLightSource = lsNone;
                        blackFilter : WideString = '';
                        whiteFilter : WideString = '';
                        appPath : WideString = '');
  end;

type
  TStone = class
    FColor : integer;
    FDiameter : integer;
    FRadius : integer;
    FStyle : integer;
    FLightSource : TLightSource;
    FBackColor : integer;
    FStonePng : TPngObject;
    FGhostPng : TPngObject;
    FRawBmp : TBitmap;
  public
    constructor Create(png : TPngObject;
                       color, diameter : integer;
                       stoneParams : TStoneParams);
    destructor Destroy; override;
    procedure Draw(canvas : TCanvas; x, y : integer);
    procedure DrawGhost(canvas : TCanvas; x, y : integer);
  private
    procedure MakeGhost;
    procedure MakeRawBmp;
  end;

function GetStone(color, radius : integer;
                  stoneParams : TStoneParams;
                  intersectionId : integer = 0) : TStone; overload;

procedure ClearCacheLists;

// ---------------------------------------------------------------------------

implementation

uses
  StrUtils, SysUtils, Contnrs, SysUtilsEx,
  ClassesEx, UGraphic;

constructor TStone.Create(png : TPngObject;
                          color, diameter : integer;
                          stoneParams : TStoneParams);
begin
  FDiameter := diameter;
  FRadius := diameter div 2;

  FStonePng := png;
  FColor := color;
  FStyle := stoneParams.FStyle;
  FLightSource := stoneParams.FLightSource;
  FBackColor := stoneParams.FBackColor;

  if ((stoneParams.FLightSource = lsTopLeft) and (stoneParams.FStyle in [dsDefault, dsJago]))
     or ((stoneParams.FStyle = dsCustom) and (stoneParams.FLightSource <> stoneParams.FCustomLightSource))
    then VerticalSymetry(FStonePng);

  MakeGhost;
  MakeRawBmp
end;

destructor TStone.Destroy;
begin
  FStonePng.Free;
  FGhostPng.Free;
  FRawBmp.Free;
  inherited
end;

procedure TStone.Draw(canvas : TCanvas; x, y : integer);
begin
  if FDiameter <= 7
    then canvas.Draw(x - FRadius, y - FRadius, FRawBmp)
    else
      begin
        dec(x, FRadius);
        dec(y, FRadius);
        FStonePng.Draw(canvas, rect(x, y, x + FDiameter, y + FDiameter))
      end
end;

procedure TStone.DrawGhost(canvas : TCanvas; x, y : integer);
begin
  dec(x, FRadius);
  dec(y, FRadius);
  FGhostPng.Draw(canvas, rect(x, y, x + FDiameter, y + FDiameter))
end;

procedure TStone.MakeGhost;
begin
  FGhostPng := TPngObject.Create;
  FGhostPng.Assign(FStonePng);
  if FColor = Black
    then ApplyPngTransparency(FGhostPng, 0.5)
    else ApplyPngTransparency(FGhostPng, 0.4)
end;

procedure TStone.MakeRawBmp;
begin
  FRawBmp := TBitmap.Create;
  FRawBmp.Width := FDiameter;
  FRawBmp.Height := FDiameter;
  FRawBmp.PixelFormat := pf32bit;
  FRawBmp.Transparent := False;
  FRawBmp.Canvas.Brush.Color := FBackColor;
  FRawBmp.Canvas.FillRect(rect(0, 0, FDiameter, FDiameter));

  FStonePng.Draw(FRawBmp.Canvas, rect(0, 0, FDiameter, FDiameter))
end;

constructor TStoneParams.Create;
begin
  FStyle := dsDefault;
  FLightSource := lsNone;
  FBackColor := clWhite;
  FBlackFilter := '';
  FWhiteFilter := ''
end;

procedure TStoneParams.SetParams(style : integer;
                                 lightSource : TLightSource;
                                 backColor : integer;
                                 customLightSource : TLightSource = lsNone;
                                 blackFilter : WideString = '';
                                 whiteFilter : WideString = '';
                                 appPath : WideString = '');
begin
  FStyle := style;
  FLightSource := lightSource;
  FBackColor   := backColor;
  FCustomLightSource := customLightSource;
  FBlackFilter := blackFilter;
  FWhiteFilter := whiteFilter;
  FAppPath := appPath
end;

// Forwards

procedure LoadStones(pcStones : TList;
                     color, radius : integer;
                     stoneParams : TStoneParams); forward;
procedure GetCachedStone(out stone : TStone;
                   color, radius, style : integer;
                   stoneParams : TStoneParams;
                   backColor, intersectionId : integer); forward;

// Public

function GetStone(color, radius : integer;
                  stoneParams : TStoneParams;
                  intersectionId : integer = 0) : TStone;
begin
  GetCachedStone(Result, color, radius, stoneParams.FStyle, stoneParams,
                 stoneParams.FBackColor, intersectionId)
end;

// -- Two level stone cache --------------------------------------------------

var
  StoneListBlack     : TObjectList; // all stones calculated until now
  StoneListWhite     : TObjectList;
  CurrentStonesBlack : TObjectList; // last stones requested
  CurrentStonesWhite : TObjectList;

procedure AllocCacheLists;
begin
  StoneListBlack := TObjectList.Create;
  StoneListWhite := TObjectList.Create;
  CurrentStonesBlack := TObjectList.Create;
  CurrentStonesWhite := TObjectList.Create;
  CurrentStonesBlack.OwnsObjects := False;
  CurrentStonesWhite.OwnsObjects := False;
end;

procedure FreeCacheLists;
begin
  StoneListBlack.Free;
  StoneListWhite.Free;
  CurrentStonesBlack.Free;
  CurrentStonesWhite.Free;
end;

procedure ClearCacheLists;
begin
  StoneListBlack.Clear;
  StoneListWhite.Clear;
  CurrentStonesBlack.Clear;
  CurrentStonesWhite.Clear;
end;

function CompareToCachedStone(cachedStone : TOBject;
                              color, radius : integer;
                              stoneParams : TStoneParams) : boolean;
begin
  with cachedStone as TStone do
    Result := (FRadius = radius) and
              (FStyle = stoneParams.FStyle) and
              (FLightSource = stoneParams.FLightSource) and
              (FBackColor = stoneParams.FBackColor)
end;

procedure FindCachedStone(out stone : TStone;
                          stoneList : TObjectList;
                          color, radius : integer;
                          stoneParams : TStoneParams;
                          intersectionId : integer);
var
  candidates : TObjectList;
  k : integer;
begin
  if color = Black
    then candidates := CurrentStonesBlack
    else candidates := CurrentStonesWhite;

  if (candidates.Count > 0) and CompareToCachedStone(candidates[0],
                                                     color, radius, stoneParams)
    then // nop
    else
      begin
        candidates.Clear;
        for k := 0 to stoneList.Count - 1 do
          if CompareToCachedStone(stoneList[k], color, radius, stoneParams)
            then candidates.Add(stoneList[k])
      end;

  if candidates.Count = 0
    then stone := nil
    else
      begin
        if candidates.Count = 1
          then k := 0
          //else k := Random(candidates.Count);
          else k := intersectionId mod candidates.Count;

        stone := TStone(candidates[k])
      end
end;

procedure LoadCachedStones(stoneList : TObjectList;
                           color, radius : integer;
                           stoneParams : TStoneParams);
var
  pcList : TList;
  i : integer;
  stone : TStone;
begin
  pcList := TList.Create;
  //list.OwnsObjects := False;

  LoadStones(pcList, color, radius, stoneParams);

  for i := 0 to pcList.Count - 1 do
    begin
      stone := TStone.Create(TPngObject(pcList[i]), color, 2 * radius + 1, stoneParams);
      stoneList.Add(stone)
    end;

  pcList.Free
end;

procedure GetCachedStone(out stone : TStone;
                         color, radius, style : integer;
                         stoneParams : TStoneParams;
                         backColor, intersectionId : integer);
var
  cacheList : TObjectList;
begin
  if color = Black
    then cacheList := StoneListBlack
    else cacheList := StoneListWhite;

  FindCachedStone(stone, cacheList,
                  color, radius, stoneParams, intersectionId);

  if stone = nil then
    begin
      LoadCachedStones(cacheList,
                       color, radius, stoneParams);

      FindCachedStone(stone, cacheList,
                      color, radius, stoneParams, intersectionId)
    end
end;

// -- Loading stones from drawing or disk ------------------------------------

// -- Loading of drawn stones

procedure GetBmStonesDrawing(bmStone : TBitmap; color, radius, backColor : integer);
var
  d, w : integer;
begin
  if backColor <> clWhite
    then w := clWhite
    else
      if GetColorBits() >= 24
        then w := clWhite - 2
        else w := clWhite - 4*(256*256+256+1);

  d := 2 * radius + 1;

  bmStone.Height := d;
  bmStone.Width  := d;
  bmStone.PixelFormat := pf32bit;

  // in principle, this should not be necessary but with the current algorithms
  // it still gives a better result
  bmStone.Canvas.Brush.Color := backColor;
  bmStone.Canvas.FillRect(rect(0, 0, d, d));

  if color = Black
    then AntiAliasedStone(bmStone, radius, radius, -1, radius, clBlack)
    else AntiAliasedStone(bmStone, radius, radius, -1, radius, w)
end;

// -- Jago stones (with permission)

procedure GetBmStonesJago(bmStone: TBitmap; color, diameter : integer);
const
  pixel  = 0.8;
var
  d, i, j, g : integer;
  di, dj, d2, r, x, y, z, xr, xg, hh, f, alpha : double;
  line  : PRGBAQuadArray;
begin
  bmStone.PixelFormat := pf32bit;

  d := diameter + 2;
  bmStone.Width  := diameter;
  bmStone.Height := diameter;
  d2 := d / 2.0 - 5e-1;
  r  := d2 - 2e-1;
  f  := sqrt(3);

  for i := 1 to d - 2 do
  begin
    line := bmStone.ScanLine[i - 1];
    for j := 1 to d - 2 do
      begin
        di := i - d2;
        dj := j - d2;
        hh := r - sqrt(di * di + dj * dj);
        if hh < 0
          then
            begin
              g := 0;
              alpha := 1
            end
          else
            begin
              z := r * r - di * di - dj * dj;
              if z > 0
                then z := sqrt(z) * f
                else z := 0;
              x := di;
              y := dj;
              xr := sqrt(6 * (x * x + y * y + z * z));
              xr := (2 * z - x + y) / xr;
              if xr > 0.9
                then xg := (xr - 0.9) * 10
                else xg := 0;
              if hh > pixel
                then
                  begin
                    if color = Black
                      then g := round(10 + 10 * xr + xg * 140)
                      else g := round(200 + 10 * xr + xg * 45);
                    alpha := 0
                  end
                else
                  begin
                    if color = Black
                      then g := round(10 + 10 * xr + xg * 140)
                      else g := round(200 + 10 * xr + xg * 45);
                    alpha := (pixel - hh) / pixel
                  end
            end;
        line[j - 1].B := g;
        line[j - 1].G := g;
        line[j - 1].R := g;
        g := 255 - Round(255 * alpha);
        line[j - 1].A := g;
      end;
  end
end;

// -- Load custom stone from disk

type
  TDiameterArray = array[1 .. 61] of byte;

var
  CustomeStoneDiameters : TDiameterArray;
  CustomeStonePath : WideString = '';

procedure GetBestMatchCustom(const filter : WideString);
var
  path : WideString;
  list : TWideStringList;
  testAll : array[1 .. 255] of integer;
  i, max : integer;
begin
  path := WideExtractFilePath(filter);

  if path = CustomeStonePath
    then exit;

  list := TWideStringList.Create;
  WideAddFilesToList(list, WideExtractFilePath(filter),
                     [afCatPath, afIncludeFiles],
                     '*.*'); //WideExtractFileName(FilterBlack));

  FillChar(testAll, 255, 0);

  max := 0;
  for i := 1 to 255 do
    if list.IndexOf(Format(filter, [i])) >= 0
      then
        begin
          testAll[i] := i;
          if i > max
            then max := i
        end;

  for i := 61 downto 1 do
    if testAll[i] = i
      then
        begin
          max := i;
          CustomeStoneDiameters[i] := i
        end
      else
        CustomeStoneDiameters[i] := max;

  CustomeStonePath := path;
  list.Free
end;

function ReplaceNumBy(const s : WideString; const subst : string) : WideString;
var
  iFirst, iPost, i : integer;
begin
  Result := s;

  iFirst := 0;
  for i := 1 to Length(s) do
    if char(s[i]) in ['0' .. '9'] then
      begin
        iFirst := i;
        break
      end;

  if iFirst = 0
    then exit;

  iPost := 0;
  for i := iFirst to Length(s) do
    if not (char(s[i]) in ['0' .. '9']) then
      begin
        iPost := i;
        break
      end;

  if iPost = 0
    then iPost := Length(s) + 1;

  Result := StuffString(s, iFirst, iPost - iFirst, subst)
end;

procedure LoadStoneCustom(pcStones : TList;
                          color, radius : integer;
                          stoneParams : TStoneParams);
var
  availableDiameter : integer;
  filter, name : WideString;
  png : TPngObject;
  //png : TPngImage;
  list : TWideStringList;
  path, mask : WideString;
  i : integer;
begin
  if color = 1
    then filter := stoneParams.FBlackFilter
    else filter := stoneParams.FWhiteFilter;

  assert(ExtractFileExt(filter) = '.png', 'Stone graphic format not supported');

  path := WideExtractFilePath(filter);
  mask := ReplaceNumBy(WideExtractFileName(filter), '%d');

  GetBestMatchCustom(path + mask);
  availableDiameter := CustomeStoneDiameters[2 * radius + 1];

  mask := ReplaceNumBy(mask, '*');
  mask := Format(mask, [availableDiameter]);

  list := TWideStringList.Create;

  WideAddFilesToList(list, path, [afCatPath, afIncludeFiles], mask);

  for i := 0 to list.Count - 1 do
    begin
      name := list[i];
      if not FileExists(name)
        then continue;

      png := TPngObject.Create;
      png.LoadFromFile(name);
      assert(png.TransparencyMode = ptmPartial);

      if availableDiameter <> 2 * radius + 1
        then SmoothResize(png, 2 * radius + 1, 2 * radius + 1);

      pcStones.Add(png)
    end;

  list.Free
end;

// -- Loading of default stones from disk

procedure LoadStoneDefault(pcStones : TList;
                           color, radius : integer;
                           stoneParams : TStoneParams);
var
  stoneParams2 : TStoneParams;
begin
  stoneParams2 := TStoneParams.Create;
  stoneParams2.FLightSource := stoneParams.FLightSource;
  stoneParams2.FBlackFilter := stoneParams.FAppPath + 'Stones\Default\Black11.png';
  stoneParams2.FWhiteFilter := stoneParams.FAppPath + 'Stones\Default\White11.png';
  stoneParams2.FCustomLightSource := lsTopLeft;
  LoadStoneCustom(pcStones, color, radius, stoneParams2);
  stoneParams2.Free
end;

// -- Entry point for loading stone

procedure LoadStones(pcStones : TList;
                     color, radius : integer;
                     stoneParams : TStoneParams);
var
  bmStone : TBitmap;
  png : TPngObject;
begin
  if radius <= 1
    then radius := 1;

  if stoneParams.FStyle in [dsDrawing, dsJago] then
    begin
      bmStone := TBitmap.Create;
      bmStone.TransparentMode := tmAuto;
      bmStone.Transparent := True;
      bmStone.PixelFormat := pf24bit
    end;

  case stoneParams.FStyle of 
    dsDrawing : GetBmStonesDrawing(bmStone, color, radius, stoneParams.FBackColor);
    dsJago    : GetBmStonesJago   (bmStone, color, radius * 2 + 1);
    dsDefault : LoadStoneDefault(pcStones, color, radius, stoneParams);
    dsCustom  : LoadStoneCustom(pcStones, color, radius, stoneParams);
  end;

  if stoneParams.FStyle in [dsDrawing, dsJago] then
    begin
      assert(bmStone.PixelFormat = pf32bit);
      png := TPngObject.CreateBlank(COLOR_RGBALPHA, 8, bmStone.Width, bmStone.Height);
      png.Assign(bmStone);
      png.CreateAlpha;
      assert(png.Header.ColorType = COLOR_RGBALPHA, IntToStr(png.Header.ColorType));
      CopyBmpTransparency(bmStone, png);
      bmStone.Free;
      pcStones.Add(png)
    end
end;

// ---------------------------------------------------------------------------

initialization
  AllocCacheLists
finalization
  FreeCacheLists
end.
