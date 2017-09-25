// ---------------------------------------------------------------------------
// -- Drago -- Board related utilities --------------------- BoardUtils.pas --
// ---------------------------------------------------------------------------

unit BoardUtils;

// Coordinate transforms
// Color transforms
// Handicap and hoshi coordinates

// ---------------------------------------------------------------------------

interface

uses
  Define;

procedure Transform(i, j, dim : integer;
                    transf : TCoordTrans;
                    var p, q : integer); overload;
procedure Transform(i, j, dimI, dimJ : integer;
                    transf : TCoordTrans;
                    var p, q : integer); overload;
function  TransformToFirstOctant(i, j, dim : integer) : TCoordTrans; overload;
function  Compose(tr1, tr2 : TCoordTrans) : TCoordTrans; // tr1 then tr2
function  Inverse(trans : TCoordTrans) : TCoordTrans;
function  RandomTrans : TCoordTrans;
function  ColorTransform(color : integer; tr : TColorTrans) : integer;
function  MarkupColorTransform(markup : integer; tr : TColorTrans) : integer;
function  MaxHandicap(boardsize : integer) : integer;
function  HandicapStones(boardsize, handicap : integer) : string;
function  IsHoshi(i, j, size : integer) : boolean;
function  xcoordinate(j, boardSize : integer; coordStyle : integer) : string; overload;
function  ycoordinate(i, boardSize : integer; coordStyle : integer) : string; overload;
function  xcoordinate(j, boardSize : integer; coordStyle : integer; coordTrans : TCoordTrans) : string; overload;
function  ycoordinate(i, boardSize : integer; coordStyle : integer; coordTrans : TCoordTrans) : string; overload;

type
  TPairStack = class
  private
  public
    Stack : array of array[0 .. 1] of integer;
    constructor Create;
    destructor  Destroy; override;
    procedure Assign(x : TPairStack);
    procedure Leave(n : integer);
    procedure Push(i : integer; j : integer = 0);
    function  Pop : integer; overload;
    procedure Pop(out i, j : integer); overload;
    function  Peek : integer; overload;
    procedure Peek(out i, j : integer); overload;
    function  AtLeast(n : integer) : boolean;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils, Math,
  Ux2y;

// -- Handling of coordinate transformations ---------------------------------
//
// -- Constants are declared in Define.pas

procedure Transform(i, j, dim : integer;
                    transf : TCoordTrans;
                    var p, q : integer);
begin
  case transf of
    trIdent :   // identity
      begin
        p := i;
        q := j
      end;
    trRot90 :   // clockwise rotation
      begin
        p := j;
        q := dim - i + 1
      end;
    trRot180 :  // rotation 180
      begin
        p := dim - i + 1;
        q := dim - j + 1
      end;
    trRot270 :  // counter clockwise rotation
      begin
        p := dim - j + 1;
        q := i
      end;
    trSymD :    // main diagonal symmetry
      begin
        p := j;
        q := i
      end;
    trSymD90,   // SymD then clockwise rotation
    trSymV :    // vertical symmetry
      begin
        p := i;
        q := dim - j + 1
      end;
    trSymD180,  // SymD then rotation 180
    trSymD2 :   // second diagonal symmetry
      begin
        p := dim - j + 1;
        q := dim - i + 1
      end;
    trSymD270, // SymD then counter clockwise rotation
    trSymH :   // horizontal symmetry
      begin
        p := dim - i + 1;
        q := j
      end;
    end
end;

procedure Transform(i, j, dimI, dimJ : integer;
                    transf : TCoordTrans;
                    var p, q : integer);
begin
  case transf of
    trIdent :   // identity
      begin
        p := i;
        q := j
      end;
    trRot90 :   // clockwise rotation
      begin
        p := j;
        q := dimI - i + 1
      end;
    trRot180 :  // rotation 180
      begin
        p := dimI - i + 1;
        q := dimJ - j + 1
      end;
    trRot270 :  // counter clockwise rotation
      begin
        p := dimJ - j + 1;
        q := i
      end;
    trSymD :    // main diagonal symmetry
      begin
        p := j;
        q := i
      end;
    trSymD90,   // SymD then clockwise rotation
    trSymV :    // vertical symmetry
      begin
        p := i;
        q := dimJ - j + 1
      end;
    trSymD180,  // SymD then rotation 180
    trSymD2 :   // second diagonal symmetry
      begin
        p := dimJ - j + 1;
        q := dimI - i + 1
      end;
    trSymD270, // SymD then counter clockwise rotation
    trSymH :   // horizontal symmetry
      begin
        p := dimI - i + 1;
        q := j
      end;
    end
end;

function WhichTransform(i, j, dim, p, q : integer) : TCoordTrans;
var
  t : TCoordTrans;
  i2, j2 : integer;
begin
  for t := trIdent to trSymD270 do
    begin
      Result := t;
      Transform(i, j, dim, t, i2, j2);
      if (i2 = p) and (j2 = q)
        then exit
    end;
  raise Exception.Create('Undefined transform')
end;

// Detection of the transformation into first octant (standard start) for a move

