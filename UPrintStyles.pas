// ---------------------------------------------------------------------------
// -- Drago -- Definition of print styles ---------------- UPrintStyles.pas --
// ---------------------------------------------------------------------------

unit UPrintStyles;

// ---------------------------------------------------------------------------

interface

uses
  IniFiles, Classes;

type
  TPrintSettings = array[1 .. 29] of string;

procedure CreatePrintIniFile(IniFile : TMemIniFile);
procedure LoadPrintIniFile(iniFile : TMemIniFile);
procedure SavePrintStyle(IniFile : TMemIniFile; style : string);
procedure SavePrintIniFile(iniFile : TMemIniFile);

procedure LoadPrintStyle(IniFile : TMemIniFile; style : string);
procedure WritePrintStyle(IniFile  : TMemIniFile;
                          Style    : string;
                          Settings : TPrintSettings);

const Print_Keys : TPrintSettings =
  (// Games
    'Games',
    'GamesFrom',
    'GamesTo',
    // Figures
    'Figures',
    'InclStartPos',
    'Pos',
    'Step',
    'InclVariations',
    // Game Infos
    'InclInfos',
    'InfosTopFmt',
    'InfosNameFmt',
    // Include coordinates
    //'InclCoord',
    // Include comments
    'InclComments',
    'RemindTitle',
    'RemindMoves',
    // Titles
    'InclTitle',
    'RelativeNum',
    'FmtMainTitle',
    'FmtVarTitle',
    // Header et footer
    'PrintHeader',
    'PrintFooter',
    'HeaderFormat',
    'FooterFormat',
    // Disposition
    'FirstFigAlone',
    'FirstFigRatio',
    'FigPerLine',
    'FigRatio',
    // Margins
    'Margins',
    // Font
    'FontName',
    'FontSize'
    );

