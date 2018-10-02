@echo off
rem > Build-Release [cfg file]

rem  Note: compiling twice the same sources gives different binaries.

rem clean output directory
del ..\dcu\*.dcu

if '%1' NEQ '' goto use_cfg_argument

:use_default_cfg
set cfg=DragoRelease.cfg
goto compile
:use_cfg_argument
set cfg=%1

rem drago.cfg is saved and restored. Note however, it will be overridden each time new options are saved in the IDE.

:compile
copy Drago.cfg Drago.cfg.bak > nul
copy %cfg% Drago.cfg > nul
dcc32 Drago
move Drago.cfg.bak Drago.cfg > nul

:return