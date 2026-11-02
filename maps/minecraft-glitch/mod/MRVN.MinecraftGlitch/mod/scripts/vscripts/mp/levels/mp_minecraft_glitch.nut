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
 while ( true )
 {
  foreach ( entity player in GetPlayerArray() )
  {
   if ( IsAlive( player ) && player.GetOrigin().z < -1248.0 )
    player.TakeDamage( 10000, null, null, { damageSourceId = eDamageSourceId.fall } )
  }
  wait 0.1
 }
}
