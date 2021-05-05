// ---------------------------------------------------------------------------
// -- Drago -- Display of pattern search results --- UfrDBPatternResult.pas --
// ---------------------------------------------------------------------------

unit UfrDBPatternResult;

// ---------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Contnrs, ImgList, Math, Types,
  TntForms, TntStdCtrls,
  SpTBXControls, SpTBXItem, ComCtrls, TntHeaderCtrl,
  UKombilo, UfrDBPickerCaption;

type
  // declaration of local descendant of TKombiloContinuation
  TCont = class(TKContinuation)
    frequency, urgency, efficiency : double;  // semicolon mandatory here!
  end;

type
  TfrDBPatternResult = class(TTntFrame)
    bvButtons: TBevel;
    pnResults: TPanel;
    lbVariation: TListBox;
    pnHeader: TPanel;
    pnViewButtons: TPanel;
    PickerCaption: TfrDBPickerCaption;
    Label1: TTntLabel;
    rbDigest: TSpTBXRadioButton;
    rbFull: TSpTBXRadioButton;
    rbKombilo: TSpTBXRadioButton;
    DigestHeader: TTntHeaderControl;
    btLabel: TSpTBXSpeedButton;
    btPlayer: TSpTBXSpeedButton;
    btEfficiency: TSpTBXSpeedButton;
    btUrgency: TSpTBXSpeedButton;
    btFrequency: TSpTBXSpeedButton;
    Bevel1: TBevel;
    ImageList: TImageList;
    procedure btLabelClick(Sender: TObject);
    procedure btPlayerClick(Sender: TObject);
    procedure btFrequencyClick(Sender: TObject);
    procedure btUrgencyClick(Sender: TObject);
    procedure btEfficiencyClick(Sender: TObject);
    procedure lbVariationDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure FrameResize(Sender: TObject);
    procedure FrameCanResize(Sender: TObject; var NewWidth,
    NewHeight: Integer; var Resize: Boolean);
  private
    kh : TKGameList;
    SepConts : TObjectList;
    procedure rbKombiloClick(Sender: TObject);
    procedure rbFullClick(Sender: TObject);
    procedure rbDigestClick(Sender: TObject);

    procedure DrawCellFrame(rect : TRect; x1, x2 : integer);
    procedure DrawCellFrames(rect : TRect; X : TIntegerDynArray);
    procedure DrawValue(s : string; rec : TRect; x1, x2, color : integer); overload;
    procedure DrawValue(n : integer; rec : TRect; x1, x2, color : integer); overload;
    procedure DrawPercent(x : double; rec : TRect; x1, x2, color : integer);

    procedure DrawKombiloItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
    procedure DrawKombiloEmpty(Rect : TRect; State : TOwnerDrawState);
    procedure DrawKombiloHeader(rec  : TRect; State : TOwnerDrawState);
    procedure DrawKombiloContinuation(cont : TCont; Rect : TRect; State : TOwnerDrawState);
    procedure DisplayKombiloBars(ratioBar, ratioB, ratiotB, ratioW, ratiotW : real;
                                 rec : TRect; x1, x2 : integer);
    procedure CalculateKombiloWidths(var X : TIntegerDynArray);

    procedure DrawDetailedItem(Index : Integer; Rect  : TRect; State : TOwnerDrawState);
    procedure DrawDetailedEmpty(Rect : TRect; State : TOwnerDrawState);
    procedure DrawDetailedHeader(Rect : TRect; State : TOwnerDrawState);
    procedure DrawDetailedContinuation(cont : TKContinuation; Rect : TRect; State : TOwnerDrawState);
    procedure CalculateDetailedWidths(var X : TIntegerDynArray);

    procedure InitDigestHeader;
    procedure DrawDigestItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
    procedure DrawDigestEmpty(index : integer; Rect : TRect; State : TOwnerDrawState);
    procedure DrawDigestContinuation(cont : TCont; Rect : TRect; State : TOwnerDrawState);
    procedure DrawDigestStone(player : integer; rec : TRect; x1, x2 : integer);
    procedure DrawDigestGauge(x : real; rec : TRect; x1, x2 : integer);
    procedure CalculateDigestWidths(var X : TIntegerDynArray);

    procedure DimListBox(n : integer);
  public
    procedure Initialize;
    procedure Finalize;
    procedure DisplayResults(akh : TKGameList);
    procedure ClearResults;
    procedure RowsInList(n : integer);
    procedure MakeSepConts;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  TntGraphics,
  DefineUi, Std, VclUtils, Translate, UStatus;

