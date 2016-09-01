object frDBRequestPanel: TfrDBRequestPanel
  Left = 0
  Top = 0
  Width = 305
  Height = 572
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  TabOrder = 0
  object Bevel1: TBevel
    Left = 0
    Top = 111
    Width = 305
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  object Bevel2: TBevel
    Left = 0
    Top = 189
    Width = 305
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  object Bevel3: TBevel
    Left = 0
    Top = 245
    Width = 305
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  object Bevel4: TBevel
    Left = 0
    Top = 392
    Width = 305
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  inline ResultPicker: TDBResultPicker
    Left = 0
    Top = 192
    Width = 305
    Height = 53
    HorzScrollBar.Visible = False
    VertScrollBar.Visible = False
    Align = alTop
    Color = 16250871
    ParentColor = False
    TabOrder = 2
    TabStop = True
    inherited PickerCaption: TfrDBPickerCaption
      Width = 305
      inherited Bevel1: TBevel
        Width = 305
      end
    end
  end
  inline RequestPicker: TDBRequestPicker
    Left = 0
    Top = 248
    Width = 305
    Height = 144
    HorzScrollBar.Visible = False
    VertScrollBar.Visible = False
    Align = alTop
    Color = 16250871
    ParentColor = False
    TabOrder = 3
    TabStop = True
    inherited PickerCaption: TfrDBPickerCaption
      Width = 305
      inherited Bevel1: TBevel
        Width = 305
      end
    end
  end
  inline DatePicker: TDBDatePicker
    Left = 0
    Top = 114
    Width = 305
    Height = 75
    Align = alTop
    AutoScroll = False
    Color = 16250871
    ParentColor = False
    TabOrder = 1
    inherited PickerCaption: TfrDBPickerCaption
      Width = 305
      inherited Bevel1: TBevel
        Width = 305
      end
    end
  end
  inline PlayerPicker: TDBPlayerPicker
    Left = 0
    Top = 0
    Width = 305
    Height = 111
    Align = alTop
    Color = 16250871
    ParentColor = False
    TabOrder = 0
    inherited PickerCaption: TfrDBPickerCaption
      Width = 305
      inherited Bevel1: TBevel
        Width = 305
      end
    end
  end
  inline SQLPicker: TDBSQLPicker
    Left = 0
    Top = 395
    Width = 305
    Height = 94
    HorzScrollBar.Visible = False
    VertScrollBar.Visible = False
    Align = alTop
    Color = 16250871
    ParentColor = False
    TabOrder = 4
    inherited Memo: TMemo
      Width = 305
      Height = 77
    end
    inherited PickerCaption: TfrDBPickerCaption
      Width = 305
      inherited Bevel1: TBevel
        Width = 305
      end
    end
  end
end
