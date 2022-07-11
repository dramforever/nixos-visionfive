{
  inputs.nixpkgs.url = "github:NickCao/nixpkgs/riscv";

  inputs.starfive-linux = {
    url = "github:starfive-tech/linux/visionfive-5.18.y";
    flake = false;
  };

  nixConfig.extra-substituters = "https://cache.nichi.co";
  nixConfig.extra-trusted-public-keys = "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=";

  outputs = { self, nixpkgs, starfive-linux }:
    let eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          crossSystem.config = "riscv64-unknown-linux-gnu";
          overlays = [ self.overlays.starfive-linux ];
        });

      overlays.starfive-linux = self: super: {
        linuxPackages_starfive =
          self.linuxPackagesFor
            (self.callPackage ./starfive-linux.nix {
              src = starfive-linux;
              kernelPatches = with self.kernelPatches; [];
            });
      };

      nixosConfigurations.misaki = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [
          ./configuration.nix
          { nixpkgs.pkgs = self.legacyPackages."x86_64-linux"; }
        ];
      };
    };
}