function TransformToFirstOctant(i, j, dim : integer) : TCoordTrans;
var
  t : TCoordTrans;
  i2, j2 : integer;
begin
  for t := trIdent to trSymD270 do
    begin
      Result := t;
      Transform(i, j, dim, t, i2, j2);
      if (i2 <= dim div 2 + 1) and (i2 + j2 > dim)
        then exit
    end;
  raise Exception.Create('Undefined transform')
end;

function Inverse(trans : TCoordTrans) : TCoordTrans;
begin
  case trans of
    trRot90  : result := trRot270;
    trRot270 : result := trRot90
    else       result := trans
  end
end;

// ComposeCoordTrans[t1, t2] = t1 then t2
const
  ComposeCoordTrans  : array[trIdent .. trSymD270, trIdent .. trSymD270] of TCoordTrans = (
  (trIdent  , trRot90  , trRot180 , trRot270 , trSymD   , trSymD90 , trSymD180, trSymD270),
  (trRot90  , trRot180 , trRot270 , trIdent  , trSymD270, trSymD   , trSymD90 , trSymD180),
  (trRot180 , trRot270 , trIdent  , trRot90  , trSymD180, trSymD270, trSymD   , trSymD90 ),
  (trRot270 , trIdent  , trRot90  , trRot180 , trSymD90 , trSymD180, trSymD270, trSymD   ),
  (trSymD   , trSymD90 , trSymD180, trSymD270, trIdent  , trRot90  , trRot180 , trRot270 ),
  (trSymD90 , trSymD180, trSymD270, trSymD   , trRot270 , trIdent  , trRot90  , trRot180 ),
  (trSymD180, trSymD270, trSymD   , trSymD90 , trRot180 , trRot270 , trIdent  , trRot90  ),
  (trSymD270, trSymD   , trSymD90 , trSymD180, trRot90  , trRot180 , trRot270 , trIdent  ));

// used only to calculate const array
function ComposeV1(tr1, tr2 : TCoordTrans) : TCoordTrans; // tr1 then tr2
var
  p1, q1, p2, q2 : integer;
begin
  Transform(4 , 17, 19, tr1, p1, q1);
  Transform(p1, q1, 19, tr2, p2, q2);
  Result := WhichTransform(4, 17, 19, p2, q2)
end;

function Compose(tr1, tr2 : TCoordTrans) : TCoordTrans; // tr1 then tr2
begin
  assert(tr1 in [trIdent .. trSymD270]);
  assert(tr2 in [trIdent .. trSymD270]);
  Result := ComposeCoordTrans[tr1, tr2]
end;

function RandomTrans : TCoordTrans;
begin
  result := TCoordTrans(random(8))
end;

// -- Handling of color transformations --------------------------------------

function ColorTransform(color : integer; tr : TColorTrans) : integer;
begin
  if tr = ctIdent
    then Result := color
    else
      case color of
        Black : Result := White;
        White : Result := Black;
        else    Result := color
      end
end;

function MarkupColorTransform(markup : integer; tr : TColorTrans) : integer;
begin
  if tr = ctIdent
    then Result := markup
    else
      case markup of
        mrkTB : Result := mrkTW;
        mrkTW : Result := mrkTB;
        else    Result := markup
      end
end;

// -- Definition of handicap stones ------------------------------------------

const
  haStones : array[1 .. 19] of string =
  ('',                                      //  1
   '',                                      //  2
   '',                                      //  3
   '',                                      //  4
   '',                                      //  5
   '',                                      //  6
   '[ce][ec][cc][ee]',                      //  7
   '[cf][fc][cc][ff]',                      //  8
   '[cg][gc][cc][gg][ce][ge][ec][eg][ee]',  //  9
   '[ch][hc][cc][hh]',                      // 10
   '[ci][ic][cc][ii][cf][if][fc][fi][ff]',  // 11
   '[cj][jc][cc][jj]',                      // 12
   '[dj][jd][dd][jj][dg][jg][gd][gj][gg]',  // 13
   '[dk][kd][dd][kk]',                      // 14
   '[dl][ld][dd][ll][dh][lh][hl][hd][hh]',  // 15
   '[dm][md][dd][mm]',                      // 16
   '[dn][nd][dd][nn][di][ni][in][id][ii]',  // 17
   '[do][od][dd][oo]',                      // 18
   '[dp][pd][dd][pp][dj][pj][jp][jd][jj]'); // 19

  haStones_v2 : array[1 .. 19] of string =
  ('',                                      //  1
   '',                                      //  2
   '',                                      //  3
   '',                                      //  4
   '',                                      //  5
   '',                                      //  6
   '[ce][ec][ee][cc]',                      //  7
   '[cf][fc][ff][cc]',                      //  8
   '[cg][gc][gg][cc][ce][ge][ec][eg][ee]',  //  9
   '[ch][hc][hh][cc]',                      // 10
   '[ci][ic][ii][cc][cf][if][fc][fi][ff]',  // 11
   '[cj][jc][jj][cc]',                      // 12
   '[dj][jd][jj][dd][dg][jg][gd][gj][gg]',  // 13
   '[dk][kd][kk][dd]',                      // 14
   '[dl][ld][ll][dd][dh][lh][hl][hd][hh]',  // 15
   '[dm][md][mm][dd]',                      // 16
   '[dn][nd][nn][dd][di][ni][in][id][ii]',  // 17
   '[do][od][oo][dd]',                      // 18
   '[dp][pd][pp][dd][dj][pj][jp][jd][jj]'); // 19

