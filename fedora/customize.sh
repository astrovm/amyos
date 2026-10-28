#!/usr/bin/bash
# Applies the Amy OS name, logo, look and settings to an installed Fedora tree.
# Shared by the bootc image (build.sh) and the live ISO (live/config.sh).
# Usage: customize.sh <repo directory>
set -euo pipefail
repo="$1"

# Shared branding assets.
install -Dm644 "$repo/branding/usr/share/icons/hicolor/256x256/apps/amyos.png" \
  /usr/share/icons/hicolor/256x256/apps/amyos.png
cp -a "$repo/branding/usr/share/plymouth/themes/amyos" /usr/share/plymouth/themes/
plymouth-set-default-theme amyos

# Plasma's own look instead of Fedora's, like the Debian ISO.
# Fedora's wallpaper and login theme are hard dependencies, so point them away.
ln -sfn Next /usr/share/wallpapers/Default
install -Dm644 /dev/stdin /etc/sddm.conf.d/amyos.conf <<'CONF'
[Theme]
Current=breeze
CONF
# The app launcher shows the start-here icon, which Fedora sets to its logo.
rm -f /usr/share/icons/hicolor/scalable/{apps,places}/start-here.svg
for dir in apps places; do
  install -Dm644 "$repo/branding/usr/share/icons/hicolor/256x256/apps/amyos.png" \
    "/usr/share/icons/hicolor/256x256/$dir/start-here.png"
done
# Unpins taskbar apps that aren't installed, like Discover.
install -Dm644 -t /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates \
  "$repo/branding/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/amyos-unpin-missing-apps.js"
cat >/etc/xdg/kcm-about-distrorc <<'CONF'
[General]
LogoPath=/usr/share/icons/hicolor/256x256/apps/amyos.png
Website=https://github.com/astrovm/amyos
CONF

# Plain KDE look and lock screen wallpaper instead of Fedora's, like the Debian build.
printf '[KDE]\nLookAndFeelPackage=org.kde.breezedark.desktop\n' >/etc/xdg/kdeglobals
cat >/etc/xdg/kscreenlockerrc <<'CONF'
[Greeter][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/Next/
PreviewImage=file:///usr/share/wallpapers/Next/
CONF

install -Dm755 "$repo/fedora/update-os-release" /usr/lib/amyos/update-os-release
/usr/lib/amyos/update-os-release

# Same memory limits as the Debian ISO: games and Wine need many maps, editors many watches.
install -Dm644 /dev/stdin /etc/sysctl.d/99-amyos.conf <<'CONF'
vm.max_map_count = 2147483642
fs.inotify.max_user_watches = 524288
CONF

systemctl enable sddm
systemctl set-default graphical.target
