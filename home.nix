{ config, unstable, pkgs, inputs, myUserName, ... }:

{
  #  Basic user Information
  home.username = "${myUserName}";
  home.homeDirectory = "/home/${myUserName}";

  imports = [];

  home.stateVersion = "24.11"; 

  # --- Packages ---
  home.packages = [
    # Browser from inputs
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    
    # Unstable channel
    unstable.jetbrains.phpstorm
    unstable.antigravity
    
    # System and work utilities
    pkgs.keepassxc
    pkgs.yazi
    pkgs.vscode
    pkgs.telegram-desktop
    pkgs.nautilus
    pkgs.obsidian
    pkgs.todoist-electron
    
    # GNOME Extensions
    pkgs.gnomeExtensions.pop-shell
    pkgs.gnomeExtensions.vertical-workspaces
    
    # Development and terminal
    pkgs.zellij
    pkgs.postman
    pkgs.dbeaver-bin
    pkgs.mariadb # dump
    pkgs.codex
    pkgs.nodejs_22
    pkgs.gcc
    pkgs.gnumake
    
    # Neovim and CLI dependencies
    pkgs.ripgrep
    pkgs.fd
    pkgs.wl-clipboard
    
    pkgs.gnumeric # xlsx viewer GUI
    pkgs.throne   # VPN UI
  ];

  # --- GNOME and GTK Settings ---
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "pop-shell@system76.com"
        "vertical-workspaces@G-dH.github.com"
      ];
    };
    "org/gnome/shell/extensions/pop-shell" = {};
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.pop-gtk-theme;
      name = "Pop-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 18;
  };

  # --- Files and environment variables ---
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/nvim";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # --- Programs ---
  programs = {
    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
        pane_frames = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true; 

      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        ossync = "sudo nixos-rebuild switch --flake /home/${myUserName}/.dotfiles#my-pc";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "docker-compose"
          "z"
          "extract"
          "fzf"
          "eza"
        ];
        theme = "fino-time";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = { x = 15; y = 15; };
          decorations = "full";
          opacity = 0.95;
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          size = 12.0;
        };
        colors = {
          primary = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };
          normal = {
            black = "#45475a";
            red = "#f38ba8";
            green = "#a6e3a1";
            yellow = "#f9e2af";
            blue = "#89b4fa";
            magenta = "#f5c2e7";
            cyan = "#94e2d5";
            white = "#bac2de";
          };
        };
      };
    };
  };
}
