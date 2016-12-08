object fmEnterJo: TfmEnterJo
  Left = 253
  Top = 108
  Width = 362
  Height = 172
  Caption = '__Mode Joseki'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object rgJouerAvec: TRadioGroup
    Left = 8
    Top = 8
    Width = 337
    Height = 41
    Caption = 'Play with'
    Columns = 3
    Items.Strings = (
      'Black'
      'White'
      'Both')
    TabOrder = 0
  end
  object btOk: TButton
    Left = 9
    Top = 115
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 1
    OnClick = btOkClick
  end
  object GroupBox: TGroupBox
    Left = 8
    Top = 56
    Width = 337
    Height = 49
    TabOrder = 2
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 141
      Height = 13
      Caption = 'Nombre de sequences jouees'
    end
    object UpDown: TUpDown
      Left = 305
      Top = 16
      Width = 16
      Height = 21
      Associate = Edit
      Min = 1
      Max = 200
      Position = 10
      TabOrder = 0
    end
    object Edit: TEdit
      Left = 211
      Top = 16
      Width = 94
      Height = 21
      TabOrder = 1
      Text = '10'
    end
  end
  object btAnnuler: TButton
    Left = 96
    Top = 115
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btAnnulerClick
  end
end
