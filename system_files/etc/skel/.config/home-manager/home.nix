{
  config,
  pkgs,
  user,
  ...
}:

{
  home = {
    username = user.userName;
    homeDirectory = user.homeDirectory;
    stateVersion = "25.05";
    packages = with pkgs; [
      asciinema
      audacious
      audacious-plugins
      bat
      bun
      cargo
      cmatrix
      croc
      devenv
      fd
      gh
      glab
      hashcat
      hashcat-utils
      john
      magic-wormhole-rs
      nerd-fonts.hack
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nixfmt-rfc-style
      p7zip-rar
      rclone
      rclone-browser
      ripgrep
      rustc
      shellcheck
      shfmt
      tealdeer
      trash-cli
      trezor-suite
      ugrep
      vscode
      yq
    ];
    sessionVariables = {
      PATH = "$PATH:${user.homeDirectory}/.cargo/bin";
      SHELL = "${pkgs.zsh}/bin/zsh";
      TERMINAL = "${pkgs.ghostty}/bin/ghostty";
    };
  };

  programs = {
    git = {
      enable = true;
      userName = user.gitConfig.userName;
      userEmail = user.gitConfig.userEmail;
      extraConfig = {
        pull.rebase = true;
      };
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
      settings = {
        background-opacity = "0.9";
        command = "${pkgs.zsh}/bin/zsh";
        font-family = "Hack Nerd Font";
        font-size = "13";
        theme = "Dark Pastel";
        window-height = "32";
        window-width = "100";
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
      initExtra = ''
        ## Keybindings section
        bindkey -e
        bindkey '^[[H'  beginning-of-line                  # Home key (xterm)
        bindkey '^[[OH' beginning-of-line                  # Home key (smkx mode)
        bindkey '^[[1~' beginning-of-line                  # Home key (screen & tmux)
        bindkey '^[[7~' beginning-of-line                  # Home key (urxvt)
        bindkey '^[[F'  end-of-line                        # End key (xterm)
        bindkey '^[[OF' end-of-line                        # End key (smkx mode)
        bindkey '^[[4~' end-of-line                        # End key (screen & tmux)
        bindkey '^[[8~' end-of-line                        # End key (urxvt)
        bindkey '^[[2~' overwrite-mode                     # Insert key
        bindkey '^[[3~' delete-char                        # Delete key
        bindkey '^[[C'  forward-char                       # Right key
        bindkey '^[[D'  backward-char                      # Left key
        bindkey '^[[5~' history-beginning-search-backward  # Page up key
        bindkey '^[[6~' history-beginning-search-forward   # Page down key
        bindkey '^[[A'  up-line-or-history                 # Up key
        bindkey '^[[B'  down-line-or-history               # Down key
        # Navigate words with Ctrl+Arrow keys
        bindkey '^[Oc' forward-word                        #
        bindkey '^[Od' backward-word                       #
        bindkey '^[[1;5D' backward-word                    #
        bindkey '^[[1;5C' forward-word                     #
        bindkey '^H' backward-kill-word                    # Delete previous word with Ctrl+Backspace
        bindkey '^[[Z' undo                                # Shift+Tab undo last action

        # Homebrew setup
        [[ -d /home/linuxbrew/.linuxbrew && $- == *i* ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      '';
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    home-manager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  targets.genericLinux.enable = true;
}
