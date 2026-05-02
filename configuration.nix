{ config, pkgs, inputs, myUserName, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- BOOT & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "tun" ];

  # --- SYSTEM SERVICES (VPN) ---
  systemd.services.throne-auto-load = {
    description = "Throne (Sing-Box) VLESS Auto-Start Daemon";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    unitConfig = {
      # Only start the service if the config file exists
      ConditionPathExists = "/etc/vpn/config.json";
    };

    serviceConfig = {
      User = "root";

      # Create a dedicated directory for cache and logs to prevent permission errors
      StateDirectory = "sing-box";
      WorkingDirectory = "/var/lib/sing-box"; 

      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/vpn/config.json";

      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; 
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };


  # --- NETWORKING ---
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall.allowedUDPPorts = [ 51820 ]; # Open port for WireGuard
  };

  # --- TIMEZONE & LOCALES ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # --- USERS ---
  users.users.${myUserName} = {
    isNormalUser = true;
    description = "${myUserName}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # --- PACKAGES & ENVIRONMENT ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    htop  
    wireguard-tools
    alacritty
    unzip
    unrar
    docker
    duf
    gdu
    xray
    greetd
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # --- PROGRAMS ---
  programs = {
    niri.enable = true;
    zsh.enable = true;
    throne = {
      enable = true;
      tunMode.enable = true; 
    };
  };

  hardware.graphics.enable = true;

  console = {
    useXkbConfig = true; 
  };


  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

  };

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; 
}
