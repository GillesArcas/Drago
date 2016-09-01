object fmRemProp: TfmRemProp
  Left = 569
  Top = 303
  BorderStyle = bsSingle
  Caption = 'fmRemProp'
  ClientHeight = 171
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SpTBXLabel1: TSpTBXLabel
    Left = 24
    Top = 24
    Width = 262
    Height = 13
    Caption = 'Enter list of properties separated by commas (C,BL,WL):'
  end
  object edProperties: TSpTBXEdit
    Left = 24
    Top = 40
    Width = 337
    Height = 24
    TabOrder = 1
  end
  object btOk: TSpTBXButton
    Left = 24
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = btOkClick
    Default = True
  end
  object btCancel: TSpTBXButton
    Left = 104
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btCancelClick
    Cancel = True
  end
  object btHelp: TSpTBXButton
    Left = 288
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 4
    OnClick = btHelpClick
  end
  object rgGames: TSpTBXRadioGroup
    Left = 24
    Top = 72
    Width = 337
    Height = 33
    TabOrder = 5
    Columns = 2
    Items.Strings = (
      'Current game'
      'All games in collection')
  end
end
