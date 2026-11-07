global function Surf_Init

global const GAMEMODE_SURF = "surf"

void function Surf_Init()
{
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
	if ( GAMETYPE == GAMEMODE_SURF || GetConVarInt( "surf_restore_wallrun" ) == 0 )
		return
	SetConVarInt( "wallrun_enable", 1 )
	SetConVarInt( "surf_restore_wallrun", 0 )
}
#endif
