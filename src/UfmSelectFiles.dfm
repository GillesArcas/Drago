object fmSelectFiles: TfmSelectFiles
  Left = 572
  Top = 138
  Width = 358
  Height = 596
  Caption = 'Select files or folders...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    350
    562)
  PixelsPerInch = 96
  TextHeight = 13
  inline frSelectFiles: TfrSelectFiles
    Left = 0
    Top = 0
    Width = 349
    Height = 512
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object btOk: TSpTBXButton
    Left = 184
    Top = 522
    Width = 75
    Height = 25
    Caption = 'Ok'
    Anchors = [akRight, akBottom]
    TabOrder = 1
    OnClick = btOkClick
  end
  object btCancel: TSpTBXButton
    Left = 268
    Top = 522
    Width = 75
    Height = 25
    Caption = 'Cancel'
    Anchors = [akRight, akBottom]
    TabOrder = 2
    OnClick = btCancelClick
  end
end
