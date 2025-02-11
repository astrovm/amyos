#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
echo_and_restore() {
  echo "$*"
  set -x
}
alias log='{ set +x; } 2> /dev/null; echo_and_restore'

log "=== Starting Amy OS build process ==="
log "$(date): Beginning package installations"

log "=== Installing Fedora packages ==="
dnf5 -y install \
  android-tools \
  aria2 \
  bleachbit \
  cmatrix \
  croc \
  gnome-disk-utility \
  gparted \
  htop \
  john \
  libvirt-nss \
  mpv \
  neovim \
  nmap \
  powerline-fonts \
  protonvpn-cli \
  rclone \
  rustup \
  ShellCheck \
  shfmt \
  solaar \
  source-foundry-hack-fonts \
  thefuck \
  tor \
  torsocks \
  virt-manager \
  wireshark \
  yt-dlp
log "✓ Fedora packages installed successfully"

log "=== Installing RPM Fusion packages ==="
dnf5 -y install --enable-repo="*rpmfusion*" \
  audacious \
  audacious-plugins-freeworld
log "✓ RPM Fusion packages installed successfully"

log "=== Installing Terra packages ==="
dnf5 -y install --enable-repo="terra" \
  coolercontrol \
  ghostty \
  starship
log "✓ Terra packages installed successfully"

log "=== Installing Docker ==="
dnf5 -y install --enable-repo="docker-ce-stable" \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin
log "✓ Docker installed successfully"

log "=== Installing Brave Browser ==="
dnf5 -y install --enable-repo="brave-browser" \
  brave-browser
log "✓ Brave Browser installed successfully"

log "=== Installing Cloudflare WARP ==="
dnf5 -y install --enable-repo="cloudflare-warp" \
  cloudflare-warp
log "✓ Cloudflare WARP installed successfully"

log "=== Installing VSCode ==="
dnf5 -y install --enable-repo="vscode" \
  code
log "✓ VSCode installed successfully"

log "=== Installing Ubuntu fonts ==="
dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y install ubuntu-family-fonts
dnf5 -y copr disable atim/ubuntu-fonts
log "✓ Ubuntu fonts installed successfully"

log "=== Installing Scrcpy ==="
dnf5 -y copr enable zeno/scrcpy
dnf5 -y install scrcpy
dnf5 -y copr disable zeno/scrcpy
log "✓ Scrcpy installed successfully"

log "=== Installing DevPod ==="
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod
dnf5 -y copr disable ublue-os/staging
log "✓ DevPod installed successfully"

log "=== Installing LACT ==="
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT
log "✓ LACT installed successfully"

log "=== Installing Cursor CLI ==="
log "Downloading Cursor CLI..."
curl --retry 3 -Lo /tmp/cursor-cli.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
log "Extracting Cursor CLI..."
tar -xzf /tmp/cursor-cli.tar.gz -C /tmp
mv /tmp/cursor /tmp/cursor-cli
log "Installing Cursor CLI to /usr/bin..."
install -c -m 0755 /tmp/cursor-cli /usr/bin
log "✓ Cursor CLI installed successfully"

log "=== Enabling system services ==="
systemctl enable docker
systemctl enable libvirtd
log "✓ Services enabled successfully"

log "=== Configuring system files ==="
log "Adding Amy OS justfile..."
echo "import \"/usr/share/amyos/just/install-apps.just\"" >>/usr/share/ublue-os/justfile

log "Configuring shell environment..."
cat <<'EOF' >>/etc/bashrc
eval "$(starship init bash)"
eval "$(thefuck --alias)"
EOF

log "=== Build process completed successfully ==="
log "$(date): Build finished"
