// ---------------------------------------------------------------------------
// -- Drago -- Some simple components ---------------------- Components.pas --
// ---------------------------------------------------------------------------

// TIntEdit      : TEdit with control of integer input
// TImageEx      : TImage with enter and leave mouse events
// TToolButtonEx : TToolButton with enter and leave mouse events

unit Components;

interface

uses 
  StdCtrls, Classes, SysUtils, ExtCtrls, Messages, Windows, IniFiles,
  Graphics, Controls, Forms, Dialogs, ComCtrls, Grids, TntGrids,
  TntStdCtrls;

type
    TIntEdit = class(TEdit)
    private
      function  GetValue : int64;
      procedure SetValue(val : int64);
    protected
      procedure KeyPress(var Key : Char); override;
    public
      FFormat : string;
      FNumDig : integer;
      constructor Create(AOwner : TComponent); override;
      property Value: Int64 read GetValue write SetValue;
  end;

  // not used. Does not work with multi byte languages
  TEmptyCaptionEdit = class(TTntEdit)
  private
    FEmptyCaption : WideString;
    procedure WMPaint(var msg: TWMPaint); message WM_PAINT;
  public
  published
    property EmptyCaption : WideString read FEmptyCaption write FEmptyCaption;
  end;

  TEditEx = class(TTntStringGrid)
  private
    FOnChange : TNotifyEvent;
    function GetText : WideString;
    procedure SetText(s : WideString);
  public
    constructor Create(AOwner : TComponent); override;
    property Text : WideString read GetText write SetText;
  published
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

  TImageEx = class(TImage)
  private
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    procedure CMMouseEnter(var msg : TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg : TMessage); message CM_MOUSELEAVE;
    protected
    procedure DoMouseEnter; dynamic;
    procedure DoMouseLeave; dynamic;
  public
    published
    property OnMouseEnter : TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave : TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TToolButtonEx = class(TToolButton)
  private
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    procedure CMMouseEnter(var msg : TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg : TMessage); message CM_MOUSELEAVE;
  protected
    procedure DoMouseEnter; dynamic;
    procedure DoMouseLeave; dynamic;
  public
  published
    property OnMouseEnter : TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave : TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TControlStringgrid = class(TStringgrid)
  private
    procedure WMCommand(var msg : TWMCommand); message WM_COMMAND;
  protected
  public
  published
  end;

type
  TListBoxEx = class(TListBox)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    function GetMyParentBackground : boolean;
    procedure SetMyParentBackground(pb : boolean);
    property ParentBackground : boolean read GetMyParentBackground write SetMyParentBackground;
  published
    { Published declarations }
  end;

type
  TColorDialogSaveCustom = class(TColorDialog)
  public
    IniFile : TMemIniFile;
    function Execute: Boolean; override;
  private
    procedure LoadIniFile;
    procedure SaveIniFile;
  end;

procedure Register;

// ---------------------------------------------------------------------------

implementation

uses
  TntGraphics;

// --

procedure Register;
begin
  RegisterComponents('Drago',
                     [TIntEdit, TImageEx, TToolButtonEx,
                      TControlStringgrid, TListBoxEx])
end;

function TListBoxEx.GetMyParentBackground : boolean;
begin
  Result := inherited ParentBackground
end;

procedure TListBoxEx.SetMyParentBackground(pb : boolean);
begin
  inherited ParentBackground := pb
end;

// -- TIntEdit ---------------------------------------------------------------

constructor TIntEdit.Create(aOwner : TComponent);
begin
  inherited;
  text := '0';
  width := 33;
  FFormat := '%d';
  FNumDig := 20
end;

function TIntEdit.GetValue : int64;
begin
  result := StrToIntDef(text, 0)
end;

procedure TIntEdit.Setvalue(val : int64);
begin
  text := Format(FFormat, [val])
end;

