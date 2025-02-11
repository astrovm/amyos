#!/bin/bash
set -ouex pipefail

echo "=== Starting Amy OS cleanup process ==="
echo "$(date): Beginning cleanup operations"

echo "=== Moving directories from /var/opt to /usr/lib/opt ==="
for dir in /var/opt/*/; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        echo "Moving directory: $dir to /usr/lib/opt/$dirname"
        mv "$dir" "/usr/lib/opt/$dirname"
        echo "Creating symlink in tmpfiles.d configuration"
        echo "L /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >> /usr/lib/tmpfiles.d/amyos.conf
        echo "✓ Processed $dirname successfully"
    fi
done
echo "✓ Directory migration completed"

echo "=== Updating font cache ==="
fc-cache -rsv
echo "✓ Font cache updated successfully"

echo "=== Cleaning DNF cache and temporary files ==="
dnf5 clean all
echo "Removing temporary files..."
rm -rf /tmp/* || true
echo "✓ System cleanup completed"

echo "=== Cleanup process completed successfully ==="
echo "$(date): Cleanup finished"
