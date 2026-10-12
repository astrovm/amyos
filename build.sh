#!/usr/bin/env bash
# Builds the Amy OS live ISO into output/.
# Runs as root inside a Debian testing container (see `just build`).
set -euo pipefail

cd "$(dirname "$0")"

# GitHub release assets must be under 2 GiB.
max_iso_bytes=$((2 * 1024 * 1024 * 1024 - 1))

work=_build
out=output

log() {
  echo "=== $* ==="
}

log "Installing build tools"
apt-get update
apt-get install -y --no-install-recommends \
  apt-utils \
  ca-certificates \
  cpio \
  debootstrap \
  dosfstools \
  live-build \
  mtools \
  squashfs-tools \
  xorriso \
  zstd

log "Preparing build directory"
rm -rf "$work"
mkdir -p "$work" "$out"
cp -a live/. "$work/"

log "Building amyos-branding package"
mkdir -p "$work/config/packages.chroot"
dpkg-deb --root-owner-group -Zxz --build branding "$work/config/packages.chroot/"

log "Building ISO"
cd "$work"
lb clean
lb config
lb build
cd ..

iso="$(find "$work" -maxdepth 1 -name '*.iso' -print -quit)"
if [[ -z "$iso" ]]; then
  echo "No ISO was produced, see $work/build.log" >&2
  exit 1
fi

name="amyos-debian-testing-$(date -u +%Y%m%d)-amd64.iso"
mv "$iso" "$out/$name"
(cd "$out" && sha256sum "$name" >"$name.sha256")

size="$(stat -c %s "$out/$name")"
log "Built $out/$name ($((size / 1024 / 1024)) MiB)"
if ((size > max_iso_bytes)); then
  echo "ISO is over 2 GiB, GitHub releases can't host it" >&2
  exit 1
fi
