# dotfiles

Personal dotfiles for **macOS, Ubuntu/Linux, and Windows (via WSL2)** — a
consistent terminal setup everywhere: Alacritty + zsh (Oh My Zsh) + zellij +
Neovim (LazyVim), with `zoxide`, `eza`, and `thefuck`.

## Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/petrepa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent and adapts to the platform:

- **macOS** — installs `thefuck`, `eza`, `zellij`, `zoxide`, `neovim`,
  `ripgrep`, `fd`, `fzf`, `lazygit` via Homebrew.
- **Ubuntu/Linux** — installs `zsh` + the Neovim toolchain
  (`build-essential`, `unzip`, `ripgrep`) via apt, and drops
  `zellij`/`zoxide`/`eza`/`neovim`/`fd`/`fzf`/`lazygit` binaries into
  `~/.local/bin` (they aren't reliably in apt). `thefuck` is optional
  (`pipx install thefuck`).
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
- `.config/nvim/` — Neovim configuration based on
  [LazyVim](https://www.lazyvim.org/). The full config dir is symlinked to
  `~/.config/nvim`; `lazy-lock.json` pins plugin versions for reproducible
  installs. Personal tweaks live in `lua/config/` and `lua/plugins/`.
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

## Editor: Neovim + LazyVim

`.config/nvim/` is a [LazyVim](https://www.lazyvim.org/) setup. On first launch,
`nvim` bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim), installs all
plugins (pinned by `lazy-lock.json`), and Mason pulls LSP servers, formatters,
and linters on demand.

Customize it in:

- `lua/config/` — `options.lua`, `keymaps.lua`, `autocmds.lua`, `lazy.lua`.
- `lua/plugins/` — one file per plugin override/addition. `example.lua` is a
  disabled reference; copy from it. Enable LazyVim **Extras** with `:LazyExtras`
  (this edits `lua/config/lazy.lua` / adds plugin specs you then commit).

After changing plugins, run `:Lazy sync`, then commit the updated
`lazy-lock.json` so other machines install the same versions. Requires a C
compiler (`build-essential`) for `nvim-treesitter` and `unzip` for Mason — both
handled by `install.sh`. Uses the same CaskaydiaCove Nerd Font as Alacritty.
