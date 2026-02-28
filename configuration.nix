{ config, pkgs, ... }:

{
  # 1. CORE SYSTEM & BOOT-----------------------------------------------------------------------------------

  imports = [
    ./hardware-configuration.nix
    #<home-manager/nixos>
  ];

  # Added for Hibernation support ---on a different computer Run commands to get computer specific info
  boot.resumeDevice = "/dev/disk/by-uuid/c7265919-2426-4228-ba0a-3fe91fcb89b2"; # -findmnt -no SOURCE,UUID -T /var/lib/swapfile
  boot.kernelParams = [ "resume_offset=122726400" ]; # -sudo filefrag -v /var/lib/swapfile | head -n 4 | tail -n 1 | awk '{print $4}' | sed 's/\.\.//'

  nix.settings.experimental-features = [
    "nix-command"
  ];
  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. SYSTEM IDENTITY & LOCALIZATION----------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [
    "162.252.172.57"
    "1.1.1.1"
  ];

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  nixpkgs.config = {
    allowUnfree = true;
  };

  # 3. HARDWARE & SERVICES (Drivers, Sound, Printing)---------------------------------------------------------
  # ---If the new computer is different (e.g., an AMD processor or Nvidia GPU), comment out those lines before the first rebuild
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt # <--- N95 video acceleration
      libvdpau-va-gl # <--- Helps with some older hardware-accelerated apps
      intel-compute-runtime # Enables OpenCL for faster image/video processing
    ];
  };

  # ADD THIS: Force the Intel Media Driver for GTK4 apps
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    GSK_RENDERER = "ngl";
    # Improves Wayland performance on Intel integrated GPUs
    MUTTER_DEBUG_ENABLE_ATOMIC_KMS = "0";
    # Fixes potential flickering in GTK4 apps on Alder Lake-N
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  # Automated cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ]; # Runs once a day
  # ADD THIS: Keep at least 5GB free at all times
  nix.settings.min-free = 5 * 1024 * 1024 * 1024;
  nix.settings.auto-optimise-store = true;

  # zram for fast compression, swapfile for hibernation/safety
  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16384;
    }
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # 4. DESKTOP ENVIRONMENT-------------------------------------------------------------------------------------
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Add this block for smoother UI scaling and VRR
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=['variable-refresh-rate', 'scale-monitor-framebuffer']
  '';

  # Add a fonts section here to improve readability on your 22" Dell
  fonts.packages = with pkgs; [
    inter
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];

  # GNOME specific tweaks
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;

  # GNOME Security & Settings
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # GNOME Bloat Removal
  environment.gnome.excludePackages = with pkgs; [
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
    loupe
    totem
    evince
    simple-scan
    snapshot
    geary
    yelp
    gnome-connections
    seahorse
    gnome-software
  ];

  #5. Users & Permissions-----------------------------------------------------------------------------------

  users.users.regan = {
    isNormalUser = true;
    description = "regan";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # 6. SYSTEM-WIDE PACKAGES & SHELL--------------------------------------------------------------------------

  # These are available to ALL users
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
    nix-index
    nil
    fastfetch
    keepassxc
    firefox
    spotify
    libreoffice
    thunderbird

  ];

  # Enable nix-index integration
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false; # Disable the old one

  # Aliases
  programs.bash.shellAliases = {
    editconf = "codium /etc/nixos/configuration.nix";
    upconf = "sudo nixos-rebuild switch";
    syncconf = "cd /etc/nixos && sudo git pull --rebase && sudo nixos-rebuild switch";
    pushconfig = "sudo git -C /etc/nixos add . && sudo git -C /etc/nixos commit -m 'update config' && sudo git -C /etc/nixos push";
    clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo nix-store --optimise";
    trash = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1 && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    hibernate = "systemctl hibernate";
    memcheck = "zramctl && free -h";
    glog = "journalctl -f -u display-manager";
  };

  # 7. Home Manager: (Specific UI styling for main account)--------------------------------------------------
  /*
    home-manager.users.regan =
      { pkgs, ... }:
      {
        home.stateVersion = "25.11";
        home.enableNixpkgsReleaseCheck = false;
        home.packages = with pkgs; [
          gnomeExtensions.forge
          gnomeExtensions.dash-to-panel
        ];

        # --- CATEGORY 2: VSCodium SHELL ---
        programs.vscode = {
          enable = true;
          package = pkgs.vscodium;

          # Move these into the "default" profile
          profiles.default = {
            extensions = with pkgs.vscode-extensions; [
              jnoortheen.nix-ide
              piousdeer.adwaita-theme
            ];

            userSettings = {
              "window.titleBarStyle" = "custom";
              "workbench.colorTheme" = "Adwaita Dark";
              "editor.fontFamily" = "'JetBrains Mono', 'monospace'";

              # --- ADD THESE FOR AUTO-FORMATTING ---
              "editor.formatOnSave" = true;
              "editor.defaultFormatter" = "jnoortheen.nix-ide";

              "[nix]" = {
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
                "editor.formatOnSave" = true;
              };

              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nil";
              "nix.formatterPath" = "nixfmt"; # Uses the nixfmt-rfc-style you have in Section 6
            };
          };
        };

        dconf.settings = {
          # --- CATEGORY 2: GNOME SHELL ---
          "org/gnome/shell" = {
            disable-user-extensions = false;
            disable-extension-version-validation = true;
            enabled-extensions = [
              pkgs.gnomeExtensions.forge.extensionUuid
              pkgs.gnomeExtensions.dash-to-panel.extensionUuid
            ];
            favorite-apps = [
              "firefox.desktop"
              "thunderbird.desktop"
              "codium.desktop"
              "spotify.desktop"
              "org.keepassxc.KeePassXC.desktop"
              "com.surfshark.Surfshark.desktop"
              "org.gnome.Calculator.desktop"
              "startcenter.desktop"
              "org.gnome.Nautilus.desktop"
            ];
          };

          # --- CATEGORY 3: GLOBAL APPEARANCE ---
          "org/freedesktop/appearance" = {
            color-scheme = 1; # 1 = Prefer dark, helps Flatpaks/Legacy apps stay dark
          };

          # --- CATEGORY 4: EXTENSION SETTINGS ---
          "org/gnome/shell/extensions/dash-to-panel" = {
            panel-thickness = 36;
            appicon-margin = 2;
            panel-sizes = "{\"0\":36,\"1\":36}";
            multi-monitors = true;
          };

          "org/gnome/shell/extensions/forge" = {
            window-gap-size = 4; # Adds a small aesthetic gap between tiled windows
            dnd-optimize = true;
          };
          "org/gnome/desktop/wm/keybindings" = {
            # Disable GNOME's default window movement so Forge can handle it
            move-to-monitor-left = [ ];
            move-to-monitor-right = [ ];
            move-to-monitor-up = [ ];
            move-to-monitor-down = [ ];
            switch-to-buffer-left = [ ];
            switch-to-buffer-right = [ ];
          };

          "org/gnome/shell/extensions/forge/keybindings" = {
            # Set Forge to use familiar shortcuts (e.g., Super + Arrows or Vim keys)
            window-swap-left = [ "<Super><Shift>Left" ];
            window-swap-right = [ "<Super><Shift>Right" ];
            window-swap-up = [ "<Super><Shift>Up" ];
            window-swap-down = [ "<Super><Shift>Down" ];

            # Focus movement
            window-focus-left = [ "<Super>Left" ];
            window-focus-right = [ "<Super>Right" ];
            window-focus-up = [ "<Super>Up" ];
            window-focus-down = [ "<Super>Down" ];
          };

          # --- CATEGORY 5: INTERFACE & BEHAVIOR ---
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            enable-hot-corners = false; # Recommended when using 'Forge' tiling
            show-battery-percentage = true;
            font-name = "Inter 11"; # Uses the font we added in Section 4
          };

          "org/gnome/desktop/background" = {
            picture-uri = "file:///nix/store/mh4hbqq6b0x4sfb2jqjjzllya0lg27fx-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
            picture-uri-dark = "file:///nix/store/mh4hbqq6b0x4sfb2jqjjzllya0lg27fx-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
          };
          "org/gnome/desktop/screensaver" = {
            picture-uri = "file:///nix/store/mh4hbqq6b0x4sfb2jqjjzllya0lg27fx-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
          };

          "org/gnome/mutter" = {
            edge-tiling = true;
            dynamic-workspaces = true;
          };

          # --- CATEGORY 6: APP FOLDERS ---
          "org/gnome/desktop/app-folders" = {
            folder-children = [
              "Libre"
              "Media"
              "Office"
              "Security"
              "Settings"
              "Terminals"
              "Utilities"
            ];
          };
          "org/gnome/desktop/app-folders/folders/Libre" = {
            name = "Libre Office";
            translate = false;
            apps = [
              "writer.desktop"
              "calc.desktop"
              "impress.desktop"
              "math.desktop"
              "draw.desktop"
              "base.desktop"
            ];
          };
          "org/gnome/desktop/app-folders/folders/Media" = {
            name = "Media Players";
            translate = false;
            apps = [
              "org.gnome.Showtime.desktop"
              "org.gnome.Decibels.desktop"
            ];
          };
          "org/gnome/desktop/app-folders/folders/Office" = {
            name = "My Office Apps";
            translate = false;
            apps = [
              "org.gnome.TextEditor.desktop"
              "org.gnome.Papers.desktop"
            ];
          };
          "org/gnome/desktop/app-folders/folders/Settings" = {
            name = "Settings";
            translate = false;
            apps = [
              "org.gnome.Settings.desktop"
              "nixos-manual.desktop"
            ];
          };
          "org/gnome/desktop/app-folders/folders/Terminals" = {
            name = "Terminals";
            translate = false;
            apps = [ "xterm.desktop" ];
          };
          "org/gnome/desktop/app-folders/folders/Utilities" = {
            name = "System Utilities";
            translate = false;
            apps = [
              "org.gnome.DiskUtility.desktop"
              "cups.desktop"
              "org.gnome.Extensions.desktop"
            ];
          };
        };
  */
}
