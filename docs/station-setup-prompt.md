# New-station setup prompt

Paste everything below the line into Claude Code on a machine that should join
this setup (Ubuntu/GNOME laptop, Windows desktop via WSL2, Omarchy/Arch laptop,
macOS). It is self-contained: the agent reads the repo for details.

---

Set up this machine as a station of my dotfiles setup. Repo:
https://github.com/petrepa/dotfiles (clone with SSH,
`git@github.com:petrepa/dotfiles.git`, into `~/dotfiles` unless a clone
already exists somewhere — check `readlink -f ~/.zshrc` first). Read its
`CLAUDE.md` and `README.md` before doing anything, and follow the conventions
in `CLAUDE.md`: guard platform-specific lines, keep `install.sh` idempotent,
never hand-edit `lazy-lock.json`, commit in small logical commits.

## The model this machine joins

- All agentic work (Claude Code) runs on one remote VM, the AWS sandbox
  (`ssh aviant-sandbox`, Ubuntu 24.04, 2 GB RAM). Every other machine is a
  client of it, and this machine is one of those clients.
- **One multiplexer, on the sandbox: herdr** (https://herdr.dev). `.zshrc`
  `exec`s into it on SSH logins there. Locally nothing auto-starts; Alacritty
  is a plain terminal, one window per task (`Ctrl+Shift+N`), the window
  manager tiles. From here I attach with either `ssh aviant-sandbox` or
  `herdr --remote aviant-sandbox` (local herdr client, remote server, over
  OpenSSH, so `~/.ssh/config` applies).
- Git on the sandbox authenticates through **ssh-agent forwarding** from the
  client machine (`ForwardAgent yes`); no private keys live on the VM.
  `ssh/rc` in the repo (linked to `~/.ssh/rc`) keeps a stable link to the
  forwarded socket on the VM so long-lived panes survive reconnects. Nothing
  about that needs doing on this machine beyond forwarding the agent.
- Escape hatches if the sandbox login `exec` misbehaves:
  `ssh -t aviant-sandbox bash` or `ssh -t aviant-sandbox 'NO_MUX=1 zsh'`.

## Steps

1. **Detect the platform** (`$OSTYPE`, `/proc/version` for WSL,
   `/etc/os-release`, `$XDG_CURRENT_DESKTOP`) and tell me what you found
   before changing anything. Then apply the platform notes below.
2. **Clone and install.** Run `./install.sh`. It installs the toolchain,
   herdr, Oh My Zsh, and symlinks `.zshrc`, `.config/nvim`,
   `.config/alacritty/alacritty.toml`, `.config/herdr/config.toml` and
   `~/.ssh/rc` (backing up non-symlink files to `*.backup`). Read the output;
   fix what fails at the source (in `install.sh`, guarded for this platform)
   rather than working around it locally.
3. **Font.** Install the CaskaydiaMono Nerd Font for the platform (see the
   platform notes) so Alacritty and Neovim render glyphs.
4. **Login shell.** `chsh -s "$(command -v zsh)"` if it is not zsh already.
5. **SSH to the sandbox.** Look at `~/.ssh/config`; add this host if missing
   (this file is machine-local and never committed):

   ```
   Host aviant-sandbox
     User ubuntu
     Hostname 13.49.44.153
     IdentityFile ~/.ssh/id_ed25519
     ForwardAgent yes
     ControlMaster auto
     ControlPath ~/.ssh/sockets/%r@%h-%p
     ControlPersist 10m
     ServerAliveInterval 15
     ServerAliveCountMax 3
   ```

   `mkdir -p ~/.ssh/sockets`. If `~/.ssh/id_ed25519` does not exist, generate
   one (`ssh-keygen -t ed25519 -C "<hostname>"`), print the public key, and
   **stop and ask me** to add it to the sandbox's `~/.ssh/authorized_keys`
   (and to GitHub) from a machine that already has access. Do not try to
   copy keys from anywhere else.
6. **ssh-agent.** `.zshrc` starts and reuses one agent locally (state in
   `~/.ssh/agent.env`) and auto-loads `~/.ssh/id_ed25519`; on desktops that
   ship their own agent (GNOME keyring, macOS) it just uses that one. Confirm
   `ssh-add -l` in a fresh shell lists the key.
7. **Verify** (all must pass; report each):
   - a new Alacritty window opens plain zsh, no multiplexer, prompt and icons
     render;
   - `ssh aviant-sandbox` lands in herdr (`Ctrl+b q` detaches; `Ctrl+b ?` is
     help);
   - inside a herdr pane on the sandbox, `ssh-add -l` lists this machine's key
     and `git -C ~/dotfiles pull` works — that proves forwarding through the
     stable link;
   - `herdr --remote aviant-sandbox` from here attaches to the same session
     (`herdr --version` here and on the VM should match; run `herdr update`
     if not);
   - `ssh -t aviant-sandbox bash` gives a plain shell;
   - `./install.sh` a second time changes nothing and downloads nothing.
8. **Commit** any repo changes you had to make (platform guards, new
   `install.sh` branch) in small commits, and push. Tell me what you changed
   and anything you could not verify.

## Platform notes

**Windows desktop (WSL2 Ubuntu).** Run everything inside WSL. `install.sh`
detects WSL and also deploys the Alacritty config to `%APPDATA%\alacritty`
on the Windows host (base + `shell.windows.toml`, which launches
`wsl.exe -e zsh`). The Nerd Font is installed on Windows, not in WSL. The
`~/.ssh/config`, key and agent all live inside WSL (that is where `ssh` and
`herdr` run). Windows Terminal is not part of the setup; Alacritty is.

**Omarchy (Arch + Hyprland).** `install.sh` has no pacman branch yet — add
one (guarded with `command -v pacman`), keep the apt branch intact, and
prefer pacman packages (`zsh`, `base-devel`, `unzip`, `ripgrep`, `fd`, `fzf`,
`eza`, `zoxide`, `neovim`, `lazygit`, `ttf-cascadia-mono-nerd`) over the
prebuilt-binary downloads. Before symlinking, check what Omarchy already
manages: its Alacritty config imports the active Omarchy theme, and it ships
its own LazyVim config and bash setup with `~/.local/share/omarchy/bin` on
PATH. Do not silently overwrite those — show me the conflict and propose the
smallest change (for example keep Omarchy's Alacritty config and carry over
only the font and keybindings; add a guarded PATH line for Omarchy's bin dir
to `.zshrc`). Hyprland tiles windows itself; the GNOME script must not run
there (it is already gated on `$XDG_CURRENT_DESKTOP`; verify it stays
skipped).

**Ubuntu/GNOME.** Nothing extra; `install.sh` also clears GNOME's Alt+1..9 app
shortcuts. If apt's Alacritty is older than 0.14 it does not understand the
`[general]` table in `alacritty.toml` (only `live_config_reload` is lost, and
it logs a warning); mention it, do not work around it in the repo.

**macOS.** Homebrew handles the packages; the Nerd Font comes from the
`homebrew/cask-fonts` cask; `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`
once so the key persists across logins.

## Do not

- Commit `~/.ssh/config`, keys, `agent.env`, or anything machine-specific.
- Add zellij or tmux back, or any local auto-started multiplexer.
- Track herdr's logs, sockets or `session.json` — only its `config.toml`.
- Make `~/.ssh/rc` print anything (it runs on every SSH session; output
  breaks scp/sftp).
- Put host names in `.zshrc`; host-role logic branches on `$SSH_CONNECTION`.
