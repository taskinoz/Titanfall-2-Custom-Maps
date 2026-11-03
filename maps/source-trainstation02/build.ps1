# Rebuild d1_trainstation_02 (Half-Life 2) with the MRVN-Radiant Source 1 converter. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$Hl2,              # Half-Life 2 'hl2' folder (map, textures and props)
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$Output = "$PSScriptRoot/../../output/source-trainstation02"
)
$ErrorActionPreference = 'Stop'
$env:PYTHONPATH = "$Mrvn/tools/respawn"
python "$Mrvn/tools/respawn/build_source_ports.py" --bsp "$Hl2/maps/d1_trainstation_02.bsp" --game-dir $Hl2 `
    --name trainstation02 --display-name 'Trainstation (HL2)' --output $Output `
    --remap "$Mrvn/install/Release/remap.exe" --repak $Repak --material-template $MaterialTemplate
