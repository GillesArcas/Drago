// ---------------------------------------------------------------------------
// -- Drago -- Input of text label markups ------------------- UfmLabel.pas --
// ---------------------------------------------------------------------------

unit UfmLabel;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, Controls, Forms,
  Dialogs, Buttons, StdCtrls,
  UViewBoard;

type
  TfmLabel = class(TForm)
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
  end;

  procedure InputLabel(view : TViewBoard; i, j : integer);

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  Main, Ux2y, Properties, UGoban, UGameTree;

var
  iLabel, jLabel : integer;
  vLabel : string;

// ---------------------------------------------------------------------------

procedure InputLabel(view : TViewBoard; i, j : integer);
var
  x, y : integer;
  pt   : TPoint;
begin
  view.gb.ij2xy(i, j, x, y);
  iLabel  := i;
  jLabel  := j;
  pv2ijs(view.gt.ValueAtij(prLB, i, j), i, j, vLabel);

  with TfmLabel.Create(Application) do
    try
      Width := 85;
      Edit1.Text := vLabel;
      pt.x := x - Edit1.Width  div 2;
      pt.y := y - Edit1.Height div 2;
      pt := view.frViewBoard.imGoban.ClientToScreen(pt);
      Left := pt.x;
      Top  := pt.y;
      ShowModal
    finally
      Release
    end
end;

procedure TfmLabel.SpeedButton1Click(Sender: TObject);
begin
  Close;
  if Edit1.Text = vLabel
    then exit
    else fmMain.ActiveView.DoEditMarkup(iLabel, jLabel, prLB,
                                         ijs2pv(iLabel, jLabel, Edit1.Text))
end;

procedure TfmLabel.SpeedButton2Click(Sender: TObject);
begin
  Close
end;

procedure TfmLabel.Edit1KeyDown(Sender: TObject; var Key: Word;
                                Shift: TShiftState);
begin
  case Key of
    VK_RETURN : SpeedButton1Click(Sender);
    VK_ESCAPE : SpeedButton2Click(Sender)
  end
end;

// ---------------------------------------------------------------------------

end.

