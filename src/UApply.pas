// ---------------------------------------------------------------------------
// -- Drago -- Interpretation of SGF properties ---------------- UApply.pas --
// ---------------------------------------------------------------------------

unit UApply;

// ---------------------------------------------------------------------------

interface

uses
  UView;

procedure ApplyNode(view : TView; mode : integer); 
procedure ApplyGM  (view : TView; mode : integer; const pv : string);
procedure ApplyST  (view : TView; mode : integer; const pv : string);
procedure ApplyCA  (view : TView; mode : integer; const pv : string);
procedure Apply_L  (view : TView; mode : integer; const pv : string);

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils, Classes,
  Define, DefineUi, UGoban, UGameTree, UStatus,
  Translate, Ux2y, UGmisc, GameUtils,
  Properties,
  CodePages;

// -- Forwards ---------------------------------------------------------------

procedure ApplyIgnored(view : TView;
                       mode : integer; pr : TPropId; const pv : string); forward;

// -- Display in the Annotation panel of of the Statusbar --------------------
//
// Annotation display is reset in ApplyNode

procedure UpdateAnnotation(view : TView; const glyph, msg : string);
begin
  if view.si.ApplyQuiet
    then // nop
    else view.AddAnnotation(glyph, msg)
end;

// -- GM : Game --------------------------------------------------------------

procedure ApplyGM(view : TView; mode : integer; const pv : string);
var
  n : integer;
begin
  n := pv2int(pv);
  if n <> 1
    then view.MessageDialog(msOk,
                            imExclam,
                            [U('The loaded game is not Go : GM property') + pv])
end;

// -- FF : File Format -------------------------------------------------------

procedure ApplyFF(view : TView; mode : integer; const pv : string);
begin
  // Nop : ignored properties are displayed in statusbar
end;

// -- CA : Charset -----------------------------------------------------------

procedure ApplyCA(view : TView; mode : integer; const pv : string);
begin
  if pv = ''
    then view.si.GameEncoding := view.st.DefaultEncoding
    else
      begin
        view.si.GameEncoding := CPNameToId(pv2str(pv));
        if view.si.GameEncoding = cpUnknown
          then view.si.GameEncoding := view.st.DefaultEncoding
      end;
end;

// -- ST : Style -------------------------------------------------------------

procedure ApplyST(view : TView; mode : integer; const pv : string);
begin
  Status.SetVariationFromST(pv)
end;

// -- SZ : Board size --------------------------------------------------------

procedure ApplySZ(view : TView; mode : integer; const pv : string);
begin
  // done in StartEvent
end;

// -- HA : Handicap ----------------------------------------------------------

procedure ApplyHA(view : TView; mode : integer; const pv : string);
begin
  view.st.Handicap := pv2int(pv)
end;

// -- Timing properties ------------------------------------------------------

// -- Initial time

procedure ApplyTM(view : TView; mode : integer; const pv : string);
begin
  if view.si.ApplyQuiet or (not view.si.HasTimeProp) or (mode in [Leave, Undo])
    then exit;

  view.StartTiming(pv2real(pv), -1)
end;

// -- Black/White time left

procedure ApplyBWL(view : TView;
                   mode : integer; pv : string; player : integer);
var
  x : TGameTree;
begin
  if view.si.ApplyQuiet
    then exit;

  with view do
    case mode of
      Enter,
      Redo  :
        UpdateTimeLeft(player, pv2real(pv));
      Leave : ;
      Undo  :
        if (gt.PrevNode <> nil) and (gt.PrevNode.PrevNode <> nil) then
          begin
            x := gt.PrevNode.PrevNode;
            if player = Black
              then pv := x.GetProp(prBL)
              else pv := x.GetProp(prWL);
            if pv = ''
              then UpdateTimeLeft(player, -1)
              else UpdateTimeLeft(player, pv2real(pv))
          end
    end
end;

// -- Black/White stones left

procedure ApplyStonesLeft(view : TView;
                          mode : integer; pv : string; player : integer);
var
  x : TGameTree;
