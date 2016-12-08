object fmCustomStones: TfmCustomStones
  Left = 404
  Top = 144
  BorderStyle = bsSingle
  Caption = 'Select custom stones...'
  ClientHeight = 257
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 32
    Top = 136
    Width = 449
    Height = 9
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 32
    Top = 176
    Width = 449
    Height = 9
    Shape = bsTopLine
  end
  object SpTBXLabel1: TSpTBXLabel
    Left = 32
    Top = 24
    Width = 101
    Height = 13
    Caption = 'Path for Black stones'
  end
  object SpTBXLabel2: TSpTBXLabel
    Left = 32
    Top = 56
    Width = 102
    Height = 13
    Caption = 'Path for White stones'
  end
  object SpTBXLabel3: TSpTBXLabel
    Left = 32
    Top = 152
    Width = 58
    Height = 13
    Caption = 'Light source'
  end
  object edBlackPath: TSpTBXEdit
    Left = 175
    Top = 20
    Width = 275
    Height = 21
    TabOrder = 3
    Text = 'edBlackPath'
  end
  object edWhitePath: TSpTBXEdit
    Left = 175
    Top = 52
    Width = 275
    Height = 21
    TabOrder = 4
    Text = 'SpTBXEdit1'
  end
  object btSelectBlackPath: TSpTBXButton
    Left = 450
    Top = 17
    Width = 35
    Height = 25
    Caption = '...'
    TabOrder = 5
    OnClick = btSelectBlackPathClick
  end
  object btSelectWhitePath: TSpTBXButton
    Left = 450
    Top = 49
    Width = 35
    Height = 25
    Caption = '...'
    TabOrder = 6
    OnClick = btSelectWhitePathClick
  end
  object SpTBXLabel4: TSpTBXLabel
    Left = 32
    Top = 96
    Width = 450
    Height = 26
    Caption = 
      'Stone names should include a number specifying the diameter. If ' +
      'names include a second number, it identifies some variation of t' +
      'he graphism.'
    Wrapping = twWrap
  end
  object btOk: TSpTBXButton
    Left = 32
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 8
    OnClick = btOkClick
    Default = True
  end
  object btCancel: TSpTBXButton
    Left = 112
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 9
    OnClick = btCancelClick
    Cancel = True
  end
  object btHelp: TSpTBXButton
    Left = 408
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 10
    OnClick = btHelpClick
  end
  object cbLightSource: TTntComboBox
    Left = 175
    Top = 145
    Width = 275
    Height = 21
    ItemHeight = 13
    TabOrder = 11
    Text = 'cbLightSource'
    Items.Strings = (
      'Top left'
      'Top right'
      'None')
  end
end
