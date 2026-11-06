{
  perSystem =
    { lib, pkgs, ... }:
    let
      zork = pkgs.callPackage ../pkgs { };

      app = pkg: description: {
        type = "app";
        program = lib.getExe pkg;
        meta = { inherit description; };
      };
    in
    {
      # the whole scope, for overrideScope
      legacyPackages.zork = zork;

      packages = {
        inherit (zork)
          zork1
          zork2
          zork3
          zork-launcher
          zork-plain
          zork-nix
          ;
        default = zork.zork-launcher;
      };

      apps = {
        default = app zork.zork-launcher "Pick a Zork game in a CRT terminal";
        zork-launcher = app zork.zork-launcher "Pick a Zork game in a CRT terminal";
        zork1 = app zork.zork1 "Zork I in a CRT terminal";
        zork2 = app zork.zork2 "Zork II in a CRT terminal";
        zork3 = app zork.zork3 "Zork III in a CRT terminal";
        zork-plain = app zork.zork-plain "Pick a Zork game in this terminal";
      };
    };
}
