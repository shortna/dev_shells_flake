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
      ];

    in
    with pkgs;
    {
      devShells.${system} = {
        rust = mkShell.override { stdenv = pkgs.clangStdenv; } {
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
	      lld
            ]
            ++ common;
        };

        cllvm = mkShell.override { stdenv = pkgs.clangStdenv; } {
          packages =
            with pkgs;
            [
              clang-analyzer
              llvm
              lldb_20
              llvmPackages_20.lldbPlugins.llef
	      lld
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
              fennel
              fennel-ls
              lua
              lua-language-server
              fnlfmt
              lua52Packages.readline
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


        # delete later
        js = mkShell {
          packages =
            with pkgs;
            [
	      nodejs
	      nodePackages.live-server
	      nodePackages.typescript-language-server
            ]
            ++ common;
        };

        cSharp = mkShell {
          packages =
            with pkgs;
            [
	      dotnet-sdk
              csharp-ls
              csharprepl
            ]
            ++ common;
        };
      };
    };
}
