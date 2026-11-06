# Jump Academy 2 (TF2) changelog

## 0.1.0 (2026-11-03, unreleased)

First test conversion. Both spawns and the teleport destinations have floor, 13 of 13 sampled displacements collide at their surface, teleports work, and the course doors show their labels.

Rebuilt 2026-11-06 with the latest compiler (still unreleased): light probes where players stand, so pilots that were dark in shaded areas are lit like their surroundings; lightmap islands larger than a page are split instead of shrunk. World views, spawns and collision tested against the 2026-11-03 build in Northstar. Some converted brushes exceed the 255-plane collision limit with bevels; their extra bevels are now dropped instead of stopping the build.
