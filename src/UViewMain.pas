// ---------------------------------------------------------------------------
// -- Drago -- Base class for Drago UI views ---------------- UViewMain.pas --
// ---------------------------------------------------------------------------

unit UViewMain;

// ---------------------------------------------------------------------------

interface

uses
  Types, SysUtils, ComCtrls, TntComCtrls, IniFiles,
  Define, DefineUi, UView;

type
  TViewMain = class(TView)
  private
    function IsActiveView : boolean;
  public
    TabSheet  : TObject;
    TabName   : WideString;
    ToBeUpdated : boolean;

    constructor Create; overload; virtual;
    procedure EnterView; virtual;
    procedure ExitView; virtual;
    function  UpdateView : boolean; virtual;
    procedure DoWhenShowing; virtual;
    procedure Translate; virtual;
    procedure AlignToClient(align : boolean); virtual; abstract;
    procedure ClearStatusBar;
    procedure ShowGameOnBoard(k : integer);
    procedure UpdateGameOnBoard(k : integer);
    procedure ShowFileName(const s : WideString); override;
    procedure ShowSaveStatus(saved : boolean); override;
    procedure ShowReadOnlyStatus(rOnly : boolean); override;
    procedure ShowGameIndex(n : integer); override;
    procedure ShowIgnoredProperty(const s : string); override;
    procedure UpdateMoveNumber(number : integer); override;
    procedure StatusBarUpdatePlayer(player : integer);
    procedure StatusBarUpdateMoveNumber(number : integer);
    procedure StatusBarUpdatePrisoners(nB, nW : integer);
    procedure StatusBarUpdateGameInfo(i, n : integer; const v : string);
    procedure AddAnnotation(const glyph, msg : string); override;
    function  MessageDialog(dlg, img : integer;
                            msg : array of WideString) : integer; override;
    function  MessageDialog(dlg, img : integer;
                            msg : array of WideString;
                            var warn : boolean) : integer; override;

    procedure SelectGame; override;
    procedure OpenGameInfoDialog; virtual;
    procedure SetExportPositionMode(active : boolean); virtual;
    procedure StartEvent(seMode : TStartEvent = seMain;
                         snMode : TStartNode  = snStrict;
                         path   : string      = ''); override;
    function AllowModification : boolean; override;
    function  GetVisible : boolean; virtual;
    procedure SetVisible(x : boolean); virtual;

    property  Visible : boolean read GetVisible write SetVisible;
  end;

procedure RestartAll;
procedure StatusBarDrawGameInfo(StatusBar : TStatusBar;
                                Panel     : TStatusPanel;
                                const Rect: TRect);

// ---------------------------------------------------------------------------

implementation

uses
  Math,
  Std, Main, UMainUtil, UActions, UViewBoard, UfmMsg, UStatus, 
  UInputQueryInt, Translate, UfmGameInfo, UGraphic, Graphics,
  UGCom;

// ---------------------------------------------------------------------------

constructor TViewMain.Create;
begin
  inherited Create;
  ToBeUpdated := True
end;

function TViewMain.GetVisible : boolean;
begin
  assert(False)
end;

procedure TViewMain.SetVisible(x : boolean);
begin
end;

procedure TViewMain.EnterView;
begin
end;

procedure TViewMain.ExitView;
begin
end;

function TViewMain.UpdateView : boolean;
begin
  if not ToBeUpdated
    then Result := False
    else
      begin
        ToBeUpdated := False;
        Result := True;

        // common updates
        Translate
      end
end;

procedure TViewMain.DoWhenShowing;
begin
  UpdateView;

  // refresh filename and game number in statusbar (and store game number)
  si.IndexTree := si.IndexTree;
  si.ReadOnly := si.ReadOnly;

  // refresh caption bar
  si.FileSave := si.FileSave;

  // refresh toolbar
  si.ModeInter := si.ModeInter;

  // update MRU menus
  SetMRU(si.FolderName, iff(kh <> nil, si.DatabaseName, si.FileName));

  // enable actions (and refresh menu and toolbar greying)
  EnableCommands(self, si.EnableMode)
end;

procedure TViewMain.Translate;
begin
end;

// ---------------------------------------------------------------------------

procedure TViewMain.ShowGameOnBoard(k : integer);
begin
  fmMain.SelectView(vmBoard);
  fmMain.ActiveView.ChangeEvent(k, seMain, snHit)
end;

procedure TViewMain.UpdateGameOnBoard(k : integer);
begin
  (TabSheet as TTabSheetEx).ViewBoard.ChangeEvent(k, seMain, snHit)
end;

// -- Show filename in title caption and tab caption -------------------------

procedure TViewMain.ShowFileName(const s : WideString);
begin
  UMainUtil.SetFileName(self, s)
end;

// -- Show save/modification status in title caption and tab caption ---------

