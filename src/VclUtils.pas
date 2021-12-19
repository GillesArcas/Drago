// ---------------------------------------------------------------------------
// -- Drago -- VCL related utilities ------------------------- VclUtils.pas --
// ---------------------------------------------------------------------------

unit VclUtils;

// ---------------------------------------------------------------------------

interface

uses
  Classes, Windows, Messages, Graphics, Controls, StdCtrls, Forms,
  TntStdCtrls, SpTBXControls;

function  GetWinStrPlacement(fm : TForm) : string;
procedure SetWinStrPlacement(fm : TForm; s : string; setWinPlace : boolean = False);
procedure UpdateWinStrPlacement(fm : TForm; s : string);
procedure SetWinStrPosition(fm : TForm; const s : string);
function  ControlRect(control : TControl) : TRect;
function  ScreenPointInsideControl(point : TPoint; control : TControl) : boolean;
function  MouseInsideControl(control : TControl) : boolean;
procedure SetNthRadioButton(buttons : array of TSpTBXRadioButton; n : integer);
function  GetNthRadioButton(buttons : array of TSpTBXRadioButton) : integer;
procedure SetComboValue(cb : TComboBox; const s : string); overload;
procedure SetComboValue(cb : TTntComboBox; const s : WideString); overload;
function  ValidateNumEdit(fm : TForm; ed : TCustomEdit; var n : integer) : boolean;
procedure EnableControl(control : TWinControl; value : boolean);
procedure UpdateMemoComment(memo : TTntMemo; const s : WideString);
function  ShortenString(canvas : TCanvas; const s : string; width : integer;
                        ellipsisWidth : integer = 0) : string;
function WideMinimizeName(const Filename: WideString;
                          Canvas: TCanvas;
                          MaxLen: Integer): WideString;
function WideMinimizeLabel(labl : TSpTBXLabel; const s : WideString) : WideString;
procedure AvoidFlickering(winCtrls : array of TWinControl);
procedure LockControl(c: TWinControl; bLock: Boolean);

// ---------------------------------------------------------------------------

implementation

uses

  SysUtils, Types, Menus, Printers,
  ExtCtrls, ComCtrls, Grids, TntForms, TntComCtrls, TntGraphics,
  Std, UnicodeUtils, SysUtilsEx;

// -- Placement of window ----------------------------------------------------
//
// cf. C:\Program Files\Borland\Delphi7\Source\Rtl\Win\Windows.pas for
// declarations of PWindowPlacement, GetWindowPlacement and SetWindowPlacement
// Help in Windows SDK at WINDOWPLACEMENT

function GetWinStrPlacement(fm : TForm) : string;
var
  WindowPlacement : TWindowPlacement;
begin
  WindowPlacement.length := sizeof(WindowPlacement);
  GetWindowPlacement(fm.Handle, @WindowPlacement);

  with WindowPlacement do
    begin
      Result := Format('%u,%u,%d,%d,%d,%d,%d,%d,%d,%d',
                       [flags, showCmd,
                        ptMinPosition.X,
                        ptMinPosition.Y,
                        ptMaxPosition.X,
                        ptMaxPosition.Y,
                        rcNormalPosition.Left,
                        rcNormalPosition.Top,
                        rcNormalPosition.Right,
                        rcNormalPosition.Bottom])
    end
end;

procedure UpdateWinStrPlacement(fm : TForm; s : string);
var
  WindowPlacement : TWindowPlacement;
begin
  with WindowPlacement do
    begin
      length                  := sizeof(WindowPlacement);
      flags                   := UINT(NthInt(s, 1, ','));
      showCmd                 := UINT(NthInt(s, 2, ','));
      ptMinPosition.X         := NthInt(s,  3, ',');
      ptMinPosition.Y         := NthInt(s,  4, ',');
      ptMaxPosition.X         := NthInt(s,  5, ',');
      ptMaxPosition.Y         := NthInt(s,  6, ',');
      rcNormalPosition.Left   := NthInt(s,  7, ',');
      rcNormalPosition.Top    := NthInt(s,  8, ',');
      rcNormalPosition.Right  := NthInt(s,  9, ',');
      rcNormalPosition.Bottom := NthInt(s, 10, ',')
    end;
  SetWindowPlacement(fm.Handle, @WindowPlacement)
end;

procedure SetWinStrPlacement(fm : TForm; s : string; setWinPlace : boolean = False);
var
  WindowPlacement : TWindowPlacement;
  r : TRect;
