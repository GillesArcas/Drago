// ---------------------------------------------------------------------------
// -- Drago -- Advanced settings frame -------------------- UfrAdvanced.pas --
// ---------------------------------------------------------------------------

unit UfrAdvanced;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, Contnrs, VirtualTrees, StdCtrls, ExtCtrls, SpTBXControls, Mask,
  SpTBXEditors, TntStdCtrls, SpTBXItem, ComCtrls, TntComCtrls;

type
  // Describes the type of value a property tree node stores in its data property.
  TEditType = (
    vtNone,
    vtString,
    vtBool,
    vtPickString,
    vtNumber,
    vtPickNumber,
    vtMemo,
    vtCheck,
    vtCombo
  );

  TPropertyEditLink = class;

  TCustomDataItem = class
    FValue : WideString;
    FComboItems : WideString;
    constructor Create(const value, comboItems : WideString);
    function  GetText : WideString; virtual; abstract;
    procedure PrepareEdit(propEditLink : TPropertyEditLink; Tree: TBaseVirtualTree; onKey : TKeyEvent; onExit : TNotifyEvent); virtual;
    function  EndEditResult(propEditLink : TPropertyEditLink) : WideString; virtual;
  end;

  TBoolDataItem = class(TCustomDataItem)
    function  GetText : WideString; override;
    procedure PrepareEdit(propEditLink : TPropertyEditLink; Tree: TBaseVirtualTree; onKey : TKeyEvent; onExit : TNotifyEvent); override;
    function  EndEditResult(propEditLink : TPropertyEditLink) : WideString; override;
  end;

  TStringDataItem = class(TCustomDataItem)
    function  GetText : WideString; override;
    procedure PrepareEdit(propEditLink : TPropertyEditLink; Tree: TBaseVirtualTree; onKey : TKeyEvent; onExit : TNotifyEvent); override;
  end;

  TComboDataItem = class(TCustomDataItem)
    function  GetText : WideString; override;
    procedure PrepareEdit(propEditLink : TPropertyEditLink; Tree: TBaseVirtualTree; onKey : TKeyEvent; onExit : TNotifyEvent); override;
    function  EndEditResult(propEditLink : TPropertyEditLink) : WideString; override;
  end;

  // Node data record
  TPropertyData =
  record
    Caption  : WideString;
    EditType : TEditType;
    Value    : WideString;
    PropKey  : integer;
    Changed  : Boolean;
    Item     : TCustomDataItem;
  end;
  PPropertyData = ^TPropertyData;

  // Our own edit link to implement several different node editors.
  TPropertyEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TWinControl;        // One of the property editor classes.
    FTree: TVirtualStringTree; // A back reference to the tree calling.
    FNode: PVirtualNode;       // The node being edited.
    FColumn: Integer;          // The column of the node being edited.
    FOldEditProc: TWndMethod;  // Used to capture some important messages
              // regardless of the type of edit control we use.

  protected
    procedure EditWindowProc(var Message: TMessage);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  public
    constructor Create;
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
    procedure DoOnExitComboBox(Sender: TObject);
  end;

type
  TfrAdvanced = class(TFrame)
    VT: TVirtualStringTree;
    Panel1: TSpTBXGroupBox;
    btRestore: TSpTBXButton;
    btSelectAll: TSpTBXButton;
    btSelect: TSpTBXButton;
    procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var ChildCount: Cardinal);
    procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure VTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      out EditLink: IVTEditLink);
    procedure btSelectClick(Sender: TObject);
    procedure btSelectAllClick(Sender: TObject);
    procedure btRestoreClick(Sender: TObject);
    procedure VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure VTBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure VTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: WideString);
  private
    procedure EnableCheckBoxes(enable, check : boolean);
  public
    procedure Initialize;
    procedure Finalize;
    procedure Update;
  end;

// ---------------------------------------------------------------------------

implementation

{$R *.dfm}

uses
  StrUtils, Types,
  DefineUi, Std, Translate, UStatus, UStatusMain,
  TntGraphics,
  UViewMain;

// ---------------------------------------------------------------------------

type
  TPropertyKey = (
    kDum,
    kExtendSetup,
    kEnableAsBooks,
    kStartVarFromOne,
    kStartVarWithFig,
    kStartVarAndMain,
    kBoldTextOnBoard,
    kMaxBoardFontSize,
    kSymmetricTiling,
    kOneInstance,
    kMinimizeToTray,
    kHookContent,
    kTabCloseBtn,
    kUsePortablePaths,
    kAbortOnReadError,
    kShowPlacesBar,     
    kPlAskForSave,
    kPlUseSameTab,
    kPlEnableUndo,
    kWarnFullScreen,
    kWarnAtModif,
    kWarnAtModifDB,
    kWarnAtReadOnly,
    kWarnDelBrch,
    kWarnInvMove,
    kWarnOnPass,
    kWarnOnResign,
    kWarnLoseOnTime,
    //kPdfUseOldLib,
    kUseBoardColor,
    kRadiusAdjust,
    kFontSizeAdjust,
    kCircleWidth,
    kLineWidth,
    kDblLineWidth,
    kHoshiStoneRatio,
    kExactWidthMm,
    kAddedBorder,
    kPdfBoldTxtBoard,
    kMarksAdjust,
    kLineHeightAdjust,
    kTrueTypeFont,
    kEmbedTTF,
    kNotFound
  );

