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

    echo "Fetching releases for $repo..." >&2
    response=$(curl -sL "https://api.github.com/repos/$repo/releases" | jq -r '.[0]')
    if [ "$response" = "null" ]; then
      echo "No releases found for $repo" >&2
      return 1
    fi

    # Convert glob pattern to regex pattern
    pattern="$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/g')"
    echo "Looking for assets matching pattern: $pattern" >&2

    # Get all assets and find matching one
    latest_url=$(echo "$response" | jq -r '.assets[].browser_download_url' | grep -E "$pattern" | head -n1)
    if [ -z "$latest_url" ]; then
      echo "No matching asset found for $name" >&2
      echo "Available assets:" >&2
      echo "$response" | jq -r '.assets[].browser_download_url' >&2
      return 1
    fi

    version=$(echo "$response" | jq -r .tag_name)
    echo "Found version $version: $latest_url" >&2
    echo "$latest_url"
  }

  install_appimage() {
    local name="$1" url="$2"
    local appimage="$APPIMAGE_DOWNLOAD_PATH/${name}.appimage"

    echo "Downloading ${name}.appimage from $url..."
    if ! wget -q "$url" -O "$appimage"; then
      echo "Failed to download from $url"
      return 1
    fi

    chmod +x "$appimage"
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
      echo "GitHub release detected for $name"
      url=$(process_github_release "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$name") || {
        echo "Failed to process GitHub release for $name"
        continue
      }
    fi

    install_appimage "$name" "$url" || {
      echo "Failed to install $name"
      continue
    }
  done < <(curl -s https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)
  echo "AppImages installation complete."
