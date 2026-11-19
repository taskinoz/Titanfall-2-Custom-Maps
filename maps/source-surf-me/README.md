# Surf Me

![AI generated](../../.github/badges/ai-generated.svg)

| | |
| --- | --- |
| Mod | `MRVN.SourceSurfMe` |
| Level | `mp_source_surf_me` |
| Version | 0.1.1 ([changelog](CHANGELOG.md)) |
| Status | Released preview |
| Thunderstore | [taskinoz/Surf_Me](https://thunderstore.io/c/northstar/p/taskinoz/Surf_Me/) |

Original map: **surf_me**, by **not_a_zombie**. Bonus 1 by Xtra_Festive;
bonus 2 by Malt; bonuses 3 and 4 by not_a_zombie.
Original author page: https://gamebanana.com/mods/122524

This converts the original Source 1 map, not a CS2 Workshop remake. The BSP matches
the author's `surf_me_3.zip` archive, MD5 `3c1a51e6ad92033f6838ac9746c92402`.
BSP SHA-256: `0c871708f167cf073210ddc1ea5dc68bf5e03f887f61c9fdfef47b742dec374f`.

## Play

Install `MRVN.SourceSurfMe` and **Surf 0.2.0 or later** into your Northstar
profile's `mods` folder. Surf 0.1.0 cancels runs on stage transitions.

Start a local Surf match and run:

```text
map mp_source_surf_me surf
```

You spawn at stage 1, facing the course. The boost/reset button returns you there.
Leaving its original start trigger begins a full-course run. Stage transitions
advance through stages 2, 3, 4 and 5 in order. Failing a later stage resets that
stage but retains elapsed time. Returning to stage 1 cancels the run. Skipping a
checkpoint or going backwards invalidates the active run. Landing on the final
platform or entering its return portal finishes only after all four transitions.
Finished runs use the existing local-save and web-submission paths.

## Conversion details

- Explicit start and finish zones come from the original `stage1_start` and
  `stage5_end` brushes. Stage destinations come from `tele2` through `tele5`.
- `surf.json` carries the timing zones, eight spawn positions and stage order.
- One original reset trigger names the nonexistent `InstanceAuto11-tele4`.
  Its conversion explicitly redirects it to `tele5`, the start of its stage-5 area.
- All 47 teleport triggers are exported after that repair.
- Base materials come from the map's embedded pak, Counter-Strike: Source,
  Team Fortress 2 and Half-Life 2. Rebuild with `build.ps1`.

## Preview limitations

The main five-stage timed course is the target of this build. Bonus areas are
converted geometrically but have no separate bonus timers or leaderboard categories.
Original player-targetname filters and arbitrary entity outputs are not emulated;
bonus gating can therefore differ. Animated flames, smoke particles, overlays,
normal maps and water volumes are not reproduced. The map has its own loading
screen (`loadscreen.png`, captured in game from the stage-1 corridor).

Released as 0.1.0 on 18 November 2026 after a play-through in the Northstar
client. Wall tops that can be stood on in the original can be stood on here too.

## Lighting and reset fixes (2026-11-09)

The two-unit courtyard reset floors are checked against the pilot's swept hull,
including a 0.25-unit contact tolerance. This catches high-speed falls between
50 ms polls and feet resting just above a floor's collision epsilon. A cheap
bounding-box rejection keeps the sweep affordable on Utopia's many portals.
The actual client/player test set downward velocity to 9,000 units/s at both courtyard locations
and returned to stage 1. A Surf Me -> Utopia switch also passed without script errors.

Source point/spot lights retain their inverse attenuation coefficients instead
of using a broad polynomial fade. Torch light no longer floods the whole room.
The bake uses one indirect bounce, 256 sky samples and a 20% minimum diffuse sky
visibility. Direct sun shadows are preserved. Surf Me uses 48-unit lightmap texels;
the accompanying Utopia lighting preview uses 32-unit texels.

These fixes were first tested in the local `R2SurfMeTest` profile.

Every map teleport now writes `[surf] teleport <from> -> <to> trigger N brush B
touch ... v ...`, and the Surf mode writes `[surf] teleport ... checkpoint=...
running=... current=...` plus `[surf] run cancelled for ... at ...`. When a
stage resets unexpectedly, those lines identify the trigger and destination
that fired without needing in-game coordinates.

## Rebuild and native checks (2026-11-13)

The copies of this map in the local preview profile and in the earlier build
folders had been truncated to zero bytes (BSP, RPak and VPKs shared hard links).
The map was rebuilt with the current converter, which includes the
trigger-transform fix (MRVN-Radiant `184ddec`). The level script in this folder now
matches that build. Record validation found no issues, and all 688 world meshes
are reachable.

`modes/surf/tests/surf_native_test.py` passed natively on this build: fail
teleports cancel, an early end portal records nothing, skipping or going back a
stage cancels, each of stages 2–5 advances once and keeps the timer through a
reset, and the end portal then records the time. Two spawn probes have floor and
pilot clearance. A full human run is still needed before release.
