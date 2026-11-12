untyped
global function CodeCallback_MapInit
struct
{
 array<vector> mins
 array<vector> maxs
 array<vector> destinations
 array<float> yaws
 array<int> choices
 array<int> brushFirst
 array<int> brushEnd
 array<vector> pushMins
 array<vector> pushMaxs
 array<vector> pushVelocities
 array<int> pushBrushFirst
 array<int> pushBrushEnd
 array<vector> planeNormals
 array<float> planeDists
 array<int> planeEnds
 table<entity, float> rampTimes
 table<entity, vector> rampVelocities
 table<entity, float> traceUntil
 table<entity, vector> lastVel
 table<entity, vector> teleportOrigins
 table<entity, vector> lastOrigin
 table<entity, float> lastTime
} file
void function CodeCallback_MapInit()
{
 ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
 ClassicMP_ForceDisableEpilogue( true )
 Riff_ForceTitanAvailability( eTitanAvailability.Never )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 992.0, 736.0, 64.0, 2016.0, 448.0, -440.0 ] )
 AddTeleport( < -992, -64, -448 >, < 736, 2016, -440 >, < -128, 0, 525.946 >, 90, 1, 0, 1 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 368.0, -144.0, -2632.0, 2640.0, 32.0, 208.0 ] )
 AddTeleport( < -368, 2632, -32 >, < -144, 2640, 208 >, < -128, 0, 525.946 >, 90, 1, 1, 2 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 736.0, 224.0, -2592.0, 3808.0, 96.0, -80.0 ] )
 AddTeleport( < -736, 2592, -96 >, < 224, 3808, -80 >, < -256, 3328, -31 >, 270, 1, 2, 3 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 240.0, -16.0, -2000.0, 2008.0, 384.0, -144.0 ] )
 AddTeleport( < -240, 2000, -384 >, < -16, 2008, -144 >, < 2528, 2240, 672 >, 90, 1, 3, 4 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1664.0, 3392.0, -2144.0, 3552.0, 128.0, -120.0 ] )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1024.0, 4032.0, -3552.0, 4384.0, 128.0, -120.0 ] )
 AddTeleport( < 1024, 2144, -128 >, < 4032, 4384, -120 >, < 2528, 2240, 672 >, 90, 1, 4, 6 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1312.0, 3680.0, 224.0, 1760.0, 208.0, -207.0 ] )
 AddTeleport( < 1312, -224, -208 >, < 3680, 1760, -207 >, < 1456, 272, 928 >, 0, 1, 6, 7 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1064.0, 1072.0, -3856.0, 4080.0, 64.0, 176.0 ] )
 AddTeleport( < 1064, 3856, -64 >, < 1072, 4080, 176 >, < 1456, 272, 928 >, 0, 1, 7, 8 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -3984.0, 3992.0, -3856.0, 4080.0, 64.0, 176.0 ] )
 AddTeleport( < 3984, 3856, -64 >, < 3992, 4080, 176 >, < 1456, 272, 928 >, 0, 1, 8, 9 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1320.0, 1328.0, -1200.0, 1424.0, -272.0, 512.0 ] )
 AddTeleport( < 1320, 1200, 272 >, < 1328, 1424, 512 >, < 2720, 5888, 832 >, 180, 1, 9, 10 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 >, < -0.64222, 0, 0.766521 >, < 0.640184, 0, -0.768221 > ], [ 528.0, 64.0, -5248.0, 6528.0, 768.0, -272.0, -249.6, 262.2 ] )
 AddTeleport( < -528, 5248, -768 >, < 64, 6528, -272 >, < 2720, 5888, 832 >, 180, 1, 10, 11 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 >, < 0.64222, 0, 0.766521 >, < -0.640184, 0, -0.768221 > ], [ 2384.0, -1792.0, -5248.0, 6528.0, 768.0, -272.0, -1739.5, 1747.4 ] )
 AddTeleport( < -2384, 5248, -768 >, < -1792, 6528, -272 >, < 2720, 5888, 832 >, 180, 1, 11, 12 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -160.0, 2784.0, -5280.0, 6496.0, 224.0, -223.0 ] )
 AddTeleport( < 160, 5280, -224 >, < 2784, 6496, -223 >, < 2720, 5888, 832 >, 180, 1, 12, 13 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -97.0, 191.0, -5280.0, 6496.0, -352.0, 353.0 ] )
 AddTeleport( < 97, 5280, 352 >, < 191, 6496, 353 >, < 2720, 5888, 832 >, 180, 1, 13, 14 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -64.0, 128.0, -5280.0, 6496.0, 320.0, -272.0 ] )
 AddTeleport( < 64, 5280, -320 >, < 128, 6496, -272 >, < 2720, 5888, 832 >, 180, 1, 14, 15 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 1920.0, -384.0, -5280.0, 6496.0, 672.0, -671.0 ] )
 AddTeleport( < -1920, 5280, -672 >, < -384, 6496, -671 >, < 2720, 5888, 832 >, 180, 1, 15, 16 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2776.0, -2768.0, -5776.0, 6000.0, 208.0, 32.0 ] )
 AddTeleport( < -2776, 5776.01, -208 >, < -2768, 6000.01, 32 >, < -5792, -1632, 2736 >, 0, 1, 16, 17 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 5920.0, -2496.0, 2400.0, -864.0, -1264.0, 1265.0 ] )
 AddTeleport( < -5920, -2400, 1264 >, < -2496, -864, 1265 >, < -5792, -1632, 2736 >, 0, 1, 17, 18 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2495.0, -2465.0, 2400.0, -864.0, -1296.0, 1297.0 ] )
 AddTeleport( < -2495, -2400, 1296 >, < -2465, -864, 1297 >, < -5792, -1632, 2736 >, 0, 1, 18, 19 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2110.0, -2080.0, 2400.0, -864.0, -1296.0, 1297.0 ] )
 AddTeleport( < -2110, -2400, 1296 >, < -2080, -864, 1297 >, < -5792, -1632, 2736 >, 0, 1, 19, 20 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2080.0, -1728.0, 2400.0, -864.0, -1264.0, 1265.0 ] )
 AddTeleport( < -2080, -2400, 1264 >, < -1728, -864, 1265 >, < -5792, -1632, 2736 >, 0, 1, 20, 21 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2688.0, 1344.0, 2400.0, -864.0, -112.0, 113.0 ] )
 AddTeleport( < -2688, -2400, 112 >, < 1344, -864, 113 >, < -5792, -1632, 2736 >, 0, 1, 21, 22 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 >, < 0, -0.707107, 0.707107 >, < 0, 0.707107, -0.707107 > ], [ 2912.0, -1728.0, -3856.0, 4480.0, -1025.0, 1649.0, -2001.8, 2002.5 ] )
 AddTeleport( < -2912, 3856, 1025 >, < -1728, 4480, 1649 >, < -2320, 104, 2392 >, 90, 1, 22, 23 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2912.0, -1728.0, -32.0, 3040.0, -1072.0, 1073.0 ] )
 AddTeleport( < -2912, 32, 1072 >, < -1728, 3040, 1073 >, < -2320, 104, 2392 >, 90, 1, 23, 24 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2912.0, -1728.0, -3041.0, 3071.0, -1088.0, 1089.0 ] )
 AddTeleport( < -2912, 3041, 1088 >, < -1728, 3071, 1089 >, < -2320, 104, 2392 >, 90, 1, 24, 25 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2912.0, -1728.0, 0.0, 3856.0, -48.0, 49.0 ] )
 AddTeleport( < -2912, 0, 48 >, < -1728, 3856, 49 >, < -2320, 104, 2392 >, 90, 1, 25, 26 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2912.0, -1728.0, -2721.0, 2782.0, -2048.0, 2049.0 ] )
 AddTeleport( < -2912, 2721, 2048 >, < -1728, 2782, 2049 >, < -2320, 104, 2392 >, 90, 1, 26, 27 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 2432.0, -2208.0, -8.0, 16.0, -592.0, 832.0 ] )
 AddTeleport( < -2432, 8, 592 >, < -2208, 16, 832 >, < -5312, 640, 2784 >, 90, 1, 27, 28 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -1328.0, 1336.0, 1744.0, -1520.0, -720.0, 960.0 ] )
 AddTeleport( < 1328, -1744, 720 >, < 1336, -1520, 960 >, < -2320, 104, 2392 >, 90, 1, 28, 29 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 128.0, -112.0, -2600.0, 2616.0, -168.0, 192.0 ] )
 AddTeleport( < -128, 2600, 168 >, < -112, 2616, 192 >, < -144, 2624, 225 >, 180, 1, 29, 30 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ -160.0, 168.0, -4320.0, 4544.0, -224.0, 464.0 ] )
 AddTeleport( < 160, 4320.01, 224 >, < 168, 4544.01, 464 >, < -256, 3328, -31 >, 270, 1, 30, 31 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 736.0, -672.0, -2960.0, 2968.0, -264.0, 328.0 ] )
 AddTeleport( < -736, 2960, 264 >, < -672, 2968, 328 >, < -592, 4432, 225 >, 0, 1, 31, 32 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 6048.0, -4576.0, -544.0, 4608.0, -848.0, 849.0 ] )
 AddTeleport( < -6048, 544, 848 >, < -4576, 4608, 849 >, < -5312, 640, 2784 >, 90, 1, 32, 33 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 6816.0, -3808.0, -4608.0, 5344.0, -848.0, 849.0 ] )
 AddTeleport( < -6816, 4608, 848 >, < -3808, 5344, 849 >, < -5312, 640, 2784 >, 90, 1, 33, 34 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 6816.0, -6080.0, -1920.0, 4608.0, -848.0, 849.0 ] )
 AddTeleport( < -6816, 1920, 848 >, < -6080, 4608, 849 >, < -5312, 640, 2784 >, 90, 1, 34, 35 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 4544.0, -3808.0, -1920.0, 4608.0, -848.0, 849.0 ] )
 AddTeleport( < -4544, 1920, 848 >, < -3808, 4608, 849 >, < -5312, 640, 2784 >, 90, 1, 35, 36 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 4544.0, -3808.0, -1857.0, 1919.0, -1216.0, 1217.0 ] )
 AddTeleport( < -4544, 1857, 1216 >, < -3808, 1919, 1217 >, < -5312, 640, 2784 >, 90, 1, 36, 37 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 6816.0, -6080.0, -1857.0, 1919.0, -1216.0, 1217.0 ] )
 AddTeleport( < -6816, 1857, 1216 >, < -6080, 1919, 1217 >, < -5312, 640, 2784 >, 90, 1, 37, 38 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 6848.0, -3776.0, -1376.0, 5344.0, 336.0, -335.0 ] )
 AddTeleport( < -6848, 1376, -336 >, < -3776, 5344, -335 >, < -5312, 640, 2784 >, 90, 1, 38, 39 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 5424.0, -5200.0, -5232.0, 5240.0, 264.0, -24.0 ] )
 AddTeleport( < -5424.01, 5232, -264 >, < -5200.01, 5240, -24 >, < -5847.88, 7312, -656 >, 270, 1, 39, 40 )
 AddBrush( [ < -1, 0, 0 >, < 1, 0, 0 >, < 0, -1, 0 >, < 0, 1, 0 >, < 0, 0, -1 >, < 0, 0, 1 > ], [ 5904.0, -5792.0, -7232.0, 7392.0, 400.0, -384.0 ] )
 AddTeleport( < -5904, 7232, -400 >, < -5792, 7392, -384 >, < -5846.97, 7287.17, -196.456 >, 270, 1, 40, 41 )
 thread KillFallenPilots()
 getroottable().MRVN_SurfMap <- { startMins = < -480, -32, 300 >, startMaxs = < 224, 288, 700 >, startOrigin = < -128, 128, 320 >, startYaw = 90.0, finishZones = [ { mins = < -5456, 5200, -296 >, maxs = < -5168, 5272, 8 > } ], checkpointOrigins = [ < 2528, 2240, 672 >, < 1456, 272, 928 >, < 2720, 5888, 832 >, < -5792, -1632, 2736 >, < -2320, 104, 2392 >, < -5312, 640, 2784 > ] }
 thread SurfRamps()
}
// A convex trigger brush: its planes, outward normals, in world space.
void function AddBrush( array<vector> normals, array<float> dists )
{
 for ( int i = 0; i < normals.len(); i++ )
 {
  file.planeNormals.append( normals[i] )
  file.planeDists.append( dists[i] )
 }
 file.planeEnds.append( file.planeNormals.len() )
}
// Whether a standing pilot's hull (32x32x72, origin at the feet) overlaps any of brushes
// [first, end); with none listed, the bounding box test alone decides.
bool function TouchesBrushes( vector o, int first, int end )
{
 if ( first == end )
  return true
 vector c = o + <0, 0, 36>
 for ( int b = first; b < end; b++ )
 {
  int p = 0
  if ( b > 0 )
   p = file.planeEnds[b - 1]
  bool inside = true
  for ( ; p < file.planeEnds[b]; p++ )
  {
   vector n = file.planeNormals[p]
   float reach = fabs( n.x ) * 16.0 + fabs( n.y ) * 16.0 + fabs( n.z ) * 36.0
   if ( DotProduct( n, c ) - file.planeDists[p] > reach )
   {
    inside = false
    break
   }
  }
  if ( inside )
   return true
 }
 return false
}
// Clip the pilot's swept hull against the original convex trigger planes.
// A two-unit reset floor can be crossed entirely between the 50 ms checks.
float function BrushSweepFraction( vector from, vector to, int first, int end )
{
 float best = 2.0
 for ( int b = first; b < end; b++ )
 {
  int p = b > 0 ? file.planeEnds[b - 1] : 0
  float enter = 0.0
  float leave = 1.0
  bool miss = false
  for ( ; p < file.planeEnds[b]; p++ )
  {
   vector n = file.planeNormals[p]
   float reach = fabs( n.x ) * 16.0 + fabs( n.y ) * 16.0 + fabs( n.z ) * 36.0 + 0.25
   float a = DotProduct( n, from + < 0, 0, 36 > ) - file.planeDists[p] - reach
   float z = DotProduct( n, to + < 0, 0, 36 > ) - file.planeDists[p] - reach
   if ( a > 0.0 && z > 0.0 ) { miss = true; break }
   if ( a <= 0.0 && z <= 0.0 ) continue
   float t = a / ( a - z )
   if ( a > z ) enter = max( enter, t )
   else leave = min( leave, t )
   if ( enter > leave ) { miss = true; break }
  }
  if ( !miss ) best = min( best, enter )
 }
 return best <= 1.0 ? best : -1.0
}
float function BoxSweepFraction( vector from, vector to, vector lo, vector hi )
{
 array<float> a = [ from.x, from.y, from.z ]
 array<float> z = [ to.x, to.y, to.z ]
 array<float> mins = [ lo.x, lo.y, lo.z ]
 array<float> maxs = [ hi.x, hi.y, hi.z ]
 float enter = 0.0
 float leave = 1.0
 for ( int axis = 0; axis < 3; axis++ )
 {
  float delta = z[axis] - a[axis]
  if ( fabs( delta ) < 0.00001 )
  {
   if ( a[axis] < mins[axis] || a[axis] > maxs[axis] ) return -1.0
   continue
  }
  float t0 = ( mins[axis] - a[axis] ) / delta
  float t1 = ( maxs[axis] - a[axis] ) / delta
  enter = max( enter, min( t0, t1 ) )
  leave = min( leave, max( t0, t1 ) )
  if ( enter > leave ) return -1.0
 }
 return enter
}
void function AddTeleport( vector mins, vector maxs, vector destination, float yaw, int choices, int brushFirst, int brushEnd )
{
 // Players touch a trigger when their hull overlaps it; origins are at the feet.
 file.mins.append( mins - <16.25, 16.25, 72.25> )
 file.maxs.append( maxs + <16.25, 16.25, 0.25> )
 file.destinations.append( destination )
 file.yaws.append( yaw )
 // The first of `choices` consecutive entries with this box; one is picked at random.
 file.choices.append( choices )
 file.brushFirst.append( brushFirst )
 file.brushEnd.append( brushEnd )
}
void function AddPush( vector mins, vector maxs, vector velocity, int brushFirst, int brushEnd )
{
 file.pushMins.append( mins - <16, 16, 72> )
 file.pushMaxs.append( maxs + <16, 16, 0> )
 file.pushVelocities.append( velocity )
 file.pushBrushFirst.append( brushFirst )
 file.pushBrushEnd.append( brushEnd )
}
// trigger_push: while inside, the player moves at least the push speed along its direction.
void function ApplyPushes( entity player, vector o )
{
 for ( int i = 0; i < file.pushMins.len(); i++ )
 {
  vector lo = file.pushMins[i]
  vector hi = file.pushMaxs[i]
  if ( o.x < lo.x || o.y < lo.y || o.z < lo.z || o.x > hi.x || o.y > hi.y || o.z > hi.z )
   continue
  if ( !TouchesBrushes( o, file.pushBrushFirst[i], file.pushBrushEnd[i] ) )
   continue
  vector push = file.pushVelocities[i]
  float speed = Length( push )
  vector dir = push / speed
  vector v = player.GetVelocity()
  float along = DotProduct( v, dir )
  if ( along < speed )
   player.SetVelocity( v + dir * ( speed - along ) )
 }
}
void function KillFallenPilots()
{
 while ( true )
 {
  foreach ( entity player in GetPlayerArray() )
  {
   if ( !IsAlive( player ) )
   {
    if ( player in file.teleportOrigins ) delete file.teleportOrigins[player]
    continue
   }
   vector o = player.GetOrigin()
   vector previous = player in file.teleportOrigins ? file.teleportOrigins[player] : o
   // External resets/respawns are discontinuities, not movement through the map.
   if ( Distance( previous, o ) > max( 1024.0, Length( player.GetVelocity() ) * 0.15 ) ) previous = o
   file.teleportOrigins[player] <- o
   ApplyPushes( player, o )
   int hit = -1
   float nearest = 2.0
   for ( int i = 0; i < file.mins.len(); i++ )
   {
    vector lo = file.mins[i]
    vector hi = file.maxs[i]
    // Cheap broad phase avoids temporary arrays for hundreds of distant triggers.
    if ( ( previous.x < lo.x && o.x < lo.x ) || ( previous.x > hi.x && o.x > hi.x ) ||
         ( previous.y < lo.y && o.y < lo.y ) || ( previous.y > hi.y && o.y > hi.y ) ||
         ( previous.z < lo.z && o.z < lo.z ) || ( previous.z > hi.z && o.z > hi.z ) ) continue
    float t = BoxSweepFraction( previous, o, lo, hi )
    if ( t < 0.0 ) continue
    if ( file.brushFirst[i] != file.brushEnd[i] )
     t = BrushSweepFraction( previous, o, file.brushFirst[i], file.brushEnd[i] )
    if ( t < 0.0 || t >= nearest ) continue
    nearest = t
    hit = i
   }
   if ( hit >= 0 )
   {
    int k = hit + RandomInt( file.choices[hit] )
    vector touchOrigin = previous + ( o - previous ) * nearest
    printl( "[surf] teleport " + player.GetPlayerName() + " " + previous + " -> " + file.destinations[k] + " trigger " + hit + " brush " + file.brushFirst[hit] + " touch " + touchOrigin + " v " + player.GetVelocity() )
    player.SetOrigin( file.destinations[k] )
    player.SetAngles( <0, file.yaws[k], 0> )
    player.SetVelocity( <0, 0, 0> )
    file.teleportOrigins[player] <- file.destinations[k]
    if ( "MRVN_SurfTeleported" in getroottable() )
     getroottable().MRVN_SurfTeleported( player, file.destinations[k], touchOrigin )
   }
   else if ( o.z < -1088.0 )
    player.TakeDamage( 10000, null, null, { damageSourceId = eDamageSourceId.fall } )
  }
  wait 0.05
 }
}


