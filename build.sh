#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-*.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo
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
    devpod \
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
    libvirt-nss \
    mpv \
    neovim \
    nmap \
    powerline-fonts \
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
echo "import \"/usr/share/amyos/just/install-apps.just\"" >> /usr/share/ublue-os/justfile

# Starship Shell Prompt
curl --retry 3 -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
echo "eval \"\$(starship init bash)\"" >> /etc/bashrc

# Cursor CLI
curl --retry 3 -Lo /tmp/cursor.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf /tmp/cursor.tar.gz -C /tmp
mv /tmp/cursor /tmp/cursor-cli
install -c -m 0755 /tmp/cursor-cli /usr/bin
