# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Starship and The Fuck
eval "$(starship init bash)"
eval "$(thefuck --alias)"

# Atuin
export ATUIN_NOBIND="true"
### bling.sh source start
test -f /usr/share/bazzite-cli/bling.sh && source /usr/share/bazzite-cli/bling.sh
### bling.sh source end
bind -x '"\C-r": __atuin_history'

# fnm
eval "$(fnm env --use-on-cd --shell bash)"

# Rust
export PATH="/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH"
