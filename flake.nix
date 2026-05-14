{
  description = "NixOS config — AMD A10 Pro + GTX 630 / Cinnamon";

  nixConfig = {
     substituters = [
       "https://cache.nixos.org"
       "https://cache.garnix.io"
       "https://freesmlauncher.cachix.org"
     ];
     trusted-public-keys = [
       "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
       "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
       "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
     ];
   };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    brave-previews.url = "github:roudinebwt/brave-preview";
    brave-previews.inputs.nixpkgs.follows = "nixpkgs";

    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher";
 };

  outputs = inputs @ { self, nixpkgs, nix-flatpak, brave-previews, freesmlauncher, ... }:
  let
    specialArgs = { inherit inputs; };
  in
    {
    nixosConfigurations.saadix = nixpkgs.lib.nixosSystem
    {
      system = "x86_64-linux";
      specialArgs = specialArgs;
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
