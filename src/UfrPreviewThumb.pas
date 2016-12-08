// ---------------------------------------------------------------------------
// -- Drago -- Preview frame for thumbnail boards ----- UfrPreviewThumb.pas --
// ---------------------------------------------------------------------------

unit UfrPreviewThumb;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  UViewMain, UViewBoard, UContext, UGoban, UGameTree;

const
  thMaxCol = 10;
  thMaxRow = 10;
  kSynchroWithIndex = True;

type
  TfrPreviewThumb = class(TFrame)
    ScrollBar: TScrollBar;
    pnThumbs: TPanel;
    imImage: TImage;
    imCursor: TImage;
    //constructor Create(aOwner: TComponent); override;
    constructor Create(aOwner, aParent : TComponent;
                       aView    : TViewMain;
                       aContext : TContext);
    destructor Destroy; override;
    procedure ImageClick(Sender: TObject);
    procedure ImageDoubleClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure FrameMouseWheelDown(Sender: TObject; Shift: TShiftState;
                                MousePos: TPoint; var Handled: Boolean);
    procedure FrameMouseWheelUp(Sender: TObject; Shift: TShiftState;
                                MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
                      var ScrollPos: Integer);
  private
    OriginView : TViewMain;
    LocalView : TViewMain;
    LocalGoban : TGoban;
    LocalBitmap : TBitmap;
    Increments : string;
    depth : integer;
    CurrentImage : TImage;
    procedure UpdateCurrentGame(index : integer);
    procedure UpdateCursor;
    procedure SetDimOfGraphArea(var h, w : integer);
    procedure BoardTopLeft(i, j : integer; var top, left : integer);
    function  GameOnImage(Sender: TObject) : integer;
    function  NumberToDisplay : integer;
    function  NthGameTree(k : integer) : TGameTree;
    function  NthCaption(k : integer) : shortstring;
    procedure ConfigureBoard(i, j : integer);
    procedure ShowBoard(i, j : integer; visible : boolean);
    procedure DisplayBoard(i, j, k, depth : integer);
    procedure SelectGame(k : integer);
    procedure FrameMouseWheelChange(newTopLeft : integer;
                          var Handled: Boolean);
    function  IsInCurrentPage(index : integer) : boolean;
    procedure ShowPattern(view : TViewBoard);
  public
    ImArray      : array[0 .. thMaxRow - 1, 0 .. thMaxCol - 1] of TImage;
    BvArray      : array[0 .. thMaxRow - 1, 0 .. thMaxCol - 1] of TBevel;
    LbArray      : array[0 .. thMaxRow - 1, 0 .. thMaxCol - 1] of TLabel;
    TopLeftGame  : integer;  // 1-based
    CurrentGame  : integer;  // 1-based
    CurrentBoard : TPoint;
    procedure Initialize;
    procedure DoWhenShowing(synchroWithIndex : boolean; start : boolean = False);
    procedure ResizeGoban;
    procedure FirstGame;
    procedure LastGame;
    procedure PrevGame;
    procedure NextGame;
    procedure GotoGame(index : integer);
    procedure StartPos;
    procedure EndPos;
    procedure PrevMove;
    procedure NextMove;
    procedure SelectMove(n : integer);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Math,
  Define, DefineUi, Std, VclUtils, UStatus, UMatchPattern,
  UView, UViewThumb, GameUtils, UBoardViewCanvas;

{$R *.dfm}

// ---------------------------------------------------------------------------

var
  GIdxNCol    : integer = 0;
  GIdxNRow    : integer = 0;
  GIdxNImg    : integer;
  GIdxRadius  : integer;
  GIdxWidth   : integer;
  HorzOffset  : integer;
  VertOffset  : integer;
  HorzDelta   : integer;
  VertDelta   : integer;

// -- Constructor and destructor ---------------------------------------------

constructor TfrPreviewThumb.Create(aOwner, aParent : TComponent;
                                   aView    : TViewMain;
                                   aContext : TContext);
var
  i, j : integer;
