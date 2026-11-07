untyped
global function _Surf_Init

// Surf: everyone on one side (no teams, no damage between players), no titans or boosts, no time
// limit, surf movement settings applied on spawn, and timed runs.
//
// A run starts when a pilot leaves the map's start room and finishes when a map teleport sends
// them back into it (the end of the course). Any other teleport (a fail floor, the jail) or a death
// ends the run without a time. Maps tell the mode where the start room is through the root table
// (MRVN_SurfMap, set by MRVN-Radiant's surf map scripts) and call MRVN_SurfTeleported on each
// teleport.
//
// Scores: finished times go to the web leaderboard when surf_leaderboard_url and
// surf_leaderboard_key are set (the key is checked at map start), and to
// R2Northstar/save_data/MRVN.Surf/surf_<map>.json when surf_save_scores is 1 (Northstar safe I/O).
// Configuration problems and rejected keys are logged as "[Surf] ERROR" and shown in chat.

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
	// Web leaderboard state: a problem to show players, and whether submitting is worth trying.
	string webProblem = ""
	bool webErrorShown = false
	bool webUsable = false
	// Saved scores: uid -> { name, time }.
	table records = {}
	bool recordsLoaded = false
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
	Surf_CheckLeaderboard()
	if ( GetConVarBool( "surf_save_scores" ) )
		Surf_LoadRecords()
}

void function Surf_OnClientConnected( entity player )
{
	SetTeam( player, TEAM_IMC )
	file.inStart[player] <- true
	// The boost key (default B... or whatever is bound to "Use boost") resets a run.
	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND4, Surf_Reset )
	string uid = player.GetUID()
	if ( uid in file.records )
		file.best[player] <- Surf_RecordTime( file.records[uid] )
	thread Surf_Greet( player )
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
	Surf_SaveRecord( player, time )
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

void function Surf_Log( string text )
{
	printl( "[Surf] " + text )
}

// Logged, told to everyone once, and to each player who joins later.
void function Surf_WebError( string text )
{
	file.webProblem = text
	file.webUsable = false
	printl( "[Surf] ERROR: " + text )
	if ( !file.webErrorShown )
	{
		file.webErrorShown = true
		Chat_ServerBroadcast( "Leaderboard error: " + text )
	}
}

// Web leaderboard (modes/surf/leaderboard in Titanfall-2-Custom-Maps).
void function Surf_CheckLeaderboard()
{
	string url = GetConVarString( "surf_leaderboard_url" )
	string key = GetConVarString( "surf_leaderboard_key" )
	if ( url == "" && key == "" )
	{
		file.webProblem = "the web leaderboard is off (surf_leaderboard_url and surf_leaderboard_key are not set)"
		Surf_Log( file.webProblem )
		return
	}
	if ( url == "" )
	{
		Surf_WebError( "surf_leaderboard_key is set but surf_leaderboard_url is empty, so times are not sent anywhere" )
		return
	}
	if ( key == "" )
	{
		Surf_WebError( "surf_leaderboard_url is set but surf_leaderboard_key is empty, so the leaderboard would reject every time" )
		return
	}
	HttpRequest request
	request.method = HttpRequestMethod.POST
	request.url = url + "/api.php?action=check"
	table<string, array<string> > headers
	headers[ "x-surf-key" ] <- [ key ]
	request.headers = headers
	request.body = "{}"
	NSHttpRequest( request,
		void function( HttpRequestResponse response ) : ( url )
		{
			if ( response.statusCode == 200 )
			{
				file.webUsable = true
				Surf_Log( "the leaderboard at " + url + " accepted this server's key" )
			}
			else if ( response.statusCode == 403 )
				Surf_WebError( "the leaderboard at " + url + " rejected surf_leaderboard_key, so times are not saved there" )
			else
				Surf_WebError( "the leaderboard at " + url + " answered " + response.statusCode + " to a key check; is surf_leaderboard_url right?" )
		},
		void function( HttpRequestFailure failure ) : ( url )
		{
			Surf_WebError( "the leaderboard at " + url + " is unreachable (" + failure.errorMessage + ")" )
		} )
}

void function Surf_SubmitScore( entity player, float time )
{
	if ( !file.webUsable )
		return
	table body = {}
	body[ "map" ] <- GetMapName()
	body[ "name" ] <- player.GetPlayerName()
	body[ "uid" ] <- player.GetUID()
	body[ "time" ] <- time
	HttpRequest request
	request.method = HttpRequestMethod.POST
	request.url = GetConVarString( "surf_leaderboard_url" ) + "/api.php?action=submit"
	table<string, array<string> > headers
	headers[ "x-surf-key" ] <- [ GetConVarString( "surf_leaderboard_key" ) ]
	request.headers = headers
	request.body = EncodeJSON( body )
	NSHttpRequest( request,
		void function( HttpRequestResponse response )
		{
			if ( response.statusCode == 403 )
				Surf_WebError( "the leaderboard rejected surf_leaderboard_key, so times are not saved there" )
			else if ( response.statusCode != 200 )
				Surf_Log( "the leaderboard rejected a time: " + response.statusCode + " " + response.body )
		},
		void function( HttpRequestFailure failure )
		{
			Surf_Log( "the leaderboard is unreachable: " + failure.errorMessage )
		} )
}

