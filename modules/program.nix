let
  module =
    packagesOption:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.zork-nix;
      zork = (pkgs.callPackage ../pkgs { }).overrideScope (
        _: _: {
          inherit (cfg)
            phosphor
            fullscreen
            gameEntries
            profile
            ;
        }
      );
    in
    {
      options.programs.zork-nix = {
        enable = lib.mkEnableOption "Zork I-III in a CRT terminal";

        phosphor = lib.mkOption {
          type = lib.types.enum [
            "amber"
            "green"
            "white"
          ];
          default = "amber";
          description = "Phosphor colour of the CRT.";
        };

        fullscreen = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open the games full screen.";
        };

        gameEntries = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "List Zork I, II and III in the app menu too, not just the Zork menu.";
        };

        profile = lib.mkOption {
          type =
            with lib.types;
            attrsOf (oneOf [
              bool
              int
              float
              str
            ]);
          default = { };
          example = {
            screenCurvature = 0.4;
            flickering = 0;
          };
          description = "cool-retro-term profile values to change, by the names its profiles use.";
        };

        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          default = zork.zork-nix;
          description = "The games, launcher and plain-terminal versions, built with these options.";
        };
      };

      config = lib.mkIf cfg.enable (lib.setAttrByPath packagesOption [ cfg.package ]);
    };
in
{
  flake.nixosModules.default = module [
    "environment"
    "systemPackages"
  ];
  flake.homeModules.default = module [
    "home"
    "packages"
  ];
}