begin
  if aOwner <> nil
    then inherited Create(aOwner);

  Parent := aParent as TWinControl;
  Align  := alClient;

  // fight against flickering
  DoubleBuffered            := True;
  ParentBackground          := False;
  pnThumbs.DoubleBuffered   := True;
  pnThumbs.ParentBackground := False;

  for i := 0 to thMaxRow - 1 do
    for j := 0 to thMaxCol - 1 do
      begin
        // bevels first to be behind images
        BvArray[i, j] := TBevel.Create(Self);
        BvArray[i, j].Parent  := pnThumbs;
        BvArray[i, j].Shape   := bsFrame;
        BvArray[i, j].Visible := False;
        // images
        ImArray[i, j] := TImage.Create(Self);
        ImArray[i, j].Parent := pnThumbs;
        ImArray[i, j].OnClick := ImageClick;
        ImArray[i, j].OnDblClick := ImageDoubleClick;
        ImArray[i, j].Visible := False;
        // labels
        LbArray[i, j] := TLabel.Create(Self);
        LbArray[i, j].Parent := pnThumbs;
        LbArray[i, j].Visible := False;
        LbArray[i, j].Transparent := True;
        LbArray[i, j].Font.Color := clBlack;
      end;

  OriginView := aView;

  LocalView := TViewThumb.Create;
  LocalView.TabSheet := OriginView.TabSheet;
  (LocalView as TViewThumb).frPreviewThumb := self;
  LocalView.Context := TContext.Create;
  LocalView.cl.Free;

  LocalView.gt := OriginView.gt;
  LocalView.cl := OriginView.cl;
  LocalView.kh := OriginView.kh;
  LocalView.si.FIndexTree := OriginView.si.FIndexTree;

  LocalGoban  := TGoban.Create;
  LocalBitmap := TBitmap.Create;
  LocalBitmap.Width := GIdxWidth;
  LocalBitmap.Height := GIdxWidth;
  LocalBitmap.PixelFormat := pf32bit;

  LocalGoban.SetBoardView(TBoardViewCanvas.Create(LocalBitmap.Canvas));
  LocalView.gb := LocalGoban;

  Increments := ''
end;

destructor TfrPreviewThumb.Destroy;
var
  i, j : integer;
begin
  LocalView.cl := nil;
  LocalView.gb := nil;
  LocalView.kh := nil;
  LocalView.Context.Free;
  LocalView.Free;
  LocalGoban.Free;
  LocalBitmap.Free;
  
  for i := 0 to thMaxRow - 1 do
    for j := 0 to thMaxCol - 1 do
      begin
        FreeAndNil(ImArray[i, j]);
        FreeAndNil(LbArray[i, j])
      end;

  inherited Destroy
end;

// -- Settings of display ----------------------------------------------------

procedure TfrPreviewThumb.Initialize;
var
  boardView : TBoardViewCanvas;
begin
  // set offsets for displaying boards
  VertOffset := 16;
  HorzOffset := 16;
  HorzDelta  := 16;
  
  // beware the following triggers a call to OnResize event
  OnResize   := nil;
  VertDelta  := 8 + LbArray[0, 0].Canvas.TextHeight('A');
  OnResize   := FrameResize;

  // compute width from radius, other settings in DoWhenShowing
  GIdxRadius := Settings.GIdxRadius;
  GIdxWidth  := 19 * (2 * GIdxRadius + 1 + 1) - 1;
  GIdxNCol   := 1;
  GIdxNRow   := 1;
  GIdxNImg   := 1;

  // initialize image for cursor
  imCursor.Width  := GIdxWidth + 4;
  imCursor.Height := GIdxWidth + 4;
  imCursor.Picture.Bitmap.Width  := GIdxWidth + 4;
  imCursor.Picture.Bitmap.Height := GIdxWidth + 4;
  imCursor.Canvas.Brush.Color := clBlue;
  imCursor.Canvas.FillRect (Rect(0, 0, GIdxWidth + 4, GIdxWidth + 4));
  CurrentBoard := Point(0, 0);

  // working board settings
  with Settings do
    begin
      LocalGoban.ShowMoveMode := smNoMark;  // no move displayed on thumbnails
      boardView := LocalGoban.BoardView as TBoardViewCanvas;
      boardView.BoardSettings(BoardBack, BorderBack,
                              ThickEdge,
                              ShowHoshis,
                              tcNone,       // no coordinates displayed on thumbnails
                              dsDrawing,
                              LightSource, NumOfMoveDigits, False)
    end;

  depth := -1
