object fmTesting: TfmTesting
  Left = 498
  Top = 272
  Width = 782
  Height = 462
  Caption = 'Regression testing'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbTests: TCheckListBox
    Left = 32
    Top = 24
    Width = 297
    Height = 329
    OnClickCheck = lbTestsClickCheck
    ItemHeight = 13
    TabOrder = 0
  end
  object mmTests: TMemo
    Left = 344
    Top = 24
    Width = 393
    Height = 329
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'mmTests')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btStart: TButton
    Left = 664
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = btStartClick
  end
  object rgAction: TRadioGroup
    Left = 32
    Top = 368
    Width = 299
    Height = 49
    Caption = 'Action'
    Columns = 2
    Items.Strings = (
      'Create reference'
      'Compare with reference')
    TabOrder = 3
  end
  object btClear: TButton
    Left = 576
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 4
    OnClick = btClearClick
  end
  object cxAll: TCheckBox
    Left = 35
    Top = 5
    Width = 97
    Height = 17
    Caption = 'All'
    TabOrder = 5
    OnClick = cxAllClick
  end
end
