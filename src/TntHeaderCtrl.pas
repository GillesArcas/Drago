unit TntHeaderCtrl;

{$R-,T-,H+,X+}

//TODO:
//	Unicodeで動作していないような気がする。。。
//Memo:
// ../HeaderCtrlTEstにtest programあり

interface

uses Forms, Classes, Controls, ComCtrls, Messages, Windows, SysUtils, CommCtrl,
  Menus, Graphics, StdCtrls, ImgList, ExtCtrls;

type

{ TTntHeaderControl }

  TTntHeaderControl = class;

  //THeaderSectionStyle = (hsText, hsOwnerDraw);

  TTntHeaderSection = class(TCollectionItem)
  private
    FText: WideString;
    FWidth: Integer;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FAlignment: TAlignment;
    FStyle: THeaderSectionStyle;
    FAllowClick: Boolean;
    FAutoSize: Boolean;
    FImageIndex: TImageIndex;
    FBiDiMode: TBiDiMode;
    FParentBiDiMode: Boolean;
    function GetLeft: Integer;
    function GetRight: Integer;
    function IsBiDiModeStored: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSize(Value: Boolean);
    procedure SetBiDiMode(Value: TBiDiMode);
    procedure SetMaxWidth(Value: Integer);
    procedure SetMinWidth(Value: Integer);
    procedure SetParentBiDiMode(Value: Boolean);
    procedure SetStyle(Value: THeaderSectionStyle);
    procedure SetText(const Value: WideString);
    procedure SetWidth(Value: Integer);
    procedure SetImageIndex(const Value: TImageIndex);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ParentBiDiModeChanged;
    function UseRightToLeftAlignment: Boolean;
    function UseRightToLeftReading: Boolean;
    property Left: Integer read GetLeft;
    property Right: Integer read GetRight;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AllowClick: Boolean read FAllowClick write FAllowClick default True;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 10000;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property ParentBiDiMode: Boolean read FParentBiDiMode write SetParentBiDiMode default True;
    property Style: THeaderSectionStyle read FStyle write SetStyle default hsText;
	property Text: WideString read FText write SetText;
    property Width: Integer read FWidth write SetWidth;
  end;

  TTntHeaderSections = class(TCollection)
  private
    FHeaderControl: TTntHeaderControl;
    function GetItem(Index: Integer): TTntHeaderSection;
    procedure SetItem(Index: Integer; Value: TTntHeaderSection);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(HeaderControl: TTntHeaderControl);
    function Add: TTntHeaderSection;
    property Items[Index: Integer]: TTntHeaderSection read GetItem write SetItem; default;
  end;

  TSectionTrackState = (tsTrackBegin, tsTrackMove, tsTrackEnd);

  TDrawSectionEvent = procedure(HeaderControl: TTntHeaderControl;
    Section: TTntHeaderSection; const Rect: TRect; Pressed: Boolean) of object;
  TSectionNotifyEvent = procedure(HeaderControl: TTntHeaderControl;
    Section: TTntHeaderSection) of object;
  TSectionTrackEvent = procedure(HeaderControl: TTntHeaderControl;
    Section: TTntHeaderSection; Width: Integer;
    State: TSectionTrackState) of object;
  TSectionDragEvent = procedure (Sender: TObject; FromSection, ToSection: TTntHeaderSection;
    var AllowDrag: Boolean) of object;

  //THeaderStyle = (hsButtons, hsFlat);

  TTntHeaderControl = class(TWinControl)
  private
    FSections: TTntHeaderSections;
    FSectionStream: TMemoryStream;
    FUpdatingSectionOrder,
    FSectionDragged: Boolean;
    FCanvas: TCanvas;
    FFromIndex,
    FToIndex: Integer;
    FFullDrag: Boolean;
    FHotTrack: Boolean;
    FDragReorder: Boolean;
    FImageChangeLink: TChangeLink;
    FImages: TCustomImageList;
    FStyle: THeaderStyle;
    FTrackSection: TTntHeaderSection;
    FTrackWidth: Integer;
    FTrackPos: TPoint;
    FOnDrawSection: TDrawSectionEvent;
    FOnSectionClick: TSectionNotifyEvent;
    FOnSectionResize: TSectionNotifyEvent;
    FOnSectionTrack: TSectionTrackEvent;
    FOnSectionDrag: TSectionDragEvent;
    FOnSectionEndDrag: TNotifyEvent;
    function  DoSectionDrag(FromSection, ToSection: TTntHeaderSection): Boolean;
    procedure DoSectionEndDrag;
    procedure ImageListChange(Sender: TObject);
    procedure SetDragReorder(const Value: Boolean);
    procedure SetFullDrag(Value: Boolean);
    procedure SetHotTrack(Value: Boolean);
    procedure SetSections(Value: TTntHeaderSections);
    procedure SetStyle(Value: THeaderStyle);
    procedure UpdateItem(Message, Index: Integer);
    procedure UpdateSection(Index: Integer);
    procedure UpdateSections;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
	procedure CreateWindowHandle(const Params: TCreateParams); override;
	procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DrawSection(Section: TTntHeaderSection; const Rect: TRect;
      Pressed: Boolean); dynamic;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SectionClick(Section: TTntHeaderSection); dynamic;
    procedure SectionDrag(FromSection, ToSection: TTntHeaderSection; var AllowDrag: Boolean); dynamic;
    procedure SectionEndDrag; dynamic;
    procedure SectionResize(Section: TTntHeaderSection); dynamic;
    procedure SectionTrack(Section: TTntHeaderSection; Width: Integer;
      State: TSectionTrackState); dynamic;
    procedure SetImages(Value: TCustomImageList); virtual;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas: TCanvas read FCanvas;
    procedure FlipChildren(AllLevels: Boolean); override;
  published
    property Align default alTop;
    property Anchors;
    property BiDiMode;
    property BorderWidth;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DragReorder: Boolean read FDragReorder write SetDragReorder;
    property Enabled;
    property Font;
    property FullDrag: Boolean read FFullDrag write SetFullDrag default True;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property Images: TCustomImageList read FImages write SetImages;
    property Constraints;
    property Sections: TTntHeaderSections read FSections write SetSections;
    property ShowHint;
    property Style: THeaderStyle read FStyle write SetStyle default hsButtons;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDrawSection: TDrawSectionEvent read FOnDrawSection write FOnDrawSection;
    property OnResize;
    property OnSectionClick: TSectionNotifyEvent read FOnSectionClick
      write FOnSectionClick;
    property OnSectionDrag: TSectionDragEvent read FOnSectionDrag
      write FOnSectionDrag;
    property OnSectionEndDrag: TNotifyEvent read FOnSectionEndDrag
      write FOnSectionEndDrag;
    property OnSectionResize: TSectionNotifyEvent read FOnSectionResize
      write FOnSectionResize;
    property OnSectionTrack: TSectionTrackEvent read FOnSectionTrack
      write FOnSectionTrack;
    property OnStartDock;
    property OnStartDrag;
  end;

