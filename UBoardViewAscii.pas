// ---------------------------------------------------------------------------
// -- Drago -- Board view for ASCII exporting --------- UBoardViewAscii.pas --
// ---------------------------------------------------------------------------

unit UBoardViewAscii;

// ---------------------------------------------------------------------------

interface

uses
  Classes,
  Define, DefineUi, UBoardView;

type
  TBoardViewAscii = class(TBoardView)

  public
    TextCanvas : TStringList;

    class function Create(mode : TExportFigure) : TBoardViewAscii; overload;
    constructor Create; overload; override;
    destructor  Destroy; override;

    procedure SetDim(aWidth, aHeight : integer; maxDiam : integer = 61); override;
    procedure BoardSettings(aShowHoshis   : boolean;
                            aCoordStyle   : integer;
                            aShowNumber   : integer;
                            aCoordTrans   : TCoordTrans;
                            drawEdge : boolean;
                            blackChar, whiteChar, hoshiChar : char);

    procedure DrawEmpty; override;
  private
    FDrawEdge  : boolean;
    FHoshiChar : char;
    FBlackChar : char;
    FWhiteChar : char;
    iOffset : integer;
    jOffset : integer;
    sPrefix : string;
    wInter  : integer;
    minNumber : integer;
    procedure HCoordToAscii(drawEdge, drawCoord : boolean);
    procedure HBorderToAscii(drawEdge, drawCoord : boolean);
    function  StoneToAscii(i, j : integer;
                           drawElems : TDrawElems;
                           chrNo, chrCR, chrSQ : char) : char;
    function  GetComCanvas : TStringList; override;
    procedure InitDrawing(var drawEdge, drawCoord : boolean); virtual; abstract;
    function  EmptyToAscii(i, j : integer) : string; virtual; abstract;
    function  InterToAscii(i, j : integer; drawElems : TDrawElems) : string; virtual; abstract;
  end;

type
  TBoardViewSL = class(TBoardViewAscii)
    procedure InitDrawing(var drawEdge, drawCoord : boolean); override;
    procedure DrawVertex(i, j : integer; drawElems : TDrawElems); override;
    function  EmptyToAscii(i, j : integer) : string; override;
    function  InterToAscii(i, j : integer; drawElems : TDrawElems) : string; override;
  end;

type
  TBoardViewRGG = class(TBoardViewAscii)
    procedure InitDrawing(var drawEdge, drawCoord : boolean); override;
    procedure DrawVertex(i, j : integer; drawElems : TDrawElems); override;
    function  EmptyToAscii(i, j : integer) : string; override;
    function  InterToAscii(i, j : integer; drawElems : TDrawElems) : string; override;
  end;

type
  TBoardViewTRC = class(TBoardViewAscii)
    procedure InitDrawing(var drawEdge, drawCoord : boolean); override;
    procedure DrawVertex(i, j : integer; drawElems : TDrawElems); override;
    function  EmptyToAscii(i, j : integer) : string; override;
    function  StoneToAscii(i, j, color : integer) : string;
    function  InterToAscii(i, j : integer; drawElems : TDrawElems) : string; override;
    function  NumberToAscii(number : integer) : string;
    procedure DrawText(i, j, inter, mrk2 : integer;
                       const s : string;
                       sizeText : TSizeText;
                       txtColor : integer = 0); override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, StrUtils, Math,
  BoardUtils;

// -- Constructors -----------------------------------------------------------

class function TBoardViewAscii.Create(mode : TExportFigure) : TBoardViewAscii;
begin
  case mode of
    eiRGG : Result := TBoardViewRGG.Create; 
    eiSSL : Result := TBoardViewSL.Create;
    eiTRC : Result := TBoardViewTRC.Create;
  else
    Result := nil
  end
end;

constructor TBoardViewAscii.Create;
begin
  inherited Create
end;

// -- Destructor -------------------------------------------------------------

destructor TBoardViewAscii.Destroy;
begin
  inherited Destroy
end;

// -- Accessors --------------------------------------------------------------

function TBoardViewAscii.GetComCanvas : TStringList;
begin
  Result := TextCanvas
end;

procedure TBoardViewAscii.SetDim(aWidth, aHeight : integer; maxDiam : integer = 61);
begin
end;

// -- Settings ---------------------------------------------------------------

procedure TBoardViewAscii.BoardSettings(aShowHoshis   : boolean;
                                        aCoordStyle   : integer;
                                        aShowNumber   : integer;
                                        aCoordTrans   : TCoordTrans;
                                        drawEdge      : boolean;
                                        blackChar, whiteChar, hoshiChar : char);
begin
  inherited BoardSettings(aShowHoshis, aCoordStyle, aShowNumber, aCoordTrans);

  FDrawEdge  := drawEdge;
  FBlackChar := blackChar;
  FWhiteChar := whiteChar;
  FHoshiChar := hoshiChar
end;

// -- Display of board -------------------------------------------------------

// -- Drawing of horizontal coordinates

procedure TBoardViewAscii.HCoordToAscii(drawEdge, drawCoord : boolean);
var
  j : integer;
  c, s : string;
