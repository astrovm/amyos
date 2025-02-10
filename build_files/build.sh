#!/bin/bash
set -ouex pipefail

# Install Fedora packages
dnf5 -y install \
    android-tools \
    aria2 \
    bleachbit \
    cmatrix \
    croc \
    gnome-disk-utility \
    gparted \
    htop \
    isoimagewriter \
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
    syncthing \
    thefuck \
    tor \
    torsocks \
    virt-manager \
    wireshark \
    yt-dlp

# Install RPM Fusion packages
dnf5 -y install --enable-repo="*rpmfusion*" \
    audacious \
    audacious-plugins-freeworld

# Install Terra packages
dnf5 -y install --enable-repo="terra" \
    coolercontrol \
    ghostty \
    starship

# Install Docker
dnf5 -y install --enable-repo="docker-ce-stable" \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin

# Install Brave Browser
dnf5 -y install --enable-repo="brave-browser" \
    brave-browser

# Install Cloudflare Warp
dnf5 -y install --enable-repo="cloudflare-warp" \
    cloudflare-warp

# Install VSCode
dnf5 -y install --enable-repo="vscode" \
    code

# Install Ubuntu fonts
dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y install ubuntu-family-fonts
dnf5 -y copr disable atim/ubuntu-fonts

# Install Scrcpy
dnf5 -y copr enable zeno/scrcpy
dnf5 -y install scrcpy
dnf5 -y copr disable zeno/scrcpy

# Install DevPod
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod
dnf5 -y copr disable ublue-os/staging

# Install Lact
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT

# Add Cursor CLI
curl --retry 3 -Lo /tmp/cursor-cli.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf /tmp/cursor-cli.tar.gz -C /tmp
mv /tmp/cursor /tmp/cursor-cli
install -c -m 0755 /tmp/cursor-cli /usr/bin

# Enable services
systemctl enable docker
systemctl enable libvirtd

# Import Amy OS justfile
echo "import \"/usr/share/amyos/just/install-apps.just\"" >> /usr/share/ublue-os/justfile

# Add Starship shell prompt and fuck alias
cat << 'EOF' >> /etc/bashrc
eval "$(starship init bash)"
eval "$(thefuck --alias)"
EOF
