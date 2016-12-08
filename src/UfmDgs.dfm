object fmDgs: TfmDgs
  Left = 528
  Top = 282
  Width = 653
  Height = 440
  Caption = 'DGS'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 8
    Top = 40
    Width = 617
    Height = 120
    ColCount = 6
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 8
    Top = 256
    Width = 617
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object btConnect: TButton
    Left = 8
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btConnectClick
  end
  object btStatus: TButton
    Left = 88
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Status'
    TabOrder = 3
    OnClick = btStatusClick
  end
end