{$R *.dfm}

const
  NumberOfEmptyLines = 5;

// ---------------------------------------------------------------------------

procedure TfrDBPatternResult.Initialize;
begin
  AvoidFlickering([pnViewButtons]);

//  // set button events now (crash when set at design time (?))
//  rbKombilo.OnClick := rbKombiloClick;
//  rbFull.OnClick    := rbFullClick;
//  rbDigest.OnClick  := rbDigestClick;

  InitDigestHeader;
  kh := nil;
  if SepConts = nil
    then SepConts := TObjectList.Create;
  PickerCaption.CheckBox := False;
  PickerCaption.Caption := U('Results');

//  // check current search view mode
//  case Settings.DBSearchView of
//    svKombilo : rbKombilo.Checked := True;
//    svFull    : rbFull   .Checked := True;
//    svDigest  : rbDigest .Checked := True;
//  end;

  AvoidFlickering([pnResults]);
  lbVariation.DoubleBuffered := True;
  pnViewButtons.Visible := False;
  //lbVariation.Visible := False;

  DimListBox(NumberOfEmptyLines)
end;

procedure TfrDBPatternResult.Finalize;
begin
//  // store search view mode
//  if rbFull.Checked
//    then Settings.DBSearchView := svFull
//    else
//      if rbDigest.Checked
//        then Settings.DBSearchView := svDigest
//        else Settings.DBSearchView := svKombilo;

  FreeAndNil(SepConts)
end;

// -- Resizing ---------------------------------------------------------------

procedure TfrDBPatternResult.FrameCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize := True //NewHeight > lbVariation.Top + 2 * lbVariation.ItemHeight
            //       + Panel1.Height + 24
end;

procedure TfrDBPatternResult.FrameResize(Sender: TObject);
begin
  //pnResults.Height := ClientHeight - (lbVariation.Top + DBPickerCaption.Height + 24)
  pnHeader.Visible := Settings.DBSearchView = svDigest;
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.RowsInList(n : integer);
begin
  //pnResults.Height := n * lbVariation.ItemHeight;
  //ClientHeight := lbVariation.Top + pnResults.Height + PickerCaption.Height + 24
end;

// ---------------------------------------------------------------------------

procedure TfrDBPatternResult.DisplayResults(akh : TKGameList);
begin
  kh := akh;

  pnHeader.Visible := Settings.DBSearchView = svDigest;
  DigestHeader.Visible := False; //Settings.DBSearchView = svDigest;
  
  case Settings.DBSearchView of
    svKombilo : if Assigned(kh)
                  then DimListBox(Max(NumberOfEmptyLines, kh.Continuations.Count + 1));
    svFull    : if Assigned(kh)
                  then DimListBox(Max(NumberOfEmptyLines, kh.Continuations.Count + 1));
    svDigest  : MakeSepConts;
  end;

  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.ClearResults;
begin
  //assert(Assigned(SepConts), 'Debug DBS');
  if Assigned(SepConts)
    then SepConts.Clear;
  DimListBox(NumberOfEmptyLines);
  lbVariation.Invalidate
end;

// -- Display of results in list box -----------------------------------------

const
  offT = 4;

// -- View mode button events

