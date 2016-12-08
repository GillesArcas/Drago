// ---------------------------------------------------------------------------
// -- Drago -- Helpers for command interpretation -------------- UGMisc.pas --
// ---------------------------------------------------------------------------

unit UGmisc;

// ---------------------------------------------------------------------------

interface

uses
  Types, Classes, SysUtils, StrUtils, IniFiles,
  DefineUi, Properties, UGoban, UGameTree, UGameColl, UInstStatus,
  UView,
  CodePages;

function  CPEncode(const s : WideString; cp : TCodePage) : string;
function  CPDecode(const s : string; cp : TCodePage) : WideString;
function  MainEncode(const s : WideString) : string;
function  MainDecode(const s : string) : WideString;
function  DecodeProperty(pr : TPropId; gt : TGameTree; si : TInstStatus) : WideString;
function  DefaultCodePage : TCodePage;
function  SelectNextMovePropDyn(gt : TGameTree) : TGameTree;

function  NthLetterMark(firstChar : char; n : integer) : string;
function  VarMarkup(si : TInstStatus) : TVarMarkup;
procedure VarClear(gb : TGoban; si : TInstStatus);
procedure DisplayVarMarkup(gb : TGoban;
                           si : TInstStatus;
                           mode, n, player, i, j : integer);

function  CoordString(i, j, taille : integer; stdCoord : boolean) : string;
function  NewStartingPosition(defaultHandicap : boolean = True) : TGameTree;
function  ExtractPosition(view : TView;
                          i1 : integer = 0;
                          j1 : integer = 0;
                          i2 : integer = 20;
                          j2 : integer = 20) : TGameTree;
procedure ExtractStoneSetting(var sB, sW : string;
                              view : TView;
                              i1 : integer = 0;
                              j1 : integer = 0;
                              i2 : integer = 20;
                              j2 : integer = 20); overload;
procedure ExtractStoneSetting(var sB, sW : string;
                              gt  : TGameTree;
                              i1 : integer = 0;
                              j1 : integer = 0;
                              i2 : integer = 20;
                              j2 : integer = 20); overload;
function  PrintGameToFile(x : TGameTree) : string;
function  ExtractGameToFile(x : TGameTree) : string;
procedure DetectBounds(x : TGameTree; out size, imin, imax, jmin, jmax : integer); overload;
procedure DetectBounds(x : TGameTree; out size : integer; out Rect: TRect); overload;
procedure DetectQuadrant(gt : TGameTree; out rView : TRect); overload;
procedure DetectSymmetry(gb : TGoban; var sym : array of boolean);
function  ResultToString(s : string) : WideString;
procedure FindFormatProperty(const format : string; var i : integer; gt : TGameTree;
                             out pn, xn, pv : string);
function  HasFormatProperty(const format : string; gt : TGameTree) : boolean;
function  VarString(n, player, i, j : integer;
                    gb : TGoban;
                    gt : TGameTree;
                    si : TInstStatus) : string; //!//WideString;
function  SpanCollection(cl : TGameColl) : longint;
function  TraverseCollectionAndProperties(cl : TGameColl) : integer;
function  TestGameTreeApi(nbEditOps : integer) : integer;

// ---------------------------------------------------------------------------

implementation

uses
  Define, Std,
  Translate, Ux2y,
  Sgfio, UStatus, Crc32,
  BoardUtils, GameUtils, UGameTreeTests, UContext;

// == Variation display handling =============================================

function VarMarkup(si : TInstStatus) : TVarMarkup;
begin
  if not si.ShowVar
    then Result := vmNone
    else
      //if VarMarkupDef = vmAbsNone
      //  then Result := vmNone
      //  else
          if Status.VarMarkupGame = vmUndef
            then Result := Status.VarMarkupDef
            else Result := Status.VarMarkupGame
end;

// -- Selection of character to display according to style, mark and number

