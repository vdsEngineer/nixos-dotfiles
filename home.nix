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

    pkgs.fuzzel
    
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

  xdg.configFile."niri/config.kdl".text = ''
      // --- АВТОЗАПУСК ---
      spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      spawn-at-startup "noctalia-shell"

      // Отключаем стартовую табличку с подсказками
      prefer-no-csd
      hotkey-overlay {
          skip-at-startup
      }

      // --- НАСТРОЙКИ ВВОДА ---
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

      // --- ВНЕШНИЙ ВИД ОКОН ---
      layout {
          gaps 16 // Отступы между окнами

          // Настройки обводки (border)
          border {
              off         // Выключаем стандартную обводку
          }

          // Вместо стандартной обводки используем focus-ring (она выглядит современнее и поддерживает скругления)
          focus-ring {
              width 2      // Сделали обводку тонкой (2 пикселя)
              
              // Цвет активного окна (замени HEX на тот, который тебе больше нравится, сейчас стоит синий)
              active-color "#89b4fa" 
              
              // Цвет неактивного окна (серый/полупрозрачный)
              inactive-color "#45475a"
          }

          // Скругление углов у окон (радиус в пикселях)
          struts {
              left 0
              right 0
              top 0
              bottom 0
          }
      }
      
      // Анимации Niri (делаем их чуть быстрее и плавнее)
      animations {
          window-open {
              duration-ms 200
              curve "ease-out-expo"
          }
      }

      // Окно настроек скруглений (нужно вынести из layout)
      window-rule {
          geometry-corner-radius 12 // Скругление углов окон
          clip-to-geometry true     // Обрезать содержимое по скругленным углам
      }

      // --- ГОРЯЧИЕ КЛАВИШИ (BINDS) ---
      binds {
          // --- Базовые программы ---
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "fuzzel"; }
          Mod+B { spawn "zen"; }
          Mod+Q { close-window; }
          Mod+Shift+E { quit; }

          // Экран блокировки
          Mod+L { spawn "loginctl" "lock-session"; }

          // --- Навигация фокуса (Перемещение взгляда) ---
          Mod+Left  { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up    { focus-window-up; }
          Mod+Down  { focus-window-down; }

          // --- Перемещение самих окон (Двигаем окна по экрану) ---
          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up    { move-window-up; }
          Mod+Shift+Down  { move-window-down; }

          // --- Навигация по рабочим столам (Workspaces) ---
          Mod+Page_Down { focus-workspace-down; }
          Mod+Page_Up   { focus-workspace-up; }
          // Перенести окно на другой рабочий стол
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Shift+Page_Up   { move-column-to-workspace-up; }

          // --- Управление шириной колонок ---
          Mod+F { maximize-column; } // Развернуть окно на весь экран
          Mod+W { switch-preset-column-width; } // Циклично менять ширину окна (1/3, 1/2, 2/3)

          // --- ВКЛАДКИ (Stacking / Consume) ---
          // Объединить окна (вкладки)
          Mod+T { consume-or-expel-window-left; }
          Mod+Y { consume-or-expel-window-right; }
          
          // --- Floating (Плавающие окна) ---
          // Сделать окно плавающим (отвязать от сетки)
          Mod+Space { toggle-window-floating; }
          Mod+Shift+Space { switch-focus-between-floating-and-tiling; }

          // --- Обзор (Overview) ---
          // Показать все рабочие столы (как в GNOME)
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
