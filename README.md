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

- Built on Fedora 44
- Uses [Bazzite](https://bazzite.gg/) as the base image
- KDE Plasma desktop
- Optimized for AMD and Intel GPUs

## Features

- [Bazzite features](https://github.com/ublue-os/bazzite#about--features)
- ADB, Fastboot and [Waydroid](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/)
- Brave Browser
- Stable Wi-Fi MAC addressing enabled
- Podman, Distrobox and Toolbx
- Ghostty terminal, Starship prompt, Zsh and `fuck` alias
- OpenRGB and CoolerControl
- Virtual Machine Manager, libvirt and QEMU
- VLC, mpv and HandBrake
- VSCode, Neovim

## Install

From existing Fedora Atomic/Universal Blue installation switch to Amy OS image:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/astrovm/amyos:latest
```

If you want to install the image on a new system download and install Bazzite ISO first:

<https://download.bazzite.gg/bazzite-stable-amd64.iso>

## Package management

GUI apps can be found as Flatpaks in the Discover app or [FlatHub](https://flathub.org/) and installed with `flatpak install ...`.

CLI apps are available from [Homebrew](https://formulae.brew.sh/) using `brew install ...`.

## Acknowledgments

This project is based on the [Universal Blue image template](https://github.com/ublue-os/image-template) and builds upon the excellent work of the Universal Blue community.