// 1-based
function NthLetterMark(firstChar : char; n : integer) : string;
begin
  if n <= 26
    then Result := Chr(Ord(firstChar) + n - 1)
    else Result := Chr(Ord(firstChar) + (n - 27) div 26) +
                   Chr(Ord(firstChar) + (n - 27) mod 26)
end;

function NthVarChar(si : TInstStatus; n : integer) : string;
begin
  if Settings.VarStyle = vsChildren
    then
      if VarMarkup(si) = vmDnCase
        then Result := NthLetterMark('a', n)
        else Result := NthLetterMark('A', n)
    else
      if n = 1
        then Result := '@'
        else
          if VarMarkup(si) = vmDnCase
            then Result := NthLetterMark('a', n - 1)
            else Result := NthLetterMark('A', n - 1)
end;

// -- Formatting for the variation list panel

function VarString(n, player, i, j : integer;
                   gb : TGoban;
                   gt : TGameTree;
                   si : TInstStatus) : string;
var
  at, name : string;
begin
  if n = 0 then
    begin
      Result := '';
      exit
    end;

  if player = Empty
    then at := '-'
    else
      if not gb.IsBoardCoord(i, j)
        then at := T('Pass2')
        else
          case VarMarkup(si) of
            vmDnCase,
            vmUpCase : at := NthVarChar(si, n);
            vmNone,
            vmGhost  : at := CoordString(i, j, Settings.BoardSize,
                                         Settings.CoordStyle <> tcSGF);
          end;

  // extract nodename and convert it to UTF8
  name := pv2str(gt.GetProp(prN));
  name := UTF8Encode(CPDecode(name, si.GameEncoding));

  Result := Format('%-2d %-5s %s', [n, at, name])
end;

// -- Display of the variation mark on board

procedure DisplayVarMarkup(gb : TGoban;
                           si : TInstStatus;
                           mode, n, player, i, j : integer);
begin
  if VarMarkup(si) in [vmGhost, vmUpCase, vmDnCase] then
    if (player <> Empty) and gb.IsBoardCoord(i, j) then
      if (mode = Enter) or (mode = Redo)
        then
          begin
            if VarMarkup(si) = vmGhost
              then gb.ShowTempMark(i, j, mrkPHv[player])
              else
                if gb.BoardMarks[i, j].FMark = mrkNo
                  then gb.ShowTempMark(i, j, mrkTxt, NthVarChar(si, n))
                  else // nop, do not override an existing markup
          end
end;

// -- Clear variations on board only

procedure VarClear(gb : TGoban; si : TInstStatus);
begin
  gb.HideTempMarks
end;

// -- Variation strings for Fuseki mode --------------------------------------

//#:1103  B:507  W:443  ?:153  (53.4%)

function ExtractFusekiDataField(const s, field : string) : string;
var
  lg, p1, p2 : integer;
begin
  Result := '';

  p1 := PosEx(field, s);
  if p1 = 0
    then exit;

  lg := Length(field);
  p2 := PosEx(' ', s, p1 + lg);
  if p2 = 0
    then p2 := Length(s) + 1;

  Result := Copy(s, p1 + lg, p2 - p1 - lg)
end;

procedure ExtractFusekiData(const s : string;
                            out nPlayed, nBlackWin, nWhiteWin : integer);
var
  sPlayed, sBlackWin, sWhiteWin : string;
begin
  sPlayed   := ExtractFusekiDataField(s, '#:');
  sBlackWin := ExtractFusekiDataField(s, 'B:');
  sWhiteWin := ExtractFusekiDataField(s, 'W:');

  nPlayed   := StrToIntDef(sPlayed  , -1);
  nBlackWin := StrToIntDef(sBlackWin, -1);
  nWhiteWin := StrToIntDef(sWhiteWin, -1)
end;

// == Miscellaneous ==========================================================

// -- Code page --------------------------------------------------------------

