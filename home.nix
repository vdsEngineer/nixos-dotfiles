{ config, unstable, pkgs, inputs, myUserName, noctalia, ... }:

{
  #  Basic user Information
  home.username = "${myUserName}";
  home.homeDirectory = "/home/${myUserName}";

  imports = [];

  home.stateVersion = "24.11"; 

  # --- Packages ---
  home.packages = [
    # Noctalia
    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

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

  # --- GTK PointerCursor ---
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
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  
  xdg.desktopEntries.phpstorm = {
    name = "PhpStorm";
    genericName = "PHP IDE";
    exec = "phpstorm -Dawt.toolkit.name=WLToolkit %f";
    icon = "phpstorm";
    terminal = false;
    categories = [ "Development" "IDE" ];
    type = "Application";
  };

  xdg.configFile."niri/config.kdl".text = ''
      // --- AUTO-START ---
      spawn-at-startup "noctalia-shell"

      prefer-no-csd
      hotkey-overlay {
          skip-at-startup
      }

      input {
          keyboard {
              xkb {
                  layout "us,ru"
                  options "grp:alt_shift_toggle"
              }
          }
          touchpad {
              tap
              natural-scroll
          }
      }

      layout {
          gaps 14 

          border {
              off
          }

          focus-ring {
              width 2 
              active-color "#89b4fa" 
              inactive-color "#45475a"
          }

          struts {
              left 0
              right 0
              top 0
              bottom 0
          }
      }
      
      // Animations Niri 
      animations {
          window-open {
              duration-ms 200
              curve "ease-out-expo"
          }
      }

      window-rule {
          geometry-corner-radius 12 // Rounding the corners of windows
          clip-to-geometry true     // Crop the content at rounded corners
      }

      // --- SETTING UP MONITORS ---
      output "HDMI-A-1" {
          // Включаем максимальную доступную герцовку из твоего списка
          mode "3440x1440@100.000"
          
          // Ставим его самым первым (слева)
          position x=0 y=0
      }

      output "eDP-1" {
          // Оставляем родные 144 Гц
          mode "1920x1080@144.000"
          
          // Сдвигаем его вправо ровно на ширину первого монитора (3440)
          position x=3440 y=0
      }

      // --- BINDS ---
      binds {
          // --- Basic programs ---
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
          Mod+B { spawn "zen"; }
          Mod+Q { close-window; }
          Mod+Shift+E { quit; }

          // Lock session
          Mod+Shift+l { spawn "loginctl" "lock-session"; }

          // --- Focus Navigation (Moving the gaze) ---
          Mod+h  { focus-column-left; }
          Mod+l { focus-column-right; }
          Mod+Up    { focus-window-up; }
          Mod+Down  { focus-window-down; }

          // --- Moving the windows themselves (Moving the windows around the screen) ---
          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up    { move-window-up; }
          Mod+Shift+Down  { move-window-down; }

          // --- Desktop Navigation (Workspaces) ---
          Mod+j { focus-workspace-down; }
          Mod+k   { focus-workspace-up; }
          // Перенести окно на другой рабочий стол
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Shift+Page_Up   { move-column-to-workspace-up; }

          // --- Column width control ---
          Mod+F { maximize-column; } // Развернуть окно на весь экран
          Mod+W { switch-preset-column-width; } // Циклично менять ширину окна (1/3, 1/2, 2/3)

          // --- (Stacking / Consume) ---
          Mod+T { consume-or-expel-window-left; }
          Mod+Y { consume-or-expel-window-right; }
          
          // --- Floating ---
          Mod+Space { toggle-window-floating; }
          Mod+Shift+Space { switch-focus-between-floating-and-tiling; }

          // --- (Overview) ---
          Mod+Tab { toggle-overview; }
      }
    '';

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
