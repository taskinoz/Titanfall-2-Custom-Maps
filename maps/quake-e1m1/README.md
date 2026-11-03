# Quake E1M1

![AI generated](../../.github/badges/ai-generated.svg)

Quake's first level, The Slipgate Complex, compiled for Titanfall 2 by
MRVN-Radiant. The original human-built level is John Romero's E1M1 for id
Software's Quake; its map source was released by John Romero in 2006 under the
GPL ([mirror](https://github.com/fzwoch/quake_map_source)). This conversion was
produced with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.QuakeE1M1Test` |
| Level | `mp_quake_e1m1` |
| Current version | 0.4.0 |
| Status | Compiler test: geometry, textures and lighting, no Quake gameplay |

## Play

Install from Thunderstore with a Northstar mod manager, or download
`MRVN.QuakeE1M1Test-<version>.zip` from the
[releases](https://github.com/taskinoz/Titanfall-2-Custom-Maps/releases) and extract
the `MRVN.QuakeE1M1Test` folder into `Titanfall2/R2Northstar/mods`. Then, in a
private match or from the console:

```text
map mp_quake_e1m1
```

`exec mrvn_quake_e1m1` does the same with cheats on for exploring. Everyone in
the match needs the same version.

## What's converted

- World geometry with LibreQuake textures (21 exact matches, 5 renamed, 38
  close substitutes; `materials.json` lists each).
- Quake's lights and a static sun, baked with one light bounce.
- A sky shell around the map, like retail maps, so death cameras and shots into
  gaps hit sky.
- 24 pilot spawns on Quake's six player starts.

Not converted: doors (left as openings), lifts, liquids, buttons, items,
monsters and Titans (disabled, as there is no navmesh). Quake's doorways are
small for a Titanfall pilot.

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.QuakeE1M1Test/` | Text files of the shipped mod, licences, `materials.json` and build verification |
| `source/e1m1-original.map` | John Romero's original map source (GPL-2.0) |
| `source/mp_quake_e1m1.map` | The adapted map the compiler reads |
| `source/test.shader` | Editor shader declarations |
| `screenshot.png` | In-game view, also used for the Thunderstore icon |
| `build.ps1` | The builder commands for this map |
| `CHANGELOG.md` | Version history |

To rebuild, see [docs/building.md](../../docs/building.md).

## Credits and licences

- E1M1: John Romero / id Software, GPL-2.0 (`COPYING`).
- Textures: [LibreQuake](https://github.com/lavenderdotpet/LibreQuake), BSD-3-Clause
  (`LICENSE-textures.txt`). No id Software textures are included.
- Compiler and packager: [MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant), GPL-2.0-or-later.
