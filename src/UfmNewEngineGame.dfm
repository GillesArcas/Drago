object fmNewEngineGame: TfmNewEngineGame
  Left = 392
  Top = 171
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__Drago - New game'
  ClientHeight = 430
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 264
    Top = 560
    Width = 109
    Height = 13
    Caption = 'Original dims: 269x441'
  end
  object gbTimeSettings: TSpTBXGroupBox
    Left = 273
    Top = 12
    Width = 232
    Height = 249
    Caption = 'Time settings'
    SkinType = sknWindows
    TabOrder = 6
    object rbNoTime: TSpTBXRadioButton
      Left = 8
      Top = 24
      Width = 75
      Height = 15
      Caption = 'No time limit'
      TabOrder = 0
      OnClick = TimeButtonClick
    end
    object rbTotalTime: TSpTBXRadioButton
      Left = 8
      Top = 56
      Width = 65
      Height = 15
      Caption = 'Total time'
      TabOrder = 1
      OnClick = TimeButtonClick
    end
    object rbTimePerMove: TSpTBXRadioButton
      Left = 8
      Top = 86
      Width = 88
      Height = 15
      Caption = 'Time per move'
      TabOrder = 2
      OnClick = TimeButtonClick
    end
    object lbTotalTime: TSpTBXLabel
      Left = 187
      Top = 57
      Width = 28
      Height = 13
      Caption = 'hr:mn'
    end
    object lbTimePerMove: TSpTBXLabel
      Left = 187
      Top = 87
      Width = 28
      Height = 13
      Caption = 'mn:sc'
    end
    object rbOverTime: TSpTBXRadioButton
      Left = 8
      Top = 116
      Width = 137
      Height = 15
      Caption = 'Initial time plus over time'
      TabOrder = 3
      OnClick = TimeButtonClick
    end
    object pnOverTime: TPanel
      Left = 20
      Top = 135
      Width = 207
      Height = 82
      BevelOuter = bvNone
      TabOrder = 6
      object SpTBXLabel7: TSpTBXLabel
        Left = 12
        Top = 57
        Width = 33
        Height = 13
        Caption = 'Stones'
      end
      object dtOverStones: TDateTimePicker
        Left = 104
        Top = 53
        Width = 57
        Height = 21
        Date = 39726.000289351850000000
        Format = 'ss'
        Time = 39726.000289351850000000
        Kind = dtkTime
        TabOrder = 2
      end
      object SpTBXLabel6: TSpTBXLabel
        Left = 167
        Top = 32
        Width = 28
        Height = 13
        Caption = 'mn:sc'
      end
      object SpTBXLabel5: TSpTBXLabel
        Left = 167
        Top = 8
        Width = 28
        Height = 13
        Caption = 'hr:mn'
      end
      inline tpMainTime: TTimePicker
        Left = 104
        Top = 3
        Width = 57
        Height = 24
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited Panel1: TPanel
          inherited Label1: TLabel
            Width = 4
          end
        end
      end
      inline tpOverTime: TTimePicker
        Left = 104
        Top = 27
        Width = 57
        Height = 24
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        inherited Panel1: TPanel
          inherited Label1: TLabel
            Width = 4
          end
        end
      end
      object Label2: TSpTBXLabel
        Left = 11
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Initial time'
        ParentColor = True
      end
      object Label5: TSpTBXLabel
        Left = 11
        Top = 32
        Width = 47
        Height = 13
        Caption = 'Over time'
        ParentColor = True
      end
    end
    inline tpTotalTime: TTimePicker
      Left = 123
      Top = 52
      Width = 57
      Height = 24
      Color = clBtnFace
      ParentColor = False
      TabOrder = 4
      inherited Panel1: TPanel
        inherited Label1: TLabel
          Width = 4
        end
      end
    end
    inline tpTimePerMove: TTimePicker
      Left = 123
      Top = 82
      Width = 57
      Height = 24
      Color = clBtnFace
      ParentColor = False
      TabOrder = 5
      inherited Panel1: TPanel
        inherited Label1: TLabel
          Width = 4
        end
      end
    end
    object cxEngineOnlyTiming: TSpTBXCheckBox
      Left = 7
      Top = 219
      Width = 123
      Height = 15
      Caption = 'Timing only for engine'
      TabOrder = 9
    end
  end
  object rgScoring: TSpTBXRadioGroup
    Left = 272
    Top = 267
    Width = 235
    Height = 89
    Caption = 'Scoring'
    ParentColor = True
    TabOrder = 8
    OnClick = rgScoringClick
    Items.Strings = (
      'Territory counting'
      'Area counting')
  end
  object gbEngine: TSpTBXGroupBox
    Left = 16
    Top = 12
    Width = 249
    Height = 81
    Caption = 'Game engine'
    ParentColor = True
    TabOrder = 4
    object cbEngines: TTntComboBox
      Left = 72
      Top = 24
      Width = 161
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbEnginesChange
    end
    object lbLevel: TSpTBXLabel
      Left = 8
      Top = 48
      Width = 25
      Height = 13
      Caption = 'Level'
      ParentColor = True
    end
    object lbName: TSpTBXLabel
      Left = 8
      Top = 24
      Width = 27
      Height = 13
      Caption = 'Name'
      ParentColor = True
    end
    object cbLevel: TTntComboBox
      Left = 72
      Top = 45
      Width = 161
      Height = 21
      DropDownCount = 10
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbLevelChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10')
    end
  end
  object pnValues: TSpTBXGroupBox
    Left = 16
    Top = 267
    Width = 249
    Height = 89
    Caption = 'Game settings'
    Color = clBtnFace
    UseDockManager = True
    TabOrder = 7
    object cbBoardSize: TComboBox
      Left = 78
      Top = 21
      Width = 57
      Height = 21
      DropDownCount = 3
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbBoardSizeChange
      Items.Strings = (
        '9'
        '13'
        '19')
    end
    object cbHandicap: TComboBox
      Left = 78
      Top = 56
      Width = 57
      Height = 21
      Style = csDropDownList
      DropDownCount = 10
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbHandicapChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9')
    end
    object cbKomi: TComboBox
      Left = 181
      Top = 21
      Width = 57
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        '0'
        '0.5'
        '5.5'
        '6.5'
        '7.5'
        '8')
    end
    object cxFree: TSpTBXCheckBox
      Left = 145
      Top = 59
      Width = 92
      Height = 15
      Caption = 'Free placement'
      ParentColor = True
      TabOrder = 3
      Alignment = taRightJustify
    end
    object lbSize: TSpTBXLabel
      Left = 9
      Top = 25
      Width = 46
      Height = 13
      Caption = 'Boardsize'
      ParentColor = True
    end
    object lbHandicap: TSpTBXLabel
      Left = 9
      Top = 60
      Width = 44
      Height = 13
      Caption = 'Handicap'
      ParentColor = True
    end
    object lbKomi: TSpTBXLabel
      Left = 143
      Top = 25
      Width = 22
      Height = 13
      Caption = 'Komi'
      ParentColor = True
    end
  end
  object cxShowGtpWindow: TSpTBXCheckBox
    Left = 400
    Top = 375
    Width = 105
    Height = 15
    Caption = 'Show GTP window'
    Color = clBtnFace
    TabOrder = 9
    Alignment = taRightJustify
  end
  object Panel1: TPanel
    Left = 0
    Top = 409
    Width = 515
    Height = 21
    Align = alBottom
    BevelOuter = bvNone
    Enabled = False
    TabOrder = 10
    DesignSize = (
      515
      21)
    object edMessage: TSpTBXEdit
      Left = 0
      Top = 0
      Width = 521
      Height = 21
      TabStop = False
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 0
      Text = 'edMessage'
    end
  end
  object gbStartPosition: TSpTBXGroupBox
    Left = 16
    Top = 100
    Width = 249
    Height = 161
    Caption = 'Start position'
    TabOrder = 5
    DesignSize = (
      249
      161)
    object rbNewGame: TSpTBXRadioButton
      Left = 8
      Top = 28
      Width = 68
      Height = 15
      Caption = 'New game'
      TabOrder = 0
      OnClick = StartPositionClick
    end
    object rbCurrentPosition: TSpTBXRadioButton
      Left = 8
      Top = 58
      Width = 95
      Height = 15
      Caption = 'Current position'
      TabOrder = 1
      OnClick = StartPositionClick
    end
    object rbAutoHandicap: TSpTBXRadioButton
      Left = 8
      Top = 88
      Width = 87
      Height = 15
      Caption = 'Auto handicap'
      TabOrder = 2
      OnClick = StartPositionClick
    end
    object TntLabel1: TSpTBXLabel
      Left = 12
      Top = 127
      Width = 101
      Height = 23
      Caption = 'Engine plays with'
      Anchors = [akLeft, akBottom]
      AutoSize = False
      ParentColor = True
      Wrapping = twWrap
    end
    object rbEngineBlack: TSpTBXRadioButton
      Left = 186
      Top = 131
      Width = 42
      Height = 15
      Caption = 'Black'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 4
      TabStop = True
      GroupIndex = 1
    end
    object rbEngineWhite: TSpTBXRadioButton
      Left = 121
      Top = 131
      Width = 46
      Height = 15
      Caption = 'White'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 3
      TabStop = True
      GroupIndex = 1
    end
  end
  object btOk: TSpTBXButton
    Left = 16
    Top = 370
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = btOkClick
    Default = True
    SkinType = sknWindows
  end
  object btCancel: TSpTBXButton
    Left = 95
    Top = 370
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
    Cancel = True
    SkinType = sknWindows
  end
  object btHelp: TSpTBXButton
    Left = 174
    Top = 370
    Width = 75
    Height = 25
    Caption = '&Help'
    TabOrder = 2
    OnClick = btHelpClick
    SkinType = sknWindows
  end
  object btMore: TSpTBXButton
    Left = 253
    Top = 370
    Width = 75
    Height = 25
    Caption = 'More...'
    TabOrder = 3
    DropDownMenu = SpTBXPopupMenu1
  end
  object SpTBXPopupMenu1: TSpTBXPopupMenu
    Left = 336
    Top = 352
    object mnEngineSettings: TSpTBXItem
      Caption = 'Engine settings...'
      ImageIndex = 69
      Images = Actions.ImageList
      OnClick = mnEngineSettingsClick
    end
    object mnMoreEngines: TSpTBXItem
      Caption = 'More engines...'
      ImageIndex = 69
      Images = Actions.ImageList
      OnClick = btMoreEnginesClick
    end
    object SpTBXItem1: TSpTBXItem
      Action = Actions.acAdvancedSettings
      Images = Actions.ImageList
    end
  end
end