begin
  with WindowPlacement do
    if s = ''
    then begin
      r := Screen.WorkAreaRect;
      length                  := sizeof(WindowPlacement);
      flags                   := 0;
      showCmd                 := SW_SHOWNORMAL;
      ptMinPosition.X         := -1;
      ptMinPosition.Y         := -1;
      ptMaxPosition.X         := -1;
      ptMaxPosition.Y         := -1;
      rcNormalPosition.Left   := r.Left + (r.Right - r.Left - fm.Width) div 2;
      rcNormalPosition.Top    := r.Top + (r.Bottom - r.Top - fm.Height) div 2;
      rcNormalPosition.Right  := rcNormalPosition.Left + fm.Width - 1;
      rcNormalPosition.Bottom := rcNormalPosition.Top + fm.Height - 1
    end
    else begin
      length                  := sizeof(WindowPlacement);
      flags                   := UINT(NthInt(s, 1, ','));
      showCmd                 := UINT(NthInt(s, 2, ','));
      ptMinPosition.X         := NthInt(s,  3, ',');
      ptMinPosition.Y         := NthInt(s,  4, ',');
      ptMaxPosition.X         := NthInt(s,  5, ',');
      ptMaxPosition.Y         := NthInt(s,  6, ',');
      rcNormalPosition.Left   := NthInt(s,  7, ',');
      rcNormalPosition.Top    := NthInt(s,  8, ',');
      rcNormalPosition.Right  := NthInt(s,  9, ',');
      rcNormalPosition.Bottom := NthInt(s, 10, ',')
    end;

  // SetWindowsPlacement is in conflict with ShowMainForm := False;
  //SetWindowPlacement(fm.Handle, @WindowPlacement)
  //
  // so do it by hand...
  with WindowPlacement.rcNormalPosition do
    fm.SetBounds(Left, Top, Right - Left + 1, Bottom - Top + 1)
end;

// Weak version to avoid problems with large fonts when resizing

procedure SetWinStrPosition(fm : TForm; const s : string);
var
  r : TRect;
begin
  if s = ''
    then
      begin
        r       := Screen.WorkAreaRect;
        fm.Left := r.Left + (r.Right - r.Left - fm.Width) div 2;
        fm.Top  := r.Top + (r.Bottom - r.Top - fm.Height) div 2
      end
    else
      begin
        fm.Left := NthInt(s,  7, ',');
        fm.Top  := NthInt(s,  8, ',')
      end
end;

// -- Rectangles -------------------------------------------------------------

function ControlRect(control : TControl) : TRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := control.Width;
  Result.Bottom := control.Height;
end;

function ScreenPointInsideControl(point : TPoint; control : TControl) : boolean;
begin
  Result := PtInRect(control.BoundsRect, point)
end;

function MouseInsideControl(control : TControl) : boolean;
var
  point : TPoint;
begin
  GetCursorPos(point);
  Result := PtInRect(control.BoundsRect, point)
end;

// -- Handling a radio button list -------------------------------------------

procedure SetNthRadioButton(buttons : array of TSpTBXRadioButton; n : integer);
begin
  if Within(n, 0, High(buttons))
    then buttons[n].Checked := True
end;

function GetNthRadioButton(buttons : array of TSpTBXRadioButton) : integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 To High(buttons) do
    if buttons[i].Checked
      then Result := i
end;

// see also http://delphi.about.com/od/adptips2006/qt/radiogroupbtns.htm

// -- Set value of combobox (possibly not in items) --------------------------

procedure SetComboValue(cb : TComboBox; const s : string);
begin
  cb.ItemIndex := cb.Items.IndexOf(s);
  {if cb.ItemIndex < 0
    then} cb.Text := s
end;

procedure SetComboValue(cb : TTntComboBox; const s : WideString);
begin
  cb.ItemIndex := cb.Items.IndexOf(s);
  {if cb.ItemIndex < 0
    then} cb.Text := s
end;

// -- Control input validity for a numerical edit box ------------------------

function ValidateNumEdit(fm : TForm; ed : TCustomEdit; var n : integer) : boolean;
begin
  Result := TryStrToInt(ed.Text, n);
  if not Result
    then fm.ActiveControl := ed
end;

// -- Update memo displaying first line --------------------------------------

procedure UpdateMemoComment(memo : TTntMemo; const s : WideString);
var
  line : integer;
  onChangeBack : TNotifyEvent;
