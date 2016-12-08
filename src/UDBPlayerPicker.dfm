object DBPlayerPicker: TDBPlayerPicker
  Left = 0
  Top = 0
  Width = 307
  Height = 108
  Color = 16250871
  ParentColor = False
  TabOrder = 0
  DesignSize = (
    307
    108)
  object cbPlayerWhite: TComboBox
    Left = 8
    Top = 80
    Width = 292
    Height = 21
    AutoDropDown = True
    AutoCloseUp = True
    BevelKind = bkSoft
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 4
    Text = '-'
    OnChange = cbPlayerWhiteChange
  end
  object cbPlayerBlack: TComboBox
    Left = 8
    Top = 33
    Width = 292
    Height = 21
    AutoDropDown = True
    AutoCloseUp = True
    BevelKind = bkSoft
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 2
    Text = '-'
    OnChange = cbPlayerBlackChange
  end
  inline PickerCaption: TfrDBPickerCaption
    Left = 0
    Top = 0
    Width = 307
    Height = 17
    Align = alTop
    TabOrder = 0
    inherited Bevel1: TBevel
      Width = 307
    end
    inherited CheckBox1: TCheckBox
      OnClick = PickerCaptionClick
    end
  end
  object Panel1: TSpTBXPanel
    Left = 7
    Top = 17
    Width = 291
    Height = 15
    Color = 16250871
    Anchors = [akLeft, akTop, akBottom]
    UseDockManager = True
    TabOrder = 1
    Borders = False
    DesignSize = (
      291
      15)
    object rbBlack: TSpTBXRadioButton
      Left = 1
      Top = 0
      Width = 42
      Height = 15
      Caption = 'Black'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 0
      OnClick = rbBlackClick
    end
    object rbBoth: TSpTBXRadioButton
      Left = 89
      Top = 0
      Width = 76
      Height = 15
      Caption = 'One of both'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 1
      OnClick = rbBothClick
    end
    object rbWinner: TSpTBXRadioButton
      Left = 200
      Top = 0
      Width = 52
      Height = 15
      Caption = 'Winner'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 2
      OnClick = rbWinnerClick
    end
  end
  object Panel2: TSpTBXPanel
    Left = 7
    Top = 63
    Width = 292
    Height = 16
    Color = 16250871
    Anchors = [akLeft, akTop, akBottom]
    UseDockManager = True
    TabOrder = 3
    Borders = False
    DesignSize = (
      292
      16)
    object rbWhite: TSpTBXRadioButton
      Left = 1
      Top = 0
      Width = 46
      Height = 15
      Caption = 'White'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 0
      OnClick = rbWhiteClick
    end
    object rbBoth2: TSpTBXRadioButton
      Left = 89
      Top = 0
      Width = 76
      Height = 15
      Caption = 'One of both'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 1
      OnClick = rbBoth2Click
    end
    object rbLoser: TSpTBXRadioButton
      Left = 200
      Top = 0
      Width = 44
      Height = 15
      Caption = 'Loser'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentColor = True
      TabOrder = 2
      OnClick = rbLoserClick
    end
  end
end
