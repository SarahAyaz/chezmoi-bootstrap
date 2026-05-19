# Chezmoi Bootstrap - macOS Setup

Automate macOS setup with [chezmoi](https://www.chezmoi.io/) (dotfiles) and [Homebrew](https://brew.sh/) (packages).

---

## Fresh Mac Setup

For a brand new macOS machine, run this command:

```bash
curl https://raw.githubusercontent.com/SarahAyaz/chezmoi-bootstrap/main/bootstrap.sh | bash
```

**That's it.** The script will:
1. Install Xcode Command Line Tools (you'll see a dialog — click "Install")
2. Install Homebrew
3. Clone this repo with chezmoi
4. Apply your dotfiles
5. Install all packages from Brewfile
6. Configure macOS system defaults (Dock, Finder, Trackpad, Keyboard, etc.)
7. Install oh-my-zsh and Powerlevel10k theme

**Time required:** 20-30 minutes (mostly Xcode CLT)

### During the Script

When prompted:
```
Proceed? (yes/no):
```

Type `yes` and press Enter.

### After the Script Completes

1. Start a new shell:
   ```bash
   exec zsh
   ```

2. Verify everything worked:
   ```bash
   chezmoi status
   git config --list | grep user
   ```

---

## Managing Existing Mac

To sync the latest dotfiles and packages to a Mac that already has this setup:

```bash
chezmoi pull
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

Or re-run the bootstrap script (it skips already-installed components):

```bash
~/.local/share/chezmoi/bootstrap.sh
```

---

## What Gets Installed

### Dotfiles
- `~/.gitconfig` — Git config
- `~/.zshrc` — Shell config
- `~/.zprofile` — Shell profile
- `~/.ssh/config` — SSH config
- `~/.aliases` — Shell aliases
- `~/.p10k.zsh` — Powerlevel10k configuration

### Packages & Applications
See [Brewfile](Brewfile) for complete list:
- Development tools (Node, Python, Terraform, Docker, Azure CLI, etc.)
- Applications (VS Code, iTerm2, Firefox, Docker Desktop, Slack, etc.)

### System Defaults (macOS Configuration)
Automatically configured via `macos-defaults.sh`:
- **Trackpad** — Tap to click, tracking speed, secondary click
- **Keyboard** — Key repeat rate, full keyboard access
- **Finder** — Show hidden files, file extensions, path bar, list view by default
- **Dock** — Auto-hide, application icon minimization, size, position
- **Mission Control** — Animation speed, space ordering
- **Safari** — Developer menu, full URL display
- **Screenshots** — Save location, format (PNG), disable shadow

---

## Common Tasks

### Customize Powerlevel10k Prompt

A minimal Powerlevel10k config is included. To customize your prompt interactively:

```bash
p10k configure
```

Your customized config is automatically saved to `~/.p10k.zsh`. Commit it to sync across machines:

```bash
cd ~/.local/share/chezmoi
chezmoi add ~/.p10k.zsh
git add -A && git commit -m "Update powerlevel10k config"
git push
```

### Add a New Dotfile

```bash
chezmoi add ~/.config/myapp/config
```

### Add a New Package

Edit [Brewfile](Brewfile), then run:

```bash
brew bundle install --file=~/.local/share/chezmoi/Brewfile
```

### Update Packages

```bash
brew update
brew upgrade
```

### Check What's Different

```bash
chezmoi status
```

### Commit Changes

```bash
cd ~/.local/share/chezmoi
git add -A
git commit -m "Update dotfiles"
git push
```

---

## Troubleshooting

### Xcode CLT Installation Dialog Doesn't Appear

Run manually:
```bash
xcode-select --install
```

Then re-run the bootstrap script.

### Git Config Not Applied

Check the current config:
```bash
git config --list | grep user
```

If needed, update manually:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### chezmoi Already Initialized

The script will skip if already initialized. To force reinitialize:
```bash
chezmoi init --force https://github.com/SarahAyaz/chezmoi-bootstrap.git
```

---

## References

- [chezmoi Documentation](https://www.chezmoi.io/)
- [Homebrew](https://brew.sh/)
- [oh-my-zsh](https://ohmyz.sh/)

---

## License

See [LICENSE](LICENSE).
