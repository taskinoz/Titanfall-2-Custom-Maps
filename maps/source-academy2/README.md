# Jump Academy 2 (TF2)

![AI generated](../../.github/badges/ai-generated.svg)

A test conversion of the Team Fortress 2 rocket-jump training map `jump_academy2_rc9`, a community map distributed by the Tempus jump servers ([download](https://static.tempus2.xyz/tempus/server/maps/jump_academy2_rc9.bsp.bz2)) to a Titanfall 2 map for Northstar. The
original human-built map belongs to its authors and is not included here; this
conversion was produced with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.SourceAcademy2` |
| Level | `mp_source_academy2` |
| Version | 0.1.0 |
| Status | Work in progress, **not released**: the source map's assets are not ours to redistribute |

## Status

Both spawns and the teleport destinations have floor, 13 of 13 sampled displacements collide at their surface, teleports work, and the course doors show their labels.

152 of 356 textures come from TF2 itself and are grey unless TF2 is installed when building. Dynamic and physics props, foliage, wires, the 3D skybox, water, doors, decals and normal maps are not converted.

## Build and play locally

The BSP, plus Team Fortress 2 and Half-Life 2 installed for stock textures and props. Run `build.ps1` (see [docs/building.md](../../docs/building.md)),
copy the output's `MRVN.SourceAcademy2` folder into `Titanfall2/R2Northstar/mods`, then:

```text
map mp_source_academy2 tdm
```

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.SourceAcademy2/` | Text files of the built mod: `mod.json`, level script, map name strings and entity lumps |
| `conversion.json` | Input hash, counts and what the converter skipped |
| `build.ps1` | The exact converter command for this map |
| `CHANGELOG.md` | Version history |

The generated `.map` and the compiled mod stay local because they are derived
from the original game's assets.