procedure TViewMain.ShowSaveStatus(saved : boolean);
begin
  SetMainCaption(self);

  with TabSheet as TTabSheetEx do
    begin
      if (Length(Caption) > 0) and (Caption[Length(Caption)] = '*')
        then Caption := Copy(Caption, 1, Length(Caption) - 1);
      if not saved
        then Caption := Caption + '*'
    end;

  Actions.acSave.Enabled := (si.MainMode <> muEngineGame) and (not saved)
                             and (si.FModeInter <> kimHB)
                             and (si.DatabaseName = '')
end;

// -- Clear status bar -------------------------------------------------------

// clear fields related to current node (ie all except sbGameNumber)

procedure TViewMain.ClearStatusBar;
begin
  with fmMain do
    begin
      StatusBar.Panels[sbLastMove  ].Text := '';
      StatusBar.Panels[sbIgnored   ].Text := '';
      StatusBar.Panels[sbGlyph     ].Text := '';
      StatusBar.Panels[sbAnnotation].Text := '';
      StatusBar.Panels[sbMoveStatus].Text := ''
    end
end;

// -- Show read only status --------------------------------------------------

procedure TViewMain.ShowReadOnlyStatus(rOnly : boolean);
var
  s : string;
begin
  if rOnly
    then s := 'ReadOnly'
    else s := '';

  fmMain.WriteInStatusPanel(sbReadOnly, s)
end;

// -- Show game index in toolbar ---------------------------------------------

procedure TViewMain.ShowGameIndex(n : integer);
var
  s : string;
begin
  if not IsActiveView
    then exit;

  s := IntToStr(n) + ' / ' + IntToStr(cl.Count);
  fmMain.StatusBar.Panels[sbGameNumber].Text := s
end;

// -- Show ignored properties in status bar ----------------------------------

procedure TViewMain.ShowIgnoredProperty(const s : string);
begin
  if not IsActiveView
    then exit;

  with fmMain.StatusBar.Panels[sbIgnored] do
    if Text = ''
      then Text := '? : ' + s
      else Text := Text + ',' + s
end;

// -- Show annotation properties in status bar -------------------------------

procedure TViewMain.AddAnnotation(const glyph, msg : string);
var
  ws : WideString;
begin
  if not IsActiveView
    then exit;

  ws := UTF8Decode(msg);

  with fmMain.StatusBar.Panels[sbAnnotation] do
    if Text = ''
      then Text := ' ' + ws
      else Text := Text + ', ' + ws;

  fmMain.WriteInStatusPanel(sbGlyph, glyph)
end;

procedure TViewMain.UpdateMoveNumber(number : integer);
begin
  inherited UpdateMoveNumber(number);

  if (Settings.MRUList.Count > 0) and (si.FileName <> '')
    then Settings.MRUList[0].Path := si.CurrentPath
end;

// -- Handling of game status in status bar ----------------------------------

procedure TViewMain.StatusBarUpdateMoveNumber(number : integer);
begin
  StatusBarUpdateGameInfo(1, 3, Format('%03d', [number]))
end;

procedure TViewMain.StatusBarUpdatePlayer(player : integer);
begin
  StatusBarUpdateGameInfo(4, 1, 'BW'[player])
end;

procedure TViewMain.StatusBarUpdatePrisoners(nB, nW : integer);
begin
  StatusBarUpdateGameInfo(5, 6, Format('%3d%3d', [nB, nW]))
end;

procedure TViewMain.StatusBarUpdateGameInfo(i, n : integer; const v : string);
begin
  with fmMain.StatusBar.Panels[sbMoveStatus] do
    begin
      Text := Format('%-10s', [Text]);
      Text := Copy(Text, 1, i - 1) + v + Copy(Text, i + n, MaxInt)
    end
end;

procedure StatusBarDrawPrisoner(canvas : TCanvas;
                                x, y, color1, color2 : integer;
                                number : string);
begin
  with canvas do
    begin
      AntiAliasedStone(canvas, x, y + 7, -1, 4, color1);
      Pen.Color := $303030;
    (*
      MoveTo(x - 2, y + 2);
      LineTo(x - 2, y + 13);
      MoveTo(x + 2, y + 2);
      LineTo(x + 2, y + 13);
    *)
      MoveTo(x + 4, y + 2);
      LineTo(x - 4, y + 13);

      x := x + 6;
      Brush.Color := color2;
      Font.Color := clBlack;
      TextOut(x, y, number)
    end
end;

// -- call by StatusBar draw event

procedure StatusBarDrawGameInfo(StatusBar : TStatusBar;
                                Panel     : TStatusPanel;
                                const Rect: TRect);
var
  s, sNum, sMove, sBlackPrisoners, sWhitePrisoners : string;
  x, y : integer;
