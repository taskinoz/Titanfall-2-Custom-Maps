global function Surf_Init
global function Surf_EncodeText
global function Surf_DecodeText

global const GAMEMODE_SURF = "surf"

void function Surf_Init()
{
	AddPrivateMatchModeSettingEnum( "#MODE_SETTING_CATEGORY_PILOT", "surf_double_jump", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "1", "#SURF_DOUBLE_JUMP" )
	AddCallback_OnCustomGamemodesInit( CreateGamemode )
	AddCallback_OnRegisteringCustomNetworkVars( SurfRegisterNetworkVars )
}

void function CreateGamemode()
{
	GameMode_Create( GAMEMODE_SURF )
	GameMode_SetName( GAMEMODE_SURF, "#GAMEMODE_SURF" )
	GameMode_SetDesc( GAMEMODE_SURF, "#SURF_DESC" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_SURF, "gnrc_modeDesc" )
	GameMode_SetEvacEnabled( GAMEMODE_SURF, false )

	GameMode_AddScoreboardColumnData( GAMEMODE_SURF, "#SCOREBOARD_SURF_FINISHED", PGS_ASSAULT_SCORE, 3 )
	GameMode_AddScoreboardColumnData( GAMEMODE_SURF, "#SCOREBOARD_SURF_BEST", PGS_DEFENSE_SCORE, 4 )
	GameMode_AddScoreboardColumnData( GAMEMODE_SURF, "#SCOREBOARD_SURF_RESETS", PGS_PILOT_KILLS, 3 )

	AddPrivateMatchMode( GAMEMODE_SURF )

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_SURF, _Surf_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_SURF, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_SURF, Cl_Surf_Init )
	#endif

	#if SERVER
		// Surf turns wallrunning off server-wide; turn it back on in every other mode.
		AddCallback_GameStateEnter( eGameState.WaitingForPlayers, Surf_RestoreDefaults )
	#endif
}

void function SurfRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_SURF )
		return

	Remote_RegisterFunction( "ServerCallback_Surf_StartRun" )
	Remote_RegisterFunction( "ServerCallback_Surf_StopRun" )
	Remote_RegisterFunction( "ServerCallback_Surf_CancelRun" )
}

#if SERVER
void function Surf_RestoreDefaults()
{
	if ( GAMETYPE == GAMEMODE_SURF )
		return
	if ( GetConVarInt( "surf_restore_wallrun" ) != 0 )
	{
		SetConVarInt( "wallrun_enable", 1 )
		SetConVarInt( "surf_restore_wallrun", 0 )
	}
	string previousAirAccelerate = GetConVarString( "surf_previous_air_accelerate" )
	if ( previousAirAccelerate != "" )
	{
		SetConVarString( "sv_airaccelerate", previousAirAccelerate )
		SetConVarString( "surf_previous_air_accelerate", "" )
	}
}
#endif

// Console-safe transport for names: never put player-supplied console syntax on
// the command line. Hex also preserves UTF-8 names and embedded spaces.
string function Surf_EncodeText( string text )
{
	string encoded = ""
	for ( int i = 0; i < text.len(); i++ )
		encoded += format( "%02x", expect int( text[i] ) & 255 )
	return encoded
}

string function Surf_DecodeText( string encoded )
{
	string digits = "0123456789abcdef"
	string text = ""
	for ( int i = 0; i + 1 < encoded.len(); i += 2 )
	{
		int hi = expect int( digits.find( encoded.slice( i, i + 1 ) ) )
		int lo = expect int( digits.find( encoded.slice( i + 1, i + 2 ) ) )
		int character = hi * 16 + lo
		text += character < 32 ? " " : format( "%c", character )
	}
	return text
}
