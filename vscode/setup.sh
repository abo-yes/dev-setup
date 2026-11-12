#!/usr/bin/env bash
# Applies this repo's VS Code config to the current machine:
# installs Fira Code font if missing, installs the listed extensions,
# and copies settings/keybindings/snippets into the VS Code user folder.
# Existing files are backed up to *.bak first.

set -euo pipefail

vscode_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_dir="$HOME/Library/Application Support/Code/User"

if ! command -v code >/dev/null 2>&1; then
    echo "VS Code 'code' CLI not found on PATH. Install VS Code, run 'Shell Command: Install code command in PATH' from the Command Palette, then re-run." >&2
    exit 1
fi

# ---------- 1. Ensure Fira Code font is installed ----------
check_and_install_fira_code() {
    echo "Checking for Fira Code font..."
    if find "$HOME/Library/Fonts" /Library/Fonts /System/Library/Fonts -iname "*FiraCode*" 2>/dev/null | grep -q .; then
        echo "Fira Code font is already installed."
        return 0
    fi

    echo "Fira Code not found. Installing..."
    if command -v brew >/dev/null 2>&1; then
        echo "Attempting install via Homebrew..."
        if brew install --cask font-fira-code 2>/dev/null; then
            echo "Fira Code installed via Homebrew."
            return 0
        fi
    fi

    echo "Downloading Fira Code from GitHub..."
    local tmp_zip="/tmp/Fira_Code.zip"
    local tmp_dir="/tmp/Fira_Code_extracted"
    local font_dir="$HOME/Library/Fonts"

    mkdir -p "$font_dir" "$tmp_dir"
    if curl -fsSL -o "$tmp_zip" "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"; then
        unzip -q -o "$tmp_zip" -d "$tmp_dir"
        cp "$tmp_dir"/ttf/*.ttf "$font_dir"/
        rm -rf "$tmp_zip" "$tmp_dir"
        echo "Fira Code installed to $font_dir."
    else
        echo "Warning: Failed to download Fira Code font." >&2
        rm -rf "$tmp_zip" "$tmp_dir"
    fi
}

check_and_install_fira_code

# ---------- 2. Install extensions ----------
echo "Installing extensions..."
while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    echo "  - $ext"
    code --install-extension "$ext" --force
done < "$vscode_dir/extensions.txt"

# ---------- 3. Copy settings and keybindings ----------
mkdir -p "$user_dir"

copy_with_backup() {
    local source="$1" dest_name="$2"
    local dest="$user_dir/$dest_name"
    if [[ -f "$dest" ]]; then
        cp "$dest" "$dest.bak"
    fi
    cp "$source" "$dest"
    echo "Updated $dest_name (backup: $dest_name.bak)"
}

copy_with_backup "$vscode_dir/settings.json" "settings.json"
copy_with_backup "$vscode_dir/keybindings.json" "keybindings.json"

snippets_source="$vscode_dir/snippets"
if [[ -d "$snippets_source" ]] && [[ -n "$(ls -A "$snippets_source" 2>/dev/null)" ]]; then
    snippets_dest="$user_dir/snippets"
    mkdir -p "$snippets_dest"
    cp -R "$snippets_source"/. "$snippets_dest"/
    echo "Updated snippets"
fi

echo "Done. Restart VS Code to pick up the new settings/keybindings."
