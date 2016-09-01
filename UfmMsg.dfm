object fmMsg: TfmMsg
  Left = 323
  Top = 225
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Drago'
  ClientHeight = 140
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = TntFormCreate
  DesignSize = (
    316
    140)
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 8
    Top = 8
    Width = 42
    Height = 42
    Transparent = True
  end
  object Bevel1: TTntBevel
    Left = 0
    Top = 96
    Width = 321
    Height = 3
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object Button1: TTntButton
    Left = 56
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '__Button1'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TTntButton
    Left = 136
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '__Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TTntButton
    Left = 216
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '__Button3'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Memo: TTntMemo
    Left = 56
    Top = 16
    Width = 249
    Height = 25
    BevelEdges = []
    BevelInner = bvNone
    BevelKind = bkFlat
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Memo')
    ReadOnly = True
    TabOrder = 4
    OnMouseMove = MemoMouseMove
  end
  object CheckBox: TSpTBXCheckBox
    Left = 8
    Top = 112
    Width = 165
    Height = 15
    Caption = 'Don'#39't show this message again'
    Anchors = [akLeft, akBottom]
    ParentColor = True
    TabOrder = 3
  end
end
