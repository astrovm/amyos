#!/usr/bin/env sh

# Check if bling has already been sourced in the current shell
if [ -n "$BASH_VERSION" ]; then
  [ "${BASH_BLING_SOURCED:-0}" -eq 1 ] && return
  BASH_BLING_SOURCED=1
elif [ -n "$ZSH_VERSION" ]; then
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

# Atuin allows these flags: "--disable-up-arrow" and/or "--disable-ctrl-r"
ATUIN_INIT_FLAGS=${ATUIN_INIT_FLAGS:-"--disable-up-arrow"}

if [ -n "$BASH_VERSION" ]; then
  [ -f "/usr/share/bash-prexec" ] && . "/usr/share/bash-prexec"
  [ "$(command -v starship)" ] && eval "$(starship init bash)"
  [ "$(command -v atuin)" ] && eval "$(atuin init bash ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
elif [ -n "$ZSH_VERSION" ]; then
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ "$(command -v starship)" ] && eval "$(starship init zsh)"
  [ "$(command -v atuin)" ] && eval "$(atuin init zsh ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
fi
