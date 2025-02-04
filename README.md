# Amy OS

A custom Universal Blue image designed for gaming, development and daily use.

## Base System

- Built on Fedora 41
- Uses [Bazzite](https://bazzite.gg/) as the base image
- Features KDE Plasma desktop environment
- Optimized for AMD and Intel GPUs

## Features

- **Productivity & Utilities**
  - ADB
  - BleachBit
  - Docker
  - Docker Compose
  - Ghostty
  - GParted
  - GNOME Disks
  - htop
  - ISOImageWriter
  - Neovim
  - nmap
  - Rclone
  - Scrcpy
  - Syncthing
  - virt-manager
  - VS Code
  - Wireshark

- **Networking & Communication**
  - Brave
  - Cloudflare WARP
  - Proton VPN
  - Tor
  - Torsocks

- **Media**
  - Audacious
  - MPV

- **Hardware Control**
  - CoolerControl
  - LACT
  - Solaar

- **Fonts**
  - Ubuntu Family

## Additional Applications (Flatpak)

- **Gaming & Emulation**
  - Alpaca
  - Bottles
  - Dolphin
  - DuckStation
  - Flycast
  - ProtonTricks
  - ProtonUp-Qt
  - RetroArch
  - ScummVM
  - Space Cadet Pinball
  - Supermodel
  - WineZGUI

- **Productivity & Utilities**
  - BoxBuddy
  - Clapgrep
  - Fedora Media Writer
  - Filelight
  - Flatseal
  - GearLever
  - KCalc
  - LibreOffice
  - Mission Center
  - Okular
  - Warehouse

- **Networking & Communication**
  - Firefox
  - LocalSend
  - qBittorrent
  - Signal
  - Telegram
  - Tor Browser
  - Varia
  - Vesktop
  - Warp

- **Creative**
  - Audacity
  - Blender
  - GIMP
  - Kdenlive
  - Krita
  - OBS Studio
  - Pinta

- **Media**
  - EasyEffects
  - Gwenview
  - Haruna
  - Spotify
  - Stremio
  - VLC

## Additional Applications (Homebrew)

- aria2
- cmatrix
- croc
- john-jumbo
- rustup
- wormhole-rs
- yt-dlp

## Installation Commands

The following `just` commands are available to install additional applications:

```bash
# Install all additional applications
just install-amy

# Install only Flatpak applications
just install-amy-flatpaks

# Install only Homebrew packages
just install-amy-brews
```

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
