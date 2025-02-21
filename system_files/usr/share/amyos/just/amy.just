# Install all Amy OS curated apps
amy-install: amy-install-flatpaks amy-install-appimages amy-install-nixpkgs

# Install only Flatpaks
amy-install-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Flatpaks..."
  ujust _install-system-flatpaks
  xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks) flatpak --system -y install
  echo "Flatpaks installation complete."

# Install only AppImages
amy-install-appimages:
  #!/usr/bin/env bash
  set -euo pipefail

  DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-${HOME}/Downloads}"
  [ ! -d "$DOWNLOAD_DIR" ] && DOWNLOAD_DIR="$HOME"

  # Install Gear Lever if not installed
  flatpak list | grep -q "it.mijorus.gearlever" || flatpak --system -y install it.mijorus.gearlever

  while IFS=, read -r name url; do
    [ -z "$name" ] || [ -z "$url" ] && continue
    echo "Processing $name..."

    # Skip if installed
    if flatpak run it.mijorus.gearlever --list-installed | grep -qi "${name}.appimage"; then
      echo "$name already installed"
      continue
    fi

    # Handle GitHub wildcards
    if [[ "$url" =~ github.com/([^/]+/[^/]+)/releases/download/[^/]*/([^/]*) ]] && [[ "$url" == *"*"* ]]; then
      pattern="$(echo "${BASH_REMATCH[2]}" | sed 's/\./\\./g' | sed 's/\*/.*/g')"
      url=$(curl --retry 3 -sL "https://api.github.com/repos/${BASH_REMATCH[1]}/releases" | jq -r ".[0].assets[].browser_download_url" | grep -E "$pattern" | head -n1)
      [ -z "$url" ] && { echo "No release found for $name"; continue; }
    fi

    # Download and install
    appimage="$DOWNLOAD_DIR/${name}.appimage"
    if curl --retry 3 -Lo "$appimage" "$url" && chmod +x "$appimage" && flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
      echo "$name installed successfully"
    else
      echo "Failed to install $name"
    fi
    rm -f "$appimage"
  done < <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)
  echo "AppImages installation complete."

# Install only Nix packages
amy-install-nixpkgs:
  #!/usr/bin/env bash
  set -euo pipefail

  # Install Nix if not installed
  [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  command -v nix &>/dev/null || ujust amy-setup-nix

  echo "Installing Nix packages..."
  xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/nixpkgs) nix profile install
  echo "Nix packages installation complete."

# Setup Nix package manager
amy-setup-nix:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Setting up Nix package manager..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # Add LD_LIBRARY_PATH to bash profile if not already present
  PROFILE_FILE="${HOME}/.bash_profile"
  EXPORT_LINE='export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.nix-profile/lib'
  if ! grep -q "LD_LIBRARY_PATH.*nix-profile/lib" "$PROFILE_FILE" 2>/dev/null; then
    echo "$EXPORT_LINE" >> "$PROFILE_FILE"
    echo "Added Nix library path to bash profile"
  fi

  echo "Nix setup complete."

# Setup Amy OS recommended settings for Cursor and VSCode
amy-setup-editors:
  #!/usr/bin/env bash
  set -euo pipefail

  for editor in "Cursor" "Code"; do
    echo "Setting up $editor configuration..."
    config_dir="${HOME}/.config/${editor}/User"
    mkdir -p "$config_dir"
    cp -f "/etc/skel/.config/${editor}/User/settings.json" "$config_dir/settings.json"
    echo "$editor configuration complete."
  done

# Setup Git and GitHub SSH key
amy-setup-git:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Setting up Git SSH key..."

  # Ask for Git username and email
  read -p "Enter your Git username: " git_username
  read -p "Enter your Git email: " git_email

  # Configure Git
  git config --global color.ui true
  git config --global user.name "$git_username"
  git config --global user.email "$git_email"

  # Generate SSH key
  echo "Generating SSH key..."
  ssh-keygen -t ed25519 -C "$git_email"

  # Display the public key
  echo "Your SSH public key:"
  cat ~/.ssh/id_ed25519.pub

  echo "Git configuration complete."
  echo "Add the above SSH key to your GitHub account at: https://github.com/settings/ssh"

# Restart Bluetooth to fix issues
amy-fix-bt:
  #!/usr/bin/env bash
  set -euo pipefail
  trap '[[ $BASH_COMMAND != echo* ]] && echo "+ $BASH_COMMAND"' DEBUG

  echo "Fixing Bluetooth..."
  sudo rfkill unblock all
  sudo rmmod btusb
  sudo modprobe btusb
  echo "Bluetooth fix complete."

