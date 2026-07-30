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
OutputDir=output
OutputBaseFilename=MartXPOS-Setup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
Uninstallable=yes

[Files]
Source: "stage\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
Source: "install-service.ps1"; DestDir: "{app}\service"; Flags: ignoreversion
Source: "firewall.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "smoke-install.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{commonappdata}\MartX\config"
Name: "{commonappdata}\MartX\data"
Name: "{commonappdata}\MartX\logs"
Name: "{commonappdata}\MartX\backups"

[Icons]
Name: "{group}\MartX POS"; Filename: "{sys}\cmd.exe"; Parameters: "/c start http://127.0.0.1:5002/"
Name: "{commondesktop}\MartX POS"; Filename: "{sys}\cmd.exe"; Parameters: "/c start http://127.0.0.1:5002/"

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\service\install-service.ps1"""; Flags: runhidden waituntilterminated
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\firewall.ps1"""; Flags: runhidden waituntilterminated
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\smoke-install.ps1"" -OpenBrowser"; Flags: runhidden waituntilterminated

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\service\install-service.ps1"" -Remove"; Flags: runhidden waituntilterminated
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\firewall.ps1"" -Remove"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
