# Rebuild Surf Utopia (TF2 build of surf_utopia_v3) with the MRVN-Radiant Source 1 converter. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$Bsp,              # surf_utopia_v3.bsp
    [Parameter(Mandatory)][string]$Hl2,              # Half-Life 2 'hl2' folder (dev water texture)
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$Loadscreen = "$PSScriptRoot/loadscreen.png",
    [string]$LoadscreenTemplate,                     # Retail loadscreen _gen .json/.uber base path
    [string]$MaterialTemplates,                      # extract_material_templates.py output: glass, cutouts, water
    [string]$Output = "$PSScriptRoot/../../output/source-surf-utopia"
)
$ErrorActionPreference = 'Stop'
$extra = @()
if ($MaterialTemplates) { $extra += '--material-templates', $MaterialTemplates }
if ($LoadscreenTemplate -and (Test-Path $Loadscreen)) { $extra += '--loadscreen', $Loadscreen, '--loadscreen-template', $LoadscreenTemplate }
$env:PYTHONPATH = "$Mrvn/tools/respawn"
# The map spans the whole Source world: 16 units per luxel runs out of memory baking light,
# 40 fits in four lightmap pages. surf_ maps get the surf-ramp script by default (--surf).
python "$Mrvn/tools/respawn/build_source_ports.py" --bsp $Bsp --game-dir $Hl2 `
    --name surf_utopia --display-name 'Surf Utopia' `
    --description 'A classic Counter-Strike surf map. Slide along the ramps, strafe into them to hold your line, and reach the end of the course. Fall off and you are sent to the jail. Play it in the Surf mode for timed runs.' --luxel-size 40 --output $Output `
    --remap "$Mrvn/install/Release/remap.exe" --repak $Repak --material-template $MaterialTemplate @extra
