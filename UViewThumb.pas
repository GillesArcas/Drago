// ---------------------------------------------------------------------------
// -- Drago -- Board thumbnail view ------------------------ UViewThumb.pas --
// ---------------------------------------------------------------------------

unit UViewThumb;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Controls,
  Define, UViewMain, UfrPreviewThumb, UContext;

type
  TViewThumb = class(TViewMain)
  private
    procedure SetVisible(x : boolean); override;
  public
    frPreviewThumb: TfrPreviewThumb;
    constructor Create(aOwner, aParent : TComponent;
                       aContext : TContext); override;
    destructor Destroy;
    function  UpdateView : boolean; override;
    procedure DoWhenShowing; override;
    procedure AlignToClient(align : boolean); override;
    procedure ResizeGoban; override;

    procedure DoFirstGame; override;
    procedure DoLastGame; override;
    procedure DoPrevGame; override;
    procedure DoNextGame; override;
    procedure SelectGame; override;
    procedure DoStartPos; override;
    procedure DoEndPos;   override;
    procedure DoPrevMove(snMode : TStartNode  = snStrict); override;
    procedure DoNextMove; override;
    procedure SelectMove; override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std, Translate, UStatus, UInputQueryInt, Main, DefineUi;

// -- Allocation -------------------------------------------------------------

constructor TViewThumb.Create(aOwner, aParent : TComponent;
                              aContext : TContext);
begin
  inherited Create;

  TabSheet := aParent as TTabSheetEx;
  Context := aContext;
  frPreviewThumb := TfrPreviewThumb.Create(aOwner, aParent, self, Context);
  frPreviewThumb.Initialize
end;

destructor TViewThumb.Destroy;
begin
  inherited Destroy
end;
              
// -- Update -----------------------------------------------------------------

function TViewThumb.UpdateView : boolean;
begin
  Result := inherited UpdateView;
  if not Result
    then exit;

  frPreviewThumb.Initialize

  //frPreviewThumb.DoWhenShowing(kSynchroWithIndex)
end;

// -- Display ----------------------------------------------------------------

procedure TViewThumb.DoWhenShowing;
begin
  // call common show routine
  inherited DoWhenShowing;

  frPreviewThumb.DoWhenShowing(kSynchroWithIndex, True)
end;

procedure TViewThumb.AlignToClient(align : boolean);
begin
  if align
    then frPreviewThumb.Align := alClient
    else frPreviewThumb.Align := alNone
end;

procedure TViewThumb.ResizeGoban;
begin
  frPreviewThumb.ResizeGoban
end;

procedure TViewThumb.SetVisible(x : boolean);
begin
  frPreviewThumb.Visible := x
end;

// -- Commands ---------------------------------------------------------------

//  -- Navigation among games

procedure TViewThumb.DoFirstGame;
begin
  frPreviewThumb.FirstGame
end;

procedure TViewThumb.DoLastGame;
begin
  frPreviewThumb.LastGame
end;

procedure TViewThumb.DoPrevGame;
begin
  frPreviewThumb.PrevGame
end;

procedure TViewThumb.DoNextGame;
begin
  frPreviewThumb.NextGame
end;

procedure TViewThumb.SelectGame;
begin
  // set Status.LastGotoGame
  inherited SelectGame;

  frPreviewThumb.GotoGame(Status.LastGotoGame)
end;

// -- Position selection

procedure TViewThumb.DoStartPos;
begin
  frPreviewThumb.StartPos
end;

procedure TViewThumb.DoEndPos;
begin
  frPreviewThumb.EndPos
end;

procedure TViewThumb.DoPrevMove(snMode : TStartNode  = snStrict);
begin
  frPreviewThumb.PrevMove
end;

procedure TViewThumb.DoNextMove;
begin
  frPreviewThumb.NextMove
end;

procedure TViewThumb.SelectMove;
var
  n : integer;
begin
  n := Settings.NbMovesIndex;
  
  if not InputQueryInt(AppName + ' - ' + U('Select move'), U('Number'), n)
    then exit;

  if Within(n, 1, 1000) then
    begin
      Settings.NbMovesIndex := n;
      frPreviewThumb.SelectMove(n)
    end
end;

// ---------------------------------------------------------------------------

end.

