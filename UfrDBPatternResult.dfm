object frDBPatternResult: TfrDBPatternResult
  Left = 0
  Top = 0
  Width = 299
  Height = 126
  Color = 16250871
  ParentColor = False
  TabOrder = 0
  OnResize = FrameResize
  object bvButtons: TBevel
    Left = 0
    Top = 100
    Width = 299
    Height = 4
    Align = alBottom
    Shape = bsBottomLine
  end
  object pnResults: TPanel
    Left = 0
    Top = 19
    Width = 299
    Height = 81
    Align = alClient
    BevelOuter = bvNone
    Color = 16250871
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 299
      Height = 3
      Align = alTop
      Shape = bsBottomLine
    end
    object lbVariation: TListBox
      Left = 0
      Top = 37
      Width = 299
      Height = 42
      Style = lbOwnerDrawFixed
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 16250871
      IntegralHeight = True
      ItemHeight = 21
      TabOrder = 1
      OnDrawItem = lbVariationDrawItem
    end
    object pnHeader: TPanel
      Left = 0
      Top = 3
      Width = 299
      Height = 17
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvNone
      Color = 16250871
      TabOrder = 0
      object btLabel: TSpTBXSpeedButton
        Left = 0
        Top = 0
        Width = 17
        Height = 17
        OnClick = btLabelClick
        Alignment = taLeftJustify
        BitmapTransparent = False
        DropDownArrow = False
        Flat = True
        Images = ImageList
        ImageIndex = 2
      end
      object btPlayer: TSpTBXSpeedButton
        Left = 18
        Top = 0
        Width = 17
        Height = 17
        OnClick = btPlayerClick
        Alignment = taLeftJustify
        DropDownArrow = False
        Flat = True
        Images = ImageList
        ImageIndex = 2
      end
      object btEfficiency: TSpTBXSpeedButton
        Left = 184
        Top = 0
        Width = 73
        Height = 17
        Caption = 'Efficiency'
        OnClick = btEfficiencyClick
        Alignment = taLeftJustify
        Bitmap.Data = {
          A6000000424DA600000000000000360000002800000005000000070000000100
          1800000000007000000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF68FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FFFFFFFFFFFFF
          000000FFFFFFFFFFFF68FFFFFF000000000000000000FFFFFF9E000000000000
          00000000000000000028FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF14FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF73}
        BitmapTransparent = False
        DropDownArrow = False
        Flat = True
        Images = ImageList
        ImageIndex = 2
      end
      object btUrgency: TSpTBXSpeedButton
        Left = 107
        Top = 0
        Width = 65
        Height = 17
        Caption = 'Urgency'
        OnClick = btUrgencyClick
        Alignment = taLeftJustify
        DropDownArrow = False
        Flat = True
        Images = ImageList
        ImageIndex = 2
      end
      object btFrequency: TSpTBXSpeedButton
        Left = 40
        Top = 0
        Width = 68
        Height = 17
        Caption = 'Frequency'
        OnClick = btFrequencyClick
        Alignment = taLeftJustify
        Bitmap.Data = {
          A6000000424DA600000000000000360000002800000005000000070000000100
          1800000000007000000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF68FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FFFFFFFFFFFFF
          000000FFFFFFFFFFFF68FFFFFF000000000000000000FFFFFF9E000000000000
          00000000000000000028FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF14FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF73}
        BitmapTransparent = False
        DropDownArrow = False
        Flat = True
        Images = ImageList
        ImageIndex = 2
      end
    end
    object DigestHeader: TTntHeaderControl
      Left = 0
      Top = 20
      Width = 299
      Height = 17
      DragReorder = False
      Sections = <
        item
          ImageIndex = 0
          Width = 50
        end
        item
          ImageIndex = 0
          Width = 50
        end
        item
          ImageIndex = 0
          Width = 50
        end
        item
          ImageIndex = 0
          Width = 50
        end
        item
          ImageIndex = 0
          Text = 'Efficiency'
          Width = 50
        end>
      Visible = False
    end
  end
  object pnViewButtons: TPanel
    Left = 0
    Top = 104
    Width = 299
    Height = 22
    Align = alBottom
    BevelOuter = bvNone
    Color = 16250871
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    DesignSize = (
      299
      22)
    object Label1: TTntLabel
      Left = 6
      Top = 3
      Width = 26
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'View:'
      Transparent = False
    end
    object rbDigest: TSpTBXRadioButton
      Left = 226
      Top = 2
      Width = 48
      Height = 15
      Caption = 'Digest'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 2
    end
    object rbFull: TSpTBXRadioButton
      Left = 139
      Top = 2
      Width = 34
      Height = 15
      Caption = 'Full'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 1
    end
    object rbKombilo: TSpTBXRadioButton
      Left = 63
      Top = 2
      Width = 54
      Height = 15
      Caption = 'Kombilo'
      Anchors = [akLeft, akBottom]
      ParentColor = True
      TabOrder = 0
    end
  end
  inline PickerCaption: TfrDBPickerCaption
    Left = 0
    Top = 0
    Width = 299
    Height = 19
    Align = alTop
    TabOrder = 2
    Visible = False
    inherited Bevel1: TBevel
      Width = 299
    end
  end
  object ImageList: TImageList
    Height = 9
    Width = 9
    Left = 20
    Top = 68
    Bitmap = {
      494C010103000400040009000900FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000240000000900000001002000000000001005
      0000000000000000000000000000000000000000000000000000787878000000
      0000000000000000000078787800000000000000000000000000000000007878
      78001F1F1F00000000001F1F1F00787878000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000003E3E3D0065656400D6D6D400FFFFFD00D6D6D4006565
      64003E3E3D000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007878780000000000000000000000
      000000000000000000000000000000000000787878007878780065656400FFFF
      FD00FFFFFD00FFFFFD00FFFFFD00FFFFFD006565640078787800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000001F1F1F00D6D6D400FFFFFD00FFFFFD00FFFFFD00FFFFFD00FFFF
      FD00D6D6D4001F1F1F0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFD00FFFF
      FD00FFFFFD00FFFFFD00FFFFFD00FFFFFD00FFFFFD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000001F1F1F00D6D6D400FFFFFD00FFFFFD00FFFFFD00FFFFFD00FFFF
      FD00D6D6D4001F1F1F0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007878780000000000000000000000
      000000000000000000000000000000000000787878007878780065656400FFFF
      FD00FFFFFD00FFFFFD00FFFFFD00FFFFFD006565640078787800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000003E3E3D0065656400D6D6D400FFFFFD00D6D6D4006565
      64003E3E3D000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000787878000000
      0000000000000000000078787800000000000000000000000000000000007878
      78001F1F1F00000000001F1F1F00787878000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424D3E000000000000003E00000028000000240000000900000001000100
      00000000480000000000000000000000000000000000000000000000FFFFFF00
      C1E0FFE00000000080C07FE00000000000003FE00000000000003DE000000000
      000038E000000000000030600000000000003FE00000000080C07FE000000000
      C1E0FFE00000000000000000000000000000000000000000000000000000}
  end
end
