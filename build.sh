#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-*.repo
dnf5 copr enable -y zeno/scrcpy
dnf5 copr enable -y atim/ubuntu-fonts
dnf5 install -y terra-release

# Install packages
dnf5 install -y \
    android-tools \
    aria2 \
    audacious \
    audacious-plugins-freeworld \
    audacity-freeworld \
    bleachbit \
    brave-browser \
    cloudflare-warp \
    cmatrix \
    code \
    containerd.io \
    coolercontrol \
    croc \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    easyeffects \
    gimp \
    gparted \
    htop \
    isoimagewriter \
    gnome-disk-utility \
    mediawriter \
    john \
    kdenlive \
    krita \
    lact \
    mpv \
    neovim \
    nmap \
    pinta \
    protonvpn-cli \
    qbittorrent \
    rclone \
    scrcpy \
    solaar \
    syncthing \
    tor \
    torbrowser-launcher \
    torsocks \
    ubuntu-family-fonts \
    virt-manager \
    vlc \
    wireshark \
    yt-dlp

# Clean cache
dnf5 clean all

# Move directories
mv /var/opt/brave.com /usr/lib/brave.com

# Enable services
systemctl enable docker
systemctl enable libvirtd

# Add just
echo "import \"/usr/share/amyos/just/apps.just\"" >> /usr/share/ublue-os/justfile
