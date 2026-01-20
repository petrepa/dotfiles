#!/bin/bash

# Dotfiles install script
# Creates symlinks from home directory to dotfiles in this repo

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create symlink for .zshrc
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
echo "Linked .zshrc"

echo ""
echo "Dotfiles installed successfully!"
echo "Run 'source ~/.zshrc' or restart your terminal to apply changes."
