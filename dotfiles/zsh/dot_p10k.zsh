# Minimal Powerlevel10k Configuration
# For full customization, run: p10k configure

typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

# Left Prompt Segments
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
  status
)

# Right Prompt Segments
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  command_execution_time
  background_jobs
  time
)

# Dir colors
typeset -g POWERLEVEL9K_DIR_FOREGROUND=blue
typeset -g POWERLEVEL9K_DIR_HOME_FOREGROUND=blue
typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND=blue

# Git/VCS colors
typeset -g POWERLEVEL9K_VCS_FOREGROUND=green

# Status colors
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=green
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=black
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=red
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=black

# Time
typeset -g POWERLEVEL9K_TIME_FOREGROUND=white
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

# Command execution time
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow

# Transient prompt - simpler prompt for previous lines
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT_ON_NEWLINE=false
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT_ELEMENTS=(dir)

# Instant prompt
[[ ! -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] || source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
