object fmEnterGm: TfmEnterGm
  Left = 492
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__Replay mode'
  ClientHeight = 337
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    353
    337)
  PixelsPerInch = 96
  TextHeight = 13
  object rgMode: TSpTBXRadioGroup
    Left = 8
    Top = 8
    Width = 337
    Height = 49
    Caption = 'Select game2'
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    OnClick = rgModeClick
    Columns = 3
    Items.Strings = (
      'Loaded game'
      'Sequential'
      'Random')
  end
  object rgPlayWith: TSpTBXRadioGroup
    Left = 8
    Top = 64
    Width = 337
    Height = 49
    Caption = 'Play with'
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    Columns = 3
    Items.Strings = (
      'Black'
      'White'
      'Both')
  end
  object rgDepth: TSpTBXRadioGroup
    Left = 8
    Top = 120
    Width = 337
    Height = 106
    Caption = 'Play2'
    Anchors = [akLeft, akBottom]
    TabOrder = 5
    Items.Strings = (
      'Full game'
      'Fuseki'
      'From current position')
  end
  object btOk: TTntButton
    Left = 8
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    TabOrder = 0
    OnClick = btOkClick
  end
  object btCancel: TTntButton
    Left = 96
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btHelp: TTntButton
    Left = 268
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btHelpClick
  end
  object rgNbAttempts: TSpTBXRadioGroup
    Left = 8
    Top = 233
    Width = 337
    Height = 49
    Caption = 'Number of attempts per move'
    Anchors = [akLeft, akBottom]
    TabOrder = 6
    Columns = 2
    Items.Strings = (
      'Only one'
      'Unlimited')
  end
  object lbFuseki: TSpTBXLabel
    Left = 157
    Top = 171
    Width = 110
    Height = 13
    Caption = 'Move number in Fuseki'
    Alignment = taRightJustify
  end
  object edFuseki: TEdit
    Left = 269
    Top = 168
    Width = 46
    Height = 21
    TabOrder = 8
    Text = '10'
  end
  object UpDown: TUpDown
    Left = 315
    Top = 168
    Width = 16
    Height = 21
    Associate = edFuseki
    Min = 10
    Max = 200
    Increment = 10
    Position = 10
    TabOrder = 9
  end
end
