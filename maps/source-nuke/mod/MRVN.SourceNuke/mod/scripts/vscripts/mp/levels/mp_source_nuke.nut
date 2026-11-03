global function CodeCallback_MapInit
struct
{
 array<vector> mins
 array<vector> maxs
 array<vector> destinations
 array<float> yaws
} file
void function CodeCallback_MapInit()
{
 ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
 ClassicMP_ForceDisableEpilogue( true )
 Riff_ForceTitanAvailability( eTitanAvailability.Never )
 thread KillFallenPilots()
}
void function AddTeleport( vector mins, vector maxs, vector destination, float yaw )
{
 // Players touch a trigger when their hull overlaps it; origins are at the feet.
 file.mins.append( mins - <16, 16, 72> )
 file.maxs.append( maxs + <16, 16, 0> )
 file.destinations.append( destination )
 file.yaws.append( yaw )
}
void function KillFallenPilots()
{
 while ( true )
 {
  foreach ( entity player in GetPlayerArray() )
  {
   if ( !IsAlive( player ) )
    continue
   vector o = player.GetOrigin()
   if ( o.z < -1472.0 )
   {
    player.TakeDamage( 10000, null, null, { damageSourceId = eDamageSourceId.fall } )
    continue
   }
   for ( int i = 0; i < file.mins.len(); i++ )
   {
    vector lo = file.mins[i]
    vector hi = file.maxs[i]
    if ( o.x < lo.x || o.y < lo.y || o.z < lo.z || o.x > hi.x || o.y > hi.y || o.z > hi.z )
     continue
    player.SetOrigin( file.destinations[i] )
    player.SetAngles( <0, file.yaws[i], 0> )
    player.SetVelocity( <0, 0, 0> )
    break
   }
  }
  wait 0.05
 }
}
