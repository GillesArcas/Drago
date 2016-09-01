unit Pages;

{$define UTF8} // Patch Unicode

{ -----------------------------------------------------------------------------}
{ Component Name:  TPages                                                      }
{ Module:          Pages                                                       }
{ Description:     Report writer and previewer                                 }
{ Version:         1.4                                                         }
{ Date:            15-FEB-2004                                                 }
{ Target:          Win32, Delphi 3 - Delphi 7                                  }
{ Author:          Angus Johnson,   angusj-AT-myrealbox-DOT-com                }
{ Copyright        © 2003 Angus Johnson                                        }
{                                                                              }
{ Notes:                                                                       }
{   * TPages is designed as a simple lightweight report writer. Reports are    }
{     created in code, they are not banded, nor are they directly linked to    }
{     TDatasets. If you're looking for a dataset aware report writer then      }
{     TPages is not for you. TPages is a visual component based on a preview   }
{     TScrollbox, though it isn't necessary to view reports prior to printing. }
{                                                                              }
{   * Main features include:                                                   }
{     + Text can be output either wrapped between page margins, in columns     }
{       or at specified offsets.                                               }
{     + Multiple alignment options -                                           }
{         > left, right and justified in non-columned text                     }
{         > left, right and currency in columned text                          }
{     + Tabs to assigned tabstops                                              }
{     + Multi-line page headers, footers and column headers                    }
{     + Multiple fonts can be used.                                            }
{     + Angled text output                                                     }
{     + Single, line & half, and double line spacing                           }
{     + Methods for printing bitmaps, lines, boxes and arrows                  }
{     + Page numbering can be redefined                                        }
{     + Text output 'groups' prevent blocks of text spanning across pages      }
{     + Designed around a TScrollbox descendant preview window with:           }
{       mouse click zoom control; keyboard handling of lineup, linedown,       }
{       pageup and pagedown srolling; mouse wheel scrolling.                   }
{                                                                              }
{   * In order to get the best print quality, TPages uses the selected print   }
{     driver's resolution to prepare reports (see also Printers.printer).      }
{     If a report will be printed to a different printer (eg by using a        }
{     PrintDialog), it's preferable to change to that printer object BEFORE    }
{     preparing the report. Otherwise, the report will be stretch drawn to the }
{     printer canvas resulting in a slight degradation in print quality.       }
{                                                                              }
{ -----------------------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, Forms,
  ExtCtrls, Printers, WinSpool, Menus, StrUtils,
  TntGraphics // PATCH Unicode
  ;

const
  MAXCOLS = 20;
  MAXTABS = 20;
  PAGENUMBER = '<<pagenumber>>';

type

  TTextAlign = (taLeft,taRight,taCenter,taJustified);
  TColAlign = (caLeft,caRight,caCurrency, caCenter);
  TLineSpacing = (lsSingle, lsOneAndHalf, lsDouble);
  TZoomStatus = (zsPercent, zsFit, zsWidth);

  TNewPageEvent = procedure(Sender: TObject; PageNumber: integer) of object;
  TZoomChangedEvent = procedure(Sender: TObject;
    Zoom: integer; ZoomStatus: TZoomStatus) of object;

  PHdrFtrRec = ^THdrFtrRec;
  THdrFtrRec = record
    Format: longint;
    FontName: string;
    LeftMargin, RightMargin: integer;
  end;

  PColRec = ^TColRec;
  TColRec = record
    ColLeft, ColRight: integer;
    ColAlign: TColAlign;
  end;

  //PATCH UNICODE
  TWideMetafileCanvas = class(TMetafileCanvas)
    procedure TextOut (x, y : integer; const s: string);
    procedure TextRect(Rect: TRect; X, Y: Integer; const Text: string);
    function  TextWidth (const Text: WideString): Integer;
  end;

  TPages = class(TScrollBox)
  private
    fPreviewSurface: TPaintbox;
    {$ifndef UTF8}
    fCanvas: TMetafileCanvas;
    {$else}
    fCanvas: TWideMetafileCanvas;
    {$endif}
    fGroupPage: TMetafile;
    fPages: TList;
    fHeaderLines: TStringList;
    fFooterLines: TStringList;
    //fColumns: TList;
    fColumnHeaderList: TStringList;
    fZoomTimer: TTimer;

    fTab: array[0..MAXTABS-1] of integer;
    fTabCount: integer;
    fCurrentPrinter: string;
    fOrientation: TPrinterOrientation;
    fDefaultLineWidth: integer;        //drawing line width (boxes etc)
    fVirtualPageNum: integer;
    fCurrPreviewPage: integer;
    fZoomIn: boolean;
    fLineHeight: integer;              //Text line height
    fLineSpacing: TLineSpacing;
    fCurrentYPos: integer;
    fHangIndent: integer;
    fAlign: TTextAlign;
    fPageMarginsPx: TRect;
    fHasPrinterInstalled: boolean;
    //fPrinterPxPerInch: TPoint; PATCH
    fPhysicalSizePx: TPoint;           //size of page in printer pixels
    fPhysicalOffsetPx: TPoint;         //size of non-printing margins in pixels
    fZoom: integer;
    fZoomStatus: TZoomStatus;
    fNegsToParenthesesInCurrCols: boolean;

    fHeaderDone: boolean;
    fFooterHeight: integer;
    fFooterGap: integer;
    fInHeaderOrFooter: boolean;
    fColumnHeaderPrinted: boolean;

    fColumnHeaderInGroup: boolean;
    fColumnsUsedInGroup: boolean;
    fGroupVerticalSpace: integer;
    fGroupVerticalPos: integer;

    fZoomChangedEvent: TZoomChangedEvent;
    fPreviewPageChangedEvent: TNotifyEvent;
    fStartNewPageEvent: TNewPageEvent;

    fSavedFlags: integer;
    fSavedFontName: string;
    fSavedAlign: TTextAlign;
    fSavedLeftMargin, fSavedRightMargin: integer;

    procedure GetPrinterParams;
    function  GetPaperSize: TSize;
    function  PrinterPxToScreenPxX(PrinterPx: integer): integer;
    function  PrinterPxToScreenPxY(PrinterPx: integer): integer;
    //function  MmToPrinterPxX(mm: integer): integer;
    //function  MmToPrinterPxY(mm: integer): integer; PATCH
    //function  PrinterPxToMmX(px: integer): integer;
    //function  PrinterPxToMmY(px: integer): integer;
    procedure ResizeAndCenterPaintbox;

    function  GetOrientation: TPrinterOrientation;
    procedure SetOrientation(orientation: TPrinterOrientation);
    procedure SetPage(NewPreviewPage: integer);
    function  GetPageCount: integer;
    function  GetLineHeight: integer;
    function  GetLineHeightMm: integer;
    procedure CheckYPos;               //ie: if not vertical room force new page
    function  GetYPos: integer;
    procedure SetYPos(YPos: integer);
    procedure SaveLayout;
    procedure RestoreSavedLayout;
    procedure NewPageInternal;
    procedure CreateMetafileCanvas(Page: TMetafile);
    procedure UpdateMetafileCanvasFont;
    function  TextFormatsToFlags: longint;
    procedure SetFontWithFlags(flags: longint);
    function  GetCanvas: TCanvas;
    function  GetPageMargins: TRect;
    procedure SetPageMargins(Rect: TRect);

    procedure DoHeader;
    procedure DoFooter;
    procedure DoHeaderFooterInternal(Lines: TStringList);
    procedure CalcFooterGap;

    function  GetColumnCount: integer;
    function  GetColumnRec(col: integer): TColRec;
    procedure PrintColumnHeaders;

    procedure SetZoom(zoom: integer);
    procedure ZoomTimerInternal(X,Y: integer; ZoomIn: boolean);
    procedure ZoomTimer(Sender: TObject);

    procedure LineInternal(start,finish: integer; DoubleLine: boolean);
    procedure PrintFormattedLine(s: string; flags: longint);
    procedure LeftOrJustifiedWrap(const s: string);
    procedure RightOrCenterWrap(const s: string);
    procedure GetTextLimitsPx(var LeftOffset, RightOffset: integer);
    procedure HandleTabsAndPrint(const leftstring: string;
      var rightstring: string; leftOffset, rightOffset: integer);
    procedure PreviewPaint(Sender: TObject);
    procedure PreviewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PreviewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    {$IFNDEF VER100}
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override; //no mousewheel support in Delphi 3
    {$ENDIF}
  public
    fPrinterPxPerInch: TPoint; //PATCH
    fColumns: TList;           //PATCH
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginDoc;
    procedure DrawText(const s: string);
    procedure DrawTextAt(s: string; XPos: integer);
    procedure DrawAngledTextAt(const s: string; XPos, Angle: integer);
    procedure DrawBox(left,top,right,bottom: integer);
    procedure DrawBMP(rec: TRect; bmp: TBitmap);
    procedure DrawMeta(rec: TRect; mf: TMetafile);
    procedure DrawArrow(Point1, Point2: TPoint;
      HeadSize: integer; SolidHead: boolean);
    procedure DrawLine(doubleline: boolean);
    procedure NewLine;
    procedure NewLines(count: integer);
    procedure NewPage;
    procedure BeginGroup;
    procedure EndGroup;
    procedure EndDoc;
    procedure PrintPages(PrintFrom, PrintTo: integer);

    procedure SetTabStops(tabs: array of integer);
    function  HasSpaceForLines(Count: integer): boolean;

    function  MmToPrinterPxX(mm: integer): integer; // PATCH
    function  MmToPrinterPxY(mm: integer): integer;
    function  PrinterPxToMmX(px: integer): integer;
    function  PrinterPxToMmY(px: integer): integer;

    //headers & footers ...
    procedure AddLineToHeader(doubleline: boolean);
    procedure AddLineToFooter(doubleline: boolean);
    procedure AddTextToHeader(const s: string);
    procedure AddTextToHeaderAt(const s: string; XPos: integer);
    procedure AddTextToFooter(const s: string);
    procedure AddTextToFooterAt(const s: string; XPos: integer);

    //columns ...
    function  GetColumnInfo(index: integer): TColRec;
    procedure AddColumn(left, right: integer; align: TColAlign);
    procedure AddColumnHeaders(headers: array of string);
    procedure DrawTextAcrossCols(StringArray: Array of string);
    procedure DrawLinesAcrossCols(StringArray: Array of string);
    procedure DrawLinesInCurrencyCols(doublelines: boolean);
    procedure ColumnHeadersNeeded;

    procedure Clear;
    procedure ClearHeaders;
    procedure ClearFooters;
    procedure ClearColumns;
    procedure ClearColumnHeaders;

    property Canvas: TCanvas read GetCanvas;
    property ColumnCount: integer read GetColumnCount;
    property CurrentYPos: integer read GetYPos write SetYPos;
    property LineHeight: integer read GetLineHeightMm;
    property PrinterName: string read fCurrentPrinter;
    property Page: integer read fCurrPreviewPage write SetPage;
    property PageCount: integer read GetPageCount;
    property PageMargins: TRect read GetPageMargins write SetPageMargins;
    property PaperSize: TSize read GetPaperSize;
    property VirtualPageNum: integer read fVirtualPageNum write fVirtualPageNum;
  published
    property NegsToParenthesesInCurrCols: boolean
      read fNegsToParenthesesInCurrCols write fNegsToParenthesesInCurrCols;
    property HangIndent: integer read fHangIndent write fHangIndent;
    property LineSpacing: TLineSpacing read fLineSpacing write fLineSpacing;
    property Orientation: TPrinterOrientation
      read GetOrientation write SetOrientation;
    property TextAlign: TTextAlign read fAlign write fAlign;
    property Zoom: integer read fZoom write SetZoom;
    property ZoomStatus: TZoomStatus read fZoomStatus;

    property OnNewPage: TNewPageEvent
      read fStartNewPageEvent write fStartNewPageEvent;
    property OnPreviewPageChanged: TNotifyEvent
      read fPreviewPageChangedEvent write fPreviewPageChangedEvent;
    property OnZoomChanged: TZoomChangedEvent
      read fZoomChangedEvent write fZoomChangedEvent;
  end;

const
  GRAY_MARGIN = 10; //minimum gray border around preview page
  PAGE_WIDTH = -1;  //preview page zoom options...
  PAGE_FIT   = -2;

  //TEXT FORMAT FLAGS...
  FORMAT_DEFAULT    = $0;
  //fontsize bits 0-7  .'. max = 255
  FORMAT_SIZE_MASK  = $FF;
  //alignment bits 8-9
  FORMAT_ALIGN_MASK = $300;
  FORMAT_LEFT       = $0;
  FORMAT_RIGHT      = $100;
  FORMAT_CENTER     = $200;
  FORMAT_JUSTIFIED  = $300;
  //fontstyle bits 10-12
  FORMAT_BOLD       = $400;
  FORMAT_UNDERLINE  = $800;
  FORMAT_ITALIC     = $1000;
  //undefined bit 13
  FORMAT_UNDEFINED  = $2000;
  //line flags bits 14-15
  FORMAT_SINGLELINE = $8000;
  FORMAT_DOUBLELINE = $4000;
  FORMAT_LINES      = $C000;
  //DrawTextAt XPos 16-30 bits  (max value = ~64000)
  FORMAT_XPOS_MASK  = $FFFF0000;

  PAPERSIZE_A4_WIDTH = 210;
  PAPERSIZE_A4_HEIGHT = 297;

procedure SetCurrentPrinterAsDefault;
function CurrentPrinterName: string;
function CurrentPrinterPaperSize: string;
procedure UseDefaultPrinter;

procedure Register;

implementation

type
  //TZStrings: used by ColumnHeaderList to store #0 terminated char arrays
  //eg: A column header row might look like - 'Column One'#0'Column Two'#0
  TZStrings = String;


//-- UNICODE PATCH

procedure  TWideMetafileCanvas.TextOut (x, y : integer; const s: string);
begin
  WideCanvasTextOut(self as TMetafileCanvas, x, y, UTF8Decode(s))
end;

procedure  TWideMetafileCanvas.TextRect(Rect: TRect; X, Y: Integer; const Text: string);
begin
  WideCanvasTextRect (self as TMetafileCanvas, Rect, x, y, UTF8Decode(Text))
end;

function TWideMetafileCanvas.TextWidth (const Text: WideString): Integer;
begin
  Result := WideCanvasTextWidth (self as TMetafileCanvas, UTF8Decode(Text))
end;

//------------------------------------------------------------------------------
// Miscellaneous functions ...
//------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('Samples', [TPages]);
end;
//------------------------------------------------------------------------------

{$IFDEF VER100}
procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ENDIF}
//------------------------------------------------------------------------------

function ConvertNegsToParentheses(const ValStr: string): string;
begin
  result := ValStr;
  if (ValStr = '') or (ValStr[1] <> '-') then exit;
  result[1] := '(';
  result := result + ')';
end;
//------------------------------------------------------------------------------

function PrinterDriverExists: boolean;
var
  Flags, Count, NumInfo: dword;
  Level: Byte;
begin
  //avoid using fPrinter.printers.count as this will raise an
  //exception if no printer driver is installed...
  Count := 0;
  try
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
      Level := 4;
    end else
    begin
      Flags := PRINTER_ENUM_LOCAL;
      Level := 5;
    end;
    EnumPrinters(Flags, nil, Level, nil, 0, Count, NumInfo);
  except
  end;
  result := (count > 0);
end;
//------------------------------------------------------------------------------

function RTrim(S: string): string;
var
  i: integer;
begin
  result := S;
  i := Length(s);
  while (i > 0) and (result[i] in [#9, #32]) do dec(i);
  setlength(result,i);
end;
//------------------------------------------------------------------------------

function Max(a,b: integer): integer;
begin
  if a > b then
    result := a else
    result := b;
end;
//------------------------------------------------------------------------------

function Min(a,b: integer): integer;
begin
  if a < b then
    result := a else
    result := b;
end;
//------------------------------------------------------------------------------

procedure UseDefaultPrinter;
begin
  Printers.Printer.PrinterIndex := -1;
end;
//------------------------------------------------------------------------------

function GetDefaultPrinterName: string;
var
  Device : array[0..255] of char;
  p,p2: PChar;
begin
  GetProfileString('windows', 'device', '', Device, 255);
  p2 := Device;
  while p2^ = ' ' do inc(p2);
  p := p2;
  while not (p2^ in [#0,',']) do inc(p2);
  setlength(result, p2 - p);
  if p2 > p then move(p^, result[1], p2 - p);
end;
//------------------------------------------------------------------------------

function GetDriverForPrinter(Device: PChar; Driver: PChar): boolean;
var
  PrintHandle: THandle;
  DriverInfo2: PDriverInfo2;
  cnt: dword;
  DriverPath: string;
begin
  result := false;
  if not OpenPrinter(Device,PrintHandle, nil) then exit;
  try
    getmem(DriverInfo2,1024);
    try
      if GetPrinterDriver(PrintHandle, nil, 2, DriverInfo2, 1024, cnt) then
      begin
        DriverPath :=
          changefileext(extractfilename(DriverInfo2.pDriverPath),'');
        strpcopy(Driver, DriverPath);
        result := true;
      end;
    finally
      freemem(DriverInfo2);
    end;
  finally
    ClosePrinter(PrintHandle);
  end;
end;
//------------------------------------------------------------------------------

procedure SetCurrentPrinterAsDefault;
var
  Device : array[0..255] of char;
  Driver : array[0..255] of char;
  Port  : array[0..255] of char;
  DefaultPrinter: string;
  hDeviceMode: THandle;
begin
  DefaultPrinter := GetDefaultPrinterName;
  Printer.GetPrinter(Device, Driver, Port, hDeviceMode);
  if DefaultPrinter = Device then exit;
  if (Driver[0] = #0) then
    if not GetDriverForPrinter(Device, Driver) then exit;  //oops !
  DefaultPrinter := format('%s,%s,%s',[Device, Driver, Port]);
  WriteProfileString( 'windows', 'device', pchar(DefaultPrinter) );
  Device := 'windows';
  SendMessage( HWND_BROADCAST, WM_WININICHANGE, 0, longint( @Device ));
end;

//------------------------------------------------------------------------------

function CurrentPrinterName: string;
var
  Device : array[0..255] of char;
  Driver : array[0..255] of char;
  Port  : array[0..255] of char;
  hDeviceMode: THandle;
begin
  if Printer.Printers.Count = 0
    then result := 'No printer'
    else
      begin
        Printer.GetPrinter(Device, Driver, Port, hDeviceMode);
        result := Device
      end
end;
//------------------------------------------------------------------------------

function CurrentPrinterPaperSize: string;
var
  PtrHdl: THandle;
  PtrPPI: TPoint;
  size: TSize;
begin
  try
    PtrHdl := printer.Handle;
    PtrPPI.x := GetDeviceCaps(PtrHdl, LOGPIXELSX);
    PtrPPI.y := GetDeviceCaps(PtrHdl, LOGPIXELSY);
    size.cx := mulDiv(GetDeviceCaps(PtrHdl, PHYSICALWIDTH), 254,PtrPPI.x *10);
    size.cy := mulDiv(GetDeviceCaps(PtrHdl, PHYSICALHEIGHT), 254,PtrPPI.y *10);
  except
    result := '';
    exit
  end;
  with size do
  begin
    if cx > cy then
    begin
      //landscape ...
      case cy of
        148: if (cx = 210) then result := 'A5 (210 x 148mm)';
        210: if (cx = 297) then result := 'A4 (297 x 210mm)';
        216: if (cx = 279) then result := 'Letter (11 x 8½")'
             else if (cx = 356) then result := 'Legal (14 x 8½")';
        297: if (cx = 420) then result := 'A3 (420 x 297mm)';
      end;
    end else
    begin
      //portrait ...
      case cx of
        148: if (cy = 210) then result := 'A5 (148 x 210mm)';
        210: if (cy = 297) then result := 'A4 (210 x 297mm)';
        216: if (cy = 279) then result := 'Letter (8½ x 11")'
             else if (cy = 356) then result := 'Legal (8½ x 14")';
        297: if (cy = 420) then result := 'A3 (297 x 420mm)';
      end;
    end;
    if result = '' then result := format('Custom (%d x %dmm)',[cx, cy]);
  end;
end;
//------------------------------------------------------------------------------

//This declaration modifies Delphi's declaration of GetTextExtentExPoint
//so that the variable to receive partial string extents (p6) is ignored ...
function GetTextExtentExPointNoPartials(DC: HDC; p2: PAnsiChar; p3, p4: Integer;
  var p5: Integer; const p6: integer; var p7: TSize): BOOL; stdcall;
    external gdi32 name 'GetTextExtentExPointA';

function GetTextExtentExPointNoPartialsW(DC: HDC; p2: PWideChar; p3, p4: Integer;
  var p5: Integer; const p6: integer; var p7: TSize): BOOL; stdcall;
    external gdi32 name 'GetTextExtentExPointW';

//TrimLine: Splits off from LS any characters beyond the allowed width
//breaking at the end of a word if possible. Leftover chars -> RS.
{$ifndef UTF8}
procedure TrimLine(canvas: TCanvas; var ls: string; out rs: string;
                           LineWidthInPxls: integer);
var
  i,len,NumCharWhichFit: integer;
  dummy: TSize;
begin
  len := length(ls);
  if len = 0 then exit; 

  //get the number of characters which will fit within LineWidth...
  if not GetTextExtentExPointNoPartials(canvas.handle,
    pchar(ls),len,LineWidthInPxls,NumCharWhichFit,0,dummy) then
      raise Exception.create('GetTextExtentExPointA WinApi error in TPages');

  if NumCharWhichFit = len then exit; //if everything fits then stop here

  i := NumCharWhichFit;
  //find the end of the last whole word which will fit...
  while (NumCharWhichFit > 0) and (ls[NumCharWhichFit] > ' ') do
    dec(NumCharWhichFit);
  if (NumCharWhichFit = 0) then NumCharWhichFit := i;

  i := NumCharWhichFit+1;
  //ignore trailing blanks in LS...
  while (ls[NumCharWhichFit] = ' ') do dec(NumCharWhichFit);
  //ignore beginning blanks in RS...
  while (i < len) and (ls[i] = ' ') do inc(i);
  rs := copy(ls,i,len);
  ls := copy(ls,1,NumCharWhichFit);        //nb: assign ls AFTER rs here
end;
{$else}
procedure TrimLine(canvas: TCanvas; var ls: string; out rs: string;
                           LineWidthInPxls: integer);
var
  i,len,NumCharWhichFit: integer;
  dummy: TSize;
  wls, wrs : WideString;
begin
  len := length(ls);
  if len = 0 then exit;

  wls := UTF8Decode (ls);

  //get the number of characters which will fit within LineWidth...
  try
    if not GetTextExtentExPointNoPartialsW(canvas.handle,
      PWideChar(wls),len,LineWidthInPxls,NumCharWhichFit,0,dummy) then
        //raise Exception.create('GetTextExtentExPointW WinApi error in TPages');
        NumCharWhichFit := len //GAL: ignore error and consider it fits in line
  except
    NumCharWhichFit := len //GAL: ignore error and consider it fits in line
  end;

  if NumCharWhichFit = len then exit; //if everything fits then stop here

  // should not be but it does. Exit as a workaround.
  if NumCharWhichFit > Length (wls) then exit;

  i := NumCharWhichFit;
  //find the end of the last whole word which will fit...
  while (NumCharWhichFit > 0) and (wls[NumCharWhichFit] > ' ') do
    dec(NumCharWhichFit);
  if (NumCharWhichFit = 0) then NumCharWhichFit := i;

  i := NumCharWhichFit+1;
  //ignore trailing blanks in LS...
  while (wls[NumCharWhichFit] = ' ') do dec(NumCharWhichFit);
  //ignore beginning blanks in RS...
  while (i < len) and (wls[i] = ' ') do inc(i);
  wrs := copy(wls,i,len);
  wls := copy(wls,1,NumCharWhichFit);        //nb: assign ls AFTER rs here

  ls := UTF8Encode (wls);
  rs := UTF8Encode (wrs);
end;
{$endif}
//------------------------------------------------------------------------------

procedure PrintBitmap(Canvas: TCanvas; DestRect: TRect; Bitmap: TBitmap);
var
    BitmapHeader:  pBitmapInfo;
    BitmapImage :  POINTER;
    HeaderSize  :  dword;
    ImageSize   :  dword;
begin
  Canvas.CopyRect (DestRect, Bitmap.Canvas, Bounds (0,0, Bitmap.Width, Bitmap.Height));
  exit; // PATCH
  GetDIBSizes(Bitmap.Handle,HeaderSize,ImageSize);
  GetMem(BitmapHeader,HeaderSize);
  GetMem(BitmapImage,ImageSize);
  try
    GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
    StretchDIBits(Canvas.Handle,
                  DestRect.Left, DestRect.Top,     // Destination Origin
                  DestRect.Right  - DestRect.Left, // Destination Width
                  DestRect.Bottom - DestRect.Top,  // Destination Height
                  0,0,                             // Source Origin
                  Bitmap.Width, Bitmap.Height,     // Source Width & Height
                  BitmapImage,
                  TBitmapInfo(BitmapHeader^),
                  DIB_RGB_COLORS,
                  SRCCOPY);
  finally
    FreeMem(BitmapHeader);
    FreeMem(BitmapImage)
  end;
end;
//------------------------------------------------------------------------------

procedure PrintMetafile(Canvas: TCanvas; DestRect: TRect; mf: TMetafile);
begin
  Canvas.Draw (DestRect.Left, DestRect.Top, mf)
end;
//------------------------------------------------------------------------------

//This DrawArrow() function is based on code downloaded from
//http://www.efg2.com/Lab/Library/Delphi/Graphics/Algorithms.htm
//(The original author is unknown)
procedure DrawArrowInternal(Canvas: TCanvas;
  FromPoint, ToPoint: TPoint; HeadSize: integer; SolidArrowHead: boolean);
var
  xbase           :  integer;
  xLineDelta      :  integer;
  xLineUnitDelta  :  Double;
  xNormalDelta    :  integer;
  xNormalUnitDelta:  Double;
  ybase           :  integer;
  yLineDelta      :  integer;
  yLineUnitDelta  :  Double;
  yNormalDelta    :  integer;
  yNormalUnitDelta:  Double;
  SavedBrushColor :  TColor;
begin
  with FromPoint do Canvas.MoveTo(x,y);
  with ToPoint do Canvas.LineTo(x,y);

  xLineDelta := ToPoint.X - FromPoint.X;
  yLineDelta := ToPoint.Y - FromPoint.Y;

  xLineUnitDelta := xLineDelta / SQRt( SQR(xLineDelta) + SQR(yLineDelta) );
  yLineUnitDelta := yLineDelta / SQRt( SQR(xLineDelta) + SQR(yLineDelta) );

  //(xBase,yBase) is where arrow line is perpendicular to base of triangle.
  xBase := ToPoint.X - ROUND(HeadSize * xLineUnitDelta);
  yBase := ToPoint.Y - ROUND(HeadSize * yLineUnitDelta);

  xNormalDelta :=  yLineDelta;
  yNormalDelta := -xLineDelta;
  xNormalUnitDelta := xNormalDelta / SQRt( SQR(xNormalDelta) + SQR(yNormalDelta) );
  yNormalUnitDelta := yNormalDelta / SQRt( SQR(xNormalDelta) + SQR(yNormalDelta) );

  SavedBrushColor := Canvas.Brush.Color;
  if SolidArrowHead then
    Canvas.Brush.Color := Canvas.Pen.Color;
  Canvas.Polygon([ToPoint,
    Point(xBase + ROUND(HeadSize*xNormalUnitDelta),
      yBase + ROUND(HeadSize*yNormalUnitDelta)),
    Point(xBase - ROUND(HeadSize*xNormalUnitDelta),
      yBase - ROUND(HeadSize*yNormalUnitDelta)) ]);
  Canvas.Brush.Color := SavedBrushColor;
end;

//------------------------------------------------------------------------------
// TPages methods (private)...
//------------------------------------------------------------------------------

procedure TPages.GetPrinterParams;
var
  PtrHdl: THandle;
  i: integer;
begin
  fCurrentPrinter := CurrentPrinterName;
  if fHasPrinterInstalled then
    try
      if (Printer.orientation <> fOrientation) then
        Printer.orientation := fOrientation;
      PtrHdl := printer.Handle;
      fPrinterPxPerInch.x := GetDeviceCaps(PtrHdl, LOGPIXELSX);
      fPrinterPxPerInch.y := GetDeviceCaps(PtrHdl, LOGPIXELSY);

      fPhysicalSizePx.x := GetDeviceCaps(PtrHdl, PHYSICALWIDTH);
      fPhysicalOffsetPx.x := GetDeviceCaps(PtrHdl,PHYSICALOFFSETX);

      fPhysicalSizePx.y := GetDeviceCaps(PtrHdl, PHYSICALHEIGHT);
      fPhysicalOffsetPx.y := GetDeviceCaps(PtrHdl,PHYSICALOFFSETY);
      fDefaultLineWidth :=
        fPrinterPxPerInch.y div screen.pixelsperinch;

      //fDefaultLineWidth ==> 0.25 mm
      fDefaultLineWidth := round(fPrinterPxPerInch.y / 25.4 * 0.25);

      exit; //if a printer was found then that's all that's needed
    except
      fHasPrinterInstalled := false;
    end;
  //if no printer drivers installed use the screen as device context and
  //assume A4 page size...
  fPhysicalSizePx :=
    point(muldiv(PAPERSIZE_A4_WIDTH*10,screen.pixelsperinch,254),
      muldiv(PAPERSIZE_A4_HEIGHT*10,screen.pixelsperinch,254));
  //assume 6mm non-printing offsets...
  fPhysicalOffsetPx := point(muldiv(60,screen.pixelsperinch,254),
                       muldiv(60,screen.pixelsperinch,254));
  fPrinterPxPerInch := point(screen.pixelsperinch,screen.pixelsperinch);
  //fDefaultLineWidth ==> 0.3 mm
  fDefaultLineWidth := round(fPrinterPxPerInch.y / 25.4 * 0.3);
  if fOrientation = poLandscape then
  begin
    //swap width & height if poLandscape ...
    i := fPhysicalSizePx.x;
    fPhysicalSizePx.x := fPhysicalSizePx.y;
    fPhysicalSizePx.y := i;
  end;
end;
//------------------------------------------------------------------------------

function TPages.PrinterPxToScreenPxX(PrinterPx: integer): integer;
begin
  Result:=round(PrinterPx*screen.pixelsperinch/fPrinterPxPerInch.x*fZoom/100);
end;
//------------------------------------------------------------------------------

function TPages.PrinterPxToScreenPxY(PrinterPx: integer): integer;
begin
  Result:=round(PrinterPx*screen.pixelsperinch/fPrinterPxPerInch.y*fZoom/100);
end;
//------------------------------------------------------------------------------

function TPages.MmToPrinterPxX(mm: integer): integer;
begin
    Result := round(mm * fPrinterPxPerInch.x/25.4);
end;
//------------------------------------------------------------------------------

function TPages.MmToPrinterPxY(mm: integer): integer;
begin
    Result := round(mm * fPrinterPxPerInch.y/25.4);
end;
//------------------------------------------------------------------------------

function TPages.PrinterPxToMmX(px: integer): integer;
begin
  result := round(px * 25.4 / fPrinterPxPerInch.x);
end;
//------------------------------------------------------------------------------

function TPages.PrinterPxToMmY(px: integer): integer;
begin
  result := round(px * 25.4 / fPrinterPxPerInch.y);
end;
//------------------------------------------------------------------------------

procedure TPages.ResizeAndCenterPaintbox;
var
  w,h,l,t: integer;
begin
  with fPreviewSurface do
  begin
    w := PrinterPxToScreenPxX(fPhysicalSizePx.x)+GRAY_MARGIN*2;
    h := PrinterPxToScreenPxY(fPhysicalSizePx.y)+GRAY_MARGIN*2;
    l := Max((self.clientWidth - w) div 2,0) -HorzScrollbar.Position;
    t := Max((self.clientHeight - h) div 2,0) -VertScrollbar.Position;
    setbounds(l,t,w,h);
  end;
end;
//------------------------------------------------------------------------------

function TPages.GetOrientation: TPrinterOrientation;
begin
  if (fPhysicalSizePx.x > fPhysicalSizePx.y) then
    result := poLandscape else
    result := poPortrait;
end;
//------------------------------------------------------------------------------

procedure TPages.SetOrientation(orientation: TPrinterOrientation);
begin
  //nb: it's not possible to change the orientation once a report has started
  fOrientation := orientation;
end;
//------------------------------------------------------------------------------

procedure TPages.SetPage(NewPreviewPage: integer);
begin
  if (NewPreviewPage > fPages.count) then NewPreviewPage := fPages.count
  else if (NewPreviewPage < 1) then NewPreviewPage := 1;
  if (fPages.count = 0) or (fCurrPreviewPage = NewPreviewPage) then exit;
  fCurrPreviewPage := NewPreviewPage;
  PreviewPaint(self);
  if assigned(fPreviewPageChangedEvent) then fPreviewPageChangedEvent(self);
end;
//------------------------------------------------------------------------------

function TPages.GetPageCount: integer;
begin
  result := fPages.count;
end;
//------------------------------------------------------------------------------

function TPages.GetLineHeight: integer;
var
  tm: TTextMetric;
  tmp: TMetafile;
begin
  if fLineHeight = 0 then
  begin
    if not assigned(fCanvas) then
    begin
      tmp := TMetafile.Create;
      CreateMetafileCanvas(tmp);
      GetTextMetrics(fCanvas.handle,tm);
      FreeAndNil(fCanvas);
      tmp.free;
    end
    else
      GetTextMetrics(fCanvas.handle,tm);
    fLineHeight := tm.tmHeight+tm.tmInternalLeading+tm.tmExternalLeading;
  end;

  if fInHeaderOrFooter then
    result := fLineHeight else
  begin
    case fLineSpacing of
      lsSingle: result := fLineHeight;
      lsOneAndHalf: result := round(fLineHeight*1.5);
      else result := fLineHeight*2;
    end;
  end;
end;
//------------------------------------------------------------------------------

function TPages.GetLineHeightMm: integer;
begin
  result := PrinterPxToMmY(GetLineHeight);
end;
//------------------------------------------------------------------------------

procedure TPages.CheckYPos;
begin
  if fInHeaderOrFooter then exit;
  if not fHeaderDone then DoHeader;
  if not HasSpaceForLines(1) then
  begin
    NewPageInternal;
    //nb: header is done if was in a group, so ...
    if not fHeaderDone then DoHeader;
  end;
end;
//------------------------------------------------------------------------------

function TPages.GetYPos: integer;
begin
  Result := MulDiv(fCurrentYPos,254,fPrinterPxPerInch.x*10);
end;
//------------------------------------------------------------------------------

procedure TPages.SetYPos(YPos: integer);
begin
  if fCurrentYPos >= fPhysicalSizePx.y then NewPageInternal;
  fCurrentYPos := MmToPrinterPxY(YPos);
end;
//------------------------------------------------------------------------------

procedure TPages.SaveLayout;
begin
  fSavedFlags := TextFormatsToFlags;          //SAVE FONT DETAILS
  fSavedFontName := Font.Name;
  fSavedAlign := fAlign;
  fSavedLeftMargin := fPageMarginsPx.Left;
  fSavedRightMargin := fPageMarginsPx.Right;
end;
//------------------------------------------------------------------------------

procedure TPages.RestoreSavedLayout;
begin
  SetFontWithFlags(fSavedFlags);
  Font.Name := fSavedFontName;
  fAlign := fSavedAlign;
  fPageMarginsPx.Left := fSavedLeftMargin;
  fPageMarginsPx.Right := fSavedRightMargin;
end;
//------------------------------------------------------------------------------

procedure TPages.NewPageInternal;
var
  UsedGroupSpace: integer;
  NewPage: TMetafile;
  InGroup: boolean;
begin
  UsedGroupSpace := 0; //stops a warning
  InGroup := assigned(fGroupPage);
  if InGroup then
  begin
    //close the Group ...
    UsedGroupSpace := fCurrentYPos;
    FreeAndNil(fCanvas);
    CreateMetafileCanvas(fPages[fPages.count-1]);
    fCanvas.draw(0,0,fPages[fPages.count-1]);     //re-draw the last page
  end;
  DoFooter;
  //create a new metafile and its canvas ...
  if assigned(fCanvas) then FreeAndNil(fCanvas);
  NewPage := TMetafile.Create;
  fPages.add(NewPage);
  NewPage.Width := fPhysicalSizePx.x;
  NewPage.Height := fPhysicalSizePx.y;
  CreateMetafileCanvas(NewPage);

  inc(fVirtualPageNum);
  fCurrentYPos := fPageMarginsPx.top;
  if assigned(fStartNewPageEvent) then fStartNewPageEvent(self,fPages.count);
  fHeaderDone := false;
  fColumnHeaderPrinted := false; //when next col. started add header
  if InGroup then
  begin
    DoHeader;
    if fColumnsUsedInGroup then
    begin
      //The next line is a workaround to stop an endless loop. CheckYPos (called
      //via PrintColumnHeaders) thinks we're still drawing on fGroupPage as it's
      //still assigned so can flag "out of room" and try to create another page.
      fGroupVerticalSpace := fPhysicalSizePx.y;
      if not fColumnHeaderInGroup then
        PrintColumnHeaders else
        fColumnHeaderPrinted := true;
    end;
    fCanvas.draw(0,fCurrentYPos,fGroupPage);
    FreeAndNil(fGroupPage);
    inc(fCurrentYPos,UsedGroupSpace);
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.CreateMetafileCanvas(Page: TMetafile);
begin
  {$ifndef UTF8}
  fCanvas := TMetafileCanvas.Create(Page, 0); // NOT PROTECTED
  {$else}
  fCanvas := TWideMetafileCanvas.Create(Page, 0); // NOT PROTECTED
  {$endif}
  UpdateMetafileCanvasFont;
  fCanvas.Pen.Width := fPrinterPxPerInch.y div screen.PixelsPerInch;
  setbkmode(fCanvas.handle,TRANSPARENT);
end;
//------------------------------------------------------------------------------

procedure TPages.UpdateMetafileCanvasFont;
begin
  //next 2 lines are a printer bug workaround - 23Mar2000
  fCanvas.font.size := font.size+1;
  fCanvas.Font.PixelsPerInch := fPrinterPxPerInch.y;
  fCanvas.Font := self.Font;
end;
//------------------------------------------------------------------------------

function TPages.TextFormatsToFlags: longint;
begin
  result := min(max(font.size,4),FORMAT_SIZE_MASK); {size between 4 and 255}
  case falign of
    taRight: result := result or FORMAT_RIGHT;
    taCenter: result := result or FORMAT_CENTER;
    taJustified: result := result or FORMAT_JUSTIFIED;
  end;
  if fsBold in font.style then result := result or FORMAT_BOLD;
  if fsUnderline in font.style then result := result or FORMAT_UNDERLINE;
  if fsItalic in font.style then result := result or FORMAT_ITALIC;
end;
//------------------------------------------------------------------------------

procedure TPages.SetFontWithFlags(flags: longint);
var
  fontstyle: TFontStyles;
begin
  font.size := flags and FORMAT_SIZE_MASK;
  if (flags and FORMAT_BOLD) <> 0 then
    fontstyle := [fsBold] else
    fontstyle := [];
  if (flags and FORMAT_UNDERLINE) <> 0 then
    fontstyle := fontstyle+ [fsUnderline];
  if (flags and FORMAT_ITALIC) <> 0 then
    fontstyle := fontstyle+ [fsItalic];
  font.style := fontstyle;
  case (flags and FORMAT_ALIGN_MASK) of
    FORMAT_LEFT: falign := taLeft;
    FORMAT_RIGHT: falign := taRight;
    FORMAT_CENTER: falign := taCenter;
    else falign := taJustified;
  end;
end;
//------------------------------------------------------------------------------

function TPages.HasSpaceForLines(Count: integer): boolean;
begin
  if assigned(fGroupPage) then
    result := fCurrentYPos + GetLineHeight*Count < fGroupVerticalSpace else
    result := fCurrentYPos + GetLineHeight*Count <
      fPhysicalSizePx.y - fPageMarginsPx.bottom - fFooterHeight;
end;
//------------------------------------------------------------------------------

function TPages.GetCanvas: TCanvas;
begin
  result := fCanvas;
end;
//------------------------------------------------------------------------------

procedure TPages.DoHeader;
begin
  fHeaderDone := true;
  if (fHeaderLines.count = 0) then exit;
  SaveLayout;
  DoHeaderFooterInternal(fHeaderLines);
  inc(fCurrentYPos, fLineHeight div 2); //add a small header gap
  RestoreSavedLayout;
end;
//------------------------------------------------------------------------------

procedure TPages.DoFooter;
begin
  if (fFooterLines.count = 0) then exit;
  SaveLayout;
  fCurrentYPos := fPhysicalSizePx.y -
    fPageMarginsPx.bottom - fFooterHeight + fFooterGap;
  DoHeaderFooterInternal(fFooterLines);
  RestoreSavedLayout;
end;
//------------------------------------------------------------------------------

procedure TPages.DoHeaderFooterInternal(Lines: TStringList);
var
  i: integer;
begin
  fInHeaderOrFooter := true;
  try
    for i := 0 to Lines.count -1 do
      with PHdrFtrRec(Lines.objects[i])^ do
      begin
        self.Font.name := FontName;
        if assigned(fCanvas) then fCanvas.font := self.font;
        fPageMarginsPx.Left := LeftMargin;
        fPageMarginsPx.Right := RightMargin;
        PrintFormattedLine(Lines[i], Format);
      end;
  finally
    fInHeaderOrFooter := false;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.CalcFooterGap;
begin
  GetLineHeight;
  //make sure there's a gap of at least 1/4 of a lineheight
  //between the page body and the footer ...
  fFooterGap := fLineHeight div 4;
  fFooterHeight := fFooterGap;
end;
//------------------------------------------------------------------------------

function TPages.GetColumnRec(col: integer): TColRec;
begin
  result.ColLeft := 0;
  result.ColRight := 0;
  if (col < 0) or (col >= fColumns.count) then exit;
  result := PColRec(fColumns[col])^;
end;
//------------------------------------------------------------------------------

procedure TPages.PrintColumnHeaders;
var
  i,j,SavedFontSize: integer;
  SavedFontStyle: TFontStyles;
  SavedAlign: TTextAlign;
  headers: array[0..MAXCOLS-1] of string;
  zStr: TZStrings;

  function GetSubstringFromStringArray(var s: TZStrings): string;
  begin
    result := pchar(s);
    s := copy(s,length(result)+2,length(s));
  end;

begin
  if (fColumnHeaderList.count = 0) or (fColumns.count = 0) then exit;
  CheckYPos;

  fColumnHeaderPrinted := true;   //stops an endless loop

  SavedFontSize := Font.size;
  SavedFontStyle := font.style;
  SavedAlign := fAlign;
  for i := 0 to fColumnHeaderList.count-1 do
  begin
    SetFontWithFlags(longint(fColumnHeaderList.objects[i]));
    j := 0;
    zStr := fColumnHeaderList[i];
    while (j < MAXCOLS) and (zStr<>'') do
    begin
      headers[j] := GetSubstringFromStringArray(zStr);
      inc(j);
    end;
    DrawTextAcrossCols(slice(headers,j));
  end;
  //add a small space below the column headers
  inc(fCurrentYPos,fLineHeight div 3);

  Font.size := SavedFontSize;
  font.style := SavedFontStyle;
  fAlign := SavedAlign;
  if assigned(fGroupPage) then fColumnHeaderInGroup := true;
end;
//------------------------------------------------------------------------------

procedure TPages.SetZoom(Zoom: integer);
var
  i,zoomW,zoomH: integer;
begin
  (*
  TMetaFile(fPages[0]).Width  := 709;
  TMetaFile(fPages[0]).Height := 1000;
  TMetaFile(fPages[0]).SaveToFile ('c:\Gilles\Go\Drago\1stPage.wmf');
  *)

  if (zoom < PAGE_FIT) or (zoom in [0..9]) or (zoom > 200) then exit;

  //ZoomStatus required when resizing...
  if zoom = PAGE_FIT then fZoomStatus := zsFit
  else if zoom = PAGE_WIDTH then fZoomStatus := zsWidth
  else fZoomStatus := zsPercent;

  if (fZoom = Zoom) or (not handleallocated) then exit;
  fZoom := Zoom;

  //calculate the new fZoom ...
  if zoom = PAGE_FIT then
  begin
    ZoomW := trunc((clientWidth-GRAY_MARGIN*2)*fPrinterPxPerInch.x*
               100/fPhysicalSizePx.x/screen.pixelsperinch);
    ZoomH := trunc((clientHeight-GRAY_MARGIN*2)*fPrinterPxPerInch.y*
               100/fPhysicalSizePx.y/screen.pixelsperinch);
    //choose the smallest of width% and height% to fit on page (but min 10%)
    fZoom := Max(Min(ZoomW,ZoomH),10);
  end
  else if zoom = PAGE_WIDTH then
  begin
    fZoom := trunc((clientWidth-GRAY_MARGIN*2)*fPrinterPxPerInch.x*
               100/fPhysicalSizePx.x/screen.pixelsperinch);
  end
  else
    fZoom := Zoom;

  i := PrinterPxToScreenPxY(GetLineHeight);
  HorzScrollbar.Increment := i;
  VertScrollbar.Increment := i;

  //resize and center preview surface...
  ResizeAndCenterPaintbox;

  if assigned(fZoomChangedEvent) then
    fZoomChangedEvent(self, fZoom, fZoomStatus);
end;
//------------------------------------------------------------------------------

procedure TPages.ZoomTimerInternal(X,Y: integer; ZoomIn: boolean);
var
  OldZoom: integer;
  pt: TPoint;
begin
  OldZoom := fZoom;
  sendmessage(handle,WM_SETREDRAW,0,0);
  try
    if ZoomIn then
    begin
      if fZoom >= 200 then fZoomTimer.enabled := false       //(maximum 200%)
      else Zoom := round((fZoom + 10)/10)*10;                //to nearest 10%
    end else
    begin
      if (fZoom > 20) then Zoom := round((fZoom - 10)/10)*10 //(minimum 20%)
      else fZoomTimer.enabled := false;
    end;
    if fZoom = OldZoom then exit;
    //work out click pos relative to page (as x & y percentages)
    pt.x := (X-fPreviewSurface.left- GRAY_MARGIN)*100 div
        PrinterPxToScreenPxX(fPhysicalSizePx.x);
    pt.x := min(max(pt.x,0),100);
    pt.y := (Y-fPreviewSurface.top- GRAY_MARGIN)*100 div
      PrinterPxToScreenPxY(fPhysicalSizePx.y);
    pt.y := min(max(pt.y,0),100);
    //finally, adjust scrollbar positions based on click pos ...
    with HorzScrollbar do position := pt.x*(range-clientwidth) div 100;
    with VertScrollbar do position := pt.y*(range-clientheight) div 100;
  finally
    sendmessage(handle,WM_SETREDRAW,1,0);
  end;
  invalidate;
end;
//------------------------------------------------------------------------------

procedure TPages.ZoomTimer(Sender: TObject);
var
  CursorPos: TPoint;
begin
  GetCursorPos(CursorPos);
  CursorPos := ScreenToClient(CursorPos);
  ZoomTimerInternal(CursorPos.x,CursorPos.y, fZoomIn);
end;
//------------------------------------------------------------------------------

procedure TPages.LineInternal(start,finish: integer; DoubleLine: boolean);
var
  Y: integer;
begin
  with fCanvas do
  begin
    pen.width := muldiv(fDefaultLineWidth,self.font.size,8);
    if fsBold in self.font.style then pen.width := pen.width +1;
    if DoubleLine then
    begin
      Y := fCurrentYPos + (GetLineHeight div 2) - (pen.width);
      moveto(start,Y);
      lineto(finish,Y);
      moveto(start,Y + pen.width*2);
      lineto(finish,Y + pen.width*2);
    end else
    begin
      Y := fCurrentYPos + (GetLineHeight div 2) - (pen.width div 2);
      moveto(start,Y);
      lineto(finish,Y);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.PrintFormattedLine(s: string; flags: longint);
var
  i: integer;
  leftOffset, rightOffset: integer;
begin
  s := rtrim(s);
  i := pos(PAGENUMBER,lowercase(s));
  if i > 0 then
  begin
    delete(s,i,14);
    insert(inttostr(fVirtualPageNum),s,i);
  end;

  if flags <> FORMAT_DEFAULT then SetFontWithFlags(flags);

  if (flags and FORMAT_SINGLELINE = FORMAT_SINGLELINE) then
  begin
    CheckYPos;
    GetTextLimitsPx(leftOffset,rightOffset);
    LineInternal(leftOffset,rightOffset, false);
    newLine;
  end
  else if (flags and FORMAT_DOUBLELINE = FORMAT_DOUBLELINE) then
  begin
    CheckYPos;
    GetTextLimitsPx(leftOffset,rightOffset);
    LineInternal(leftOffset,rightOffset, true);
    newLine;
  end
  else if s = '' then
    newline
  else if (flags and FORMAT_XPOS_MASK <> 0) then
    DrawTextAt(s, (flags and FORMAT_XPOS_MASK) shr 16)
  else if (falign in  [taLeft,taJustified]) then
    LeftOrJustifiedWrap(s)
  else
    RightOrCenterWrap(s);
end;
//------------------------------------------------------------------------------

procedure TPages.LeftOrJustifiedWrap(const s: string);
var
  indent, leftOffset, rightOffset, LineWidth: integer;
  leftstring,rightstring: string;
  firstLoop: boolean;
begin
  leftstring := s;
  Indent := MmToPrinterPxX(fHangIndent);
  firstLoop := true;
  repeat
    CheckYPos;
    GetTextLimitsPx(leftOffset,rightOffset);
    LineWidth := rightOffset-leftOffset;

    //offset leftOffset if hang-indenting...
    if (Indent <> 0) then
    begin
      if firstLoop then
      begin
        firstLoop := false;
        if (Indent < 0) then
        begin
          inc(leftOffset,-Indent);
          dec(LineWidth,-Indent);
        end;
      end
      else if (Indent > 0) and (Indent < LineWidth) then
      begin
        inc(leftOffset,Indent);
        dec(LineWidth,Indent);
      end;
    end;

    //dump overrun into rightstring...
    TrimLine(fcanvas,leftstring,rightstring,LineWidth);

    //HandleTabsAndPrint: prints leftstring after adjusting for tabs and
    //prepending any further text overrun into rightstring ...
    HandleTabsAndPrint(leftstring, rightstring, leftOffset, rightOffset);
    if length(rightstring) = 0 then break;
    leftstring := rightstring;
    newline;
  until false;
  newline;
end;
//------------------------------------------------------------------------------

procedure TPages.RightOrCenterWrap(const s: string);
var
  i,leftOffset,rightOffset, LineWidth: integer;
  leftstring,rightstring: string;
  offset: integer;
begin
  //falign = either taRight OR taCentered...

  leftstring := s;
  Offset := 0; //stops a warning

  //remove tabs...
  i := pos(#9,leftstring);
  while i > 0 do
  begin
    delete(leftstring,i,1);
    insert('    ',leftstring,i);
    i := pos(#9,leftstring);
  end;

  repeat
    GetTextLimitsPx(leftOffset,rightOffset);
    LineWidth := rightOffset-leftOffset;

    TrimLine(fcanvas,leftstring,rightstring,LineWidth);
    case falign of
      taRight:   Offset := rightOffset - fcanvas.TextWidth(leftstring)-1;
      taCenter:  Offset := leftOffset +
        (rightOffset-leftOffset-fcanvas.TextWidth(leftstring)) div 2;
      else exit; //should never happen - ?? add assert
    end;
    CheckYPos;
    fcanvas.TextOut(Offset, fCurrentYPos, leftstring);
    if length(rightstring) = 0 then break;
    leftstring := rightstring;
    newline;
  until false;
  newline;
end;
//------------------------------------------------------------------------------

procedure TPages.GetTextLimitsPx(var LeftOffset, RightOffset: integer);
begin
  //Offsets (in Printer pixels) based on current page margins
  LeftOffset := fPageMarginsPx.left;
  RightOffset := fPhysicalSizePx.x-fPageMarginsPx.right;
end;
//------------------------------------------------------------------------------
  
procedure TPages.HandleTabsAndPrint(const leftstring: string;
  var rightstring: string; leftOffset, rightOffset: integer);
const
  //if a tabstop is very close to the right margin, it may spoil justifying...
  MIN_CHAR_WIDTH_PX = 5;
var
  i, spacecount, lw, tabPos, tabIndex: integer;
  ls, rs: string;
  size: TSize;
  xtra, left, j : integer;
begin
  //handles tabs one at a time and prints text into the available space...
  //(unfortunately there's no equivalent GetTextExtentExPoint() for tabbed text
  //and using GetTabbedTextExtent() and TabbedDrawText() instead would appear
  //to be undesirable as there's no efficient way to determine the number of
  //chars that will fit within the specified space.)
  ls := leftstring;
  lw := rightOffset - leftOffset; //linewidth
  tabPos := pos(#9,ls);

  while tabPos > 0 do //and still room to print
  begin
    //split line at the tab ...
    if rs <> '' then
        rs := copy(ls,tabPos+1,length(ls)) + ' '+ rs else
        rs := copy(ls,tabPos+1,length(ls));
    //add a trailing space so next the tabstop is at least one space away ...
    ls := copy(ls,1,tabPos-1)+' ';
    //get offset of next tabstop ...
    {$ifndef UTF8}
    GetTextExtentPoint32(fcanvas.handle,pchar(ls),tabPos,size);
    {$else}
    GetTextExtentPoint32W(fcanvas.handle,pwidechar(UTF8Decode(ls)),tabPos,size);
    {$endif}
    i := leftOffset + size.cx; //minimum pos for next tabstop
    tabIndex := 0;
    while tabIndex < MAXTABS do
      if fTab[tabIndex] > i then
        break
      else
        inc(tabIndex);
    if (tabIndex = MAXTABS) or
      (fTab[tabIndex] >= rightOffset - MIN_CHAR_WIDTH_PX) then
    begin
      //no tabstop found to align 'rs' to, so ...
      //rather than left aligning 'ls', remove its appended space and
      //break out ready to print it ? align left&right justified.
      setLength(ls,length(ls)-1);
      break;
    end;
    //tabstop found so DrawText 'ls' simply left aligned ...
    fcanvas.TextOut(leftOffset, fCurrentYPos, ls);
    leftOffset := fTab[tabIndex];
    lw := rightOffset - leftOffset;
    ls := rs;
    TrimLine(fcanvas,ls,rs,lw);
    tabPos := pos(#9,ls);
  end;
  if rs <> '' then
    rightstring := rs + ' '+ rightstring;

  //OK, no TABS now in ls...
  //print ls into (remaining) linewidth at (leftOffset, fCurrentYPos)
  if (falign = taLeft) or (rightstring = '') then
    fcanvas.TextOut(leftOffset, fCurrentYPos, ls)
  else
  begin
    spacecount := 0;
    for i := 1 to length(ls) do if ls[i] = ' ' then inc(spacecount);
    try
      {$ifndef UTF8}
      GetTextExtentPoint32(fcanvas.handle,pchar(ls),length(ls),size);
      {$else}
      GetTextExtentPoint32W(fcanvas.handle,pwidechar(UTF8Decode(ls)),length(ls),size);
      {$endif}
    except
      spacecount := 0 //GAL: ignore error and consider there is no spaces
    end;
    {
    if (spacecount > 0) then
      SetTextJustification(fcanvas.handle, lw - size.cx, spacecount);
    fcanvas.TextOut(leftOffset,fCurrentYPos, ls);
    SetTextJustification(fcanvas.handle,0,0);
    }
    xtra := 0;
    left := 0;
    if spacecount > 0 then
      begin
        xtra := (lw - size.cx) div spacecount;
        left := (lw - size.cx) mod spacecount
      end;
    i    := 1;
    repeat
       j := PosEx (' ', ls, i);
       if j = 0 then
         begin
            fcanvas.TextOut(leftOffset,fCurrentYPos, copy (ls, i, length (ls)));
            break
         end;
       fcanvas.TextOut(leftOffset,fCurrentYPos, copy (ls, i, j - i + 1));
       leftOffset := fCanvas.PenPos.x + xtra;
       if left <> 0 then inc (leftOffset);
       if left <> 0 then dec (left);
       i := j + 1
    until false
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.PreviewPaint(Sender: TObject);
var
  r: TRect;
begin
  with fPreviewSurface do
  begin
    //paint the preview surface background gray ...
    //note: this is the page surface including the GRAY_MARGIN area
    canvas.brush.color := self.color;
    canvas.FillRect(r);

    //paint the page white with a dark gray line around it...
    r := clientrect;
    inflaterect(r,-GRAY_MARGIN,-GRAY_MARGIN);
    canvas.brush.color := clWhite;
    canvas.pen.width := 1;
    canvas.pen.color := clGray;
    with r do
      canvas.Rectangle(left,top,right,bottom);
    //draw the metafile on the page...
    if PageCount > 0 then
      Canvas.StretchDraw(r,TMetaFile(fPages[fCurrPreviewPage-1]));
    //draw the page shadows...
    r.Top := GRAY_MARGIN+3;
    r.Left := ClientWidth-GRAY_MARGIN;
    r.Bottom := ClientHeight-GRAY_MARGIN+3;
    r.Right := r.Left+3;
    canvas.brush.color := clGray;
    canvas.FillRect(r);

    r.Top := ClientHeight-GRAY_MARGIN;
    r.Left := GRAY_MARGIN+3;
    r.Bottom := r.Top+3;
    r.Right := ClientWidth-GRAY_MARGIN+3;
    canvas.brush.color := clGray;
    canvas.FillRect(r);
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.PreviewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //pass the TPaintbox mouse-down event messages to self (TScrollBox) ...
  MouseDown(Button,Shift,X+fPreviewSurface.left,Y+fPreviewSurface.Top);
end;
//------------------------------------------------------------------------------

procedure TPages.PreviewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //pass the TPaintbox mouse-up event messages to self (TScrollBox) ...
  MouseUp(Button,Shift,X+fPreviewSurface.left,Y+fPreviewSurface.Top);
end;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TPages methods (protected)...
//------------------------------------------------------------------------------

procedure TPages.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  if assigned(fCanvas) then UpdateMetafileCanvasFont;
  fLineHeight := 0; //force recalculation of lineheight
end;
//------------------------------------------------------------------------------

procedure TPages.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;
//------------------------------------------------------------------------------

procedure TPages.KeyDown(var Key: Word; Shift: TShiftState);

  procedure SetPageAndPosition(newpage,newpos: integer);
  begin
    perform(WM_SETREDRAW,0,0);
    Page := newpage;
    VertScrollbar.position := newpos;
    perform(WM_SETREDRAW,1,0);
    refresh;
  end;

var
  OldPosition,lh: integer;
begin
  lh := PrinterPxToScreenPxY(GetLineHeight);
  if Key = vk_down then
    with VertScrollbar do
    begin
      OldPosition := Position;
      position := position + lh;
      if (Position = OldPosition) and (Page < PageCount) then
        SetPageAndPosition(Page+1,0);
    end
  else if Key = vk_up then
    with VertScrollbar do
    begin
      OldPosition := Position;
      position := position - lh;
      if (Position = OldPosition) and (Page > 1) then
        SetPageAndPosition(Page-1,range);
    end
  else if Key = vk_right then
    with HorzScrollbar do position := position + max(lh,0)
  else if Key = vk_left then
    with HorzScrollbar do position := position - min(lh,range)
  else if Key = vk_next then
    with VertScrollbar do
    begin
      if (shift = [ssCtrl]) and (Page < PageCount) then
        SetPageAndPosition(PageCount,0)
      else
      begin
        OldPosition := Position;
        position := position + max(clientheight - lh,0);
        if (Position = OldPosition) and (Page < PageCount) then
          SetPageAndPosition(Page+1,0);
      end;
    end
  else if Key = vk_prior then
    with VertScrollbar do
    begin
      if (shift = [ssCtrl]) and (Page > 1) then
          SetPageAndPosition(1,0)
      else
      begin
        OldPosition := Position;
        position := position - max(clientheight-lh,0);
        if (Position = OldPosition) and (Page > 1) then
          SetPageAndPosition(Page-1,range);
      end;
  end;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TPages.CreateWnd;
begin
  inherited CreateWnd;
  //force page repositioning  +/-resizing
  case ZoomStatus of
    zsPercent: ResizeAndCenterPaintbox;
    zsWidth: zoom := PAGE_WIDTH;
    else zoom := PAGE_FIT;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.Resize;
begin
  //force page repositioning  +/-resizing
  case ZoomStatus of
    zsPercent: ResizeAndCenterPaintbox;
    zsWidth: zoom := PAGE_WIDTH;
    else zoom := PAGE_FIT;
  end;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TPages.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //allow overriding of default mouse handling...
  if not assigned(OnMouseDown) then
  begin
    fZoomIn := (Button = mbLeft);
    ZoomTimerInternal(X, Y, fZoomIn);
    fZoomTimer.Enabled := true;
  end;
  if canfocus and not focused then Setfocus;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TPages.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  fZoomTimer.enabled := false;
  inherited;
end;
//------------------------------------------------------------------------------

{$IFNDEF VER100}
function TPages.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean;
var
  key: word;
begin
  //treat mousewheel events as if a down-arrow or up-arrow event ...
  if WheelDelta < 0 then key := VK_DOWN else key := VK_UP;
  KeyDown(Key,[]);
  Result:= true;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// TPages methods (public)...
//------------------------------------------------------------------------------

constructor TPages.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  Height := 150;
  width := 200;
  ControlStyle := ControlStyle - [csAcceptsControls];
  color := (AOwner as TCustomForm).color;
  HorzScrollBar.Tracking:=True;
  VertScrollBar.Tracking:=True;
  tabstop := true;

  font.name := 'Courier New';
  font.size := 12;
  fLineSpacing := lsSingle;
  fCurrPreviewPage := 0;
  fOrientation := poPortrait;

  fPages := TList.create;
  fHeaderLines := TStringList.Create;
  fFooterLines := TStringList.Create;
  fColumns := TList.create;
  fColumnHeaderList := TStringList.create;

  fZoomTimer := TTimer.create(self);
  fZoomTimer.Interval := 200;
  fZoomTimer.OnTimer := ZoomTimer;
  fZoomTimer.enabled := false;

  fHasPrinterInstalled :=
    not (csDesigning in componentState) and PrinterDriverExists;
  GetPrinterParams; //necessary, but will also be updated in BeginDoc().
  fCanvas := nil;
  fPreviewSurface := TPaintbox.Create(self);
  fPreviewSurface.parent := self;
  fPreviewSurface.OnPaint := PreviewPaint;
  fPreviewSurface.OnMouseDown := PreviewMouseDown;
  fPreviewSurface.OnMouseUp := PreviewMouseUp;
  fZoomStatus := zsPercent;
  fZoom := 100;
end;
//------------------------------------------------------------------------------

destructor TPages.Destroy;
begin
  Clear;
  fPages.free;
  fHeaderLines.free;
  fFooterLines.free;
  fColumns.free;
  fColumnHeaderList.free;
  fPreviewSurface.free;
  fZoomTimer.free;
  inherited Destroy;
end;
//------------------------------------------------------------------------------

procedure TPages.BeginDoc;
begin
  Clear;
  GetPrinterParams; //essential as Printers.printer object may have changed

  fHangIndent := 0;
  fAlign := taLeft;
  SetPageMargins(Rect(10,10,10,10));
  fVirtualPageNum := 0;

  application.processmessages;
  NewPageInternal;  //create a blank page

  //preview resize in case Printers.printer object has changed
  case ZoomStatus of
    zsPercent: zoom := fzoom;
    zsWidth: zoom := PAGE_WIDTH;
    else zoom := PAGE_FIT;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.DrawText(const s: string);
var
  P, Start: PChar;
  tmpStr: string;
begin
  CheckYPos;
  if s = '' then
    newline
  else
  begin
   //manages newline characters in 's' ...
   P := Pointer(s);
   while P^ <> #0 do
   begin
     Start := P;
     while not (P^ in [#0, #10, #13]) do Inc(P);
     SetString(tmpStr, Start, P - Start);
     PrintFormattedLine(tmpStr, FORMAT_DEFAULT);
     if P^ = #13 then Inc(P);
     if P^ = #10 then Inc(P);
   end;
  end;
end;
//------------------------------------------------------------------------------
procedure TPages.DrawTextAt(s: string; XPos: integer);
var
  i: integer;
begin
  if length(s) = 0 then exit;
  CheckYPos;
  XPos := MmToPrinterPxX(XPos);

  i := pos(PAGENUMBER,lowercase(s));
  if i > 0 then
  begin
    delete(s,i,14);
    insert(inttostr(fVirtualPageNum),s,i);
  end;

  //will print either to the left or right or Xpos ...
  with fcanvas do
    case falign of
      taRight: TextOut(XPos-TextWidth(s)-1, fCurrentYPos, s);
      else TextOut(XPos, fCurrentYPos, s);
    end;
end;
//------------------------------------------------------------------------------

procedure TPages.DrawAngledTextAt(const s: string; XPos, Angle: integer);
var
  lf: TLogFont;
  OldFontHdl,NewFontHdl: HFont;
begin
  if length(s) = 0 then exit;
  CheckYPos;
  XPos := MmToPrinterPxX(XPos);
  with fcanvas do
  begin
    if GetObject(Font.Handle, SizeOf(lf), @lf) = 0 then exit;
    lf.lfEscapement := Angle * 10;
    lf.lfOrientation := Angle * 10;
    lf.lfOutPrecision := OUT_TT_ONLY_PRECIS;
    NewFontHdl := CreateFontIndirect(lf);
    OldFontHdl := selectObject(handle,NewFontHdl);
    TextOut(XPos, fCurrentYPos, s);
    selectObject(handle,OldFontHdl);
    DeleteObject(NewFontHdl);
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.DrawBox(left,top,right,bottom: integer);
begin
  if not fHeaderDone then DoHeader;
  left := MmToPrinterPxX(left);
  top := MmToPrinterPxY(top);
  right := MmToPrinterPxX(right);
  bottom := MmToPrinterPxY(bottom);
  with fCanvas do
  begin
    pen.width := muldiv(fDefaultLineWidth,self.font.size,8);
    if fsBold in self.font.style then pen.width := pen.width +1;
    moveto(left,top);
    lineto(right,top);
    lineto(right,bottom);
    lineto(left,bottom);
    lineto(left,top);
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.DrawBMP(rec: TRect; bmp: TBitmap);
begin
  if not fHeaderDone then DoHeader;
  with rec do
  begin
    left := MmToPrinterPxX(left);
    top := MmToPrinterPxY(top);
    right := MmToPrinterPxX(right);
    bottom := MmToPrinterPxY(bottom);
  end;
  PrintBitmap(fCanvas, rec, bmp);
end;
//------------------------------------------------------------------------------

procedure TPages.DrawMeta(rec: TRect; mf: TMetafile);
begin
  if not fHeaderDone then DoHeader;
  with rec do
  begin
    left := MmToPrinterPxX(left);
    top := MmToPrinterPxY(top);
    right := MmToPrinterPxX(right);
    bottom := MmToPrinterPxY(bottom);
  end;
  PrintMetafile(fCanvas, rec, mf);
end;
//------------------------------------------------------------------------------

procedure TPages.DrawArrow(Point1, Point2: TPoint;
      HeadSize: integer; SolidHead: boolean);
begin
  if not fHeaderDone then DoHeader;
  Point1.X := MmToPrinterPxX(Point1.X);
  Point1.Y := MmToPrinterPxY(Point1.Y);
  Point2.X := MmToPrinterPxX(Point2.X);
  Point2.Y := MmToPrinterPxY(Point2.Y);
  HeadSize := MmToPrinterPxX(max(HeadSize,0));
  fCanvas.pen.width := muldiv(fDefaultLineWidth,self.font.size, 8);
  DrawArrowInternal(fCanvas, Point1, Point2, HeadSize, SolidHead);
end;
//------------------------------------------------------------------------------

procedure TPages.DrawLine(doubleline: boolean);
begin
  if not fHeaderDone then DoHeader;
  LineInternal(fPageMarginsPx.left,
    fPhysicalSizePx.x-fPageMarginsPx.right, doubleline);
  newLine;
end;
//------------------------------------------------------------------------------

procedure TPages.NewLine;
begin
  if not fHeaderDone then DoHeader;
  inc(fCurrentYPos, GetLineHeight);
end;
//------------------------------------------------------------------------------

procedure TPages.NewLines(count: integer);
begin
  //if count < 1 then exit;
  if not fHeaderDone then DoHeader;
  inc(fCurrentYPos, GetLineHeight* count);
end;
//------------------------------------------------------------------------------

procedure TPages.NewPage;
begin
  if assigned(fGroupPage) then
    raise Exception.Create('Cannot call NewPage within a group block.');
  if not fHeaderDone then DoHeader;
  NewPageInternal;
end;
//------------------------------------------------------------------------------

procedure TPages.BeginGroup;
begin
  if not fHeaderDone then DoHeader;

  if assigned(fGroupPage) then
    raise Exception.create('Group already started!');

  //make sure there's room for at least 2 lines otherwise just start a new page
  //(a group surely contains at least 2 lines )
  if not HasSpaceForLines(2) then
  begin
    NewPageInternal;
    exit;
  end;

  fGroupVerticalSpace :=
    fPhysicalSizePx.y - fCurrentYPos - fPageMarginsPx.bottom - fFooterHeight;

  fColumnsUsedInGroup := false;
  fColumnHeaderInGroup := false;
  if assigned(fCanvas) then FreeAndNil(fCanvas);
  fGroupPage := TMetafile.Create;
  CreateMetafileCanvas(fGroupPage);
  fGroupPage.Width := fPhysicalSizePx.x;
  fGroupPage.Height := fGroupVerticalSpace + fPhysicalOffsetPx.Y; //for safety
  fGroupVerticalPos := fCurrentYPos;
  fCurrentYPos := 0;
end;
//------------------------------------------------------------------------------

procedure TPages.EndGroup;
begin
  if not assigned(fGroupPage) then exit;
  FreeAndNil(fCanvas); //closes fGroupPage canvas
  CreateMetafileCanvas(fPages[fPages.count-1]);
  fCanvas.draw(0,0,fPages[fPages.count-1]);     //re-draw the last page
  fCanvas.draw(0,fGroupVerticalPos,fGroupPage); //add the Group data
  FreeAndNil(fGroupPage);                       //destroy Group metafile
  inc(fCurrentYPos,fGroupVerticalPos);
end;
//------------------------------------------------------------------------------

procedure TPages.EndDoc;
begin
  DoFooter;
  if assigned(fCanvas) then FreeAndNil(fCanvas);

  //cancel the last page if it hasn't been started ...
  if (fPages.Count > 1) and not fHeaderDone then
  begin
    TMetafile(fPages[fPages.count -1]).free;
    fPages.Delete(fPages.count -1);
  end;

  //OK, all Metafile pages have now been created and added to fPages.
  fCurrPreviewPage := 1;
  if assigned(fPreviewPageChangedEvent)
    then fPreviewPageChangedEvent(self);
  invalidate;
end;
//------------------------------------------------------------------------------

procedure TPages.PrintPages(PrintFrom, PrintTo: integer);
var
  i: integer;
  CheckCurrentPtr: string;
  UseStretchDraw: boolean;
begin
  if not fHasPrinterInstalled then
    raise Exception.Create('No printer driver is currently installed.');

  //ideally, the user has changed printers BEFORE generating a report, but
  //if they want a report sent to a different printer then use StretchDraw ...
  CheckCurrentPtr := CurrentPrinterName;
  if CheckCurrentPtr <> fCurrentPrinter then
  begin
    GetPrinterParams;                        //also updates fCurrentPrinter
    UseStretchDraw := true;
  end
  else
    UseStretchDraw := false;

  PrintFrom := max(PrintFrom-1,0);
  if PrintTo = 0 then PrintTo := fPages.count-1
  else PrintTo := min(PrintTo-1,fPages.count-1);

  with printer do
  begin
    Title := application.Title + ' document';
    Orientation := self.Orientation; //just in case fPrinter changed
    BeginDoc;
    for i := PrintFrom to PrintTo do
    begin
      //nb: the printer's page origin is fPhysicalOffsetPx so it's
      //    necessary to offset our rect by -fPhysicalOffsetPx ...
      if UseStretchDraw then
        Canvas.StretchDraw(Rect(-fPhysicalOffsetPx.x,-fPhysicalOffsetPx.y,
          fPhysicalSizePx.x-fPhysicalOffsetPx.x,
            fPhysicalSizePx.y-fPhysicalOffsetPx.y), fPages[i])
      else
        Canvas.Draw(-fPhysicalOffsetPx.x,-fPhysicalOffsetPx.y,fPages[i]);
      if i < PrintTo then printer.NewPage;
    end;
    EndDoc;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.SetTabStops(tabs: array of integer);
var
  i: integer;
begin
  for i := 0 to MAXTABS-1 do fTab[i] := 0;
  fTabCount := min(high(tabs)+1,MAXTABS);
  //ignore trailing 0 tabs in array ...
  if (fTabCount > 0) then
    while (fTabCount > 0) and (tabs[fTabCount-1] = 0) do dec(fTabCount);

  if (fTabCount > 1) then
  begin
    if (tabs[0] <= 0) then
      raise Exception.Create('Tabs stops must be greater than 0.');
    fTab[0] := MmToPrinterPxX(tabs[0]);
    for i := 1 to fTabCount -1 do
      if tabs[i] > tabs[i-1] then
        fTab[i] := MmToPrinterPxX(tabs[i]) else
        raise Exception.Create('Tabs stops must be in ascending order');
  end
  else if fTabCount = 1 then
  begin
    //if one tab set then use that tab as the interval for subsequent tabs
    for i := 0 to MAXTABS-1 do
      fTab[i] := MmToPrinterPxX((i+1)*tabs[0]);
    fTabCount := MAXTABS;
  end else
  begin
    //if no tabs set then default to tabs every 20mm
    for i := 0 to MAXTABS-1 do fTab[i] := MmToPrinterPxX((i+1)*20);
    fTabCount := MAXTABS;
  end;
end;
//------------------------------------------------------------------------------

function TPages.GetPageMargins: TRect;
begin
  with result do
  begin
    Left := PrinterPxToMmX(fPageMarginsPx.left);
    Top := PrinterPxToMmY(fPageMarginsPx.top);
    Right := PrinterPxToMmX(fPageMarginsPx.right);
    Bottom := PrinterPxToMmY(fPageMarginsPx.bottom);
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.SetPageMargins(Rect: TRect);
begin
  with fPageMarginsPx do
  begin
    Top := MmToPrinterPxY(Rect.top);
    Bottom := MmToPrinterPxY(Rect.bottom);
    Left := MmToPrinterPxX(Rect.left);
    Right := MmToPrinterPxX(Rect.right);
  end;
  if not fHeaderDone then fCurrentYPos := fPageMarginsPx.top;
end;
//------------------------------------------------------------------------------

function TPages.GetPaperSize: TSize;
begin
  //result.cx := mulDiv(fPhysicalSizePx.X, 254,fPrinterPxPerInch.x *10);
  //result.cy := mulDiv(fPhysicalSizePx.Y, 254,fPrinterPxPerInch.y *10);
  result.cx := 210;
  result.cy := 297;
end;
//------------------------------------------------------------------------------

procedure TPages.AddLineToHeader(doubleline: boolean);
var
  HdrFtrRec: PHdrFtrRec;
begin
  new(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    format := TextFormatsToFlags;
    LeftMargin := fPageMarginsPx.left;
    RightMargin := fPageMarginsPx.right;
    FontName := font.Name;
    if doubleline then
      format := format or FORMAT_DOUBLELINE else
      format := format or FORMAT_SINGLELINE;
    fHeaderLines.addobject('',pointer(HdrFtrRec));
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.AddLineToFooter(doubleline: boolean);
var
  HdrFtrRec: PHdrFtrRec;
begin
  if fFooterLines.count = 0 then CalcFooterGap;
  new(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    format := TextFormatsToFlags;
    LeftMargin := fPageMarginsPx.left;
    RightMargin := fPageMarginsPx.right;
    FontName := font.Name;
    if doubleline then
      format := format or FORMAT_DOUBLELINE else
      format := format or FORMAT_SINGLELINE;
  end;
  fFooterLines.addobject('',pointer(HdrFtrRec));
  inc(fFooterHeight, GetLineHeight);
end;
//------------------------------------------------------------------------------

procedure TPages.AddTextToHeader(const s: string);
var
  HdrFtrRec: PHdrFtrRec;
begin
  New(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    format := TextFormatsToFlags;
    LeftMargin := fPageMarginsPx.Left;
    RightMargin := fPageMarginsPx.Right;
    FontName := font.name;
    fHeaderLines.addobject(s, pointer(HdrFtrRec));
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.AddTextToHeaderAt(const s: string; XPos: integer);
var
  HdrFtrRec: PHdrFtrRec;
begin
  //todo - can't print at 0mm from left edge so raise exception

  New(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    Format := TextFormatsToFlags;
    Format := Format or (XPos shl 16);
    LeftMargin := fPageMarginsPx.Left;
    RightMargin := fPageMarginsPx.Right;
    FontName := font.name;
    fHeaderLines.addobject(s,pointer(HdrFtrRec));
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.AddTextToFooter(const s: string);
var
  HdrFtrRec: PHdrFtrRec;
begin
  if fFooterLines.count = 0 then CalcFooterGap;
  New(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    Format := TextFormatsToFlags;
    LeftMargin := fPageMarginsPx.Left;
    RightMargin := fPageMarginsPx.Right;
    FontName := font.name;
    fFooterLines.addobject(s,pointer(HdrFtrRec));
  end;
  inc(fFooterHeight, GetLineHeight);
end;
//------------------------------------------------------------------------------

procedure TPages.AddTextToFooterAt(const s: string; XPos: integer);
var
  FlagPos: longint;
  HdrFtrRec: PHdrFtrRec;
begin
  //todo - can't print at 0mm from left edge so raise exception
  if fFooterLines.count = 0 then CalcFooterGap;
  New(HdrFtrRec);
  with HdrFtrRec^ do
  begin
    Format := TextFormatsToFlags;
    LeftMargin := fPageMarginsPx.Left;
    RightMargin := fPageMarginsPx.Right;
    FontName := font.name;
    FlagPos := XPos shl 16;
    Format := Format or FlagPos;
    fFooterLines.addobject(s,pointer(HdrFtrRec));
  end;
end;
//------------------------------------------------------------------------------

function TPages.GetColumnCount: integer;
begin
  result := fColumns.count;
end;
//------------------------------------------------------------------------------

function TPages.GetColumnInfo(index: integer): TColRec;
begin
  if (index < 0) or (index >= fColumns.count) then
    raise Exception.create('GetColumnInfo: index out of range');
  with PColRec(fColumns[index])^ do
  begin
    result.ColLeft := PrinterPxToMmX(ColLeft);
    result.ColRight := PrinterPxToMmX(ColRight);
    result.ColAlign := ColAlign;
  end;
end;
//------------------------------------------------------------------------------

procedure TPages.AddColumn(left, right: integer; align: TColAlign);
var
  cr: PColRec;
begin
  left := MmToPrinterPxX(left);
  right := MmToPrinterPxX(right);

  with fColumns do
    if (Count > 0) and (left < PColRec(fColumns[Count-1]).ColRight) then
      raise Exception.create('Columns overlap!');
  new(cr);
  with cr^ do
  begin
    ColLeft := left;
    ColRight := right;
    ColAlign := align;
  end;
  fColumns.add(cr);
end;
//------------------------------------------------------------------------------

procedure TPages.AddColumnHeaders(headers: array of string);
var
  i,flags: integer;
  zStr: TZStrings;
begin
  flags := TextFormatsToFlags;
  zStr := '';
  for i := Low(headers) to High(headers) do
    zStr := zStr + headers[i]+#0;
  fColumnHeaderList.addobject(zStr,pointer(flags));  
  fColumnHeaderPrinted := false;
end;
//---------------------------------------------------------------------

procedure TPages.DrawTextAcrossCols(StringArray: Array of string);
var
  i,lh: integer;
  ColRec: TColRec;
  s: string;
begin
  CheckYPos;
  if (fColumnHeaderList.count > 0) and not fColumnHeaderPrinted then
  begin
    i := fColumnHeaderList.count + 2;
    if not HasSpaceForLines(i) then
      NewPageInternal;
    PrintColumnHeaders;
  end;
  if assigned(fGroupPage) then fColumnsUsedInGroup := true;

  lh := GetLineHeight;
  for i := 0 to High(StringArray) do
  begin
    if i >= fColumns.Count then break
    else if (StringArray[i] = '') then continue; //nothing to print in this col.
    ColRec := GetColumnRec(i);
    with ColRec, fCanvas do
    begin
      //it's possible earlier col text may show *between* later cols, so ...
      fillRect(rect(ColLeft,fCurrentYPos,fPhysicalSizePx.x,fCurrentYPos+lh));
      case ColAlign of
        caLeft:
          textrect(rect(ColLeft,fCurrentYPos,
            fPhysicalSizePx.X-fPageMarginsPx.right,
            fCurrentYPos+lh), ColLeft,fCurrentYPos,StringArray[i]);
        caRight:
          //-1 added to fix a bug while printing (not previewing) where
          //the last character is often chopped ...
          textrect(rect(ColLeft,fCurrentYPos,ColRight,fCurrentYPos+lh),
            ColRight-TextWidth(StringArray[i])-1,fCurrentYPos,StringArray[i]);
        caCenter:
          textrect(rect(ColLeft,fCurrentYPos,ColRight,fCurrentYPos+lh),
            ColLeft + ((ColRight - ColLeft + 1) - TextWidth(StringArray[i])) div 2,
            fCurrentYPos,StringArray[i]);
        caCurrency:
          begin
            s := StringArray[i];
            if fNegsToParenthesesInCurrCols then
              s := ConvertNegsToParentheses(s);
            //ignore parentheses when aligning currency values ...
            if (s[length(s)] = ')') then
              textrect(rect(ColLeft, fCurrentYPos, ColRight+TextWidth(')'),
                fCurrentYPos+lh),
                ColRight-TextWidth(s)+TextWidth(')')-1, fCurrentYPos,s)
            else
              textrect(rect(ColLeft,fCurrentYPos,ColRight,fCurrentYPos+lh),
                ColRight-TextWidth(s)-1, fCurrentYPos,s);
          end;
      end;
    end;
  end;
  newline;
end;
//------------------------------------------------------------------------------

procedure TPages.DrawLinesAcrossCols(StringArray: array of string);
var
  LeftArray: array of string;
  NoMore: boolean;
  i, k: integer;
  sl, sr : string;
begin
  SetLength(LeftArray,length(StringArray));
  repeat
    NoMore := True;
    for i := 0 to High(StringArray) do
    begin
      if i >= fColumns.Count then break;
      LeftArray[i] := StringArray[i];
      with GetColumnRec(i) do
        begin
          Leftarray[i] := Trim (Leftarray[i]);
          k := Pos (#13#10, Leftarray[i]);
          if k = 0
            then begin
              sl := Leftarray[i];
              sr := '';
              StringArray[i] := ''
            end
            else begin
              sl := copy (Leftarray[i], 1, k - 1);
              sr := '';
              StringArray[i] := copy (Leftarray[i], k, length (Leftarray[i]))
            end;
          TrimLine(fCanvas,sl,sr,ColRight - ColLeft + 1);
          Leftarray[i] := sl;
          StringArray[i] := sr + StringArray[i]
        end;
      if StringArray[i] <> '' then NoMore := False;
    end;
    DrawTextAcrossCols (LeftArray);
  until NoMore
end;
//------------------------------------------------------------------------------

procedure TPages.DrawLinesInCurrencyCols(doublelines: boolean);
var
  i: integer;
  ColRec: TColRec;
begin
  CheckYPos;

  if (fColumnHeaderList.count > 0) and not fColumnHeaderPrinted then
  begin
    i := fColumnHeaderList.count + 2;
    if not HasSpaceForLines(i) then
      NewPageInternal;
    PrintColumnHeaders;
  end;

  for i := 0 to fColumns.Count-1 do
  begin
    if i >= fColumns.Count then exit;
    ColRec := GetColumnRec(i);
    with ColRec do
      if ColAlign = caCurrency then
        LineInternal(ColLeft, ColRight, doublelines);
  end;
  newline;
end;
//------------------------------------------------------------------------------

procedure TPages.ColumnHeadersNeeded;
begin
  fColumnHeaderPrinted := false;
end;
//------------------------------------------------------------------------------

procedure TPages.Clear;
var
  i: integer;
begin
  if assigned(fCanvas) then FreeAndNil(fCanvas);
  if assigned(fGroupPage) then FreeAndNil(fGroupPage);
  for i := 0 to fPages.count -1 do TMetafile(fPages[i]).free;
  fPages.clear;
  ClearHeaders;
  ClearFooters;
  ClearColumns;
  SetTabStops([20]);
end;
//------------------------------------------------------------------------------

procedure TPages.ClearHeaders;
var
  i: integer;
begin
  for i := 0 to fHeaderLines.count-1 do
    dispose(PHdrFtrRec(fHeaderLines.objects[i]));
  fHeaderLines.clear;
end;
//------------------------------------------------------------------------------

procedure TPages.ClearFooters;
var
  i: integer;
begin
  for i := 0 to fFooterLines.count-1 do
    dispose(PHdrFtrRec(fFooterLines.objects[i]));
  fFooterLines.clear;
end;
//------------------------------------------------------------------------------

procedure TPages.ClearColumns;
var
  i: integer;
begin
  for i := 0 to fColumns.count-1 do Dispose(PColRec(fColumns[i]));
  fColumns.clear;
  ClearColumnHeaders;
end;
//------------------------------------------------------------------------------

procedure TPages.ClearColumnHeaders;
begin
  fColumnHeaderList.clear;
end;
//------------------------------------------------------------------------------

end.

