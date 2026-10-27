# Install WezTerm and link this repository's config on Windows.

$ErrorActionPreference = "Stop"
$terminalDir = $PSScriptRoot
$configDir = Join-Path $env:USERPROFILE ".config\wezterm"
$configFile = Join-Path $configDir "wezterm.lua"

if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "WezTerm is not installed and winget was not found. Install WezTerm, then re-run."
    }
    winget install --id wez.wezterm --exact --accept-source-agreements --accept-package-agreements
}

New-Item -ItemType Directory -Force -Path $configDir | Out-Null
if ((Test-Path $configFile) -and -not ((Get-Item $configFile).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    $backup = "$configFile.bak"
    if (Test-Path $backup) {
        $backup = "$configFile.$(Get-Date -Format yyyyMMddHHmmss).bak"
    }
    Move-Item $configFile $backup
    Write-Host "Backed up existing config to $backup"
}

if (Test-Path $configFile) {
    Remove-Item $configFile -Force
}
New-Item -ItemType SymbolicLink -Path $configFile -Target (Join-Path $terminalDir "wezterm.lua") | Out-Null
Write-Host "Linked WezTerm config: $configFile"
Write-Host "Done. Launch WezTerm to use the config."