function Header_GetItemW(Header: HWnd; Index: Integer; var Item: THDItemW): Bool;

procedure Register;

implementation

uses TntControls, TntSysUtils;

procedure CreateUnicodeHandle_ComCtl(Control: TWinControl; const Params: TCreateParams;
  const SubClass: WideString);
begin
  Assert(SubClass <> '', 'TNT Internal Error: Only call CreateUnicodeHandle_ComCtl for Common Controls.');
  CreateUnicodeHandle(Control, Params, SubClass);
  if Win32PlatformIsUnicode then
    SendMessageW(Control.Handle, CCM_SETUNICODEFORMAT, Integer(True), 0);
end;

{ TTntHeaderSection }

constructor TTntHeaderSection.Create(Collection: TCollection);
begin
  FWidth := 50;
  FMaxWidth := 10000;
  FAllowClick := True;
  FImageIndex := -1;
  FParentBiDiMode := True;
  inherited Create(Collection);
  ParentBiDiModeChanged;
end;

procedure TTntHeaderSection.Assign(Source: TPersistent);
begin
  if Source is TTntHeaderSection then
  begin
    Text := TTntHeaderSection(Source).Text;
    Width := TTntHeaderSection(Source).Width;
    MinWidth := TTntHeaderSection(Source).MinWidth;
    MaxWidth := TTntHeaderSection(Source).MaxWidth;
    Alignment := TTntHeaderSection(Source).Alignment;
    Style := TTntHeaderSection(Source).Style;
    AllowClick := TTntHeaderSection(Source).AllowClick;
    ImageIndex := TTntHeaderSection(Source).ImageIndex;
  end
  else inherited Assign(Source);
end;

