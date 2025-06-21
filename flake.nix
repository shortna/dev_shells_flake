{
  description = "dev env's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nvim.url = "github:shortna/nvim_flake/master";
  };

  outputs =
    {
      self,
      nixpkgs,
      nvim,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      cTools = with pkgs; [
        bear
        gnumake
        cmake
        ninja
        autoconf
        automake
        pkg-config
        pkgconf
        valgrind
        llvmPackages_20.clang-tools # clangd is here
      ];

      common = with pkgs; [
        jq
        git
        fish
        nvim.packages.${system}.default
        readline
        tokei
      ];

      shell =
        { name, packages, env }:
        env.mkDerivation {
          name = name;
          nativeBuildInputs = packages ++ common;
        };

    in
    {
      devShells.${system} = {
        rust = shell {
          name = "rust";
          packages = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rustfmt
            pkgs.rust-analyzer
            pkgs.clippy
            pkgs.bacon
            pkgs.irust
            pkgs.lldb_20
            pkgs.llvmPackages_20.bintools
          ];
          env = pkgs.llvmPackages_20.stdenv;
        };

        cllvm = shell {
          name = "cllvm";
          packages = [
            pkgs.clang-analyzer
            pkgs.lldb_20
            pkgs.llvmPackages_20.bintools
          ] ++ cTools;
          env = pkgs.llvmPackages_20.stdenv;
        };

        cgnu = shell {
          name = "cgnu";
          packages = [
            pkgs.gdb
            pkgs.gef
            pkgs.binutils
          ] ++ cTools;
          env = pkgs.gccStdenv;
        };

        lua = shell {
          name = "lua";
          packages = [
            pkgs.lua
            pkgs.lua-language-server
          ];
          env = pkgs.stdenv;
        };

        haskell = shell {
          name = "haskell";
          packages = [
            pkgs.ghc
            pkgs.cabal-install
            pkgs.haskell-language-server
            pkgs.ghcid
          ];
          env = pkgs.stdenv;
        };

        nix = shell {
          name = "nix";
          packages = [
            pkgs.nixfmt-rfc-style
            pkgs.nixd
          ];
          env = pkgs.stdenv;
        };

        python3 = shell {
          name = "python3";
          packages = [
            pkgs.python3
            pkgs.pyright
          ];
          env = pkgs.stdenv;
        };
      };
    };
}
