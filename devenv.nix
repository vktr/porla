{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.boost
    pkgs.cmake
    pkgs.curl
    pkgs.libsodium
    pkgs.libtorrent-rasterbar
    pkgs.lua54Packages.lua
    pkgs.ninja
    pkgs.openssl
    pkgs.sqlite
    pkgs.zlib
  ];
}
