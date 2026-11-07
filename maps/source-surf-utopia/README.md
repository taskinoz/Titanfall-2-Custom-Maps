# Surf Utopia

![AI generated](../../.github/badges/ai-generated.svg)

A test conversion of `surf_utopia_v3`, a classic Counter-Strike surf map, to a
Titanfall 2 map for Northstar. The source is its Team Fortress 2 build, as served by
community map servers ([fastdl.me](https://main.fastdl.me/maps/surf_utopia_v3.bsp.bz2)).
The original human-built map belongs to its authors (the in-map credits; not
confirmed) and is not included here; this conversion was produced with AI (see
[AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.SourceSurfUtopia` |
| Level | `mp_source_surf_utopia` |
| Version | 0.1.0 |
| Status | Work in progress, **not released**: the source map's assets are not ours to redistribute |

## Surfing in Titanfall 2

Source players surf because a ramp steeper than 45.6° is not ground: they slide
along it without friction and steer with air strafing. Standing, Titanfall 2 treats
a 52° ramp as ground, and ground movement stops a pilot in half a second. Crouched,
it doesn't. The level script therefore crouches pilots, with no ground friction,
while they are on any surface steeper than Source's limit, and lets them stand a
quarter second after they leave it. Tested in Northstar: pushed along the longest
ramp, a pilot kept a steady ~700 units/s along it while sliding down it.

Wallrunning, double jumps and grapples still work, so some stages can be skipped.

## Status

- All materials are packed in the map (TF2 textures and the Dustbowl sky) except one HL2
  water texture; all six ramp and credits props convert, with collision.
- Falling sends you to the jail, a random cell of eight as in the original. The
  jail's doors, buttons, crate traps and explosions are not converted, so the
  cells are open.
- Boosters (`trigger_push`) work by script. The spinning fans don't spin.

## Build and play locally

The BSP, plus Half-Life 2 installed for its water texture. Run `build.ps1` (see
[docs/building.md](../../docs/building.md)), copy the output's `MRVN.SourceSurfUtopia`
folder into `Titanfall2/R2Northstar/mods`, then:

```text
map mp_source_surf_utopia tdm
```

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.SourceSurfUtopia/` | Text files of the built mod: `mod.json`, level script, map name strings and entity lumps |
| `conversion.json` | Input hash, counts and what the converter skipped |
| `build.ps1` | The exact converter command for this map |
| `CHANGELOG.md` | Version history |

The generated `.map` and the compiled mod stay local because they are derived
from the original map's assets.
