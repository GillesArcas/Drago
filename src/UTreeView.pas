// ---------------------------------------------------------------------------
// -- Drago -- Display of game tree ------------------------- UTreeView.pas --
// ---------------------------------------------------------------------------

unit UTreeView;

// ---------------------------------------------------------------------------

interface

uses
  Forms, StdCtrls, Types, ComCtrls, ExtCtrls,
  SysUtils, Dialogs, Classes, Controls, Messages, Windows, StrUtils,
  Graphics, Jpeg, Contnrs,
  UViewBoard, UGameTree, Ustatus;

(* experimental

type
  TTreeViewNode = class
    FNumber : integer; // move number
    FI : integer;      // vertical index of node in tree view matrix
    FJ : integer;      // horizontal index
  end;

  TTreeViewNodes = class(TBucketList)
    procedure Add(gt : TGameTree); overload;
    function GetNumber(gt : TGameTree) : integer;
    procedure SetNumber(gt : TGameTree; number : integer);
  end;

  TTreeViewData = class
    FTreeViewNodes : TTreeViewNodes;
  end;

//

procedure TTreeViewNodes.Add(gt : TGameTree);
begin
  Add(gt, TTreeViewNode.Create)
end;

function TTreeViewNodes.GetNumber(gt : TGameTree) : integer;
begin
  Result := TTreeViewNode(Data[gt]).FNumber
end;

procedure TTreeViewNodes.SetNumber(gt : TGameTree; number : integer);
begin
  TTreeViewNode(Data[gt]).FNumber := number
end;

  *)

procedure InitTreeViewModule;
procedure LoadTreeView (view : TViewBoard; x : TGameTree;
                        i0, j0 : integer;
                        reset  : boolean = False);
procedure TV_Refresh   (view : TViewBoard);
procedure TV_Update    (view : TViewBoard; i, j : integer);
procedure TV_UpdateWin (view : TViewBoard; i, j : integer);
procedure TV_UpdateMove(view : TViewBoard; gt : TGameTree; marker : boolean);
procedure TV_UpdatePointerXY(view : TViewBoard; x, y : integer);
procedure TV_UpdateView(view : TViewBoard);
procedure TV_LinkMoves (view : TViewBoard; origin : TGameTree);
procedure TV_LinkVars  (view : TViewBoard; origin : TGameTree);
procedure TV_DelMove   (view : TViewBoard);

procedure UpdateTreeView(view : TViewBoard; x : TGameTree; i0, j0 : integer;
                         draw : boolean = False);
procedure GetTreeDim    (gt : TGameTree; var height, width : integer);

procedure TV_CreateStones(st : TStatus);

// ---------------------------------------------------------------------------

implementation

uses
  Std, Ux2y, Properties, VclUtils, Main, Ugraphic, UGCom, UInstStatus, 
  Define, DefineUi, BoardUtils, UStones, UGoban;

const
  MARKGT = TGameTree($ffffffff);

// ---------------------------------------------------------------------------

procedure DrawBackGround(image : TImage;
                         panel : TPanel; gb : TGoban;
                         draw : boolean); forward;
procedure DrawBorderNumber(imTree : TImage; gt : TGameTree;
                           si : TInstStatus; TVi0, TVi1 : integer); forward;
procedure DrawNode(canvas : TCanvas; gt : TGameTree; x, y : integer;
                   colorTrans : TColorTrans; mrk : integer); forward;
procedure DrawElem(view : TViewBoard; canvas : TCanvas; i, j : integer); forward;

// ---------------------------------------------------------------------------

var
  // common to all instances
  StoneBlack, StoneWhite : TStone;
  bmBack    : TBitmap;
  TextFont2 : integer;
  TextFont3 : integer;

// -- Game tree display coordinate encoding ----------------------------------
//
// The (i,j) position of a game node in the game tree display is encoded in
// the Tag field of the node. Here are the encoding/decoding functions.

