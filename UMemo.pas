// ---------------------------------------------------------------------------
// -- Drago -- Access to results of replaying modes ------------- UMemo.pas --
// ---------------------------------------------------------------------------

unit UMemo;

// ---------------------------------------------------------------------------

interface

uses
  Forms, SysUtils, IniFiles, Controls,
  UViewMain;

var
  PbProfile    : TMemIniFile;
  PbNumber     : integer;
  PbLoadedFile : string;

  GmProfile    : TMemIniFile;
  GmNumber     : integer;
  GmLoadedFile : string;

function  GmVerifyAndLoad(view : TViewMain) : boolean;
function  PbVerifyAndLoad(view : TViewMain) : boolean;
procedure GmLoad         (view : TViewMain);
procedure PbLoad         (view : TViewMain);

function  PbGetLast : integer;
function  GmGetLast : integer;
procedure PbSetLast(n : integer);
procedure GmSetLast(n : integer);
function  GetPbNth (n : integer) : string;
procedure SetPbNth (n : integer; s : string);
function  PbNthOcc (n : integer) : integer;
function  GetGmNth (n : integer) : string;
procedure SetGmNth (n : integer; s : string);
function  GmNthOcc (n : integer) : integer;
procedure GmUpdateNth(index, mode, play, score : integer);
procedure PbUpdateNth(index : integer; correct, storeLast : boolean);

// ---------------------------------------------------------------------------

implementation

uses
  Define, DefineUi, Translate, Std, Main, Ugcom, UProblemUtil, UfmMsg,
  Properties;

var
  PbList, PbTags : array of string;
  GmList, GmTags : array of string;

// -- Verification of file and loading before starting session ---------------

// -- Games

function GmVerifyAndLoad(view : TViewMain) : boolean;
var
  cancel : boolean;
begin
  Result := False;

  SaveOrCancel(view, cancel);
  if cancel
    then exit;

  if not IsAGameFile(view.cl) then
    if MessageDialog(msYesNo, imQuestion,
                     [U('The file doesn''t seem to be a game file.'),
                      U('Continue') + ' ?']) = mrNo
      then exit;

  Result := True;
  try
    Screen.Cursor := fmMain.WaitCursor;
    GmLoad(view)
  finally
    Screen.Cursor := crDefault
  end
end;

// -- Problems

function IsEmptyFile(view : TViewMain) : boolean;
begin
  with view do
    case cl.Count of
      0 : Result := True;
      1 : Result := gt.Root.HasProp(SetupProps) = False;
      else Result := False
    end
end;

function PbVerifyAndLoad(view : TViewMain) : boolean;
var
  cancel : boolean;
begin
  Result := False;

  SaveOrCancel(view, cancel);
  if cancel
    then exit;

  if IsEmptyFile(view) then
    begin
      MessageDialog(msOk, imExclam,
                    [U('The file is not a problem collection.'),
                     '',
                     U('A problem collection must be loaded to start a problem session.')]);
      exit
    end;

  if not IsAProblemFile(view.cl) then
    if MessageDialog(msYesNo, imQuestion,
                     [U('The file doesn''t seem to be a problem file.'),
                      '',
                      U('A problem collection must be loaded to start a problem session.'),
                      '',
                      U('Continue') + ' ?']) = mrNo
      then exit;

  Result := True;
  try
    Screen.Cursor := fmMain.WaitCursor;
    PbLoad(view)
  finally
    Screen.Cursor := crDefault
  end
end;

// -- Loading ----------------------------------------------------------------

// -- Games

procedure GmLoad(view : TViewMain);
var
  i : integer;
begin
  GmNumber := view.cl.Count;
  SetLength(GmList, 1+GmNumber);
  SetLength(GmTags, 1+GmNumber);

  if view.si.FolderName = ''
    then
      begin
        GmLoadedFile := ExtractFileName(view.si.FileName);
        for i := 1 to GmNumber do
          begin
            GmTags[i] := IntToStr(i);
            GmList[i] := GmProfile.ReadString(GmLoadedFile, GmTags[i], '')
          end
      end
    else
      begin
        GmLoadedFile := ExtractFileName(ExcludeTrailingPathDelimiter(view.si.FolderName));
        for i := 1 to GmNumber do
          begin
            GmTags[i] := ExtractFileName(view.cl.Filename[i]);
            GmTags[i] := GmTags[i] + '-' + IntToStr(view.cl.Index[i]);
            GmList[i] := GmProfile.ReadString(GmLoadedFile, GmTags[i], '')
          end
      end
end;

// -- Problems

procedure PbLoad(view : TViewMain);
var
  i : integer;
