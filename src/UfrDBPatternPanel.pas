// ---------------------------------------------------------------------------
// -- Drago -- Frame for pattern search in DB ------- UfrDBPatternPanel.pas --
// ---------------------------------------------------------------------------

unit UfrDBPatternPanel;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Controls, ImgList, Forms, Graphics,
  ExtCtrls, StdCtrls, ComCtrls,
  TntStdCtrls, TntForms, TntExtCtrls,
  UfrDBPatternResult,
  TB2Toolbar, TB2Dock, TB2Item, SpTBXItem;

type
  TfrDBPatternPanel = class(TTntFrame)
    ilParam: TImageList;
    pnBackground: TTntPanel;
    Panel1: TTntPanel;
    Bevel1: TBevel;
    frResults: TfrDBPatternResult;
    pnButtons: TTntPanel;
    Label4: TTntLabel;
    Label5: TTntLabel;
    cbFixedPos: TTntCheckBox;
    cbFixedColor: TTntCheckBox;
    cbBlack: TTntCheckBox;
    cbWhite: TTntCheckBox;
    pnPatternSettings: TPanel;
    SpTBXToolbar1: TSpTBXToolbar;
    SpTBXLabelItem1: TSpTBXLabelItem;
    btNextBlack: TSpTBXItem;
    btNextWhite: TSpTBXItem;
    btNextBoth: TSpTBXItem;
    btNextAlternate: TSpTBXItem;
    SpTBXToolbar2: TSpTBXToolbar;
    SpTBXRightAlignSpacerItem1: TSpTBXRightAlignSpacerItem;
    SpTBXItem5: TSpTBXItem;
    procedure cbFixedColorClick(Sender: TObject);
    procedure cbFixedPosClick(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
    var Accept: Boolean);
    procedure cbSearchInDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure cbBlackClick(Sender: TObject);
    procedure cbWhiteClick(Sender: TObject);
    procedure BoardThumbbtCaptureClick(Sender: TObject);
    procedure BoardThumbbtClearClick(Sender: TObject);
    procedure NextMoveClick(Sender: TObject);
  private
    RowsInList : integer;
    procedure SetNextMoveButtons;
  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;
    procedure Initialize;
    procedure Capture(i1, j1, i2, j2 : integer); overload;
    procedure InitSearch;
    procedure StartSearch(var ok : boolean);
    procedure TerminateSearch(Sender: TObject);
    procedure DoWhenUpdating;
    procedure EnableEditing(mode : boolean);
    procedure EnableSelection(enable : boolean);
  end;

procedure PatternSearchMsgProc(const s : WideString);

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils,
  Define, DefineUi, Translate, TranslateVcl, UfmDBSearch, Main, UDatabase,
  UStatus, UGoban,
  UGameTree, 
  GameUtils;

{$R *.dfm}

// -- Creation of frame ------------------------------------------------------

constructor TfrDBPatternPanel.Create(aOwner : TComponent);
begin
  inherited Create(aOwner);
  //Initialize
end;

procedure TfrDBPatternPanel.Initialize;
var
  DBNextMove : integer;
begin
(*
  BoardThumb.Align := alNone;
  BoardThumb.Height := Splitter1.Top;
  BoardThumb.Align := alClient;
*)
  Name := '';
  RowsInList := 4;

(*
  PickerCaption.CheckBox := False;
  PickerCaption.Caption := U('Pattern(right-click to select)');
  //DBBaseNamePicker.Initialize;
  BoardThumb.Initialize(smPattern);
  Splitter1.Minimize;
  Splitter1.Visible := False;
  PickerCaption.Visible := False;
*)
  pnButtons.Visible := False;

  frResults.Initialize;
(*
  with fmMain.ActiveView do
    BoardThumb.Capture(gb, gb.iMinView, gb.jMinView,
                       gb.iMaxView, gb.jMaxView);
  fmDBSearch.NotifyThumbnailChange;
*)
  DBSearchContext.IsThumbPattern := False;
  RowsInList := 5;
  frResults.RowsInList(RowsInList);

  // set player mode (avoiding to change status during setting)
  DBNextMove      := Settings.DBNextMove;
  cbBlack.Checked := DBNextMove in [Black, Both];
  cbWhite.Checked := DBNextMove in [White, Both];
  SetNextMoveButtons;

  // set anchor modes
  cbFixedColor.Checked := Settings.DBFixedColor;
  cbFixedPos  .Checked := Settings.DBFixedPos;

  TranslateComponent(SpTBXToolbar1);
  TranslateComponent(SpTBXToolbar2);
  SpTBXToolbar2.Left := Self.Width - 8 - SpTBXToolbar2.Width;

  //frResults.DisplayResults(DBSearchContext.kh)
