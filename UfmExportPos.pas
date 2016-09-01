// ---------------------------------------------------------------------------
// -- Drago -- Export position --------------------------- UfmExportPos.pas --
// ---------------------------------------------------------------------------

unit UfmExportPos;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Types,
  Dialogs, Buttons, StdCtrls, ExtCtrls, UGoban, Spin, StrUtils, Clipbrd,
  TntForms, TntStdCtrls, SpTBXControls, SpTBXItem, SpTBXSkins,
  DefineUi, UStatus, Components, TntGrids, Grids,
  UViewBoard;

type
  TfmExportPos = class(TTntForm)
    Image: TImage;
    Bevel: TBevel;
    SaveDialog1: TSaveDialog;
    pnOption: TPanel;
    pnFormat: TPanel;
    cb1: TComboBox;
    cb4: TComboBox;
    cb3: TComboBox;
    ie1: TIntEdit;
    btClipboard: TTntButton;
    btSave: TTntButton;
    btCancel: TTntButton;
    btHelp: TTntButton;
    gbFormat: TSpTBXGroupBox;
    sbFormat: TSpeedButton;
    gbOption: TSpTBXGroupBox;
    sbOption: TSpeedButton;
    gbDim: TSpTBXGroupBox;
    ieWidth: TIntEdit;
    ieHeight: TIntEdit;
    ieDiam: TIntEdit;
    GroupBox1: TSpTBXGroupBox;
    edZone: TEdit;
    lbAsBooks: TSpTBXLabel;
    lb1: TSpTBXLabel;
    lb4: TSpTBXLabel;
    lb3: TSpTBXLabel;
    lb2: TSpTBXLabel;
    lb5: TSpTBXLabel;
    lbWidth: TSpTBXLabel;
    lbHeight: TSpTBXLabel;
    lbBoard: TSpTBXLabel;
    lbStone: TSpTBXLabel;
    lbRect: TSpTBXLabel;
    cbAsBooks: TTntComboBox;
    sg1: TTntStringGrid;
    cb2: TTntComboBox;
    rbPNG: TSpTBXRadioButton;
    rbWMF: TSpTBXRadioButton;
    rbGIF: TSpTBXRadioButton;
    rbJPG: TSpTBXRadioButton;
    rbBMP: TSpTBXRadioButton;
    rbASC: TSpTBXRadioButton;
    rbSGF: TSpTBXRadioButton;
    rbPDF: TSpTBXRadioButton;
    procedure FormShow(Sender: TObject);
    procedure btClipboardClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edZoneChange(Sender: TObject);
    procedure sbFormatClick(Sender: TObject);
    procedure rbWMFClick(Sender: TObject);
    procedure sbOptionClick(Sender: TObject);
    procedure cb1Change(Sender: TObject);
    procedure ieWidthChange(Sender: TObject);
    procedure ieHeightChange(Sender: TObject);
    procedure cbAsBooksChange(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure ieDiamChange(Sender: TObject);
  private
    bmButton : TBitmap;
    StartHeight : integer;
    procedure SetFormatIndex(i : TExportFigure);
    function  GetFormatIndex : TExportFigure;
    procedure DoZoneChange(i1, j1, i2, j2 : integer);
    procedure AdjustDiamFromDim;
    procedure AdjustDimFromDiam(i1, j1, i2, j2 : integer);
    procedure PlusMinus(button : TSpeedButton; state : integer);
    procedure ShowFormatOptions(st : TStatus);
    procedure ShowParam(st : TStatus);
    procedure ShowParamFormat(st : TStatus);
    function  SaveParam(st : TStatus) : boolean;
    procedure ExportIMG(mode    : TExportFigure;
                        imgName : string;
                        i1, j1, i2, j2, width, height : integer);
    procedure ExportASC(imgName : string; i1, j1, i2, j2 : integer);
    procedure ExportSGF(imgName : string; i1, j1, i2, j2 : integer);
    function  GetActiveView : TViewBoard;
    property  ActiveView : TViewBoard read GetActiveView;
  public
    bm : TBitmap;
    mygb : TGoban;
    class procedure Execute;
    class function IsOpen : boolean;
    procedure ShowZone(gb : TGoban; i1, j1, i2, j2 : integer);
    procedure Capture(i1, j1, i2, j2 : integer);
    procedure ShowThumb(i1, j1, i2, j2 : integer);
    procedure Translate(st : TStatus);
  end;

var
  fmExportPos: TfmExportPos;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses 
  Define, Std, WinUtils,
  UexporterIMG, Main, UMainUtil, Ux2y, UGcom, Translate,
  UGmisc, HtmlHelpAPI, UGameTree, Sgfio, UDialogs,
  UStatusMain, VclUtils, UView, UBoardViewCanvas, UBoardViewMetric,
  UImageExporterBMP,
  UImageExporterPDF,
  UImageExporterTXT,
  UImageExporterWMF;

// -- Opening ----------------------------------------------------------------

class procedure TfmExportPos.Execute;
begin
  fmExportPos := TfmExportPos.Create(Application);
  fmExportPos.Show
end;

class function TfmExportPos.IsOpen : boolean;
begin
  Result := fmExportPos <> nil
end;

// -- Helpers ----------------------------------------------------------------

function TfmExportPos.GetActiveView : TViewBoard;
begin
  assert(fmMain.ActiveView is TViewBoard);
  
  Result := fmMain.ActiveView as TViewBoard
end;

// -- Creation ---------------------------------------------------------------

procedure TfmExportPos.FormCreate(Sender: TObject);
begin
  EnableCommands(ActiveView, mdExpo);

  bm := TBitmap.Create;
  mygb := TGoban.Create;
  mygb.SetBoardView(TBoardViewCanvas.Create(bm.Canvas));

  with ActiveView do
    self.Capture(gb.iMinView, gb.jMinView, gb.iMaxView, gb.jMaxView);

  ieWidth.OnChange := ieWidthChange;
  ieHeight.OnChange := ieHeightChange;

  bmButton        := TBitmap.Create;
  bmButton.Height := 11;
  bmButton.Width  := 11;
  StartHeight     := Height;

  pnOption.Visible := False;
  pnFormat.Visible := False;

  if IsXP then
    begin
      GroupBox1.Height := GroupBox1.Height - 4;
      GroupBox1.Top    := GroupBox1.Top + 2
    end;

  gbOption.SkinType := sknWindows;
  gbDim   .SkinType := sknWindows;
  gbFormat.SkinType := sknWindows;
end;

// -- Display of the form ----------------------------------------------------

procedure TfmExportPos.FormShow(Sender: TObject);
begin
  Translate(Settings);
  SetWinStrPosition(self, StatusMain.FmExpPosPlace);

  // size according to gbFormat
  ClientWidth  := gbFormat.Left + gbFormat.Width + gbFormat.Left;
  Image.Left   := gbFormat.Left;
  Image.Width  := gbFormat.Width;
  Image.Height := Image.Width;

  pnFormat.Visible := False;
  pnOption.Visible := False;
  PlusMinus(sbFormat, +1);
  PlusMinus(sbOption, +1);

  ActiveView.SetExportPositionMode(True);

  ShowParam(Settings);
  with mygb do
    ShowThumb(iMinView, jMinView, iMaxView, jMaxView);
  with mygb do
    ShowZone(mygb, iMinView, jMinView, iMaxView, jMaxView);
end;

// -- Closing ----------------------------------------------------------------

procedure TfmExportPos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fmExportPos := nil;

  // restore commands, was started in Edit mode
  EnableCommands(ActiveView, mdEdit);

  if pnOption.Visible
    then sbOptionClick(self);
  if pnFormat.Visible
    then sbFormatClick(self);

  StatusMain.FmExpPosPlace := GetWinStrPlacement(self);

  ActiveView.SetExportPositionMode(False);
  ActiveView.gb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);

  bm.Free;
  mygb.Free;
  bmButton.Free;
  
  // correct way to free when closing
  Action := caFree
