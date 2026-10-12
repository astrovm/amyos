# Amy OS

A minimal KDE Plasma desktop with the Amy OS name and logo, in two flavors:

- **Debian testing:** a live USB with the Calamares installer. Update it with `apt`.
- **Fedora:** a bootc image. It updates as a whole with `bootc upgrade`.

Both include Plasma, a terminal and a file manager. No web browser is
preinstalled.

## Install Debian

1. Download the ISO for your computer from [Releases](https://github.com/astrovm/amyos/releases):
   `amd64` for Intel and AMD, `arm64` for ARM.
2. Write it to a USB stick.
3. Boot it and open **Install Amy OS** on the desktop.

Install Firefox afterwards with `sudo apt install firefox-esr`.

### ARM

The `arm64` ISO boots on ARM computers with UEFI firmware, and also on:

- **Raspberry Pi 3, 4 and 5:** write the ISO to an SD card and boot it.
  USB also works on a Pi 4, and on a Pi 3 with USB boot turned on.
  This runs the live session; installing onto a Pi isn't supported yet.
- **Apple Silicon Macs:** run the [Asahi installer](https://asahilinux.org),
  pick **UEFI environment only**, then boot the USB stick.
  Works on the Macs Asahi supports. Debian's kernel lacks some Mac drivers,
  so not all hardware works yet.

## Install Fedora

From any Fedora Atomic or bootc system, on AMD64 or ARM64:

```bash
sudo bootc switch ghcr.io/astrovm/amyos:fedora
```

Reboot, then update with `sudo bootc upgrade`. Images are signed with
`cosign.pub`. Install Firefox with `sudo rpm-ostree install firefox`.

## Build

Needs `just` and `podman`. Both build for the machine's own architecture.

```bash
sudo just build      # Debian ISO, lands in output/
just run-vm          # or: just run-vm bios
just build-fedora    # Fedora image, as localhost/amyos:fedora
```

CI builds both ISOs and the Fedora image on every push and pull request.
Run the workflow by hand to publish the ISOs as a release.
The default branch also publishes the Fedora image, and rebuilds it daily.

## Layout

- `live/`: live-build config (packages, boot menu, Calamares).
- `branding/`: the `amyos-branding` package (name, logo, boot splash).
- `build.sh`: builds the ISO inside a Debian testing container.
- `raspberry-pi.sh`: adds the Raspberry Pi boot files to the ARM64 ISO.
- `fedora/`: the Fedora bootc image (`Containerfile` and its build script).
  It reuses the logo and boot splash from `branding/`.
