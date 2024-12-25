#!/bin/bash

set -e

echo "Updating packages and installing tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git zsh neovim docker.io

echo "Installing bat..."
curl -LO https://github.com/sharkdp/bat/releases/download/v0.23.0/bat_0.23.0_amd64.deb
sudo dpkg -i bat_0.23.0_amd64.deb
rm bat_0.23.0_amd64.deb

echo "Installing Alacritty..."
sudo add-apt-repository ppa:mmstick76/alacritty
sudo apt update
sudo apt install -y alacritty

echo "Installing Zellij..."
curl -sSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-linux.tar.gz | tar xz
sudo mv zellij /usr/local/bin

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Linux setup complete!"

