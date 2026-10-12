#!/usr/bin/bash
# Installs a minimal KDE Plasma desktop and the Amy OS branding.
# Runs inside fedora/Containerfile, with the repo mounted at /ctx.
set -euo pipefail

# Same desktop as the Debian ISO: Plasma, a terminal, files, network, sound, Bluetooth.
dnf -y install --setopt=install_weak_deps=False \
  plasma-desktop plasma-workspace-wayland sddm sddm-breeze sddm-wayland-plasma \
  konsole dolphin systemsettings kscreen powerdevil \
  plasma-nm NetworkManager-wifi wpa_supplicant \
  plasma-pa pipewire-pulseaudio wireplumber \
  bluedevil bluez \
  xdg-desktop-portal-kde xdg-desktop-portal-gtk \
  google-noto-sans-fonts google-noto-color-emoji-fonts \
  plymouth-theme-spinner
dnf clean all

# Branding, shared with the Debian package in branding/.
install -Dm644 /ctx/branding/usr/share/icons/hicolor/256x256/apps/amyos.png \
  /usr/share/icons/hicolor/256x256/apps/amyos.png
install -Dm644 /ctx/branding/usr/share/plymouth/themes/amyos/watermark.png \
  /usr/share/plymouth/themes/spinner/watermark.png
plymouth-set-default-theme spinner

# Keep ID=fedora so Fedora tools keep working; only the shown name changes.
release="$(readlink -f /usr/lib/os-release)"
version="$(sed -n 's/^VERSION_ID=//p' "$release")"
sed -i -E \
  -e "s/^NAME=.*/NAME=\"Amy OS\"/" \
  -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Amy OS (Fedora $version)\"/" \
  -e "s/^LOGO=.*/LOGO=amyos/" \
  -e "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"amyos\"/" \
  -e "s|^HOME_URL=.*|HOME_URL=\"https://github.com/astrovm/amyos\"|" \
  -e "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/astrovm/amyos/issues\"|" \
  "$release"

systemctl enable sddm
systemctl set-default graphical.target

# Rebuild the initramfs so the boot splash uses the Amy OS logo.
kernel="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n' | sort -V | tail -n 1)"
dracut --no-hostonly --kver "$kernel" --reproducible --zstd --add ostree \
  -f "/usr/lib/modules/$kernel/initramfs.img"

# /var and /run are not updated with the image; drop build leftovers.
rm -rf /var/log/dnf5.log* /var/lib/dnf /run/dnf /run/sddm
find /var/cache -mindepth 1 -maxdepth 1 ! -name libdnf5 -exec rm -rf {} +