function CPEncode(const s : WideString; cp : TCodePage) : string;
begin
  case cp of
    cpDefault :
      if IsMultiByte(CurrentCodePage)
        then Result := wstomb(s, CurrentCodePage)
        else Result := s;
    utf8 : Result := UTF8Encode(s)
  else
    Result := wstomb(s, cp)
  end
end;

function CPDecode(const s : string; cp : TCodePage) : WideString;
begin
  case cp of
    cpDefault :
      if IsMultiByte(CurrentCodePage)
        then Result := mbtows(s, CurrentCodePage)
        else Result := s;
    utf8 : Result := UTF8Decode(s)
  else
    Result := mbtows(s, cp)
  end;

  // return something when conversion failure
  if (Result = '') and (s <> '')
    then Result := s
end;

// --

function MainEncode(const s : WideString) : string;
begin
  Result := CPEncode(s, Settings.DefaultEncoding)
end;

function MainDecode(const s : string) : WideString;
begin
  Result := CPDecode(s, Settings.DefaultEncoding)
end;

// --

function DecodeProperty(pr : TPropId; gt : TGameTree; si : TInstStatus) : WideString;
var
  s : string;
begin
  s := pv2txt(gt.GetProp(pr));
  Result := CPDecode(s, si.GameEncoding)
end;

// -- Default code page for reading sgf, result may be cpUnknown

function DefaultCodePage : TCodePage;
begin
  if Settings.DefaultEncoding = cpDefault
    then Result := CurrentCodePage
    else Result := Settings.DefaultEncoding
end;

// -- Coordinate conversion --------------------------------------------------
//
// stdCoord : true: Korsheld, false: sgf

function CoordString(i, j, taille : integer; stdCoord : boolean) : string;
begin
  if stdCoord
    then Result := absKorsh[j] + IntToStr(taille + 1 - i)
    else Result := coordSgf[j] + coordSgf[i]
end;

// -- Creation of starting position ------------------------------------------

function NewStartingPosition(defaultHandicap : boolean = True) : TGameTree;
begin
  Result := TGameTree.Create;

  if Settings.DefaultProp
    then
      begin
        Result.AddProp(prGM, int2pv(1));
        Result.AddProp(prFF, int2pv(4));
        Result.AddProp(prAP, str2pv(AppName + ':' + AppVersion));
        Result.AddProp(prSZ, int2pv(Settings.BoardSize))
      end
    else
      if Settings.BoardSize <> 19
        then Result.AddProp(prSZ, int2pv(Settings.BoardSize));

  if Settings.CreateEncoding = utf8
    then Result.AddProp(prCA, str2pv(CPIdToName(utf8)))
    else Result.AddProp(prCA, str2pv(CPIdToName(CurrentCodePage)));

  if (Settings.Handicap > 0) and defaultHandicap then
    begin
      Result.PutProp(prHA, int2pv(Settings.Handicap));
      if Settings.Handicap > 1
        then Result.PutProp(prAB,
                      HandicapStones(Settings.BoardSize, Settings.Handicap))
    end
end;

// -- Extraction of a position -----------------------------------------------

procedure ExtractStoneSetting(var sB, sW : string;
                              view : TView;
                              i1 : integer = 0;
                              j1 : integer = 0;
                              i2 : integer = 20;
                              j2 : integer = 20);
var
  i, j : integer;
begin
  if i1 = 0 then
    begin
      i1 := 1;
      j1 := 1;
      i2 := view.gb.BoardSize;
      j2 := view.gb.BoardSize
    end;

  sB := '';
  sW := '';

  for i := i1 to i2 do
    for j := j1 to j2 do
      case view.gb.Board[i, j] of
        Black : sB := sB + ij2pv(i, j);
        White : sW := sW + ij2pv(i, j)
      end
end;

procedure ExtractStoneSetting(var sB, sW : string;
                              gt : TGameTree;
                              i1 : integer = 0;
                              j1 : integer = 0;
                              i2 : integer = 20;
                              j2 : integer = 20);
