# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for a consistent terminal setup across **macOS, Ubuntu/Linux,
and Windows (via WSL2)**: Alacritty + zsh (Oh My Zsh) + Neovim (LazyVim), plus
`zoxide`, `eza`, `thefuck`, and herdr as the only multiplexer, running on the
remote sandbox where the agents run. Configs are symlinked from this repo into
`$HOME`. `docs/station-setup-prompt.md` is the prompt for bringing a new
machine onto this setup.

## Installation

```bash
./install.sh
```

`install.sh` detects the platform (`$OSTYPE`, plus `/proc/version` for WSL) and:
- **macOS**: installs deps via Homebrew (thefuck, eza, zoxide, neovim,
  ripgrep, fd, fzf, lazygit).
- **Linux**: installs apt packages that need root (`zsh`, `build-essential`,
  `unzip`, `ripgrep`); installs `zoxide`/`eza`/`fd`/`fzf`/`lazygit` as
  prebuilt binaries into `~/.local/bin`, and Neovim into `~/.local/opt/nvim`
  (symlinked to `~/.local/bin/nvim`); `thefuck` is optional.
- **both**: installs `herdr` via `curl -fsSL https://herdr.dev/install.sh | sh`
  (one binary in `~/.local/bin`), skipped when already on PATH.
- Installs Oh My Zsh if missing.
- Symlinks `.zshrc`, `.config/nvim`, `.config/alacritty/alacritty.toml`,
  `.config/herdr/config.toml`, and `ssh/rc` → `~/.ssh/rc` (backing up
  existing non-symlink files to `*.backup`); removes dangling links of
  retired configs (`~/.config/zellij`).
- **WSL only**: also deploys Alacritty to the Windows host by concatenating
  `alacritty.toml` + `shell.windows.toml` into `%APPDATA%\alacritty\alacritty.toml`.

After installation: `source ~/.zshrc` or restart the terminal; run
`chsh -s "$(which zsh)"` if zsh isn't the login shell.

## Structure

- `.zshrc` — Oh My Zsh (`robbyrussell` theme, `git` plugin). Adds
  `~/.local/bin` to PATH; macOS-only paths and `thefuck`/`zoxide` init are
  guarded so it's portable across all three platforms. Two blocks branch on
  `$SSH_CONNECTION` (see "Where things run" below): the ssh-agent block and
  the multiplexer auto-start.
- `.config/herdr/config.toml` — herdr config, the only tracked file in
  `~/.config/herdr` (herdr writes logs, sockets and `session.json` there).
- `docs/station-setup-prompt.md` — self-contained prompt to paste into Claude
  Code on a new machine (Ubuntu/GNOME, Windows/WSL2, Omarchy/Arch, macOS) to
  bring it onto this setup and verify it.
- `ssh/rc` — sshd runs `~/.ssh/rc` at the start of every SSH session. Keeps
  `~/.ssh/ssh_auth_sock` linked to a live forwarded agent socket. Must never
  print (sshd pipes its output into the session, which breaks scp/sftp).
- `.config/nvim/` — Neovim / [LazyVim](https://www.lazyvim.org/) config (whole
  dir symlinked to `~/.config/nvim`). `init.lua` bootstraps lazy.nvim; personal
  config in `lua/config/`, plugin specs/overrides in `lua/plugins/`.
  `lazy-lock.json` pins plugin versions — commit it after `:Lazy sync`. The
  starter's own `.git`/`README`/`LICENSE` were stripped; its `.gitignore` is
  kept (it only ignores scratch/test artifacts, not `lazy-lock.json`).
- `.config/alacritty/` — Alacritty config:
  - `alacritty.toml` — base, self-contained, **no shell block** (so macOS/Linux
    use the login shell). Default window size/placement (no forced size,
    centering, or maximize), Catppuccin Mocha, CaskaydiaMono Nerd Font Mono,
    `Ctrl+Shift+N` for a new window. Symlinked to
    `~/.config/alacritty/alacritty.toml` on macOS/Linux.
  - `shell.windows.toml` — Windows-only `[terminal.shell]` fragment
    (`wsl.exe → zsh`). Appended to the base by `install.sh` on Windows.
- `AutoHotKey/` — Windows scripts: macOS-like editing shortcuts and app-window
  switching.