function TagEncode(i, j : integer) : integer;
begin
  Result := j shl 15 + i
end;

procedure TagDecode(tag : integer; out i, j : integer);
begin
  i := tag and $7fff;
  j := tag shr 15
end;

// -- Initialisation of module -----------------------------------------------

procedure InitTreeViewModule;
begin
  bmBack := TBitmap.Create;
  TV_CreateStones(Settings)
end;

// -- Dimensions of game tree without horizontal optimization ----------------

procedure GetTreeDimensions(gt : TGameTree; var height, width : integer);
var
  x : TGameTree;
  h, w, hh, ww : integer;
begin
  if gt = nil then
    begin
      height := 0;
      width  := 0;
      exit
    end;

  if gt.NextNode = nil then
    begin
      height := 1;
      width  := 1;
      exit
    end;

  h := 0;
  w := 0;
  x := gt.NextNode;
  while x <> nil do
    begin
      GetTreeDimensions(x, hh, ww);
      h := Max(h, hh);
      w := w + ww;
      x := x.NextVar
    end;
  height := h + 1;
  width  := w
end;

procedure GetTreeDim1(gt : TGameTree; var height, width : integer);
var
  s : string;
  x : TGameTree;
  h, w, hh, ww : integer;
  noMove : boolean;
begin
  if gt = nil then
    begin
      height := 0;
      width  := 0;
      exit
    end;

  noMove := not gt.HasMove;

  if gt.PrevNode = nil
    then
      if noMove
        then gt.Number := 0
        else gt.Number := 1
    else
      if noMove
        then gt.Number := gt.PrevNode.Number
        else gt.Number := gt.PrevNode.Number + 1;

  s := gt.GetProp(prMN);
  if s <> ''
    then
      if noMove
        then gt.Number := pv2int(s) - 1
        else gt.Number := pv2int(s);

  if gt.NextNode = nil then
    begin
      height := 1;
      width  := 1;
      exit
    end;

  h := 0;
  w := 0;
  x := gt.NextNode;
  while x <> nil do
    begin
      GetTreeDim1(x, hh, ww);
      h := Max(h, hh);
      w := w + ww;
      x := x.NextVar
    end;
  height := h + 1;
  width  := w
end;

procedure GetTreeDim(gt : TGameTree; var height, width : integer);
begin
  gt := gt.Root;
  GetTreeDim1(gt, height, width)
end;

// -- Filling up of tree matrix with horizontal optimization -----------------

procedure FindFreeColumn(gt : TGameTree; var m : TTreeMat; i0 : integer;
                         var j : integer);
var
  i : integer;
begin
  i := i0;
  while gt <> nil do
    begin
      while m[i, j] <> nil do
        begin
          m[i0, j] := MARKGT;
          inc(j)
        end;
      inc(i);
      gt := gt.NextNode
    end
end;

procedure LoadTreeMatIJ(gt : TGameTree;
                        var m : TTreeMat;
                        var width : integer;
                        i, j : integer);
begin
  m[i, j] := gt;
  gt.Tag := TagEncode(i, j);
  if j + 1 > width
    then width := j + 1;

  if gt.NextNode <> nil
    then LoadTreeMatIJ(gt.NextNode, m, width, i + 1, j);

  if gt.NextVar = nil
    then exit;

  gt := gt.NextVar;
  inc(j);
  FindFreeColumn(gt, m, i, j);
  LoadTreeMatIJ(gt, m, width, i, j)
end;

procedure LoadTreeMat(gt : TGameTree; var m : TTreeMat; var width : integer);
begin
  width := 0;
  LoadTreeMatIJ(gt, m, width, 0, 0)
end;

// -- Display of game tree ---------------------------------------------------

// Note: TreeSurvey enables to store images from a big game tree with some
// horizontal step (experimental).
//
// radius of stone in tree view must be set to 4.
// some values set by hand...

{.$define TreeSurvey}

