unit UFullScreenToggler;

interface

uses
  Forms;

type
  TFullScreenToggler = class
  private
    FBorderStyleBack : TFormBorderStyle;
    FWindowStateBack : TWindowState;
    FPlacementBack : string;
    procedure Toggle;
  public
    constructor Create;
    procedure Execute;
  end;

implementation

uses
  SysUtils,
  DefineUi, Main, UStatus, UActions, UShortcuts, Translate, UfmMsg, UMainUtil;

constructor TFullScreenToggler.Create;
begin
  FBorderStyleBack := bsNone;
  FWindowStateBack := wsMaximized;
  FPlacementBack := '';

  fmMain.DockTop.Visible := True;
  fmMain.SpTBXMainMenu.Visible := True;
end;

procedure TFullScreenToggler.Execute;
var
  shortcut : string;
  msg1, msg2 : WideString;
begin
  if (FBorderStyleBack = bsNone) and Settings.WarnFullScreen then
    begin
      shortcut := TrShortCutToText(Actions.acFullScreen.Shortcut);
      msg1 := U('Toggling to full screen mode.');
      msg2 := WideFormat(U('Restore window mode with %s'), [shortcut]);

      if MessageDialog(msOkCancel, imQuestion, [msg1, msg2], Settings.WarnFullScreen)
         = 2{mrCancel}
        then exit
    end;

  try
    fmMain.ActiveViewBoard.frViewBoard.Visible := False;
    Toggle;
  finally
    fmMain.ActiveViewBoard.frViewBoard.Visible := True
  end
end;

procedure TFullScreenToggler.Toggle;
var
  maximized : boolean;
  page, i : integer;
begin
  with fmMain do
    if BorderStyle <> bsNone
      then
        begin
          FBorderStyleBack := BorderStyle;
          FWindowStateBack := WindowState;
          FPlacementBack := GetMainPlacement;
          BorderStyle := bsNone;
          WindowState := wsMaximized;
          SpTBXMainMenu.Visible := False;
          DockTop.Visible := False;
          DockBottom.Visible := False;
          DockLeft.Visible := False;
          DockRight.Visible := False;
          StatusBar.Visible := False;
          page := MainPageControl.ActivePageIndex;
          for i := 0 to MainPageControl.PageCount - 1 do
            (MainPageControl.Pages[i] as TTabSheetEx).TabVisible := False;
          MainPageControl.ActivePageIndex := page
        end
      else
        begin
          BorderStyle := FBorderStyleBack;
          FBorderStyleBack := bsNone;
          WindowState := FWindowStateBack;
          SetMainPlacement(FPlacementBack, maximized);
          SpTBXMainMenu.Visible := True;
          DockTop.Visible := True;
          DockBottom.Visible := True;
          DockLeft.Visible := True;
          DockRight.Visible := True;
          StatusBar.Visible := True;
          page := MainPageControl.ActivePageIndex;
          for i := 0 to MainPageControl.PageCount - 1 do
            (MainPageControl.Pages[i] as TTabSheetEx).TabVisible := True;
          MainPageControl.ActivePageIndex := page
        end
end;

end.
 