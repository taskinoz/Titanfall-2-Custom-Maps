# Titanfall Surf dedicated server

The local public server uses `C:/Games/Titanfall2/R2Surf`, separate from client
mod-manager profiles. Start it with `C:/Games/Titanfall2/Start-TitanfallSurf.ps1`.
The launcher prevents duplicate instances of this exact profile.

Current packages: Surf 0.2.0, Surf Utopia 0.1.5, Surf Me 0.1.1, Surf Beginner
0.2.1 and Northstar 1.31.15. The four Surf packages are installed from their
actual Thunderstore ZIPs under `R2Surf/mods/taskinoz.MRVN.*`. Their mod.json
identities, not folder names, are the enabledmods.json keys. The previous Surf
0.1.0 and Utopia 0.1.3 folders are kept in `R2Surf/mods.backup-20261122`.

Keep exactly one copy of each mod. Northstar also loads `R2Surf/packages/*/mods/*`,
so a Thunderstore download left in `packages/` alongside the unpacked copy in
`mods/` is a second install of the same identity. With two copies of `MRVN.Surf`
(identical version) Northstar logs `Mod 'MRVN.Surf' has several versions enabled,
disabling them all`, the gamemode never registers, and the server silently runs
`tdm` even though the command line says `+setplaylist surf`. Symptom: the server
is listed but its gamemode is not `surf`. Fix: remove one copy (move `packages/`
aside) and enable one version per identity in `enabledmods.json`. Verify the log
says `GAMETYPE: surf` and has no `several versions enabled` warning.

The launch command is:

```text
NorthstarLauncher.exe -dedicated -multiple -profile=R2Surf -console +hostport 37015 +fps_max 60 +sv_hibernate_when_empty 0 +setplaylist surf +mp_gamemode surf +map mp_source_surf_utopia
```

The server config repeats `fps_max 60`, disables empty-server hibernation and
keeps the standard 5000 ms presence-update interval. The leaderboard URL and
private key are set in both `mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg`
and `ns_startup_args_dedi.txt`; never copy the key into docs. The log confirms
`[Surf] the leaderboard at https://titanfall.rocks/surf accepted this server's key`
at each map start.

## All three surf maps

The `surf` playlist lists `mp_source_surf_utopia`, `mp_source_surf_me` and
`mp_source_surf_beginner` with equal weight in
`R2Surf/mods/taskinoz.MRVN.Surf/keyvalues/playlists_v2.txt`. With the playlist's
600-second time limit and `ns_should_return_to_lobby 0`, a finished match moves
to the next map instead of returning to the lobby. The playlist lives inside the
Surf mod, so re-add the Surf Me and Surf Beginner lines after updating Surf.
Northstar's compiled copy is under `R2Surf/runtime/compiled/mod_patch_*_playlists_v2.txt`.

On 22 November 2026 each map was started in turn and verified: `GAMETYPE: surf`,
the map VPK mounted, the leaderboard accepted the key, no `[Surf] ERROR`, and
the server registered to the master server. An actual end-of-match rotation has
not been observed yet.

## Visibility regression diagnosed 2026-11-09

The process initially registered but then intermittently disappeared from the
master list. Checking only successful startup registration did not catch this.
At runtime it inherited `fps_max -1` (desktop-refresh based). An explicit 60 FPS
limit restored normal frame/console processing and completed the asynchronous
leaderboard check. Empty-server hibernation is also explicitly disabled.
The actual Surf playlist is selected so it is advertised as `surf`, rather than
`Load a map on the command line`.

## A quiet log is not a crash (checked 2026-11-13)

`attempted to write pdata of size 0!` follows every disconnect. The server has no
persistence backend, so it's harmless. After the last player leaves, the log
can stay silent for hours while the server keeps running and stays listed. To
tell a healthy idle server from a dead one, check:

- the server is still on the live master list;
- `Get-WinEvent` (Application log, IDs 1000/1002) has no crash or hang event for
  the server's process ID. Crashes in `materialsystem_dx11.dll` belong to game
  clients, not the dedicated server;
- the process isn't stuck: an idle 60 FPS server averages about 1% of one core,
  with its main thread sleeping between frames.

Don't kill a quiet server just because its log stopped. The 11 November
"zombie" was a healthy idle server, as far as the evidence shows.

When verifying a restart, check the live master list repeatedly for at least two
minutes and reload https://northstar.tf/servers/?filter=surf. A process, bound
UDP socket or one successful registration is not sufficient proof of a healthy
server. Check that Surf mode loads without script errors and the leaderboard
accepts the configured key. Keep diagnostic curl verbosity off in normal operation.
