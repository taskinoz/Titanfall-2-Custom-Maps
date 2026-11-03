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
 AddTeleport( < -3776, -5680, 0 >, < -3392, -4400, 432 >, < -3712, -4576, 1 >, 270 )
 AddTeleport( < -5568, -4160, 0 >, < -4960, -3584, 192 >, < -5024, -4032, 1 >, 135 )
 AddTeleport( < -2720, -3688, 0 >, < -2432, -3328, 192 >, < -2931.41, -3369.32, 5 >, 326 )
 AddTeleport( < -2988, -5264, 0 >, < -2000, -4096, 144 >, < -2656, -4384, -3 >, 303 )
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
   if ( o.z < -542.0 )
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
