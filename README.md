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

The `arm64` ISO boots on ARM computers with UEFI firmware, and also on:

- **Raspberry Pi 3, 4 and 5:** write the ISO to an SD card and boot it.
  USB also works on a Pi 4, and on a Pi 3 with USB boot turned on.
  This runs the live session; installing onto a Pi isn't supported yet.
- **Apple Silicon Macs:** run the [Asahi installer](https://asahilinux.org),
  pick **UEFI environment only**, then boot the USB stick.
  Works on the Macs Asahi supports. Debian's kernel lacks some Mac drivers,
  so not all hardware works yet.

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
- `raspberry-pi.sh`: adds the Raspberry Pi boot files to the ARM64 ISO.
