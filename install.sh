#!/bin/bash
#
# Dotfiles install script — macOS, Ubuntu/Linux, and Windows (via WSL2).
#
# - macOS:   installs deps via Homebrew (thefuck, eza, zellij, zoxide)
# - Linux:   installs zsh via apt, and zellij/zoxide/eza as user binaries
#            in ~/.local/bin (they aren't reliably packaged in apt)
# - Windows: run this inside WSL2 (Ubuntu). In addition to the Linux setup it
#            deploys the Alacritty config to %APPDATA%\alacritty on the host.
#
# All steps are idempotent and back up existing non-symlink files.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing dotfiles from $DOTFILES_DIR"

# ---------- platform detection ----------
OS="unknown"
case "$OSTYPE" in
    darwin*) OS="macos" ;;
    linux*)  OS="linux" ;;
esac

IS_WSL=0
if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then IS_WSL=1; fi

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

have() { command -v "$1" >/dev/null 2>&1; }

# ---------- dependencies ----------
install_macos_deps() {
    if ! have brew; then
        echo "Warning: Homebrew not installed. Install it from https://brew.sh"
        echo "Skipping dependency installation."
        return
    fi
    for pkg in thefuck eza zellij zoxide; do
        if have "$pkg"; then
            echo "$pkg already installed"
        else
            echo "Installing $pkg..."
            brew install "$pkg"
        fi
    done
}

install_linux_deps() {
    local arch tmp
    arch="$(uname -m)"
    tmp="$(mktemp -d)"

    # zsh — from the distro (needs sudo)
    if ! have zsh; then
        if have apt-get; then
            echo "Installing zsh (sudo required)..."
            sudo apt-get update -y && sudo apt-get install -y zsh
        else
            echo "Please install zsh with your package manager, then re-run."
        fi
    else
        echo "zsh already installed"
    fi

    # zellij — prebuilt musl binary -> ~/.local/bin
    if ! have zellij; then
        echo "Installing zellij -> $LOCAL_BIN ..."
        curl -fsSL -o "$tmp/zellij.tgz" \
            "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${arch}-unknown-linux-musl.tar.gz" \
            && tar xzf "$tmp/zellij.tgz" -C "$LOCAL_BIN"
    else
        echo "zellij already installed"
    fi

    # eza — prebuilt binary -> ~/.local/bin
    if ! have eza; then
        echo "Installing eza -> $LOCAL_BIN ..."
        curl -fsSL -o "$tmp/eza.tgz" \
            "https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-unknown-linux-gnu.tar.gz" \
            && tar xzf "$tmp/eza.tgz" -C "$LOCAL_BIN"
    else
        echo "eza already installed"
    fi

    # zoxide — asset name is versioned, so resolve the URL from the GitHub API
    if ! have zoxide; then
        echo "Installing zoxide -> $LOCAL_BIN ..."
        local zurl
        zurl="$(curl -fsSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest \
            | grep -oE '"browser_download_url": *"[^"]*'"${arch}"'-unknown-linux-musl.tar.gz"' \
            | head -1 | sed -E 's/.*"(https[^"]+)"/\1/')"
        if [ -n "$zurl" ]; then
            curl -fsSL -o "$tmp/zoxide.tgz" "$zurl" \
                && tar xzf "$tmp/zoxide.tgz" -C "$tmp" \
                && cp "$tmp/zoxide" "$LOCAL_BIN/" && chmod +x "$LOCAL_BIN/zoxide"
        else
            echo "Could not resolve a zoxide release for $arch — skipping."
        fi
    else
        echo "zoxide already installed"
    fi

    rm -rf "$tmp"
    echo "Note: thefuck is optional (Python-based). Install with 'pipx install thefuck' if wanted."
}

case "$OS" in
    macos)
        echo ""
        echo "Detected macOS, checking dependencies..."
        install_macos_deps
        ;;
    linux)
        echo ""
        echo "Detected Linux$([ "$IS_WSL" = 1 ] && echo ' (WSL2)'), checking dependencies..."
        install_linux_deps
        ;;
    *)
        echo "Unknown OS ($OSTYPE) — skipping dependency installation."
        ;;
esac

# ---------- Oh My Zsh ----------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    echo "Oh My Zsh already installed"
fi

# ---------- symlink helper ----------
link() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up $dest -> $dest.backup"
        mv "$dest" "$dest.backup"
    fi
    ln -sfn "$src" "$dest"
    echo "Linked $dest"
}

# .zshrc
link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# zellij
mkdir -p "$HOME/.config"
link "$DOTFILES_DIR/.config/zellij" "$HOME/.config/zellij"

# Alacritty — native config for macOS/Linux
mkdir -p "$HOME/.config/alacritty"
link "$DOTFILES_DIR/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# ---------- Windows (WSL) Alacritty deploy ----------
if [ "$IS_WSL" = 1 ]; then
    appdata_win="$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')"
    if [ -n "$appdata_win" ]; then
        win_ala="$(wslpath "$appdata_win")/alacritty"
        mkdir -p "$win_ala"
        cat "$DOTFILES_DIR/.config/alacritty/alacritty.toml" \
            "$DOTFILES_DIR/.config/alacritty/shell.windows.toml" > "$win_ala/alacritty.toml"
        echo "Deployed Alacritty config (base + WSL shell) to $win_ala/alacritty.toml"
    else
        echo "Could not resolve %APPDATA% — skipping Windows Alacritty deploy."
    fi
fi

# ---------- default shell hint ----------
if have zsh && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo ""
    echo "Your login shell is not zsh yet. Switch with:"
    echo "    chsh -s \"$(command -v zsh)\""
fi

echo ""
echo "Dotfiles installed successfully!"
echo "Run 'source ~/.zshrc' or restart your terminal to apply changes."
