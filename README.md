# dotfiles

Personal dotfiles for **macOS, Ubuntu/Linux, and Windows (via WSL2)** — a
consistent terminal setup everywhere: Alacritty + zsh (Oh My Zsh) + zellij,
with `zoxide`, `eza`, and `thefuck`.

## Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/petrepa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent and adapts to the platform:

- **macOS** — installs `thefuck`, `eza`, `zellij`, `zoxide` via Homebrew.
- **Ubuntu/Linux** — installs `zsh` via apt and drops `zellij`/`zoxide`/`eza`
  binaries into `~/.local/bin` (they aren't reliably in apt). `thefuck` is
  optional (`pipx install thefuck`).
- **Windows** — run it inside **WSL2 (Ubuntu)**. It does the Linux setup *and*
  deploys the Alacritty config to `%APPDATA%\alacritty` on the Windows host.

It also installs Oh My Zsh (if missing), symlinks the configs, and prints the
`chsh` command to make zsh your login shell.

After installing: `source ~/.zshrc` (or restart the terminal), and run
`chsh -s "$(which zsh)"` if zsh isn't your default shell yet.

## What's included

- `.zshrc` — Zsh / Oh My Zsh config (auto-starts zellij). Cross-platform: the
  macOS-only paths are guarded, so it's clean on Linux/WSL too.
- `.config/zellij/` — Zellij terminal multiplexer configuration.
- `.config/alacritty/` — Alacritty terminal emulator configuration:
  - `alacritty.toml` — base config (windowed, Catppuccin Mocha, Nerd Font).
    Used directly on macOS/Linux.
  - `shell.windows.toml` — Windows-only fragment (`wsl.exe → zsh`), appended to
    the base when deploying on Windows.
- `AutoHotKey/` — Windows AutoHotKey scripts (macOS-like keyboard shortcuts).

## Terminal emulator: Alacritty

The Alacritty window opens at its default size with a Nerd Font — no forced
size, centering, or maximize; the OS/window manager handles placement (e.g.
Raycast's Center command on Windows/macOS if you want to center on demand).
`Ctrl+Shift+N` opens a new window. On Windows it launches WSL2 straight into
zsh; on macOS/Linux it uses your login shell.

Requires the **CaskaydiaCove Nerd Font** (from
[nerd-fonts](https://github.com/ryanoasis/nerd-fonts)) installed on the host
for icons/glyphs to render.
