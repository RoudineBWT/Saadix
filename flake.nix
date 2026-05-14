{
  description = "NixOS config — AMD A10 Pro + GTX 630 / Cinnamon";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak

    brave-previews.url = "github:roudinebwt/brave-preview";
    brave-previews.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, nix-flatpak, brave-previews, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
