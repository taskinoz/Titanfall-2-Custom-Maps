// Native Surf rule checks, appended to a scratch copy of _gamemode_surf.nut by
// surf_native_test.py and started from _Surf_Init. Never ship this in the mod.
// Every check prints "[SurfTest] ok ..."; a failure throws, which the harness
// reports as a script error. The last line is "[SurfTest] PASSED <map>".

void function SurfTest_Require( bool condition, string what )
{
	if ( !condition )
		throw "SurfTest failed on " + GetMapName() + ": " + what
	printl( "[SurfTest] ok " + what )
}

void function SurfTest_Begin( entity p, float elapsed )
{
	file.runStart[p] <- Time() - elapsed
	file.runCheckpoint[p] <- 0
	file.inStart[p] <- false
}

void function SurfTest_Run()
{
	while ( !file.haveMap || GetPlayerArray().len() == 0 || !IsAlive( GetPlayerArray()[0] ) )
		wait 0.2
	wait 3.0
	entity p = GetPlayerArray()[0]
	int stages = file.checkpointOrigins.len()
	printl( "[SurfTest] map=" + GetMapName() + " mode=" + GAMETYPE + " checkpoints=" + stages + " finishZones=" + file.finishMins.len() )
	SurfTest_Require( GAMETYPE == "surf", "gamemode is surf" )
	SurfTest_Require( file.finishMins.len() > 0, "map exports finish zones" )
	vector start = ( file.startMins + file.startMaxs ) * 0.5
	vector finish = ( file.finishMins[0] + file.finishMaxs[0] ) * 0.5
	vector nowhere = start + < 0, 0, 60000 >

	// A teleport that is neither the start nor a stage (fail floor, jail) cancels.
	SurfTest_Begin( p, 30.0 )
	Surf_OnTeleported( p, nowhere )
	SurfTest_Require( !( p in file.runStart ), "fail teleport cancels the run" )

	// An unfinished staged run can't finish through the end portal.
	if ( stages > 0 )
	{
		SurfTest_Begin( p, 30.0 )
		Surf_MapTeleported( p, start, finish )
		SurfTest_Require( !( p in file.runStart ), "early end portal does not record a time" )
		SurfTest_Require( !( p in file.best ), "early end portal leaves no best time" )

		// Skipping a stage or going backwards cancels.
		SurfTest_Begin( p, 30.0 )
		if ( stages >= 2 )
		{
			Surf_OnTeleported( p, file.checkpointOrigins[1] )
			SurfTest_Require( !( p in file.runStart ), "skipping a stage cancels the run" )
		}
		SurfTest_Begin( p, 30.0 )
		Surf_OnTeleported( p, file.checkpointOrigins[0] )
		if ( stages >= 2 )
		{
			Surf_OnTeleported( p, file.checkpointOrigins[1] )
			Surf_OnTeleported( p, file.checkpointOrigins[0] )
			SurfTest_Require( !( p in file.runStart ), "going back a stage cancels the run" )
		}
	}

	// A full run: each stage in order, a same-stage reset on each, then the end portal.
	SurfTest_Begin( p, 42.0 )
	float began = file.runStart[p]
	for ( int i = 0; i < stages; i++ )
	{
		Surf_OnTeleported( p, file.checkpointOrigins[i] )
		Surf_OnTeleported( p, file.checkpointOrigins[i] )
		SurfTest_Require( p in file.runStart && file.runStart[p] == began, "stage " + ( i + 2 ) + " transition and reset keep the timer" )
		SurfTest_Require( file.runCheckpoint[p] == i + 1, "stage " + ( i + 2 ) + " advances once" )
	}
	Surf_MapTeleported( p, start, finish )
	SurfTest_Require( !( p in file.runStart ), "end portal finishes the run" )
	SurfTest_Require( p in file.best && file.best[p] > 41.5 && file.best[p] < 43.5, "finish records a time of about 42 s" )
	printl( "[SurfTest] PASSED " + GetMapName() )
}