end;

procedure TfmExportPos.btCancelClick(Sender: TObject);
begin
  Close
end;

procedure TfmExportPos.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_ExpPos)
end;

// -- Translation of the form ------------------------------------------------

procedure RightJustifyLabel(lb : TLabel; right : integer); overload;
var
  w : integer;
begin
  w := lb.Canvas.TextWidth(lb.Caption);
  lb.Width := w;
  lb.Left := right - w
end;

procedure RightJustifyLabel(lb : TSpTBXLabel; right : integer); overload;
begin
  lb.Left := right - lb.Width
end;

procedure TfmExportPos.Translate(st : TStatus);
begin
  Caption             := U('Export position');
  lbRect.Caption      := U('Figure coordinates');
  gbOption.Caption    := U('Settings');
  gbDim.Caption       := U(iff(GetFormatIndex in [eiWMF, eiPDF],
                               'Dimensions (mm)',
                               'Dimensions (px)'));

  lbBoard.Caption     := U('Board');
  lbStone.Caption     := U('Stone diameter');
  lbWidth.Caption     := U('W');
  lbHeight.Caption    := U('H');
  RightJustifyLabel(lbWidth , ieWidth.Left  - 2);
  RightJustifyLabel(lbHeight, ieHeight.Left - 2);
  ShowFormatOptions(st);
  gbFormat.Caption    := U('Format');
  lbAsBooks.Caption   := U('Move numbers');
  lb2.Caption         := U('Draw edge');
  lb3.Caption         := U('Hoshis');
  lb4.Caption         := U('Black');
  lb5.Caption         := U('White');
  cbAsBooks.Items[0]  := U('As board');
  cbAsBooks.Items[1]  := U('As books');
  cbAsBooks.ItemIndex := iff(st.PrNumAsBooks, 1, 0);
  cbAsBooks.Text      := cbAsBooks.Items[cbAsBooks.ItemIndex];
  btClipboard.Caption := U('Clipboard');
  btSave.Caption      := U('Save');
  btHelp.Caption      := U('&Help');
  btCancel.Caption    := U('Close');