procedure TTntHeaderSection.SetBiDiMode(Value: TBiDiMode);
begin
  if Value <> FBiDiMode then
  begin
    FBiDiMode := Value;
    FParentBiDiMode := False;
    Changed(False);
  end;
end;

function TTntHeaderSection.IsBiDiModeStored: Boolean;
begin
  Result := not FParentBiDiMode;
end;

procedure TTntHeaderSection.SetParentBiDiMode(Value: Boolean);
begin
  if FParentBiDiMode <> Value then
  begin
    FParentBiDiMode := Value;
    ParentBiDiModeChanged;
  end;
end;

procedure TTntHeaderSection.ParentBiDiModeChanged;
begin
  if FParentBiDiMode then
  begin
    if GetOwner <> nil then
    begin
      BiDiMode := TTntHeaderSections(GetOwner).FHeaderControl.BiDiMode;
      FParentBiDiMode := True;
    end;
  end;
end;

function TTntHeaderSection.UseRightToLeftReading: Boolean;
begin
  Result := SysLocale.MiddleEast and (BiDiMode <> bdLeftToRight);
end;

function TTntHeaderSection.UseRightToLeftAlignment: Boolean;
begin
  Result := SysLocale.MiddleEast and (BiDiMode = bdRightToLeft);
end;

function TTntHeaderSection.GetDisplayName: string;
begin
  Result := Text;
  if Result = '' then Result := inherited GetDisplayName;
end;

function TTntHeaderSection.GetLeft: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Index - 1 do
    Inc(Result, TTntHeaderSections(Collection)[I].Width);
end;

function TTntHeaderSection.GetRight: Integer;
begin
  Result := Left + Width;
end;

procedure TTntHeaderSection.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Changed(False);
  end;
end;

procedure TTntHeaderSection.SetAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then
  begin
    FAutoSize := Value;
    if TTntHeaderSections(Collection).FHeaderControl <> nil then
      TTntHeaderSections(Collection).FHeaderControl.AdjustSize;
  end;
end;

procedure TTntHeaderSection.SetMaxWidth(Value: Integer);
begin
  if Value < FMinWidth then Value := FMinWidth;
  if Value > 10000 then Value := 10000;
  FMaxWidth := Value;
  SetWidth(FWidth);
end;

