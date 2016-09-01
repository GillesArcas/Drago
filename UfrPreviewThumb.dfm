object frPreviewThumb: TfrPreviewThumb
  Left = 0
  Top = 0
  Width = 443
  Height = 270
  Align = alClient
  TabOrder = 0
  OnMouseWheelDown = FrameMouseWheelDown
  OnMouseWheelUp = FrameMouseWheelUp
  OnResize = FrameResize
  object ScrollBar: TScrollBar
    Left = 426
    Top = 0
    Width = 17
    Height = 270
    Align = alRight
    Kind = sbVertical
    PageSize = 0
    TabOrder = 0
    OnScroll = ScrollBarScroll
  end
  object pnThumbs: TPanel
    Left = 0
    Top = 0
    Width = 426
    Height = 270
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object imImage: TImage
      Left = 2
      Top = 2
      Width = 422
      Height = 266
      Align = alClient
    end
    object imCursor: TImage
      Left = 344
      Top = 152
      Width = 105
      Height = 105
    end
  end
end
