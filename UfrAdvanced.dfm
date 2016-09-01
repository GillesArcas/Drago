object frAdvanced: TfrAdvanced
  Left = 0
  Top = 0
  Width = 356
  Height = 364
  TabOrder = 0
  object VT: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 400
    Height = 303
    Align = alLeft
    EditDelay = 100
    Header.AutoSizeIndex = 1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag]
    HintMode = hmTooltip
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.SelectionOptions = [toExtendedFocus, toMultiSelect, toSiblingSelectConstraint]
    OnBeforeCellPaint = VTBeforeCellPaint
    OnChange = VTChange
    OnChecked = VTChecked
    OnCreateEditor = VTCreateEditor
    OnEditing = VTEditing
    OnGetText = VTGetText
    OnPaintText = VTPaintText
    OnGetHint = VTGetHint
    OnInitChildren = VTInitChildren
    OnInitNode = VTInitNode
    Columns = <
      item
        Position = 0
        Width = 250
      end
      item
        Position = 1
        Width = 96
      end
      item
        Position = 2
      end>
  end
  object Panel1: TSpTBXGroupBox
    Left = 0
    Top = 303
    Width = 400
    Height = 44
    Caption = 'Restore default'
    Color = clBtnFace
    Align = alBottom
    UseDockManager = True
    TabOrder = 1
    DesignSize = (
      400
      44)
    object btRestore: TSpTBXButton
      Left = 185
      Top = 20
      Width = 75
      Height = 15
      Caption = 'Restore'
      Anchors = [akLeft, akBottom]
      TabOrder = 2
      OnClick = btRestoreClick
    end
    object btSelectAll: TSpTBXButton
      Left = 93
      Top = 20
      Width = 85
      Height = 15
      Caption = 'Select all2'
      TabOrder = 1
      OnClick = btSelectAllClick
    end
    object btSelect: TSpTBXButton
      Left = 10
      Top = 20
      Width = 75
      Height = 15
      Caption = 'Select'
      TabOrder = 0
      OnClick = btSelectClick
    end
  end
end
