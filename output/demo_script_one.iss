#define MyAppName "Demo App"
#define MyAppVersion "1.21"
#define MyAppPublisher "My Company, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "demo_project.exe"

[Setup]
AppId={{72B09127-9F16-482E-8EAF-D867C0C54579}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Demo App One
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
OutputDir=C:\Users\AGL\Desktop\demo\demo_project\output
OutputBaseFilename=demo_app_one
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}\logs"; Permissions: users-modify

[Files]
Source: "C:\Users\AGL\Desktop\demo\demo_project\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\AGL\Desktop\demo\demo_project\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\AGL\Desktop\demo\demo_project\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  DownloadPage: TDownloadWizardPage;
  NeedsVC2022: Boolean;
  NeedsDirectX: Boolean;
  NeedsWebView2: Boolean;

// Check for Visual C++ Redistributable
function IsVC2015To2022RedistInstalled(): Boolean;
var
  RegKey: String;
begin
  RegKey := 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64';
  if RegKeyExists(HKEY_LOCAL_MACHINE, RegKey) then
  begin
    Result := True;
    Exit;
  end;
  
  RegKey := 'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64';
  Result := RegKeyExists(HKEY_LOCAL_MACHINE, RegKey);
end;

// Check for DirectX version
function CheckDirectXVersion(): Boolean;
var
  D3DPath: String;
begin
  D3DPath := ExpandConstant('{sys}\d3d11.dll');
  Result := FileExists(D3DPath);
end;

// Check for WebView2
function IsWebView2Installed(): Boolean;
begin
  Result := RegKeyExists(HKEY_LOCAL_MACHINE,
    'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}') or
    RegKeyExists(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}');
end;

// Create the download page
procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

// Main initialization function
function InitializeSetup(): Boolean;
var
  MissingComponents: String;
  InstallMissing: Integer;
begin
  Result := True;
  MissingComponents := '';

  // Check components
  NeedsVC2022 := not IsVC2015To2022RedistInstalled();
  NeedsDirectX := not CheckDirectXVersion();
  NeedsWebView2 := not IsWebView2Installed();

  if NeedsVC2022 then
    MissingComponents := MissingComponents + '- Microsoft Visual C++ 2015-2022 Redistributable (x64)' + #13#10;
  if NeedsDirectX then
    MissingComponents := MissingComponents + '- DirectX 11' + #13#10;
  if NeedsWebView2 then
    MissingComponents := MissingComponents + '- Microsoft Edge WebView2 Runtime' + #13#10;

  // If missing components found, ask user to install them
  if MissingComponents <> '' then
  begin
    InstallMissing := MsgBox('The following components are required but not installed:' + #13#10#13#10 + 
                            MissingComponents + #13#10 +
                            'Would you like to download and install them now?' + #13#10 +
                            'Note: Installation may take several minutes.',
                            mbConfirmation, MB_YESNO);
    
    if InstallMissing = IDNO then
    begin
      Result := False;
      MsgBox('The application requires these components to function properly. ' +
             'Installation will now exit.', mbError, MB_OK);
    end;
  end;
end;
