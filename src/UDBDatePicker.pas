// ---------------------------------------------------------------------------
// -- Drago -- Date picker for database request --------- UDBDatePicker.pas --
// ---------------------------------------------------------------------------

unit UDBDatePicker;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  StdCtrls, DateUtils,
  UDatePicker, UfrDBPickerCaption,
  TntStdCtrls, SpTBXControls, SpTBXEditors, SpTBXItem, TntForms;

type
  TDatePickerMode = (dmDate, dmRange);
  TDatePickerUnit = (duDay = 0, duMonth, duYear, duCentury);

  TDBDatePicker = class(TFrame)
    DateFrom: TDatePicker;
    DateTo: TDatePicker;
    PickerCaption: TfrDBPickerCaption;
    lbDate: TLabel;
    lbTo: TTntLabel;
    cxRange: TSpTBXCheckBox;
    cbUnit: TSpTBXComboBox;
    procedure rbRangeClick(Sender: TObject);
    procedure cbUnitChange(Sender: TObject);
    procedure DateTimePickerFromChange(Sender: TObject);
    procedure cxRangeClick(Sender: TObject);
    procedure PickerCaptionClick(Sender: TObject);
  private
    function  GetMode : TDatePickerMode;
    procedure SetMode(mode : TDatePickerMode);
    procedure SetUnit(unyt : TDatePickerUnit); overload;
    procedure SetUnit(unyt : TDatePickerUnit; tp : TDatePicker); overload;
    procedure ChangeRequest; overload;
    procedure ChangeRequest(Sender : TObject); overload;
  public
    procedure Default(aEnabled : boolean);
    procedure SetDatePicker(sFrom, sTo : string; mode : TDatePickerMode;
                                                 unyt : TDatePickerUnit);
    function  EncodeIniString(sFrom, sTo : string;
                              mode : TDatePickerMode;
                              unyt : TDatePickerUnit) : string;
    procedure DecodeIniString(s : string;
                              var sFrom, sTo : string;
                              var mode : TDatePickerMode;
                              var unyt : TDatePickerUnit);
    function GetLabel : string;
    function GetRequest : string;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses 
  Std, Translate, UfrDBRequestPanel;

// -- Forwards

function DateToKFormat(const date : TDate) : string; forward;
function FirstDayInPeriod(date : TDate; unyt : TDatePickerUnit) : TDate; forward;
function LastDayInPeriod (date : TDate; unyt : TDatePickerUnit) : TDate; forward;

// -- Default configuration --------------------------------------------------

procedure TDBDatePicker.Default(aEnabled : boolean);
begin
  DateFrom.OnChange := ChangeRequest;
  DateTo  .OnChange := ChangeRequest;

  SetDatePicker(DateToKFormat(ToDay),
                DateToKFormat(ToDay), dmDate, duDay);

  PickerCaption.CheckBox := True;
  PickerCaption.Caption := U('Search on date');
  PickerCaption.Checked := aEnabled;
  PickerCaptionClick(nil);
  lbTo.Left := DateTo.Left - (lbTo.Width + 5);

  Invalidate
end;

// -- Enabling ---------------------------------------------------------------

procedure TDBDatePicker.PickerCaptionClick(Sender: TObject);
var
  checked : boolean;
begin
  /////SetFocus;
  checked := PickerCaption.Checked;
  cbUnit  .Enabled := checked; cbUnit.Invalidate;
  cxRange .Enabled := checked;
  DateFrom.Enabled := checked;
  lbTo    .Enabled := checked and (GetMode = dmRange);
  DateTo  .Enabled := checked and (GetMode = dmRange);
  lbDate  .Enabled := checked;
  ChangeRequest
end;

// -- Construction of label --------------------------------------------------

function TDBDatePicker.GetLabel : string;
var
  mode : TDatePickerMode;
  period : TDatePickerUnit;
  date1, date2 : TDate;
begin
  Result := '';
  mode   := GetMode;
  period := TDatePickerUnit(cbUnit.ItemIndex);
  date1  := DateFrom.Date;
  date2  := DateTo.Date;

  case mode of
    dmDate :
      if period = duDay
        then Result := DateToKformat(date1)
        else Result := DateToKformat(FirstDayInPeriod(date1, period))
                       + ' ... '
                       + DateToKformat(LastDayInPeriod(date1, period));
    dmRange :
      Result := DateToKformat(FirstDayInPeriod(date1, period))
                       + ' ... '
                       + DateToKformat(LastDayInPeriod(date2, period))
  end;

  if Result <> ''
    then Result := '(' + Result + ')'
end;

// -- Construction of request ------------------------------------------------

function TDBDatePicker.GetRequest : string;
var
  mode : TDatePickerMode;
  period : TDatePickerUnit;
  date1, date2 : TDate;
