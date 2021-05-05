// ---------------------------------------------------------------------------
// -- Drago -- About dialog ---------------------------------- UfmAbout.pas --
// ---------------------------------------------------------------------------

unit UfmAbout;

// ---------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Jpeg, ExtCtrls, SpTBXControls, StdCtrls,
  TntForms, TntComCtrls, ComCtrls, SpTBXItem;

type
  TfmAbout = class(TTntForm)
    Image1: TImage;
    PageControl: TTntPageControl;
    TabSheetLicense: TTntTabSheet;
    mmLicense: TMemo;
    TabSheetCredits: TTntTabSheet;
    TabSheetAbout: TTntTabSheet;
    pnCredits: TSpTBXPanel;
    pnAbout: TSpTBXPanel;
    procedure FormShow(Sender: TObject);
  private
    procedure LoadLicense;
  public
    class function Execute : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  ShellAPI, Types,
  DefineUi, Std, Translate, TranslateVcl;

// ---------------------------------------------------------------------------

class function TfmAbout.Execute : boolean;
begin
  with TfmAbout.Create(Application) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure TfmAbout.LoadLicense;
var
  tmpStream: TResourceStream;
begin
  tmpStream := TResourceStream.Create(HInstance, 'LICENSE', 'TEXT');
  try
    mmLicense.Lines.LoadFromStream(tmpStream);
  finally
    tmpStream.Free;
  end;
end;

var
  StrAbout : array[0 .. 7] of string =
  ('DRAGO',
   'version',
   kCopyright,
   'Drago is freeware',
   '---',
   'Gilles Arcas-Luque',
   'gilles_arcas@hotmail.com',
   'www.godrago.net');

  StrCredits : array[0 .. 12] of string =
  ('libkombilo and Kombilo are developed by Ulrich Goertz:',
   'www.u-go.net/kombilo/',
   '---',
   'Player images are courtesy of',
   'Nihon Ki-in, Kansai Ki-in and Hanguk Kiwon.',
   '---',
   'Full size player images may be found on GoGoD CD:',
   'www.gogod.co.uk',
   'Thanks to GoGoD team for authorization to include fuseki8.sgf',
   'extracted from GoGoD CD summer 2010 database.',
   '---',
   'More credits:',
   'www.godrago.net/Credits.htm');

function IsLink(s : string) : boolean;
begin
  Result := (Pos('@', s) > 0) or
            (Pos('www.', s) > 0) or
            (Pos('http:', s) > 0)
end;

procedure ShowLink(st : TSpTBXLabel);
begin
  if IsLink(st.Caption) then
    begin
      st.Font.Color := clHotLight;
      st.LinkText := st.Caption;
      if (Pos('@', st.LinkText) > 0) and (Pos('mailto:', st.LinkText) = 0)
        then st.LinkText := 'mailto:' + st.LinkText
    end
end;

procedure DisplayStrings(panel : TSpTBXPanel; strings : array of string; mode : integer);
const
  lineHeight = 22;
var
  i, y : integer;
  x : TComponent;
begin
  y := (panel.Height - Length(strings) * lineHeight) div 2;

  for i := 0 to High(strings) do
    begin
      if strings[i] = '---'
        then x := TBevel.Create(panel)
        else x := TSpTBXLabel.Create(panel);

      if x is TBevel then
        with x as TBevel do
          begin
            Parent := panel;
            Top := y + lineHeight div 2 - 2;
            Width := 225;
            Height := 2;
            Left := (panel.Width - Width) div 2;
            Shape := bsBox;
            Style := bsLowered;
          end;

      if x is TSpTBXLabel then
        with x as TSpTBXLabel do
          begin
            Parent := panel;
            Top := y;
            Height := lineHeight;
            Font.Name := 'MS Sans Serif';
            Font.Height := 14;
            if strings[i] = 'DRAGO'
              then Font.Style := [fsBold]
              else Font.Style := [];

            // some thing strange here. The 2 tabs seem to have different
            // behaviours...
            if mode = 0
              then
                begin
                  AutoSize := True;
                  Caption := UTF8DecodeX(strings[i]);
                  Left := (panel.ClientWidth - ClientWidth) div 2;
                end
              else
                begin
                  AutoSize := False;
                  Caption := UTF8DecodeX(strings[i]);
                  Width := panel.Width;
                  Left := 0;
                  Alignment := taCenter
                end;

            ShowLink(x as TSpTBXLabel)
          end;

      inc(y, lineHeight)
    end;

