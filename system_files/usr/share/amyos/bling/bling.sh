#!/usr/bin/env sh

# Check if bling has already been sourced so that we dont break atuin. https://github.com/atuinsh/atuin/issues/380#issuecomment-1594014644
[ "${BLING_SOURCED:-0}" -eq 1 ] && return
BLING_SOURCED=1

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

if [ "$(basename "$0")" = "bash" ]; then
  [ -f "/usr/share/bash-prexec" ] && . "/usr/share/bash-prexec"
  [ "$(command -v starship)" ] && eval "$(starship init bash)"
  [ "$(command -v atuin)" ] && eval "$(atuin init bash ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
elif [ "$(basename "$0")" = "zsh" ]; then
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ "$(command -v starship)" ] && eval "$(starship init zsh)"
  [ "$(command -v atuin)" ] && eval "$(atuin init zsh ${ATUIN_INIT_FLAGS})"
  [ "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
  [ "$(command -v thefuck)" ] && eval "$(thefuck --alias)"
fi
