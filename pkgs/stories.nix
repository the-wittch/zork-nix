{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  games,
}:

let
  sources = lib.mapAttrs (
    repo: game:
    fetchFromGitHub {
      owner = "historicalsource";
      inherit repo;
      inherit (game) rev hash;
    }
  ) games;
in
stdenvNoCC.mkDerivation {
  pname = "zork-stories";
  version = "0-unstable-2025-11-20";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
  ''
  + lib.concatStrings (
    lib.mapAttrsToList (name: src: ''
      install -Dm444 ${src}/COMPILED/${name}.z3 $out/share/zork/${name}.z3
      install -Dm444 ${src}/LICENSE $out/share/licenses/zork-stories/${name}-LICENSE
    '') sources
  )
  + ''
    runHook postInstall
  '';

  meta = {
    description = "Zork I-III story files, as compiled by Infocom";
    homepage = "https://github.com/historicalsource";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
