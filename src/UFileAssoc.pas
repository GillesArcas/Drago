unit UFileAssoc;

interface

procedure RegisterAsso(const exeName, ext, FileTypeID, FileTypeName : string; var ok : boolean);
procedure UnregisterAsso(const exeName, ext, FileTypeID : string; var ok : boolean);
function  IsAssociated(const exeName, ext, FileTypeID : string) : boolean;
procedure NotifyExt;
function  IsAssociatedWithDrago(const exeName, ext : string) : boolean;
function  HasRegistryWriteAccess : boolean;

implementation

uses
  SysUtils, Registry, Windows, ShlObj;

// -- Drago specific ---------------------------------------------------------

const
  DragoFileTypeID   = 'Drago.Document';
  DragoFileTypeName = 'Drago document';

function IsAssociatedWithDrago(const exeName, ext : string) : boolean;
begin
  Result := IsAssociated(exeName, '.' + LowerCase(ext), DragoFileTypeID)
end;

function HasRegistryWriteAccess : boolean;
var
  ok : boolean;
  s : string;
begin
  with TRegistry.Create do
    try
      Result := True;
      try
        RootKey := HKEY_CLASSES_ROOT;

        OpenKey('\' + DragoFileTypeID, True);
        WriteString('', DragoFileTypeName);
        CloseKey
      finally
        free
      end
    except
      Result := False
    end
end;

// -- Files extension association --------------------------------------------
//
// -- RegisterAsso('Drago.exe', '.sgf', 'Drago.Document', 'Drago document')

function AssoCommand(const exeName : string) : string;
begin
  Result := '"' + exeName + '" "%1"'
end;

procedure RegisterAsso(const exeName, ext, FileTypeID, FileTypeName : string; var ok : boolean);
begin
  with TRegistry.Create do
    try
      ok := True;

      try
        RootKey := HKEY_CLASSES_ROOT;

        // associate extension with FileTypeID
        OpenKey('\' + ext, True);
        WriteString('', FileTypeID);
        CloseKey;

        // create FileTypeID key
        OpenKey('\' + FileTypeID, True);
        WriteString('', FileTypeName);
        CloseKey;

        OpenKey('\' + FileTypeID + '\DefaultIcon', True);
        WriteString('', exeName + ',1');
        CloseKey;

        OpenKey('\' + FileTypeID + '\Shell', True);
        WriteString('', 'open');
        CloseKey;

        OpenKey('\' + FileTypeID + '\Shell\open', True);
        WriteString('', '&Open');
        CloseKey;

        OpenKey('\' + FileTypeID + '\Shell\open\command', True);
        WriteString('', AssoCommand(exeName));
        CloseKey;

        // delete association in Explorer user settings
        RootKey := HKEY_CURRENT_USER;
        if OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + ext, False)
          then
            begin
              DeleteValue('Progid');
              DeleteValue('Application');
              CloseKey
            end;

        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, PChar(''), PChar(''))
      finally
        free
      end
    except
      ok := False
    end
end;

// -- Test association with file type Id -------------------------------------
//
// -- if IsAssociated('Drago.exe', '.sgf', 'Drago.Document') then ...

function IsAssociated(const exeName, ext, FileTypeID : string) : boolean;
var
  curAssoc, command : string;
begin
  with TRegistry.Create do
    try
      Result := False;

      RootKey := HKEY_CLASSES_ROOT;

      // get current file association
      if not OpenKey('\' + ext, False)
        then exit
        else
          begin
            curAssoc := ReadString('');
            CloseKey
          end;

      // exit if not related with FileTypeID
      if curAssoc <> FileTypeID
        then exit;

      // get association command
      if not OpenKey('\' + FileTypeID + '\Shell\open\command', False)
        then exit
        else
          begin
            command := ReadString('');
            CloseKey
          end;

      // exit if not the same command
      if command <> AssoCommand(exeName)
        then exit;

      // associated if Explorer user settings are empty
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + ext, False)
        then
          begin
            Result := (ReadString('Progid') = '') and
                      (ReadString('Application') = '');
            CloseKey
          end;

    finally
      free
    end
end;

// -- Restore association ----------------------------------------------------
//
// -- UnregisterAsso('Drago.exe', '.sgf', 'Drago.Document')

procedure UnregisterAsso(const exeName, ext, FileTypeID : string; var ok : boolean);
begin
  ok := True;

  // test if restore possible
  if not IsAssociated(exeName, ext, FileTypeID)
    then exit;

  with TRegistry.Create do
    try
      try
        RootKey := HKEY_CLASSES_ROOT;

        // delete association
        OpenKey('\' + ext, True);
        WriteString('', '');
        CloseKey;

        // do not delete FileTypeID key to avoid breaking another association
        // FileTypeId will not be deleted when uninstalling
        (*
        DeleteKey('\' + FileTypeID);
        *)

        // notify
        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, PChar(''), PChar(''))
      except
        ok := False
      end
    finally
      free
    end
end;

procedure NotifyExt;
begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, pchar(''), pchar(''))
end;

end.

(*
File associations are made through HKEY_CLASSES_ROOT and HKEY_CURRENT_USER as
follow. HKEY_CURRENT_USER has priority.

SmartGo settings

[HKEY_CLASSES_ROOT\.sgf]
@="SmartGo.Document"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.sgf]
"Progid"="SmartGo.Document"

MoyoGo settings

[HKEY_CLASSES_ROOT\.sgf]
@="SGFfile"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.sgf]
"Progid"="Moyo Go game(s)"
"Application"="C:\\Program Files\\Moyo Go Studio\\MoyoGo.exe"
*)

