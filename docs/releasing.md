# Releasing

Each map or mode version is released on its own: one Git tag, one GitHub release and one
Thunderstore version.

| | Format | Example |
| --- | --- | --- |
| Mod version | `X.Y.Z` in `mod.json` | `0.5.1` |
| Tag and release | `<map folder>-v<version>` | `minecraft-glitch-v0.5.1` |
| Player ZIP | `<ModName>-<version>.zip` | `MRVN.MinecraftGlitch-0.5.1.zip` |
| Source ZIP (Minecraft) | `<ModName>-source-<version>.zip` | `MRVN.MinecraftGlitch-source-0.5.1.zip` |
| Thunderstore package | `taskinoz-<Name>-<version>` | `taskinoz-Minecraft_Glitch-0.5.1` |

Never change a published ZIP or Thunderstore version. Bump the version instead.

## Steps

1. **Build and test** the new version (see [building.md](building.md)), with the new
   version in the mod's `mod.json`.
2. **Update the repository:** copy the built mod's text files into
   `maps/<map>/mod/<ModName>/`, the new `.map` into `maps/<map>/source/`, add a
   `CHANGELOG.md` entry and update the version in the map's README and the root
   README.
3. **Update the catalog:** in `thunderstore/packages.json`, set the map's
   `version`, `tag`, `asset`, `bytes` and `sha256`. Get the size and hash with:

   ```powershell
   (Get-Item MRVN.MinecraftGlitch-0.5.2.zip).Length
   (Get-FileHash MRVN.MinecraftGlitch-0.5.2.zip -Algorithm SHA256).Hash.ToLower()
   ```

4. **Commit and push to `main`**, then tag: `git tag -a minecraft-glitch-v0.5.2 -m "Glitch (Minecraft) 0.5.2"`
   and `git push origin minecraft-glitch-v0.5.2`.
5. **Publish the GitHub release** with the player ZIP (and source ZIP) attached:

   ```powershell
   gh release create minecraft-glitch-v0.5.2 MRVN.MinecraftGlitch-0.5.2.zip MRVN.MinecraftGlitch-source-0.5.2.zip `
       --title "Glitch (Minecraft) 0.5.2" --notes-file notes.md
   ```

Publishing the release starts the **Publish maps to Thunderstore** workflow. It
downloads the ZIP named in the catalog, checks its size and SHA-256, repackages it
in Thunderstore's layout (`manifest.json`, `README.md`, `icon.png`,
`mods/taskinoz.<ModName>/`) without changing any runtime file, and uploads it.
A release whose tag isn't in the catalog, such as an older version, publishes
nothing.

When the first releases were created with `gh release create` on 2026-11-03, no
workflow run started, and the cause wasn't found. If no run appears under Actions
within a minute, run the workflow by hand (below) with the release tag and
**publish** on.

## Running the workflow by hand

In GitHub, open **Actions → Publish maps to Thunderstore → Run workflow** on
`main`. Selection is `current` (every catalogued map), a mod name such as
`MRVN.QuakeE1M1Test`, or a release tag. With **publish** off it only builds the
packages and attaches them to the run for checking. With it on it uploads them.
A version that's already on Thunderstore is downloaded and compared, then skipped
if identical; a different package at the same version fails.

Locally, the same packaging runs without uploading:

```powershell
python tools/thunderstore_ci.py --source-dir C:\folder\with\release\zips --output output/thunderstore
python -m unittest discover -s tools
```

## Thunderstore account

Packages publish under the **taskinoz** team. The repository Actions secret
`TS_KEY` holds that team's Thunderstore service-account token. Only the
configuration check and the upload step can read it. Never put it in a file,
release asset or workflow input.

Icons are 256x256 PNGs in `thunderstore/icons/<Name>.png`. Descriptions are at
most 250 characters. Every package README states that the conversion was made
with AI and links to the original map.

The packaging and upload scripts are adapted from
[apex-to-titanfall-2](https://github.com/taskinoz/apex-to-titanfall-2). Its
[notes on Thunderstore publishing](https://github.com/taskinoz/apex-to-titanfall-2/blob/main/docs/thunderstore-ci.md)
explain why uploads use the multipart, background-submission protocol.

## Game modes

Mode entries use `kind: mode` and `source_path` pointing to the runtime mod folder.
They contain scripts and may contain Northstar `keyvalues` patches; they do not
require a BSP or RPak. Maps can list Thunderstore `dependencies` in the catalog.
Surf and Surf Utopia are separate releases; Surf Utopia depends on Surf 0.1.0.
