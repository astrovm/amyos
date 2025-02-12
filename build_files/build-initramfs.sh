#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
echo_and_restore() {
  echo "$*"
  set -x
}
alias log='{ set +x; } 2> /dev/null; echo_and_restore'

log "=== Building initramfs ==="
log "$(date): Starting initramfs build process"

log "Querying installed kernel version..."
QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)"
log "Found kernel version: $QUALIFIED_KERNEL"

log "Building initramfs with dracut..."
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

log "Setting initramfs permissions..."
chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img

log "✓ initramfs built successfully"
log "$(date): Build process completed"
