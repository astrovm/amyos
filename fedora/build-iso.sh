#!/usr/bin/env bash
# Builds the Amy OS Fedora live ISO for the host architecture into output/.
# Runs as root inside a Fedora container, see `just build-fedora-iso`.
# Builds the release of that container, so `fedora:latest` follows each new Fedora release.
set -euo pipefail
cd "$(dirname "$0")/.."

case "$(uname -m)" in
  x86_64) architecture=amd64 ;;
  aarch64) architecture=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

dnf -y install kiwi kiwi-systemdeps distribution-gpg-keys
release="$(rpm -E %fedora)"

rm -rf _build output
mkdir -p _build/description/root/root/amyos output
sed "s/@RELEASE@/$release/g" fedora/live/config.kiwi >_build/description/config.kiwi
cp fedora/live/config.sh _build/description/
# config.sh runs these inside the image.
cp -a branding fedora _build/description/root/root/amyos/

mapfile -t packages < <(grep -v -e '^#' -e '^$' fedora/desktop.list)
kiwi-ng --type iso system build --description _build/description --target-dir _build/image \
  "${packages[@]/#/--add-package=}"

name="amyos-fedora-$release-$(date -u +%Y%m%d)-$architecture.iso"
mv _build/image/*.iso "output/$name"
(cd output && sha256sum "$name" >"$name.sha256")

size=$(stat -c %s "output/$name")
echo "ISO size: $((size / 1024 / 1024)) MiB"
if ((size >= 2 * 1024 ** 3)); then
  echo "ISO is over 2 GiB, too big for a GitHub release" >&2
  exit 1
fi
