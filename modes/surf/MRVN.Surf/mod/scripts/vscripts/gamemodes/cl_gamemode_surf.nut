global function Cl_Surf_Init
global function ServerCallback_Surf_StartRun
global function ServerCallback_Surf_StopRun
global function ServerCallback_Surf_CancelRun

// The Gauntlet RUI clamps its numeric speed at 50.05 km/h in compiled code.
// Use stock text RUIs for the same information without that limit.
const float SURF_UNITS_TO_KPH = 0.09144 // Source units are inches: 0.0254 * 3.6.
const float SURF_HUD_INTERVAL = 0.05
struct
{
	var timerRui = null
	var bestRui = null
	var speedRui = null
	var splashRui = null
	float startTime = 0.0
	float bestTime = -1.0
	float finalTime = 0.0
	bool finished = false
	array<var> leaderboardRuis
	array<string> leaderboardRows
	string leaderboardKind = "local"
	bool leaderboardDoubleJump = true
} file

void function Cl_Surf_Init()
{
	AddServerToClientStringCommandCallback( "SurfLeaderboard", Surf_ReceiveLeaderboard )
	AddScoreboardShowCallback( Surf_ShowLeaderboard )
	AddScoreboardHideCallback( Surf_HideLeaderboard )
	// The default game state HUD: the FFA one expects one player per team and errors with one team.
}

void function Surf_DestroyRuis()
{
	if ( file.timerRui != null )
		RuiDestroyIfAlive( file.timerRui )
	if ( file.bestRui != null )
		RuiDestroyIfAlive( file.bestRui )
	if ( file.speedRui != null )
		RuiDestroyIfAlive( file.speedRui )
	if ( file.splashRui != null )
		RuiDestroyIfAlive( file.splashRui )
	file.timerRui = null
	file.bestRui = null
	file.speedRui = null
	file.splashRui = null
}

var function Surf_CreateHudText( vector position, float size )
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 1 )
	RuiSetFloat2( rui, "msgPos", position )
	RuiSetFloat( rui, "msgFontSize", size )
	RuiSetFloat( rui, "msgAlpha", 1.0 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", < 1, 1, 1 > )
	return rui
}

string function Surf_FormatTime( float seconds )
{
	seconds = max( 0.0, seconds )
	int minutes = int( seconds / 60.0 )
	return format( "%i:%05.2f", minutes, seconds - minutes * 60.0 )
}

float function Surf_SpeedKph( vector velocity )
{
	// Match the Gauntlet's weighting of vertical movement, using velocity rather
	// than position differences so map teleports cannot produce speed spikes.
	velocity.z *= 0.25
	return velocity.Length() * SURF_UNITS_TO_KPH
}

void function Surf_UpdateHud()
{
	float elapsed = file.finished ? file.finalTime : Time() - file.startTime
	RuiSetString( file.timerRui, "msgText", "TIME  " + Surf_FormatTime( elapsed ) )
	RuiSetString( file.bestRui, "msgText", "BEST  " + ( file.bestTime > 0.0 ? Surf_FormatTime( file.bestTime ) : "--:--.--" ) )
	entity player = GetLocalViewPlayer()
	float speed = IsValid( player ) ? Surf_SpeedKph( player.GetVelocity() ) : 0.0
	RuiSetString( file.speedRui, "msgText", format( "%.0f km/h", speed ) )
}

void function Surf_HudThink( var timerRui )
{
	while ( file.timerRui == timerRui )
	{
		Surf_UpdateHud()
		wait SURF_HUD_INTERVAL
	}
}

void function ServerCallback_Surf_StartRun( float startTime, float best )
{
	Surf_DestroyRuis()
	file.startTime = startTime
	file.bestTime = best
	file.finished = false
	file.timerRui = Surf_CreateHudText( < 0.86, 0.34, 0 >, 32.0 )
	file.bestRui = Surf_CreateHudText( < 0.86, 0.38, 0 >, 24.0 )
	file.speedRui = Surf_CreateHudText( < 0.86, 0.43, 0 >, 40.0 )
	thread Surf_HudThink( file.timerRui )
}

void function ServerCallback_Surf_StopRun( float time, bool isBest )
{
	if ( file.timerRui == null )
		return
	file.finished = true
	file.finalTime = time
	if ( isBest )
		file.bestTime = time
	Surf_UpdateHud()
	if ( file.splashRui != null )
		RuiDestroyIfAlive( file.splashRui )
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

void function Surf_ReceiveLeaderboard( array<string> args )
{
	if ( args.len() == 3 && args[0] == "begin" )
	{
		file.leaderboardKind = args[1]
		file.leaderboardDoubleJump = args[2] == "1"
		file.leaderboardRows.clear()
	}
	else if ( args.len() == 4 && args[0] == "row" )
	{
		int rank = args[1].tointeger()
		if ( rank != file.leaderboardRows.len() + 1 || rank > 5 )
			return
		string name = Surf_DecodeText( args[3] )
		if ( name.len() > 18 ) name = name.slice( 0, 18 ) + "..."
		float seconds = args[2].tofloat()
		int minutes = int( seconds / 60.0 )
		file.leaderboardRows.append( format( "%d. %s  %d:%06.3f", rank, name, minutes, seconds - minutes * 60.0 ) )
	}
	if ( file.leaderboardRuis.len() > 0 )
		Surf_UpdateLeaderboard()
}

void function Surf_ShowLeaderboard()
{
	Surf_HideLeaderboard()
	for ( int i = 0; i < 7; i++ )
	{
		var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 10 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", < 0.035, 0.29 + i * 0.035, 0 > )
		RuiSetFloat( rui, "msgFontSize", i == 0 ? 28.0 : 24.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", 0.0 )
		RuiSetFloat3( rui, "msgColor", < 1, 1, 1 > )
		file.leaderboardRuis.append( rui )
	}
	Surf_UpdateLeaderboard()
}

void function Surf_UpdateLeaderboard()
{
	RuiSetString( file.leaderboardRuis[0], "msgText", file.leaderboardKind == "local" ? "SERVER TOP 5" : "SESSION TOP 5" )
	RuiSetString( file.leaderboardRuis[1], "msgText", "Double jump " + ( file.leaderboardDoubleJump ? "on" : "off" ) )
	for ( int i = 0; i < 5; i++ )
	{
		string text = i < file.leaderboardRows.len() ? file.leaderboardRows[i] : ( i == 0 ? "No completed runs yet" : "" )
		RuiSetString( file.leaderboardRuis[i + 2], "msgText", text )
	}
}

void function Surf_HideLeaderboard()
{
	foreach ( var rui in file.leaderboardRuis )
		RuiDestroyIfAlive( rui )
	file.leaderboardRuis.clear()
}
