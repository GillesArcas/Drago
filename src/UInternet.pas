unit UInternet;

interface

function DownloadInString (const url: string; var dest : string) : boolean;

implementation

uses
  Types, ExtActns, WinInet;

// http://delphi.about.com/od/networking/a/html_scraping.htm
function Download_HTM(const sURL, sLocalFileName : string): boolean;
begin
  Result := True;
  with TDownloadURL.Create(nil) do
  try
    URL:=sURL;
    Filename:=sLocalFileName;
    try
      ExecuteTarget(nil) ;
    except
      Result:=False
    end;
  finally
    Free;
  end;
end;

function DownloadFile(const url: string;
                      const destinationFileName: string): boolean;
var
  hInet: HINTERNET;
  hFile: HINTERNET;
  localFile: File;
  buffer: array[1..1024] of byte;
  bytesRead: DWORD;
begin
  result := False;
  hInet := InternetOpen(PChar('Drago experimental'),
    INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  hFile := InternetOpenURL(hInet,PChar(url),nil,0,0,0);
  if Assigned(hFile) then
  begin
    AssignFile(localFile,destinationFileName);
    Rewrite(localFile,1);
    repeat
      InternetReadFile(hFile,@buffer,SizeOf(buffer),bytesRead);
      BlockWrite(localFile,buffer,bytesRead);
    until bytesRead = 0;
    CloseFile(localFile);
    result := true;
    InternetCloseHandle(hFile);
  end;
  InternetCloseHandle(hInet);
end;

function DownloadInString (const url: string; var dest : string) : boolean;
var
  hInet: HINTERNET;
  hFile: HINTERNET;
  buffer: array [1 .. 1024] of byte;
  bytesRead: DWORD;
begin
  Result := False;
  dest := '';
  hInet := InternetOpen(PChar('Drago experimental'),
                        INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  hFile := InternetOpenURL(hInet, PChar(url), nil, 0, 0, 0);
  if Assigned(hFile) then
    begin
      repeat
        InternetReadFile(hFile, @buffer, SizeOf(buffer) - 1, bytesRead);
        buffer[bytesRead + 1] := 0;
        dest := dest + PChar(@buffer)
      until bytesRead = 0;
      Result := true;
      InternetCloseHandle(hFile);
    end;
  InternetCloseHandle(hInet);
end;

end.
 