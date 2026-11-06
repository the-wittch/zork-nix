{
  lib,
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  coreutils,
  games,
  zork-crt-term,
  zork-menu,
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
      base=''${XDG_DATA_HOME:-$HOME/.local/share}/zork
      mkdir -p "$base/${game}"
      RESOURCE_NAME=${game} exec zork-crt-term ${lib.escapeShellArg info.title} "$base/${game}" \
        ${lib.getExe zork-menu} "$base" ${game}
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
