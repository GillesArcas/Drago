object fmExtract: TfmExtract
  Left = 425
  Top = 345
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'fmExtract'
  ClientHeight = 178
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 16
  object sbMore: TSpeedButton
    Left = 410
    Top = 34
    Width = 23
    Height = 22
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      040000000000800000000000000000000000100000001000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00111111111111
      1111111111111111111111111111111111111111111111111111111111111111
      1111111111111111111111111111111111111111111111111111110011100111
      0011110011100111001111111111111111111111111111111111111111111111
      1111111111111111111111111111111111111111111111111111}
    OnClick = sbMoreClick
  end
  object Label2: TTntLabel
    Left = 11
    Top = 9
    Width = 150
    Height = 16
    Caption = 'Select root for file names:'
    Transparent = False
  end
  object lbRoot: TTntLabel
    Left = 11
    Top = 71
    Width = 119
    Height = 16
    Caption = 'Export starting from:'
    Transparent = False
  end
  object edRoot: TTntEdit
    Left = 11
    Top = 34
    Width = 394
    Height = 24
    TabOrder = 0
    Text = 'edRoot'
    OnChange = edRootChange
  end
  object edName: TTntEdit
    Left = 11
    Top = 95
    Width = 394
    Height = 24
    Enabled = False
    TabOrder = 3
    Text = 'edName'
  end
  object btOk: TTntButton
    Left = 11
    Top = 143
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 1
    OnClick = btOkClick
  end
  object btCancel: TTntButton
    Left = 91
    Top = 143
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btCancelClick
  end
end
