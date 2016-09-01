unit Preview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Pages, ComCtrls, ToolWin
  {$IFNDEF VER100}, ImgList{$ENDIF},
  TntComCtrls, TntForms;

type
  TPreviewForm = class(TTntForm)
    PrintDialog1: TPrintDialog;
    ImageList1: TImageList;
    ImageList2: TImageList;
    StatusBar1: TTntStatusBar;
    ToolBar1: TTntToolBar;
    btnFirst: TTntToolButton;
    btnPrev: TTntToolButton;
    btnNext: TTntToolButton;
    btnLast: TTntToolButton;
    ToolButton1: TToolButton;
    btnZoomIn: TTntToolButton;
    btnZoomOut: TTntToolButton;
    btnPrint: TTntToolButton;
    ToolButton3: TToolButton;
    btnClose: TTntToolButton;
    procedure BtnPrintClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Pages1PreviewPageChanged(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure Pages1ZoomChanged(Sender: TObject; Zoom: Integer;
      ZoomStatus: TZoomStatus);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    ZoomIndex: integer;
    procedure UpdateNavButtons;

  public
    Pages: TPages;
  end;

var
  fmPreview : TPreviewForm;

const
  crMagnify = 2;
  zoom: array[ 0.. 5 ] of integer = (25, 50, 75, 100, 150, 200);

implementation

{$R *.DFM}
{$R MagGlass.res}

uses
  DefineUi, Translate, TranslateVcl, Main, VclUtils;

//------------------------------------------------------------------------------
// TPreviewForm methods ...
//------------------------------------------------------------------------------

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
  Caption := AppName + ' - ' + U('Preview');

  Pages := TPages.Create(self);
  Pages.Parent := self;
  Pages.Align := alClient;
  Pages.OnPreviewPageChanged := Pages1PreviewPageChanged;
  Pages.OnZoomChanged := Pages1ZoomChanged;

  Screen.Cursors[crMagnify] := LoadCursor(HInstance, 'MGLASS');
  Pages.cursor := crMagnify;
end;

// ---------------------------------------------------------------------------

procedure TPreviewForm.FormShow(Sender: TObject);
var
  s : string;
begin
  TranslateForm(Self);

  with fmMain.IniFile do
    begin
      SetWinStrPlacement(self, ReadString('Windows', 'Preview', ''));
      //Pages.Zoom := PAGE_FIT
      Pages.Zoom := ReadInteger('Windows', 'PreviewZoom', PAGE_FIT);
    end;

  if Pages.PageCount > 1 then
  begin
    btnNext.enabled := true;
    btnLast.enabled := true;
  end;

  s := CurrentPrinterPaperSize;
  if s = ''
    then Statusbar1.Panels[2].Text := CurrentPrinterName
    else Statusbar1.Panels[2].Text := CurrentPrinterName + '  -  ' + s
end;

// ---------------------------------------------------------------------------

procedure TPreviewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with fmMain.IniFile do
    begin
      WriteString ('Windows', 'Preview', GetWinStrPlacement(self));
      WriteInteger('Windows', 'PreviewZoom', Pages.Zoom)
    end;

  Action := caFree
end;

// ---------------------------------------------------------------------------

procedure TPreviewForm.btnFirstClick(Sender: TObject);
begin
  //page navigation button pressed
  with Pages do
  begin
    //display the appropriate page ...
    perform(WM_SETREDRAW,0,0);
    if Sender = btnFirst then
      Page := 1
    else if Sender = btnPrev then
      Page := Page-1
    else if Sender = btnNext then
      Page := Page+1
    else
      Page := PageCount;
    VertScrollbar.position := 0;
    HorzScrollbar.position := 0;
    perform(WM_SETREDRAW,1,0);
    invalidate;
  end;
  UpdateNavButtons;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.btnZoomInClick(Sender: TObject);
begin
  if ZoomIndex = 5 then exit;
  inc(ZoomIndex);
  Pages.zoom := zoom[ZoomIndex];
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.btnZoomOutClick(Sender: TObject);
begin
  if ZoomIndex = 0 then exit;
  dec(ZoomIndex);
  Pages.zoom := zoom[ZoomIndex];
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.BtnPrintClick(Sender: TObject);
begin
  with PrintDialog1 do
  begin
    MinPage := 1;
    MaxPage := Pages.PageCount;
    FromPage := 1;
    ToPage := MaxPage;
    Copies := 1;
    if execute then
    begin
      screen.cursor := crHourglass;
      try
        Pages.printpages(FromPage,ToPage);
      finally
        screen.cursor := crDefault;
      end;
      close;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.BtnCloseClick(Sender: TObject);
begin
  close;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.Pages1PreviewPageChanged(Sender: TObject);
begin
  with Pages do
    Statusbar1.Panels[0].Text := '  ' + WideFormat(U('Page %d of %d'), [Page, PageCount]);
  UpdateNavButtons;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then close;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.UpdateNavButtons;
begin
  with Pages do
  begin
    if Page = 1 then
    begin
      btnFirst.enabled := false;
      btnPrev.enabled := false;
    end else
    begin
      btnFirst.enabled := true;
      btnPrev.enabled := true;
    end;
    if Page = PageCount then
    begin
      btnNext.enabled := false;
      btnLast.enabled := false;
    end else
    begin
      btnNext.enabled := true;
      btnLast.enabled := true;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TPreviewForm.Pages1ZoomChanged(Sender: TObject;
  Zoom: Integer; ZoomStatus: TZoomStatus);
begin
  if Zoom <= 25 then
    ZoomIndex := 0
  else if Zoom <= 50 then
    ZoomIndex := 1
  else if Zoom <= 75 then
    ZoomIndex := 2
  else if Zoom <= 100 then
    ZoomIndex := 3
  else if Zoom <= 150 then
    ZoomIndex := 4
  else
    ZoomIndex := 5;
  case ZoomStatus of
    zsPercent: Statusbar1.Panels[1].Text := inttostr(Zoom) +'%';
    zsFit: Statusbar1.Panels[1].Text := 'Fit';
    else Statusbar1.Panels[1].Text := 'Width';
  end;
end;

//------------------------------------------------------------------------------

end.
