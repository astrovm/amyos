# Amy OS (Debian testing)

Debian testing with KDE Plasma, as a live USB with the Calamares installer.

It's plain Debian with the Amy OS name and logo. Update it with `apt`.

The image includes a minimal Plasma desktop, a terminal, and Calamares.
A web browser is not preinstalled. After installation, install Firefox with
`sudo apt install firefox-esr`.

## Install

1. Download the ISO from [Releases](https://github.com/astrovm/amyos/releases).
2. Write it to a USB stick.
3. Boot it and open **Install Amy OS** on the desktop.

## Build

Needs `just` and `podman`. The ISO lands in `output/`.

```bash
sudo just build
just run-vm        # or: just run-vm bios
```

CI builds the ISO on every push to `debian`.
Run the workflow by hand on `debian` to publish a release.

## Layout

- `live/`: live-build config (packages, boot menu, Calamares).
- `branding/`: the `amyos-branding` package (name, logo, boot splash).
- `build.sh`: builds both inside a Debian testing container.