type
  TProperty = record
    pi : integer;      // parent index (section index)
    ix : integer;      // node index   (index in section)
    ed : TEditType;    // edit type
    pk : TPropertyKey; // property key
    pr : string;       // property name
    ci : string;       // combo items (comma separated strings)
  end;

const
  PropNum = 45;

var
  PropertyList : array[0 .. PropNum - 1] of TProperty = (
    (ed: vtNone;   pk: kDum;              pr: 'Board'),
    (ed: vtCombo;  pk: kExtendSetup;      pr: 'Click sequence in stone setup mode'; ci: 'Set, remove;Set, swap color, remove'),
    (ed: vtBool;   pk: kEnableAsBooks;    pr: 'Enable moves as books'),
    (ed: vtBool;   pk: kStartVarFromOne;  pr: 'Start variation from 1'),
    (ed: vtBool;   pk: kStartVarWithFig;  pr: 'Start variation with figure'),
    (ed: vtBool;   pk: kStartVarAndMain;  pr: 'Start variation settings include main line'),
    (ed: vtBool;   pk: kBoldTextOnBoard;  pr: 'Bold text'),
    (ed: vtString; pk: kMaxBoardFontSize; pr: 'Maximum font size'),
    (ed: vtBool;   pk: kSymmetricTiling;  pr: 'Texture tiling with symmetries'),
    (ed: vtNone;   pk: kDum;              pr: 'User interface'),
    (ed: vtBool;   pk: kOneInstance;      pr: 'Allow only one instance'),
    (ed: vtBool;   pk: kMinimizeToTray;   pr: 'Minimize to tray'),
    (ed: vtBool;   pk: kHookContent;      pr: 'Hook content of window when resizing'),
    (ed: vtBool;   pk: kTabCloseBtn;      pr: 'Show tab close buttons'),
    (ed: vtNone;   pk: kDum;              pr: 'Files'),
    (ed: vtBool;   pk: kUsePortablePaths; pr: 'Save paths relatively to install folder'),
    (ed: vtBool;   pk: kAbortOnReadError; pr: 'Abort reading on file error'),
    (ed: vtBool;   pk: kShowPlacesBar;    pr: 'Open save dialogs with places bar'),
    (ed: vtNone;   pk: kDum;              pr: 'Games against engines'),
    (ed: vtBool;   pk: kPlAskForSave;     pr: 'Ask for saving when closing game'),
    (ed: vtBool;   pk: kPlUseSameTab;     pr: 'Use again previous game engine tab'),
    (ed: vtCombo;  pk: kPlEnableUndo;     pr: 'Enable undo'; ci: 'No;Yes;Only after capture'),
    (ed: vtNone;   pk: kDum;              pr: 'Warnings'),
    (ed: vtBool;   pk: kWarnFullScreen;   pr: 'Warn when toggling to full screen'),
    (ed: vtBool;   pk: kWarnAtModif;      pr: 'Warn at first modification'),
    (ed: vtBool;   pk: kWarnAtModifDB;    pr: 'Warn at modification in database game'),
    (ed: vtBool;   pk: kWarnAtReadOnly;   pr: 'Warn at modification in read only mode'),
    (ed: vtBool;   pk: kWarnDelBrch;      pr: 'Warn when delete branch'),
    (ed: vtBool;   pk: kWarnInvMove;      pr: 'Warn on invalid move'),
    (ed: vtBool;   pk: kWarnOnPass;       pr: 'Warn on game engine pass'),
    (ed: vtBool;   pk: kWarnOnResign;     pr: 'Warn on game engine resignation'),
    (ed: vtBool;   pk: kWarnLoseOnTime;   pr: 'Warn when losing on time'),
    (ed: vtNone;   pk: kDum;              pr: 'PDF'),
  //(ed: vtBool;   pk: kPdfUseOldLib;     pr: 'Use old lib'),
    (ed: vtBool;   pk: kUseBoardColor;    pr: 'Use board color'),
    (ed: vtString; pk: kExactWidthMm;     pr: 'Exact width (mm)'),
    (ed: vtString; pk: kAddedBorder;      pr: 'Added border (N;W;S;E in % of image width)'),
    (ed: vtString; pk: kRadiusAdjust;     pr: 'Radius adjustment'),
    (ed: vtString; pk: kCircleWidth;      pr: 'Circle width'),
    (ed: vtString; pk: kLineWidth;        pr: 'Line width'),
    (ed: vtString; pk: kDblLineWidth;     pr: 'Double line width'),
    (ed: vtString; pk: kHoshiStoneRatio;  pr: 'Hoshi stone ratio'),
    (ed: vtString; pk: kMarksAdjust;      pr: 'Marks adjustment (line width;size factor)'),
    (ed: vtString; pk: kFontSizeAdjust;   pr: 'Font size adjustment (f or f;f or f;f;f see help)'),
    (ed: vtBool;   pk: kPdfBoldTxtBoard;  pr: 'Bold text'),
    (ed: vtString; pk: kLineHeightAdjust; pr: 'Line height adjustment')
  );

