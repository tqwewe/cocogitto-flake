{
  description = "The Conventional Commits toolbox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    cocogitto-git = {
      url = "github:cocogitto/cocogitto";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, cocogitto-git, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        craneLib = crane.lib.${system};
        cocogitto = craneLib.buildPackage {
          src = cocogitto-git;

          buildInputs = [ pkgs.libgit2 ];

          # GIT_AUTHOR_EMAIL = "cocogitto@cocogitto.com";
          # GIT_COMMITTER_EMAIL = "cocogitto@cocogitto.com";
          # GIT_AUTHOR_NAME = "Cocogitto";

          doCheck = false;
        };
      in
      {
        checks = {
          inherit cocogitto;
        };

        packages.default = cocogitto;

        apps.default = flake-utils.lib.mkApp {
          drv = cocogitto;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks.${system};

          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            git
          ];
        };
      });
}
