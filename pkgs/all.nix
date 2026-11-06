{
  lib,
  symlinkJoin,
  zork1,
  zork2,
  zork3,
  zork-launcher,
  zork-plain,
}:

symlinkJoin {
  name = "zork-nix";
  paths = [
    zork1
    zork2
    zork3
    zork-launcher
    zork-plain
  ];
  meta = {
    description = "Zork I-III in a CRT terminal, with a menu and plain-terminal versions";
    mainProgram = "zork";
    platforms = lib.platforms.linux;
  };
}
