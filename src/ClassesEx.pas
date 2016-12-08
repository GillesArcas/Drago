unit ClassesEx;

interface

uses
  Classes {$ifndef FPC}, TntClasses {$endif};

{$ifndef FPC}

type
  TWideStringList = class(TTntStringList);

{$else}

type
  TWideStringList = TStringList;

{$endif}

implementation

end.
