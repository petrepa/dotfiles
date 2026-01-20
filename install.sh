#!/bin/bash

# Dotfiles install script
# Creates symlinks from home directory to dotfiles in this repo

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Install dependencies on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "Detected macOS, checking dependencies..."

    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Warning: Homebrew not installed. Install it from https://brew.sh"
        echo "Skipping dependency installation."
    else
        # Install thefuck if not present
        if ! command -v thefuck &> /dev/null; then
            echo "Installing thefuck..."
            brew install thefuck
        else
            echo "thefuck already installed"
        fi

        # Install eza if not present
        if ! command -v eza &> /dev/null; then
            echo "Installing eza..."
            brew install eza
        else
            echo "eza already installed"
        fi

        # Install zellij if not present
        if ! command -v zellij &> /dev/null; then
            echo "Installing zellij..."
            brew install zellij
        else
            echo "zellij already installed"
        fi
    fi
fi

# Create symlink for .zshrc
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
echo "Linked .zshrc"

# Create symlink for zellij config
mkdir -p "$HOME/.config"
if [ -d "$HOME/.config/zellij" ] && [ ! -L "$HOME/.config/zellij" ]; then
    echo "Backing up existing zellij config to .config/zellij.backup"
    mv "$HOME/.config/zellij" "$HOME/.config/zellij.backup"
fi
ln -sf "$DOTFILES_DIR/.config/zellij" "$HOME/.config/zellij"
echo "Linked zellij config"

echo ""
echo "Dotfiles installed successfully!"
echo "Run 'source ~/.zshrc' or restart your terminal to apply changes."
