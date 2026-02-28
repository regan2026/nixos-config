{ ... }:

{
  imports = [
    # This links the machine-specific hardware (UUIDs, etc.)
    ./hardware-configuration.nix
    # This links your "Universal" settings (Apps, GNOME, Aliases)
    ../../common/core.nix
  ];

  # This is where the machine name is defined
  networking.hostName = "nixos-pc";
}
