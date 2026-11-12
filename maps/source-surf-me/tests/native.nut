
void function SurfMe_Test()
{
 while ( !file.haveMap ) wait 0.1
 void functionref( bool, string ) require = void function( bool ok, string message )
 {
  if ( !ok ) throw "SURF_ME_TEST: " + message
 }
 require( file.checkpointOrigins.len() == 4, "four stage checkpoints" )
 require( !Surf_IsCheckpointTransition( 0, 2 ), "skip stage rejected" )
 require( !Surf_IsCheckpointTransition( 2, 1 ), "backwards stage rejected" )
 require( !Surf_IsCheckpointTransition( 0, -1 ), "unknown destination rejected" )
 entity probe = CreateEntity( "info_target" )
 DispatchSpawn( probe )
 file.runStart[probe] <- Time() - 60.0
 file.runCheckpoint[probe] <- 0
 float began = file.runStart[probe]
 require( !Surf_CompletedCheckpoints( probe ), "finish requires all stages" )
 Surf_FinishRun( probe )
 require( probe in file.runStart, "early finish ignored" )
 for ( int i = 0; i < file.checkpointOrigins.len(); i++ )
 {
  vector destination = file.checkpointOrigins[i]
  require( Surf_CheckpointAt( destination ) == i + 1, "checkpoint identified" )
  Surf_OnTeleported( probe, destination )
  Surf_OnTeleported( probe, destination )
  require( probe in file.runStart && file.runStart[probe] == began, "stage transition and reset retain timer" )
  require( file.runCheckpoint[probe] == i + 1, "stage advances once" )
 }
 require( Surf_CompletedCheckpoints( probe ), "finish unlocked after fifth stage" )
 delete file.runStart[probe]
 delete file.runCheckpoint[probe]
 delete file.inStart[probe]
 probe.Destroy()
 printl( "[SurfMeTest] checkpoint timer assertions passed" )
 array<vector> spawns = [ < -13102.5, -3232, -752 >, < -13102.5, -2912, -752 >, < -12782.5, -3232, -752 >, < -12782.5, -2912, -752 >,
 < -13262.5, -3232, -752 >, < -13262.5, -2912, -752 >, < -12942.5, -3232, -752 >, < -12942.5, -2912, -752 > ]
 foreach ( vector o in spawns )
 {
  TraceResults r = TraceLine( o + < 0, 0, 32 >, o - < 0, 0, 256 >, null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
  require( r.fraction > 0.0 && r.fraction < 1.0, "floor under spawn " + o )
  require( r.surfaceNormal.z > 0.7, "spawn floor is walkable " + o )
  printl( "[SurfMeTest] spawn " + o + " floor=" + r.endPos + " normal=" + r.surfaceNormal )
 }
 array<vector> arrivals = clone file.checkpointOrigins
 arrivals.append( < -12782.5, -3072, -768 > )
 arrivals.append( < -9232, 12736, -736 > )
 foreach ( vector o in arrivals )
 {
  TraceResults floor = TraceLine( o, o - < 0, 0, 1024 >, null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
  TraceResults hull = TraceHull( o, o + < 0, 0, 1 >, < -16, -16, 0 >, < 16, 16, 72 >, null, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
  require( !floor.startSolid && floor.fraction < 1.0, "floor under stage arrival " + o )
  require( !hull.startSolid && hull.fraction >= 0.99, "pilot clearance at stage arrival " + o )
  printl( "[SurfMeTest] arrival " + o + " floor=" + floor.endPos )
 }
 printl( "[SurfMeTest] ALL PASSED" )
}
