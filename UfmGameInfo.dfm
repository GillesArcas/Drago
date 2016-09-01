object fmGameInfo: TfmGameInfo
  Left = 440
  Top = 285
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'fmGameInfo'
  ClientHeight = 252
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    472
    252)
  PixelsPerInch = 96
  TextHeight = 13
  object lbMsg: TTntLabel
    Left = 184
    Top = 221
    Width = 28
    Height = 13
    Caption = 'lbMsg'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object PageControl: TTntPageControl
    Left = 10
    Top = 2
    Width = 452
    Height = 201
    ActivePage = TabSheet7
    Images = ImageList
    RaggedRight = True
    TabOrder = 2
    OnChange = PageControlChange
    object TabSheet1: TTntTabSheet
      Caption = 'Summary'
      object Panel4: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object lbResult: TTntLabel
          Left = 112
          Top = 128
          Width = 38
          Height = 13
          Caption = 'lbResult'
        end
        object Label19: TTntLabel
          Left = 8
          Top = 58
          Width = 25
          Height = 13
          Caption = 'Place'
        end
        object Label23: TTntLabel
          Left = 8
          Top = 83
          Width = 23
          Height = 13
          Caption = 'Date'
        end
        object Label11: TTntLabel
          Left = 8
          Top = 108
          Width = 30
          Height = 13
          Caption = 'Result'
        end
        object Label20: TTntLabel
          Left = 8
          Top = 33
          Width = 28
          Height = 13
          Caption = 'White'
        end
        object Label21: TTntLabel
          Left = 8
          Top = 8
          Width = 24
          Height = 13
          Caption = 'Black'
        end
        object edPC: TTntEdit
          Left = 112
          Top = 55
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          Text = 'edPC'
          OnChange = edPCChange
        end
        object edDT: TTntEdit
          Left = 112
          Top = 80
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          Text = 'edDT'
          OnChange = edDTChange
        end
        object edRE: TTntEdit
          Left = 112
          Top = 105
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          Text = 'edRE'
          OnChange = edREChange
        end
        object edPW: TTntEdit
          Left = 112
          Top = 30
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          Text = 'edPW'
          OnChange = edPWChange
        end
        object edPB: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Text = 'edPB'
          OnChange = edPBChange
        end
      end
    end
    object TabSheet2: TTntTabSheet
      Caption = 'Event'
      object Panel2: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label4: TTntLabel
          Left = 8
          Top = 83
          Width = 25
          Height = 13
          Caption = 'Place'
        end
        object lbEV: TTntLabel
          Left = 8
          Top = 33
          Width = 28
          Height = 13
          Caption = 'Event'
        end
        object lbGN: TTntLabel
          Left = 8
          Top = 8
          Width = 27
          Height = 13
          Caption = 'Game'
        end
        object Label3: TTntLabel
          Left = 8
          Top = 58
          Width = 31
          Height = 13
          Caption = 'Round'
        end
        object Label5: TTntLabel
          Left = 8
          Top = 108
          Width = 23
          Height = 13
          Caption = 'Date'
        end
        object edGN: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          TabOrder = 0
          Text = 'edGN'
        end
        object edEV: TTntEdit
          Left = 112
          Top = 30
          Width = 321
          Height = 21
          TabOrder = 1
          Text = 'edEV'
        end
        object edRO: TTntEdit
          Left = 112
          Top = 55
          Width = 321
          Height = 21
          TabOrder = 2
          Text = 'edRO'
        end
        object edPC2: TTntEdit
          Left = 112
          Top = 80
          Width = 321
          Height = 21
          TabOrder = 3
          Text = 'edPC2'
          OnChange = edPC2Change
        end
        object edDT2: TTntEdit
          Left = 112
          Top = 105
          Width = 321
          Height = 21
          TabOrder = 4
          Text = 'edDT2'
          OnChange = edDT2Change
        end
      end
    end
    object TabSheet3: TTntTabSheet
      Caption = 'Players'
      object Panel1: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label1: TTntLabel
          Left = 8
          Top = 8
          Width = 24
          Height = 13
          Caption = 'Black'
        end
        object Label2: TTntLabel
          Left = 8
          Top = 92
          Width = 28
          Height = 13
          Caption = 'White'
        end
        object Label6: TTntLabel
          Left = 56
          Top = 8
          Width = 27
          Height = 13
          Caption = 'Name'
        end
        object Label7: TTntLabel
          Left = 56
          Top = 33
          Width = 24
          Height = 13
          Caption = 'Rank'
        end
        object Label8: TTntLabel
          Left = 56
          Top = 58
          Width = 26
          Height = 13
          Caption = 'Team'
        end
        object imBlack: TImage
          Left = 8
          Top = 30
          Width = 25
          Height = 25
          Picture.Data = {
            07544269746D617036050000424D360500000000000036040000280000001000
            0000100000000100080000000000000100000000000000000000000100000001
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
            FF00FFFFFFFFFF674A3D3E4C68FFFFFFFFFFFFFFFF6C25191D1E1F201F2D6FFF
            FFFFFFFF5C161C1F2122232324242261FFFFFF6D161D1F212324252627282825
            70FFFF251C1F21232426282B2E30302D36FF67191E212324262A2E3235383937
            2F6B491C202224262A2F343A3F4446433A573E1E212325292E343C444B515452
            46503F1F2224272C323B444E5760656453524C1F2325292F37414C586572807C
            5B5E691E23262A313B475463748AB38E5872FF2B23262B333E4B5A6B81B3CF80
            52FFFF7121262B333F4C5C6E8AB8945B7AFFFFFF622428313B49576879785970
            FFFFFFFFFF73342A333E4951514F7AFFFFFFFFFFFFFFFF70584E515E74FFFFFF
            FFFF}
          Transparent = True
        end
        object Label14: TTntLabel
          Left = 56
          Top = 92
          Width = 27
          Height = 13
          Caption = 'Name'
        end
        object Label15: TTntLabel
          Left = 56
          Top = 117
          Width = 24
          Height = 13
          Caption = 'Rank'
        end
        object Label16: TTntLabel
          Left = 56
          Top = 142
          Width = 26
          Height = 13
          Caption = 'Team'
        end
        object imWhite: TImage
          Left = 8
          Top = 114
          Width = 25
          Height = 25
          Picture.Data = {
            07544269746D617036050000424D360500000000000036040000280000001000
            0000100000000100080000000000000100000000000000000000000100000001
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
            FF00FFFFFFFFFF7168666B7580FFFFFFFFFFFFFFFF755464747C8284827D91FF
            FFFFFFFF6A56717F878D929598988F95FFFFFF775674828B91979B9FA2A4A59D
            A0FFFF5370818C93999DA2A6A9ACAEAFA4FF75617D8A92999EA3A7ABAFB2B5B8
            B7AA66718590989EA3A8ACB0B4B8BBBFC1B464798B959CA2A7ACB0B5B9BDC1C5
            C9BE687E8F99A0A6ABB0B4B9BDC2C7CCD0C5717F929CA3A9AFB4B9BDC2C7D3DA
            D7C77F7C939EA6ADB2B7BCC1C6D2F3E5DEC3FF7592A0A8AFB5BBC0C6CCECFCE2
            DBFFFF8E889FAAB2B8BEC4CAD7F7E8E3C6FFFFFF8F95A9B3BBC2C8CFDAE1E3CC
            FFFFFFFFFF9C9DB0BCC4CCD3DBD8C5FFFFFFFFFFFFFFFFA6AEB8BFC3BFFFFFFF
            FFFF}
          Transparent = True
        end
        object edPB2: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          AutoSelect = False
          TabOrder = 0
          Text = 'edPB2'
          OnChange = edPB2Change
        end
        object edPW2: TTntEdit
          Left = 112
          Top = 89
          Width = 321
          Height = 21
          TabOrder = 3
          Text = 'edPW2'
          OnChange = edPW2Change
        end
        object edWR: TTntEdit
          Left = 112
          Top = 114
          Width = 321
          Height = 21
          TabOrder = 4
          Text = 'edWR'
        end
        object edWT: TTntEdit
          Left = 112
          Top = 139
          Width = 321
          Height = 21
          TabOrder = 5
          Text = 'edWT'
        end
        object edBR: TTntEdit
          Left = 112
          Top = 30
          Width = 321
          Height = 21
          TabOrder = 1
          Text = 'edBR'
        end
        object edBT: TTntEdit
          Left = 112
          Top = 55
          Width = 321
          Height = 21
          TabOrder = 2
          Text = 'edBT'
        end
      end
    end
    object TabSheet4: TTntTabSheet
      Caption = 'Rules'
      object Panel3: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label9: TTntLabel
          Left = 8
          Top = 108
          Width = 44
          Height = 13
          Caption = 'Handicap'
        end
        object Label10: TTntLabel
          Left = 8
          Top = 83
          Width = 22
          Height = 13
          Caption = 'Komi'
        end
        object Label12: TTntLabel
          Left = 8
          Top = 8
          Width = 26
          Height = 13
          Caption = 'Rules'
        end
        object Label13: TTntLabel
          Left = 8
          Top = 33
          Width = 22
          Height = 13
          Caption = 'Time'
        end
        object Label31: TTntLabel
          Left = 8
          Top = 58
          Width = 44
          Height = 13
          Caption = 'Byo-Yomi'
        end
        object Label17: TTntLabel
          Left = 136
          Top = 33
          Width = 10
          Height = 13
          Caption = 'hr'
        end
        object Label18: TTntLabel
          Left = 172
          Top = 33
          Width = 14
          Height = 13
          Caption = 'mn'
        end
        object edRU: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          TabOrder = 0
          Text = 'edRU'
        end
        object ed_hr: TTntEdit
          Left = 112
          Top = 30
          Width = 20
          Height = 21
          TabOrder = 1
          OnChange = ed_hrChange
        end
        object edOT: TTntEdit
          Left = 112
          Top = 55
          Width = 321
          Height = 21
          TabOrder = 3
          Text = 'edOT'
        end
        object edHA: TTntEdit
          Left = 112
          Top = 105
          Width = 321
          Height = 21
          Color = cl3DLight
          ReadOnly = True
          TabOrder = 5
          Text = 'edHA'
        end
        object edKM: TTntEdit
          Left = 112
          Top = 80
          Width = 321
          Height = 21
          TabOrder = 4
          Text = 'edKM'
        end
        object ed_mn: TTntEdit
          Left = 148
          Top = 30
          Width = 20
          Height = 21
          TabOrder = 2
          OnChange = ed_hrChange
        end
        object edTM: TTntEdit
          Left = 192
          Top = 30
          Width = 241
          Height = 21
          TabStop = False
          Enabled = False
          TabOrder = 6
          Text = 'edTM'
        end
      end
    end
    object TabSheet5: TTntTabSheet
      Caption = 'Sources'
      object Panel5: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label22: TTntLabel
          Left = 8
          Top = 83
          Width = 47
          Height = 13
          Caption = 'Copyright'
        end
        object Label30: TTntLabel
          Left = 8
          Top = 33
          Width = 53
          Height = 13
          Caption = 'Annotation'
        end
        object Label25: TTntLabel
          Left = 8
          Top = 8
          Width = 22
          Height = 13
          Caption = 'User'
        end
        object Label26: TTntLabel
          Left = 8
          Top = 58
          Width = 33
          Height = 13
          Caption = 'Source'
        end
        object edUS: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          TabOrder = 0
          Text = 'edUS'
        end
        object edAN: TTntEdit
          Left = 112
          Top = 30
          Width = 321
          Height = 21
          TabOrder = 1
          Text = 'edAN'
        end
        object edSO: TTntEdit
          Left = 112
          Top = 55
          Width = 321
          Height = 21
          TabOrder = 2
          Text = 'edSO'
        end
        object edCP: TTntEdit
          Left = 112
          Top = 80
          Width = 321
          Height = 21
          TabOrder = 3
          Text = 'edCP'
        end
      end
    end
    object TabSheet6: TTntTabSheet
      Caption = 'Comment'
      object mmGC: TTntMemo
        Left = 0
        Top = 0
        Width = 440
        Height = 177
        Lines.Strings = (
          'mmGC')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TabSheet7: TTntTabSheet
      Caption = 'Misc'
      ImageIndex = 6
      object Panel6: TPanel
        Left = 2
        Top = 2
        Width = 440
        Height = 167
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object Label24: TTntLabel
          Left = 8
          Top = 8
          Width = 52
          Height = 13
          Caption = 'Application'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label27: TTntLabel
          Left = 8
          Top = 33
          Width = 54
          Height = 13
          Caption = 'SGF format'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label28: TTntLabel
          Left = 8
          Top = 58
          Width = 24
          Height = 13
          Caption = 'Style'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TntLabel1: TTntLabel
          Left = 8
          Top = 82
          Width = 38
          Height = 13
          Caption = 'Charset'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edAP: TTntEdit
          Left = 112
          Top = 5
          Width = 321
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Text = 'edAP'
        end
        object edFF: TTntEdit
          Left = 112
          Top = 30
          Width = 321
          Height = 21
          TabStop = False
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
          Text = 'edFF'
        end
        object cbST: TTntComboBox
          Left = 112
          Top = 56
          Width = 321
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 2
          Items.Strings = (
            'No style defined for current game'
            'Show next moves - Allow board markup'
            'Show alternate moves - Allow board markup'
            'Show next moves - No board markup'
            'Show alternate moves - No board markup')
        end
        object lbCa: TSpTBXLabel
          Left = 112
          Top = 104
          Width = 98
          Height = 13
          Caption = 'Charset not handled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edCA: TEdit
          Left = 112
          Top = 82
          Width = 321
          Height = 21
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNone
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 3
        end
      end
    end
  end
  object btCancel: TTntButton
    Left = 96
    Top = 215
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btOk: TTntButton
    Left = 10
    Top = 215
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btOkClick
  end
  object ImageList: TImageList
    Width = 1
    Left = 432
    Top = 212
    Bitmap = {
      494C010101000400040001001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000040000001000000001002000000000000001
      000000000000000000000000000000000000000000007B7B7B007B7B7B007B7B
      7B00000000007B7B7B007B7B7B007B7B7B00000000007B7B7B007B7B7B007B7B
      7B00FFFFFF007B7B7B007B7B7B007B7B7B00FFFFFF007B7B7B007B7B7B007B7B
      7B00FFFFFF007B7B7B007B7B7B007B7B7B00FFFFFF007B7B7B007B7B7B007B7B
      7B00FFFFFF007B7B7B007B7B7B007B7B7B00FFFFFF007B7B7B007B7B7B007B7B
      7B00000000007B7B7B007B7B7B007B7B7B00FFFFFF007B7B7B007B7B7B007B7B
      7B00FFFFFF007B7B7B007B7B7B007B7B7B00000000007B7B7B007B7B7B007B7B
      7B00000000007B7B7B007B7B7B007B7B7B00000000007B7B7B007B7B7B007B7B
      7B00000000007B6B7B007B6B7B007B6B7B00424D3E000000000000003E000000
      2800000004000000100000000100010000000000400000000000000000000000
      000000000000000000000000FFFFFF0080000000F00000008000000070000000
      0000000070000000000000007000000000000000800000000000000000000000
      8000000080000000A0000000B000000000000000000000000000000000000000
      000000000000}
  end
end
