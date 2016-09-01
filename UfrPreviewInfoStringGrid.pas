// ---------------------------------------------------------------------------
// -- Drago : Information preview frame ----------------- UFRPREVIEWINFO.PAS--
// ---------------------------------------------------------------------------

unit UfrPreviewInfo;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, StdCtrls, Buttons, ComCtrls, ExtCtrls, ImgList, Types,
  TntSystem, TntGraphics,
  Define, UContext, UTViewBoard, TntGrids;

const maxCol = 13;

type
   TfrPreviewInfo = class(TFrame)
      ImageList: TImageList;
      Bevel1: TBevel;
      HeaderControl: THeaderControl;
      StringGrid: TTntStringGrid;
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;
      procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
                                   Rect: TRect; State: TGridDrawState);
      procedure FrameEnter(Sender: TObject);
      procedure StringGridDblClick(Sender: TObject);
      procedure HeaderControlSectionResize(HeaderControl: THeaderControl;
                                           Section: THeaderSection);
      procedure StringGridClick(Sender: TObject);
      procedure HeaderControlSectionClick(HeaderControl: THeaderControl;
                                          Section: THeaderSection);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
   private
      ViewMode : TViewMode;
      Sorted  : array[0 .. maxCol - 1] of integer;
      StringGridEmpty : boolean;
      procedure DoWhenCreating;
      function  NumberToDisplay : integer;
      procedure ConfigGrid(cx : TContext);
      procedure ConfigGridDef(infoCol : string);
      procedure ConfigGridPb;
      procedure ConfigGridGm;
      procedure ConfigGridApply(nCol : integer; width : array of integer;
                                caption : array of string);
      procedure StoreGridDesc();
      procedure UpdateCurrentGame(newRow : integer);
      procedure SortIndex(Acol : integer);
   public
      xgv : Tgview; // pointer on current gview
      procedure DoWhenUpdating;
      procedure DoWhenShowing;
      procedure GetRowStrings(ARow : integer);
      function  GameOnRow(i : integer) : integer;
      function  ClickInGrid : boolean;
      function  SelectedGame : integer;
      procedure FirstGame;
      procedure LastGame;
      procedure PrevGame;
      procedure NextGame;
      procedure GotoGame(n : integer);
      procedure GameInfo(Sender : TObject);
  end;

// ---------------------------------------------------------------------------

implementation

uses
   Std, Translate, Ugtree, Ux2y, Main, UTView, Ugcom, Properties, UMemo,
   UfmMsg;

{$R *.dfm}

// -- Note on caching --------------------------------------------------------

// We avoid to load the complete stringgrid by accessing only to the info
// values from the cells to display.

const EnableCaching = True;

// -- Constructor ------------------------------------------------------------

constructor TfrPreviewInfo.Create(aOwner : TComponent);
begin
   if aOwner <> nil
      then inherited Create(aOwner);

   // fight against flickering
   AvoidFlickering([self, HeaderControl, StringGrid]);

   //DoWhenCreating;
   //ShowTextDef;
end;

procedure TfrPreviewInfo.DoWhenCreating;
begin
   //StringGrid.ColCount := maxCol
end;

destructor TfrPreviewInfo.Destroy;
begin
   inherited Destroy
end;

// -- Display and update -----------------------------------------------------

procedure TfrPreviewInfo.DoWhenUpdating;
var k : integer;
begin
   // link with context and store view mode
   xgv := ((Parent as TView).Tab as TTabSheetEx).gv;
   ViewMode := xgv.si.ViewMode;

   // settings of string grid
   StringGrid.RowCount := NumberToDisplay;
   StringGridEmpty := NumberToDisplay = 0;
   ConfigGrid(xgv.Context);

   // erase first line (if NumberToDisplay = 0, RowCount is still 1)
   StringGrid.Rows[0].Text := '';

   // initialize 1st cell in row (to be tested when caching)
   for k := 1 to NumberToDisplay do
      if EnableCaching
         then StringGrid.Rows[k - 1].Text := ''
         else GetRowStrings(k - 1)
end;

procedure TfrPreviewInfo.FrameEnter(Sender: TObject);
begin
   DoWhenShowing
