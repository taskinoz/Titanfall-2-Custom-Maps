# Uma Minecraft to Titanfall 2 test port

Original Minecraft map: BirthdayTrain, https://www.planetminecraft.com/project/ru-titanfall-2-uma/
Original game: Respawn Entertainment. Minecraft assets: Mojang/Microsoft.
Local conversion by MRVN-Radiant. Retain these credits with any derivative.

Extract MRVN.MinecraftUma into R2Northstar/mods. In a local Northstar session use:
`map mp_minecraft_uma tdm`

This is an experimental pilot-only geometry port. No navmesh, Titans, AI,
objective placements, Minecraft commands/redstone, or moving mechanisms.
Glitch's author lists the Minecraft source as 55% complete.
48 Source units per block. Shape boxes follow Java blockstate/model variants;
rotated subelements use unrotated bounds. Plants, signs and zero-thickness
elements are omitted. Glass/leaf alpha is composited onto opaque backing.
Animated textures use their first frame. Per-face model UV rotations and
subrectangle UVs are approximated by world-aligned 48-unit tiling.
UMA's upper white-glass containment shell becomes sky.
Safe spawn sites are selected on the primary floor. Both maps loaded and rendered in Northstar. All eight pilot spawn hulls and
both team spawn selections passed. Full traversal and multiplayer testing remain.

Editable source: mp_minecraft_uma.map and assets/ in the adjacent source ZIP.
Use this output directory as the editor/compiler basepath.
Third-party game assets are for local use; no redistribution license is granted.

Compiler visibility count overflow was corrected before packaging. See
RESPAWN_MINECRAFT_PORTS.md for build and verification details.
