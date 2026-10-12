# Amy OS

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/amyos)](https://artifacthub.io/packages/container/amyos/amyos)

A minimal KDE Plasma desktop with the Amy OS name and logo.

- **Debian testing:** live ISO with the Calamares installer, for AMD64 and ARM64.
- **Fedora:** bootc image, for AMD64 and ARM64.

## Debian

Download the ISO from [Releases](https://github.com/astrovm/amyos/releases),
write it to a USB stick and boot it.

Both ISOs and their SHA256 checksums publish as prereleases after successful
builds on `main` and every Monday at 10:35 UTC (07:35 in Argentina). Each ISO
is a single file under 2 GiB. Manual workflow runs on `main` also publish.

The ARM64 ISO also boots on:

- **Raspberry Pi 3, 4 and 5:** from an SD card. Live session only.
- **Apple Silicon Macs:** through the Asahi installer's **UEFI environment only** option.

## Fedora

```bash
sudo bootc switch ghcr.io/astrovm/amyos:fedora
```

## Build

```bash
sudo just build      # Debian ISO, into output/
just build-fedora    # Fedora image, as localhost/amyos:fedora
just run-vm          # Boot the newest ISO
```
