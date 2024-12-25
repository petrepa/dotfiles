#!/bin/bash

set -e

echo "Creating symlinks for configuration files..."

ln -sf "$PWD/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$PWD/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
ln -sf "$PWD/neovim/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$PWD/neovim/lazy" "$HOME/.config/nvim/lazy"

echo "Symlinks created!"
