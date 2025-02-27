[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/amyos)](https://artifacthub.io/packages/container/amyos/amyos)
[![Build Amy OS](https://github.com/astrovm/amyos/actions/workflows/build.yml/badge.svg)](https://github.com/astrovm/amyos/actions/workflows/build.yml)

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/astrovm/amyos/refs/heads/main/repo_files/amy-logo-black.png">
    <img alt="Amy OS Logo" src="https://raw.githubusercontent.com/astrovm/amyos/refs/heads/main/repo_files/amy-logo-white.png" width="100">
  </picture>
</div>

# Amy OS

A custom Fedora Atomic image designed for gaming, development and daily use.

## Base System

- Built on Fedora 41
- Uses [Bazzite](https://bazzite.gg/) as the base image
- KDE Plasma 6.3 with Valve's themes from SteamOS
- Optimized for AMD and Intel GPUs

## Features

- [Bazzite features](https://github.com/ublue-os/bazzite#about--features)
- `cursor` and `cursor-cli` commands
- ADB, Fastboot and Waydroid
- Audacious with Winamp skins
- Brave Browser
- Cloudflare WARP
- Curated list of [Flatpaks](https://github.com/astrovm/amyos/blob/main/repo_files/flatpaks) and [AppImages](https://github.com/astrovm/amyos/blob/main/repo_files/appimages)
- DNS over TLS, DNSSEC and MAC address randomization enabled
- Docker, Podman, Distrobox and Toolbx
- Fixed Plasma integration with Google Drive
- Ghostty terminal, Starship prompt, Zsh, `fuck` alias and Atuin history search (Ctrl+R)
- Nix with GPU drivers symlink and Home Manager custom config
- OpenRGB and CoolerControl
- Switch to standalone SteamOS session from login screen
- Virtual Machine Manager, libvirt and QEMU
- VLC, mpv, HandBrake and Audacity
- VSCode, Cursor with Remote Tunnels fixed, Neovim

## Install

From existing Fedora Atomic/Universal Blue installation switch to Amy OS image:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/astrovm/amyos:latest
```

If you want to install the image on a new system download and install Bazzite ISO first:

<https://download.bazzite.gg/bazzite-stable-amd64.iso>

## Custom commands

The following `ujust` commands are available:

```bash
# Clean up old packages and Docker/Podman images and volumes
ujust amy-clean

# Install all Amy OS apps
ujust amy-install

# Install only Flatpaks
ujust amy-install-flatpaks

# Install only AppImages
ujust amy-install-appimages

# Install only Nix packages
ujust amy-install-nixpkgs

# Setup Amy OS settings for Cursor and VSCode
ujust amy-setup-editors

# Setup Nix Home Manager with Amy OS config
ujust amy-setup-home

# Setup Nix package manager
ujust amy-setup-nix

# Setup Sonic Adventure DX mods
ujust amy-setup-sadx

# Restart Bluetooth to fix issues
ujust amy-fix-bt

# Manage SSD encryption optimizations (Workqueue and TRIM)
ujust amy-ssd-crypto
```

## Package management

GUI apps can be found as Flatpaks in the Discover app or [FlatHub](https://flathub.org/) and installed with `flatpak install ...`.

CLI and GUI apps are available from [Nix](https://search.nixos.org/packages) using `nix profile install nixpkgs#...`.

[Homebrew](https://formulae.brew.sh/) is also available for installing CLI apps with `brew install ...`.

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