// Surf ramps. Standing, Titanfall counts a slope as ground well past Source's 45.6 degree
// walkable limit: ground movement stops a pilot sliding along a 52 degree ramp within half a
// second. Crouched, the same ramp is not ground (tested in Northstar): the pilot keeps their
// speed along it and slides down it as in Source. So on anything steeper than Source's limit
// pilots are crouched, with no ground friction, until a quarter second after leaving it.
// Two Titanfall moves fight surfing there: auto-mantle (a rising ramp ahead reads as a wall
// with a ledge, and the pilot is vaulted forward) and slides (crouching at speed on a frame
// counted as ground starts one, with its forward boost). Both are cancelled on a ramp and the
// previous frame's velocity restored; each cancel is logged as [surf].
// Titanfall also moves a pilot up a rising ramp without turning the climb into velocity (play
// trace on surf_utopia: rising 1,370 units/s while reporting -377), so pilots left ramps with no
// upward speed. Source's ClipVelocity is applied instead: within reach of the ramp, the part of
// the velocity going into it is removed every frame.
// Ramp bugs: crossing the seam between two brushes of one ramp, Titanfall's per-brush collision
// can catch the next brush's hidden back face (surf_utopia's curved ramp end: 2,686 units/s
// forward became 459 in one tick, with nothing in the way). As surf servers' rampbug fixes do,
// a big speed loss while surfing is undone unless a hull sweep along the last tick's motion
// hits a real wall, floor or ceiling; it is logged as [surf].
void function SurfRamps()
{
 while ( true )
 {
  foreach ( entity player in GetPlayerArray() )
  {
   bool surfing = player in file.rampTimes
   if ( !IsAlive( player ) )
   {
    if ( surfing )
     StopSurfing( player )
    continue
   }
   vector o = player.GetOrigin()
   // A line from the feet: on a 52 degree ramp the surface under the centre is up to 21 units below them.
   TraceResults r = TraceLine( o + <0, 0, 4>, o - <0, 0, 40>, player, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
   if ( r.fraction < 1.0 && r.surfaceNormal.z > 0.05 && r.surfaceNormal.z < 0.7 )
   {
    if ( !surfing )
    {
     player.ForceCrouch()
     player.SetGroundFrictionScale( 0.0 )
    }
    else if ( player.IsMantling() || player.IsTraversing() )
    {
     printl( "[surf] cancelled a mantle at " + o )
     player.ClearTraverse()
     player.SetVelocity( file.rampVelocities[player] )
    }
    else if ( player.IsSliding() && Length( player.GetVelocity() ) > Length( file.rampVelocities[player] ) + 40.0 )
    {
     printl( "[surf] cancelled a slide boost at " + o )
     player.SetVelocity( file.rampVelocities[player] )
    }
    // The line starts 4 units above the feet and is 44 long; on the ramp the surface under the
    // centre is at most 21 units below the feet.
    if ( r.fraction * 44.0 - 4.0 < 24.0 )
    {
     vector v = player.GetVelocity()
     float into = DotProduct( v, r.surfaceNormal )
     if ( into < 0.0 )
      player.SetVelocity( v - r.surfaceNormal * into )
    }
    file.rampTimes[player] <- Time()
    file.rampVelocities[player] <- player.GetVelocity()
    file.traceUntil[player] <- Time() + 3.0
   }
   else if ( surfing && Time() - file.rampTimes[player] > 0.25 )
    StopSurfing( player )
   if ( player in file.rampTimes )
   {
    file.lastVel[player] <- player.GetVelocity()
    file.lastOrigin[player] <- o
    file.lastTime[player] <- Time()
   }
  }
  WaitFrame()
 }
}
void function FixRampBug( entity player, vector o )
{
 vector prev = file.lastVel[player]
 vector cur = player.GetVelocity()
 if ( Length( prev ) - Length( cur ) < 400.0 )
  return
 float dt = Time() - file.lastTime[player]
 vector from = file.lastOrigin[player]
 // A teleport (the jail, a stage reset) also zeroes velocity: leave those alone.
 if ( Distance( o, from ) > Length( prev ) * dt + 200.0 )
  return
 TraceResults h = TraceHull( from, from + prev * dt, < -16, -16, 0 >, < 16, 16, 48 >, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
 if ( h.fraction < 1.0 && ( h.surfaceNormal.z <= 0.05 || h.surfaceNormal.z >= 0.7 ) )
  return
 // Pilot gravity: free flight in the traces loses about 600 units/s of vertical speed a second.
 vector fixed = prev - < 0, 0, 600.0 * dt >
 if ( h.fraction < 1.0 )
 {
  float into = DotProduct( fixed, h.surfaceNormal )
  if ( into < 0.0 )
   fixed = fixed - h.surfaceNormal * into
 }
 printl( "[surf] fixed a ramp bug at " + o + ": " + cur + " -> " + fixed )
 player.SetVelocity( fixed )
}
void function StopSurfing( entity player )
{
 delete file.rampTimes[player]
 delete file.rampVelocities[player]
 if ( player in file.lastVel )
 {
  delete file.lastVel[player]
  delete file.lastOrigin[player]
  delete file.lastTime[player]
 }
 player.UnforceCrouch()
 player.SetGroundFrictionScale( 1.0 )
}
