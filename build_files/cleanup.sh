#!/bin/bash
set -ouex pipefail

# Move directories from /var/opt to /usr/lib/opt and create symlinks
for dir in /var/opt/*/; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        mv "$dir" "/usr/lib/opt/$dirname"
        echo "L /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >> /usr/lib/tmpfiles.d/amyos.conf
    fi
done

# Update font cache
fc-cache -fs

# Clean cache
dnf5 clean all
rm -rf /tmp/* || true
