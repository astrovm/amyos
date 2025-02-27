{ config, pkgs, ... }:

{
  home = {
    username = "astro";
    homeDirectory = "/home/astro";
    stateVersion = "24.11";
    packages = with pkgs; [
      cmatrix
      croc
      devenv
      gh
      glab
      john
      magic-wormhole-rs
      nixfmt-rfc-style
      shellcheck
      shfmt
    ];
    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
      EDITOR = "/usr/bin/nvim";
    };
  };

  xdg.configFile = {
    "ghostty/config".text = ''
      background-opacity = "0.9"
      command = "${pkgs.zsh}/bin/zsh"
      font-family = "Hack Nerd Font"
      font-size = "13"
      theme = "Dark Pastel"
      window-height = "32"
      window-width = "100"
    '';
  };

  programs = {
    git = {
      enable = true;
      userName = "astrovm";
      userEmail = "~@4st.li";
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
        bindkey '^[[H'  beginning-of-line                               # Home key (xterm)
        bindkey '^[[OH' beginning-of-line                               # Home key (smkx mode)
        bindkey '^[[1~' beginning-of-line                               # Home key (screen & tmux)
        bindkey '^[[7~' beginning-of-line                               # Home key (urxvt)
        bindkey '^[[F'  end-of-line                                     # End key (xterm)
        bindkey '^[[OF' end-of-line                                     # End key (smkx mode)
        bindkey '^[[4~' end-of-line                                     # End key (screen & tmux)
        bindkey '^[[8~' end-of-line                                     # End key (urxvt)
        bindkey '^[[2~' overwrite-mode                                  # Insert key
        bindkey '^[[3~' delete-char                                     # Delete key
        bindkey '^[[C'  forward-char                                    # Right key
        bindkey '^[[D'  backward-char                                   # Left key
        bindkey '^[[5~' history-beginning-search-backward               # Page up key
        bindkey '^[[6~' history-beginning-search-forward                # Page down key
        bindkey '^[[A'  up-line-or-history                              # Up key
        bindkey '^[[B'  down-line-or-history                            # Down key
        # Navigate words with ctrl+arrow keys
        bindkey '^[Oc' forward-word                                     #
        bindkey '^[Od' backward-word                                    #
        bindkey '^[[1;5D' backward-word                                 #
        bindkey '^[[1;5C' forward-word                                  #
        bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
        bindkey '^[[Z' undo                                             # Shift+tab undo last action
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
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

    home-manager.enable = true;
  };

  targets.genericLinux.enable = true;
}