end;

procedure TfrDBPatternPanel.DoWhenUpdating;
begin
end;

// -- Destruction of frame ---------------------------------------------------

destructor TfrDBPatternPanel.Destroy;
begin
(*
  Settings.DBPatSplitter := Splitter1.Top;
  BoardThumb.Finalize;
*)
  frResults.Finalize;

  inherited Destroy
end;

// -- Resizing ---------------------------------------------------------------

procedure TfrDBPatternPanel.Splitter1CanResize(Sender: TObject;
                                   var NewSize: Integer; var Accept: Boolean);
begin
  // NewSize is the height of frResults
  // keep minimal height for board thumb and results
  Accept := ((panel1.Height - NewSize) > 2*pnButtons.Height) and (NewSize > 2*pnButtons.Height);
  // TODO: finalize
  Accept := True
end;

// -- Capture and display of thumbnail ---------------------------------------

procedure TfrDBPatternPanel.Capture(i1, j1, i2, j2 : integer);
begin
(*
  BoardThumb.Capture(fmMain.ActiveView.gb, i1, j1, i2, j2)
*)
end;

procedure TfrDBPatternPanel.BoardThumbbtCaptureClick(Sender: TObject);
begin
(*
  BoardThumb.btCaptureClick(Sender);
*)
  DBSearchContext.IsThumbPattern := False;
end;

// -- Search start and terminate events --------------------------------------

procedure TfrDBPatternPanel.InitSearch;
begin
  fmMain.ActiveView.gb.HideSearchMarks(False);
(*
  BoardThumb.mygb.HideSearchMarks(False)
*)
end;

procedure PatternSearchMsgProc(const s : WideString);
begin
  fmDBSearch.ShowStatusMsg(U(s))
end;

procedure TfrDBPatternPanel.StartSearch(var ok : boolean);
var
  gb : TGoban;
  gt : TGameTree;
begin
(*
  DoPatternSearch(BoardThumb.mygb, DBSearchContext.kh,
                  BoardThumb.mygb.iMinData, BoardThumb.mygb.jMinData,
                  BoardThumb.mygb.iMaxData, BoardThumb.mygb.jMaxData,
                  PatternSearchMsgProc,
                  ok);
*)
  gb := fmMain.ActiveView.gb;
  gt := fmMain.ActiveView.gt;

  if gb.FLastRect.Top = 0
    then
      begin
        ok := False;
        PatternSearchMsgProc('No rectangle defined in current view.')
      end
    else
      DoPatternSearch(gb, DBSearchContext.kh,
                      gb.FLastRect.Top, gb.FLastRect.Left,
                      gb.FLastRect.Bottom, gb.FLastRect.Right,
                      NextPlayer(gt),
                      PatternSearchMsgProc,
                      ok)
end;

procedure TfrDBPatternPanel.TerminateSearch(Sender: TObject);
var
  gb : TGoban;
  s, signature : string;
  searchGameTree : TGameTree;
  index : integer;
begin
  signature := GetSignature(fmMain.ActiveView.gt);
  searchGameTree := fmMain.ActiveView.gt.Root.Copy;
  s := fmMain.ActiveView.gt.StepsToNode;
