# Nuke (CS2) changelog

## Unreleased (2026-11-07)

- Chain-link fences, grates and railings are cut out; glass is translucent, faint where its texture is missing from the export.
- Fences no longer cast solid baked shadows.

## 0.1.0 (2026-11-03, unreleased)

First test conversion. It loads, 7 of 8 spawns are clear, and the yards, roofs, silo and props render with sun shadows. Collision matches the render from above and below.

Rebuilt 2026-11-06 with the latest compiler (still unreleased): light probes where players stand, so pilots that were dark in shaded areas are lit like their surroundings. World views and spawns tested against the 2026-11-03 build in Northstar.

Doorways open: doors, breakable windows and vents, and the Retakes site blockers are no longer drawn (their collision isn't in the map's physics, so they blocked the view but not players). Ground decals and trim stay on the surfaces they sit on. The sky uses CS2's own sky panorama instead of a flat colour. Fences and other cutout materials are still missing: there is no alpha-tested material template yet.
