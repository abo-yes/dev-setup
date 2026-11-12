# Applies this repo's VS Code config to the current machine:
# installs Fira Code font if missing, installs the listed extensions,
# and copies settings/keybindings/snippets into the VS Code user folder.
# Existing files are backed up to *.bak first.

$ErrorActionPreference = "Stop"
$vscodeDir = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code 'code' CLI not found on PATH. Install VS Code, enable 'code' in PATH, then re-run."
    exit 1
}

# ---------- 1. Ensure Fira Code font is installed ----------
function Test-FiraCodeInstalled {
    $regPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts",
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    )
    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            if ($props) {
                foreach ($prop in $props.PSObject.Properties) {
                    if ($prop.Name -like "*Fira*Code*") {
                        return $true
                    }
                }
            }
        }
    }
    $fileMatches = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts", "$env:WINDIR\Fonts" -Filter "*FiraCode*.ttf" -ErrorAction SilentlyContinue
    if ($fileMatches) {
        return $true
    }
    return $false
}

function Install-FiraCode {
    if (Test-FiraCodeInstalled) {
        Write-Host "Fira Code font is already installed."
        return
    }

    Write-Host "Fira Code font not found. Downloading and installing..."
    $url = "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
    $tempZip = Join-Path $env:TEMP "Fira_Code.zip"
    $tempExtract = Join-Path $env:TEMP "Fira_Code_extracted"

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing
        if (Test-Path $tempExtract) {
            Remove-Item $tempExtract -Recurse -Force
        }
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

        $userFontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
        New-Item -ItemType Directory -Force -Path $userFontDir | Out-Null
        $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

        $ttfFiles = Get-ChildItem -Path (Join-Path $tempExtract "ttf") -Filter "*.ttf"
        foreach ($file in $ttfFiles) {
            $destFile = Join-Path $userFontDir $file.Name
            Copy-Item $file.FullName $destFile -Force

            $style = $file.BaseName -replace "^FiraCode-", ""
            $fontName = if ($style -eq $file.BaseName) { "Fira Code (TrueType)" } else { "Fira Code $style (TrueType)" }
            Set-ItemProperty -Path $regPath -Name $fontName -Value $destFile
        }
        Write-Host "Fira Code font installed successfully to user fonts."
    }
    catch {
        Write-Warning "Failed to automatically install Fira Code font: $_"
    }
    finally {
        if (Test-Path $tempZip) { Remove-Item $tempZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

Install-FiraCode

# ---------- 2. Install extensions ----------
Write-Host "Installing extensions..."
Get-Content (Join-Path $vscodeDir "extensions.txt") | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
    Write-Host "  - $_"
    code --install-extension $_ --force
}

# ---------- 3. Copy settings and keybindings ----------
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