var
  TheName : string;
  jpg : TJPEGImage;

procedure TreeSurvey(view : TViewBoard; x : TGameTree);
var
  i, j, step : integer;
begin
  jpg := TJPEGImage.Create;

  i := 0;
  j := -48;
  step := 4;

  while j < view.si.TVwidth do
    begin
      TheName := Format('\Gilles\Volatil\tree%4.4d.jpg', [12 + j div step]);
      UpdateTreeView(view, x, i, j, True);
      jpg.Assign(view.frViewBoard.imTree.Picture.Bitmap);
      jpg.SaveToFile(TheName);
      inc(j, step)
    end;
end;

procedure LoadTreeView(view : TViewBoard;
                       x : TGameTree;
                       i0, j0 : integer;
                       reset  : boolean = False);
var
  j : integer;
begin
  if reset then
    begin
      with view do
        begin
          si.TVi0 := 0; si.TVi1 := 0; si.nStoneH := 0;
          si.TVj0 := 0; si.TVj1 := 0; si.nStoneW := 0;
        end;
      with view.frViewBoard do
        begin
          sbTreeV.OnChange := nil;
          sbTreeH.OnChange := nil;
          pnTree.OnResize  := nil;
          sbTreeV.Position := 0;
          sbTreeH.Position := 0;
          //*//pnTree.Height := Panel2.Height - sbTreeH.Height; // cf Notes 13/03/05
          imTree.Height := pnTree.Height;                  // "
          //*//pnTree.Width  := Panel2.Width  - sbTreeV.Width ; // "
          imTree.Width  := pnTree.Width ;                  // "
          sbTreeV.OnChange := sbTreeVChange;
          sbTreeH.OnChange := sbTreeHChange;
          pnTree.OnResize  := pnTreeResize
        end
    end;

  with view.si do
    begin
      GetTreeDim(x.Root, TVheight, TVwidth);
      SetLength(TVmat, 0, 0);
      SetLength(TVmat, TVheight, TVwidth);
      LoadTreeMat(x.Root, TVmat, TVwidth);
      SetLength(TVmat, TVheight, TVwidth)
    end;

  UpdateTreeView(view, x, i0, j0, True);

  {$ifdef TreeSurvey}
  TreeSurvey(view, x)
  {$endif}
end;

// -- Update of game tree ----------------------------------------------------

procedure SetVisibleMat(view : TViewBoard);
begin
  with view do
    begin
      // set number of stones in width
      si.nStoneW := (frViewBoard.imTree.Width - si.TVoffsetH) div Status.TvInterH;
      if (frViewBoard.imTree.Width - si.TVoffsetH - si.nStoneW * Status.TvInterH) > (Settings.TvRadius + 2)
        then inc(si.nStoneW);

      // set number of stones in height
      si.nStoneH := (frViewBoard.imTree.Height - si.TVoffsetV) div Status.TvInterV;
      if (frViewBoard.imTree.Height - si.TVoffsetV - si.nStoneH * Status.TvInterV) > (Settings.TvRadius + 2)
        then inc(si.nStoneH);

      with frViewBoard do
        begin
          // set vertical scrollbar
          sbTreeV.Visible := si.TVheight >= si.nStoneH;
          if sbTreeV.Visible
            then sbTreeV.Max := si.TVheight - si.nStoneH
            else sbTreeV.Max := 0;
          if sbTreeV.Max = 0
            then sbTreeV.Visible := False;

          // set horizontal scrollbar
          sbTreeH.Visible := si.TVwidth >= si.nStoneW;
          if sbTreeH.Visible
            then sbTreeH.Max := si.TVwidth - si.nStoneW
            else sbTreeH.Max := 0;
          if sbTreeH.Max = 0
            then sbTreeH.Visible := False
        end
    end
end;

procedure UpdateTreeView(view : TViewBoard; x : TGameTree; i0, j0 : integer;
                         draw : boolean = False);
var
  i, j : integer;
