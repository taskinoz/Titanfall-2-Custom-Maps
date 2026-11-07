# Surf Utopia changelog

## 0.1.0 (2026-11-07, unreleased)

First test conversion, of the Team Fortress 2 build of `surf_utopia_v3`.

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
