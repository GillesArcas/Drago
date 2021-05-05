// ---------------------------------------------------------------------------
// -- Drago -- Simple time picker frame ------------------- UTimePicker.pas --
// ---------------------------------------------------------------------------

unit UTimePicker;

// ---------------------------------------------------------------------------
// Note :
// -- VCL (best said Windows) time picker doesn't enable to set the default
// -- focus on least significant field.
// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Components, DateUtils, SpTBXItem;

type
  TTimePicker = class(TFrame)
    Timer1: TTimer;
    Panel1: TPanel;
    Label1: TLabel;
    UpDown1: TUpDown;
    IntEdit1: TIntEdit;
    IntEdit2: TIntEdit;
    procedure IntEdit1Click(Sender: TObject);
    procedure IntEdit2Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown1MouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure IntEdit1Change(Sender: TObject);
    procedure IntEdit1Enter(Sender: TObject);
  private
    FButton : TUDBtnType;
    FHour   : boolean;
    procedure SetEnabled(enabled : boolean);
    function  GetEnabled : boolean;
    procedure SetTime(seconds : integer);
    function  GetTime : integer;
  public
    FFocus : integer;
    OnChange : procedure of object;
    constructor Create(AOwner:TComponent); override;
    property Enabled : boolean read GetEnabled write SetEnabled;
    property Seconds : integer read GetTime write SetTime;
    property HourStyle : boolean read FHour write FHour;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  Std;

constructor TTimePicker.Create(AOwner:TComponent);
begin
  inherited;
  // fight against flickering
  DoubleBuffered   := True;
  ParentBackground := False;
  Panel1.DoubleBuffered := True;
  Panel1.ParentBackground := False;
  IntEdit1.DoubleBuffered := True;
  IntEdit2.DoubleBuffered := True;
  UpDown1.DoubleBuffered := True;

  IntEdit1.Onchange := nil;
  IntEdit2.Onchange := nil;
  IntEdit1.FFormat  := '%2.2d';
  IntEdit2.FFormat  := '%2.2d';
  IntEdit1.Value    := 0;
  IntEdit2.Value    := 0;
  IntEdit1.FNumDig  := 2;
  IntEdit2.FNumDig  := 2;
  IntEdit1.Onchange := IntEdit1Change;
  IntEdit2.Onchange := IntEdit1Change;

  // set focus on least significant field
  FFocus := 2;

  HourStyle := True
end;

// -- Access to date value ---------------------------------------------------

procedure TTimePicker.SetEnabled(enabled : boolean);
begin
  Label1.Enabled   := enabled;
  IntEdit1.Enabled := enabled;
  IntEdit2.Enabled := enabled;
  UpDown1.Enabled  := enabled;
end;

function TTimePicker.GetEnabled  : boolean;
begin
end;

// -- Access to time value (in seconds) --------------------------------------

procedure TTimePicker.SetTime(seconds : integer);
begin
  if HourStyle
    then
      begin
        IntEdit1.Value := seconds div 3600;
        IntEdit2.Value := (seconds mod 3600) div 60
      end
    else
      begin
        IntEdit1.Value := (seconds mod 3600) div 60;
        IntEdit2.Value := (seconds mod 3600) mod 60
      end
end;

function TTimePicker.GetTime : integer;
begin
  if HourStyle
    then Result := (IntEdit1.Value * 60 + IntEdit2.Value) * 60
    else Result :=  IntEdit1.Value * 60 + IntEdit2.Value
end;

// -- Handling of focus ------------------------------------------------------

procedure TTimePicker.IntEdit1Click(Sender: TObject);
begin
  FFocus := 1;
  IntEdit1.SelStart := 0;
  IntEdit1.SelLength := 2;
  HideCaret((Sender as TEdit).Handle)
end;

procedure TTimePicker.IntEdit2Click(Sender: TObject);
begin
  FFocus := 2;
  IntEdit2.SelStart := 0;
  IntEdit2.SelLength := 2;
  HideCaret((Sender as TEdit).Handle)
end;

// -- Updown events ----------------------------------------------------------

{
For an unknown reason, OnClick is sometimes not triggered, but OnMouseDown
is. So the OnClick event is called from the OnMouseDown...
}

procedure TTimePicker.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
  n : integer;
begin
  case Button of
    btNext :
      case FFocus of
        1 :  n := Seconds + iff(HourStyle, 3600, 60);
        2 :  n := Seconds + iff(HourStyle, 60  ,  1);
      end;
    btPrev :
      case FFocus of
        1 :  n := Seconds - iff(HourStyle, 3600, 60);
        2 :  n := Seconds - iff(HourStyle, 60  ,  1);
      end;
  end;

  if n < 0
    then Seconds := 0
    else Seconds := n;

  if FFocus = 1
    then
      begin
        IntEdit1.SelStart := 0;
        IntEdit1.SelLength := 2
      end
    else
      begin
        IntEdit2.SelStart := 0;
        IntEdit2.SelLength := 2
      end
end;

procedure TTimePicker.UpDown1MouseDown(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Y < UpDown1.Height div 2
    then FButton := btNext
    else FButton := btPrev;

  UpDown1Click(Sender, FButton);
  Sleep(100);
  Timer1.Enabled := True
end;

procedure TTimePicker.UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
                                     Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := False
end;

// ---------------------------------------------------------------------------

procedure TTimePicker.Timer1Timer(Sender: TObject);
begin
  UpDown1Click(Sender, FButton)
end;

// ---------------------------------------------------------------------------

procedure TTimePicker.IntEdit1Enter(Sender: TObject);
begin
  HideCaret((Sender as TEdit).Handle)
end;

procedure TTimePicker.IntEdit1Change(Sender: TObject);
begin
  HideCaret((Sender as TEdit).Handle)
end;

// ---------------------------------------------------------------------------

end.