end;

// -- Display and saving of settings -----------------------------------------

procedure TfmExportPos.ShowParam(st : TStatus);
begin
  // format and dimensions
  SetFormatIndex(st.prExportPos);
  ieDiam.Value := st.PrExportPosDiam;

  // general settings
  cbAsBooks.ItemIndex := iff(st.PrNumAsBooks, 1, 0);

  // format selection
  ShowParamFormat(st)
end;

procedure TfmExportPos.ShowParamFormat(st : TStatus);
begin
  case st.prExportPos of
    eiJPG :
      begin
        ie1.Value      := st.prQualityJPEG;
        ie1.ReadOnly   := False
      end;
    eiRGG :
      begin
        st.AscDrawEdge := cb2.ItemIndex = 0;
        cb2.ItemIndex  := iff(st.AscDrawEdge, 0, 1);
        cb3.Text       := st.AscHoshi;
        cb4.Text       := st.AscBlackChar;
        ie1.Text       := 'O';
        ie1.ReadOnly   := True
      end
    else // nop
  end
end;

function TfmExportPos.SaveParam(st : TStatus) : boolean;
begin
  // format and dimensions
  st.prExportPos     := TExportFigure(GetFormatIndex);
  st.PrExportPosDiam := ieDiam.Value;

  // general settings
  st.PrNumAsBooks    := cbAsBooks.ItemIndex = 1;

  // format selection
  case st.prExportPos of
    eiJPG : st.prQualityJPEG := MaxMin(ie1.Value, 1, 100);
    eiRGG :
      begin
        st.AscDrawEdge  := cb2.ItemIndex = 0;
        st.AscBlackChar := cb4.Text[1];
        st.AscWhiteChar := 'O';
        st.AscHoshi     := cb3.Text[1];
      end
    else // nop
  end;

  Result := True
end;

