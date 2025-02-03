# Amy OS

A custom Universal Blue image designed for gaming, development and daily use.

## Base System

- Built on Fedora 41
- Uses [Bazzite](https://bazzite.gg/) as the base image
- Features KDE Plasma desktop environment
- Optimized for AMD and Intel GPUs

## Features

- **Development Tools**
  - VS Code
  - Neovim
  - Docker
  - Docker Compose
  - ADB
  - Scrcpy

- **System Utilities**
  - htop
  - GParted
  - ISOImageWriter
  - GNOME Disks
  - nmap
  - virt-manager
  - BleachBit
  - John the Ripper
  - Wireshark
  - Syncthing
  - Rclone

- **Media Applications**
  - VLC
  - MPV
  - Audacious

- **Internet & Downloads**
  - Brave
  - Cloudflare WARP
  - Proton VPN
  - Tor
  - Torsocks

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
  - Firefox
  - LibreOffice
  - Filelight
  - Flatseal
  - GearLever
  - Gwenview
  - Haruna
  - KCalc
  - Mission Center
  - Okular
  - Warehouse
  - BoxBuddy
  - Clapgrep
  - Warp
  - Fedora Media Writer
  - qBittorrent
  - EasyEffects

- **Creative**
  - Blender
  - OBS Studio
  - Audacity
  - Kdenlive
  - GIMP
  - Krita
  - Pinta

- **Communication & Media**
  - LocalSend
  - Signal
  - Spotify
  - Stremio
  - Telegram
  - Vesktop

- **Security & Privacy**
  - Tor Browser

## Additional Applications (Homebrew)

- wormhole-rs
- croc
- aria2
- yt-dlp
- cmatrix

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
