object fmExportPos: TfmExportPos
  Left = 673
  Top = 161
  Anchors = [akLeft, akTop, akBottom]
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Export position'
  ClientHeight = 462
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    493
    462)
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 7
    Top = 7
    Width = 205
    Height = 205
  end
  object Bevel: TBevel
    Left = 152
    Top = 152
    Width = 50
    Height = 50
    Shape = bsFrame
  end
  object pnOption: TPanel
    Left = 256
    Top = 24
    Width = 205
    Height = 32
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object lbAsBooks: TSpTBXLabel
      Left = 8
      Top = 9
      Width = 70
      Height = 13
      Caption = 'Move numbers'
      ParentColor = True
    end
    object cbAsBooks: TTntComboBox
      Left = 108
      Top = 5
      Width = 88
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAsBooksChange
      Items.Strings = (
        'As board'
        'As books')
    end
  end
  object pnFormat: TPanel
    Left = 256
    Top = 96
    Width = 205
    Height = 169
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 6
    object cb1: TComboBox
      Left = 96
      Top = 4
      Width = 100
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 0
      Text = 'Sensei'#39's Library'
      OnChange = cb1Change
      Items.Strings = (
        'rec.games.go'
        'Sensei'#39's Library')
    end
    object cb4: TComboBox
      Left = 96
      Top = 70
      Width = 100
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'X'
      Items.Strings = (
        'X'
        '#')
    end
    object cb3: TComboBox
      Left = 96
      Top = 48
      Width = 100
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = '.'
      Items.Strings = (
        '.'
        ','
        '+')
    end
    object ie1: TIntEdit
      Left = 96
      Top = 92
      Width = 100
      Height = 21
      TabOrder = 5
      Text = '0'
    end
    object lb1: TSpTBXLabel
      Left = 8
      Top = 8
      Width = 26
      Height = 13
      Caption = 'Mode'
      ParentColor = True
    end
    object lb4: TSpTBXLabel
      Left = 8
      Top = 73
      Width = 24
      Height = 13
      Caption = 'Black'
      ParentColor = True
    end
    object lb3: TSpTBXLabel
      Left = 8
      Top = 51
      Width = 31
      Height = 13
      Caption = 'Hoshis'
      ParentColor = True
    end
    object lb2: TSpTBXLabel
      Left = 8
      Top = 29
      Width = 52
      Height = 13
      Caption = 'Draw edge'
      ParentColor = True
    end
    object lb5: TSpTBXLabel
      Left = 8
      Top = 95
      Width = 28
      Height = 13
      Caption = 'White'
      ParentColor = True
    end
    object sg1: TTntStringGrid
      Left = 8
      Top = 120
      Width = 187
      Height = 84
      ColCount = 2
      Ctl3D = False
      DefaultRowHeight = 20
      RowCount = 10
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object cb2: TTntComboBox
      Left = 96
      Top = 26
      Width = 100
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      Text = 'Yes'
      Items.Strings = (
        'Yes'
        'No')
    end
  end
  object btClipboard: TTntButton
    Left = 7
    Top = 405
    Width = 90
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Clipboard'
    TabOrder = 0
    OnClick = btClipboardClick
  end
  object btSave: TTntButton
    Left = 7
    Top = 433
    Width = 90
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save'
    TabOrder = 1
    OnClick = btSaveClick
  end
  object btCancel: TTntButton
    Left = 120
    Top = 433
    Width = 90
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btHelp: TTntButton
    Left = 120
    Top = 405
    Width = 90
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btHelpClick
  end
  object gbFormat: TSpTBXGroupBox
    Left = 7
    Top = 326
    Width = 205
    Height = 73
    Caption = 'Format'
    SkinType = sknWindows
    ParentColor = True
    TabOrder = 5
    DesignSize = (
      205
      73)
    object sbFormat: TSpeedButton
      Left = 174
      Top = 2
      Width = 10
      Height = 10
      Layout = blGlyphTop
      Spacing = 0
      OnClick = sbFormatClick
    end
    object rbPNG: TSpTBXRadioButton
      Left = 136
      Top = 14
      Width = 38
      Height = 15
      Caption = 'PNG'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 2
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbWMF: TSpTBXRadioButton
      Left = 8
      Top = 14
      Width = 42
      Height = 15
      Caption = 'WMF'
      Color = clMenuBar
      Anchors = [akLeft, akBottom]
      TabOrder = 0
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbGIF: TSpTBXRadioButton
      Left = 80
      Top = 14
      Width = 35
      Height = 15
      Caption = 'GIF'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 1
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbJPG: TSpTBXRadioButton
      Left = 8
      Top = 32
      Width = 42
      Height = 15
      Caption = 'JPEG'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 3
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbBMP: TSpTBXRadioButton
      Left = 80
      Top = 32
      Width = 38
      Height = 15
      Caption = 'BMP'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 4
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbASC: TSpTBXRadioButton
      Left = 8
      Top = 52
      Width = 46
      Height = 15
      Caption = 'ASCII'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 5
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbSGF: TSpTBXRadioButton
      Left = 80
      Top = 52
      Width = 37
      Height = 15
      Caption = 'SGF'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 6
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
    object rbPDF: TSpTBXRadioButton
      Left = 136
      Top = 32
      Width = 37
      Height = 15
      Caption = 'PDF'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 7
      OnClick = rbWMFClick
      SkinType = sknWindows
    end
  end
  object gbOption: TSpTBXGroupBox
    Left = 8
    Top = 217
    Width = 205
    Height = 109
    HelpContext = 100
    Caption = 'Options'
    TabOrder = 7
    object sbOption: TSpeedButton
      Left = 174
      Top = 2
      Width = 10
      Height = 10
      Spacing = 0
      OnClick = sbOptionClick
    end
    object gbDim: TSpTBXGroupBox
      Left = 6
      Top = 46
      Width = 193
      Height = 57
      Caption = 'Dimensions (px)'
      TabOrder = 0
      DesignSize = (
        193
        57)
      object ieWidth: TIntEdit
        Left = 102
        Top = 11
        Width = 32
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 0
        Text = '9999'
        OnChange = ieWidthChange
      end
      object ieHeight: TIntEdit
        Left = 153
        Top = 11
        Width = 32
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 1
        Text = '9999'
        OnChange = ieHeightChange
      end
      object ieDiam: TIntEdit
        Left = 153
        Top = 31
        Width = 32
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 2
        Text = '99'
        OnChange = ieDiamChange
      end
      object lbWidth: TSpTBXLabel
        Left = 94
        Top = 14
        Width = 5
        Height = 13
        Caption = 'L'
        Anchors = [akLeft, akBottom]
        ParentColor = True
      end
      object lbHeight: TSpTBXLabel
        Left = 142
        Top = 14
        Width = 7
        Height = 13
        Caption = 'H'
        Anchors = [akLeft, akBottom]
        ParentColor = True
      end
      object lbBoard: TSpTBXLabel
        Left = 8
        Top = 14
        Width = 28
        Height = 13
        Caption = 'Board'
        Anchors = [akLeft, akBottom]
        ParentColor = True
      end
      object lbStone: TSpTBXLabel
        Left = 8
        Top = 34
        Width = 73
        Height = 13
        Caption = 'Stone diameter'
        Anchors = [akLeft, akBottom]
        ParentColor = True
      end
    end
    object GroupBox1: TSpTBXGroupBox
      Left = 7
      Top = 12
      Width = 192
      Height = 34
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -3
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      DesignSize = (
        192
        34)
      object edZone: TEdit
        Left = 132
        Top = 9
        Width = 52
        Height = 21
        Anchors = [akLeft, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = 'M19:M19'
        OnChange = edZoneChange
      end
      object lbRect: TSpTBXLabel
        Left = 8
        Top = 12
        Width = 88
        Height = 13
        Caption = '__Image rectangle'
        Anchors = [akLeft, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = True
        ParentFont = False
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'jpg'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 115
    Top = 170
  end
end
