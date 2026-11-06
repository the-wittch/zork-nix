{
  lib,
  writeShellApplication,
  symlinkJoin,
  coreutils,
  games,
  zork-menu,
}:

let
  savesBase = "\${XDG_DATA_HOME:-$HOME/.local/share}/zork";

  game =
    name:
    writeShellApplication {
      name = "${name}-plain";
      text = ''
        exec ${lib.getExe zork-menu} "${savesBase}" ${name}
      '';
    };

  menu = writeShellApplication {
    name = "zork-plain";
    runtimeInputs = [ coreutils ];
    text = ''
      saves=${savesBase}
      mkdir -p "$saves"
      exec ${lib.getExe zork-menu} "$saves"
    '';
  };
in
symlinkJoin {
  name = "zork-plain";
  paths = [ menu ] ++ map game (lib.attrNames games);
  meta = {
    description = "Zork I-III for any terminal, no CRT effects";
    mainProgram = "zork-plain";
    platforms = lib.platforms.unix;
  };
}
