global function Cl_Surf_Init
global function ServerCallback_Surf_StartRun
global function ServerCallback_Surf_StopRun
global function ServerCallback_Surf_CancelRun

// Run timer on the HUD: Titanfall's Gauntlet chronometer (time, best time and speed).
struct
{
	var timerRui = null
	var splashRui = null
} file

void function Cl_Surf_Init()
{
	// The default game state HUD: the FFA one expects one player per team and errors with one team.
}

void function Surf_DestroyRuis()
{
	if ( file.timerRui != null )
		RuiDestroyIfAlive( file.timerRui )
	if ( file.splashRui != null )
		RuiDestroyIfAlive( file.splashRui )
	file.timerRui = null
	file.splashRui = null
}

void function ServerCallback_Surf_StartRun( float startTime, float best )
{
	Surf_DestroyRuis()
	file.timerRui = RuiCreate( $"ui/gauntlet_hud.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
	RuiSetGameTime( file.timerRui, "startTime", startTime )
	if ( best > 0.0 )
		RuiSetFloat( file.timerRui, "bestTime", best )
	RuiTrackFloat3( file.timerRui, "playerPos", GetLocalViewPlayer(), RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetBool( file.timerRui, "useMetric", true )
}

void function ServerCallback_Surf_StopRun( float time, bool isBest )
{
	if ( file.timerRui == null )
		return
	RuiSetBool( file.timerRui, "runFinished", true )
	RuiSetFloat( file.timerRui, "finalTime", time )
	if ( isBest )
		RuiSetFloat( file.timerRui, "bestTime", time )
	file.splashRui = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
	RuiSetFloat( file.splashRui, "duration", 5.0 )
	RuiSetString( file.splashRui, "message", "#GAUNTLET_FINISH_TEXT" )
	thread Surf_ClearAfter( file.timerRui, 6.0 )
}

void function ServerCallback_Surf_CancelRun()
{
	Surf_DestroyRuis()
}

void function Surf_ClearAfter( var rui, float delay )
{
	wait delay
	if ( file.timerRui == rui )
		Surf_DestroyRuis()
}
