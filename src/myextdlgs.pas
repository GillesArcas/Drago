
{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{       Copyright (c) 1995,99 Inprise Corporation       }
{                                                       }
{*******************************************************}
{
  This file redefines the OpenPictureDialog to replace the following resource
  strings with calls to Drago translation function T(''):

  srNone = '(empty)';
  SPictureLabel = 'Image:';
  SPreviewLabel = 'Preview';
}

unit MyExtDlgs;

{$R-,H+,X+}

interface

uses
  Messages, Windows, SysUtils, Classes, Controls, StdCtrls, Graphics,
  ExtCtrls, Buttons, Dialogs;

type

{ TMyOpenPictureDialog }

  TMyOpenPictureDialog = class(TOpenDialog)
  private
    FPicture: TPicture;
    FPicturePanel: TPanel;
    FPictureLabel: TLabel;
    FPreviewButton: TSpeedButton;
    FPaintPanel: TPanel;
    FPaintBox: TPaintBox;
    function  IsFilterStored: Boolean;
    procedure PaintBoxPaint(Sender: TObject);
    procedure PreviewClick(Sender: TObject);
    procedure PreviewKeyPress(Sender: TObject; var Key: Char);
  protected
    procedure DoClose; override;
    procedure DoSelectionChange; override;
    procedure DoShow; override;
  published
    property Filter stored IsFilterStored;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; override;
  end;

{ TSavePictureDialog }

  TSavePictureDialog = class(TMyOpenPictureDialog)
  public
    function Execute: Boolean; override;
  end;

implementation

uses Consts, Forms, CommDlg, Dlgs, Translate;

{ TMyOpenPictureDialog }

//{$R MYEXTDLGS.RES}

constructor TMyOpenPictureDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := GraphicFilter(TGraphic);
  FPicture := TPicture.Create;
  FPicturePanel := TPanel.Create(Self);
  with FPicturePanel do
  begin
    Name := 'PicturePanel';
    Caption := '';
    SetBounds(204, 5, 169, 200);
    BevelOuter := bvNone;
    BorderWidth := 6;
    TabOrder := 1;
    FPictureLabel := TLabel.Create(Self);
    with FPictureLabel do
    begin
      Name := 'PictureLabel';
      Caption := '';
      SetBounds(6, 6, 157, 23);
      Align := alTop;
      AutoSize := False;
      Parent := FPicturePanel;
    end;
    FPreviewButton := TSpeedButton.Create(Self);
    with FPreviewButton do
    begin
      Name := 'PreviewButton';
      SetBounds(77, 1, 23, 22);
      Enabled := False;
      Glyph.LoadFromResourceName(HInstance, 'PREVIEWGLYPH');
      Hint := T('Preview2'); ///SPreviewLabel;
      ParentShowHint := False;
      ShowHint := True;
      OnClick := PreviewClick;
      Parent := FPicturePanel;
    end;
    FPaintPanel := TPanel.Create(Self);
    with FPaintPanel do
    begin
      Name := 'PaintPanel';
      Caption := '';
      SetBounds(6, 29, 157, 145);
      Align := alClient;
      BevelInner := bvRaised;
      BevelOuter := bvLowered;
      TabOrder := 0;
      FPaintBox := TPaintBox.Create(Self);
      Parent := FPicturePanel;
      with FPaintBox do
      begin
        Name := 'PaintBox';
        SetBounds(0, 0, 153, 141);
        Align := alClient;
        OnDblClick := PreviewClick;
        OnPaint := PaintBoxPaint;
        Parent := FPaintPanel;
      end;
    end;
  end;
end;

destructor TMyOpenPictureDialog.Destroy;
begin
  FPaintBox.Free;
  FPaintPanel.Free;
  FPreviewButton.Free;
  FPictureLabel.Free;
  FPicturePanel.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TMyOpenPictureDialog.DoSelectionChange;
var
  FullName: string;
  ValidPicture: Boolean;

  function ValidFile(const FileName: string): Boolean;
  begin
    Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
  end;

begin
  FullName := FileName;
  ValidPicture := FileExists(FullName) and ValidFile(FullName);
  if ValidPicture then
  try
    FPicture.LoadFromFile(FullName);
    FPictureLabel.Caption := Format(SPictureDesc,
      [FPicture.Width, FPicture.Height]);
    FPreviewButton.Enabled := True;
  except
    ValidPicture := False;
  end;
  if not ValidPicture then
  begin
    FPictureLabel.Caption := T('Image:'); ///SPictureLabel
    FPreviewButton.Enabled := False;
    FPicture.Assign(nil);
  end;
  FPaintBox.Invalidate;
  inherited DoSelectionChange;
end;

procedure TMyOpenPictureDialog.DoClose;
begin
  inherited DoClose;
  { Hide any hint windows left behind }
  Application.HideHint;
end;

procedure TMyOpenPictureDialog.DoShow;
var
  PreviewRect, StaticRect: TRect;
begin
  { Set preview area to entire dialog }
  GetClientRect(Handle, PreviewRect);
  StaticRect := GetStaticRect;
  { Move preview area to right of static area }
  PreviewRect.Left := StaticRect.Left + (StaticRect.Right - StaticRect.Left);
  Inc(PreviewRect.Top, 4);
  FPicturePanel.BoundsRect := PreviewRect;
  FPreviewButton.Left := FPaintPanel.BoundsRect.Right - FPreviewButton.Width - 2;
  FPicture.Assign(nil);
  FPicturePanel.ParentWindow := Handle;
  inherited DoShow;
end;

function TMyOpenPictureDialog.Execute;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'DLGTEMPLATE' else
    Template := nil;
  Result := inherited Execute;
end;

procedure TMyOpenPictureDialog.PaintBoxPaint(Sender: TObject);
var
  DrawRect: TRect;
  SNone: string;
begin
  with TPaintBox(Sender) do
  begin
    Canvas.Brush.Color := Color;
    DrawRect := ClientRect;
    if FPicture.Width > 0 then
    begin
      with DrawRect do
        if (FPicture.Width > Right - Left) or (FPicture.Height > Bottom - Top) then
        begin
          if FPicture.Width > FPicture.Height then
            Bottom := Top + MulDiv(FPicture.Height, Right - Left, FPicture.Width)
          else
            Right := Left + MulDiv(FPicture.Width, Bottom - Top, FPicture.Height);
          Canvas.StretchDraw(DrawRect, FPicture.Graphic);
        end
        else
          with DrawRect do
            Canvas.Draw(Left + (Right - Left - FPicture.Width) div 2, Top + (Bottom - Top -
              FPicture.Height) div 2, FPicture.Graphic);
    end
    else
      with DrawRect, Canvas do
      begin
        SNone := T('(empty)'); ///srNone
        TextOut(Left + (Right - Left - TextWidth(SNone)) div 2, Top + (Bottom -
          Top - TextHeight(SNone)) div 2, SNone);
      end;
  end;
end;

procedure TMyOpenPictureDialog.PreviewClick(Sender: TObject);
var
  PreviewForm: TForm;
  Panel: TPanel;
begin
  PreviewForm := TForm.Create(Self);
  with PreviewForm do
  try
    Name := 'PreviewForm';
    Caption := T('Preview2'); ///SPreviewLabel
    BorderStyle := bsSizeToolWin;
    KeyPreview := True;
    Position := poScreenCenter;
    OnKeyPress := PreviewKeyPress;
    Panel := TPanel.Create(PreviewForm);
    with Panel do
    begin
      Name := 'Panel';
      Caption := '';
      Align := alClient;
      BevelOuter := bvNone;
      BorderStyle := bsSingle;
      BorderWidth := 5;
      Color := clWindow;
      Parent := PreviewForm;
      with TImage.Create(PreviewForm) do
      begin
        Name := 'Image';
        Caption := '';
        Align := alClient;
        Stretch := True;
        Picture.Assign(FPicture);
        Parent := Panel;
      end;
    end;
    if FPicture.Width > 0 then
    begin
      ClientWidth := FPicture.Width + (ClientWidth - Panel.ClientWidth)+ 10;
      ClientHeight := FPicture.Height + (ClientHeight - Panel.ClientHeight) + 10;
    end;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMyOpenPictureDialog.PreviewKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then TForm(Sender).Close;
end;

{ TSavePictureDialog }

function TSavePictureDialog.Execute: Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'DLGTEMPLATE' else
    Template := nil;
  Result := DoExecute(@GetSaveFileName);
end;

function TMyOpenPictureDialog.IsFilterStored: Boolean;
begin
  Result := not (Filter = GraphicFilter(TGraphic));
end;

end.
