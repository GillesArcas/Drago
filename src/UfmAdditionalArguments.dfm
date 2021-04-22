object fmAdditionalArguments: TfmAdditionalArguments
  Left = 445
  Top = 234
  Width = 454
  Height = 260
  Caption = 'Additional arguments'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object edAddtionalArgs: TSpTBXEdit
    Left = 16
    Top = 128
    Width = 409
    Height = 21
    TabOrder = 5
    OnChange = edAddtionalArgsChange
  end
  object btOk: TSpTBXButton
    Left = 16
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = btOkClick
    Default = True
  end
  object btCancel: TSpTBXButton
    Left = 96
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
    Cancel = True
  end
  object btHelp: TSpTBXButton
    Left = 176
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 2
  end
  object lbCustom: TSpTBXLabel
    Left = 18
    Top = 22
    Width = 407
    Height = 26
    Caption = 
      'Rules, timing, boardsize and level arguments are predefined. Add' +
      'itional arguments for current engine may be entered here.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Wrapping = twWrap
  end
  object edArgs: TSpTBXEdit
    Left = 16
    Top = 80
    Width = 409
    Height = 21
    TabStop = False
    Enabled = False
    ReadOnly = True
    TabOrder = 3
  end
  object SpTBXLabel1: TSpTBXLabel
    Left = 18
    Top = 64
    Width = 95
    Height = 13
    Caption = 'Current parameters'
  end
  object SpTBXLabel2: TSpTBXLabel
    Left = 18
    Top = 112
    Width = 105
    Height = 13
    Caption = 'Additional parameters'
  end
end