procedure TfrDBPatternResult.rbKombiloClick(Sender: TObject);
begin
  // kh is assigned by DoPatternSearch
  if Assigned(kh)
    then DimListBox(kh.Continuations.Count + 1);

  Settings.DBSearchView := svKombilo;
  pnHeader.Visible := False;
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.rbFullClick(Sender: TObject);
begin
  // kh is assigned by DoPatternSearch
  if Assigned(kh)
    then DimListBox(kh.Continuations.Count + 1);

  Settings.DBSearchView := svFull;
  pnHeader.Visible := False;
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.rbDigestClick(Sender: TObject);
begin
  // create list of continuations with separated colors
  MakeSepConts;

  Settings.DBSearchView := svDigest;
  pnHeader.Visible := True;
  lbVariation.Invalidate
end;

// -- Draw item event --------------------------------------------------------

procedure TfrDBPatternResult.lbVariationDrawItem(Control : TWinControl;
                                                 Index : Integer;
                                                 Rect  : TRect;
                                                 State : TOwnerDrawState);
begin
  case Settings.DBSearchView of
    svKombilo :
      DrawKombiloItem(Index, Rect, State);
    svFull :
      DrawDetailedItem(Index, Rect, State);
    svDigest :
      DrawDigestItem(Index, Rect, State)
  end
end;

// -- Helpers for draw item event --------------------------------------------

// Draw single cell

procedure TfrDBPatternResult.DrawCellFrame(rect : TRect; x1, x2 : integer);
begin
  with lbVariation.Canvas do
    begin
      Brush.Color := clLtGray;
      FrameRect(Types.Rect(x1, rect.Top-1, x2, rect.Bottom));
    end
end;

// Draw all cells in line

procedure TfrDBPatternResult.DrawCellFrames(rect : TRect; X : TIntegerDynArray);
var
  i : integer;
begin
  // erase rectangle
  lbVariation.Canvas.Brush.Color := clWhite;
  lbVariation.Canvas.FillRect(rect);

  // draw cell borders
  for i := 0 to High(X) - 1 do
    DrawCellFrame(Rect, X[i], X[i + 1] + 1)
end;

// Draw values

procedure TfrDBPatternResult.DrawValue(s : string;
                                       rec : TRect;
                                       x1, x2, color : integer);
begin
  with lbVariation.Canvas do
    begin
      Font.Name := 'Arial';
      Font.Size := 8;
      while TextWidth(s) + (4 + 2) > (x2 - x1 - 1) do
        Font.Size := Font.Size - 1;
      Brush.Color := color;
      TextOut(x1 + 4, rec.Top + offT, s)
    end
end;

procedure TfrDBPatternResult.DrawValue(n : integer;
                                       rec : TRect;
                                       x1, x2, color : integer);
begin
  if n < 0
    then DrawValue(' - '       , rec, x1, x2, color)
    else DrawValue(IntToStr(n), rec, x1, x2, color)
end;

procedure TfrDBPatternResult.DrawPercent(x : double;
                                         rec : TRect;
                                         x1, x2, color : integer);
begin
  if x < 0
    then DrawValue(' - ', rec, x1, x2, color)
    else DrawValue(Format('%1.1f', [100 * x]), rec, x1, x2, color)
end;

// -- Display of results in Kombilo mode -------------------------------------

procedure TfrDBPatternResult.DrawKombiloItem(Index : Integer;
                                             Rect  : TRect;
                                             State : TOwnerDrawState);
begin
  if Index = 0
    then DrawKombiloHeader(Rect, State)
    else
      if not TKGameList.Registered(kh) or (Index > kh.Continuations.Count)
        then DrawKombiloEmpty(Rect, State)
        else DrawKombiloContinuation(kh.Continuations[Index - 1], Rect, State)
end;

// Calculate widths of columns

procedure TfrDBPatternResult.CalculateKombiloWidths(var X : TIntegerDynArray);
var
  w1, w2, w3 : integer;
