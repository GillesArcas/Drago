@echo off
rem > Build-Release [cfg file]

rem  Note: compiling twice the same sources gives different binaries.

rem Utiliser DragoDelphi7se.cfg

rem Rajouter à la main SpTBXGlyphs.res et VirtualTrees.res dans src sinon marche pas

rem Il faut faire un build sous l'IDE pour avoir les dcu des 3rd (TNT, etc)
rem en l'état le build par batch avec DragoD7Lite.cfg ne recompile pas les dc 3rd
rem et le build échoue.
rem DONC: ne pas effacer les dcu tant que le build batch ne sait pas recompiler
rem les 3rd.

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