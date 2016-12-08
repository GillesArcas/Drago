object frViewBoard: TfrViewBoard
  Left = 0
  Top = 0
  Width = 937
  Height = 652
  Color = clBtnFace
  ParentColor = False
  TabOrder = 0
  OnMouseWheelDown = FrameMouseWheelDown
  OnMouseWheelUp = FrameMouseWheelUp
  OnResize = FrameResize
  object bvGoban: TBevel
    Left = 24
    Top = 96
    Width = 50
    Height = 50
    Shape = bsFrame
  end
  object imGoban: TImageEx
    Left = 24
    Top = 40
    Width = 49
    Height = 41
    OnMouseDown = imGobanMouseDown
    OnMouseMove = imGobanMouseMove
    OnMouseUp = imGobanMouseUp
    OnMouseEnter = imGobanMouseEnter
    OnMouseLeave = imGobanMouseLeave
  end
  object imImage: TImage
    Left = 16
    Top = 224
    Width = 57
    Height = 57
  end
  object bvMain1: TBevel
    Left = 0
    Top = 0
    Width = 937
    Height = 2
    Align = alTop
    Shape = bsTopLine
  end
  object bvMain2: TBevel
    Left = 0
    Top = 650
    Width = 937
    Height = 2
    Align = alBottom
    Shape = bsTopLine
  end
  object ToolButtonEx1: TToolButtonEx
    Left = 424
    Top = 312
    Caption = 'ToolButtonEx1'
  end
  object ToolButtonEx2: TToolButtonEx
    Left = 432
    Top = 320
    Caption = 'ToolButtonEx2'
  end
  object pnPlayers: TPanel
    Left = 286
    Top = 242
    Width = 169
    Height = 55
    BevelOuter = bvNone
    TabOrder = 1
    object lbBlack: TTntLabel
      Left = 11
      Top = 8
      Width = 27
      Height = 13
      Caption = 'Black'
      Transparent = False
    end
    object lbBlackV: TTntLabel
      Left = 73
      Top = 8
      Width = 54
      Height = 13
      Caption = '__lbBlackV'
      Transparent = False
    end
    object lbWhite: TTntLabel
      Left = 11
      Top = 27
      Width = 28
      Height = 13
      Caption = 'White'
      Transparent = False
    end
    object lbWhiteV: TTntLabel
      Left = 73
      Top = 27
      Width = 55
      Height = 13
      Caption = '__lbWhiteV'
      Transparent = False
    end
    object imBlackTurn: TImage
      Left = 144
      Top = 8
      Width = 16
      Height = 16
      Transparent = True
    end
    object imWhiteTurn: TImage
      Left = 143
      Top = 27
      Width = 16
      Height = 16
      Transparent = True
    end
  end
  object pnImage: TPanel
    Left = 24
    Top = 160
    Width = 49
    Height = 41
    BevelOuter = bvNone
    Caption = '__pnImage'
    TabOrder = 2
  end
  object edGobanFocus: TEdit
    Left = 80
    Top = 50
    Width = 0
    Height = 21
    TabStop = False
    TabOrder = 3
  end
  object MultiDockLeft: TSpTBXMultiDock
    Left = 0
    Top = 2
    Width = 9
    Height = 648
  end
  object MultiDockRight: TSpTBXMultiDock
    Left = 735
    Top = 2
    Width = 202
    Height = 648
    Position = dpxRight
    object dpMain: TSpTBXDockablePanel
      Left = 0
      Top = 0
      Width = 202
      Height = 648
      Caption = 'Side bar'
      DockPos = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnDockChanged = dpMainDockChanged
      OnResize = dpMainResize
      Images = Actions.ImageList
      Options.Caption = False
      Options.Close = False
      Options.CloseImageIndex = 113
      Options.TitleBarMaxSize = 15
      OnDrawCaptionPanel = dpMainDrawCaptionPanel
      object SpTBXRightAlignSpacerItem1: TSpTBXRightAlignSpacerItem
        CustomWidth = 171
      end
      object mnShow: TSpTBXSubmenuItem
        Caption = 'Show'
        ImageIndex = 113
        Images = Actions.ImageList
        OnClick = mnShowClick
        object mnShowInCurrentTab: TSpTBXSubmenuItem
          Caption = 'Show in current tab...'
          object mnGameInfo: TSpTBXItem
            Caption = 'Game information'
            OnClick = mnGameInfoClick
          end
          object mnNodeName: TSpTBXItem
            Caption = 'Node name'
            OnClick = mnNodeNameClick
          end
          object mnTiming: TSpTBXItem
            Caption = 'Timing'
            OnClick = mnTimingClick
          end
          object mnVariations: TSpTBXItem
            Caption = 'Variations'
            OnClick = mnVariationsClick
          end
          object mnGameTree: TSpTBXItem
            Caption = 'Game tree'
            OnClick = mnGameTreeClick
          end
          object mnComments: TSpTBXItem
            Caption = 'Comments'
            OnClick = mnCommentsClick
          end
        end
        object btMore: TSpTBXItem
          Action = Actions.acSidebarSettings
          ImageIndex = 5
          Images = Actions.ImageListOptions
        end
      end
      object pnMain: TPanel
        Left = 0
        Top = 15
        Width = 198
        Height = 629
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnMain'
        TabOrder = 1
        object SideBarDock: TSpTBXMultiDock
          Left = 0
          Top = 0
          Width = 196
          Height = 629
          object dpVariations: TSpTBXDockablePanel
            Left = 0
            Top = 357
            Width = 196
            Height = 54
            Caption = 'Variations'
            DockableTo = []
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 357
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnCloseQuery = CloseQueryCloseSideBarPanel
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            Options.TaskPaneStyleResize = True
            object SpTBXItem4: TSpTBXItem
              Action = Actions.acSidebarSettings
              ImageIndex = 113
              Images = Actions.ImageList
              CustomWidth = 16
              CustomHeight = 16
            end
            inline frVariations: TfrVariations
              Left = 0
              Top = 19
              Width = 192
              Height = 31
              Align = alClient
              TabOrder = 1
              inherited lbVariation: TTntListBox
                Width = 192
                Height = 31
                OnClick = lbVariationClick
              end
            end
          end
          object dpGameTree: TSpTBXDockablePanel
            Left = 0
            Top = 261
            Width = 196
            Height = 96
            Caption = 'Game tree'
            DockableTo = []
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 261
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnCloseQuery = CloseQueryCloseSideBarPanel
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            Options.TaskPaneStyleResize = True
            object SpTBXItem3: TSpTBXItem
              Action = Actions.acGameTreeSettings
              Images = Actions.ImageList
              CustomWidth = 16
              CustomHeight = 16
            end
            object pnTree: TPanel
              Left = 0
              Top = 19
              Width = 192
              Height = 73
              Align = alClient
              BevelOuter = bvNone
              Caption = '__pnTree'
              TabOrder = 1
              object imTree: TImage
                Left = 0
                Top = 0
                Width = 175
                Height = 57
                Align = alClient
                OnMouseDown = imTreeMouseDown
              end
              object sbTreeH: TScrollBar
                Left = 0
                Top = 57
                Width = 192
                Height = 16
                Align = alBottom
                PageSize = 0
                TabOrder = 0
                TabStop = False
                OnChange = sbTreeHChange
              end
              object sbTreeV: TScrollBar
                Left = 175
                Top = 0
                Width = 17
                Height = 57
                Align = alRight
                Kind = sbVertical
                PageSize = 0
                TabOrder = 1
                TabStop = False
                OnChange = sbTreeVChange
              end
            end
          end
          object dpComments: TSpTBXDockablePanel
            Left = 0
            Top = 566
            Width = 196
            Height = 63
            Caption = 'Comments'
            DockableTo = []
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 566
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            OnCloseQuery = CloseQueryCloseSideBarPanel
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            Options.TaskPaneStyleResize = True
            object SpTBXItem2: TSpTBXItem
              Action = Actions.acSidebarSettings
              ImageIndex = 113
              Images = Actions.ImageList
              CustomWidth = 16
              CustomHeight = 16
            end
            object mmComment: TTntMemo
              Left = 0
              Top = 19
              Width = 192
              Height = 40
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              BorderStyle = bsNone
              Constraints.MinHeight = 21
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              Lines.Strings = (
                'mmComme'
                'nt')
              ParentFont = False
              ScrollBars = ssVertical
              TabOrder = 1
              OnChange = mmCommentChange
              OnClick = mmCommentClick
            end
          end
          object dpGameInfo: TSpTBXDockablePanel
            Left = 0
            Top = 411
            Width = 196
            Height = 155
            Caption = 'Game information'
            Color = clWhite
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 411
            Resizable = False
            TabOrder = 3
            Visible = False
            OnCloseQuery = CloseQueryCloseSideBarPanel
            OnResize = dpGameInfoResize
            FixedDockedSize = True
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            Options.TaskPaneStyleResize = True
            object SpTBXItem1: TSpTBXItem
              Action = Actions.acGameInfo
              ImageIndex = 5
              Images = ImageListSideBar
              CustomWidth = 16
              CustomHeight = 16
            end
            object mnSideBarSettings: TSpTBXItem
              Action = Actions.acSidebarSettings
              ImageIndex = 113
              Images = Actions.ImageList
              CustomWidth = 16
              CustomHeight = 16
            end
            object Panel1: TPanel
              Left = 0
              Top = 19
              Width = 192
              Height = 160
              BevelOuter = bvNone
              Caption = 'Panel1'
              Color = clWhite
              TabOrder = 1
              DesignSize = (
                192
                160)
              object pnGameInfoImages: TSpTBXPanel
                Left = 0
                Top = 0
                Width = 192
                Height = 94
                Caption = 'pnGameInfoImages'
                Align = alTop
                UseDockManager = True
                ParentColor = True
                TabOrder = 0
                Borders = False
                object imgBlack: TImage
                  Left = 7
                  Top = 20
                  Width = 64
                  Height = 65
                  Center = True
                  Proportional = True
                end
                object imgWhite: TImage
                  Left = 76
                  Top = 20
                  Width = 64
                  Height = 65
                end
                object lbGIBlack: TSpTBXLabel
                  Left = 7
                  Top = 4
                  Width = 24
                  Height = 13
                  Caption = 'Black'
                end
                object lbGIWhite: TSpTBXLabel
                  Left = 77
                  Top = 4
                  Width = 28
                  Height = 13
                  Caption = 'White'
                end
              end
              object lxGameInfo: TSpTBXListBox
                Left = 1
                Top = 95
                Width = 190
                Height = 48
                Anchors = [akLeft, akTop, akRight]
                BorderStyle = bsNone
                IntegralHeight = True
                ItemHeight = 16
                ParentColor = True
                TabOrder = 1
                TabWidth = 20
                OnDrawItemBackground = lxGameInfoDrawItemBackground
              end
            end
          end
          object dpTiming: TSpTBXDockablePanel
            Left = 0
            Top = 42
            Width = 196
            Height = 46
            Caption = 'Timing'
            Color = clWhite
            DockableTo = []
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 42
            TabOrder = 4
            Visible = False
            OnCloseQuery = CloseQueryCloseSideBarPanel
            OnResize = dpTimingResize
            FixedDockedSize = True
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            object lbBLeft: TTntLabel
              Left = 7
              Top = 23
              Width = 24
              Height = 13
              Caption = 'Black'
              Transparent = True
            end
            object lbBLeftV: TTntLabel
              Left = 68
              Top = 23
              Width = 4
              Height = 13
              Caption = '-'
              Transparent = True
            end
            object imBlackStone: TImage
              Left = 84
              Top = 39
              Width = 13
              Height = 13
              Picture.Data = {
                07544269746D617020050000424D200500000000000036040000280000000D00
                00000D0000000100080001000000EA0000000000000000000000000100000001
                0000000000000101010002020200030303000404040005050500060606000707
                070008080800090909000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F
                0F00101010001111110012121200131313001414140015151500161616001717
                170018181800191919001A1A1A001B1B1B001C1C1C001D1D1D001E1E1E001F1F
                1F00202020002121210022222200232323002424240025252500262626002727
                270028282800292929002A2A2A002B2B2B002C2C2C002D2D2D002E2E2E002F2F
                2F00303030003131310032323200333333003434340035353500363636003737
                370038383800393939003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F
                3F00404040004141410042424200434343004444440045454500464646004747
                470048484800494949004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F
                4F00505050005151510052525200535353005454540055555500565656005757
                570058585800595959005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F
                5F00606060006161610062626200636363006464640065656500666666006767
                670068686800696969006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F
                6F00707070007171710072727200737373007474740075757500767676007777
                770078787800797979007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F
                7F00808080008181810082828200838383008484840085858500868686008787
                870088888800898989008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F
                8F00909090009191910092929200939393009494940095959500969696009797
                970098989800999999009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F
                9F00A0A0A000A1A1A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7
                A700A8A8A800A9A9A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAF
                AF00B0B0B000B1B1B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7
                B700B8B8B800B9B9B900BABABA00BBBBBB00BCBCBC00BDBDBD00BEBEBE00BFBF
                BF00C0C0C000C1C1C100C2C2C200C3C3C300C4C4C400C5C5C500C6C6C600C7C7
                C700C8C8C800C9C9C900CACACA00CBCBCB00CCCCCC00CDCDCD00CECECE00CFCF
                CF00D0D0D000D1D1D100D2D2D200D3D3D300D4D4D400D5D5D500D6D6D600D7D7
                D700D8D8D800D9D9D900DADADA00DBDBDB00DCDCDC00DDDDDD00DEDEDE00DFDF
                DF00E0E0E000E1E1E100E2E2E200E3E3E300E4E4E400E5E5E500E6E6E600E7E7
                E700E8E8E800E9E9E900EAEAEA00EBEBEB00ECECEC00EDEDED00EEEEEE00EFEF
                EF00F0F0F000F1F1F100F2F2F200F3F3F300F4F4F400F5F5F500F6F6F600F7F7
                F700F8F8F800F9F9F900FAFAFA00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FFFF
                FF00000DFFFFFF92543D373F5693FFFFFF000000000DFFFF702D202122232534
                76FFFF000000000DFF702C1E2022232425273676FF000000000D922C1E202224
                272A2C2E2F3B94000000000D54201F2224282C31363939375E000000000D3D20
                2123272C333B424749444F000000000D372122252B323B4650595C544F000000
                000D3E2323282E384452606F796558000000000D56242429313D4C5D738E9B6C
                69000000000D9433252A3341526684A7A3699A000000000DFF76352B33415267
                82937C8AFF000000000DFFFF7739323C4A59616589FFFF000000000DFFFFFF98
                5F4D4D55689BFFFFFF000001}
              Transparent = True
            end
            object lbBlackStonesLeft: TLabel
              Left = 66
              Top = 38
              Width = 12
              Height = 13
              Caption = '25'
              Transparent = True
            end
            object lbWLeftV: TTntLabel
              Left = 68
              Top = 56
              Width = 4
              Height = 13
              Caption = '-'
              Transparent = True
            end
            object lbWLeft: TTntLabel
              Left = 7
              Top = 56
              Width = 28
              Height = 13
              Caption = 'White'
              Transparent = True
            end
            object imWhiteStone: TImage
              Left = 84
              Top = 70
              Width = 13
              Height = 13
              Picture.Data = {
                07544269746D617020050000424D200500000000000036040000280000000D00
                00000D0000000100080001000000EA0000000000000000000000000100000001
                0000000000000101010002020200030303000404040005050500060606000707
                070008080800090909000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F
                0F00101010001111110012121200131313001414140015151500161616001717
                170018181800191919001A1A1A001B1B1B001C1C1C001D1D1D001E1E1E001F1F
                1F00202020002121210022222200232323002424240025252500262626002727
                270028282800292929002A2A2A002B2B2B002C2C2C002D2D2D002E2E2E002F2F
                2F00303030003131310032323200333333003434340035353500363636003737
                370038383800393939003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F
                3F00404040004141410042424200434343004444440045454500464646004747
                470048484800494949004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F
                4F00505050005151510052525200535353005454540055555500565656005757
                570058585800595959005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F
                5F00606060006161610062626200636363006464640065656500666666006767
                670068686800696969006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F
                6F00707070007171710072727200737373007474740075757500767676007777
                770078787800797979007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F
                7F00808080008181810082828200838383008484840085858500868686008787
                870088888800898989008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F
                8F00909090009191910092929200939393009494940095959500969696009797
                970098989800999999009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F
                9F00A0A0A000A1A1A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7
                A700A8A8A800A9A9A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAF
                AF00B0B0B000B1B1B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7
                B700B8B8B800B9B9B900BABABA00BBBBBB00BCBCBC00BDBDBD00BEBEBE00BFBF
                BF00C0C0C000C1C1C100C2C2C200C3C3C300C4C4C400C5C5C500C6C6C600C7C7
                C700C8C8C800C9C9C900CACACA00CBCBCB00CCCCCC00CDCDCD00CECECE00CFCF
                CF00D0D0D000D1D1D100D2D2D200D3D3D300D4D4D400D5D5D500D6D6D600D7D7
                D700D8D8D800D9D9D900DADADA00DBDBDB00DCDCDC00DDDDDD00DEDEDE00DFDF
                DF00E0E0E000E1E1E100E2E2E200E3E3E300E4E4E400E5E5E500E6E6E600E7E7
                E700E8E8E800E9E9E900EAEAEA00EBEBEB00ECECEC00EDEDED00EEEEEE00EFEF
                EF00F0F0F000F1F1F100F2F2F200F3F3F300F4F4F400F5F5F500F6F6F600F7F7
                F700F8F8F800F9F9F900FAFAFA00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FFFF
                FF00000DFFFFFF9B6F6A6D7580A8FFFFFF000000000DFFFF8767727E858B8C8D
                A8FFFF000000000DFF876C77858E94999C9DA0B2FF000000000D9C6677879198
                9EA2A6AAABAABE000000000D70708390989FA5AAAEB2B6B6AF000000000D687B
                8C979EA5ABB0B5B9BEC1B9000000000D6B82929CA3AAB0B5BAC0C5CAC3000000
                000D718696A1A8AFB5BAC0C9D4D3C9000000000D7E8699A4ACB3B9BFC8D7E8DA
                C8000000000DA88899A6AFB7BDC5D2E7EEDCD2000000000DFFA399A6B2BBC2CA
                D9E9E0DDFF000000000DFFFFADA4B0BCC5CED6DADCFFFF000000000DFFFFFFBB
                AAB4BFC5C6D0FFFFFF000001}
              Transparent = True
            end
            object lbWhiteStonesLeft: TLabel
              Left = 67
              Top = 70
              Width = 12
              Height = 13
              Caption = '25'
              Transparent = True
            end
            object pbBlackStonesLeft: TSpTBXProgressBar
              Left = 108
              Top = 40
              Width = 46
              Height = 11
              Color = cl3DLight
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              CaptionType = pctNone
              Smooth = True
              SkinType = sknWindows
            end
            object pbBlackTime: TSpTBXProgressBar
              Left = 108
              Top = 25
              Width = 46
              Height = 11
              Color = cl3DLight
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              CaptionType = pctNone
              Smooth = True
              SkinType = sknWindows
            end
            object pbWhiteTime: TSpTBXProgressBar
              Left = 108
              Top = 56
              Width = 46
              Height = 11
              Color = cl3DLight
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              CaptionType = pctNone
              Smooth = True
              SkinType = sknWindows
            end
            object pbWhiteStonesLeft: TSpTBXProgressBar
              Left = 108
              Top = 72
              Width = 46
              Height = 11
              Color = cl3DLight
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              CaptionType = pctNone
              Smooth = True
              SkinType = sknWindows
            end
          end
          object dpNodeName: TSpTBXDockablePanel
            Left = 0
            Top = 0
            Width = 196
            Height = 42
            Caption = 'Node name'
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 0
            Resizable = False
            TabOrder = 5
            Visible = False
            OnCloseQuery = CloseQueryCloseSideBarPanel
            FixedDockedSize = True
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.RestoreImageIndex = 1
            Options.TaskPaneStyleResize = True
            object edNodeName: TTntEdit
              Left = 0
              Top = 19
              Width = 192
              Height = 19
              Align = alClient
              AutoSize = False
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              BorderStyle = bsNone
              Constraints.MaxHeight = 21
              TabOrder = 1
              Text = 'tutyutyutuytuytyut'
              OnChange = edNodeNameChange
              OnClick = edNodeNameClick
            end
            object cbNodeName: TSpTBXComboBox
              Left = 0
              Top = 19
              Width = 145
              Height = 21
              ItemHeight = 13
              TabOrder = 2
              Text = 'cbNodeName'
              Visible = False
              OnSelect = cbNodeNameSelect
            end
          end
          object dpPad: TSpTBXDockablePanel
            Left = 0
            Top = 218
            Width = 196
            Height = 43
            DockPos = 218
            TabOrder = 6
            Options.Close = False
            Options.TitleBarMaxSize = 5
          end
          object dpQuickSearch: TSpTBXDockablePanel
            Left = 0
            Top = 88
            Width = 196
            Height = 130
            Caption = 'Pattern search'
            DockableTo = []
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 88
            TabOrder = 7
            Visible = False
            OnClose = dpQuickSearchClose
            OnCloseQuery = CloseQueryCloseSideBarPanel
            Images = ImageListSideBar
            Options.Minimize = True
            Options.CloseImageIndex = 2
            Options.MinimizeImageIndex = 0
            Options.TaskPaneStyleResize = True
            object btSearchSettings: TSpTBXItem
              Action = Actions.acSearchSettingsModal
              Images = Actions.ImageList
              CustomWidth = 16
              CustomHeight = 16
            end
            object Panel2: TPanel
              Left = 0
              Top = 19
              Width = 192
              Height = 107
              Align = alClient
              Caption = 'Panel2'
              TabOrder = 1
              object Bevel3: TBevel
                Left = 1
                Top = 90
                Width = 190
                Height = 3
                Align = alBottom
                Shape = bsBottomLine
              end
              inline frDBPatternResult: TfrDBPatternResult
                Left = 1
                Top = 1
                Width = 190
                Height = 89
                Align = alClient
                Color = 16250871
                ParentColor = False
                TabOrder = 0
                inherited bvButtons: TBevel
                  Top = 63
                  Width = 190
                end
                inherited pnResults: TPanel
                  Width = 190
                  Height = 44
                  inherited Bevel1: TBevel
                    Width = 190
                  end
                  inherited lbVariation: TListBox
                    Width = 190
                    Height = 0
                  end
                  inherited pnHeader: TPanel
                    Width = 190
                  end
                  inherited DigestHeader: TTntHeaderControl
                    Width = 190
                  end
                end
                inherited pnViewButtons: TPanel
                  Top = 67
                  Width = 190
                  DesignSize = (
                    190
                    22)
                end
                inherited PickerCaption: TfrDBPickerCaption
                  Width = 190
                  inherited Bevel1: TBevel
                    Width = 190
                  end
                  inherited Label1: TTntLabel
                    Width = 31
                  end
                end
              end
              object lbQuickSearch: TSpTBXLabel
                Left = 1
                Top = 93
                Width = 190
                Height = 13
                Caption = 'lbQuickSearch'
                Color = clMenu
                Align = alBottom
              end
            end
          end
        end
      end
    end
  end
  object VSplitter: TSpTBXSplitter
    Left = 731
    Top = 2
    Width = 4
    Height = 648
    Cursor = crSizeWE
    Align = alRight
    Color = clNone
    ParentColor = False
    ResizeStyle = rsPattern
    SkinType = sknWindows
    OnMoving = VSplitterCanResize
    OnMoved = VSplitterMoved
  end
  object pnStatus: TSpTBXPanel
    Left = 286
    Top = 153
    Width = 169
    Height = 84
    SkinType = sknWindows
    UseDockManager = True
    ParentColor = True
    TabOrder = 0
    Borders = False
    object imPlayer: TImage
      Left = 96
      Top = 6
      Width = 18
      Height = 18
      Transparent = True
    end
    object lbNextPlayer: TTntLabel
      Left = 11
      Top = 8
      Width = 29
      Height = 13
      Caption = 'Player'
      Transparent = False
    end
    object lbLastMove: TTntLabel
      Left = 11
      Top = 27
      Width = 49
      Height = 13
      Caption = 'Last move'
      Transparent = False
    end
    object lbBlackPriso: TTntLabel
      Left = 11
      Top = 45
      Width = 72
      Height = 13
      Caption = 'Black prisoners'
      Transparent = False
    end
    object lbWhitePriso: TTntLabel
      Left = 11
      Top = 64
      Width = 73
      Height = 13
      Caption = 'White prisoners'
      Transparent = False
    end
    object lbMoveNumberV: TTntLabel
      Left = 120
      Top = 27
      Width = 79
      Height = 13
      Caption = 'lbMoveNumberV'
      Transparent = False
    end
    object lbBlackPrisoV: TTntLabel
      Left = 120
      Top = 45
      Width = 65
      Height = 13
      Caption = 'lbBlackPrisoV'
      Transparent = False
    end
    object lbWhitePrisoV: TTntLabel
      Left = 120
      Top = 64
      Width = 66
      Height = 13
      Caption = 'lbWhitePrisoV'
      Transparent = False
    end
    object lbPlayerV: TSpTBXLabel
      Left = 120
      Top = 8
      Width = 44
      Height = 13
      Caption = 'lbPlayerV'
      ParentColor = True
      SkinType = sknNone
    end
  end
  object dpProblems: TSpTBXDockablePanel
    Left = 456
    Top = 450
    Width = 172
    Height = 169
    Caption = 'Problems'
    Color = clWhite
    DockMode = dmCannotFloat
    Resizable = False
    TabOrder = 7
    Visible = False
    FixedDockedSize = True
    Options.Close = False
    Options.CloseImageIndex = 12
    Options.MinimizeImageIndex = 10
    object lbPb1: TTntLabel
      Left = 9
      Top = 29
      Width = 37
      Height = 13
      Caption = 'Number'
      Transparent = True
    end
    object lbPb2: TTntLabel
      Left = 9
      Top = 48
      Width = 50
      Height = 13
      Caption = 'Reference'
      Transparent = True
    end
    object lbPb3: TTntLabel
      Left = 9
      Top = 143
      Width = 23
      Height = 13
      Caption = 'Time'
      Transparent = True
    end
    object lbPb1v: TTntLabel
      Left = 108
      Top = 29
      Width = 45
      Height = 13
      Caption = '__lbPb1v'
      Transparent = True
    end
    object lbPb2v: TTntLabel
      Left = 108
      Top = 48
      Width = 45
      Height = 13
      Caption = '__lbPb2v'
      Transparent = True
    end
    object lbPb3v: TTntLabel
      Left = 108
      Top = 143
      Width = 45
      Height = 13
      Caption = '__lbPb3v'
      Transparent = True
    end
    object lbSol4: TTntLabel
      Left = 108
      Top = 124
      Width = 41
      Height = 13
      Caption = '__lbSol4'
      Transparent = True
    end
    object lbSol3: TTntLabel
      Left = 108
      Top = 105
      Width = 41
      Height = 13
      Caption = '__lbSol3'
      Transparent = True
    end
    object lbSol1: TTntLabel
      Left = 9
      Top = 105
      Width = 69
      Height = 13
      Caption = 'Problem status'
      Transparent = True
    end
    object lbSol2: TTntLabel
      Left = 9
      Top = 124
      Width = 67
      Height = 13
      Caption = 'Attempt status'
      Transparent = True
    end
    object lbPb4: TTntLabel
      Left = 9
      Top = 67
      Width = 41
      Height = 13
      Caption = 'Attempts'
    end
    object lbPb4v: TTntLabel
      Left = 108
      Top = 67
      Width = 45
      Height = 13
      Caption = '__lbPb4v'
    end
    object lbPb5: TTntLabel
      Left = 9
      Top = 86
      Width = 41
      Height = 13
      Caption = 'Success'
    end
    object lbPb5v: TTntLabel
      Left = 108
      Top = 86
      Width = 45
      Height = 13
      Caption = '__lbPb5v'
    end
    object lbSol6: TTntLabel
      Left = 152
      Top = 121
      Width = 16
      Height = 26
      Caption = 'C'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = 4210816
      Font.Height = -24
      Font.Name = 'Wingdings'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lbSol5: TTntLabel
      Left = 150
      Top = 96
      Width = 20
      Height = 32
      Caption = 'C'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = 4210816
      Font.Height = -29
      Font.Name = 'Wingdings'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
  end
  object dpReplayGame: TSpTBXDockablePanel
    Left = 259
    Top = 488
    Width = 172
    Height = 130
    Caption = 'Replay game'
    Color = clWhite
    DockMode = dmCannotFloat
    TabOrder = 8
    Visible = False
    FixedDockedSize = True
    Options.Close = False
    DesignSize = (
      172
      130)
    object imGmHint: TImage
      Left = 108
      Top = 109
      Width = 64
      Height = 8
    end
    object lbGm1: TSpTBXLabel
      Left = 9
      Top = 29
      Width = 27
      Height = 13
      Caption = 'Black'
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
    end
    object lbGm2: TSpTBXLabel
      Left = 9
      Top = 48
      Width = 28
      Height = 13
      Caption = 'White'
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
    end
    object lbGm3: TSpTBXLabel
      Left = 9
      Top = 67
      Width = 19
      Height = 13
      Caption = 'You'
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
    end
    object lbGm4: TSpTBXLabel
      Left = 9
      Top = 86
      Width = 32
      Height = 13
      Caption = 'Moves'
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
    end
    object lbGm1v: TSpTBXLabel
      Left = 108
      Top = 29
      Width = 48
      Height = 13
      Caption = '__lbGm1v'
      ParentColor = True
    end
    object lbGm2v: TSpTBXLabel
      Left = 108
      Top = 48
      Width = 48
      Height = 13
      Caption = '__lbGm2v'
      ParentColor = True
    end
    object lbGm3v: TSpTBXLabel
      Left = 108
      Top = 67
      Width = 48
      Height = 13
      Caption = '__lbGm3v'
      ParentColor = True
    end
    object lbGm4v: TSpTBXLabel
      Left = 108
      Top = 86
      Width = 48
      Height = 13
      Caption = '__lbGm4v'
      ParentColor = True
    end
    object lbGm5: TSpTBXLabel
      Left = 9
      Top = 105
      Width = 19
      Height = 13
      Caption = 'Hint'
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
    end
  end
  object gbResult: TSpTBXDockablePanel
    Left = 64
    Top = 412
    Width = 172
    Height = 205
    Caption = 'gbResult'
    TabOrder = 9
    Options.Close = False
    object lbWhiteH: TTntLabel
      Left = 120
      Top = 29
      Width = 28
      Height = 13
      Caption = 'White'
      Transparent = True
    end
    object lbTotW: TTntLabel
      Left = 120
      Top = 141
      Width = 47
      Height = 13
      Caption = '__lbTotW'
      Transparent = True
    end
    object lbTotB: TTntLabel
      Left = 80
      Top = 141
      Width = 43
      Height = 13
      Caption = '__lbTotB'
      Transparent = True
    end
    object lbTotal: TTntLabel
      Left = 11
      Top = 141
      Width = 24
      Height = 13
      Caption = 'Total'
      Transparent = True
    end
    object lbTerW: TTntLabel
      Left = 120
      Top = 61
      Width = 47
      Height = 13
      Caption = '__lbTerW'
      Transparent = True
    end
    object lbTerritory: TTntLabel
      Left = 11
      Top = 61
      Width = 38
      Height = 13
      Caption = 'Territory'
      Transparent = True
    end
    object lbTerB: TTntLabel
      Left = 80
      Top = 61
      Width = 43
      Height = 13
      Caption = '__lbTerB'
      Transparent = True
    end
    object lbResult: TTntLabel
      Left = 16
      Top = 173
      Width = 38
      Height = 13
      Caption = 'lbResult'
      Transparent = True
    end
    object lbPriW: TTntLabel
      Left = 120
      Top = 85
      Width = 43
      Height = 13
      Caption = '__lbPriW'
      Transparent = True
    end
    object lbPriso: TTntLabel
      Left = 11
      Top = 85
      Width = 43
      Height = 13
      Caption = 'Prisoners'
      Transparent = True
    end
    object lbPriB: TTntLabel
      Left = 80
      Top = 85
      Width = 39
      Height = 13
      Caption = '__lbPriB'
      Transparent = True
    end
    object lbKomiV: TTntLabel
      Left = 120
      Top = 109
      Width = 50
      Height = 13
      Caption = '__lbKomiV'
      Transparent = True
    end
    object lbKomi: TTntLabel
      Left = 11
      Top = 109
      Width = 23
      Height = 13
      Caption = 'Komi'
      Transparent = True
    end
    object lbBlackH: TTntLabel
      Left = 80
      Top = 29
      Width = 27
      Height = 13
      Caption = 'Black'
      Transparent = True
    end
    object bvResult: TBevel
      Left = 8
      Top = 164
      Width = 154
      Height = 31
      Shape = bsFrame
    end
    object Bevel2: TBevel
      Left = 8
      Top = 125
      Width = 153
      Height = 9
      Shape = bsBottomLine
    end
    object Bevel1: TBevel
      Left = 10
      Top = 43
      Width = 153
      Height = 9
      Shape = bsBottomLine
    end
  end
  object gbResign: TSpTBXDockablePanel
    Left = 64
    Top = 352
    Width = 172
    Height = 57
    Caption = 'gbResign'
    TabOrder = 10
    Options.Close = False
    object lbResign: TTntLabel
      Left = 14
      Top = 30
      Width = 38
      Height = 13
      Caption = 'lbResult'
      Transparent = True
    end
  end
  object tmProblem: TTimer
    Enabled = False
    OnTimer = tmProblemTimer
    Left = 272
    Top = 8
  end
  object tmAutoReplay: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmAutoReplayTimer
    Left = 312
    Top = 8
  end
  object tmEngine: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmEngineTimer
    Left = 352
    Top = 8
  end
  object ImageListSideBar: TImageList
    Left = 392
    Top = 8
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
      0000000000000000000000000000000000000000000029292900292929000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000ADADAD00ADADAD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003B3B3B00A7A7A7002929
      2900000000000000000000000000000000000000000000000000000000000000
      00000000000000000000ADADAD00ADADAD00ADADAD00ADADAD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000039393900A7A7A700A7A7
      A700292929000000000000000000000000000000000000000000000000000000
      00000000000000000000ADADAD00ADADAD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002B2B2B00292929002929
      2900292929002929290029292900292929002828280036363600A2A2A200A2A2
      A200A2A2A2002929290000000000000000000000000000000000000000000000
      0000000000000000000000000000ADADAD00ADADAD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003A3A3A00969696009292
      92009292920092929200929292009292920092929200919191008D8D8D008D8D
      8D008D8D8D008D8D8D0029292900000000000000000000000000000000000000
      0000000000000000000000000000ADADAD00ADADAD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000393939006A6A6A006666
      6600666666006666660066666600666666006666660066666600666666006666
      6600666666006666660066666600292929000000000000000000000000000000
      000000000000000000000000000000000000ADADAD00ADADAD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000038383800E2E2E200E2E2
      E200E2E2E200E2E2E200E2E2E200E2E2E200E2E2E200E2E2E200B5B5B500B4B4
      B400B4B4B400E2E2E20036363600000000000000000000000000000000000000
      000000000000000000000000000000000000ADADAD00ADADAD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003B3B3B00383838003636
      3600363636003636360036363600363636003636360032323200D2D2D200D2D2
      D200E2E2E2003636360000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD00ADADAD000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000036363600D2D2D200E2E2
      E200363636000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000ADADAD00ADADAD00ADADAD00ADADAD000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000036363600E2E2E2003636
      3600000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000ADADAD00ADADAD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000036363600363636000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD00ADADAD000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD00ADADAD000000
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
      0000000000000000000000000000000000000000000000460000004600000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000064000039D871000046
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000062000039D8710039D8
      7100004600000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000808080000000
      00000000000000000000000000000000000000000000004A0000004600000046
      00000046000000460000004600000046000000440000005D000036D26D0036D2
      6D0036D26D000046000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080000000000080808000000000000000
      00000000000000000000000000000000000000000000006300002BCB56002AC7
      53002AC753002AC753002AC753002AC753002AC7530029C5520027C14E0027C1
      4E0027C14E0027C14E0000460000000000000000000000000000000000000000
      0000000000008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      00000000000000000000000000000000000000000000006200000BA715000AA3
      13000AA313000AA313000AA313000AA313000AA313000AA313000AA313000AA3
      13000AA313000CA50E000AA31300004600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080000000000080808000000000000000
      00000000000000000000000000000000000000000000005F000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0054E9730054E8
      720054E8720000FFFF00005D0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000650000005F0000005D
      0000005D0000005D0000005D0000005D0000005D00000056000072FF9D0072FF
      9D0000FFFF00005D000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000005D000072FF9D0000FF
      FF00005D00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000005D000000FFFF00005D
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000005D0000005D00000000
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
      FFFFFFFF00000000FF9FFE7F00000000FF8FFC3F00000000FF87FCFF00000000
      8003FE7F000000008001FE7F000000008000FF3F000000008001FF3F00000000
      8003FF9F00000000FF87FE1F00000000FF8FFF3F00000000FF9FFFFF00000000
      FFFFFF9F00000000FFFFFF9F00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FFFFFFFFFFFFFFF8FFFFFFF7FFBEFFF87
      FFFFFF7FFDDF8003FFFFFF7FFEBF8001F80FF80FFF7F8000FFFFFF7FFEBF8001
      FFFFFF7FFDDF8003FFFFFF7FFBEFFF87FFFFFFFFFFFFFF8FFFFFFFFFFFFFFF9F
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object ilGradients: TImageList
    Height = 6
    Width = 62
    Left = 328
    Top = 520
    Bitmap = {
      494C01010200040004003E000600FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000F80000000600000001002000000000004017
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF4C0000FF
      4C00000000000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF69002AFF
      6900000000000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF003333FF003333FF003333FF003333FF003333FF003333
      FF003333FF003333FF0055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      870055FF870055FF870055FF870055FF870055FF870055FF870055FF870055FF
      8700000000000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF006666FF006666FF006666FF006666FF006666FF006666
      FF006666FF006666FF007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFFA5007FFF
      A500000000000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF009999FF00AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFFC300AAFF
      C300000000000000000000000000000000000000000000000000000000000000
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
      000000000000000000000000000000000000CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCCFF00CCCC
      FF00CCCCFF00CCCCFF00D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FFE000D4FF
      E000000000000000000000000000000000000000000000000000000000000000
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
      28000000F8000000060000000100010000000000C00000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
end
