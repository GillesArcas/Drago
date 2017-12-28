// ---------------------------------------------------------------------------
// -- Drago -- Implementation of Go Text Protocol ---------------- UGtp.pas --
// ---------------------------------------------------------------------------

unit UGtp;

// ---------------------------------------------------------------------------

{$ifdef FPC}

interface
type
  TGtp = class
  end;
implementation
end.

{$else}

interface

uses
  DosCommand, UGameTree, Properties;

type
  TGTPStatus = (gtpOk, gtpErr0r, gtpUndef);
  TTerminateType = (ttUserTerminate, ttErrorTerminate, ttAbortTerminate);

  TCallBack  = procedure of object;
  TOnTrace   = procedure (const s : string);
  TOnReturn  = procedure (view : TObject);

  TGtp = class
  public
    Context       : TObject;
    DosCommand    : TDosCommand;
    OutputString  : string;
    FullName      : WideString;
    FInfoName     : string;
    FInfoVersion  : string;
    FInfoCommands : string;
    AliveList, DeadList, SekiList, GameResult : string;
    OnGtpError    : TOnReturn;
    OnGtpCrash    : TOnReturn;

    constructor Create(aContext : TObject;
                       Trace : TOnTrace;
                       gtpError, gtpCrash : TOnReturn);
    destructor  Destroy; override;
    procedure   Start(const aFullname : WideString; const args : string; out ok : boolean);
    procedure   Info (aOnReturn : TOnReturn);
    procedure   Stop (aOnReturn : TOnReturn = nil);
    function    Active : boolean;
    procedure   Send(ACallBack : TCallBack; cmd : string);
    procedure   SendAndIgnoreResult(aOnReturn : TOnReturn; cmd : string);
    procedure   NewGame(aOnReturn : TOnReturn;
                        aBoardsize: integer;
                        aHandicap : integer;
                        aKomi     : real;
                        aPlayBl   : boolean;
                        aFreeHa   : boolean;
                        aFreeSt   : string;
                        aSgfGame  : TGameTree);
    procedure   TimeSettings (aOnReturn : TOnReturn;
                              mainTime, byoYomi_time, byoYomiStones : integer);
    procedure   TimeLeft     (aOnReturn : TOnReturn;
                              player : string; time, stones : integer);
    procedure   ClientPlay   (aOnReturn : TOnReturn; const player, move : string);
    procedure   EnginePlay   (aOnReturn : TOnReturn; const player : string);
    procedure   Play         (aOnReturn : TOnReturn; const player, move : string);
    procedure   PlayFirst    (aOnReturn : TOnReturn; player : string);
    procedure   Undo         (aOnReturn : TOnReturn);
    procedure   FinalScore   (aOnReturn : TOnReturn);
    procedure   FinalStatus  (aOnReturn : TOnReturn);
    procedure   Command      (aOnReturn : TOnReturn; const cmd : string);
    procedure   ScoreEstimate(aOnReturn : TOnReturn; gt : TGameTree = nil);
    procedure   SuggestMove  (aOnReturn : TOnReturn; const player : string; gt : TGameTree = nil); overload;
    procedure   InfluenceRegions(aOnReturn : TOnReturn; const player : string; gt : TGameTree = nil);
    procedure   GroupStatus  (aOnReturn : TOnReturn; const vertex : string; gt : TGameTree = nil);
  private
    TerminateType : TTerminateType;
    OnReturn     : TOnReturn;
    OnTrace      : TOnTrace;
    CallBack     : TCallBack;
    SendSgfCallBack : TCallBack;
    SendMovesCallBack : TCallBack;
    OutputBuffer : string;
    OutputStatus : TGTPStatus;

    boardsize: integer;         // NewGame function parameter copy
    Handicap : integer;
    Komi     : real;
    PlayBl   : boolean;
    FreeHa   : boolean;
    FreeSt   : string;
    SgfGame  : TGameTree;
    SgfRoot  : TGameTree;

    SgfIndex   : integer;
    LastPlayer : string;
    LastMove   : string;
    ListMoves  : string;        // used by SendMoves
    FVertex    : string;        // used by GroupStatus

    FixedHandicapAvailable   : boolean;
    SetFreeHandicapAvailable : boolean;
    LoadSgfAvailable         : boolean;

    procedure DosCommandNewLine(Sender: TObject; NewLine: string;
                                OutputType: TOutputType);
    procedure DosCommandTerminate;
    procedure StopOnGtpError;
    procedure TerminateCommand;
    procedure Info2;
    procedure Info3;
    procedure Info4;
    procedure NewGame1;
    procedure NewGame2;
    procedure NewGame3;
    procedure NewGame4;
    procedure NewGame5;
    procedure NewGame6;
    procedure StartGame;
    procedure LoadSgf2;
    procedure LoadSgfDone;
    procedure SendGameTree;
    procedure SendGameTree2;
    procedure SendGameTree3;
    procedure SendGameTree4;
    procedure ClientPlay2;
    procedure EnginePlay2;
    procedure Play2;
    procedure Play3;
    procedure Play4;
    procedure SendMoves(ACallBack : TCallBack; const player, coord : string);
    procedure SendMoves2;
    procedure Undo2;
    procedure LoadSgf(ACallBack : TCallBack; gt : TGameTree);
    procedure TimeSettings2;
    procedure TimeLeft2;
    procedure FinalScore2;
    procedure FinalStatus2;
    procedure FinalStatus3;
    procedure FinalStatus4;
    procedure Command2;
    procedure ScoreEstimate2;
    procedure SuggestMove2;
    procedure InfluenceRegions2;
    procedure GroupStatus2;
    procedure GroupStatus3;
    procedure GroupStatus4;
    procedure FindNextProp(out pr : TPropId; out pv : string);
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils, Windows, 
  Define, Ux2y, UView,
  UGMisc, Std, GameUtils, BoardUtils,
  SysUtilsEx;

