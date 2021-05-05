// ---------------------------------------------------------------------------
// -- Drago -- Frame to display list of variations ------ UfrVariations.pas --
// ---------------------------------------------------------------------------

unit UfrVariations;

// ---------------------------------------------------------------------------

interface

uses
  Types, SysUtils, Classes, Graphics, Forms,
  Controls, StdCtrls, TntStdCtrls, TntGraphics, 
  DefineUi;

type
  TfrVariations = class(TFrame)
    lbVariation: TTntListBox;
    procedure lbVariationDrawItem(Control: TWinControl; Index: Integer;
                                  Rect: TRect; State: TOwnerDrawState);
  private
    procedure DrawVarTitle(const s : WideString; rec : TRect);
    procedure DrawVarLine (const s : WideString; rec : TRect);
    procedure DisplayField(const s : WideString; rec : TRect; x1, x2, color : integer);
    procedure DrawPatLine (const s : WideString; rec : TRect);
  public
    procedure VarClear(varStyle : TVarStyle);
    procedure VarAdd(const s : string; selected : boolean);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std, Translate;

{$R *.dfm}

// -- Reset of the listbox ---------------------------------------------------

procedure TfrVariations.VarClear(varStyle : TVarStyle);
begin
  with lbVariation do
    if Visible then
      begin
        Items.Clear;
        if varStyle = vsChildren
          then Items.Add(U('Next moves'))
          else Items.Add(U('Alternate moves'))
      end
end;

// -- Addition of an item in the listbox -------------------------------------
//
// -- Add '+' in front the string to add if selected, '-' otherwise

procedure TfrVariations.VarAdd(const s : string; selected : boolean);
begin
  if lbVariation.Visible
    then lbVariation.Items.Add(iff(selected, '+', '-') + UTF8Decode(s));

  // force item index to avoid dotted rectangle on first line after
  // clicking on list in sibling mode (perhaps drawn because list is
  // cleared in VarClear).
  if selected
    then lbVariation.ItemIndex := lbVariation.Items.Count - 1
end;

// -- Display utility routines -----------------------------------------------

const
  off0 = 0;
  off1 = 16;
  off2 = 55;
  off3 = 85;
  off4 = 115;
  offT = 4;

// -- Display of variation title in listbox

procedure TfrVariations.DrawVarTitle(const s : WideString; rec : TRect);
begin
  with lbVariation.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(rec);
      WideCanvasTextOut(lbVariation.Canvas, rec.Left + 2, rec.Top + offT, s)
    end
end;

// -- Display of variation line in listbox

procedure TfrVariations.DrawVarLine(const s : WideString; rec : TRect);
var
  index, coord, nodename, played, playedpc, winpc : WideString;
  brushColorFont : TColor;
begin
  index := Copy(s, 2, 2);
  coord := Copy(s, 5, 5);
  nodename := Copy(s, 11, MAXINT);

  with lbVariation.Canvas do
    begin
      // BtnFace color if selected, white otherwise
      if s[1] = '+'
        then brushColorFont := clBtnFace
        else brushColorFont := clWhite;

      Brush.Color := brushColorFont;
      FillRect(rec);
      Font.Color := clBlack;

      // display number of variation
      DisplayField(index, rec, off0, off1, brushColorFont);

      // display coordinates of variation (or pass)
      DisplayField(coord, rec, off1, off2, brushColorFont);

      if True//si.ModeInter <> kimFU
        then
          // display node name
          DisplayField(nodename, rec, off2, rec.Right, brushColorFont)
        else
          begin
            nodename := TrimLeft(nodename);
            played   := NthWord(nodename, 1);
            playedpc := NthWord(nodename, 2);
            winpc    := NthWord(nodename, 3);
            DisplayField(played, rec, off2, off3, brushColorFont);
            DisplayField(playedpc, rec, off3, off4, brushColorFont);
            DisplayField(winpc, rec, off4, rec.Right, brushColorFont)
          end
     end
end;

procedure TfrVariations.DisplayField(const s : WideString;
                                      rec : TRect;
                                      x1, x2, color : integer);
begin
  with lbVariation.Canvas do
    begin
      Brush.Color := color;
      WideCanvasTextOut(lbVariation.Canvas, x1 + 2, rec.Top + offT, s);
      Brush.Color := clLtGray;
      FrameRect(Rect(x1, rec.Top, x2, rec.Bottom + 1))
    end
end;

// -- Display line for pattern search

procedure TfrVariations.DrawPatLine(const s : WideString; rec : TRect);
begin
  with lbVariation.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(rec);
      Font.Color := clBlack;
      TextOut(rec.Left + 2, rec.Top + offT, Copy(s, 2, 1000))
    end
end;

// -- Draw item event --------------------------------------------------------

procedure TfrVariations.lbVariationDrawItem(Control : TWinControl;
                                             Index : Integer;
                                             Rect  : TRect;
                                             State : TOwnerDrawState);
var
  s : WideString;
begin
  s := (Control as TTntListBox).Items[Index];

  if Index = 0
    then DrawVarTitle(s, Rect)
    else DrawVarLine(s, Rect)
end;

// ---------------------------------------------------------------------------

end.
