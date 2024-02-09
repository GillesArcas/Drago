set mysed=d:\gilles\@tools\sed

set view=view-main
set caption=Main window
gosub makeview
set view=view-index-info
set caption=Game information view
gosub makeview
set view=view-index-diag
set caption=Thumbnail view
gosub makeview
set view=view-layout
set caption=Print layout dialog
gosub makeview
set view=view-exportpos
set caption=Export position dialog
gosub makeview
set view=view-options
set caption=Option dialog
gosub makeview

del tmp.tmp > nul

quit

:makeview
copy view-archetype.htm tmp.tmp
%mysed -e "s/IMAGE/%view%/" -e "s/CAPTION/%caption%/" tmp.tmp > %view%.htm
return