end;

procedure TfrPreviewInfo.DoWhenShowing;
var i, n : integer;
begin
   if xgv = nil
      then exit;

   // Sections are initialized when updating the view.  However, when starting
   // and loading a PreviewInfo, sections are initialized but sections seem to
   // be reset, but the Tag keeps its value. This is used to detect and correct
   // the problem but should be handled in a more satisfactory way.

   if True//HeaderControl.Tag <> HeaderControl.Sections.Count
      then ConfigGrid(xgv.Context);

   i := xgv.si.IndexTree - 1;
   //n := StringGrid.VisibleColCount; !!
   n := StringGrid.VisibleRowCount;
   (*
   if n = 0
      then StringGrid.TopRow := i
      else StringGrid.TopRow := (i div n) * n;
   *)
   if n = 0
      then exit;

   StringGrid.TopRow := (i div n) * n;

   // en test, plutot que le code apr�s
   if (i >= 0) and (i < StringGrid.RowCount)
      then StringGrid.Row := i

   // move focus to current game if stringgrid visible
   (*
   with Parent as TView do
      if Tab = fmMain.ActiveControl then
         with Tab as TTabSheetEx do
            if cx.si.ViewMode in [vmInfo, vmInfoPb, vmInfoGm] then
               try
                  fmMain.ActiveControl := StringGrid;
                  StringGrid.Row := i
               except
                  //cannot focus a disabled or invisible window
               end
   if fmMain.ActiveControl = fmMain.PageControl then
      if fmMain.PageControl.ActivePage = (Parent as TView).Tab then
         with (Parent as TView).Tab as TTabSheetEx do
            if cx.si.ViewMode in [vmInfo, vmInfoPb, vmInfoGm] then
               try
                  fmMain.ActiveControl := StringGrid;
                  StringGrid.Row := i
               except
                  //cannot focus a disabled or invisible window
               end
   *)
end;

// -- Settings of grid -------------------------------------------------------

procedure TfrPreviewInfo.ConfigGrid(cx : TContext);
begin
   case cx.si.ViewMode of
      vmInfo   : ConfigGridDef(cx.st.InfoCol);
      vmInfoGm : ConfigGridGm();
      vmInfoPb : ConfigGridPb();
   end
end;

// -- Default mode

const k1stWidth = 40;

procedure TfrPreviewInfo.ConfigGridDef(infoCol : string);
var n, l, i, w : integer;
    widthArray : array of integer;
    captionArray : array of string;
    atLessOneNot0 : boolean;
    pn : string;
begin
   n := NthInt(infoCol, 1, ';');
   if n = 0
      then
         begin
            // something wrong
            l := (ClientWidth - k1stWidth) div 5;

            ConfigGridApply(6,
                            [k1stWidth, l, l, l, l, l - 3],
                            ['#', 'PB', 'PW', 'PC', 'DT', 'RE']);

            xgv.st.InfoCol := '5;PB;;PW;;PC;;DT;;RE;;'
         end
      else
         begin
            l := (ClientWidth - k1stWidth) div n;

            SetLength(widthArray, n + 1);
            SetLength(captionArray, n + 1);
            atLessOneNot0 := False;

            captionArray[0] := '#';
            widthArray[0] := k1stWidth;

            for i := 1 to n do
               begin
                  pn := NthWord(infoCol, (i - 1) * 2 + 2, ';');
                  w  := Nthint (infoCol, (i - 1) * 2 + 3, ';');
                  if w <> 0
                     then atLessOneNot0 := True;
                  captionArray[i] := pn;
                  widthArray[i] := w
               end;

            if not atLessOneNot0 then
               for i := 1 to n do
                  widthArray[i] := l;

            ConfigGridApply(n + 1, widthArray, captionArray)
         end;
end;

// -- Problem mode

procedure TfrPreviewInfo.ConfigGridPb;
begin
   ConfigGridApply(4,
                  [30, 100, 100, 100],
                  ['#', 'Trials', 'Success', '%'])
end;

// -- Game replay mode

