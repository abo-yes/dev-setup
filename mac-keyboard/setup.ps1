# Installs AutoHotkey v2 (if missing), adds mac-keys.ahk to the Startup folder
# and starts it now.

$ErrorActionPreference = "Stop"
$script = Join-Path $PSScriptRoot "mac-keys.ahk"

if (-not (Get-Command AutoHotkey64 -ErrorAction SilentlyContinue) -and
    -not (Test-Path "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe")) {
    Write-Host "Installing AutoHotkey v2..."
    winget install --id AutoHotkey.AutoHotkey -e --accept-source-agreements --accept-package-agreements
}

$startup = [Environment]::GetFolderPath("Startup")
$shortcut = Join-Path $startup "mac-keys.lnk"
$shell = New-Object -ComObject WScript.Shell
$link = $shell.CreateShortcut($shortcut)
$link.TargetPath = $script
$link.WorkingDirectory = $PSScriptRoot
$link.Save()
Write-Host "Added startup shortcut: $shortcut"

Start-Process $script
Write-Host "Done. mac-keys.ahk is running (tray icon: green H)."