function MaxHandicap(boardsize : integer) : integer;
begin
  Result := Length(haStones[boardsize]) div 4
end;

function HandicapStones(boardsize, handicap : integer) : string;
var
  s : string;
begin
  Result := '';
  if handicap < 2
    then exit
    else handicap := Min(handicap, MaxHandicap(boardsize));

  s := haStones[boardsize];
  if handicap in [2, 3, 4, 6, 8, 9]
    then Result := Copy(s, 1, handicap * 4)
    else Result := Copy(s, 1, handicap * 4 - 4) + Copy(s, 33, 4);
end;

function IsHoshi(i, j, size : integer) : boolean;
var
  h, x : string;
begin
  h := HandicapStones(size, MaxHandicap(size));
  x := ij2pv(i, j);
  Result := Pos(x, h) > 0
end;

// -- Coordinates ------------------------------------------------------------

function xcoordinate(j, boardsize : integer; coordStyle : integer) : string;
begin
  case CoordStyle of
    0 : Result := '  ';
    1 : Result := absKorsh[j];
    2 : Result := coordSgf[j];
    3 : Result := IntToStr(j)
  end
end;

function ycoordinate(i, boardsize : integer; coordStyle : integer) : string;
begin
  case coordStyle of
    0 : Result := '  ';
    1 : Result := IntToStr(boardsize + 1 - i);
    2 : Result := coordSgf[i];
    3 : Result := IntToStr(i)
  end
end;

// Coordinates taking orientation into account

function xcoordinate(j, boardSize : integer; coordStyle : integer; coordTrans : TCoordTrans) : string;
begin
  case coordTrans of
    trIdent, trSymD270, trSymH :
      Result := xcoordinate(j, boardsize, coordStyle);
    trRot90, trSymD180, trSymD2 :
      Result := ycoordinate(boardsize + 1 - j, boardsize, coordStyle);
    trRot180, trSymD90, trSymV :
      Result := xcoordinate(boardsize + 1 - j, boardsize, coordStyle);
    trRot270, trSymD :
      Result := ycoordinate(j, boardsize, coordStyle)
  end
end;

function ycoordinate(i, boardSize : integer; coordStyle : integer; coordTrans : TCoordTrans) : string;
begin
  case coordTrans of
    trIdent, trSymD90, trSymV :
      Result := ycoordinate(i, boardsize, coordStyle);
    trRot90, trSymD :
      Result := xcoordinate(i, boardsize, coordStyle);
    trRot180, trSymD270, trSymH :
      Result := ycoordinate(boardsize + 1 - i, boardsize, coordStyle);
    trRot270, trSymD180, trSymD2 :
      Result := xcoordinate(boardsize + 1 - i, boardsize, coordStyle)
  end
end;

// ---------------------------------------------------------------------------
// -- Handling of goban stacks -----------------------------------------------
// ---------------------------------------------------------------------------

constructor TPairStack.Create;
begin
  SetLength(Stack, 0)
end;

destructor TPairStack.Destroy;
begin
  SetLength(Stack, 0)
end;

procedure TPairStack.Assign(x : TPairStack);
var
  i : integer;
begin
  SetLength(Stack, Length(x.Stack));
  for i := 0 to High(Stack) do
    Stack[i] := x.Stack[i]
end;

procedure TPairStack.Leave(n : integer);
begin
  while AtLeast(n + 1) do Pop
end;

procedure TPairStack.Push(i : integer; j : integer = 0);
var
  n : integer;
begin
  n := Length(Stack);
  SetLength(Stack, n + 1);
  Stack[n, 0] := i;
  Stack[n, 1] := j
end;

function TPairStack.Pop : integer;
var
  i, j : integer;
begin
  Pop(i, j);
  Result := i
end;

procedure TPairStack.Pop(out i, j : integer);
var
  n : integer;
begin
  n := Length(Stack);
  i := Stack[n - 1, 0];
  j := Stack[n - 1, 1];
  if n > 0
    then SetLength(Stack, n - 1)
end;

function TPairStack.Peek : integer;
var
  i, j : integer;
begin
  Peek(i, j);
  Result := i
end;

procedure TPairStack.Peek(out i, j : integer);
var
  n : integer;
begin
  n := Length(Stack);

  if n <= 0 then
    begin
      i := 0;
      j := 0;
      Assert(False)
    end;

  i := Stack[n - 1, 0];
  j := Stack[n - 1, 1]
end;

function TPairStack.AtLeast(n : integer) : boolean;
begin
  Result := Length(Stack) >= n
end;

// ---------------------------------------------------------------------------

end.
