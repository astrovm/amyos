[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/amyos)](https://artifacthub.io/packages/container/amyos/amyos)
[![Build Amy OS](https://github.com/astrovm/amyos/actions/workflows/build.yml/badge.svg)](https://github.com/astrovm/amyos/actions/workflows/build.yml)

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://i.imgur.com/CqD0yyd.png">
    <img alt="Amy OS Logo" src="https://i.imgur.com/V6NLhnj.png" width="100">
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
- `rustup-init` command
- adb, fastboot and scrcpy
- Audacious with Winamp skins
- Brave and Tor Browser
- Cloudflare WARP
- Curated list of Flatpaks, Homebrews and AppImages
- DNS over TLS enabled by default
- Fixed Google Drive native integration
- Ghostty terminal and Starship shell prompt
- Hack and Ubuntu Nerd Fonts
- OpenRGB, CoolerControl, LACT and Solaar
- qBittorrent, yt-dlp and aria2
- Signal and Telegram
- Switch to standalone SteamOS session from login screen
- Virtual Machine Manager
- VLC, mpv, HandBrake and Audacity
- VSCode, Cursor with Remote Tunnels, Neovim, Docker and DevPod

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
ujust install-amy

# Install only Flatpaks
ujust install-amy-flatpaks

# Install only Homebrews
ujust install-amy-brews

# Install only AppImages
ujust install-amy-appimages

# Setup Amy OS recommended settings for Cursor and VSCode
ujust setup-editor-config
```

## Curated list of apps

```
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
- Space Cadet Pinball
- Spotify
- Stremio
- Varia
- Vesktop
- Warp

# Homebrews

- wormhole-rs

# AppImages

- EmuDeck
- Trezor Suite
```

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
