# Install all Amy OS curated apps
amy-install: amy-install-flatpaks amy-install-brews amy-install-appimages

# Install only Flatpaks
amy-install-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Flatpaks..."
  ujust _install-system-flatpaks
  flatpak --system -y install $(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks)
  echo "Flatpaks installation complete."

# Install only Homebrews
amy-install-brews:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Homebrews..."
  brew install $(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews)
  echo "Homebrews installation complete."

# Install only AppImages
amy-install-appimages:
  #!/usr/bin/env bash
  set -euo pipefail

  DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-${HOME}/Downloads}"
  [ ! -d "$DOWNLOAD_DIR" ] && DOWNLOAD_DIR="$HOME"

  # Install Gear Lever if needed
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

# Setup Amy OS recommended settings for Cursor and VSCode
amy-setup-editors:
  #!/usr/bin/env bash
  set -euo pipefail
  trap '[[ $BASH_COMMAND != echo* ]] && echo "+ $BASH_COMMAND"' DEBUG

  echo "Setting up Cursor configuration..."
  CURSOR_CONFIG_DIR="${HOME}/.config/Cursor/User"
  mkdir -p "$CURSOR_CONFIG_DIR"
  rm -f "$CURSOR_CONFIG_DIR/settings.json"
  cp /etc/skel/.config/Cursor/User/settings.json "$CURSOR_CONFIG_DIR/settings.json"
  echo "Cursor configuration complete."

  echo "Setting up VSCode configuration..."
  VSCODE_CONFIG_DIR="${HOME}/.config/Code/User"
  mkdir -p "$VSCODE_CONFIG_DIR"
  rm -f "$VSCODE_CONFIG_DIR/settings.json"
  cp /etc/skel/.config/Code/User/settings.json "$VSCODE_CONFIG_DIR/settings.json"
  echo "VSCode configuration complete."


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

# Manage SSD devices encryption performance settings
amy-ssd-crypto:
  #!/usr/bin/env bash
  set -euo pipefail

  # List LUKS2 devices and their current settings
  list_devices() {
    local luks_devices
    luks_devices=$(sudo dmsetup ls --target crypt) || true

    if [ -z "$luks_devices" ]; then
      echo "No LUKS devices found."
      return 1
    fi

    echo "LUKS Devices:"
    echo "=============================================="

    while read -r name _; do
      [ -z "$name" ] && continue

      local status
      status=$(sudo cryptsetup status "$name")
      local device=$(echo "$status" | grep "device:" | cut -d: -f2 | xargs)
      local flags=$(echo "$status" | grep "flags:" | cut -d: -f2 | xargs)

      # Check if it's LUKS2
      if ! sudo cryptsetup isLuks --type luks2 "$device" 2>/dev/null; then
        continue
      fi

      echo "Device: $name"
      echo "Source: $device"
      echo "Optimizations:"
      echo "- TRIM: $(echo "$flags" | grep -q "discards" && echo "enabled" || echo "disabled")"
      echo "- No read workqueue: $(echo "$flags" | grep -q "no_read_workqueue" && echo "enabled" || echo "disabled")"
      echo "- No write workqueue: $(echo "$flags" | grep -q "no_write_workqueue" && echo "enabled" || echo "disabled")"
      echo "----------------------------------------------"
    done <<< "$luks_devices"
  }

  # Check if device supports TRIM
  check_trim() {
    local device="$1"
    local disc_info
    disc_info=$(sudo lsblk --pairs --discard "$device" | head -n1)
    local disc_gran=$(echo "$disc_info" | grep -o 'DISC-GRAN="[^"]*"' | cut -d'"' -f2)
    local disc_max=$(echo "$disc_info" | grep -o 'DISC-MAX="[^"]*"' | cut -d'"' -f2)

    [[ "$disc_gran" != "0" ]] && [[ "$disc_max" != "0" ]]
  }

  # Main script
  echo "SSD Encryption Performance Manager"
  echo "=============================================="

  # List current devices and settings
  list_devices || exit 1

  # Get device selection
  echo
  read -p "Enter LUKS device name to optimize (or press Enter to exit): " device
  [ -z "$device" ] && exit 0

  # Verify device exists and is LUKS2
  if ! sudo cryptsetup status "$device" &>/dev/null; then
    echo "Error: Device $device not found"
    exit 1
  fi

  # Get source device
  source_dev=$(sudo cryptsetup status "$device" | grep "device:" | cut -d: -f2 | xargs)

  # Verify it's LUKS2
  if ! sudo cryptsetup isLuks --type luks2 "$source_dev" 2>/dev/null; then
    echo "Error: Device $device is not a LUKS2 device"
    exit 1
  fi

  echo
  echo "Available optimizations:"
  echo "1) Enable all optimizations (with TRIM if supported)"
  echo "2) Enable optimizations without TRIM"
  echo "3) Disable all optimizations"
  echo
  read -p "Select option (1-3): " choice

  case $choice in
    1)
      if check_trim "$source_dev"; then
        sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --allow-discards --persistent refresh "$device"
        echo "✓ All optimizations enabled with TRIM support"
      else
        echo "! TRIM not supported, enabling other optimizations only"
        sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh "$device"
      fi
      ;;
    2)
      sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh "$device"
      echo "✓ Optimizations enabled without TRIM"
      ;;
    3)
      sudo cryptsetup --persistent refresh "$device"
      echo "✓ All optimizations disabled"
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
