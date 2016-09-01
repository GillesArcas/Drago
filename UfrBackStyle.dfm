object frBackStyle: TfrBackStyle
  Left = 0
  Top = 0
  Width = 319
  Height = 63
  TabOrder = 0
  object GroupBox: TTntGroupBox
    Left = 0
    Top = 0
    Width = 319
    Height = 63
    Align = alClient
    Caption = '__Area'
    TabOrder = 0
    DesignSize = (
      319
      63)
    object Image1: TImage
      Left = 264
      Top = 12
      Width = 48
      Height = 47
    end
    object Bevel1: TBevel
      Left = 264
      Top = 11
      Width = 50
      Height = 49
      Shape = bsFrame
    end
    object Button1: TTntRadioButton
      Left = 8
      Top = 18
      Width = 121
      Height = 12
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Default texture'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TTntRadioButton
      Left = 140
      Top = 18
      Width = 123
      Height = 17
      Caption = 'Custom texture'
      TabOrder = 1
      OnKeyPress = Button2KeyPress
      OnMouseDown = Button2MouseDown
    end
    object Button3: TTntRadioButton
      Left = 8
      Top = 40
      Width = 129
      Height = 17
      Caption = 'Color'
      TabOrder = 2
      OnKeyPress = Button3KeyPress
      OnMouseDown = Button3MouseDown
    end
    object Button4: TTntRadioButton
      Left = 140
      Top = 40
      Width = 123
      Height = 17
      Caption = 'As board'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object ColorDialog: TColorDialog
    Left = 160
    Top = 40
  end
end
