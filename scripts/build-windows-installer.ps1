# Build SB Simple Netpad Windows installer.
# Usage: .\scripts\build-windows-installer.ps1 [-SkipFlutterBuild]

#Requires -Version 5.1

param(
    [switch]$SkipFlutterBuild
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$PubspecPath = Join-Path $ProjectRoot 'pubspec.yaml'
$BuildOutput = Join-Path $ProjectRoot 'build\windows\x64\runner\Release'
$DistDir = Join-Path $ProjectRoot 'dist'
$InstallerDir = Join-Path $ProjectRoot 'installer\windows'
$IssFile = Join-Path $InstallerDir 'netpad-beta.iss'
$StageName = 'SB-Simple-Netpad-windows-x64'
$StageDir = Join-Path $DistDir $StageName

function Get-ProjectVersion {
    $line = Get-Content $PubspecPath | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
    if ($line -match 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
        return $Matches[1]
    }
    throw "Could not parse version from pubspec.yaml"
}

function Find-InnoSetupCompiler {
    $candidates = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 7\ISCC.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    return $null
}

$Version = Get-ProjectVersion
Write-Host "SB Simple Netpad $Version - Windows installer build" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"
Write-Host ""

Push-Location $ProjectRoot
try {
    if (-not $SkipFlutterBuild) {
        Write-Host "Fetching packages..."
        & flutter pub get
        if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

        Write-Host "Building Windows release..."
        & flutter build windows --release
        if ($LASTEXITCODE -ne 0) { throw "flutter build windows failed" }
    }

    if (-not (Test-Path (Join-Path $BuildOutput 'netpad.exe'))) {
        throw "Release build not found at $BuildOutput. Run without -SkipFlutterBuild."
    }

    Write-Host "Staging installer payload..."
    if (Test-Path $StageDir) {
        Remove-Item -LiteralPath $StageDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StageDir -Force | Out-Null

    $AppStage = Join-Path $StageDir 'app'
    New-Item -ItemType Directory -Path $AppStage -Force | Out-Null
    Copy-Item -Path (Join-Path $BuildOutput '*') -Destination $AppStage -Recurse -Force

    Copy-Item -Path (Join-Path $InstallerDir 'Setup.ps1') -Destination $StageDir -Force
    Copy-Item -Path (Join-Path $InstallerDir 'Setup.cmd') -Destination $StageDir -Force
    Copy-Item -Path (Join-Path $ProjectRoot 'LICENSE') -Destination $StageDir -Force
    Set-Content -Path (Join-Path $StageDir 'VERSION.txt') -Value $Version -Encoding ASCII -NoNewline

    $readme = @"
SB Simple Netpad $Version - Windows x64
=======================================

Quick install
-------------
1. Extract this folder anywhere.
2. Double-click Setup.cmd (or run Setup.ps1 in PowerShell).
3. Allow Windows Firewall when the app first runs so LAN peers can connect.

Requirements
------------
- Windows 10 or later (64-bit)
- Devices on the same local network for peer sync

Uninstall
---------
Settings -> Apps -> SB Simple Netpad
or run Uninstall.cmd from the install folder after setup.

Note: Microsoft Store purchases require a Store-signed MSIX, not this sideload package.
"@
    Set-Content -Path (Join-Path $StageDir 'README-INSTALL.txt') -Value $readme -Encoding UTF8

    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
    $zipPath = Join-Path $DistDir "SB-Simple-Netpad-$Version-windows-x64.zip"
    if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    Compress-Archive -Path (Join-Path $StageDir '*') -DestinationPath $zipPath -CompressionLevel Optimal

    $iscc = Find-InnoSetupCompiler
    $setupExe = Join-Path $DistDir "SB-Simple-Netpad-$Version-windows-x64-setup.exe"
    if ($iscc) {
        Write-Host "Compiling Inno Setup installer..."
        & $iscc "/DMyAppVersion=$Version" "/DBuildDir=$BuildOutput" $IssFile
        if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed" }
        if (-not (Test-Path $setupExe)) {
            throw "Expected installer not found at $setupExe"
        }
    }
    else {
        Write-Host "Inno Setup not found - skipping .exe installer." -ForegroundColor Yellow
        Write-Host "Install Inno Setup 6+ and re-run to produce a single setup.exe:"
        Write-Host "  winget install JRSoftware.InnoSetup"
    }

    Write-Host ""
    Write-Host "Build complete:" -ForegroundColor Green
    Write-Host "  ZIP:   $zipPath"
    if (Test-Path $setupExe) {
        Write-Host "  EXE:   $setupExe"
    }
    Write-Host "  Stage: $StageDir"
}
finally {
    Pop-Location
}
