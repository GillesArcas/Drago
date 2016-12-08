object DBSQLPicker: TDBSQLPicker
  Left = 0
  Top = 0
  Width = 307
  Height = 126
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Color = 16250871
  ParentColor = False
  TabOrder = 0
  object Memo: TMemo
    Left = 0
    Top = 17
    Width = 307
    Height = 109
    Align = alClient
    Lines.Strings = (
      'Memo')
    ScrollBars = ssVertical
    TabOrder = 0
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
end
