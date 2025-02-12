#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
echo_and_restore() {
  echo "$*"
  set -x
}
alias log='{ set +x; } 2> /dev/null; echo_and_restore'

log "=== Starting Amy OS cleanup process ==="
log "$(date): Beginning cleanup operations"

log "=== Updating font cache ==="
fc-cache -rs
log "✓ Font cache updated successfully"

log "=== Cleaning DNF cache and temporary files ==="
log "Cleaning DNF cache..."
dnf5 clean all
log "Removing temporary files..."
rm -rf /tmp/* || true
log "Cleaning /var directory..."
mv /var/lib/alternatives /staged-alternatives
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/lib
mv /staged-alternatives /var/lib/alternatives
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
log "✓ System cleanup completed"

log "=== Cleanup process completed successfully ==="
log "$(date): Cleanup finished"
