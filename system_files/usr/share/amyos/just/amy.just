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
    if aria2c --dir="$(dirname "$appimage")" --out="$(basename "$appimage")" --max-tries=3 --connect-timeout=30 "$url" && chmod +x "$appimage" && flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
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
  nix run home-manager/master -- init --switch "$HM_CONFIG_DIR"
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

# Setup Sonic Adventure mods (SADX and SA2)
amy-setup-samods:
  #!/usr/bin/env bash
  set -euo pipefail

  # Variables and paths
  TEMP_DIR=$(mktemp -d)
  STEAM_CONFIG="${HOME}/.steam/steam/steamapps/libraryfolders.vdf"
  SADX_APPID="71250"
  SA2_APPID="213610"

  # Cleanup function
  trap 'rm -rf "$TEMP_DIR"' EXIT

  # Install required tools
  install_dependencies() {
    echo "Installing required tools..."
    flatpak list | grep -q "com.github.Matoking.protontricks" ||
      flatpak --system -y install com.github.Matoking.protontricks
    flatpak list | grep -q "net.davidotek.pupgui2" ||
      flatpak --system -y install net.davidotek.pupgui2
    flatpak override --user --filesystem="${HOME}/.local/share/Steam" com.github.Matoking.protontricks
  }

  # Find game installation path
  find_game_dir() {
    local game_path="$1"

    if [ -f "$STEAM_CONFIG" ]; then
      while IFS= read -r line; do
        if [[ $line =~ \"path\"[[:space:]]*\"([^\"]+)\" ]]; then
          possible_path="${BASH_REMATCH[1]}/steamapps/common/$game_path"
          if [ -d "$possible_path" ]; then
            flatpak override --user --filesystem="${BASH_REMATCH[1]}" com.github.Matoking.protontricks
            echo "$possible_path"
            return 0
          fi
        fi
      done < "$STEAM_CONFIG"
    fi
    echo ""
  }

  # Handle game setup
  setup_game() {
    local game_type="$1"
    local game_name="Sonic Adventure ${game_type^^}"
    local game_path="Sonic Adventure ${game_type^^}"
    local appid="SA${game_type^^}_APPID"

    echo -e "\n===== $game_name Setup ====="

    # Find game installation
    echo "Looking for $game_name installation..."
    GAME_DIR=$(find_game_dir "$game_path")

    if [ -z "$GAME_DIR" ]; then
      echo "⚠️ Could not find $game_name installation."
      echo "Skipping $game_name setup."
      return 1
    fi

    echo "✓ Found $game_name at: $GAME_DIR"

    # Steam configuration steps
    echo -e "\n[Steam Configuration]"
    if [ "$game_type" = "dx" ]; then
      echo "1. Right-click $game_name in Steam → Properties"
      echo "2. Add to Launch Options: WINEDLLOVERRIDES=\"d3d8=n,b\" %command%"
      echo "3. Enable 'Force the use of a specific Steam Play compatibility tool'"
      echo "4. Select GE-Proton (install it first via ProtonUp-Qt if needed)"
      echo "5. Launch the game once and exit"
    else  # SA2
      echo "1. Right-click $game_name in Steam → Properties"
      echo "2. Enable 'Force the use of a specific Steam Play compatibility tool'"
      echo "3. Select GE-Proton (install it first via ProtonUp-Qt if needed)"
      echo "4. Launch the game once and exit"
    fi

    # Offer to launch ProtonUp-Qt
    echo -e "\nDo you want to launch ProtonUp-Qt to install GE-Proton? (y/n)"
    read -r launch_protonup
    if [[ "$launch_protonup" =~ ^[Yy]$ ]]; then
      flatpak run net.davidotek.pupgui2 &>/dev/null
    fi

    echo -e "\nHave you completed the Steam configuration steps? (y/n)"
    read -r config_done
    if [[ ! "$config_done" =~ ^[Yy]$ ]]; then
      echo "You can run this command again later to continue setup."
      return 1
    fi

    # Install .NET Runtime
    echo "Installing .NET Desktop Runtime 8..."
    flatpak run com.github.Matoking.protontricks ${!appid} --unattended dotnetdesktop8 &>/dev/null
    echo "✓ .NET Runtime installed"

    # Game-specific setup
    if [ "$game_type" = "dx" ]; then
      setup_sadx "$GAME_DIR"
    else
      setup_sa2 "$GAME_DIR"
    fi

    return 0
  }

  # SADX-specific setup
  setup_sadx() {
    local SADX_DIR="$1"

    # Download mod installer
    echo -e "\nDownloading SADX mod installer..."
    local installer="${SADX_DIR}/sadx_setup.exe"
    if ! aria2c --dir="$(dirname "$installer")" --out="$(basename "$installer")" --max-tries=3 --connect-timeout=30 "https://dcmods.unreliable.network/owncloud/data/PiKeyAr/files/Setup/sadx_setup.exe"; then
      echo "❌ Failed to download mod installer. Check your internet connection."
      return 1
    fi
    echo "✓ Downloaded mod installer"

    # Convert path to Windows format
    local WIN_PATH="Z:${SADX_DIR//\//\\}"

    echo -e "\n[Mod Installation]"
    echo "When the SADX Mod Installer launches:"
    echo "1. Use this path as the Destination Folder: ${WIN_PATH}"
    echo "2. Select the mods you want to install"

    flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid $SADX_APPID "$installer" &>/dev/null

    echo -e "\n[Final Configuration]"
    echo "1. Launch SADX and select 'Configure'"
    echo "2. Navigate to: Mods → Game Config → Graphics"
    echo "3. Set your display and resolution settings"

    echo -e "\n✅ SADX setup complete! Enjoy playing with mods!"
  }

  # SA2-specific setup
  setup_sa2() {
    local SA2_DIR="$1"

    # Create mods directory
    local MODS_DIR="${SA2_DIR}/mods"
    mkdir -p "$MODS_DIR"

    # Download SA Mod Manager
    echo -e "\nDownloading SA Mod Manager..."
    local MOD_MANAGER_DIR="$TEMP_DIR/SAModManager"
    mkdir -p "$MOD_MANAGER_DIR"

    local MOD_MANAGER_ZIP="$TEMP_DIR/SAModManager.zip"
    if ! aria2c --dir="$(dirname "$MOD_MANAGER_ZIP")" --out="$(basename "$MOD_MANAGER_ZIP")" --max-tries=3 --connect-timeout=30 "https://github.com/X-Hax/SA-Mod-Manager/releases/latest/download/release_x64.zip"; then
      echo "❌ Failed to download SA Mod Manager. Check your internet connection."
      return 1
    fi

    # Extract and install mod manager
    echo "Installing SA Mod Manager..."
    if ! 7z x "$MOD_MANAGER_ZIP" -o"$MOD_MANAGER_DIR" -y &>/dev/null ||
       ! cp "$MOD_MANAGER_DIR"/SAModManager.exe "$SA2_DIR"; then
      echo "❌ Failed to install SA Mod Manager."
      return 1
    fi

    # Backup original launcher and replace with mod manager
    if [ -f "$SA2_DIR"/Launcher.exe ] && [ ! -f "$SA2_DIR"/Launcher.exe.bak ]; then
      mv "$SA2_DIR"/Launcher.exe "$SA2_DIR"/Launcher.exe.bak
    fi
    mv "$SA2_DIR"/SAModManager.exe "$SA2_DIR"/Launcher.exe
    echo "✓ SA Mod Manager installed"

    # Ask if user wants to install recommended mods
    echo -e "\nWould you like to install recommended mods? (y/n)"
    read -r install_mods
    if [[ "$install_mods" =~ ^[Yy]$ ]]; then
      install_sa2_mods "$MODS_DIR"
    else
      echo "Skipping mod installation."
    fi

    echo -e "\n[Final Configuration]"
    echo "1. Launch SA2 (the SA Mod Manager will start automatically)"
    echo "2. Enable the installed mods in the manager"
    echo "3. For SA2 Input Controls, set deadzone to 5%"
    echo "4. For Retranslated Story, set audio to Japanese in the game's menu"
    echo "5. Place 'Stage Atmosphere Tweaks' at the bottom of your mod list"

    echo -e "\n✅ SA2 setup complete! Enjoy playing with mods!"
  }

  # Install recommended SA2 mods
  install_sa2_mods() {
    local MODS_DIR="$1"

    # Define mods to install with their GameBanana file IDs
    declare -A MODS=(
      ["SA2 Render Fix"]="1388911"
      ["Cutscene Revamp"]="440737"
      ["Retranslated Story -COMPLETE-"]="1388469"
      ["HD GUI: SA2 Edition"]="409120"
      ["IMPRESSive"]="1213103"
      ["Stage Atmosphere Tweaks"]="884395"
      ["SA2 Volume Controls"]="835829"
      ["Mech Sound Improvement"]="893090"
      ["SA2 Input Controls"]="1255952"
      ["Better Radar"]="860716"
      ["HedgePanel - Sonic + Shadow Tweaks"]="454296"
      ["Sonic: New Tricks"]="915082"
      ["Retranslated Hints"]="1388468"
    )

    echo -e "\nDownloading and installing recommended mods..."
    echo "This may take a while, depending on your internet connection."

    # Check 7z RAR support
    local seven_z_rar_support=false
    if 7z i | grep -q "rar"; then
      seven_z_rar_support=true
    fi

    local success_count=0
    local failed_mods=""

    for mod_name in "${!MODS[@]}"; do
      echo "- Installing ${mod_name}..."
      local mod_id="${MODS[${mod_name}]}"
      local temp_mod_dir="${TEMP_DIR}/${mod_name// /_}"
      local download_url="https://gamebanana.com/mmdl/${mod_id}"

      mkdir -p "${temp_mod_dir}"

      # Download the mod directly to the temp directory
      if ! aria2c --dir="${temp_mod_dir}" --allow-overwrite=true --max-tries=3 --connect-timeout=30 "${download_url}"; then
        echo "  ⚠️ Failed to download ${mod_name}. Skipping."
        failed_mods+="${mod_name}, "
        continue
      fi

      # Find the downloaded file
      local downloaded_file=$(ls -1 "${temp_mod_dir}" | head -n 1)
      if [ -z "$downloaded_file" ]; then
        echo "  ⚠️ Failed to locate downloaded file for ${mod_name}. Skipping."
        failed_mods+="${mod_name}, "
        continue
      fi

      # Full path to downloaded file
      local full_path="${temp_mod_dir}/${downloaded_file}"
      echo "  Downloaded as: ${downloaded_file}"

      # Extract file based on extension and 7z RAR support
      local extract_success=false
      if [[ "$downloaded_file" == *.rar ]] && ! $seven_z_rar_support; then
        # Use unrar for RAR files when 7z doesn't support RAR
        unrar x -y "${full_path}" "${MODS_DIR}" >/dev/null 2>&1 && extract_success=true
      else
        7z x "${full_path}" -o"${MODS_DIR}" -y >/dev/null 2>&1 && extract_success=true
      fi

      if $extract_success; then
        echo "  ✓ ${mod_name} installed successfully."
        success_count=$((success_count + 1))
      else
        echo "  ⚠️ Failed to extract ${downloaded_file}. Skipping."
        failed_mods+="${mod_name}, "
      fi
    done

    echo -e "\n✓ Successfully installed ${success_count} mods out of ${#MODS[@]}."

    if [ -n "$failed_mods" ]; then
      echo "⚠️ Failed to install: ${failed_mods%, }"
      echo "You can manually download these mods from GameBanana."
    fi

    # Always return success
    return 0
  }

  # Display game selection menu
  echo "===== Sonic Adventure Mod Setup ====="
  echo "Select which game(s) to set up:"
  echo "1. Sonic Adventure DX only"
  echo "2. Sonic Adventure 2 only"
  echo "3. Both games"

  # Get user selection
  select_game() {
    local valid=false
    local choice

    until $valid; do
      read -p "Enter your choice (1-3): " choice
      case "$choice" in
        1) echo "sadx"; valid=true ;;
        2) echo "sa2"; valid=true ;;
        3) echo "both"; valid=true ;;
        *) echo "Invalid choice. Please enter 1, 2, or 3." >&2 ;;
      esac
    done
  }

  game=$(select_game)

  # Install dependencies
  install_dependencies

  # Process game selection
  case "$game" in
    "sadx")
      setup_game "dx"
      ;;
    "sa2")
      setup_game "2"
      ;;
    "both")
      setup_game "dx"
      setup_game "2"
      ;;
  esac

  echo -e "\n===== Setup Complete ====="

# Clean up old packages and Docker/Podman images and volumes
amy-clean:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Cleaning up system..."
  docker system prune -af
  podman system prune -af
  flatpak uninstall --unused
  rpm-ostree cleanup -bm
  nix-collect-garbage -d
  sudo docker system prune -af
  sudo podman system prune -af
  sudo -i nix-collect-garbage -d
