#define MyAppName "MartX POS"
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#define MyAppPublisher "MartX"

[Setup]
AppId={{D5C3D7EF-8C54-4B52-9C0B-1A27F4B8C930}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\MartX
DefaultGroupName=MartX POS
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
OutputDir=output
OutputBaseFilename=MartXPOS-Setup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
Uninstallable=yes
SetupIconFile=martx.ico

[Files]
Source: "stage\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
Source: "martx.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "install-service.ps1"; DestDir: "{app}\service"; Flags: ignoreversion
Source: "firewall.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "smoke-install.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "open-app.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "create-cashier-shortcut.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "install.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{commonappdata}\MartX\config"
Name: "{commonappdata}\MartX\data"
Name: "{commonappdata}\MartX\logs"
Name: "{commonappdata}\MartX\backups"

[Icons]
Name: "{group}\MartX POS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\open-app.ps1"" -HostName 127.0.0.1 -Port 5002"; WorkingDir: "{app}"; IconFilename: "{app}\martx.ico"
Name: "{commondesktop}\MartX POS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\open-app.ps1"" -HostName 127.0.0.1 -Port 5002"; WorkingDir: "{app}"; IconFilename: "{app}\martx.ico"

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\install.ps1"" -InstallRoot ""{app}"" -DataRoot ""{commonappdata}\MartX"" -Version ""{#MyAppVersion}"""; Flags: runhidden waituntilterminated
Filename: "http://127.0.0.1:5002/"; Description: "Launch MartX POS"; Flags: postinstall nowait shellexec skipifsilent

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\service\install-service.ps1"" -Remove"; Flags: runhidden waituntilterminated
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\firewall.ps1"" -Remove"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  NssmPath: string;
begin
  if CurStep = ssInstall then
  begin
    { Stop the existing service before replacing native sqlite3 files. }
    NssmPath := ExpandConstant('{app}\service\nssm.exe');
    if FileExists(NssmPath) then
    begin
      Exec(NssmPath, 'stop MartXPOS confirm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Sleep(2000);
    end;
  end;
end;
