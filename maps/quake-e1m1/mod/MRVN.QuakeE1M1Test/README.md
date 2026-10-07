# Experimental Northstar E1M1 test

This is a geometry/compiler test, **not a verified playable Quake port**. The BSP
has selected format validation and independently verified VPK bytes. Engine
loading, rendering and collision have not yet been tested. The compiler still
emits placeholder lighting and other incomplete structures; loading can fail or
crash. No navigation mesh or Quake gameplay is included.

## Installation and testing

Copy the entire `MRVN.QuakeE1M1Test` folder into `Titanfall2/R2Northstar/mods`, then
restart Northstar. Enable `MRVN.QuakeE1M1Test` in the Mods menu if necessary.
This adds `mp_quake_e1m1`; it does not replace the retail Coliseum BSP. Use a local
test session. Other clients would need the same mod to join this map.

Open the developer console (launch Northstar with `-console` if needed), then run:

```text
exec mrvn_quake_e1m1
```

The configuration enables cheats for the test session, selects Pilot vs Pilot
(`tdm`) and issues `map mp_quake_e1m1`. Custom-map startup through this command
is experimental and needs an engine test. If the loading screen completes, use
`noclip` to inspect geometry; Quake doorways are much smaller than Titanfall's
pilot hull. `mat_fullbright 1` may help inspect the placeholder lighting if the
engine exposes that debug setting. Unsupported commands can simply be omitted.

All original Quake entity behavior is removed. Brush entities are folded into
static world geometry; doors, elevators, water and triggers do not retain their
Quake behavior. Twenty-four pilot spawn entities use the six source spawn
locations for both teams and both initial/respawn classes. Geometry uses the
installed Coliseum `world/dev/dev_gray_512` material instead of Quake textures.
An RPAK alias requests the installed Coliseum assets; no Respawn assets are
redistributed. The custom level script does not run Coliseum's arena setup.

If loading fails, preserve the newest `R2Northstar/logs` log and any crash report.
Check for `MRVN.QuakeE1M1Test`, `mp_quake_e1m1`, VPK mount errors, RPAK errors,
script compile errors and the message `MRVN E1M1 experimental geometry test loaded`.
Note whether the failure happens before map loading, while loading, or after
spawning. This distinguishes packaging issues from remaining BSP format defects.

To remove the test, disable the mod and restart Northstar, or move its folder out
of `R2Northstar/mods` while the game is closed.

## Sources and licenses

- Quake E1M1 / The Slipgate Complex: id Software, map by John Romero; source
  released by John Romero in October 2006. Retrieved from
  [fzwoch/quake_map_source](https://github.com/fzwoch/quake_map_source/tree/27abebaa3886bb0e3156cce3a604673d22b243f8),
  commit `27abebaa3886bb0e3156cce3a604673d22b243f8`. GPL-2.0; `COPYING`, original
  source and adapted MAP source are included. No Quake WAD images are included.
- Compiler: MRVN-Radiant / remap, including its NetRadiant lineage and Respawn
  format research attribution in `docs/RESPAWN_SOURCES.md` in the project.
- VPK layout and independent verification:
  [pg9182/tf2vpk](https://github.com/pg9182/tf2vpk/tree/b73c54d8e4245075ea207c7e51a2a86fdb94e4ff),
  commit `b73c54d8e4245075ea207c7e51a2a86fdb94e4ff` (MIT). The package writer is
  original MRVN-Radiant GPL-2.0-or-later code; tf2vpk is not bundled.
- Mod structure, VPK mounting and RPAK alias behavior:
  [Northstar documentation](https://docs.northstar.tf/Modding/guides/gettingstarted/),
  [RPAK documentation](https://docs.northstar.tf/Modding/guides/tools/rpakmodding/),
  [NorthstarLauncher mod manager](https://github.com/R2Northstar/NorthstarLauncher/blob/main/primedev/mods/modmanager.cpp).
  No Northstar code is copied into the test script. Checked against the local
  Northstar 1.31.13 installation; no script VM or engine validation was performed.

## Rebuilding in MRVN-Radiant

Run from the repository root, choosing a new output directory each time:

```powershell
python tools/respawn/build_northstar_test_mod.py --map .local/respawn/map-trials/e1m1-tf2/e1m1.map --copying .local/respawn/map-trials/e1m1-tf2/COPYING --remap install/Release/remap.exe --tf2vpk .local/respawn/tf2vpk.exe --output .local/respawn/northstar-e1m1
```

The output includes the mod, ZIP, adapted source, compiler log, BSP validation,
member SHA-256 hashes and independent VPK CRC/readback verification. Dependencies
and game assets stay outside the distributable mod. The included adapted MAP and
the compiler/package scripts in the MRVN-Radiant repository provide its source.