procedure TIntEdit.KeyPress(var Key : Char);
begin
  if Key in [#8, #13]
    then inherited KeyPress(Key)
    else
      if Key in ['+', '-', '0'..'9']
        then
          if (Length(Text) < FNumDig) or (SelLength <> 0)
            then inherited KeyPress(Key)
            else Key := #0
        else Key := #0
end;

// -- TEditEx ----------------------------------------------------------------

constructor TEditEx.Create(AOwner : TComponent);
begin
  inherited;
  Options := [goEditing];
  Height := 21;
  FixedRows := 0;
  FixedCols := 0;
  RowCount := 1;
  ColCount := 1;
  DefaultColWidth := Width
end;

function TEditEx.GetText : WideString;
begin
  Result := Cells[0, 0]
end;

procedure TEditEx.SetText(s : WideString);
begin
  Cells[0, 0] := s;
  if Assigned(FOnChange)
    then FOnChange(self)
end;

// -- TEmptyCaptionEdit ------------------------------------------------------

procedure TEmptyCaptionEdit.WMPaint(var msg: TWMPaint);
var
  Canvas : TCanvas;
  ps : TPaintStruct;
begin
  Canvas := TCanvas.Create;
  try
    BeginPaint(Handle, ps);
    Canvas.handle := ps.hdc;
    {$R-}
    Perform(WM_ERASEBKGND, Canvas.Handle, 0);
    {$R+}
    SaveDC(canvas.handle);
    try
      Canvas.Font := Font;
      if Text = ''
        then Canvas.Font.Color := clLtGray
        else
          if Enabled
            then Canvas.Font.Color := clBlack
            else Canvas.Font.Color := clLtGray;
(*
      if Text = ''
        then Canvas.TextOut(1, 1, EmptyCaption)
        else Canvas.TextOut(1, 1, Text);
*)
      if Text = ''
        then WideCanvasTextOut(Canvas, 1, 1, EmptyCaption)
        else WideCanvasTextOut(Canvas, 1, 1, Text)
    finally
      RestoreDC(Canvas.Handle, - 1);
    end;
  finally
    EndPaint(handle, ps);
    Canvas.Free
  end;
end;

// -- TImageEx ---------------------------------------------------------------

procedure TImageEx.CMMouseEnter(var msg : TMessage);
begin
  DoMouseEnter
end;

procedure TImageEx.CMMouseLeave(var msg : TMessage);
begin
  DoMouseLeave
end;

procedure TImageEx.DoMouseEnter;
begin
  if Assigned(FOnMouseEnter) then FOnMOuseEnter(self)
end;

procedure TImageEx.DoMouseLeave;
begin
  if Assigned(FOnMouseLeave) then FOnMOuseLeave(self)
end;

// -- TToolButtonEx ----------------------------------------------------------

procedure TToolButtonEx.CMMouseEnter(var msg : TMessage);
begin
  DoMouseEnter
end;

procedure TToolButtonEx.CMMouseLeave(var msg : TMessage);
begin
  DoMouseLeave
end;

procedure TToolButtonEx.DoMouseEnter;
begin
  if Assigned(FOnMouseEnter) then FOnMOuseEnter(self)
end;

procedure TToolButtonEx.DoMouseLeave;
begin
  if Assigned(FOnMouseLeave) then FOnMOuseLeave(self)
end;

// ---------------------------------------------------------------------------

{ TControlStringgrid }
//Peter Below (TeamB)
//http://www.nsonic.de/Delphi/txt_WIS00451.htm

procedure TControlStringgrid.WMCommand(var msg: TWMCommand);
begin
  If EditorMode and ( msg.Ctl = InplaceEditor.Handle ) Then
    inherited
  Else
    If msg.Ctl <> 0 Then
    msg.result :=
        SendMessage( msg.ctl, CN_COMMAND,
              TMessage(msg).wparam,
              TMessage(msg).lparam );
end;

// ---------------------------------------------------------------------------

const
  CustomColorSection = 'CustomColors';

function TColorDialogSaveCustom.Execute : boolean;
begin
  LoadIniFile;
  Result := inherited Execute;
  SaveIniFile
end;

procedure TColorDialogSaveCustom.LoadIniFile;
var
  i : integer;
  s : string;
begin
  CustomColors.Clear;
  for i := 0 to 15 do
    begin
      s := IniFile.ReadString(CustomColorSection, 'Color' + Chr(65 + i), '000000');
      CustomColors.Add('Color' + Chr(65 + i) + '=' + s)
    end
end;

procedure TColorDialogSaveCustom.SaveIniFile;
var
  i : integer;
  s : string;
begin
  for i := 0 to 15 do
    begin
      s := CustomColors.Strings[i];
      s := Copy(s, Pos('=', s) + 1, MaxInt);
      if s <> '000000'
        then IniFile.WriteString(CustomColorSection, 'Color' + Chr(65 + i), s)
    end
end;

// ---------------------------------------------------------------------------

end.

