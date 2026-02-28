{ config, pkgs, ... }:

{
  home.username = "regan";
  home.homeDirectory = "/home/regan";
  home.stateVersion = "25.11";

  # 1. Packages & Extensions
  home.packages = with pkgs; [
    gnomeExtensions.forge
    gnomeExtensions.dash-to-panel
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

    # Forge Keybindings
    "org/gnome/shell/extensions/forge/keybindings" = {
      window-swap-left = [ "<Super><Shift>Left" ];
      window-swap-right = [ "<Super><Shift>Right" ];
      window-swap-up = [ "<Super><Shift>Up" ];
      window-swap-down = [ "<Super><Shift>Down" ];
      window-focus-left = [ "<Super>Left" ];
      window-focus-right = [ "<Super>Right" ];
      window-focus-up = [ "<Super>Up" ];
      window-focus-down = [ "<Super>Down" ];
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
    };
  };
}
