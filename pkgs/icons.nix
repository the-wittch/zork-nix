{
  lib,
  runCommand,
  writeText,
  games,
  phosphorColor,
}:

let
  icon =
    label:
    writeText "icon.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
        <defs>
          <pattern id="scan" width="4" height="4" patternUnits="userSpaceOnUse">
            <rect width="4" height="2" fill="#000000" fill-opacity="0.35"/>
          </pattern>
        </defs>
        <rect x="4" y="8" width="120" height="104" rx="18" fill="#2a2622"/>
        <rect x="14" y="18" width="100" height="78" rx="16" fill="#0b0b0b"/>
        <text x="64" y="54" fill="${phosphorColor}" font-family="monospace" font-size="27" font-weight="bold" text-anchor="middle">ZORK</text>
        <text x="64" y="84" fill="${phosphorColor}" font-family="monospace" font-size="24" font-weight="bold" text-anchor="middle">${label}</text>
        <rect x="14" y="18" width="100" height="78" rx="16" fill="url(#scan)"/>
        <rect x="52" y="112" width="24" height="8" rx="3" fill="#2a2622"/>
      </svg>
    '';
in
runCommand "zork-icons" { } (
  ''
    dir=$out/share/icons/hicolor/scalable/apps
    mkdir -p $dir
    install -m444 ${icon ">_"} $dir/zork.svg
  ''
  + lib.concatStrings (
    lib.mapAttrsToList (name: game: ''
      install -m444 ${icon game.numeral} $dir/${name}.svg
    '') games
  )
)