// On joining: any leaderboard problem, then the map's top times (web if set up, else saved).
void function Surf_Greet( entity player )
{
	wait 5.0
	if ( !IsValid( player ) )
		return
	if ( file.webProblem != "" )
		Chat_ServerPrivateMessage( player, "Leaderboard: " + file.webProblem, false )
	string url = GetConVarString( "surf_leaderboard_url" )
	if ( url != "" )
	{
		Surf_ShowWebTop( player, url )
		return
	}
	if ( file.recordsLoaded )
		Chat_ServerPrivateMessage( player, Surf_LocalTopText(), false )
}

void function Surf_ShowWebTop( entity player, string url )
{
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
			if ( response.statusCode != 200 || !IsValid( player ) )
				return
			table data = DecodeJSON( "{\"scores\":" + response.body + "}" )
			array scores = expect array( data[ "scores" ] )
			string text = "World records on " + GetMapName() + ":"
			int rank = 1
			foreach ( var value in scores )
			{
				table score = expect table( value )
				text += format( "\n%d. %s  %s", rank, expect string( score[ "name" ] ), Surf_FormatTime( Surf_RecordTime( score ) ) )
				rank++
			}
			if ( scores.len() == 0 )
				text += " none yet"
			Chat_ServerPrivateMessage( player, text, false )
		},
		void function( HttpRequestFailure failure )
		{
			Surf_Log( "the leaderboard is unreachable: " + failure.errorMessage )
		} )
}

// Saved scores (surf_save_scores 1): Northstar safe I/O, in R2Northstar/save_data/MRVN.Surf/.
string function Surf_RecordFile()
{
	return "surf_" + GetMapName() + ".json"
}

float function Surf_RecordTime( var record )
{
	return expect float( expect table( record ).time.tofloat() )
}

void function Surf_LoadRecords()
{
	string name = Surf_RecordFile()
	bool exists = false
	try
	{
		exists = NSDoesFileExist( name )
	}
	catch ( ex )
	{
		printl( "[Surf] ERROR: surf_save_scores is 1 but Northstar safe I/O failed checking save_data/MRVN.Surf/" + name + ": " + ex + "; scores are not saved to disk" )
		return
	}
	if ( !exists )
	{
		file.recordsLoaded = true
		Surf_Log( "no saved scores yet for this map; they will be saved to save_data/MRVN.Surf/" + name )
		return
	}
	NSLoadJSONFile( name,
		void function( table data ) : ( name )
		{
			if ( "scores" in data )
				file.records = expect table( data.scores )
			file.recordsLoaded = true
			foreach ( entity player in GetPlayerArray() )
				if ( player.GetUID() in file.records )
					file.best[player] <- Surf_RecordTime( file.records[player.GetUID()] )
			Surf_Log( "loaded " + file.records.len() + " saved scores from " + name )
		},
		void function() : ( name )
		{
			printl( "[Surf] ERROR: couldn't read saved scores " + name + " (missing or not JSON); starting this map's scores again" )
			file.recordsLoaded = true
		} )
}

void function Surf_SaveRecord( entity player, float time )
{
	if ( !GetConVarBool( "surf_save_scores" ) || !file.recordsLoaded )
		return
	string uid = player.GetUID()
	if ( uid in file.records && Surf_RecordTime( file.records[uid] ) <= time )
		return
	file.records[uid] <- { name = player.GetPlayerName(), time = time }
	table data = { version = 1, map = GetMapName(), scores = file.records }
	try
	{
		NSSaveJSONFile( Surf_RecordFile(), data )
	}
	catch ( ex )
	{
		printl( "[Surf] ERROR: couldn't save scores to save_data/MRVN.Surf/" + Surf_RecordFile() + " (Northstar safe I/O): " + ex )
	}
}

string function Surf_LocalTopText()
{
	array<table> scores
	foreach ( uid, record in file.records )
		scores.append( expect table( record ) )
	scores.sort( int function( table a, table b )
	{
		float ta = expect float( a.time.tofloat() )
		float tb = expect float( b.time.tofloat() )
		if ( ta < tb )
			return -1
		if ( ta > tb )
			return 1
		return 0
	} )
	string text = "Server records on " + GetMapName() + ":"
	for ( int i = 0; i < scores.len() && i < SURF_SCORES_SHOWN; i++ )
		text += format( "\n%d. %s  %s", i + 1, expect string( scores[i].name ), Surf_FormatTime( expect float( scores[i].time.tofloat() ) ) )
	if ( scores.len() == 0 )
		text += " none yet"
	return text
}
