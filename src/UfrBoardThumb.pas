// ---------------------------------------------------------------------------
// -- Drago -- Frame to display thumbnail board --------- UfrBoardThumb.pas --
// ---------------------------------------------------------------------------

unit UfrBoardThumb;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Components, ActnList, Buttons, ImgList,
  SpTBXControls, SpTBXItem,
  DefineUi, UView, UGoban;

type
  TfrBoardThumb = class(TFrame)
    Bevel: TBevel;
    imGoban: TImageEx;
    ImageList: TImageList;
    btBlack: TSpTBXButton;
    btWhite: TSpTBXButton;
    btWildcard: TSpTBXButton;
    btCapture: TSpTBXButton;
    btClear: TSpTBXButton;
    procedure imGobanMouseEnter(Sender: TObject);
    procedure imGobanMouseLeave(Sender: TObject);
    procedure imGobanMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
    procedure imGobanMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure imGobanMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
    procedure btBlackClick(Sender: TObject);
    procedure btWhiteClick(Sender: TObject);
    procedure btWildcardClick(Sender: TObject);
    procedure btCaptureClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure FrameMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  private
    ModeInter, ModeInterBak : integer;
    FSearchMode : TSearchMode;
    iCurrent, jCurrent, iStart, jStart : integer;
    function  ActiveView : TView;
    procedure InitializeButtons(searchMode : TSearchMode);
  public
    mygb : TGoban;
    procedure Initialize(searchMode : TSearchMode);
    procedure Finalize;
    procedure Capture(gb : TGoban; i1, j1, i2, j2 : integer);
    procedure ShowThumb(i1, j1, i2, j2 : integer);
    procedure imGobanMouseDownSignature(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure SetGlyph(btn : TBitBtn; image : integer);
    procedure UpdateButton(mode : integer);
    procedure HandleButtonClick(mode : integer);
    procedure DrawSigOnBoard(sig : string);
    procedure ClickOnboard(mode, i, j : integer);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Math,
  Std, Ux2y, Define, Main,
  UStatus, UfrDBSignaturePanel,
  UfmDBSearch, UBoardView, UBoardViewCanvas;

{$R *.dfm}

// -- Initialization ---------------------------------------------------------

procedure TfrBoardThumb.Initialize(searchMode : TSearchMode);
begin
  // fight against flickering
  //AvoidFlickering([self]); if doublefuffered, transparency VCL bug occurs
  ParentBackground := False;

  FSearchMode := searchMode;
  InitializeButtons(searchMode);

  mygb := TGoban.Create;
  mygb.SetBoardView(TBoardViewCanvas.Create(imGoban.Canvas));
  mygb.BoardView.CoordStyle := tcNone;
  mygb.Silence := False;

  ModeInter := kimGE
end;

procedure TfrBoardThumb.InitializeButtons(searchMode : TSearchMode);
var
  buttons : array[0 .. 4] of TControl;
  i : integer;
begin
  // initialize list of buttons
  buttons[0] := btBlack;
  buttons[1] := btWhite;
  buttons[2] := btWildcard;
  buttons[3] := btCapture;
  buttons[4] := btClear;

  for i := 0 to 4 do
    begin
      buttons[i].Visible := (searchMode = smPattern) or (i > 2);
      buttons[i].Top := ClientHeight - btClear.Height - 4;
      buttons[i].Width := (ClientWidth - 4) div 5;
      buttons[i].Left := 2 + i * buttons[i].Width + iff(i > 2, 2, 0);
      buttons[i].Anchors := [akBottom]
    end;

  if searchMode = smSig then
    begin
      btCapture.Left := Width div 2 - 1 - btCapture.Width;
      btClear.Left   := Width div 2 + 1;
    end
end;

procedure TfrBoardThumb.Finalize;
begin
  mygb.Free
end;

function TfrBoardThumb.ActiveView : TView;
begin
  Result := fmMain.ActiveView
end;

// -- Capture and display of thumbnail ---------------------------------------

procedure TfrBoardThumb.Capture(gb : TGoban; i1, j1, i2, j2 : integer);
begin
  if gb <> mygb then
    begin
      mygb.Assign(gb);
      (mygb.BoardView as TBoardViewCanvas).PartialTouch := False;
      mygb.SetView(i1, j1, i2, j2);
      mygb.BoardView.CoordStyle := tcNone
    end;

  OnResize := nil;
  ShowThumb(i1, j1, i2, j2);
  OnResize := FrameResize
end;

procedure TfrBoardThumb.ShowThumb(i1, j1, i2, j2 : integer);
var
  ymin, ymax, hmax : integer;
begin
  ymin := 2;
  ymax := btClear.Top - 4;
  hmax := ymax - ymin + 1;
  hmax := Max(hmax, 0);
  hmax := Min(hmax, ClientWidth);

  imGoban.Width  := hmax;
  imGoban.Height := hmax;
  imGoban.Picture.Bitmap.Width := imGoban.Width;
  imGoban.Picture.Bitmap.Height := imGoban.Height;

  mygb.SetView(i1, j1, i2, j2);
  mygb.SetDim(imGoban.Width, imGoban.Height, 29);
  mygb.BoardView.AdjustToSize;
  mygb.Draw;

  imGoban.Width  := (mygb.BoardView as TBoardViewCanvas).ExtWidth;
  imGoban.Height := (mygb.BoardView as TBoardViewCanvas).ExtHeight;
  imGoban.Top    := ymin + (hmax - imGoban.Height) div 2;
  imGoban.Left   := (ClientWidth - imGoban.Width ) div 2;

  // set bevel around thumbnail
  Bevel.Top     := imGoban.Top    - 2;
  Bevel.Left    := imGoban.Left   - 2;
  Bevel.Width   := imGoban.Width  + 4;
  Bevel.Height  := imGoban.Height + 4;

  mygb.Silence := False;

  //InitializeButtons(FSearchMode);
end;

// -- Resizing ---------------------------------------------------------------

procedure TfrBoardThumb.FrameResize(Sender: TObject);
begin
  if Assigned(mygb) then
    with mygb do
      ShowThumb(iMinView, jMinView, iMaxView, jMaxView)
end;

// -- Button events ----------------------------------------------------------

procedure TfrBoardThumb.SetGlyph(btn : TBitBtn; image : integer);
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.Width  := 9;
  bmp.Height := 9;
  bmp.TransparentMode := tmAuto;
  ImageList.Draw(bmp.Canvas, 0, 0, image);
  btn.Glyph.Assign(bmp);
  bmp.Free
end;

procedure TfrBoardThumb.UpdateButton(mode : integer);
begin
(*
  btBlack.Glyph := nil;
  btWhite.Glyph := nil;
  btWildcard.Glyph := nil;
*)
  btBlack.ImageIndex := -1;
  btWhite.ImageIndex := -1;
  btWildcard.ImageIndex := -1;

  if ModeInter = mode
    then ModeInter := kimGE
    else
      begin
        case mode of
          kimAB : btBlack.ImageIndex := 0; //SetGlyph(btBlack, 0);
          kimAW : btWhite.ImageIndex := 1; //SetGlyph(btWhite, 1);
          kimWC : btWildcard.ImageIndex := 2; //SetGlyph(btWildcard, 2);
        end;

        ModeInter := mode
      end
end;

procedure TfrBoardThumb.HandleButtonClick(mode : integer);
begin
  //UpdateButton(mode);

  if ActiveView.si.EnableMode = mdEdit
    then ActiveView.si.ModeInter := mode
    else UpdateButton(mode)
end;

// -- Black button

procedure TfrBoardThumb.btBlackClick(Sender: TObject);
begin
  HandleButtonClick(kimAB)
end;

// -- White button

procedure TfrBoardThumb.btWhiteClick(Sender: TObject);
begin
  HandleButtonClick(kimAW)
end;

// -- Wildcard button

procedure TfrBoardThumb.btWildcardClick(Sender: TObject);
begin
  HandleButtonClick(kimWC)
end;

// -- Capture button

procedure TfrBoardThumb.btCaptureClick(Sender: TObject);
begin
  with ActiveView do
    Capture(gb, gb.iMinView, gb.jMinView, gb.iMaxView, gb.jMaxView)
end;

// -- Clear button

procedure TfrBoardThumb.btClearClick(Sender: TObject);
begin
  mygb.Silence := False;
  mygb.Clear;
  ShowThumb(1, 1, mygb.BoardSize, mygb.BoardSize);

  // warn search form about change in thumbnail
  fmDBSearch.NotifyThumbnailChange(True)
end;

// -- Mouse events -----------------------------------------------------------

// called in fmMain OnMouseUp handler
procedure RButtonUpCallBackThumb;
begin
(*
  if Assigned(fmDBSearch) and Assigned(fmDBSearch.frDBPatternPanel)
    then fmDBSearch.frDBPatternPanel.BoardThumb.imGobanMouseUp(nil, mbRight, [], 0, 0)
*)
end;

procedure TfrBoardThumb.imGobanMouseEnter(Sender: TObject);
begin
  fmMain.OnMessageRButtonUp := nil
end;

procedure TfrBoardThumb.imGobanMouseLeave(Sender: TObject);
begin
  fmMain.OnMessageRButtonUp := RButtonUpCallBackThumb
end;

procedure TfrBoardThumb.imGobanMouseDown(Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssRight in Shift then
    begin
      ModeInterBak := ModeInter;
      ModeInter := kimPS;

      // set cross shape cursor
      Screen.Cursor := crZone;
      imGoban.OnMouseEnter := imGobanMouseEnter;
      imGoban.OnMouseLeave := imGobanMouseLeave
    end;

  if ModeInter = kimPS
    then mygb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);

  mygb.xy2ij(X, Y, iCurrent, jCurrent);
  iStart := iCurrent;
  jStart := jCurrent;

  if ModeInter = kimPS then
    begin
      mygb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
      mygb.Rectangle(iStart, jStart, iStart, jStart, True);
      exit
    end;

  // handle only basic setup
  if not (ModeInter in [kimAB, kimAW, kimWC])
    then exit;

  // warn search form about change in thumbnail
  fmDBSearch.NotifyThumbnailChange;

  if ModeInter in [kimAB, kimAW]
    then ClickOnBoard(ModeInter, iCurrent, jCurrent)
    else // kimWC
      if mygb.BoardMarks[iCurrent, jCurrent].FMark = mrkWC
        then mygb.ShowSymbol(iCurrent, jCurrent, mrkNO)
        else mygb.ShowSymbol(iCurrent, jCurrent, mrkWC)
end;

procedure TfrBoardThumb.ClickOnboard(mode, i, j : integer);
var
  currentInter, newInter : integer;
begin
  currentInter := mygb.Board[i, j];

  case mode of
    kimAB :
      if (not Settings.ExtendSetup)
        then
          if currentInter = Black
            then newInter := Empty
            else newInter := Black
        else
          case currentInter of
            Black : newInter := White;
            White : newInter := Empty;
            else    newInter := Black
          end;
    kimAW :
      if (not Settings.ExtendSetup)
        then
          if currentInter = White
            then newInter := Empty
            else newInter := White
        else
          case currentInter of
            Black : newInter := Empty;
            White : newInter := Black;
            else    newInter := White
          end
  end;

  mygb.GameBoard.Board[i, j] := newInter;
  mygb.ShowVertex(i, j)
end;

procedure TfrBoardThumb.imGobanMouseMove(Sender: TObject;
                                         Shift: TShiftState; X, Y: Integer);
var
  i, j : integer;
begin
  if mygb.InsideBoard(X, Y) and ((ssLeft in Shift) or (ssRight in Shift)) then
    case ModeInter of
      kimPS :
        begin
          mygb.xy2ij(X, Y, i, j);

          if (i <> iCurrent) or (j <> jCurrent)
            then
              begin
                mygb.Rectangle(iStart, jStart, iCurrent, jCurrent, False);
                iCurrent := i;
                jCurrent := j;
                mygb.Rectangle(iStart, jStart, iCurrent, jCurrent, True);
              end
        end
    end
end;

procedure TfrBoardThumb.imGobanMouseUp(Sender : TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ModeInter = kimPS then
    begin
      Screen.Cursor := crDefault;
      imGoban.OnMouseEnter := nil;
      imGoban.OnMouseLeave := nil;
      ModeInter := ModeInterBak;
      Capture(mygb, iStart, jStart, iCurrent, jCurrent);

      // warn search form about change in thumbnail
      fmDBSearch.NotifyThumbnailChange;
    end
end;

procedure TfrBoardThumb.FrameMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  imGobanMouseUp(Sender, Button, Shift, X, Y)
end;

// -- Signature mode

function SigNum(i : integer) : integer;
begin
  if i < 3
    then Result := 20 * (i + 1)
    else Result := 20 * (i - 2) + 11
end;

procedure TfrBoardThumb.DrawSigOnBoard(sig : string);
var
  i, j, k : integer;
  sgf : string;
begin
  mygb.Clear;
  mygb.DrawEmpty;

  for k := 0 to 5 do
    if Length(sig) < k * 2 + 2
      then // nop
      else
        begin
          sgf := Copy(sig, k * 2 + 1, 2);
          sgf2ij(sgf, i, j);

          if mygb.IsBoardCoord(i, j)
            then mygb.BoardView.DrawSigMark(i, j, SigNum(k))
        end
end;

procedure TfrBoardThumb.imGobanMouseDownSignature(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  moveNum : integer;
begin
  mygb.xy2ij(X, Y, iCurrent, jCurrent);

  with Parent as TfrDBSignaturePanel do
    UpdateSignatureEdits(ij2sgf(iCurrent, jCurrent), moveNum)
end;

// ---------------------------------------------------------------------------

end.