# Manage SSD encryption optimizations (Workqueue and TRIM)
amy-ssd-crypto:
  #!/usr/bin/env bash
  set -euo pipefail

  # Get LUKS2 devices
  luks_devices=$(sudo dmsetup ls --target crypt) || { echo "No LUKS devices found."; exit 1; }

  # Display devices and their settings
  echo "LUKS2 Devices and Settings:"
  echo "=========================="

  while read -r name _; do
    [ -z "$name" ] && continue

    status=$(sudo cryptsetup status "$name")
    device=$(echo "$status" | grep "device:" | cut -d: -f2 | xargs)

    # Skip if not LUKS2
    sudo cryptsetup isLuks --type luks2 "$device" 2>/dev/null || continue

    flags=$(echo "$status" | grep "flags:" | cut -d: -f2 | xargs)
    echo "Device: $name (${device})"
    echo "- TRIM: $(echo "$flags" | grep -q "discards" && echo "enabled" || echo "disabled")"
    echo "- No read workqueue: $(echo "$flags" | grep -q "no_read_workqueue" && echo "enabled" || echo "disabled")"
    echo "- No write workqueue: $(echo "$flags" | grep -q "no_write_workqueue" && echo "enabled" || echo "disabled")"
    echo "--------------------------"
  done <<< "$luks_devices"

  # Get and validate device selection
  read -p "Enter LUKS device name to optimize (or press Enter to exit): " device
  [ -z "$device" ] && exit 0

  if ! sudo cryptsetup status "$device" &>/dev/null; then
    echo "Error: Device $device not found"
    exit 1
  fi

  source_dev=$(sudo cryptsetup status "$device" | grep "device:" | cut -d: -f2 | xargs)
  if ! sudo cryptsetup isLuks --type luks2 "$source_dev" 2>/dev/null; then
    echo "Error: Device $device is not a LUKS2 device"
    exit 1
  fi

  # Check TRIM support
  supports_trim=$(sudo lsblk --pairs --discard "$source_dev" | head -n1 | grep -E 'DISC-GRAN="[1-9].*DISC-MAX="[1-9]')

  # Show menu options
  echo -e "\nSelect optimization option:"
  if [[ -n "$supports_trim" ]]; then
    options=(
      "Enable workqueue optimizations with TRIM"
      "Enable workqueue optimizations without TRIM"
      "Disable all optimizations"
    )
  else
    options=(
      "Enable workqueue optimizations"
      "Disable all optimizations"
    )
  fi

  for i in "${!options[@]}"; do
    echo "$((i+1))) ${options[i]}"
  done

  read -p "Select option (1-${#options[@]}): " choice
  [[ ! "$choice" =~ ^[1-${#options[@]}]$ ]] && { echo "Invalid option"; exit 1; }

  # Apply selected optimization
  case $choice in
    1)
      if [[ -n "$supports_trim" ]]; then
        sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --allow-discards --persistent refresh "$device"
        echo "✓ Workqueue optimizations enabled with TRIM"
      else
        sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh "$device"
        echo "✓ Workqueue optimizations enabled"
      fi
      ;;
    2)
      if [[ -n "$supports_trim" ]]; then
        sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh "$device"
        echo "✓ Workqueue optimizations enabled without TRIM"
      else
        sudo cryptsetup --persistent refresh "$device"
        echo "✓ All optimizations disabled"
      fi
      ;;
    3)
      sudo cryptsetup --persistent refresh "$device"
      echo "✓ All optimizations disabled"
      ;;
  esac

# Setup Sonic Adventure DX mods
amy-setup-sadx:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Setting up SADX mods..."

  # Install ProtonTricks if not installed
  flatpak list | grep -q "com.github.Matoking.protontricks" || flatpak --system -y install com.github.Matoking.protontricks

  # Install ProtonUp-Qt if not installed
  flatpak list | grep -q "net.davidotek.pupgui2" || flatpak --system -y install net.davidotek.pupgui2

  # Configure Steam directory access
  flatpak override --user --filesystem="${HOME}/.local/share/Steam" com.github.Matoking.protontricks

  echo -e "\n=== Steam Configuration Steps ==="
  echo "1. ProtonUp-Qt will now launch. Please install GE-Proton."
  flatpak run net.davidotek.pupgui2 &>/dev/null

  echo -e "\nIn Steam, configure Sonic Adventure DX:"
  echo "1. Right-click the game → Properties"
  echo "2. Add this to Launch Options:"
  echo "   WINEDLLOVERRIDES=\"d3d8=n,b\" %command%"
  echo "3. Enable 'Force the use of a specific Steam Play compatibility tool'"
  echo "4. Select the GE-Proton version you just installed"
  echo "5. Launch the game once and exit"
  echo -e "\nPress Enter once you've completed these steps..."
  read -p ""

  # Find SADX installation path
  library_config="${HOME}/.steam/steam/steamapps/libraryfolders.vdf"
  SADX_DIR=""
  if [ -f "$library_config" ]; then
    while IFS= read -r line; do
      if [[ $line =~ \"path\"[[:space:]]*\"([^\"]+)\" ]]; then
        possible_path="${BASH_REMATCH[1]}/steamapps/common/Sonic Adventure DX"
        if [ -d "$possible_path" ]; then
          SADX_DIR="$possible_path"
          # Add Flatpak override for the Steam library
          flatpak override --user --filesystem="${BASH_REMATCH[1]}" com.github.Matoking.protontricks
          break
        fi
      fi
    done < "$library_config"
  fi
  [ -z "$SADX_DIR" ] && { echo "Error: Could not find SADX installation. Please launch the game first."; exit 1; }

  # Download and run mod installer
  installer="${SADX_DIR}/sadx_setup.exe"
  echo -e "\nDownloading mod installer..."
  curl --retry 3 -Lo "$installer" "https://dcmods.unreliable.network/owncloud/data/PiKeyAr/files_versions/Setup/sadx_setup.exe.v1736656352"

  echo -e "\nInstalling .NET Desktop Runtime 8..."
  flatpak run com.github.Matoking.protontricks 71250 dotnetdesktop8 &>/dev/null

  # Convert path to Windows format
  WIN_PATH="Z:${SADX_DIR//\//\\}"

  echo -e "\n=== Mod Installation ==="
  echo "When the SADX Mod Installer launches, use this path as the Destination Folder:"
  echo "${WIN_PATH}"
  flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid 71250 "$installer" &>/dev/null

  echo -e "\n=== Final Configuration Steps ==="
  echo "1. Launch SADX and select 'Configure'"
  echo "2. Navigate to: Mods → Game Config → Graphics"
  echo "3. Set your display and resolution settings"
  echo "4. Click 'Save & Play' to start the game"
  echo -e "\nSetup complete! Enjoy playing SADX with mods!"
