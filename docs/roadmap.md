# Map development roadmap

Status as of 18 November 2026. This covers the maps in this repository, the Surf
mode, and the converter, compiler and testing work they depend on in
[MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant) and
[ARES](https://github.com/taskinoz/ARES). Update it when an item ships or changes.

## Where things stand

| Area | State |
| --- | --- |
| Surf Utopia | Released, 0.1.4 (18 Nov: pilots stand up after ramps and teleports). The public `Titanfall Surf` server still runs 0.1.3 with Surf 0.1.0 until it is updated |
| Surf mode | Released, 0.2.0 (18 Nov): staged maps with in-order checkpoints |
| Surf Me | Released, 0.1.0 (18 Nov) after a play-through; five-stage rules pass native tests. Red-lit stage-3 room and bonus timers remain open |
| Surf Beginner | Released, 0.2.1 (22 Nov): seven-stage course. CS:S textures remain grey until CS:S is installed |
| surf_kitsune, surf_cyberwave | Source BSPs downloaded and checksummed; not converted |
| Other Source ports (Nuke, Academy, Trainstation) | Local only; Valve assets mean they aren't released |
| Minecraft and Quake ports | Released |
| Leaderboard site | Search, map filter and global rank are live at titanfall.rocks/surf, with four public Surf Utopia runs |
| Testing | ARES map harness (PR #2) runs maps and mods in Northstar, TFO, R1Delta and R5Reloaded unattended |
| Titanfall 1 / TFO | Compiled v29 maps load in TFO and R1Delta; collision matches TFO; lighting, water and packaging incomplete (Phase 2) |
| Apex / R5Reloaded | Season 3 only: a TF2 → Apex port loads on the dedicated server; the client crashes on sign-on; S0–S2 untested (Phase 3) |

## Phase 1 checkpoint: 14 November 2026

Phase 1 is **partially verified, not finished**. Utopia 0.1.3 and Surf 0.1.0
remain the public releases. The local branch contains the staged Surf 0.2.0
preparation, Surf Me's rebuilt five-stage preview and loading screen, Surf
Beginner's seven-stage preview, native rule tests and the source-map assessment.
The checkpoint implementation is committed; the latest crouch recovery changes
in the three level scripts and MRVN-Radiant's converter template are uncommitted.

The 13 November native tests passed the timed-run rules on Utopia, Me and
Beginner, and spawn clearance at Beginner's seven stage starts. The separate
Surf Me crouch check observed crouching on a ramp, recovery after leaving it,
and standing after a fail teleport. Recovery checks headroom and resets the
forced slide at teleports. These are recorded results from the previous work;
no Northstar test was rerun on 14 November.

Release gates remain: a human run of all five Me stages with deliberate fails
and a finish recorded locally and online; then Surf 0.2.0 and Me packages,
catalog updates and server rotation. Beginner still needs seven CS:S materials,
lighting comparison, its own loading screen and a human run. Bonus categories,
real-trigger/reset-floor automation and Kitsune filter emulation remain open.
The empty-server crash investigation was closed without evidence of a server
crash; the leaderboard server label still needs correcting.

At the user's request, Phase 2 has begun alongside these outstanding release
gates. Initial runtime work used TFO while another system used EA/Origin.
After EA sign-in was available, R1Delta 3.0.5 also passed the six shared
baseline collision checks, matching TFO exactly. Broader acceptance in both
runtimes remains outstanding. See MRVN-Radiant's
[Phase 2 checklist](https://github.com/taskinoz/MRVN-Radiant/blob/9fd8bddb6e16f3e8e69dd8215e2a5db1484e9392/docs/respawn/RESPAWN_TF1_PHASE2.md).

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

1. ~~**Commit the Surf Me and checkpoint work.**~~ Done 13 November (branch
   `surf-stages-and-surf-me`). The branch includes the
   checkpoint-capable `_gamemode_surf.nut`, the Surf README update,
   `maps/source-surf-me/`, `maps/surf-map-sources.json`, `docs/surf-map-collection.md`
   and `docs/dedicated-server.md`. The later crouch recovery fix remains
   uncommitted; see the checkpoint above.
2. **Do a full human run of Surf Me.** Start to finish through all five stages,
   with deliberate fails on each stage. Confirm the timer survives resets,
   that skipping a stage cancels the run, and that the finish records locally and
   on the web.
3. **Release Surf 0.2.0** with staged-map support. Version bumped and changelog
   written; Utopia 0.1.3 passes every non-staged rule check natively under it
   (13 November). Waiting on item 2 before tagging. Then update the server's
   installed mod (one version per identity: see `docs/dedicated-server.md`).
4. **Release Surf Me 0.1.0.** Ready apart from item 2: rebuilt with the current
   converter, its own loading screen and native checks (13 November). Still
   needed: the Thunderstore package, the catalog entry and a place in the server
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

7. ~~**Convert surf_beginner.**~~ Released as 0.2.0 on 22 November: seven stages,
   its own loading screen and 11 localisations. Remaining: install
   Counter-Strike: Source for its seven missing textures, check its dark lighting
   against the original, and a human run. The recipe (measure the start platform
   with harness traces, take checkpoints from the stage teleport destinations,
   pad the last end trigger into a finish zone) is in its README.
8. **Bonus courses as leaderboard categories.** Surf Me has four bonus areas that
   are converted but untimed. Add per-category start and finish zones to
   `surf.json`, a category field in submissions, and a category filter on the site.
9. **Map rotation on the server.** All three released maps are installed and in the
   `surf` playlist (22 November); each loads with the leaderboard key accepted and
   keeps its own records. Remaining: watch a real end-of-match rotation, or add a
   vote/changelevel command for switching on demand.
10. ~~**Assess surf_kitsune and surf_cyberwave.**~~ Done 13 November.
    - **surf_cyberwave: convert next.** Two stages (`s1_start`, `s2_start`), one
      bonus (`b1_start`) and a spawn; 12 plain teleports. Its only scripting is a
      `logic_auto` that runs `sv_maxvelocity 7500`. Its 95 MB BSP probably embeds
      its own textures. Check that the Surf mode's speed cap allows 7,500 u/s.
    - **surf_kitsune: needs converter work first.** Its secret colour route is
      gated by player names: `trigger_multiple` sets `!activator`'s targetname
      (`AddOutput targetname X1`…), and teleports with `filter_activator_name`
      fire only for matching names. The converter ignores filters, so those
      teleports would fire for everyone and pull normal runs into the secret
      route. Emulate per-player names and filtered teleports in the generated
      level script (roadmap item 12), or drop the filtered teleports.
11. **Automated surf checks.** Started 13 November: `modes/surf/tests/surf_native_test.py`
    checks the Surf rules on any map natively, through the ARES harness. Still
    to add: reset-floor sweeps, and each stage's real triggers fired in game
    rather than called from script.

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

Started 14 November by user request while Phase 1 release gates remain open.
"Full support" means an authored or
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
   each gap into its own task below. Started 14 November: reproducible inventory
   of all 70 writer lump types against Angel City, Colony and TFO lobby; 52 have
   record schemas and 18 need separate validation (updated 15 November). Matching directory versions
   and passing static checks do not establish semantic parity. Evidence and
   follow-up tasks are in MRVN-Radiant's `RESPAWN_TF1_PHASE2.md`.
   A new authored brush/flat-patch fixture also completed two TFO sessions:
   all 12 ray/hull checks passed; one of four crate-height expectations failed
   with the crate resting higher on the brush. Orientation/contact diagnostics
   are needed before interpreting that discrepancy. After EA sign-in,
   R1Delta 3.0.5 passed the same six collision checks with identical results;
   the crate probes were omitted because that small prop is removed in R1Delta.
2. **Collision completeness.** Finish the unresolved patch and dome triangle hull
   cases. Check titan hulls, projectiles and grenades as well as pilots, and
   triggers. Use paired TFO and R1Delta harness runs with the same `checks.json`.
3. **Physics stability.** Find the VPhysics instability seen on repeated runs.
   Cover more shapes, speeds and stacking, and confirm buoyancy against a retail
   water control.
4. **Water.** Give water its own visibility cells and verify underwater rendering,
   fog and the transitions into and out of water. The opt-in portal path already
   preserves water boundaries and assigns water cells; convex/sloped compiler
   cases pass. Cell water-index ranges are now validated (15 November).
   Underwater rendering/fog and paired buoyancy acceptance remain open.
5. **Lighting.** Decode the real-time light (RTL) texel format. Bake world
   lightmaps and ambient probes so characters are lit like on retail maps. Compare
   paired screenshots of a retail map and its decompiled-and-rebuilt copy.
6. **Materials and models.** Package VMT/VTF materials and static-prop models with
   the map. TF1 keeps most models in per-map VPKs, so a map must ship what it uses.
   Use r1-model-compiler (MDL v52) for new models.
7. **Gameplay entities.** Spawns for every TF1 mode (attrition, hardpoint, CTF, last
   titan standing), objectives, drop-ship and titan-fall paths, ziplines, and an
   `info_intermission` added automatically when missing. Camera fallback is done
   15 November: copied from a located pilot spawn, preserving authored cameras;
   four compiler cases and an R1Delta native startup check pass. Other gameplay
   entities remain open.
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

- ARES PR #2 is merged; use its harnesses for future testing. Then retire the
  one-off `run.py` controllers under MRVN-Radiant `.local/respawn/`.
- Keep `maps/surf-map-sources.json` as the record of the downloaded inputs. Never
  commit or release the Source BSPs or Valve assets themselves.
- Record findings in Gravemind (`games/respawn/maps/testing-and-packaging.md` and
  related documents) as each item ships.
