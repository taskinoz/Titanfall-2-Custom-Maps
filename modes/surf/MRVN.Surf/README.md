# Surf 0.1.0

A Northstar game mode for surf maps. Install the Surf Utopia map separately, select
Surf in a private match, or use `mp_gamemode surf` before loading a surf map.

- Uncapped speed display, run timer, personal best and finish announcement.
- Hold Tab for the map's server top five, or enter `surf_leaderboard` in the console.
- Best times save locally by default. A hosted PHP leaderboard is optional.
- Double jump is optional in Pilot / Surf: double jump, or `surf_double_jump 0`
  before loading the map. Each rule has separate records.
- Surf Utopia finishes on any of the three end platforms or their end teleports.
- The boost key resets a run. Wallrunning, titans and boosts are disabled.

Manual install: place MRVN.Surf in R2Northstar/mods and restart Northstar. Both
clients and the server need this mode. Remove duplicate manually installed copies
when switching to a mod manager.

[Server and leaderboard setup](https://github.com/taskinoz/Titanfall-2-Custom-Maps/tree/main/modes/surf).

Written with AI; see [AI.md](https://github.com/taskinoz/Titanfall-2-Custom-Maps/blob/main/AI.md).
