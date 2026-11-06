# Survival Games (Minecraft)

![AI generated](../../.github/badges/ai-generated.svg)

The Original Survival Games Minecraft map, converted to a Titanfall 2 map for
Northstar. The original human-built map is
[on Planet Minecraft](https://www.planetminecraft.com/project/the-original-survival-games-map/);
this conversion was produced with AI (see [AI.md](../../AI.md)).

| | |
| --- | --- |
| Mod | `MRVN.MinecraftSurvivalGames` |
| Level | `mp_minecraft_survival_games` |
| Version | 0.5.2 |
| Status | **Not released**: local builds only, until the author and permission are confirmed |

## What's converted

The original is a forest island about 1,000 blocks across inside a glass dome.
At 48 units per block that is 48,000 units, past the +/-16,384 units of world the
converters keep to, so this conversion is the 321 by 321 block square around the cornucopia
(about 15,400 units across): the cornucopia, the forest and lakes around it, and
the island's east shore.

- 2.8 million blocks, from 12 blocks below sea level up to the treetops, with
  Minecraft 1.20.6 textures, sun shadows and baked ambient light.
- Sealed caves are filled and buried faces hidden. What renders and what collides
  are separate brushes: the textured blocks only draw, and the same space merged
  into 39,000 invisible boxes collides, within the engine's 65,535 collision
  brushes.
- Lightmaps at 32 units per texel (16 lightmap pages) keep the map within the
  1,000-mesh budget.
- Four start and respawn sites for each team, north and south of the cornucopia.

Not converted: water (lakes are dry hollows you can walk through), plants,
redstone, chests and the glass dome, which lies outside the converted area.
There is no navmesh, so Titans and AI don't work.

## Build and play locally

Download the world ZIP from Planet Minecraft. It was saved by a Minecraft version
older than 1.13, so upgrade it once with Mojang's server (this accepts the
[Minecraft EULA](https://aka.ms/MinecraftEULA)):

```powershell
python <MRVN-Radiant>/tools/respawn/upgrade_minecraft_world.py --world "The Original Survival Games Map.zip" `
    --output survival-games-upgraded.zip --java "C:\Program Files\Java\jdk-26.0.1\bin\java.exe" --accept-eula
```

Then run `build.ps1` with the upgraded ZIP (see [docs/converting.md](../../docs/converting.md)),
copy the output's `MRVN.MinecraftSurvivalGames` folder into
`Titanfall2/R2Northstar/mods`, and run:

```text
map mp_minecraft_survival_games tdm
```

## Files

| Path | Contents |
| --- | --- |
| `mod/MRVN.MinecraftSurvivalGames/` | Text files of the mod: `mod.json`, level script, map name strings and entity lumps |
| `source/conversion.json` | Selection bounds, anchor, block counts and omitted block types |
| `build.ps1` | The exact converter command for this map |
| `CHANGELOG.md` | Version history |

The editable `.map` (121 MB) is over GitHub's file size limit; it is in the
build's `MRVN.MinecraftSurvivalGames-source-<version>.zip`.

## Credits

- Original Minecraft map: The Original Survival Games Map on Planet Minecraft,
  probably by Vareide (not yet confirmed from the map's page).
- Minecraft textures and models: Mojang Studios / Microsoft.
- Converter and compiler: [MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant).
