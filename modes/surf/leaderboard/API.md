# Surf leaderboard API, version 1

The contract between the `MRVN.Surf` Northstar mod (game servers) and a leaderboard
server. `api.php` in this folder is the reference implementation (PHP 8 + SQLite); any server
that follows this document works with the mod, in any language.

## Overview

- Game servers **submit** finished runs and **read** the top times for a map.
- Writes are authenticated with a per-server key; reads are public.
- Everything is JSON over HTTP(S). The mod is configured with a base URL
  (`surf_leaderboard_url`, e.g. `https://example.com/surf`, no trailing slash) and a key
  (`surf_leaderboard_key`).

All endpoints are one path, `<base>/api.php`, with the operation in the `action` query
parameter. A reimplementation must keep that path and parameter, because the mod builds its
URLs as `<base>/api.php?action=...`. (A server can route `/api.php` to anything.)

| Action | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `check` | POST | key | Confirm a server key is valid |
| `submit` | POST | key | Store one finished run |
| `top` | GET | none | Best time per player on a map |
| `maps` | GET | none | Maps that have runs, with counts and record |

## Conventions

- **Request bodies** are UTF-8 JSON. The mod sends `Content-Type: application/json; charset=utf-8`.
  Servers should parse the body as JSON whatever the content type says.
- **Responses** are UTF-8 JSON with `Content-Type: application/json; charset=utf-8`, for errors too.
- **Errors** have the body `{"error": "<message>"}` and a non-2xx status. The mod only looks at
  the status code; the message is for logs.
- **Times** are in seconds, as JSON numbers with a fractional part (e.g. `83.25`, `70.0`).
  Responses should always write a fraction (`70.0`, not `70`); the mod accepts both.
- **Map names** are Titanfall level names: `^[a-z0-9_]{1,64}$` (e.g. `mp_source_surf_utopia`).
- **Player IDs** (`uid`) are the Northstar/Origin user ID as a decimal string:
  `^[0-9]{1,32}$`. They identify players; names can change and are only for display.
- **Dates** are ISO 8601 in UTC (`2026-11-07T13:01:29+00:00`).

## Authentication

Write endpoints (`check`, `submit`) take the server key in the request header:

```
X-Surf-Key: <key>
```

The header name is case-insensitive (the mod sends `x-surf-key`). The server holds a list
of named keys, one per game server. The name is stored with each run (`server` in responses).
A missing, empty or unknown key gets **403**. Compare keys in constant time.

Keys are secrets: they are long random strings (the reference setup uses 48 hex
characters, `bin2hex(random_bytes(24))`), never logged and never returned.

## `POST ?action=check`

Confirms the key. The mod calls this once at map start and treats anything but 200 as a
configuration error (logged and shown in chat; no runs are submitted that match).

Request body: ignored (the mod sends `{}`).

| Status | Body |
| --- | --- |
| 200 | `{"ok": true, "server": "<key name>"}` |
| 403 | `{"error": "unknown server key"}` |

## `POST ?action=submit`

Stores one finished run.

Request body:

```json
{
  "map": "mp_source_surf_utopia",
  "name": "The_taskinoz",
  "uid": "1000108120826",
  "time": 83.25
}
```

| Field | Type | Rule |
| --- | --- | --- |
| `map` | string | Map name pattern above |
| `name` | string | Trimmed, 1–64 characters (Unicode) |
| `uid` | string | Player ID pattern above |
| `time` | number | Within the server's accepted range (reference: 5 to 3600 seconds) |

Checks, in this order: key (403), JSON body (400), fields (400), rate limit (429). Then the run
is stored. **Every run is stored**, not only personal bests; the leaderboard picks each
player's best when read.

Rate limit: at most one run per `uid` every 3 seconds (across all servers). A faster repeat
gets 429 and is not stored.

| Status | Body |
| --- | --- |
| 200 | `{"ok": true, "rank": 4}`: the run's place among players' best times on that map (1 = record) |
| 400 | `{"error": "body must be JSON"}`, `"bad map"`, `"bad name"`, `"bad uid"`, `"time out of range"` |
| 403 | `{"error": "unknown server key"}` |
| 429 | `{"error": "too many submissions"}` |
| 500 | `{"error": "server error"}` |

