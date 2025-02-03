# Install Amy OS Flatpaks
install-amy-flatpaks:
    #!/usr/bin/bash
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Install Amy OS Brews
install-amy-brews:
    #!/usr/bin/bash
    BREW_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews | tr '\n' ' ')"
    brew install ${BREW_LIST}

# Install Amy OS Flatpaks and Brews
install-amy: install-amy-flatpaks install-amy-brews