begin
  if view.si.ApplyQuiet
    then exit;

  with view do
    case mode of
      Enter,
      Redo  :
        UpdateStonesLeft(player, pv2int(pv));
      Leave : ;
      Undo  :
        if (gt.PrevNode <> nil) and (gt.PrevNode.PrevNode <> nil) then
          begin
            x := gt.PrevNode.PrevNode;
            if player = Black
              then pv := x.GetProp(prOB)
              else pv := x.GetProp(prOW);
            if pv = ''
              then UpdateStonesLeft(player, -1)
              else UpdateStonesLeft(player, pv2int(pv))
          end
    end
end;

// -- B,W : Moves ------------------------------------------------------------

// -- Pass move

procedure ApplyPass(view : TView; mode : integer; player : integer);
begin
  if mode in [Enter, Redo]
    then
      if player = Black
        then UpdateAnnotation(view, 'Pass', T('Black') + ' ' + T('pass3'))
        else UpdateAnnotation(view, 'Pass', T('White') + ' ' + T('pass3'));

  case mode of
    Enter : inc(view.gb.GameBoard.MoveNumber);
    Undo  : dec(view.gb.GameBoard.MoveNumber)
    else // nop
  end
end;

// -- Apply B or W

procedure ApplyBorW(view : TView;
                    mode : integer; const pv : string; player : integer);
var
  i, j, status : integer;
begin
  with view do
    begin
      status := CgbOk;

      if pv = '[]'                          // encoding for pass
        then i := gb.BoardSize + 1
        else pv2ij(pv, i, j);

      if not gb.IsBoardCoord(i, j)          // another encoding for pass
        then ApplyPass(view, mode, player)
        else
          case mode of
            Enter : gb.Play(i, j, player, status);
            Undo  : gb.Undo;
            Leave : gb.Leave   (i, j);
            Redo  : gb.ComeBack(i, j)
          end;

      if si.ApplyQuiet
        then exit;

      case mode of
        Undo  : ApplyBWL(view, mode, pv, player);
        Enter : if gtp = nil then
                  case player of
                    Black : if gt.GetProp(prBL) = ''
                              then UpdateTiming(Black, '-');
                    White : if gt.GetProp(prWL) = ''
                              then UpdateTiming(White, '-')
                  end
      end;

      if status <> CgbOk then
        if player = Black
          then ApplyIgnored(view, mode, prB, pv)
          else ApplyIgnored(view, mode, prW, pv)
    end
end;

// -- AB,AW,AE : Position ----------------------------------------------------

procedure ApplyAddBWE(view : TView;
                      mode : integer; const val : string; inter : integer);
var
  i, j, k : integer;
  x : string;
begin
  if mode in [Leave, Redo]
    then exit;

  k := 1;
  x := nthpv(val, k);

  while x <> '' do
    begin
      pv2ij(x, i, j);

      with view do
        if gb.IsBoardCoord(i, j) then
          case mode of
            Enter : gb.Setup(i, j, inter);
            Undo  : gb.Remove
            else // nop
          end;

      inc(k);
      x := nthpv(val, k)
    end
end;

// -- M : Markups ------------------------------------------------------------

procedure ApplyM(view : TView; mode : integer; const val : string; mrk : integer);
var
  i, j, k : integer;
  x : string;
begin
  k := 1;
  x := nthpv(val, k);

  while x <> '' do
    begin
      pv2ij(x, i, j);

      with view do
        if (mode = Enter) or (mode = Redo)
          then
            if mrk = mrkWC
              then gb.ShowSymbol(i, j, mrk, 2)
              else gb.ShowSymbol(i, j, mrk)
          else
            if mrk = mrkWC
              then gb.ShowSymbol(i, j, mrkNO, 2)
              else gb.ShowSymbol(i, j, mrkNO);

      inc(k);
      x := nthpv(val, k)
    end
end;

// -- L : Letter -------------------------------------------------------------

var
  CurrentLetterIndex : integer; // reset in ApplyNode

procedure ApplyCurrentLetter(view : TView; i, j : integer);
begin
  view.gb.ShowSymbol(i, j, NthLetterMark('A', CurrentLetterIndex));
  inc(CurrentLetterIndex)
end;

procedure ApplyL(view : TView; mode : integer; const val : string);
var
  i, j, k : integer;
  x : string;
