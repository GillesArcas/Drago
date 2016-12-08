// ---------------------------------------------------------------------------
// -- Drago -- Implementation of properties ---------------- Properties.pas --
// ---------------------------------------------------------------------------

unit Properties;

// ---------------------------------------------------------------------------

interface

const
  pr00=00; prAB=01; prAE=02; prAN=03; prAP=04; prAR=05; prAW=06; prB =07;
  prBL=08; prBM=09; prBR=10; prBT=11; prC =12; prCA=13; prCP=14; prCR=15;
  prDD=16; prDM=17; prDO=18; prDT=19; prEV=20; prFF=21; prFG=22; prGB=23;
  prGC=24; prGM=25; prGN=26; prGW=27; prHA=28; prHO=29; prIT=30; prKM=31;
  prKO=32; prL =33; prLB=34; prLN=35; prM =36; prMA=37; prMN=38; prN =39;
  prOB=40; prON=41; prOT=42; prOW=43; prPB=44; prPC=45; prPL=46; prPM=47;
  prPW=48; prRE=49; prRO=50; prRU=51; prSL=52; prSO=53; prSQ=54; prST=55;
  prSZ=56; prTB=57; prTE=58; prTM=59; prTR=60; prTW=61; prUC=62; prUS=63;
  prV =64; prVW=65; prW =66; prWL=67; prWR=68; prWT=69; prWV=70;
  pr_L=71; pr_R=72; pr_W=73;

  prNone = 0;
  prNum  = pr_W;

  SetupProps   = [prAB, prAW, prAE];
  MarkupProps  = [prCR, prLB, prL, prM, prMA, prSQ, prTR];
  RuntimeProps = [pr_L, pr_R, pr_W];

type
  TPropId  = integer;
  TPropIds = set of byte;

function  PropertyIndex(const pn : string) : integer;
function  PropertyId   (const pn : string) : TPropId;
function  PropertyName (pr : TPropId) : string;
function  FindPropText (const pn : string) : string;
function  FindPropIndex(const pn : string) : integer;
procedure FindPropDef  (pr : TPropId; var typ, act : integer;
                        var longName : string;
                        var caption1 : string;
                        var caption2 : string);
function  CanBeCompressed(pr : TPropId)  : boolean;
function  CatenateValues (pr : TPropId)  : boolean;

// ---------------------------------------------------------------------------

implementation

const
  KnownPropertyNumber = prNum + 1;

type
  TProperty = record
    pn : string;
    pr : TPropId;
    at : string;
    ln : string;
    s1 : string;
    s2 : string;
 end;

{
at[1] type   : 0, unknown
               1, Move
               2, Setup
               3, Node annotation
               4, Move annotation
               5, Markup
               6, Root
               7, Game info
               8, Timing
               9, Miscellaneous
               A, Go specific
               B, Deprecated
               C, User defined
               D, Drago runtime
at[2] action : 0, not handled,
               1, handled by routine
               2, handled as annotation in statusbar
at[3] can be compressed to rectangles
}

