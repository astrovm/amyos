[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/amyos)](https://artifacthub.io/packages/search?repo=amyos)

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

- `cursor` and `cursor-cli` commands
- `fuck` alias
- `rustup-init` command
- adb, fastboot and scrcpy
- Brave Browser
- Cloudflare WARP
- Curated list of Flatpaks, Homebrews and AppImages
- Fixed Google Drive native integration
- Hack, Powerline and Ubuntu fonts
- Starship shell prompt
- Virtual Machine Manager
- VS Code, Neovim, Docker and DevPod

## Install

From existing Fedora Atomic/Universal Blue installation switch to Amy OS image:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/astrovm/amyos:latest
```

If you want to install the image on a new system download and install Bazzite ISO first:

<https://download.bazzite.gg/bazzite-stable-amd64.iso>

## Just commands

The following `just` commands are available to install Flatpaks, Homebrews and AppImages:

```bash
# Install all apps
just install-amy

# Install only Flatpaks
just install-amy-flatpaks

# Install only Homebrews
just install-amy-brews

# Install only AppImages
just install-amy-appimages
```

### Flatpaks

- Alpaca
- Audacity
- Blender
- Bottles
- BoxBuddy
- Clapgrep
- Dolphin
- DuckStation
- Easy Effects
- Fedora Media Writer
- Filelight
- Firefox
- Flatseal
- Flycast
- Gear Lever
- GIMP
- Gwenview
- Haruna
- ISO Image Writer
- KCalc
- Kdenlive
- Krita
- LibreOffice
- LocalSend
- Mission Center
- OBS Studio
- Okular
- Pinta
- Podman Desktop
- ProtonTricks
- ProtonUp-Qt
- qBittorrent
- RetroArch
- ScummVM
- Signal
- Space Cadet Pinball
- Spotify
- Stremio
- Telegram
- Tor Browser
- Varia
- Vesktop
- VLC
- Warehouse
- Warp
- WineZGUI

### Homebrews

- wormhole-rs

### AppImages

- Cursor
- OpenRGB

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
