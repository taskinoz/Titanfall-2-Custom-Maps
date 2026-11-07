# Rebuild Glitch (Minecraft) with the MRVN-Radiant converter. See docs/building.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$World,            # Oblivering's world ZIP from Planet Minecraft
    [Parameter(Mandatory)][string]$Jar,              # Official Minecraft Java 1.20.6 client JAR
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$Loadscreen = "$PSScriptRoot/loadscreen.png",
    [string]$LoadscreenTemplate,                     # Retail loadscreen _gen .json/.uber base path
    [string]$MaterialTemplates,                      # extract_material_templates.py output: glass, cutouts, water
    [string]$Output = "$PSScriptRoot/../../output/minecraft-glitch"
)
$ErrorActionPreference = 'Stop'
$extra = @()
if ($MaterialTemplates) { $extra += '--material-templates', $MaterialTemplates }
if ($LoadscreenTemplate -and (Test-Path $Loadscreen)) { $extra += '--loadscreen', $Loadscreen, '--loadscreen-template', $LoadscreenTemplate }
# The 'glitch' preset holds the inspected settings: bounds, anchor, spawns, the death
# pit at Z -192, native ziplines, open-sky spawns and the filled terrain corner.
python "$Mrvn/tools/respawn/build_minecraft_ports.py" --name glitch `
    --world $World --jar $Jar --output $Output --remap "$Mrvn/install/Release/remap.exe" `
    --repak $Repak --material-template $MaterialTemplate @extra
