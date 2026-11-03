# Rebuild Quake E1M1 with the MRVN-Radiant test-mod builder. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,          # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$LibreQuake,    # LibreQuake checkout (texture WADs and docs/COPYING)
    [Parameter(Mandatory)][string]$ColiseumPak,   # Decompressed copy of your mp_coliseum.rpak
    [Parameter(Mandatory)][string]$ColiseumEnt,   # Your mp_coliseum_env.ent, for the menu light rig
    [Parameter(Mandatory)][string]$Repak,         # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$Tf2Vpk,        # pg9182/tf2vpk, used to verify the VPK
    [string]$Output = "$PSScriptRoot/../../output/quake-e1m1"
)
$ErrorActionPreference = 'Stop'
$map = "$PSScriptRoot/source/e1m1-original.map"
$materials = "$Output-materials"
python "$Mrvn/tools/respawn/build_quake_materials.py" --map $map --textures "$LibreQuake/texture-wads" `
    --template-pak $ColiseumPak --repak $Repak --license "$LibreQuake/docs/COPYING" --output $materials
python "$Mrvn/tools/respawn/build_northstar_test_mod.py" --map $map `
    --copying "$PSScriptRoot/mod/MRVN.QuakeE1M1Test/COPYING" --remap "$Mrvn/install/Release/remap.exe" `
    --tf2vpk $Tf2Vpk --materials $materials --sun --menu-rig $ColiseumEnt --output $Output
