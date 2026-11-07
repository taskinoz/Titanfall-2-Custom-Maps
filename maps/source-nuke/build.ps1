# Rebuild Nuke (CS2) with the MRVN-Radiant Source 2 converter. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$Csgo,             # Counter-Strike 2 'game/csgo' folder
    [Parameter(Mandatory)][string]$Vrf,              # Source2Viewer-CLI.exe, release 20.1
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$MaterialTemplates,                      # extract_material_templates.py output: glass, cutouts, water
    [string]$Output = "$PSScriptRoot/../../output/source-nuke"
)
$ErrorActionPreference = 'Stop'
$extra = @()
if ($MaterialTemplates) { $extra += '--material-templates', $MaterialTemplates }
$env:PYTHONPATH = "$Mrvn/tools/respawn"
# The glTF export is cached next to the output and reused by later builds.
python "$Mrvn/tools/respawn/build_source2_ports.py" --vpk "$Csgo/maps/de_nuke.vpk" --vrf $Vrf `
    --gameinfo "$Csgo/gameinfo.gi" --export "$Output-export" `
    --name nuke --display-name 'Nuke (CS2)' --output $Output `
    --remap "$Mrvn/install/Release/remap.exe" --repak $Repak --material-template $MaterialTemplate @extra
