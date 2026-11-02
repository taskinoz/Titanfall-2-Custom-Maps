# Glitch (Minecraft): Minecraft to Titanfall 2 test port

Original Minecraft map: Oblivering, https://www.planetminecraft.com/project/glitch-titanfall-2/
Original game: Respawn Entertainment. Minecraft assets: Mojang/Microsoft.
Local conversion by MRVN-Radiant. Retain these credits with any derivative.

Extract MRVN.MinecraftGlitch into R2Northstar/mods. In a local Northstar session use:
`map mp_minecraft_glitch tdm`

This is an experimental pilot-only geometry port. No navmesh, Titans, AI,
objective placements, Minecraft commands/redstone, or moving mechanisms.
48 Source units per block. Shape boxes follow Java blockstate/model variants;
rotated subelements use unrotated bounds. Plants, signs and zero-thickness
elements are omitted. Glass/leaf alpha is composited onto opaque backing.
Animated textures use their first frame. Per-face model UV rotations and
subrectangle UVs are approximated by world-aligned 48-unit tiling.
Safe spawn sites are selected on the primary floor. Runtime behavior still
requires in-game verification; a successful compile is not proof of playability.

Editable source: mp_minecraft_glitch.map and assets/ in the adjacent source ZIP.
Use this output directory as the editor/compiler basepath.
Third-party game assets are for local use; no redistribution license is granted.
