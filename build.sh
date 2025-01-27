#!/bin/bash

set -ouex pipefail

# Add repositories
dnf5 config-manager addrepo --from-repofile https://gist.github.com/astrovm/fb1a053d82c7c745fdb46c674b8c0002/raw/b93e2ef423a6432702a05566131f4c5431216be6/vscode.repo
dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 copr enable -y zeno/scrcpy
dnf5 copr enable -y codifryed/CoolerControl
dnf5 copr enable -y atim/ubuntu-fonts

# Install packages
dnf5 install -y \
    code \
    neovim \
    android-tools \
    scrcpy \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    lact \
    liquidctl \
    coolercontrol \
    aria2 \
    bleachbit \
    btop \
    cmatrix \
    easyeffects \
    gparted \
    htop \
    mpv \
    net-tools \
    nmap \
    protontricks \
    tmux \
    tor \
    torsocks \
    util-linux \
    virt-manager \
    vlc \
    yt-dlp \
    ubuntu-family-fonts

# Enable services
systemctl enable docker