`rank` is 1 + the number of players whose best time on the map, counting this run, is strictly
faster than this run. A run slower than the player's own best therefore counts that best too
(their earlier, faster run is ahead of it).

## `GET ?action=top&map=<map>&limit=<n>`

Each player's best time on a map, fastest first.

| Parameter | Rule |
| --- | --- |
| `map` | Required, map name pattern |
| `limit` | Optional, default 10, clamped to 1–100 |

Response 200: a JSON **array** (not an object):

```json
[
  {"name": "New", "uid": "5005", "time": 70.0, "date": "2026-11-07T13:01:29+00:00", "server": "Test server"},
  {"name": "Viper", "uid": "2002", "time": 79.125, "date": "2026-11-07T13:01:17+00:00", "server": "Test server"}
]
```

One entry per `uid`: their fastest run on that map. `name` and `server` are from that run,
`date` is when it was submitted. Ordering: `time` ascending, then earlier `date` first (the first
to set a time keeps the place). An unknown map returns `[]`. A bad `map` returns 400 `bad map`.

The mod reads `name` and `time` and shows the first five in chat.

## `GET ?action=maps`

Maps that have at least one run:

```json
[{"map": "mp_source_surf_utopia", "runs": 6, "players": 5, "record": 7.2}]
```

`runs` is all stored runs, `players` distinct `uid`s, `record` the fastest time. Ordered by map
name. (The reference implementation returns the counts as strings; clients should accept numbers
or numeric strings.)

Any other or missing `action` gets 404 `{"error": "unknown action"}`. `submit` or `check` with a
method other than POST gets 405 `{"error": "use POST"}`.

## Storage

The reference implementation keeps one table; a reimplementation only needs to keep what the
endpoints return:

| Column | Type | Notes |
| --- | --- | --- |
| `id` | integer | Primary key |
| `map` | text | |
| `uid` | text | |
| `name` | text | Name at the time of the run |
| `time` | real | Seconds |
| `server` | text | Name of the key that submitted it |
| `created` | integer | Unix time of submission |

Indexes on `(map, time)` and `(uid, created)` serve `top` and the rate limit.

## What the mod does with responses

| Call | When | 200 | 403 | Other / unreachable |
| --- | --- | --- | --- | --- |
| `check` | Map start, when both URL and key are set | Submissions enabled | `[Surf] ERROR`, chat warning, no submissions | Same as 403 |
| `submit` | Each finished run | Nothing shown (the mod announces the time itself) | `[Surf] ERROR`, chat warning, submissions stop | Logged |
| `top` | A player joins | Top five in chat | n/a | Logged |

Submissions are fire-and-forget: the mod doesn't retry, so a server that is down for a while loses
those runs.

## Testing a reimplementation

```sh
B=http://127.0.0.1:8765; K=<a key from your config>
curl -s -X POST "$B/api.php?action=check" -H "X-Surf-Key: $K"                 # 200 {"ok":true,...}
curl -s -X POST "$B/api.php?action=check" -H "X-Surf-Key: wrong"              # 403
curl -s -X POST "$B/api.php?action=submit" -H "X-Surf-Key: $K" \
     -d '{"map":"mp_source_surf_utopia","name":"Pilot","uid":"1006","time":83.25}'   # 200 {"ok":true,"rank":1}
curl -s -X POST "$B/api.php?action=submit" -H "X-Surf-Key: $K" \
     -d '{"map":"mp_source_surf_utopia","name":"Pilot","uid":"1006","time":80.5}'    # 429 (within 3 s)
curl -s -X POST "$B/api.php?action=submit" -H "X-Surf-Key: $K" \
     -d '{"map":"mp_source_surf_utopia","name":"Fast","uid":"3003","time":1}'        # 400 time out of range
curl -s "$B/api.php?action=top&map=mp_source_surf_utopia&limit=5"                    # [{"name":"Pilot",...}]
curl -s "$B/api.php?action=maps"
```

Names are user input: a leaderboard page must escape them (the reference page shows
`<b>Viper</b>` as text).
