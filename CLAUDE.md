# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing shell configurations across macOS and Windows. The repository uses symlinks to connect configuration files from this repo to the home directory.

## Installation

```bash
./install.sh
```

The install script:
- On macOS: auto-installs dependencies via Homebrew (thefuck, eza, zellij)
- Creates symlinks from `$HOME` to dotfiles in this repo
- Backs up existing files (e.g., `.zshrc` → `.zshrc.backup`) before symlinking
- After installation, run `source ~/.zshrc` or restart terminal

## Structure

- `.zshrc` - Zsh configuration using Oh My Zsh with `robbyrussell` theme and `git` plugin
- `.config/zellij/` - Zellij terminal multiplexer configuration (symlinked to `~/.config/zellij`)
- `AutoHotKey/` - Windows AutoHotKey scripts for macOS-like keyboard shortcuts

## Key Configuration Details

**Shell dependencies:**
- Oh My Zsh (expected at `$HOME/.oh-my-zsh`)
- `thefuck` command correction tool
- `eza` for enhanced directory listing
- `zellij` terminal multiplexer (auto-starts when terminal opens)

**Custom aliases defined in .zshrc:**
- `p` → `cd ~/Project`
- `lsa` → `ls -a`
- `lt` → tree view with eza
- `lta` → tree view including hidden files