// -- Display of coordinates -------------------------------------------------

procedure TfmExportPos.ShowZone(gb : TGoban; i1, j1, i2, j2 : integer);
begin
  SortPair(i2, i1);
  SortPair(j1, j2);

  edZone.OnChange := nil;

  if gb.BoardView.CoordStyle = tcSGF
    then edZone.Text := ij2sgf(i2, j1) + ':' +
                        ij2sgf(i1, j2)
    else edZone.Text := ij2kor(i1, j1, gb.BoardSize) + ':' +
                        ij2kor(i2, j2, gb.BoardSize);

  edZone.OnChange := edZoneChange;

  DoZoneChange(i1, j1, i2, j2)
end;

procedure TfmExportPos.DoZoneChange(i1, j1, i2, j2 : integer);
begin
  ieWidth.OnChange  := nil;
  ieHeight.OnChange := nil;

  AdjustDimFromDiam(i1, j1, i2, j2);

  ieWidth.OnChange  := ieWidthChange;
  ieHeight.OnChange := ieHeightChange
end;

// -- Display of thumbnail ---------------------------------------------------

procedure TfmExportPos.ShowThumb(i1, j1, i2, j2 : integer);
var
  bitmap : TBitmap;
begin
  SortPair(i1, i2);
  SortPair(j1, j2);

  mygb.SetView(i1, j1, i2, j2);
  //Image.Width  := 205; // use design width
  Image.Width  := gbFormat.Width;
  Image.Height := Image.Width;
  bitmap := Image.Picture.Bitmap;
  (mygb.BoardView as TBoardViewMetric).StoneStyle := 0;
  ExportBoardToBMP(mygb, bitmap, Image.Width, Image.Height);
  Image.Top    := (Self.ClientWidth - bitmap.Height) div 2;
  Image.Left   := (Self.ClientWidth - bitmap.Width ) div 2;
  Image.Width  := bitmap.Width;
  Image.Height := bitmap.Height;
  Bevel.Top    := Image.Top    - 2;
  Bevel.Left   := Image.Left   - 2;
  Bevel.Width  := Image.Width  + 4;
  Bevel.Height := Image.Height + 4;

  //edZoneChange(self)
  DoZoneChange(i1, j1, i2, j2)
end;

// -- Capture of thumbnail ---------------------------------------------------

procedure TfmExportPos.Capture(i1, j1, i2, j2 : integer);
begin
  // update window goban with active goban parameters
  mygb.Assign(ActiveView.gb);

  // override ShowMoveMode with with global settings
  if Settings.PrNumAsBooks
    then mygb.ShowMoveMode := smBook
    else mygb.ShowMoveMode := Settings.ShowMoveMode;
    
  ShowThumb(i1, j1, i2, j2)
end;

// -- Save button ------------------------------------------------------------

procedure TfmExportPos.btSaveClick(Sender: TObject);
var
  mode : TExportFigure;
  ext, fileName : WideString;
begin
  if not SaveParam(Settings)
    then exit;
  mode := GetFormatIndex;

  case mode of
    eiGIF : ext := U('GIF files')   + ' (*.gif)|*.gif';
    eiPNG : ext := U('PNG files')   + ' (*.png)|*.png';
    eiJPG : ext := U('JPEG files')  + ' (*.jpg)|*.jpg';
    eiBMP : ext := U('BMP files')   + ' (*.bmp)|*.bmp';
    eiRGG : ext := U('ASCII files') + ' (*.txt)|*.txt';
    eiSSL : ext := U('ASCII files') + ' (*.txt)|*.txt';
    eiWMF : ext := U('WMF files')   + ' (*.wmf)|*.wmf';
    eiSGF : ext := U('SGF files')   + ' (*.sgf)|*.sgf';
    eiPDF : ext := U('PDF files')   + ' (*.pdf)|*.pdf';
  end;

  if SaveDialog('Save as',
                '',
                '',
                RightStr(ext, 3),
                ext,
                True,
                fileName)
    then // continue
    else exit;

  with mygb do
    case mode of
      eiSGF : ExportSGF(fileName, iMinData, jMinData, iMaxData, jMaxData);
      eiRGG,
      eiSSL : ExportASC(fileName, iMinData, jMinData, iMaxData, jMaxData);
      else    ExportIMG(mode,
                        fileName, iMinData, jMinData, iMaxData, jMaxData,
                        ieWidth.Value, ieHeight.Value)
    end
