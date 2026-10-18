# Applies this repo's VS Code config to the current machine:
# installs the listed extensions and copies settings/keybindings/snippets
# into the VS Code user folder. Existing files are backed up to *.bak first.

$ErrorActionPreference = "Stop"
$vscodeDir = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code 'code' CLI not found on PATH. Install VS Code, enable 'code' in PATH, then re-run."
    exit 1
}

Write-Host "Installing extensions..."
Get-Content (Join-Path $vscodeDir "extensions.txt") | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
    Write-Host "  - $_"
    code --install-extension $_ --force
}

New-Item -ItemType Directory -Force -Path $userDir | Out-Null

function Copy-WithBackup($source, $destName) {
    $dest = Join-Path $userDir $destName
    if (Test-Path $dest) {
        Copy-Item $dest "$dest.bak" -Force
    }
    Copy-Item $source $dest -Force
    Write-Host "Updated $destName (backup: $destName.bak)"
}

Copy-WithBackup (Join-Path $vscodeDir "settings.json") "settings.json"
Copy-WithBackup (Join-Path $vscodeDir "keybindings.json") "keybindings.json"

$snippetsSource = Join-Path $vscodeDir "snippets"
if ((Test-Path $snippetsSource) -and (Get-ChildItem $snippetsSource -ErrorAction SilentlyContinue)) {
    $snippetsDest = Join-Path $userDir "snippets"
    New-Item -ItemType Directory -Force -Path $snippetsDest | Out-Null
    Copy-Item (Join-Path $snippetsSource "*") $snippetsDest -Recurse -Force
    Write-Host "Updated snippets"
}

Write-Host "Done. Restart VS Code to pick up the new settings/keybindings."
