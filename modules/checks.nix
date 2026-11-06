{ config, ... }:
let
  inherit (config.flake) nixosModules homeModules;
in
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      zork = config.legacyPackages.zork;
      green = zork.overrideScope (_: _: { phosphor = "green"; });
      typo = zork.overrideScope (_: _: { profile.screenCurvatur = 0.4; });
      withGames = zork.overrideScope (_: _: { gameEntries = true; });

      # stands in for frotz inside the CRT and reports how it was started
      probe = pkgs.writeShellScriptBin "frotz" ''
        window=$(xwininfo -root -tree | grep -m1 '"Zork I"' | awk '{ print $1 }')
        {
          echo "parent=$(cat /proc/$PPID/comm)"
          echo "cwd=$PWD"
          echo "args=$*"
          echo "exit-prompt=''${FROTZ_NO_EXIT_PROMPT:-}"
          echo "wm-class=$(xprop -id "$window" WM_CLASS)"
        } > "$HOME/probe"
      '';
      probed = zork.overrideScope (_: _: { frotz = probe; });

      opening = {
        zork1 = "West of House";
        zork2 = "Inside the Barrow";
        zork3 = "Endless Stair";
      };

      play =
        game:
        pkgs.runCommand "smoke-${game}" { nativeBuildInputs = [ zork.dfrotz ]; } ''
          printf 'look\nquit\ny\n' | dfrotz -m -p -w 80 ${zork.zork-stories}/share/zork/${game}.z3 > out
          grep -q ${lib.escapeShellArg opening.${game}} out || { cat out; exit 1; }
          touch $out
        '';

      # options a module evaluation needs, without the rest of NixOS or Home Manager
      stub =
        path:
        { lib, ... }:
        {
          options = lib.setAttrByPath path (
            lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            }
          );
          config._module.args.pkgs = pkgs;
        };

      evalModule =
        module: path:
        (lib.evalModules {
          modules = [
            module
            (stub path)
            {
              programs.zork-nix = {
                enable = true;
                phosphor = "green";
              };
            }
          ];
        }).config;

      nixos = evalModule nixosModules.default [
        "environment"
        "systemPackages"
      ];
      home = evalModule homeModules.default [
        "home"
        "packages"
      ];
    in
    {
      checks = lib.mapAttrs' (game: _: lib.nameValuePair "smoke-${game}" (play game)) opening // {
        saves-stay-put = pkgs.runCommand "saves-stay-put" { nativeBuildInputs = [ zork.dfrotz ]; } ''
          mkdir saves elsewhere
          cd saves
          printf 'save\nzork1.qzl\nsave\na-long-save-name-for-a-short-path.qzl\nsave\n%s/elsewhere/escape.qzl\nquit\ny\n' "$PWD/.." \
            | dfrotz -m -p -R "$PWD" ${zork.zork-stories}/share/zork/zork1.z3 > /dev/null
          test -s zork1.qzl
          test -s a-long-save-name-for-a-short-path.qzl
          test -z "$(ls -A ../elsewhere)"
          touch $out
        '';

        crt-profile =
          pkgs.runCommand "crt-profile"
            {
              nativeBuildInputs = [
                pkgs.sqlite
                pkgs.jq
              ];
            }
            ''
              check() {
                db=$(echo "$1"/*.sqlite)
                for key in _CURRENT_PROFILE _CURRENT_SETTINGS _CUSTOM_PROFILES; do
                  test "$(sqlite3 "$db" "select count(*) from settings where setting = '$key'")" = 1
                done
                sqlite3 "$db" "select value from settings where setting = '_CURRENT_PROFILE'" \
                  | jq -e --arg c "$2" '.fontColor == $c and .rasterization == 1' > /dev/null
              }
              check ${zork.zork-crt-profile} '#ffb000'
              check ${green.zork-crt-profile} '#33ff66'
              test ${lib.boolToString (builtins.tryEval typo.zork-crt-profile.drvPath).success} = false
              touch $out
            '';

        desktop-files =
          pkgs.runCommand "desktop-files" { nativeBuildInputs = [ pkgs.desktop-file-utils ]; }
            ''
              desktop-file-validate ${zork.zork-nix}/share/applications/*.desktop
              for name in zork zork1 zork2 zork3; do
                test -f ${zork.zork-nix}/share/icons/hicolor/scalable/apps/$name.svg
              done
              ! grep -q NoDisplay ${zork.zork-nix}/share/applications/zork.desktop
              grep -qx NoDisplay=true ${zork.zork-nix}/share/applications/zork1.desktop
              ! grep -q NoDisplay ${withGames.zork-nix}/share/applications/zork1.desktop
              touch $out
            '';

        crt-launch =
          pkgs.runCommand "crt-launch"
            {
              nativeBuildInputs = with pkgs; [
                xvfb-run
                xwininfo
                xprop
                gawk
                sqlite
              ];
            }
            ''
              export HOME=$PWD/home
              export XDG_DATA_HOME=$HOME/.local/share XDG_STATE_HOME=$HOME/.local/state XDG_CACHE_HOME=$HOME/.cache
              mkdir -p $HOME

              # software OpenGL, since the sandbox has no GPU
              export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
              export __EGL_VENDOR_LIBRARY_DIRS=${pkgs.mesa}/share/glvnd/egl_vendor.d
              export LD_LIBRARY_PATH=${pkgs.mesa}/lib

              xvfb-run -a -s '-screen 0 1280x1024x24' timeout 120 ${probed.zork1}/bin/zork1

              cat $HOME/probe
              saves=$XDG_DATA_HOME/zork/zork1
              grep -qx 'parent=.cool-retro-ter' $HOME/probe
              grep -qx "cwd=$saves" $HOME/probe
              grep -qx "args=-R $saves ${zork.zork-stories}/share/zork/zork1.z3" $HOME/probe
              grep -qx 'exit-prompt=1' $HOME/probe
              grep -qx 'wm-class=WM_CLASS(STRING) = "zork1", "cool-retro-term"' $HOME/probe

              test "$(ls -A $XDG_DATA_HOME)" = zork
              test "$(sqlite3 $XDG_STATE_HOME/zork-nix/cool-retro-term/cool-retro-term/QML/OfflineStorage/Databases/*.sqlite \
                "select json_extract(value, '$.fontColor') from settings where setting = '_CURRENT_PROFILE'")" = '#ffb000'
              touch $out
            '';

        menu-saved = pkgs.runCommand "menu-saved" { } ''
          mkdir -p saves/zork2
          touch saves/zork2/zork2.qzl
          printf q | TERM=dumb ${zork.zork-menu}/bin/zork-menu saves > out
          grep -q 'Zork II .*(saved)' out
          ! grep -q -e 'Zork I .*(saved)' -e 'Zork III .*(saved)' out
          touch $out
        '';

        modules =
          assert nixos.environment.systemPackages == [ nixos.programs.zork-nix.package ];
          assert home.home.packages == [ home.programs.zork-nix.package ];
          assert nixos.programs.zork-nix.package != zork.zork-nix;
          pkgs.runCommand "modules" { } "touch $out";
      };
    };
}
