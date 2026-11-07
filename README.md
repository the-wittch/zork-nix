# zork-nix

Zork I, II and III in cool-retro-term, with amber phosphor, scanlines, a little curvature, bloom and flicker.

## Play

A menu to pick I, II or III:

```bash
nix run github:the-wittch/zork-nix
```

Straight into one game (`zork1`, `zork2` or `zork3`), or the menu in the terminal you're already in, without the CRT:

```bash
nix run github:the-wittch/zork-nix#zork1
nix run github:the-wittch/zork-nix#zork-plain
```

The window closes when you quit the game. The plain version also has `zork1-plain`, `zork2-plain` and `zork3-plain`.

## Install

Add the flake to your inputs:

```nix
inputs.zork-nix.url = "github:the-wittch/zork-nix";
```

Then, in your NixOS configuration:

```nix
{
  imports = [ inputs.zork-nix.nixosModules.default ];
  programs.zork-nix = {
    enable = true;
    phosphor = "green";
    fullscreen = true;
  };
}
```

For Home Manager, import `inputs.zork-nix.homeModules.default` instead. Either way the app menu gets one Zork entry, which opens the menu, and you get the `zork1`, `zork2`, `zork3` and plain commands. Set `gameEntries = true` to list each game in the app menu as well.

## Saves

Each game runs in `$XDG_DATA_HOME/zork/<game>/`, usually `~/.local/share/zork/zork1/`, and frotz's `-R` keeps saving and restoring inside it. Type a name at the save prompt, or press Enter for the default.

When a game has saves, it starts with a list of them, newest first. Enter continues the newest, a number loads that save, and N starts a new game. In the game, `restore` loads a save too. The menu marks games that have a save.

## The CRT look

The look is written fresh from the flake on every launch, into cool-retro-term's own settings folder under `$XDG_STATE_HOME/zork-nix`. Your normal cool-retro-term settings are never read or changed, and changes made through its menu during a game last until the window closes.

- `phosphor`: `amber` (default), `green` or `white`.
- `fullscreen`: `true` or `false`.
- `profile`: any value from a cool-retro-term profile, by the name its profiles use:

  ```nix
  programs.zork-nix.profile = {
    screenCurvature = 0.4;
    flickering = 0;
    rasterization = 0;
    fontName = "IBM_DOS";
  };
  ```

  The defaults are in [`pkgs/crt-profile.nix`](pkgs/crt-profile.nix). A name cool-retro-term doesn't know stops the build.

Without the modules, override the package set:

```nix
(inputs.zork-nix.legacyPackages.x86_64-linux.zork.overrideScope (_: _: { phosphor = "green"; })).zork-launcher
```

## How it works

The story files are `COMPILED/zork{1,2,3}.z3` from Microsoft's [historicalsource](https://github.com/historicalsource) repos, fetched at pinned commits. Infocom compiled them, and they were on its drive when it shut down: Zork I release 119, Zork II release 63, Zork III release 25. Nothing is compiled from the ZIL source.

The interpreter is frotz, the curses build from nixpkgs, which draws the status line properly in a terminal. It carries three patches. With `-R`, frotz cut save names short when the save folder's path was short, and a long name could overflow a buffer. Loading a save at start with `-L` overran a buffer too. And when `FROTZ_NO_EXIT_PROMPT` is set, as it is in the CRT, it quits without waiting for a key.

cool-retro-term runs the menu with `-e`, and the menu replaces itself with frotz, so quitting the game closes the window. Inside the game, `XDG_DATA_HOME` points at the private settings folder. frotz doesn't use it. Each window gets its own window class, so the dock can show that game's icon.

## Development

```bash
nix flake check
nix build .#zork1
```

The checks play the opening of each game with `dfrotz`, test that saves stay in their folder and that a save loads. One starts Zork I in cool-retro-term on a virtual display, with a stand-in for frotz, to check the launch, the window class and that your settings are left alone. Others check the save list, the menu's save markers, the CRT profile, the desktop files and both modules.

## Licences

- The Zork source and story files: MIT, © 2025 Microsoft. The licence files are in `share/licenses/zork-stories/` of the `zork-stories` package. ZORK is a registered trademark; this project isn't affiliated with its owner.
- frotz: GPL-2.0-or-later. cool-retro-term: GPL-3.0.
- This flake: MIT, see [LICENSE](LICENSE).
