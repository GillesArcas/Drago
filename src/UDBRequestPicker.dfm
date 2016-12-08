object DBRequestPicker: TDBRequestPicker
  Left = 0
  Top = 0
  Width = 307
  Height = 144
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Color = 16250871
  ParentColor = False
  TabOrder = 0
  DesignSize = (
    307
    144)
  object Bevel3: TBevel
    Left = 256
    Top = 40
    Width = 41
    Height = 17
    Shape = bsFrame
  end
  object StringGrid: TControlStringgrid
    Left = 102
    Top = 21
    Width = 140
    Height = 91
    ColCount = 2
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goVertLine, goHorzLine, goEditing, goAlwaysShowEditor]
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyUp = StringGridKeyUp
    OnTopLeftChanged = StringGridTopLeftChanged
  end
  inline PickerCaption: TfrDBPickerCaption
    Left = 0
    Top = 0
    Width = 307
    Height = 17
    Align = alTop
    TabOrder = 8
    inherited Bevel1: TBevel
      Width = 307
    end
    inherited CheckBox1: TCheckBox
      OnClick = PickerCaptionClick
    end
  end
  object btAdd: TSpTBXButton
    Left = 7
    Top = 121
    Width = 75
    Height = 15
    Caption = 'Add'
    Anchors = [akLeft, akBottom]
    TabOrder = 5
    OnClick = btAddClick
  end
  object btRemove: TSpTBXButton
    Left = 82
    Top = 121
    Width = 75
    Height = 15
    Caption = 'Remove'
    Anchors = [akLeft, akBottom]
    TabOrder = 6
    OnClick = btRemoveClick
  end
  object btClear: TSpTBXButton
    Left = 157
    Top = 121
    Width = 75
    Height = 15
    Caption = 'Clear'
    Anchors = [akLeft, akBottom]
    TabOrder = 7
    OnClick = btClearClick
  end
  object ComboBox1: TSpTBXComboBox
    Left = 9
    Top = 21
    Width = 100
    Height = 21
    BevelKind = bkSoft
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboBox1Change
  end
  object ComboBox2: TSpTBXComboBox
    Left = 9
    Top = 45
    Width = 100
    Height = 21
    BevelKind = bkSoft
    ItemHeight = 13
    TabOrder = 2
    Text = 'ComboBox2'
  end
  object ComboBox3: TSpTBXComboBox
    Left = 9
    Top = 67
    Width = 100
    Height = 21
    BevelKind = bkSoft
    ItemHeight = 13
    TabOrder = 3
    Text = 'ComboBox3'
  end
  object ComboBox4: TSpTBXComboBox
    Left = 9
    Top = 91
    Width = 100
    Height = 21
    BevelKind = bkSoft
    ItemHeight = 13
    TabOrder = 4
    Text = 'ComboBox4'
    Visible = False
  end
end