begin
  k := 1;
  x := nthpv(val, k);

  while x <> '' do
    begin
      pv2ij(x, i, j);

      if not view.gb.IsBoardCoord(i, j)
        then continue;

      if (mode = Enter) or (mode = Redo)
        then ApplyCurrentLetter(view, i, j)
        else view.gb.ShowSymbol(i, j, mrkNO);

      inc(k);
      x := nthpv(val, k)
    end
end;

// -- LB : Labels ------------------------------------------------------------

procedure ApplyLB(view : TView; mode : integer; const val : string);
var
  i, j, k : integer;
  x, txt : string;
begin
  k := 1;
  x := nthpv(val, k);

  while x <> '' do
    begin
      i := Pos(':', x) + 1;
      if i = 1
        then txt := ''
        else txt := CleanEscChar(Copy(x, i, Length(x) - i));

      if Length(txt) > 3
        then                        // 3 first for strings
          if TryStrToInt(txt, i)    // 3 last for numbers
            then txt := Copy(txt, Length(txt) - 2, 3)
            else txt := Copy(txt, 1, 3);

      pv2ij(x, i, j);

      if view.gb.IsBoardCoord(i, j)
        then
          if (mode = Enter) or (mode = Redo)
            then
              if (txt = '') and view.st.EmptyLBAsL
                then ApplyCurrentLetter(view, i, j)
                else view.gb.ShowSymbol(i, j, txt)
            else view.gb.ShowSymbol(i, j, mrkNO);

      inc(k);
      x := nthpv(val, k)
    end
end;

// -- N : Node names ---------------------------------------------------------

procedure ApplyN(view : TView; mode : integer; const pv : string);
begin
  with view do
    begin
      if (mode in [Leave, Undo]) or si.ApplyQuiet
        then exit;

      UpdateNodeName(pv)
    end
end;

// -- C : Comments -----------------------------------------------------------

procedure ApplyC(view : TView; mode : integer; const val : string);
var
  move, i, iC, iB, iW : integer;
  colour : char;
  pr : TPropId;
  pv : string;
begin
  with view do
    begin
      if Status.Exporting and (mode = Enter) then
        begin
          move := gb.MoveNumber; //TODO: what if no move

          iC := -1;
          iB := -1;
          iW := -1;

          for i := 1 to gt.PropNumber do
            begin
              gt.NthProp(i, pr, pv);
              if pr = prC
                then iC := i;
              if pr = prB
                then iB := i;
              if pr = prW
                then iW := i
            end;

          if ((iB >= 0) and (iC < iB)) or ((iW >= 0) and (iC < iW))
            then inc(move);

          if iB >= 0
            then colour := 'B'
            else
              if iW > 0
                then colour := 'W'
                else colour := 'N';

          Status.AccumComment.Add(colour + Format('%4d', [move])
                                  + UTF8Encode(CPDecode(pv2txt(val), si.GameEncoding)))
        end;

      if (mode in [Leave, Undo]) or si.ApplyQuiet
        then exit;

      UpdateComments(val)
    end
end;

// -- MN : Move Number -------------------------------------------------------

procedure ApplyMN(view : TView; mode : integer; const pv : string);
begin
  with view do
    case mode of
      Enter : begin // called before applying any other property
                gb.PushOffset(gb.MoveNumber + 1,
                               pv2int(pv) - (gb.MoveNumber + 1));
              end;
      Undo  : begin // called before applying any other property
                gb.PopOffset
              end;
      else // nop
   end
end;

// -- PL : Player ------------------------------------------------------------
// not used, not tested

procedure ApplyPL(view : TView; mode : integer; const pv : string);
begin
  if Length(pv) < 3
    then // pv invalid, keep st.Player
    else
      case UpCase(pv[2]) of
        'B' : view.UpdatePlayer(Black);
        'W' : view.UpdatePlayer(White);
        else // pv invalid, keep st.Player
      end
end;

// -- FG : Figure ------------------------------------------------------------

