#!/usr/bin/env bash
# Builds the Amy OS live ISO for the host architecture into output/.
# Runs as root inside a Debian testing container, see `just build`.
set -euo pipefail
cd "$(dirname "$0")/.."

architecture="$(dpkg --print-architecture)"
case "$architecture" in
  amd64) filter=x86 ;;
  arm64) filter=arm64 ;;
  *) echo "Unsupported architecture: $architecture" >&2; exit 1 ;;
esac

apt-get update
apt-get install -y live-build

rm -rf _build output
cp -a debian/live _build
mkdir -p _build/config/packages.chroot output
# Only the installed files: the artwork sources next to them stay out of /.
mkdir -p _build/branding
cp -a branding/usr _build/branding/
cp -a debian/branding/. _build/branding/
dpkg-deb --root-owner-group --build _build/branding _build/config/packages.chroot/

# Larger XZ blocks and the native instruction filter reduce the filesystem without dropping files.
(cd _build && lb config && MKSQUASHFS_OPTIONS="-b 1M -Xbcj $filter" lb build)

if [[ "$architecture" == arm64 ]]; then
  ./debian/raspberry-pi.sh
fi

name="amyos-debian-testing-$(date -u +%Y%m%d)-$architecture.iso"
mv _build/*.iso "output/$name"
(cd output && sha256sum "$name" >"$name.sha256")

size=$(stat -c %s "output/$name")
echo "ISO size: $((size / 1024 / 1024)) MiB"
if ((size >= 2 * 1024 ** 3)); then
  echo "ISO is over 2 GiB, too big for a GitHub release" >&2
  exit 1
fi
