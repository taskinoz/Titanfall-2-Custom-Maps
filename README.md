# Titanfall 2 Custom Maps

[![AI: generated conversions](.github/badges/ai-generated.svg)](AI.md)

Custom maps for Titanfall 2 on [Northstar](https://northstar.tf), converted from
Minecraft, Quake and Source engine maps with
[MRVN-Radiant](https://github.com/taskinoz/MRVN-Radiant). The conversions were made
with AI; the maps themselves were built by people. See [AI.md](AI.md) for the
disclosure and links to every original.

## Maps

| Map | Level | Version | Status |
| --- | --- | --- | --- |
| [UMA (Minecraft)](maps/minecraft-uma) | `mp_minecraft_uma` | 0.5.2 | Released preview |
| [Glitch (Minecraft)](maps/minecraft-glitch) | `mp_minecraft_glitch` | 0.5.2 | Released preview |
| [Survival Games (Minecraft)](maps/minecraft-survival-games) | `mp_minecraft_survival_games` | 0.5.2 | Unreleased, local builds only |
| [Quake E1M1](maps/quake-e1m1) | `mp_quake_e1m1` | 0.4.1 | Released compiler test |
| [Jump Academy 2 (TF2)](maps/source-academy2) | `mp_source_academy2` | 0.1.0 | Unreleased, local builds only |
| [Nuke (CS2)](maps/source-nuke) | `mp_source_nuke` | 0.1.0 | Unreleased, local builds only |
| [Trainstation (HL2)](maps/source-trainstation02) | `mp_source_trainstation02` | 0.1.0 | Unreleased, local builds only |
| [Surf Utopia](maps/source-surf-utopia) | `mp_source_surf_utopia` | 0.1.2 | Released preview |

## Game modes

| Mode | Mod | Status |
| --- | --- | --- |
| [Surf](modes/surf) | `MRVN.Surf` | 0.1.0: timed runs, speedometer and leaderboards |

All are pilot-only: there is no navmesh, so Titans and AI don't work. The other map ports were tested with one player in Pilot vs Pilot (`tdm`).
Surf mode was tested on Surf Utopia, including saved times and all three end
platforms and portals.

## Install

**With a mod manager:** install [Surf](https://thunderstore.io/c/northstar/p/taskinoz/Surf/)
and [Surf Utopia](https://thunderstore.io/c/northstar/p/taskinoz/Surf_Utopia/) for surf races.
Surf Utopia installs the Surf mode as a dependency. Other maps include [UMA](https://thunderstore.io/c/northstar/p/taskinoz/Minecraft_UMA/), [Glitch](https://thunderstore.io/c/northstar/p/taskinoz/Minecraft_Glitch/) or [Quake E1M1](https://thunderstore.io/c/northstar/p/taskinoz/Quake_E1M1/) from
[Thunderstore](https://thunderstore.io/c/northstar/p/taskinoz/).

**By hand:** download a map's ZIP from
[Releases](https://github.com/taskinoz/Titanfall-2-Custom-Maps/releases), close the
game, delete any older copy of that mod folder, and extract the ZIP so its folder
(for example `MRVN.MinecraftUma`) sits in `Titanfall2/R2Northstar/mods`.

Start Northstar, check the mod is enabled under Mods, start a private match, and
run the map's command in the console, for example `map mp_minecraft_uma tdm`.
Everyone in the match needs the same version installed.

Every released version is kept on the Releases page. Each map's `CHANGELOG.md`
lists what changed.

## Repository layout

```text
maps/<map>/
  README.md        what the map is, how to play it, credits
  CHANGELOG.md     version history
  build.ps1        the exact converter command
  mod/<ModName>/   text files of the shipped Northstar mod
  source/          editable .map source (released maps)
thunderstore/      publishing catalog and icons
tools/             Thunderstore packaging and upload scripts
docs/              building, releasing and the project's history
```

Compiled files (`.bsp`, `.rpak`, `.vpk`) are not in Git. They are attached to each
GitHub release. Each version is also a Git tag, `<map>-v<version>`.

## Documentation

- [Converting a map](docs/converting.md): turning a Minecraft, Source or Counter-Strike 2 map into a Titanfall 2 map.
- [Building a map](docs/building.md): toolchain, inputs and rebuild commands.
- [Releasing](docs/releasing.md): GitHub releases and Thunderstore publishing.
- [History](docs/history.md): how the version history was assembled.

## Credits and licences

Original maps belong to their authors (see [AI.md](AI.md) and each map's README).
Titanfall 2 belongs to Respawn Entertainment and Electronic Arts, Minecraft assets
to Mojang Studios / Microsoft, and Half-Life 2 and Counter-Strike 2 to Valve. The
Quake E1M1 package is GPL-2.0 with BSD-licensed LibreQuake textures. MRVN-Radiant
is GPL-2.0-or-later. No licence is chosen yet for this repository's own scripts
and documentation.