end;

// -- Clipboard button -------------------------------------------------------

procedure TfmExportPos.btClipboardClick(Sender: TObject);
var
  mode : TExportFigure;
begin
  if not SaveParam(Settings)
    then exit;
  mode := GetFormatIndex;

  with mygb do
    if mode in [eiRGG, eiSSL]
      then ExportASC('', iMinData, jMinData, iMaxData, jMaxData)
      else ExportIMG(mode,
                     '', iMinData, jMinData, iMaxData, jMaxData,
                     ieWidth.Value, ieHeight.Value)
end;

// -- Events on size selection -----------------------------------------------

procedure TfmExportPos.ieDiamChange(Sender: TObject);
begin
  // freeze change events
  ieWidth.OnChange  := nil;
  ieHeight.OnChange := nil;

  // compute height and width from diameter
  AdjustDimFromDiam(mygb.iMinView, mygb.jMinView,
                    mygb.iMaxView, mygb.jMaxView);

  // restore change events
  ieWidth.OnChange  := ieWidthChange;
  ieHeight.OnChange := ieHeightChange
end;

procedure TfmExportPos.ieWidthChange(Sender: TObject);
var
  w, h, n : integer;
begin
  // freeze change events
  ieDiam.OnChange   := nil;
  ieHeight.OnChange := nil;

  // compute height from width
  w := mygb.jMaxView - mygb.jMinView + 1;
  h := mygb.iMaxView - mygb.iMinView + 1;
  n := StrToIntDef(ieWidth.Text, 1);
  ieHeight.Value := Round(n * h / w);

  // compute diameter from height and width
  AdjustDiamFromDim;

  // restore change events
  ieDiam.OnChange   := ieDiamChange;
  ieHeight.OnChange := ieHeightChange;
end;

procedure TfmExportPos.ieHeightChange(Sender: TObject);
var
  w, h, n : integer;
begin
  // freeze change events
  ieDiam.OnChange  := nil;
  ieWidth.OnChange := nil;

  // compute width from height
  w := mygb.jMaxView - mygb.jMinView + 1;
  h := mygb.iMaxView - mygb.iMinView + 1;
  n := StrToIntDef(ieHeight.Text, 1);
  ieWidth.Value := Round(n * w / h);

  // compute diameter from height and width
  AdjustDiamFromDim;

  // restore change events
  ieDiam.OnChange  := ieDiamChange;
  ieWidth.OnChange := ieWidthChange
end;

procedure TfmExportPos.AdjustDiamFromDim;
var
  bmp : TBitmap;
begin
  with TBoardViewMetric.Create do
    begin
      bmp := TBitmap.Create; // see Danny Thorpe post at http://www.delphigroups.info/2/9/310064.html
      Canvas := bmp.Canvas;
      CoordStyle := Settings.CoordStyle;
      SetView(mygb.iMinView, mygb.jMinView,
              mygb.iMaxView, mygb.jMaxView);

      SetDim(ieWidth.Value, ieHeight.Value);
      ieDiam.Value := Max(1, Diameter);

      bmp.Free;
      Free
    end
end;

procedure TfmExportPos.AdjustDimFromDiam(i1, j1, i2, j2 : integer);
var
  bmp : TBitmap;
begin
  with TBoardViewMetric.Create do
    begin
      bmp := TBitmap.Create; // see Danny Thorpe post at http://www.delphigroups.info/2/9/310064.html
      Canvas := bmp.Canvas;
      CoordStyle := Settings.CoordStyle;
      SetView(i1, j1, i2, j2);

      Diameter := ieDiam.Value;
      AdjustDimFromDiameter;

      ieWidth.Value := ExtWidth;
      ieHeight.Value := ExtHeight;

      bmp.Free;
      Free
    end