begin
  SetLength(X, 6);

  with lbVariation.Canvas do
    begin
      Font.Name := 'Arial';
      Font.Size := 8;
      w1 := TextWidth(' A ');
      w2 := TextWidth(' 99999 ');
      w3 := TextWidth(' 100.0 ');
    end;

  X[0] := 0;
  X[1] := w1;
  X[2] := w1 + w2;
  X[3] := w1 + w2 + w3;
  X[4] := w1 + w2 + w3 + w3;
  X[5] := lbVariation.ClientWidth - 1
end;

// Display header

procedure TfrDBPatternResult.DrawKombiloHeader(rec : TRect; State : TOwnerDrawState);
var
  numHits, numSwitched, Bwins, Wwins : integer;
  s : WideString;
begin
  if not TKGameList.Registered(kh)
    then numHits := 0
    else kh.StatHits(numHits, numSwitched, Bwins, Wwins);

  if numHits = 0
    then s := WideFormat(U('%d matches'), [numHits])
    else s := WideFormat(U('%d matches (%d/%d), B: %1.1f%%, W: %1.1f%%'),
                          [numHits,
                           numHits - numSwitched, numSwitched,
                           Bwins / numHits * 100, Wwins / numHits * 100]);

  with lbVariation.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(rec);
      Brush.Color := clLtGray;
      FrameRect(Rect(rec.Left, rec.Top, rec.Right, rec.Bottom));
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;

  WideCanvasTextOut(lbVariation.Canvas, rec.Left + 2, rec.Top + offT, s)
end;

// Display continuation

procedure TfrDBPatternResult.DrawKombiloContinuation(cont  : TCont;
                                              Rect  : TRect;
                                              State : TOwnerDrawState);
var
  X : TIntegerDynArray;
  nBW, nMaxBW : integer;
  winB, winW, ratioBar, ratioB, ratiotB, ratioW, ratiotW : real;
begin
  CalculateKombiloWidths(X);
  DrawCellFrames(rect, X);

  if cont.W = 0 then winW := -1 else winW := cont.wW / cont.W;
  if cont.B = 0 then winB := -1 else winB := cont.wB / cont.B;

  with TCont(kh.Continuations[0]) do
    nMaxBW := B + W;

  nBW      := cont.B + cont.W;
  ratioBar := nBW / nMaxBW;
  ratioB   := (cont.B - cont.tB) / nBW;
  ratiotB  := cont.tB / nBW;
  ratioW   := (cont.W - cont.tW) / nBW;
  ratiotW  := cont.tW / nBW;

  DrawValue  (cont.labl, Rect, X[0], X[1] + 1, clWhite);
  DrawValue  (nBW      , Rect, X[1], X[2] + 1, clWhite);
  DrawPercent(winW     , Rect, X[2], X[3] + 1, clWhite);
  DrawPercent(winB     , Rect, X[3], X[4] + 1, clWhite);
  DisplayKombiloBars(ratioBar, ratioB, ratiotB, ratioW, ratiotW, Rect, X[4], X[5] + 1)
end;

// Display empty item

procedure TfrDBPatternResult.DrawKombiloEmpty(Rect  : TRect;
                                              State : TOwnerDrawState);
var
  X : TIntegerDynArray;
begin
  CalculateKombiloWidths(X);
  DrawCellFrames(rect, X)
end;

// Display bars

procedure TfrDBPatternResult.DisplayKombiloBars(ratioBar, ratioB, ratiotB, ratioW, ratiotW : real;
                                                rec : TRect;
                                                x1, x2 : integer);
var
  wBar, top, bottom, a, b : integer;
begin
  with lbVariation.Canvas do
    begin
      wBar := Round(((x2 - 5) - (x1 + 5) + 1) * ratioBar);

      top    := rec.Top    + 6;
      bottom := rec.Bottom - 6;

      a := x1 + 5;
      b := a + Round(wBar * ratiotB);
      Brush.Color := clDkGray;
      FillRect(Rect(a, top, b, bottom));

      a := b;
      b := a + Round(wBar * ratioB);
      Brush.Color := clBlack;
      FillRect(Rect(a, top, b, bottom));

      a := b;
      b := a + Round(wBar * ratioW);
      Brush.Color := clWhite;
      FillRect(Rect(a, top, b, bottom));

      a := b;
      b := a + Round(wBar * ratiotW);
      Brush.Color := clLtGray;
      FillRect(Rect(a, top, b, bottom));

      Brush.Color := clBlack;
      FrameRect(Rect(x1 + 4, top - 1, x1 + 4 + wBar + 2, bottom + 1));
    end