begin
  with view do
    begin
      si.TextFontB := Min((Status.TvInterV * 8) div 10, 10);
      si.TVoffsetH := Status.TvInterH div 2 + 2;
      si.TVoffsetV := Status.TvInterV div 2 + 2;

      if Settings.TvMoveNumber = tmBorder then
        with frViewBoard.imTree.Canvas do
          begin
            Font.Size  := si.TextFontB;
            Font.Style := [fsBold];
            si.TVoffsetH := TextWidth('999') + 2 * 5 + Settings.TvRadius
          end
    end;

  with view, si do
    begin
      {$ifdef TreeSurvey}
      pnTree.ClientWidth  := 640;
      pnTree.ClientHeight := 480;
      sbTreeH.Parent := nil;
      sbTreeV.Parent := nil;
      {$endif}

      SetVisibleMat(view);

      TVi0 := i0;
      TVi1 := TVi0 + nStoneH - 1;
      TVj0 := j0;
      TVj1 := TVj0 + nStoneW - 1;

      {$ifndef TreeSurvey}
      while TVj0 > frViewBoard.SbTreeH.Position do
        begin
          dec(TVj0);
          dec(TVj1)
        end;
      {$endif}

      frViewBoard.imTree.Picture.Bitmap.Width  := frViewBoard.pnTree.ClientWidth;
      frViewBoard.imTree.Picture.Bitmap.Height := frViewBoard.pnTree.ClientHeight;

      DrawBackGround(frViewBoard.imTree, frViewBoard.pnTree, gb, draw);

      if Settings.TvMoveNumber = tmBorder
        then DrawBorderNumber(frViewBoard.imTree, x, si, TVi0, TVi1);

      for i := TVi0 to TVi1 do
        for j := TVj0 to TVj1 do
          if (i < 0) or(j < 0)
            then // ignore (convenient for kogo survey)
            else
              if (i < TVheight) and (j < TVwidth) and (TVmat[i, j] <>  nil)
                then DrawElem(view, frViewBoard.imTree.Canvas, i, j)
  end;
  
  TV_UpdateWin(view, i0, j0); // update scrollbars, then view
  TV_UpdateMove(view, x, True);
end;

// -- Update of display area -------------------------------------------------

procedure TV_UpdateWin(view : TViewBoard; i, j : integer);
begin
  with view, frViewBoard.sbTreeV do
    if i < si.TVi0
      then Position := Position - (si.TVi0 - i)
      else
        if i > si.TVi1
          then Position := Position + (i - si.TVi1);

  with view, frViewBoard.sbTreeH do
    if j < si.TVj0
      then Position := Position - (si.TVj0 - j)
      else
        if j > si.TVj1
          then Position := Position + (j - si.TVj1)
end;

procedure TV_ShowMove(view : TViewBoard; gt : TGameTree);
var
  i, j : integer;
begin
  TagDecode(gt.Tag, i, j);

  if Within(i, view.si.TVi0, view.si.TVi1) and Within(j, view.si.TVj0, view.si.TVj1)
    then TV_UpdateMove(view, gt, True)
    else TV_UpdateWin(view, i, j)
end;

// -- Update of current move -------------------------------------------------

var
  DrawBorderFromJ : integer = -1;

procedure TV_UpdateMove(view : TViewBoard; gt : TGameTree; marker : boolean);
var
  i, j, x, y, a, player, color : integer;
