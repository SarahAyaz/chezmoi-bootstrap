#!/bin/bash
set -euo pipefail

###############################################################################
# Chezmoi Bootstrap - Fresh macOS Setup
# Automates: Xcode CLT → Homebrew → chezmoi → dotfiles → packages
#
# Usage:
#   ./bootstrap.sh
#
###############################################################################

REPO_URL="https://github.com/SarahAyaz/chezmoi-bootstrap.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}→${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }

###############################################################################
# 1. Xcode Command Line Tools
###############################################################################

install_xcode_clt() {
    if xcode-select -p &>/dev/null; then
        log_success "Xcode CLT already installed"
        return 0
    fi
    
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for installation
    while ! xcode-select -p &>/dev/null; do
        echo -n "."
        sleep 10
    done
    echo ""
    log_success "Xcode CLT installed"
}

###############################################################################
# 2. Homebrew
###############################################################################

install_homebrew() {
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH for Apple Silicon
    if [ "$(uname -m)" == "arm64" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
        [ -f ~/.zprofile ] && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    
    log_success "Homebrew installed"
}

###############################################################################
# 3. chezmoi
###############################################################################

install_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        log_success "chezmoi already installed"
        return 0
    fi
    
    log_info "Installing chezmoi..."
    brew install chezmoi
    log_success "chezmoi installed"
}

###############################################################################
# 4. chezmoi init (clone repo + apply dotfiles)
###############################################################################

init_chezmoi() {
    CHEZMOI_DIR="${HOME}/.local/share/chezmoi"
    
    if [ -d "$CHEZMOI_DIR/.git" ]; then
        log_warn "chezmoi already initialized"
        return 0
    fi
    
    log_info "Initializing chezmoi..."
    chezmoi init --apply "$REPO_URL" || return 1
    log_success "chezmoi initialized and dotfiles applied"
}

###############################################################################
# 6. Homebrew bundle (install packages)
###############################################################################

install_packages() {
    local brewfile="${HOME}/.local/share/chezmoi/Brewfile"
    
    if [ ! -f "$brewfile" ]; then
        log_error "Brewfile not found at $brewfile"
        return 1
    fi
    
    log_info "Installing packages from Brewfile..."
    brew bundle --file="$brewfile" || return 1
    log_success "Packages installed"
}

###############################################################################
# 7. macOS System Defaults
###############################################################################

apply_macos_defaults() {
    local defaults_script="${HOME}/.local/share/chezmoi/macos-defaults.sh"
    
    if [ ! -f "$defaults_script" ]; then
        log_warn "macOS defaults script not found, skipping..."
        return 0
    fi
    
    log_info "Applying macOS system defaults..."
    chmod +x "$defaults_script"
    "$defaults_script" || return 1
}

post_install_setup() {
    log_info "Running post-install setup..."
    
    # oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
    fi
    
    # Powerlevel10k
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        log_info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" || true
    fi
    
    log_success "Post-install setup complete"
}

###############################################################################
# Main
###############################################################################

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         Chezmoi Bootstrap - macOS Fresh Setup                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "This will install:"
    echo "  • Xcode Command Line Tools"
    echo "  • Homebrew"
    echo "  • chezmoi (dotfiles manager)"
    echo "  • Your dotfiles (git, zsh, ssh configs)"
    echo "  • Applications & packages"
    echo ""
    echo "Repository: $REPO_URL"
    echo ""
    
    read -p "Proceed? (yes/no): " -r reply
    if [[ ! "$reply" =~ ^[Yy][Ee][Ss]$ ]]; then
        log_warn "Bootstrap cancelled"
        exit 0
    fi
    echo ""
    
    install_xcode_clt || exit 1
    install_homebrew || exit 1
    install_chezmoi || exit 1
    init_chezmoi || exit 1
    install_packages || exit 1
    apply_macos_defaults || exit 1
    post_install_setup || exit 1
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    ✓ Bootstrap Complete!                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Start new shell:  exec zsh"
    echo "  2. Configure Powerlevel10k: p10k configure"
    echo "  3. Verify dotfiles:  chezmoi status"
    echo ""
}

main "$@"