procedure TfrPreviewInfo.ConfigGridGm;
var l : integer;
begin
   l := (Width - 30 - 30 - 7*32) div 5;
   ConfigGridApply(13, [30, l, l, l, l, l, 32, 32, 32, 32, 32, 32, 30],
                   ['', 'Black', 'White', 'Place', 'Date', 'Result',
                    '#', 'GB', 'GW', 'G', 'FB', 'FW', 'F'])
end;

// -- Generic routine

procedure TfrPreviewInfo.ConfigGridApply(nCol : integer;
                                         width : array of integer;
                                         caption : array of string);
var i, w : integer;
begin
   StringGrid.ColCount := nCol;

   HeaderControl.Sections.Clear();

   for i := 0 to nCol - 1 do
      begin
         if i = 0
            then w := width[i] + 4
            else w := width[i] + 1;

         with HeaderControl.Sections do
            begin
               Add();
               Items[i].Width := w;
               Items[i].ImageIndex := iff(NumberToDisplay > fmMain.st.SortLimit, -1, 0);

               if ViewMode = vmInfo
                  then
                     if i = 0
                        then Items[i].Text := caption[i]
                        else Items[i].Text := T(FindPropText(caption[i]))
                  else Items[i].Text := T(caption[i])
            end;

         StringGrid.ColWidths[i] := width[i];
         Sorted[i] := 0
      end;

   // see DoWhenShowing
   HeaderControl.Tag := HeaderControl.Sections.Count
end;

// -- Storage of grid config

procedure TfrPreviewInfo.StoreGridDesc();
var desc, s : string;
    i : integer;
begin
   // save column settings only for default mode
   if ViewMode <> vmInfo
      then exit;

   desc := xgv.st.InfoCol;

   s := NthWord(desc, 1, ';');
   for i := 1 to StringGrid.ColCount - 1 do
      begin
         s := s + ';' + NthWord(desc, (i - 1) * 2 + 2, ';');
         s := s + ';' + IntToStr(StringGrid.ColWidths[i])
      end;

   xgv.st.InfoCol := s
end;

// -- Draw cell event --------------------------------------------------------
//
// -- Owner draw enables caching and header adjustment

procedure TfrPreviewInfo.StringGridDrawCell(Sender: TObject;
                                             ACol, ARow: Integer;
                                             Rect: TRect;
                                             State: TGridDrawState);
var val : WideString;
    i, w : integer;
begin
   if (ACol < 0) or (ARow < 0)
      then exit;
      
   // adjust header when displaying top left cell (for horizontal scrolling)
   if (ARow = StringGrid.TopRow) and (Acol = StringGrid.LeftCol) then
      begin
         IdeAssert(StringGrid.ColCount = HeaderControl.Sections.Count);

         for i := 0 to StringGrid.ColCount - 1 do
            if i < StringGrid.LeftCol
               then HeaderControl.Sections.Items[i].Width := 0
               else
                  begin
                     if i = StringGrid.LeftCol
                        then w := StringGrid.ColWidths[i] + 4
                        else w := StringGrid.ColWidths[i] + 1;

                     HeaderControl.Sections.Items[i].Width := w
                  end
      end;

   // fill cells in row if required
   GetRowStrings(ARow);

   // adjust string within cell width
   val := StringGrid.Cells[ACol, ARow];
   //PATCH//
   //val := ShortenString(StringGrid.Canvas, val, rect.Right - rect.Left - 5);
   //PATCH//

   with StringGrid.Canvas do
      begin
         Brush.Color := clWhite;
         FillRect(rect);

         // draw selection rectangle if required
         if gdSelected in State then
            begin
               Pen.Color := clBlue;
               MoveTo(rect.Left-1, rect.Top);
               LineTo(rect.Right, rect.Top);
               if ACol = StringGrid.ColCount - 1
                  then LineTo(rect.Right, rect.Bottom - 1)
                  else MoveTo(rect.Right, rect.Bottom - 1);
               LineTo(rect.Left - 1, rect.Bottom - 1);
               if ACol = 0 then
                  begin
                     MoveTo(rect.Left, rect.Bottom - 1);
                     LineTo(rect.Left, rect.Top)
                  end
            end;

         // output string in cell
         //TextOut(rect.Left + 4, rect.Top + 6, val)
         WideCanvasTextOut(StringGrid.Canvas, rect.Left + 4, rect.Top + 6, val)
      end
