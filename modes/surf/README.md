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

Ramp bugs (losing your speed at a seam between two ramp brushes) are left in, as in Counter-Strike.
MRVN-Radiant's `--rampbug-fix` undoes them, as surf servers' rampbug plugins do.

## Play

Install `MRVN.Surf` and a surf map (e.g. `MRVN.SourceSurfUtopia`) in `R2Northstar/mods`, then:

```text
mp_gamemode surf
map mp_source_surf_utopia
```

or pick **Surf** in a private match.

## Run a server with the leaderboard

Set, in the server's `autoexec_ns_server.cfg` or on its command line:

```text
surf_leaderboard_url "https://your.site/surf"
surf_leaderboard_key "<the key you added to the site's config.php>"
```

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

## Tested

In Northstar, against a local copy of the leaderboard: a run timed from leaving Surf Utopia's start
room to its end teleport, announced in chat, stored, and listed on the page; a pilot teleported
straight into the jail does not start a run; the HUD timer and finish screen show. The PHP API's key,
range, rate and map checks and the page's escaping were tested locally.

## Next

- A surfing viewmodel: hands holding a Nessie doll (the game has `models/domestic/nessy_doll.mdl`),
  with its own idle and movement animations. This needs a custom viewmodel compiled from the
  empty-hands rig.