var
  view : TView;
begin
  // create and initialize working bare view
  view := TView.Create;
  view.Context := TContext.Create;
  view.gt := gt;
  view.gb := TGoban.Create;
  try
    view.MoveToStart;
    view.MoveToEnd;
    ExtractStoneSetting(sB, sW, view);
  finally
    view.Context.Free;
    view.Free
  end
end;

function ExtractPosition(view : TView;
                         i1 : integer = 0;
                         j1 : integer = 0;
                         i2 : integer = 20;
                         j2 : integer = 20) : TGameTree;
const
  BW = 'BW';
var
  sB, sW : string;
begin
  Result := NewStartingPosition();
  Result.RemProp(prHA);
  Result.RemProp(prAB);
  Result.PutProp(prSZ, int2pv(view.gb.BoardSize));

  ExtractStoneSetting(sB, sW, view, i1, j1, i2, j2);

  if sB <> ''
    then Result.AddProp(prAB, sB);
  if sW <> ''
    then Result.AddProp(prAW, sW);

  Result.AddProp(prPL, str2pv(BW[NextPlayer(view.gt)]))
end;

// -- Printing of game in a temporary file -----------------------------------

function PrintGameToFile(x : TGameTree) : string;
begin
  Result := Status.TmpPath + '\tmp.sgf';
  PrintWholeTree(Result, x, False, False)
end;

function ExtractGameToFile(x : TGameTree) : string;
const
  pr : array[1 .. {4}1] of TPropId = (prHA{, prKM ,prAB, prAW});
var
  gt : TGameTree;
  pv : string;
  i : integer;
begin
  gt := x.MovesToNode;
  x := x.Root;

  for i := Low(pr) to High(pr) do
    begin
      pv := x.GetProp(pr[i]);
      if pv <> ''
        then gt.AddProp(pr[i], pv)
    end;

  Result := Status.TmpPath + '\tmp.sgf';
  PrintWholeTree(Result, gt, False, False);
  gt.FreeGameTree
end;

// -- Search for the enclosing rectangle of the current position -------------

procedure SetExtrema(i, j : integer; var imin, jmin, imax, jmax : integer);
begin
  if i < imin then imin := i;
  if i > imax then imax := i;
  if j < jmin then jmin := j;
  if j > jmax then jmax := j
end;

procedure DetectBoundsInner(gt : TGameTree; var imin, jmin, imax, jmax : integer);
var
  n, i, j, k : integer;
  pr : TPropId;
  pv, x : string;
begin
  if gt <> nil then
    begin
      for n := 1 to gt.PropNumber do
        begin
          gt.NthProp(n, pr, pv);

          if (pr = prB) or (pr = prW) then
            begin
              pv2ij(pv, i, j);
              if Within(i, 1, 19) // test pass
                then SetExtrema(i, j, imin, jmin, imax, jmax)
            end;

          if (pr = prAB) or (pr = prAW) then
            begin
              k := 1;
              x := nthpv(pv, k);

              while x <> '' do
                begin
                  pv2ij(x, i, j);
                  SetExtrema(i, j, imin, jmin, imax, jmax);
                  inc(k);
                  x := nthpv(pv, k)
                end
            end
        end;

      if (imax - imin + 1 > 15) or (jmax - jmin + 1 > 15)
        then exit;

      DetectBoundsInner(gt.NextNode, imin, jmin, imax, jmax);
      DetectBoundsInner(gt.NextVar, imin, jmin, imax, jmax)
    end
end;

procedure DetectBounds(x : TGameTree; out size, imin, imax, jmin, jmax : integer);
begin
  x    := x.Root;
  size := BoardSizeOfGameTree(x);
  imin := size;
  imax := 1;
  jmin := size;
  jmax := 1;

  if size = 19
    then DetectBoundsInner(x, imin, jmin, imax, jmax)
end;

