// ---------------------------------------------------------------------------
// -- Drago -- Dialog to start problem session ----------- UfmProblems.pas --
// ---------------------------------------------------------------------------

unit UfmProblems;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Math,
  TntForms, TntStdCtrls, TntExtCtrls, SpTBXControls, SpTBXItem, SpTBXSkins,
  Grids, TntGrids, TB2Item, Menus;

type
  TfmProblems = class(TTntForm)
    rgMode: TSpTBXRadioGroup;
    rgMarkup: TSpTBXRadioGroup;
    pnNbPb: TSpTBXPanel;
    lbNbPb: TTntLabel;
    edNbPb: TTntEdit;
    cbRndPos: TSpTBXCheckBox;
    cbRndCol: TSpTBXCheckBox;
    StatBox: TSpTBXGroupBox;
    StatGrid: TTntStringGrid;
    SpTBXGroupBox1: TSpTBXGroupBox;
    btDontCare: TSpTBXRadioButton;
    btProportion: TSpTBXRadioButton;
    edFailureRatio: TEdit;
    lbIncFailure: TSpTBXLabel;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    btHelp: TSpTBXButton;
    btMore: TSpTBXButton;
    SpTBXPopupMenu1: TSpTBXPopupMenu;
    SpTBXItem1: TSpTBXItem;
    SpTBXItem2: TSpTBXItem;
    mnShow: TSpTBXSubmenuItem;
    mnShowGlyphs: TSpTBXItem;
    mnShowTimer: TSpTBXItem;
    procedure FormShow     (Sender: TObject);
    procedure btOkClick    (Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btHelpClick  (Sender: TObject);
    procedure btDontCareClick(Sender: TObject);
    procedure StatGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btShowStatClick(Sender: TObject);
    procedure btResetStatClick(Sender: TObject);
  private
    procedure ApplySettings;
    procedure UpdateSettings(numberOfProblems, failureRatio : integer);
    procedure ShowStatBox;
  public
    class function Execute : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  TntGraphics,
  DefineUi, Translate, TranslateVcl, HtmlHelpAPI, VclUtils, UStatus, Main,
  UGameColl, UMemo, UProblemUtil, UActions;

{$R *.DFM}

// ---------------------------------------------------------------------------

class function TfmProblems.Execute : boolean;
begin
  with TfmProblems.Create(Application) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release;
      Application.ProcessMessages
    end
end;

procedure TfmProblems.FormShow(Sender : TObject);
var
  i : integer;
begin
  Font.Name          := Settings.AppFontName;
  Font.Size          := Settings.AppFontSize;
  Caption            := AppName + ' - ' + U('Solve problems');
  TranslateForm(Self);

  rgMode  .SkinType  := sknWindows;
  rgMarkup.SkinType  := sknWindows;
  cbRndPos.SkinType  := sknWindows;
  cbRndCol.SkinType  := sknWindows;

  // solve string truncation problem in mode box
  for i := 0 to 2 do
    with rgMode.Controls[i] as TSpTBXRadioButton do
      Wrapping := twWrap;

  ShowStatBox;
  ApplySettings
end;

// -- Access to settings

procedure TfmProblems.ApplySettings;
begin
  rgMode.ItemIndex     := Settings.PbMode;
  edNbPb.Text          := IntToStr(Settings.PbNumber);
  rgMarkup.ItemIndex   := Settings.PbMarkup;
  cbRndPos.Checked     := Settings.PbRndPos;
  cbRndCol.Checked     := Settings.PbRndCol;
  btDontCare.Checked   := not Settings.PbUseFailureRatio;
  btProportion.Checked := not btDontCare.Checked;
  edFailureRatio.Text  := IntToStr(Settings.PbFailureRatio);
  mnShowTimer.Checked  := Status.PbShowTimer;
  mnShowGlyphs.Checked := Status.PbShowGlyphs
end;

procedure TfmProblems.UpdateSettings(numberOfProblems, failureRatio : integer);
begin
  Settings.PbMode   := rgMode.ItemIndex;
  Settings.PbNumber := EnsureRange(numberOfProblems, 1, fmMain.ActiveView.cl.Count);
  Settings.PbMarkup := rgMarkup.ItemIndex;
  Settings.PbRndPos := cbRndPos.Checked;
  Settings.PbRndCol := cbRndCol.Checked;
  Settings.PbUseFailureRatio := btProportion.Checked;
  Settings.PbFailureRatio := EnsureRange(failureRatio, 0, 100);
  Status.PbShowTimer  := mnShowTimer.Checked;
  Status.PbShowGlyphs := mnShowGlyphs.Checked
end;

// -- Display of statistic summary

procedure TfmProblems.ShowStatBox;
var
  n, nVisited, nTrials, nSuccess : integer;
begin
  StatGrid.Color := StatBox.Color;

  StatGrid.Cells[0,0] := U('Problems in collection');
  StatGrid.Cells[0,1] := U('Visited problems');
  StatGrid.Cells[0,2] := U('Number of attempts');
  StatGrid.Cells[0,3] := U('Number of successes');

  CollectionStatistics(fmMain.ActiveView.cl, n, nVisited, nTrials, nSuccess);

  StatGrid.Cells[1,0] := IntToStr(n);
  StatGrid.Cells[1,1] := IntToStr(nVisited);
  if n = 0
    then StatGrid.Cells[2,1] := '0.00%'
    else StatGrid.Cells[2,1] := Format('%2.2f%%', [100.0 * nVisited / n]);
  StatGrid.Cells[1,2] := IntToStr(nTrials);
  StatGrid.Cells[1,3] := IntToStr(nSuccess);
  if nTrials = 0
    then StatGrid.Cells[2,3] := '0.00%'
    else StatGrid.Cells[2,3] := Format('%2.2f%%', [100.0 * nSuccess / nTrials]);

  StatGrid.ColWidths[0] := Round((StatGrid.ClientWidth * 2) / 3);
  StatGrid.ColWidths[1] := Round(StatGrid.ColWidths[0] / 6);
  StatGrid.ColWidths[2] := StatGrid.ColWidths[1] + 20
end;

procedure TfmProblems.StatGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s : WideString;
  x : integer;
begin
  StatGrid.Canvas.Brush.Color := Color;
  StatGrid.Canvas.FillRect(rect);

  s := StatGrid.Cells[ACol, ARow];

  // right justify numerical values
  if ACol = 0
    then x := Rect.Left + 5
    else x := Rect.Left + StatGrid.ColWidths[ACol] - StatGrid.Canvas.TextWidth(s);

  //StatGrid.Canvas.TextOut(x, Rect.Top + 2, s)
  WideCanvasTextOut(StatGrid.Canvas, x, Rect.Top + 2, s)
end;

// -- Buttons

procedure TfmProblems.btShowStatClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Actions.acPbIndexExecute(nil)
end;

procedure TfmProblems.btResetStatClick(Sender: TObject);
begin
  ResetCollectionStatistics(fmMain.ActiveView.cl);
  ShowStatBox
end;

procedure TfmProblems.btDontCareClick(Sender: TObject);
begin
  edFailureRatio.Enabled := not btDontCare.Checked;
  lbIncFailure.Enabled := not btDontCare.Checked;
  if lbIncFailure.Enabled
    then lbIncFailure.Caption := '%'
end;

procedure TfmProblems.btOkClick(Sender : TObject);
var
  n1, n2 : integer;
begin
  if not ValidateNumEdit(self, edNbPb, n1)
    then exit;
  if not ValidateNumEdit(self, edFailureRatio, n2)
    then exit;

  UpdateSettings(n1, n2);

  ModalResult := mrOK
end;

procedure TfmProblems.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfmProblems.btHelpClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_ModePb)
end;

// ---------------------------------------------------------------------------

end.
