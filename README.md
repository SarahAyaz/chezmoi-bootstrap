# Chezmoi Bootstrap — macOS Setup

Declarative macOS setup powered by [chezmoi](https://www.chezmoi.io/) +
[Homebrew](https://brew.sh/). Dotfiles, packages, system defaults and
post-install tooling are all driven by chezmoi's native execution model — no
hand-rolled orchestrator script.

---

## Fresh Mac Setup

One command, on a brand-new macOS machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply SarahAyaz/chezmoi-bootstrap
```

chezmoi will:

1. Install itself.
2. Clone this repo into `~/.local/share/chezmoi`.
3. Run scripts in the order dictated by their prefixes (see below).
4. Materialise every `dot_*` / `private_dot_*` file into `$HOME`.

**Time required:** ~20–30 min (mostly Xcode CLT + Homebrew downloads).

After it finishes:

```bash
exec zsh
chezmoi status        # should report no diffs
```

---

## Execution Model

chezmoi runs scripts in a deterministic order. The naming convention encodes
**when** and **how often** each script runs:

| Prefix                  | When chezmoi runs it                                            |
| ----------------------- | --------------------------------------------------------------- |
| `run_once_before_*`     | Once per machine, **before** files are written.                 |
| `run_onchange_after_*`  | Whenever the script's hash changes, **after** files are written. |

Numeric prefixes (`00`, `20`, `30`, `40`) define ordering within a phase.

### Pipeline in this repo

```
run_once_before_00-install-core-dependencies.sh    # Xcode CLT + Homebrew
   │
   ▼
(chezmoi writes dot_* / private_dot_* files into $HOME)
   │
   ▼
run_onchange_after_20-install-packages.sh.tmpl     # brew bundle (Brewfile)
run_onchange_after_30-apply-macos-defaults.sh.tmpl # macos-defaults.sh
run_onchange_after_40-post-install-setup.sh        # oh-my-zsh, p10k, plugins
```

> **Why no `10-apply-dotfiles`?** chezmoi applies dotfiles natively between
> the `before` and `after` phases — no script needed.

### How "re-run on change" works

`run_onchange_*` scripts are re-executed whenever their **post-template**
content changes. The two scripts that depend on external files use chezmoi
templates to embed a hash of the source they care about:

```bash
#   Brewfile hash: {{ include "Brewfile" | sha256sum }}
```

Edit the `Brewfile` → rendered hash changes → script content changes →
chezmoi re-runs it on the next `chezmoi apply`. Same pattern for
`macos-defaults.sh`.

Each script is **atomic** (does one thing) and **idempotent** (safe to re-run).

---

## Repository Layout

```
.
├── Brewfile                                          # Homebrew package list
├── macos-defaults.sh                                 # macOS `defaults write` calls
│
├── dot_aliases                       → ~/.aliases
├── dot_gitconfig                     → ~/.gitconfig
├── dot_gitignore                     → ~/.gitignore
├── dot_p10k.zsh                      → ~/.p10k.zsh
├── dot_zprofile                      → ~/.zprofile
├── dot_zshrc                         → ~/.zshrc
├── private_dot_ssh/private_config    → ~/.ssh/config        (mode 0600)
│
├── run_once_before_00-install-core-dependencies.sh
├── run_onchange_after_20-install-packages.sh.tmpl
├── run_onchange_after_30-apply-macos-defaults.sh.tmpl
└── run_onchange_after_40-post-install-setup.sh
```

`dot_<name>` files are rewritten by chezmoi as `~/.<name>`. The `private_`
prefix tells chezmoi to set restrictive permissions (`0600` / `0700`).

---

## Day-to-Day Workflow

### Sync the latest state to this machine

```bash
chezmoi update     # git pull + apply
# or
chezmoi apply      # apply only what's already in the source dir
```

`chezmoi apply` re-runs any `run_onchange_*` scripts whose hash has changed.

### Edit a dotfile

```bash
chezmoi edit ~/.zshrc      # opens the source file in $EDITOR
chezmoi apply              # write changes back to $HOME
```

### Add a new dotfile

```bash
chezmoi add ~/.config/myapp/config
```

### Add a new package

Edit `Brewfile`, then:

```bash
chezmoi apply              # 20-install-packages re-runs automatically
```

### Tweak a macOS default

Edit `macos-defaults.sh`, then:

```bash
chezmoi apply              # 30-apply-macos-defaults re-runs automatically
```

### Commit & push

```bash
chezmoi cd
git add -A && git commit -m "…"
git push
```

---

## Inspection / Debugging

```bash
chezmoi status                                      # what would change
chezmoi diff                                        # show pending diffs
chezmoi apply -v                                    # verbose apply
chezmoi execute-template < some.tmpl                # preview a template
chezmoi state dump                                  # which scripts have run
chezmoi state delete-bucket --bucket=scriptState    # force all run_onchange to re-run
chezmoi state delete-bucket --bucket=entryState     # force run_once to re-run
```

---

## Troubleshooting

**Xcode CLT dialog never appears**

```bash
xcode-select --install
chezmoi apply
```

**Re-initialise from scratch**

```bash
chezmoi init --force SarahAyaz/chezmoi-bootstrap
chezmoi apply
```

---

## References

- [chezmoi — Scripts](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [chezmoi — Templates](https://www.chezmoi.io/user-guide/templating/)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)

---

## License

See [LICENSE](LICENSE).
