unit UfmDgs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls;

type
  TfmDgs = class(TForm)
    StringGrid1: TStringGrid;
    Memo1: TMemo;
    btConnect: TButton;
    btStatus: TButton;
    procedure btConnectClick(Sender: TObject);
    procedure btStatusClick(Sender: TObject);
  private
    procedure SendRequestEcho (const request : string;
                               var answer : string;
                               var status : boolean);
  public
    class function Execute : boolean;
  end;

var
  fmDgs: TfmDgs;

implementation

{$R *.dfm}

uses
  Types,
  Std, UInternet;

class function TfmDgs.Execute : boolean;
begin
  with TfmDgs.Create (Application) do
    try
      Result := ShowModal <> mrCancel
    finally
      Release
    end
end;

procedure TfmDgs.SendRequestEcho (const request : string;
                                  var answer : string;
                                  var status : boolean);
begin
  Memo1.Lines.Add(request);
  status := DownloadInString (request, answer);
  Memo1.Lines.Add(answer);
end;

procedure TfmDgs.btConnectClick(Sender: TObject);
var
  dest : string;
  status : boolean;
begin
  SendRequestEcho ('http://www.dragongoserver.net/login.php?quick_mode=1&userid=fightingstones&passwd=aqqwx123',
                   dest, status)
end;

procedure TfmDgs.btStatusClick(Sender: TObject);
var
  dest : string;
  status : boolean;
  list : TStringList;
  i, j : integer;
  A : TStringDynArray;
begin
  //Download_HTM('http://www.dragongoserver.net/sgf.php?gid=605759&owned_comments=1&quick_mode=1',
  //             'd:\Gilles\volatil\tmp.sgf');

  SendRequestEcho ('http://www.dragongoserver.net/quick_status.php',
                   dest, status);
  list := TStringList.Create;
  list.Text := dest;
  for i := 0 to list.Count - 1 do
    begin
      Memo1.Lines.Add(list[i]);
      //'G', 605759, 'jogie', 'B', '2010-11-02 21:23', 'C: 88d'
      //'G', 595442, 'Kyuuba', 'W', '2010-11-04 10:09', 'C: 73d 14h'
      Split (list[i], A, ',');
      if i > StringGrid1.RowCount - 1
        then StringGrid1.RowCount := StringGrid1.RowCount + 1;
      for j := 0 to Length(A) - 1 do
        StringGrid1.Cells [j, i] := A[j]
    end
end;

end.
