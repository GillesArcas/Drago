object fmUserSaveFolder: TfmUserSaveFolder
  Left = 387
  Top = 371
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Save folder...'
  ClientHeight = 234
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 16
  object Bevel2: TBevel
    Left = 16
    Top = 184
    Width = 398
    Height = 3
    Shape = bsTopLine
  end
  object btSelect: TTntButton
    Left = 268
    Top = 144
    Width = 72
    Height = 20
    Caption = 'Select all'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btSelectClick
  end
  object btUnselect: TTntButton
    Left = 344
    Top = 144
    Width = 72
    Height = 20
    Caption = 'Unselect all'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btUnselectClick
  end
  object btOk: TTntButton
    Left = 16
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 3
    OnClick = btOkClick
  end
  object btCancel: TTntButton
    Left = 176
    Top = 200
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    OnClick = btCancelClick
  end
  object btHelp: TTntButton
    Left = 256
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 5
  end
  object btIgnore: TTntButton
    Left = 96
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Ignore'
    TabOrder = 6
    OnClick = btIgnoreClick
  end
  object lbFolder: TSpTBXLabel
    Left = 16
    Top = 16
    Width = 130
    Height = 16
    Caption = 'Files modified in folder'
    ParentColor = True
  end
  object Label2: TSpTBXLabel
    Left = 18
    Top = 145
    Width = 112
    Height = 16
    Caption = 'Select files to save:'
    ParentColor = True
  end
  object CheckListBox: TTntCheckListBox
    Left = 16
    Top = 40
    Width = 401
    Height = 97
    ItemHeight = 16
    TabOrder = 0
  end
end
