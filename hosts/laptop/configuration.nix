{ config, pkgs, ... }:

{
imports = [
./hardware-configuration.nix
];

networking.hostName = "regan-laptop";

services.libinput.enable = true;
system.stateVersion = "25.11";
}