procedure InitializeProperties;
var
  currentSection, currentKey, i : integer;
begin
  currentSection := -1;
  currentKey     := -1;

  for i := 0 to PropNum - 1 do
    if PropertyList[i].ed = vtNone
      then
        begin
          inc(currentSection);
          currentKey := -1;
          PropertyList[i].pi := -1;
          PropertyList[i].ix := currentSection
        end
      else
        begin
          inc(currentKey);
          PropertyList[i].pi := currentSection;
          PropertyList[i].ix := currentKey
        end
end;

// Conversion from (sectionIndex, keyIndex) to index in property list

function PropertyIndex(sectionIndex, keyIndex : integer) : integer;
begin
  for Result := 0 to PropNum - 1 do
    if (PropertyList[Result].pi = sectionIndex) and
       (PropertyList[Result].ix = keyIndex)
      then exit;

  Result := -1;
end;

// Number of keys in section

function NumberOfChildren(sectionIndex : integer) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to PropNum - 1 do
    if PropertyList[i].pi = sectionIndex
      then inc(Result)
end;

// -- Access to settings -----------------------------------------------------

function BoolToString(x : boolean) : string;
begin
  Result := iff(x, '1', '0')
end;

function StringToBool(x : string) : boolean;
begin
  Result := x = '1'
end;

function FindDefault(key : TPropertyKey) : WideString;
begin
  case key of
    kExtendSetup     : Result := BoolToString(__ExtendSetup);
    kEnableAsBooks   : Result := BoolToString(__EnableAsBooks);
    kStartVarFromOne : Result := BoolToString(__StartVarFromOne);
    kStartVarWithFig : Result := BoolToString(__StartVarWithFig);
    kStartVarAndMain : Result := BoolToString(__StartVarAndMain);
    kBoldTextOnBoard : Result := BoolToString(__BoldTextOnBoard);
    kMaxBoardFontSize: Result := IntToStr    (__MaxBoardFontSize);
    kSymmetricTiling : Result := BoolToString(__SymmetricTiling);
    kOneInstance     : Result := BoolToString(__OneInstance);
    kMinimizeToTray  : Result := BoolToString(__MinimizeToTray);
    kHookContent     : Result := BoolToString(__HookContent);
    kTabCloseBtn     : Result := '1';
    kUsePortablePaths: Result := BoolToString(__UsePortablePaths);
    kAbortOnReadError: Result := BoolToString(__AbortOnReadError);
    kShowPlacesBar   : Result := BoolToString(__ShowPlacesBar   );
    kPlAskForSave    : Result := '0';
    kPlUseSameTab    : Result := '1';
    kPlEnableUndo    : Result := IntToStr    (integer(__PlEnableUndo));
    kWarnAtModif     : Result := BoolToString(__WarnAtModif);
    kWarnFullScreen  : Result := BoolToString(__WarnFullScreen);
    kWarnAtModifDB   : Result := BoolToString(__WarnAtModifDB);
    kWarnAtReadOnly  : Result := BoolToString(__WarnAtReadOnly);
    kWarnDelBrch     : Result := BoolToString(__WarnDelBrch);
    kWarnInvMove     : Result := BoolToString(__WarnInvMove);
    kWarnOnPass      : Result := BoolToString(__WarnOnPass);
    kWarnOnResign    : Result := BoolToString(__WarnOnResign);
    kWarnLoseOnTime  : Result := BoolToString(__WarnLoseOnTime);
    //kPdfUseOldLib    : Result := BoolToString(__PdfUseOldLib);
    kUseBoardColor   : Result := BoolToString(__PdfUseBoardColor);
    kRadiusAdjust    : Result := FloatToStrF (__PdfRadiusAdjust, ffGeneral, 3, 1);
    kFontSizeAdjust  : Result := __PdfFontSizeAdjust;
    kCircleWidth     : Result := FloatToStrF (__PdfCircleWidth, ffGeneral, 3, 1);
    kLineWidth       : Result := FloatToStrF (__PdfLineWidth, ffGeneral, 3, 1);
    kDblLineWidth    : Result := FloatToStrF (__PdfDblLineWidth, ffGeneral, 3, 1);
    kHoshiStoneRatio : Result := FloatToStrF (__PdfHoshiStoneRatio, ffGeneral, 3, 1);
    kExactWidthMm    : Result := IntToStr    (__PdfExactWidthMm);
    kAddedBorder     : Result := __PdfAddedBorder;
    kPdfBoldTxtBoard : Result := BoolToString (__PdfBoldTextOnBoard);
    kMarksAdjust     : Result := __PdfMarksAdjust;
    kLineHeightAdjust: Result := FloatToStrF  (__PdfLineHeightAdjust, ffGeneral, 3, 1);
    kTrueTypeFont    : Result := __PdfTrueTypeFont;
    kEmbedTTF        : Result := BoolToString (__PdfEmbedTTF);
    kNotFound        : assert(False);
  end