end;

procedure TfmAbout.FormShow(Sender: TObject);
var
  s : string;
  i : integer;
  str : array of string;
  trad : TStringDynArray;
begin
  Caption := AppName + ' - ' + U('About');

  TranslateForm(self);
  
  // load license resource
  LoadLicense;

  SetLength(str, Length(StrAbout));
  for i := 0 to High(StrAbout) do
    str[i] := StrAbout[i];
  str[1] := T('Version') + ' ' + AppVersion;

  s := T('$TranslationCredit');
  if (s = '$TranslationCredit') or (s = '')
    then // nop
    else
      begin
        s := StringReplace(s, '\n', ';', [rfReplaceAll]);
        Split(s, trad, ';');

        SetLength(str, Length(StrAbout) + Length(trad) + 1);
        str[Length(StrAbout)] := '---';
        for i := 0 to High(trad) do
          str[i + Length(StrAbout) + 1] := trad[i]
      end;

  DisplayStrings(pnAbout, str, 0);
  DisplayStrings(pnCredits, StrCredits, 1);

  // for some reason, the display is messed up on first tabsheet
  TabSheetLicense.PageIndex := 2;

  // open on about tabsheet
  PageControl.TabIndex := 0;
end;

// ---------------------------------------------------------------------------

end.

// ---------------------------------------------------------------------------

// -- Redefinition of TStaticText to handle hyperlink

type
  TTntStaticText = class(TntStdCtrls.TTntStaticText)
  private
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Draw(Active: Boolean);
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
  end;

procedure TfmAbout.ShowLink(st : TTntStaticText);
begin
  if IsLink(st.Caption) then
    begin
      st.Transparent := False;
      st.Font.Color  := clHotLight;
      st.Font.Style  := [fsUnderline];
      st.OnClick     := URLClick
    end
end;

// Handling hyperlink by redefining TStaticText before form declaration comes
// from a tip by Eddie Shipman at www.delphipages.com/news/detaildocs.cfm?ID=147

procedure TTntStaticText.Draw(Active: Boolean);
begin
  with Self.Font do
    if Active
      then
        if not Focused
          then Screen.Cursor := crHandPoint
          else // nop
      else
        if not Focused
          then Screen.Cursor := crDefault
end;

procedure TTntStaticText.CMMouseEnter(var Message: TMessage);
begin
  if not IsLink(Caption)
    then exit;
  inherited;
  Draw(True);
end;

procedure TTntStaticText.CMMouseLeave(var Message: TMessage);
begin
  if not IsLink(Caption)
    then exit;
  inherited;
  Draw(False);
end;

procedure TTntStaticText.WMKillFocus(var Message: TWMSetFocus);
begin
  if not IsLink(Caption)
    then exit;
  inherited;
  Draw(False);
end;

procedure TTntStaticText.WMSetFocus(var Message: TWMSetFocus);
begin
  if not IsLink(Caption)
    then exit;
  inherited;
  Draw(True);
end;

procedure TTntStaticText.WMKeyUp(var Message: TWMKeyUp);
begin
  if not IsLink(Caption)
    then exit;
  if Assigned(OnClick) and (Message.CharCode = 13)
    then Click
end;

// ---------------------------------------------------------------------------

procedure TfmAbout.URLClick(Sender: TObject);
var
  s : string;
begin
  s := TStaticText(Sender).Caption;

  if not IsLink(s)
    then s := TStaticText(Sender).Hint;

  if not IsLink(s)
    then exit;

  if (Pos('@', s) > 0) and (Pos('mailto:', s) = 0)
    then s := 'mailto:' + s;

  ShellExecute(0, 'open', PChar(s), '', '', SW_SHOW)
end;




