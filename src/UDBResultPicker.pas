// ---------------------------------------------------------------------------
// -- Drago -- Result picker for database request ----- UDBResultPicker.pas --
// ---------------------------------------------------------------------------

unit UDBResultPicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, Math,
  FloatSpinEdit, UfrDBPickerCaption, TntStdCtrls, TntForms;

type
  TDBResultPicker = class(TFrame)
    seScore: TFloatSpinEdit;
    lbDummy: TLabel;
    PickerCaption: TfrDBPickerCaption;
    cbPlayer: TTntComboBox;
    cbResult: TTntComboBox;
    procedure cbResultChange(Sender: TObject);
    procedure PickerCaptionClick(Sender: TObject);
    procedure cbPlayerChange(Sender: TObject);
    procedure seScoreChange(Sender: TObject);
  private
    procedure ChangeRequest;
  public
    procedure Default(aEnabled : boolean);
    function GetRequest : string;
  end;

// ---------------------------------------------------------------------------

implementation

uses Translate, UfrDBRequestPanel;

{$R *.dfm}

// -- Default configuration --------------------------------------------------

procedure TDBResultPicker.Default(aEnabled : boolean);
begin
  PickerCaption.CheckBox := True;
  PickerCaption.Caption := U('Search on result');

  cbPlayer.ItemIndex := 0;
  cbResult.ItemIndex := 0;
  seScore.Value := 0.5;
  cbResultChange(nil);

  PickerCaption.Checked := aEnabled;
  PickerCaptionClick(nil);
  Invalidate;
end;

// -- Enabling ---------------------------------------------------------------

procedure TDBResultPicker.PickerCaptionClick(Sender: TObject);
begin
  /////SetFocus;
  cbPlayer.Enabled := PickerCaption.Checked;
  cbResult.Enabled := PickerCaption.Checked;
  seScore .Enabled := PickerCaption.Checked;
  cbResultChange(Sender)
end;

// -- Construction of request ------------------------------------------------

function MakeAtLess(player : char; value : double) : string;
forward;
function MakeAtMost(player : char; value : double) : string;
forward;

function TDBResultPicker.GetRequest : string;
var
  player : char;
  score : string;
