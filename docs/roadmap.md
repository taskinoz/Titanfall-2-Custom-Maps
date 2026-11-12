# Map development roadmap

Status as of 12 November 2026. This covers the maps in this repository, the Surf
mode, and the converter, compiler and testing work they depend on in
[MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant) and
[ARES](https://github.com/taskinoz/ARES). Update it when an item ships or changes.

## Where things stand

| Area | State |
| --- | --- |
| Surf Utopia | Released, 0.1.3. Runs on the public `Titanfall Surf` dedicated server with web leaderboard submissions |
| Surf mode | Released, 0.1.0. Checkpoint (staged-map) support exists only as uncommitted development code |
| Surf Me | Local preview: compiles, loads, five-stage timer passes native tests. No full human run yet; not released |
| surf_beginner, surf_kitsune, surf_cyberwave | Source BSPs downloaded and checksummed; not converted |
| Other Source ports (Nuke, Academy, Trainstation) | Local only; Valve assets mean they aren't released |
| Minecraft and Quake ports | Released |
| Leaderboard site | Search, map filter and global rank are live at titanfall.rocks/surf, with four public Surf Utopia runs |
| Testing | ARES map harness (PR #2) runs maps and mods in Northstar, TFO, R1Delta and R5Reloaded unattended |
| Titanfall 1 / TFO | Compiled v29 maps load in TFO and R1Delta; collision matches TFO; lighting, water and packaging incomplete (Phase 2) |
| Apex / R5Reloaded | Season 3 only: a TF2 → Apex port loads on the dedicated server; the client crashes on sign-on; S0–S2 untested (Phase 3) |

## Goals

1. **A small, finished surf collection.** Utopia, Me and Beginner released and
   playable end to end, each with a timed course, working resets and a leaderboard
   category. Kitsune and Cyberwave follow if their mechanics convert cleanly.
2. **A dependable public server.** Map rotation through the collection, no crashes
   when players leave, and runs recorded on the live leaderboard.
3. **Repeatable conversions.** A new Source surf map goes from BSP to a playable
   preview with one recipe and no hand-written fixes, except for repairs that are
   recorded in that map's `conversion.json`.
4. **Evidence for every release.** Each release has a harness report (load,
   spawns, stage arrivals, resets) and at least one recorded human run.
5. **Titanfall 1 and Titanfall Online full support** (Phase 2). Maps built and
   released for both runtimes from the same source.
6. **Apex / R5Reloaded seasons 0–3** (Phase 3). One map that builds for every
   season and is tested in that season's runtime.

## Phase 1 — Now: finish what's in progress

1. **Commit the Surf Me and checkpoint work.** The working tree holds the
   checkpoint-capable `_gamemode_surf.nut`, the Surf README update,
   `maps/source-surf-me/`, `maps/surf-map-sources.json`, `docs/surf-map-collection.md`
   and `docs/dedicated-server.md`. Commit them on a branch so they aren't lost.
2. **Do a full human run of Surf Me.** Start to finish through all five stages,
   with deliberate fails on each stage. Confirm the timer survives resets,
   that skipping a stage cancels the run, and that the finish records locally and
   on the web.
3. **Release Surf 0.2.0** with staged-map support. Check first that Utopia, which
   has no checkpoints, behaves exactly as in 0.1.0. Then update the server's
   installed mod (one version per identity: see `docs/dedicated-server.md`).
4. **Release Surf Me 0.1.0.** This needs its own load screen (it still uses the
   Coliseum one), a description and a Thunderstore package. Add it to the server
   rotation.
5. ~~**Investigate the empty-server crash.**~~ Done 13 November: no crash
   happened. `attempted to write pdata of size 0!` is logged on every disconnect,
   including on servers that keep running. Windows recorded no crash or hang for
   the server process; the four Northstar crash events since 9 November are all
   from other processes (three in the client-only `materialsystem_dx11.dll`). The
   log simply goes quiet when nobody is connected. See `docs/dedicated-server.md`.
6. ~~**Confirm live leaderboard submissions.**~~ Done: titanfall.rocks/surf lists
   four Surf Utopia runs from 10–11 November. Follow-up: the Server column says
   "My server" for every run, so give the server key a proper label on the site.

## Phase 1 — Next: grow the collection

7. **Convert surf_beginner.** It should be the simplest of the three; use it to
   make the recipe from the Surf Me conversion repeatable.
8. **Bonus courses as leaderboard categories.** Surf Me has four bonus areas that
   are converted but untimed. Add per-category start and finish zones to
   `surf.json`, a category field in submissions, and a category filter on the site.
9. **Map rotation on the server.** Switch maps by playlist or vote, keep each map's
   records separate, and make sure every map in the rotation is installed and enabled.
10. **Assess surf_kitsune and surf_cyberwave.** List the entity logic each one
    relies on (filters, outputs, moving parts) before converting. Leave out any map
    whose course depends on behaviour the converter can't reproduce.
11. **Automated surf checks in ARES.** Turn the Surf Me native tests (stage
    arrivals, reset floors, spawn clearance, checkpoint order) into a reusable
    `checks.json` + Session script. Every surf map can then be checked the same way
    before release.

## Phase 1 — Later: conversion quality

12. **Entity logic.** Player targetname filters and simple outputs (enable/disable
    triggers, teleport destinations), so bonus gating and multi-route maps behave
    like the originals.
13. **Visual parity.** Water volumes, overlays and decals, normal maps, animated
    or particle effects (torches, smoke), and better bounce lighting on dark walls.
    Nuke shows the current limits.
14. **Render budget.** Replace the vertex snapping used to fit the engine's index
    budget with mesh splitting or static props. This lets detailed maps keep their
    shape.
15. **Ramp feel.** The rampbug fix and Source velocity clipping are opt-in. Collect
    `--surf-trace` logs from real runs on each map to decide whether they should
    become defaults.

## Phase 2 — Titanfall 1 and Titanfall Online full support

Starts after the surf collection ships. "Full support" means an authored or
converted map compiles for BSP v29, is packaged for each runtime, and passes the
same harness checks plus a human playtest in **both** Titanfall Online (TFORevive)
and Titanfall 1 (R1Delta). Track the two runtimes separately even though they share
v29: they mount content differently and accept different maps (R1Delta needs
`info_intermission` and coordinates within ±16384 units; TFO doesn't).

Current state: compiled v29 maps load in both runtimes. Brush and patch
collision matches TFO within 0.001 unit across 5,148 traces and hull sweeps.
Physics props settle on brushes and patches. Surface properties and water records
are written. The remaining work, in order:

1. **Compiler parity checklist.** Go through every v29 lump the compiler writes
   and mark it verified or unverified against retail Angel City, Colony and TFO's
   own maps. Use ARES `validate_records.py` and record-level comparisons. Turn
   each gap into its own task below.
2. **Collision completeness.** Finish the unresolved patch and dome triangle hull
   cases. Check titan hulls, projectiles and grenades as well as pilots, and
   triggers. Use paired TFO and R1Delta harness runs with the same `checks.json`.
3. **Physics stability.** Find the VPhysics instability seen on repeated runs.
   Cover more shapes, speeds and stacking, and confirm buoyancy against a retail
   water control.
4. **Water.** Give water its own visibility cells and verify underwater rendering,
   fog and the transitions into and out of water.
5. **Lighting.** Decode the real-time light (RTL) texel format. Bake world
   lightmaps and ambient probes so characters are lit like on retail maps. Compare
   paired screenshots of a retail map and its decompiled-and-rebuilt copy.
6. **Materials and models.** Package VMT/VTF materials and static-prop models with
   the map. TF1 keeps most models in per-map VPKs, so a map must ship what it uses.
   Use r1-model-compiler (MDL v52) for new models.
7. **Gameplay entities.** Spawns for every TF1 mode (attrition, hardpoint, CTF, last
   titan standing), objectives, drop-ship and titan-fall paths, ziplines, and an
   `info_intermission` added automatically when missing.
8. **Navigation.** AI meshes for grunts and spectres. This is version 2 work in
   MRVN-Radiant's plan, so attrition maps will have no AI until it's done.
9. **Packaging and release.** Produce a TFO mod and an R1Delta addon from one
   build. Write a release recipe like the Titanfall 2 one, with a harness report
   from both runtimes attached to each release.
10. **Converter targets.** Add a v29 target to the Source, Minecraft and Quake
    converters so existing ports can be built for TF1. Start with Surf Utopia as
    the test case.

Exit criteria: one converted map and one authored test map released for both
runtimes. Each must pass harness collision, spawn, physics and view checks, and
have one recorded human match per runtime.

## Phase 3 — Apex Legends / R5Reloaded, seasons 0–3

Starts after Phase 2. R5Reloaded can run seasons 0, 1, 2 and 3, so each season is
its own target. One build per season, tested in that season's runtime, before
any season is called supported.

What differs between seasons, from the local samples and model readers:

| Season | Sample map | BSP | Lump storage | Models |
| --- | --- | --- | --- | --- |
| S0 | `mp_rr_canyonlands_64k_x_64k` | v47 | External `.bsp_lump` sidecars | RMDL v54 subversion 8, component files |
| S1 | `mp_rr_canyonlands_64k_x_64k` | v47 | External sidecars | RMDL v54 subversion 8, component files |
| S2 | `mp_rr_canyonlands_mu1` | v47 | External sidecars | RMDL v54 subversion 9, VG1 |
| S3 | `mp_rr_aqueduct` | v47 | Embedded in the BSP | RMDL v54 subversion 10, VG1 |

All four use BSP v47, but the shared version number doesn't prove identical
record layouts. Compare per-lump record sizes and versions across all four samples
before writing any shared code path.

Current state: only S3 has been tested. The Titanfall 2 → Apex geometry port
(`port_tf2_to_apex.py`) builds an S3 map that loads on the dedicated server, with
collision probes matching within 0.0001. The rendered client still crashes on
sign-on, and visuals, lighting and RPak materials are unfinished.

1. **Season runtimes.** Set up an isolated R5Reloaded install (or profile) for each
   season, and fingerprint its executable and SDK version. Extend the ARES R5
   harness with `--season` so every run records which runtime it tested.
2. **Season format survey.** Write per-lump record sizes and versions for S0–S3
   into a format table. Add per-season profiles to the ARES BSP tools, the way
   the model reader already has `--target s0..s3`.
3. **Fix the S3 client crash.** Get a converted map to render in the S3 client
   before widening to other seasons. Once that works, season 3 becomes the
   reference target.
4. **Writer profiles.** Give the v47 writer a season profile that chooses sidecar
   or embedded lumps, entity header variants and record layouts. Then build the
   same test map for S0, S1, S2 and S3.
5. **Materials and RPaks.** Build per-season RPaks with RePak, using that season's
   material and texture asset versions. Confirm the RPak version for each season;
   S3 uses v8.
6. **Models.** Compile static props per season with r5-model-compiler
   (`r5studiomdl --target s0..s3`), and check physics and BVH collision with the
   ARES `validate-r5-collision` skill.
7. **Collision and visibility.** Generate Apex BVH collision and visibility for
   authored maps rather than taking them from a donor map. Use harness traces to
   compare each season against its own retail maps.
8. **Gameplay and packaging.** Playlists and modes for each season (survival, TDM,
   firing range), spawn and ring data for survival, and a per-season package layout
   with a server VPK (`englishserver_<map>.bsp.pak000_dir.vpk`) for dedicated hosting.
9. **Release.** A season compatibility table in each map's README, and a harness
   report from every season it claims.

Exit criteria: one test map that builds, loads, renders and passes collision checks
in all four seasons, plus one converted map released for at least season 3.

## Future development (compiler)

These are tracked in MRVN-Radiant's `docs/respawn` notes. They matter here
because they limit what a converted map can contain.

- **Titanfall 2 visibility.** Cells and portals (`_viewportals`) work but are
  opt-in; packed large-mesh nodes, water portals and leak handling are unfinished.
  Large maps currently run with a single visibility cell.
- **Collision.** Triangle-collision bevels still have unresolved cases on curved
  patches and some dome triangles. Hull clearance parity isn't established.
- **Lighting.** Shader semantics for probes and the menu stage need verification.
  RTL decoding is part of Phase 2.

## Housekeeping

- Merge ARES PR #2 and use its harnesses for future testing. Then retire the
  one-off `run.py` controllers under MRVN-Radiant `.local/respawn/`.
- Keep `maps/surf-map-sources.json` as the record of the downloaded inputs. Never
  commit or release the Source BSPs or Valve assets themselves.
- Record findings in Gravemind (`games/respawn/maps/testing-and-packaging.md` and
  related documents) as each item ships.
