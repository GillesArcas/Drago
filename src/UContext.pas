// ---------------------------------------------------------------------------
// -- Drago -- View context ---------------------------------- UContext.pas --
// ---------------------------------------------------------------------------

unit UContext;

// ---------------------------------------------------------------------------

interface

uses
  UInstStatus, UGameColl, UGameTree, UGoban, UKombilo, Ugtp;

type
  TContext = class
    gb  : TGoban;
    si  : TInstStatus;
    cl  : TGameColl;
    gt  : TGameTree;
    kh  : TKGameList;
    gtp : TGtp;
    constructor Create;
    destructor Destroy; override;
  end;

// ---------------------------------------------------------------------------

implementation

uses
  SysUtils;

// ---------------------------------------------------------------------------

constructor TContext.Create;
begin
  si := TInstStatus.Create;
  cl := TGameColl.Create;
end;

destructor TContext.Destroy;
begin
  gb.Free;
  si.Free;
  cl.Free;
  FreeAndNil(kh);
  FreeAndNil(gtp)
end;

// ---------------------------------------------------------------------------

end.