procedure ApplyFG(view : TView; mode : integer; const pv : string);
begin
  with view do
    if Status.IgnoreFG
      then exit
      else
        case mode of
          Enter :
            begin
              si.StackFG.Push(pv);
              gb.PushFG;
              gb.Draw;
              Status.AccumComment.Clear
            end;
          Leave : ; //Status.AccumComment.Clear;
          Redo  : ; // nop
          Undo  :
            begin
              si.StackFG.Pop;
              gb.PopFG;
              gb.Draw
            end
        end
end;

// -- _R : Result (private property used only at run time) -------------------

procedure Apply_R(view : TView; mode : integer; const pv : string);
begin
  if (mode in [Leave, Undo]) or view.si.ApplyQuiet
    then exit;

  view.ShowGameResult(pv)
end;

// -- _L : Label (private property used only at run time) --------------------
//
// Used by pattern search to mark continuations on board. Intended to be
// deleted when leaving the node.

procedure Apply_L(view : TView; mode : integer; const pv : string);
begin
  ApplyLB(view, mode, pv)
end;

// -- _W : Wildcard (private property used only at run time) -----------------
//
// Used by pattern search to mark wildcards on board. 

procedure Apply_W(view : TView; mode : integer; const pv : string);
begin
  ApplyM(view, mode, pv, mrkWC)
end;

// -- Apply annotation properties --------------------------------------------

procedure ApplyAnnotation(view : TView;
                          mode : integer;
                          pr : TPropId;
                          const pv : string;
                          const libelle1, libelle2 : string);
var
  s : string;
begin
  if (mode in [Leave, Undo]) or view.si.ApplyQuiet
    then exit;

  case pv[2] of
    '1' : s := libelle1;
    '2' : s := libelle2;
    ']' : s := libelle1; // empty value
    else  s := ''        // error
  end;

  UpdateAnnotation(view, 'Annotation', T(s))
end;

// -- Apply of ignored properties (unknown or not handled) -----------------

procedure ApplyIgnored(view : TView;
                       mode : integer; pr : TPropId; const pv : string);
begin
  if (mode in [Leave, Undo]) or view.si.ApplyQuiet
    then exit;

  view.ShowIgnoredProperty(PropertyName(pr))
end;

// -- Apply color transform --------------------------------------------------

function ApplyColorTransform(pr : TPropId) : TPropId;
begin
  case pr of
    //prB  : Result := prW;
    //prW  : Result := prB;
    //prAB : Result := prAW;
    //prAW : Result := prAB;
    //prTB : Result := prTW;
    //prTW : Result := prTB;
    prBL : Result := prWL;
    prWL : Result := prBL;
    prGB : Result := prGW;
    prGW : Result := prGB
  else
    Result := pr
  end
end;

// -- Dispatch ---------------------------------------------------------------

procedure ApplyProp(view : TView; mode : integer; pr : TPropId; const pv : string);
var
  typ, act : integer;
  longName : string;
  s1, s2   : string;
begin
  if view.gb.ColorTrans = ctReverse
    then pr := ApplyColorTransform(pr);

  case pr of
    prB  : ApplyBorW (view, mode, pv, Black);
    prW  : ApplyBorW (view, mode, pv, White);
    prBL : ApplyBWL  (view, mode, pv, Black);
    prWL : ApplyBWL  (view, mode, pv, White);
    prOB : ApplyStonesLeft(view, mode, pv, Black);
    prOW : ApplyStonesLeft(view, mode, pv, White);
    prTM : ApplyTM   (view, mode, pv);
    prSZ : ApplySZ   (view, mode, pv);
    prAB : ApplyAddBWE(view, mode, pv, Black);
    prAW : ApplyAddBWE(view, mode, pv, White);
    prAE : ApplyAddBWE(view, mode, pv, Empty);
    prC  : ApplyC    (view, mode, pv);
    prMA : ApplyM    (view, mode, pv, mrkMA);
    prM  : ApplyM    (view, mode, pv, mrkM);
    prTR : ApplyM    (view, mode, pv, mrkTR);
    prSQ : ApplyM    (view, mode, pv, mrkSQ);
    prCR : ApplyM    (view, mode, pv, mrkCR);
    prTB : ApplyM    (view, mode, pv, mrkTB);
    prTW : ApplyM    (view, mode, pv, mrkTW);
    prL  : ApplyL    (view, mode, pv);
    prLB : ApplyLB   (view, mode, pv);
    prN  : ApplyN    (view, mode, pv);
    prPL : ; { nop, cf ApplyNode.NextPlayer }
    prFF : ApplyFF   (view, mode, pv);
    prGM : ; { nop, cf StartEvent }
    prMN : ; { nop, cf ApplyNode }
    prST : ; { nop, cf StartEvent }
    prFG : ApplyFG   (view, mode, pv);
    pr_L : Apply_L   (view, mode, pv);
    pr_R : Apply_R   (view, mode, pv);
    pr_W : Apply_W   (view, mode, pv);
  else
    begin
      FindPropDef(pr, typ, act, longName, s1, s2);

      if typ = 0
        then ApplyIgnored(view, mode, pr, pv)
        else
          case act of
            0 : ApplyIgnored(view, mode, pr, pv);
            1 : ; // nop
            2 : ApplyAnnotation(view, mode, pr, pv, s1, s2);
            else  // Bug
          end
    end
  end
