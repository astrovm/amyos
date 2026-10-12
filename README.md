# Amy OS (Debian testing)

Debian testing with KDE Plasma, as a live USB with the Calamares installer.

It's plain Debian with the Amy OS name and logo. Update it with `apt`.

The image includes a minimal Plasma desktop, a terminal, and Calamares.
A web browser is not preinstalled. After installation, install Firefox with
`sudo apt install firefox-esr`.

## Install

1. Download the ISO for your computer from [Releases](https://github.com/astrovm/amyos/releases):
   `amd64` for Intel and AMD, `arm64` for ARM.
2. Write it to a USB stick.
3. Boot it and open **Install Amy OS** on the desktop.

### ARM

The `arm64` ISO boots on any ARM computer with UEFI firmware.

- **Raspberry Pi 4:** put the [Pi 4 UEFI firmware](https://github.com/pftf/RPi4)
  on an SD card first, then boot the USB stick.
- **Apple Silicon Macs:** run the [Asahi installer](https://asahilinux.org),
  pick **UEFI environment only**, then boot the USB stick.
  Debian's kernel lacks some Mac drivers, so not all hardware works yet.

## Build

Needs `just` and `podman`. The ISO lands in `output/`.

```bash
sudo just build
just run-vm        # or: just run-vm bios
```

It builds for the machine's own architecture.
CI builds both ISOs on every push to `debian`.
Run the workflow by hand on `debian` to publish a release.

## Layout

- `live/`: live-build config (packages, boot menu, Calamares).
- `branding/`: the `amyos-branding` package (name, logo, boot splash).
- `build.sh`: builds both inside a Debian testing container.
