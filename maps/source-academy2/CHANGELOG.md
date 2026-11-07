# Jump Academy 2 (TF2) changelog

## Unreleased (2026-11-07)

- Glass walls are translucent and `$alphatest` foliage cards and fences are cut out (`-MaterialTemplates`).

## 0.1.0 (2026-11-03, unreleased)

First test conversion. Both spawns and the teleport destinations have floor, 13 of 13 sampled displacements collide at their surface, teleports work, and the course doors show their labels.

Rebuilt 2026-11-06 with the latest compiler (still unreleased): light probes where players stand, so pilots that were dark in shaded areas are lit like their surroundings. World views and spawns tested against the 2026-11-03 build in Northstar. Some converted brushes exceed the 255-plane collision limit with bevels; their extra bevels are now dropped instead of stopping the build.

func_illusionary geometry and non-solid world brushes now render (without collision). Most of the map's remaining gaps are translucent glass walls, which stay solid but invisible until a translucent material template exists, and stock TF2 props and textures, which need Team Fortress 2 installed when building.
