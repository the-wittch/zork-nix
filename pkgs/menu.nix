{
  lib,
  writeShellApplication,
  coreutils,
  findutils,
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
    findutils
    ncurses
  ];
  text = ''
    # zork-menu SAVES_DIR [GAME]
    base=$1
    game=''${2:-}

    saved() {
      local files=("$base/$1"/*.qzl)
      if [[ -e ''${files[0]} ]]; then
        echo "  (saved)"
      fi
    }

    banner() {
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
    }

    if [[ -z $game ]]; then
      banner
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
    fi

    case $game in
      ${lib.concatMapStrings (c: ''
        ${c.name}) title=${lib.escapeShellArg c.title} ;;
      '') choices}
      *)
        echo "unknown game: $game" >&2
        exit 2
        ;;
    esac

    saves=$base/$game
    mkdir -p "$saves"
    cd "$saves"

    mapfile -d ''' -t files < <(
      find . -maxdepth 1 -type f -name '*.qzl' -printf '%T@\t%f\0' | sort -z -rn | head -z -n 9 | cut -z -f 2-
    )

    load=()
    if ((''${#files[@]})); then
      banner
      printf '      %s\n\n' "$title"
      for i in "''${!files[@]}"; do
        printf '      %d  %-26s %s\n' $((i + 1)) "''${files[i]}" "$(date -r "''${files[i]}" '+%Y-%m-%d %H:%M')"
      done
      printf '\n      N  New game\n      Q  Quit\n\n'

      while true; do
        read -r -s -n 1 -p '      Enter continues the newest > ' key || exit 0
        echo
        case $key in
          "") load=(-L "$saves/''${files[0]}") ;;
          [1-9])
            if ((key > ''${#files[@]})); then
              continue
            fi
            load=(-L "$saves/''${files[key - 1]}")
            ;;
          n | N) ;;
          q | Q) exit 0 ;;
          *) continue ;;
        esac
        break
      done
    fi

    exec ${lib.getExe frotz} -R "$saves" "''${load[@]}" "${zork-stories}/share/zork/$game.z3"
  '';
}