end;

// -- Caching routine

procedure TfrPreviewInfo.GetRowStrings(ARow : integer);
var gt : Tgtree;
    i, n, nOk : integer;
    pn, s, s1, s2 : string;
begin
   // use boolean to detect empty stringgrid (rowcount seems to refuse to be 0)
   // and avoid problems with caching on the extra row when should be empty.
   if StringGridEmpty
      then exit;
      
   if StringGrid.Cells[0, ARow] <> ''
      then exit;

   if ARow + 1 > xgv.cl.nTree
      then exit;

   gt := xgv.cl[ARow + 1];

   StringGrid.Cells[0, ARow] := Format('%5d', [ARow + 1]);

   case ViewMode of
      vmInfo :
         for i := 1 to NthInt(xgv.st.InfoCol, 1, ';') do
            begin
               pn := NthWord(xgv.st.InfoCol, i * 2, ';');
               StringGrid.Cells[i, ARow] := CPToWideString(pv2str(GetProp(gt, pn)))
               //StringGrid.Cells[i, ARow] := CPToWideString(pv2strNoCRLF(GetProp(gt, pn)))
               //StringGrid.Cells[i, ARow] := pv2strNoCRLF(GetProp(gt, pn))
            end;
      vmInfoGm :
         begin
            s := '5;PB;;PW;;PC;;DT;;RE;;';
            for i := 1 to NthInt(s, 1, ';') do
               begin
                  pn := NthWord(s, i * 2, ';');
                  StringGrid.Cells[i, ARow] := pv2strNoCRLF(GetProp(gt, pn))
               end;
            s := GetGmNth(ARow + 1);
            for i := 1 to 7 do
               StringGrid.Cells[5+i, ARow] := Format('%4s', [NthWord(s, i, ' ')])
         end;
      vmInfoPb :
         begin
            s := GetPbNth(ARow + 1);
            s1 := NthWord(s, 1, ' ');
            s2 := NthWord(s, 2, ' ');
            n   := StrToIntDef(s1, 0);
            nOk := StrToIntDef(s2, 0);

            StringGrid.Cells[1, ARow] := Format('%4s', [s1]);
            StringGrid.Cells[2, ARow] := Format('%4s', [s2]);
            if n = 0
               then StringGrid.Cells[3, ARow] := Format('%4s', [''])
               else StringGrid.Cells[3, ARow] := Format('%4s', [IntToStr(nOk * 100 div n)])
         end
   end;
end;

// -- Actions ----------------------------------------------------------------

procedure TfrPreviewInfo.UpdateCurrentGame(newRow : integer);
begin
   StringGrid.Row := newRow;
   GetRowStrings(newRow);
   xgv.si.IndexTree := GameOnRow(newRow);
   xgv.si.FileName  := xgv.cl.FileName[xgv.si.IndexTree];
end;

// -- Control of click position

function TfrPreviewInfo.ClickInGrid : boolean;
var
   where : TPoint;
   coord : TGridCoord;
begin
   where := StringGrid.ScreenToClient(Mouse.CursorPos);
   coord := StringGrid.MouseCoord(where.X, where.Y);

   Result := (coord.X > -1) and (coord.Y > -1);

   // check whether it is not in the first row in an empty grid
   if Result and (coord.Y = 0)
      then Result := StringGrid.Cells[0, 0] <> ''
end;

// -- Click on grid

procedure TfrPreviewInfo.StringGridClick(Sender: TObject);
begin
   if not ClickInGrid
      then exit;

   UpdateCurrentGame(StringGrid.Row);
end;

// -- Double click

procedure TfrPreviewInfo.StringGridDblClick(Sender: TObject);
var i : integer;
begin
   if not ClickInGrid
      then exit;

   i := SelectedGame();

   if i <= xgv.cl.nTree then
      begin
         ChangeEvent(xgv, i, seMain, snHit);
         fmMain.SelectView(vmBoard)
      end
end;

