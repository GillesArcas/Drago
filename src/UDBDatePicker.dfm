object DBDatePicker: TDBDatePicker
  Left = 0
  Top = 0
  Width = 307
  Height = 75
  AutoScroll = False
  Color = 16775159
  ParentColor = False
  TabOrder = 0
  DesignSize = (
    307
    75)
  object lbDate: TLabel
    Left = 11
    Top = 50
    Width = 31
    Height = 13
    Caption = 'lbDate'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3158064
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbTo: TTntLabel
    Left = 200
    Top = 49
    Width = 12
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'To'
    Transparent = False
  end
  inline DateFrom: TDatePicker
    Left = 220
    Top = 19
    Width = 80
    Height = 23
    AutoScroll = False
    Color = clBtnFace
    ParentColor = False
    TabOrder = 3
  end
  inline DateTo: TDatePicker
    Left = 220
    Top = 44
    Width = 80
    Height = 23
    AutoScroll = False
    Color = clBtnFace
    ParentColor = False
    TabOrder = 4
    inherited Panel1: TPanel
      inherited IntEdit1: TIntEdit
        Left = 5
      end
    end
  end
  inline PickerCaption: TfrDBPickerCaption
    Left = 0
    Top = 0
    Width = 307
    Height = 17
    Align = alTop
    TabOrder = 1
    inherited Bevel1: TBevel
      Width = 307
    end
    inherited CheckBox1: TCheckBox
      OnClick = PickerCaptionClick
    end
  end
  object cxRange: TSpTBXCheckBox
    Left = 142
    Top = 24
    Width = 49
    Height = 15
    Caption = 'Range'
    ParentColor = True
    TabOrder = 0
    OnClick = cxRangeClick
  end
  object cbUnit: TSpTBXComboBox
    Left = 8
    Top = 21
    Width = 128
    Height = 21
    AutoComplete = False
    AutoDropDown = True
    BevelKind = bkSoft
    Style = csDropDownList
    DropDownCount = 4
    ItemHeight = 13
    TabOrder = 2
    OnChange = cbUnitChange
    Items.Strings = (
      'Day'
      'Month'
      'Year')
  end
end
