{
  lib,
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  coreutils,
  zork-crt-term,
  zork-icons,
  zork-menu,
}:

let
  launch = writeShellApplication {
    name = "zork";
    runtimeInputs = [
      coreutils
      zork-crt-term
    ];
    text = ''
      saves=''${XDG_DATA_HOME:-$HOME/.local/share}/zork
      mkdir -p "$saves"
      RESOURCE_NAME=zork exec zork-crt-term Zork "$saves" ${lib.getExe zork-menu} "$saves"
    '';
  };

  desktop = makeDesktopItem {
    name = "zork";
    desktopName = "Zork";
    genericName = "Text adventure";
    comment = "Pick Zork I, II or III";
    exec = "zork";
    icon = "zork";
    startupWMClass = "zork";
    categories = [
      "Game"
      "AdventureGame"
    ];
  };
in
symlinkJoin {
  name = "zork-launcher";
  paths = [
    launch
    desktop
    zork-icons
  ];
  meta = {
    description = "Menu for Zork I-III in a CRT terminal";
    mainProgram = "zork";
    platforms = lib.platforms.linux;
  };
}
