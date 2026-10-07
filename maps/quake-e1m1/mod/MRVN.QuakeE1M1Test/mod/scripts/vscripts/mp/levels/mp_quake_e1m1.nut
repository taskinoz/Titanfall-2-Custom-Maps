global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	print( "MRVN E1M1 experimental geometry test loaded" )
}
