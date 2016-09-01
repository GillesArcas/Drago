// ---------------------------------------------------------------------------
// -- Drago -- Debug, test and optimization ------------------ UfmDebug.pas --
// ---------------------------------------------------------------------------

unit UfmDebug;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, TypInfo,
  UGoban, UGameTree, UGameColl, StdCtrls, FileCtrl;

type
  TfmDebug = class(TForm)
    Memo: TMemo;
  end;

var
  fmDebug: TfmDebug = nil;

procedure DoDebug(sEgg : string);
procedure Resources(cl : TGameColl);
procedure BenchRead(cl : TGameColl);
procedure BenchSpan(cl : TGameColl; fileName : string);
procedure SpanCurrent;
procedure TraceGameEngine;
procedure Test_Editing;
procedure Test_RandomGame;
procedure Test_Trans;
procedure Test_GTP;

procedure SpanCurrentTree(gb : TGoban;
                          gt : TGameTree;
                          silence : Boolean);
function MyTimeToStr(d : double) : string;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  SysUtilsEx,
  Define, Main, Ustatus, SgfIo, Ugcom, UTreeView,
  UEngines, BoardUtils, ViewUtils, UView;

// -- Activation -------------------------------------------------------------

procedure DoRangeError; forward;

procedure DoDebug(sEgg : string);
begin
  with fmMain do
    begin
      if sEgg = 'DBG' then
        begin
          mnDebug.Visible := not mnDebug.Visible;
          if mnDebug.Visible
            then fmDebug := TfmDebug.Create(Application)
            else
              if fmDebug <> nil
                then fmDebug.Release;
          exit
        end;
      if sEgg = 'GTP' then
        begin
          Status.Debug := not Status.Debug;
          if Status.Debug
            then
              begin
                fmDebug := TfmDebug.Create(Application);
                fmDebug.Show
              end
            else fmDebug.Release;
          exit
        end;
      if sEgg = 'MEM' then
        begin
          tmMemory.Enabled := not tmMemory.Enabled;
          exit
        end;
      if sEgg = 'BUG' then
        begin
          DoRangeError;
          exit
        end;
      if sEgg = 'SHC' then
        begin
          ActionsWithShortcut.Visible := not ActionsWithShortcut.Visible
        end
    end
end;

{$r+}

procedure DoRangeError;
var
  arr : array[0 .. 9] of integer;
  n, i : integer;
  l : TStringList;
begin
  case random(3) of
    0 : begin
          i := -1;
          n := arr[i];
          ShowMessage(IntToStr(n))
        end;
    1 : begin
          i := 0;
          n := 1 div i;
          ShowMessage(IntToStr(n))
        end;
    2 : begin
          n := StrToIntDef(l.Strings[1], 1);
          ShowMessage(IntToStr(n))
        end
  end
end;

// -- Helpers ----------------------------------------------------------------

function ActiveView : TView;
begin
  Result := fmMain.ActiveView
end;

// -- Format timing

function MyTimeToStr(d : double) : string;
var
  h, m, s, ms : word;
begin
  DecodeTime(d, h, m, s, ms);
  MyTimeToStr := TimeToStr(d) + '.' + Format('%2d', [ms div 10])
end;

// -- Resources --------------------------------------------------------------

// -- Size of strings

procedure StringSize(x : TGameTree; var nChar, nByte : integer);
var
  nC1, nB1, nC2, nB2 : integer;
begin
  if x = nil
    then
      begin
        nChar := 0;
        nByte := 0
      end
    else
      begin
        StringSize(x.NextNode, nC1, nB1);
        StringSize(x.NextVar, nC2, nB2);
        Assert(False);
        (*
        nChar := nC1 + nC2 + Length(x.Value);
        if Length(x.Value) = 0
          then nByte := nB1 + nB2
          else nByte := nB1 + nB2 + Length(x.Value)
                                  + 4   // refcount
                                  + 4   // length
                                  + 1   // ending #0
        *)
      end
