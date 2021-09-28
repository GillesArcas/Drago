object fmMain: TfmMain
  Left = 230
  Top = 149
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  AutoScroll = False
  Caption = ' '
  ClientHeight = 474
  ClientWidth = 905
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MenuForShortcuts
  OldCreateOrder = False
  ShowHint = True
  OnActivate = FormActivate
  OnCanResize = FormCanResize
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnPaint = FormPaint
  OnResize = TntFormResize
  OnShow = TntFormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DockTop: TSpTBXDock
    Left = 0
    Top = 0
    Width = 905
    Height = 52
    BackgroundOnToolbars = False
    BoundLines = [blBottom]
    object ToolbarFile: TSpTBXToolbar
      Left = 0
      Top = 25
      ChevronPriorityForNewItems = tbcpLowest
      CloseButton = False
      DockPos = 0
      DockRow = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Caption = 'File'
      object SpTBXItem3: TSpTBXItem
        Action = Actions.acNew
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem2: TSpTBXItem
        Action = Actions.acOpen
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem1: TSpTBXItem
        Action = Actions.acSave
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem4: TSpTBXItem
        Action = Actions.acPrint
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXSeparatorItem1: TSpTBXSeparatorItem
      end
      object SpTBXItem6: TSpTBXItem
        Action = Actions.acFavorites
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem5: TSpTBXItem
        Action = Actions.acGameInfo
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXSeparatorItem3: TSpTBXSeparatorItem
      end
      object SpTBXItem12: TSpTBXItem
        Action = Actions.acViewBoard
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem11: TSpTBXItem
        Action = Actions.acViewInfo
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem10: TSpTBXItem
        Action = Actions.acViewThumb
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXSeparatorItem2: TSpTBXSeparatorItem
      end
      object SpTBXItem9: TSpTBXItem
        Action = Actions.acCreateDatabase
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem8: TSpTBXItem
        Action = Actions.acOpenDatabase
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object SpTBXItem7: TSpTBXItem
        Action = Actions.acSearchDB
        Images = Actions.ImageList
        MinHeight = 20
        MinWidth = 20
      end
      object btQuickSearch: TSpTBXItem
        Action = Actions.acQuickSearch
        Images = Actions.ImageList
      end
      object SpTBXSeparatorItem4: TSpTBXSeparatorItem
      end
      object SpTBXItem13: TSpTBXItem
        Action = Actions.acOptions
        Images = Actions.ImageList
      end
    end
    object SpTBXMainMenu: TSpTBXToolbar
      Left = 0
      Top = 0
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = -16
      DragHandleStyle = dhNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FullSize = True
      ParentFont = False
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 1
      Caption = 'SpTBXMainMenu'
      Customizable = False
      MenuBar = True
      object mnFile: TSpTBXSubmenuItem
        Caption = 'File'
        OnClick = mnFileClick
        object SpTBXItem14: TSpTBXItem
          Action = Actions.acNew
          Images = Actions.ImageList
          MinHeight = 20
          MinWidth = 20
        end
        object SpTBXItem18: TSpTBXItem
          Action = Actions.acOpen
          Images = Actions.ImageList
        end
        object SpTBXItem17: TSpTBXItem
          Action = Actions.acOpenFolder
          Images = Actions.ImageList
        end
        object SpTBXItem16: TSpTBXItem
          Action = Actions.acSave
          Images = Actions.ImageList
        end
        object SpTBXItem15: TSpTBXItem
          Action = Actions.acSaveAs
          Images = Actions.ImageList
        end
        object mnReadOnly: TSpTBXItem
          Action = Actions.acReadOnly
          Images = Actions.ImageList
        end
        object SpTBXItem20: TSpTBXItem
          Action = Actions.acClose
          Images = Actions.ImageList
        end
        object SpTBXItem19: TSpTBXItem
          Action = Actions.acCloseAll
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem5: TSpTBXSeparatorItem
        end
        object mnCollections: TSpTBXSubmenuItem
          Caption = 'Collections'
          object SpTBXItem25: TSpTBXItem
            Action = Actions.acAppend
            Images = Actions.ImageList
          end
          object SpTBXItem24: TSpTBXItem
            Action = Actions.acMerge
            Images = Actions.ImageList
          end
          object SpTBXItem23: TSpTBXItem
            Action = Actions.acExtractCurrent
            Images = Actions.ImageList
          end
          object SpTBXItem22: TSpTBXItem
            Action = Actions.acExtractAll
            Images = Actions.ImageList
          end
          object SpTBXItem162: TSpTBXItem
            Action = Actions.acDeleteGame
          end
          object mnMakeGameTree: TSpTBXItem
            Action = Actions.acMakeGameTree
          end
        end
        object SpTBXSeparatorItem6: TSpTBXSeparatorItem
        end
        object SpTBXItem158: TSpTBXItem
          Action = Actions.acOpenFromClipBoard
          Images = Actions.ImageList
        end
        object SpTBXItem155: TSpTBXItem
          Action = Actions.acSaveToClipboard
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem32: TSpTBXSeparatorItem
        end
        object SpTBXItem27: TSpTBXItem
          Action = Actions.acFavorites
          Images = Actions.ImageList
        end
        object SpTBXItem26: TSpTBXItem
          Action = Actions.acGameInfo
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem8: TSpTBXSeparatorItem
        end
        object SpTBXItem30: TSpTBXItem
          Action = Actions.acPrint
          Images = Actions.ImageList
        end
        object SpTBXItem29: TSpTBXItem
          Action = Actions.acExport
          Images = Actions.ImageList
        end
        object SpTBXItem28: TSpTBXItem
          Action = Actions.acExportPos
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem7: TSpTBXSeparatorItem
        end
        object SpTBXItem35: TSpTBXItem
          Action = Actions.acQuit
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem9: TSpTBXSeparatorItem
        end
        object mnFile1: TSpTBXItem
          OnClick = mnFile1PrevClick
        end
        object mnFile2: TSpTBXItem
          Tag = 1
          OnClick = mnFile1PrevClick
        end
        object mnFile3: TSpTBXItem
          Tag = 2
          OnClick = mnFile1PrevClick
        end
        object mnFile4: TSpTBXItem
          Tag = 3
          OnClick = mnFile1PrevClick
        end
      end
      object mnView: TSpTBXSubmenuItem
        Caption = 'View'
        object SpTBXItem160: TSpTBXItem
          Action = Actions.acFullScreen
          Images = Actions.ImageList
        end
        object SpTBXItem40: TSpTBXItem
          Action = Actions.acViewBoard
          Images = Actions.ImageList
        end
        object SpTBXItem39: TSpTBXItem
          Action = Actions.acViewInfo
          Images = Actions.ImageList
        end
        object SpTBXItem38: TSpTBXItem
          Action = Actions.acViewThumb
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem10: TSpTBXSeparatorItem
        end
        object SpTBXItem135: TSpTBXItem
          Action = Actions.acRestoreTrans
          Images = Actions.ImageList
        end
        object SpTBXItem31: TSpTBXItem
          Action = Actions.acMirror
          Images = Actions.ImageList
        end
        object SpTBXItem134: TSpTBXItem
          Action = Actions.acFlip
          Images = Actions.ImageList
        end
        object SpTBXItem133: TSpTBXItem
          Action = Actions.acRotate180
          Images = Actions.ImageList
        end
        object SpTBXItem132: TSpTBXItem
          Action = Actions.acRotate90Clock
          Images = Actions.ImageList
        end
        object SpTBXItem131: TSpTBXItem
          Action = Actions.acRotate90Trigo
          Images = Actions.ImageList
        end
        object SpTBXItem136: TSpTBXItem
          Action = Actions.acSwapColors
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem28: TSpTBXSeparatorItem
        end
        object mnShowToolbars: TSpTBXSubmenuItem
          Caption = 'Show toolbars'
          OnClick = mnShowToolbarsClick
          object mnShowTB_File: TSpTBXItem
            Caption = 'File'
            Checked = True
            OnClick = mnShowTB_Click
          end
          object mnShowTB_View: TSpTBXItem
            Caption = 'View'
            Checked = True
            OnClick = mnShowTB_Click
          end
          object mnShowTB_Navigation: TSpTBXItem
            Caption = 'Navigation'
            Checked = True
            OnClick = mnShowTB_Click
          end
          object mnShowTB_Edit: TSpTBXItem
            Caption = 'Edit'
            Checked = True
            OnClick = mnShowTB_Click
          end
          object mnShowTB_Misc: TSpTBXItem
            Caption = 'Misc'
            Checked = True
            OnClick = mnShowTB_Click
          end
        end
        object SpTBXItem146: TSpTBXItem
          Action = Actions.acToolbarSettings
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem17: TSpTBXSeparatorItem
        end
        object SpTBXItem37: TSpTBXItem
          Action = Actions.acBoardSettings
          Images = Actions.ImageList
        end
        object SpTBXItem36: TSpTBXItem
          Action = Actions.acPreviewSettings
          Images = Actions.ImageList
        end
      end
      object mnNavigation: TSpTBXSubmenuItem
        Caption = 'Navigation'
        object SpTBXItem54: TSpTBXItem
          Action = Actions.acFirstGame
          Images = Actions.ImageList
        end
        object SpTBXItem53: TSpTBXItem
          Action = Actions.acPrevGame
          Images = Actions.ImageList
        end
        object SpTBXItem52: TSpTBXItem
          Action = Actions.acNextGame
          Images = Actions.ImageList
        end
        object SpTBXItem51: TSpTBXItem
          Action = Actions.acLastGame
          Images = Actions.ImageList
        end
        object SpTBXItem50: TSpTBXItem
          Action = Actions.acSelectGame
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem11: TSpTBXSeparatorItem
        end
        object SpTBXItem59: TSpTBXItem
          Action = Actions.acStartPos
          Images = Actions.ImageList
        end
        object SpTBXItem58: TSpTBXItem
          Action = Actions.acPrevMove
          Images = Actions.ImageList
        end
        object SpTBXItem57: TSpTBXItem
          Action = Actions.acNextMove
          Images = Actions.ImageList
        end
        object SpTBXItem56: TSpTBXItem
          Action = Actions.acEndPos
          Images = Actions.ImageList
        end
        object SpTBXItem55: TSpTBXItem
          Action = Actions.acSelectMove
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem12: TSpTBXSeparatorItem
        end
        object SpTBXItem63: TSpTBXItem
          Action = Actions.acPrevTarget
          Images = Actions.ImageList
        end
        object SpTBXItem62: TSpTBXItem
          Action = Actions.acNextTarget
          Images = Actions.ImageList
        end
        object SpTBXItem61: TSpTBXItem
          Action = Actions.acAutoReplay
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem13: TSpTBXSeparatorItem
        end
        object SpTBXItem60: TSpTBXItem
          Action = Actions.acNavigationSettings
          Images = Actions.ImageList
        end
      end
      object mnEdition: TSpTBXSubmenuItem
        Caption = 'Edit'
        object SpTBXItem64: TSpTBXItem
          Action = Actions.acUndoMove
          Images = Actions.ImageList
        end
        object SpTBXItem45: TSpTBXItem
          Action = Actions.acDeleteBranch
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem14: TSpTBXSeparatorItem
        end
        object SpTBXSubmenuItem6: TSpTBXSubmenuItem
          Action = Actions.acGameEdit
          Images = Actions.ImageList
          object SpTBXItem69: TSpTBXItem
            Action = Actions.acGameEditBlackFirst
            Images = Actions.ImageList
          end
          object SpTBXItem68: TSpTBXItem
            Action = Actions.acGameEditWhiteFirst
            Images = Actions.ImageList
          end
        end
        object SpTBXItem67: TSpTBXItem
          Action = Actions.acAddBlack
          Images = Actions.ImageList
        end
        object SpTBXItem41: TSpTBXItem
          Action = Actions.acAddWhite
          Images = Actions.ImageList
        end
        object SpTBXItem70: TSpTBXItem
          Action = Actions.acEmpty
        end
        object SpTBXSubmenuItem7: TSpTBXSubmenuItem
          Action = Actions.acMarkup
          Images = Actions.ImageList
          object SpTBXItem76: TSpTBXItem
            Action = Actions.acMarkupCross
            Images = Actions.ImageList
          end
          object SpTBXItem75: TSpTBXItem
            Action = Actions.acMarkupTriangle
            Images = Actions.ImageList
          end
          object SpTBXItem74: TSpTBXItem
            Action = Actions.acMarkupCircle
            Images = Actions.ImageList
          end
          object SpTBXItem73: TSpTBXItem
            Action = Actions.acMarkupSquare
            Images = Actions.ImageList
          end
          object SpTBXItem72: TSpTBXItem
            Action = Actions.acMarkupLetter
            Images = Actions.ImageList
          end
          object SpTBXItem71: TSpTBXItem
            Action = Actions.acMarkupNumber
            Images = Actions.ImageList
          end
          object SpTBXItem77: TSpTBXItem
            Action = Actions.acMarkupLabel
            Images = Actions.ImageList
          end
          object SpTBXSeparatorItem16: TSpTBXSeparatorItem
          end
          object SpTBXItem79: TSpTBXItem
            Action = Actions.acBlackTerritory
            Images = Actions.ImageList
          end
          object SpTBXItem78: TSpTBXItem
            Action = Actions.acWhiteTerritory
            Images = Actions.ImageList
          end
        end
        object SpTBXSeparatorItem15: TSpTBXSeparatorItem
        end
        object mnPlayer: TSpTBXSubmenuItem
          Caption = 'Player'
          object SpTBXItem102: TSpTBXItem
            Action = Actions.acBlackToPlay
            Images = Actions.ImageList
          end
          object SpTBXItem100: TSpTBXItem
            Action = Actions.acWhiteToPlay
            Images = Actions.ImageList
          end
        end
        object SpTBXItem99: TSpTBXItem
          Action = Actions.acInsertPass
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem22: TSpTBXSeparatorItem
        end
        object SpTBXItem101: TSpTBXItem
          Action = Actions.acInsert
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem30: TSpTBXSeparatorItem
        end
        object SpTBXItem108: TSpTBXItem
          Action = Actions.acMakeMainBranch
        end
        object SpTBXItem159: TSpTBXItem
          Action = Actions.acPromoteVariation
        end
        object SpTBXItem163: TSpTBXItem
          Action = Actions.acDemoteVariation
        end
        object SpTBXSeparatorItem34: TSpTBXSeparatorItem
        end
        object SpTBXItem156: TSpTBXItem
          Action = Actions.acRemoveProperties
        end
        object SpTBXItem161: TSpTBXItem
          Action = Actions.acInsertEmptyNode
        end
      end
      object mnDatabase: TSpTBXSubmenuItem
        Caption = 'Database'
        object SpTBXItem66: TSpTBXItem
          Action = Actions.acCreateDatabase
          Images = Actions.ImageList
        end
        object SpTBXItem65: TSpTBXItem
          Action = Actions.acOpenDatabase
          Images = Actions.ImageList
        end
        object SpTBXItem86: TSpTBXItem
          Action = Actions.acAddToDatabase
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem19: TSpTBXSeparatorItem
        end
        object SpTBXItem85: TSpTBXItem
          Action = Actions.acSearchDB
          Images = Actions.ImageList
        end
        object SpTBXItem21: TSpTBXItem
          Action = Actions.acQuickSearch
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem18: TSpTBXSeparatorItem
        end
        object SpTBXItem84: TSpTBXItem
          Action = Actions.acDatabaseSettings
          Images = Actions.ImageList
        end
      end
      object mnLibrary: TSpTBXItem
        Caption = 'Library'
      end
      object mnReplayGames: TSpTBXSubmenuItem
        Caption = 'Games'
        object SpTBXItem88: TSpTBXItem
          Action = Actions.acGmSession
          Images = Actions.ImageList
        end
        object SpTBXItem87: TSpTBXItem
          Action = Actions.acGmIndex
          Images = Actions.ImageList
        end
        object SpTBXItem42: TSpTBXItem
          Action = Actions.acGmCancel
          Images = Actions.ImageList
        end
      end
      object mnJoseki: TSpTBXItem
        Caption = 'Joseki'
        OnClick = mnJosekiClick
      end
      object mnProblems: TSpTBXSubmenuItem
        Caption = 'Problems'
        object SpTBXItem89: TSpTBXItem
          Action = Actions.acPbSession
          Images = Actions.ImageList
        end
        object SpTBXItem49: TSpTBXItem
          Action = Actions.acPbIndex
          Images = Actions.ImageList
        end
        object SpTBXItem48: TSpTBXItem
          Action = Actions.acPbHint
          Images = Actions.ImageList
        end
        object mnPbFreeMode: TSpTBXItem
          Action = Actions.acPbToggleFreeMode
          Images = Actions.ImageList
        end
        object SpTBXItem44: TSpTBXItem
          Action = Actions.acPbCancel
          Images = Actions.ImageList
        end
      end
      object mnEngineGame: TSpTBXSubmenuItem
        Caption = 'Play'
        object SpTBXItem95: TSpTBXItem
          Action = Actions.acNewEngineGame
          Images = Actions.ImageList
        end
        object SpTBXItem94: TSpTBXItem
          Action = Actions.acPass
          Images = Actions.ImageList
        end
        object SpTBXItem93: TSpTBXItem
          Action = Actions.acResign
          Images = Actions.ImageList
        end
        object SpTBXItem92: TSpTBXItem
          Action = Actions.acCancelGame
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem21: TSpTBXSeparatorItem
        end
        object SpTBXItem91: TSpTBXItem
          Action = Actions.acScoreEstimate
          Images = Actions.ImageList
        end
        object SpTBXItem96: TSpTBXItem
          Action = Actions.acSuggestMove
          Images = Actions.ImageList
        end
        object SpTBXItem150: TSpTBXItem
          Action = Actions.acInfluenceRegions
          Images = Actions.ImageList
        end
        object SpTBXItem157: TSpTBXItem
          Action = Actions.acGroupStatus
          Images = Actions.ImageList
        end
        object SpTBXItem151: TSpTBXItem
          Action = Actions.acShowGtpWindow
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem20: TSpTBXSeparatorItem
        end
        object SpTBXItem90: TSpTBXItem
          Action = Actions.acEngineSettings
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem31: TSpTBXSeparatorItem
        end
        object mnTestEngine: TSpTBXItem
          Caption = 'Test'
          OnClick = mnTestEngineClick
        end
      end
      object mnOptions: TSpTBXSubmenuItem
        Caption = 'Options'
        object SpTBXItem148: TSpTBXItem
          Action = Actions.acOptions
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem29: TSpTBXSeparatorItem
        end
        object SpTBXItem147: TSpTBXItem
          Action = Actions.acNavigationSettings
          Images = Actions.ImageList
        end
        object SpTBXItem154: TSpTBXItem
          Action = Actions.acDatabaseSettings
          Images = Actions.ImageList
        end
        object SpTBXItem153: TSpTBXItem
          Action = Actions.acEngineSettings
          Images = Actions.ImageList
        end
        object SpTBXItem152: TSpTBXItem
          Action = Actions.acLanguageSettings
          Images = Actions.ImageList
        end
        object SpTBXItem149: TSpTBXItem
          Action = Actions.acSidebarSettings
          Images = Actions.ImageList
        end
      end
      object mnHelp: TSpTBXSubmenuItem
        Caption = 'Help'
        object SpTBXItem98: TSpTBXItem
          Action = Actions.acDisplayHelp
          Images = Actions.ImageList
        end
        object SpTBXItem165: TSpTBXItem
          Action = Actions.acHome
          Images = Actions.ImageList
        end
        object SpTBXItem164: TSpTBXItem
          Action = Actions.acDonate
          Images = Actions.ImageList
        end
        object SpTBXItem97: TSpTBXItem
          Action = Actions.acAbout
          Images = Actions.ImageList
        end
      end
      object mnDebug: TSpTBXSubmenuItem
        Caption = 'Debug'
        OnClick = mnDebugClick
        object mnResources: TSpTBXItem
          Caption = 'Resources'
          OnClick = mnResourcesClick
        end
        object SpTBXItem111: TSpTBXItem
          Caption = 'Bench read'
          OnClick = mnBenchReadClick
        end
        object SpTBXItem110: TSpTBXItem
          Caption = 'Bench span'
          OnClick = mnBenchSpanClick
        end
        object SpTBXItem109: TSpTBXItem
          Caption = 'List current tree'
          OnClick = mnListCurrentClick
        end
        object mnSaveCurrent: TSpTBXItem
          Caption = 'Save current tree'
          OnClick = mnSaveCurrentClick
        end
        object SpTBXItem107: TSpTBXItem
          Caption = 'Span current tree'
          OnClick = mnSpanCurrentClick
        end
        object SpTBXItem106: TSpTBXItem
          Caption = 'Test editing'
          OnClick = mnTestEditingClick
        end
        object SpTBXItem105: TSpTBXItem
          Caption = 'Test trans'
          OnClick = mnTestTransClick
        end
        object SpTBXItem104: TSpTBXItem
          Caption = 'Test GTP'
          OnClick = mnTestGTPClick
        end
        object mnTestDivers: TSpTBXItem
          Caption = 'Test divers'
          OnClick = mnTestDiversClick
        end
      end
    end
    object ToolbarEdit: TSpTBXToolbar
      Left = 212
      Top = 25
      ChevronPriorityForNewItems = tbcpLowest
      CloseButton = False
      DockPos = 212
      DockRow = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Caption = 'Edit'
      object SpTBXItem46: TSpTBXItem
        Action = Actions.acUndoMove
        Images = Actions.ImageList
      end
      object SpTBXItem115: TSpTBXItem
        Action = Actions.acDeleteBranch
        Images = Actions.ImageList
      end
      object SpTBXSeparatorItem26: TSpTBXSeparatorItem
      end
      object tbGameEdit: TSpTBXSubmenuItem
        Action = Actions.acGameEdit
        Images = Actions.ImageList
        DropdownCombo = True
        object SpTBXItem126: TSpTBXItem
          Action = Actions.acGameEditBlackFirst
          Images = Actions.ImageList
        end
        object SpTBXItem125: TSpTBXItem
          Action = Actions.acGameEditWhiteFirst
          Images = Actions.ImageList
        end
      end
      object SpTBXItem114: TSpTBXItem
        Action = Actions.acAddBlack
        Images = Actions.ImageList
      end
      object SpTBXItem113: TSpTBXItem
        Action = Actions.acAddWhite
        Images = Actions.ImageList
      end
      object tbCurrentMarkup: TSpTBXSubmenuItem
        Caption = 'Current markup'
        ImageIndex = 18
        Images = Actions.ImageList
        DropdownCombo = True
        object SpTBXItem124: TSpTBXItem
          Action = Actions.acMarkupCross
          Images = Actions.ImageList
        end
        object SpTBXItem123: TSpTBXItem
          Action = Actions.acMarkupTriangle
          Images = Actions.ImageList
        end
        object SpTBXItem122: TSpTBXItem
          Action = Actions.acMarkupCircle
          Images = Actions.ImageList
        end
        object SpTBXItem121: TSpTBXItem
          Action = Actions.acMarkupSquare
          Images = Actions.ImageList
        end
        object SpTBXItem120: TSpTBXItem
          Action = Actions.acMarkupLetter
          Images = Actions.ImageList
        end
        object SpTBXItem119: TSpTBXItem
          Action = Actions.acMarkupNumber
          Images = Actions.ImageList
        end
        object SpTBXItem118: TSpTBXItem
          Action = Actions.acMarkupLabel
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem24: TSpTBXSeparatorItem
        end
        object SpTBXItem117: TSpTBXItem
          Action = Actions.acBlackTerritory
          Images = Actions.ImageList
        end
        object SpTBXItem116: TSpTBXItem
          Action = Actions.acWhiteTerritory
          Images = Actions.ImageList
        end
        object SpTBXSeparatorItem33: TSpTBXSeparatorItem
        end
        object btMarkupWildcard: TSpTBXItem
          Action = Actions.acWildcard
          Images = Actions.ImageList
        end
      end
      object SpTBXItem112: TSpTBXItem
        Action = Actions.acInsert
        Images = Actions.ImageList
      end
    end
    object ToolbarNavigation: TSpTBXToolbar
      Left = 525
      Top = 25
      ChevronPriorityForNewItems = tbcpLowest
      CloseButton = False
      DockPos = 488
      DockRow = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      Caption = 'Navigation'
      Customizable = False
      object SpTBXItem81: TSpTBXItem
        Action = Actions.acFirstGame
        Images = Actions.ImageList
      end
      object SpTBXItem80: TSpTBXItem
        Action = Actions.acPrevGame
        Images = Actions.ImageList
      end
      object SpTBXItem34: TSpTBXItem
        Action = Actions.acNextGame
        Images = Actions.ImageList
      end
      object SpTBXItem33: TSpTBXItem
        Action = Actions.acLastGame
        Images = Actions.ImageList
      end
      object SpTBXItem32: TSpTBXItem
        Action = Actions.acSelectGame
        Images = Actions.ImageList
      end
      object SpTBXSeparatorItem23: TSpTBXSeparatorItem
      end
      object SpTBXItem129: TSpTBXItem
        Action = Actions.acStartPos
        Images = Actions.ImageList
      end
      object SpTBXItem128: TSpTBXItem
        Action = Actions.acPrevMove
        Images = Actions.ImageList
      end
      object SpTBXItem127: TSpTBXItem
        Action = Actions.acNextMove
        Images = Actions.ImageList
      end
      object SpTBXItem83: TSpTBXItem
        Action = Actions.acEndPos
        Images = Actions.ImageList
      end
      object SpTBXItem82: TSpTBXItem
        Action = Actions.acSelectMove
        Images = Actions.ImageList
      end
      object SpTBXSeparatorItem25: TSpTBXSeparatorItem
      end
      object tbPrevTarget: TSpTBXItem
        Action = Actions.acPrevTarget
        Images = Actions.ImageList
      end
      object tbNextTarget: TSpTBXSubmenuItem
        Action = Actions.acNextTarget
        Images = Actions.ImageList
        Options = [tboDropdownArrow]
        DropdownCombo = True
        object SpTBXItem43: TSpTBXItem
          Action = Actions.acNavigationSettings
          Images = Actions.ImageList
        end
      end
      object tbAutoReplay: TSpTBXSubmenuItem
        Action = Actions.acAutoReplay
        Images = Actions.ImageList
        Options = [tboDropdownArrow]
        DropdownCombo = True
        object SpTBXItem47: TSpTBXItem
          Action = Actions.acNavigationSettings
          Images = Actions.ImageList
        end
      end
    end
    object ToolbarView: TSpTBXToolbar
      Left = 320
      Top = 25
      ChevronPriorityForNewItems = tbcpLowest
      CloseButton = False
      DockPos = 320
      DockRow = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Visible = False
      Caption = 'View'
      object SpTBXItem103: TSpTBXItem
        Action = Actions.acViewBoard
        Images = Actions.ImageList
      end
      object SpTBXItem137: TSpTBXItem
        Action = Actions.acViewInfo
        Images = Actions.ImageList
      end
      object SpTBXItem138: TSpTBXItem
        Action = Actions.acViewThumb
        Images = Actions.ImageList
      end
      object SpTBXSeparatorItem27: TSpTBXSeparatorItem
      end
      object SpTBXItem142: TSpTBXItem
        Action = Actions.acRestoreTrans
        Images = Actions.ImageList
      end
      object SpTBXItem141: TSpTBXItem
        Action = Actions.acMirror
        Images = Actions.ImageList
      end
      object SpTBXItem140: TSpTBXItem
        Action = Actions.acFlip
        Images = Actions.ImageList
      end
      object SpTBXItem139: TSpTBXItem
        Action = Actions.acRotate180
        Images = Actions.ImageList
      end
      object SpTBXItem144: TSpTBXItem
        Action = Actions.acRotate90Clock
        Images = Actions.ImageList
      end
      object SpTBXItem143: TSpTBXItem
        Action = Actions.acRotate90Trigo
        Images = Actions.ImageList
      end
      object SpTBXItem145: TSpTBXItem
        Action = Actions.acSwapColors
        Images = Actions.ImageList
      end
    end
    object ToolbarMisc: TSpTBXToolbar
      Left = 872
      Top = 25
      ChevronPriorityForNewItems = tbcpLowest
      CloseButton = False
      DockPos = 922
      DockRow = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Caption = 'Misc2'
      object SpTBXItem130: TSpTBXItem
        Action = Actions.acNewEngineGame
        Images = Actions.ImageList
      end
    end
  end
  object MainPageControl: TTntPageControl
    Left = 9
    Top = 52
    Width = 887
    Height = 387
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = MainPageControlChange
    OnDragDrop = MainPageControlDragDrop
    OnDragOver = MainPageControlDragOver
    OnMouseDown = MainPageControlMouseDown
    OnMouseMove = MainPageControlMouseMove
    OnMouseUp = MainPageControlMouseUp
  end
  object StatusBar: TTntStatusBar
    Left = 0
    Top = 448
    Width = 905
    Height = 26
    Panels = <>
    ParentColor = True
    OnDrawPanel = StatusBarDrawPanel
  end
  object DockRight: TSpTBXDock
    Left = 896
    Top = 52
    Width = 9
    Height = 387
    Color = clBtnFace
    Position = dpRight
  end
  object DockBottom: TSpTBXDock
    Left = 0
    Top = 439
    Width = 905
    Height = 9
    Color = clBtnFace
    Position = dpBottom
  end
  object DockLeft: TSpTBXDock
    Left = 0
    Top = 52
    Width = 9
    Height = 387
    Color = clBtnFace
    Position = dpLeft
  end
  object pmMarkup: TPopupMenu
    Images = Actions.ImageList
    Left = 88
    Top = 176
    object pmMarkupCross: TTntMenuItem
      Action = Actions.acMarkupCross
      RadioItem = True
    end
    object pmMarkupTriangle: TTntMenuItem
      Action = Actions.acMarkupTriangle
      RadioItem = True
    end
    object pmMarkupCircle: TTntMenuItem
      Action = Actions.acMarkupCircle
      RadioItem = True
    end
    object pmMarkupSquare: TTntMenuItem
      Action = Actions.acMarkupSquare
      RadioItem = True
    end
    object pmMarkupLetter: TTntMenuItem
      Action = Actions.acMarkupLetter
      RadioItem = True
    end
    object pmMarkupNumber: TTntMenuItem
      Action = Actions.acMarkupNumber
      RadioItem = True
    end
    object pmMarkupLabel: TTntMenuItem
      Action = Actions.acMarkupLabel
    end
    object N9: TTntMenuItem
      Caption = '-'
    end
    object pmBlackTerritory: TTntMenuItem
      Action = Actions.acBlackTerritory
      RadioItem = True
    end
    object pmWhiteTerritory: TTntMenuItem
      Action = Actions.acWhiteTerritory
      RadioItem = True
    end
  end
  object tmMemory: TTimer
    Enabled = False
    OnTimer = tmMemoryTimer
    Left = 352
    Top = 64
  end
  object pmTab1: TPopupMenu
    AutoPopup = False
    Images = Actions.ImageList
    OnPopup = pmTab1Popup
    Left = 88
    Top = 231
    object mnNewInTab: TTntMenuItem
      Action = Actions.acNewInTab
    end
    object mnOpenInTab: TTntMenuItem
      Action = Actions.acOpenInTab
    end
    object mnOpenFolderInTab: TTntMenuItem
      Action = Actions.acOpenFolderInTab
    end
    object Reloadcurrentfile1: TTntMenuItem
      Action = Actions.acReloadCurrentFile
    end
    object N15: TTntMenuItem
      Caption = '-'
    end
    object mnSave2: TTntMenuItem
      Action = Actions.acSave
    end
    object mnSaveAs2: TTntMenuItem
      Action = Actions.acSaveAs
    end
    object N16: TTntMenuItem
      Caption = '-'
    end
    object mnCloseTab: TTntMenuItem
      Action = Actions.acClose
    end
    object mnCloseAll2: TTntMenuItem
      Action = Actions.acCloseAll
    end
  end
  object pmTab2: TPopupMenu
    Images = Actions.ImageList
    Left = 88
    Top = 288
    object mnNew2: TTntMenuItem
      Action = Actions.acNew
    end
    object mnOpen2: TTntMenuItem
      Action = Actions.acOpen
    end
    object mnOpenFolder2: TTntMenuItem
      Action = Actions.acOpenFolder
    end
    object N17: TTntMenuItem
      Caption = '-'
    end
    object mnCloseAll3: TTntMenuItem
      Action = Actions.acCloseAll
    end
  end
  object pmEditMode: TPopupMenu
    Images = Actions.ImageList
    Left = 88
    Top = 120
    object mnEditGameBlackFirst: TTntMenuItem
      Action = Actions.acGameEditBlackFirst
      AutoCheck = True
    end
    object mnEditGameWhiteFirst: TTntMenuItem
      Action = Actions.acGameEditWhiteFirst
      AutoCheck = True
    end
  end
  object BtnImages: TImageList
    Height = 10
    Width = 10
    Left = 272
    Top = 120
    Bitmap = {
      494C01010300040004000A000A00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000280000000A00000001002000000000004006
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00DEDEDE00DEDE
      DE0000000000DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE0000000000DEDE
      DE00DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00C6C6C600F7F7F700F7F7
      F70000000000F7F7F700F7F7F700F7F7F700F7F7F70000000000F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE000000
      0000DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE000000
      0000DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F70000000000F7F7F700F7F7F70000000000F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE000000000000000000DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE000000000000000000DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F7000000000000000000F7F7F700F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE000000000000000000DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE000000000000000000DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F7000000000000000000F7F7F700F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE000000
      0000DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE000000
      0000DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F70000000000F7F7F700F7F7F70000000000F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00DEDEDE00DEDE
      DE0000000000DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE0000000000DEDE
      DE00DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00C6C6C600F7F7F700F7F7
      F70000000000F7F7F700F7F7F700F7F7F700F7F7F70000000000F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      28000000280000000A0000000100010000000000500000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000}
  end
  object TabBtnImages: TImageList
    Left = 272
    Top = 176
  end
  object ApplicationEvents: TApplicationEvents
    OnException = ApplicationEventsException
    OnMessage = ApplicationEventsMessage
    Left = 440
    Top = 64
  end
  object TabImages: TImageList
    Left = 272
    Top = 64
    Bitmap = {
      494C010106000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000EFEF0000DEDE0000DEDE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000EFEF0000DEDE0000DEDE0000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000EFEF0000DEDE0000DEDE0000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000EFEF0000DEDE0000DEDE0000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000EFEF0000DEDE0000DEDE0000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000000000000000000000000000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000EFEF0000DEDE0000DEDE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00C6C6C60000000000FFFFFF0000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000EFEF0000DEDE0000DEDE0000CECE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000009C9C9C004A4A4A00737373008C8C8C00BDBDBD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00005252520029292900212121008C8C8C00949494009C9C9C00ADADAD000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00C6C6
      C60000000000000000000000000000000000000000000000000000000000A5A5
      A5002929290021212100212121009C9C9C00A5A5A500ADADAD00ADADAD00DEDE
      DE00000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00C6C6
      C600000000000000000000000000000000000000000000000000000000004A4A
      4A00212121002121210029292900A5A5A500ADADAD00B5B5B500BDBDBD00BDBD
      BD00000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00C6C6C60000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000003131
      310021212100212121002929290039393900B5B5B500BDBDBD00BDBDBD00BDBD
      BD00000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF00C6C6C60000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000004A4A
      4A002121210029292900313131004A4A4A00BDBDBD00CECECE00DEDEDE00CECE
      CE00000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00C6C6C60000000000FFFFFF0000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00C6C6C60000000000FFFFFF0000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      000084848400000000000000000000000000000000000000000000000000A5A5
      A50031313100292929003939390052525200CECECE00DEDEDE00E7E7E700E7E7
      E700000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00005A5A5A00393939003939390052525200CECECE00DEDEDE00DEDEDE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A5A5A500525252004A4A4A00CECECE00E7E7E700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFF00000000FFFFFFFF00000000
      FFFFFC3F00000000E01FF81F00000000E01BF00F00000000E015F00F00000000
      E015F00F00000000E01FF00F00000000E015F00F00000000E015F00F00000000
      E01BF00F00000000E03FF81F00000000FFFFFFFF00000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFF00FF00FFFFFFFFFF00FF00FF007F83FF00FF00FF007F01F
      F00FF00FF007E00FF00FF00FF007E00FF00FF00FF007E00FF00FF00FF007E00F
      F00FF00FF007E00FF01FF01FF8FFF01FFFFFFFFFFFFFF83FFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object GridImages: TImageList
    Height = 11
    Width = 11
    Left = 272
    Top = 232
    Bitmap = {
      494C01010300040004000B000B00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000002C0000000B00000001002000000000009007
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F70084848400DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00DEDE
      DE00DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE00DEDEDE0000000000DEDEDE00DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F70000000000F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE000000
      00000000000000000000DEDEDE00DEDEDE00DEDEDE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600DEDEDE00DEDEDE00DEDEDE00000000000000000000000000DEDE
      DE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7F700F7F7F700F7F7F7000000
      00000000000000000000F7F7F700F7F7F700F7F7F700F7F7F70084848400DEDE
      DE00DEDEDE00DEDEDE000000000000000000000000000000000000000000DEDE
      DE00DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE000000
      000000000000000000000000000000000000DEDEDE00DEDEDE00C6C6C600F7F7
      F700F7F7F700F7F7F7000000000000000000000000000000000000000000F7F7
      F700F7F7F700F7F7F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F70084848400DEDE
      DE00DEDEDE00DEDEDE000000000000000000000000000000000000000000DEDE
      DE00DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE000000
      000000000000000000000000000000000000DEDEDE00DEDEDE00C6C6C600F7F7
      F700F7F7F700F7F7F7000000000000000000000000000000000000000000F7F7
      F700F7F7F700F7F7F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE000000
      00000000000000000000DEDEDE00DEDEDE00DEDEDE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600DEDEDE00DEDEDE00DEDEDE00000000000000000000000000DEDE
      DE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7F700F7F7F700F7F7F7000000
      00000000000000000000F7F7F700F7F7F700F7F7F700F7F7F70084848400DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0000000000DEDEDE00DEDEDE00DEDE
      DE00DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600DEDEDE00DEDEDE00DEDE
      DE00DEDEDE0000000000DEDEDE00DEDEDE00DEDEDE00DEDEDE00C6C6C600F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F70000000000F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F70084848400DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE00DEDEDE00C6C6C600F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F70084848400DEDE
      DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
      DE00DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F70084848400848484008484840084848400848484008484
      8400848484008484840084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424D3E000000000000003E000000280000002C0000000B00000001000100
      00000000580000000000000000000000000000000000000000000000FFFFFF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000}
  end
  object MenuForShortcuts: TMainMenu
    Left = 88
    Top = 72
    object ActionsWithShortcut: TMenuItem
      Caption = 'Actions with shortcut'
    end
  end
  object OneInstance: TOneInstance
    Left = 544
    Top = 72
  end
end
