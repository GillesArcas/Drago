object fmOptions: TfmOptions
  Left = 286
  Top = 172
  Anchors = [akTop]
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '__Drago - Options'
  ClientHeight = 487
  ClientWidth = 730
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bvPage: TBevel
    Left = 169
    Top = 38
    Width = 355
    Height = 411
    Shape = bsFrame
  end
  object pnTitle: TPanel
    Left = 176
    Top = 8
    Width = 548
    Height = 22
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clCream
    TabOrder = 4
    object lbTitle: TTntLabel
      Left = 5
      Top = 2
      Width = 43
      Height = 16
      Caption = '  lbTitle'
      Color = clCream
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object StringGrid: TTntStringGrid
    Left = 8
    Top = 8
    Width = 160
    Height = 423
    Color = clCream
    ColCount = 2
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine]
    ParentFont = False
    TabOrder = 3
    OnClick = StringGridClick
    OnDrawCell = StringGridDrawCell
    OnMouseMove = StringGridMouseMove
  end
  object PageControl: TTntPageControl
    Left = 176
    Top = 40
    Width = 546
    Height = 407
    ActivePage = TabSheetMoves
    Style = tsFlatButtons
    TabOrder = 5
    TabStop = False
    object TabSheetBoard: TTntTabSheet
      Caption = 'Board'
      ImageIndex = 1
      OnShow = TabSheetBoardShow
      object GroupBox4: TTntGroupBox
        Left = 8
        Top = 118
        Width = 529
        Height = 65
        Caption = 'Stones'
        TabOrder = 2
        object imGoban: TImage
          Left = 53
          Top = 11
          Width = 269
          Height = 49
        end
        object udGoban: TUpDown
          Left = 17
          Top = 24
          Width = 16
          Height = 24
          Max = 3
          TabOrder = 0
          TabStop = True
          OnClick = udGobanClick
        end
        object btSelectStones: TSpTBXButton
          Left = 384
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Select'
          Enabled = False
          TabOrder = 1
          OnClick = btSelectStonesClick
        end
      end
      inline BackStyle_Board: TfrBackStyle
        Left = 8
        Top = 0
        Width = 327
        Height = 65
        TabOrder = 0
        inherited GroupBox: TTntGroupBox
          Width = 327
          Height = 65
          inherited Button1: TTntRadioButton
            Height = 14
          end
        end
      end
      inline BackStyle_Border: TfrBackStyle
        Left = 8
        Top = 246
        Width = 327
        Height = 65
        TabOrder = 4
        inherited GroupBox: TTntGroupBox
          Width = 327
          Height = 65
          inherited Button1: TTntRadioButton
            Height = 14
          end
        end
      end
      object Panel1: TPanel
        Left = 8
        Top = 69
        Width = 327
        Height = 41
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 1
        TabStop = True
        object cbThickLines: TTntCheckBox
          Left = 8
          Top = 13
          Width = 151
          Height = 17
          Caption = 'Thick edges'
          TabOrder = 0
        end
        object cbHoshis: TTntCheckBox
          Left = 145
          Top = 13
          Width = 151
          Height = 17
          Caption = 'Hoshis'
          TabOrder = 1
        end
      end
      object rgCoordinates: TTntRadioGroup
        Left = 8
        Top = 190
        Width = 327
        Height = 49
        Caption = 'Coordinates'
        Columns = 3
        Items.Strings = (
          'None2'
          'Korschelt'
          'SGF')
        TabOrder = 3
        OnClick = rgCoordinatesClick
      end
      object rgZone: TTntRadioGroup
        Left = 8
        Top = 317
        Width = 327
        Height = 49
        Caption = 'Displayed zone'
        Columns = 2
        Items.Strings = (
          'Whole board'
          'Zoom on corner')
        TabOrder = 5
      end
    end
    object TabSheetMoves: TTntTabSheet
      Caption = 'Moves'
      ImageIndex = 3
      OnShow = TabSheetMovesShow
      object rgShowMove: TTntRadioGroup
        Left = 8
        Top = 0
        Width = 340
        Height = 97
        Caption = 'Show moves'
        Columns = 2
        Items.Strings = (
          'None'
          'Last move with number'
          'All moves with number'
          'Last move with markup'
          'Last N moves with number')
        TabOrder = 0
      end
      object rgVarStyle: TTntRadioGroup
        Left = 8
        Top = 108
        Width = 340
        Height = 49
        Caption = 'Show variations as...'
        Columns = 2
        Items.Strings = (
          'Next moves'
          'Alternate moves')
        TabOrder = 1
      end
      object rgVarMarkup: TTntRadioGroup
        Left = 8
        Top = 169
        Width = 340
        Height = 65
        Caption = 'Markup of variations on goban'
        Columns = 2
        Items.Strings = (
          'None'
          'Ghost stones'
          'Uppercase letters'
          'Lowercase letters')
        TabOrder = 2
      end
      object gbShowNumbers: TTntGroupBox
        Left = 8
        Top = 245
        Width = 340
        Height = 49
        Caption = 'Move numbers'
        TabOrder = 3
        object cbShowTwoDigits: TTntCheckBox
          Left = 8
          Top = 21
          Width = 306
          Height = 17
          Caption = 'Display only two last digits'
          TabOrder = 0
        end
      end
      object Label1: TSpTBXLabel
        Left = 358
        Top = 47
        Width = 159
        Height = 13
        Caption = 'Number of visible move numbers:'
        ParentColor = True
      end
      object edVisibleMoves: TIntEdit
        Left = 357
        Top = 64
        Width = 57
        Height = 21
        TabOrder = 5
        Text = 'edVisibleMoves'
        OnChange = edVisibleMovesChange
      end
    end
    object TabSheetGameTree: TTntTabSheet
      Caption = 'Game tree'
      ImageIndex = 5
      OnShow = TabSheetGameTreeShow
      object GroupBox5: TTntGroupBox
        Left = 8
        Top = 70
        Width = 327
        Height = 65
        Caption = 'Stones'
        TabOrder = 1
        object imTree: TImage
          Left = 53
          Top = 11
          Width = 156
          Height = 49
        end
        object Label7: TTntLabel
          Left = 223
          Top = 28
          Width = 32
          Height = 13
          Caption = 'Radius'
          Transparent = False
        end
        object udTree: TUpDown
          Left = 17
          Top = 24
          Width = 16
          Height = 24
          Max = 3
          Position = 1
          TabOrder = 0
          TabStop = True
          OnClick = udTreeClick
        end
        object ieTvRadius: TIntEdit
          Left = 264
          Top = 24
          Width = 33
          Height = 21
          TabOrder = 1
          Text = '1'
        end
        object udTvRadius: TUpDown
          Left = 297
          Top = 24
          Width = 16
          Height = 21
          Associate = ieTvRadius
          Min = 1
          Max = 15
          Position = 1
          TabOrder = 2
        end
      end
      inline BackStyle_Tree: TfrBackStyle
        Left = 8
        Top = 0
        Width = 327
        Height = 65
        TabOrder = 0
        inherited GroupBox: TTntGroupBox
          Width = 327
          Height = 65
          inherited Button1: TTntRadioButton
            Height = 14
          end
        end
      end
      object rgTvMoves: TTntRadioGroup
        Left = 8
        Top = 142
        Width = 327
        Height = 57
        Caption = 'Move numbers'
        Columns = 3
        Items.Strings = (
          'No2'
          'On the side'
          'On the stones')
        TabOrder = 2
      end
    end
    object TabSheetView: TTntTabSheet
      Caption = 'View'
      ImageIndex = 6
      OnShow = TabSheetViewShow
      inline BackStyle_Win: TfrBackStyle
        Left = 8
        Top = 0
        Width = 327
        Height = 65
        TabOrder = 0
        inherited GroupBox: TTntGroupBox
          Width = 327
          Height = 65
          inherited Button1: TTntRadioButton
            Height = 14
          end
        end
      end
      object gbLighting: TTntGroupBox
        Left = 8
        Top = 80
        Width = 327
        Height = 65
        Caption = 'Light source'
        TabOrder = 1
        object imLighting: TImage
          Left = 141
          Top = 11
          Width = 172
          Height = 49
        end
        object rbLightingLeft: TTntRadioButton
          Left = 9
          Top = 19
          Width = 113
          Height = 17
          Caption = 'Top left'
          TabOrder = 0
          OnClick = rbLightingLeftClick
        end
        object rbLightingRight: TTntRadioButton
          Left = 9
          Top = 39
          Width = 113
          Height = 17
          Caption = 'Top right'
          TabOrder = 1
          OnClick = rbLightingRightClick
        end
      end
      object GroupBox16: TSpTBXGroupBox
        Left = 8
        Top = 160
        Width = 329
        Height = 73
        Caption = 'Menu and toolbar skins'
        TabOrder = 2
        object cbThemes: TComboBox
          Left = 14
          Top = 27
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          Text = 'cbThemes'
        end
      end
    end
    object TabSheetIndex: TTntTabSheet
      Caption = 'Preview2'
      ImageIndex = 6
      object GroupBox9: TTntGroupBox
        Left = 8
        Top = 0
        Width = 329
        Height = 277
        Caption = 'Definition of information columns'
        TabOrder = 1
        inline frCfgInfoPreview: TfrCfgInfoPreview
          Left = 2
          Top = 15
          Width = 323
          Height = 258
          TabOrder = 0
          inherited Label3: TTntLabel
            Caption = 'Select property etc.'
          end
        end
      end
      object GroupBox2: TTntGroupBox
        Left = 8
        Top = 327
        Width = 327
        Height = 42
        Caption = 'Thumbnail preview'
        TabOrder = 0
        DesignSize = (
          327
          42)
        object Label10: TTntLabel
          Left = 8
          Top = 17
          Width = 60
          Height = 13
          Anchors = [akLeft, akBottom]
          Caption = 'Stone radius'
          Transparent = False
        end
        object udGIdxRadius: TUpDown
          Left = 299
          Top = 13
          Width = 16
          Height = 21
          Anchors = [akLeft, akBottom]
          Associate = ieGIdxRadius
          Min = 1
          Max = 20
          Position = 1
          TabOrder = 0
        end
        object ieGIdxRadius: TIntEdit
          Left = 266
          Top = 13
          Width = 33
          Height = 21
          Anchors = [akLeft, akBottom]
          TabOrder = 1
          Text = '1'
        end
      end
      object GroupBox15: TTntGroupBox
        Left = 8
        Top = 280
        Width = 329
        Height = 44
        Caption = 'Sorting of information records'
        TabOrder = 2
        object Label8: TTntLabel
          Left = 9
          Top = 20
          Width = 176
          Height = 13
          Caption = 'Enabled if record number is less than'
          Transparent = False
        end
        object ieSortLimit: TIntEdit
          Left = 266
          Top = 16
          Width = 49
          Height = 21
          TabOrder = 0
          Text = '999999'
        end
      end
    end
    object TabSheetSidebar: TTntTabSheet
      Caption = 'Sidebar'
      ImageIndex = 13
      OnShow = TabSheetSidebarShow
      object SpTBXGroupBox1: TSpTBXGroupBox
        Left = 8
        Top = 184
        Width = 407
        Height = 129
        Caption = 'Game information panel'
        SkinType = sknWindows
        TabOrder = 1
        object btImgDir: TSpeedButton
          Left = 371
          Top = 75
          Width = 23
          Height = 22
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            040000000000800000000000000000000000100000001000000000000000FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00111111111111
            1111111111111111111111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111110011100111
            0011110011100111001111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111}
          OnClick = btImgDirClick
        end
        object SpTBXLabel1: TSpTBXLabel
          Left = 8
          Top = 27
          Width = 34
          Height = 13
          Caption = 'Format'
        end
        object edGameInfoFormat: TTntEdit
          Left = 128
          Top = 25
          Width = 265
          Height = 21
          TabOrder = 0
          Text = 'edGameInfoFormat'
        end
        object cxGameInfoImageDisplay: TSpTBXCheckBox
          Left = 128
          Top = 56
          Width = 14
          Height = 15
          TabOrder = 1
          Alignment = taRightJustify
        end
        object SpTBXLabel2: TSpTBXLabel
          Left = 8
          Top = 80
          Width = 76
          Height = 13
          Caption = 'Image directory'
        end
        object edGameInfoImageDir: TTntEdit
          Left = 128
          Top = 76
          Width = 242
          Height = 21
          TabOrder = 2
          Text = 'TntEdit1'
          OnChange = edGameInfoImageDirChange
        end
        object SpTBXLabel3: TSpTBXLabel
          Left = 8
          Top = 56
          Width = 70
          Height = 13
          Caption = 'Display images'
        end
        object lbPath: TSpTBXLabel
          Left = 128
          Top = 95
          Width = 265
          Height = 13
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object GroupBox3: TSpTBXGroupBox
        Left = 8
        Top = 6
        Width = 407
        Height = 165
        Caption = 'Default visibility of panels when creating a tab'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 0
        object Label4: TTntLabel
          Left = 32
          Top = 22
          Width = 66
          Height = 13
          Caption = 'Always visible'
          Transparent = False
        end
        object Label6: TTntLabel
          Left = 207
          Top = 22
          Width = 77
          Height = 13
          Caption = 'Visible if needed'
          Transparent = False
        end
        object clbVisible: TTntCheckListBox
          Left = 32
          Top = 40
          Width = 121
          Height = 112
          OnClickCheck = clbVisibleClickCheck
          ItemHeight = 18
          Items.Strings = (
            'Game information'
            'Timing'
            'Node name'
            'Variation list'
            'Game tree'
            'Comments')
          Style = lbOwnerDrawFixed
          TabOrder = 0
        end
        object clbConditional: TTntCheckListBox
          Left = 208
          Top = 40
          Width = 121
          Height = 112
          ItemHeight = 18
          Items.Strings = (
            'Game information'
            'Timing'
            'Node name'
            'Variation list'
            'Game tree'
            'Comments')
          Style = lbOwnerDrawFixed
          TabOrder = 1
          OnClick = clbConditionalClick
        end
      end
      object gbFont: TSpTBXGroupBox
        Left = 8
        Top = 316
        Width = 197
        Height = 49
        Caption = 'Comment font'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 2
        object Label2: TTntLabel
          Left = 8
          Top = 20
          Width = 19
          Height = 13
          Caption = 'Size'
          Transparent = False
        end
        object cbFontSize: TComboBox
          Left = 79
          Top = 17
          Width = 58
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            '6'
            '7'
            '8'
            '9'
            '10'
            '11'
            '12')
        end
      end
      object gbTextPanels: TSpTBXGroupBox
        Left = 218
        Top = 316
        Width = 197
        Height = 49
        Caption = 'Text panels'
        SkinType = sknWindows
        ParentColor = True
        TabOrder = 3
        TabStop = True
        Visible = False
        object Bevel3: TBevel
          Left = 79
          Top = 15
          Width = 58
          Height = 23
          Shape = bsFrame
        end
        object imTextColor: TImage
          Left = 81
          Top = 17
          Width = 52
          Height = 18
        end
        object sbTextColor: TSpeedButton
          Left = 139
          Top = 15
          Width = 23
          Height = 22
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            040000000000800000000000000000000000100000001000000000000000FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00111111111111
            1111111111111111111111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111110011100111
            0011110011100111001111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111}
          OnClick = sbTextColorClick
        end
        object Label3: TTntLabel
          Left = 8
          Top = 21
          Width = 25
          Height = 13
          Caption = 'Color'
          Transparent = False
        end
      end
    end
    object TabSheet9: TTntTabSheet
      Caption = 'Shortcuts'
      ImageIndex = 11
      inline frCfgShortcuts: TfrCfgShortcuts
        Left = 0
        Top = 0
        Width = 341
        Height = 374
        TabOrder = 0
        inherited Label3: TTntLabel
          Left = 87
        end
        inherited Label4: TTntLabel
          Left = 87
        end
      end
    end
    object TabsheetToolbars: TTntTabSheet
      Caption = 'Toolbars'
      inline frCfgSpToolbars: TfrCfgSpToolbars
        Left = 0
        Top = 0
        Width = 539
        Height = 374
        TabOrder = 0
      end
    end
    object TabSheetSounds: TTntTabSheet
      Caption = 'Sounds'
      ImageIndex = 8
      object GroupBox8: TTntGroupBox
        Left = 8
        Top = 6
        Width = 327
        Height = 41
        TabOrder = 0
        object cbEnableSounds: TTntCheckBox
          Left = 14
          Top = 14
          Width = 283
          Height = 17
          Caption = 'Enable sounds'
          TabOrder = 0
          OnClick = cbEnableSoundsClick
        end
      end
      object GroupBox11: TTntGroupBox
        Left = 8
        Top = 56
        Width = 327
        Height = 201
        Caption = 'Sounds'
        TabOrder = 1
        object sbSound: TSpeedButton
          Left = 290
          Top = 129
          Width = 23
          Height = 22
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            040000000000800000000000000000000000100000001000000000000000FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00111111111111
            1111111111111111111111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111110011100111
            0011110011100111001111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111}
          OnClick = sbSoundClick
        end
        object edSound: TEdit
          Left = 16
          Top = 129
          Width = 273
          Height = 21
          ReadOnly = True
          TabOrder = 2
          Text = 'edSound'
        end
        object rbSoundDefault: TTntRadioButton
          Left = 13
          Top = 81
          Width = 284
          Height = 17
          Caption = 'Default'
          TabOrder = 0
          OnClick = rbSoundDefaultClick
        end
        object rbSoundCustom: TTntRadioButton
          Left = 14
          Top = 105
          Width = 283
          Height = 17
          Caption = 'Custom'
          TabOrder = 1
          OnClick = rbSoundCustomClick
        end
        object rbSoundNone: TTntRadioButton
          Left = 14
          Top = 56
          Width = 299
          Height = 17
          Caption = 'None'
          TabOrder = 3
          OnClick = rbSoundNoneClick
        end
        object cbSounds: TTntComboBox
          Left = 16
          Top = 24
          Width = 297
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 4
          OnChange = cbSoundsChange
          Items.Strings = (
            'Stones'
            'Invalid move'
            'Engine move')
        end
        object btTestSound3: TTntButton
          Left = 16
          Top = 162
          Width = 75
          Height = 25
          Caption = 'Test'
          TabOrder = 5
          OnClick = btTestSoundClick
        end
      end
    end
    object TabSheet5: TTntTabSheet
      Caption = 'Files'
      ImageIndex = 2
      object gbFichiers: TTntGroupBox
        Left = 8
        Top = 172
        Width = 327
        Height = 159
        Caption = 'Properties'
        TabOrder = 1
        object cbCreer: TTntCheckBox
          Left = 15
          Top = 48
          Width = 305
          Height = 17
          Caption = 'New file with full SGF properties'
          TabOrder = 1
        end
        object cbJoueur: TTntCheckBox
          Left = 15
          Top = 72
          Width = 305
          Height = 17
          Caption = 'Change player with SGF property'
          TabOrder = 2
        end
        object cbCompact: TTntCheckBox
          Left = 15
          Top = 24
          Width = 305
          Height = 17
          Caption = 'Save with 10 moves on each line'
          TabOrder = 0
        end
        object cbCompressList: TTntCheckBox
          Left = 15
          Top = 96
          Width = 289
          Height = 17
          Caption = 'Compress lists of points'
          TabOrder = 3
        end
        object cbLongPNames: TTntCheckBox
          Left = 15
          Top = 120
          Width = 297
          Height = 17
          Caption = 'Accept long property names'
          TabOrder = 4
        end
      end
      object gbStart: TTntGroupBox
        Left = 8
        Top = 88
        Width = 327
        Height = 71
        Caption = 'Starting'
        TabOrder = 0
        object cbOpenLast: TTntCheckBox
          Left = 15
          Top = 20
          Width = 233
          Height = 17
          Caption = 'Start with last files'
          TabOrder = 0
          OnClick = cbOpenLastClick
        end
        object cbOpenNode: TTntCheckBox
          Left = 15
          Top = 42
          Width = 233
          Height = 17
          Caption = 'Start with last move'
          TabOrder = 1
        end
      end
      object TntGroupBox1: TTntGroupBox
        Left = 8
        Top = 8
        Width = 327
        Height = 71
        Caption = 'File associations'
        TabOrder = 2
        object cxSGFAsso: TTntCheckBox
          Left = 15
          Top = 20
          Width = 218
          Height = 17
          Caption = 'SGF files'
          TabOrder = 0
        end
        object cxMGTAsso: TTntCheckBox
          Left = 15
          Top = 42
          Width = 218
          Height = 17
          Caption = 'MGT files'
          TabOrder = 1
        end
      end
    end
    object TabSheetNavigation: TTntTabSheet
      Caption = 'Navigation'
      ImageIndex = 12
      object Bevel4: TBevel
        Left = 8
        Top = 368
        Width = 329
        Height = 3
        Shape = bsTopLine
      end
      object Panel2: TPanel
        Left = 8
        Top = 184
        Width = 329
        Height = 25
        BevelOuter = bvNone
        TabOrder = 2
        object Bevel6: TBevel
          Left = 1
          Top = 7
          Width = 330
          Height = 3
          Shape = bsTopLine
        end
        object lbAuto: TSpTBXLabel
          Left = 18
          Top = 1
          Width = 53
          Height = 13
          Caption = 'Auto replay'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = True
          ParentFont = False
        end
      end
      object Panel3: TPanel
        Left = 6
        Top = 0
        Width = 329
        Height = 25
        BevelOuter = bvNone
        TabOrder = 3
        object bvStart: TBevel
          Left = 1
          Top = 7
          Width = 330
          Height = 3
          Shape = bsTopLine
        end
        object lbTargets: TSpTBXLabel
          Left = 18
          Top = 1
          Width = 62
          Height = 13
          Caption = 'Move targets'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = True
          ParentFont = False
        end
      end
      object ieTargetStep: TIntEdit
        Left = 160
        Top = 24
        Width = 33
        Height = 21
        TabOrder = 11
        Text = '0'
      end
      object cbAutoUseTimeProp: TTntCheckBox
        Left = 8
        Top = 312
        Width = 300
        Height = 17
        Caption = 'Use timing properties when available'
        TabOrder = 1
      end
      object cbTargetStep: TTntCheckBox
        Left = 8
        Top = 24
        Width = 150
        Height = 17
        Caption = 'Every N moves'
        TabOrder = 4
      end
      object cbTargetComment: TTntCheckBox
        Left = 8
        Top = 48
        Width = 150
        Height = 17
        Caption = 'Comments'
        TabOrder = 5
      end
      object cbTargetStartVar: TTntCheckBox
        Left = 8
        Top = 72
        Width = 150
        Height = 17
        Caption = 'Starts of variation'
        TabOrder = 6
      end
      object cbTargetEndVar: TTntCheckBox
        Left = 8
        Top = 96
        Width = 150
        Height = 17
        Caption = 'Ends of variation'
        TabOrder = 7
      end
      object cbTargetFigure: TTntCheckBox
        Left = 8
        Top = 120
        Width = 150
        Height = 17
        Caption = 'Figures'
        TabOrder = 8
      end
      object cbTargetAnnotation: TTntCheckBox
        Left = 8
        Top = 144
        Width = 150
        Height = 17
        Caption = 'Annotations'
        TabOrder = 9
      end
      object cbStopAtTarget: TTntCheckBox
        Left = 8
        Top = 336
        Width = 300
        Height = 17
        Caption = 'Stop at targets'
        TabOrder = 10
      end
      object gbTiming: TTntGroupBox
        Left = 8
        Top = 216
        Width = 329
        Height = 81
        Caption = 'Time between two moves'
        TabOrder = 0
        object lbAutoDelay: TLabel
          Left = 121
          Top = 60
          Width = 58
          Height = 13
          Caption = 'lbAutoDelay'
          Transparent = False
        end
        object lbMinDelay: TLabel
          Left = 32
          Top = 56
          Width = 11
          Height = 13
          Caption = '0s'
          Transparent = False
        end
        object lbMaxDelay: TLabel
          Left = 288
          Top = 56
          Width = 11
          Height = 13
          Caption = '1s'
          Transparent = False
        end
        object btMoreDelay: TSpeedButton
          Left = 301
          Top = 24
          Width = 19
          Height = 22
          Flat = True
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            1800000000000003000000000000000000000000000000000000E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE09F9F9FE3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0606060FDFDFDFDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060E3DFE0E3DFE0FD
            FDFDFDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0606060E3DFE0E3DFE0E3DFE0E3DFE0FDFDFDFDFDFDE3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0FDFDFDFDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0606060E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE09090909090
            90E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060E3DFE0E3DFE0E3
            DFE0E3DFE0909090909090E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0606060E3DFE0E3DFE0909090909090E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060909090909090E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0606060E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0}
          OnClick = btMoreDelayClick
        end
        object btLessDelay: TSpeedButton
          Left = 8
          Top = 24
          Width = 19
          Height = 22
          Flat = True
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            1800000000000003000000000000000000000000000000000000E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0FDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0FDFDFDFDFDFDFDFDFDE3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0FD
            FDFDFDFDFDE3DFE0E3DFE0FDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0FDFDFDFDFDFDE3DFE0E3DFE0E3DFE0E3DFE0FDFDFDE3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0FDFDFDFDFDFDE3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0FDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0606060606060E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0FDFDFDE3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060606060E3
            DFE0E3DFE0E3DFE0E3DFE0FDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060606060E3DFE0E3DFE0FDFDFDE3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0606060606060FDFDFDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0606060E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
            E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
            E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
            DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0}
          OnClick = btLessDelayClick
        end
        object TrackBarAutoReplay: TTrackBar
          Left = 28
          Top = 24
          Width = 273
          Height = 25
          LineSize = 10
          Max = 100
          PageSize = 10
          Frequency = 10
          TabOrder = 0
          OnChange = TrackBarAutoReplayChange
        end
      end
    end
    object TabSheetDatabase: TTntTabSheet
      Caption = 'Database'
      ImageIndex = 15
      object GroupBox12: TTntGroupBox
        Left = 8
        Top = 8
        Width = 329
        Height = 57
        Caption = 'General'
        TabOrder = 0
        object Label5: TTntLabel
          Left = 28
          Top = 24
          Width = 30
          Height = 13
          Caption = 'Cache'
          Transparent = False
        end
        object edCache: TEdit
          Left = 192
          Top = 21
          Width = 121
          Height = 21
          TabOrder = 0
          Text = 'edCache'
        end
      end
      object GroupBox13: TTntGroupBox
        Left = 8
        Top = 72
        Width = 329
        Height = 189
        Caption = 'Creation'
        TabOrder = 1
        object cxProcessVar: TTntCheckBox
          Left = 8
          Top = 48
          Width = 302
          Height = 17
          Caption = 'Process variations'
          TabOrder = 0
        end
        object cxDetectDup: TTntCheckBox
          Left = 8
          Top = 76
          Width = 305
          Height = 17
          Caption = 'Detect duplicates'
          TabOrder = 1
          OnClick = cxDetectDupClick
        end
        object cxOmitDup: TTntCheckBox
          Left = 8
          Top = 132
          Width = 313
          Height = 17
          Caption = 'Omit duplicates when detected'
          TabOrder = 4
        end
        object cxOmitSgfErr: TTntCheckBox
          Left = 8
          Top = 160
          Width = 313
          Height = 17
          Caption = 'Omit games with SGF errors'
          TabOrder = 5
        end
        object cxCreateEx: TTntCheckBox
          Left = 8
          Top = 20
          Width = 313
          Height = 17
          Caption = 'Create with extended algorithms'
          TabOrder = 6
        end
        object rbDupSignature: TTntRadioButton
          Left = 24
          Top = 92
          Width = 297
          Height = 17
          Caption = 'by using signature'
          TabOrder = 2
        end
        object rbDupFinalPos: TTntRadioButton
          Left = 24
          Top = 108
          Width = 297
          Height = 17
          Caption = 'by using final position'
          TabOrder = 3
        end
      end
      object GroupBox14: TTntGroupBox
        Left = 8
        Top = 268
        Width = 329
        Height = 73
        Caption = 'Pattern search'
        TabOrder = 2
        Visible = False
        object Label11: TTntLabel
          Left = 25
          Top = 46
          Width = 47
          Height = 13
          Caption = 'Move limit'
          Transparent = False
        end
        object edMoveLimit: TIntEdit
          Left = 192
          Top = 42
          Width = 121
          Height = 21
          TabOrder = 1
          Text = '0'
        end
        object cxSearchVar: TTntCheckBox
          Left = 25
          Top = 20
          Width = 180
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Search in variations'
          TabOrder = 0
        end
      end
      object btDefaultDB: TTntButton
        Left = 8
        Top = 356
        Width = 75
        Height = 17
        Caption = 'Default'
        TabOrder = 3
        OnClick = btDefaultDBClick
      end
    end
    object TabSheetEngines: TTntTabSheet
      Caption = 'Game engines'
      OnShow = TabSheetEnginesShow
      inline frCfgGameEngines: TfrCfgGameEngines
        Left = -6
        Top = -1
        Width = 543
        Height = 370
        TabOrder = 0
        inherited SpTBXGroupBox1: TSpTBXGroupBox
          inherited btAdd: TSpTBXButton
            OnClick = frCfgGameEnginesbtAddClick
          end
        end
      end
    end
    object TabSheetLanguage: TTntTabSheet
      Caption = 'Language'
      object GroupBox7: TTntGroupBox
        Left = 8
        Top = 16
        Width = 329
        Height = 57
        Caption = 'Select language for user interface'
        TabOrder = 0
        object cbLangue: TSpTBXComboBox
          Left = 15
          Top = 21
          Width = 299
          Height = 23
          Style = csOwnerDrawFixed
          ItemHeight = 17
          TabOrder = 0
          OnDrawItem = cbLangueDrawItem
        end
      end
      object TntGroupBox2: TTntGroupBox
        Left = 8
        Top = 80
        Width = 329
        Height = 57
        Caption = 'Select code page for game files'
        TabOrder = 1
        object cbEncoding: TSpTBXComboBox
          Left = 15
          Top = 21
          Width = 299
          Height = 23
          Style = csOwnerDrawFixed
          DropDownCount = 15
          ItemHeight = 17
          TabOrder = 0
          OnDrawItem = cbEncodingDrawItem
          HotTrack = False
        end
      end
      object rgCreateEncoding: TSpTBXRadioGroup
        Left = 8
        Top = 144
        Width = 329
        Height = 65
        Caption = 'Create game files using...'
        TabOrder = 2
        Items.Strings = (
          'UTF-8'
          'System default code page')
      end
    end
    object TabSheetAdvanced: TTntTabSheet
      Caption = 'Advanced'
      OnShow = TabSheetAdvancedShow
      inline frAdvanced: TfrAdvanced
        Left = 0
        Top = 0
        Width = 538
        Height = 376
        Align = alClient
        TabOrder = 0
        inherited VT: TVirtualStringTree
          Width = 538
          Height = 332
          Columns = <
            item
              Position = 0
              Width = 200
            end
            item
              Position = 1
              Width = 338
            end>
        end
        inherited Panel1: TSpTBXGroupBox
          Top = 332
          Width = 538
          DesignSize = (
            538
            44)
        end
      end
    end
    object TabSheetDum: TTntTabSheet
      Caption = 'Dum'
      ImageIndex = 12
      inline frCfgPredefinedEngines: TfrCfgPredefinedEngines
        Left = -22
        Top = 15
        Width = 347
        Height = 359
        TabOrder = 0
        DesignSize = (
          347
          359)
      end
    end
    object TabSheetEngineOld: TTntTabSheet
      Caption = 'Game engine'
      ImageIndex = 7
      object GroupBox1: TTntGroupBox
        Left = 8
        Top = 0
        Width = 329
        Height = 73
        Caption = 'Binary'
        TabOrder = 0
        object sbEngine: TSpeedButton
          Left = 296
          Top = 19
          Width = 23
          Height = 22
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            040000000000800000000000000000000000100000001000000000000000FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00111111111111
            1111111111111111111111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111110011100111
            0011110011100111001111111111111111111111111111111111111111111111
            1111111111111111111111111111111111111111111111111111}
        end
        object edEngine: TTntEdit
          Left = 8
          Top = 20
          Width = 278
          Height = 21
          TabOrder = 0
          Text = 'edEngine'
        end
        object lbEngine: TSpTBXLabel
          Left = 8
          Top = 48
          Width = 40
          Height = 13
          Caption = 'lbEngine'
          ParentColor = True
        end
      end
      object GroupBox6: TTntGroupBox
        Left = 8
        Top = 80
        Width = 329
        Height = 89
        Caption = 'Parameters'
        TabOrder = 1
        DesignSize = (
          329
          89)
        object Edit1: TEdit
          Left = 94
          Top = 20
          Width = 225
          Height = 21
          Enabled = False
          TabOrder = 1
          Text = '--mode gtp --level \level'
        end
        object edCustomParam: TEdit
          Left = 94
          Top = 52
          Width = 225
          Height = 21
          Anchors = [akLeft, akBottom]
          TabOrder = 3
          Text = 'edCustomParam'
        end
        object rbParDefault: TTntRadioButton
          Left = 8
          Top = 22
          Width = 85
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Default'
          TabOrder = 0
        end
        object rbParCustom: TTntRadioButton
          Left = 8
          Top = 54
          Width = 85
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Custom'
          TabOrder = 2
        end
      end
      object gbUndo: TTntGroupBox
        Left = 8
        Top = 248
        Width = 329
        Height = 49
        Caption = 'Enable Undo'
        TabOrder = 2
        object rbUndoNo: TSpTBXRadioButton
          Left = 8
          Top = 20
          Width = 31
          Height = 15
          Caption = 'No'
          ParentColor = True
          TabOrder = 0
          Alignment = taRightJustify
        end
        object rbUndoYes: TSpTBXRadioButton
          Left = 72
          Top = 20
          Width = 35
          Height = 15
          Caption = 'Yes'
          ParentColor = True
          TabOrder = 1
          Alignment = taRightJustify
        end
        object rbUndoCapture: TSpTBXRadioButton
          Left = 136
          Top = 20
          Width = 107
          Height = 15
          Caption = 'Only after capture'
          ParentColor = True
          TabOrder = 2
          Alignment = taRightJustify
        end
      end
      object rgScoringTmp: TTntRadioGroup
        Left = 8
        Top = 176
        Width = 329
        Height = 65
        Caption = 'Scoring'
        Items.Strings = (
          'Territory counting'
          'Area counting')
        TabOrder = 3
      end
      object lbEngOptInhibited: TSpTBXLabel
        Left = 64
        Top = 350
        Width = 221
        Height = 13
        Caption = 'Game engine options are inhibited during game'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object btOk: TSpTBXButton
    Left = 179
    Top = 448
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = btOkClick
  end
  object btCancel: TSpTBXButton
    Left = 265
    Top = 448
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btHelp: TSpTBXButton
    Left = 440
    Top = 448
    Width = 75
    Height = 25
    Caption = '&Help'
    TabOrder = 2
    OnClick = btHelpClick
    SkinType = sknWindows
  end
  object btMore: TSpTBXButton
    Left = 352
    Top = 448
    Width = 75
    Height = 25
    Caption = 'More'
    TabOrder = 6
    Visible = False
    OnClick = btHelpClick
    SkinType = sknWindows
  end
  object ColorDialog: TColorDialog
    Left = 10
    Top = 439
  end
end
