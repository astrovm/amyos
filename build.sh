#!/usr/bin/env bash
# Builds the Amy OS live ISO into output/.
# Runs as root inside a Debian testing container, see `just build`.
set -euo pipefail
cd "$(dirname "$0")"

apt-get update
apt-get install -y live-build

rm -rf _build output
cp -a live _build
mkdir -p _build/config/packages.chroot output
dpkg-deb --root-owner-group --build branding _build/config/packages.chroot/

(cd _build && lb config && lb build)

name="amyos-debian-testing-$(date -u +%Y%m%d)-amd64.iso"
mv _build/*.iso "output/$name"
(cd output && sha256sum "$name" >"$name.sha256")

size=$(stat -c %s "output/$name")
echo "ISO size: $((size / 1024 / 1024)) MiB"
if ((size >= 2 * 1024 ** 3)); then
  echo "ISO is over 2 GiB, too big for a GitHub release" >&2
  exit 1
fi
