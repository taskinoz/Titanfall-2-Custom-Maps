
void function MRVN_SurfSweepTest()
{
 int reset = -1
 for ( int i = 0; i < file.destinations.len(); i++ )
  if ( Distance( file.destinations[i], < -12782.5, -3072, -768 > ) < 8.0 && file.brushEnd[i] - file.brushFirst[i] == 19 ) reset = i
 if ( reset < 0 ) throw "Surf Me courtyard reset trigger not found"
 array<vector> before = [ < -9000, -3072, -4000 >, < -6570, -1489, -8200 > ]
 array<vector> after = [ < -9000, -3072, -4600 >, < -6570, -1489, -8600 > ]
 for ( int i = 0; i < before.len(); i++ )
 {
  int first = file.brushFirst[reset]
  int end = file.brushEnd[reset]
  if ( TouchesBrushes( after[i], first, end ) ) throw "Reset test must reproduce the old missed trigger"
  float t = BrushSweepFraction( before[i], after[i], first, end )
  if ( t < 0.0 || t > 1.0 ) throw "Fast fall skipped a two-unit reset floor"
  printl( "[SurfMeTest] swept courtyard reset passed case=" + i + " fraction=" + t )
 }
 if ( BrushSweepFraction( < -9000, -3072, 0 >, < -9000, -3072, -100 >, file.brushFirst[reset], file.brushEnd[reset] ) >= 0.0 )
  throw "Air above courtyard must not teleport"
 if ( BoxSweepFraction( < -10, 20, 0 >, < 20, -10, 0 >, < 0, 0, -1 >, < 2, 2, 1 > ) >= 0.0 )
  throw "Diagonal bounding-box near miss must not teleport"
 printl( "[SurfMeTest] swept reset and near-miss assertions passed" )
}
