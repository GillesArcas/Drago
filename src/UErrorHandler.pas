// ---------------------------------------------------------------------------
// -- Drago -- Application error handler ---------------- UErrorHandler.pas --
// ---------------------------------------------------------------------------

unit UErrorHandler;

// ---------------------------------------------------------------------------

interface

uses
  Windows, Classes, SysUtils, Dialogs, Controls, Forms;

procedure ApplicationErrorHandler(Sender : TObject; E : Exception);

// ---------------------------------------------------------------------------

implementation

uses
  DefineUi;

(*
// -- Translation of some error messages from French Delphi ------------------

const ErrorMsg : array[1 .. 13, 1 .. 2] of string =
(
('Mémoire insuffisante'                     , 'Out of memory'),
('Fichier introuvable'                      , 'File not found'),
('Nom de fichier incorrect'                 , 'Invalid filename'),
('Trop de fichiers ouverts'                 , 'Too many open files'),
('Accès au fichier refusé'                  , 'File access denied'),
('Lecture au-delà de la fin de fichier'     , 'Read beyond end of file'),
('Disque plein'                             , 'Disk full'),
('Division par zéro'                        , 'Division by zero'),
('Erreur de vérification d''étendue'        , 'Range check error'),
('Débordement d''entier'                    , 'Integer overflow'),
('Opération en virgule flottante incorrecte', 'Invalid floating point operation'),
('Division par zéro en virgule flottante'   , 'Floating point division by zero'),
('Indice de liste hors limites'             , 'List index out of range')
);

function Translate(s : string) : string;
var
  i : integer;
begin
  for i := Low(ErrorMsg) to High(ErrorMsg) do
    if ErrorMsg[i, 1] = s then
      begin
        Result := ErrorMsg[i, 2];
        exit
      end;

  if Copy(s, 1, Length(ErrorMsg[13, 1])) = ErrorMsg[13, 1] then
    begin
      Result := ErrorMsg[13, 2] + Copy(s, Length(ErrorMsg[13, 1]) + 1, 100);
      exit
    end;

  Result := s

end;
*)
// ---------------------------------------------------------------------------

procedure LimitLogFile(nRecordsToKeep : integer);
var
  fname : string;
  lines : TStringList;
  i, nRecords, nRemove, n : integer;
begin
  fname := ChangeFileExt(ParamStr(0), '.log');

  // still no error record
  if not FileExists(fname)
    then exit;

  // read log file
  lines := TStringList.Create;
  lines.LoadFromFile(fname);

  // count the number of error records
  nRecords := 0;
  for i := 0 to lines.Count - 1 do
    if (Length(lines[i]) > 0) and (lines[i][1] = '-')
      then inc(nRecords);

  // number max of records not reached
  if nRecords <= nRecordsToKeep then
    begin
      lines.Free;
      exit
    end;

  // number of records to remove
  nRemove := nRecords - nRecordsToKeep;

  // find first record to keep
  n := 0;
  for i := 0 to lines.Count - 1 do
    begin
      if (Length(lines[i]) > 0) and (lines[i][1] = '-')
        then inc(n);
      if n = nRemove + 1
        then break
    end;

  // remove the i lines before first record to keep
  for i := 0 to i - 1 do
    lines.Delete(0);

  // save log file
  lines.SaveToFile(fname);
  lines.Free
end;

procedure Log(const s : string);
var
  fname : string;
  f : text;
begin
  fname := ChangeFileExt(ParamStr(0), '.log');
  assign(f, fname);
  if not FileExists(fname)
    then rewrite(f)
    else append(f);
  writeln(f, s);
  close(f)
end;

procedure ApplicationErrorHandler(Sender : TObject; E : Exception);
var
  s : string;
begin
  try
    MessageDlg('Application error :('
               + CRLF
               + CRLF + E.Message // Translate(E.Message)
               + CRLF
               + CRLF + 'Please report to ' + kEMail,
               mtCustom, [mbOk], 0);

    s := '-- ' + DateTimeToStr(Now)
               + CRLF + 'Version       = ' + AppVersion
               + CRLF + 'Exception     = ' + E.ClassName
               + CRLF + 'Message       = ' + E.Message // Translate(E.Message)
               + CRLF + 'Address       = $' + IntToHex(Integer(ExceptAddr), 8)
               + CRLF + 'ActiveForm    = ' + Screen.ActiveForm.Name
               + CRLF + 'ActiveControl = ' + Screen.ActiveControl.Name
               + CRLF + 'Code page     = ' + IntToStr(GetACP);

    Log(s)
  except
  end
end;

// ---------------------------------------------------------------------------

initialization
  LimitLogFile(10)
end.
