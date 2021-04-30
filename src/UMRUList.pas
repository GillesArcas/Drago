// ---------------------------------------------------------------------------
// -- Drago -- Most Recent Used list handling ---------------- UMRUList.pas --
// ---------------------------------------------------------------------------

unit UMRUList;

// ---------------------------------------------------------------------------

interface

uses
  Classes, TntIniFiles, SysUtils,
  Define;

type
  TMRUItem = class
    Folder : WideString;
    Name   : WideString;
    Index  : integer;
    Path   : WideString;
    Trans  : TCoordTrans;
    constructor Create(const aFolder, aName : WideString;
                       aIndex : integer;
                       const aPath  : WideString;
                       aTrans : TCoordTrans = trIdent);
  end;

  TMRUList = class
    FMaxCount : integer;
    Items : TList;
    CompareNames     : boolean;
    DistinguishIndex : boolean;
    DistinguishPath  : boolean;

    constructor Create;
    destructor  Destroy; override;
    procedure SetMaxCount(n : integer);
    function  Count : integer;
    function  IndexOf(const aFolder, aName : WideString;
                      aIndex : integer;
                      const aPath : WideString) : integer;
    procedure Clear;
    procedure Add(const aFolder, aName : WideString;
                  aIndex : integer;
                  const aPath  : WideString;
                  aTrans : TCoordTrans = trIdent);
    procedure Get(n : integer;
                  out aFolder, aName : WideString;
                  out aIndex : integer;
                  out aPath, aText : WideString);
    function  GetItem(n : integer) : TMRUItem;
    function  GetPath(n : integer) : WideString;
    function  GetTrans(n : integer) : TCoordTrans;
    procedure LoadFromIni(iniFile : TTntMemIniFile; section : string);
    procedure SaveToIni(iniFile : TTntMemIniFile; section : string);

    property MaxCount : integer read FMaxCount write SetMaxCount;
    property MRUItems[n : integer] : TMRUItem read GetItem; default;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  Std;

// -- Implementation of TMRUItem ---------------------------------------------

constructor TMRUItem.Create(const aFolder, aName : WideString;
                            aIndex : integer;
                            const aPath  : WideString;
                            aTrans : TCoordTrans = trIdent);
begin
  Folder := aFolder;
  Name   := aName;
  Index  := aIndex;
  Path   := aPath;
  Trans  := aTrans
end;

// -- Implementation of TMRUList ---------------------------------------------

// -- Creation and destruction

constructor TMRUList.Create;
begin
  inherited Create;
  Items := TList.Create;
  CompareNames  := False;    // dont compare names IF folders are defined
  DistinguishIndex := False; // dont compare index
  DistinguishPath  := False; // dont compare paths
  MaxCount := 4
end;

destructor TMRUList.Destroy;
begin
  Clear;
  Items.Free;
  inherited Destroy
end;

// -- Setting of max number of items

procedure TMRUList.SetMaxCount(n : integer);
begin
  FMaxCount := n;

  // remove items if required
  while Items.Count > n do
    Items.Delete(n)
end;

function TMRUList.Count : integer;
begin
  Result := Items.Count
end;

procedure TMRUList.Get(n : integer;
                       out aFolder, aName : WideString;
                       out aIndex : integer;
                       out aPath, aText : WideString);
begin
  if n < Count
    then
      with TMRUItem(Items[n]) do
        begin
          aFolder := Folder;
          aName   := Name;
          aIndex  := Index;
          aPath   := Path
        end
    else
      begin
        aFolder := '';
        aName   := '';
        aIndex  := -1;
        aPath   := ''
      end
end;

function TMRUList.GetItem(n : integer) : TMRUItem;
begin
  if Within(n, 0, Count - 1)
    then Result := TMRUItem(Items[n])
    else Result := nil
end;

function  TMRUList.GetPath(n : integer) : WideString;
begin
  if n < Count
    then Result := TMRUItem(Items[n]).Path
    else Result := ''
end;

function  TMRUList.GetTrans(n : integer) : TCoordTrans;
begin
  if n < Count
    then Result := TMRUItem(Items[n]).Trans
    else Result := trIdent
end;

procedure TMRUList.Clear;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    TMRUItem(Items[i]).Free;

  Items.Clear
end;

procedure TMRUList.Add(const aFolder, aName : WideString;
                       aIndex : integer;
                       const aPath  : WideString;
                       aTrans : TCoordTrans = trIdent);
var
  i : integer;
begin
  i := IndexOf(aFolder, aName, aIndex, aPath);

  if i = 0
    then exit; // nop

  if i > 0
    then Items.Insert(0, Items.Extract(Items[i]))
    else
      begin
        Items.Insert(0, TMRUItem.Create(aFolder, aName, aIndex, aPath, aTrans));
        if Items.Count > MaxCount then
          begin
            TMRUItem(Items[Items.Count - 1]).Free;
            Items.Delete(Items.Count - 1)
          end
      end
end;

function TMRUList.IndexOf(const aFolder, aName : WideString;
                          aIndex : integer;
                          const aPath : WideString) : integer;
var
  i : integer;
  s : WideString;
begin
  for i := 0 to Count - 1 do
    with TMRUItem(Items[i]) do
    begin
      s := Path;
      if (aFolder = Folder) and
         //(aName = Name) and
         (((not CompareNames) and (Folder <> '')) or (aName = Name)) and
         ((not DistinguishIndex) or (aIndex = Index)) and
         ((not DistinguishPath ) or (aPath  = s))
      then
        begin
          Result := i;
          exit
        end
    end;
  Result := -1
end;

// -- Ini files --------------------------------------------------------------
//
// Folders and filenames are stores in UTF8.

procedure TMRUList.LoadFromIni(iniFile : TTntMemIniFile; section : string);
var
  i : integer;
  s : string;
begin
  MaxCount := iniFile.ReadInteger(section, 'MaxCount', 4);
  Clear;

  // add backward to preserve order
  for i := MaxCount - 1 downto 0 do
    begin
      s := IntToStr(i);
      if iniFile.ReadString (section, 'File' + s, '') = ''
        then continue;

      Add(UTF8Decode(iniFile.ReadString(section, 'Folder' + s, '')),
          UTF8Decode(iniFile.ReadString(section, 'File'   + s, '')),
          iniFile.ReadInteger(section, 'Index'  + s, -1),
          iniFile.ReadString (section, 'Path'   + s, ''),
          TCoordTrans(iniFile.ReadInteger(section, 'Trans' + s, 0)))
    end
end;

procedure TMRUList.SaveToIni(iniFile : TTntMemIniFile; section : string);
var
  i, n : integer;
begin
  iniFile.WriteInteger(section, 'MaxCount', MaxCount);
  for i := 0 to Items.Count - 1 do
    with TMRUItem(Items[i]) do
      begin
        iniFile.WriteString(section, 'Folder' + IntToStr(i), UTF8Encode(Folder));
        iniFile.WriteString(section, 'File'   + IntToStr(i), UTF8Encode(Name));
        iniFile.WriteInteger(section, 'Index'  + IntToStr(i), Index);
        iniFile.WriteString(section, 'Path'   + IntToStr(i), Path);
        n := ord(Trans);
        iniFile.WriteInteger(section, 'Trans'  + IntToStr(i), n)
      end
end;

// ---------------------------------------------------------------------------

end.
