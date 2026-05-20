#!/bin/bash
#
# Post-install setup: oh-my-zsh + Powerlevel10k theme.
#
# Re-runs whenever this script changes. Each step is idempotent (skipped
# when the target directory already exists), so it is safe to re-run.
#
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}→${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }

# oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing oh-my-zsh…"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_success "oh-my-zsh already installed"
fi

# Powerlevel10k
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    log_info "Installing Powerlevel10k…"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    log_success "Powerlevel10k already installed"
fi

# zsh-syntax-highlighting
ZSH_HL_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
if [[ ! -d "$ZSH_HL_DIR" ]]; then
    log_info "Installing zsh-syntax-highlighting…"
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_HL_DIR"
else
    log_success "zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
ZSH_AS_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AS_DIR" ]]; then
    log_info "Installing zsh-autosuggestions…"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AS_DIR"
else
    log_success "zsh-autosuggestions already installed"
fi

log_success "Post-install setup complete"
