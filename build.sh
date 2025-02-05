#!/bin/bash
set -ouex pipefail

# Create directories
mkdir -p /var/opt

# Install Fedora packages
dnf5 -y install \
    android-tools \
    bleachbit \
    gparted \
    htop \
    isoimagewriter \
    gnome-disk-utility \
    libvirt-nss \
    mpv \
    neovim \
    nmap \
    powerline-fonts \
    protonvpn-cli \
    rclone \
    solaar \
    syncthing \
    tor \
    torsocks \
    virt-manager \
    wireshark

# Install RPM Fusion packages
dnf5 -y install --enable-repo="*rpmfusion*" \
    audacious \
    audacious-plugins-freeworld

# Install Terra packages
dnf5 -y install --enable-repo="terra" \
dnf5 -y install \
    coolercontrol \
    ghostty

# Install Docker
dnf5 -y install --enable-repo="docker-ce-stable" \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    containerd.io

# Install Brave Browser
dnf5 -y install --enable-repo="brave-browser" \
    brave-browser

# Install Cloudflare Warp
dnf5 -y install --enable-repo="cloudflare-warp" \
    cloudflare-warp

# Install VSCode
dnf5 -y install --enable-repo="vscode" \
    code

# Install Ubuntu fonts
dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y install ubuntu-family-fonts
dnf5 -y copr disable atim/ubuntu-fonts

# Install Scrcpy
dnf5 -y copr enable zeno/scrcpy
dnf5 -y install scrcpy
dnf5 -y copr disable zeno/scrcpy

# Install DevPod
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod
dnf5 -y copr disable ublue-os/staging

# Install Lact
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT

# Move directories from /var/opt to /usr/lib and create symlinks
for dir in /var/opt/*/; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        mv "$dir" "/usr/lib/$dirname"
        echo "L  /opt/$dirname -  -  -  -  /usr/lib/$dirname" >> /usr/lib/tmpfiles.d/relocated-directories.conf
    fi
done

# Enable services
systemctl enable libvirtd
systemctl enable docker

# Import Amy OS justfile
echo "import \"/usr/share/amyos/just/install-apps.just\"" >> /usr/share/ublue-os/justfile

# Add Starship Shell Prompt
curl --retry 3 -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
echo "eval \"\$(starship init bash)\"" >> /etc/bashrc

# Add Cursor CLI
curl --retry 3 -Lo /tmp/cursor.tar.gz "https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64"
tar -xzf /tmp/cursor.tar.gz -C /tmp
mv /tmp/cursor /tmp/cursor-cli
install -c -m 0755 /tmp/cursor-cli /usr/bin

# Clean cache
dnf5 clean all
rm -rf /tmp/* || true
