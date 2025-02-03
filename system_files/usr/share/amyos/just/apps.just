install-amy-flatpaks:
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

install-amy-brews:
    BREW_LIST="$(curl https://raw.githubusercontent.com/astrovm/amyos/main/repo_files/brews | tr '\n' ' ')"
    brew install ${BREW_LIST}

install-amy: install-amy-flatpaks install-amy-brews