end;

// -- Display of results in full mode ----------------------------------------

procedure TfrDBPatternResult.DrawDetailedItem(Index : Integer;
                                              Rect  : TRect;
                                              State : TOwnerDrawState);
begin
  if Index = 0
    then DrawDetailedHeader(Rect, State)
    else
      if not TKGameList.Registered(kh) or (Index > kh.Continuations.Count)
        then DrawDetailedEmpty(Rect, State)
        else DrawDetailedContinuation(kh.Continuations[Index - 1], Rect, State);
end;

// Calculate widths of columns

procedure TfrDBPatternResult.CalculateDetailedWidths(var X : TIntegerDynArray);
var
  w1, w2, i : integer;
begin
  SetLength(X, 10);
  w1 := lbVariation.Canvas.TextWidth(' A ');
  w2 := (lbVariation.ClientWidth - w1) div 8;
  X[0] := 0;
  X[1] := w1;
  for i := 2 to 9 do
    X[i] := X[i - 1] + w2
end;

// Draw empty item

procedure TfrDBPatternResult.DrawDetailedEmpty(Rect  : TRect;
                                               State : TOwnerDrawState);
var
  X : TIntegerDynArray;
begin
  CalculateDetailedWidths(X);
  DrawCellFrames(rect, X)
end;

// Display of header

procedure TfrDBPatternResult.DrawDetailedHeader(Rect  : TRect;
                                                State : TOwnerDrawState);
var
  X : TIntegerDynArray;
  S : TStringDynArray;
  i : integer;
begin
  CalculateDetailedWidths(X);
  DrawCellFrames(rect, X);

  Split('|' + T('B|B/T|B+/B|B-/B|W|W/T|B+/W|B-/W'), S, '|');

  for i := 0 To 8 do
    DrawValue(S[i], Rect, X[i], X[i + 1] + 1, clWhite)
end;

// Display continuation

procedure TfrDBPatternResult.DrawDetailedContinuation(cont  : TKContinuation;
                                               Rect  : TRect;
                                               State : TOwnerDrawState);
var
  X : TIntegerDynArray;
  bb, bw : boolean;
begin
  CalculateDetailedWidths(X);
  DrawCellFrames(rect, X);

  bb := Settings.DBNextMove in [1, 3];
  bw := Settings.DBNextMove in [2, 3];

  DrawValue(cont.labl           , Rect, X[0], X[1], clWhite);
  DrawValue(iff(bb, cont.B , -1), Rect, X[1], X[2], clWhite);
  DrawValue(iff(bb, cont.tB, -1), Rect, X[2], X[3], clWhite);
  DrawValue(iff(bb, cont.wB, -1), Rect, X[3], X[4], clWhite);
  DrawValue(iff(bb, cont.lB, -1), Rect, X[4], X[5], clWhite);
  DrawValue(iff(bw, cont.W , -1), Rect, X[5], X[6], clWhite);
  DrawValue(iff(bw, cont.tW, -1), Rect, X[6], X[7], clWhite);
  DrawValue(iff(bw, cont.wW, -1), Rect, X[7], X[8], clWhite);
  DrawValue(iff(bw, cont.lW, -1), Rect, X[8], X[9], clWhite)
end;

// -- Display of results in digest form --------------------------------------

procedure TfrDBPatternResult.DrawDigestItem(Index : Integer;
                                            Rect  : TRect;
                                            State : TOwnerDrawState);
begin
  if Index = 0
    then InitDigestHeader;

  if not Assigned(SepConts)
    then exit;

  if not TKGameList.Registered(kh) or (Index >= SepConts.Count)
    then DrawDigestEmpty(Index, Rect, State)
    else DrawDigestContinuation(SepConts[Index] as TCont, Rect, State)
