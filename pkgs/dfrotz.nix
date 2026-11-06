{ frotz }:

# nixpkgs only offers the curses and SDL front ends
frotz.overrideAttrs (old: {
  pname = "dfrotz";
  buildFlags = [ "dumb" ];
  installTargets = "install_dumb";
  meta = old.meta // {
    description = "Z-machine interpreter with plain text input and output";
    mainProgram = "dfrotz";
  };
})
