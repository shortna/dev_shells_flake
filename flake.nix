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
        clang-tools # clangd is here
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
        { packages, stdenv }:
        pkgs.mkShell.override { stdenv = stdenv; } {
          packages = packages ++ common;
        };

    in
    {
      devShells.${system} = {
        rust = shell {
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
          stdenv = pkgs.llvmPackages_20.libcxxStdenv;
        };

        cllvm = shell {
          packages = [
            pkgs.clang-analyzer
            pkgs.lldb_20
            pkgs.llvmPackages_20.bintools
          ] ++ cTools;
          stdenv = pkgs.llvmPackages_20.libcxxStdenv;
        };

        cgnu = shell {
          packages = [
            pkgs.gdb
            pkgs.gef
            pkgs.binutils
          ] ++ cTools;
          stdenv = pkgs.gccStdenv;
        };

        lua = shell {
          packages = [
            pkgs.lua
            pkgs.lua-language-server
          ];
          stdenv = pkgs.stdenv;
        };

        haskell = shell {
          packages = [
            pkgs.ghc
            pkgs.cabal-install
            pkgs.haskell-language-server
            pkgs.ghcid
          ];
          stdenv = pkgs.stdenv;
        };

        nix = shell {
          packages = [
            pkgs.nixfmt-rfc-style
            pkgs.nixd
          ];
          stdenv = pkgs.stdenv;
        };

        python3 = shell {
          packages = [
            pkgs.python3
            pkgs.pyright
          ];
          stdenv = pkgs.stdenv;
        };
      };
    };
}
