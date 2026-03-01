{ pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;
  services.libinput.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hostName removed - handled by host file
  networking.networkmanager.enable = true;
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;
  zramSwap.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  users.users.regan = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    nautilus
    gnome-calculator
    gnome-text-editor
    papers
    showtime
    decibels
    flatpak
    nixfmt-rfc-style
    nil
    firefox
    spotify
    libreoffice
    thunderbird
    keepassxc
  ];

  services.gnome.core-apps.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    # The classics
    baobab
    epiphany
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-tour
    gnome-weather

    # The new ones (NixOS 25.11 / GNOME 47/48/49)
    loupe # Image Viewer
    totem # Video Player
    evince # Document Viewer (replaced by Papers)
    snapshot # Camera
    geary # Email
    yelp # Help
    seahorse # Passwords
    gnome-software # App Store (Doesn't work well on NixOS anyway)

    # Extra system tools you might not want
    gnome-connections
    simple-scan
  ];

  programs.bash.enable = true;

  programs.bash.shellAliases = {
    nixconf = "codium /etc/nixos/";
    editconf = "codium /etc/nixos/common/core.nix";
    edithost = "codium /etc/nixos/hosts/nixos-pc/configuration.nix";
    upconf = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-pc"; # Absolute path is safer
    pushconfig = "cd /etc/nixos && sudo git add . && sudo git commit -m 'Update Config' && sudo git push";
    clean = "nix-collect-garbage -d && sudo nix-store --optimise";
  };
}
