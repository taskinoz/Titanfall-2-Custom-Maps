# Glitch (Minecraft) changelog

## Unreleased (2026-11-07)

- Loading screen and icon recaptured from the current build.
- Grey stained glass is translucent and trapdoors are cut out.
- Water shows as a see-through surface; deep columns are kill zones.
- The two one-block waterfalls no longer kill partway down: one-wide columns of water are drawn as see-through falls and pilots drop through them.

## 0.5.2 (2026-11-06)

Rebuilt with the latest MRVN-Radiant compiler. Character lighting now comes from light probes placed where players stand (about 86,000, up from a coarse grid), which keeps pilots lit like their surroundings instead of picking up a probe far away. Probe light visibility is measured over a character-sized volume. Geometry, spawns and world lighting are unchanged: 27 camera views match 0.5.1 apart from the HUD.

## 0.5.1 (2026-11-02)

Glitch: fills the hole in the world's terrain at the south-west corner and restores the cut-off northern edge. UMA: version bump only.

## 0.5.0 (2026-11-02)

Fewer, larger world meshes fix sections vanishing at wide fields of view, 96 placed torches with baked lights, map names on the loading screen and menus, an invisible roof and walls around the build, UMA's barrier blocks and glass roof become clip.

## 0.4.3 (2026-11-02)

Fixed-pattern sky occlusion removes spotty shadows, in-game loading screens, Glitch's pit kills at Z -192, Glitch's iron-bar lines become native ziplines, spawns need a clear area and face the middle.

## 0.3.1 (2026-11-02)

The menu Titan stands on open grass; the brick backdrop moved behind it.

## 0.3.0 (2026-11-02)

Sharp BC1 textures, sun shadows and brighter ambient, a Minecraft sky dome with blocky clouds and a square sun, a block-built multiplayer menu stage, buttons on their walls, all spawns inside the map with per-team selection.

## 0.1.0 (2026-11-02)

First geometry ports: selected build area, merged block brushes, resident texture pak, sun and ambient bake, eight spawns per team. Fixes the visibility tree that hid most of Glitch's meshes.

