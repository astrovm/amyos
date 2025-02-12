# Install all Amy OS apps
install-amy: install-amy-flatpaks install-amy-brews install-amy-appimages

# Install Amy OS Flatpaks
install-amy-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Flatpaks..."
  ujust _install-system-flatpaks
  flatpak --system -y install $(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks)
  echo "Flatpaks installation complete."

# Install Amy OS Homebrews
install-amy-brews:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Homebrews..."
  brew install $(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews)
  echo "Homebrews installation complete."

# Install Amy OS AppImages
install-amy-appimages:
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
      url=$(curl -sL "https://api.github.com/repos/${BASH_REMATCH[1]}/releases" | jq -r ".[0].assets[].browser_download_url" | grep -E "$pattern" | head -n1)
      [ -z "$url" ] && { echo "No release found for $name"; continue; }
    fi

    # Download and install
    appimage="$DOWNLOAD_DIR/${name}.appimage"
    if wget "$url" -O "$appimage" && chmod +x "$appimage" && flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
      echo "$name installed successfully"
    else
      echo "Failed to install $name"
    fi
    rm -f "$appimage"
  done < <(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)
  echo "AppImages installation complete."

# Setup Cursor and VSCode settings
setup-editor-config:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Setting up Cursor configuration..."
  CURSOR_CONFIG_DIR="${HOME}/.config/Cursor/User"
  mkdir -p "$CURSOR_CONFIG_DIR"
  rm -f "$CURSOR_CONFIG_DIR/settings.json"
  curl https://raw.githubusercontent.com/astrovm/amyos/main/user_files/.config/Cursor/User/settings.json -o "$CURSOR_CONFIG_DIR/settings.json"
  echo "Cursor configuration complete."

  echo "Setting up VSCode configuration..."
  VSCODE_CONFIG_DIR="${HOME}/.config/Code/User"
  mkdir -p "$VSCODE_CONFIG_DIR"
  rm -f "$VSCODE_CONFIG_DIR/settings.json"
  curl https://raw.githubusercontent.com/astrovm/amyos/main/user_files/.config/Code/User/settings.json -o "$VSCODE_CONFIG_DIR/settings.json"
  echo "VSCode configuration complete."
