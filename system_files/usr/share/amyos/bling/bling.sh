#!/usr/bin/env sh

# Get current shell name
CURRENT_SHELL="$(basename "$0")"

# Check if bling has already been sourced in the current shell
if [ "$CURRENT_SHELL" = "bash" ]; then
  [ "${BASH_BLING_SOURCED:-0}" -eq 1 ] && return
  BASH_BLING_SOURCED=1
elif [ "$CURRENT_SHELL" = "zsh" ]; then
  [ "${ZSH_BLING_SOURCED:-0}" -eq 1 ] && return
  ZSH_BLING_SOURCED=1
fi

# ls aliases
if [ "$(command -v eza)" ]; then
  alias ll='eza -l --icons=auto --group-directories-first'
  alias l.='eza -d .*'
  alias ls='eza'
  alias l1='eza -1'
fi

# ugrep for grep
if [ "$(command -v ug)" ]; then
  alias grep='ug'
  alias egrep='ug -E'
  alias fgrep='ug -F'
  alias xzgrep='ug -z'
  alias xzegrep='ug -zE'
  alias xzfgrep='ug -zF'
fi

# set ATUIN_INIT_FLAGS in your ~/.bashrc before ublue-bling is sourced.
# Atuin allows these flags: "--disable-up-arrow" and/or "--disable-ctrl-r"
ATUIN_INIT_FLAGS=${ATUIN_INIT_FLAGS:-"--disable-up-arrow"}

if [ "$CURRENT_SHELL" = "bash" ]; then
  [ -f "/usr/share/bash-prexec" ] && . "/usr/share/bash-prexec"
  [ "$(command -v starship)" ] && eval "$(starship init bash)"
  [ "$(command -v atuin)" ] && eval "$(atuin init bash ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
elif [ "$CURRENT_SHELL" = "zsh" ]; then
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ "$(command -v starship)" ] && eval "$(starship init zsh)"
  [ "$(command -v atuin)" ] && eval "$(atuin init zsh ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
fi
