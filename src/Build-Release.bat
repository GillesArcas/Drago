@echo off
rem > Build-Release [cfg file]

rem  Note: compiling twice the same sources gives different binaries.

rem clean output directory
del ..\dcu\*.dcu

if '%1' NEQ '' goto use_cfg_argument

:use_default_cfg
dcc32 Drago
goto return

:use_cfg_argument
set cfg=%1
copy Drago.cfg Drago.cfg.bak > nul
copy %cfg% Drago.cfg > nul
dcc32 Drago
move Drago.cfg.bak Drago.cfg > nul

:return