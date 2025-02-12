# Install all Amy OS apps
install-amy: install-amy-flatpaks install-amy-brews install-amy-appimages

# Install Amy OS Flatpaks
install-amy-flatpaks:
  #!/usr/bin/env bash
  echo "Installing Flatpaks..."
  ujust _install-system-flatpaks
  FLATPAK_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks | tr '\n' ' ')"
  flatpak --system -y install $FLATPAK_LIST
  echo "Flatpaks installation complete."

# Install Amy OS Homebrews
install-amy-brews:
  #!/usr/bin/env bash
  echo "Installing Homebrews..."
  BREW_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews | tr '\n' ' ')"
  brew install $BREW_LIST
  echo "Homebrews installation complete."

# Install Amy OS AppImages
install-amy-appimages:
  #!/usr/bin/env bash
  if ! flatpak list | grep -q "it.mijorus.gearlever"; then
    echo "Gear Lever not installed, installing..."
    flatpak --system -y install it.mijorus.gearlever
  fi

  echo "Installing AppImages..."
  if [ -n "$XDG_DOWNLOAD_DIR" ]; then
    APPIMAGE_DOWNLOAD_PATH="$XDG_DOWNLOAD_DIR"
  elif [ -d "$HOME/Downloads" ]; then
    APPIMAGE_DOWNLOAD_PATH="$HOME/Downloads"
  else
    APPIMAGE_DOWNLOAD_PATH="$HOME"
  fi
  echo "Download path: $APPIMAGE_DOWNLOAD_PATH"

  APPIMAGE_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)"
  echo "$APPIMAGE_LIST" | while IFS=',' read -r name url; do
    if [ -n "$name" ] && [ -n "$url" ]; then
      APPIMAGE_NAME="${name}.appimage"
      echo "Checking $APPIMAGE_NAME..."
      if ! flatpak run it.mijorus.gearlever --list-installed | grep -qi "$APPIMAGE_NAME"; then
        echo "Downloading $APPIMAGE_NAME..."
        # Handle GitHub URLs with wildcards to find the latest release
        if [[ "$url" =~ github.com/([^/]+/[^/]+)/releases/download/[^/]*/[^/]* ]] && [[ "$url" == *"*"* ]]; then
          repo="${BASH_REMATCH[1]}"
          response=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
          latest_url=$(echo "$response" | grep -o '"browser_download_url": ".*AppImage"' | head -n1 | cut -d'"' -f4)
          if [ -n "$latest_url" ]; then
            echo "Found latest release: $latest_url"
            url="$latest_url"
          else
            echo "Failed to get latest release URL for $name"
            continue
          fi
        fi

        wget "$url" -O "$APPIMAGE_DOWNLOAD_PATH/$APPIMAGE_NAME" || {
          echo "Failed to download $APPIMAGE_NAME"
          continue
        }

        echo "Integrating $APPIMAGE_NAME with Gear Lever..."
        flatpak run it.mijorus.gearlever --integrate "$APPIMAGE_DOWNLOAD_PATH/$APPIMAGE_NAME" -y || {
          echo "Failed to integrate $APPIMAGE_NAME"
          rm -f "$APPIMAGE_DOWNLOAD_PATH/$APPIMAGE_NAME"
          continue
        }
        rm -f "$APPIMAGE_DOWNLOAD_PATH/$APPIMAGE_NAME"
        echo "$APPIMAGE_NAME installed successfully"
      else
        echo "$APPIMAGE_NAME is already installed"
      fi
    fi
  done
  echo "AppImages installation complete."
