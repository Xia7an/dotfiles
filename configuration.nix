# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";
  
  networking.hostName = "FUJITSU-Server";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
   };
  };

  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;
  networking.firewall = {
    enable = true;
    # tailscaleの仮想NICを信頼する
    # `<Tailscaleのホスト名>:<ポート番号>`のアクセスが可能になる
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    xkb = {
      layout = "jp"; # 日本語配列にする
      variant = "";
      options = "terminate:ctrl_alt_bksp";
    };
    enable = true;
    displayManager = {
      gdm.enable = true;
    };
  };

  # swayを自動起動させるための設定
  services.gnome.gnome-keyring.enable = true;
  services.displayManager = {
    defaultSession = "sway";
  };
  # swayを有効化
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  #kanshi config
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
    };
  };


  # Enable the Deepin Desktop Environment.
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.deepin.enable = true;
  
  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "jp";
  #  variant = "";
  #};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.inoyu = {
    isNormalUser = true;
    description = "inoyu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  programs = {
    git = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true; # $EDITOR=nvimに設定
      viAlias = true;
      vimAlias = true;
    };
    zsh = {
      enable = true;
    };

  };

 i18n.inputMethod = {
   enabled = "fcitx5";
   fcitx5.addons = [pkgs.fcitx5-mozc];
 };

 fonts = {
   fonts = with pkgs; [
     noto-fonts-cjk-serif
     noto-fonts-cjk-sans
     noto-fonts-emoji
     # nerdfonts
     hackgen-nf-font
   ];
   fontDir.enable = true;
   fontconfig = {
     defaultFonts = {
       serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
       sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
       monospace = ["JetBrainsMono Nerd Font"];
       emoji = ["Noto Color Emoji"];
     };
   };
 };
  
  # Install firefox.
  programs.firefox.enable = true;
  
  #Docker configuration
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  
 #pdf2zh docker service
 systemd.services.pdf2zhd = {
    description = "pdf2zsh docker service";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker run -d -p 7860:7860 byaidu/pdf2zh";
      RemainAfterExit = true;
    };
  };
 systemd.services.ytmbookmarker = {
    description = "YTM Bookmarker Next.js service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/inoyu/nextjs/ytmusic-bookmarker";
      ExecStart = "/home/inoyu/.nix-profile/bin/npm run start";
      Restart = "always";
      EnvironmentFile = "/home/inoyu/nextjs/ytmusic-bookmarker/.env.local";
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;  
  };


  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  kitty
  rofi
  grim
  wl-clipboard
  mako
  yazi
  neofetch
  gotop 
  chromium
  (python311.withPackages (ps: with ps; [
      pip
      requests
      numpy 
    ]))
  ];

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  security.sudo.wheelNeedsPassword = false;
  
 #Nextcloud configuration
  environment.etc."nextcloud-admin-pass".text = "PWD";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "localhost";
    config = {
      adminuser = "inoyu";
      adminpassFile = "/etc/nextcloud-admin-pass";
      objectstore.s3.useSsl = true;
      dbtype = "sqlite";
    };  
    settings = {
      trusted_domains = ["localhost" "nixos"];
    };
    
  };

  #cron configuration
  services.cron = {
    enable = true;
    systemCronJobs = [
      "50 0 * * * root shutdown -h now"
    ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