end;

// Calculate widths of columns

procedure TfrDBPatternResult.CalculateDigestWidths(var X : TIntegerDynArray);
var
  w, i : integer;
begin
  SetLength(X, 6);

  X[0] := 0;
  X[1] := lbVariation.Canvas.TextWidth(' W ');
  X[2] := X[1] + 18;

  w := (lbVariation.ClientWidth - X[2]) div 3;

  for i := 3 to 5 do
    X[i] := X[i - 1] + w
end;

// Display header

procedure TfrDBPatternResult.InitDigestHeader;
var
  X : TIntegerDynArray;
begin
  CalculateDigestWidths(X);

  pnHeader.ParentColor := False;
  pnHeader.ParentBackground := False;
  btLabel.Left       := 0;
  btLabel.Width      := X[1] + 1;
  btPlayer.Left      := btLabel.Left + btLabel.Width - 1;
  btPlayer.Width     := X[2] - X[1] + 1;
  btFrequency.Left   := btPlayer.Left + btPlayer.Width - 1;
  btFrequency.Width  := X[3] - X[2] + 2;
  btUrgency.Left     := btFrequency.Left + btFrequency.Width - 1;
  btUrgency.Width    := X[4] - X[3];
  btEfficiency.Left  := btUrgency.Left + btUrgency.Width - 1;
  btEfficiency.Width := ClientWidth - X[4];

  btFrequency .Font.Name := 'Arial';
  btUrgency   .Font.Name := 'Arial';
  btEfficiency.Font.Name := 'Arial';

  btFrequency .Caption := U('Frequency');
  btUrgency   .Caption := U('Urgency');
  btEfficiency.Caption := U('Efficiency');
end;

// Display empty item

procedure TfrDBPatternResult.DrawDigestEmpty(index : integer;
                                             Rect  : TRect;
                                             State : TOwnerDrawState);
var
  widths : TIntegerDynArray;
begin
  CalculateDigestWidths(widths);
  DrawCellFrames(rect, widths);

  lbVariation.Canvas.Brush.Color := clWhite;
  lbVariation.Canvas.Font.Color := clLtGray;
  if index = 0
    then
      WideCanvasTextOut(lbVariation.Canvas, rect.Left + 4, rect.Top + offT,
                        U('Right-click to select on board'));
  if index = 1
    then
      WideCanvasTextOut(lbVariation.Canvas, rect.Left + 4, rect.Top + offT,
                        U('Found games are in database tab'))
end;

// Display continuation

procedure TfrDBPatternResult.DrawDigestContinuation(cont  : TCont;
                                                    Rect  : TRect;
                                                    State : TOwnerDrawState);
var
  X : TIntegerDynArray;
  player : integer;
  frequency : real;
begin
  CalculateDigestWidths(X);
  DrawCellFrames(rect, X);

  // index in stone image list
  player := iff(cont.B > 0, 0, 1);

  // patch frequency to avoid displaying '0', will be displayed as '< 1'
  if Round(100 * cont.frequency) = 0
    then frequency := -cont.frequency
    else frequency := +cont.frequency;

  // draw cell contents
  DrawValue      (cont.labl      , Rect, X[0], X[1] + 1, clWhite);
  DrawDigestStone(player         , Rect, X[1], X[2] + 1);
  DrawDigestGauge(frequency      , Rect, X[2], X[3] + 1);
  DrawDigestGauge(cont.urgency   , Rect, X[3], X[4] + 1);
  DrawDigestGauge(cont.efficiency, Rect, X[4], X[5] + 1)
end;

// Draw stones

procedure TfrDBPatternResult.DrawDigestStone(player : integer; rec : TRect;
                                             x1, x2 : integer);
begin
  ImageList.Draw(lbVariation.Canvas,
                 (x1 + x2) div 2 - 4,
                 (rec.Bottom + rec.Top) div 2 - 4,
                  player);
