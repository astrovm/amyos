#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Nix"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-start-daemon --no-confirm
tar --zstd -cvf /usr/share/nix.tar.zst /nix

log "Copying Nix users to /usr/lib/passwd"
grep "^nixbld" /etc/passwd >> /usr/lib/passwd

log "Enabling system services"
mkdir -p /usr/lib/systemd/system
ln -s /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.service /usr/lib/systemd/system/
ln -s /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.socket /usr/lib/systemd/system/
systemctl enable nix-setup.service nix-directory.service nix.mount ensure-symlinked-units-resolve.service

log "Nix install completed"