end;

// -- Format memo

procedure FormatMemo(s : string; n : integer);
begin
  fmDebug.Memo.Lines.Add(Format('%-20s %10.0n', [s, n*1.0]))
end;

// -- Command

procedure Resources(cl : TGameColl);
var
  sN, sC, sB, sC1, sB1, i, h, w : integer;
begin
  sN := 0;
  sC := 0;
  sB := 0;
  for i := 1 to cl.Count do
    begin
      inc(sN, cl[i].NumberOfNodes);
      StringSize(cl[i], sC1, sB1);
      inc(sC, sC1);
      inc(sB, sB1)
    end;
  GetTreeDim(ActiveView.gt.Root, h, w);

  with fmDebug.Memo.Lines do
    begin
      Add('-- Application --');
      FormatMemo('Blocs', AllocMemCount);
      FormatMemo('Octets', AllocMemSize);
      Add('-- Fichier ------');
      FormatMemo('Nombre noeuds', sN);
      //*//FormatMemo('Volume noeuds', sN * sizeof(Tgnode));
      FormatMemo('Nombre caracteres', sC);
      FormatMemo('Volume chaines', sB);
      //*//FormatMemo('Volume fichier', sN * sizeof(Tgnode) + sB);
      Add('-- Jeu ----------');
      FormatMemo('Hauteur', h);
      FormatMemo('Largeur', w);
      Add('')
    end;
  fmDebug.Show
end;

// -- Bench de de lecture fichier --------------------------------------------

procedure BenchRead(cl : TGameColl);
var
  List : TStringList;
  i, n : integer;
  d1, d2, t : double;
