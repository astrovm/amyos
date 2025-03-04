# Install all Amy OS apps
amy-install: amy-install-flatpaks amy-install-appimages amy-install-nixpkgs

# Install only Flatpaks
amy-install-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Flatpaks..."
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
      [ -z "$url" ] && {
        echo "No release found for $name"
        continue
      }
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

  NIX_PROFILE="/nix/var/nix/profiles/default"
  NIX_DAEMON_SCRIPT="$NIX_PROFILE/etc/profile.d/nix-daemon.sh"
  OPENGL_PROFILE="/nix/var/nix/profiles/opengl-driver"
  OPENGL_PROFILE_32="/nix/var/nix/profiles/opengl-driver-32"
  OPENGL_SYMLINK_CONF="/etc/tmpfiles.d/nix-opengl-driver.conf"

  # Source Nix daemon if available
  [ -f "$NIX_DAEMON_SCRIPT" ] && . "$NIX_DAEMON_SCRIPT"
  command -v nix &>/dev/null || ujust amy-setup-nix

  echo "Installing Nix system fonts..."
  sudo -i nix profile install nixpkgs#nerd-fonts.{hack,ubuntu,ubuntu-mono,ubuntu-sans}

  echo "Installing Nix system drivers..."
  sudo -i nix profile install --profile "$OPENGL_PROFILE" nixpkgs#{amdvlk,mesa.drivers}

  echo "Installing Nix system 32-bit drivers..."
  sudo -i nix profile install --profile "$OPENGL_PROFILE_32" nixpkgs#driversi686Linux.{amdvlk,mesa.drivers}

  echo "Setting up drivers symlink..."
  sudo rm -f "$OPENGL_SYMLINK_CONF"
  printf "L+ /run/opengl-driver - - - - %s\nL+ /run/opengl-driver-32 - - - - %s\n" "$OPENGL_PROFILE" "$OPENGL_PROFILE_32" | sudo tee "$OPENGL_SYMLINK_CONF"
  sudo systemd-tmpfiles --create "$OPENGL_SYMLINK_CONF"

  echo "Nix packages installation complete."

# Setup Nix package manager
amy-setup-nix:
  #!/usr/bin/env bash
  set -euo pipefail

  NIX_DAEMON_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  NIX_INSTALLER="https://install.determinate.systems/nix"

  echo "Setting up Nix package manager..."
  curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER" | sh -s -- install --no-confirm
  [ -f "$NIX_DAEMON_SCRIPT" ] && . "$NIX_DAEMON_SCRIPT"
  echo "Nix setup complete."

# Setup Nix Home Manager with Amy OS config
amy-setup-home:
  #!/usr/bin/env bash
  set -euo pipefail

  # Source Nix daemon if available
  NIX_DAEMON_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  [ -f "$NIX_DAEMON_SCRIPT" ] && . "$NIX_DAEMON_SCRIPT"
  command -v nix &>/dev/null || ujust amy-setup-nix

  echo "Setting up Nix Home Manager..."

  # Resolve real home path in case it's a symlink
  REAL_HOME=$(readlink -f "$HOME")
  HM_CONFIG_DIR="${REAL_HOME}/.config/home-manager"
  SKEL_CONFIG_DIR="/etc/skel/.config/home-manager"
  CONFIG_FILES=("user.nix" "home.nix" "flake.nix")

  # Create config directory if it doesn't exist
  mkdir -p "$HM_CONFIG_DIR"

  # Check and handle each config file
  for file in "${CONFIG_FILES[@]}"; do
    user_file="${HM_CONFIG_DIR}/${file}"
    skel_file="${SKEL_CONFIG_DIR}/${file}"

    if [ ! -f "$user_file" ]; then
      echo "Copying $file from skeleton..."
      cp "$skel_file" "$user_file"
    elif ! cmp -s "$user_file" "$skel_file"; then
      echo "Warning: $file exists and differs from skeleton file."
      echo "Please manually merge your changes or backup and remove the file to use defaults."
      exit 1
    fi
  done

  # Configure user.nix
  echo "Configuring user settings..."
  sed -i "0,/userName = \"\"/s//userName = \"$USER\"/" "$HM_CONFIG_DIR/user.nix"
  sed -i "s|homeDirectory = \"\"|homeDirectory = \"$REAL_HOME\"|" "$HM_CONFIG_DIR/user.nix"

  # Prompt for Git configuration
  read -p "Enter your Git user name: " git_name
  read -p "Enter your Git email: " git_email
  sed -i "/gitConfig = {/,/};/c\\  gitConfig = {\n    userName = \"$git_name\";\n    userEmail = \"$git_email\";\n  };" "$HM_CONFIG_DIR/user.nix"

  # Initialize and switch to the new configuration
  nix run home-manager/release-24.11 -- init --switch "$HM_CONFIG_DIR"
  echo "Nix Home Manager setup complete."

