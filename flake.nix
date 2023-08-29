{
  description = "staticblog";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: 
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function rec {
          inherit system;
          compilerVersion = "ghc962";
          pkgs = nixpkgs.legacyPackages.${system};
          hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
            overrides = hfinal: hprev: {
              staticblog = hfinal.callCabal2nix "staticblog" ./. {};
            };
          };
        });
    in
    {
      # nix fmt
      formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

      # nix develop
      devShell = forAllSystems ({hsPkgs, pkgs, ...}:
        hsPkgs.shellFor {
          # withHoogle = true;
          packages = p: [
            p.staticblog
          ];
          buildInputs = with pkgs;
            [
              hsPkgs.haskell-language-server
              haskellPackages.cabal-install
              cabal2nix
              haskellPackages.ghcid
              haskellPackages.fourmolu
              haskellPackages.cabal-fmt
            ]
            ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
        });

      # nix build
      packages = forAllSystems ({hsPkgs, ...}: {
          staticblog = hsPkgs.staticblog;
          default = hsPkgs.staticblog;
      });

      # You can't build the staticblog package as a check because of IFD in cabal2nix
      checks = {};

      # nix run
      apps = forAllSystems ({system, ...}: {
        staticblog = { 
          type = "app"; 
          program = "${self.packages.${system}.staticblog}/bin/staticblog"; 
        };
        default = self.apps.${system}.staticblog;
      });
    };
}