end;

function FindValue(key : TPropertyKey) : WideString;
begin
  case key of
    kExtendSetup     : Result := BoolToString(Settings.ExtendSetup);
    kEnableAsBooks   : Result := BoolToString(Settings.EnableAsBooksTmp);
    kStartVarFromOne : Result := BoolToString(Settings.StartVarFromOne);
    kStartVarWithFig : Result := BoolToString(Settings.StartVarWithFig);
    kStartVarAndMain : Result := BoolToString(Settings.StartVarAndMain);
    kBoldTextOnBoard : Result := BoolToString(Settings.BoldTextOnBoard);
    kMaxBoardFontSize: Result := IntToStr    (Settings.MaxBoardFontSize);
    kSymmetricTiling : Result := BoolToString(Settings.SymmetricTiling);
    kOneInstance     : Result := BoolToString(StatusMain.OneInstance);
    kMinimizeToTray  : Result := BoolToString(StatusMain.MinimizeToTray);
    kHookContent     : Result := BoolToString(Settings.HookContent);
    kTabCloseBtn     : Result := BoolToString(Settings.TabCloseBtn);
    kUsePortablePaths: Result := BoolToString(Settings.UsePortablePaths);
    kAbortOnReadError: Result := BoolToString(Settings.AbortOnReadError);
    kShowPlacesBar   : Result := BoolToString(Settings.ShowPlacesBar);
    kPlAskForSave    : Result := BoolToString(Settings.PlAskForSave);
    kPlUseSameTab    : Result := BoolToString(Settings.PlUseSameTab);
    kPlEnableUndo    : Result := IntToStr    (integer(Settings.PlUndo));
    kWarnFullScreen  : Result := BoolToString(Settings.WarnFullScreen);
    kWarnAtModif     : Result := BoolToString(Settings.WarnAtModif);
    kWarnAtModifDB   : Result := BoolToString(Settings.WarnAtModifDB);
    kWarnAtReadOnly  : Result := BoolToString(Settings.WarnAtReadOnly);
    kWarnDelBrch     : Result := BoolToString(Settings.WarnDelBrch);
    kWarnInvMove     : Result := BoolToString(Settings.WarnInvMove);
    kWarnOnPass      : Result := BoolToString(Settings.WarnOnPass);
    kWarnOnResign    : Result := BoolToString(Settings.WarnOnResign);
    kWarnLoseOnTime  : Result := BoolToString(Settings.WarnLoseOnTime);
  //kPdfUseOldLib    : Result := BoolToString(Settings.PdfUseOldLib);
    kUseBoardColor   : Result := BoolToString(Settings.pdfUseBoardColor);
    kRadiusAdjust    : Result := FloatToStrF (Settings.PdfRadiusAdjust, ffGeneral, 3, 1);
    kFontSizeAdjust  : Result := Settings.PdfFontSizeAdjust;
    kCircleWidth     : Result := FloatToStrF (Settings.PdfCircleWidth, ffGeneral, 3, 1);
    kLineWidth       : Result := FloatToStrF (Settings.PdfLineWidth, ffGeneral, 3, 1);
    kDblLineWidth    : Result := FloatToStrF (Settings.PdfDblLineWidth, ffGeneral, 3, 1);
    kHoshiStoneRatio : Result := FloatToStrF (Settings.PdfHoshiStoneRatio, ffGeneral, 3, 1);
    kExactWidthMm    : Result := IntToStr    (Settings.PdfExactWidthMm);
    kAddedBorder     : Result := Settings.PdfAddedBorder;
    kPdfBoldTxtBoard : Result := BoolToString(Settings.PdfBoldTextOnBoard);
    kMarksAdjust     : Result := Settings.PdfMarksAdjust;
    kLineHeightAdjust: Result := FloatToStrF (Settings.PdfLineHeightAdjust, ffGeneral, 3, 1);
    kTrueTypeFont    : Result := Settings.PdfTrueTypeFont;
    kEmbedTTF        : Result := BoolToString(Settings.PdfEmbedTTF);
    kNotFound        : assert(False);
  end
end;