const Print_Default : TPrintSettings =
  (// Games
    {Games         } '0',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '1',
    {InclStartPos  } '0',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '1',
    // Game Infos
    {InclInfos     } '1',
    {InfosTopFmt   } '\PB\PW\DT\RE',
    {InfosNameFmt  } '\PB (B) vs \PW (W), \DT',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '0',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '0',
    {FmtMainTitle  } 'Game \game - Figure \figure (\moves)',
    {FmtVarTitle   } 'Game \game - Diagram \figure',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '100',
    {FigPerLine    } '1',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_SingleGame : TPrintSettings =
  (// Games
    {Games         } '0',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '4',
    {InclStartPos  } '0',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '1',
    // Game Infos
    {InclInfos     } '1',
    {InfosTopFmt   } '\PB\PW\DT\RE',
    {InfosNameFmt  } '\PB (B) vs \PW (W), \DT',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '0',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '1',
    {FmtMainTitle  } 'Figure \figure (\moves)',
    {FmtVarTitle   } 'Diagram \figure',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '1',
    {FirstFigRatio } '70',
    {FigPerLine    } '2',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_GameCollection : TPrintSettings =
  (// Games
    {Games         } '1',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '1',
    {InclStartPos  } '0',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '0',
    // Game Infos
    {InclInfos     } '2',
    {InfosTopFmt   } '\PB\PW\DT\RE',
    {InfosNameFmt  } '\PB (B) vs \PW (W), \DT',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '0',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '0',
    {FmtMainTitle  } 'Game \game',
    {FmtVarTitle   } '',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '75',
    {FigPerLine    } '2',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_FusekiCollection : TPrintSettings =
  (// Games
    {Games         } '1',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '2',
    {InclStartPos  } '0',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '0',
    // Game Infos
    {InclInfos     } '2',
    {InfosTopFmt   } '\PB\PW\DT\RE',
    {InfosNameFmt  } '\PB (B) vs \PW (W), \DT',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '0',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '0',
    {FmtMainTitle  } 'Game \game (\moves)',
    {FmtVarTitle   } '',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '75',
    {FigPerLine    } '2',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_InfoCollection : TPrintSettings =
  (// Games
    {Games         } '1',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '0',
    {InclStartPos  } '0',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '1',
    // Game Infos
    {InclInfos     } '1',
    {InfosTopFmt   } '\PB\PW\BR\WR\DT\PC\RE',
    {InfosNameFmt  } '\PB (B) vs \PW (W), \DT',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '0',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '0',
    {RelativeNum   } '0',
    {FmtMainTitle  } '',
    {FmtVarTitle   } '',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '75',
    {FigPerLine    } '2',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_ProblemCollection : TPrintSettings =
  (// Games
    {Games         } '1',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '0',
    {InclStartPos  } '1',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '0',
    // Game Infos
    {InclInfos     } '0',
    {InfosTopFmt   } '',
    {InfosNameFmt  } '',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '1',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '0',
    {FmtMainTitle  } 'Problem \game',
    {FmtVarTitle   } '',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '75',
    {FigPerLine    } '3',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

const Print_SolutionCollection : TPrintSettings =
  (// Games
    {Games         } '1',
    {GamesFrom     } '1',
    {GamesTo       } '1',
    // Figures
    {Figures       } '1',
    {InclStartPos  } '1',
    {Pos           } '50',
    {Step          } '50',
    {InclVariations} '1',
    // Game Infos
    {InclInfos     } '0',
    {InfosTopFmt   } '',
    {InfosNameFmt  } '',
    // Include coordinates
    //{InclCoord     } '0',
    // Include comments
    {InclComments  } '1',
    {RemindTitle   } '1',
    {RemindMoves   } '0',
    // Titles
    {InclTitle     } '1',
    {RelativeNum   } '0',
    {FmtMainTitle  } 'Problem \game - Figure \figure',
    {FmtVarTitle   } 'Problem \game - Figure \figure',
    // Header et footer
    {PrintHeader   } '1',
    {PrintFooter   } '1',
    {HeaderFormat  } '\left \file \right ''Printed by Drago''',
    {FooterFormat  } '\left ''Page '' \page \right \date',
    // Disposition
    {FirstFigAlone } '0',
    {FirstFigRatio } '75',
    {FigPerLine    } '3',
    {FigRatio      } '100',
    // Margins
    {Margins       } '15,15,15,15',
    // Font
    {FontName      } 'Arial',
    {FontSize      } '10'
    );

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi, UStatus, Translate;

// ---------------------------------------------------------------------------

procedure WritePrintStyle(IniFile  : TMemIniFile;
                          Style    : string;
                          Settings : TPrintSettings);
var
  i : integer;
begin
  with IniFile do
    for i := low(Print_Keys) to high(Print_Keys) do
      WriteString(style, Print_Keys[i], T(Settings[i]))
end;

// -- Loading of a printing style --------------------------------------------

procedure LoadPrintStyle(IniFile : TMemIniFile; style : string);
var
  n : integer;
  st : TStatus;
begin
  st := Settings;

  with IniFile do
    begin
      // Games
      n                  := ReadInteger(style, 'Games'         , ord(pgCurrent));
      st.PrGames         := TprGames(n);
      st.PrFrom          := ReadInteger(style, 'GamesFrom'     , 1);
      st.PrTo            := ReadInteger(style, 'GamesTo'       , 1);
      // Figures
      n                  := ReadInteger(style, 'Figures'       , ord(fgLast));
      st.PrFigures       := TFigures(n);
      st.PrInclStartPos  := ReadBool   (style, 'InclStartPos'  , False);
      st.PrPos           := ReadInteger(style, 'Pos'           , 50);
      st.PrStep          := ReadInteger(style, 'Step'          , 50);
      st.PrInclVar       := ReadBool   (style, 'InclVariations', True);
      // Include game information
      n                  := ReadInteger(style, 'InclInfos'     , ord(inTop));
      st.PrInclInfos     := TprInfos(n);
      st.PrInfosTopFmt   := ReadString (style, 'InfosTopFmt'   , '\PB\PW\DT\RE');
      st.PrInfosNameFmt  := ReadString (style, 'InfosNameFmt'  , '\PB (B) vs \PW (W), \DT');
      // Include comments
      st.PrInclComm      := ReadBool   (style, 'InclComments'  , True);
      st.PrRemindTitle   := ReadBool   (style, 'RemindTitle'   , False);
      st.PrRemindMoves   := ReadBool   (style, 'RemindMoves'   , False);
      // Titles
      st.PrInclTitle     := ReadBool   (style, 'InclTitle'     , True);
      st.PrRelNum        := ReadBool   (style, 'RelativeNum'   , False);
      st.PrFmtMainTitle  := ReadString (style, 'FmtMainTitle'  , stFmtMainTitle);
      st.PrFmtVarTitle   := ReadString (style, 'FmtVarTitle'   , stFmtVarTitle);
      // Header and footer
      st.PrPrintHeader   := ReadBool   (style, 'PrintHeader'   , True);
      st.PrPrintFooter   := ReadBool   (style, 'PrintFooter'   , True);
      st.PrHeaderFormat  := ReadString (style, 'HeaderFormat'  , '\left \file \right ''Printed by Drago''');
      st.PrFooterFormat  := ReadString (style, 'FooterFormat'  , '\left ''Page '' \page \right \date');
      // Layout
      st.PrFirstFigAlone := ReadBool   (style, 'FirstFigAlone' , False);
      st.PrFirstFigRatio := ReadInteger(style, 'FirstFigRatio' , 75);
      st.PrFigPerLine    := ReadInteger(style, 'FigPerLine'    , 1);
      st.PrFigRatio      := ReadInteger(style, 'FigRatio'      , 100);
      // Margins
      st.PrMargins       := ReadString (style, 'Margins'       , '15,15,15,15');
      // Fonts
      st.PrFontName      := ReadString (style, 'FontName'      , 'Arial');
      st.PrFontSize      := ReadInteger(style, 'FontSize'      , 10);
    end
  end;

// -- Saving of a printing style ---------------------------------------------

procedure SavePrintStyle(IniFile : TMemIniFile; style : string);
var
  st : TStatus;
begin
  st := Settings;

  with IniFile do
    begin
      // Games
      WriteInteger(style, 'Games'         , ord(st.PrGames));
      WriteInteger(style, 'GamesFrom'     , st.PrFrom);
      WriteInteger(style, 'GamesTo'       , st.PrTo);
      // Figures
      WriteInteger(style, 'Figures'       , ord(st.PrFigures));
      WriteBool   (style, 'InclStartPos'  , st.PrInclStartPos);
      WriteInteger(style, 'Pos'           , st.PrPos);
      WriteInteger(style, 'Step'          , st.PrStep);
      WriteBool   (style, 'InclVariations', st.PrInclVar);
      // Include info
      WriteInteger(style, 'InclInfos'     , ord(st.PrInclInfos));
      WriteString (style, 'InfosTopFmt'   , st.PrInfosTopFmt);
      WriteString (style, 'InfosNameFmt'  , st.PrInfosNameFmt);
      // Include comments
      WriteBool   (style, 'InclComments'  , st.PrInclComm);
      WriteBool   (style, 'RemindTitle'   , st.PrRemindTitle);
      WriteBool   (style, 'RemindMoves'   , st.PrRemindMoves);
      // Titles
      WriteBool   (style, 'InclTitle'     , st.PrInclTitle);
      WRiteBool   (style, 'RelativeNum'   , st.PrRelNum);
      WriteString (style, 'FmtMainTitle'  , st.PrFmtMainTitle);
      WriteString (style, 'FmtVarTitle'   , st.PrFmtVarTitle);
      // Header and footer
      WriteBool   (style, 'PrintHeader'   , st.PrPrintHeader);
      WriteBool   (style, 'PrintFooter'   , st.PrPrintFooter);
      WriteString (style, 'HeaderFormat'  , st.PrHeaderFormat);
      WriteString (style, 'FooterFormat'  , st.PrFooterFormat);
      // Layout
      WriteInteger(style, 'FigPerLine'    , st.PrFigPerLine);
      WriteInteger(style, 'FigRatio'      , st.PrFigRatio);
      WriteBool   (style, 'FirstFigAlone' , st.PrFirstFigAlone);
      WriteInteger(style, 'FirstFigRatio' , st.PrFirstFigRatio);
      // Margins
      WriteString (style, 'Margins'       , st.PrMargins);
      // Fonts
      WriteString (style, 'FontName'      , st.PrFontName);
      WriteInteger(style, 'FontSize'      , st.PrFontSize);
    end
end;

// -- Creation in inifile of predefined printing styles ----------------------

procedure CreatePrintIniFile(IniFile : TMemIniFile);
begin
  WritePrintStyle(IniFile, 'Print'                   , Print_Default);
  WritePrintStyle(IniFile, 'Print-Default'           , Print_Default);
  WritePrintStyle(IniFile, 'Print-SingleGame'        , Print_SingleGame);
  WritePrintStyle(IniFile, 'Print-GameCollection'    , Print_GameCollection);
  WritePrintStyle(IniFile, 'Print-FusekiCollection'  , Print_FusekiCollection);
  WritePrintStyle(IniFile, 'Print-InfoCollection'    , Print_InfoCollection);
  WritePrintStyle(IniFile, 'Print-ProblemCollection' , Print_ProblemCollection);
  WritePrintStyle(IniFile, 'Print-SolutionCollection', Print_SolutionCollection);
  IniFile.UpdateFile
end;

// -- Loading of printing settings -------------------------------------------

procedure LoadPrintIniFile(iniFile : TMemIniFile);
var
  st : TStatus;
  n : integer;
  list : TStringList;
begin
  st := Settings;

  with iniFile do
    begin
      // read export formats
      n := ReadInteger('Print', 'ExportGame', ord(egRTF));
      st.PrExportGame    := TExportGame(n);
      n := ReadInteger('Print', 'ExportFigure', ord(eiWMF));
      st.PrExportFigure  := TExportFigure(n);
      n := ReadInteger('Print', 'ExportPos', ord(eiWMF));
      st.PrExportPos     := TExportFigure(n);

      // read options for exporting games and figures
      st.PrPaperSize     := ReadString ('Print', 'PaperSize'  , 'A4');
      st.PrLandscape     := ReadBool   ('Print', 'Landscape'  , False);
      st.PrCompressPDF   := ReadBool   ('Print', 'CompressPDF', True);
      st.PrQualityJPEG   := ReadInteger('Print', 'QualityJPEG', 75);

      // read export position settings
      st.PrNumAsBooks    := ReadBool   ('Print', 'NumAsBooks' , False);
      st.PrExportPosDiam := ReadInteger('Print', 'ExportPosDiam', 20);
      st.PrDPI           := ReadInteger('Print', 'DPI'        , 360);
      st.AscDrawEdge     := ReadBool   ('Ascii', 'DrawEdge'   , True);
      st.AscBlackChar    := ReadString ('Ascii', 'BlackChar'  , 'X')[1];
      st.AscWhiteChar    := ReadString ('Ascii', 'WhiteChar'  , 'O')[1];
      st.AscHoshi        := ReadString ('Ascii', 'Hoshi'      , ',')[1];

      // read current style
      LoadPrintStyle(iniFile, 'Print');

      // read list of styles
      Status.PrStyles.Clear;
      list := TStringList.Create;
      ReadSections(list);
      for n := 0 to list.Count - 1 do
        if Copy(list[n], 1, 5) = 'Print' then
          if list[n] = 'Print'
            then Status.PrStyles.Add('Current')
            else Status.PrStyles.Add(Copy(list[n], 7, Length(list[n])));
      list.Free
    end
end;

// -- Saving of printing settings --------------------------------------------

procedure SavePrintIniFile(iniFile : TMemIniFile);
var
  st : TStatus;
begin
  st := Settings;

  with iniFile do
    begin
      // save export formats
      WriteInteger('Print', 'ExportGame'   , ord(st.PrExportGame));
      WriteInteger('Print', 'ExportFigure' , ord(st.PrExportFigure));
      WriteInteger('Print', 'ExportPos'    , ord(st.PrExportPos));

      // save options for exporting games and figures
      WriteString ('Print', 'PaperSize'    , st.PrPaperSize);
      WriteBool   ('Print', 'Landscape'    , st.PrLandscape);
      WriteBool   ('Print', 'CompressPDF'  , st.PrCompressPDF);
      WriteInteger('Print', 'QualityJPEG'  , st.PrQualityJPEG);

      // save options for exporting positions
      WriteBool   ('Print', 'NumAsBooks'   , st.PrNumAsBooks);
      WriteInteger('Print', 'ExportPosDiam', st.PrExportPosDiam);
      WriteBool   ('Ascii', 'DrawEdge'     , st.AscDrawEdge);
      WriteString ('Ascii', 'BlackChar'    , st.AscBlackChar);
      WriteString ('Ascii', 'WhiteChar'    , st.AscWhiteChar);
      WriteString ('Ascii', 'Hoshi'        , st.AscHoshi);

      SavePrintStyle(iniFile, 'Print')
    end
end;

// ---------------------------------------------------------------------------

end.
