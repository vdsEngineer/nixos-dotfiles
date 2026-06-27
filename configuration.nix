{ config, pkgs, inputs, myUserName, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- BOOT & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "tun" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [
    "nvidia.NVreg_DynamicPowerManagement=0x00"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"   
    "nvidia.NVreg_EnableS0ixPowerManagement=0"
    "pcie_aspm=off" 
    "nvidia-drm.fbdev=1"
  ];

  systemd.tmpfiles.rules = [
    "d /var/log/atop 0755 root root 7d"
  ];

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

systemd.services.nvidia-clock-lock = {
    description = "Lock NVIDIA GPU clocks to prevent Niri Wayland stuttering";
    
    wantedBy = [ "multi-user.target" ];
    
    after = [ "systemd-modules-load.service" ]; 

    serviceConfig = {
      Type = "oneshot"; 
      User = "root";    
      ExecStartPre = "-${config.hardware.nvidia.package.bin}/bin/nvidia-smi -rgc";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lgc 450,600";
      ExecStartPost = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl 12";
      RemainAfterExit = true;
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
    firewall.allowedUDPPorts = [ 51820 19999 ]; # Open port for WireGuard
    firewall.trustedInterfaces = [ "docker0" ];
    firewall.extraCommands = ''
      iptables -I INPUT -i br-+ -j ACCEPT
      iptables -I FORWARD -i br-+ -j ACCEPT
      iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -o wlp4s0 -j MASQUERADE
    '';
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
    steam-run
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NVD_BACKEND = "direct";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      ELECTRON_ENABLE_WAYLAND = "1";
      NIRI_DEBUG_RENDER_OFFSCREEN = "1";
  };

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
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    atop = {
        enable = true;
    };
  };

  hardware.graphics.enable = true;
  
  hardware.nvidia = {
    modesetting.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = false; 
    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;
    nvidiaPersistenced = true;

    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0"; 
      amdgpuBusId = "PCI:6:0:0";
    };
  };

  console = {
    useXkbConfig = true; 
  };


  services = {
    udisks2.enable = true;
    gvfs.enable = true;

    xserver = {
      enable = false;
      videoDrivers = [ "nvidia" ];
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

  zramSwap = {
    enable = true;
    algorithm = "zstd"; 
    memoryPercent = 100;
  };

  system.stateVersion = "25.05"; 
}
