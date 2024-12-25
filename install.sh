#!/bin/bash

set -e

echo "Starting dotfiles installation..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Detected macOS."
  ./macos.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Detected Linux."
  ./linux.sh
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

echo "Setting up symlinks..."
./symlink.sh

echo "Dotfiles setup complete!"
