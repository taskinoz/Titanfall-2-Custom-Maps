# Converting a map for Titanfall 2

How to turn a Minecraft world, a Source map (Team Fortress 2, Half-Life 2,
Counter-Strike: Source and similar) or a Counter-Strike 2 map into a playable
Northstar map with the [MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant)
converters. [building.md](building.md) lists the toolchain versions and how to
rebuild the maps already in this repository; [releasing.md](releasing.md) covers
publishing.

Every converter does the same three things: it reads the original map, writes an
editable `.map` plus textures and materials, then compiles that with `remap` and
packages a Northstar mod (BSP, entity files, texture RPak, VPK and a player ZIP).
Conversions are pilot-only: there is no navmesh, so Titans and AI don't work.

## Before you start

- **Permission.** Check the original map's licence or ask its author. Keep their
  credit in the map's README, and add the map to [AI.md](../AI.md).
- **MRVN-Radiant** on the `respawn-format-research` branch, with `remap` built
  (`install/Release/remap.exe`).
- **Python 3.10+** with NumPy and Pillow.
- **RePak** built from r-ex/RePak `adc52f7`. Older RePak builds crash with an
  access violation on these manifests.
- **A native Titanfall 2 world material** to clone, passed as
  `--material-template` (the base path of a `_wld` and `_colpass_wld`
  `.json`/`.uber` pair). MRVN-Radiant's `build_box_genesis.py` writes one at
  `assets/material/world/box_genesis/white`.
- **Titanfall 2 with Northstar** for testing.

Run the converters from the MRVN-Radiant checkout (or set `PYTHONPATH` to its
`tools/respawn`). Each writes to an `--output` folder that must not exist yet.

## Minecraft worlds

Converter: `tools/respawn/build_minecraft_ports.py`. One block becomes 48 units.

### 1. Get the world

Download the world ZIP from the map's page yourself. Planet Minecraft sits
behind a browser check, so scripts can't fetch it. You also need the official
**Minecraft Java 1.20.6 client JAR**, which provides block models and textures;
it is listed in your launcher's version manifest.

**Old worlds.** The converter reads worlds saved by Minecraft 1.13 or later. If
it stops with "world saved before Minecraft 1.13", upgrade the ZIP first with
Mojang's own upgrader. This runs the official 1.20.6 server once with
`--forceUpgrade` and needs Java 21 or later:

```powershell
python tools/respawn/upgrade_minecraft_world.py --world old.zip --output upgraded.zip `
    --java "C:\Program Files\Java\jdk-26.0.1\bin\java.exe" --accept-eula
```

`--accept-eula` accepts the [Minecraft EULA](https://aka.ms/MinecraftEULA) for
that server run. Worlds older than 1.2 (`.mcr` region files) must first be
opened and saved in Minecraft 1.2 to 1.12.

### 2. First build: let the converter find the map

```powershell
python tools/respawn/build_minecraft_ports.py --name survival_games `
    --world survival_games.zip --jar 1.20.6.jar --output out/survival_games `
    --remap install/Release/remap.exe --repak repak.exe `
    --material-template assets/material/world/box_genesis/white `
    --display-name "Survival Games (Minecraft)" --author "Author" --source-url "https://..."
