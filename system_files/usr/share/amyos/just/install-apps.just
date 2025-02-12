# Install all Amy OS apps
install-amy: install-amy-flatpaks install-amy-brews install-amy-appimages

# Install Amy OS Flatpaks
install-amy-flatpaks:
  #!/usr/bin/env bash
  echo "Installing Flatpaks..."
  ujust _install-system-flatpaks
  flatpak --system -y install $(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks)
  echo "Flatpaks installation complete."

# Install Amy OS Homebrews
install-amy-brews:
  #!/usr/bin/env bash
  echo "Installing Homebrews..."
  brew install $(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews)
  echo "Homebrews installation complete."

# Install Amy OS AppImages
install-amy-appimages:
  #!/usr/bin/env bash
  # Ensure Gear Lever is installed
  if ! flatpak list | grep -q "it.mijorus.gearlever"; then
    echo "Installing Gear Lever..."
    flatpak --system -y install it.mijorus.gearlever
  fi

  # Set download path
  APPIMAGE_DOWNLOAD_PATH="${XDG_DOWNLOAD_DIR:-${HOME}/Downloads}"
  [ ! -d "$APPIMAGE_DOWNLOAD_PATH" ] && APPIMAGE_DOWNLOAD_PATH="$HOME"
  echo "Download path: $APPIMAGE_DOWNLOAD_PATH"

  # Process each AppImage
  process_github_release() {
    local repo="$1" pattern="$2" name="$3"
    local response latest_url version

    # Get latest release and matching asset
    response=$(curl -s "https://api.github.com/repos/$repo/releases" | jq -r '.[0]')
    pattern="$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/g')"
    latest_url=$(jq -r '.assets[].browser_download_url' <<<"$response" | grep -E "$pattern" | head -n1)

    # Return if no matching asset found
    [ -z "$latest_url" ] && { echo "No matching asset found for $name"; return 1; }

    # Show version and URL
    version=$(jq -r .tag_name <<<"$response")
    echo "Found version $version: $latest_url"
    echo "$latest_url"
  }

  install_appimage() {
    local name="$1" url="$2"
    local appimage="$APPIMAGE_DOWNLOAD_PATH/${name}.appimage"

    echo "Downloading ${name}.appimage..."
    wget -q "$url" -O "$appimage" || { echo "Failed to download"; return 1; }

    echo "Integrating with Gear Lever..."
    if flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
      echo "${name}.appimage installed successfully"
    else
      echo "Failed to integrate ${name}.appimage"
      rm -f "$appimage"
      return 1
    fi
    rm -f "$appimage"
  }

  # Main loop
  while IFS=, read -r name url; do
    [ -z "$name" ] || [ -z "$url" ] && continue
    echo "Processing $name..."

    # Skip if already installed
    if flatpak run it.mijorus.gearlever --list-installed | grep -qi "${name}.appimage"; then
      echo "${name}.appimage is already installed"
      continue
    fi

    # Handle GitHub releases with wildcards
    if [[ "$url" =~ github.com/([^/]+/[^/]+)/releases/download/[^/]*/([^/]*) ]] && [[ "$url" == *"*"* ]]; then
      url=$(process_github_release "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$name") || continue
    fi

    install_appimage "$name" "$url" || continue
  done < <(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)
  echo "AppImages installation complete."
