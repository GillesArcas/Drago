object DBResultPicker: TDBResultPicker
  Left = 0
  Top = 0
  Width = 310
  Height = 53
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Color = 16250871
  ParentColor = False
  TabOrder = 0
  object lbDummy: TLabel
    Left = 136
    Top = 24
    Width = 3
    Height = 13
  end
  object seScore: TFloatSpinEdit
    Left = 255
    Top = 20
    Width = 45
    Height = 22
    Increment = 1.000000000000000000
    MaxValue = 99.500000000000000000
    TabOrder = 3
    Value = 99.500000000000000000
    OnChange = seScoreChange
  end
  inline PickerCaption: TfrDBPickerCaption
    Left = 0
    Top = 0
    Width = 310
    Height = 17
    Align = alTop
    TabOrder = 0
    inherited Bevel1: TBevel
      Width = 310
    end
    inherited CheckBox1: TCheckBox
      OnClick = PickerCaptionClick
    end
  end
  object cbPlayer: TTntComboBox
    Left = 8
    Top = 20
    Width = 96
    Height = 21
    BevelKind = bkSoft
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbPlayerChange
    Items.Strings = (
      'Black'
      'White'
      'One of both')
  end
  object cbResult: TTntComboBox
    Left = 111
    Top = 20
    Width = 142
    Height = 21
    BevelKind = bkSoft
    Style = csDropDownList
    DropDownCount = 10
    ItemHeight = 13
    TabOrder = 2
    OnChange = cbResultChange
    Items.Strings = (
      'wins'
      'wins by'
      'wins by at least'
      'wins by at most'
      'wins by resignation'
      'wins on time'
      'wins by forfeit'
      'Draw'
      'No result'
      'Other or unknown')
  end
end
