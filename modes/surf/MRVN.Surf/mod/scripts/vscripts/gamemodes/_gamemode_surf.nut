untyped
global function _Surf_Init

// Surf: everyone on one side (no teams, no damage between players), no titans or boosts, no time
// limit, surf movement settings applied on spawn, and timed runs.
//
// A run starts when a pilot leaves the map's start room and finishes when a map teleport sends
// them back into it (the end of the course). Any other teleport (a fail floor, the jail) or a death
// ends the run without a time. Maps tell the mode where the start room is through the root table
// (MRVN_SurfMap, set by MRVN-Radiant's surf map scripts) and call MRVN_SurfTeleported on each
// teleport. Finished times go to the web leaderboard when surf_leaderboard_url is set.

const float SURF_TICK = 0.05
const int SURF_SCORES_SHOWN = 5

struct
{
	table<entity, bool> inStart
	table<entity, float> runStart
	table<entity, float> best
	vector startMins
	vector startMaxs
	bool haveMap = false
} file

void function _Surf_Init()
{
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	SetLoadoutGracePeriodEnabled( false )
	SetTimerBased( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )

	// Server-wide: restored by Surf_RestoreDefaults when another mode starts.
	SetConVarInt( "wallrun_enable", 0 )
	SetConVarInt( "surf_restore_wallrun", 1 )

	AddCallback_OnClientConnected( Surf_OnClientConnected )
	AddCallback_OnClientDisconnected( Surf_OnClientDisconnected )
	AddCallback_OnPlayerRespawned( Surf_OnPlayerRespawned )
	AddCallback_OnPlayerKilled( Surf_OnPlayerKilled )

	getroottable().MRVN_SurfTeleported <- Surf_MapTeleported
	thread Surf_Tick()
	thread Surf_FetchScores( null )
}

void function Surf_OnClientConnected( entity player )
{
	SetTeam( player, TEAM_IMC )
	file.inStart[player] <- true
	// The boost key (default B... or whatever is bound to "Use boost") resets a run.
	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND4, Surf_Reset )
	thread Surf_FetchScores( player )
}

void function Surf_OnClientDisconnected( entity player )
{
	if ( player in file.inStart )
		delete file.inStart[player]
	if ( player in file.runStart )
		delete file.runStart[player]
	if ( player in file.best )
		delete file.best[player]
}

void function Surf_OnPlayerRespawned( entity player )
{
	// Pilots strafe on ramps much like Source players with a high sv_airaccelerate.
	player.kv.airAcceleration = GetConVarFloat( "surf_air_acceleration" )
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )
	foreach ( int slot in [ OFFHAND_ORDNANCE, OFFHAND_SPECIAL ] )
		if ( IsValid( player.GetOffhandWeapon( slot ) ) )
			player.TakeOffhandWeapon( slot )
	// Bare hands: the only thing to hold while surfing.
	if ( !IsValid( player.GetOffhandWeapon( OFFHAND_MELEE ) ) )
		player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )
	PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
	Surf_Cancel( player )
}

void function Surf_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	Surf_Cancel( victim )
}

void function Surf_Reset( entity player )
{
	if ( !IsAlive( player ) || !file.haveMap )
		return
	Surf_Cancel( player )
	player.SetPlayerGameStat( PGS_PILOT_KILLS, player.GetPlayerGameStat( PGS_PILOT_KILLS ) + 1 )
	table map = expect table( getroottable().MRVN_SurfMap )
	player.SetOrigin( expect vector( map.startOrigin ) )
	player.SetAngles( < 0, expect float( map.startYaw ), 0 > )
	player.SetVelocity( < 0, 0, 0 > )
	file.inStart[player] <- true
}

bool function Surf_InStart( vector o )
{
	vector lo = file.startMins
	vector hi = file.startMaxs
	return o.x >= lo.x && o.y >= lo.y && o.z >= lo.z && o.x <= hi.x && o.y <= hi.y && o.z <= hi.z
}

// Starts a run when a pilot leaves the start room.
void function Surf_Tick()
{
	while ( !( "MRVN_SurfMap" in getroottable() ) )
		wait 1.0
	table map = expect table( getroottable().MRVN_SurfMap )
	file.startMins = expect vector( map.startMins )
	file.startMaxs = expect vector( map.startMaxs )
	file.haveMap = true
	while ( true )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( !IsAlive( player ) )
				continue
			bool inside = Surf_InStart( player.GetOrigin() )
			bool was = player in file.inStart ? file.inStart[player] : false
			if ( was && !inside && !( player in file.runStart ) )
			{
				file.runStart[player] <- Time()
				float best = player in file.best ? file.best[player] : -1.0
				Remote_CallFunction_NonReplay( player, "ServerCallback_Surf_StartRun", Time(), best )
			}
			file.inStart[player] <- inside
		}
		wait SURF_TICK
	}
}

