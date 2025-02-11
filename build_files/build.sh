#!/bin/bash
set -ouex pipefail

echo "=== Starting Amy OS build process ==="
echo "$(date): Beginning package installations"

echo "=== Installing Fedora packages ==="
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
    solaar \
    source-foundry-hack-fonts \
    thefuck \
    tor \
    torsocks \
    virt-manager \
    wireshark \
    yt-dlp
echo "✓ Fedora packages installed successfully"

echo "=== Installing RPM Fusion packages ==="
dnf5 -y install --enable-repo="*rpmfusion*" \
    audacious \
    audacious-plugins-freeworld
echo "✓ RPM Fusion packages installed successfully"

echo "=== Installing Terra packages ==="
dnf5 -y install --enable-repo="terra" \
    coolercontrol \
    ghostty \
    starship
echo "✓ Terra packages installed successfully"

echo "=== Installing Docker ==="
dnf5 -y install --enable-repo="docker-ce-stable" \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin
echo "✓ Docker installed successfully"

echo "=== Installing Brave Browser ==="
dnf5 -y install --enable-repo="brave-browser" \
    brave-browser
echo "✓ Brave Browser installed successfully"

echo "=== Installing Cloudflare WARP ==="
dnf5 -y install --enable-repo="cloudflare-warp" \
    cloudflare-warp
echo "✓ Cloudflare WARP installed successfully"

echo "=== Installing VSCode ==="
dnf5 -y install --enable-repo="vscode" \
    code
echo "✓ VSCode installed successfully"

echo "=== Installing Ubuntu fonts ==="
dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y install ubuntu-family-fonts
dnf5 -y copr disable atim/ubuntu-fonts
echo "✓ Ubuntu fonts installed successfully"

echo "=== Installing Scrcpy ==="
dnf5 -y copr enable zeno/scrcpy
dnf5 -y install scrcpy
dnf5 -y copr disable zeno/scrcpy
echo "✓ Scrcpy installed successfully"

echo "=== Installing DevPod ==="
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod
dnf5 -y copr disable ublue-os/staging
echo "✓ DevPod installed successfully"

echo "=== Installing LACT ==="
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT
echo "✓ LACT installed successfully"

echo "=== Installing Cursor CLI ==="
echo "Downloading Cursor CLI..."
curl --retry 3 -Lo /tmp/cursor-cli.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
echo "Extracting Cursor CLI..."
tar -xzf /tmp/cursor-cli.tar.gz -C /tmp
mv /tmp/cursor /tmp/cursor-cli
echo "Installing Cursor CLI to /usr/bin..."
install -c -m 0755 /tmp/cursor-cli /usr/bin
echo "✓ Cursor CLI installed successfully"

echo "=== Enabling system services ==="
systemctl enable docker
systemctl enable libvirtd
echo "✓ Services enabled successfully"

echo "=== Configuring system files ==="
echo "Adding Amy OS justfile..."
echo "import \"/usr/share/amyos/just/install-apps.just\"" >> /usr/share/ublue-os/justfile

echo "Configuring shell environment..."
cat << 'EOF' >> /etc/bashrc
eval "$(starship init bash)"
eval "$(thefuck --alias)"
EOF

echo "=== Build process completed successfully ==="
echo "$(date): Build finished"
