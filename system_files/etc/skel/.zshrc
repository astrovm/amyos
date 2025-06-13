#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -U compinit
compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
setopt APPEND_HISTORY
## for sharing history between zsh processes
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0

# autoload -U colors
#colors

# Keybindings section
bindkey -e
bindkey '^[[H'  beginning-of-line                  # Home key (xterm)
bindkey '^[[OH' beginning-of-line                  # Home key (smkx mode)
bindkey '^[[1~' beginning-of-line                  # Home key (screen & tmux)
bindkey '^[[7~' beginning-of-line                  # Home key (urxvt)
bindkey '^[[F'  end-of-line                        # End key (xterm)
bindkey '^[[OF' end-of-line                        # End key (smkx mode)
bindkey '^[[4~' end-of-line                        # End key (screen & tmux)
bindkey '^[[8~' end-of-line                        # End key (urxvt)
bindkey '^[[2~' overwrite-mode                     # Insert key
bindkey '^[[3~' delete-char                        # Delete key
bindkey '^[[C'  forward-char                       # Right key
bindkey '^[[D'  backward-char                      # Left key
bindkey '^[[5~' history-beginning-search-backward  # Page up key
bindkey '^[[6~' history-beginning-search-forward   # Page down key
bindkey '^[[A'  up-line-or-history                 # Up key
bindkey '^[[B'  down-line-or-history               # Down key
# Navigate words with Ctrl+Arrow keys
bindkey '^[Oc' forward-word                        #
bindkey '^[Od' backward-word                       #
bindkey '^[[1;5D' backward-word                    #
bindkey '^[[1;5C' forward-word                     #
bindkey '^H' backward-kill-word                    # Delete previous word with Ctrl+Backspace
bindkey '^[[Z' undo                                # Shift+Tab undo last action

# Autosuggestions, Starship, and The Fuck
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
eval "$(thefuck --alias)"

# Atuin
export ATUIN_NOBIND="true"
### bling.sh source start
test -f /usr/share/bazzite-cli/bling.sh && source /usr/share/bazzite-cli/bling.sh
### bling.sh source end
bindkey '^r' atuin-search

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# Rust
export PATH="/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH"
