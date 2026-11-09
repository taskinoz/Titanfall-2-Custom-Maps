untyped
global function _Surf_Init
global function Surf_InitPlayerMovement

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
	array<vector> finishMins
	array<vector> finishMaxs
	string webUrl = ""
	string webKey = ""
	// Web leaderboard state: a problem to show players, and whether submitting is worth trying.
	string webProblem = ""
	bool webErrorShown = false
	bool webUsable = false
	// Saved scores: uid -> { name, time }.
	table records = {}
	bool recordsLoaded = false
	bool pendingRecordSave = false
	bool allowDoubleJump = true
} file

void function _Surf_Init()
{
	file.allowDoubleJump = GetCurrentPlaylistVarInt( "surf_double_jump", GetConVarInt( "surf_double_jump" ) ) != 0
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	SetLoadoutGracePeriodEnabled( false )
	SetTimerBased( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )

	// Server-wide: restored by Surf_RestoreDefaults when another mode starts.
	// The pilot keyvalue alone leaves the replicated server air control at its
	// normal value. Preserve the original across consecutive Surf maps.
	if ( GetConVarString( "surf_previous_air_accelerate" ) == "" )
		SetConVarString( "surf_previous_air_accelerate", GetConVarString( "sv_airaccelerate" ) )
	SetConVarFloat( "sv_airaccelerate", GetConVarFloat( "surf_air_acceleration" ) )
	SetConVarInt( "wallrun_enable", 0 )
	SetConVarInt( "surf_restore_wallrun", 1 )

	AddCallback_OnClientConnected( Surf_OnClientConnected )
	AddCallback_OnClientDisconnected( Surf_OnClientDisconnected )
	AddCallback_OnPlayerKilled( Surf_OnPlayerKilled )
	AddClientCommandCallback( "surf_leaderboard", Surf_LeaderboardCommand )

	getroottable().MRVN_SurfTeleported <- Surf_MapTeleported
	thread Surf_Tick()
	Surf_CheckLeaderboard()
	if ( GetConVarBool( "surf_save_scores" ) )
		Surf_LoadRecords()
	else
		file.recordsLoaded = true
}

// Northstar.Custom registers its movement callbacks in an After callback. Register
// ours afterwards as well, so its default/playlist value cannot overwrite Surf.
void function Surf_InitPlayerMovement()
{
	if ( GAMETYPE != GAMEMODE_SURF )
		return

	AddCallback_OnPlayerRespawned( Surf_OnPlayerRespawned )
	AddCallback_OnPlayerGetsNewPilotLoadout( Surf_OnPlayerGetsNewPilotLoadout )
	AddCallback_OnTitanBecomesPilot( Surf_OnPlayerChangesForm )
	AddCallback_OnPilotBecomesTitan( Surf_OnPlayerChangesForm )
}

void function Surf_ApplyPlayerMovement( entity player )
{
	if ( !player.IsTitan() )
	{
		array<string> mods = UntypedArrayToStringArray( player.GetPlayerSettingsMods() )
		int index = mods.find( "surf_disable_doublejump" )
		bool changed = false
		if ( !file.allowDoubleJump && index == -1 )
		{
			mods.append( "surf_disable_doublejump" )
			changed = true
		}
		else if ( file.allowDoubleJump && index != -1 )
		{
			mods.remove( index )
			changed = true
		}
		if ( changed )
			player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
	}
	// Settings changes can reset movement values, so apply air control last.
	player.kv.airAcceleration = GetConVarFloat( "surf_air_acceleration" )
}

void function Surf_OnPlayerGetsNewPilotLoadout( entity player, PilotLoadoutDef loadout )
{
	Surf_ApplyPlayerMovement( player )
}

void function Surf_OnPlayerChangesForm( entity player, entity titan )
{
	Surf_ApplyPlayerMovement( player )
}

void function Surf_OnClientConnected( entity player )
{
	SetTeam( player, TEAM_IMC )
	file.inStart[player] <- true
	// The boost key (default B... or whatever is bound to "Use boost") resets a run.
	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND4, Surf_Reset )
	string uid = player.GetUID()
	if ( uid in file.records )
		Surf_ApplySavedBest( player )
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
	Surf_ApplyPlayerMovement( player )
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
	if ( "finishZones" in map )
	{
		foreach ( var value in expect array( map.finishZones ) )
		{
			table zone = expect table( value )
			file.finishMins.append( expect vector( zone.mins ) )
			file.finishMaxs.append( expect vector( zone.maxs ) )
		}
	}
	file.haveMap = true
	while ( true )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( !IsAlive( player ) )
				continue
			vector origin = player.GetOrigin()
			if ( player in file.runStart && Surf_OnFinishPlatform( player, origin ) )
				Surf_FinishRun( player )
			bool inside = Surf_InStart( origin )
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

// Feet must be grounded inside a map-authored finish zone: flying over it
// or falling below its deck does not finish a run.
bool function Surf_OnFinishPlatform( entity player, vector origin )
{
	return player.IsOnGround() && Surf_InFinishZone( origin )
}

