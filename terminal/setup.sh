#!/usr/bin/env bash
# Install WezTerm and link this repository's config on macOS and Linux.

set -euo pipefail

terminal_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
config_file="$config_dir/wezterm.lua"

install_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        echo "WezTerm is already installed."
        return
    fi

    case "$(uname -s)" in
        Darwin)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Homebrew is required to install WezTerm on macOS. Install Homebrew, then re-run." >&2
                exit 1
            fi
            brew install --cask wezterm
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
                    echo "Install curl and gpg first, then re-run this script." >&2
                    exit 1
                fi
                curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
                echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
                sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
                sudo apt-get update
                sudo apt-get install -y wezterm
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --needed wezterm
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y wezterm
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y wezterm
            elif command -v flatpak >/dev/null 2>&1; then
                flatpak install --user -y flathub org.wezfurlong.wezterm
            elif command -v brew >/dev/null 2>&1; then
                brew install wezterm/wezterm-linuxbrew/wezterm
            else
                echo "No supported package manager found. Install WezTerm for your distribution, then re-run." >&2
                echo "See https://wezterm.org/install/linux.html" >&2
                exit 1
            fi
            ;;
        *)
            echo "This installer supports macOS and Linux." >&2
            exit 1
            ;;
    esac
}

install_wezterm
mkdir -p "$config_dir"

if [[ -e "$config_file" && ! -L "$config_file" ]]; then
    backup="$config_file.bak"
    if [[ -e "$backup" ]]; then
        backup="$config_file.$(date +%Y%m%d%H%M%S).bak"
    fi
    mv "$config_file" "$backup"
    echo "Backed up existing config to $backup"
fi

ln -sfn "$terminal_dir/wezterm.lua" "$config_file"
echo "Linked WezTerm config: $config_file"
echo "Done. Launch WezTerm to use the config."
