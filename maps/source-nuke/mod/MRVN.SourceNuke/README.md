# Nuke (CS2): Source engine to Titanfall 2 test port

Source map: de_nuke.vpk. Original game assets belong to their owners (Valve).
Local conversion by MRVN-Radiant, for local testing only: no redistribution licence is granted.

Extract MRVN.SourceNuke into R2Northstar/mods and run `map mp_source_nuke tdm`.

Render meshes, textures (base colour only), physics collision, lights and spawns are
converted. Render meshes are simplified by snapping vertices to a grid. Cutout and
translucent materials (glass, decals), wires, the 3D skybox, doors, physics props
and normal maps are not.