procedure SaveValue(key : TPropertyKey; value : WideString);
begin
  case key of
    kExtendSetup     : Settings.ExtendSetup         := StringToBool(value);
    kEnableAsBooks   : Settings.EnableAsBooksTmp    := StringToBool(value);
    kStartVarFromOne : Settings.StartVarFromOne     := StringToBool(value);
    kStartVarWithFig : Settings.StartVarWithFig     := StringToBool(value);
    kStartVarAndMain : Settings.StartVarAndMain     := StringToBool(value);
    kBoldTextOnBoard : Settings.BoldTextOnBoard     := StringToBool(value);
    kMaxBoardFontSize: Settings.MaxBoardFontSize    := StrToIntDef (value, __MaxBoardFontSize);
    kSymmetricTiling : Settings.SymmetricTiling     := StringToBool(value);
    kOneInstance     : StatusMain.OneInstance       := StringToBool(value);
    kMinimizeToTray  : StatusMain.MinimizeToTray    := StringToBool(value);
    kHookContent     : Settings.HookContent         := StringToBool(value);
    kUsePortablePaths: Settings.UsePortablePaths    := StringToBool(value);
    kAbortOnReadError: Settings.AbortOnReadError    := StringToBool(value);
    kShowPlacesBar   : Settings.ShowPlacesBar       := StringToBool(value);
    kTabCloseBtn     : Settings.TabCloseBtn         := StringToBool(value);
    kPlAskForSave    : Settings.PlAskForSave        := StringToBool(value);
    kPlUseSameTab    : Settings.PlUseSameTab        := StringToBool(value);
    kPlEnableUndo    : Settings.PlUndo              := TEngineUndo (StrToInt(value));
    kWarnFullScreen  : Settings.WarnFullScreen      := StringToBool(value);
    kWarnAtModif     : Settings.WarnAtModif         := StringToBool(value);
    kWarnAtModifDB   : Settings.WarnAtModifDB       := StringToBool(value);
    kWarnAtReadOnly  : Settings.WarnAtReadOnly      := StringToBool(value);
    kWarnDelBrch     : Settings.WarnDelBrch         := StringToBool(value);
    kWarnInvMove     : Settings.WarnInvMove         := StringToBool(value);
    kWarnOnPass      : Settings.WarnOnPass          := StringToBool(value);
    kWarnOnResign    : Settings.WarnOnResign        := StringToBool(value);
    kWarnLoseOnTime  : Settings.WarnLoseOnTime      := StringToBool(value);
    kUseBoardColor   : Settings.PdfUseBoardColor    := StringToBool(value);
    kRadiusAdjust    : Settings.PdfRadiusAdjust     := StrToFloatDef(value, 0);
    kFontSizeAdjust  : begin
                         value := AnsiReplaceText(value, ',', '.');
                         Settings.PdfFontSizeAdjust:= value
                       end;
    kCircleWidth     : Settings.PdfCircleWidth      := StrToFloatDef(value, 0);
    kLineWidth       : Settings.PdfLineWidth        := StrToFloatDef(value, 0);
    kDblLineWidth    : Settings.PdfDblLineWidth     := StrToFloatDef(value, 0);
    kHoshiStoneRatio : Settings.PdfHoshiStoneRatio  := StrToFloatDef(value, 0);
    kExactWidthMm    : Settings.PdfExactWidthMm     := StrToIntDef  (value, 0);
    kAddedBorder     : begin
                         value := AnsiReplaceText(value, ',', '.');
                         Settings.PdfAddedBorder    := value
                       end;
    kPdfBoldTxtBoard : Settings.PdfBoldTextOnBoard := StringToBool(value);
    kMarksAdjust     : begin
                         value := AnsiReplaceText(value, ',', '.');
                         Settings.PdfMarksAdjust    := value;
                       end;
    kLineHeightAdjust: Settings.PdfLineHeightAdjust := StrToFloatDef(value, 0);
    kTrueTypeFont    : Settings.PdfTrueTypeFont     := value;
    kEmbedTTF        : Settings.PdfEmbedTTF         := StringToBool(value);
    kNotFound        : assert(False);
  end
end;

// -- Public -----------------------------------------------------------------

var
  NewStartVarFromOne, NewStartVarWithFig, NewStartVarAndMain : boolean;

procedure TfrAdvanced.Initialize;
begin
  NewStartVarFromOne := Settings.StartVarFromOne;
  NewStartVarWithFig := Settings.StartVarWithFig;
  NewStartVarAndMain := Settings.StartVarAndMain;

  InitializeProperties;
  
  with VT do
    begin
      BeginUpdate;
      try
        Header.Columns[0].Width := 350;
        NodeDataSize := SizeOf(TPropertyData);
        Clear;
        RootNodeCount := NumberOfChildren(-1)
      finally
        EndUpdate
      end
    end
end;

procedure TfrAdvanced.Finalize;
var
  node : PVirtualNode;
  data : PPropertyData;
begin
  node := VT.GetFirst;

  while Assigned(node) do
    begin
      if VT.GetNodeLevel(node) = 1 then
        begin
          data := VT.GetNodeData(Node);
          data.Item.Free
        end;

      node := VT.GetNext(node)
    end
end;

procedure TfrAdvanced.Update;
var
  node : PVirtualNode;
  data : PPropertyData;
begin
  if (NewStartVarFromOne <> Settings.StartVarFromOne) or
     (NewStartVarWithFig <> Settings.StartVarWithFig) or
     (NewStartVarAndMain <> Settings.StartVarAndMain)
    then RestartAll;

  node := VT.GetFirst;

  while Assigned(node) do
    begin
      if VT.GetNodeLevel(node) = 1 then
        begin
          data := VT.GetNodeData(Node);
          SaveValue(TPropertyKey(data.PropKey), data.Value);
        end;

      node := VT.GetNext(node)
    end
end;

// -- Initialization of nodes ------------------------------------------------

procedure TfrAdvanced.VTInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Data: PPropertyData;
  k : integer;