end;

// -- Events on area selection -----------------------------------------------

function IsValidRectangle(s : string; var i1, j1, i2, j2 : integer) : boolean;
var
  p : integer;
  s1, s2 : string;
  ok1, ok2 : boolean;
begin
  Result := False;

  p := Pos(':', s);
  if not (p in [3, 4])
    then exit;

  s1 := Copy(s, 1, p - 1);
  s2 := Copy(s, p + 1, 1000);

  kor2ij(s1, fmExportPos.mygb.BoardSize, i1, j1, ok1);
  kor2ij(s2, fmExportPos.mygb.BoardSize, i2, j2, ok2);

  Result := ok1 and ok2
end;

procedure TfmExportPos.edZoneChange(Sender: TObject);
var
  i1, j1, i2, j2 : integer;
begin
  if IsValidRectangle(edZone.Text, i1, j1, i2, j2) then
    begin
      Capture(i1, j1, i2, j2);
      DoZoneChange(i1, j1, i2, j2)
    end
end;

// -- Event on book/board mode selection -------------------------------------

procedure TfmExportPos.cbAsBooksChange(Sender: TObject);
begin
  Settings.PrNumAsBooks := cbAsBooks.ItemIndex = 1;
  with mygb do
    self.Capture(iMinView, jMinView, iMaxView, jMaxView);
end;

// -- Update of +/- button ---------------------------------------------------

procedure TfmExportPos.PlusMinus(button : TSpeedButton; state : integer);
begin
  bmButton.Canvas.FillRect(Rect(0, 0, 12, 12));
  bmButton.Canvas.MoveTo(1, 4);
  bmButton.Canvas.LineTo(7, 4);
  if state > 0 then
    begin
      bmButton.Canvas.MoveTo(4, 1);
      bmButton.Canvas.LineTo(4, 7);
    end;
  button.Glyph.Assign(bmButton)
end;

// -- Opening and closing of general settings --------------------------------

procedure TfmExportPos.sbOptionClick(Sender: TObject);
begin
  if not pnOption.Visible then
    begin
      pnOption.Top     := gbOption.Top + gbOption.Height;
      pnOption.Left    := gbOption.Left;
      pnOption.Width   := gbOption.Width;
      pnOption.Visible := True;
      Height           := Height       + pnOption.Height;
      gbFormat.Top     := gbFormat.Top + pnOption.Height;
      if pnFormat.Visible
        then pnFormat.Top := pnFormat.Top + pnOption.Height;
      cbAsBooks.ItemIndex := iff(Settings.PrNumAsBooks, 1, 0);
    end
  else
    begin
      pnOption.Visible := False;
      Height           := Height       - pnOption.Height;
      gbFormat.Top     := gbFormat.Top - pnOption.Height;
      if pnFormat.Visible
        then pnFormat.Top := pnFormat.Top - pnOption.Height;
    end;

  PlusMinus(sbOption, iff(pnOption.Visible, -1, +1))
end;

// -- Event for Format radio button ------------------------------------------
//
// Same handler for all buttons

procedure TfmExportPos.rbWMFClick(Sender: TObject);
begin
  Settings.prExportPos := GetFormatIndex;
  ShowFormatOptions(Settings);

  gbDim.Caption := U(iff(GetFormatIndex in [eiWMF, eiPDF],
                         'Dimensions (mm)',
                         'Dimensions (px)'));
  btClipboard.Enabled := GetFormatIndex in [eiWMF, eiBMP, eiRGG, eiSSL]
end;

// -- Events for ASCII mode combo --------------------------------------------

procedure TfmExportPos.cb1Change(Sender: TObject);
begin
  Settings.PrExportPos := GetFormatIndex;
  ShowFormatOptions(Settings);
end;

// -- Opening and closing of format settings ---------------------------------

