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
    audacious \
    audacious-plugins-freeworld \
    bleachbit \
    brave-browser \
    cloudflare-warp \
    code \
    containerd.io \
    coolercontrol \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    ghostty \
    gparted \
    htop \
    isoimagewriter \
    gnome-disk-utility \
    lact \
    mpv \
    neovim \
    nmap \
    protonvpn-cli \
    rclone \
    scrcpy \
    solaar \
    syncthing \
    tor \
    torsocks \
    ubuntu-family-fonts \
    virt-manager \
    wireshark

# Clean cache
dnf5 clean all

# Move directories
mv /var/opt/brave.com /usr/lib/brave.com

# Enable services
systemctl enable docker
systemctl enable libvirtd

# Add just
echo "import \"/usr/share/amyos/just/apps.just\"" >> /usr/share/ublue-os/justfile