end;

// Draw bars

procedure TfrDBPatternResult.DrawDigestGauge(x : real;
                                             rec : TRect;
                                             x1, x2 : integer);
var
  m, x3 : integer;
  s : string;
begin
  with lbVariation.Canvas do
    begin
      Font.Name := 'Arial';
      Font.Size := 7;
      x3 := x2 - 2 - TextWidth(' 100% ');
      m := (rec.Top + rec.Bottom) div 2;

      Brush.Color := $00840204;
      FrameRect(Rect(x1 + 2, m - 3, x3, m + 3));
      Brush.Color := $00008400;
      FillRect(Rect(x1 + 3, m - 2, x1 + 3 + Round(Abs(x) * (x3 - x1 - 4)), m + 2));

      if x < 0
        then s := '< 1'
        else s := IntToStr(Round(100 * x));

      Brush.Color := clWhite;
      TextOut(x3 + 2, rec.Top + offT + 1, s + '%')
    end
end;

// -- Header button events ---------------------------------------------------

function CompareCont_Label     (cont1, cont2 : pointer) : integer; forward;
function CompareCont_Player    (cont1, cont2 : pointer) : integer; forward;
function CompareCont_Frequency (cont1, cont2 : pointer) : integer; forward;
function CompareCont_Urgency   (cont1, cont2 : pointer) : integer; forward;
function CompareCont_Efficiency(cont1, cont2 : pointer) : integer; forward;

procedure TfrDBPatternResult.btLabelClick(Sender: TObject);
begin
  SepConts.Sort(CompareCont_Label);
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.btPlayerClick(Sender: TObject);
begin
  SepConts.Sort(CompareCont_Player);
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.btFrequencyClick(Sender: TObject);
begin
  SepConts.Sort(CompareCont_Frequency);
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.btUrgencyClick(Sender: TObject);
begin
  SepConts.Sort(CompareCont_Urgency);
  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.btEfficiencyClick(Sender: TObject);
begin
  SepConts.Sort(CompareCont_Efficiency);
  lbVariation.Invalidate
end;

// -- Sorting predicates -----------------------------------------------------

// -- B = 0 xor W = 0

// -- Sort on label

function CompareCont_Label(cont1, cont2 : pointer) : integer;
var
  c1, c2 : TCont;
begin
  c1 := TCont(cont1);
  c2 := TCont(cont2);

  if c1 = c2
    then Result := 0 // trap unexpected cases of equality
    else
      if c1.labl <> c2.labl
        then Result := Ord(c1.labl) - Ord(c2.labl)
        else Result := iff(c1.B > 0, -1, +1)
end;

// -- Sort on player

function CompareCont_Player(cont1, cont2 : pointer) : integer;
var
  c1, c2 : TCont;
begin
  c1 := TCont(cont1);
  c2 := TCont(cont2);

  if (c1.B > 0) = (c2.B > 0)
    then Result := Ord(c1.labl) - Ord(c2.labl)
    else Result := iff(c1.B > 0, -1, +1)
end;

// -- Sort on frequency

function CompareCont_Frequency(cont1, cont2 : pointer) : integer;
var
  c1, c2 : TCont;
begin
  c1 := TCont(cont1);
  c2 := TCont(cont2);

  if c1.frequency = c2.frequency
    then Result := Ord(c1.labl) - Ord(c2.labl)
    else Result := Sign(c2.frequency - c1.frequency)
end;

// -- Sort on urgency

function CompareCont_Urgency(cont1, cont2 : pointer) : integer;
var
  c1, c2 : TCont;
begin
  c1 := TCont(cont1);
  c2 := TCont(cont2);

  if c1.urgency = c2.urgency
    then Result := Ord(c1.labl) - Ord(c2.labl)
    else Result := Sign(c2.urgency - c1.urgency)
end;

// -- Sort on efficiency

function CompareCont_Efficiency(cont1, cont2 : pointer) : integer;
var
  c1, c2 : TCont;
