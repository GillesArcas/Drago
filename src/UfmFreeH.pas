// ---------------------------------------------------------------------------
// -- Drago -- Free handicap stones input -------------------- UfmFreeH.pas --
// ---------------------------------------------------------------------------

unit UfmFreeH;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, 
  TntForms, TntStdCtrls, SpTBXControls,
  UBoardViewCanvas, UViewBoard, StdCtrls, SpTBXItem;

type
  TFreeHCallBack = procedure(view : TViewBoard);

  TfmFreeH = class(TTntForm)
    Timer: TTimer;
    Image: TImage;
    Bevel: TBevel;
    Label1: TSpTBXLabel;
    btOk: TSpTBXButton;
    btCancel: TSpTBXButton;
    procedure btOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Translate;
  private
    FBoardView : TBoardViewCanvas;
    MyView : TViewBoard;
    Callback : TFreeHCallBack;
  public
    class procedure Execute(view : TViewBoard; aCallback : TFreeHCallBack);
    procedure FmClose;
  end;

var
  fmFreeH: TfmFreeH;
  IsOpen : boolean = False;

// ---------------------------------------------------------------------------

implementation

uses
  Define, DefineUi, Std, Properties, UMainUtil, UGameTree, Translate, VclUtils,
  UBoardView, UStatus,
  UStatusMain;

{$R *.dfm}

// -- Entry point ------------------------------------------------------------

class procedure TfmFreeH.Execute(view : TViewBoard; aCallback : TFreeHCallBack);
begin
  fmFreeH := TfmFreeH.Create(Application);
  fmFreeH.MyView := view;
  fmFreeH.Callback := aCallback;
  fmFreeH.Show;
end;

// ---------------------------------------------------------------------------

procedure TfmFreeH.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  IsOpen := True;
end;

// ---------------------------------------------------------------------------

procedure TfmFreeH.Translate;
begin
  Caption          := U('Free placement');
  Label1.Width     := 153;
  Label1.Caption   := U('Click on goban to set handicap stones.')
                       + #$D#$A
                       + U('Click again on a stone to remove it.');
  btOk.Caption     := U('Ok');
  btCancel.Caption := U('Cancel')
end;

procedure TfmFreeH.FormShow(Sender: TObject);
var
  i : integer;
begin
  Translate;
  EnableAllCommands(False);
  SetWinStrPlacement(self, StatusMain.fmFreeHaPlace);

  btOk.Enabled := False;
  Timer.Enabled := True;
  MyView.si.ModeInter := kimAB;
  Screen.Cursor := crDefault;

  FBoardView := TBoardViewCanvas.Create(Image.Canvas);
  FBoardView.BoardSize := 11;

  FBoardView.BoardSettings(Settings.BoardBack, Settings.BorderBack,
                           False, False, tcNone,
                           Settings.StoneStyle, Settings.LightSource, 0, not True);

  FBoardView.SetView(2, 2, 2, 10);
  FBoardView.SetDim(Image.Width, Image.Height);
  FBoardView.AdjustToSize;

  Image.Width  := FBoardView.ExtWidth;
  Image.Height := FBoardView.ExtHeight;
  Image.Left   := (ClientWidth - Image.Width) div 2;
  Bevel.Top    := Image.Top    - 2;
  Bevel.Left   := Image.Left   - 2;
  Bevel.Height := Image.Height + 5;
  Bevel.Width  := Image.Width  + 5;

  FBoardView.DrawBoard;
  for i := 1 to Settings.Handicap do
    FBoardView.DrawStone(2, i + 1, Black)
end;

// -- Timer events -----------------------------------------------------------

procedure TfmFreeH.TimerTimer(Sender: TObject);
var
  pv : string;
  n, i : integer;
begin
  pv := MyView.gt.GetProp(prAB);
  n := Length(pv) div 4;

  FBoardView.DrawBoard;
  for i := 1 to Settings.Handicap do
    if i <= Settings.Handicap - n
      then FBoardView.DrawStone(2, i + 1, Black)
      else FBoardView.DrawSymbol(2, i + 1, 0, 0, mrkPHB);

  btOk.Enabled := n = Settings.Handicap;
  MyView.si.FModeInter := iff(n < Settings.Handicap, kimHB, kimEB)
end;

// -- Button events ----------------------------------------------------------

// -- Ok button

procedure TfmFreeH.btOkClick(Sender: TObject);
begin
  MyView.si.FModeInter := kimAB;
  Close;
  CallBack(MyView)
end;

// -- Cancel button

procedure TfmFreeH.btCancelClick(Sender: TObject);
begin
  MyView.si.FModeInter := kimAB;
  Close
end;

// -- Closing ----------------------------------------------------------------

procedure TfmFreeH.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FmClose;
  Action := caFree
end;

procedure TfmFreeH.FmClose;   
begin
  FBoardView.Free;
  IsOpen := False;
  Timer.Enabled := False;
  StatusMain.fmFreeHaPlace := GetWinStrPlacement(self);
  EnableAllCommands(True);
end;

// ---------------------------------------------------------------------------

end.
