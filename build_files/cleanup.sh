#!/usr/bin/env bash
set -euo pipefail
echo_and_restore() {
  echo "$*"; set -x
}
shopt -s expand_aliases; alias log='{ set +x; } 2> /dev/null; echo_and_restore'

log "=== Starting Amy OS cleanup process ==="
log "$(date): Beginning cleanup operations"

log "=== Moving directories from /var/opt to /usr/lib/opt ==="
for dir in /var/opt/*/; do
  if [ -d "$dir" ]; then
    dirname=$(basename "$dir")
    log "Moving directory: $dir to /usr/lib/opt/$dirname"
    mv "$dir" "/usr/lib/opt/$dirname"
    log "Creating symlink in tmpfiles.d configuration"
    echo "L /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >> /usr/lib/tmpfiles.d/amyos.conf
    log "✓ Processed $dirname successfully"
  fi
done
log "✓ Directory migration completed"

log "=== Updating font cache ==="
fc-cache -rsv
log "✓ Font cache updated successfully"

log "=== Cleaning DNF cache and temporary files ==="
dnf5 clean all
log "Removing temporary files..."
rm -rf /tmp/* || true
log "✓ System cleanup completed"

log "=== Cleanup process completed successfully ==="
log "$(date): Cleanup finished"
