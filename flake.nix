{
  inputs.nixpkgs.url = "github:NickCao/nixpkgs/riscv";

  inputs.binderlay = {
    url = "github:dramforever/binderlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.starfive-linux = {
    url = "github:starfive-tech/linux/visionfive-5.18.y";
    flake = false;
  };

  nixConfig.extra-substituters = "https://cache.nichi.co";
  nixConfig.extra-trusted-public-keys = "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=";

  outputs = { self, nixpkgs, binderlay, sops-nix, starfive-linux }:
    let eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          crossSystem.config = "riscv64-unknown-linux-gnu";
          overlays = [
            self.overlays.starfive-linux
            binderlay.overlays.default
          ];
        });

      overlays.starfive-linux = self: super: {
        linuxPackages_starfive =
          (self.linuxPackagesFor
            (self.callPackage ./starfive-linux.nix {
              src = starfive-linux;
              kernelPatches = with self.kernelPatches; [];
            })).extend (kself: ksuper: {
              visionfive-kernel-modules =
                kself.callPackage ./kernel-modules {};
            });
      };

      nixosConfigurations.misaki = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          { nixpkgs.pkgs = self.legacyPackages."x86_64-linux"; }
        ];
      };
    };
}
