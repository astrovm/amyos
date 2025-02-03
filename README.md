# Amy OS

A custom Universal Blue image designed for gaming, development and daily use.

## Base System

- Built on Fedora 41
- Uses [Bazzite](https://bazzite.gg/) as the base image
- Features KDE Plasma desktop environment
- Optimized for AMD and Intel GPUs

## Features

- **Development Tools**
  - VS Code (Microsoft's code editor)
  - Neovim (Modern Vim text editor)
  - Docker & Docker Compose (Container platform)
  - ADB & Scrcpy (Android development and screen mirroring tools)

- **System Utilities**
  - htop (System monitoring tool)
  - GParted (Partition editor)
  - ISOImageWriter, GNOME Disks, Fedora Media Writer (Disk writing utilities)
  - nmap (Network analysis utility)
  - virt-manager (Virtual machine management)
  - BleachBit (System cleaner)
  - John the Ripper (Password security tool)
  - Wireshark (Network protocol analyzer)
  - CMatrix (Terminal matrix effect)
  - Syncthing (Continuous file synchronization)
  - Rclone (Cloud storage sync tool)
  - Croc (Secure file transfer tool)

- **Media Applications**
  - VLC, MPV (Video players)
  - Audacious (Audio player)
  - Audacity & EasyEffects (Audio editing tools)
  - Kdenlive (Video editor)
  - GIMP (Advanced image editor)
  - Krita (Digital painting)
  - Pinta (Simple image editor)

- **Internet & Downloads**
  - Brave (Web browser)
  - Cloudflare WARP & Proton VPN (VPN & DNS services)
  - qBittorrent (Torrent client)
  - aria2 (Download utility)
  - yt-dlp (Video downloader)
  - Tor, Tor Browser & Torsocks (Anonymity network tools)

- **Hardware Control**
  - CoolerControl (Fan and pump controller)
  - LACT (GPU configuration and monitoring tool)
  - Solaar (Logitech device manager)

- **Fonts**
  - Ubuntu Family

## Additional Applications (Flatpak)

- **Gaming & Emulation**
  - Alpaca (Game launcher with AMD plugin)
  - Bottles (Wine manager)
  - Dolphin (GameCube/Wii emulator)
  - DuckStation (PlayStation 1 emulator)
  - Flycast (Dreamcast emulator)
  - ProtonTricks (Wine configuration)
  - ProtonUp-Qt (Proton version manager)
  - RetroArch (Multi-system emulator)
  - ScummVM (Classic adventure games)
  - Space Cadet Pinball
  - Supermodel (SEGA Model 3 emulator)
  - WineZGUI (Wine frontend)

- **Productivity & Utilities**
  - Firefox (Web browser)
  - LibreOffice (Office suite)
  - Filelight (Disk usage analyzer)
  - Flatseal (Flatpak permissions manager)
  - GearLever (Container manager)
  - Gwenview (Image viewer)
  - Haruna (Video player)
  - KCalc (Calculator)
  - Mission Center (System monitor)
  - Okular (Document viewer)
  - Warehouse (Flatpak manager)
  - BoxBuddy (Distrobox manager)
  - Clapgrep (Log viewer)
  - Warp (File transfer)

- **Creative**
  - Blender (3D creation suite)
  - OBS Studio (Streaming/recording)
    - GStreamer plugins
    - VA-API plugin (Hardware acceleration)
    - Vulkan capture plugin

- **Communication & Media**
  - LocalSend (Local file sharing)
  - Signal (Secure messenger)
  - Spotify (Music streaming)
  - Stremio (Media streaming)
  - Telegram (Messenger)
  - Vesktop (Discord client)

## Additional Applications (Homebrew)

- magic-wormhole.rs (Secure file transfer)

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
