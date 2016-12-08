object fmInsert: TfmInsert
  Left = 661
  Top = 164
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'fmInsert'
  ClientHeight = 337
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    388
    337)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TTntPageControl
    Left = 8
    Top = 8
    Width = 369
    Height = 273
    ActivePage = TabSheet3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object TabSheet1: TTntTabSheet
      Caption = 'Annotations'
      object gbPosition: TSpTBXGroupBox
        Left = 8
        Top = 2
        Width = 345
        Height = 153
        Caption = 'Position annotations'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 0
        object Bevel1: TBevel
          Left = 8
          Top = 102
          Width = 329
          Height = 9
          Shape = bsBottomLine
        end
        object pnPosition: TPanel
          Left = 8
          Top = 16
          Width = 329
          Height = 92
          BevelOuter = bvNone
          ParentBackground = False
          ParentColor = True
          TabOrder = 0
          object cb_GB1: TTntCheckBox
            Left = 12
            Top = 8
            Width = 149
            Height = 17
            Caption = 'cb_GB1'
            TabOrder = 0
            OnClick = cb_GB1Click
          end
          object cb_GB2: TTntCheckBox
            Left = 168
            Top = 8
            Width = 161
            Height = 17
            Caption = 'cb_GB2'
            TabOrder = 1
          end
          object cb_GW1: TTntCheckBox
            Left = 12
            Top = 28
            Width = 149
            Height = 17
            Caption = 'cb_GW1'
            TabOrder = 2
          end
          object cb_GW2: TTntCheckBox
            Left = 168
            Top = 28
            Width = 161
            Height = 17
            Caption = 'cb_GW2'
            TabOrder = 3
          end
          object CB_DM1: TTntCheckBox
            Left = 12
            Top = 48
            Width = 149
            Height = 17
            Caption = 'CB_DM1'
            TabOrder = 4
          end
          object cb_DM2: TTntCheckBox
            Left = 168
            Top = 48
            Width = 161
            Height = 17
            Caption = 'cb_DM2'
            TabOrder = 5
          end
          object cb_UC1: TTntCheckBox
            Left = 12
            Top = 68
            Width = 149
            Height = 17
            Caption = 'cb_UC1'
            TabOrder = 6
          end
          object cb_UC2: TTntCheckBox
            Left = 168
            Top = 68
            Width = 161
            Height = 17
            Caption = 'cb_UC2'
            TabOrder = 7
          end
        end
        object pnHotSpot: TPanel
          Left = 8
          Top = 112
          Width = 329
          Height = 33
          BevelOuter = bvNone
          ParentBackground = False
          ParentColor = True
          TabOrder = 1
          object cb_HO1: TTntCheckBox
            Left = 12
            Top = 8
            Width = 149
            Height = 17
            Caption = 'cb_HO1'
            TabOrder = 0
          end
          object cb_HO2: TTntCheckBox
            Left = 168
            Top = 8
            Width = 161
            Height = 17
            Caption = 'cb_HO2'
            TabOrder = 1
          end
        end
      end
      object gbMove: TSpTBXGroupBox
        Left = 8
        Top = 158
        Width = 345
        Height = 80
        Caption = 'Move annotations'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 1
        object cb_BM1: TTntCheckBox
          Left = 18
          Top = 16
          Width = 149
          Height = 17
          Caption = 'cb_BM1'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
        end
        object cb_BM2: TTntCheckBox
          Left = 176
          Top = 16
          Width = 161
          Height = 17
          Caption = 'cb_BM2'
          TabOrder = 1
        end
        object cb_DO: TTntCheckBox
          Left = 18
          Top = 36
          Width = 149
          Height = 17
          Caption = 'cb_DO'
          TabOrder = 2
        end
        object cb_IT: TTntCheckBox
          Left = 176
          Top = 36
          Width = 161
          Height = 17
          Caption = 'cb_IT'
          TabOrder = 3
        end
        object cb_TE1: TTntCheckBox
          Left = 18
          Top = 56
          Width = 149
          Height = 17
          Caption = 'cb_TE1'
          TabOrder = 4
        end
        object cb_TE2: TTntCheckBox
          Left = 176
          Top = 56
          Width = 161
          Height = 17
          Caption = 'cb_TE2'
          TabOrder = 5
        end
      end
    end
    object TabSheet3: TTntTabSheet
      Caption = 'Text'
      ImageIndex = 2
      object Label3: TTntLabel
        Left = 8
        Top = 16
        Width = 54
        Height = 13
        Caption = 'Node name'
        Transparent = False
      end
      object Label4: TTntLabel
        Left = 8
        Top = 72
        Width = 45
        Height = 13
        Caption = 'Comment'
        Transparent = False
      end
      object mmComment: TTntMemo
        Left = 8
        Top = 96
        Width = 345
        Height = 137
        Lines.Strings = (
          'mmComment')
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object edNodeName: TTntEdit
        Left = 8
        Top = 40
        Width = 345
        Height = 21
        TabOrder = 0
      end
    end
    object TabSheet2: TTntTabSheet
      Caption = 'Others'
      ImageIndex = 1
      object gbAutres: TSpTBXGroupBox
        Left = 8
        Top = 163
        Width = 345
        Height = 74
        Caption = 'Other properties'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 2
        object ed_MN: TEdit
          Left = 178
          Top = 18
          Width = 49
          Height = 21
          TabOrder = 1
          Text = 'ed_MN'
        end
        object cb_WV: TTntCheckBox
          Left = 18
          Top = 48
          Width = 311
          Height = 17
          Caption = 'cb_WV'
          TabOrder = 2
        end
        object cb_MN: TTntCheckBox
          Left = 18
          Top = 18
          Width = 159
          Height = 17
          Caption = 'cb_MN'
          TabOrder = 0
          OnClick = cb_MNClick
        end
      end
      object gbTiming: TSpTBXGroupBox
        Left = 8
        Top = 2
        Width = 345
        Height = 74
        Caption = 'Timing'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 0
        object Label1: TTntLabel
          Left = 229
          Top = 17
          Width = 46
          Height = 13
          Caption = 'hh:mm:ss'
          Transparent = False
        end
        object Label2: TTntLabel
          Left = 229
          Top = 48
          Width = 46
          Height = 13
          Caption = 'hh:mm:ss'
          Transparent = False
        end
        object edBL: TEdit
          Left = 178
          Top = 14
          Width = 49
          Height = 21
          TabOrder = 2
        end
        object edWL: TEdit
          Left = 178
          Top = 46
          Width = 49
          Height = 21
          TabOrder = 3
        end
        object cb_BL: TTntCheckBox
          Left = 18
          Top = 18
          Width = 151
          Height = 17
          Caption = 'Black time left'
          TabOrder = 0
          OnClick = cb_BLClick
        end
        object cb_WL: TTntCheckBox
          Left = 18
          Top = 48
          Width = 151
          Height = 17
          Caption = 'White time left'
          TabOrder = 1
          OnClick = cb_WLClick
        end
      end
      object GroupBox1: TSpTBXGroupBox
        Left = 8
        Top = 82
        Width = 345
        Height = 74
        Caption = 'Figures'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 1
        object ed_FGName: TEdit
          Left = 178
          Top = 18
          Width = 151
          Height = 21
          TabOrder = 2
          Text = 'ed_FGName'
        end
        object cb_FG: TTntCheckBox
          Left = 18
          Top = 18
          Width = 95
          Height = 17
          Caption = 'Insert figure'
          TabOrder = 0
          OnClick = cb_FGClick
        end
        object cb_FGName: TTntCheckBox
          Left = 111
          Top = 18
          Width = 58
          Height = 17
          Caption = 'Name'
          TabOrder = 1
          OnClick = cb_FGNameClick
        end
        object cb_FGCoord: TTntCheckBox
          Left = 111
          Top = 48
          Width = 217
          Height = 17
          Caption = 'Show coordinates'
          TabOrder = 3
        end
      end
    end
  end
  object btOk: TTntButton
    Left = 8
    Top = 301
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    TabOrder = 0
    OnClick = btOkClick
  end
  object btAnnuler: TTntButton
    Left = 96
    Top = 301
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btAnnulerClick
  end
  object btAide: TTntButton
    Left = 302
    Top = 301
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btAideClick
  end
end