const KnownPropertyList : array[0 .. KnownPropertyNumber - 1] of TProperty =
(
(pn:''  ;pr:pr00;at:'0100';ln:''              ;s1:''                   ;s2:''),
(pn:'AB';pr:prAB;at:'2111';ln:'AddBlack'      ;s1:''                   ;s2:''),
(pn:'AE';pr:prAE;at:'2111';ln:'AddEmpty'      ;s1:''                   ;s2:''),
(pn:'AN';pr:prAN;at:'7100';ln:'ANnotation'    ;s1:''                   ;s2:''),
(pn:'AP';pr:prAP;at:'6100';ln:'APplication'   ;s1:''                   ;s2:''),
(pn:'AR';pr:prAR;at:'5001';ln:'ARrow'         ;s1:''                   ;s2:''),
(pn:'AW';pr:prAW;at:'2111';ln:'AddWhite'      ;s1:''                   ;s2:''),
(pn:'B' ;pr:prB ;at:'1100';ln:'Black'         ;s1:''                   ;s2:''),
(pn:'BL';pr:prBL;at:'8000';ln:'BlacktimeLeft' ;s1:'Black time left'    ;s2:''),
(pn:'BM';pr:prBM;at:'4200';ln:'BadMove'       ;s1:'Bad'                ;s2:'Very bad'),
(pn:'BR';pr:prBR;at:'7100';ln:'BlackRank'     ;s1:'Black rank'         ;s2:''),
(pn:'BT';pr:prBT;at:'7100';ln:'BlackTeam'     ;s1:'Black team'         ;s2:''),
(pn:'C' ;pr:prC ;at:'3101';ln:'Comment'       ;s1:''                   ;s2:''),
(pn:'CA';pr:prCA;at:'6100';ln:'ChArset'       ;s1:''                   ;s2:''),
(pn:'CP';pr:prCP;at:'7100';ln:'CoPyright'     ;s1:''                   ;s2:''),
(pn:'CR';pr:prCR;at:'5111';ln:'CiRcle'        ;s1:''                   ;s2:''),
(pn:'DD';pr:prDD;at:'5011';ln:''              ;s1:''                   ;s2:''),
(pn:'DM';pr:prDM;at:'3200';ln:''              ;s1:'Balanced position'  ;s2:'Very balanced position'),
(pn:'DO';pr:prDO;at:'4200';ln:'DOubtful'      ;s1:'Doubtful'           ;s2:''),
(pn:'DT';pr:prDT;at:'7100';ln:'DaTe'          ;s1:'Date'               ;s2:''),
(pn:'EV';pr:prEV;at:'7100';ln:'EVent'         ;s1:'Event'              ;s2:''),
(pn:'FF';pr:prFF;at:'6100';ln:'FileFormat'    ;s1:''                   ;s2:''),
(pn:'FG';pr:prFG;at:'9100';ln:'FiGure'        ;s1:'Figure'             ;s2:''),
(pn:'GB';pr:prGB;at:'3200';ln:'GoodforBlack'  ;s1:'Good for Black'     ;s2:'Very good for Black'),
(pn:'GC';pr:prGC;at:'7100';ln:'GameComment'   ;s1:''                   ;s2:''),
(pn:'GM';pr:prGM;at:'6100';ln:'GaMe'          ;s1:''                   ;s2:''),
(pn:'GN';pr:prGN;at:'7100';ln:'GameName'      ;s1:'Game2'              ;s2:''),
(pn:'GW';pr:prGW;at:'3200';ln:'GoodforWhite'  ;s1:'Good for White'     ;s2:'Very good for White'),
(pn:'HA';pr:prHA;at:'A100';ln:'HAndicap'      ;s1:'Handicap'           ;s2:''),
(pn:'HO';pr:prHO;at:'3200';ln:'HotSpot'       ;s1:'Hot spot'           ;s2:'Very hot spot'),
(pn:'IT';pr:prIT;at:'4200';ln:'InTeresting'   ;s1:'Interesting'        ;s2:''),
(pn:'KM';pr:prKM;at:'A100';ln:'KoMi'          ;s1:'Komi'               ;s2:''),
(pn:'KO';pr:prKO;at:'1000';ln:'KO'            ;s1:''                   ;s2:''),
(pn:'L' ;pr:prL ;at:'B111';ln:'Letter'        ;s1:''                   ;s2:''),
(pn:'LB';pr:prLB;at:'5101';ln:'LaBel'         ;s1:''                   ;s2:''),
(pn:'LN';pr:prLN;at:'5001';ln:'Line'          ;s1:''                   ;s2:''),
(pn:'M' ;pr:prM ;at:'B111';ln:'Mark'          ;s1:''                   ;s2:''),
(pn:'MA';pr:prMA;at:'5111';ln:'MArk'          ;s1:''                   ;s2:''),
(pn:'MN';pr:prMN;at:'1100';ln:'MoveNumber'    ;s1:'Move numbers from'  ;s2:''),
(pn:'N' ;pr:prN ;at:'3100';ln:'Nodename'      ;s1:''                   ;s2:''),
(pn:'OB';pr:prOB;at:'8100';ln:'mOveBlackleft' ;s1:''                   ;s2:''),
(pn:'ON';pr:prON;at:'7000';ln:'OpeNing'       ;s1:''                   ;s2:''),
(pn:'OT';pr:prOT;at:'7100';ln:'OverTime'      ;s1:''                   ;s2:''),
(pn:'OW';pr:prOW;at:'8100';ln:'mOveWhiteleft' ;s1:''                   ;s2:''),
(pn:'PB';pr:prPB;at:'7100';ln:'PlayerBlack'   ;s1:'Black player'       ;s2:''),
(pn:'PC';pr:prPC;at:'7100';ln:'PlaCe'         ;s1:'Place'              ;s2:''),
(pn:'PL';pr:prPL;at:'2100';ln:'PLayer'        ;s1:''                   ;s2:''),
(pn:'PM';pr:prPM;at:'9000';ln:'PrintnuMbers'  ;s1:''                   ;s2:''),
(pn:'PW';pr:prPW;at:'7100';ln:'PlayerWhite'   ;s1:'White player'       ;s2:''),
(pn:'RE';pr:prRE;at:'7100';ln:'REsult'        ;s1:'Result'             ;s2:''),
(pn:'RO';pr:prRO;at:'7100';ln:'ROund'         ;s1:'Round'              ;s2:''),
(pn:'RU';pr:prRU;at:'7100';ln:'RUles'         ;s1:'Rules'              ;s2:''),
(pn:'SL';pr:prSL;at:'5011';ln:'SelectedPoint' ;s1:''                   ;s2:''),
(pn:'SO';pr:prSO;at:'7100';ln:'SOurce'        ;s1:''                   ;s2:''),
(pn:'SQ';pr:prSQ;at:'5111';ln:'SQuare'        ;s1:''                   ;s2:''),
(pn:'ST';pr:prST;at:'6000';ln:'STyle'         ;s1:''                   ;s2:''),
(pn:'SZ';pr:prSZ;at:'6100';ln:'SiZe'          ;s1:'Size'               ;s2:''),
(pn:'TB';pr:prTB;at:'A011';ln:'TerritoryBlack';s1:''                   ;s2:''),
(pn:'TE';pr:prTE;at:'4200';ln:'TEsuji'        ;s1:'Tesuji'             ;s2:'Very good tesuji'),
(pn:'TM';pr:prTM;at:'7100';ln:'TiMelimit'     ;s1:''                   ;s2:''),
(pn:'TR';pr:prTR;at:'5111';ln:'TRiangle'      ;s1:''                   ;s2:''),
(pn:'TW';pr:prTW;at:'A011';ln:'TerritoryWhite';s1:''                   ;s2:''),
(pn:'UC';pr:prUC;at:'3200';ln:'UnClear'       ;s1:'Unclear position'   ;s2:'Very unclear position'),
(pn:'US';pr:prUS;at:'7100';ln:'USer'          ;s1:'User'               ;s2:''),
(pn:'V' ;pr:prV ;at:'3000';ln:'nodeValue'     ;s1:''                   ;s2:''),
(pn:'VW';pr:prVW;at:'9011';ln:'VieWpart'      ;s1:''                   ;s2:''),
(pn:'W' ;pr:prW ;at:'1100';ln:'White'         ;s1:''                   ;s2:''),
(pn:'WL';pr:prWL;at:'8000';ln:'WhitetimeLeft' ;s1:'White time left'    ;s2:''),
(pn:'WR';pr:prWR;at:'7100';ln:'WhiteRank'     ;s1:'White rank'         ;s2:''),
(pn:'WT';pr:prWT;at:'7100';ln:'WhiteTeam'     ;s1:'White team'         ;s2:''),
(pn:'WV';pr:prWV;at:'C100';ln:'WrongVariation';s1:'Wrong variation (uliGo)';s2:''),
(pn:'_L';pr:pr_L;at:'D100';ln:'Label'         ;s1:''                   ;s2:''),
(pn:'_R';pr:pr_R;at:'D100';ln:'Result'        ;s1:''                   ;s2:''),
(pn:'_W';pr:pr_W;at:'D100';ln:'Wildcard'      ;s1:''                   ;s2:'')
);