begin
  Data := Sender.GetNodeData(Node);

  if ParentNode = nil
    then
      begin
        k := PropertyIndex(-1, Node.Index);
        Data.Item     := nil;
        Data.Caption  := PropertyList[k].pr;
        Data.EditType := vtNone;
        Data.Value    := '';
        Data.PropKey  := ord(PropertyList[k].pk);
        InitialStates := InitialStates + [ivsHasChildren]//, ivsExpanded]
      end
    else
      begin
        k := PropertyIndex(Node.Parent.Index, Node.Index);
        Data.Caption  := PropertyList[k].pr;
        Data.EditType := PropertyList[k].ed;
        Data.Value    := FindValue(PropertyList[k].pk);
        Data.PropKey  := ord(PropertyList[k].pk);

        case Data.EditType of
          vtBool   : Data.Item := TBoolDataItem.Create  (data.Value, PropertyList[k].ci);
          vtString : Data.Item := TStringDataItem.Create(data.Value, PropertyList[k].ci);
          vtCombo  : Data.Item := TComboDataItem.Create (data.Value, PropertyList[k].ci);
        end;
      end
end;

procedure TfrAdvanced.VTInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
begin
  ChildCount := NumberOfChildren(Node.Index)
end;

// -- GetText event ----------------------------------------------------------

procedure TfrAdvanced.VTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  data : PPropertyData;
begin
  data := Sender.GetNodeData(Node);

  if TextType = ttNormal then
    case Column of
      0 : CellText := U(Data.Caption);
//      1 : CellText := data.Item.GetText
(*
      1 : if Data.EditType = vtBool
            then CellText := iff(Data.Value = '1', U('Yes'), U('No'))
            else CellText := U(Data.Value)
*)
      1 : if data.EditType = vtNone
            then CellText := U(data.Value)
            else CellText := U(data.Item.GetText)
    end
end;

// -- Cell display -----------------------------------------------------------

procedure TfrAdvanced.VTBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
begin
  EXIT;
  
  if Column = 1
    then TargetCanvas.Brush.Color := clCream //$FAFAFA
    else TargetCanvas.Brush.Color := clWindow;

  TargetCanvas.FillRect(CellRect)
end;

procedure TfrAdvanced.VTPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  Data: PPropertyData;
begin
  if Node.Parent = Sender.RootNode
    then TargetCanvas.Font.Style := [fsBold]
    else
      if Column = 0
        then //TargetCanvas.Font.Color := clBlue
        else
          begin
            Data := Sender.GetNodeData(Node);
            if Data.Changed
              then TargetCanvas.Font.Color := clRed
              else TargetCanvas.Font.Style := []
          end;
end;

// -- Hint -------------------------------------------------------------------
//
// HintMode = hmToolTip: display hint if cell text is shorten

procedure TfrAdvanced.VTGetHint(Sender: TBaseVirtualTree;
                                Node: PVirtualNode; Column: TColumnIndex;
                                var LineBreakStyle: TVTTooltipLineBreakStyle;
                                var HintText: WideString);
var
  Data: PPropertyData;
begin
  if Sender.GetNodeLevel(Node) = 0
    then HintText := ''
    else
      begin
        Data := Sender.GetNodeData(Node);
        if Column = 0
          then HintText := U(Data.Caption)
          else HintText := U(Data.Value)
      end
end;

// -- Editing ----------------------------------------------------------------

procedure TfrAdvanced.VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
                                Column: TColumnIndex; var Allowed: Boolean);
var
  Data: PPropertyData;
begin
  with Sender do
  begin
    Data := GetNodeData(Node);
    Allowed := (Node.Parent <> RootNode) and (Column = 1) and (Data.EditType <> vtNone)
  end
end;

procedure TfrAdvanced.VTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  // Start immediate editing as soon as another node gets focused.
  with Sender do
  begin
      if Assigned(Node) and (Node.Parent <> RootNode) and not (tsIncrementalSearching in TreeStates) then
      begin
         // Note: the test whether a node can really be edited is done in the OnEditing event.
         EditNode(Node, 1);
      end;
   end;
end;

procedure TfrAdvanced.VTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  out EditLink: IVTEditLink);
// This is the callback of the tree control to ask for an application defined edit link. Providing one here allows
// us to control the editing process up to which actual control will be created.
// TPropertyEditLink implements an interface and hence benefits from reference counting. We don't need to keep a
// reference to free it. As soon as the tree finished editing the class will be destroyed automatically.
begin
  EditLink := TPropertyEditLink.Create;
end;

// -- Check and button events ------------------------------------------------

// -- Checking a section checks all sons

procedure TfrAdvanced.VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  node2 : PVirtualNode;
begin
  if (Sender.GetNodeLevel(Node) = 0) and (Node.CheckState = csCheckedNormal) then
    begin
      node2 := VT.GetFirst;
      while Assigned(node2)do
        begin
          if node2.Parent = Node then
            begin
              node2.CheckState := csCheckedNormal;
              VT.RepaintNode(node2)
            end;
          node2 := VT.GetNext(node2)
        end
    end;

  if (Sender.GetNodeLevel(Node) = 1) and (Node.CheckState = csUncheckedNormal) then
    begin
      Node.Parent.CheckState := csUnCheckedNormal;
      VT.RepaintNode(Node.Parent)
    end
