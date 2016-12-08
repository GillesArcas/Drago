unit URandom;

(*
This module provides a pseudo random generator independant from compiler.

Refrerence :

Random Number Generators: Good Ones Are Hard To Find
Steve Park and Keith Miller
Communications of the ACM, October 1988

Google 2147483647 48271 Park for more information.

*)

interface

var
  RandSeed : integer = 123456789;

procedure Randomize;
function  Random : double; overload;
function  Random(range : integer) : integer; overload;
function  RandomBoolean(pr : double = 0.5) : boolean;

implementation

uses
  Windows;

const
  Multiplier = 48271;
  Modulo     = 2147483647;
  Q          = Modulo div Multiplier;
  R          = Modulo mod Multiplier;

procedure Randomize;
var
  seed : _SYSTEMTIME;
begin
  GetSystemTime(seed);
  RandSeed := seed.wMilliseconds;
end;

function RandomInternal : integer;
begin
  Result := Multiplier * (RandSeed mod Q) - R * (RandSeed div Q);
  if Result < 0
    then inc(Result, Modulo);

  RandSeed := Result
end;

function Random : double;
begin
  Result := RandomInternal / Modulo
end;

function Random(range : integer) : integer;
begin
  Result := RandomInternal mod range
end;

function RandomBoolean(pr : double = 0.5) : boolean;
begin
  Result := Random < pr
end;

end.
