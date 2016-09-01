// ---------------------------------------------------------------------------
// -- Drago -- Form to input and display game information - UfmGameInfo.pas --
// ---------------------------------------------------------------------------

unit UfmGameInfo;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ImgList,
  TntForms, TntSystem, TntStdCtrls, TntComCtrls, SpTBXControls,
  UView, UGameTree, SpTBXItem;

type
  TfmGameInfo = class(TTntForm)
    PageControl: TTntPageControl;
    TabSheet1: TTntTabSheet;
    TabSheet2: TTntTabSheet;
    TabSheet3: TTntTabSheet;
    TabSheet4: TTntTabSheet;
    TabSheet5: TTntTabSheet;
    TabSheet6: TTntTabSheet;
    TabSheet7: TTntTabSheet;
    Panel2: TPanel;
    Label4: TTntLabel;
    lbEV: TTntLabel;
    lbGN: TTntLabel;
    Label3: TTntLabel;
    Label5: TTntLabel;
    Panel1: TPanel;
    Label1: TTntLabel;
    Label2: TTntLabel;
    Label6: TTntLabel;
    Label7: TTntLabel;
    Label8: TTntLabel;
    Panel3: TPanel;
    Label9: TTntLabel;
    Label10: TTntLabel;
    Label12: TTntLabel;
    Label13: TTntLabel;
    Label31: TTntLabel;
    imBlack: TImage;
    Label14: TTntLabel;
    Label15: TTntLabel;
    Label16: TTntLabel;
    Label17: TTntLabel;
    Label18: TTntLabel;
    Panel5: TPanel;
    Label22: TTntLabel;
    Label30: TTntLabel;
    Label25: TTntLabel;
    Label26: TTntLabel;
    Panel4: TPanel;
    ImageList: TImageList;
    imWhite: TImage;
    Panel6: TPanel;
    Label24: TTntLabel;
    Label27: TTntLabel;
    Label28: TTntLabel;
    lbResult: TTntLabel;
    lbMsg: TTntLabel;
    edPC: TTntEdit;
    edDT: TTntEdit;
    edRE: TTntEdit;
    edPW: TTntEdit;
    edPB: TTntEdit;
    edGN: TTntEdit;
    edEV: TTntEdit;
    edRO: TTntEdit;
    edPC2: TTntEdit;
    edDT2: TTntEdit;
    edPB2: TTntEdit;
    edPW2: TTntEdit;
    edWR: TTntEdit;
    edWT: TTntEdit;
    edBR: TTntEdit;
    edBT: TTntEdit;
    edRU: TTntEdit;
    ed_hr: TTntEdit;
    edOT: TTntEdit;
    edHA: TTntEdit;
    edKM: TTntEdit;
    ed_mn: TTntEdit;
    edTM: TTntEdit;
    edUS: TTntEdit;
    edAN: TTntEdit;
    edSO: TTntEdit;
    edCP: TTntEdit;
    edAP: TTntEdit;
    edFF: TTntEdit;
    btCancel: TTntButton;
    btOk: TTntButton;
    cbST: TTntComboBox;
    mmGC: TTntMemo;
    TntLabel1: TTntLabel;
    lbCa: TSpTBXLabel;
    Label19: TTntLabel;
    Label23: TTntLabel;
    Label11: TTntLabel;
    Label20: TTntLabel;
    Label21: TTntLabel;
    edCA: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure edPBChange(Sender: TObject);
    procedure edPWChange(Sender: TObject);
    procedure edPCChange(Sender: TObject);
    procedure edDTChange(Sender: TObject);
    procedure edPC2Change(Sender: TObject);
    procedure edDT2Change(Sender: TObject);
    procedure edPB2Change(Sender: TObject);
    procedure edPW2Change(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ed_hrChange(Sender: TObject);
    procedure edTMShow(Sender: TObject);
    procedure edREChange(Sender: TObject);
  private
    xgt : TGameTree;
    FEnabled : boolean;
    procedure Disable;
    procedure ClickWhenReadOnly(Sender: TObject);
    function  ActiveView : TView;
  public
    class function Execute(gt : TGameTree; aEnabled : boolean) : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, Ux2y, Properties, Main, Translate, TranslateVcl, UStatus, UGmisc,
  UApply, CodePages;

{$R *.DFM}

class function TfmGameInfo.Execute(gt : TGameTree; aEnabled : boolean) : boolean;
var
  r : TModalResult;
begin
  with TfmGameInfo.Create(Application) do
    try
      xgt := gt;
      FEnabled := aEnabled;
      r := ShowModal;
      Result := r <> mrCancel
    finally
      Release
    end
end;

function TfmGameInfo.ActiveView : TView;
begin
  Result := fmMain.ActiveView
end;

procedure TfmGameInfo.FormShow(Sender: TObject);
var
  gt, rt : TGameTree;
  i, i0  : integer;
  ed     : TTntEdit;
  ts     : TTntTabSheet;
  s      : string;
  pr     : TPropId;
begin
  gt := xgt;
  rt := gt.Root;

  Font.Name := Settings.AppFontName;
  Font.Size := Settings.AppFontSize;
  Caption   := AppName + ' - ' + U('Game information');
  TranslateForm(Self);

  i0 := 100;
  for i := 0 To ComponentCount - 1 do
    begin
      if Components[i] is TTntEdit then
        begin
          ed := TTntEdit(Components[i]);
          pr := FindPropIndex(Copy(ed.Name, 3, 2));
          if pr = prNone
            then continue;
          s  := pv2str(rt.GetProp(pr));
          if pr = prFF
            then
              if s = ''
                then ed.Text := ''
                else ed.Text := 'FF[' + s + ']'
            else ed.Text := DecodeProperty(pr, rt, ActiveView.si);
          ts := (ed.Parent as TPanel).Parent as TTntTabSheet
        end
      else
      if Components[i] is TTntMemo then
        begin
          s  := pv2str(rt.GetProp(prGC));
          mmGC.Text := MainDecode(s);
          ts := mmGC.Parent as TTntTabSheet
        end
      else
      if Components[i].Name = 'cbST' then
        begin
          s  := pv2str(rt.GetProp(prST));
          cbST.ItemIndex := StrToIntDef(s, -1) + 1;
          ts := (ed.Parent as TPanel).Parent as TTntTabSheet
        end
      else
      if Components[i].Name = 'edCA' then
        begin
          lbCA.Visible := False;
          s := pv2str(rt.GetProp(prCA));
          if s = ''
            then edCA.Text := 'Default'
            else
              if CPNameToId(s) = cpUnknown
                then
                  begin
                    edCA.Text := s;
                    lbCA.Visible := True
                  end
                else edCA.Text := CPIdToDescr(CPNameToId(s))
        end
      else
        s := '';

      if (s <> '') and (s <> ' ') and (ts.PageIndex < i0) // cf note
        then i0 := ts.PageIndex
    end;

  if i0 = 100
    then i0 := 0;
  PageControl.ActivePage := PageControl.Pages[i0];

  PageControlChange(Sender);
  edTMShow(Sender);

  lbMsg.Visible := False;
  lbMsg.Caption := U('Read only');
  if not FEnabled
    then Disable
end;

// -- Control of changes for displaying the '!' icon -------------------------

procedure TfmGameInfo.PageControlChange(Sender: TObject);
var
  i  : integer;
  ed : TEdit;
  ts : TTntTabSheet;
  s  : string;
begin
  for i := 0 To ComponentCount - 1 do
    if Components[i] is TTntTabSheet then
      (Components[i] as TTntTabSheet).ImageIndex := -1;

  for i := 0 To ComponentCount - 1 do
    begin
      if Components[i] is TEdit then
        begin
          ed := TEdit(Components[i]);
          s  := ed.Text;
          ts := (ed.Parent as TPanel).Parent as TTntTabSheet
        end
        else
      if Components[i] is TMemo then
        begin
          s  := mmGC.Text;
          ts := mmGC.Parent as TTntTabSheet
        end
        else
      if Components[i].Name = 'cbST' then
        begin
          s  := cbST.Items[cbST.ItemIndex];
          ts := (cbST.Parent as TPanel).Parent as TTntTabSheet
        end
        else s := '';

      if (s <> '') and (s <> ' ') // cf note at end of file
        then ts.ImageIndex := 0
    end;

  lbMsg.Visible := False
end;

// -- Control of changes -----------------------------------------------------

procedure TfmGameInfo.Disable;
var
  i : integer;
  s : string;
begin
  for i := 0 To ComponentCount - 1 do
    if Components[i] is TTntEdit then
      with Components[i] as TTntEdit do
      begin
        OnClick := ClickWhenReadOnly;
        OnEnter := ClickWhenReadOnly;
        ReadOnly := True
      end
    else
    if Components[i] is TTntMemo then
      with Components[i] as TTntMemo do
      begin
        OnClick := ClickWhenReadOnly;
        OnEnter := ClickWhenReadOnly;
        ReadOnly := True
      end
    else
    if Components[i].Name = 'cbST' then
      //with Components[i] as TComboBox do
      begin
        OnEnter := ClickWhenReadOnly;
        // no ReadOnly prop for combobox, so remove all but current item
        s := cbST.Text;
        cbST.Items.Clear;
        cbST.Items.Add(s);
        cbST.ItemIndex := 0
      end
end;

procedure TfmGameInfo.ClickWhenReadOnly(Sender: TObject);
begin
  lbMsg.Visible := True;
end;

// -- Ok button --------------------------------------------------------------

procedure TfmGameInfo.btOkClick(Sender : TObject);
var
  i  : integer;
  ed : TTntEdit;
  pn, pv : string;
  pr : TPropId;
  gt, rt : TGameTree;
begin
  gt := xgt;
  rt := gt.Root;

  for i := 0 To ComponentCount - 1 do
    begin
      if Components[i] is TTntEdit then
        begin
          ed := TTntEdit(Components[i]);
          pn := Copy(ed.Name, 3, 2);         // edXX names
          pr := PropertyIndex(pn);
          pv := ed.Text
        end
      else
      if Components[i] is TTntMemo then
        begin
          pr := prGC;                         // only one memo
          pv := mmGC.Text
        end
      else
      if Components[i].Name = 'cbST' then
        begin
          pr := prST;
          if cbST.ItemIndex = 0
            then pv := ''
            else pv := IntToStr(cbST.ItemIndex - 1)
        end
      else continue;

      // add escape char ('\') if required and convert to property value ([xx])
      if pv <> ''
        then pv := str2pv(PutEscChar(pv));

      // nop on ed_hr and ed_mn
      if pn[1] = '_'
        then continue;

      // nop on edFF
      if pr = prFF
        then continue;

      // nop if property value not changed
      if pv = AdjustLineBreaks(rt.GetProp(pr))
        then continue;

      // modified value found, confirm modification
      if not ActiveView.AllowModification then
        begin
          // modifications are not allowed, no need to proceed
          Close;
          exit
        end;

      // remove or put new value
      if pv = ''
        then rt.RemProp(pr)
        else rt.PutProp(pr, pv);

      // update UI if STyle has changed
      if pr = prST then
        begin
          ActiveView.ShowNextOrVars(Undo);
          ApplyST(ActiveView, Enter, pv);
          ActiveView.ShowNextOrVars(Enter)
        end;

      // update GameEncoding if ChArset has changed
      if pr = prCA then
        begin
          ApplyCA(ActiveView, Enter, pv);
          ActiveView.ReApplyNode
        end;

      // remind something has changed
      ActiveView.si.FileSave := False
    end;

  //Close
  ModalResult := mrOk
end;

// -- Cancel button ----------------------------------------------------------

procedure TfmGameInfo.btCancelClick(Sender: TObject);
begin
  Close
end;

// -- Update of result text label --------------------------------------------

procedure TfmGameInfo.edREChange(Sender: TObject);
begin
  lbResult.Caption := ResultToString(edRE.Text)
end;

// -- Update of duplicated fields --------------------------------------------

procedure TfmGameInfo.edPBChange(Sender: TObject);
begin
  edPB2.Text := edPB.Text
end;

procedure TfmGameInfo.edPWChange(Sender: TObject);
begin
  edPW2.Text := edPW.Text
end;

procedure TfmGameInfo.edPCChange(Sender: TObject);
begin
  edPC2.Text := edPC.Text
end;

procedure TfmGameInfo.edDTChange(Sender: TObject);
begin
  edDT2.Text := edDT.Text
end;

procedure TfmGameInfo.edPC2Change(Sender: TObject);
begin
  edPC.Text := edPC2.Text
end;

procedure TfmGameInfo.edDT2Change(Sender: TObject);
begin
  edDT.Text := edDT2.Text
end;

procedure TfmGameInfo.edPB2Change(Sender: TObject);
begin
  edPB.Text := edPB2.Text
end;

procedure TfmGameInfo.edPW2Change(Sender: TObject);
begin
  edPW.Text := edPW2.Text
end;

// -- Conversion of game time ------------------------------------------------

procedure TfmGameInfo.edTMShow(Sender: TObject);
var
  h, m, s : integer;
begin
  if edTM.Text <> '' then
    begin
      s := StrToIntDef(edTM.Text, 0);
      if s <> 0 then
        begin
          h := s div 3600;
          m := (s mod 3600) div 60;
          ed_hr.Text := Format('%2.2d', [h]);
          ed_mn.Text := Format('%2.2d', [m])
        end
    end
end;

procedure TfmGameInfo.ed_hrChange(Sender: TObject);
var
  h, m : integer;
begin
  h := StrToIntDef(ed_hr.Text, 0);
  m := StrToIntDef(ed_mn.Text, 0);
  ed_hr.Text := Format('%2.2d', [h]);
  ed_mn.Text := Format('%2.2d', [m]);
  edTM.Text  := IntToStr(h * 3600 + m * 60)
end;

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------

Note :

An error occurs if the first element (not checked for others) is ''. So, there
is ' ' in cbST and we test also the equality with ' ' for current tab
selection and display of '!'.

// ---------------------------------------------------------------------------



