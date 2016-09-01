object fmProblems: TfmProblems
  Left = 512
  Top = 167
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__Problem mode'
  ClientHeight = 391
  ClientWidth = 349
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  DesignSize = (
    349
    391)
  PixelsPerInch = 96
  TextHeight = 13
  object rgMode: TSpTBXRadioGroup
    Left = 8
    Top = 103
    Width = 166
    Height = 100
    Caption = 'Problem order'
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Items.Strings = (
      'Sequential from current'
      'Sequential from stored'
      'Random')
  end
  object rgMarkup: TSpTBXRadioGroup
    Left = 9
    Top = 275
    Width = 337
    Height = 65
    Caption = 'Solution marks'
    Anchors = [akLeft, akBottom]
    TabOrder = 6
    Columns = 2
    Items.Strings = (
      'uliGo'
      'Goproblems'
      'Main line'
      'Autodetect')
  end
  object pnNbPb: TSpTBXPanel
    Left = 180
    Top = 109
    Width = 166
    Height = 94
    Color = clBtnFace
    Anchors = [akLeft, akBottom]
    UseDockManager = True
    TabOrder = 4
    object lbNbPb: TTntLabel
      Left = 11
      Top = 15
      Width = 94
      Height = 13
      Caption = 'Number of problems'
      Transparent = False
    end
    object edNbPb: TTntEdit
      Left = 120
      Top = 12
      Width = 30
      Height = 21
      TabOrder = 0
      Text = '999'
    end
    object cbRndPos: TSpTBXCheckBox
      Left = 10
      Top = 41
      Width = 97
      Height = 15
      Caption = 'Random position'
      ParentColor = True
      TabOrder = 1
    end
    object cbRndCol: TSpTBXCheckBox
      Left = 11
      Top = 68
      Width = 84
      Height = 15
      Caption = 'Random color'
      ParentColor = True
      TabOrder = 2
    end
  end
  object StatBox: TSpTBXGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 89
    Caption = 'Statistics'
    ParentColor = True
    TabOrder = 7
    object StatGrid: TTntStringGrid
      Left = 10
      Top = 15
      Width = 320
      Height = 64
      BorderStyle = bsNone
      ColCount = 3
      DefaultRowHeight = 16
      DefaultDrawing = False
      Enabled = False
      FixedCols = 0
      RowCount = 4
      FixedRows = 0
      Options = []
      ParentColor = True
      TabOrder = 0
      OnDrawCell = StatGridDrawCell
    end
  end
  object SpTBXGroupBox1: TSpTBXGroupBox
    Left = 8
    Top = 211
    Width = 337
    Height = 55
    Caption = 'Include problems incorrectly solved'
    Anchors = [akLeft, akBottom]
    TabOrder = 5
    object btDontCare: TSpTBXRadioButton
      Left = 10
      Top = 25
      Width = 65
      Height = 15
      Caption = 'don'#39't care'
      TabOrder = 0
      OnClick = btDontCareClick
    end
    object btProportion: TSpTBXRadioButton
      Left = 173
      Top = 26
      Width = 38
      Height = 15
      Caption = 'ratio'
      TabOrder = 1
      OnClick = btDontCareClick
    end
    object edFailureRatio: TEdit
      Left = 292
      Top = 24
      Width = 30
      Height = 21
      Enabled = False
      TabOrder = 2
      Text = '100'
    end
    object lbIncFailure: TSpTBXLabel
      Left = 323
      Top = 27
      Width = 8
      Height = 13
      Caption = '%'
      Enabled = False
      ParentColor = True
    end
  end
  object btOk: TSpTBXButton
    Left = 8
    Top = 359
    Width = 75
    Height = 25
    Caption = 'Ok'
    Anchors = [akLeft, akBottom]
    TabOrder = 0
    OnClick = btOkClick
    Default = True
  end
  object btCancel: TSpTBXButton
    Left = 88
    Top = 359
    Width = 75
    Height = 25
    Caption = 'Cancel'
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    OnClick = btCancelClick
    Cancel = True
  end
  object btHelp: TSpTBXButton
    Left = 168
    Top = 359
    Width = 75
    Height = 25
    Caption = '&Help'
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    OnClick = btHelpClick
  end
  object btMore: TSpTBXButton
    Left = 248
    Top = 359
    Width = 75
    Height = 25
    Caption = 'More...'
    Anchors = [akLeft, akBottom]
    TabOrder = 8
    DropDownMenu = SpTBXPopupMenu1
  end
  object SpTBXPopupMenu1: TSpTBXPopupMenu
    Left = 323
    Top = 362
    object SpTBXItem2: TSpTBXItem
      Caption = 'Show detailed statistics'
      OnClick = btShowStatClick
    end
    object SpTBXItem1: TSpTBXItem
      Caption = 'Reset collection statistics'
      OnClick = btResetStatClick
    end
    object mnShow: TSpTBXSubmenuItem
      Caption = 'Show...'
      object mnShowTimer: TSpTBXItem
        Caption = 'Timer'
        AutoCheck = True
      end
      object mnShowGlyphs: TSpTBXItem
        Caption = 'Glyphs'
        AutoCheck = True
      end
    end
  end
end
