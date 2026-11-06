{
  lib,
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  coreutils,
  frotz,
  games,
  zork-stories,
  zork-crt-term,
  zork-icons,
  gameEntries,
  game,
}:

let
  info = games.${game};

  launch = writeShellApplication {
    name = game;
    runtimeInputs = [
      coreutils
      zork-crt-term
    ];
    text = ''
      saves=''${XDG_DATA_HOME:-$HOME/.local/share}/zork/${game}
      mkdir -p "$saves"
      RESOURCE_NAME=${game} exec zork-crt-term ${lib.escapeShellArg info.title} "$saves" \
        ${lib.getExe frotz} -R "$saves" ${zork-stories}/share/zork/${game}.z3
    '';
  };

  desktop = makeDesktopItem {
    name = game;
    desktopName = info.title;
    genericName = "Text adventure";
    comment = info.subtitle;
    exec = game;
    icon = game;
    startupWMClass = game;
    noDisplay = !gameEntries;
    categories = [
      "Game"
      "AdventureGame"
    ];
  };
in
symlinkJoin {
  name = game;
  paths = [
    launch
    desktop
    zork-icons
  ];
  meta = {
    description = "${info.title}: ${info.subtitle}, in a CRT terminal";
    mainProgram = game;
    platforms = lib.platforms.linux;
  };
}
