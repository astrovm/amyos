#!/usr/bin/env sh

# Determine shell and prevent double-sourcing
[ -z "$BASH_VERSION" ] && [ -z "$ZSH_VERSION" ] && return
[ -n "$BASH_VERSION" ] && shell="bash" && [ "${BASH_BLING_SOURCED:-0}" -eq 1 ] && return || BASH_BLING_SOURCED=1
[ -n "$ZSH_VERSION" ] && shell="zsh" && [ "${ZSH_BLING_SOURCED:-0}" -eq 1 ] && return || ZSH_BLING_SOURCED=1

# Set up aliases if commands exist
for cmd in eza ug; do
  command -v "$cmd" >/dev/null && {
    case "$cmd" in
    eza)
      alias ls='eza'
      alias ll='eza -l --icons=auto --group-directories-first'
      alias l.='eza -d .*'
      alias l1='eza -1'
      ;;
    ug)
      alias grep='ug'
      alias egrep='ug -E'
      alias fgrep='ug -F'
      alias xzgrep='ug -z'
      alias xzegrep='ug -zE'
      alias xzfgrep='ug -zF'
      ;;
    esac
  }
done

# Shell-specific configurations
case "$shell" in
bash)
  [ -f "/usr/share/bash-prexec" ] && . "/usr/share/bash-prexec"
  ;;
zsh)
  [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && . "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ;;
esac

# Common tool initialization
ATUIN_INIT_FLAGS=${ATUIN_INIT_FLAGS:-"--disable-up-arrow"}
for tool in starship atuin zoxide thefuck; do
  command -v "$tool" >/dev/null && {
    case "$tool" in
    atuin)
      eval "$($tool init $shell $ATUIN_INIT_FLAGS)"
      ;;
    starship | zoxide)
      eval "$($tool init $shell)"
      ;;
    thefuck)
      eval "$(thefuck --alias)"
      ;;
    esac
  }
done
