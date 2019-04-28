object frCfgPredefinedEngines: TfrCfgPredefinedEngines
  Left = 0
  Top = 0
  Width = 451
  Height = 359
  TabOrder = 0
  DesignSize = (
    451
    359)
  object Bevel1: TBevel
    Left = 16
    Top = 312
    Width = 313
    Height = 10
    Shape = bsBottomLine
  end
  object SpTBXLabel2: TSpTBXLabel
    Left = 15
    Top = 16
    Width = 118
    Height = 13
    Caption = 'Select predefined engine'
  end
  object StringGrid: TStringGrid
    Left = 8
    Top = 40
    Width = 330
    Height = 153
    ColCount = 2
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object lbMessage: TSpTBXLabel
    Left = 15
    Top = 269
    Width = 321
    Height = 33
    Caption = 
      'Press Ok (then you will have to enter executable installation pa' +
      'th) or cancel.'
    AutoSize = False
    Wrapping = twWrap
  end
  object btOpenBrowser: TSpTBXRadioButton
    Left = 15
    Top = 221
    Width = 186
    Height = 15
    Caption = 'Open browser, download and install'
    TabOrder = 1
  end
  object btAlreadyInstalled: TSpTBXRadioButton
    Left = 15
    Top = 245
    Width = 94
    Height = 15
    Caption = 'Already installed'
    TabOrder = 2
  end
  object SpTBXLabel1: TSpTBXLabel
    Left = 15
    Top = 325
    Width = 431
    Height = 17
    Caption = 
      'If the engine motor you want to play with is not in the list, ed' +
      'it the following file:'
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Wrapping = twWrap
  end
  object lbEditEnginesConfig: TSpTBXLabel
    Left = 15
    Top = 340
    Width = 69
    Height = 14
    Caption = 'engines.config'
    OnClick = lbEditEnginesConfigClick
    LinkText = 'engines.config'
    SkinType = sknWindows
    Underline = True
  end
end
