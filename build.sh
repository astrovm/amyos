#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
dnf5 config-manager addrepo --from-repofile https://gist.github.com/astrovm/fb1a053d82c7c745fdb46c674b8c0002/raw/b93e2ef423a6432702a05566131f4c5431216be6/vscode.repo
dnf5 config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 config-manager addrepo --from-repofile https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo
dnf5 copr enable -y zeno/scrcpy
dnf5 copr enable -y codifryed/CoolerControl
dnf5 copr enable -y atim/ubuntu-fonts

# Install packages
dnf5 install -y \
    android-tools \
    aria2 \
    audacious \
    audacity \
    bleachbit \
    brave-browser \
    btop \
    cloudflare-warp \
    cmatrix \
    code \
    containerd.io \
    coolercontrol \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    easyeffects \
    filelight \
    firefox \
    gimp \
    gparted \
    gwenview \
    haruna \
    htop \
    john \
    kcalc \
    krita \
    lact \
    libreoffice \
    liquidctl \
    mpv \
    neovim \
    net-tools \
    nmap \
    okular \
    protontricks \
    qbittorrent \
    scrcpy \
    tmux \
    tor \
    torbrowser-launcher \
    torsocks \
    ubuntu-family-fonts \
    util-linux \
    virt-manager \
    vlc \
    wireshark \
    yt-dlp

# Move directories
mv /var/opt/brave.com /usr/lib/brave.com

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/brave-browser.conf <<EOF
L  /opt/brave.com -  -  -  -  /usr/lib/brave.com
EOF

# Enable services
systemctl enable docker
systemctl enable libvirtd
