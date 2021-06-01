{
  # WARNING this is very much still experimental.
  description = "A collection of darwin modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    lib = {
      # TODO handle multiple architectures.
      evalConfig = import ./eval-config.nix { inherit (nixpkgs) lib; currentSystem = "aarch64-darwin"; };
      darwinSystem = { modules, inputs ? {}, ... }@args:
        self.lib.evalConfig (args // {
          inputs = { inherit nixpkgs; darwin = self; } // inputs;
          modules = modules ++ [ self.darwinModules.flakeOverrides ];
        });
    };

    darwinModules.flakeOverrides = ./modules/system/flake-overrides.nix;
    darwinModules.hydra = ./modules/examples/hydra.nix;
    darwinModules.lnl = ./modules/examples/lnl.nix;
    darwinModules.ofborg = ./modules/examples/ofborg.nix;
    darwinModules.simple = ./modules/examples/simple.nix;

    checks.x86_64-darwin.simple = (self.lib.darwinSystem {
      modules = [ self.darwinModules.simple ];
    }).system;

  };
}
