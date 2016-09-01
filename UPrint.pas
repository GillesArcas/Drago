// ---------------------------------------------------------------------------
// -- Drago -- Printing and exporting games -------------------- UPrint.pas --
// ---------------------------------------------------------------------------

unit UPrint;

// ---------------------------------------------------------------------------

interface

uses
  SysUtils,
  Types, Classes,
  StrUtils,
  Define, DefineUi, UGameTree,
  UView, UExporter,
  UInstStatus;

function PerformPreview(aView : TView;
                        var ok : boolean;
                        exporter : TExporter;
                        aExportMode   : TExportMode;
                        aExportFigure : TExportFigure;
                        aShowMoveMode : TShowMoveMode = smBook) : integer;

function ParseGameInfosName(gt : TGameTree; const format : string; si : TInstStatus) : string;

function ExportFilename(view        : TView;
                        aExportMode : TExportMode;
                        filename    : WideString) : WideString;
// callbacks

var
  PrintStepOnGame   : function : boolean of object;
  PrintStepOnFigure : function : boolean of object;
  PrintStepFinished : function : boolean of object;

// ---------------------------------------------------------------------------

implementation

uses
  ClassesEx, SysUtilsEx,
  UContext,
  UImageExporter,
  Translate,
  Ux2y, UGmisc, GameUtils, CodePages,
  Properties, UStatus, UGameColl, 
  UGoban,
  ViewUtils,
  Std;

// -- Local data -------------------------------------------------------------

const
  DefaultPixelsPerInch = 96; // was screen.PixelsPerInch
  interDiag = 2;

type
  TDelayedStrings = TStringDynArray;

var
  nFigures, nMainFigures, nFigInGame : integer;
  widthDiag, leftDiag, currentGame : integer;
  DelayStrings : TDelayedStrings;
  DelayAccumComment : TStringList;
  Numbering : TIntStack;

// -- Helpers ----------------------------------------------------------------

// Number of columns of figure in line

function ColPerLine(view : TView) : integer;
begin
  if nFigInGame = 1
    then
      if view.st.PrFirstFigAlone
        then Result := 1
        else Result := view.st.PrFigPerLine
    else Result := view.st.PrFigPerLine
end;

// Available column to display the nFigInGame-th figure

function ColFree(view : TView) : integer;
begin
  if view.st.PrFirstFigAlone
    then
      if nFigInGame = 1
        then Result := 0
        else Result := (nFigInGame - 2) mod view.st.PrFigPerLine
    else
      if view.st.PrInclInfos = inTop
        then Result := (nFigInGame - 1) mod view.st.PrFigPerLine
        else Result := (nFigures   - 1) mod view.st.PrFigPerLine
end;

// Number of columns used after displaying nFigInGame-th figure
//
// 0    1    2    3
//           free      : if 2 are used
//                     : ... there will be 3

function ColNum(view : TView) : integer;
begin
  Result := ColFree(view) + 1
end;

// Is first figure in line?

function FirstFigIsInLine(view : TView) : boolean;
// not used
var
  prFigPerLine : integer;
begin
  prFigPerLine := ColPerLine(view);
  Result := (    view.st.PrFirstFigAlone and (nFigInGame <= 1           )) or
            (not view.st.PrFirstFigAlone and (nFigInGame <= prFigPerLine))
end;

// -- Forward ----------------------------------------------------------------

procedure FlushFigureData(exporter : TExporter; view : TView; force : boolean = False); forward;

// -- Handling of delayed data -----------------------------------------------

procedure ResetDelayData(exporter : TExporter; n : integer);
var
  i : integer;
begin
  for i := 0 to n - 1 do
    begin
      DelayStrings[i] := ''
    end;
  exporter.ResetDelayImages(n)
end;

procedure SetLengthDelayData(exporter : TExporter; n : integer);
begin
  SetLength(DelayStrings, n);
  ResetDelayData(exporter, n)
end;

procedure AddDelayString(fig : integer; const s : string);
begin
  if DelayStrings[fig] = ''
    then DelayStrings[fig] := s
    else DelayStrings[fig] := DelayStrings[fig] + #13#10 + s
end;

// ---------------------------------------------------------------------------
// -- Headers and footers ----------------------------------------------------
// ---------------------------------------------------------------------------

procedure Parse(s : string; var tokens : TWideStringList);
var
  l, i, k : integer;
  sep : char;
