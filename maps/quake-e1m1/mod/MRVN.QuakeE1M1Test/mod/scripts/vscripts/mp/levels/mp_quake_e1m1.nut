global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	// No navmesh or Titan drop space: replacement Titans would fail to find a
	// spawn point (_replacement_titans_drop.gnut, empty array).
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	print( "MRVN E1M1 experimental geometry test loaded" )
}
