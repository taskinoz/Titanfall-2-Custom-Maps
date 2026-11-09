# Surf Utopia 0.1.3

Surf Utopia v3 converted for Titanfall 2 / Northstar. Original human-built map:
https://main.fastdl.me/maps/surf_utopia_v3.bsp.bz2 (authors credited in-map).
Conversion source and AI disclosure: https://github.com/taskinoz/Titanfall-2-Custom-Maps

Install MRVN.SourceSurfUtopia alongside MRVN.Surf 0.1.0, then run:

    mp_gamemode surf
    map mp_source_surf_utopia

Everyone in the match needs the same map version. Do not enable duplicate manual
and Thunderstore installations of this mod.

0.1.3 repairs the jail exit threshold and improves baked lighting in shadowed areas.
The original floor stripes and the existing ramp package image are retained.
Reset teleports use swept hull checks, including compiled bevel planes and a small
contact tolerance. All three end platforms and end portals still use Surf's finish hooks.

This is a converted preview: original doors/buttons and spinning fan logic are not
implemented. The jail cells and exit remain open.