// -- Construction and destruction -------------------------------------------

constructor TGtp.Create(aContext : TObject;
                        Trace : TOnTrace;
                        gtpError, gtpCrash : TOnReturn);
begin
  inherited Create;

  Context       := aContext;
  OnTrace       := Trace;
  OnGtpError    := gtpError;
  OnGtpCrash    := gtpCrash;

  DosCommand := TDosCommand.Create(nil);
  DosCommand.OnNewLine := DosCommandNewLine;
  DosCommand.OnTerminated := DosCommandTerminate;
  TerminateType := ttAbortTerminate;

  OutputBuffer := ''
end;

destructor TGtp.Destroy;
begin
  TerminateType := ttUserTerminate;
  DosCommand.Stop;
  FreeAndNil(DosCommand);
  inherited Destroy
end;

// -- Start of engine --------------------------------------------------------

procedure TGtp.Start(const aFullname : WideString; const args : string; out ok : boolean);
begin
  FullName := aFullname;
  DosCommand.CommandLine := '"' + aFullname + '" ' + args;
  DosCommand.CurrentDirectory := WideExtractFilePath(aFullname);
  DosCommand.Execute(ok)
end;

// -- Stop of engine ---------------------------------------------------------

// -- Commands

procedure TGtp.Stop(aOnReturn : TOnReturn = nil);
begin
  OnReturn := aOnReturn;

  TerminateType := ttUserTerminate;
  DosCommand.Stop;

  if @OnReturn <> nil
    then OnReturn(Context)
end;

procedure TGtp.StopOnGtpError;
begin
  TerminateType := ttErrorTerminate;
  Stop;
end;

// -- Wait for terminate

function TGtp.Active : boolean;
begin
  Result := Assigned(self) and Assigned(DosCommand)
            and DosCommand.Active
            and DosCommand.IsAlive
end;

// -- Stop on error event

procedure TGtp.DosCommandTerminate;
begin
  case TerminateType of
    ttUserTerminate  : ; //nop
    ttErrorTerminate :
      if Assigned(OnGtpError)
        then OnGtpError(Context);
    ttAbortTerminate :
      if Assigned(OnGtpCrash)
        then OnGtpCrash(Context)
  end
end;

// -- Sending of a command ---------------------------------------------------

procedure TGtp.Send(ACallBack : TCallBack; cmd : string);
begin
  OnTrace(cmd);
  CallBack := ACallBack;
  DosCommand.SendLine(cmd, True)
end;

procedure TGtp.DosCommandNewLine(Sender: TObject; NewLine: string;
                                 OutputType: TOutputType);
var
  i, p : integer;
