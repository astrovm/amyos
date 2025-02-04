# Amy OS

A custom Universal Blue image designed for gaming, development and daily use.

## Base System

- Built on Fedora 41
- Uses [Bazzite](https://bazzite.gg/) as the base image
- Features KDE Plasma desktop environment
- Optimized for AMD and Intel GPUs
- Includes [Starship](https://starship.rs/) shell prompt

## RPM packages

- **Productivity & Utilities**
  - ADB
  - BleachBit
  - devpod
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
  - Powerline
  - Ubuntu Family

## Flatpaks

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
  - Podman Desktop
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

## Homebrews

- aria2
- cmatrix
- croc
- john-jumbo
- rustup
- wormhole-rs
- yt-dlp

## AppImages

- Cursor

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

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
