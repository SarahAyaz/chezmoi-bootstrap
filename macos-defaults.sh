#!/bin/bash
# Resilient mode: keep -u (unset vars) and pipefail, but NOT -e.
# Individual `defaults write` calls are allowed to fail; failures are
# collected via an ERR trap and reported in a summary at the end.
set -uo pipefail
set -E   # ensure ERR trap is inherited by functions

###############################################################################
# macOS Defaults Configuration
# Sets up system preferences for a fresh macOS install
# Run after Homebrew installation
#
# Usage:
#   ./macos-defaults.sh
#
# Exit code is ALWAYS 0 — partial failures are non-fatal so that bootstrap
# can continue. Inspect stderr / the final summary for what failed.
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}→${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "${RED}✗${NC} $1" >&2; }

###############################################################################
# Failure tracking
###############################################################################

FAILURES=()
_record_failure() {
    # $1 = exit code, $2 = line number, $3 = command
    FAILURES+=("line $2 (exit $1): $3")
}
trap '_record_failure "$?" "$LINENO" "$BASH_COMMAND"' ERR

###############################################################################
# System Preferences
###############################################################################

set_system_defaults() {
    log_info "Configuring System Preferences..."
    
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "
    
    # Disable asking for password immediately after sleep/screensaver
    defaults write com.apple.screensaver askForPassword -int 0
}

###############################################################################
# Trackpad & Mouse
###############################################################################

set_trackpad_defaults() {
    log_info "Configuring Trackpad..."
    
    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClick -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    
    # Trackpad: increase tracking speed
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
    
    # Mouse: increase tracking speed
    defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5
}

###############################################################################
# Keyboard
###############################################################################

set_keyboard_defaults() {
    log_info "Configuring Keyboard..."
    
    # Key repeat rate (lower = faster)
    defaults write NSGlobalDomain KeyRepeat -int 2
    
    # Delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Enable full keyboard access (Tab in all controls)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    # Disable press-and-hold for accented characters (use key repeat instead)
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
}

###############################################################################
# Finder
###############################################################################

set_finder_defaults() {
    log_info "Configuring Finder..."
    
    # Show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions by default
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true
    
    # Set default folder view to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Disable the warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Set Desktop as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
}

###############################################################################
# Dock
###############################################################################

set_dock_defaults() {
    log_info "Configuring Dock..."
    
    # Auto-hide the dock
    defaults write com.apple.dock autohide -bool true
    
    # Minimize windows into their application icon
    defaults write com.apple.dock minimize-to-app-icon -bool true
    
    # Set dock size (pixel value)
    defaults write com.apple.dock tilesize -int 48
    
    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    
    # Don't show Dashboard as a Space
    defaults write com.apple.dock dashboard-in-overlay -bool true
    
    # Dock position: left (uncomment to change)
    # defaults write com.apple.dock orientation -string left
}

###############################################################################
# Mission Control & Spaces
###############################################################################

set_mission_control_defaults() {
    log_info "Configuring Mission Control..."
    
    # Speed up Mission Control animation
    defaults write com.apple.dock expose-animation-duration -float 0.12
    
    # Don't rearrange spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false
}

###############################################################################
# Appearance
###############################################################################

set_appearance_defaults() {
    log_info "Configuring Appearance..."
    
    # Use dark appearance (change to "Light" for light mode)
    # defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    # Enable subpixel font rendering on non-Apple displays
    defaults write NSGlobalDomain AppleFontSmoothing -int 2
}

###############################################################################
# Safari
###############################################################################

set_safari_defaults() {
    log_info "Configuring Safari..."
    
    # Show the full URL in the address bar
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
    
    # Enable the Develop menu and Web Inspector
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    
    # Make Safari's search banners default to Contains instead of Starts With
    defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
}

###############################################################################
# Screenshots
###############################################################################

set_screenshots_defaults() {
    log_info "Configuring Screenshots..."
    
    # Save screenshots to Desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    
    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
}

###############################################################################
# Activity Monitor
###############################################################################

set_activity_monitor_defaults() {
    log_info "Configuring Activity Monitor..."
    
    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
    
    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5
    
    # Show all running processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    
    # Sort Activity Monitor window by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
}

###############################################################################
# Restart Services
###############################################################################

restart_services() {
    log_info "Restarting services to apply changes..."
    
    # Restart Dock
    killall Dock 2>/dev/null || true
    
    # Restart Finder
    killall Finder 2>/dev/null || true
    
    # Restart SystemUIServer (menu bar)
    killall SystemUIServer 2>/dev/null || true
}

###############################################################################
# Main
###############################################################################

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              macOS System Preferences Configuration            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    set_system_defaults
    set_trackpad_defaults
    set_keyboard_defaults
    set_finder_defaults
    set_dock_defaults
    set_mission_control_defaults
    set_appearance_defaults
    set_safari_defaults
    set_screenshots_defaults
    set_activity_monitor_defaults
    
    restart_services
    
    echo ""
    if [ "${#FAILURES[@]}" -eq 0 ]; then
        log_success "macOS defaults applied successfully"
    else
        log_warn "macOS defaults applied with ${#FAILURES[@]} non-fatal failure(s):"
        for f in "${FAILURES[@]}"; do
            echo "    - $f" >&2
        done
        log_warn "Continuing — these failures are non-fatal."
    fi
    echo ""
    echo "Note: Some changes require a restart to take effect."
    echo ""
    # Always succeed so the bootstrap pipeline keeps going.
    return 0
}

main "$@"
exit 0
