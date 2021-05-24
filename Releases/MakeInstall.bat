@echo off
:: MakeInstall install|portable|both
:: if no argument, both

setlocal

:: to be checked, configuration dependant
set godir=G:\Go
set inno="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
set zip=7z.exe

set mode=%1
if "%mode%"=="" set mode=both

set makeinstall=No
set makeportable=No
if "%mode%"=="install"  set makeinstall=Yes
if "%mode%"=="both"     set makeinstall=Yes
if "%mode%"=="portable" set makeportable=Yes
if "%mode%"=="both"     set makeportable=Yes

set nver=0430

:: files in portable install
set files=^
 Drago.exe^
 .\Releases\DragoPortable.ini^
 LibKombilo.dll^
 libhpdf.dll^
 engines.config^
 Drago-??.chm^
 .\Releases\Readme.txt^
 .\Releases\License.txt^
 Stones\Default\*.*^
 Stones\SenteGoban\*.*^
 Textures\*.*^
 Languages\Drago-??.lng^
 Players\*.*^
 %godir%\Sgf\Fuseki\fuseki8.sgf^
 %godir%\Sgf\Games\kisei.sgf^
 %godir%\Sgf\Problemes\kido.sgf^
 %godir%\Sgf\Problemes\easy.sgf^
 %godir%\Sgf\Problemes\hard.sgf^
 %godir%\Sgf\Problemes\reflexes.sgf^
 %godir%\Databases\kisei.db^
 %godir%\Databases\kisei.db1^
 %godir%\Databases\kisei.db2

:: make sure the files used at runtime are correctly archived
cd %godir%\Drago
for %%1 in (LibKombilo.dll libhpdf.dll engines.config Drago-??.chm) do (
    fc %%1 runtime\%%1 > NUL
    if errorlevel 1 (echo Diff between installed and archived file: %%1. Please check. & goto :eof)
)

:: check version numbers
set /P choice=Check version numbers (%nver%) in readme, about, executable versions? [ok, quit]
if "%choice%" neq "ok" goto :eof

:: check source management
git status .. --short -uno
set /P choice=Check source management? [ok, quit]
if "%choice%" neq "ok" goto :eof

:: delete executable to have the creation date reset
del %godir%\Drago\drago.exe

:: build executable
cd %godir%\Drago\Src
call Build-Release DragoRelease.cfg

:: archive sources
set y=%date:~-4%
set m=%date:~3,2%
set d=%date:~0,2%
set today=%y%%m%%d%
set name=%today%-%nver%
cd %godir%\Drago\Src
%zip% a -r %name%.7z *.*
move %name%.7z ..\Releases\Sources

:: make standard install
if %makeinstall%==Yes (
    cd %godir%\Drago\Releases
    %inno% Drago.iss
    %zip% a SetupDrago%nver%.zip SetupDrago%nver%.exe
    del SetupDrago%nver%.exe > nul
    move SetupDrago%nver%.zip %godir%\Drago\Releases\Install
)

:: make portable install
if %makeportable%==Yes (
    cd %godir%\Drago
    %zip% a PortableDrago%nver%.zip %files%
    move PortableDrago%nver%.zip %godir%\Drago\Releases\Install
)
