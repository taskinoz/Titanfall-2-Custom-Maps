global function CodeCallback_MapInit
void function CodeCallback_MapInit()
{
 ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
 ClassicMP_ForceDisableEpilogue( true )
 Riff_ForceTitanAvailability( eTitanAvailability.Never )
 thread KillFallenPilots()
}
void function KillFallenPilots()
{
 // Deep water: Titanfall 2 has no swimming, so pilots who go under die.
 array<vector> waterMins = [ < -96.0, -480.0, 240.0 >, < 3744.0, 1056.0, 96.0 >, < 3792.0, 1056.0, 240.0 > ]
 array<vector> waterMaxs = [ < -48.0, -336.0, 314.0 >, < 3792.0, 1200.0, 170.0 >, < 3840.0, 1200.0, 314.0 > ]
 vector waterLo = < -96.0, -480.0, 96.0 >
 vector waterHi = < 3840.0, 1200.0, 314.0 >
 while ( true )
 {
  foreach ( entity player in GetPlayerArray() )
  {
   if ( !IsAlive( player ) )
    continue
   vector p = player.GetOrigin()
   bool dead = p.z < -192.0
   bool nearWater = p.x >= waterLo.x && p.x <= waterHi.x && p.y >= waterLo.y && p.y <= waterHi.y && p.z >= waterLo.z && p.z <= waterHi.z
   for ( int i = 0; nearWater && i < waterMins.len() && !dead; i++ )
   {
    vector a = waterMins[i]
    vector b = waterMaxs[i]
    dead = p.x >= a.x && p.x <= b.x && p.y >= a.y && p.y <= b.y && p.z >= a.z && p.z <= b.z
   }
   if ( dead )
    player.TakeDamage( 10000, null, null, { damageSourceId = eDamageSourceId.fall } )
  }
  wait 0.1
 }
}