end;

// -- Entry point ------------------------------------------------------------

// -- Helpers

function SettingsStartFromOne(view : TView) : boolean;
begin
  Result := view.st.StartVarFromOne and
            ( (view.gt.PrevVar <> nil) or
             ((view.gt.NextVar <> nil) and view.st.StartVarAndMain) )
end;

function SettingsStartWithFig(view : TView) : boolean;
begin
  Result := view.st.StartVarWithFig and
            ( (view.gt.PrevVar <> nil) or
             ((view.gt.NextVar <> nil) and view.st.StartVarAndMain) )
end;

// --

procedure ApplyNode(view : TView; mode : integer);
var
  pr : TPropId;
  pv : string;
  i  : integer;
begin
  with view do
    begin
      if gt = nil then
        begin
          if gb.silence or si.ApplyQuiet
            then exit;
          UpdatePlayer(Black);
          exit
        end;

      if gt = LastVisitedNode
        then // nop
        else LastVisitedNode := gt;

      if (not si.ApplyQuiet) and (mode in [Leave, Undo])
        then view.gb.HideTempMarks;

      if not si.ApplyQuiet
        then ClearView;

      // reset letter index for L property
      CurrentLetterIndex := 1;

      // apply properties from first one when entering the node
      if (mode = Enter) or (mode = Redo) then
        begin
          pv := gt.GetProp(prMN);
          if pv <> ''
            then ApplyMN(view, mode, pv)
            else
              if SettingsStartFromOne(view)
                then ApplyMN(view, mode, '[1]');

          for i := 1 to gt.PropNumber do
            begin
              gt.NthProp(i, pr, pv);
              ApplyProp(view, mode, pr, pv)
            end;

          pv := gt.GetProp(prFG);
          if pv <> ''
            then // nop
            else
              if SettingsStartWithFig(view)
                then ApplyFG(view, mode, '[]');
        end;

      // apply properties from last one when leaving the node
      if (mode = Leave) or (mode = Undo) then
        begin
          pv := gt.GetProp(prFG);
          if pv <> ''
            then // nop
            else
              if SettingsStartWithFig(view)
                then ApplyFG(view, mode, '[]');

          for i := gt.PropNumber downto 1 do
            begin
              gt.NthProp(i, pr, pv);
              ApplyProp(view, mode, pr, pv)
            end;

          pv := gt.GetProp(prMN);
          if pv <> ''
            then ApplyMN(view, mode, pv)
            else
              if SettingsStartFromOne(view)
                then ApplyMN(view, mode, '[1]');
        end;

      if gb.silence or si.ApplyQuiet
        then exit;

      ShowNextOrVars(mode);

      UpdateMoveNumber(gb.NumWithOffset);
      UpdatePrisoners(gb.GameBoard.Prisoner[Black],
                      gb.GameBoard.Prisoner[White]);

      if (mode = Enter) or (Mode = Redo)
        then UpdatePlayer(NextPlayer(view.gt, view.si.Player))
    end
end;

// ---------------------------------------------------------------------------

end.