begin
  if drawCoord then
    begin
      s := sPrefix;

      if jMin > 1
        then s := ''
        else
          if drawEdge
            then s := '    '
            else s := '   ';

      for j := jMin to jMax do
        begin
          c := xcoordinate(j, BoardSize, CoordStyle, CoordTrans);
          s := s + Format('%-*s', [wInter, c])
        end;

      TextCanvas.Add(s)
    end
end;

// -- Drawing of horizontal border

procedure TBoardViewAscii.HBorderToAscii(drawEdge, drawCoord : boolean);
var
  j : integer;
  s : string;
begin
  if drawEdge then
    begin
      s := sPrefix;

      if jMin = 1 then
        if drawCoord
          then s := s + '  +-'
          else s := s + '+-';

      for j := jMin to jMax do
        s := s + DupeString('-', wInter);

      if jMax = BoardSize
        then s := s + '+';

      TextCanvas.Add(s)
    end;
end;

procedure TBoardViewAscii.DrawEmpty;
var
  drawEdge, drawCoord : boolean;
  i, j : integer;
  c, s : string;
begin
  TextCanvas.Clear;
  InitDrawing(drawEdge, drawCoord);

  if iMin = 1
    then HCoordToAscii (drawEdge, drawCoord);
  if iMin = 1
    then HBorderToAscii(drawEdge, drawCoord);

  iOffset := TextCanvas.Count;

  for i := iMin to iMax do
    begin
      s := sPrefix;

      if jMin = 1 then
        begin
          if drawCoord then
            begin
              c := ycoordinate(i, BoardSize, CoordStyle, CoordTrans);
              s := s + Format('%2s', [c]);
            end;
          if drawEdge
            then s := s + '| '
            else s := s + ' '
        end;

      jOffset := Length(s) + 1;

      for j := jMin to jMax do
        s := s + EmptyToAscii(i, j) + ' ';

      if jMax = BoardSize then
        begin
          if drawEdge
            then s := s + '|';
          if drawCoord then
            begin
              c := ycoordinate(i, BoardSize, CoordStyle, CoordTrans);
              s := s + Format('%-2s', [c]);
            end
        end;

      TextCanvas.Add(s)
    end;

  if iMax = BoardSize
    then HBorderToAscii(drawEdge, drawCoord);
  if iMax = BoardSize
    then HCoordToAscii (drawEdge, drawCoord)
end;

// -- Display of intersection ------------------------------------------------

// -- Digit conversion (RGG and SL)

function NumberToAscii(n : integer; default : char) : char;
var
  digits : string;
begin
  digits := '1234567890';

  if not InRange(n, 1, 10)
    then Result := default
    else Result := digits[n]
end;

// -- Conversion of (i,j) intersection with stone (RGG and SL)

function TBoardViewAscii.StoneToAscii(i, j : integer;
                                      drawElems : TDrawElems;
                                      chrNo, chrCR, chrSQ : char) : char;
var
  n : integer;
begin
  case drawElems.MainMark of
    mrkCR : Result := chrCR;
    mrkSQ : Result := chrSQ
  else
    if drawElems.MainText = ''
      then Result := NumberToAscii(drawElems.MoveNumber, chrNo)
      else
        begin
          // try to display text mark as a possible move number string
          n := StrToIntDef(drawElems.MainText, 0);
          Result := NumberToAscii(n, chrNo)
        end
  end
end;

// == Customization for each exporting mode ==================================

// -- SL style ---------------------------------------------------------------

procedure TBoardViewSL.InitDrawing(var drawEdge, drawCoord : boolean);
begin
  drawEdge  := True;
  drawCoord := False;
  sPrefix   := '$$ ';
  wInter    := 2;
  minNumber := MaxInt;

  // add prefix for coordinates and color parity. Color parity can be changed
  // in DrawVertex
  TextCanvas.Add(IfThen(CoordStyle = tcNone, '$$B', '$$Bc'));
end;

procedure TBoardViewSL.DrawVertex(i, j : integer; drawElems : TDrawElems);
var
  s : string;
begin
  if (drawElems.Stone = White) and Odd(drawElems.MoveNumber) then
    begin
      s := TextCanvas[0];
      s[3] := 'W';
      TextCanvas[0] := s
    end;
  if drawElems.MoveNumber > 0
    then minNumber := Min(minNumber, drawElems.MoveNumber);

  s := TextCanvas[iOffset + i - iMin];
  s[jOffset + 2 * (j - jMin)] := InterToAscii(i, j, drawElems)[1];
  TextCanvas[iOffset + i - iMin] := s
end;

function TBoardViewSL.EmptyToAscii(i, j : integer) : string;
begin
  if IsHoshi(i, j, BoardSize)
    then Result := ','
    else Result := '.'
end;