begin
  if gt.Tag = -1
    then exit;

  TagDecode(gt.Tag, i, j);

  with view.si do
    if not Within(i, TVi0, TVi1) or not Within(j, TVj0, TVj1)
      then exit;

  x := view.si.TVoffsetH + (j - view.si.TVj0) * Status.TvInterH; // center
  y := view.si.TVoffsetV + (i - view.si.TVi0) * Status.TvInterV;

  if not marker
    then
      DrawNode(view.frViewBoard.imTree.Canvas, gt, x, y,
               view.gb.ColorTrans,
               iff(Settings.TvMoveNumber = tmStones, 0, 1))
    else
      with view.frViewBoard.imTree.Canvas do
        begin
          if (Settings.TvMoveNumber = tmBorder) and (j <> DrawBorderFromJ)
            then DrawBorderNumber(view.frViewBoard.imTree, gt, view.si,
                                  view.si.TVi0, view.si.TVi1);

          DrawNode(view.frViewBoard.imTree.Canvas, gt, x, y, view.gb.ColorTrans, 2);

          // draw current move markup
          if view.si.TVmat[i, j].HasProp(prB)
            then player := Black
            else player := White;
          player := ColorTransform(player, view.gb.ColorTrans);
          if player = Black
            then color := clWhite
            else color := clBlack;
          pen.color   := color;
          brush.color := color;
          a := Max(3, Settings.TvRadius div 8);
          rectangle(x - a + 1, y - a + 1, x + a, y + a);

          // store last node marked in game tree
          view.si.TvLastMarked := gt
        end
end;

// -- Update of pointer mark -------------------------------------------------

procedure TV_UpdatePointerXY(view : TViewBoard; x, y : integer);
var
  i, j : integer;
begin
  with view.si do
    begin
      i := (y - TVoffsetV + Settings.TvRadius) div Status.TvInterV + TVi0;
      j := (x - TVoffsetH + Settings.TvRadius) div Status.TvInterH + TVj0;

      if not within(i, 0, TVheight - 1) or not within (j, 0, TVwidth - 1) or
          (TVmat[i, j] = nil) or (TVmat[i, j] = MARKGT)
        then exit;

      DoGoToNode(view, TVmat[i, j]);
      TV_UpdateView(view)
    end
end;

// -- Handling of events -----------------------------------------------------

procedure TV_Refresh(view : TViewBoard);
begin
  UpdateTreeView(view, view.gt, view.si.TVi0, view.si.TVj0)
end;

procedure TV_Update(view : TViewBoard; i, j : integer);
begin
  UpdateTreeView(view, view.gt, i, j)
end;

// -- Moves ------------------------------------------------------------------

procedure TV_UpdateView(view : TViewBoard);
var
  i, j : integer;
begin
  with view do
    begin
      if si.ApplyQuiet or (gt = nil)
        then exit;

      TagDecode(gt.Tag, i, j);

      if Within(i, si.TVi0, si.TVi1) and Within(j, si.TVj0, si.TVj1)
        then
          begin
            TV_UpdateMove(view, si.TvLastMarked, False); // starting point
            TV_UpdateMove(view, gt, True)
          end
        else
          begin
            TV_UpdateWin(view, i, j); // update scrollbars, then view
            TV_UpdateMove(view, gt, True)
          end
    end
end;

// -- Insertion of a new move ------------------------------------------------

procedure TV_LinkMoves(view : TViewBoard; origin : TGameTree);
var
  i, j : integer;
begin
  if origin.Tag = -1
    then exit; // something wrong

  TagDecode(origin.Tag, i, j);

  with view.si do
    if i + 1 > (TVheight - 1) then
      begin
        inc(TVheight);
        view.frViewBoard.sbTreeV.Max := TVheight - 1;
        SetLength(TVmat, TVheight, TVwidth)
      end;

  with view do
    if si.TVmat[i + 1, j] <> nil
      then LoadTreeView(view, gt, si.TVi0, si.TVj0)
      else
        begin
          si.TVmat[i + 1, j] := gt;
          gt.Tag := TagEncode(i + 1, j);
          gt.Number := gt.PrevNode.Number + 1; // TODO: protect access
          if i + 1 <= si.TVi1
            //then UTreeView.UpdateTreeView(view, gt, si.TVi0, si.TVj0)
            then UpdateTreeView(view, gt, si.TVi0, si.TVj0)
        end;

  TV_ShowMove(view, view.gt)
end;

