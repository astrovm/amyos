#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo\ \"===* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

# Package lists
declare -A PACKAGES=(
  ["fedora"]="\
    android-tools \
    aria2 \
    bleachbit \
    cmatrix \
    cockpit \
    cockpit-bridge \
    cockpit-machines \
    cockpit-networkmanager \
    cockpit-ostree \
    cockpit-podman \
    cockpit-selinux \
    cockpit-storaged \
    cockpit-system \
    croc \
    fish \
    gnome-disk-utility \
    gparted \
    htop \
    isoimagewriter \
    john \
    neovim \
    nmap \
    openrgb \
    powerline-fonts \
    qbittorrent \
    rclone \
    rustup \
    ShellCheck \
    shfmt \
    solaar \
    thefuck \
    tor \
    torbrowser-launcher \
    torsocks \
    virt-manager \
    virt-viewer \
    wireshark \
    yt-dlp \
    zsh"

  ["rpmfusion-free-updates"]="\
    audacious \
    audacious-plugins-freeworld \
    telegram-desktop"

  ["fedora-multimedia"]="\
    HandBrake-cli \
    HandBrake-gui \
    mpv \
    vlc"

  ["terra"]="\
    audacity-freeworld \
    coolercontrol \
    ghostty \
    hack-nerd-fonts \
    starship \
    ubuntu-nerd-fonts \
    ubuntumono-nerd-fonts \
    WoeUSB-ng \
    youtube-music"

  ["docker-ce"]="\
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin"

  ["brave-browser"]="brave-browser"
  ["cloudflare-warp"]="cloudflare-warp"
  ["signal-desktop"]="signal-desktop"
  ["vscode"]="code"

  ["copr:gloriouseggroll/nobara-41"]="\
    lact \
    scrcpy"
  ["copr:ublue-os/staging"]="devpod"
)

log "Starting Amy OS build process"

# Install all packages
log "Installing packages"
for repo in "${!PACKAGES[@]}"; do
  if [[ $repo == copr:* ]]; then
    # Handle COPR packages
    copr_repo=${repo#copr:}
    dnf5 -y copr enable "$copr_repo"
    read -ra pkg_array <<<"${PACKAGES[$repo]}"
    dnf5 -y install "${pkg_array[@]}"
    dnf5 -y copr disable "$copr_repo"
  else
    # Handle regular packages
    if [ "$repo" != "fedora" ]; then
      enable_opt="--enable-repo=$repo"
    else
      enable_opt=""
    fi
    read -ra pkg_array <<<"${PACKAGES[$repo]}"
    dnf5 -y install $enable_opt "${pkg_array[@]}"
  fi
done

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

# Disable autostart
log "Disabling autostart"
rm -f /etc/xdg/autostart/{solaar.desktop,com.cloudflare.WarpTaskbar.desktop}
rm -f /etc/skel/.config/autostart/steam.desktop

# Configure system
log "Configuring system"
echo "import \"/usr/share/amyos/just/install-apps.just\"" >>/usr/share/ublue-os/justfile
echo "eval \"\$(starship init bash)\"" >>/etc/bashrc
echo "eval \"\$(thefuck --alias)\"" >>/etc/bashrc
echo "starship init fish | source" >>/etc/fish/config.fish
echo "thefuck --alias | source" >>/etc/fish/config.fish

log "Build process completed"
