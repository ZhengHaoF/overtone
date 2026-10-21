; Per-user installer of the exact saved production Release bundle.
#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef SourceDir
  #error SourceDir is required
#endif
#ifndef OutputDir
  #error OutputDir is required
#endif
#if !FileExists(SourceDir + "\overtone.exe")
  #error Missing production executable
#endif
#if !FileExists(SourceDir + "\flutter_windows.dll")
  #error Missing Flutter runtime
#endif

[Setup]
AppId=overtone.ZhengHaoF
AppName=泛音
AppVersion={#AppVersion}
AppVerName=泛音 {#AppVersion}
DefaultDirName={localappdata}\Programs\overtone
DefaultGroupName=overtone
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=overtone-{#AppVersion}-windows-x64-setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\overtone.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
MinVersion=10.0

; Simplified Chinese is an unofficial translation and is not bundled with the
; Inno Setup installer since 6.3, so it is vendored below and referenced by a
; script-relative path. Source: jrsoftware/issrc commit 6ef32198ef1f7b7b375cd4b6b90896c2a58eb4c2
; (Files/Languages/ChineseSimplified.isl, requires Inno Setup 6.5.0 or later).
[Languages]
Name: "zh"; MessagesFile: "inno_languages\ChineseSimplified.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\泛音"; Filename: "{app}\overtone.exe"; WorkingDir: "{app}"; IconFilename: "{app}\data\flutter_assets\assets\app_icon.ico"; AppUserModelID: "com.kugo.player"
Name: "{autodesktop}\泛音"; Filename: "{app}\overtone.exe"; WorkingDir: "{app}"; IconFilename: "{app}\data\flutter_assets\assets\app_icon.ico"; AppUserModelID: "com.kugo.player"; Tasks: desktopicon

[Run]
Filename: "{app}\overtone.exe"; Description: "运行 泛音"; Flags: nowait postinstall skipifsilent
