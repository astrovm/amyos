#!/usr/bin/bash
# Installs a minimal KDE Plasma desktop and the Amy OS branding.
# Runs inside fedora/Containerfile, with the repo mounted at /ctx.
set -euo pipefail

mapfile -t packages < <(grep -v -e '^#' -e '^$' /ctx/fedora/desktop.list)
dnf -y install --setopt=install_weak_deps=False "${packages[@]}"
# Fedora remixes drop the Fedora logos.
dnf -y swap fedora-logos generic-logos

/ctx/fedora/customize.sh /ctx

# Rebuild the initramfs so the boot splash uses the Amy OS logo.
kernel="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n' | sort -V | tail -n 1)"
dracut --no-hostonly --kver "$kernel" --reproducible --zstd --add ostree \
  -f "/usr/lib/modules/$kernel/initramfs.img"

# /run is not part of the image; drop build leftovers.
rm -rf /var/lib/dnf /run/dnf /run/sddm
