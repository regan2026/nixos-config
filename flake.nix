{
  description = "Regan's NixOS Flake Configuration";

  inputs = {
    # The NixOS system source (locked to 25.11 Xantusia)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager (for your GNOME extensions and Codium)
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    {
      # NOTE: 'nixos' here must match your networking.hostName in configuration.nix
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          # This connects Home Manager to your Flake
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # This imports your separate home.nix file
            home-manager.users.regan = import ./home.nix;
          }
        ];
      };
    };
}
