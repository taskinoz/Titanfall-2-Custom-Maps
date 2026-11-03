# Trainstation (HL2)

![AI generated](../../.github/badges/ai-generated.svg)

A test conversion of Valve's `d1_trainstation_02` from Half-Life 2 to a Titanfall 2 map for Northstar. The
original human-built map belongs to its authors and is not included here; this
conversion was produced with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.SourceTrainstation02` |
| Level | `mp_source_trainstation02` |
| Version | 0.1.0 |
| Status | Work in progress, **not released**: the source map's assets are not ours to redistribute |

## Status

All 8 spawns are clear and the static props render and collide.

Dynamic and physics props, foliage, wires, the 3D skybox, water, doors, decals and normal maps are not converted.

## Build and play locally

Half-Life 2 installed. Run `build.ps1` (see [docs/building.md](../../docs/building.md)),
copy the output's `MRVN.SourceTrainstation02` folder into `Titanfall2/R2Northstar/mods`, then:

```text
map mp_source_trainstation02 tdm
```

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.SourceTrainstation02/` | Text files of the built mod: `mod.json`, level script, map name strings and entity lumps |
| `conversion.json` | Input hash, counts and what the converter skipped |
| `build.ps1` | The exact converter command for this map |
| `CHANGELOG.md` | Version history |

The generated `.map` and the compiled mod stay local because they are derived
from the original game's assets.
