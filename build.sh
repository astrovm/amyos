#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Add Brave Browser Repository
dnf5 config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# Add VSCode Repository
dnf5 config-manager addrepo --from-repofile https://gist.github.com/astrovm/fb1a053d82c7c745fdb46c674b8c0002/raw/b93e2ef423a6432702a05566131f4c5431216be6/vscode.repo

# Install apps
dnf install -y brave-browser code
