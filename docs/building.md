# Building a map

The converters and the map compiler live in the
[MRVN-Radiant fork](https://github.com/taskinoz/MRVN-Radiant), under
`tools/respawn/` and `tools/remap/`. This repository holds what is specific to each
map: its recipe (`build.ps1`), the shipped mod's text files and, for released maps,
the editable `.map`.

## Toolchain

| Tool | Version | Used for |
| --- | --- | --- |
| [MRVN-Radiant fork](https://github.com/taskinoz/MRVN-Radiant) (`respawn-format-research` branch) | as of 2026-11-06 | Converters, `remap` compiler, VPK and STBSP writers |
| Python | 3.10 or later, with Pillow and NumPy | Converters |
| [RePak](https://github.com/r-ex/RePak) | commit `adc52f7` | Texture and material RPaks |
| [tf2vpk](https://github.com/pg9182/tf2vpk) | commit `b73c54d` | Quake only: independent VPK check |
| [Source2Viewer-CLI](https://github.com/ValveResourceFormat/ValveResourceFormat) | 20.1 | Nuke only: CS2 map export |
| Titanfall 2 with Northstar | Northstar 1.31.13 or later | Testing; Coliseum's paks are aliased at runtime |

Build `remap` in the MRVN-Radiant checkout first, so `install/Release/remap.exe`
exists (see that repository's README). The recipes call
`<MRVN>/tools/respawn/*.py` and `<MRVN>/install/Release/remap.exe`.

`-MaterialTemplate` is the base path of a native Titanfall 2 world material: a
`_wld.json`/`.uber` and `_colpass_wld.json`/`.uber` pair. The converters clone it
for every texture. MRVN-Radiant's `build_box_genesis.py` writes a suitable one
(`assets/material/world/box_genesis/white`).

## Inputs

Original maps and game files are not in this repository. Download or point at
your own copies:

| Map | Inputs |
| --- | --- |
| UMA, Glitch | The world ZIP from the map's Planet Minecraft page; the official Minecraft Java 1.20.6 client JAR (from your launcher's version manifest) |
| Quake E1M1 | Nothing extra: `source/e1m1-original.map` is the GPL map. A [LibreQuake](https://github.com/lavenderdotpet/LibreQuake) checkout for textures, and a decompressed copy of your `mp_coliseum.rpak` and `mp_coliseum_env.ent` as templates |
| Jump Academy 2 | `jump_academy2_rc9.bsp`; Team Fortress 2 and Half-Life 2 installed |
| Nuke | Counter-Strike 2 installed |
| Trainstation | Half-Life 2 installed |

## Rebuild

From this repository, for example:

```powershell
./maps/minecraft-glitch/build.ps1 -Mrvn C:\path\to\MRVN-Radiant `
    -World C:\downloads\glitch.zip -Jar C:\path\to\1.20.6.jar `
    -Repak C:\path\to\repak.exe -MaterialTemplate C:\path\to\box_genesis\white `
    -LoadscreenTemplate C:\path\to\loadscreen_gen
```

The output goes to `output/<map>/` (ignored by Git). It contains the mod folder,
a player ZIP, the editable `.map` and editor textures, and the converter's reports:
`conversion.json`, `validation.json`, `spawns.json` and `visibility-coverage.json`.

The Minecraft loading screen is a second pass: build once, take a 1920x1080 shot
in game (`impulse 200` hides the weapon, `cl_drawhud 0` the HUD), save it as the
map's `loadscreen.png`, then build again with `-LoadscreenTemplate` (the base path
of a retail `_widescreen_gen` material `.json`/`.uber` pair).

## Editing a map

Open `source/<level>.map` in MRVN-Radiant with the game set to Titanfall 2, and use
the build output folder (or the extracted release source ZIP) as the base path so
the editor finds the textures. The converters regenerate the `.map` on every
build, so hand edits are lost if you rebuild from the original world. To keep
them, compile the edited `.map` directly with `remap` and package it with the
converter's packaging step.

## Testing

Copy the built mod folder into `Titanfall2/R2Northstar/mods`, start a private
match and run the map's command. Before releasing, check at least:

- the map loads with no script errors in `R2Northstar/logs`;
- every spawn has floor and room (the converters write `spawns.json`);
- camera sweeps at 90 and 110 degrees field of view show no holes or vanishing
  sections;
- the loading screen and map name show correctly.