procedure DetectBounds(x : TGameTree; out size : integer; out rect: TRect);
var
  imin, imax, jmin, jmax : integer;
begin
  DetectBounds(x, size, imin, imax, jmin, jmax);
  rect.Top    := iMin;
  rect.Bottom := iMax;
  rect.Left   := jMin;
  rect.Right  := jMax
end;

function IntersectArea(const r1, r2 : TRect) : integer;
var
  r : TRect;
begin
  if not IntersectRect(r, r1, r2)
    then Result := 0
    else Result := (r.Right - r.Left + 1) * (r.Bottom - r.Top + 1)
end;

procedure RotPoint(var p : TPoint; dim : integer; n : integer = 1);
var
  i, tmp : integer;
begin
  for i := 1 to n do
    begin
      tmp := p.y;
      p.y := dim + 1 - p.x;
      p.x := tmp
    end
end;

procedure RotRect(var r : TRect; dim : integer; n : integer = 1);
var
  i, tmp : integer;
begin
  for i := 1 to n do
    begin
      RotPoint(r.TopLeft    , dim);
      RotPoint(r.BottomRight, dim);
      tmp := r.Top; r.Top := r.Bottom; r.Bottom := tmp
    end
end;

procedure DetectQuadrant(gt : TGameTree; out rView : TRect);
var
  size, s0, s1, s2, s3, s, q, mx : integer;
  rGame : TRect;
begin
  DetectBounds(gt, size, rGame);

  if (size <> 19)               or // only for boardsize 19
    (rGame.Left > rGame.Right)     // only if not empty
    then
      begin
        rView := Rect(1, 1, size, size);
        exit
      end;

  s0 := IntersectArea(rGame, Rect( 1,  1, 10, 10)); // 0 | 1
  s1 := IntersectArea(rGame, Rect(10,  1, 19, 10)); // - - -
  s2 := IntersectArea(rGame, Rect(10, 10, 19, 19)); // 3 | 2
  s3 := IntersectArea(rGame, Rect( 1, 10, 10, 19));
  q := 0;
  s := s0;
  if s1 > s then
    begin q := 1; s := s1 end;
  if s2 > s then
    begin q := 2; s := s2 end;
  if s3 > s then
    begin q := 3; s := s3 end;

  RotRect(rGame, 19, q);

  mx := Max(rGame.Right, rGame.Bottom);

  if mx < 10
    then rView := Rect(1, 1, 10, 10)
    else
      if mx < 16
        then rView := Rect(1, 1, mx + 1, mx + 1)
        else rView := Rect(1, 1, size, size);

  RotRect(rView, 19, 4 - q)
end;

// -- Detection of the symmetries in the current position

// TODO: check
// -- sym must be set to 8 before call

procedure DetectSymmetry(gb : TGoban; var sym : array of boolean);
var
  i, j, i2, j2, x : integer;
  t : TCoordTrans;
begin
  sym[0] := True; // trIdent;

  for t := trRot90 to trSymD270 do
    begin
      sym[ord(t)] := True;
      i := 1;
      while i <= gb.BoardSize do
        begin
          j := 1;
          while j <= gb.BoardSize do
            begin
              x := gb.Board[i, j];
              if x in [Black, White] then
                begin
                  Transform(i, j, gb.BoardSize, t, i2, j2);
                  if gb.Board[i2, j2] <> x then
                    begin
                      sym[ord(t)] := False;
                      i := gb.BoardSize + 1;
                      j := gb.BoardSize + 1
                    end
                end;
              inc(j)
            end;
          inc(i)
        end
    end
end;

// -- Parsing of game information format string ------------------------------
//
// format used by printing or displaying game information; e.g. '\PB vs \PW'

// -- Find property and fetch data in game tree

// find the first property inside format starting from index i included
// when not found, return index i = 0
// when found, update index and return property name, text and value from game tree
// return all string as UTF-8