begin
  c1 := TCont(cont1);
  c2 := TCont(cont2);

  if c1.efficiency = c2.efficiency
    then Result := Ord(c1.labl) - Ord(c2.labl)
    else Result := Sign(c2.efficiency - c1.efficiency)
end;

// -- Construction of continuation list with separated colors ----------------

procedure TfrDBPatternResult.MakeSepConts;
var
  i : integer;
  r : TCont;
begin
  if not Assigned(SepConts) then
    begin
      DimListBox(NumberOfEmptyLines); // create 5 empty slots
      exit
    end;

  SepConts.Clear;

  // kh is assigned by DoPatternSearch
  if Assigned(kh) then
    with kh do
      for i := 0 to Continuations.Count - 1 do
        with TKContinuation(Continuations[i]) do
          begin
            if B > 0 then
              begin
                r := TCont.Create;
                r.labl := labl;
                r.B := B;
                r.W := 0;
                r.tB := tB;
                r.wB := wB;
                r.lB := lB;
                r.frequency  := B / kh.NbMatches;
                r.urgency    := (B - tB) / B;
                r.efficiency := wB / B;
                SepConts.Add(r)
              end;
            if W > 0 then
              begin
                r := TCont.Create;
                r.labl := labl;
                r.B := 0;
                r.W := W;
                r.tW := tW;
                r.wW := wW;
                r.lW := lW;
                r.frequency  := W / kh.NbMatches;
                r.urgency    := (W - tW) / W;
                r.efficiency := lW / W;
                SepConts.Add(r)
              end
          end;

  SepConts.Sort(CompareCont_Frequency);

  // synchronize length of listbox with separate colors list
  if SepConts.Count = 0
    then DimListBox(NumberOfEmptyLines)
    else DimListBox(SepConts.Count)
end;

procedure TfrDBPatternResult.DimListBox(n : integer);
var
  i : integer;
begin
  lbVariation.Clear;
  for i := 0 to n - 1 do
    lbVariation.Items.Add('')
end;

// ---------------------------------------------------------------------------

end.

procedure TfrDBPatternResult.DigestHeaderSectionClick(
  HeaderControl: TTntHeaderControl; Section: TTntHeaderSection);
begin
  case Section.Index of
    0 : SepConts.Sort(CompareCont_Label);
    1 : SepConts.Sort(CompareCont_Player);
    2 : SepConts.Sort(CompareCont_Frequency);
    3 : SepConts.Sort(CompareCont_Urgency);
    4 : SepConts.Sort(CompareCont_Efficiency);
  end;

  lbVariation.Invalidate
end;

procedure TfrDBPatternResult.DigestHeaderDrawSection(
  HeaderControl: TTntHeaderControl; Section: TTntHeaderSection;
  const Rect: TRect; Pressed: Boolean);
begin
  with HeaderControl do
    begin
      Canvas.Brush.Color := clWhite;
      Canvas.FillRect(Rect);
      WideCanvasTextOut(Canvas, Rect.Left, Rect.Top, Section.Text)
    end
end;

// not used
procedure TfrDBPatternResult.ResizeDigestHeader(X : array of integer);
var
  i : integer;
begin
  // enable section resizing
  for i := 0 to 4 do
    begin
      DigestHeader.Sections[i].MinWidth := 0;
      DigestHeader.Sections[i].MaxWidth := 10000;
    end;

  // resize
  DigestHeader.Sections[0].Width := X[0] + 2;
  DigestHeader.Sections[1].Width := X[1] - X[0];
  DigestHeader.Sections[2].Width := X[2] - X[1];
  DigestHeader.Sections[3].Width := X[3] - X[2];
  DigestHeader.Sections[4].Width := DigestHeader.ClientWidth - X[3];

  // avoid section resizing
  for i := 0 to 4 do
    begin
      DigestHeader.Sections[i].MinWidth := DigestHeader.Sections[i].Width;
      DigestHeader.Sections[i].MaxWidth := DigestHeader.Sections[i].Width;
    end;
end;


