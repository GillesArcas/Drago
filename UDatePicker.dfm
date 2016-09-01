object DatePicker: TDatePicker
  Left = 0
  Top = 0
  Width = 120
  Height = 22
  AutoScroll = False
  Color = clBtnFace
  ParentColor = False
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 80
    Height = 22
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clWhite
    TabOrder = 0
    object Label1: TLabel
      Left = 28
      Top = 4
      Width = 4
      Height = 13
      Caption = '-'
      Color = clWhite
      ParentColor = False
    end
    object Label2: TLabel
      Left = 43
      Top = 4
      Width = 4
      Height = 13
      Caption = '-'
    end
    object UpDown1: TUpDown
      Left = 61
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
      Width = 24
      Height = 14
      BorderStyle = bsNone
      TabOrder = 1
      Text = '2006'
      OnChange = IntEdit1Change
      OnClick = IntEdit1Click
      OnExit = IntEdit1Exit
    end
    object IntEdit2: TIntEdit
      Left = 31
      Top = 4
      Width = 12
      Height = 14
      BorderStyle = bsNone
      TabOrder = 2
      Text = '11'
      OnChange = IntEdit1Change
      OnClick = IntEdit2Click
      OnExit = IntEdit2Exit
    end
    object IntEdit3: TIntEdit
      Left = 46
      Top = 4
      Width = 12
      Height = 14
      BorderStyle = bsNone
      TabOrder = 3
      Text = '11'
      OnChange = IntEdit1Change
      OnClick = IntEdit3Click
      OnExit = IntEdit3Exit
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 96
    Top = 16
  end
end
