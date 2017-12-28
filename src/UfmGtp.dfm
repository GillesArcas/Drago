object fmGtp: TfmGtp
  Left = 537
  Top = 143
  Width = 381
  Height = 563
  Caption = 'fmGtp'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 432
    Width = 373
    Height = 97
    Align = alBottom
    TabOrder = 1
    object lbWarning: TSpTBXLabel
      Left = 10
      Top = 10
      Width = 288
      Height = 13
      Caption = 'Enter and send GTP command (no feedback on main board):'
    end
    object btSend: TSpTBXButton
      Left = 288
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Send'
      TabOrder = 1
      OnClick = btSendClick
    end
    object btSave: TSpTBXButton
      Left = 92
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Save'
      TabOrder = 3
      OnClick = btSaveClick
    end
    object btClear: TSpTBXButton
      Left = 9
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 2
      OnClick = btClearClick
    end
    object btClose: TSpTBXButton
      Left = 175
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 5
      OnClick = btCloseClick
    end
    object edSend: TSpTBXEdit
      Left = 8
      Top = 26
      Width = 275
      Height = 21
      TabOrder = 0
      OnKeyDown = edSendKeyDown
    end
  end
  object Memo: TTntMemo
    Left = 0
    Top = 0
    Width = 373
    Height = 432
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Memo')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 336
    Top = 488
  end
end