// List of properties

var
  PropertyList : array of TProperty;
  PropertyNumber : integer;

// Initialization of properties (called in initialization section)

procedure InitPropertyList;
var
  i : integer;
begin
  SetLength(PropertyList, 100);
  PropertyNumber := KnownPropertyNumber;

  for i := 0 to KnownPropertyNumber - 1 do
    begin
      PropertyList[i] := KnownPropertyList[i];

      // make sure the list is sorted in same order as constants
      Assert(PropertyList[i].pr = i)
    end
end;

// Addition of an unknown property
//
// After known properties, properties are stored with no particular order

function NewProperty(const pname : string) : integer;
begin
  if Length(PropertyList) = PropertyNumber
    then SetLength(PropertyList, PropertyNumber + 1);

  inc(PropertyNumber);

  with PropertyList[PropertyNumber - 1] do
    begin
      pn := pname;
      pr := PropertyNumber - 1;
      at := '000';
      ln := '';
      s1 := '';
      s2 := ''
    end;

  Result := PropertyNumber - 1
end;

// Search for property name in list of known properties

function FindPropIndex(const pn : string) : integer;
var
  iMin, iMax : integer;
begin
  // first guess
  Result := prB; if pn = 'B' then exit;
  Result := prW; if pn = 'W' then exit;

  // dichotomy search
  iMin   := 1;
  iMax   := KnownPropertyNumber - 1;
  Result := KnownPropertyNumber div 2;
  repeat
    if pn = PropertyList[Result].Pn
      then exit;
    if pn < PropertyList[Result].Pn
      then iMax := Result
      else iMin := Result;
    Result := (iMin + iMax) div 2
  until iMin = Result;

  if pn = PropertyList[Result].Pn
    then // ok
    else Result := prNone