// Called by the map script on every teleport (the root table only holds untyped functions).
function Surf_MapTeleported( player, destination )
{
	Surf_OnTeleported( expect entity( player ), expect vector( destination ) )
}

void function Surf_OnTeleported( entity player, vector destination )
{
	// Teleported out of the start room's reach (a fail floor, the jail): not a run start.
	if ( !Surf_InStart( destination ) )
	{
		file.inStart[player] <- false
		Surf_Cancel( player )
		return
	}
	if ( !( player in file.runStart ) )
	{
		file.inStart[player] <- true
		return
	}
	float time = Time() - file.runStart[player]
	delete file.runStart[player]
	file.inStart[player] <- true
	bool isBest = !( player in file.best ) || time < file.best[player]
	if ( isBest )
	{
		file.best[player] <- time
		player.SetPlayerGameStat( PGS_DEFENSE_SCORE, int( time + 0.5 ) )
	}
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_Surf_StopRun", time, isBest )
	Chat_ServerBroadcast( format( "%s finished in %s%s", player.GetPlayerName(), Surf_FormatTime( time ), isBest ? " (personal best)" : "" ) )
	Surf_SubmitScore( player, time )
}

void function Surf_Cancel( entity player )
{
	if ( !( player in file.runStart ) )
		return
	delete file.runStart[player]
	if ( IsValid( player ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_Surf_CancelRun" )
}

string function Surf_FormatTime( float time )
{
	int minutes = int( time / 60.0 )
	float seconds = time - minutes * 60.0
	if ( minutes > 0 )
		return format( "%d:%06.3f", minutes, seconds )
	return format( "%.3f s", seconds )
}

// Web leaderboard (modes/surf/leaderboard in Titanfall-2-Custom-Maps).
void function Surf_SubmitScore( entity player, float time )
{
	string url = GetConVarString( "surf_leaderboard_url" )
	if ( url == "" )
		return
	table body = {}
	body[ "map" ] <- GetMapName()
	body[ "name" ] <- player.GetPlayerName()
	body[ "uid" ] <- player.GetUID()
	body[ "time" ] <- time
	HttpRequest request
	request.method = HttpRequestMethod.POST
	request.url = url + "/api.php?action=submit"
	table<string, array<string> > headers
	headers[ "x-surf-key" ] <- [ GetConVarString( "surf_leaderboard_key" ) ]
	request.headers = headers
	request.body = EncodeJSON( body )
	NSHttpRequest( request,
		void function( HttpRequestResponse response )
		{
			if ( response.statusCode != 200 )
				printl( "[Surf] leaderboard rejected a time: " + response.statusCode + " " + response.body )
		},
		void function( HttpRequestFailure failure )
		{
			printl( "[Surf] leaderboard unreachable: " + failure.errorMessage )
		} )
}

// Shows the map's top times in chat: to one player when they join, or to everyone.
void function Surf_FetchScores( entity player )
{
	string url = GetConVarString( "surf_leaderboard_url" )
	if ( url == "" )
		return
	if ( IsValid( player ) )
		wait 5.0
	HttpRequest request
	request.method = HttpRequestMethod.GET
	request.url = url + "/api.php"
	table<string, array<string> > query
	query[ "action" ] <- [ "top" ]
	query[ "map" ] <- [ GetMapName() ]
	query[ "limit" ] <- [ string( SURF_SCORES_SHOWN ) ]
	request.queryParameters = query
	NSHttpRequest( request,
		void function( HttpRequestResponse response ) : ( player )
		{
			if ( response.statusCode != 200 )
				return
			table data = DecodeJSON( "{\"scores\":" + response.body + "}" )
			array scores = expect array( data[ "scores" ] )
			string text = "World records on " + GetMapName() + ":"
			int rank = 1
			foreach ( var value in scores )
			{
				table score = expect table( value )
				text += format( "\n%d. %s  %s", rank, expect string( score[ "name" ] ), Surf_FormatTime( expect float( score[ "time" ] ) ) )
				rank++
			}
			if ( scores.len() == 0 )
				text += " none yet"
			if ( IsValid( player ) )
				Chat_ServerPrivateMessage( player, text, false )
			else if ( player == null )
				Chat_ServerBroadcast( text )
		},
		void function( HttpRequestFailure failure )
		{
			printl( "[Surf] leaderboard unreachable: " + failure.errorMessage )
		} )
}
