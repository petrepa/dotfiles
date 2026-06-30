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
- `AutoHotKey/` — Windows AutoHotKey scripts (macOS-like keyboard shortcuts and
  centering Alacritty on launch).

## Terminal emulator: Alacritty

The Alacritty window is non-maximized (110×32) with a Nerd Font. On Windows it
launches WSL2 straight into zsh, and `AutoHotKey/niceToHaves.ahk` centers each
new Alacritty window (Alacritty has no native centering). On macOS/Linux,
Alacritty uses your login shell and the window manager handles placement.

Requires the **CaskaydiaCove Nerd Font** (from
[nerd-fonts](https://github.com/ryanoasis/nerd-fonts)) installed on the host
for icons/glyphs to render.