end;

// -- Thumbnail board display ------------------------------------------------

// -- Configuration of thumbnail

procedure TfrPreviewThumb.ConfigureBoard(i, j : integer);
var
  x, y : integer;
begin
  // image top left corner
  BoardTopLeft(i, j, y, x);

  // bevel
  with BvArray[i, j] do
    begin
      Width  := GIdxWidth + 4;
      Height := GIdxWidth + 4;
      Top    := y - 2;
      Left   := x - 2
    end;

  // board image
  ImArray[i, j].BoundsRect := Rect(x, y, x + GIdxWidth, y + GIdxWidth);

  // label
  with LbArray[i, j] do
    begin
      Width  := GIdxWidth - 3;
      Top    := y + GIdxWidth + 2;
      Left   := x
    end
end;

// -- Control of thumbnail visibility

procedure TfrPreviewThumb.ShowBoard(i, j : integer; visible : boolean);
begin
  if LbArray[i, j].Visible = visible
    then exit;

  ImArray[i, j].Visible := visible;
  BvArray[i, j].Visible := visible;
  LbArray[i, j].Visible := visible
end;

// -- Display of one thumbnail

procedure TfrPreviewThumb.DisplayBoard(i, j, k, depth : integer);
var
  p : integer;
begin
  LocalBitmap.Width := GIdxWidth;
  LocalBitmap.Height := GIdxWidth;

  // refresh board
  ShowBoard(i, j, True);
  ConfigureBoard(i, j);

  // save current image to use later in Resize
  CurrentImage := ImArray[i, j];

  // initialize
  LocalView.gt := NthGameTree(k);
  LocalView.gb.CoordTrans := trIdent;

  // draw board (on temporary bitmap)
  if LocalView.cl.Hits[k] = ''
    then
      begin
        LocalView.StartEvent(seIndex, snExtend);
        LocalView.GotoMove(depth, kLastQuiet, snExtend);

        if Length(Increments) > 0 then
          begin
            for p := 1 to Length(Increments) do
              case Increments[p] of
                '+' : if LocalView.gt.NextNode <> nil
                        then LocalView.MoveForward;
                '-' : if LocalView.gt.PrevNode <> nil
                        then LocalView.MoveBackward;
                '[' : LocalView.GotoMove(0, kLastQuiet, snExtend);
                ']' : LocalView.GotoMove(MaxMoveNumber, kLastQuiet, snExtend);
                else // nop
              end
          end
      end
    else
      begin
        LocalView.StartEvent(seIndex, snStrict);
        LocalView.GotoPath(FirstHit(LocalView.cl.Hits[k], LocalView.cl[k]),
                  kLastQuiet);

        ShowSearchPattern(LocalView.gb, LocalView.kh)
      end;

  // copy temporary bitmap to screen
  ImArray[i, j].Canvas.Draw(0, 0, LocalBitmap)
end;

procedure TfrPreviewThumb.ResizeGoban;
var
  aWidth, aHeight : integer;
begin
  aWidth  := CurrentImage.Width;
  aHeight := CurrentImage.Height;

  LocalGoban.Resize(aWidth, aHeight);

  with LocalGoban.BoardView as TBoardViewCanvas do
    begin
      CurrentImage.Picture.Bitmap.Width  := ExtWidth;
      CurrentImage.Picture.Bitmap.Height := ExtHeight;
      CurrentImage.Left   := CurrentImage.Left + (aWidth  - ExtWidth ) div 2;
      CurrentImage.Top    := CurrentImage.Top  + (aHeight - ExtHeight) div 2;
      CurrentImage.Width  := ExtWidth;
      CurrentImage.Height := ExtHeight
    end
end;

// -- Display of pattern frame for DB search display

procedure TfrPreviewThumb.ShowPattern(view : TViewBoard);
begin
  ShowSearchPattern(view.gb, LocalView.kh)