// -- Insertion of new variation ---------------------------------------------

procedure TV_LinkVars(view : TViewBoard; origin : TGameTree);
var
  i, j : integer;
begin
  if origin.Tag = -1
    then exit; // something wrong

  TagDecode(origin.Tag, i, j);

  with view.si do
    if j + 1 > (TVwidth - 1) then
      begin
        inc(TVwidth);
        view.frViewBoard.sbTreeH.Max := TVwidth - 1;
        SetLength(TVmat, TVheight, TVwidth)
      end;

  with view, si do
    if TVmat[i, j + 1] <> nil
      then LoadTreeView(view, gt, TVi0, TVj0)
      else
        begin
          TVmat[i, j + 1] := gt;
          gt.tag := TagEncode(i, j + 1);
          gt.Number := gt.PrevNode.Number + 1; // TODO: protect access
          if (i {+ 1} <= TVi1) and (j + 1 <= TVj1)
            //then UTreeView.UpdateTreeView(view, gt, TVi0, TVj0)
            then UpdateTreeView(view, gt, TVi0, TVj0)
        end;

  TV_ShowMove(view, view.gt)
end;

// -- Suppression of a move --------------------------------------------------

procedure TV_DelMove(view : TViewBoard);
begin
  with view do
    begin
      LoadTreeView(view, gt, si.TVi0, si.TVj0);
      TV_ShowMove(view, gt)
    end

  (* attempt to optimize

  LoadTreeView(gb, gt, st, TVi0, TVj0);
  i := gt.Tag and $3ff;
  j := gt.Tag shr 10;
  if i < TVi0
    then fmMain.sbTreeV.Position := fmMain.sbTreeV.Position - 1;
  if j < TVj0
    then fmMain.sbTreeH.Position := fmMain.sbTreeH.Position - 1;
  exit;

  if gt.Tag = -1
    then exit; // something wrong

  i := gt.Tag and $3ff;
  j := gt.Tag shr 10;

  TVmat[i, j] := nil;
  if gt.NextVar = nil
    then UpdateTreeView(gb, gt.PrevNode, st, TVi0, TVj0)
    else LoadTreeView(gb, gt.Root, st, TVi0, TVj0)
  *)
end;

// -- Graphic functions ------------------------------------------------------

// -- Background display

procedure DrawBackGround(image : TImage;
                         panel : TPanel; gb : TGoban;
                         draw  : boolean);
begin
  // apply background on canvas
  Settings.TreeBack.Apply(image.Canvas, ControlRect(image));

  // backup canvas
  bmBack.Width  := panel.ClientWidth;
  bmBack.Height := panel.ClientHeight;
  bmBack.Canvas.CopyRect(Rect(0, 0, bmBack.Width, bmBack.Height),
                         image.Canvas,
                         Rect(0, 0, bmBack.Width, bmBack.Height));
end;

// -- Stone creation

procedure TV_CreateStones;
var
  stoneParams : TStoneParams;
begin
  stoneParams := TStoneParams.Create;
  stoneParams.SetParams(Settings.TvStoneStyle,
                        Settings.LightSource,
                        Settings.TreeBack.MeanColor,
                        Settings.CustomLightSource,
                        Settings.CustomBlackPath,
                        Settings.CustomWhitePath,
                        Settings.AppPath);
  StoneBlack := GetStone(Black, Settings.TvRadius, stoneParams);
  StoneWhite := GetStone(White, Settings.TvRadius, stoneParams);
  stoneParams.Free;

  TextFont2 := AdjustFontSize(fmMain.Canvas,
                              Settings.TvRadius, Settings.MaxBoardFontSize,
                              [fsBold, fsUnderline], '99');
  TextFont3 := AdjustFontSize(fmMain.Canvas,
                              Settings.TvRadius, Settings.MaxBoardFontSize,
                              [fsBold, fsUnderline], '999');
end;

// -- Display of move numbers on border