procedure TfmExportPos.sbFormatClick(Sender: TObject);
begin
  if not pnFormat.Visible then
    begin
      Settings.prExportPos := GetFormatIndex;
      pnFormat.Visible := True;
      ShowFormatOptions(Settings);
      pnFormat.Top     := gbFormat.Top + gbFormat.Height;
      pnFormat.Left    := gbFormat.Left;
    end
  else
    begin
      pnFormat.Visible := False;
      Height := StartHeight{470} + iff(pnOption.Visible, pnOption.Height, 0)
                                 + iff(pnFormat.Visible, pnFormat.Height, 0)
    end;

  PlusMinus(sbFormat, iff(pnFormat.Visible, -1, +1))
end;

procedure TfmExportPos.ShowFormatOptions(st : TStatus);
const
  RC = #$0D#$0A;
begin
  with pnFormat do
    case st.prExportPos of
      eiWMF,
      eiPDF,
      eiGIF,
      eiPNG,
      eiBMP :
        begin
          Height        := 6;
          ie1.Visible   := False;
          cb1.Visible   := False;
          ie1.Visible   := False;
        end;
      eiJPG :
        begin
          Height        := cb1.Top + ie1.Height + cb1.Top;
          ie1.Top       := cb1.Top;
          ie1.Left      := cb2.Left + cb2.Width div 2;
          ie1.Width     := cb2.Width div 2;
          cb1.Visible   := False;
          cb2.Visible   := False;
          cb3.Visible   := False;
          cb4.Visible   := False;
          ie1.Visible   := True;
          sg1.Visible   := False;
          lb1.Caption   := U('Jpeg quality (1-100)');
        end;
      eiRGG :
        begin
          cb1.Visible   := Visible;
          cb2.Visible   := Visible;
          cb3.Visible   := Visible;
          cb4.Visible   := Visible;
          ie1.Visible   := True;
          sg1.Visible   := False;

          ie1.Top       := cb4.Top + (cb4.Top - cb3.Top);
          ie1.Left      := cb4.Left;
          ie1.Width     := cb4.Width;
          Height        := ie1.Top + (ie1.Top - cb4.Top) + 4;

          lb1.Caption   := U('Mode');
          cb2.Items.Strings[0] := U('Yes');
          cb2.Items.Strings[1] := U('No');
          cb1.ItemIndex := 0;
        end;
      eiSSL :
        begin
          cb1.Visible   := Visible;
          cb2.Visible   := False;
          cb3.Visible   := False;
          cb4.Visible   := False;
          ie1.Visible   := False;
          sg1.Visible   := True;

          lb1.Caption   := U('Mode');
          cb1.ItemIndex := 1;
          sg1.Top       := cb2.Top; // 26;
          sg1.ColWidths[0] := sg1.Width - cb1.Width;
          sg1.ColWidths[1] := cb1.Width;

          Height        := sg1.Top + sg1.Height + 4;

          sg1.Rows[0].Text := U('Black') + RC + 'X';
          sg1.Rows[1].Text := U('White') + RC + 'O';
          sg1.Rows[2].Text := U('Moves from 1 to 10') + RC + '1,...,9,0';
          sg1.Rows[3].Text := U('Black with circle') + RC + 'B';
          sg1.Rows[4].Text := U('White with circle') + RC + 'W';
          sg1.Rows[5].Text := U('Black with square') + RC + '#';
          sg1.Rows[6].Text := U('White with square') + RC + '@';
          sg1.Rows[7].Text := U('Circle') + RC + 'C';
          sg1.Rows[8].Text := U('Square') + RC + 'S';
          sg1.Rows[9].Text := U('Letter') + RC + 'a,...,z';
        end
    end;
    
  Height := StartHeight{470} + iff(pnOption.Visible, pnOption.Height, 0)
                 + iff(pnFormat.Visible, pnFormat.Height, 0);

  ShowParamFormat(st)
end;

// -- Export to graphic ------------------------------------------------------

procedure TfmExportPos.ExportIMG(mode    : TExportFigure;
                                 imgName : string;
                                 i1, j1, i2, j2, width, height : integer);
