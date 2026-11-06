# Quake E1M1 changelog

## 0.4.1 (2026-11-06)

Rebuilt with the latest MRVN-Radiant compiler: light probes where players stand (6,824, up from 1,180 on a grid) and probe light visibility over a character-sized volume, so pilots pick up nearby lights more consistently. Some spots beside lights in enclosed corridors are darker than before, because the nearest probe no longer sees lights the player can't. Geometry and world lighting are unchanged.

## 0.4.0 (2026-10-13)

One-bounce baked lighting, the map enclosed in a sky shell like retail maps, Titans disabled (no navmesh), fixed CSG occluders reading unset bevel planes.

## 0.3.0 (2026-10-12)

LibreQuake textures, Quake light entities and a static sun, baked lightmaps.

## 0.2.1 (2026-10-07)

Fixes the surface vertex ranges (`first_vertex` relative to the material sort, inclusive `num_vertices`) that crashed grapples and impact queries.

## 0.2.0 (2026-10-07)

Doors removed to leave openings, triggers, liquids, buttons and lifts dropped, 24 pilot spawns, Coliseum replacement materials, dropship intro and evac disabled. Crashed when grappling.

## 0.1.1 (2026-10-07)

Loose BSP and entity files under `mod/maps` so Northstar's map command can find the map. First version to load: white developer surfaces, wrong shadows, blocked passages.

## 0.1.0 (2026-10-07)

First Northstar package of E1M1 compiled by remap, with a VPK-only map. Northstar rejected `map mp_quake_e1m1` as not found.

