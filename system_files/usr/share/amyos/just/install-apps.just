# Install Amy OS Flatpaks
install-amy-flatpaks:
    #!/bin/bash
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Install Amy OS Homebrews
install-amy-brews:
    #!/bin/bash
    BREW_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews | tr '\n' ' ')"
    brew install ${BREW_LIST}

# Install Amy OS AppImages
install-amy-appimages:
    #!/bin/bash
    mkdir -p $HOME/Applications
    if [ ! -f "$HOME/Applications/cursor.appimage" ]; then
        wget https://downloader.cursor.sh/linux/appImage/x64 -O $HOME/Applications/cursor.appimage
    fi
    chmod +x $HOME/Applications/cursor.appimage
    flatpak run it.mijorus.gearlever --integrate $HOME/Applications/cursor.appimage
    nohup cursor-cli version use stable --install-dir $HOME/Applications/cursor.appimage >/dev/null 2>&1 &

# Install all Amy OS apps
install-amy: install-amy-flatpaks install-amy-brews install-amy-appimages
