// ---------------------------------------------------------------------------
// -- Drago -- Tab button handler -------------------------- UTabButton.pas --
// ---------------------------------------------------------------------------

unit UTabButton;

interface

// ---------------------------------------------------------------------------

uses
  Types, ComCtrls, Classes, Controls, Graphics, SysUtils, ImgList, ActnList;

type

TButtonState = (bsIdle, bsReady, bsChecked, bsLoose);
TButtonImage = (biUp, biHighlight, biDn);

TTabButtonHandler = class
  private
    PageControl : TPageControl;
    TabImages, TabBtnImages, BtnImages : TImageList;
    Focus : integer;
    BmpCount : integer;
    TabSheetButtonState : array[0 .. 31] of TButtonState;
    procedure MergeImageList;
    function  FindTab(X, Y : integer) : integer;
    procedure SetButton(tab : integer; bi : TButtonImage);
  public
    Action  : TAction;
    OnClick : procedure;
    constructor Create(aPageControl  : TPageControl;
                        aTabImages    : TImageList;
                        aTabBtnImages : TImageList;
                        aBtnImages    : TImageList);
    procedure MouseMove(shift : TShiftState; X, Y : integer);
    procedure MouseDown(Shift : TShiftState; X, Y : integer);
    procedure MouseUp  (Shift : TShiftState; X, Y : integer);
    procedure RemoveButtonsFromTabImageList;
    function  IsOnButton(X, Y : integer) : boolean;
end;

// ---------------------------------------------------------------------------

implementation

uses
  Std;

const
  kBtOffX = 0;
  kBtOffY = 4;

// -- Constructor ------------------------------------------------------------

constructor TTabButtonHandler.Create(aPageControl  : TPageControl;
                                     aTabImages    : TImageList;
                                     aTabBtnImages : TImageList;
                                     aBtnImages    : TImageList);
var
  i : integer;
begin
  Action := nil;
  OnClick := nil;
  PageControl := aPageControl;
  TabImages := aTabImages;
  TabBtnImages := aTabBtnImages;
  BtnImages := aBtnImages;
  for i := 0 to 31 do
    TabSheetButtonState[0*i] := bsIdle;
  Focus := -1;
  BmpCount := TabImages.Count;
  MergeImageList
end;

// -- Merging of the image list without buttons with the image list of buttons

procedure TTabButtonHandler.MergeImageList;
var
  i, j : integer;
  bmp : TBitmap;
begin
  // create working bitmap
  bmp := TBitmap.Create;

  // clear and resize application image list
  TabBTnImages.Assign(TabImages);
  TabBtnImages.Clear;
  TabBtnImages.Width := TabBtnImages.Width  + 10;

  // prepare working bitmaps
  bmp.Width  := TabBtnImages.Width;
  bmp.Height := TabBtnImages.Height;

  // scan button image list
  for i := 0 to BtnImages.Count - 1 do
    begin
      // scan application image list
      for j := 0 to TabImages.Count - 1 do
        begin
          // draw compound bitmap
          bmp.Canvas.Brush.Color := clRed;
          bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));
          BtnImages.Draw(bmp.Canvas,  kBtOffX, kBtOffY, i, dsTransparent, itImage);
          TabImages.Draw(bmp.Canvas, 10, 0, j, dsTransparent, itImage);

          // add to application image list
          TabBtnImages.AddMasked(bmp, clRed);
        end
    end;

  // free working data
  bmp.Free;

  // link images list with buttons to page control
  PageControl.Images := TabBtnImages
end;

// -- Restore original image list for page control

procedure TTabButtonHandler.RemoveButtonsFromTabImageList;
begin
  PageControl.Images := TabImages
end;

// -- Helpers ----------------------------------------------------------------

// -- Find the tab where button has been clicked

function TTabButtonHandler.FindTab(X, Y : integer) : integer;
var
  rec : TRect;