begin
  if OutputType = otBeginningOfLine
    then exit;
  OnTrace(NewLine);

  for i := 1 to Length(NewLine) do
    if NewLine[i] <> #13
      then OutputBuffer := OutputBuffer + NewLine[i];

  OutputBuffer := OutputBuffer + #10;

  p := Pos(#10#10, OutputBuffer);
  if p = 0
    then
      begin
        if (Length(OutputBuffer) > 0) and not (OutputBuffer[1] in ['=', '?'])
          then OutputBuffer := '';
        exit
      end;

  OutputString := Copy(OutputBuffer, 1, p + 1);
  //OnTrace(OutputString);
  
  case OutputString[1] of
    '=' : OutputStatus := gtpOk;
    '?' : OutputStatus := gtpErr0r;
    else  OutputStatus := gtpUndef
  end;
  OutputString := Copy(OutputString, 3, Length(OutputString));
  OutputBuffer := Copy(OutputBuffer, p + 2, Length(OutputBuffer));

  if True//OutputStatus = gtpOk
    then
      begin
        if Assigned(CallBack)
          then CallBack
      end
    else StopOnGtpError
end;

// -- GTP game functions -----------------------------------------------------
//
// -- The following functions use only gtp.Send method.

procedure TGtp.TerminateCommand;
begin
  OnReturn(Context)
end;

procedure TGtp.SendAndIgnoreResult(aOnReturn : TOnReturn; cmd : string);
begin
  OnReturn := aOnReturn;
  Send(TerminateCommand, cmd)
end;

// -- Engine information -----------------------------------------------------

procedure TGtp.Info(aOnReturn : TOnReturn);
begin
  OnReturn := aOnReturn;
  Send(Info2, 'name')
end;

procedure TGtp.Info2;
begin
  FInfoName := Copy(OutputString, 1, Pos(#10, OutputString) - 1);
  Send(Info3, 'version')
end;

procedure TGtp.Info3;
begin
  FInfoVersion := Copy(OutputString, 1, Pos(#10, OutputString) - 1);
  Send(Info4, 'list_commands')
end;

procedure TGtp.Info4;
begin
  FInfoCommands := OutputString;
  if Length(FInfoVersion) > 10
    then OutputString := FInfoName
    else OutputString := FInfoName + ' ' + FInfoVersion;
  OnReturn(Context)
end;

// -- New game command

procedure TGtp.NewGame(aOnReturn : TOnReturn;
                       aBoardsize: integer;
                       aHandicap : integer;
                       aKomi     : real;
                       aPlayBl   : boolean;
                       aFreeHa   : boolean;
                       aFreeSt   : string;
                       aSgfGame  : TGameTree);
begin
  OnReturn  := aOnReturn;
  Boardsize := Aboardsize;
  Komi      := Akomi;
  Handicap  := AHandicap;
  PlayBl    := aPlayBl;
  FreeHa    := aFreeHa;
  FreeSt    := aFreeSt;
(*
  if aSgfGame = nil
    then SgfGame := nil
    else SgfGame := aSgfGame.Last.MovesToNode;
*)
  SgfGame := aSgfGame;

  Send(NewGame1, 'list_commands')
end;

procedure TGtp.NewGame1;
begin
  FInfoCommands := OutputString;
  FixedHandicapAvailable   := Pos('fixed_handicap'   , FInfoCommands) > 0;
  SetFreeHandicapAvailable := Pos('set_free_handicap', FInfoCommands) > 0;
  LoadSgfAvailable         := Pos('loadsgf'          , FInfoCommands) > 0;

  Send(NewGame2, 'boardsize ' + IntTostr(Boardsize))
end;

procedure TGtp.NewGame2;
var
  s : string;
begin
  s := StringReplace(FloatToStr(Komi), ',', '.', []);
  Send(NewGame3, 'komi ' + s)
end;

procedure TGtp.NewGame3;
begin
  Send(NewGame4, 'clear_board')
end;

procedure TGtp.NewGame4;
begin
  if Handicap < 2
    then NewGame6
    else
      if not FreeHa
        then
          begin
            if FixedHandicapAvailable
              then Send(NewGame6, 'fixed_handicap ' + IntTostr(Handicap))
              else
                if SetFreeHandicapAvailable
                  then Send(NewGame6,
                            'set_free_handicap ' +
                            sgf2gtp(HandicapStones(Boardsize, Handicap), Boardsize))
                  else SendMoves(NewGame6, 'b',
                                 sgf2gtp(HandicapStones(Boardsize, Handicap), Boardsize))
            end
        else
          if PlayBl
            then Send(NewGame5, 'place_free_handicap ' + IntTostr(Handicap))
            else Send(StartGame, 'set_free_handicap ' + FreeSt)
end;

// -- Return from free placement by engine

procedure TGtp.NewGame5;
var
  s, r, x : string;
  i, j, k : integer;
begin
  with Context as TView do
    begin
      gt.Root.PutProp(prHA, str2pv(IntToStr(Handicap)));
      s := gtp2sgf(OutputString, gb.BoardSize);
      r := '';
      for k := 0 to handicap - 1 do
        begin
          x := '[' + Copy(s, k * 2 + 1, 2) + ']';
          r := r +  x;
          pv2ij(x, i, j);
          gb.Setup(i, j, Black)
        end;

      gt.Root.PutProp(prAB, r);
      StartGame
    end
end;

procedure TGtp.NewGame6;
begin
  if SgfGame = nil
    then StartGame
    else LoadSgf(StartGame, SgfGame)
end;

procedure TGtp.StartGame;
begin
  OnReturn(Context)
end;

// -- Send sgf game file -----------------------------------------------------

procedure TGtp.LoadSgf(ACallBack : TCallBack; gt : TGameTree);
begin
  SendSgfCallBack := ACallBack;
  if gt = nil
    then SgfGame := nil
    else SgfGame := gt.MovesToNode;

  SgfRoot := SgfGame.Root;
  Send(LoadSgf2, 'known_command loadsgf')
end;

procedure TGtp.LoadSgf2;
begin
  if AnsiStartsStr('true', LowerCase(OutputString))
    then Send(LoadSgfDone, 'loadsgf ' + ExtractShortPathName(PrintGameToFile(SgfGame)))
    else SendGameTree
end;

procedure TGtp.LoadSgfDone;
begin
  SgfRoot.FreeGameTree;
  SendSgfCallBack
end;

procedure TGtp.SendGameTree;
begin
  // SgfGame is initialized with path from root to position
  // root may contain SZ, HA, KM
  // other nodes may contain AB, AW, B, W
  SgfRoot   := SgfGame.Root;
  SgfGame   := SgfRoot;
  SgfIndex  := 1;
  BoardSize := BoardsizeOfGameTree(SgfGame);

  Send(SendGameTree2, 'boardsize ' + IntToStr(Boardsize))
end;

procedure TGtp.SendGameTree2;
var
  pv : string;
begin
  pv := SgfRoot.GetProp(prKM);
  pv := pv2str(pv);

  if pv = ''
    then SendGameTree3
    else Send(SendGameTree3, 'komi ' + AnsiReplaceStr(pv, ',', '.'))
end;

procedure TGtp.SendGameTree3;
begin
  Send(SendGameTree4, 'clear_board')
end;

procedure TGtp.SendGameTree4;
var
  pr : TPropId;
  pv : string;
begin
  FindNextProp(pr, pv);

  if pr = prNone
    then LoadSgfDone
    else
      begin
        if IsPvValidCoord(pv, BoardSize)
          then pv := sgf2kor(pv2str(pv), BoardSize)
          else pv := 'pass';

        if (pr = prAB) or (pr = prB)
          then Send(SendGameTree4, 'play b ' + pv)
          else
            if (pr = prAW) or (pr = prW)
              then Send(SendGameTree4, 'play w ' + pv)
              else SendGameTree4
      end
end;

procedure TGtp.FindNextProp(out pr : TPropId; out pv : string);
begin
  pr := prNone;

  if SgfGame = nil
    then exit;

  while True do
    begin
      SgfGame.NthProp(SgfIndex, pr, pv, False);

      if pr <> prNone
        then break;

      if SgfGame.NextNode = nil
        then exit;

      SgfGame  := SgfGame.NextNode;
      SgfIndex := 1
    end;

  inc(SgfIndex)
end;

// -- Time settings ----------------------------------------------------------

procedure TGtp.TimeSettings(aOnReturn : TOnReturn;
                            mainTime, byoYomi_time, byoYomiStones : integer);
begin
  OnReturn := AOnReturn;
  Send(TimeSettings2, Format('time_settings %d %d %d',
                             [mainTime, byoYomi_time, byoYomiStones]))
end;

procedure TGtp.TimeSettings2;
begin
  OnReturn(Context)
end;

// Note: Drago sends a time_left command just before sending the genmove
// command. This is consistent with CGOS and KGS. See:
// http://computer-go.org/pipermail/computer-go/2007-December/012671.html
// http://computer-go.org/pipermail/computer-go/2007-December/012697.html

procedure TGtp.TimeLeft(aOnReturn : TOnReturn;
                        player : string;
                        time, stones : integer);
begin
  OnReturn := AOnReturn;
  if stones < 0
    then stones := 0;
  Send(TimeLeft2, Format('time_left %s %d %d', [player, time, stones]))
end;

procedure TGtp.TimeLeft2;
begin
  OnReturn(Context)
end;

// -- User move followed by engine answer ------------------------------------

procedure TGtp.ClientPlay(aOnReturn : TOnReturn; const player, move : string);
begin
  OnReturn := aOnReturn;
  Send(ClientPlay2, 'play ' + player + ' ' + move)
end;

procedure TGtp.ClientPlay2;
begin
  OnReturn(Context)
end;

// --

procedure TGtp.EnginePlay(aOnReturn : TOnReturn; const player : string);
begin
  OnReturn := aOnReturn;
  //Send(Play3, 'genmove ' + player)
  if player = 'b'
    then LastPlayer := 'w'
    else LastPlayer := 'b';

  Play2
end;

procedure TGtp.EnginePlay2;
begin
  OnReturn(Context)
end;

// --

procedure TGtp.Play(aOnReturn : TOnReturn; const player, move : string);
begin
  OnReturn := aOnReturn;
  LastPlayer := player;
  Send(Play2, 'play ' + player + ' ' + move)
end;

procedure TGtp.Play2;
begin
  if LastPlayer = 'b'
    then Send(Play3, 'genmove w')
    else Send(Play3, 'genmove b')
end;

procedure TGtp.Play3;
var
  i, j, col, status : integer;
begin
  OutputString := Copy(OutputString, 1, Pos(#10, OutputString) - 1);
  i := 0;
  if UpperCase(OutputString) = 'PASS'
    then j := 0 // i = 0, j = 0 : pass
    else
      if UpperCase(OutputString) = 'RESIGN'
        then j := 1 // i = 0, j = 1 : resign
        else kor2ij(OutputString, Boardsize, i, j);

  if LastPlayer = 'b'
    then col := White
    else col := Black;

  LastMove := OutputString;

  if (Context as TView).gb.IsValid(i, j, col, status)
    then Play4
    else
      begin
        OutputString := (*T(*)'Illegal move'(*)*) + ' ' + OutputString;
        StopOnGtpError
      end
end;

procedure TGtp.Play4;
begin
  OutputString := LastMove;
  OnReturn(Context)
end;

// -- First move

procedure TGtp.PlayFirst(aOnReturn : TOnReturn; player : string);
begin
  OnReturn := aOnReturn;
  if player = 'b'
    then LastPlayer := 'w'
    else LastPlayer := 'b';
  Play2
end;

// -- Play several moves in a raw (used for handicap if no other way)

procedure TGtp.SendMoves(ACallBack : TCallBack; const player, coord : string);
begin
  SendMovesCallBack := ACallBack;
  LastPlayer := player;
  ListMoves  := Trim(coord);
  SendMoves2
end;

procedure TGtp.SendMoves2;
var
  move : string;
begin
  if ListMoves = ''
    then SendMovesCallBack
    else
      begin
        move := NthWord(ListMoves, 1);
        ListMoves := Copy(ListMoves, Length(move) + 2, MaxInt);
        Send(SendMoves2, 'play ' + LastPlayer + ' ' + move)
      end
end;

// -- Undo

procedure TGtp.Undo(aOnReturn : TOnReturn);
begin
  OnReturn := aOnReturn;
  Send(Undo2, 'undo')
end;

procedure TGtp.Undo2;
begin
  Send(TerminateCommand, 'undo')
end;

// -- Score counting ---------------------------------------------------------

procedure TGtp.FinalScore(AOnReturn : TOnReturn);
begin
  OnReturn := AOnReturn;
  Send(FinalScore2, 'final_score')
end;

procedure TGtp.FinalScore2;
begin
  GameResult := Copy(OutputString, 1, Pos(#10, OutputString) - 1);
  OnReturn(Context)
end;

// -- Status setting ---------------------------------------------------------

procedure TGtp.FinalStatus(AOnReturn : TOnReturn);
begin
  OnReturn  := AOnReturn;
  DeadList  := '';
  AliveList := '';
  SekiList  := '';
  Send(FinalStatus2, 'final_status_list dead')
end;

procedure TGtp.FinalStatus2;
begin
  DeadList := OutputString;
  OnReturn(Context);
  exit;

  if True
    then FinalStatus3
    else Send(FinalStatus3, 'final_status_list alive') // not used
end;

procedure TGtp.FinalStatus3;
begin
  AliveList := OutputString;
  if True
    then FinalStatus4
    else Send(FinalStatus4, 'final_status_list seki')  // not used
end;

procedure TGtp.FinalStatus4;
begin
  SekiList := OutputString;
  OnReturn(Context)
end;

// -- Launching of a command -------------------------------------------------

procedure TGtp.Command(aOnReturn : TOnReturn; const cmd : string);
begin
  OnReturn := AOnReturn;
  Send(Command2, cmd)
end;

procedure TGtp.Command2;
begin
  OnReturn(Context)
end;

// -- Score estimate ---------------------------------------------------------

procedure TGtp.ScoreEstimate(aOnReturn : TOnReturn; gt : TGameTree = nil);
begin
  OnReturn := AOnReturn;
  if gt = nil
    then ScoreEstimate2
    else LoadSgf(ScoreEstimate2, gt)
end;

procedure TGtp.ScoreEstimate2;
begin
  Send(TerminateCommand, 'estimate_score')
end;

// -- Move suggestion --------------------------------------------------------

procedure TGtp.SuggestMove(aOnReturn : TOnReturn; const player : string; gt : TGameTree = nil);
begin
  OnReturn   := AOnReturn;
  LastPlayer := player;

  if gt = nil
    then SuggestMove2
    else LoadSgf(SuggestMove2, gt)
end;

procedure TGtp.SuggestMove2;
begin
  if LastPlayer = 'b'
    then Send(TerminateCommand, 'reg_genmove b')
    else Send(TerminateCommand, 'reg_genmove w')
end;

// -- Influence regions ------------------------------------------------------

procedure TGtp.InfluenceRegions(aOnReturn : TOnReturn; const player : string; gt : TGameTree = nil);
begin
  OnReturn := AOnReturn;
  LastPlayer := player;

  if gt = nil
    then InfluenceRegions2
    else LoadSgf(InfluenceRegions2, gt)
end;

procedure TGtp.InfluenceRegions2;
begin
  if LastPlayer = 'b'
    then Send(TerminateCommand, 'initial_influence b influence_regions')
    else Send(TerminateCommand, 'initial_influence w influence_regions')
end;

// -- Group status -----------------------------------------------------------

procedure TGtp.GroupStatus(aOnReturn : TOnReturn; const vertex : string; gt : TGameTree = nil);
begin
  OnReturn := AOnReturn;
  FVertex := vertex;

  if gt = nil
    then GroupStatus2
    else LoadSgf(GroupStatus2, gt)
end;

procedure TGtp.GroupStatus2;
begin
  Send(GroupStatus3, 'dragon_stones ' + FVertex)
end;

procedure TGtp.GroupStatus3;
var
  vertex : string;
begin
  // FVertex is the requested intersection
  // OutputString is the dragon
  // save dragon in FVertex, duplicating initial intersection at beginning of string
  vertex := FVertex;
  FVertex := vertex + ' ' + Trim(OutputString);

  // ask for status
  Send(GroupStatus4, 'dragon_status ' + vertex)
end;

procedure TGtp.GroupStatus4;
begin
  OutputString := Trim(OutputString) + ' ' + FVertex;
  OnReturn(Context)
end;

// ---------------------------------------------------------------------------

end.
{$endif}
// ---------------------------------------------------------------------------


