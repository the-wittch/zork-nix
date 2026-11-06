{
  lib,
  writeShellApplication,
  coreutils,
  ncurses,
  frotz,
  games,
  zork-stories,
}:

let
  choices = lib.imap1 (i: name: {
    key = toString i;
    inherit name;
    inherit (games.${name}) title subtitle;
  }) (lib.attrNames games);
in
writeShellApplication {
  name = "zork-menu";
  runtimeInputs = [
    coreutils
    ncurses
  ];
  text = ''
    # zork-menu SAVES_DIR
    base=$1

    saved() {
      local files=("$base/$1"/*.qzl)
      if [[ -e ''${files[0]} ]]; then
        echo "  (saved)"
      fi
    }

    clear || true
    cat <<'EOF'

        #######   #####   ######   #    #
             #   #     #  #     #  #   #
            #    #     #  #     #  #  #
           #     #     #  ######   ###
          #      #     #  #   #    #  #
         #       #     #  #    #   #   #
        #######   #####   #     #  #    #

    EOF
    ${lib.concatMapStrings (c: ''
      printf '      %s  %-9s %-29s%s\n' ${c.key} ${lib.escapeShellArg c.title} ${lib.escapeShellArg c.subtitle} "$(saved ${c.name})"
    '') choices}
    printf '\n      Q  Quit\n\n'

    while true; do
      read -r -s -n 1 -p '      > ' key || exit 0
      echo
      case $key in
        ${lib.concatMapStrings (c: ''
          ${c.key}) game=${c.name} ;;
        '') choices}
        q | Q) exit 0 ;;
        *) continue ;;
      esac
      break
    done

    saves=$base/$game
    mkdir -p "$saves"
    cd "$saves"
    exec ${lib.getExe frotz} -R "$saves" "${zork-stories}/share/zork/$game.z3"
  '';
}