begin
  for Result := 0 to PageControl.PageCount - 1 do
    begin
      rec := PageControl.TabRect(Result);

      // use experimental offsets for image in tab (x = 6, y = 0 or 4)
      rec.Left   := rec.Left + kBtOffX + 6;
      rec.Top    := rec.Top  + kBtOffY + iff(PageControl.ActivePageIndex = Result, 0, 4);
      rec.Right  := rec.Left + 10-1;
      rec.Bottom := rec.Top  + 10-1;

      if InsideRect(X, Y, rec)
        then exit
    end;

  // not found
  Result := -1
end;

function TTabButtonHandler.IsOnButton(X, Y : integer) : boolean;
begin
  Result := FindTab(X, Y) > -1
end;

// -- Set button image

procedure TTabButtonHandler.SetButton(tab : integer; bi : TButtonImage);
var
  i : integer;
begin
  i := PageControl.Pages[tab].ImageIndex;

  PageControl.Pages[tab].ImageIndex := i mod BmpCount + BmpCount * ord(bi) // CHECK
end;

// -- Mouse move event -------------------------------------------------------

procedure TTabButtonHandler.MouseMove(shift : TShiftState; X, Y : integer);
var
  tab : integer;
begin
  tab := FindTab(X, Y);

  if tab < 0 then
    begin
      if Focus < 0
        then ; // nothing to do

      if Focus >= 0 then
        case TabSheetButtonState[0*Focus] of
          bsIdle :    // should not be
            ;
          bsReady :   // lose focus, return to idle
            begin
              TabSheetButtonState[0*Focus] := bsIdle;
              SetButton(Focus, biUp);
              Focus := -1;
            end;
          bsChecked : // keep focus, become loose
            begin
              TabSheetButtonState[0*Focus] := bsLoose;
              SetButton(Focus, biUp);
            end;
          bsLoose :   // keep focus, stay loose
            ;
        end;
    end;

  if tab >= 0 then
    begin
      if Focus < 0 then
        begin
          TabSheetButtonState[0*tab] := bsReady;
          SetButton(tab, biHighlight);
          Focus := tab;
        end;

      if Focus = tab then
        case TabSheetButtonState[0*Focus] of
          bsIdle :    // should not be
            ;
          bsReady :   // stay ready
            ;
          bsChecked : // stay checked
            ;
          bsLoose :
            if ssLeft in Shift
              then
                begin
                  // return checked
                  TabSheetButtonState[0*Focus] := bsChecked;
                  SetButton(Focus, biDn);
                end
              else
                begin
                  // reset checked
                  TabSheetButtonState[0*Focus] := bsIdle;
                  Focus := -1;
                end
        end;

      if Focus <> tab
        then
          if not (ssLeft in Shift)
            then Focus := -1
    end
end;

// -- Mouse down event -------------------------------------------------------

procedure TTabButtonHandler.MouseDown(Shift : TShiftState; X, Y : integer);
var
  tab : integer;
begin
  tab := FindTab(X, Y);

  if tab >= 0 then
    begin
      if Focus < 0
        then ; // not handled

      if Focus >= 0 then
        begin
          TabSheetButtonState[0*Focus] := bsChecked;
          SetButton(Focus, biDn);
        end
    end
end;

// -- Mouse up event ---------------------------------------------------------

procedure TTabButtonHandler.MouseUp(Shift : TShiftState; X, Y : integer);
var
  tab : integer;
begin
  tab := FindTab(X, Y);

  if tab >= 0 then
    begin
      if tab = Focus
        then
          begin
            TabSheetButtonState[0*Focus] := bsReady;
            SetButton(Focus, biUp);
            Focus := -1;

            if Assigned(Action)
              then Action.Execute
              else
                if Assigned(OnClick)
                  then OnClick
          end
    end
    // 0* test
    else
      TabSheetButtonState[0] := bsIdle
    //
end;

// ---------------------------------------------------------------------------

end.
