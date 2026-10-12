[![Build live ISO](https://github.com/astrovm/amyos/actions/workflows/build.yml/badge.svg?branch=debian)](https://github.com/astrovm/amyos/actions/workflows/build.yml?query=branch%3Adebian)

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/astrovm/amyos/refs/heads/main/repo_files/amy-logo-black.png">
    <img alt="Amy OS Logo" src="https://raw.githubusercontent.com/astrovm/amyos/refs/heads/main/repo_files/amy-logo-white.png" width="100">
  </picture>
</div>

# Amy OS (Debian testing)

Debian testing with KDE Plasma, on a live USB with the Calamares installer.

It's plain Debian under the Amy OS name and logo. You update it with `apt`.

## What's different from Debian

- Amy OS name in **About this System**, `/etc/os-release` and the GRUB menu.
- Amy OS logo in the boot menu, boot splash and installer.
- The system still reports `ID=debian`, so Debian tools and repos work as usual.
- Installed systems follow `testing`, with `contrib`, `non-free` and `non-free-firmware` enabled.

## Install

1. Download the ISO from [Releases](https://github.com/astrovm/amyos/releases).
2. Write it to a USB stick (Fedora Media Writer, Impression, `dd`, etc.).
3. Boot from it and open **Install Amy OS** on the desktop.

## Build

Needs `just` and `podman`. The ISO lands in `output/`.

```bash
sudo just build
just run-vm        # UEFI
just run-vm bios
```

CI builds the ISO on every push to `debian`.
Run the workflow by hand on the `debian` branch to publish a release.

## Layout

- `live/`: live-build config (packages, hooks, boot menu art, Calamares branding).
- `branding/`: the `amyos-branding` package (os-release name, logo, GRUB name, Plymouth theme).
- `build.sh`: builds the package and the ISO inside a Debian testing container.
