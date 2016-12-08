// ---------------------------------------------------------------------------
// -- Drago -- Game information list view ------------------- UViewInfo.pas --
// ---------------------------------------------------------------------------

unit UViewInfo;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, Controls,
  UViewMain, UfrPreviewInfo, UContext;

type
  TViewInfo = class(TViewMain)
  private
    procedure SetVisible(x : boolean); override;
  public
    frPreviewInfo: TfrPreviewInfo;
    constructor Create(aOwner, aParent : TComponent;
                       aContext : TContext); override;
    destructor Destroy; override;
    function  UpdateView : boolean; override;
    procedure DoWhenShowing; override;
    procedure AlignToClient(align : boolean); override;

    procedure DoFirstGame; override;
    procedure DoLastGame; override;
    procedure DoPrevGame; override;
    procedure DoNextGame; override;
    procedure SelectGame; override;
    procedure OpenGameInfoDialog; override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  UStatus, Main;

// -- Allocation -------------------------------------------------------------

constructor TViewInfo.Create(aOwner, aParent : TComponent;
                             aContext : TContext);
begin
  inherited Create;
  
  TabSheet := aParent as TTabSheetEx;
  Context := aContext;
  frPreviewInfo := TfrPreviewInfo.Create(aOwner, aParent, self);
end;

destructor TViewInfo.Destroy;
begin
  inherited Destroy
end;

// -- Update -----------------------------------------------------------------

function TViewInfo.UpdateView : boolean;
begin
  Result := inherited UpdateView;
  if not Result
    then exit;

  frPreviewInfo.DoWhenUpdating
end;

// -- Display ----------------------------------------------------------------

procedure TViewInfo.DoWhenShowing;
begin
  // call common show routine
  inherited DoWhenShowing;

  frPreviewInfo.DoWhenShowing;
end;

procedure TViewInfo.AlignToClient(align : boolean);
begin
  if align
    then frPreviewInfo.Align := alClient
    else frPreviewInfo.Align := alNone
end;

procedure TViewInfo.SetVisible(x : boolean);
begin
  frPreviewInfo.Visible := x
end;

// -- Navigation -------------------------------------------------------------

procedure TViewInfo.DoFirstGame;
begin
  frPreviewInfo.FirstGame
end;

procedure TViewInfo.DoLastGame;
begin
  frPreviewInfo.LastGame
end;

procedure TViewInfo.DoPrevGame;
begin
  frPreviewInfo.PrevGame
end;

procedure TViewInfo.DoNextGame;
begin
  frPreviewInfo.NextGame
end;

procedure TViewInfo.SelectGame;
begin
  // set Status.LastGotoGame
  inherited SelectGame;

  frPreviewInfo.GotoGame(Status.LastGotoGame)
end;

// ---------------------------------------------------------------------------

procedure TViewInfo.OpenGameInfoDialog;
begin
  frPreviewInfo.GameInfo
end;

// ---------------------------------------------------------------------------

end.
