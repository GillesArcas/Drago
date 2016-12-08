unit Define;

interface

const

// Intersections

  Empty = 0;
  Black = 1;
  White = 2;

// Go board markups

  mrkNO    =    0;    // No markup                 
  mrkMA    =    1;
  mrkTR    =    2;    // Triangle
  mrkM     =    3;
  mrkCR    =    4;    // Circle
  mrkSQ    =    5;    // Square
  mrkLB    =    6;    // not used
  mrkL     =    7;    // not used
  mrkTB    =    8;    // Black territory
  mrkTW    =    9;    // White territory           
  mrkTXT   =   10;    // Text
  mrkCUR   =   11;    // LastMove mark             
  mrkPHB   =  101;    // Black ghost
  mrkPHW   =  102;    // White ghost               
  mrkGH    =  103;    // Good hint mark
  mrkBH    =  104;    // Bad hint mark
  mrkSG    =  105;    // Signature mark
  mrkCS    =  106;    // Critical life status
  mrkWC    = 1000;    // Wild card

  mrkPHv   : array[Black .. White] of integer = (mrkPHB, mrkPHW);

// Goban errors

  CgbOk        = 0;
  CgbPass      = 1;
  CgbUnfree    = 2;
  CgbKo        = 3;
  CgbSuicide   = 4;
  CgbNoUndo    = 5;

  CgbErrorMsg  : array[CgbOk .. CgbNoUndo] of string = (
    '',
    '',
    'Impossible to play there',
    'Illegal ko capture',
    'Illegal suicide...',
    '');

// Style of coordinates

  tcNone   =  0;
  tcKorsch =  1;
  tcSGF    =  2;

// Styles for go board background display

  agColorDefault   = 0;
  agColorCustom    = 1;
  agTextureDefault = 2;
  agTextureCustom  = 3;

// Styles for stone display (ds : display stone)

  dsDrawing        = 0;
  dsJago           = 1;
  dsDefault        = 2;
  dsCustom         = 3;

type

// Show move modes

  TShowMoveMode = (smNoMark, smNumber, smMark, smAll, smBook, smNumberN);

// Coordinates and color transforms

  TCoordTrans = (trIdent, trRot90, trRot180, trRot270,
                 trSymD , trSymD90, trSymD180, trSymD270,
                 trSymH , trSymV, trSymD2);

  TColorTrans = (ctIdent, ctReverse);

// Origin of lighting

  TLightSource = (lsTopLeft, lsTopRight, lsNone);

// StartNode modes

  TStartNode = (snStrict, snExtend, snHit);

//

function ReverseColor(color : integer) : integer;

implementation

function ReverseColor(color : integer) : integer;
begin
  case color of
    Black : Result := White;
    White : Result := Black;
  else
    Result := color
  end
end;

end.
 