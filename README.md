# dotfiles

Personal dotfiles for **macOS, Ubuntu/Linux, and Windows (via WSL2)** — a
consistent terminal setup everywhere: Alacritty + zsh (Oh My Zsh) + Neovim
(LazyVim), with `zoxide`, `eza`, and `thefuck`, plus a multiplexer (herdr, or
zellij) that runs on the one machine where the agents run — see
[Where things run](#where-things-run).

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
- **both** — installs [herdr](https://herdr.dev) with its own installer (one
  binary in `~/.local/bin`).
- **Windows** — run it inside **WSL2 (Ubuntu)**. It does the Linux setup *and*
  deploys the Alacritty config to `%APPDATA%\alacritty` on the Windows host.

It also installs Oh My Zsh (if missing), symlinks the configs, and prints the
`chsh` command to make zsh your login shell.

After installing: `source ~/.zshrc` (or restart the terminal), and run
`chsh -s "$(which zsh)"` if zsh isn't your default shell yet.

## What's included

- `.zshrc` — Zsh / Oh My Zsh config. Cross-platform: the macOS-only paths
  are guarded, so it's clean on Linux/WSL too. On SSH logins it lands in the
  host's persistent multiplexer session (herdr if installed, else zellij);
  locally it starts nothing.
- `.config/herdr/config.toml` — herdr (agent-aware multiplexer) config. Only
  this file is tracked; herdr keeps logs/sockets/session state next to it.
- `.config/zellij/` — Zellij configuration: a minimal `config.kdl` (tokyo-night
  theme, direct Alt+u/d scrolling) plus `themes/`, including the orange
  `sandbox` theme that `.zshrc` selects on remote hosts only.
- `ssh/rc` — linked to `~/.ssh/rc`; keeps a stable link to the forwarded
  ssh-agent socket on hosts you SSH into (see below). Inert elsewhere.
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
- `gnome/` — GNOME shortcut tweaks (Linux only, skipped on WSL). Currently
  disables the Alt+1..9 "switch to application" dash shortcuts, since app
  launching is handled by ulauncher instead — this frees Alt+<digit> for
  apps that want it themselves (e.g. KiCad's Alt+1/2/3 view shortcuts).

## Where things run

One multiplexer, on the machine where the agents run. Agentic work (Claude
Code) happens on a remote sandbox VM (`ssh aviant-sandbox`); every local
station — this Ubuntu/GNOME laptop, a Windows/WSL desktop, an Omarchy laptop —
is just a client of it.

**Locally:** Alacritty is a plain terminal, nothing auto-starts. One window per
task (`Ctrl+Shift+N`), the window manager tiles them (GNOME's Tiling Assistant,
Hyprland, Windows). When panes are wanted locally: `zj [name]` attaches to a
local zellij session by hand.

**Remote (sandbox):** a persistent server keeps the panes and agents running
between connections. `.zshrc` `exec`s into it on SSH logins:

- **herdr** (default when installed) — shows which agent in each pane is
  working, idle or blocked. From a laptop, `herdr --remote aviant-sandbox`
  draws the remote session with the local UI/keys; it uses OpenSSH, so
  `~/.ssh/config` aliases and `ForwardAgent` apply. From a phone/tablet SSH
  client, `ssh aviant-sandbox` lands in the same session. Prefix `Ctrl+b`
  (`prefix+q` detaches).
- **zellij** (fallback when herdr is absent) — `zellij attach -c main` with
  the orange `sandbox` theme, so it can never be mistaken for a local session.

Because `.zshrc` `exec`s the multiplexer, a crash on login closes the SSH
session. Escape hatches: `ssh -t aviant-sandbox bash` (skips `.zshrc`) or
`ssh -t aviant-sandbox 'NO_MUX=1 zsh'` (this config, no multiplexer). Shells
inside a pane never re-trigger it (`$HERDR_ENV` / `$ZELLIJ` / `$TMUX`).

**Git on the sandbox** uses the laptop's ssh-agent via `ForwardAgent yes` — no
private keys on the VM. Two things make that survive a long-lived session:
`~/.ssh/rc` (from `ssh/rc`) relinks `~/.ssh/ssh_auth_sock` to the newest live
forwarded socket whenever the old one is dead, and `.zshrc` points every SSH
shell at that link instead of the per-connection path. `.zshrc` never starts a
local agent over SSH. `ssh-add -l` on the laptop should list the key; on the
VM it lists the same keys.

Handy on the laptop side, in `~/.ssh/config` (not in this repo):
`ControlMaster auto` + `ControlPersist` for the sandbox host, so every
`ssh`/`scp`/`herdr --remote` shares one connection and one forwarded socket.

## Terminal emulator: Alacritty

The Alacritty window opens at its default size with a Nerd Font — no forced
size, centering, or maximize; the OS/window manager handles placement (e.g.
Raycast's Center command on Windows/macOS if you want to center on demand).
`Ctrl+Shift+N` opens a new window. On Windows it launches WSL2 straight into
zsh; on macOS/Linux it uses your login shell.

Requires the **CaskaydiaMono Nerd Font** (from
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
handled by `install.sh`. Uses the same CaskaydiaMono Nerd Font as Alacritty.