procedure TTntHeaderSection.SetMinWidth(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if Value > FMaxWidth then Value := FMaxWidth;
  FMinWidth := Value;
  SetWidth(FWidth);
end;

procedure TTntHeaderSection.SetStyle(Value: THeaderSectionStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed(False);
  end;
end;

procedure TTntHeaderSection.SetText(const Value: WideString);
begin
  if FText <> Value then
  begin
	FText := Value;
    Changed(False);
  end;
end;

procedure TTntHeaderSection.SetWidth(Value: Integer);
begin
  if Value < FMinWidth then Value := FMinWidth;
  if Value > FMaxWidth then Value := FMaxWidth;
  if FWidth <> Value then
  begin
    FWidth := Value;
    if Collection <> nil then
      Changed(Index < Collection.Count - 1);
  end;
end;

procedure TTntHeaderSection.SetImageIndex(const Value: TImageIndex);
begin
  if Value <> FImageIndex then
  begin
    FImageIndex := Value;
    Changed(False);
  end;
end;

{ TTntHeaderSections }

constructor TTntHeaderSections.Create(HeaderControl: TTntHeaderControl);
begin
  inherited Create(TTntHeaderSection);
  FHeaderControl := HeaderControl;
end;

function TTntHeaderSections.Add: TTntHeaderSection;
begin
  Result := TTntHeaderSection(inherited Add);
end;

function TTntHeaderSections.GetItem(Index: Integer): TTntHeaderSection;
begin
  Result := TTntHeaderSection(inherited GetItem(Index));
end;

function TTntHeaderSections.GetOwner: TPersistent;
begin
  Result := FHeaderControl;
end;

procedure TTntHeaderSections.SetItem(Index: Integer; Value: TTntHeaderSection);
begin
  inherited SetItem(Index, Value);
end;

procedure TTntHeaderSections.Update(Item: TCollectionItem);
begin
  if Item <> nil then
    FHeaderControl.UpdateSection(Item.Index) else
    FHeaderControl.UpdateSections;
end;

{ TTntHeaderControl }

constructor TTntHeaderControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [];
  Align := alTop;
  Height := 17;
  FSections := TTntHeaderSections.Create(Self);
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FFullDrag := True;
  FDragReorder := False;
  FSectionDragged := False;
  FUpdatingSectionOrder := False;
  FSectionStream := nil;
end;

destructor TTntHeaderControl.Destroy;
begin
  FImageChangeLink.Free;
  FCanvas.Free;
  FSections.Free;
  if Assigned(FSectionStream) then FSectionStream.Free;
  inherited Destroy;
end;

procedure TTntHeaderControl.CreateParams(var Params: TCreateParams);
const
  HeaderStyles: array[THeaderStyle] of DWORD = (HDS_BUTTONS, 0);
begin
  InitCommonControl(ICC_LISTVIEW_CLASSES);
  inherited CreateParams(Params);
  CreateSubClass(Params, WC_HEADER);
  with Params do
  begin
    Style := Style or HeaderStyles[FStyle];
    if FFullDrag then Style := Style or HDS_FULLDRAG;
    if FHotTrack then Style := Style or HDS_HOTTRACK;
    if FDragReorder then Style := Style or HDS_DRAGDROP;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TTntHeaderControl.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle_ComCtl(Self, Params, WC_HEADER);
end;

procedure TTntHeaderControl.CreateWnd;

  procedure ReadSections;
  var
    Reader: TReader;
  begin
    if FSectionStream = nil then Exit;
    Sections.Clear;
    Reader := TReader.Create(FSectionStream, 1024);
    try
      Reader.ReadValue;
      Reader.ReadCollection(Sections);
    finally
      Reader.Free;
    end;
    FSectionStream.Free;
    FSectionStream := nil;
  end;

begin
  inherited CreateWnd;
  if (Images <> nil) and Images.HandleAllocated then
    Header_SetImageList(Handle, Images.Handle);
  if FSectionStream <> nil then
    ReadSections
  else
    UpdateSections;
end;

procedure TTntHeaderControl.DestroyWnd;
var
  Writer: TWriter;
begin
  if FSectionStream = nil then
    FSectionStream := TMemoryStream.Create;
  Writer := TWriter.Create(FSectionStream, 1024);
  try
    Writer.WriteCollection(FSections);
  finally
    Writer.Free;
    FSectionStream.Position := 0;
  end;
  inherited DestroyWnd;
end;

procedure TTntHeaderControl.CMBiDiModeChanged(var Message: TMessage);
var
  Loop: Integer;
begin
  inherited;
  if HandleAllocated then
    for Loop := 0 to Sections.Count - 1 do
      if Sections[Loop].ParentBiDiMode then
        Sections[Loop].ParentBiDiModeChanged;
end;

procedure TTntHeaderControl.FlipChildren(AllLevels: Boolean);
var
  Loop, FirstWidth, LastWidth: Integer;
  ASectionsList: TTntHeaderSections;
begin
  if HandleAllocated and
     (Sections.Count > 0) then
  begin
    { Get the true width of the last section }
    LastWidth := ClientWidth;
    FirstWidth := Sections[0].Width;
    for Loop := 0 to Sections.Count - 2 do Dec(LastWidth, Sections[Loop].Width);
    { Flip 'em }
    ASectionsList := TTntHeaderSections.Create(Self);
    try
      for Loop := 0 to Sections.Count - 1 do with ASectionsList.Add do
        Assign(Self.Sections[Loop]);
      for Loop := 0 to Sections.Count - 1 do
        Sections[Loop].Assign(ASectionsList[Sections.Count - Loop - 1]);
    finally
      ASectionsList.Free;
    end;
    { Set the width of the last Section }
    if Sections.Count > 1 then
    begin
      Sections[Sections.Count-1].Width := FirstWidth;
      Sections[0].Width := LastWidth;
    end;
    UpdateSections;
  end;
end;

procedure TTntHeaderControl.DrawSection(Section: TTntHeaderSection;
  const Rect: TRect; Pressed: Boolean);
begin
  if Assigned(FOnDrawSection) then
    FOnDrawSection(Self, Section, Rect, Pressed) else
    FCanvas.FillRect(Rect);
end;

procedure TTntHeaderControl.SectionClick(Section: TTntHeaderSection);
begin
  if Assigned(FOnSectionClick) then FOnSectionClick(Self, Section);
end;

procedure TTntHeaderControl.SectionResize(Section: TTntHeaderSection);
begin
  if Assigned(FOnSectionResize) then FOnSectionResize(Self, Section);
end;

procedure TTntHeaderControl.SectionTrack(Section: TTntHeaderSection;
  Width: Integer; State: TSectionTrackState);
begin
  if Assigned(FOnSectionTrack) then FOnSectionTrack(Self, Section, Width, State);
end;

procedure TTntHeaderControl.SetFullDrag(Value: Boolean);
begin
  if FFullDrag <> Value then
  begin
    FFullDrag := Value;
    RecreateWnd;
  end;
end;

procedure TTntHeaderControl.SetHotTrack(Value: Boolean);
begin
  if FHotTrack <> Value then
  begin
    FHotTrack := Value;
    RecreateWnd;
  end;
end;

procedure TTntHeaderControl.SetStyle(Value: THeaderStyle);
begin
  if FStyle <> Value then
  begin
	FStyle := Value;
	RecreateWnd;
  end;
end;

procedure TTntHeaderControl.SetDragReorder(const Value: Boolean);
begin
  if FDragReorder <> Value then
  begin
	FDragReorder := Value;
	RecreateWnd;
  end;
end;

procedure TTntHeaderControl.SetSections(Value: TTntHeaderSections);
begin
  FSections.Assign(Value);
end;

procedure TTntHeaderControl.UpdateItem(Message, Index: Integer);
var
  Item: THDItemW;
  AAlignment: TAlignment;
begin
  with Sections[Index] do
  begin
	FillChar(Item, SizeOf(Item), 0);
	Item.mask := HDI_WIDTH or HDI_TEXT or HDI_FORMAT;
	Item.cxy := Width;
	Item.pszText := PWChar(Text);
	Item.cchTextMax := Length(Text);
	AAlignment := Alignment;
	if UseRightToLeftAlignment then ChangeBiDiModeAlignment(AAlignment);
	case AAlignment of
	  taLeftJustify: Item.fmt := HDF_LEFT;
	  taRightJustify: Item.fmt := HDF_RIGHT;
	else
      Item.fmt := HDF_CENTER;
    end;
    if Style = hsOwnerDraw then
      Item.fmt := Item.fmt or HDF_OWNERDRAW else
      Item.fmt := Item.fmt or HDF_STRING;
    if UseRightToLeftReading then Item.fmt := Item.fmt or HDF_RTLREADING;
    if Assigned(Images) and (FImageIndex >= 0) then
    begin
      Item.mask := Item.mask or HDI_IMAGE;
      Item.fmt := Item.fmt or HDF_IMAGE;
      Item.iImage := FImageIndex;
	end;
	SendMessageW(Handle, Message, Index, Integer(@Item));
  end;
end;

procedure TTntHeaderControl.UpdateSection(Index: Integer);
begin
  if HandleAllocated then UpdateItem(HDM_SETITEMW, Index);
end;

procedure TTntHeaderControl.UpdateSections;
var
  I: Integer;
begin
  if HandleAllocated and not FUpdatingSectionOrder then
  begin
	for I := 0 to SendMessage(Handle, HDM_GETITEMCOUNT, 0, 0) - 1 do
      SendMessageW(Handle, HDM_DELETEITEM, 0, 0);
    for I := 0 to Sections.Count - 1 do UpdateItem(HDM_INSERTITEMW, I);
  end;
end;

procedure TTntHeaderControl.CNDrawItem(var Message: TWMDrawItem);
var
  SaveIndex: Integer;
begin
  with Message.DrawItemStruct^ do
  begin
    SaveIndex := SaveDC(hDC);
    FCanvas.Lock;
    try
      FCanvas.Handle := hDC;
      FCanvas.Font := Font;
      FCanvas.Brush.Color := clBtnFace;
      FCanvas.Brush.Style := bsSolid;
      DrawSection(Sections[itemID], rcItem, itemState and ODS_SELECTED <> 0);
    finally
      FCanvas.Handle := 0;
      FCanvas.Unlock;
      RestoreDC(hDC, SaveIndex);
    end;
  end;
  Message.Result := 1;
end;

procedure TTntHeaderControl.CNNotify(var Message: TWMNotify);
var
  Section: TTntHeaderSection;
  TrackState: TSectionTrackState;
  MsgPos: Longint;
  hdhti: THDHitTestInfo;
  hdi: THDItemW;
begin
  with PHDNotify(Message.NMHdr)^ do
    case Hdr.code of
	  HDN_ITEMCLICKW:
		SectionClick(Sections[Item]);
	  HDN_ITEMCHANGEDW:
		if PItem^.mask and HDI_WIDTH <> 0 then
		begin
		  Section := Sections[Item];
		  if Section.FWidth <> PItem^.cxy then
		  begin
			Section.FWidth := PItem^.cxy;
			SectionResize(Section);
		  end;
		end;
	  HDN_BEGINTRACKW, HDN_TRACKW, HDN_ENDTRACKW:
		begin
          Section := Sections[Item];
          case Hdr.code of
            HDN_BEGINTRACKW: TrackState := tsTrackBegin;
            HDN_ENDTRACKW: TrackState := tsTrackEnd;
          else
            TrackState := tsTrackMove;
          end;
          try
            if TrackState <> tsTrackEnd then
            begin
              FTrackSection := Section;
              FTrackWidth := Section.Width;
              MsgPos := GetMessagePos;
              FTrackPos.X := MsgPos and $FFFF;
              FTrackPos.Y := MsgPos shr 16;
              Windows.ScreenToClient(Handle, FTrackPos);
            end;
            with PItem^ do
            begin
              if cxy < Section.FMinWidth then cxy := Section.FMinWidth;
              if cxy > Section.FMaxWidth then cxy := Section.FMaxWidth;
              SectionTrack(Section, cxy, TrackState);
            end;
          finally
            if TrackState = tsTrackEnd then FTrackSection := nil;
          end;
        end;
      HDN_ENDDRAG:
        begin
          Message.Result := 0;
          MsgPos := GetMessagePos;
          hdhti.Point.X := MsgPos and $FFFF;
          Windows.ScreenToClient(Handle, hdhti.Point);
          hdhti.Point.Y := ClientHeight div 2;
          SendMessageW(Handle, HDM_HITTEST, 0, Integer(@hdhti));
          hdi.Mask := HDI_ORDER;
          if hdhti.Item < 0 then
            if (HHT_TOLEFT and hdhti.Flags) <> 0 then
              FToIndex := 0
            else begin
              if ((HHT_TORIGHT and hdhti.Flags) <> 0)
              or ((HHT_NOWHERE and hdhti.Flags) <> 0) then
                FToIndex := Sections.Count - 1
            end
          else begin
            Header_GetItemW(Handle, hdhti.Item, hdi);
            FToIndex := hdi.iOrder;
          end;
          Header_GetItemW(Handle, Item, hdi);
          FFromIndex := hdi.iOrder;
          FSectionDragged := DoSectionDrag(Sections[FFromIndex], Sections[FToIndex]);
        end;
      NM_RELEASEDCAPTURE:
        if FSectionDragged then DoSectionEndDrag;
    end;
end;

procedure TTntHeaderControl.WndProc(var Message: TMessage);
var
  cxy: Integer;
  ShortCircuit: Boolean;

  function FullWindowUpdate: Boolean;
  var
    DragWindows: Bool;
  begin
    Result := FullDrag and SystemParametersInfo(SPI_GETDRAGFULLWINDOWS, 0,
      @DragWindows, 0) and DragWindows;
  end;

begin
  if (Message.Msg = WM_MOUSEMOVE) and FullWindowUpdate and
    (FTrackSection <> nil) and MouseCapture then
  begin
    cxy := FTrackWidth + (TWMMouse(Message).XPos - FTrackPos.X);
    ShortCircuit := False;
    if cxy < FTrackSection.FMinWidth then
    begin
      Dec(cxy, FTrackSection.FMinWidth);
      ShortCircuit := True;
    end;
    if cxy > FTrackSection.FMaxWidth then
    begin
      Dec(cxy, FTrackSection.FMaxWidth);
      ShortCircuit := True;
    end;
    SectionTrack(FTrackSection, cxy, tsTrackMove);
    if ShortCircuit then
      Dec(TWMMouse(Message).XPos, cxy);
  end;
  inherited WndProc(Message);
end;

procedure TTntHeaderControl.WMLButtonDown(var Message: TWMLButtonDown);
var
  Index: Integer;
  Info: THDHitTestInfo;
begin
  Info.Point.X := Message.Pos.X;
  Info.Point.Y := Message.Pos.Y;
  Index := SendMessageW(Handle, HDM_HITTEST, 0, Integer(@Info));
  if (Index < 0) or (Info.Flags and HHT_ONHEADER = 0) or
    Sections[Index].AllowClick then inherited;
end;

procedure TTntHeaderControl.WMSize(var Message: TWMSize);
var
  I, Count, WorkWidth, TmpWidth, Remain: Integer;
  List: TList;
  Section: TTntHeaderSection;
begin
  inherited;
  if HandleAllocated and not (csReading in ComponentState) then
  begin
    { Try to fit all sections within client width }
    List := TList.Create;
    try
      WorkWidth := ClientWidth;
      for I := 0 to Sections.Count - 1 do
      begin
        Section := Sections[I];
        if Section.AutoSize then
          List.Add(Section)
        else
          Dec(WorkWidth, Section.Width);
      end;
      if List.Count > 0 then
      begin
        Sections.BeginUpdate;
        try
          repeat
            Count := List.Count;
            Remain := WorkWidth mod Count;
            { Try to redistribute sizes to those sections which can take it }
            TmpWidth := WorkWidth div Count;
            for I := Count - 1 downto 0 do
            begin
              Section := TTntHeaderSection(List[I]);
              if I = 0 then
                Inc(TmpWidth, Remain);
              Section.Width := TmpWidth;
            end;

            { Verify new sizes don't conflict with min/max section widths and
              adjust if necessary. }
            TmpWidth := WorkWidth div Count;
            for I := Count - 1 downto 0 do
            begin
              Section := TTntHeaderSection(List[I]);
              if I = 0 then
                Inc(TmpWidth, Remain);
              if Section.Width <> TmpWidth then
              begin
                List.Delete(I);
                Dec(WorkWidth, Section.Width);
              end;
            end;
          until (List.Count = 0) or (List.Count = Count);
        finally
          Sections.EndUpdate;
        end;
      end;
    finally
      List.Free;
    end;
  end;
end;

procedure TTntHeaderControl.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  Invalidate;
end;

function TTntHeaderControl.DoSectionDrag(FromSection, ToSection: TTntHeaderSection): Boolean;
begin
  Result := True;
  SectionDrag(FromSection, ToSection, Result);
end;

procedure TTntHeaderControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

procedure TTntHeaderControl.SetImages(Value: TCustomImageList);
begin
  if Images <> nil then
    Images.UnRegisterChanges(FImageChangeLink);
  FImages := Value;
  if Images <> nil then
  begin
    Images.RegisterChanges(FImageChangeLink);
    Images.FreeNotification(Self);
    Header_SetImageList(Handle, Images.Handle);
  end
  else Header_SetImageList(Handle, 0);
  UpdateSections;
end;

procedure TTntHeaderControl.ImageListChange(Sender: TObject);
begin
  Header_SetImageList(Handle, TCustomImageList(Sender).Handle);
  UpdateSections;
end;

procedure TTntHeaderControl.SectionDrag(FromSection, ToSection: TTntHeaderSection;
  var AllowDrag: Boolean);
begin
  if Assigned(FOnSectionDrag) then FOnSectionDrag(Self, FromSection, ToSection,
    AllowDrag);
end;

procedure TTntHeaderControl.DoSectionEndDrag;

  procedure UpdateSectionOrder(FromSection, ToSection: TTntHeaderSection);
  var
    I: Integer;
    SectionOrder: array of Integer;
  begin
    FUpdatingSectionOrder := True;
    try
      Sections.FindItemID(FromSection.ID).Index := ToSection.Index;
      SetLength(SectionOrder, Sections.Count);
      for I := 0 to Sections.Count - 1 do SectionOrder[I] := Sections[I].ID;
      Header_SetOrderArray(Handle, Sections.Count, PInteger(SectionOrder));
    finally
      FUpdatingSectionOrder := False;
    end;
  end;

begin
  FSectionDragged := False;
  UpdateSectionOrder(Sections[FFromIndex], Sections[FToIndex]);
  SectionEndDrag;
end;

procedure TTntHeaderControl.SectionEndDrag;
begin
  if Assigned(FOnSectionEndDrag) then FOnSectionEndDrag(Self);
end;

function Header_GetItemW(Header: HWnd; Index: Integer; var Item: THDItemW): Bool;
begin
  Result := Bool( SendMessageW(Header, HDM_GETITEMW, Index, Longint(@Item)) );
end;

procedure Register;
begin
  RegisterComponents('Tnt Win32', [TTntHeaderControl]);
end;

end.

