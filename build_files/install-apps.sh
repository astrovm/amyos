#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

# RPM packages list
declare -A RPM_PACKAGES=(
  ["fedora"]="\
    android-tools \
    aria2 \
    bchunk \
    bleachbit \
    fuse-btfs \
    fuse-devel \
    fuse3-devel \
    fzf \
    gnome-disk-utility \
    gparted \
    gwenview \
    hashcat \
    isoimagewriter \
    kcalc \
    kgpg \
    ksystemlog \
    neovim \
    nmap \
    openrgb \
    printer-driver-brlaser \
    qemu-kvm \
    thefuck \
    util-linux \
    virt-manager \
    virt-viewer \
    wireshark \
    yakuake \
    yt-dlp \
    zsh-autosuggestions \
    zsh"

  ["terra"]="\
    coolercontrol \
    ghostty \
    hack-nerd-fonts \
    starship \
    ubuntu-nerd-fonts \
    ubuntumono-nerd-fonts \
    ubuntusans-nerd-fonts"

  ["fedora-multimedia"]="\
    HandBrake-cli \
    HandBrake-gui \
    haruna \
    mpv \
    vlc-plugin-bittorrent \
    vlc-plugin-ffmpeg \
    vlc-plugin-kde \
    vlc-plugin-pause-click \
    vlc"

  ["brave-browser"]="brave-browser"
  ["vscode"]="code"
)

log "Starting Amy OS build process"

log "Installing RPM packages"
mkdir -p /var/opt
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
    cmd=(dnf5 -y install)
    [[ -n "$enable_opt" ]] && cmd+=("$enable_opt")
    cmd+=("${pkg_array[@]}")
    "${cmd[@]}"
  fi
done

log "Build process completed"
