[TOC]

------

# Big picture

## Go board implementation

![goban.class](goban.class.jpg)

------

##### TGoban

Full class with logic and display capabilities.

##### TGoBoard

Only logic: position, capture, ko, etc.

##### TBoardView

How the board is displayed, subclassed for display in graphic or text form.

##### TBoardViewMetric

Graphic display as pdf or bitmaps.

##### TBoardViewAscii

Board display in text format, subclassed into __TBoardViewSL__, **TBoardViewRGG** and **TBoardViewTRC** respectively to export to Sensei Library diagram format, rec.games.go diagram format and to the format used for Drago testing.

##### TBoardViewCanvas

Board display in graphic format (bitmap, WMF).

##### TBoardViewVector

Board display in WMF format.

##### TBoardViewScript

Export the board as a list of text commands to be used when exporting to PDF (see UImageExporterPDF).

##### TBookBoard

In charge, of exporting a position as in books, i.e. prisoners are not removed and following moves are indicated with the number of the captured stone (e.g. move 56 at 34).

------

## Printing and exporting

![exporter.class](exporter.class.jpg)

TExporter classes are used by the print form and the print module to export or preview games. 

The print form (fmPrint) enables the user to specify the action (preview, print or export) and set the parameters. Action and formats are instantiated into the relevant TExporter and TExporterImage.

The procedure DoPreviewGame (legacy name) goes through a game and launches the export of comments, figures and variations according to the parameters set by the user. When an export action is required, the procedure used the current exporter.

TExporter copes with full games.

TExporterImage concerns only board images making TExportedImage to be used by TExporter.

TExporterDOC, TExporterHTM, TExporterPDF, ExporterRTF, TExporterTXT

Are respectively used to export to

TExporterIMG, TExporterNFG, TExporterPRE
