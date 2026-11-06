{
  lib,
  writeShellApplication,
  cool-retro-term,
  coreutils,
  zork-crt-profile,
  fullscreen,
}:

writeShellApplication {
  name = "zork-crt-term";
  runtimeInputs = [
    cool-retro-term
    coreutils
  ];
  text = ''
    # zork-crt-term TITLE WORKDIR COMMAND [ARG...]
    title=$1
    workdir=$2
    shift 2

    state=''${XDG_STATE_HOME:-$HOME/.local/state}/zork-nix
    db=$state/cool-retro-term/cool-retro-term/QML/OfflineStorage/Databases
    mkdir -p "$db"
    cp -f --no-preserve=mode ${zork-crt-profile}/* "$db"/

    # cool-retro-term writes its settings back on exit; this keeps that away from yours
    export XDG_DATA_HOME=$state
    export FROTZ_NO_EXIT_PROMPT=1
    exec cool-retro-term ${lib.optionalString fullscreen "--fullscreen "}-T "$title" --workdir "$workdir" -e "$@"
  '';
}
