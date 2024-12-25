#!/bin/bash

set -e

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing applications..."
brew install alacritty bat zellij zsh neovim docker

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Configuring Docker Desktop..."
./docker/docker.desktop.sh

echo "macOS setup complete!"
