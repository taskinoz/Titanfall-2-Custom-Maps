# Rebuild Survival Games (Minecraft) with the MRVN-Radiant converter. See docs/converting.md.
param(
    [Parameter(Mandatory)][string]$Mrvn,             # MRVN-Radiant checkout with remap built
    [Parameter(Mandatory)][string]$World,            # The world ZIP after upgrade_minecraft_world.py
    [Parameter(Mandatory)][string]$Jar,              # Official Minecraft Java 1.20.6 client JAR
    [Parameter(Mandatory)][string]$Repak,            # RePak built from r-ex/RePak adc52f7
    [Parameter(Mandatory)][string]$MaterialTemplate, # Native TF2 world material base path
    [string]$MaterialTemplates,                      # extract_material_templates.py output: glass, cutouts, water
    [string]$Output = "$PSScriptRoot/../../output/minecraft-survival-games"
)
$ErrorActionPreference = 'Stop'
$extra = @()
if ($MaterialTemplates) { $extra += '--material-templates', $MaterialTemplates }
# The 'survival_games' preset holds the bounds around the cornucopia, the anchor,
# spawns, terrain mode, 48-unit lightmap texels, the starting mesh cluster and redstone.
python "$Mrvn/tools/respawn/build_minecraft_ports.py" --name survival_games `
    --world $World --jar $Jar --output $Output --remap "$Mrvn/install/Release/remap.exe" `
    --repak $Repak --material-template $MaterialTemplate @extra
