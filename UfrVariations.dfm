object frVariations: TfrVariations
  Left = 0
  Top = 0
  Width = 273
  Height = 240
  TabOrder = 0
  object lbVariation: TTntListBox
    Left = 0
    Top = 0
    Width = 273
    Height = 240
    Style = lbOwnerDrawFixed
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ItemHeight = 21
    TabOrder = 0
    OnDrawItem = lbVariationDrawItem
  end
end
