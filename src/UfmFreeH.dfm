object fmFreeH: TfmFreeH
  Left = 625
  Top = 308
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__fmFreeH'
  ClientHeight = 158
  ClientWidth = 171
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
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 4
    Top = 75
    Width = 163
    Height = 29
  end
  object Bevel: TBevel
    Left = 8
    Top = 88
    Width = 153
    Height = 25
    Shape = bsFrame
  end
  object Label1: TSpTBXLabel
    Left = 8
    Top = 8
    Width = 153
    Height = 13
    Caption = '__Label1'
    ParentColor = True
    Wrapping = twWrap
  end
  object btOk: TSpTBXButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = btOkClick
    Default = True
  end
  object btCancel: TSpTBXButton
    Left = 88
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
    Cancel = True
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 88
    Top = 32
  end
end