procedure DrawBorderNumber(imTree : TImage; gt : TGameTree;
                           si : TInstStatus;
                           TVi0, TVi1 : integer);
label
  continue;
var
  i, h, w, x, y, dum : integer;
  s : string;
begin
  if gt = nil // should not be
    then exit;

  with imTree.Canvas do
    begin
      Font.Size  := si.TextFontB;
      Font.Style := [fsBold];
      Font.Color := Settings.TreeBack.PenColor;
      Brush.Style := bsClear;

      h := TextHeight('1');
      w := TextWidth('999');

      CopyRect(Rect(0, 0, 5 + w, imTree.Picture.Bitmap.Height),
               bmBack.Canvas,
               Rect(0, 0, 5 + w, imTree.Picture.Bitmap.Height));
      TagDecode(gt.Tag, dum, DrawBorderFromJ);
      //DrawBorderFromJ := gt.Tag shr 10;

      while gt.NextNode <> nil do
        gt := gt.NextNode;

      while gt <> nil do
        begin
          if gt.Tag = -1
            then exit; // something wrong

          TagDecode(gt.Tag, i, dum);
          //i := gt.Tag and $3ff;

          if (i < TVi0) or (i > TVi1)
            then goto continue;

          if (gt = nil) or (gt = MARKGT)
            then goto continue;

          if not gt.HasMove
            then goto continue;

          s := IntToStr(gt.Number);
          x := 5 + (w - TextWidth(s)) div 2;
          y := si.TVoffsetV + (i - TVi0) * Status.TvInterV - h div 2;

          TextOut(x, y, s);
          continue:
          gt := gt.PrevNode
        end
    end
end;

// -- Display of stones

function HasMoreInfo(gt : TGameTree) : boolean;
var
  nProp, i : integer;
begin
  nProp := gt.PropNumber;

  if nProp = 0
    then Result := False
    else
      if nProp > 3
        then Result := True
        else
          for i := 1 to nProp do
            begin
              Result := not(gt.NthPropId(i) in [prB, prW, prBL, prWL, prOB, prOW]);
              if Result = True
                then exit
            end
end;

procedure DrawStone(canvas : TCanvas;
                    gt : TGameTree;
                    x, y, player : integer;
                    colorTrans : TColorTrans;
                    mrk : integer); // 0: number, 1: '...', 2: current
var
  stone : TStone;
  color : integer;
  s : string;
begin
  // apply color transform
  player := ColorTransform(player, colorTrans);

  if player = Black
    then stone := StoneBlack
    else stone := StoneWhite;
  if player = Black
    then color := clWhite
    else color := clBlack;

  {$ifdef TreeSurvey}
  mrk := -1;
  {$endif}

  with canvas do
    begin
      //Draw(x - Settings.TvRadius, y - Settings.TvRadius, bm);
      stone.Draw(canvas, x, y);

      if ((mrk = 0) and (gt.Number < 100)) or (mrk <> 0)
        then Font.Size := TextFont2
        else Font.Size := TextFont3;

      Brush.Style := bsClear;
      Font.Color  := color;
      Font.Name   := 'Arial';

      case mrk of
        0 : begin
              if HasMoreInfo(gt)
                then Font.Style := [fsBold, fsUnderline]
                else Font.Style := [fsBold];

              s := IntToStr(gt.Number);
              TextOut(x - TextWidth (s) div 2,
                      y - TextHeight(s) div 2, s)
            end;
        1 : begin
              if not HasMoreInfo(gt)
                then exit;
              Font.Style := [fsBold];
              s := '...';
              TextOut(x - TextWidth(s) div 2,
                      y - 3 * TextHeight(s) div 4, s)
            end;
        2 : ;
      end
    end
end;

// -- Display of a node (with or without stone)

procedure DrawNode(canvas : TCanvas;
                   gt : TGameTree;
                   x, y : integer;
                   colorTrans : TColorTrans;
                   mrk : integer);
