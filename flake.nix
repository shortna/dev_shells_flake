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
        sparse
        clang-tools # clangd is here
      ];

      common = with pkgs; [
	git
        fish
        nvim.packages.${system}.default
      ];

      shell =
        env: name: pkgs:
        env.mkDerivation {
          name = name;
          buildInputs = pkgs ++ common;
        };

    in
    with pkgs;
    {
      devShells.${system} = {
        rust = shell stdenvNoCC "rust" (
          with pkgs;
          [
            cargo
            rustc
            rustfmt
            rust-analyzer
            clippy
            bacon
	    irust
          ] ++ self.devShells.${system}.cllvm.buildInputs
        );

        cllvm = shell clangStdenv "cllvm" (
          with pkgs;
          [
            clang
            clang-analyzer
            llvm
            lldb
          ]
          ++ cTools
        );

        cgnu = shell gccStdenv "cgnu" (
          with pkgs;
          [
            gdb
            binutils
          ]
          ++ cTools
        );

        lua = shell stdenvNoCC "lua" (
          with pkgs;
          [
            lua
            lua-language-server
          ]
        );

        haskell = shell stdenvNoCC "haskell" (
          with pkgs;
          [
            ghc
            cabal-install
            haskell-language-server
          ]
        );

        nix = shell stdenvNoCC "nix" (
          with pkgs;
          [
            nixfmt-rfc-style
            nixd
          ]
        );

        python3 = shell stdenvNoCC "python3" (
          with pkgs;
          [
            python3
            pyright
          ]
        );

        cSharp = shell stdenvNoCC "cSharp" (
          with pkgs;
          [
            dotnet-sdk
            csharp-ls
            csharprepl
          ]
        );
      };
    };
}
