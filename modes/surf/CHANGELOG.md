# Surf changelog

## 0.2.0 - 2026-11-18

- Multi-stage maps: a map can list its stage start points (`checkpointOrigins`).
  Stages must be completed in order; a reset to the current stage keeps the
  timer running, and skipping or going back a stage cancels the run. The finish
  only counts after the last stage. Maps without stages work exactly as before.
- Teleports and cancelled runs are written to the server log (`[surf]` lines)
  to diagnose unexpected resets.
- Native rule checks for any surf map: `tests/surf_native_test.py`.

## 0.1.0 - 2026-11-09

- First public release of the Surf game mode for Northstar.
- Surf air acceleration, automatic movement settings and optional double jump.
- Run timer, uncapped km/h speedometer, personal best and finish announcement.
- Tab scoreboard panel with exact server records, including disconnected players.
- Local best times saved by default; separate records for each double-jump rule.
- Optional PHP web leaderboard with setup diagnostics and submission confirmation.
- All three Surf Utopia end platforms and their portals finish an active run;
  a finish is submitted once, and other reset portals cancel unfinished runs.
