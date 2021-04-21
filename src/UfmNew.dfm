object fmNew: TfmNew
  Left = 542
  Top = 271
  Anchors = []
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__Drago - New game'
  ClientHeight = 227
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = TntFormClose
  OnCreate = fmNewCreate
  OnShow = TntFormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 264
    Top = 560
    Width = 109
    Height = 13
    Caption = 'Original dims: 269x441'
  end
  object btOk: TTntButton
    Left = 17
    Top = 187
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 0
    OnClick = btOkClick
  end
  object btCancel: TTntButton
    Left = 99
    Top = 187
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btHelp: TTntButton
    Left = 181
    Top = 187
    Width = 75
    Height = 25
    Caption = '&Help'
    TabOrder = 2
    OnClick = btHelpClick
  end
  object pnValues: TSpTBXGroupBox
    Left = 16
    Top = 16
    Width = 257
    Height = 91
    Caption = 'Game settings'
    Color = clBtnFace
    UseDockManager = True
    TabOrder = 3
    object Bevel1: TBevel
      Left = 118
      Top = 13
      Width = 6
      Height = 67
      Shape = bsLeftLine
    end
    object lbSize: TTntLabel
      Left = 8
      Top = 20
      Width = 19
      Height = 13
      Caption = 'Size'
      Transparent = False
    end
    object lbHandicap: TTntLabel
      Left = 125
      Top = 20
      Width = 44
      Height = 13
      Caption = 'Handicap'
      Transparent = False
    end
    object lbKomi: TTntLabel
      Left = 10
      Top = 53
      Width = 22
      Height = 13
      Caption = 'Komi'
      Transparent = False
    end
    object cbSize: TComboBox
      Left = 56
      Top = 16
      Width = 57
      Height = 21
      DropDownCount = 3
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbSizeChange
      Items.Strings = (
        '9'
        '13'
        '19')
    end
    object cbHandicap: TComboBox
      Left = 176
      Top = 16
      Width = 57
      Height = 21
      Style = csDropDownList
      DropDownCount = 10
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbHandicapChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9')
    end
    object cbKomi: TComboBox
      Left = 56
      Top = 51
      Width = 57
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        '0'
        '0.5'
        '5.5'
        '6.5'
        '7.5'
        '8')
    end
    object ckFree: TTntCheckBox
      Left = 125
      Top = 54
      Width = 97
      Height = 17
      Caption = 'Free placement'
      TabOrder = 3
    end
  end
  object rgCreateIn: TSpTBXRadioGroup
    Left = 16
    Top = 112
    Width = 257
    Height = 49
    Caption = 'Create in'
    ParentColor = True
    TabOrder = 4
    Columns = 2
    Items.Strings = (
      'New file'
      'Current file')
  end
end