begin
  Result := '';

  if not PickerCaption.Checked
    then exit;

  mode   := GetMode;
  period := TDatePickerUnit(cbUnit.ItemIndex);
  date1  := DateFrom.Date;
  date2  := DateTo.Date;

  case mode of
    dmDate :
      if period = duDay
        then Result := 'DT = ''' + DateToKformat(date1) + ''''
        else Result := 'DT >= ''' + DateToKformat(FirstDayInPeriod(date1, period))
                                  + ''' and DT <= '''
                                  + DateToKformat(LastDayInPeriod(date1, period))
                                  + '''';
    dmRange :
      Result := 'DT >= ''' + DateToKformat(FirstDayInPeriod(date1, period))
                           + ''' and DT <= '''
                           + DateToKformat(LastDayInPeriod(date2, period))
                           + ''''
  end;

  if Result <> ''
    then Result := '(' + Result + ')'
end;

// -- Conversions between TDate and yyyy-mm-dd format ------------------------

function DateToKFormat(const date : TDate) : string;
var
  year, month, day : word;
begin
  try
    DecodeDate(date, year, month, day);
    Result := Format('%.4d-%.2d-%.2d', [year, month, day])
  except
    Result := ''
  end
end;

function KFormatToDate(const s : string) : TDate;
begin
  try
    Result := EncodeDate(NthInt(s, 1, '-'), NthInt(s, 2, '-'),
                         NthInt(s, 3, '-'))
  except
    Result := Today
  end
end;

// -- Normalizations of dates to first or last of unit -----------------------

function FirstDayInPeriod(date : TDate; unyt : TDatePickerUnit) : TDate;
begin
  case unyt of
    duDay :
      Result := date;
    duMonth :
      Result := RecodeDay(date, 1);
    duYear :
      Result := RecodeMonth(FirstDayInPeriod(date, duMonth), 1);
    duCentury :
      Result := RecodeYear(FirstDayInPeriod(date, duYear), YearOf(Date) div 100 * 100);
  end
end;

function LastDayInPeriod(date : TDate; unyt : TDatePickerUnit) : TDate;
begin
  case unyt of
    duDay :
      Result := date;
    duMonth :
      Result := EndOfTheMonth(Date);
    duYear :
      Result := EndOfTheYear(Date);
    duCentury :
      Result := EndOfTheYear(IncYear(FirstDayInPeriod(date, duCentury), 99));
  end
end;

// ---------------------------------------------------------------------------

procedure TDBDatePicker.SetDatePicker(sFrom, sTo : string;
                                      mode : TDatePickerMode;
                                      unyt : TDatePickerUnit);
begin
  DateFrom.Date := KFormatToDate(sFrom);
  DateTo  .Date := KFormatToDate(sTo);

  cbUnit.ItemIndex := ord(unyt);
  cxRange.Checked := mode = dmRange;

  SetMode(mode)
end;

function TDBDatePicker.GetMode : TDatePickerMode;
begin
  if not cxRange.Checked
    then Result := dmDate
    else Result := dmRange
end;

procedure TDBDatePicker.SetMode(mode : TDatePickerMode);
begin
  case mode of
    dmDate :
      begin
        DateFrom.Enabled := True;
        cbUnit.Enabled := True;
        lbTo.Enabled := False;
        DateTo.Enabled := False
      end;
    dmRange :
      begin
        DateFrom.Enabled := True;
        cbUnit.Enabled := True;
        lbTo.Enabled := True;
        DateTo.Enabled := True
      end;
    end;
end;

procedure TDBDatePicker.SetUnit(unyt : TDatePickerUnit; tp : TDatePicker);
begin
  with tp do
    case unyt of
      duDay :
        begin
          DateFrom.FFocus := 3;
          DateTo  .FFocus := 3;
        end;
      duMonth :
        begin
          DateFrom.FFocus := 2;
          DateTo  .FFocus := 2;
          Date := RecodeDay(Date, 1);
        end;
      duYear :
        begin
          DateFrom.FFocus := 1;
          DateTo  .FFocus := 1;
          Date := RecodeDay(Date, 1);
          Date := RecodeMonth(Date, 1);
        end;
    end
end;

procedure TDBDatePicker.SetUnit(unyt : TDatePickerUnit);
begin
  SetUnit(unyt, DateFrom);
  SetUnit(unyt, DateTo)
end;

// -- Coding and decoding the ini string -------------------------------------

function  TDBDatePicker.EncodeIniString(sFrom, sTo : string;
                                        mode : TDatePickerMode;
                                        unyt : TDatePickerUnit) : string;
begin
  Result := Format('%d;%d;%s;%s', [Ord(mode), Ord(unyt), sFrom, sTo])
end;

procedure TDBDatePicker.DecodeIniString(s : string;
                                        var sFrom, sTo : string;
                                        var mode : TDatePickerMode;
                                        var unyt : TDatePickerUnit);
begin
  sFrom := NthWord(s, 3, ';');
  sTo   := NthWord(s, 4, ';');
  mode  := TDatePickerMode(StrToIntDef(NthWord(s, 1, ';'), 0));
  unyt  := TDatePickerUnit(StrToIntDef(NthWord(s, 2, ';'), 0))
end;

// -- Event handlers ---------------------------------------------------------

procedure TDBDatePicker.ChangeRequest;
begin
  lbDate.Caption := GetLabel;
  (Parent as TfrDBRequestPanel).ChangeRequest
end;

procedure TDBDatePicker.ChangeRequest(Sender : TObject);
begin
  (Parent as TfrDBRequestPanel).ChangeRequest
end;

procedure TDBDatePicker.rbRangeClick(Sender: TObject);
begin
  inherited;
  SetMode(dmRange);
  ChangeRequest;
end;

procedure TDBDatePicker.cxRangeClick(Sender: TObject);
begin
  inherited;
  if cxRange.Checked
    then SetMode(dmRange)
    else SetMode(dmDate);
  ChangeRequest;
end;

procedure TDBDatePicker.cbUnitChange(Sender: TObject);
begin
  inherited;
  SetUnit(TDatePickerUnit(cbUnit.ItemIndex));
  ChangeRequest;
end;

procedure TDBDatePicker.DateTimePickerFromChange(Sender: TObject);
begin
  inherited;
  //SetUnit(TDatePickerUnit(cbUnit.ItemIndex), DateTimePickerFrom)
  ChangeRequest;
end;

// ---------------------------------------------------------------------------

end.
