# Nuke (CS2)

![AI generated](../../.github/badges/ai-generated.svg)

A test conversion of Valve's `de_nuke` from Counter-Strike 2 to a Titanfall 2 map for Northstar. The
original human-built map belongs to its authors and is not included here; this
conversion was produced with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.SourceNuke` |
| Level | `mp_source_nuke` |
| Version | 0.1.0 |
| Status | Work in progress, **not released**: the source map's assets are not ours to redistribute |

## Status

It loads, 7 of 8 spawns are clear, and the yards, roofs, silo and props render with sun shadows. Collision matches the render from above and below.

Walls facing away from the sun are very dark (no bounce light). Doors, glass, decals, the chain-link fences, foliage and the distant skyline are missing. Render meshes are simplified by snapping vertices to fit the engine's index budget.

## Build and play locally

Counter-Strike 2 installed and Source2Viewer-CLI 20.1. Run `build.ps1` (see [docs/building.md](../../docs/building.md)),
copy the output's `MRVN.SourceNuke` folder into `Titanfall2/R2Northstar/mods`, then:

```text
map mp_source_nuke tdm
```

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.SourceNuke/` | Text files of the built mod: `mod.json`, level script, map name strings and entity lumps |
| `conversion.json` | Input hash, counts and what the converter skipped |
| `build.ps1` | The exact converter command for this map |
| `CHANGELOG.md` | Version history |

The generated `.map` and the compiled mod stay local because they are derived
from the original game's assets.
