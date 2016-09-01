// ---------------------------------------------------------------------------
// -- Drago -- Dialog to set annotation properties ---------- UfmInsert.pas --
// ---------------------------------------------------------------------------

unit UfmInsert;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Controls, Forms,
  StdCtrls, ExtCtrls,
  TntForms, TntStdCtrls, SpTBXControls, TntComCtrls,
  Properties, UViewBoard, UfrViewBoard, ComCtrls, Classes, SpTBXItem;

type
  TfmInsert = class(TTntForm)
    PageControl: TTntPageControl;
    TabSheet1: TTntTabSheet;
    TabSheet2: TTntTabSheet;
    TabSheet3: TTntTabSheet;
    mmComment: TTntMemo;
    gbPosition: TSpTBXGroupBox;
    Bevel1: TBevel;
    pnPosition: TPanel;
    cb_GB1: TTntCheckBox;
    cb_GB2: TTntCheckBox;
    cb_GW1: TTntCheckBox;
    cb_GW2: TTntCheckBox;
    CB_DM1: TTntCheckBox;
    cb_DM2: TTntCheckBox;
    cb_UC1: TTntCheckBox;
    cb_UC2: TTntCheckBox;
    pnHotSpot: TPanel;
    cb_HO1: TTntCheckBox;
    cb_HO2: TTntCheckBox;
    gbMove: TSpTBXGroupBox;
    cb_BM1: TTntCheckBox;
    cb_BM2: TTntCheckBox;
    cb_DO: TTntCheckBox;
    cb_IT: TTntCheckBox;
    cb_TE1: TTntCheckBox;
    cb_TE2: TTntCheckBox;
    gbAutres: TSpTBXGroupBox;
    ed_MN: TEdit;
    cb_WV: TTntCheckBox;
    cb_MN: TTntCheckBox;
    gbTiming: TSpTBXGroupBox;
    edBL: TEdit;
    edWL: TEdit;
    cb_BL: TTntCheckBox;
    cb_WL: TTntCheckBox;
    GroupBox1: TSpTBXGroupBox;
    ed_FGName: TEdit;
    cb_FG: TTntCheckBox;
    cb_FGName: TTntCheckBox;
    cb_FGCoord: TTntCheckBox;
    btOk: TTntButton;
    btAnnuler: TTntButton;
    btAide: TTntButton;
    Label3: TTntLabel;
    Label4: TTntLabel;
    Label1: TTntLabel;
    Label2: TTntLabel;
    edNodeName: TTntEdit;
    procedure FormShow(Sender: TObject);
    procedure FormShowFigure(Sender: TObject);
    procedure ShowTimeLeft(pr : TPropId; const pv : string; cb : TCheckBox; ed : TEdit);
    function  ValidateTimeLeft(cb : TTntCheckBox; ed : TEdit; var t : integer) : boolean;
    function  ValidateMN(var n : integer) : boolean;
    procedure FormCreate(Sender: TObject);
    procedure cb_GB1Click(Sender: TObject);
    procedure btAnnulerClick(Sender: TObject);
    procedure btAideClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure UpdateFG;
    procedure cb_MNClick(Sender: TObject);
    procedure cb_BLClick(Sender: TObject);
    procedure cb_WLClick(Sender: TObject);
    procedure cb_FGClick(Sender: TObject);
    procedure cb_FGNameClick(Sender: TObject);
    procedure OkCheckBoxPair(pr : TPropId; cb1, cb2 : TTntCheckBox);
    procedure UpdateProperty(checked : boolean; pr : TPropId; const newPv : string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function  GetActiveView : TViewBoard;
    function  GetActiveFrame : TfrViewBoard;
    property  ActiveView : TViewBoard read GetActiveView;
    property  ActiveFrame : TfrViewBoard read GetActiveFrame;
  public
    class procedure Execute;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils,
  DefineUi, Std, Translate, TranslateVcl, Ux2y, Main, UGameTree, UApply,
  UGMisc, UStatusMain, VclUtils,
  HtmlHelpAPI, Ugcom, UTreeView;

{$R *.dfm}

// -- Display request --------------------------------------------------------

class procedure TfmInsert.Execute;
begin
  with TfmInsert.Create(Application) do
    try
      // open only if current view is a TViewBoard
      if fmMain.ActiveView is TViewBoard
        then ShowModal
    finally
      Release
    end
end;

// -- Helpers ----------------------------------------------------------------

function TfmInsert.GetActiveView : TViewBoard;
begin
  Result := fmMain.ActiveView as TViewBoard
end;

function TfmInsert.GetActiveFrame : TfrViewBoard;
begin
  Result := ActiveView.frViewBoard
end;

// -- Creation ---------------------------------------------------------------

procedure TfmInsert.FormCreate(Sender : TObject);
var
  dum, lib1, lib2 : string;
  i, typ, act : integer;
  cb : TTntCheckBox;
begin
  for i := 0 To ComponentCount - 1 do
    begin
      if Components[i] is TSpTBXGroupBox
        then (Components[i] as TSpTBXGroupBox).Color := $FDFCFC;

      if Components[i] is TTntCheckBox then
        begin
          cb := TTntCheckBox(Components[i]);

          if AnsiStartsStr('cb_FG', cb.Name)
            then continue;

          if (cb <> cb_FG) and (cb <> cb_WV) and (cb <> cb_MN) and
             (cb <> cb_BL) and (cb <> cb_WL)
            then cb.OnClick := cb_GB1.OnClick;

          FindPropDef(PropertyIndex(Copy(cb.Name, 4, 2)), typ, act, dum, lib1, lib2);
          if (Length(cb.name) = 5) or (cb.Name[6] = '1')
            then cb.Caption := U(lib1)
            else cb.Caption := U(lib2)
        end
    end;

  Label3.Color := gbPosition.Color;
  Label4.Color := gbPosition.Color;

  PageControl.ActivePage := PageControl.Pages[0]
end;

// -- Display of form --------------------------------------------------------

procedure TfmInsert.FormShow(Sender: TObject);
var
  i : integer;
  x : TCheckBox;
  pr : TPropId;
  pn, pv, s : string;
begin
  Caption := AppName + ' - ' + U('Insert');
  TranslateForm(self);
  SetWinStrPosition(self, StatusMain.fmInsertPlace);

  // Updates of CheckBoxes less figure
  for i := 0 To ComponentCount - 1 do
    if Components[i] is TTntCheckBox then
      begin
        x  := TCheckBox(Components[i]);

        // Ignore figure
        if AnsiStartsStr('cb_FG', x.Name)
          then continue;

        pn := Copy(x.Name, 4, 2);
        pr := PropertyIndex(pn);
        pv := Copy(x.Name, 6, 1); // empty if single
        s  := ActiveView.gt.GetProp(pr);

        if s = ''
          then x.Checked := False
          else x.Checked := pv = pv2str(s);

        if pr = prMN then
          begin
            x.Checked := s <> '';
            ed_MN.Enabled := s <> '';
            if s = ''
              then ed_MN.Text := IntToStr(ActiveView.gb.NumWithOffset)
              else ed_MN.Text := pv2str(s)
          end;

        if pr = prBL
          then ShowTimeLeft(prB, s, x, edBL);
        if pr = prWL
          then ShowTimeLeft(prW, s, x, edWL);
      end;

  // update node name
  pv := ActiveView.gt.GetProp(prN);
  edNodeName.Text := CPDecode(pv2txt(pv), ActiveView.si.GameEncoding);

  // update comment
  mmComment.Clear;
  pv := ActiveView.gt.GetProp(prC);
  UpdateMemoComment(mmComment, CPDecode(pv2txt(pv), ActiveView.si.GameEncoding));

  // update figure property
  FormShowFigure(Sender)
end;

procedure TfmInsert.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StatusMain.fmInsertPlace := GetWinStrPlacement(self)
end;

// -- Update of figure controls

procedure TfmInsert.FormShowFigure(Sender: TObject);
var
  pv, name : string;
  n : integer;
begin
  cb_FGName.Enabled   := False;
  ed_FGName.Enabled   := False;
  cb_FGCoord.Enabled  := False;
  ed_FGName.Text      := '';

  pv := ActiveView.gt.GetProp(prFG);
  cb_FG.Checked := pv <> '';
  if cb_FG.Checked then
    begin
      cb_FGName.Enabled  := True;
      ed_FGName.Enabled  := True;
      cb_FGCoord.Enabled := True;
      pv2ns(pv, n, name);

      cb_FGCoord.Checked := n mod 2 = 1;
      cb_FGName.Checked  := (n shr 1) mod 2 = 1;
      if cb_FGName.Checked
        then ed_FGName.Text := name
    end
end;

// -- Update of time left controls

procedure TfmInsert.ShowTimeLeft(pr : TPropId; const pv : string; cb : TCheckBox; ed : TEdit);
begin
  if ActiveView.gt.GetProp(pr) = ''
    then
      begin
        cb.Checked := False;
        cb.Enabled := False;
        ed.Enabled := False;
        ed.Text := ''//'__:__:__'
      end
    else
      begin
        cb.Checked := pv <> '';
        cb.Enabled := True;
        ed.Enabled := cb.Checked;
        if cb.Checked
          then ed.Text := SecToTime(pv2real(pv))
          else ed.Text := ''//'__:__:__'
      end
end;

// -- Events -----------------------------------------------------------------

// -- Check box Annotations

procedure TfmInsert.cb_GB1Click(Sender : TObject);
var
  i : integer;
begin
  if (Sender as TTntCheckBox).Checked then
    for i := 0 To ComponentCount - 1 do
      if (Components[i] <> Sender) and (Components[i] is TTntCheckBox) then
        with Components[i] as TTntCheckBox do
          if Parent = (Sender as TTntCheckBox).Parent // gbPosition
            then Checked := False
end;

// -- Check box Time left

procedure TfmInsert.cb_BLClick(Sender : TObject);
begin
  edBL.Enabled := cb_BL.Checked
end;

procedure TfmInsert.cb_WLClick(Sender: TObject);
begin
  edWL.Enabled := cb_WL.Checked
end;

// -- Check box Figure

procedure TfmInsert.cb_FGClick(Sender: TObject);
begin
  cb_FGName.Enabled  := cb_FG.Checked;
  cb_FGCoord.Enabled := cb_FG.Checked;
  cb_FGName.Checked  := False;
  cb_FGCoord.Checked := False;
  ed_FGName.Enabled  := False;
  ed_FGName.Text     := ''
end;

procedure TfmInsert.cb_FGNameClick(Sender: TObject);
begin
  ed_FGName.Enabled  := cb_FGName.Checked;
  ed_FGName.Text     := '';
end;

// -- Check box Move number

procedure TfmInsert.cb_MNClick(Sender : TObject);
begin
  ed_MN.Enabled := cb_MN.Checked
end;

// -- OK button --------------------------------------------------------------

procedure TfmInsert.btOkClick(Sender: TObject);
var
  tB, tW, n : integer;
  HadMN : boolean;
begin
  if not ValidateTimeLeft(cb_BL, edBL, tB) then exit;
  if not ValidateTimeLeft(cb_WL, edWL, tW) then exit;
  if not ValidateMN      (n)               then exit;

  HadMN := ActiveView.gt.HasProp(prMN);

  ApplyNode(ActiveView, Undo);

  OkCheckBoxPair(prGB, cb_GB1, cb_GB2);
  OkCheckBoxPair(prGW, cb_GW1, cb_GW2);
  OkCheckBoxPair(prDM, cb_DM1, cb_DM2);
  OkCheckBoxPair(prUC, cb_UC1, cb_UC2);
  OkCheckBoxPair(prHO, cb_HO1, cb_HO2);
  OkCheckBoxPair(prBM, cb_BM1, cb_BM2);
  OkCheckBoxPair(prTE, cb_TE1, cb_TE2);

  UpdateProperty(cb_DO.Checked, prDO, '[]');
  UpdateProperty(cb_IT.Checked, prIT, '[]');
  UpdateProperty(cb_WV.Checked, prWV, '[]');
  UpdateProperty(cb_BL.Checked, prBL, int2pv(tB));
  UpdateProperty(cb_WL.Checked, prWL, int2pv(tW));
  UpdateProperty(cb_MN.Checked, prMN, int2pv(n));

  // update game tree when inserting MN property
  if cb_MN.Checked or (cb_MN.Checked <> HadMN)
    then LoadTreeView(ActiveView, ActiveView.gt, ActiveFrame.sbTreeV.Position,
                                                 ActiveFrame.sbTreeH.Position);

  // update figure
  UpdateFG;

  // update comment
  ActiveFrame.mmComment.Lines := mmComment.Lines;
  InputComments(ActiveView);

  // update node name
  ActiveFrame.edNodeName.Text := edNodeName.Text;
  InputNodeName(ActiveView);

  Close;
  ApplyNode(ActiveView, Enter)
end;

// -- Check time left format

function TfmInsert.ValidateTimeLeft(cb : TTntCheckBox;
                                    ed : TEdit;
                                    var t : integer) : boolean;
begin
  Result := True;
  if not cb.Checked
    then exit;
  t := TimeToSec(ed.Text);
  if t < 0 then
    begin
      PageControl.ActivePage := PageControl.Pages[2];
      ActiveControl := ed;
      Result := False
    end
end;

// -- Check move number format

function TfmInsert.ValidateMN(var n : integer) : boolean;
begin
  Result := TryStrToInt(ed_MN.Text, n);
  if not Result then
    begin
      PageControl.ActivePage := PageControl.Pages[2];
      ActiveControl := ed_MN
    end
end;

// -- Update property

procedure TfmInsert.UpdateProperty(checked : boolean; pr : TPropId; const newPv : string);
var
  pv : string;
begin
  pv := fmMain.ActiveView.gt.GetProp(pr);

  if not checked
    then
      if pv = ''
        then exit
        else
          if not fmMain.ActiveView.AllowModification
            then exit
            else fmMain.ActiveView.gt.RemProp(pr)
    else
      if (pv = '') or (newPv <> pv)
        then
          if not fmMain.ActiveView.AllowModification
            then exit
            else fmMain.ActiveView.gt.PutProp(pr, newPv);

  fmMain.ActiveView.si.FileSave := False
end;

// -- Update pair of check boxes

procedure TfmInsert.OkCheckBoxPair(pr : TPropId; cb1, cb2 : TTntCheckBox);
begin
  UpdateProperty(cb1.Checked or cb2.Checked, pr, iff(cb1.Checked, '[1]', '[2]'))
end;

// -- Update figures

procedure TfmInsert.UpdateFG;
var
  pv : string;
begin
  if not cb_FG.Checked
    then pv := ''
    else
      if (not cb_FGCoord.Checked) and (not cb_FGName.Checked)
        then pv := '[]'
        else pv := ns2pv(ord(cb_FGCoord.Checked)
                         + ord(cb_FGName.Checked) * 2
                         + 4   // list move shown
                         + 256 // don't remove capture stones
                         + 0,  // hoshis shown
                    ed_FGName.Text);

  UpdateProperty(cb_FG.Checked, prFG, pv)
end;

// -- Cancel button ----------------------------------------------------------

procedure TfmInsert.btAnnulerClick(Sender: TObject);
begin
  Close
end;

// -- Help button ------------------------------------------------------------

procedure TfmInsert.btAideClick(Sender: TObject);
begin
  HtmlHelpShowContext(IDH_SGF)
end;

// ---------------------------------------------------------------------------

end.
