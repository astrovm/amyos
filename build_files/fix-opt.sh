#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
echo_and_restore() {
  echo "$*"
  set -x
}
alias log='{ set +x; } 2> /dev/null; echo_and_restore'

log "=== Starting Amy OS /opt fix process ==="
log "$(date): Beginning fix operations"

log "=== Moving directories from /var/opt to /usr/lib/opt ==="
for dir in /var/opt/*/; do
  if [ -d "$dir" ]; then
    dirname=$(basename "$dir")
    log "Moving directory: $dir to /usr/lib/opt/$dirname"
    mv "$dir" "/usr/lib/opt/$dirname"
    log "Creating symlink in tmpfiles.d configuration"
    echo "L /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >>/usr/lib/tmpfiles.d/amyos.conf
    log "✓ Processed $dirname successfully"
  fi
done
log "✓ Directory migration completed"

log "=== Fix process completed successfully ==="
log "$(date): Fix finished"
