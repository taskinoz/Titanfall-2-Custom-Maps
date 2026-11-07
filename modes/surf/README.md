# Surf mode

![AI generated](../../.github/badges/ai-generated.svg)

A Northstar game mode for surf maps converted with MRVN-Radiant (so far
[Surf Utopia](../../maps/source-surf-utopia)). Written with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.Surf` |
| Mode | `surf` |
| Version | 0.1.0 |
| Status | Work in progress, not released |

## What it does

- **No teams:** everyone is on one side, so there is no damage between players.
- **Surf settings applied for you:** wallrunning off (server-wide while the mode runs; turned
  back on when another mode starts) and air acceleration 9000 (`surf_air_acceleration`).
  No titans, no boosts, no time limit.
- **Bare hands:** pilots spawn with only the empty-handed melee.
- **Timed runs:** the timer starts when you leave the start room and stops when the map's end
  teleport sends you back to it. Falling into a fail floor or the jail, or dying, ends the run
  without a time. The run timer, speed and best time show on the HUD (Titanfall's Gauntlet
  chronometer), finished runs are announced in chat, and the scoreboard shows runs, best time
  (seconds) and resets.
- **Reset:** the boost key sends you back to the start.
- **Web leaderboard:** finished times are sent to the PHP site in [leaderboard](leaderboard),
  and the map's top five are shown in chat when you join.
- **Scores on disk** (`surf_save_scores 1`): each player's best time per map is kept in
  `R2Northstar/save_data/MRVN.Surf/surf_<map>.json` (Northstar safe I/O), loaded at map start for
  personal bests, and its top five are shown on joining when there is no web leaderboard.

Ramp bugs (losing your speed at a seam between two ramp brushes) are left in, as in Counter-Strike.
MRVN-Radiant's `--rampbug-fix` undoes them, as surf servers' rampbug plugins do.

## Play

Install `MRVN.Surf` and a surf map (e.g. `MRVN.SourceSurfUtopia`) in `R2Northstar/mods`, then:

```text
mp_gamemode surf
map mp_source_surf_utopia
```

or pick **Surf** in a private match.

## Server settings

Set in the server's `autoexec_ns_server.cfg` or on its command line:

| ConVar | Default | Use |
| --- | --- | --- |
| `surf_leaderboard_url` | empty | The leaderboard site, e.g. `https://your.site/surf` |
| `surf_leaderboard_key` | empty | This server's key from the site's `config.php` |
| `surf_save_scores` | `0` | `1` saves best times per map to `save_data/MRVN.Surf/` |
| `surf_air_acceleration` | `9000` | Pilots' air acceleration |

Leaderboard problems are written to the server log as `[Surf] ERROR: ...` and shown in chat
(to everyone once, and to each player who joins):

| Setup | Result |
| --- | --- |
| No URL and no key | Not an error: the web leaderboard is off; joining players are told so |
| URL without a key, or a key without a URL | Error; no times are sent |
| URL with a key the site doesn't know | The key is checked at map start (`api.php?action=check`); error, no times are sent |
| Site unreachable | Error at map start; later failures are logged |

A failure to save scores to disk (Northstar safe I/O) is logged as `[Surf] ERROR`, and the game
carries on without saving.

## Host the leaderboard

The site is plain PHP 8 with SQLite (`pdo_sqlite`):

1. Copy `leaderboard/` to a PHP host, e.g. as `https://your.site/surf`.
2. Copy `config.example.php` to `config.php`, add a key per game server
   (`php -r "echo bin2hex(random_bytes(24)), PHP_EOL;"`) and, if you can, point `database`
   outside the web root. The included `.htaccess` keeps the config and `data/` private on Apache;
   on nginx, deny `config.php`, `lib.php` and `data/` yourself.
3. Open `https://your.site/surf/` for the leaderboard page.

API (used by the mod):

| Request | Purpose |
| --- | --- |
| `POST api.php?action=submit`, header `X-Surf-Key`, body `{"map","name","uid","time"}` | Store a run. Rejects unknown keys, times outside 5 s to 1 h and more than one run per player every 3 s. Replies with the run's rank. |
| `GET api.php?action=top&map=<map>&limit=<n>` | Each player's best time on a map, fastest first |
| `GET api.php?action=maps` | Maps with runs, players and records |
| `POST api.php?action=check`, header `X-Surf-Key` | 200 if the key is known, 403 if not (servers check their key at map start) |

## Tested

Leaderboard settings, in Northstar against a local copy of the site: no URL or key (notice in chat,
log line), URL without a key (error), wrong key (rejected at the map-start check, error in log and
chat, no times sent), good key (time stored); `surf_save_scores 1` wrote
`surf_mp_source_surf_utopia.json` and a later match loaded it (2 scores, personal best kept).

In Northstar, against a local copy of the leaderboard: a run timed from leaving Surf Utopia's start
room to its end teleport, announced in chat, stored, and listed on the page; a pilot teleported
straight into the jail does not start a run; the HUD timer and finish screen show. The PHP API's key,
range, rate and map checks and the page's escaping were tested locally.

## Next

- A surfing viewmodel: hands holding a Nessie doll (the game has `models/domestic/nessy_doll.mdl`),
  with its own idle and movement animations. This needs a custom viewmodel compiled from the
  empty-hands rig.
