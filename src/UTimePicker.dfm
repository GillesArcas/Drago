object TimePicker: TTimePicker
  Left = 0
  Top = 0
  Width = 131
  Height = 22
  Color = clBtnFace
  ParentColor = False
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 1
    Width = 57
    Height = 22
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clWhite
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 4
      Width = 3
      Height = 13
      Caption = ':'
      Color = clWhite
      ParentColor = False
      Transparent = False
    end
    object UpDown1: TUpDown
      Left = 37
      Top = 1
      Width = 17
      Height = 19
      TabOrder = 0
      OnMouseDown = UpDown1MouseDown
      OnMouseUp = UpDown1MouseUp
    end
    object IntEdit1: TIntEdit
      Left = 4
      Top = 4
      Width = 12
      Height = 14
      BorderStyle = bsNone
      TabOrder = 1
      Text = '59'
      OnChange = IntEdit1Change
      OnClick = IntEdit1Click
      OnEnter = IntEdit1Enter
    end
    object IntEdit2: TIntEdit
      Left = 19
      Top = 4
      Width = 12
      Height = 14
      BorderStyle = bsNone
      TabOrder = 2
      Text = '59'
      OnChange = IntEdit1Change
      OnClick = IntEdit2Click
      OnEnter = IntEdit1Change
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 80
  end
end