end;

procedure TfrAdvanced.EnableCheckBoxes(enable, check : boolean);
var
  node : PVirtualNode;
begin
  node := VT.GetFirst;
  while Assigned(node) do
    begin
      if enable
        then node.CheckType := ctCheckBox
        else node.CheckType := ctNone;
      if check
        then node.CheckState := csCheckedNormal
        else node.CheckState := csUncheckedNormal;

      VT.RepaintNode(node);
      node := VT.GetNext(node)
    end
end;

procedure TfrAdvanced.btSelectClick(Sender: TObject);
begin
  EnableCheckBoxes(True, False)
end;

procedure TfrAdvanced.btSelectAllClick(Sender: TObject);
begin
  EnableCheckBoxes(True, True)
end;

procedure TfrAdvanced.btRestoreClick(Sender: TObject);
var
  node : PVirtualNode;
  data : PPropertyData;
begin
  node := VT.GetFirst;
  while Assigned(node) do
    begin
      if (node.CheckState = csCheckedNormal) and (VT.GetNodeLevel(node) > 0) then
        begin
          data := VT.GetNodeData(node);
          data.Value := FindDefault(TPropertyKey(Data.PropKey));
          data.Item.FValue := data.Value;
          //VT.ResetNode(node)
          VT.InvalidateNode(node);
        end;

      node := VT.GetNext(node)
    end;

  EnableCheckBoxes(False, False);
  VT.Repaint
end;

// == Property editors =======================================================

constructor TPropertyEditLink.Create;
begin
   inherited;
end;

destructor TPropertyEditLink.Destroy;
begin
   FEdit.Free;
   inherited;
end;

// when a combo has focus, and when the option form is closed, there is no WM_KILLFOCUS
// message launched for a combo. So, editing is ended through the OnExit event.  
procedure TPropertyEditLink.DoOnExitComboBox(Sender: TObject);
begin
  if (Sender as TTntComboBox).Visible
    then FTree.EndEditNode;
end;

function TPropertyEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
var
  Data: PPropertyData;
begin
  Result := True;
  FTree := Tree as TVirtualStringTree;
  FNode := Node;
  FColumn := Column;

  // determine what edit type actually is needed
  FEdit.Free;
  FEdit := nil;
  Data := FTree.GetNodeData(Node);
  //Data.Item.PrepareEdit(self, Tree, EditKeyDown, DoOnExitComboBox);

  case Data.EditType of
    vtString:
      Data.Item.PrepareEdit(self, Tree, EditKeyDown, DoOnExitComboBox);
    vtBool:
      Data.Item.PrepareEdit(self, Tree, EditKeyDown, DoOnExitComboBox);
    vtCombo:
      Data.Item.PrepareEdit(self, Tree, EditKeyDown, DoOnExitComboBox);
  else
    Result := False;
  end;
end;


procedure TPropertyEditLink.EditWindowProc(var Message: TMessage);
// Here we can capture messages for keeping track of focus changes.
begin
  case Message.Msg of
    WM_KILLFOCUS:
      if FEdit is TTntComboBox
        then // handled by OnExit event
      else
        FTree.EndEditNode;
  else
    FOldEditProc(Message);
  end;
end;

function TPropertyEditLink.BeginEdit: Boolean;
begin
  Result := True;
  FEdit.Show;
  FEdit.SetFocus;
  // Set a window procedure hook(aka subclassing) to get notified about important messages.
  FOldEditProc := FEdit.WindowProc;
  FEdit.WindowProc := EditWindowProc;
end;

function TPropertyEditLink.CancelEdit: Boolean;
begin
  Result := True;
  // Restore the edit's window proc.
  FEdit.WindowProc := FOldEditProc;
  FEdit.Hide;
end;

function TPropertyEditLink.EndEdit: Boolean;
var
  Data: PPropertyData;
  S: WideString;
  P: TPoint;
  Dummy: Integer;
begin
  // Check if the place the user click on yields another node as the one we
  // are currently editing. If not then do not stop editing.
  GetCursorPos(P);
  P := FTree.ScreenToClient(P);
  Result := FTree.GetNodeAt(P.X, P.Y, True, Dummy) <> FNode;

  if Result then
  begin
    Data := FTree.GetNodeData(FNode);

    // restore the edit's window proc
    FEdit.WindowProc := FOldEditProc;

    S := Data.Item.EndEditResult(self);
    
    if S <> Data.Value then
    begin
      data.Item.FValue := S;
      Data.Value := S;
      Data.Changed := True;
      FTree.InvalidateNode(FNode);

      // 'OnChange'
      case TPropertyKey(Data.PropKey) of
        kEnableAsBooks:
          Status.EnableAsBooksTmp := S = '1';
        kStartVarFromOne :
          NewStartVarFromOne := S = '1';
        kStartVarWithFig :
          NewStartVarWithFig := S = '1';
        kStartVarAndMain :
          NewStartVarAndMain := S = '1';
      end
    end;

    FEdit.Hide;
  end;