end;

// Search for a property in whole list of properties

function PropertyId(const pn : string) : TPropId;
begin
  REsult := PropertyIndex(pn)
end;

function PropertyIndex(const pn : string) : integer;
var
  i : integer;
begin
  Result := FindPropIndex(pn);
  if Result > 0
    then exit;

  for i := KnownPropertyNumber to PropertyNumber - 1 do
    if pn = PropertyList[i].Pn then
      begin
        Result := i;
        exit
      end;

  Result := NewProperty(pn)
end;

// Access to property name

function PropertyName(pr : TPropId) : string;
begin
  Result := PropertyList[pr].Pn
end;

// Access to property attributes

procedure FindPropDef(pr : TPropId;
                      var typ, act : integer;
                      var longName : string;
                      var caption1 : string;
                      var caption2 : string);
begin
  if pr = prNone
    then typ := 0
    else
      with PropertyList[pr] do
        begin
          typ      := ord(at[1]) - ord('0');
          act      := ord(at[2]) - ord('0');
          longName := ln;
          caption1 := s1;
          caption2 := s2
        end
end;

function FindPropText(const pn : string) : string;
begin
  Result := PropertyList[FindPropIndex(pn)].s1
end;

function CanBeCompressed(pr : TPropId) : boolean;
begin
  Result := PropertyList[pr].at[3] = '1'
end;

function CatenateValues (pr : TPropId)  : boolean;
begin
  Result := PropertyList[pr].at[4] = '1'
end;

// ---------------------------------------------------------------------------

begin
  InitPropertyList
end.
