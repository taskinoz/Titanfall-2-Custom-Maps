# Minecraft UMA and Glitch test ports

2 November 2026. Local, editable geometry ports of the user-selected worlds:

| World | Author | Input version | Selected blocks | Generated brushes | Textures |
| --- | --- | --- | ---: | ---: | ---: |
| [UMA](https://www.planetminecraft.com/project/ru-titanfall-2-uma/) | BirthdayTrain | Java 1.17.1 | 47,400 | 18,110 | 125 |
| [Glitch](https://www.planetminecraft.com/project/glitch-titanfall-2/) | Oblivering | Java 1.20.4 | 44,811 | 8,169 | 31 |

Glitch's author describes the Minecraft source as 55% complete and permits
derivatives with credit. Retain both authors' credits. These conversions are
local artifacts, not a publication or redistribution of the downloaded worlds.
Minecraft textures/models come from the official Java 1.20.6 client, SHA-1
`05b6f1c6b46a29d6ea82b4e0d42190e42402030f`, downloaded from the URL in the
user's installed launcher manifest. Minecraft assets remain Mojang/Microsoft's;
Titanfall assets remain Respawn's. Tool code is GPL-2.0-or-later.

## Outputs

Ignored `.local/respawn/minecraft-ports/{uma,glitch}-v1/` contains:

- `mp_minecraft_NAME.map`: editable classic MAP source for MRVN-Radiant.
- `assets/`: editor textures, shader declarations and native material inputs.
- `MRVN.MinecraftUma-0.1.0.zip` / `MRVN.MinecraftGlitch-0.1.0.zip`: Northstar mods.
- Matching `-source-0.1.0.zip`: MAP, editor PNG/shader assets and notes.
- Conversion, visibility-coverage, BSP-validation, budget and runtime reports.

Extract the mod folder into `Titanfall2/R2Northstar/mods`. Load locally with
`map mp_minecraft_uma tdm` or `map mp_minecraft_glitch tdm`. Both use the
installed Coliseum base pak plus their own resident texture/material RPaks.
They have four start and four respawn positions for each team, sun/ambient
baked lighting, solid brush collision and a plain sky enclosure.

## Reproduce

`tools/respawn/minecraft_world.py` reads Java palette Anvil chunks from the
world ZIP without extracting arbitrary paths. `build_minecraft_ports.py`
selects the authored build, resolves blockstate variants/multipart models,
turns nonzero model boxes into brushes, merges full cubes with identical
six-face materials, converts textures to resident DDS/RPak assets, compiles
with remap and packages the mod. Only selected overworld chunks are read.

```powershell
python tools/respawn/build_minecraft_ports.py --name glitch --world WORLD.zip --jar OFFICIAL_CLIENT.jar --output NEW_DIRECTORY --remap install/Release/remap.exe --repak PATH_TO_REPAK.exe --material-template PATH_TO_NATIVE_MATERIAL_BASE
python -m unittest discover -s tools/respawn -p test_minecraft_ports.py -v
```

The material template is a paired `_wld.json/.uber` and
`_colpass_wld.json/.uber` native TF2 world material, as used by the existing
Box Genesis builder. Pass the base path before these suffixes.

Selections are explicit inclusive Minecraft bounds, X/Y/Z:

- UMA: `(-144,16,-64)` to `(32,75,56)`, anchor `(-48,33,0)`.
- Glitch: `(-64,188,-64)` to `(180,225,48)`, anchor `(64,199,-8)`.

Glitch's elevated authored build is separated from its ground-level and
distant structure-test copies. UMA's main arena is separated from the remote
command-block setup. Coordinates transform to `(X,-Z,Y)` around each anchor,
at 48 Source units per block, allowing a 72-unit pilot under two-block doors.

## Compiler visibility correction

The first Glitch render exposed missing world geometry. The legacy SAH tree
could stop with more than 255 direct objects, then silently truncate the
serialized eight-bit reference count. Traversal of that BSP could reach only
318 of 3,591 world meshes. Collision was unaffected, so a spawn-only test
would not have detected this.

`Shared::MakeVisTree` now partitions groups larger than 255 by their median
centre before SAH. Child bounds enclose complete objects and may overlap;
every object remains owned by a child. The rebuilt maps expose all 3,591
Glitch and 9,017 UMA world meshes. The importer checks coverage by traversing
serialized nodes, not merely by checking lump sizes. Regression tests include
truncated-count detection and bounded child groups. Existing compiler
regressions across Titanfall Online, TF2 and Apex pass after the change.

## Runtime checks

Both corrected BSPs loaded in the installed Titanfall 2 build 6968 through
Northstar in an isolated profile. Client and server reached ready state with
one local pilot. Each map's eight sites passed native floor traces and
32-by-32-by-72 pilot hull-clearance tests. Native start-spawn selection chose
the matching team for both IMC and Militia. In-engine screenshots were
inspected after the visibility correction. These are load/render/spawn smoke
tests, not full traversal, wallrunning, competitive balancing or network tests.

Nine focused importer tests and all 14 existing compiler-regression entries
passed. Corrected Glitch uses 190,662 world indices, UMA 350,028, respectively
6.06% and 11.13% of the locally audited engine's 3,145,728 index capacity.

## Scope and approximations

These are pilot-only local test ports. No navmesh, Titans, AI, hardpoints,
CTF positions, audio layout, minimap artwork or multiplayer balancing pass.
Minecraft commands/redstone and moving mechanisms are not translated.
Glass and leaves have opaque alpha backing; textures use their first animation
frame. Per-face model UV rotations/subrectangles use approximate world tiling.
Model-element rotations use unrotated bounds. Plants, signs/banners and
zero-thickness elements are omitted; state types are recorded in each report.
UMA's white-glass upper containment shell becomes sky.

The supplied converters were inspected for workflow ideas:
[minecraft-to-vmf](https://github.com/potato1234x/minecraft-to-vmf),
[Sourcecraft](https://github.com/Garten/sourcecraft), and
[mca2vmf](https://github.com/gramx/mca2vmf). They target VMF/Source rather than
native TF2 materials and packaging. The Python converter explicitly lacks
brush optimization. No converter implementation was copied into this importer.