var
  bitmap : TBitmap;
  metafile : TMetafile;
  dpi, px, py : integer;
  textCanvas : TStringList;
  mmWidth, mmHeight : integer;
begin
  if (mode = eiWMF) and (imgName = '') // export wmf to clipboard with 96 dpi
    then dpi := 96
    else dpi := Status.prDPI;

  bitmap     := nil; 
  metafile   := nil; 
  textCanvas := nil;

  SortPair(i1, i2);
  SortPair(j1, j2);

  mygb.SetView(i1, j1, i2, j2);

  case mode of
    eiWMF:
      begin
        metafile := TMetaFile.Create;
        ExportBoardToWMF(mygb, metafile, width, height, dpi);
      end;
    eiPDF:
      begin
        if Settings.PdfExactWidthMm > 0 then
          begin
            // force dim to a large value to avoid rounding errors
            width  := 200;
            height := 200
          end;
        textCanvas := TStringList.Create;
        px := round(width  * 72 / 25.4);            // PDF default dpi = 72
        py := round(height * 72 / 25.4);            // PDF default dpi = 72
                                                    // dim expressed in pixels
        ExportBoardToPDF(mygb, px, py, textCanvas, mmWidth, mmHeight)
      end;
    else
      begin
        bitmap := TBitmap.Create;
        ExportBoardToBMP(mygb, bitmap, width, height)
      end
    end;

  UExporterIMG.ExportIMG(bitmap, metafile, textCanvas, mode, dpi, imgName);

  FreeAndNil(metafile);
  FreeAndNil(textCanvas);
  FreeAndNil(bitmap)
end;

// -- Export to SGF ----------------------------------------------------------

procedure TfmExportPos.ExportSGF(imgName : string; i1, j1, i2, j2 : integer);
var
  gt : TGameTree;
begin
  gt := ExtractPosition(fmMain.ActiveView, i1, j1, i2, j2);
  PrintWholeTree(imgName, gt, False, False);
  gt.FreeGameTree
end;

// -- Export to ASCII --------------------------------------------------------
// ---------------------------------------------------------------------------

procedure TfmExportPos.ExportASC(imgName : string;
                                 i1, j1, i2, j2 : integer);
var
  textCanvas : TStringList;
begin
  textCanvas := TStringList.Create;
  ExportBoardToAscii(mygb, Settings.PrExportPos, textCanvas);

  if imgName = ''
    then Clipboard.SetTextBuf(PChar(textCanvas.Text))
    else textCanvas.SaveToFile(imgName);

  textCanvas.Free
end;

// -- Handling of format indexes ---------------------------------------------

procedure TfmExportPos.SetFormatIndex(i : TExportFigure);
begin
  case i of
    eiWMF : rbWMF.Checked := True;
    eiPDF : rbPDF.Checked := True;
    eiGIF : rbGIF.Checked := True;
    eiPNG : rbPNG.Checked := True;
    eiJPG : rbJPG.Checked := True;
    eiBMP : rbBMP.Checked := True;
    eiSGF : rbSGF.Checked := True;
    eiRGG : begin
              cb1.ItemIndex := 0;
              rbASC.Checked := True
            end;
    eiSSL : begin
              cb1.ItemIndex := 1;
              rbASC.Checked := True
            end
  end
end;

function TfmExportPos.GetFormatIndex : TExportFigure;
begin
  if rbWMF.Checked then Result := eiWMF else
  if rbPDF.Checked then Result := eiPDF else
  if rbGIF.Checked then Result := eiGIF else
  if rbPNG.Checked then Result := eiPNG else
  if rbJPG.Checked then Result := eiJPG else
  if rbBMP.Checked then Result := eiBMP else
  if rbSGF.Checked then Result := eiSGF else
  if rbASC.Checked then
    if cb1.ItemIndex = 0
      then Result := eiRGG
      else Result := eiSSL
end;

// ---------------------------------------------------------------------------

end.