end;

// -- Display ----------------------------------------------------------------

procedure TfrPreviewThumb.DoWhenShowing(synchroWithIndex : boolean;
                                        start : boolean = False);
var
  n, i, j, k : integer;
  prevNRow, prevNCol : integer;
begin
  // avoid accessing to view during creation
  if LocalView = nil
    then exit;

  //MilliTimer;

  // force dimensions of image in background
  imImage.Width := pnThumbs.Width;
  imImage.Height := pnThumbs.Height;
  imImage.Picture.Bitmap.Width := pnThumbs.Width;
  imImage.Picture.Bitmap.Height := pnThumbs.Height;

  // update view background
  Settings.WinBackground.Apply(imImage.Canvas, ControlRect(imImage));

  // number of games to display
  n := NumberToDisplay;

  // configure dimensions
  prevNRow  := GIdxNRow;
  prevNCol  := GIdxNCol;
  GIdxWidth := 19 * (2 * GIdxRadius + 1 + 1) - 1;
  GIdxNCol  := (pnThumbs.Width  - HorzOffset) div (GIdxWidth + HorzDelta);
  GIdxNRow  := (pnThumbs.Height - VertOffset) div (GIdxWidth + VertDelta);
  GIdxNCol  := EnsureRange(1, thMaxCol, GIdxNCol);
  GIdxNRow  := EnsureRange(1, thMaxRow, GIdxNRow);
  GIdxNImg  := GIdxNCol * GIdxNRow;

  // update visibility when dimensions change
  //if (GIdxNRow <> prevNRow) or (GIdxNCol <> prevNCol) then
    for i := 0 to thMaxRow - 1 do
      for j := 0 to thMaxCol - 1 do
        ShowBoard(i, j, (i < GIdxNRow) and (j < GIdxNCol));

  // exit if no board to display
  if GIdxNimg = 0
    then exit;

  //CurrentGame := LocalView.si.IndexTree;
  CurrentGame := OriginView.si.IndexTree;
  if synchroWithIndex
    then TopLeftGame := ((CurrentGame - 1) div GIdxNImg) * GIdxNImg + 1;

  // update scrollbar
  ScrollBar.Min := 1;
  ScrollBar.Max := Max(1, n);
  ScrollBar.Position := TopLeftGame;
  ScrollBar.SmallChange := GIdxNImg;
  ScrollBar.LargeChange := GIdxNImg;

  // find number of moves to be displayed
  depth := Settings.NbMovesIndex;
(*
  if depth < 0 then
    case Settings.ModePosIndex of
      piInitial : depth := 0;
      piFinal   : depth := MaxMoveNumber;
      piInter   : depth := Settings.NbMovesIndex
    end;
*)

  for i := 0 to GIdxNRow - 1 do
    for j := 0 to GIdxNCol - 1 do
      begin
        // game index of current board
        k := TopLeftGame + i * GIdxNCol + j;

        // continue if no game to display, or display board and label
        if k > n
          then ShowBoard(i, j, False)
          else
            begin
              DisplayBoard(i, j, k, depth);
              LbArray[i, j].Caption := NthCaption(k);
              //LbArray[i, j].Caption := FirstHit(xgv.cl.Hits[k], xgv.cl[k])
            end
        end;

  UpdateCursor;
  //Trace(Format('Display page : %d', [MilliTimer]));
end;

// -- Graphic cursor update

procedure TfrPreviewThumb.UpdateCursor;
var
  i, j, y, x : integer;
begin
  // hide cursor
  imCursor.Visible := False;
  if ImArray[CurrentBoard.Y, CurrentBoard.X].Visible
    then BvArray[CurrentBoard.Y, CurrentBoard.X].Visible := True;

  // test if current game is visible
  if not Within(CurrentGame, TopLeftGame, TopLeftGame + GIdxNImg - 1)
    then exit;

  // compute top left coordinates
  i := (CurrentGame - TopLeftGame) div GIdxNCol;
  j := (CurrentGame - TopLeftGame) mod GIdxNCol;
  BoardTopLeft(i, j, y, x);

  // display cursor
  imCursor.Visible := True;
  imCursor.Left    := x - 2;
  imCursor.Top     := y - 2;
  BvArray[i, j].Visible := not True;
  CurrentBoard := Point(j, i)