(*
  EndPatternSearch(fmMain.ActiveView, BoardThumb.mygb,
                   BoardThumb.mygb.iMinData, BoardThumb.mygb.jMinData,
                   BoardThumb.mygb.iMaxData, BoardThumb.mygb.jMaxData);
*)
(* moved
  gb := fmMain.ActiveView.gb;
  EndPatternSearch(fmMain.ActiveView, nil, //BoardThumb.mygb,
                  gb.FLastRect.Top, gb.FLastRect.Left,
                  gb.FLastRect.Bottom, gb.FLastRect.Right);

  frResults.DisplayResults(DBSearchContext.kh);
*)
(*
  if ActiveDBTab.TabView.cl.Count = 0
    then ActiveDBTab.TabView.si.ViewMode := vmInfo
    else ActiveDBTab.TabView.si.ViewMode := vmThumb
*)

  CurrentEntriesToCollection(DBSearchContext.DBTab.ViewBoard, '', '', 1);
  fmMain.InvalidateView(DBSearchContext.DBTab, vmAll);

  with DBSearchContext do
    if DBTab = CallingTab //DB//
      then // nop
        begin
          index := FindGameInCollection(searchGameTree, DBTab.TabView.cl);
          DBTab.TabView.si.IndexTree := index;
          DBTab.TabView.gt := DBTab.TabView.cl[index];
          DBTab.TabView.GotoNode(DBTab.TabView.gt.Root.NodeAfterSteps(s));
        end
      else
        if DBTab.TabView.cl.Count = 0
          then fmMain.SelectView(DBTab, vmInfo)
          else fmMain.SelectView(DBTab, vmThumb);

  gb := fmMain.ActiveView.gb;
  EndPatternSearch(fmMain.ActiveView, nil, //BoardThumb.mygb,
                  gb.FLastRect.Top, gb.FLastRect.Left,
                  gb.FLastRect.Bottom, gb.FLastRect.Right);

  frResults.DisplayResults(DBSearchContext.kh);
  searchGameTree.FreeGameTree
end;

// -- Enabling of thumbnail selection ----------------------------------------

procedure TfrDBPatternPanel.EnableSelection(enable : boolean);
begin
(*
  with BoardThumb do
    if enable
      then imGoban.OnMouseMove := imGobanMouseMove
      else imGoban.OnMouseMove := nil
*)
end;

// -- Check box events -------------------------------------------------------

procedure TfrDBPatternPanel.cbFixedColorClick(Sender: TObject);
begin
  Settings.DBFixedColor := cbFixedColor.Checked
end;

procedure TfrDBPatternPanel.cbFixedPosClick(Sender: TObject);
begin
  Settings.DBFixedPos := cbFixedPos.Checked
end;

procedure TfrDBPatternPanel.cbBlackClick(Sender: TObject);
begin
  if (not cbBlack.Checked) and (not cbWhite.Checked)
    then (Sender as TTntCheckbox).Checked := True;

  if cbBlack.Checked
    then
      if cbWhite.Checked
        then Settings.DBNextMove := Both
        else Settings.DBNextMove := Black
    else Settings.DBNextMove := White
end;

procedure TfrDBPatternPanel.cbWhiteClick(Sender: TObject);
begin
  cbBlackClick(Sender)
end;

procedure TfrDBPatternPanel.EnableEditing(mode : boolean);
begin

end;

procedure TfrDBPatternPanel.NextMoveClick(Sender: TObject);
begin
  case (Sender as TSpTBXItem).Tag of
    0 : Settings.DBNextMove := Black;
    1 : Settings.DBNextMove := White;
    2 : Settings.DBNextMove := pcBoth;
    3 : Settings.DBNextMove := pcAlternate;
  end;
end;

procedure TfrDBPatternPanel.SetNextMoveButtons;
begin
  // remove alternate button if not set manually in config
  btNextAlternate.Visible := Settings.DBNextMove = pcAlternate;
  
  case Settings.DBNextMove of
    Black : btNextBlack.Checked := True;
    White : btNextWhite.Checked := True;
    pcBoth : btNextBoth.Checked := True;
    pcAlternate : btNextAlternate.Checked := True;
  end;
end;

// -- Item drawing in combo boxes --------------------------------------------

procedure TfrDBPatternPanel.cbSearchInDrawItem(Control: TWinControl;
                         Index: Integer; Rect: TRect; State: TOwnerDrawState);
(*
var
  cb : TComboBox;
  x, y, x1, x2 : integer;
*)
begin
(*
  cb := Control as TComboBox;
  x := Rect.Left;
  y := Rect.Top + (cb.ItemHeight - ilParam.Height) div 2;
  x1 := x;
  x2 := x + ilParam.Width;

  with cb.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(Rect);
      TextOut(Rect.Left + 24, Rect.Top, cb.Items[Index])
    end;

  if cb = cbNext then
    with ilParam do
      case Index of
        0 : begin
              Draw(cb.Canvas, x1, y, 0);
              Draw(cb.Canvas, x2, y, 1)
            end;
        1 : Draw(cb.Canvas, x1, y, 0);
        2 : Draw(cb.Canvas, x1, y, 1);
      end;
*)
end;

// ---------------------------------------------------------------------------

procedure TfrDBPatternPanel.BoardThumbbtClearClick(Sender: TObject);
begin
(*
  BoardThumb.btClearClick(Sender);
*)
end;

// ---------------------------------------------------------------------------

end.
