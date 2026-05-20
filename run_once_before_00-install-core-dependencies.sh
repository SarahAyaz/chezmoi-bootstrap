#!/bin/bash
#
# Bootstrap dependencies required before chezmoi can apply anything else.
#
# Runs exactly once per machine (chezmoi tracks execution by script hash).
# If this script changes, chezmoi will re-run it on the next `chezmoi apply`.
#
# Responsibilities:
#   1. Install Xcode Command Line Tools (provides git, clang, make)
#   2. Install Homebrew (package manager used by later run_onchange_ scripts)
#
# Idempotent: every step is guarded by a presence check.
#
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}→${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error()   { echo -e "${RED}✗${NC} $1" >&2; }

###############################################################################
# 1. Xcode Command Line Tools
###############################################################################
if xcode-select -p &>/dev/null; then
    log_success "Xcode CLT already installed"
else
    log_info "Installing Xcode Command Line Tools (GUI dialog will appear)…"
    xcode-select --install < /dev/tty 2>/dev/null || true
    until xcode-select -p &>/dev/null; do
        printf '.'
        sleep 10
    done
    echo ""
    log_success "Xcode CLT installed"
fi

###############################################################################
# 2. Homebrew
###############################################################################
if [ "$(uname -m)" = "arm64" ]; then
    BREW_BIN="/opt/homebrew/bin/brew"
else
    BREW_BIN="/usr/local/bin/brew"
fi

if command -v brew &>/dev/null; then
    log_success "Homebrew already installed"
else
    log_info "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Persist brew shellenv for future login shells (Apple Silicon).
    if [ "$(uname -m)" = "arm64" ]; then
        if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    fi

    if [ ! -x "$BREW_BIN" ]; then
        log_error "Homebrew binary not found at $BREW_BIN after install"
        exit 1
    fi
    log_success "Homebrew installed"
fi

# Make brew available to subsequent chezmoi scripts in this same run.
eval "$($BREW_BIN shellenv)"