```

`--name` becomes the level `mp_minecraft_<name>` and the mod
`MRVN.Minecraft<Name>`. Without `--bounds`, `--anchor` and `--spawns`, the
converter finds the largest build in the world and prints what it picked:

- **bounds:** the block box to convert;
- **anchor:** the map origin, whose Y is the floor spawns stand on;
- **spawn areas:** the centre of each team's spawn area;
- **invisible glass roofs.**

Check these in game, then pin them on later builds:

| Option | Use |
| --- | --- |
| `--bounds X1 Y1 Z1 X2 Y2 Z2` | Block box to convert |
| `--anchor X Y Z` | Map origin; Y is the main floor |
| `--spawns X1 Z1 X2 Z2` | Centre of each team's spawn area |
| `--kill-z Z` | World Z below which pilots die (pits, the void) |
| `--invisible-block NAME[:MIN_Y]` | Block type to make invisible but solid, e.g. a glass roof; barrier blocks always are |
| `--iron-bar-ziplines` | Iron bar lines become ziplines |
| `--spawn-open-sky` | Only spawn under open sky |
| `--fill-floor-notches` | Complete the main floor's rectangle where edge pieces are missing |
| `--mesh-cluster N` | World units per render mesh cluster |
| `--view-portals` | Experimental visibility culling; fails on very blocky maps |

Once settled, add the map to `PRESETS` in `build_minecraft_ports.py` so a plain
`--name` rebuild reproduces it.

### 3. Loading screen

Build once, take a 1920x1080 screenshot in game (`impulse 200` hides the weapon,
`cl_drawhud 0` the HUD), save it as the map's `loadscreen.png`, and build again
with `--loadscreen loadscreen.png --loadscreen-template <retail _widescreen_gen base path>`.

### What converts

Full and shaped blocks follow their Java block models. Glass and leaves are
composited onto an opaque backing, torches become baked lights, and the build is
enclosed by an invisible roof and walls. Plants, signs, redstone, commands, chests
and moving parts are left out.

## Source maps (Source 1)

Converter: `tools/respawn/build_source_ports.py`, for compiled `.bsp` files from
Team Fortress 2, Half-Life 2, Counter-Strike: Source, Garry's Mod and similar.

### Inputs

- **The `.bsp`.** Content packed into the map is read from its pakfile.
- **One `--game-dir` per game the map uses**, e.g. TF2's `tf` folder and HL2's
  `hl2` folder. The converter reads loose files and the folder's `*_dir.vpk`
  archives. **The game must be installed**: a TF2 map converted without TF2
  installed loses every stock TF2 model and texture. Jump Academy 2 lost 1,557 of
  its 2,194 prop instances and showed grey surfaces this way.

```powershell
python tools/respawn/build_source_ports.py --bsp jump_academy2_rc9.bsp `
    --game-dir "...\Team Fortress 2\tf" --game-dir "...\Half-Life 2\hl2" `
    --name academy2 --display-name "Jump Academy 2 (TF2)" --output out/academy2 `
    --remap install/Release/remap.exe --repak repak.exe --material-template <template>
```

| Option | Use |
| --- | --- |
| `--spawns X1 Y1 X2 Y2` | Centre of each team's spawn area, in Source units |
| `--kill-z Z` | World Z below which pilots die |
| `--luxel-size N` | World units per lightmap texel to start from; large maps raise it automatically |
| `--mesh-cluster N` | World units per render mesh cluster |
| `--no-props` | Leave static props out |

### What converts

| Source | Titanfall 2 |
| --- | --- |
| World brushes, `func_detail`, `func_brush`, `func_wall`, `func_lod` (unrotated) | Brushes with collision |
| `func_illusionary` | Render-only geometry from its compiled faces, no collision |
| Non-solid world brushes (contents 0) | Render-only brushes |
| Player clip | Invisible player clip |
| Displacements | Patches, with a coarser invisible collision copy |
| Static props | Render meshes, plus collision from their physics hulls |
| Lights, `light_environment` | Baked lights and sun |
| `trigger_teleport` | Teleports |
| 3D skybox, sky faces | A sky dome |

**Not converted:** doors and other moving brushes, triggers (other than
teleports), water, clear glass (kept solid but invisible), and cutout or
translucent materials such as fences and foliage cards (there is no alpha-test
material template yet).

### Check the report

`conversion.json` in the output lists what was skipped and why. Look at:

- **`missing_materials`:** textures that were not found render grey. Usually a
  `--game-dir` is missing or the game isn't installed.
- **`skipped` → `unreadable model`:** props whose model was not found.
- **`skipped` → `contents …` and entity classes:** brushes left out.

To find missing surfaces, compare the original's visible faces with the
compiled render geometry:

```powershell
python tools/respawn/source_coverage.py jump_academy2_rc9.bsp out/academy2/mp_source_academy2.bsp
```

It prints the share of visible area with no converted geometry, by owner (world,
`func_illusionary`, ...) and by material. Water and clear glass are expected to
appear. On Jump Academy 2 they are all that remains, but the map builds many of its
walls from translucent glass (`cyanglass`, `combineglass`). Until a translucent
material template exists, those walls are solid but invisible.

## Counter-Strike 2 maps (Source 2)

Converter: `tools/respawn/build_source2_ports.py`. It runs
[Source2Viewer-CLI](https://github.com/ValveResourceFormat/ValveResourceFormat)
(release 20.1) once to export the world as glTF with textures, the physics and the
entities into `--export`, and reuses that export on later builds.

```powershell
python tools/respawn/build_source2_ports.py --vpk "...\game\csgo\maps\de_nuke.vpk" `
    --vrf Source2Viewer-CLI.exe --gameinfo "...\game\csgo\gameinfo.gi" --export out/nuke-export `
    --name nuke --display-name "Nuke (CS2)" --output out/nuke `
    --remap install/Release/remap.exe --repak repak.exe --material-template <template>
```

| Option | Use |
| --- | --- |
| `--triangle-budget N` | Render triangles to simplify to (default 950,000) |
| `--collision all\|hulls\|none` | Physics meshes and hulls, hulls only, or none |
| `--entity-models` | Also render entity models (doors, breakables, game-mode blockers); they get no collision |

What it does:

- **Simplification:** render meshes are simplified to the budget by snapping
  vertices to a grid, within each mesh, so decals and trim stay on the surfaces
  they sit on.
- **Collision:** comes from the map's physics. Only player-blocking hulls and
  meshes are kept.
- **Entity models:** doors, breakable windows and vents, Retakes blockers and
  loose props are left out by default, because their collision is not in the
  world physics. Kept, they would block doorways visually while letting players
  walk through.
- **Sky:** the `env_sky` panorama is exported from `pak01_dir.vpk` next to
  `gameinfo.gi` and mapped onto the sky dome. Without it the sky is the sun's
  flat sky colour.
- **Not converted:** cutout and blended materials (fences, foliage, decals) are
  skipped, as are normal maps.

## Test in Northstar

Copy the mod folder from the output into `Titanfall2/R2Northstar/mods` (delete
any older copy first), start a private match and run `map mp_<level> tdm`. Check:

- the map loads with no script errors in `R2Northstar/logs`;
- every spawn has floor and room (`spawns.json` lists them);
- camera sweeps at 90 and 110 degrees field of view show no holes or vanishing
  sections;
- in third person (`sv_cheats 1`, `thirdperson`), pilots are lit like their
  surroundings rather than black;
- collision matches what you see: walk into walls, props and doorways;
- the loading screen and map name show correctly.

For repeatable comparisons between builds, the `MapTest.Harness` mod (installed
in a separate `R2MapHarness` Northstar profile) can be driven over local HTTP to
load a map, place cameras and capture the same views from two builds. Diff the
captures: differences confined to the HUD mean the world is unchanged.

## Release

Follow [releasing.md](releasing.md): copy the mod's text files and the `.map`
into `maps/<map>/`, write the README (with the original author's credit) and
CHANGELOG, add the map to the catalog, tag and publish.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| RePak exits with an access violation | Old RePak build; use r-ex/RePak `adc52f7` |
| `remap.exe` can't be rebuilt (`LNK1104`) | A converter is still running and holds it open |
| Grey surfaces, `missing_materials` in the report | Game content not found: add `--game-dir` or install the game |
| Props missing, `unreadable model` in the report | Same as above, for models |
| "world saved before Minecraft 1.13" | Run `upgrade_minecraft_world.py` |
| "Collision brush exceeds 255 non-axial sides" warning | Extra bevels on a very complex brush were dropped; harmless |
| Pilots black in shaded areas | Old build: rebuild with MRVN-Radiant from 6 November 2026 or later (light probes where players stand) |