end;

procedure TPropertyEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  CanAdvance: Boolean;
begin
  case Key of
    VK_RETURN : Key := 0;
    //VK_RETURN,
    VK_UP,
    VK_DOWN:
      begin
        // Consider special cases before finishing edit mode.
        CanAdvance := Shift = [];
        if FEdit is TComboBox then
          CanAdvance := CanAdvance and not TComboBox(FEdit).DroppedDown;

        if CanAdvance then
        begin
          FTree.EndEditNode;
          with FTree do
          begin
            if Key = VK_UP then
              FocusedNode := GetPreviousVisible(FocusedNode)
            else
              FocusedNode := GetNextVisible(FocusedNode);
            Selected[FocusedNode] := True;
          end;
          Key := 0;
        end;
      end;
  end;
end;

procedure TPropertyEditLink.ProcessMessage(var Message: TMessage);
begin
  FEdit.WindowProc(Message);
end;

function TPropertyEditLink.GetBounds: TRect;
begin
  Result := FEdit.BoundsRect;
end;

procedure TPropertyEditLink.SetBounds(R: TRect);
var
  Dummy: Integer;
begin
  // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
  // we have to set the edit's width explicitly to the width of the column.
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  FEdit.BoundsRect := R;
end;

// -- Editors ----------------------------------------------------------------

// custom editor

constructor TCustomDataItem.Create(const value, comboItems : WideString);
begin
  FValue := value;
  FComboItems := comboItems
end;

procedure TCustomDataItem.PrepareEdit(propEditLink : TPropertyEditLink;
                                      Tree : TBaseVirtualTree;
                                      onKey : TKeyEvent;
                                      onExit : TNotifyEvent);
begin
end;

function TCustomDataItem.EndEditResult(propEditLink : TPropertyEditLink) : WideString;
var
  buffer : array[0 .. 1024] of char;
begin
  GetWindowText(propEditLink.FEdit.Handle, buffer, 1024);
  Result := buffer
end;

// string editor

function TStringDataItem.GetText : WideString;
begin
  Result := FValue
end;

procedure TStringDataItem.PrepareEdit(propEditLink : TPropertyEditLink;
                                      Tree : TBaseVirtualTree;
                                      onKey : TKeyEvent;
                                      onExit : TNotifyEvent);
var
  propEdit : TTntEdit;
begin
  propEdit := TTntEdit.Create(nil);

  propEdit.Parent    := Tree;
  propEdit.Text      := FValue;
  propEdit.OnKeyDown := onKey;

  propEditLink.FEdit := propEdit
end;

// bool editor

function TBoolDataItem.GetText : WideString;
begin
  Result := iff(FValue = '1', U('Yes'), U('No'))
end;

procedure TBoolDataItem.PrepareEdit(propEditLink : TPropertyEditLink;
                                    Tree : TBaseVirtualTree;
                                    onKey : TKeyEvent;
                                    onExit : TNotifyEvent);
var
  propEdit : TTntComboBox;
begin
  propEdit := TTntComboBox.Create(nil);

  propEdit.Parent    := Tree;
  propEdit.OnKeyDown := onKey;
  propEdit.OnExit    := onExit;
  propEdit.Items.Add(U('Yes'));
  propEdit.Items.Add(U('No'));
  propEdit.ItemIndex := iff(FValue = '1', 0, 1);
  propEdit.Text      := GetText;

  propEditLink.FEdit := propEdit
end;

function TBoolDataItem.EndEditResult(propEditLink : TPropertyEditLink) : WideString;
begin
  Result := iff(TTntComboBox(propEditLink.FEdit).ItemIndex = 0, '1', '0')
end;

// combo editor

function TComboDataItem.GetText : WideString;
var
  strings : TStringDynArray;
begin
  Split(FComboItems, strings, ';');
  Result := strings[StrToInt(FValue)]
end;

procedure TComboDataItem.PrepareEdit(propEditLink : TPropertyEditLink;
                                     Tree : TBaseVirtualTree;
                                     onKey : TKeyEvent;
                                     onExit : TNotifyEvent);
var
  propEdit : TTntComboBox;
  strings : TStringDynArray;
  i : integer;
begin
  propEdit := TTntComboBox.Create(nil);

  Split(FComboItems, strings, ';');

  propEdit.Parent    := Tree;
  propEdit.OnKeyDown := onKey;
  propEdit.OnExit    := onExit;

  for i := 0 to High(strings) do
    propEdit.Items.Add(U(strings[i]));
  propEdit.ItemIndex := StrToInt(FValue);
  propEdit.Text      := U(strings[propEdit.ItemIndex]);

  propEditLink.FEdit := propEdit
end;

function TComboDataItem.EndEditResult(propEditLink : TPropertyEditLink) : WideString;
var
  i : integer;
begin
  i := (propEditLink.FEdit as TTntComboBox).ItemIndex;
  if i >= 0
    then FValue := IntToStr(i);
  Result := FValue
end;

// ---------------------------------------------------------------------------

end.
