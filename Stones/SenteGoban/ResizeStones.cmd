@echo off
setlocal

rem imagemagick filters
rem http://www.imagemagick.org/script/command-line-options.php#filter
rem default is Lanczos

set filter=

for /L %%1 in (7,2,19) do convert BlackStone48.png -resize %%1 %filter% BlackStone%%1.png

for /L %%1 in (7,2,19) do (
  for /L %%2 in (0,1,11) do convert WhiteStone48-%%2.png -resize %%1 %filter% WhiteStone%%1-%%2.png
)
