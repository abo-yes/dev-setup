#!/usr/bin/env bash
# Exports this machine's current VS Code config (extensions, settings,
# keybindings, snippets) into this repo. Run this after changing anything
# in VS Code, then commit and push so other machines can pick it up with
# setup.sh / setup.ps1.

set -euo pipefail

vscode_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_dir="$HOME/Library/Application Support/Code/User"

if ! command -v code >/dev/null 2>&1; then
    echo "VS Code 'code' CLI not found on PATH." >&2
    exit 1
fi

code --list-extensions | sort > "$vscode_dir/extensions.txt"
cp "$user_dir/settings.json" "$vscode_dir/settings.json"
cp "$user_dir/keybindings.json" "$vscode_dir/keybindings.json"

snippets_source="$user_dir/snippets"
if [[ -d "$snippets_source" ]] && [[ -n "$(ls -A "$snippets_source" 2>/dev/null)" ]]; then
    snippets_dest="$vscode_dir/snippets"
    mkdir -p "$snippets_dest"
    cp -R "$snippets_source"/. "$snippets_dest"/
fi

echo "Exported current VS Code config into $vscode_dir."
echo "Review the diff, then commit and push."
