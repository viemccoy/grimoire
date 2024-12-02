{ pkgs ? import <nixpkgs> {} }:

let
  mozilla = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ mozilla ]; };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Use nightly rust with wasm target
    (nixpkgs.latest.rustChannels.nightly.rust.override {
      extensions = [ "rust-src" "rust-analyzer-preview" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
    
    # Required for egui/eframe
    pkg-config
    openssl
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    libxkbcommon
    libGL
    
    # Web development tools
    trunk
    wasm-pack
  ];

  shellHook = ''
    export RUSTC_VERSION=$(rustc --version)
    echo "Using Rust version: $RUSTC_VERSION"
    rustc --print target-list | grep wasm32-unknown-unknown
  '';
}