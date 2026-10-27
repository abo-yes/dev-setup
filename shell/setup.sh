#!/usr/bin/env bash
# Install Zsh, Oh My Zsh, and the shared shell configuration.

set -euo pipefail

shell_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
zshrc="$HOME/.zshrc"

install_packages() {
    case "$(uname -s)" in
        Darwin)
            command -v brew >/dev/null 2>&1 || {
                echo "Homebrew is required on macOS. Install it, then re-run." >&2
                exit 1
            }
            brew list zsh >/dev/null 2>&1 || brew install zsh
            brew list git >/dev/null 2>&1 || brew install git
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y zsh git curl
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y zsh git curl
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --needed zsh git curl
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y zsh git curl
            else
                echo "No supported package manager found. Install zsh, git, and curl, then re-run." >&2
                exit 1
            fi
            ;;
        *)
            echo "This script supports macOS and Linux. Use PowerShell on Windows." >&2
            exit 1
            ;;
    esac
}

install_oh_my_zsh() {
    if [[ ! -d "$omz_dir" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            || { echo "Oh My Zsh installation failed." >&2; exit 1; }
    fi
}

install_plugin() {
    local name="$1" repo="$2"
    local destination="$omz_dir/custom/plugins/$name"
    if [[ ! -d "$destination" ]]; then
        git clone --depth=1 "$repo" "$destination"
    fi
}

install_packages
install_oh_my_zsh
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

if [[ -e "$zshrc" && ! -L "$zshrc" ]]; then
    backup="$zshrc.bak"
    [[ -e "$backup" ]] && backup="$zshrc.$(date +%Y%m%d%H%M%S).bak"
    mv "$zshrc" "$backup"
    echo "Backed up existing .zshrc to $backup"
fi

ln -sfn "$shell_dir/zshrc" "$zshrc"

if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
    zsh_path="$(command -v zsh)"
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        echo "Add $zsh_path to /etc/shells before changing your login shell."
    elif [[ -t 0 ]]; then
        chsh -s "$zsh_path" "$USER" || echo "Could not change login shell; run: chsh -s $zsh_path"
    fi
fi

echo "Zsh and Oh My Zsh are ready. Start a new terminal or run: exec zsh"