procedure TfrPreviewInfo.StringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   //fmMain.StatusBar.Panels[3].Text := 'foo'
end;

// -- Navigation between games

procedure TfrPreviewInfo.FirstGame();
begin
   UpdateCurrentGame(0)
end;

procedure TfrPreviewInfo.LastGame();
begin
   UpdateCurrentGame(StringGrid.RowCount - 1)
end;

procedure TfrPreviewInfo.PrevGame();
begin
   if StringGrid.Row > 0
      then UpdateCurrentGame(StringGrid.Row - 1)
end;

procedure TfrPreviewInfo.NextGame();
begin
   if StringGrid.Row < NumberToDisplay() - 1
      then UpdateCurrentGame(StringGrid.Row + 1)
end;

procedure TfrPreviewInfo.GotoGame(n : integer);
begin
   UpdateCurrentGame(n - 1)
end;

// -- Game information

procedure TfrPreviewInfo.GameInfo(Sender : TObject);
begin
end;

// -- Utilities --------------------------------------------------------------

function TfrPreviewInfo.NumberToDisplay : integer;
begin
   Result := xgv.cl.nTree
end;

function TfrPreviewInfo.GameOnRow(i : integer) : integer;
begin
   Result := StrToIntDef(Trim(StringGrid.Cells[0, i]), 1)
end;

function TfrPreviewInfo.SelectedGame : integer;
begin
   Result := GameOnRow(StringGrid.Row)
end;

// -- Sort -------------------------------------------------------------------

procedure TfrPreviewInfo.HeaderControlSectionClick(HeaderControl: THeaderControl;
                                                   Section: THeaderSection);
begin
   HeaderControl.Font.Name := 'Tahoma';
   //Section.Text := UTF8ToWideString('Параметры');
   Section.Text := UTF8ToWideString('précédent');

   if (NumberToDisplay > fmMain.st.SortLimit) and fmMain.st.WarnWhenSort then
      begin
         MessageDialog(msOk, imExclam,
                       [Format(T('Sorting is not enabled over %d records.'),
                               [fmMain.st.SortLimit]),
                        T('See Options | Preview to change this setting.')],
                       fmMain.st.WarnWhenSort);
         exit
      end;

   SortIndex(Section.Index)
end;

procedure Reverse(list : TStringList);
var i : integer;
begin
   with list do
      begin
         for i := 0 to Count - 1 do
            if i >= Count - 1 - i
               then exit
               else Exchange(i, Count - 1 - i)
      end
end;

procedure TfrPreviewInfo.SortIndex(Acol : integer);
var list : TStringList;
    i, k : integer;
    s : string;
begin
   list := TStringList.Create;

   for i := 0 to NumberToDisplay - 1 do
      begin
         GetRowStrings(i);
         s := StringGrid.Cells[Acol, i];

         // if s empty, add last ascii char to move empty strings to the end
         if (Trim(s) = '') and (Sorted[Acol] <= 0)
            then s := #255;

         list.Add(s + '@' + StringGrid.Rows[i].Text)
      end;

   list.Sort;

   for i := 0 to maxCol - 1 do
      if i <> Acol then Sorted[i] := 0;

   if Sorted[Acol] <= 0
      then Sorted[Acol] := 1
      else
         begin
            Sorted[Acol] := -1;
            Reverse(list)
         end;

   for i := 0 to NumberToDisplay - 1 do
      begin
         k := Pos('@', list[i]);
         s := Copy(list[i], k + 1, 10000);
         StringGrid.Rows[i].Text := s
      end;

   list.Free;

   //ActiveControl := StringGrid TOFIX
end;

// --- Misc events -----------------------------------------------------------

procedure TfrPreviewInfo.HeaderControlSectionResize(HeaderControl: THeaderControl;
                                                    Section: THeaderSection);
begin
   StringGrid.ColWidths[Section.Index] := Section.Right - Section.Left - 1;
   StoreGridDesc()
end;

// ---------------------------------------------------------------------------

begin
   // Avoid exception class EClassNotFound with message 'Class TStringGrid not found'
   // when changing StringGrid : TStringGrid to TTntStringGrid
   RegisterClass(TStringGrid)
end.
