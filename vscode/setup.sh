#!/usr/bin/env bash
# Applies this repo's VS Code config to the current machine:
# installs the listed extensions and copies settings/keybindings/snippets
# into the VS Code user folder. Existing files are backed up to *.bak first.

set -euo pipefail

vscode_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_dir="$HOME/Library/Application Support/Code/User"

if ! command -v code >/dev/null 2>&1; then
    echo "VS Code 'code' CLI not found on PATH. Install VS Code, run 'Shell Command: Install code command in PATH' from the Command Palette, then re-run." >&2
    exit 1
fi

echo "Installing extensions..."
while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    echo "  - $ext"
    code --install-extension "$ext" --force
done < "$vscode_dir/extensions.txt"

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
