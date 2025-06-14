{ pkgs, lib, config, inputs, ... }:

let
  libantlr4 = pkgs.stdenv.mkDerivation {
    name = "antlr4";
    version = "2.1.0";
    
    src = pkgs.fetchFromGitHub {
      owner = "antlr";
      repo = "antlr4";
      rev = "4.13.2";
      sha256 = "sha256-DxxRL+FQFA+x0RudIXtLhewseU50aScHKSCDX7DE9bY=";
    };

    nativeBuildInputs = with pkgs; [
      cmake
    ];
    
    buildInputs = with pkgs; [
      # Add any runtime dependencies here
    ];

    sourceRoot = "source/runtime/Cpp";

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DWITH_LIBCXX=OFF"
      "-DANTLR_BUILD_CPP_TESTS=OFF"
    ];

    buildPhase = ''
      make -j$NIX_BUILD_CORES
    '';

    installPhase = ''
      make install
    '';
  };

  libuws = pkgs.stdenv.mkDerivation {
    name = "uWebSockets";
    version = "000d9fe";
    
    src = pkgs.fetchFromGitHub {
      owner = "vktr";
      repo = "uWebSockets";
      rev = "95e7c8b06c757e6d89ea5295237fee11e0664abc";
      sha256 = "sha256-Icz7joaoTtluz3Zvppi8gJmT+8dvbUWu93R/2RqT+s8=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      boost
      openssl
      openssl.dev
      zlib
    ];
    
    buildInputs = with pkgs; [
    ];

    sourceRoot = "source";

    buildPhase = ''
      WITH_ASIO=1 WITH_OPENSSL=1 make -j$NIX_BUILD_CORES
    '';

    installPhase = ''
      mkdir -p $out/include
      mkdir -p $out/include/uWebSockets
      mkdir -p $out/lib

      cp uSockets/uSockets.a $out/lib/libuSockets.a
      cp uSockets/src/libusockets.h $out/include
      cp src/* $out/include/uWebSockets
    '';
  };

in
{
  packages = [
    libantlr4
    libuws

    pkgs.antlr
    pkgs.boost
    pkgs.cmake
    pkgs.curl.dev
    pkgs.libsodium
    pkgs.libtorrent-rasterbar
    pkgs.libzip
    pkgs.llvm
    pkgs.lua54Packages.lua
    pkgs.ninja
    pkgs.openssl
    pkgs.openssl.dev
    pkgs.sqlite.dev
    pkgs.zlib.dev
  ];

  env = {
  };
}