begin
  PbNumber := view.cl.Count;
  SetLength(PbList, 1+PbNumber);
  SetLength(PbTags, 1+PbNumber);

  if view.si.FolderName = ''
    then
      begin
        PbLoadedFile := ExtractFileName(view.si.FileName);
        for i := 1 to PbNumber do
          begin
            PbTags[i] := IntToStr(i);
            PbList[i] := pbProfile.ReadString(PbLoadedFile, PbTags[i], '')
          end
      end
    else
      begin
        PbLoadedFile := ExtractFileName(ExcludeTrailingPathDelimiter(view.si.FolderName));
        for i := 1 to PbNumber do
          begin
            PbTags[i] := ExtractFileName(view.cl.Filename[i]);
            PbTags[i] := PbTags[i] + '-' + IntToStr(view.cl.Index[i]);
            PbList[i] := PbProfile.ReadString(PbLoadedFile, PbTags[i], '')
          end
      end
end;

// -- Access to nth game or problem ------------------------------------------

// -- Games

// GmNth is a string '<num Replay>
//                    <best score full game with Black>  <idem with White> <idem with both>
//                    <best score fuseki    with Black>  <idem with White> <idem with both>'

function GetGmNth(n : integer) : string;
begin
  Result := GmList[n]
end;

procedure SetGmNth(n : integer; s : string);
begin
  GmList[n] := s;
  GmProfile.WriteString(GmLoadedFile, GmTags[n], s)
end;

function GmNthOcc(n : integer) : integer;
begin
  Result := StrToIntDef(NthWord(GmList[n], 1), 0)
end;

// -- Problems

// PbNth(n) is a string '<number of attempts> <number of successes>'

function GetPbNth(n : integer) : string;
begin
  Result := PbList[n]
end;

procedure SetPbNth(n : integer; s : string);
begin
  PbList[n] := s;
  PbProfile.WriteString(PbLoadedFile, PbTags[n], s)
end;

function PbNthOcc(n : integer) : integer;
begin
  Result := StrToIntDef(NthWord(PbList[n], 1), 0)
end;

// -- Update of results ------------------------------------------------------

// -- Games

// strScores : GmNth
// mode      : play with Black, White, both
// play      : 0: full game, 1: fuseki, 2: from position
//             treat current position as full game
// score     : integer percentage of correct moves

procedure UpdateScores(var strScores : string; mode, play, score : integer);
var
  x : array[0 .. 6] of integer;
  i : integer;
begin
  // treat current position as full game
  if play = 2
    then play := 0;

  if strScores = ''
    then
      for i := 0 to 6 do
        x[i] := 0
    else
      for i := 0 to 6 do
        x[i] := StrToInt(NthWord(strScores, i+1));

  inc(x[0]);
  case mode of
    Black : x[3 * play + 1] := max(x[3 * play + 1], score);
    White : x[3 * play + 2] := max(x[3 * play + 2], score);
    BOTH  : x[3 * play + 3] := max(x[3 * play + 3], score);
  end;
  strScores := Format('%d %d %d %d %d %d %d',
                      [x[0], x[1], x[2], x[3], x[4], x[5], x[6]])
end;

procedure GmUpdateNth(index, mode, play, score : integer);
var
  s : string;
begin
  s := GetGmNth(index);
  UpdateScores(s, mode, play, score);
  SetGmNth(index, s);

  gmProfile.UpdateFile
end;

// -- Problems

procedure PbUpdateNth(index : integer; correct, storeLast : boolean);
var
  s : string;
  n, nOk : integer;
begin
  s   := GetPbNth(index);
  n   := StrToIntDef(NthWord(s, 1), 0);
  nOk := StrToIntDef(NthWord(s, 2), 0);
  inc(n);
  if correct
    then inc(nOk);

  SetPbNth(index, format('%d %d', [n, nOk]));
  if storeLast
    then PbSetLast(index);

  pbProfile.UpdateFile
end;

// -- Access to last game in sequence mode -----------------------------------

function PbGetLast : integer;
begin
  Result := PbProfile.ReadInteger(PbLoadedFile, 'Last', 0)
end;

procedure PbSetLast(n : integer);
begin
  PbProfile.WriteInteger(PbLoadedFile, 'Last', n)
end;

function GmGetLast : integer;
begin
  Result := GmProfile.ReadInteger(GmLoadedFile, 'Last', 0)
end;

procedure GmSetLast(n : integer);
begin
  GmProfile.WriteInteger(GmLoadedFile, 'Last', n)
end;

// ---------------------------------------------------------------------------

initialization
  PbProfile := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.pb'));
  PbLoadedFile := '';
  GmProfile := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.gm'));
  GmLoadedFile := ''
finalization
  PbProfile.Free;
  GmProfile.Free
end.