begin
  List := TStringList.Create;
  List.Clear;
  AddFilesToList(List, '..\Sgf\Joseki\' , '*.sgf');
  //AddFilesToList(List, '..\Sgf\MFGo\'   , '*.sgf');
  {
  AddFilesToList(List, '..\Sgf\Fuseki\' , '*.sgf');
  AddFilesToList(List, '..\Sgf\Joseki\' , '*.sgf');
  AddFilesToList(List, '..\Sgf\Parties\', '*.sgf');
  AddFilesToList(List, '..\Sgf\Problemes\', '*.sgf');
  AddFilesToList(List, '..\Sgf\Vrac\'   , '*.sgf');
  AddFilesToList(List, '..\Sgf\Vrac\'   , '*.mgt');
  }

  fmDebug.Show;
  t := 0;
  for i := 0 To List.Count - 1 do
    begin
      //d1 := Now;
      ReadSgf(cl, List[i], n,
              Settings.LongPNames, Settings.AbortOnReadError);
      //d2 := Now;
      d1 := Now;
      //LoadTreeView(ActiveView as TViewBoard, cl[1].Root, 0, 0);
      d2 := Now;
      t := t + (d2 - d1);
      if n = 0
        then fmDebug.Memo.Lines.Add ('Lecture ' + List[i] + ' incorrecte')
        else
          if sgfResult <> 0
            then fmDebug.Memo.Lines.Add('Lecture ' + List[i] + ' incomplete')
            else fmDebug.Memo.Lines.Add('Lecture ' + List[i] + ' OK');
    end;
  fmDebug.Memo.Lines.Add('Elapsed: ' + MyTimeToStr(t));

  //DoMainNewFile(False);
  List.Free
end;

// -- Bench Parcours ---------------------------------------------------------

procedure BenchSpan(cl : TGameColl; fileName : string);
var
  ListSms, ListFiles : TStringList;
  fn : string;
  i, n : integer;
  d1, d2, t : double;
  quiet : boolean;
begin
  quiet := False;

  ListSms := TStringList.Create;
  ListSms.LoadFromFile(fileName);
  ListFiles := TStringList.Create;
  for i := 0 to ListSms.Count - 1 do
    if ListSms.Strings[i][1] = ';'
      then continue
      else AddFilesToList(ListFiles, ExtractFilePath(ListSms.Strings[i])
                                   , ExtractFileName(ListSms.Strings[i]));

  fmDebug.Show;

  t := 0;
  for i := 0 to ListFiles.Count - 1 do
    begin
      fn := ListFiles.Strings[i];
      ReadSgf(cl, fn, n,
              Settings.LongPNames, Settings.AbortOnReadError);
      if n = 0
        then fmDebug.Memo.Lines.Add ('Lecture ' + fn + ' incorrecte')
        else
          if sgfResult <> 0
            then fmDebug.Memo.Lines.Add('Lecture ' + fn + ' incomplete')
            else fmDebug.Memo.Lines.Add('Lecture ' + fn + ' OK');

      ActiveView.ApplyQuiet(quiet);
      d1 := Now;
      for n := 1 to cl.Count do
        begin
          ActiveView.gt := cl[n];
          ActiveView.StartEvent;
          SpanCurrentTree(ActiveView.gb, ActiveView.gt, quiet)
        end;
      d2 := Now;
      t := t + (d2 - d1)
    end;
  fmDebug.Memo.Lines.Add('Elapsed: ' + MyTimeToStr(t));

  DoMainNewFile(False)
end;

// -- Bench Parcours ---------------------------------------------------------

var
  maxVar : integer;

function NumVar(x : TGameTree) : integer;
begin
  Result := 0;
  while x.NextVar <> nil do
    begin
      inc(Result);
      x := x.NextVar
    end;
end;

procedure SpanCurrentTree(gb : TGoban;
                          gt : TGameTree;
                          silence : Boolean);
begin
  if (gt <> nil) and (gt.NextNode <> nil) then
    begin
      if NumVar(gt) > maxVar then
        begin
          maxVar := NumVar(gt);
          fmDebug.Memo.Lines.Add(gt.StepsToNode)
        end;

      ActiveView.DoNextMove;
      if not Silence
        then Application.ProcessMessages;
      SpanCurrentTree(gb, gt, Silence);

      while gt.NextVar <> nil do
        begin
          DoNextVariation(ActiveView);
          if not Silence
             then Application.ProcessMessages;
          SpanCurrentTree(gb, gt, Silence)
        end;

      ActiveView.DoPrevMove;
      if not Silence
        then Application.ProcessMessages;
    end;
end;

procedure SpanCurrent;
var
  d1, d2 : double;
begin
  fmDebug := TFmDebug.Create(Application);
  fmDebug.Show;
  maxVar := 0;
  d1 := Now;
  with ActiveView do
    SpanCurrentTree(gb, gt, not False);
  d2 := Now;
  fmDebug.Memo.Lines.Add('Elapsed: ' + MyTimeToStr(d2 - d1));
end;

// -- Search for string in comment -------------------------------------------

procedure SearchInCommentInner(gb : TGoban;
                               gt : TGameTree;
                               silence : boolean;
                               s : string);
begin
  if (gt <> nil) and (gt.NextNode <> nil) then
    begin
      ActiveView.DoNextMove;
      if not Silence
        then Application.ProcessMessages;
      SpanCurrentTree(gb, gt, Silence);

      while gt.NextVar <> nil do
        begin
          DoNextVariation(ActiveView);
          if not Silence
            then Application.ProcessMessages;
          SpanCurrentTree(gb, gt, Silence)
        end;

      ActiveView.DoPrevMove;
      if not Silence
        then Application.ProcessMessages;
    end;
end;

procedure SearchInComment(s : string);
begin
  fmDebug := TFmDebug.Create(Application);
  fmDebug.Show;
  with ActiveView do
    SearchInCommentInner(gb, gt, not False, s);
end;

// -- Traces moteur de jeu ---------------------------------------------------

procedure TraceGameEngine;
begin
  Status.Debug := not Status.Debug;
  if Status.Debug
    then fmDebug.Show
    else fmDebug.Close
end;

// -- Test des commandes GNU Go hors partie ----------------------------------

var
  LoopGTP : integer;

procedure Test_GTP_Callback(gv : TView; const x : string);
begin
  fmDebug.Memo.Lines.Add(IntToStr(LoopGTP));
  fmDebug.Memo.Lines.Add(x);
  Application.ProcessMessages
end;

procedure Test_GTP;
begin
  fmDebug.Show;
  for LoopGTP := 1 to 100 do
    case 2 of
      //0 : EngineInformation(fmMain.ActiveView, Test_GTP_Callback);
      1 : ScoreEstimate    (fmMain.ActiveView, Test_GTP_Callback);
      2 : SuggestMove      (fmMain.ActiveView, Test_GTP_Callback)
    end
end;

// -- Test des opérations d'édition ------------------------------------------

procedure Test_Editing;
const
  nbEditOps = 2000;
  prDelTerminal = 5;
  prAddVar = 1;
var
  Nodes : TList;
  k, i, j, n, status : integer;
  x : TGameTree;
begin
  with fmMain do
    begin
      DoMainNewFile(False);
      Nodes := TList.Create;
      Nodes.Add(ActiveView.gt);

      for k := 1 to nbEditOps do
        begin
          n := Random(Nodes.Count);
          x := TGameTree(Nodes.Items[n]);

          ActiveView.GoToNode(x);
          repeat
            i := Random(19) + 1;
            j := Random(19) + 1
          until ActiveView.gb.IsValid(i, j, ActiveView.si.Player, status);

          if ActiveView.gt.NextNode = nil
            then
              begin
                if (Random(100) < prDelTerminal) and (ActiveView.gt.PrevNode <> nil)
                  then
                    begin
                      Nodes.Delete(Nodes.indexOf(ActiveView.gt));
                      ActiveView.DoUndoMove
                    end
                  else
                    begin
                      ActiveView.DoNewMove(i, j);
                      Nodes.Add(ActiveView.gt)
                    end
              end
            else
              if Random(100) < prAddVar then
                begin
                  ActiveView.DoNewVar(i, j);
                  Nodes.Add(ActiveView.gt)
                end;

          Application.ProcessMessages
        end
    end;
  Nodes.Free
end;

procedure Test_RandomGame;
var
  p, k, i, j, n, status, nValid : integer;
  valid : array[1 .. 361, 1 .. 2] of integer;
begin
  for p := 1 to 10 do
  with fmMain do
    begin
      DoMainNewFile(True);

      for k := 1 to 2000 do
        begin
          nValid := 0;
          for i := 1 to 19 do
            for j := 1 to 19 do
              if ActiveView.gb.IsValid(i, j, ActiveView.si.Player, status) then
                begin
                  inc(nValid);
                  valid[nValid, 1] := i;
                  valid[nValid, 2] := j
                end;

          if nValid = 0
            then break;

          n := 1 + Random(nValid);
          i := valid[n, 1];
          j := valid[n, 2];
          ActiveView.DoNewMove(i, j);

          Application.ProcessMessages
        end
    end
end;

// ---------------------------------------------------------------------------

procedure Nop; overload;
begin
end;

procedure Nop(x : string); overload;
begin
   fmDebug.Memo.Lines.Add(x)
end;

procedure Test_Trans;
var
  t1, t2, t : TCoordTrans;
  s : string;
begin
  fmDebug.Show;
  for t1 := trIdent to trSymD270 do
    begin
      s := '(';
      for t2 := trIdent to trSymD270 do
        begin
          t := Compose(t1, t2);
          s := s + ' ' + Format('%-9s,', [GetEnumName(TypeInfo(TCoordTrans), ord(t))])
        end;
      s := s + '),';
      fmDebug.Memo.Lines.Add(s);
    end
end;

// ---------------------------------------------------------------------------

initialization
  fmDebug := nil
end.