begin
  with canvas do
    CopyRect(Rect(x - Settings.TvRadius, y - Settings.TvRadius,
                  x + Settings.TvRadius, y + Settings.TvRadius),
             bmBack.Canvas,
             Rect(x - Settings.TvRadius, y - Settings.TvRadius,
                  x + Settings.TvRadius, y + Settings.TvRadius));

  if gt.HasProp(prB)
    then DrawStone(canvas, gt, x, y, Black, colorTrans, mrk)
    else
      if gt.HasProp(prW)
        then DrawStone(canvas, gt, x, y, White, colorTrans, mrk)
        // todo 0 : should draw ellipsis if some prop
        else AntiAliasedStone(canvas, x, y, 0, Settings.TvRadius-1, clSilver)
end;

// -- Display of item (node + link)

procedure DrawElem(view : TViewBoard; canvas : TCanvas; i, j : integer);
var
  gt : TGameTree;
  si : TInstStatus;
  x, y, x1, x2 : integer;
begin
  si := view.si;
  gt := si.TVmat[i, j];

  with canvas do
    begin
      Pen.Color := clBlack;
      //Pen.Style := psDot;

      x := si.TVoffsetH + (j - si.TVj0) * Status.TvInterH; // center
      y := si.TVoffsetV + (i - si.TVi0) * Status.TvInterV;

      if gt = MARKGT then
        begin
          PolyLine([Point(x - Status.TvInterH div 2    , y - Status.TvInterV div 2),
                    Point(x + Status.TvInterH div 2 + 1, y - Status.TvInterV div 2)]);
          exit
        end;

      DrawNode(canvas, gt, x, y, view.gb.ColorTrans, iff(Settings.TvMoveNumber = tmStones, 0, 1));

      Pen.Color := clBlack;
      if gt.PrevNode <> nil
        then PolyLine([Point(x, y - Settings.TvRadius),
                       Point(x, y - Status.TvInterV div 2 - 1)]);
      if gt.NextNode <> nil
        then PolyLine([Point(x, y + Settings.TvRadius),
                       Point(x, y + Status.TvInterV div 2 + 1)]);

      x1 := x - iff(gt.prevVar = nil, 0, Status.TvInterH div 2);
      x2 := x + iff(gt.nextVar = nil, 0, Status.TvInterH div 2 + 1);
      if x1 < x2
        then PolyLine([Point(x1, y - Status.TvInterV div 2),
                       Point(x2, y - Status.TvInterV div 2)])
    end
end;

// ---------------------------------------------------------------------------

initialization
finalization
  bmBack.Free
end.

// ---------------------------------------------------------------------------

const
  dp : array[3 .. 30] of integer =
                    (1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3);
const
  ep : array[3 .. 30] of integer =
                    (0,0,0,1,1,2,2,1,2,2,3,3,3,2,3,3,3,4,4,4,4,4,4,4,4,4,4,4);

procedure DrawCont(x, y, r, color : integer);
var
  d : integer;
  rect : TRect;
begin
  (*
  d := dp[r];
  rect.Left   := x - d div 2;
  rect.Top    := y - d div 2;
  rect.Right  := x + (d + 1) div 2 + 0;
  rect.Bottom := y + (d + 1) div 2 + 0;
  *)
  with fmMain.imTree.Canvas do
    begin
      Brush.Color := color;
      Pen.Color   := color;
      MoveTo(x - r div 2, y);
      LineTo(x + r div 2, y);
      MoveTo(x, y - r div 2);
      LineTo(x, y + r div 2);
      (*
      Rectangle(rect);
      dec(rect.Left , ep[r] + d);
      dec(rect.Right, ep[r] + d);
      Rectangle(rect);
      inc(rect.Left , 2 * (ep[r] + d));
      inc(rect.Right, 2 * (ep[r] + d));
      Rectangle(rect)
      *)
    end
end;

// ---------------------------------------------------------------------------


