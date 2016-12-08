// ---------------------------------------------------------------------------
// -- Drago -- Simple date picker frame ------------------- UDatePicker.pas --
// ---------------------------------------------------------------------------

unit UDatePicker;

// ---------------------------------------------------------------------------
// Note :
// -- VCL (best said Windows) date picker doesn't handle years below 1752
// -- year must be > 0 (EncodeDate)
// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Components, DateUtils;

type
  TDatePicker = class(TFrame)
    Panel1: TPanel;
    UpDown1: TUpDown;
    IntEdit1: TIntEdit;
    Label1: TLabel;
    IntEdit2: TIntEdit;
    Label2: TLabel;
    IntEdit3: TIntEdit;
    Timer1: TTimer;
    procedure IntEdit1Click(Sender: TObject);
    procedure IntEdit2Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure IntEdit3Click(Sender: TObject);
    procedure UpDown1MouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure IntEdit1Change(Sender: TObject);
    procedure IntEdit2Exit(Sender: TObject);
    procedure IntEdit1Exit(Sender: TObject);
    procedure IntEdit3Exit(Sender: TObject);
  private
    FButton : TUDBtnType;
    procedure CheckDate;
    procedure SetEnabled(enabled : boolean);
    function  GetEnabled : boolean;
    procedure SetDate(date : TDate);
    function  GetDate : TDate;
  public
    FFocus : integer;
    OnChange : procedure of object;
    constructor Create(AOwner:TComponent); override;
    property Enabled : boolean read GetEnabled write SetEnabled;
    property Date : TDate read GetDate write SetDate;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

constructor TDatePicker.Create(AOwner:TComponent);
begin
  inherited;
  // fight against flickering
  DoubleBuffered   := True;
  ParentBackground := False;
  Panel1.DoubleBuffered := True;
  Panel1.ParentBackground := False;
  IntEdit1.DoubleBuffered := True;
  IntEdit2.DoubleBuffered := True;
  IntEdit3.DoubleBuffered := True;
  UpDown1.DoubleBuffered := True;

  IntEdit1.Onchange := nil;
  IntEdit2.Onchange := nil;
  IntEdit3.Onchange := nil;
  IntEdit1.Value    := 0;
  IntEdit2.Text     := '0';
  IntEdit3.Text     := '0';
  IntEdit1.FFormat  := '%.4d';
  IntEdit2.FFormat  := '%.2d';
  IntEdit3.FFormat  := '%.2d';
  IntEdit1.FNumDig  := 4;
  IntEdit2.FNumDig  := 2;
  IntEdit3.FNumDig  := 2;
  IntEdit1.Onchange := IntEdit1Change;
  IntEdit2.Onchange := IntEdit1Change;
  IntEdit3.Onchange := IntEdit1Change;
end;

// -- Checking of month and day ----------------------------------------------

procedure TDatePicker.CheckDate;
begin
  // year
  if IntEdit1.Value = 0
    then IntEdit1.Value := 0; //1;
  // month
  if IntEdit2.Value = 0
    then IntEdit2.Value := 1;
  // day
  if IntEdit3.Value = 0
    then IntEdit3.Value := 1;

  // normalize format
  IntEdit1.Value := IntEdit1.Value;
  IntEdit2.Value := IntEdit2.Value;
  IntEdit3.Value := IntEdit3.Value;
end;

// -- Acces to date value ----------------------------------------------------

procedure TDatePicker.SetEnabled(enabled : boolean);
begin
  Label1.Enabled := enabled;
  Label2.Enabled := enabled;
  IntEdit1.Enabled := enabled;
  IntEdit2.Enabled := enabled;
  IntEdit3.Enabled := enabled;
  UpDown1.Enabled := enabled;
end;

function TDatePicker.GetEnabled  : boolean;
begin
end;

// -- Acces to date value ----------------------------------------------------

procedure TDatePicker.SetDate(date : TDate);
begin
  IntEdit1.Value := YearOf(date);
  IntEdit2.Value := MonthOf(date);
  IntEdit3.Value := DayOf(date)
end;

function TDatePicker.GetDate : TDate;
var
  date : TDateTime;
begin
  if TryEncodeDate(IntEdit1.Value, IntEdit2.Value, IntEdit3.Value, date)
    then Result := date
    else Result := Today
end;

// -- Handling of focus ------------------------------------------------------

procedure TDatePicker.IntEdit1Click(Sender: TObject);
begin
  //CheckDate;
  FFocus := 1;
  IntEdit1.SelStart := 0;
  IntEdit1.SelLength := 4;
  IntEdit1.FFormat := '%d';
end;

procedure TDatePicker.IntEdit1Exit(Sender: TObject);
begin
  IntEdit1.FFormat := '%.4d';
end;

procedure TDatePicker.IntEdit2Click(Sender: TObject);
begin
  //CheckDate;
  FFocus := 2;
  IntEdit2.SelStart := 0;
  IntEdit2.SelLength := 2;
  IntEdit2.FFormat := '%d';
end;

procedure TDatePicker.IntEdit2Exit(Sender: TObject);
begin
  IntEdit2.FFormat := '%.2d';
end;

procedure TDatePicker.IntEdit3Click(Sender: TObject);
begin
  //CheckDate;
  FFocus := 3;
  IntEdit3.SelStart := 0;
  IntEdit3.SelLength := 2;
  IntEdit3.FFormat := '%d';
end;

procedure TDatePicker.IntEdit3Exit(Sender: TObject);
begin
  IntEdit3.FFormat := '%.2d';
end;

// -- Updown events ----------------------------------------------------------

{
For an unknown reason, OnClick is sometimes not triggered, but OnMouseDown
is. So the OnClick event is called from the OnMouseDown...
}

procedure TDatePicker.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  case Button of
    btNext :
      case FFocus of
        1 :  Date := IncYear (Date, 1);
        2 :  Date := IncMonth(Date, 1);
        else Date := IncDay  (Date, 1);
      end;
    btPrev :
      case FFocus of
        1 :  Date := IncYear (Date, -1);
        2 :  Date := IncMonth(Date, -1);
        else Date := IncDay  (Date, -1);
      end;
  end
end;

procedure TDatePicker.UpDown1MouseDown(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Y < UpDown1.Height div 2
    then FButton := btNext
    else FButton := btPrev;

  IntEdit1.FFormat := '%.4d';
  IntEdit2.FFormat := '%.2d';
  IntEdit3.FFormat := '%.2d';

  UpDown1Click(Sender, FButton);
  Sleep(100);
  Timer1.Enabled := True
end;

procedure TDatePicker.UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
                                     Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := False
end;

// ---------------------------------------------------------------------------

procedure TDatePicker.Timer1Timer(Sender: TObject);
begin
  UpDown1Click(Sender, FButton)
end;

// ---------------------------------------------------------------------------

procedure TDatePicker.IntEdit1Change(Sender: TObject);
begin
  OnChange
end;

// ---------------------------------------------------------------------------

end.