begin
  s := Panel.Text;
  if s = ''
    then exit;

  sNum            := Copy(s, 1, 3);
  sMove           := Copy(s, 4, 1);
  sBlackPrisoners := ':' + Trim(Copy(s, 5, 3));
  sWhitePrisoners := ':' + Trim(Copy(s, 8, 3));

  with StatusBar.Canvas do
    begin
      Brush.Color := StatusBar.Color;
      FillRect(Rect);

      TextOut(Rect.Left, Rect.Top, sNum);

      x := Rect.Left + TextWidth(sNum) + 15;
      if sMove = 'B'
        then AntiAliasedStone(StatusBar.Canvas, x, Rect.Top + 7, -1, 4, clBlack)
        else AntiAliasedStone(StatusBar.Canvas, x, Rect.Top + 7, -1, 4, clWhite);

      x := x + 20;
      y := Rect.Top;
      StatusBarDrawPrisoner(StatusBar.Canvas, x, y, clBlack, StatusBar.Color,
                            sBlackPrisoners);
      x := x + 20 + TextWidth(sBlackPrisoners) + 5;
      StatusBarDrawPrisoner(StatusBar.Canvas, x, y, clWhite, StatusBar.Color,
                            sWhitePrisoners);
    end;
end;

// -- Initial display of all tabs --------------------------------------------

procedure RestartAll;
var
  i : integer;
  view : TViewBoard;
begin
  for i := 0 to fmMain.PageCount - 1 do
    begin
      view := fmMain.Pages[i].ViewBoard;
      view.StartDisplay
    end
end;

// ---------------------------------------------------------------------------

function TViewMain.MessageDialog(dlg, img : integer;
                                 msg : array of WideString) : integer;
begin
  Result := UfmMsg.MessageDialog(dlg, img, msg)
end;

function TViewMain.MessageDialog(dlg, img : integer;
                                 msg : array of WideString;
                                 var warn : boolean) : integer;
begin
  Result := UfmMsg.MessageDialog(dlg, img, msg, warn)
end;

// ---------------------------------------------------------------------------

procedure TViewMain.SelectGame;
var
  n : integer;
begin
  n := Status.LastGotoGame;
  if InputQueryInt(AppName + ' - ' + U('Select game'), U('Number'), n)
    then Status.LastGotoGame := EnsureRange(n, 1, cl.Count)
end;

// -- Helpers ----------------------------------------------------------------

function TViewMain.IsActiveView : boolean;
begin
  Result := (self = fmMain.ActiveView)
end;

procedure TViewMain.StartEvent(seMode : TStartEvent = seMain;
                               snMode : TStartNode  = snStrict;
                               path   : string      = '');
begin
  inherited StartEvent(seMode, snMode, path);
  
  // this enables to update the tree view when changing event from info view
  // or thumb view.
  //if (self is TViewInfo) or (self is TViewThumb)
  //  then (TabSheet as TTabSheetEx).ViewBoard.StartEvent(seMode, snMode, path)
end;

// -- Test authorization to modify current file

function AllowModification(view : TViewMain) : boolean;
var
  s : string;
  b : boolean;
begin
  // read only
  if view.si.ReadOnly then
    begin
      if Settings.WarnAtReadOnly
        then
          view.MessageDialog(msOk, imExclam,
                             [U('Tab is in read only mode.')],
                             Settings.WarnAtReadOnly);
      Result := False;
      exit
    end;

  if view.si.DatabaseName = ''
    then
      // file or folder
      if (view.si.MainMode <> muNavigation) or not Settings.WarnAtModif
        then Result := True
        else
          begin
            Result := view.MessageDialog(msOkCancel, imQuestion,
                                          [U('File modification.'),
                                           U('Do you want to proceed?')],
                                          Settings.WarnAtModif)
                      = 1 {mrOk};
            if Result
              then view.si.MainMode := muModification
          end
    else
      // database
      begin
        if (view.si.MainMode <> muNavigation) or not Settings.WarnAtModifDB
          then Result := True
          else Result := view.MessageDialog(msOkCancel, imQuestion,
                                            [U('Unable to modify game in database.'),
                                             U('Extract to a new tab and try again?')],
                                            Settings.WarnAtModifDB)
                         = 1 {mrOk};

        if Result then
          begin
            b := PatternSearchMode(view) = psmQuickSearchSideBar;
            s := view.gt.StepsToNode;
            DoMainExtractOne;
            fmMain.ActiveView.GotoNode(fmMain.ActiveView.gt.Root.NodeAfterSteps(s));
            fmMain.ActiveView.si.MainMode := muModification;
            if b
              then (fmMain.ActiveView as TViewBoard).InitQuickSearch;
            Result := False
          end
      end
end;

function TViewMain.AllowModification : boolean;
begin
  Result := UViewMain.AllowModification(self)
end;

// -- Dialogs ----------------------------------------------------------------

procedure TViewMain.OpenGameInfoDialog;
begin
  TfmGameInfo.Execute(fmMain.ActiveView.cl[fmMain.ActiveView.si.IndexTree],
                      not fmMain.ActiveView.si.ReadOnly)
end;

procedure TViewMain.SetExportPositionMode(active : boolean);
begin
end;

// ---------------------------------------------------------------------------

end.


