{
  description = "A very basic flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11"; };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux" # AMD/Intel Linux
        "aarch64-linux" # ARM Linux
        "aarch64-darwin" # ARM macOS
      ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems
        (system: fn { pkgs = import nixpkgs { inherit system; }; });

    in {
      # used when calling `nix fmt <path/to/flake.nix>`
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt);

      # nix develop <flake-ref>#<name>
      # -- 
      # $ nix develop <flake-ref>#blue
      # $ nix develop <flake-ref>#yellow
      devShells = forAllSystems ({ pkgs }: {
        blue = pkgs.mkShell {
          name = "blue";
          nativeBuildInputs = [ pkgs.fortune ];
          TEAM = "blue";
          shellHook = ''
            echo "team $TEAM rocks!"
          '';
        };
        yellow = pkgs.mkShell {
          name = "yellow";
          nativeBuildInputs = [ pkgs.fortune ];
          TEAM = "yellow";
          shellHook = ''
            echo "team $TEAM rocks!"
          '';
        };
      });

      # nix run|build <flake-ref>#<pkg-name>
      # -- 
      # $ nix run <flake-ref>#hello
      # $ nix run <flake-ref>#cowsay
      packages = forAllSystems ({ pkgs }: {
        hello = pkgs.hello;
        cowsay = pkgs.cowsay;
      });

      # nix flake init --template <flake-ref>#<template-name>
      templates = {
        starter-22-11 = {
          path = ./templates/starter-22.11;
          description = "starter for 22.11";
        };
      };
    };
}
