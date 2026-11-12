# Rebuild the original Source 1 surf_me as a Titanfall 2 local preview.
param(
    [Parameter(Mandatory)][string]$Mrvn,
    [Parameter(Mandatory)][string]$Bsp,
    [Parameter(Mandatory)][string]$Css,
    [Parameter(Mandatory)][string]$Tf2,
    [Parameter(Mandatory)][string]$Hl2,
    [Parameter(Mandatory)][string]$Repak,
    [Parameter(Mandatory)][string]$MaterialTemplate,
    [Parameter(Mandatory)][string]$MaterialTemplates,
    [string]$Loadscreen = "$PSScriptRoot/loadscreen.png",
    [string]$LoadscreenTemplate,                     # Retail loadscreen _gen .json/.uber base path
    [string]$Python = 'python',
    [string]$Output = "$PSScriptRoot/../../output/source-surf-me"
)
$ErrorActionPreference = 'Stop'
$extra = @()
if ($LoadscreenTemplate -and (Test-Path $Loadscreen)) { $extra += '--loadscreen', $Loadscreen, '--loadscreen-template', $LoadscreenTemplate }
& $Python "$Mrvn/tools/respawn/build_source_ports.py" --bsp $Bsp `
    --game-dir $Css --game-dir $Tf2 --game-dir $Hl2 `
    --name surf_me --display-name 'Surf Me' `
    --description 'Five stages of Egyptian-themed surfing by not_a_zombie. Play Surf mode for timed runs through all five stages.' `
    --surf --surf-config "$PSScriptRoot/surf.json" --luxel-size 48 --mesh-cluster 12288 `
    --output $Output --remap "$Mrvn/install/Release/remap.exe" --repak $Repak `
    --material-template $MaterialTemplate --material-templates $MaterialTemplates @extra
if ($LASTEXITCODE -ne 0) { throw "Surf Me conversion failed with exit code $LASTEXITCODE" }
