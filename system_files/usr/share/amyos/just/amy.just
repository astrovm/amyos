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

# Setup Git and GitHub SSH configuration
amy-setup-git:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Setting up Git configuration..."

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