end;

// == Commands ===============================================================

// not used
procedure TfrPreviewThumb.SelectGame(k : integer);
begin
  //ChangeEvent(xgv, k, seMain, snHit);
  //fmMain.SelectView(vmBoard);
  //ChangeEvent(xgv, k, seMain, snHit);
end;

// == Events =================================================================

// -- Resizing events --------------------------------------------------------

procedure TfrPreviewThumb.FrameResize(Sender: TObject);
begin
  DoWhenShowing(kSynchroWithIndex)
end;

// -- Mouse wheel events -----------------------------------------------------

procedure TfrPreviewThumb.FrameMouseWheelChange(newTopLeft : integer;
                                                var Handled: Boolean);
var
  maxTopLeft : integer;
begin
  Handled := True;
  maxTopLeft := ((NumberToDisplay - 1) div GIdxNImg) * GIdxNImg + 1;
  newTopLeft := Max(1, Min(maxTopLeft, newTopLeft));

  if (newTopLeft <> TopLeftGame) and (newTopLeft <= NumberToDisplay) then
    begin
      TopLeftGame := newTopLeft;
      DoWhenShowing(not kSynchroWithIndex)
    end
end;

procedure TfrPreviewThumb.FrameMouseWheelUp(Sender: TObject;
            Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  FrameMouseWheelChange(TopLeftGame - GIdxNImg, Handled)
end;

procedure TfrPreviewThumb.FrameMouseWheelDown(Sender: TObject;
            Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  FrameMouseWheelChange(TopLeftGame + GIdxNImg, Handled)
end;

// -- Scrollbar events -------------------------------------------------------

procedure TfrPreviewThumb.ScrollBarScroll(Sender     : TObject;
                                          ScrollCode : TScrollCode;
                                          var ScrollPos : Integer);
var
  newTopLeft : integer;
begin
  ScrollBar.Visible := False;  // to avoid scrollbar cursor blinking
  ScrollBar.Visible := True;   // (W2K)

  newTopLeft := ((ScrollPos - 1) div GIdxNImg) * GIdxNImg + 1;

  if (newTopLeft <> TopLeftGame) and (newTopLeft <= NumberToDisplay) then
    begin
      TopLeftGame := newTopLeft;
      DoWhenShowing(not kSynchroWithIndex)
    end
end;

// == Actions ================================================================

function TfrPreviewThumb.IsInCurrentPage(index : integer) : boolean;
begin
  Result := TopLeftGame = ((index - 1) div GIdxNImg) * GIdxNImg + 1
end;

procedure TfrPreviewThumb.UpdateCurrentGame(index : integer);
begin
  LocalView.si.IndexTree := index;
  LocalView.gt := LocalView.cl[index];
  LocalView.si.FileName  := LocalView.cl.FileName[index];
  OriginView.si.IndexTree := index;
  OriginView.gt := LocalView.cl[index];
  OriginView.si.FileName  := LocalView.cl.FileName[index];
  CurrentGame := index;

  if IsInCurrentPage(index)
    then UpdateCursor
    else DoWhenShowing(kSynchroWithIndex)
end;

// -- Click on boards

procedure TfrPreviewThumb.ImageClick(Sender : TObject);
var
  k : integer;
begin
  k := GameOnImage(Sender);

  if Within(k, 1, NumberToDisplay) then
    begin
      UpdateCurrentGame(k);
      LocalView.UpdateGameOnBoard(k)
    end
end;

procedure TfrPreviewThumb.ImageDoubleClick(Sender : TObject);
var
  k : integer;
begin
  k := GameOnImage(Sender);

  if Within(k, 1, NumberToDisplay) then
    begin
      UpdateCurrentGame(k);
      LocalView.ShowGameOnBoard(k)
    end
end;

// -- Navigation among games

procedure TfrPreviewThumb.FirstGame;
begin
  UpdateCurrentGame(1)
end;

procedure TfrPreviewThumb.LastGame;
begin
  UpdateCurrentGame(NumberToDisplay)
end;

procedure TfrPreviewThumb.PrevGame;
begin
  if LocalView.si.IndexTree > 1
    then UpdateCurrentGame(LocalView.si.IndexTree - 1)
end;

procedure TfrPreviewThumb.NextGame;
begin
  if LocalView.si.IndexTree < NumberToDisplay
    then UpdateCurrentGame(LocalView.si.IndexTree + 1)
end;

procedure TfrPreviewThumb.GotoGame(index : integer);
begin
  UpdateCurrentGame(index)
end;

// -- Position selection

procedure TfrPreviewThumb.StartPos;
begin
  Settings.NbMovesIndex := 0;
  Settings.ModePosIndex := piInitial;
  Increments := '[';
  DoWhenShowing(not kSynchroWithIndex)
end;

procedure TfrPreviewThumb.EndPos;
begin
  Settings.NbMovesIndex := -1;
  Settings.ModePosIndex := piFinal;
  Increments := ']';
  DoWhenShowing(not kSynchroWithIndex)
end;

procedure TfrPreviewThumb.PrevMove;
begin
  if Settings.NbMovesIndex <> 0
    then Settings.NbMovesIndex := Settings.NbMovesIndex - 1;
  Settings.ModePosIndex := piInter;
  Increments := Increments + '-';
  DoWhenShowing(not kSynchroWithIndex)
end;

procedure TfrPreviewThumb.NextMove;
begin
  if Settings.NbMovesIndex <> -1
    then Settings.NbMovesIndex := Settings.NbMovesIndex + 1;
  Settings.ModePosIndex := piInter;
  Increments := Increments + '+';
  DoWhenShowing(not kSynchroWithIndex)
end;

procedure TfrPreviewThumb.SelectMove(n : integer);
begin
  Settings.NbMovesIndex := n;
  Settings.ModePosIndex := piInter;
  Settings.NbMovesIndex := n;
  Increments := '';
  depth := n;
  DoWhenShowing(not kSynchroWithIndex)
end;

// == Display utilities ======================================================

// -- Dimensions of graphic area

procedure TfrPreviewThumb.SetDimOfGraphArea(var h, w : integer);
begin
  h := GIdxNRow * (GIdxWidth + VertDelta) + 2 * VertOffset;
  w := GIdxNCol * (GIdxWidth + HorzDelta) + 2 * HorzOffset
end;

// -- Top left coordinates of i,j board

procedure TfrPreviewThumb.BoardTopLeft(i, j : integer; var top, left : integer);
begin
  top  := i * (GIdxWidth + VertDelta) + VertOffset;
  left := j * (GIdxWidth + HorzDelta) + HorzOffset
end;

function TfrPreviewThumb.GameOnImage(Sender : TObject) : integer;
var
  i, j : integer;
begin
  Result := -1;
  
  for i := 0 to GIdxNRow - 1 do
    for j := 0 to GIdxNCol - 1 do
      if ImArray[i, j] = Sender then
        begin
          Result := TopLeftGame + i * GIdxNCol + j;
          exit
        end
end;

// ---------------------------------------------------------------------------

function TfrPreviewThumb.NumberToDisplay : integer;
begin
  Result := LocalView.cl.Count
end;

function TfrPreviewThumb.NthGameTree(k : integer) : TGameTree;
begin
  Result := LocalView.cl[k]
end;

function TfrPreviewThumb.NthCaption(k : integer) : shortstring;
begin
  Result := IntToStr(k)
end;

// -- Bounded increments -----------------------------------------------------
//
// increments is a string made of '+' and '-'. The function applies in
// sequence these increments while staying in the range [0, max].

function BoundedIncrement(n, max : integer; increments : string) : integer;
var
  i : integer;
begin
  Result := n;

  for i := 1 to Length(increments) do
    case increments[i] of
      '+' : if Result < max
              then inc(Result);
      '-' : if Result > 0
              then dec(Result);
      else // nop
    end
end;

// ---------------------------------------------------------------------------

end.
