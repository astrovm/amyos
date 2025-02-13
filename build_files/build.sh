#!/usr/bin/env bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo\ \"===* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

# Package lists
FEDORA_PACKAGES=(
  android-tools aria2 bleachbit cmatrix croc gnome-disk-utility gparted htop
  john libvirt-nss mpv neovim nmap openrgb powerline-fonts protonvpn-cli
  rclone rustup ShellCheck shfmt solaar source-foundry-hack-fonts thefuck
  tor torsocks virt-manager wireshark yt-dlp
)

RPM_FUSION_PACKAGES=(
  audacious audacious-plugins-freeworld
)

TERRA_PACKAGES=(
  coolercontrol ghostty starship
)

DOCKER_PACKAGES=(
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin
)

log "Starting Amy OS build process"

# Install packages
log "Installing Fedora packages"
dnf5 -y install "${FEDORA_PACKAGES[@]}"

log "Installing RPM Fusion packages"
dnf5 -y install --enable-repo="*rpmfusion*" "${RPM_FUSION_PACKAGES[@]}"

log "Installing Terra packages"
dnf5 -y install --enable-repo="terra" "${TERRA_PACKAGES[@]}"

log "Installing Docker"
dnf5 -y install --enable-repo="docker-ce-stable" "${DOCKER_PACKAGES[@]}"

# Install individual packages from their repos
log "Installing additional packages"
dnf5 -y install --enable-repo="brave-browser" brave-browser
dnf5 -y install --enable-repo="cloudflare-warp" cloudflare-warp
dnf5 -y install --enable-repo="vscode" code

# Install packages from COPR repos
log "Installing COPR packages"
for repo in "atim/ubuntu-fonts:ubuntu-family-fonts" \
  "zeno/scrcpy:scrcpy" \
  "ublue-os/staging:devpod" \
  "ilyaz/LACT:lact"; do
  IFS=: read -r repo_name pkg_name <<<"$repo"
  dnf5 -y copr enable "$repo_name"
  dnf5 -y install "$pkg_name"
  dnf5 -y copr disable "$repo_name"
done

# Install Gamescope Session
log "Installing Gamescope Session"
mkdir -p /usr/share/gamescope-session-plus
curl -Lo /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz
dnf5 -y install --repo copr:copr.fedorainfracloud.org:kylegospo:bazzite gamescope-session-plus gamescope-session-steam

# Install Cursor
log "Installing Cursor"
# GUI version
curl --retry 3 -Lo /tmp/cursor-gui.appimage "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x /tmp/cursor-gui.appimage
/tmp/cursor-gui.appimage --appimage-extract
mkdir -p /usr/share/cursor
cp -r ./squashfs-root/* /usr/share/cursor
rm -rf ./squashfs-root
chmod -R a+rX /usr/share/cursor
mkdir -p /usr/share/cursor/bin
install -m 0755 /usr/share/cursor/resources/app/bin/cursor /usr/share/cursor/bin/cursor
# Move Cursor AppImage wrapper script as fallback
mv /usr/bin/cursor /usr/bin/cursor-appimage
ln -s /usr/share/cursor/bin/cursor /usr/bin/cursor
cp -r /usr/share/cursor/usr/share/icons/hicolor/* /usr/share/icons/hicolor
# CLI version
curl --retry 3 -Lo /tmp/cursor-cli.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf /tmp/cursor-cli.tar.gz -C /tmp
install -m 0755 /tmp/cursor /usr/share/cursor/bin/cursor-tunnel
ln -s /usr/share/cursor/bin/cursor-tunnel /usr/bin/cursor-cli

# Enable services
log "Enabling system services"
systemctl enable docker libvirtd

# Configure system
log "Configuring system"
echo "import \"/usr/share/amyos/just/install-apps.just\"" >>/usr/share/ublue-os/justfile
echo "eval \"\$(starship init bash)\"" >>/etc/bashrc
echo "eval \"\$(thefuck --alias)\"" >>/etc/bashrc

log "Build process completed"