begin
  Result := '';

  if not PickerCaption.Checked
    then exit;

  case cbPlayer.ItemIndex of
    0 : player := 'B';
    1 : player := 'W';
    2 : player := '_'
  end;

  case cbResult.ItemIndex of
    0 : score := '+%'; // wins
    1 : score := '+' + seScore.Text; // wins by
    2 : ; // wins by at less see below
    3 : ; // wins by at most see below
    4 : score := '+R'; // wins by resignation
    5 : score := '+T'; // wins on time
    6 : score := '+F'; // wins by forfeit
    7 : ; // draw
    8 : ; // no result
    9 : ; // other, unknown
  end;

  case cbResult.ItemIndex of
    2 : Result := MakeAtLess(player, seScore.Value);
    3 : Result := MakeAtMost(player, seScore.Value);
    7 : Result := '(RE like ''Jigo%'' OR RE like ''Draw%'')';
    8 : Result := '(RE like ''Void%'')';
    9 : Result := '(NOT (RE like ''B%'' OR RE like ''W%'' OR '
                      + 'RE like ''Void%'' OR RE like ''Jigo%'' OR '
                      + 'RE like ''Draw%''))';
    else
      if (player = '_') or (Pos('%', score) > 0)
        then Result := '(RE like ''' + player + score + ''')'
        else Result := '(RE = '''    +  player + score + ''')'
  end
end;

// -- Event handlers ---------------------------------------------------------

procedure TDBResultPicker.ChangeRequest;
begin
  (Parent as TfrDBRequestPanel).ChangeRequest
end;

procedure TDBResultPicker.cbResultChange(Sender: TObject);
begin
  inherited;
  seScore.Enabled := cbResult.ItemIndex in [1, 2, 3];
  ChangeRequest;
end;

procedure TDBResultPicker.cbPlayerChange(Sender: TObject);
begin
  ChangeRequest;
end;

procedure TDBResultPicker.seScoreChange(Sender: TObject);
begin
  ChangeRequest;
end;

// -- Construction of number ranges from string comparison... ----------------

function JoinOr(strings : array of string) : string;
var
  i : integer;
begin
  Result := '(' + strings[0];
  for i := 1 to High(strings) do
    Result := Result + ' OR ' + strings[i];
  Result := Result + ')'
end;

function Clause(fmt : string; player : char; value : double) : string;
begin
  Result := Format(fmt, [player, player, player, value])
end;

const
  fmSup1Int = '(RE like ''%s+_'' AND RE <= ''%s+9'' AND RE >= ''%s+%1.0f'')';
  fmSup1Dec = '(RE like ''%s+_.5'' AND RE <= ''%s+9.9'' AND RE >= ''%s+%1.1f'')';
  fmSup2Int = '(RE like ''%s+__'' AND RE <= ''%s+99'' AND RE >= ''%s+%1.0f'')';
  fmSup2Dec = '(RE like ''%s+__.5'' AND RE <= ''%s+99.9'' AND RE >= ''%s+%1.1f'')';

function MakeAtLess1(player : char; value : double) : string;
begin
  if value <= 9 then
    if Frac(value) = 0
      then Result := JoinOr([Clause(fmSup1Int, player, value),
                             Clause(fmSup1Dec, player, value + 0.1),
                             Clause(fmSup2Int, player, 10),
                             Clause(fmSup2Dec, player, 10.1)])
      else Result := JoinOr([Clause(fmSup1Int, player, Ceil(value)),
                             Clause(fmSup1Dec, player, value),
                             Clause(fmSup2Int, player, 10),
                             Clause(fmSup2Dec, player, 10.1)]);

  if (value > 9) and (value < 10) then
    if True
      then Result := JoinOr([Clause(fmSup1Dec, player, value),
                             Clause(fmSup2Int, player, 10),
                             Clause(fmSup2Dec, player, 10.1)]);

  if value >= 10 then
    if Frac(value) = 0
      then Result := JoinOr([Clause(fmSup2Int, player, value),
                             Clause(fmSup2Dec, player, value + 0.1)])
      else Result := JoinOr([Clause(fmSup2Int, player, Ceil(value)),
                             Clause(fmSup2Dec, player, value)])
end;

function MakeAtLess(player : char; value : double) : string;
begin
  case player of
    'B', 'W' :
      Result := MakeAtLess1(player, value);
    '_' :
      Result := '(' + MakeAtLess1('B', value) + ' OR '
                    + MakeAtLess1('W', value) + ')'
  end
end;

const
  fmInf1Int = '(RE like ''%s+_'' AND RE >= ''%s+0'' AND RE <= ''%s+%1.0f'')';
  fmInf1Dec = '(RE like ''%s+_.5'' AND RE >= ''%s+0.0'' AND RE <= ''%s+%1.1f'')';
  fmInf2Int = '(RE like ''%s+__'' AND RE >= ''%s+00'' AND RE <= ''%s+%1.0f'')';
  fmInf2Dec = '(RE like ''%s+__.5'' AND RE >= ''%s+00.0'' AND RE <= ''%s+%1.1f'')';

function MakeAtMost1(player : char; value : double) : string;
begin
  if value < 10 then
    if Frac(value) = 0
      then Result := JoinOr([Clause(fmInf1Int, player, value),
                             Clause(fmInf1Dec, player, value - 0.1)])
      else Result := JoinOr([Clause(fmInf1Int, player, Floor (value)),
                             Clause(fmInf1Dec, player, value)]);

  if value = 10 then
    if True
      then Result := JoinOr([Clause(fmInf1Int, player, 9),
                             Clause(fmInf1Dec, player, 9.9),
                             Clause(fmInf2Int, player, 10)]);

  if value > 10 then
    if Frac(value) = 0
      then Result := JoinOr([Clause(fmInf1Int, player, 9),
                             Clause(fmInf1Dec, player, 9.9),
                             Clause(fmInf2Int, player, value),
                             Clause(fmInf2Dec, player, value - 0.1)])
      else Result := JoinOr([Clause(fmInf1Int, player, 9),
                             Clause(fmInf1Dec, player, 9.9),
                             Clause(fmInf2Int, player, Floor(value)),
                             Clause(fmInf2Dec, player, value)])
end;

function MakeAtMost(player : char; value : double) : string;
begin
  case player of
    'B', 'W' :
      Result := MakeAtMost1(player, value);
    '_' :
      Result := '(' + MakeAtMost1('B', value) + ' OR '
                    + MakeAtMost1('W', value) + ')'
  end
end;


// ---------------------------------------------------------------------------

end.
