#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
dnf5 config-manager addrepo --from-repofile https://gist.github.com/astrovm/fb1a053d82c7c745fdb46c674b8c0002/raw/b93e2ef423a6432702a05566131f4c5431216be6/vscode.repo
dnf5 config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 copr enable -y zeno/scrcpy
dnf5 copr enable -y codifryed/CoolerControl
dnf5 copr enable -y atim/ubuntu-fonts

# Install packages
dnf5 install -y \
    # Development Tools
    code \
    neovim \
    # System Tools
    btop \
    htop \
    tmux \
    util-linux \
    # Network Tools
    net-tools \
    nmap \
    # Browsers
    brave-browser \
    # Container & Virtualization
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    virt-manager \
    # Android Development
    android-tools \
    scrcpy \
    # Hardware Control
    lact \
    liquidctl \
    coolercontrol \
    # KDE Applications
    filelight \
    gwenview \
    haruna \
    kcalc \
    okular \
    # Media & Downloads
    aria2 \
    mpv \
    vlc \
    yt-dlp \
    # System Management
    bleachbit \
    gparted \
    # Audio
    easyeffects \
    # Privacy & Security
    tor \
    torsocks \
    # Gaming
    protontricks \
    # Misc
    cmatrix \
    ubuntu-family-fonts

# Move directories
mv /var/opt/brave.com /usr/lib/brave.com

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/brave-browser.conf <<EOF
L  /opt/brave.com -  -  -  -  /usr/lib/brave.com
EOF

# Enable services
systemctl enable docker
