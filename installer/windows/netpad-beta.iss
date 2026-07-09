; SB Simple Netpad — Windows Beta Installer (Inno Setup 6)
; Build with: scripts/build-windows-installer.ps1

#define MyAppName "SB Simple Netpad"
#define MyAppPublisher "Spencer Beaumier"
#define MyAppURL "https://github.com/SpencerBeaumier/SB-Simple-Netpad"
#define MyAppExeName "netpad.exe"
#define MyAppId "{{A4E8C2F1-9B3D-4E6A-8F7C-1D2E3A4B5C6D}"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion} Beta
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\LICENSE
OutputDir=..\..\dist
OutputBaseFilename=SB-Simple-Netpad-{#MyAppVersion}-beta-windows-x64-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
MinVersion=10.0
DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "launchapp"; Description: "Launch {#MyAppName} after installation"; GroupDescription: "Post-install:"; Flags: checkedonce

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent; Tasks: launchapp

[Messages]
SetupAppTitle=Install {#MyAppName} (Beta)
SetupWindowTitle=Install {#MyAppName} (Beta) — {#MyAppVersion}
WelcomeLabel2=This will install [name/ver] on your computer.%n%nBeta software for LAN peer-to-peer note sharing. Allow Windows Firewall access when prompted so peers on your network can connect.

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