begin
  tokens := TWideStringList.Create;
  s := s + ' ';
  l := Length(s);
  i := 1;
  while i < l do
    begin
      while (i <= l) and not (s[i] in ['\', '''', '"']) do
        inc(i);
      if i > l
        then exit;
      k := i;
      if s[i] = '\'
        then sep := ' '
        else sep := s[i];
      i := PosEx(sep, s, k + 1);
      if i = 0
        then exit;
      tokens.Add(Copy(s, k, i - k));
      inc(i)
    end
end;

function AddItem(view : TView; var s : UTF8String; const item : string) : boolean;
var
  theName : WideString;
  s2 : string;
begin
  with view do
    if si.FolderName = ''
      then theName := si.FileName
      else theName := WideExcludeTrailingPathDelimiter(si.FolderName);

  Result := True;
  if item[1] in ['''', '"']
    then s := s + Copy(item, 2, Length(item) - 1)
  else if item = '\file'
    then s := s + theName
  else if item = '\name'
    then s := s + WideExtractFileName(theName)
  else if item = '\page'
    then s := s + '<<pagenumber>>'
  else if item = '\date'
    then
      begin
        DateTimeToString(s2, 'dd/mm/yyyy', Now);
        s := s + s2
      end
  else Result := False
end;

function ItemString(view : TView; tokens : TWideStringList; var i : integer) : UTF8String;
begin
  Result := '';
  inc(i);
  while (i <= tokens.Count - 1) and AddItem(view, Result, tokens[i]) do
    inc(i)
end;

procedure Apply(view : TView;
                tokens : TWideStringList;
                var sLeft, sCenter, sRight: UTF8String);
var
  l, i : integer;
begin
  l := tokens.Count;
  i := 0;
  if (i < l) and (tokens[i] = '\left'  )
    then sLeft   := ItemString(view, tokens, i);
  if (i < l) and (tokens[i] = '\center')
    then sCenter := ItemString(view, tokens, i);
  if (i < l) and (tokens[i] = '\right' )
    then sRight  := ItemString(view, tokens, i)
end;

procedure HeaderFooterFormat(view : TView;
                             const hfFormat : UTF8String;
                             var sLeft, sCenter, sRight : UTF8String);
var
  tokens : TWideStringList;
begin
  Parse(hfFormat, tokens);
  Apply(view, tokens, sLeft, sCenter, sRight);
  tokens.Free
end;

procedure SetupHeader(exporter : TExporter; view : TView);
var
  sLeft, sCenter, sRight : UTF8String;
begin
  if not view.st.PrPrintHeader then exit;

  HeaderFooterFormat(view, view.st.PrHeaderFormat, sLeft, sCenter, sRight);
  exporter.SetupHeader(sLeft, sCenter, sRight, True)
end;

procedure SetupFooter(exporter : TExporter; view : TView);
var
  sLeft, sCenter, sRight : UTF8String;
begin
  if not view.st.PrPrintFooter then exit;

  HeaderFooterFormat(view, view.st.PrFooterFormat, sLeft, sCenter, sRight);
  exporter.SetupFooter(sLeft, sCenter, sRight, True)
end;

// ---------------------------------------------------------------------------
// -- Printing of game information -------------------------------------------
// ---------------------------------------------------------------------------

// All strings from Drago, UTF8 encoded, or from SGF, CP encoded, are exported
// as UTF8.

// -- Parsing of token

procedure ParseInfoToken(const format : string; var i : integer; gt : TGameTree;
                         out pn, xn, pv : string);
var
  pr : TPropId;
begin
  pn := Copy(format, i + 1, 2);
  pr := FindPropIndex(pn);
  xn := FindPropText(pn);
  pv := pv2str(gt.GetProp(pr));
  if pr = prRE
    then pv := UTF8Encode(ResultToString(pv));
  if xn = ''
    then inc(i)
    else inc(i, 3)
end;

// -- Parsing of format for information at top

procedure ParseGameInfosTop(exporter : TExporter; view : TView;
                            format : string);
var
  i, n, k : integer;
  pn, xn, pv : string;
  buffer : TStringDynArray;
begin
  SetLength(buffer, 4);
  for k := 0 to 3 do
    buffer[k] := '';

  format := format + ' ';
  n := 0;
  i := 1;

  repeat
    i := PosEx('\', format, i);
    if i = 0
      then break;
    ParseInfoToken(format, i, view.gt.Root, pn, xn, pv);
    buffer[n + 0] := UTF8Encode(U(xn));
    if pn = 'RE'
      then buffer[n + 1] := pv
      else buffer[n + 1] := UTF8Encode(MainDecode(pv));
    inc(n, 2);
    if n = 4 then
      begin
        exporter.WriteTextAcrossCols(buffer, view.si.GameEncoding);
        for k := 0 to 3 do
          buffer[k] := '';
        n := 0
      end
  until False;
  if n = 2
    then exporter.WriteTextAcrossCols(buffer, view.si.GameEncoding)
end;

// -- Printing of format for information at top

procedure PreviewGameInfosTop(exporter : TExporter; view : TView);
var
  n : integer;
begin
  if view.st.PrInclInfos <> inTop
    then exit;

  with exporter do
    begin
(*
      BeginGroup;
*)
      n := (PaperSize.cx - PageMargins.Left - PageMargins.Right) div 6;
      ClearColumns;
      AddColumn(0 * n + 0, 1 * n, ecaLeft, utf8);//CurrentCodePage);
      AddColumn(1 * n + 2, 3 * n, ecaLeft, view.si.GameEncoding);
      AddColumn(3 * n + 2, 4 * n, ecaLeft, utf8);//CurrentCodePage);
      AddColumn(4 * n + 2, 6 * n, ecaLeft, view.si.GameEncoding);
      FontStyle([]);
      ParseGameInfosTop(exporter, view, view.st.PrInfosTopFmt);
      DrawLine(False);
      //NewLine
    end
end;

// -- Parsing of format for information in figure name
//
// The strings displayed under the figure will use the CurrentCodePage, see
// SetupFigureColumns. This is natural as the strings are defined in the
// same language as the UI. However to print the game information, it is
// necessary to switch to the current game encoding. This is requested
// only for libharu for which the change of code page must be explicit.
//
// To do that, the substrings to be converted to the current game encoding are
// decorated with characters #$1F. These delimiters are used only in
// TExporter.WriteTextAcrossCols and cleaned in other TExporterXXX.WriteTextAcrossCols

function ParseGameInfosName(gt : TGameTree; const format : string; si : TInstStatus) : string;
var
  i : integer;
  pn, xn, pv : string;
begin
  Result := format;
  i := 1;
  repeat
    i := PosEx('\', format, i);
    if i = 0
      then break;
    ParseInfoToken(format, i, gt, pn, xn, pv);
    if xn <> '' then
      begin
        if pn = 'RE'
          then pv := pv // already UTF8
          //else pv := UTF8Encode(MainDecode(pv));
          else pv := UTF8Encode(CPDecode(pv, si.GameEncoding));
        pv := GameInfoDelimiter + pv + GameInfoDelimiter;
        Result := StringReplace(Result, '\' + pn, pv, [rfReplaceAll])
      end
  until False
end;

// -- Printing of format for information in figure name

procedure PreviewGameInfosName(view : TView);
begin
  if (view.st.PrInclInfos <> inName) or (nFigInGame > 1)
    then exit;

  AddDelayString(ColFree(view),
                 ParseGameInfosName(view.gt.Root, view.st.PrInfosNameFmt, view.si))
end;

// ---------------------------------------------------------------------------
// -- Printing of figures ----------------------------------------------------
// ---------------------------------------------------------------------------

procedure PreviewDiagram(exporter : TExporter;
                         view : TView;
                         mmWidth : integer);
var
  pxSize   : integer;
  mmHeight : integer;
  textCanvas : TStringList;
  exportedImage : TExportedImage;
begin
  if exporter.FExportMode = emNFig
    then exit;

  case exporter.fExportFigure of
    eiWMF :
      begin
        pxSize := round(mmWidth * exporter.PrinterPxPerInchX / 25.4);
        exportedImage := exporter.FImageExporter.ExportImage(view.gb,
                                                            pxSize, pxSize,
                                                            exporter.PrinterPxPerInchX);
        exporter.AddDelayImage(ColFree(view), exportedImage)
      end;
    eiPDF :
      begin
        if view.st.PdfExactWidthMm > 0 then
          begin
            // force dim to large value to avoid rounding errors
            mmWidth := 200
          end;

        pxSize := round(mmWidth * 72 / 25.4);

        exportedImage := exporter.FImageExporter.ExportImage(view.gb, pxSize, pxSize, 72);
        exporter.AddDelayImage(ColFree(view), exportedImage)
      end;
    eiTRC, eiSSL, eiRGG :
      begin
        exportedImage := exporter.FImageExporter.ExportImage(view.gb, 0, 0, 0);
        exporter.AddDelayImage(ColFree(view), exportedImage)
      end;
    else
      begin
        if exporter.FExportMode <> emExportPDF
          then pxSize := round(mmWidth * DefaultPixelsPerInch / 25.4)
          else pxSize := exporter.MmToPrinterPxX(mmWidth);

        exportedImage := exporter.FImageExporter.ExportImage(view.gb, pxSize, pxSize, 0);
        exporter.AddDelayImage(ColFree(view), exportedImage)
      end
  end
end;

// -- Handling of figure caption ---------------------------------------------

function NumberingToString(view : TView) : string;
var
  i : integer;
begin
  if not view.st.PrRelNum
    then
      if Pos('\game', view.st.PrFmtMainTitle) = 0
        then Result := IntToStr(nFigures)
        else Result := IntToStr(nFigInGame)
    else
      begin
        Result := IntToStr(Numbering.Items[0]);
        for i := 1 to High(Numbering.Items) do
          Result := Result + '.' + IntToStr(Numbering.Items[i])
      end
end;

function MovesToString(gb : TGoban) : string;
var
  minFG, maxFG : integer;
begin
  with gb do
    begin
      UpdateMovesFG(minFG, maxFG);
      if minFG > maxFG
        then Result := '-' // no moves in figure
        else Result := IntToStr(NumWithOffset(minFG)) + '-' +
                       IntToStr(NumWithOffset(maxFG))
    end
end;

function PlayerToString(gt : TGameTree) : string;
var
  s : WideString;
begin
  case NextPlayer(gt) of
    Black : s := U('Black');
    White : s := U('White');
    else    s := ''
  end;

  Result := UTF8Encode(s)
end;

function TitleString(view : TView) : string;
var
  format : string;
begin
  if Numbering.Count <= 1
    then format := view.st.PrFmtMainTitle
    else format := view.st.PrFmtVarTitle;

  // replace format tags
  Result := AnsiReplaceText(format, '\game'  , IntToStr(CurrentGame));
  Result := AnsiReplaceText(Result, '\figure', NumberingToString(view));
  Result := AnsiReplaceText(Result, '\moves' , MovesToString(view.gb));
  Result := AnsiReplaceText(Result, '\player', PlayerToString(view.gt))
end;

procedure PreviewFigTitle(view : TView);
begin
  if view.st.PrInclTitle
    then AddDelayString(ColFree(view), TitleString(view))
end;

// -- Display of over moves --------------------------------------------------

procedure PreviewOverMoves(view : TView);
var
  s : string;
begin
  s := view.gb.OverMoveString;
  if s <> ''
    then AddDelayString(ColFree(view), s)
end;

// -- Display of comments ----------------------------------------------------

procedure PreviewComments(view : TView);
begin
  if not view.st.PrInclComm
    then exit;

  if (view.st.PrFigPerLine > 1) and (view.sa.AccumComment.Count > 0)
    then DelayAccumComment.Add('F    ' + TitleString(view));

  DelayAccumComment.AddStrings(view.sa.AccumComment)
end;

// -- Setting for figure columns ---------------------------------------------

procedure SetupFigureColumns(exporter : TExporter; view : TView; nFig : integer);
var
  prFigPerLine, prFigRatio, w1, w2, i : integer;
begin
  case nFig of
    0 :
      if view.st.PrFirstFigAlone
        then
          begin
            prFigPerLine := 1;
            prFigRatio   := view.st.PrFirstFigRatio
          end
        else
          begin
            prFigPerLine := view.st.PrFigPerLine;
            prFigRatio   := view.st.PrFigRatio
          end;
    1 :
      begin
        if view.st.PrFirstFigAlone then
          begin
            prFigPerLine := view.st.PrFigPerLine;
            prFigRatio   := view.st.PrFigRatio
          end
        else exit
      end
    else exit
  end;

  with exporter do
    begin
      w1 := PaperSize.cx - (PageMargins.Left + PageMargins.Right);
      widthDiag := (w1 - (prFigPerLine - 1) * interDiag) div prFigPerLine;
      widthDiag := Round((1.0 * widthDiag * prFigRatio) / 100);
      w2 := prFigPerLine * (widthDiag + interDiag) - interDiag;
      leftDiag  := PageMargins.Left + (w1 - w2) div 2;

      ClearColumns;
      if prFigPerLine = 1
        then AddColumn(0, PaperSize.cx - PageMargins.Left - PageMargins.Right,
                       ecaCenter, utf8)//CurrentCodePage)
        else
          for i := 0 to prFigPerLine - 1 do
            AddColumn(leftDiag - PageMargins.Left + i * (widthDiag + interDiag),
                      leftDiag - PageMargins.Left + i * (widthDiag + interDiag) + widthDiag,
                      ecaCenter, utf8)//CurrentCodePage)
    end
end;

// -- Flush of a row of figures ----------------------------------------------

procedure FlushComments(exporter : TExporter; view : TView);
var
  i : integer;
  s, col, move, comm : string;
begin
  with exporter do
    begin
      TextAlign(etaJustified);

      for i := 0 to DelayAccumComment.Count - 1 do
        begin
          s := DelayAccumComment[i];

          // extract tag, move number and comment
          // tag 'F' is added in PreviewComments
          // tags 'N', 'B' and 'W' are added in ApplyC
          col := s[1];
          move := Trim(Copy(s, 2, 4));
          comm := Copy(s, 6, MaxInt);

          case col[1] of
            'F' : if view.st.PrInclTitle
                    then s := ''
                    else continue;
            'N' : s := '';
            'B' : if not view.st.PrRemindMoves
                    then s := ''
                    else s := UTF8Encode(U('Black')) + ' ' + move + ': ';
            'W' : if not view.st.PrRemindMoves
                    then s := ''
                    else s := UTF8Encode(U('White')) + ' ' + move + ': '
          end;

          if (col[1] = 'F') and (not view.st.PrRemindTitle)
            then continue;
          if col[1] = 'F'
            then NewLine(0.45);
          if col[1] = 'F'
            then FontStyle([efsItalic])
            else FontStyle([]);
          Encoding(utf8);
          WriteText(s);
          if col[1] = 'F'
            then Encoding(utf8)
            else Encoding(view.si.GameEncoding);
          WriteText(comm);
          if col[1] = 'F'
            then NewLine(0.45)
        end;
      if DelayAccumComment.Count > 0
        then NewLine
    end
end;

// -- Flush figures, figure titles and comments

procedure FlushFigureData(exporter : TExporter;
                          view : TView;
                          force : boolean = False);
var
  prFigPerLine, nFig : integer;
begin
  if nFigures = 0
    then exit;
  prFigPerLine := ColPerLine(view);   // Max number of figures in line
  nFig         := ColNum(view);       // Number of figures in line
  if nFig = 0
    then exit;

  case force of
    False : // Flush if line is complete
      if nFig <> prFigPerLine
        then exit;
    True  : // Flush if line is not complete(otherwise it is already done)
      if nFig = prFigPerLine
        then exit
  end;

  exporter.FontStyle([]);
  exporter.FlushColsInPage(Copy(DelayStrings, 0, nFig), nFig, view.si.GameEncoding);
  FlushComments(exporter, view);

  ResetDelayData(exporter, view.st.PrFigPerLine);
  DelayAccumComment.Clear
end;

// -- Display of figures -----------------------------------------------------

procedure PreviewFigure(exporter : TExporter; view : TView);
var
  pv, name : string;
  n : integer;
  coordOn, nameOn : boolean;
begin
  if exporter.FExportMode = emNFig then
    begin
      inc(exporter.nFigures);
      exit
    end;

  if Assigned(PrintStepOnFigure) and (not PrintStepOnFigure)
    then exit;

  SetupFigureColumns(exporter, view, nFigInGame);

  Numbering.Inc;
  inc(nFigInGame);
  inc(nFigures);
  if Numbering.Count = 1
    then inc(nMainFigures);

  nameOn := False;

  if view.st.PrFigures = fgPropFG then
    begin
      if view.si.StackFG.Count = 0
        then pv := '[]'
        else pv := view.si.StackFG.Peek;

      if pv = '[]'
        then // Nop : FG[]
        else
          begin
            pv2ns(pv, n, name);
            coordOn := n mod 2 = 1;
            nameOn  := (n shr 1) mod 2 = 1;

            if coordOn
              then view.gb.BoardView.CoordStyle := tcKorsch
              else view.gb.BoardView.CoordStyle := tcNone
          end
    end;

  PreviewDiagram(exporter, view, widthDiag);
  PreviewFigTitle(view);
  if nameOn
    //then AddDelayString((nFigures - 1) mod view.st.PrFigPerLine, name)
    then AddDelayString((nFigInGame - 1) mod view.st.PrFigPerLine, name)
    else PreviewGameInfosName(view);
  PreviewOverMoves(view);
  PreviewComments(view);
  FlushFigureData(exporter, view)
end;

// -- Printing of game -------------------------------------------------------

procedure DoPreviewGame1(exporter : TExporter;
                         view : TView;
                         first, last : integer); forward;
procedure DoPreviewGame2(exporter : TExporter;
                         view : TView;
                         gtFirst, gtLast : TGameTree); forward;
procedure DoPreviewGame3(exporter : TExporter;
                         view : TView); forward;

procedure OutputFigureFromProperty(exporter : TExporter;
                                   view : TView;
                                   gtFirst, gtLast : TGameTree;
                                   var lastNode : TGameTree); forward;

procedure OutputFigureFromSettings(exporter : TExporter;
                                   view : TView;
                                   gtFirst, gtLast : TGameTree;
                                   var lastNode : TGameTree); forward;

// -- Printing of games ------------------------------------------------------

procedure DoPreviewGame(exporter : TExporter;
                        view : TView;
                        lastMove : integer = MaxMoveNumber);
begin
  if (view.st.PrInclInfos = inTop) or (view.st.PrFirstFigAlone)
    then FlushFigureData(exporter, view, True);

  if (CurrentGame > 1) and (view.st.PrInclInfos = inTop)
    then exporter.AddPage;

  PreviewGameInfosTop(exporter, view);
  nFigInGame := 0;
  view.si.StackFG.Clear;
  view.ApplyQuiet(True);
  view.StartEvent(sePrint, snExtend);

  view.gb.PushFG;
  if view.st.PrInclStartPos then
    begin
      PreviewFigure(exporter, view);
      view.gb.PushFG;
      Status.AccumComment.Clear
    end;

  DoPreviewGame1(exporter, view, 0, lastMove);
  view.ApplyQuiet(False)
end;

procedure DoPreviewGame1(exporter : TExporter;
                         view : TView;
                         first, last : integer);
var
  gtFirst, gtLast, lastNode : TGameTree;
  n : integer;
begin
  n := first;
  repeat
    inc(n, view.st.PrStep);
    gtFirst := view.gt;

    case view.st.PrFigures of
      fgNone    : begin
                    //exporter.NewLine; // fix a bug if no infos
                                        // (yes but which bug?)
                                        // removed because it adds one
                                        // empty line for each event
                exit
              end;
      fgLast    : view.GotoMove(last, kLastQuiet);
      fgInter   : if view.st.PrPos = 0
                    then // nop, GotoMove doesn't use snMode
                    else view.GotoMove(last, kLastQuiet);
      //fgPropFG  : GotoNextFG(view);
      fgPropFG  : MoveToEndOfFigure(view);
      fgMarkCom : GoToNextMarkupOrComment(view);
      fgStep    : view.GotoMove(n, kLastQuiet);
    end;

    gtLast := view.gt;

    if view.st.PrFigures = fgPropFG
      then OutputFigureFromProperty(exporter, view, gtFirst, gtLast, lastNode)
      else OutputFigureFromSettings(exporter, view, gtFirst, gtLast, lastNode);

    if view.st.PrFigures in [fgLast, fgInter]
      then exit
  until view.gt = nil;

  view.gt := lastNode
end;

// view.st.PrFigures <> fgPropFG

procedure OutputFigureFromSettings(exporter : TExporter;
                                   view : TView;
                                   gtFirst, gtLast : TGameTree;
                                   var lastNode : TGameTree);
begin
  PreviewFigure(exporter, view);

  if view.st.PrInclVar
    then DoPreviewGame2(exporter, view, gtFirst, gtLast);

  if view.st.PrFigures in [fgLast, fgInter]
    then exit;

  Status.AccumComment.Clear;
  lastNode := view.gt;

  view.MoveForward;
  view.gb.PushFG
end;

// view.st.PrFigures = fgPropFG

procedure OutputFigureFromProperty(exporter : TExporter;
                                   view : TView;
                                   gtFirst, gtLast : TGameTree;
                                   var lastNode : TGameTree);
begin
  PreviewFigure(exporter, view);

  if view.st.PrInclVar
    then DoPreviewGame2(exporter, view, gtFirst, gtLast);

  Status.AccumComment.Clear;
  lastNode := view.gt;

  //view.gb.StartFigure;
  view.MoveForward
end;

procedure DoPreviewGame2(exporter : TExporter;
                         view : TView;
                         gtFirst, gtLast : TGameTree);
begin
  while view.gt <> gtFirst do
    view.MoveBackward;

  if view.gt.PrevVar <> nil
    then
      // end of moving backward in a variation
      if (view.gt.NextNode = nil) or (gtFirst = gtLast)
        then exit
        else view.MoveForward;

  Numbering.Push(0);
  while True do
    begin
      if view.gt.NextVar <> nil
        then DoPreviewGame3(exporter, view);
      if view.gt = gtLast
        then break;
      view.MoveForward
    end;
  Numbering.Pop
end;

procedure DoPreviewGame3(exporter : TExporter; view : TView);
var
  gtFirst : TGameTree;
begin
  while view.gt.NextVar <> nil do
    begin
      if view.st.NumberVarFromRoot
        then //nop
        else view.gb.PushFG;
        
      Status.AccumComment.Clear;

      DoNextVariation(view);
      gtFirst := view.gt;
      DoPreviewGame1(exporter, view, view.gb.MoveNumber - 1, MaxMoveNumber);

      while view.gt <> gtFirst do
        view.MoveBackward
    end;

  while view.gt.PrevVar <> nil do
    DoPrevVariation(view)
end;

// -- Entry point

procedure PreviewGame(exporter : TExporter; view : TView);
begin
  //nFigInGame := 0;
  Numbering  := TIntStack.Create;
  if Pos('\game', view.st.PrFmtMainTitle) = 0
    then Numbering.Push(nMainFigures)
    else Numbering.Push(0);

  view.si.ApplyQuiet := False;
  Status.IgnoreFG   := view.st.PrFigures <> fgPropFG;

  case view.st.PrFigures of
    fgNone    : DoPreviewGame(exporter, view, 0);
    fgLast    : DoPreviewGame(exporter, view, MaxMoveNumber);
    fgInter   : DoPreviewGame(exporter, view, view.st.PrPos);
    fgPropFG  : DoPreviewGame(exporter, view);
    fgStep    : DoPreviewGame(exporter, view);
    fgMarkCom : DoPreviewGame(exporter, view)
  end;

  //if (view.st.PrInclInfos = inTop) and (nFigures = 0)
  //if (view.st.PrInclInfos = inTop) and (nFigInGame = 0)
  //  then exporter.EndGroup;

  Numbering.Free
end;

// -- Printing of several games ----------------------------------------------

// -- Loop on games

procedure PreviewGamesFromTo(exporter : TExporter;
                             view : TView;
                             iFrom, iTo : integer);
var
  i : integer;
begin
  for i := iFrom to iTo do
    begin
      CurrentGame := i;
      view.gt := view.cl[i];
      PreviewGame(exporter, view);

      if Assigned(PrintStepOnGame) and (not PrintStepOnGame)
        then exit;
    end
end;

// -- Entry point

procedure PreviewGames(exporter : TExporter; view : TView);
begin
  case view.st.PrGames of
    pgCurrent : begin
                  CurrentGame := 1;
                  PreviewGame(exporter, view)
                end;
    pgAll     : PreviewGamesFromTo(exporter, view, 1, view.cl.Count);
    pgFromTo  : PreviewGamesFromTo(exporter, view, view.st.PrFrom, view.st.PrTo);
  end;

  if Assigned(PrintStepFinished) and (not PrintStepFinished)
    then exit;

  FlushFigureData(exporter, view, True)
end;

// -- Layout settings --------------------------------------------------------

procedure SetupPageLayout(exporter : TExporter; view : TView);
begin
  nFigures     := 0;
  nFigInGame   := 0;
  nMainFigures := 0;
  SetLengthDelayData(exporter, view.st.PrFigPerLine)
end;

// -- Preview ----------------------------------------------------------------

procedure PerformExport(exporter : TExporter; view : TView; var ok : boolean);
begin
  exporter.FontName(view.st.PrFontName); // only one time before BeginDoc
  exporter.FontSize(view.st.PrFontSize); // for RTF

  if exporter.FExportMode = emExportPDF then
    begin
      exporter.SetPageMargins(NthInt(view.st.PrMargins, 1, ','),
                              NthInt(view.st.PrMargins, 3, ','),
                              NthInt(view.st.PrMargins, 2, ','),
                              NthInt(view.st.PrMargins, 4, ','));
      SetupHeader(exporter, view);
      SetupFooter(exporter, view)
    end;

  exporter.BeginDoc(ok);
  if not ok
    then exit;

  if not (exporter.FExportMode = emExportPDF) then
    begin
      exporter.SetPageMargins(NthInt(view.st.PrMargins, 1, ','),
                              NthInt(view.st.PrMargins, 3, ','),
                              NthInt(view.st.PrMargins, 2, ','),
                              NthInt(view.st.PrMargins, 4, ','));
      SetupHeader(exporter, view);
      SetupFooter(exporter, view);
    end;

  SetupPageLayout(exporter, view);
  PreviewGames(exporter, view);
  exporter.EndDoc
end;

function ExportFilename(view        : TView;
                        aExportMode : TExportMode;
                        filename    : WideString) : WideString;
begin
  case aExportMode of
    emNFig       : Result := '';
    emPrint      : Result := '';
    emPreviewRTF : Result := '';
    emPreviewPDF : Result := view.sa.TmpPath + '\tmp.pdf';
    emPreviewDOC : Result := view.sa.TmpPath + '\tmp.doc';
    emPreviewHTM : Result := view.sa.TmpPath + '\tmp.htm';
    emPreviewTXT : Result := view.sa.TmpPath + '\tmp.txt';
    else
      // use name given as argument
      Result := filename
  end
end;

function PerformPreview(aView : TView;
                        var ok : boolean;
                        exporter : TExporter;
                        aExportMode   : TExportMode;
                        aExportFigure : TExportFigure;
                        aShowMoveMode : TShowMoveMode = smBook) : integer;
var
  view : TView;
  exactWidthBak : integer;
  addedBorderBak : string;
  filename : WideString;
begin
  Status.Exporting := True;
  Result := 0;

  view := TView.Create;
  view.Context := TContext.Create;
  view.cl.Free;
  view.si.Free;
  view.cl := aView.cl;
  view.gt := aView.gt;
  view.si := aView.si;
  view.si.ShowVar := False;

  view.gb := TGoban.Create;
  view.gb.BoardSettings(view.st.ShowHoshis,
                        view.st.CoordStyle,
                        view.st.NumOfMoveDigits,
                        trIdent,
                        aShowMoveMode,
                        view.st.NumberOfVisibleMoveNumbers);

  // avoid some advanced PDF settings for full game export
  exactWidthBak  := view.st.PdfExactWidthMm;
  addedBorderBak := view.st.PdfAddedBorder;
  view.st.PdfExactWidthMm := 0;
  view.st.PdfAddedBorder  := '0;0;0;0';

  filename := ExportFilename(aView, aExportMode, filename);

  try
    PerformExport(exporter, view, ok);
    if not ok then
      begin
        view.MessageDialog(msOk, imExclam,
                      [U('Impossible to write file') + ' ' + filename]);
        exit
      end;

    if Assigned(PrintStepFinished)
      then ok := PrintStepFinished;

    // set result (with number of figures in case of TExporterNFG)
    Result := exporter.Result;

  finally
    Status.Exporting := False;
    view.cl := nil; // protect data from fmMain.ActiveView before freeing
    view.gt := nil;
    view.si := nil;
    view.cx.Free;
    view.Free;

    // restore initial state, GoToNode to restore figure stack
    aView.si.ShowVar := True;
    aView.GoToNode(aView.gt);

    // restore advanced pdf settings
    view.st.PdfExactWidthMm := exactWidthBak;
    view.st.PdfAddedBorder  := addedBorderBak;
  end
end;

// ---------------------------------------------------------------------------

begin
  DelayAccumComment := TStringList.Create
end.

