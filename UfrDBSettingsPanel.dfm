object frDBSettingsPanel: TfrDBSettingsPanel
  Left = 0
  Top = 0
  Width = 301
  Height = 468
  TabOrder = 0
  DesignSize = (
    301
    468)
  inline BaseNamePicker: TDBBaseNamePicker
    Left = 0
    Top = 3
    Width = 300
    Height = 73
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    inherited SpTBXGroupBox1: TSpTBXGroupBox
      Left = 4
      Top = -1
      Width = 293
      inherited sbOpen: TTntSpeedButton
        Left = 262
        Top = 16
        Width = 26
        Height = 26
        OnClick = BaseNamePickersbOpenClick
      end
      inherited cbName: TComboBox
        Width = 253
        OnChange = BaseNamePickercbNameChange
      end
    end
  end
  object rgPatternSearchView: TSpTBXRadioGroup
    Left = 4
    Top = 269
    Width = 292
    Height = 50
    Caption = 'Pattern search view'
    TabOrder = 1
    Columns = 3
    Items.Strings = (
      'Kombilo'
      'Full'
      'Digest')
  end
  object btOk: TSpTBXButton
    Left = 8
    Top = 432
    Width = 75
    Height = 25
    Caption = 'Ok'
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    OnClick = btOkClick
  end
  object btCancel: TSpTBXButton
    Left = 88
    Top = 432
    Width = 75
    Height = 25
    Caption = 'Cancel'
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btHelp: TSpTBXButton
    Left = 168
    Top = 432
    Width = 75
    Height = 25
    Caption = 'Help'
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    OnClick = btHelpClick
  end
  object rgNextMove: TSpTBXRadioGroup
    Left = 4
    Top = 191
    Width = 292
    Height = 73
    Caption = 'Pattern search next move'
    TabOrder = 5
    Columns = 2
    Items.Strings = (
      'Black'
      'Any or none'
      'White'
      'Alternate')
  end
  object SpTBXGroupBox1: TSpTBXGroupBox
    Left = 4
    Top = 72
    Width = 292
    Height = 113
    Caption = 'Pattern search parameters'
    TabOrder = 6
    DesignSize = (
      292
      113)
    object cbFixedColor: TSpTBXCheckBox
      Left = 10
      Top = 22
      Width = 250
      Height = 15
      Caption = 'Fixed color'
      Anchors = [akLeft, akBottom]
      AutoSize = False
      ParentColor = True
      TabOrder = 0
    end
    object cbFixedPos: TSpTBXCheckBox
      Left = 10
      Top = 41
      Width = 250
      Height = 15
      Caption = 'Fixed position'
      Anchors = [akLeft, akBottom]
      AutoSize = False
      ParentColor = True
      TabOrder = 1
    end
    object cxSearchVar: TSpTBXCheckBox
      Left = 10
      Top = 60
      Width = 250
      Height = 15
      Caption = 'Search in variations'
      AutoSize = False
      ParentColor = True
      TabOrder = 2
    end
    object edMoveLimit: TIntEdit
      Left = 155
      Top = 87
      Width = 130
      Height = 21
      TabOrder = 3
      Text = '0'
    end
    object Label11: TSpTBXLabel
      Left = 12
      Top = 90
      Width = 47
      Height = 13
      Caption = 'Move limit'
      ParentColor = True
    end
  end
end
