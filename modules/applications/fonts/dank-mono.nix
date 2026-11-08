_: {
  flake.lib.fonts.dankMono = # make a  derivation for berkeley-mono font installation
    { pkgs }:

    pkgs.stdenv.mkDerivation {
      pname = "dank-mono-typeface";
      version = "1.009";

      src = ../../../assets/dank-mono.zip;

      unpackPhase = ''
        runHook preUnpack
        ${pkgs.unzip}/bin/unzip $src

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        install -Dm644 dank-mono/*.ttf -t $out/share/fonts/truetype

        runHook postInstall
      '';
    };
}
