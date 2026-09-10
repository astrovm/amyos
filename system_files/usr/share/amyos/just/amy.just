# Install all Amy OS curated apps
amy-install: amy-install-flatpaks amy-install-brews amy-install-appimages

# Install only Flatpaks
amy-install-flatpaks:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Flatpaks..."
    xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks) flatpak --system -y install
    echo "Flatpaks installation complete."

# Install only Homebrews
amy-install-brews:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Homebrews..."
    xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews) brew install
    echo "Homebrews installation complete."

# Install only AppImages
amy-install-appimages:
    #!/usr/bin/env bash
    set -euo pipefail

    DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-${HOME}/Downloads}"
    [ ! -d "$DOWNLOAD_DIR" ] && DOWNLOAD_DIR="$HOME"

    # Install Gear Lever if not installed
    flatpak list | grep -q "it.mijorus.gearlever" || flatpak --system -y install it.mijorus.gearlever

    while IFS=, read -r name url; do
      [ -z "$name" -o -z "$url" ] && continue
      echo "Processing $name..."

      # Skip if installed
      if flatpak run it.mijorus.gearlever --list-installed | grep -qi "${name}.appimage"; then
        echo "$name already installed"
        continue
      fi

      # Handle GitHub wildcards
      if [[ "$url" =~ github.com/([^/]+/[^/]+)/releases/download/[^/]*/([^/]*) ]] && [[ "$url" == *"*"* ]]; then
        pattern="$(echo "${BASH_REMATCH[2]}" | sed 's/\./\\./g' | sed 's/\*/.*/g')"
        # Try each release until we find one with an AppImage
        url=""
        while read -r release_url; do
          if [[ "$release_url" =~ $pattern ]]; then
            url="$release_url"
            break
          fi
        done < <(curl --retry 3 -sL "https://api.github.com/repos/${BASH_REMATCH[1]}/releases" | jq -r ".[].assets[].browser_download_url")
        [ -z "$url" ] && {
          echo "No release found for $name"
          continue
        }
      fi

      # Handle JSON API responses
      if [[ "$url" != http*github.com* ]]; then
        response=$(curl --retry 3 -sL "$url")
        if echo "$response" | jq -e '.downloadUrl' >/dev/null 2>&1; then
          url=$(echo "$response" | jq -r '.downloadUrl')
          echo "  Found download URL in JSON: $url"
        elif echo "$response" | jq -e '.download_url' >/dev/null 2>&1; then
          url=$(echo "$response" | jq -r '.download_url')
          echo "  Found download URL in JSON: $url"
        fi
      fi

      # Download and install
      appimage="$DOWNLOAD_DIR/${name}.appimage"
      if aria2c --dir="$(dirname "$appimage")" --out="$(basename "$appimage")" --max-tries=3 --connect-timeout=30 "$url" && chmod +x "$appimage" && flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
        echo "$name installed successfully"
      else
        echo "Failed to install $name"
      fi
      rm -f "$appimage"
    done < <(curl --retry 3 -sL https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)
    echo "AppImages installation complete."

# Setup Amy OS recommended settings for VSCode
amy-setup-editors:
    #!/usr/bin/env bash
    set -euo pipefail

    for editor in "Code"; do
      echo "Setting up $editor configuration..."
      config_dir="${HOME}/.config/${editor}/User"
      mkdir -p "$config_dir"
      cp -f "/etc/skel/.config/${editor}/User/settings.json" "$config_dir/settings.json"
      echo "$editor setup complete."
    done

# Setup Ghostty terminal configuration
amy-setup-ghostty:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting up Ghostty configuration..."
    config_dir="${HOME}/.config/ghostty"
    mkdir -p "$config_dir"
    cp -f "/etc/skel/.config/ghostty/config" "$config_dir/config"
    echo "Ghostty setup complete."

# Setup shell configurations (zsh, bash)
amy-setup-shells:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting up shell configurations..."

    # Setup Zsh configuration
    echo "Setting up Zsh configuration..."
    cp -f "/etc/skel/.zshrc" "${HOME}/.zshrc"
    cp -f "/etc/skel/.zprofile" "${HOME}/.zprofile"
    echo "Zsh configuration complete."

    # Setup Bash configuration
    echo "Setting up Bash configuration..."
    cp -f "/etc/skel/.bashrc" "${HOME}/.bashrc"
    cp -f "/etc/skel/.bash_profile" "${HOME}/.bash_profile"
    cp -f "/etc/skel/.bash_logout" "${HOME}/.bash_logout"
    echo "Bash configuration complete."

    echo "Shell configurations setup complete."

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
    luks_devices=$(sudo dmsetup ls --target crypt) || {
      echo "No LUKS devices found."
      exit 1
    }

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
    done <<<"$luks_devices"

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
      echo "$((i + 1))) ${options[i]}"
    done

    read -p "Select option (1-${#options[@]}): " choice
    [[ ! "$choice" =~ ^[1-${#options[@]}]$ ]] && {
      echo "Invalid option"
      exit 1
    }

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

# Clean up old packages and Docker/Podman images and volumes
amy-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up system..."
    podman system prune -af
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    sudo podman system prune -af
