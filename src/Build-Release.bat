@echo off
rem > Build-Release [cfg file]

rem Note1: compiling twice the same sources gives different binaries.
rem Note2: paths must be checked in DragoRelease.cfg

rem Explicit paths. Better in case another delphi version installed. To be configured.
set DCC32=D:\Borland\Delphi7\bin\dcc32.exe
set BRCC32=D:\Borland\Delphi7\Bin\brcc32.exe

rem clean output directory
del ..\dcu\*.dcu > nul

if '%1' NEQ '' goto use_cfg_argument

:use_default_cfg
set cfg=DragoRelease.cfg
goto compile
:use_cfg_argument
set cfg=%1

:compile
rem Compile resources (note this is not done automatically by the IDE)
%brcc32% Resources.rc -foResources.res

rem Compile project (current Drago.cfg is saved and restored)
copy Drago.cfg Drago.cfg.bak > nul
copy %cfg% Drago.cfg > nul
%DCC32% Drago
move Drago.cfg.bak Drago.cfg > nul

:return