- `gnome/` — `disable-app-switch-shortcuts.sh` clears GNOME's
  `switch-to-application-1..9` keybindings (Alt+1..9 dash app launching), run
  by `install.sh` on native Linux (skipped under WSL). Frees Alt+<digit> for
  app-level shortcuts since ulauncher (Super+space) is the app launcher.

## Key Configuration Details

**Cross-platform model:** one repo, three targets. The shell/multiplexer stack
runs natively on macOS/Linux and inside WSL2 on Windows. Alacritty is a host
GUI app: symlinked on macOS/Linux, deployed (copied, base + WSL shell) to
`%APPDATA%` on Windows.

**Shell dependencies:** Oh My Zsh (`$HOME/.oh-my-zsh`), `herdr` (multiplexer,
used on the remote host; the client everywhere), `zoxide` (`z` to jump), `eza`
(listings), `thefuck` (optional).

**Where things run:** one multiplexer, on the machine where the agents run
(the AWS sandbox, `ssh aviant-sandbox`). Local stations (Ubuntu/GNOME laptop,
Windows/WSL desktop, Omarchy laptop) run a plain Alacritty and never
auto-start a multiplexer — a local one wrapped around `ssh` nests two and
steals the inner one's keys. `.zshrc` behaves per host by testing
`$SSH_CONNECTION`, not hostnames:

- **SSH login (sandbox):** `exec herdr` when installed. Guarded by
  `$HERDR_ENV`/`$TMUX` (pane shells inherit `SSH_CONNECTION`) and `NO_MUX=1`.
  Escape hatches when herdr crashes on login: `ssh -t aviant-sandbox bash`,
  or `ssh -t aviant-sandbox 'NO_MUX=1 zsh'`. `herdr --remote aviant-sandbox`
  from a laptop attaches the same server through OpenSSH (ssh config aliases
  and `ForwardAgent` apply; the server is started over a non-interactive ssh
  command, so this branch never fires for it). Prefix `Ctrl+b`.
- **Local:** no auto-start, nothing to attach to.

**Agent forwarding on the sandbox:** git there authenticates with the
laptop's agent (`ForwardAgent yes`); no private key should be needed on the
VM. `ssh/rc` relinks `~/.ssh/ssh_auth_sock` to the new connection's socket
only when the current link is dead (so `scp`/`ssh host cmd`/herdr's bridge
never hijack a live one), and `.zshrc` exports that link path in every SSH
shell, so panes created by an earlier connection recover after a reconnect.
Over SSH `.zshrc` never sources `~/.ssh/agent.env` or starts an agent — doing
so hid the forwarded agent behind a local one. Locally the agent block is
unchanged (start/reuse one agent, auto-load `id_ed25519`).

**Keys through the stack:** Alt+<key> reaches the remote herdr as
ESC-prefixed bytes over ssh, unchanged by Alacritty or GNOME (the `gnome/`
tweak frees Alt+1..9 for apps like KiCad; herdr switches tabs with
`prefix+digit`, so it does not depend on it).

**Custom aliases defined in .zshrc:**
- `p` → `cd ~/Project`
- `ls` → `eza` listing (icons, hyperlinks, dirs first)
- `lsa` → `ls -a`
- `lt` → tree view with eza
- `lta` → tree view including hidden files
- `personal-claude` / `work-claude` → launch `claude` with `CLAUDE_CONFIG_DIR`
  pointed at `~/.claude-personal` / `~/.claude-work` so each account's
  credentials/config stay isolated

## Conventions

- Keep `alacritty.toml` free of OS-specific shell config; Windows specifics go
  in `shell.windows.toml` and are appended at install time.
- Guard platform-specific lines in `.zshrc` (existence checks or `$OSTYPE`) so
  the file stays clean on every platform. Host-role differences (local vs
  sandbox) branch on `$SSH_CONNECTION`, never on hostnames.
- Keep `install.sh` idempotent.
- Only `config.toml` under `.config/herdr/` is tracked; never add herdr's
  logs, sockets or `session.json`.
- `ssh/rc` must stay silent and only touch the agent-socket link.
- For Neovim, don't hand-edit `lazy-lock.json`; change plugins via
  `lua/plugins/` then `:Lazy sync` and commit the regenerated lockfile.