# Setup Amy OS recommended settings for Cursor and VSCode
amy-setup-editors:
  #!/usr/bin/env bash
  set -euo pipefail

  for editor in "Cursor" "Code"; do
    echo "Setting up $editor configuration..."
    config_dir="${HOME}/.config/${editor}/User"
    mkdir -p "$config_dir"
    cp -f "/etc/skel/.config/${editor}/User/settings.json" "$config_dir/settings.json"
    echo "$editor setup complete."
  done

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

# Setup Sonic Adventure mods (DX or SA2)
amy-setup-samods game="both":
  #!/usr/bin/env bash
  set -euo pipefail

  # Handle game selection
  case "$game" in
    "sadx"|"dx"|"1")
      echo "Setting up Sonic Adventure DX mods..."
      setup_sadx=true
      setup_sa2=false
      ;;
    "sa2"|"2")
      echo "Setting up Sonic Adventure 2 mods..."
      setup_sadx=false
      setup_sa2=true
      ;;
    "both"|"all")
      echo "Setting up mods for both Sonic Adventure DX and Sonic Adventure 2..."
      setup_sadx=true
      setup_sa2=true
      ;;
    *)
      echo "Invalid game selection: $game"
      echo "Valid options: sadx, sa2, both"
      exit 1
      ;;
  esac

  # Install common dependencies
  echo "Installing required tools..."
  if ! flatpak list | grep -q "com.github.Matoking.protontricks"; then
    flatpak --system -y install com.github.Matoking.protontricks
  fi

  if ! flatpak list | grep -q "net.davidotek.pupgui2"; then
    flatpak --system -y install net.davidotek.pupgui2
  fi

  # Configure Steam directory access
  flatpak override --user --filesystem="${HOME}/.local/share/Steam" com.github.Matoking.protontricks

  echo -e "\n=== Steam Configuration Steps ==="
  echo "1. ProtonUp-Qt will now launch. Please install GE-Proton."
  flatpak run net.davidotek.pupgui2 &>/dev/null

  # Find Steam library paths
  library_config="${HOME}/.steam/steam/steamapps/libraryfolders.vdf"

  # Function to find game installation path and add Flatpak override
  find_game_dir() {
    local game_path="$1"
    local game_dir=""

    if [ -f "$library_config" ]; then
      while IFS= read -r line; do
        if [[ $line =~ \"path\"[[:space:]]*\"([^\"]+)\" ]]; then
          possible_path="${BASH_REMATCH[1]}/steamapps/common/$game_path"
          if [ -d "$possible_path" ]; then
            game_dir="$possible_path"
            # Add Flatpak override for the Steam library
            flatpak override --user --filesystem="${BASH_REMATCH[1]}" com.github.Matoking.protontricks
            break
          fi
        fi
      done < "$library_config"
    fi

    echo "$game_dir"
  }

  # SADX Setup
  if [ "$setup_sadx" = true ]; then
    echo -e "\n=== Sonic Adventure DX Configuration ==="
    echo "In Steam, configure Sonic Adventure DX:"
    echo "1. Right-click the game → Properties"
    echo "2. Add this to Launch Options:"
    echo "   WINEDLLOVERRIDES=\"d3d8=n,b\" %command%"
    echo "3. Enable 'Force the use of a specific Steam Play compatibility tool'"
    echo "4. Select the GE-Proton version you just installed"
    echo "5. Launch the game once and exit"
    echo -e "\nPress Enter once you've completed these steps..."
    read -p ""

    # Find SADX installation path
    SADX_DIR=$(find_game_dir "Sonic Adventure DX")
    [ -z "$SADX_DIR" ] && {
      echo "Error: Could not find SADX installation. Please launch the game first."
      setup_sadx=false
    }

    if [ "$setup_sadx" = true ]; then
      # Download and run mod installer
      installer="${SADX_DIR}/sadx_setup.exe"
      echo -e "\nDownloading mod installer..."
      curl --retry 3 -Lo "$installer" "https://dcmods.unreliable.network/owncloud/data/PiKeyAr/files/Setup/sadx_setup.exe"

      echo -e "\nInstalling .NET Desktop Runtime 8..."
      flatpak run com.github.Matoking.protontricks 71250 dotnetdesktop8 &>/dev/null

      # Convert path to Windows format
      WIN_PATH="Z:${SADX_DIR//\//\\}"

      echo -e "\n=== Mod Installation ==="
      echo "When the SADX Mod Installer launches, use this path as the Destination Folder:"
      echo "${WIN_PATH}"
      flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid 71250 "$installer" &>/dev/null

      echo -e "\n=== SADX Configuration Steps ==="
      echo "1. Launch SADX and select 'Configure'"
      echo "2. Navigate to: Mods → Game Config → Graphics"
      echo "3. Set your display and resolution settings"
      echo "4. Click 'Save & Play' to start the game"
      echo -e "\nSADX setup complete! Enjoy playing with mods!"
    fi
  fi

  # SA2 Setup
  if [ "$setup_sa2" = true ]; then
    echo -e "\n=== Sonic Adventure 2 Configuration ==="
    echo "In Steam, configure Sonic Adventure 2:"
    echo "1. Right-click the game → Properties"
    echo "2. Enable 'Force the use of a specific Steam Play compatibility tool'"
    echo "3. Select the GE-Proton version you just installed"
    echo "4. Launch the game once and exit"
    echo -e "\nPress Enter once you've completed these steps..."
    read -p ""

    # Find SA2 installation path
    SA2_DIR=$(find_game_dir "Sonic Adventure 2")
    [ -z "$SA2_DIR" ] && {
      echo "Error: Could not find SA2 installation. Please launch the game first."
      setup_sa2=false
    }

    if [ "$setup_sa2" = true ]; then
      # Create temp directory for downloads
      TEMP_DIR=$(mktemp -d)
      trap 'rm -rf "$TEMP_DIR"' EXIT

      # Download SA Mod Manager
      echo -e "\nDownloading SA Mod Manager..."
      MOD_MANAGER_ZIP="$TEMP_DIR/SAModManager.zip"
      MOD_MANAGER_DIR="$TEMP_DIR/SAModManager"
      mkdir -p "$MOD_MANAGER_DIR"

      # Get the latest release URL
      LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/X-Hax/SA-Mod-Manager/releases/latest |
                          grep "browser_download_url.*release_x64.zip" |
                          cut -d '"' -f 4)

      curl --retry 3 -Lo "$MOD_MANAGER_ZIP" "$LATEST_RELEASE_URL"

      # Extract the mod manager
      unzip -q "$MOD_MANAGER_ZIP" -d "$MOD_MANAGER_DIR"

      # Copy mod manager to game directory
      echo "Installing SA Mod Manager to game directory..."
      cp "$MOD_MANAGER_DIR"/SAModManager.exe "$SA2_DIR"
      mv "$SA2_DIR"/Launcher.exe "$SA2_DIR"/Launcher.exe.bak
      cp "$MOD_MANAGER_DIR"/SAModManager.exe "$SA2_DIR"/Launcher.exe

      # Install .NET Desktop Runtime 8 for the mod manager
      echo -e "\nInstalling .NET Desktop Runtime 8..."
      flatpak run com.github.Matoking.protontricks 213610 dotnetdesktop8 &>/dev/null

      # Create mods directory if it doesn't exist
      MODS_DIR="${SA2_DIR}/mods"
      mkdir -p "$MODS_DIR"

      # Define mods to install with their GameBanana IDs and names
      echo -e "\nDownloading and installing recommended mods..."
      declare -A MODS=(
        ["SA2 Render Fix"]="452445"
        ["Cutscene Revamp"]="48872"
        ["Retranslated Story -COMPLETE-"]="437858"
        ["HD GUI: SA2 Edition"]="33171"
        ["IMPRESSive"]="469542"
        ["Stage Atmosphere Tweaks"]="407838"
        ["SA2 Volume Controls"]="381193"
        ["Mech Sound Improvement"]="412706"
        ["SA2 Input Controls"]="515637"
        ["Better Radar"]="313161"
        ["HedgePanel - Sonic + Shadow Tweaks"]="48950"
        ["Sonic: New Tricks"]="48941"
        ["Retranslated Hints"]="350607"
      )

      # Function to download and install a mod
      download_and_install_mod() {
        local mod_name="$1"
        local mod_id="$2"
        local mod_dir="${MODS_DIR}/${mod_name}"
        local temp_mod_dir="${TEMP_DIR}/${mod_name}"
        local download_page="https://gamebanana.com/mods/download/${mod_id}"

        echo "- Installing ${mod_name}..."
        mkdir -p "${temp_mod_dir}"
        mkdir -p "${mod_dir}"

        # Use wget with automatic cookie management to handle redirects and download the file
        echo "  Downloading from GameBanana..."

        # First, get the download page
        wget --timeout=30 --tries=3 -q --save-cookies="${temp_mod_dir}/cookies.txt" \
             --keep-session-cookies -O "${temp_mod_dir}/download_page.html" "${download_page}" || {
          echo "  Failed to access download page for ${mod_name}. Skipping."
          return
        }

        # Extract the actual download link - look for the main download button link
        download_link=$(grep -o 'href="https://gamebanana.com/dl/[^"]*' "${temp_mod_dir}/download_page.html" | head -1 | cut -d'"' -f2)

        if [ -z "$download_link" ]; then
          echo "  Failed to find download link for ${mod_name}. Skipping."
          return
        fi

        # Download the actual file
        echo "  Downloading mod file..."
        temp_mod_file="${temp_mod_dir}/mod_file"
        wget --timeout=30 --tries=3 -q --load-cookies="${temp_mod_dir}/cookies.txt" \
             --keep-session-cookies -O "${temp_mod_file}" "${download_link}" || {
          echo "  Failed to download ${mod_name}. Skipping."
          return
        }

        # Extract using 7z
        echo "  Extracting mod files..."
        7z x "${temp_mod_file}" -o"${mod_dir}" -y > /dev/null || {
          echo "  Failed to extract ${mod_name}. Skipping."
          return
        }

        echo "  ✓ ${mod_name} installed successfully."
      }

      # Install each mod
      for mod_name in "${!MODS[@]}"; do
        download_and_install_mod "${mod_name}" "${MODS[${mod_name}]}"
      done

      echo -e "\n=== SA2 Configuration Steps ==="
      echo "1. Launch SA2"
      echo "2. The SA Mod Manager should start automatically"
      echo "3. Enable the installed mods in the manager"
      echo "4. Configure SA2 Input Controls (set deadzone to 5%)"
      echo "5. Click 'Save and Play' to start the game with mods"
      echo -e "\nMod Installation Notes:"
      echo "- Place 'Stage Atmosphere Tweaks' at the bottom of your mod list"
      echo "- For Retranslated Story, set audio to Japanese in the game's menu"
      echo -e "\nSA2 setup complete! Enjoy playing with mods!"
    fi
  fi

# Clean up old packages and Docker/Podman images and volumes
amy-clean:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Cleaning up system..."
  docker image prune -af
  docker volume prune -f
  podman image prune -af
  podman volume prune -f
  flatpak uninstall --unused
  rpm-ostree cleanup -bm
  nix-collect-garbage -d
  sudo docker image prune -af
  sudo docker volume prune -f
  sudo podman image prune -af
  sudo podman volume prune -f
  sudo -i nix-collect-garbage -d
