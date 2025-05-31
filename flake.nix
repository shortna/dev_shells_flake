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

        clang-manpages
      ];

      common = with pkgs; [
        jq
        git
        fish
        nvim.packages.${system}.default
        readline
	tokei
      ];

    in
    with pkgs;
    {
      devShells.${system} = {
        rust = mkShell.override { stdenv = pkgs.llvmPackages_20.libcxxStdenv; } {
          packages =
            with pkgs;
            [
              cargo
              rustc
              rustfmt
              rust-analyzer
              clippy
              bacon
              irust
              lldb_20
	      llvmPackages_20.bintools
            ]
            ++ common;
        };

        cllvm = mkShell.override { stdenv = pkgs.llvmPackages_20.libcxxStdenv; } {
          packages =
            with pkgs;
            [
              clang-analyzer
              lldb_20
	      llvmPackages_20.bintools
            ]
            ++ cTools
            ++ common;
        };

        cgnu = mkShell {
          packages =
            with pkgs;
            [
              gdb
              gef
              binutils
            ]
            ++ cTools
            ++ common;
        };

        lua = mkShell {
          packages =
            with pkgs;
            [
              lua
              lua-language-server
            ]
            ++ common;
        };

        haskell = mkShell {
          packages =
            with pkgs;
            [
              ghc
              cabal-install
              haskell-language-server
              ghcid
            ]
            ++ common;
        };

        nix = mkShell {
          packages =
            with pkgs;
            [
              nixfmt-rfc-style
              nixd
            ]
            ++ common;
        };

        python3 = mkShell {
          packages =
            with pkgs;
            [
              python3
              pyright
            ]
            ++ common;
        };
      };
    };
}
