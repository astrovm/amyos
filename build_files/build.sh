#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

# RPM packages list
declare -A RPM_PACKAGES=(
  ["fedora"]="\
    AcetoneISO \
    android-tools \
    bchunk \
    bleachbit \
    coolercontrol \
    ghostty \
    gnome-disk-utility \
    gparted \
    hack-nerd-fonts \
    isoimagewriter \
    neovim \
    nmap \
    openrgb \
    qbittorrent \
    rclone \
    starship \
    thefuck \
    tor \
    torsocks \
    ubuntu-nerd-fonts \
    ubuntumono-nerd-fonts \
    virt-manager \
    virt-viewer \
    wireshark"

  ["fedora-multimedia"]="\
    HandBrake-cli \
    HandBrake-gui \
    mpv \
    vlc"

  ["rpmfusion-free,rpmfusion-free-updates,rpmfusion-nonfree,rpmfusion-nonfree-updates"]="\
    audacious \
    audacious-plugins-freeworld \
    audacity-freeworld"

  ["docker-ce"]="\
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin"

  ["brave-browser"]="brave-browser"
  ["cloudflare-warp"]="cloudflare-warp"
  ["vscode"]="code"
)

log "Starting Amy OS build process"

log "Installing RPM packages"
for repo in "${!RPM_PACKAGES[@]}"; do
  read -ra pkg_array <<<"${RPM_PACKAGES[$repo]}"
  if [[ $repo == copr:* ]]; then
    # Handle COPR packages
    copr_repo=${repo#copr:}
    dnf5 -y copr enable "$copr_repo"
    dnf5 -y install "${pkg_array[@]}"
    dnf5 -y copr disable "$copr_repo"
  else
    # Handle regular packages
    [[ $repo != "fedora" ]] && enable_opt="--enable-repo=$repo" || enable_opt=""
    dnf5 -y install $enable_opt "${pkg_array[@]}"
  fi
done

log "Enabling system services"
systemctl enable docker libvirtd

log "Configuring Bash shell"
{
  echo "eval \"\$(starship init bash)\""
  echo "eval \"\$(thefuck --alias)\""
} >>/etc/bashrc

log "Installing Cursor GUI"
GUI_DIR="/tmp/cursor-gui"
mkdir -p "$GUI_DIR"
curl --retry 3 -Lo "$GUI_DIR/cursor.appimage" "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x "$GUI_DIR/cursor.appimage"
(cd "$GUI_DIR" && ./cursor.appimage --appimage-extract)
chmod -R a+rX "$GUI_DIR/squashfs-root"
cp -r "$GUI_DIR/squashfs-root/usr/share/icons/hicolor/"* /usr/share/icons/hicolor
rm -r "$GUI_DIR/squashfs-root/usr/share/icons/hicolor"
mkdir -p /usr/share/cursor/bin
mv "$GUI_DIR/squashfs-root/"* /usr/share/cursor
install -m 0755 /usr/share/cursor/resources/app/bin/cursor /usr/share/cursor/bin/cursor
ln -s /usr/share/cursor/bin/cursor /usr/bin/cursor

log "Installing Cursor CLI"
CLI_DIR="/tmp/cursor-cli"
mkdir -p "$CLI_DIR"
curl --retry 3 -Lo "$CLI_DIR/cursor-cli.tar.gz" "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf "$CLI_DIR/cursor-cli.tar.gz" -C "$CLI_DIR"
install -m 0755 "$CLI_DIR/cursor" /usr/share/cursor/bin/cursor-tunnel
ln -s /usr/share/cursor/bin/cursor-tunnel /usr/bin/cursor-cli

log "Removing autostart files"
rm /etc/xdg/autostart/com.cloudflare.WarpTaskbar.desktop
rm /etc/skel/.config/autostart/steam.desktop

log "Adding Amy OS just recipes"
echo "import \"/usr/share/amyos/just/amy.just\"" >>/usr/share/ublue-os/justfile

log "Hide incompatible Bazzite just recipes"
for recipe in "install-coolercontrol" "install-openrgb" "install-docker"; do
  if ! sed -n "s/^$recipe:/_$recipe:/p" /usr/share/ublue-os/just/82-bazzite-apps.just | grep -q .; then
    echo "Error: Failed to replace $recipe"
    exit 1
  fi
  sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/82-bazzite-apps.just
done

log "Build process completed"