function TBoardViewSL.InterToAscii(i, j : integer; drawElems : TDrawElems) : string;
begin
  case drawElems.Stone of
    Empty :
      case drawElems.MainMark of
      (* ICI
        mrkNO :
          if drawElems.MainText = ''
            then Result := EmptyToAscii(i, j)
            else Result := LowerCase(drawElems.MainText)[1]; // diff avec exportpos
        *)
        mrkNO : Result := EmptyToAscii(i, j);
        mrkTXT : Result := LowerCase(drawElems.MainText)[1]; // diff avec exportpos
        mrkCR : Result := 'C';
        mrkSQ : Result := 'S'
      else
        Result := EmptyToAscii(i, j)
      end;
    Black : Result := StoneToAscii(i, j, drawElems, 'X', 'B', '#');
    White : Result := StoneToAscii(i, j, drawElems, 'O', 'W', '@')
  end
end;

// -- RGG style --------------------------------------------------------------

procedure TBoardViewRGG.InitDrawing(var drawEdge, drawCoord : boolean);
begin
  drawEdge  := FDrawEdge;
  drawCoord := CoordStyle <> tcNone;
  sPrefix   := '';
  wInter    := 2
end;

procedure TBoardViewRGG.DrawVertex(i, j : integer; drawElems : TDrawElems);
var
  s : string;
begin
  s := TextCanvas[iOffset + i - iMin];
  s[jOffset + 2 * (j - jMin)] := InterToAscii(i, j, drawElems)[1];
  TextCanvas[iOffset + i - iMin] := s
end;

function TBoardViewRGG.EmptyToAscii(i, j : integer) : string;
begin
  if IsHoshi(i, j, BoardSize)
    then Result := FHoshiChar
    else Result := '.'
end;

function TBoardViewRGG.InterToAscii(i, j : integer; drawElems : TDrawElems) : string;
var
  c : char;
begin
  c := FBlackChar;

  case drawElems.Stone of
    Empty : Result := EmptyToAscii(i, j);
    Black : Result := StoneToAscii(i, j, drawElems,  c ,  c ,  c );
    White : Result := StoneToAscii(i, j, drawElems, 'O', 'O', 'O');
  end
end;

// -- ASCII tracing style ----------------------------------------------------

procedure TBoardViewTRC.InitDrawing(var drawEdge, drawCoord : boolean);
begin
  drawEdge  := FDrawEdge;
  drawCoord := CoordStyle <> tcNone;
  sPrefix := '';
  wInter  := 5
end;

procedure TBoardViewTRC.DrawVertex(i, j : integer; drawElems : TDrawElems);
var
  s : string;
begin
  s := TextCanvas[iOffset + i - iMin];
  s := StuffString(s, jOffset + 5 * (j - jMin), 4, InterToAscii(i, j, drawElems));
  TextCanvas[iOffset + i - iMin] := s
end;

function TBoardViewTRC.InterToAscii(i, j : integer; drawElems : TDrawElems) : string;
begin
  Result := StoneToAscii(i, j, drawElems.Stone);

  case drawElems.MainMark of
(* ICI
    mrkNO :
      if drawElems.MainText = ''
        then
          if drawElems.MoveNumber > 0
            then Result := Result[1] + NumberToAscii(i, j, drawElems.MoveNumber)
            else
              if drawElems.AuxMark = mrkCur
                then Result := Result[1] + '<--'
                else // nop
        else
          Result := Result[1] + Copy(drawElems.MainText + '..', 1, 3);
*)
    mrkNO :
      if drawElems.MoveNumber > 0
        then Result := Result[1] + NumberToAscii(drawElems.MoveNumber)
        else
          if drawElems.AuxMark = mrkCur
            then Result := Result[1] + '<--'
            else; // nop
    mrkTXT : Result := Result[1] + Copy(drawElems.MainText + '..', 1, 3);
    mrkCR : Result := Result[1] + 'CR.';
    mrkSQ : Result := Result[1] + 'SQ.';
    mrkTR : Result := Result[1] + 'TR.'
  else
    // nop
  end;
end;

function TBoardViewTRC.EmptyToAscii(i, j : integer) : string;
begin
  if IsHoshi(i, j, BoardSize)
    then Result := '+...'
    else Result := '....'
end;

function TBoardViewTRC. StoneToAscii(i, j, color : integer) : string;
begin
  case color of
    Empty : Result := EmptyToAscii(i, j);
    Black : Result := 'B...';
    White : Result := 'W...'
  end
end;

function TBoardViewTRC.NumberToAscii(number : integer) : string;
begin
  Result := Format('%d', [number mod 1000]);
  Result := Result + DupeString('.', 3 - Length(Result))
end;

procedure TBoardViewTRC.DrawText(i, j, inter, mrk2 : integer;
                                 const s : string;
                                 sizeText : TSizeText;
                                 txtColor : integer = 0);
var
  line, x : string;
begin
  line := TextCanvas[iOffset + i - iMin];
  x := Copy(line, jOffset + 5 * (j - jMin), 4);

  x[4] := s[1];

  line := StuffString(line, jOffset + 5 * (j - jMin), 4, x);
  TextCanvas[iOffset + i - iMin] := line
end;

// ---------------------------------------------------------------------------

end.

