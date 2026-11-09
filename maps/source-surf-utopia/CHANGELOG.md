# Surf Utopia changelog

## 0.1.3 - 2026-11-09

- Repaired the jail exit threshold left exposed by the omitted rotating door, preserving the original paving and red stripes.
- Improved baked shadows with one indirect bounce, 256 sky samples, a diffuse sky visibility floor and 32-unit lightmap texels.
- Swept teleport checks catch thin reset floors, with compiled bevel planes and a small contact tolerance.
- Retained the ramp screenshot package image.
- Verified the reported jail view and collision/clearance across all five repaired floor bands in the Northstar client.

## 0.1.2 - 2026-11-09

- Corrected the package image to the supplied ramp screenshot.
- Map assets and gameplay scripts are unchanged.

## 0.1.1 - 2026-11-09

- Thunderstore image updated to the latest END-platform screenshot.
- Map assets and gameplay scripts are unchanged from 0.1.0.

## 0.1.0 (2026-11-07, unreleased)

First test conversion, of the Team Fortress 2 build of `surf_utopia_v3`.

- Loading screen of its own (an in-game capture) and a map description in the lobby and loading screen.
- Surfing works: on ramps steeper than Source's walkable limit (45.6°) pilots are crouched with no ground friction. Standing, Titanfall treats a 52° ramp as ground and stops a pilot within half a second; crouched, it doesn't, and pilots keep their speed along the ramp and slide down it as in Source.
- Teleport triggers use their real shapes: many are thin slabs along slopes, and testing their
  bounding boxes sent pilots to jail while still riding the next ramp.
- Ramp bugs at brush seams are left in, as in Counter-Strike (the converter's `--rampbug-fix` undoes them).
- Works with the new Surf mode ([modes/surf](../../modes/surf)): the map tells the mode where its start
  room is and reports teleports, so runs are timed.
- Rising ramps launch you upward as in Source: Titanfall carried pilots up a ramp without giving
  them the upward speed, so they dropped onto the jail slope after the curved second ramp.
- The sky no longer cuts through the ramps near the map's corners.
- On ramps, auto-mantle and slide boosts are cancelled (they pushed pilots forward on the curved
  second ramp); each cancel is logged as `[surf]` in the Northstar log.
- Falling off a stage sends you to the jail, to a random cell as in the original (its `logic_case` picks one of eight); the other teleports go to their fixed destinations.
- The six `trigger_push` boosters and jail lifts push pilots by script.
- Spawns are the map's Counter-Strike team spawns, in the start room.
- Not converted: the jail's doors, buttons, crate traps and explosions (the cells are open), and the spinning `func_rotating` fans.

- Surf timing now ends on landing on the final platform assembly (both decks and
  the lower deck's roof), rather than waiting for a return teleport. Flying past
  the platform does not finish; reset portals cancel unfinished runs.

- End teleports also finish and submit active runs, including end portals leading
  to the jail. Their pre-teleport position distinguishes them from other resets;
  a run already finished on landing cannot be submitted twice.

- Added the upper END platform and its jail-control-room portal to the finish
  zones. The existing two lower platforms and their portals remain finish zones.