procedure FindFormatProperty(const format : string;
                             var i : integer;
                             gt : TGameTree;
                             out pn, xn, pv : string);
var
  pr : TPropId;
begin
  repeat
    i := PosEx('\', format, i);
    if i = 0
      then exit;

    inc(i);
    pn := Copy(format, i, 2);
    pr := PropertyIndex(pn)
  until pr <> prNone;

  inc(i, 2);
  xn := FindPropText(pn);
  pv := pv2str(gt.GetProp(pr));
  if pr = prRE
    then pv := ResultToString(pv)
    else pv := MainDecode(pv);

  xn := UTF8Encode(U(xn));
  pv := UTF8Encode(pv)
end;

// -- Test format property in game tree

function HasFormatProperty(const format : string; gt : TGameTree) : boolean;
var
  i : integer;
  pn, xn, pv : string;
begin
  i := 0;
  Result := True;
  pv := '';
  repeat
    FindFormatProperty(format, i, gt, pn, xn, pv);
    if pv <> ''
      then exit
      else inc(i)
  until pn = '';
  Result := False
end;

// -- Construction of game result string -------------------------------------
//
// Convert a sgf result property (B+1.5) into a string

function ResultToString(s : string) : WideString;
var
  x : real;
begin
  s := UpperCase(Trim(s));
  if s = ''
    then exit;

  if (s = '0') or (s = 'DRAW')
    then Result := U('Draw')
  else
  if s = 'VOID'
    then Result := U('No result')
  else
  if s = '?'
    then Result := U('Unknown result')
  else
  if (Length(s) < 2) or (not (s[1] in ['B', 'W'])) or (s[2] <> '+')
    then exit;

  if Result <> ''
    then exit;

  if s[1] = 'B'
    then Result := U('Black wins')
    else Result := U('White wins');

  if Length(s) = 2
    then exit;

  case s[3] of
    'R' : Result := Result + ' ' + U('by resignation');
    'T' : Result := Result + ' ' + U('on time');
    'F' : Result := Result + ' ' + U('by forfeit');
    else
      if TryStrToReal(Copy(s, 3, 100), x)
        then Result := WideFormat(U('%s wins by %s points'),
                                  [U(iff(s[1] = 'B', 'Black', 'White')),
                                   Copy(s, 3, 100)])
        else Result := Result
  end
end;

// -- Random moves in a game tree --------------------------------------------

// -- Constant probability for each move

procedure SelectNextMoveEqui(var gt : TGameTree);
var
  MoveList : TList;
begin
  gt := gt.NextNode;
  MoveList := TList.Create;

  while gt <> nil do
    begin
      MoveList.Add(gt);
      gt := gt.NextVar
    end;

  if MoveList.Count = 0
    then gt := nil
    else gt := MoveList[random(MoveList.Count)];

  MoveList.Free
end;

// -- Probability proportional to the number of moves in subtrees.

function SelectNextMovePropDyn(gt : TGameTree) : TGameTree;
var
  MoveList : TList;
  size : array of integer;
  x : TGameTree;
  n, p, i : integer;
begin
  x := gt.NextNode;
  MoveList := TList.Create;

  while x <> nil do
    begin
      MoveList.Add(x);
      x := x.NextVar
    end;

  if MoveList.Count = 0
    then Result := nil
    else
      begin
        SetLength(size, MoveList.Count);
        n := 0;
        for i := 0 to MoveList.Count - 1 do
          begin
            size[i] := TGameTree(MoveList[i]).NumberOfNodes;
            inc(n, size[i])
          end;

        p := random(n);
        n := 0;
        for i := 0 to MoveList.Count - 1 do
          begin
            inc(n, size[i]);
            if n >= p then
              begin
                Result := MoveList[i];
                break
              end
          end;
      end;

  MoveList.Free
end;

// ---------------------------------------------------------------------------

// Traversing tree depth first direct order

function TraverseTreeDepthFirst1(gt : TGameTree; crc : longint) : longint;
begin
  Result := crc;

  if gt = nil
    then exit;

  Result := UpdateCrc32(Result, gt.Number);
  Result := TraverseTreeDepthFirst1(gt.NextNode, Result);
  Result := TraverseTreeDepthFirst1(gt.NextVar, Result)
end;

function TraverseTreeDepthFirst2(gt : TGameTree; crc : longint) : longint;
begin
  Result := crc;

  while gt <> nil do
    begin
      Result := UpdateCrc32(Result, gt.Number);
      Result := TraverseTreeDepthFirst2(gt.NextNode, Result);

      gt := gt.NextVar
    end
end;

function TraverseTreeDepthFirst(gt : TGameTree; crc : longword) : longword;
begin
  Result := crc;

  while gt <> nil do
    begin
      Result := UpdateCrc32(Result, gt.Number);
      gt := gt.NextNodeDepthFirst
    end
end;

// Traversing tree depth first reverse order

function TraverseTreeDepthFirstRev(gt : TGameTree; crc : longint) : longint;
begin
  Result := crc;

  if gt = nil
    then exit;

  Result := TraverseTreeDepthFirstRev(gt.NextVar, Result);
  Result := TraverseTreeDepthFirstRev(gt.NextNode, Result);
  Result := UpdateCrc32(Result, gt.Number)
end;

function TraverseTreeDepthFirstRev3(gt : TGameTree; crc : longword) : longword;
begin
  gt := gt.LastNodeDepthFirst;

  Result := crc;

  while gt <> nil do
    begin
      Result := UpdateCrc32(Result, gt.Number);
      gt := gt.PrevNodeDepthFirst
    end
end;

// Depth first numbering of moves

procedure NumDepthFirstIn(gt : TGameTree; var n : integer);
begin
  if gt = nil
    then exit;

  gt.Number := n;
  inc(n);

  NumDepthFirstIn(gt.NextNode, n);
  NumDepthFirstIn(gt.NextVar, n)
end;

procedure NumDepthFirst(gt : TGameTree);
var
  n : integer;
begin
  n := 1;
  NumDepthFirstIn(gt, n)
end;

// Traversing test

function SpanCollection(cl : TGameColl) : longint;
var
  i : integer;
  r : longword;
begin
  r := $FFFFFFFF;
  for i := 0 to cl.Count - 1 do
    begin
      NumDepthFirst(cl.Trees[i]);
      r := TraverseTreeDepthFirst(cl.Trees[i], r)
    end;
  Result := longint(r)
end;

// Traversing tree and properties

function TraverseTreeAndProperties(gt : TGameTree) : integer;
var
  n, i : integer;
  pr : TPropId;
  pv : string;
begin
  Result := 0;
  if gt = nil
    then exit;

  n := gt.PropNumber;
  for i := 1 to n do
    gt.NthProp(i, pr, pv, False);

  Result := n + TraverseTreeAndProperties(gt.NextNode)
              + TraverseTreeAndProperties(gt.NextVar)
end;

// Traversing test

function TraverseCollectionAndProperties(cl : TGameColl) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to cl.Count - 1 do
    Result := Result + TraverseTreeAndProperties(cl.Trees[i])
end;

// Random edit

function TestGameTreeApi(nbEditOps : integer) : integer;
const
  randSeed = 123456789;
  prDelTerminal = 5;    // probability to delete a terminal node
  prDelBranch = 2;      // probability to delete a non terminal node
  prAddVar = 5;         // probability to add a variation
var
  gt : TGameTree;
begin
  gt := RandomGameTree(randSeed, nbEditOps, prDelTerminal, prDelBranch, prAddVar);
  NumDepthFirst(gt);
  Result := integer(TraverseTreeDepthFirstRev3(gt, $FFFFFFFF));
  gt.FreeGameTree
end;

// ---------------------------------------------------------------------------

end.