bool function Surf_InFinishZone( vector origin )
{
	for ( int i = 0; i < file.finishMins.len(); i++ )
	{
		vector lo = file.finishMins[i]
		vector hi = file.finishMaxs[i]
		if ( origin.x >= lo.x && origin.y >= lo.y && origin.z >= lo.z &&
		     origin.x <= hi.x && origin.y <= hi.y && origin.z <= hi.z )
			return true
	}
	return false
}

// Called by the map script on every teleport (the root table only holds untyped functions).
function Surf_MapTeleported( player, destination, source = null )
{
	entity pilot = expect entity( player )
	// Classify the portal by its source, before considering its destination.
	// End portals may lead to the start or the jail. Both finish an active run.
	if ( source != null && Surf_InFinishZone( expect vector( source ) ) )
		Surf_FinishRun( pilot )
	Surf_OnTeleported( pilot, expect vector( destination ) )
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
	// End portals already finished via their source zone. Other portals reset.
	if ( file.finishMins.len() > 0 )
	{
		Surf_Cancel( player )
		file.inStart[player] <- true
		return
	}
	Surf_FinishRun( player )
}

void function Surf_FinishRun( entity player )
{
	if ( !( player in file.runStart ) ) return
	float time = Time() - file.runStart[player]
	delete file.runStart[player]
	file.inStart[player] <- Surf_InStart( player.GetOrigin() )
	bool isBest = !( player in file.best ) || time < file.best[player]
	if ( isBest )
	{
		file.best[player] <- time
		player.SetPlayerGameStat( PGS_DEFENSE_SCORE, int( time + 0.5 ) )
	}
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_Surf_StopRun", time, isBest )
	Chat_ServerBroadcast( format( "%s finished in %s%s", player.GetPlayerName(), Surf_FormatTime( time ), isBest ? " (personal best)" : "" ) )
	Surf_Log( format( "completed: %s map=%s time=%.6f seconds double_jump=%d", player.GetPlayerName(), GetMapName(), time, file.allowDoubleJump ? 1 : 0 ) )
	Surf_SubmitScore( player, time )
	Surf_SaveRecord( player, time )
	Surf_BroadcastLocalLeaderboard()
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
bool function Surf_ValidLeaderboardUrl( string url )
{
	int prefix = url.find( "https://" ) == 0 ? 8 : ( url.find( "http://" ) == 0 ? 7 : 0 )
	if ( prefix == 0 || url.len() <= prefix || url.find( " " ) != null || url.find( "\n" ) != null )
		return false
	string host = url.slice( prefix )
	var slash = host.find( "/" )
	if ( slash != null ) host = host.slice( 0, expect int( slash ) )
	return host != "" && host.find( "@" ) == null && host.find( "?" ) == null && host.find( "#" ) == null
}

void function Surf_CheckLeaderboard()
{
	string url = GetConVarString( "surf_leaderboard_url" )
	string key = GetConVarString( "surf_leaderboard_key" )
	file.webKey = key
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
	if ( !Surf_ValidLeaderboardUrl( url ) )
	{
		Surf_WebError( "surf_leaderboard_url must be a full quoted http:// or https:// URL with a hostname; no web requests will be sent" )
		return
	}
	while ( url.slice( url.len() - 1 ) == "/" )
		url = url.slice( 0, url.len() - 1 )
	file.webUrl = url
	if ( !NSIsHttpEnabled() )
	{
		Surf_WebError( "Northstar HTTP requests are disabled; remove -disablehttprequests from the launch arguments for the web leaderboard" )
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
	body[ "map" ] <- Surf_RecordMap()
	body[ "name" ] <- player.GetPlayerName()
	body[ "uid" ] <- player.GetUID()
	body[ "time" ] <- time
	HttpRequest request
	request.method = HttpRequestMethod.POST
	request.url = file.webUrl + "/api.php?action=submit"
	table<string, array<string> > headers
	headers[ "x-surf-key" ] <- [ file.webKey ]
	request.headers = headers
	request.body = EncodeJSON( body )
	NSHttpRequest( request,
		void function( HttpRequestResponse response )
		{
			if ( response.statusCode == 200 )
				Surf_Log( "web leaderboard accepted the completed run" )
			else if ( response.statusCode == 403 )
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
	Chat_ServerPrivateMessage( player, "Press the scoreboard key (Tab by default) for this map's top times; surf_leaderboard in the console also lists them. Double jump " + ( file.allowDoubleJump ? "on" : "off" ) + ".", false )
	Surf_SendLocalLeaderboard( player )
	if ( file.recordsLoaded )
		Chat_ServerPrivateMessage( player, Surf_LocalTopText(), false )
	string url = file.webUrl
	if ( url != "" && NSIsHttpEnabled() )
		Surf_ShowWebTop( player, url )
}

void function Surf_ShowWebTop( entity player, string url )
{
	HttpRequest request
	request.method = HttpRequestMethod.GET
	request.url = url + "/api.php"
	table<string, array<string> > query
	query[ "action" ] <- [ "top" ]
	query[ "map" ] <- [ Surf_RecordMap() ]
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
// Latch rules for the whole map. Runs without double jump never compete with
// the existing double-jump records, locally or on the optional web leaderboard.
string function Surf_RecordMap()
{
	return GetMapName() + ( file.allowDoubleJump ? "" : "__no_double_jump" )
}

string function Surf_RecordFile()
{
	return "surf_" + Surf_RecordMap() + ".json"
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
			{
				table saved = expect table( data.scores )
				foreach ( uid, record in saved )
					if ( !( uid in file.records ) || Surf_RecordTime( record ) < Surf_RecordTime( file.records[uid] ) )
						file.records[uid] <- record
			}
			file.recordsLoaded = true
			foreach ( entity player in GetPlayerArray() )
				if ( player.GetUID() in file.records )
					Surf_ApplySavedBest( player )
			if ( file.pendingRecordSave )
				Surf_PersistRecords()
			Surf_BroadcastLocalLeaderboard()
			Surf_Log( "loaded " + file.records.len() + " saved scores from " + name )
		},
		void function() : ( name )
		{
			printl( "[Surf] ERROR: couldn't read saved scores " + name + " (missing or not JSON); existing file preserved, new records kept for this session" )
		} )
}

void function Surf_ApplySavedBest( entity player )
{
	string uid = player.GetUID()
	if ( !( uid in file.records ) )
		return
	float best = Surf_RecordTime( file.records[uid] )
	if ( !( player in file.best ) || best < file.best[player] )
		file.best[player] <- best
	player.SetPlayerGameStat( PGS_DEFENSE_SCORE, int( file.best[player] + 0.5 ) )
}

void function Surf_SaveRecord( entity player, float time )
{
	string uid = player.GetUID()
	if ( uid in file.records && Surf_RecordTime( file.records[uid] ) <= time )
		return
	file.records[uid] <- { name = player.GetPlayerName(), time = time }
	if ( !GetConVarBool( "surf_save_scores" ) )
		return
	file.pendingRecordSave = true
	if ( file.recordsLoaded )
		Surf_PersistRecords()
}

void function Surf_PersistRecords()
{
	table data = { version = 1, map = GetMapName(), double_jump = file.allowDoubleJump, scores = file.records }
	try
	{
		NSSaveJSONFile( Surf_RecordFile(), data )
		file.pendingRecordSave = false
		Surf_Log( "queued local record write: save_data/MRVN.Surf/" + Surf_RecordFile() )
	}
	catch ( ex )
	{
		printl( "[Surf] ERROR: couldn't save scores to save_data/MRVN.Surf/" + Surf_RecordFile() + " (Northstar safe I/O): " + ex )
	}
}

array<table> function Surf_SortedRecords()
{
	array<table> scores
	foreach ( uid, record in file.records )
		scores.append( expect table( record ) )
	scores.sort( int function( table a, table b )
	{
		float ta = Surf_RecordTime( a )
		float tb = Surf_RecordTime( b )
		if ( ta < tb ) return -1
		if ( ta > tb ) return 1
		return 0
	} )
	return scores
}

void function Surf_SendLocalLeaderboard( entity player )
{
	if ( !IsValid( player ) )
		return
	string kind = GetConVarBool( "surf_save_scores" ) && file.recordsLoaded ? "local" : "session"
	ServerToClientStringCommand( player, "SurfLeaderboard begin " + kind + " " + ( file.allowDoubleJump ? "1" : "0" ) )
	array<table> scores = Surf_SortedRecords()
	for ( int i = 0; i < scores.len() && i < SURF_SCORES_SHOWN; i++ )
	{
		table score = scores[i]
		string name = expect string( score.name )
		if ( name.len() > 64 ) name = name.slice( 0, 64 )
		if ( name == "" ) name = "Player"
		ServerToClientStringCommand( player, format( "SurfLeaderboard row %d %.6f %s", i + 1, Surf_RecordTime( score ), Surf_EncodeText( name ) ) )
	}
}

void function Surf_BroadcastLocalLeaderboard()
{
	foreach ( entity player in GetPlayerArray() )
		Surf_SendLocalLeaderboard( player )
}

bool function Surf_LeaderboardCommand( entity player, array<string> args )
{
	Surf_SendLocalLeaderboard( player )
	Chat_ServerPrivateMessage( player, Surf_LocalTopText(), false )
	string url = file.webUrl
	if ( url != "" && NSIsHttpEnabled() ) Surf_ShowWebTop( player, url )
	return true
}

string function Surf_LocalTopText()
{
	array<table> scores = Surf_SortedRecords()
	string text = "Server records on " + GetMapName() + " (double jump " + ( file.allowDoubleJump ? "on" : "off" ) + "):"
	for ( int i = 0; i < scores.len() && i < SURF_SCORES_SHOWN; i++ )
		text += format( "\n%d. %s  %s", i + 1, expect string( scores[i].name ), Surf_FormatTime( expect float( scores[i].time.tofloat() ) ) )
	if ( scores.len() == 0 )
		text += " none yet"
	return text
}
