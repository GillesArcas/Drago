object fmInputQueryInt: TfmInputQueryInt
  Left = 375
  Top = 282
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = '__fmInputQueryInt'
  ClientHeight = 101
  ClientWidth = 274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = TntFormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IntEdit1: TIntEdit
    Left = 16
    Top = 32
    Width = 244
    Height = 21
    TabOrder = 0
    Text = '0'
  end
  object Label1: TSpTBXLabel
    Left = 16
    Top = 16
    Width = 44
    Height = 13
    Caption = '__Label1'
    ParentColor = True
  end
  object btOk: TTntButton
    Left = 64
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 1
    OnClick = btOkClick
  end
  object btCancel: TTntButton
    Left = 144
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btCancelClick
  end
end
