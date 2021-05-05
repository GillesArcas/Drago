// ---------------------------------------------------------------------------
// -- Drago -- Player picker for database request ----- UDBPlayerPicker.pas --
// ---------------------------------------------------------------------------

unit UDBPlayerPicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Controls,
  StdCtrls, UfrDBPickerCaption,
  TntForms, SpTBXControls, Forms, SpTBXItem;

type
  TDBPlayerPicker = class(TTntFrame)
    cbPlayerWhite: TComboBox;
    cbPlayerBlack: TComboBox;
    PickerCaption: TfrDBPickerCaption;
    Panel1: TSpTBXPanel;
    rbBlack: TSpTBXRadioButton;
    rbBoth: TSpTBXRadioButton;
    rbWinner: TSpTBXRadioButton;
    Panel2: TSpTBXPanel;
    rbWhite: TSpTBXRadioButton;
    rbBoth2: TSpTBXRadioButton;
    rbLoser: TSpTBXRadioButton;
    procedure rbBlackClick(Sender: TObject);
    procedure rbBothClick(Sender: TObject);
    procedure rbWinnerClick(Sender: TObject);
    procedure PickerCaptionClick(Sender: TObject);
    procedure cbPlayerBlackChange(Sender: TObject);
    procedure cbPlayerWhiteChange(Sender: TObject);
    procedure rbWhiteClick(Sender: TObject);
    procedure rbLoserClick(Sender: TObject);
    procedure rbBoth2Click(Sender: TObject);
  private
    procedure ChangeRequest;
  public
    procedure Default(aEnabled : boolean; pl : TStringList);
    function GetRequest : string;
    procedure Translate;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  SysUtils,
  Std, Translate, TranslateVcl, UfrDBRequestPanel;

var
  StrAny : string;

// -- Default configuration --------------------------------------------------

procedure TDBPlayerPicker.Default(aEnabled : boolean; pl : TStringList);
begin
  PickerCaption.CheckBox := True;
  PickerCaption.Caption := U('Search on players');

  StrAny := '-- ' + U('Any') + ' --';
  pl.Insert(0, StrAny);

  cbPlayerBlack.Items.Assign(pl);
  cbPlayerWhite.Items.Assign(pl);

  cbPlayerBlack.ItemIndex := 0;
  cbPlayerWhite.ItemIndex := 0;
  cbPlayerBlack.AutoDropDown := False;
  cbPlayerWhite.AutoDropDown := False;

  rbBlack.Checked := True;
  rbWhite.Checked := True;

  PickerCaption.Checked := aEnabled;
  PickerCaptionClick(nil);
  ChangeRequest;
  Invalidate;
end;

// -- Translation ------------------------------------------------------------

// Must avoid to translate the full list of players.

procedure TDBPlayerPicker.Translate;
begin
  TranslateTComponent(PickerCaption);
  TranslateTSpTBXRadioButton(rbBlack);
  TranslateTSpTBXRadioButton(rbWhite);
  TranslateTSpTBXRadioButton(rbBoth);
  TranslateTSpTBXRadioButton(rbBoth2);
  TranslateTSpTBXRadioButton(rbWinner);
  TranslateTSpTBXRadioButton(rbLoser);
  if cbPlayerBlack.Items.Count > 0
    then cbPlayerBlack.Items[0] := U(cbPlayerBlack.Items[0]);
  if cbPlayerWhite.Items.Count > 0
    then cbPlayerWhite.Items[0] := U(cbPlayerWhite.Items[0])
end;

// -- Enabling ---------------------------------------------------------------

procedure TDBPlayerPicker.PickerCaptionClick(Sender: TObject);
var
  checked : boolean;
begin
  inherited;
  /////SetFocus;
  checked := PickerCaption.Checked;
  rbBlack .Enabled := checked;
  rbWhite .Enabled := checked;
  rbBoth  .Enabled := checked;
  rbBoth2 .Enabled := checked;
  rbWinner.Enabled := checked;
  rbLoser .Enabled := checked;
  cbPlayerBlack.Enabled := checked;
  cbPlayerWhite.Enabled := checked;
  ChangeRequest
end;

// -- Construction of request ------------------------------------------------

function RequestPlayer(rq, player : string) : string;
begin
  if player = StrAny
    then Result := ''
    else Result := rq + ' like ' + AnsiQuotedStr('%' + player + '%', '''')
end;

function RequestBlackWhite(pb, pw : string) : string;
begin
  if (pb = StrAny) and (pw = StrAny)
    then Result := ''
    else Result := join(' AND ', [RequestPlayer('PB', pb),
                                  RequestPlayer('PW', pw)])
end;

function RequestBoth(pb, pw : string) : string;
begin
  if (pb = StrAny) and (pw = StrAny)
    then Result := ''
    else Result := join(' OR ', ['(' + RequestBlackWhite(pb, pw) + ')',
                                 '(' + RequestBlackWhite(pw, pb) + ')'])
end;

function RequestWinnerLoser(pb, pw : string) : string;
var
  r1, r2 : string;
begin
  if (pb = StrAny) and (pw = StrAny)
    then Result := ''
    else
      begin
        r1 := join(' AND ', [RequestPlayer('PB', pb),
                             RequestPlayer('PW', pw), 'RE like ''B%''']);
        r2 := join(' AND ', [RequestPlayer('PW', pb),
                             RequestPlayer('PB', pw), 'RE like ''W%''']);

        Result := '(' + r1 + ') OR (' + r2 + ')'
      end
end;

function TDBPlayerPicker.GetRequest : string;
var
  pb, pw : string;
begin
  pb := cbPlayerBlack.Text;
  pw := cbPlayerWhite.Text;

  if not PickerCaption.Checked
    then Result := ''
    else
      if rbBlack.Checked
        then Result := RequestBlackWhite(pb, pw)
        else
          if rbBoth.Checked
            then Result := RequestBoth(pb, pw)
            else Result := RequestWinnerLoser(pb, pw);

  if Result <> ''
    then Result := '(' + Result + ')'
end;

// -- Event handlers ---------------------------------------------------------

procedure TDBPlayerPicker.ChangeRequest;
begin
  (Parent as TfrDBRequestPanel).ChangeRequest
end;

procedure TDBPlayerPicker.rbBlackClick(Sender: TObject);
begin
  inherited;
  rbWhite.Checked := rbBlack.Checked;
  ChangeRequest
end;

procedure TDBPlayerPicker.rbBothClick(Sender: TObject);
begin
  inherited;
  rbBoth2.Checked := rbBoth.Checked;
  ChangeRequest
end;

procedure TDBPlayerPicker.rbWinnerClick(Sender: TObject);
begin
  inherited;
  rbLoser.Checked := rbWinner.Checked;
  ChangeRequest
end;

procedure TDBPlayerPicker.cbPlayerBlackChange(Sender: TObject);
begin
  ChangeRequest
end;

procedure TDBPlayerPicker.cbPlayerWhiteChange(Sender: TObject);
begin
  ChangeRequest
end;

procedure TDBPlayerPicker.rbWhiteClick(Sender: TObject);
begin
  rbBlack.Checked := rbWhite.Checked;
  ChangeRequest
end;

procedure TDBPlayerPicker.rbBoth2Click(Sender: TObject);
begin
  rbBoth.Checked := rbBoth2.Checked;
  ChangeRequest
end;

procedure TDBPlayerPicker.rbLoserClick(Sender: TObject);
begin
  rbWinner.Checked := rbLoser.Checked;
  ChangeRequest
end;

// ---------------------------------------------------------------------------

end.
