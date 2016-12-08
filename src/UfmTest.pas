unit UfmTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmTest = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure DoTest(timeOut : boolean = False);
  public
    class function Execute : boolean;
  end;

var
  fmTest: TfmTest;

implementation

{$R *.dfm}

uses
  Std, UGtp, DosCommand;

class function TfmTest.Execute : boolean;
begin
  with TfmTest.Create(Application) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure Trace(const s : string);
begin
  fmTest.Memo1.Lines.Add(s)
end;

procedure TfmTest.DoTest(timeOut : boolean = False);
var
  gtp : TGtp;
  fullname, arguments, s : string;
  ok : boolean;
  i : integer;
begin
  fullname := NthWord(Edit1.Text, 1);
  arguments := '';
  for i := 2 to MaxInt do
    begin
      s := NthWord(Edit1.Text, i);
      if s = ''
        then break;
      arguments := arguments + ' ' + s
    end;

  gtp := TGtp.Create(nil, Trace, nil, nil);
  gtp.DosCommand.OnTerminated := nil;
  if timeOut
    then gtp.DosCommand.MaxTimeAfterBeginning := 10; // 10s timeout

  Memo1.Lines.Add('Fullname:  ' + fullname);
  Memo1.Lines.Add('Arguments: ' + arguments);
  gtp.Start(fullname, arguments, ok);

  if ok
    then Memo1.Lines.Add('Engine started')
    else Memo1.Lines.Add('Engine unable to start');

  Sleep(2000);

  if gtp.Active
    then Memo1.Lines.Add('Engine running')
    else Memo1.Lines.Add('Engine stopped')
end;

procedure TfmTest.Button1Click(Sender: TObject);
begin
  DoTest(False)
end;

procedure TfmTest.Button2Click(Sender: TObject);
begin
  DoTest(True)
end;

procedure TfmTest.FormShow(Sender: TObject);
begin
  Edit1.Clear;
  Memo1.Clear
end;

end.
