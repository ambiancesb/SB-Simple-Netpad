# SB Simple Netpad — Windows Beta setup (no Inno Setup required).
# Installs to the current user's Programs folder and registers an uninstall entry.

#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

$AppName = 'SB Simple Netpad'
$Publisher = 'Spencer Beaumier'
$ExeName = 'netpad.exe'

function Get-ProjectVersion {
    param([string]$PubspecPath)
    $line = Get-Content $PubspecPath | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
    if (-not $line) { throw "Could not read version from $PubspecPath" }
    if ($line -match 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
        return $Matches[1]
    }
    throw "Could not parse version from: $line"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppSource = Join-Path $ScriptDir 'app'
$VersionFile = Join-Path $ScriptDir 'VERSION.txt'
if (Test-Path $VersionFile) {
    $Version = (Get-Content $VersionFile -Raw).Trim()
}
else {
    $PubspecPath = Join-Path $ScriptDir '..\..\pubspec.yaml'
    if (Test-Path $PubspecPath) {
        $Version = Get-ProjectVersion (Resolve-Path $PubspecPath)
    }
    else {
        $Version = '1.2.0'
    }
}

if (-not (Test-Path (Join-Path $AppSource $ExeName))) {
    Write-Error "Application files not found in '$AppSource'. Run scripts/build-windows-installer.ps1 first."
}

$InstallRoot = Join-Path $env:LOCALAPPDATA 'Programs' $AppName
$StartMenuDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs' $AppName
$UninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"

Write-Host ""
Write-Host "  $AppName $Version Beta - Windows Setup" -ForegroundColor Cyan
Write-Host "  Install location: $InstallRoot"
Write-Host ""

$existing = Get-ItemProperty -Path $UninstallKey -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "An existing installation was found. It will be replaced." -ForegroundColor Yellow
}

$desktopShortcut = Read-Host "Create a desktop shortcut? [Y/n]"
$launchAfter = Read-Host "Launch $AppName when setup finishes? [Y/n]"

if (Test-Path $InstallRoot) {
    Remove-Item -LiteralPath $InstallRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
Copy-Item -Path (Join-Path $AppSource '*') -Destination $InstallRoot -Recurse -Force

New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
$WshShell = New-Object -ComObject WScript.Shell

$startShortcut = $WshShell.CreateShortcut((Join-Path $StartMenuDir "$AppName.lnk"))
$startShortcut.TargetPath = Join-Path $InstallRoot $ExeName
$startShortcut.WorkingDirectory = $InstallRoot
$startShortcut.Description = "$AppName $Version Beta"
$startShortcut.Save()

if ($desktopShortcut -eq '' -or $desktopShortcut -match '^[Yy]') {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $desktopShortcutObj = $WshShell.CreateShortcut((Join-Path $desktopPath "$AppName.lnk"))
    $desktopShortcutObj.TargetPath = Join-Path $InstallRoot $ExeName
    $desktopShortcutObj.WorkingDirectory = $InstallRoot
    $desktopShortcutObj.Description = "$AppName $Version Beta"
    $desktopShortcutObj.Save()
}

$uninstallScript = @"
#Requires -Version 5.1
`$ErrorActionPreference = 'Stop'
`$AppName = '$AppName'
`$InstallRoot = '$InstallRoot'
`$StartMenuDir = '$StartMenuDir'
`$UninstallKey = '$UninstallKey'
`$DesktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) "`$AppName.lnk"

if (Test-Path `$InstallRoot) { Remove-Item -LiteralPath `$InstallRoot -Recurse -Force }
if (Test-Path `$StartMenuDir) { Remove-Item -LiteralPath `$StartMenuDir -Recurse -Force }
if (Test-Path `$DesktopShortcut) { Remove-Item -LiteralPath `$DesktopShortcut -Force }
if (Test-Path `$UninstallKey) { Remove-Item -LiteralPath `$UninstallKey -Force }
Write-Host "Uninstalled `$AppName."
"@
$uninstallPath = Join-Path $InstallRoot 'Uninstall.ps1'
Set-Content -Path $uninstallPath -Value $uninstallScript -Encoding UTF8

$uninstallCmd = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$uninstallPath`"`r`npause"
Set-Content -Path (Join-Path $InstallRoot 'Uninstall.cmd') -Value $uninstallCmd -Encoding ASCII

New-Item -Path $UninstallKey -Force | Out-Null
Set-ItemProperty -Path $UninstallKey -Name DisplayName -Value "$AppName $Version Beta"
Set-ItemProperty -Path $UninstallKey -Name DisplayVersion -Value $Version
Set-ItemProperty -Path $UninstallKey -Name Publisher -Value $Publisher
Set-ItemProperty -Path $UninstallKey -Name InstallLocation -Value $InstallRoot
Set-ItemProperty -Path $UninstallKey -Name UninstallString -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$uninstallPath`""
Set-ItemProperty -Path $UninstallKey -Name DisplayIcon -Value (Join-Path $InstallRoot $ExeName)
Set-ItemProperty -Path $UninstallKey -Name NoModify -Value 1 -Type DWord
Set-ItemProperty -Path $UninstallKey -Name NoRepair -Value 1 -Type DWord

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Green
Write-Host "Allow Windows Firewall access when you first run the app so LAN peers can connect."
Write-Host ""

if ($launchAfter -eq '' -or $launchAfter -match '^[Yy]') {
    Start-Process -FilePath (Join-Path $InstallRoot $ExeName) -WorkingDirectory $InstallRoot
}
