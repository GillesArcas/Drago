object fmFactorize: TfmFactorize
  Left = 421
  Top = 104
  BorderStyle = bsSingle
  Caption = 'Make game tree'
  ClientHeight = 365
  ClientWidth = 558
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 325
    Width = 557
    Height = 4
    Shape = bsTopLine
  end
  object btStart: TSpTBXButton
    Left = 15
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btStartClick
    Default = True
    SkinType = sknWindows
  end
  object btClose: TSpTBXButton
    Left = 95
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = btCloseClick
    Cancel = True
    SkinType = sknWindows
  end
  object ProgressBar: TSpTBXProgressBar
    Left = 8
    Top = 338
    Width = 542
    Height = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    CaptionGlow = gldNone
    CaptionType = pctNone
    Smooth = True
    SkinType = sknWindows
  end
  object cxTewari: TSpTBXCheckBox
    Left = 296
    Top = 2
    Width = 205
    Height = 15
    Caption = 'Detect move inversions (keep invisible!)'
    TabOrder = 5
    Visible = False
  end
  object ListBox: TTntMemo
    Left = 264
    Top = 14
    Width = 281
    Height = 299
    Lines.Strings = (
      'ListBox')
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object rgReference: TSpTBXRadioGroup
    Left = 16
    Top = 192
    Width = 233
    Height = 75
    Caption = 'Game reference'
    TabOrder = 6
    Items.Strings = (
      'None'
      'Filename'
      'Signature')
  end
  object rgSource: TSpTBXRadioGroup
    Left = 16
    Top = 8
    Width = 233
    Height = 57
    Caption = 'Games to process'
    ParentColor = True
    TabOrder = 3
    Items.Strings = (
      'Process current tab'
      'Select files or folders to process')
  end
  object btHelp: TSpTBXButton
    Left = 175
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 7
    OnClick = btHelpClick
  end
  object SpTBXGroupBox1: TSpTBXGroupBox
    Left = 16
    Top = 80
    Width = 233
    Height = 97
    Caption = 'Parameters'
    TabOrder = 8
    object SpTBXLabel1: TSpTBXLabel
      Left = 8
      Top = 24
      Width = 29
      Height = 13
      Caption = 'Depth'
      SkinType = sknWindows
    end
    object edDepth: TTntEdit
      Left = 166
      Top = 19
      Width = 60
      Height = 21
      TabOrder = 1
      Text = 'edDepth'
    end
    object edUnique: TTntEdit
      Left = 166
      Top = 44
      Width = 60
      Height = 21
      TabOrder = 2
      Text = 'edDepth'
    end
    object SpTBXLabel2: TSpTBXLabel
      Left = 8
      Top = 49
      Width = 68
      Height = 13
      Caption = 'Unique moves'
    end
    object cxNormPos: TSpTBXCheckBox
      Left = 8
      Top = 72
      Width = 163
      Height = 15
      Caption = 'Normalize position of first move'
      TabOrder = 4
    end
  end
end
