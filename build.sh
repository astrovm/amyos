#!/bin/bash

set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Add repositories
dnf5 config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 config-manager addrepo --from-repofile https://gist.github.com/astrovm/fb1a053d82c7c745fdb46c674b8c0002/raw/b93e2ef423a6432702a05566131f4c5431216be6/vscode.repo
dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

# Install packages
rpm-ostree install -y \
    code \
    neovim \
    android-tools \
    brave-browser \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable services
systemctl enable docker
