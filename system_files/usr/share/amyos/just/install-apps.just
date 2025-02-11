# Install Amy OS Flatpaks
install-amy-flatpaks:
    #!/bin/bash
    echo "Installing Flatpaks..."
    ujust _install-system-flatpaks
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks | tr '\n' ' ')"
    flatpak --system -y install $FLATPAK_LIST
    echo "Flatpaks installation complete."

# Install Amy OS Homebrews
install-amy-brews:
    #!/bin/bash
    echo "Installing Homebrews..."
    BREW_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews | tr '\n' ' ')"
    brew install $BREW_LIST
    echo "Homebrews installation complete."

# Install Amy OS AppImages
install-amy-appimages:
    #!/bin/bash
    echo "Installing AppImages..."
    if ! flatpak list | grep -q "it.mijorus.gearlever"; then
        flatpak --system -y install it.mijorus.gearlever
    fi
    APPIMAGE_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/appimages)"
    echo "$APPIMAGE_LIST" | while IFS=',' read -r name url; do
        if [ -n "$name" ] && [ -n "$url" ]; then
            APPIMAGE_NAME="${name}.appimage"
            if [ -n "$XDG_DOWNLOAD_DIR" ]; then
                APPIMAGE_DOWNLOAD_PATH="$XDG_DOWNLOAD_DIR/$APPIMAGE_NAME"
            elif [ -d "$HOME/Downloads" ]; then
                APPIMAGE_DOWNLOAD_PATH="$HOME/Downloads/$APPIMAGE_NAME"
            else
                APPIMAGE_DOWNLOAD_PATH="$HOME/$APPIMAGE_NAME"
            fi
            echo "Checking $APPIMAGE_NAME..."
            if ! flatpak run it.mijorus.gearlever --list-installed | grep -qi "$APPIMAGE_NAME"; then
                echo "Downloading $APPIMAGE_NAME..."
                wget "$url" -O "$APPIMAGE_DOWNLOAD_PATH" || {
                    echo "Failed to download $APPIMAGE_NAME"
                    continue
                }
                echo "Integrating $APPIMAGE_NAME with Gear Lever..."
                flatpak run it.mijorus.gearlever --integrate "$APPIMAGE_DOWNLOAD_PATH" -y || {
                    echo "Failed to integrate $APPIMAGE_NAME"
                    rm -f "$APPIMAGE_DOWNLOAD_PATH"
                    continue
                }
                rm -f "$APPIMAGE_DOWNLOAD_PATH"
                echo "$APPIMAGE_NAME installed successfully"
            else
                echo "$APPIMAGE_NAME is already installed"
            fi
        fi
    done
    echo "AppImages installation complete."

# Install all Amy OS apps
install-amy: install-amy-flatpaks install-amy-brews install-amy-appimages
