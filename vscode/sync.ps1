# Exports this machine's current VS Code config (extensions, settings,
# keybindings, snippets) into this repo. Run this after changing anything
# in VS Code, then commit and push so other machines can pick it up with
# setup.ps1.

$ErrorActionPreference = "Stop"
$vscodeDir = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code 'code' CLI not found on PATH."
    exit 1
}

code --list-extensions | Sort-Object | Set-Content (Join-Path $vscodeDir "extensions.txt")
Copy-Item (Join-Path $userDir "settings.json") (Join-Path $vscodeDir "settings.json") -Force
Copy-Item (Join-Path $userDir "keybindings.json") (Join-Path $vscodeDir "keybindings.json") -Force

$snippetsSource = Join-Path $userDir "snippets"
if ((Test-Path $snippetsSource) -and (Get-ChildItem $snippetsSource -ErrorAction SilentlyContinue)) {
    $snippetsDest = Join-Path $vscodeDir "snippets"
    New-Item -ItemType Directory -Force -Path $snippetsDest | Out-Null
    Copy-Item (Join-Path $snippetsSource "*") $snippetsDest -Recurse -Force
}

Write-Host "Exported current VS Code config into $vscodeDir."
Write-Host "Review the diff, then commit and push."
