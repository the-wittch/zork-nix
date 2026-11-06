{
  lib,
  runCommand,
  sqlite,
  phosphorColor,
  profile,
}:

let
  # every key cool-retro-term reads from a profile
  defaults = {
    fontColor = phosphorColor;
    backgroundColor = "#000000";
    fontName = "PRO_FONT_SCALED";
    fontWidth = 1;
    rasterization = 1;
    screenCurvature = 0.2;
    bloom = 0.55;
    flickering = 0.12;
    glowingLine = 0.15;
    burnIn = 0.25;
    staticNoise = 0.08;
    jitter = 0.08;
    horizontalSync = 0.05;
    chromaColor = 0.3;
    saturationColor = 0.3;
    rbgShift = 0;
    brightness = 0.55;
    contrast = 0.8;
    ambientLight = 0.15;
    windowOpacity = 1;
    margin = 0.5;
    frameMargin = 0.1;
    blinkingCursor = false;
  };

  unknown = lib.subtractLists (lib.attrNames defaults) (lib.attrNames profile);
  look =
    assert lib.assertMsg (
      unknown == [ ]
    ) "zork-nix profile: cool-retro-term has no setting called ${lib.concatStringsSep ", " unknown}";
    defaults // profile;

  settings = {
    width = 1024;
    height = 768;
    x = 100;
    y = 100;
    fps = 20;
    windowScaling = 1;
    fontScaling = 0.9;
    fontNames = [
      look.fontName
      look.fontName
      look.fontName
    ];
    showMenubar = false;
    showTerminalSize = false;
    bloomQuality = 0.5;
    burnInQuality = 0.5;
    useCustomCommand = false;
    customCommand = "";
  };

  # Qt LocalStorage names the file after the md5 of the database name, coolretroterm1
  db = "27e743fe85b8912a46804fed99e8a9ab";
in
runCommand "zork-crt-profile"
  {
    nativeBuildInputs = [ sqlite ];
    passAsFile = [
      "lookJson"
      "settingsJson"
    ];
    lookJson = builtins.toJSON look;
    settingsJson = builtins.toJSON settings;
  }
  ''
    mkdir $out
    sqlite3 $out/${db}.sqlite <<EOF
    CREATE TABLE settings(setting TEXT UNIQUE, value TEXT);
    INSERT INTO settings VALUES ('_CURRENT_PROFILE', readfile('$lookJsonPath'));
    INSERT INTO settings VALUES ('_CURRENT_SETTINGS', readfile('$settingsJsonPath'));
    INSERT INTO settings VALUES ('_CUSTOM_PROFILES', '[]');
    EOF
    cat > $out/${db}.ini <<EOF
    [General]
    Description=StorageDatabase
    Driver=QSQLITE
    EstimatedSize=100000
    Name=coolretroterm1
    Version=1.0
    EOF
  ''
