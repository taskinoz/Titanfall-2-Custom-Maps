# Rebuild Jump Academy 2 (TF2) with the MRVN-Radiant Source 1 converter. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$Bsp,              # jump_academy2_rc9.bsp
    [Parameter(Mandatory)][string]$Tf2,              # Team Fortress 2 'tf' folder, for stock textures and props
    [Parameter(Mandatory)][string]$Hl2,              # Half-Life 2 'hl2' folder
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$Output = "$PSScriptRoot/../../output/source-academy2"
)
$ErrorActionPreference = 'Stop'
$env:PYTHONPATH = "$Mrvn/tools/respawn"
python "$Mrvn/tools/respawn/build_source_ports.py" --bsp $Bsp --game-dir $Tf2 --game-dir $Hl2 `
    --name academy2 --display-name 'Jump Academy 2 (TF2)' --output $Output `
    --remap "$Mrvn/install/Release/remap.exe" --repak $Repak --material-template $MaterialTemplate
