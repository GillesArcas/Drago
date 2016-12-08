unit UfmTesting;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ExtCtrls, IniFiles;

type
  TfmTesting = class(TForm)
    lbTests: TCheckListBox;
    mmTests: TMemo;
    btStart: TButton;
    rgAction: TRadioGroup;
    btClear: TButton;
    cxAll: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure lbTestsClickCheck(Sender: TObject);
    procedure cxAllClick(Sender: TObject);
  private
    TestList : TMemIniFile;
    BatchFolder : string;
    ReferenceFolder : string;
    OutputFolder : string;
    procedure DoAllTests;
    procedure DoOneTest(name, batch, reference, result : string; var ok : boolean);
  public
    class procedure Execute;
  end;

var
  fmTesting: TfmTesting;

implementation

{$R *.dfm}

uses
  Std, UBatch;

class procedure TfmTesting.Execute;
begin
  with TfmTesting.Create(Application) do
    try
      TestList := TMemIniFile.Create(TestingDirectory() + 'Testing.ini');
      ShowModal
    finally
      TestList.Free;
      Release
    end
end;

procedure TfmTesting.FormCreate(Sender: TObject);
begin
  fmTesting := self
end;

procedure TfmTesting.FormShow(Sender: TObject);
begin
  rgAction.ItemIndex := 1; // compare with reference
  mmTests.Clear;

  // read folder names
  BatchFolder     := TestingDirectory() + TestList.ReadString('Folders', 'BatchFolder', '');
  ReferenceFolder := TestingDirectory() + TestList.ReadString('Folders', 'ReferenceFolder', '');
  OutputFolder    := TestingDirectory() + TestList.ReadString('Folders', 'OutputFolder', '');
  BatchFolder     := IncludeTrailingPathDelimiter(BatchFolder);
  ReferenceFolder := IncludeTrailingPathDelimiter(ReferenceFolder);
  OutputFolder    := IncludeTrailingPathDelimiter(OutputFolder);

  // read all sections for test descriptions and remove folder section at pos 0
  TestList.ReadSections(lbTests.Items);
  lbTests.Items.Delete(0)
end;

procedure TfmTesting.btClearClick(Sender: TObject);
begin
  mmTests.Clear
end;

procedure TfmTesting.btStartClick(Sender: TObject);
begin
  DoAllTests
end;

procedure TfmTesting.DoAllTests;
var
  i : integer;
  testdescr, filename, batch, reference, result : string;
  okAll, ok : boolean;
begin
  okAll := True;

  for i := 0 to lbTests.Items.Count - 1 do
    if lbTests.Checked[i] then
      begin
        testdescr := lbTests.Items[i];
        filename  := TestList.ReadString(testdescr, 'Filename', '');
        batch     := BatchFolder + filename + '.batch';
        reference := ReferenceFolder + filename + '.ref';
        result    := OutputFolder + filename + '.out';

        DoOneTest(testdescr, batch, reference, result, ok);
        okAll := okAll and ok
      end;

    if okAll
      then mmTests.Lines.Add('Global result   : OK')
      else mmTests.Lines.Add('Global result   : Failed')
end;

procedure LogErrors(const s : string);
begin
  fmTesting.mmTests.Lines.Add(s)
end;

procedure TfmTesting.DoOneTest(name, batch, reference, result : string; var ok : boolean);
var
  sRef, sRes : string;
  timing : int64;
begin
  mmTests.Lines.Add(Format('Starting test   : %-20s ...', [name]));

  case rgAction.ItemIndex of
    0 :
      begin
        ApplyBatch(batch, reference, '', LogErrors, timing);
        mmTests.Lines.Add(Format('Timing for test : %-20s : %d', [name, timing]));
        ok := True
      end;

    1 :
      begin
        ApplyBatch(batch, '', result, LogErrors, timing);
        mmTests.Lines.Add(Format('Timing for test : %-20s : %d', [name, timing]));

        sRef := FileToString(reference);
        sRes := FileToString(result);

        if sRef = sRes
          then mmTests.Lines.Add(Format('Result for test : %-20s : OK', [name]))
          else mmTests.Lines.Add(Format('Result for test : %-20s : Failed', [name]));
        ok := (sRef = sRes)
      end;
  end;
end;

procedure TfmTesting.cxAllClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to lbTests.Items.Count - 1 do
    lbTests.Checked[i] := cxAll.Checked
end;

procedure TfmTesting.lbTestsClickCheck(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to lbTests.Items.Count - 1 do
    if lbTests.Checked[i] = False then
      begin
        cxAll.OnClick := nil;
        cxAll.Checked := False;
        cxAll.OnClick := cxAllClick;
        exit
      end;

  cxAll.Checked := True
end;

end.
