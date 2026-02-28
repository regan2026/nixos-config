{ pkgs, ... }:

{
  home.username = "regan";
  home.homeDirectory = "/home/regan";
  home.stateVersion = "25.11";

  # 1. Packages & Extensions
  home.packages = with pkgs; [
    gnomeExtensions.forge
    gnomeExtensions.dash-to-panel
    nixos-artwork.wallpapers.simple-blue # Ensures the wallpaper is actually installed
  ];

  # 2. VSCodium Settings
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        piousdeer.adwaita-theme
      ];
      userSettings = {
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Adwaita Dark";
        "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixfmt";
      };
    };
  };

  # 3. GNOME & UI Settings (dconf)
  dconf.settings = {
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

    # --- FIX 1: THE WALLPAPER ---
    "org/gnome/desktop/background" = {
      picture-uri = "file://${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
      font-name = "Inter 11";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      panel-thickness = 36;
      appicon-margin = 2;
      panel-sizes = "{\"0\":36,\"1\":36}";
      multi-monitors = true;
    };

    "org/gnome/shell/extensions/forge" = {
      window-gap-size = 4;
      dnd-optimize = true;
    };

    # --- FIX 2: THE APP FOLDERS ---
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

    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
    };
  };
}
