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
- Features KDE Plasma desktop environment
- Optimized for AMD and Intel GPUs

## Features

- [Bazzite features](https://github.com/ublue-os/bazzite#about--features)
- `cursor` and `cursor-cli` commands
- `fuck` alias
- adb and fastboot
- Audacious with Winamp skins
- Brave Browser
- Cloudflare WARP
- Curated list of Flatpaks, AppImages and Nix packages
- DNS over TLS enabled
- Fixed Google Drive native integration
- Ghostty terminal and Starship shell prompt
- Hack and Ubuntu Nerd Fonts
- MAC address randomization enabled
- OpenRGB and CoolerControl
- qBittorrent, yt-dlp and aria2
- Switch to standalone SteamOS session from login screen
- Virtual Machine Manager
- VLC, mpv, HandBrake and Audacity
- VSCode, Cursor with Remote Tunnels, Neovim and Docker

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
# Install all Amy OS curated apps
ujust amy-install

# Install only Flatpaks
ujust amy-install-flatpaks

# Install only AppImages
ujust amy-install-appimages

# Install only Nix packages
ujust amy-install-nixpkgs

# Setup Nix package manager
ujust amy-setup-nix

# Setup Amy OS settings for Cursor and VSCode
ujust amy-setup-editors

# Setup Git and GitHub SSH key
ujust amy-setup-git

# Setup Sonic Adventure DX mods
ujust amy-setup-sadx

# Restart Bluetooth to fix issues
ujust amy-fix-bt

# Manage SSD encryption optimizations (Workqueue and TRIM)
ujust amy-ssd-crypto
```

## Curated list of apps

```text
# Flatpaks

- Alpaca
- Blender
- Bottles
- Easy Effects
- Fedora Media Writer
- GIMP
- Kdenlive
- Krita
- LibreOffice
- LocalSend
- OBS Studio
- Pinta
- Podman Desktop
- Signal
- Space Cadet Pinball
- Spotify
- Stremio
- Telegram
- Tor Browser
- Varia
- Vesktop
- Warp

# AppImages

- Trezor Suite

# Nix packages

- magic-wormhole-rs
- shellcheck
- shfmt
```

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
