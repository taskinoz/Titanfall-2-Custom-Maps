# Surf mode

![AI generated](../../.github/badges/ai-generated.svg)

A Northstar game mode for surf maps converted with MRVN-Radiant (so far
[Surf Utopia](../../maps/source-surf-utopia)). Written with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.Surf` |
| Mode | `surf` |
| Version | 0.1.0 |
| Status | Released preview |

## What it does

- **Optional double jump:** enabled by default. In private-match settings use **Pilot /
  Surf: double jump**, or set `surf_double_jump 0` on the server before loading the
  map. `1` enables it. The choice stays fixed until the next map; loadout changes
  reapply it. Times with double jump disabled have a separate record list.
- **No teams:** everyone is on one side, so there is no damage between players.
- **Surf settings applied for you:** wallrunning off (server-wide while the mode runs; turned
  back on when another mode starts) and air acceleration 9000 (`surf_air_acceleration`), applied
  to both server `sv_airaccelerate` and the pilot air-acceleration keyvalue. The server's
  previous value is restored when another mode starts, including after consecutive Surf maps.
  Pilot settings run after Northstar's movement callbacks and are reapplied on respawn,
  loadout changes and titan/pilot transitions.
  No titans, no boosts, no time limit.
- **Bare hands:** pilots spawn with only the empty-handed melee.
- **Timed runs:** the timer starts when you leave the start room and stops when the map's end
  platform is landed on (Surf Utopia exports grounded finish zones for all three
  end platforms, including the upper END portal). Maps without
  finish zones retain the return-to-start teleport finish. On maps with finish zones,
  end teleports also finish using their source zone; other reset teleports cancel the run. Falling into a fail floor or the jail, or dying, ends the run
  without a time. The run timer, uncapped speed in km/h and best time show on the HUD,
  finished runs are announced in chat, and the scoreboard shows runs, best time
  (seconds) and resets.
- **Reset:** the boost key sends you back to the start.
- **Web leaderboard:** finished times are sent to the PHP site in [leaderboard](leaderboard),
  and the map's top five are shown in chat when you join.
- **Scores on disk** (on by default; `surf_save_scores 1`): each player's best time per map is kept in
  `R2Northstar/save_data/MRVN.Surf/surf_<map>.json` (Northstar safe I/O), loaded at map start for
  personal bests, and its top five are shown on joining.
- **Scoreboard leaderboard:** use the normal scoreboard key (Tab by default). A side
  panel shows the map's top five server records, including players who disconnected,
  with millisecond precision and the double-jump rule. The normal rows still show
  connected players' runs, rounded best seconds and resets. `surf_leaderboard` in
  the console lists server records in chat and also queries the web leaderboard
  when configured. With disk saving off, the panel is labelled **Session top 5**.

The speed readout uses player velocity with the Gauntlet's quarter-weighted vertical
component and the Source inch-to-km/h conversion. It avoids the stock Gauntlet RUI's
compiled 50.05 km/h clamp and teleport-induced position-difference spikes.

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
| `surf_save_scores` | `1` | `1` saves best times per map to `save_data/MRVN.Surf/` |
| `surf_double_jump` | `1` | Allow double jump (`0` disables it); private-match setting takes precedence; applies next map |
| `surf_air_acceleration` | `9000` | Server `sv_airaccelerate` and pilots' air acceleration |

Dedicated startup arguments must use separate `+` commands, with the full URL and
key quoted. Use the folder containing `api.php`, not `api.php` itself:

```text
+surf_leaderboard_url "http://your-host/surf"
+surf_leaderboard_key "YOUR_SERVER_KEY"
+mp_gamemode surf
+map mp_source_surf_utopia
```

These are ConVars/commands, not `+setplaylist` arguments. HTTP requests are enabled
by default; remove `-disablehttprequests` if present. `-allowlocalhttp` is only needed
for a loopback/private-network leaderboard (or a destination requiring Northstar's
IPv6 exception); a public IPv4 host does not need it. Malformed URLs are rejected
before requests are sent. The log confirms key acceptance and accepted run
submissions; local saves continue independently of the web service.

Local records survive map changes and restarts in
`R2Northstar/save_data/MRVN.Surf/surf_<map>.json`. The no-double-jump category uses
`surf_<map>__no_double_jump.json`; the optional web service uses the corresponding
`<map>__no_double_jump` map key too. Existing records retain the double-jump-enabled
category. A completed run's exact time and rule are logged even when disk saving is
off; a session from before saving was enabled cannot be recovered from a rounded
scoreboard stat after disconnecting. Runs that finish while a saved file is loading
are merged with the saved bests, and an unreadable file is preserved.

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

API (used by the mod; the full contract for reimplementing it in another language is in
[leaderboard/API.md](leaderboard/API.md)):

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

The scoreboard panel and local persistence were also checked in an isolated Northstar
profile with synthetic finishes: the faster record survived a slower finish and a map
reload, and double-jump-disabled records used a separate file. An actual jump input
while falling produced an upward boost with double jump enabled and no boost with it
disabled. Test records were removed with the temporary profile mod; they were not
installed into the normal player profile.

## Next

- A surfing viewmodel: hands holding a Nessie doll (the game has `models/domestic/nessy_doll.mdl`),
  with its own idle and movement animations. This needs a custom viewmodel compiled from the
  empty-hands rig.