begin
  with memo do
    begin
      onChangeBack := OnChange;
      OnChange := nil;
      Lines.Add(s);
      OnChange := onChangeBack;
      line := SendMessage(Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
      SendMessage(Handle, EM_LINESCROLL, 0, -line)
    end
end;

// -- Enable all control children --------------------------------------------

procedure EnableControl(control : TWinControl; value : boolean);
var
  i : integer;
begin
  for i := 0 to control.ControlCount - 1 do
    begin
      control.Controls[i].Enabled := value;
      if control.Controls[i] is TWinControl
        then EnableControl(control.Controls[i] as TWinControl, value)
    end
end;

// -- Shortening of a string -------------------------------------------------

// from the WideString function with same name in VirtualTreeView
// credit Mike Lischke www.soft-gems.net

function ShortenString(canvas : TCanvas; const s : string; width : integer;
                       ellipsisWidth : integer = 0) : string;
var
  Size : TSize;
  len, L, H, N, W : integer;
begin
  // return input string if it fits
  Result := s;
  if canvas.TextWidth(s) < width
    then exit;

  // some inits
  Result := '';
  len := Length(s);

  // return empty string if no place
  if (len = 0) or (width <= 0)
    then exit;

  // determine width of ellipsis
  if ellipsisWidth = 0
    then ellipsisWidth := canvas.TextWidth('...');

  // return empty string if no place
  if Width <= EllipsisWidth
    then exit;

  // do a binary search for the optimal string length which fits into the given width.
  L := 0;
  H := Len - 1;
  while L < H do
    begin
      N := (L + H + 1) shr 1;
      GetTextExtentPoint(canvas.Handle, PChar(s), N, Size);
      W := Size.cx + EllipsisWidth;
      if W <= Width
        then L := N
        else H := N - 1;
    end;

  Result := Copy(S, 1, L) + '...'
end;

// -- WideMinimizeName -- (adapted from FileCtrl.pas in VCL source files) ----

procedure CutFirstDirectory(var S: WideString);
var
  Root: Boolean;
  P: Integer;
begin
  if S = '\' then
    S := ''
  else
  begin
    if S[1] = '\' then
    begin
      Root := True;
      Delete(S, 1, 1);
    end
    else
      Root := False;
    if S[1] = '.' then
      Delete(S, 1, 4);
    P := WidePos('\',S,1);
    if P <> 0 then
    begin
      Delete(S, 1, P);
      S := '...\' + S;
    end
    else
      S := '';
    if Root then
      S := '\' + S;
  end;
end;

function WideMinimizeName(const Filename: WideString; Canvas: TCanvas;
  MaxLen: Integer): WideString;
var
  Drive: WideString;
  Dir: WideString;
  Name: WideString;
begin
  Result := FileName;
  Dir := WideExtractFilePath(Result);
  Name := WideExtractFileName(Result);

  if (Length(Dir) >= 2) and (Dir[2] = ':') then
  begin
    Drive := Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive := '';
  while ((Dir <> '') or (Drive <> '')) and
         (WideCanvasTextWidth(Canvas, Result) > MaxLen) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then
      Drive := ''
    else
      CutFirstDirectory(Dir);
    Result := Drive + Dir + Name;
  end;
end;

// -- Shortening of a label --------------------------------------------------

// Used to minimize labels with AutoSize False keeping width constant. Labels
// do not have canvas, thus creates one. Using a TCanvas rather than a
// Tbitmpap launches a "canvas does not allow drawing" error.

function WideMinimizeLabel(labl : TSpTBXLabel; const s : WideString) : WideString;
var
  bmp : TBitmap;
begin
  Result := s;
  bmp := TBitmap.Create;
  try
    bmp.Canvas.Font.Assign(labl.Font);
    Result := WideMinimizeName(s, bmp.Canvas, labl.Width)
  finally
    bmp.Free
  end
end;

// -- Fight against flickering -----------------------------------------------

procedure AvoidFlickering(winCtrls : array of TWinControl);
var
  i : integer;
begin
  for i := Low(winCtrls) to High(winCtrls) do
    begin
      winCtrls[i].DoubleBuffered := True;

      // note TWinControl.ParentBackground is protected
      if winCtrls[i] is TFrame
        then (winCtrls[i] as TFrame).ParentBackground := False
      else if winCtrls[i] is TTntFrame
        then (winCtrls[i] as TTntFrame).ParentBackground := False
      else if winCtrls[i] is TForm
        then // nop
      else if winCtrls[i] is TPanel
        then (winCtrls[i] as TPanel).ParentBackground := False
      else if winCtrls[i] is TListBox
        then // nop
      else if winCtrls[i] is TGroupBox
        then (winCtrls[i] as TGroupBox).ParentBackground := False
      else if winCtrls[i] is TCheckBox
        then // nop
      else if winCtrls[i] is TTntStatusBar
        then // nop
      else if winCtrls[i] is THeaderControl
        then // nop
      else if winCtrls[i] is TStringGrid
        then // nop
      else if winCtrls[i] is TTntMemo
        then // nop
      else
        // if running from IDE, warn developer otherwise ignore
        Assert(DebugHook = 0, 'add type to AvoidFlickering!')
    end
end;

// -- Lock control under all modifications -----------------------------------
//
// http://www.swissdelphicenter.ch/torry/showcode.php?id=1301

procedure LockControl(c: TWinControl; bLock: Boolean);
begin
  if (c = nil) or (c.Handle = 0)
    then exit;

  if bLock
    then SendMessage(c.Handle, WM_SETREDRAW, 0, 0)
    else
      begin
        SendMessage(c.Handle, WM_SETREDRAW, 1, 0);
        RedrawWindow(c.Handle, nil, 0,
                     RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
      end
end;

// ---------------------------------------------------------------------------

end.
