{
  lib,
  newScope,
  frotz,
}:

lib.makeScope newScope (self: {
  frotz = frotz.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      # -R cut save names short when the save directory's path was short
      ./frotz-restricted-path.patch
      # the exit prompt is an extra key press in a window that's closing anyway
      ./frotz-no-exit-prompt.patch
    ];
  });

  phosphor = "amber";
  fullscreen = false;
  gameEntries = false;
  profile = { };

  phosphorColor =
    let
      colors = {
        amber = "#ffb000";
        green = "#33ff66";
        white = "#e6e6e6";
      };
    in
    assert lib.assertOneOf "phosphor" self.phosphor (lib.attrNames colors);
    colors.${self.phosphor};

  games = import ./games.nix;

  zork-stories = self.callPackage ./stories.nix { };
  dfrotz = self.callPackage ./dfrotz.nix { };
  zork-crt-profile = self.callPackage ./crt-profile.nix { };
  zork-crt-term = self.callPackage ./crt-term.nix { };
  zork-icons = self.callPackage ./icons.nix { };
  zork-menu = self.callPackage ./menu.nix { };

  zork1 = self.callPackage ./game.nix { game = "zork1"; };
  zork2 = self.callPackage ./game.nix { game = "zork2"; };
  zork3 = self.callPackage ./game.nix { game = "zork3"; };
  zork-launcher = self.callPackage ./launcher.nix { };
  zork-plain = self.callPackage ./plain.nix { };

  zork-nix = self.callPackage ./all.nix { };
})
