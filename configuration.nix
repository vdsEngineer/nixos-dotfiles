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
    dunst
    wireguard-tools
    alacritty
    unzip
    unrar
    docker
    duf
    gdu
    xray
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # --- PROGRAMS ---
  programs = {
    zsh.enable = true;
    throne = {
      enable = true;
      tunMode.enable = true; 
    };
  };

  # --- GRAPHICS & DESKTOP (GNOME) ---
  hardware.graphics.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  
  # Disable unnecessary GNOME bloatware
  services.gnome = {
    core-apps.enable = false;
    localsearch.enable = false;
    tinysparql.enable = false;
  };

  # --- BACKGROUND SERVICES ---
  services.v2raya.enable = true;
  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; 
}
