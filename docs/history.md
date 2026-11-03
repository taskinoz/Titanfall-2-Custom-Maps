# How the version history was assembled

These maps were first built inside the MRVN-Radiant fork, in an ignored local
folder (`.local/respawn/`), between 7 October and 3 November 2026. That fork's Git
history records the converter and compiler changes, but not the map builds.

When this repository was created, each released build was replayed in order as
one commit, dated with the build's timestamp and tagged `<map>-v<version>`:

| Map | Versions |
| --- | --- |
| Quake E1M1 | 0.1.0, 0.1.1, 0.2.0, 0.2.1, 0.3.0, 0.4.0 |
| UMA (Minecraft) | 0.1.0, 0.3.0, 0.3.1, 0.4.3, 0.5.0, 0.5.1 |
| Glitch (Minecraft) | 0.1.0, 0.3.0, 0.3.1, 0.4.3, 0.5.0, 0.5.1 |

Each commit contains the text files from that version's player ZIP (and source
ZIP for the Minecraft maps): `mod.json`, level scripts, map name strings, entity
lumps, READMEs and the editable `.map`. The ZIPs themselves are attached to the
matching GitHub releases. The changelog entries were written from the notes made
when each version was handed over for testing.

Missing version numbers, such as Minecraft 0.2.0 and 0.4.0 to 0.4.2, were
intermediate builds that were never handed over for testing. The Source ports went through ten, six and five local
builds respectively but have only been versioned once, as 0.1.0, and are not released.

The commit that follows the history adds the Source ports, documentation and
publishing tools.
