# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for a consistent terminal setup across **macOS, Ubuntu/Linux,
and Windows (via WSL2)**: Alacritty + zsh (Oh My Zsh) + zellij + Neovim
(LazyVim), plus `zoxide`, `eza`, and `thefuck`. Configs are symlinked from this
repo into `$HOME`.

## Installation

```bash
./install.sh
```

`install.sh` detects the platform (`$OSTYPE`, plus `/proc/version` for WSL) and:
- **macOS**: installs deps via Homebrew (thefuck, eza, zellij, zoxide, neovim,
  ripgrep, fd, fzf, lazygit).
- **Linux**: installs apt packages that need root (`zsh`, `build-essential`,
  `unzip`, `ripgrep`); installs `zellij`/`zoxide`/`eza`/`fd`/`fzf`/`lazygit` as
  prebuilt binaries into `~/.local/bin`, and Neovim into `~/.local/opt/nvim`
  (symlinked to `~/.local/bin/nvim`); `thefuck` is optional.
- Installs Oh My Zsh if missing.
- Symlinks `.zshrc`, `.config/zellij`, `.config/nvim`, and
  `.config/alacritty/alacritty.toml` (backing up existing non-symlink files to
  `*.backup`).
- **WSL only**: also deploys Alacritty to the Windows host by concatenating
  `alacritty.toml` + `shell.windows.toml` into `%APPDATA%\alacritty\alacritty.toml`.

After installation: `source ~/.zshrc` or restart the terminal; run
`chsh -s "$(which zsh)"` if zsh isn't the login shell.

## Structure

- `.zshrc` — Oh My Zsh (`robbyrussell` theme, `git` plugin). Adds
  `~/.local/bin` to PATH; macOS-only paths and `thefuck`/`zoxide` init are
  guarded so it's portable across all three platforms.
- `.config/zellij/` — Zellij config (symlinked to `~/.config/zellij`).
- `.config/nvim/` — Neovim / [LazyVim](https://www.lazyvim.org/) config (whole
  dir symlinked to `~/.config/nvim`). `init.lua` bootstraps lazy.nvim; personal
  config in `lua/config/`, plugin specs/overrides in `lua/plugins/`.
  `lazy-lock.json` pins plugin versions — commit it after `:Lazy sync`. The
  starter's own `.git`/`README`/`LICENSE` were stripped; its `.gitignore` is
  kept (it only ignores scratch/test artifacts, not `lazy-lock.json`).
- `.config/alacritty/` — Alacritty config:
  - `alacritty.toml` — base, self-contained, **no shell block** (so macOS/Linux
    use the login shell). Default window size/placement (no forced size,
    centering, or maximize), Catppuccin Mocha, CaskaydiaCove Nerd Font,
    `Ctrl+Shift+N` for a new window. Symlinked to
    `~/.config/alacritty/alacritty.toml` on macOS/Linux.
  - `shell.windows.toml` — Windows-only `[terminal.shell]` fragment
    (`wsl.exe → zsh`). Appended to the base by `install.sh` on Windows.
- `AutoHotKey/` — Windows scripts: macOS-like editing shortcuts and app-window
  switching.

## Key Configuration Details

**Cross-platform model:** one repo, three targets. The shell/multiplexer stack
runs natively on macOS/Linux and inside WSL2 on Windows. Alacritty is a host
GUI app: symlinked on macOS/Linux, deployed (copied, base + WSL shell) to
`%APPDATA%` on Windows.

**Shell dependencies:** Oh My Zsh (`$HOME/.oh-my-zsh`), `zellij` (auto-starts
via `.zshrc`), `zoxide` (`z` to jump), `eza` (listings), `thefuck` (optional).

**Custom aliases defined in .zshrc:**
- `p` → `cd ~/Project`
- `lsa` → `ls -a`
- `lt` → tree view with eza
- `lta` → tree view including hidden files

## Conventions

- Keep `alacritty.toml` free of OS-specific shell config; Windows specifics go
  in `shell.windows.toml` and are appended at install time.
- Guard platform-specific lines in `.zshrc` (existence checks or `$OSTYPE`) so
  the file stays clean on every platform.
- Keep `install.sh` idempotent.
- For Neovim, don't hand-edit `lazy-lock.json`; change plugins via
  `lua/plugins/` then `:Lazy sync` and commit the regenerated lockfile.
