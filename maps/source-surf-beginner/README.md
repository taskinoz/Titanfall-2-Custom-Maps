# Surf Beginner

| | |
| --- | --- |
| Mod | `MRVN.SourceSurfBeginner` |
| Level | `mp_source_surf_beginner` |
| Version | 0.2.0 ([changelog](CHANGELOG.md)) |
| Status | Released preview |
| Thunderstore | [taskinoz/Surf_Beginner](https://thunderstore.io/c/northstar/p/taskinoz/Surf_Beginner/) |

Original map: **surf_beginner**, a Counter-Strike: Source surf map (BSP v20).
The original author isn't confirmed. The BSP carries no author credit, and no
GameBanana listing was found. A CS2 Workshop version was uploaded by "xen", which
may be a port. Input file and checksums: [`../surf-map-sources.json`](../surf-map-sources.json).

## Play

Install `MRVN.SourceSurfBeginner` and **Surf 0.2.0 or later** into your Northstar
profile's `mods` folder, then start a local Surf match:

```text
map mp_source_surf_beginner surf
```

You spawn on the stage-1 start platform, facing the first ramp. The boost/reset
key returns you there. Leaving the platform starts a run. The course has seven
stages: each stage's end teleport moves you to the next stage, and a fail on a
later stage returns you to that stage's start without stopping the timer.
Skipping or going back a stage cancels the run. Stage 7's end doorway (into the
original's toilet end room) finishes the run.

The map ships its own loading screen and translated lobby names and descriptions
for English, French, German, Italian, Spanish, Russian, Japanese, Polish,
Portuguese, Traditional Chinese and Simplified Chinese.

## Conversion details

- `surf.json` sets the timing: the start zone is the stage-1 platform (floor
  z 320, measured in game); the six checkpoints are the original `failman2` to
  `failman7` teleport destinations; the finish zone is stage 7's end trigger
  (`*61`, padded by 32 units). Eight spawns stand on the start platform.
- Every checkpoint is the exact destination of 2–8 of the map's 40 triggers (the
  previous stage's end plus that stage's own fail floors). Only the stage-1 fail
  floor and the spawn-room entrance lead into the start zone.
- The original spawn room, its "Spawn" return teleport, the secret area and the
  toilet end room are kept.
- Lighting is baked at 32 units per luxel. Rebuild with `build.ps1`.

## Verification (2026-11-13)

- Record validation: no issues; all 115 world meshes reachable.
- `modes/surf/tests/surf_native_test.py` passed natively: fail teleports cancel,
  an early end doorway records nothing, skipping or going back a stage cancels,
  each of stages 2–7 advances once and keeps the timer through a reset, and the
  end doorway records the time.
- All seven stage starts, the spawn room and the end room have floor and pilot
  clearance (harness spawn probes).

## Known issues

- **Missing textures.** Seven Counter-Strike: Source materials aren't found,
  because CS:S isn't installed on the build machine (`cs_havana/woodm`,
  `cs_havana/white`, `cs_havana/ground01grass`, `cs_italy/black`,
  `cs_italy/stonewall02`, `de_dust/rockwall01`, `de_piranesi/marblefloor06`; about
  2,500 faces). Those faces render plain grey. Install CS:S and rebuild with
  `-Css <path>/cstrike`.
- **Dark lighting.** The map uses the dusk `sky47` sky and renders dark. Compare
  it with the original before tuning.
- **Not yet done:** a human run through all seven stages.

Released as 0.2.0 on 22 November 2026 for Northstar, with its own loading screen
and 11 localisations.
