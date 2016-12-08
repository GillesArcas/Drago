object frCfgShortcuts: TfrCfgShortcuts
  Left = 0
  Top = 0
  Width = 341
  Height = 374
  TabOrder = 0
  DesignSize = (
    341
    374)
  object Bevel1: TBevel
    Left = 4
    Top = 314
    Width = 335
    Height = 8
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 4
    Top = 262
    Width = 335
    Height = 8
    Shape = bsTopLine
  end
  object Label0: TTntLabel
    Left = 8
    Top = 3
    Width = 77
    Height = 13
    Caption = 'Select category:'
    Transparent = False
  end
  object Label1: TTntLabel
    Left = 10
    Top = 44
    Width = 82
    Height = 13
    Caption = 'Select command:'
    Transparent = False
  end
  object Label2: TTntLabel
    Left = 10
    Top = 269
    Width = 142
    Height = 13
    Caption = 'Click in box and type shortcut:'
    Transparent = False
  end
  object lbAssignedTo1: TTntLabel
    Left = 138
    Top = 286
    Width = 58
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Assigned to:'
    Transparent = False
  end
  object lbAssignedTo2: TTntLabel
    Left = 202
    Top = 286
    Width = 30
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '(none)'
    Transparent = False
  end
  object Label3: TTntLabel
    Left = 96
    Top = 332
    Width = 176
    Height = 13
    Caption = 'Assign shortcut to selected command'
    Transparent = False
  end
  object Label4: TTntLabel
    Left = 95
    Top = 356
    Width = 169
    Height = 13
    Caption = 'Clear shortcut of selected command'
    Transparent = False
  end
  object lvActions: TTntListView
    Left = 9
    Top = 60
    Width = 325
    Height = 191
    BevelInner = bvNone
    BevelOuter = bvRaised
    BevelKind = bkFlat
    BorderStyle = bsNone
    BorderWidth = 2
    Columns = <
      item
        Caption = '__Glyphs'
        Width = 24
      end
      item
        Caption = '__Commands'
        Width = 170
      end
      item
        Caption = '__Shortcuts'
        Width = 108
      end>
    DragMode = dmAutomatic
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    SmallImages = Actions.ImageList
    TabOrder = 1
    ViewStyle = vsReport
    OnSelectItem = lvActionsSelectItem
  end
  object edShortCutDesign: THotKey
    Left = 9
    Top = 285
    Width = 121
    Height = 21
    HotKey = 0
    InvalidKeys = []
    Modifiers = []
    TabOrder = 2
  end
  object cbCategories: TTntComboBox
    Left = 8
    Top = 18
    Width = 147
    Height = 21
    Style = csDropDownList
    DropDownCount = 10
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnSelect = cbCategoriesSelect
  end
  object btAssign: TTntButton
    Left = 8
    Top = 327
    Width = 75
    Height = 23
    Caption = 'Assign'
    TabOrder = 3
    OnClick = btAssignClick
  end
  object btClear: TTntButton
    Left = 8
    Top = 351
    Width = 75
    Height = 23
    Caption = 'Clear'
    TabOrder = 4
    OnClick = btClearClick
  end
end
