signature S =
sig
	datatype Fieldstate = EXISTS | VOID | OUT 
	datatype Field = field of Fieldstate vector vector 
	datatype Direction = WEST | EAST | SOUTH | NORTH
	
	val createNewField : int * int -> Field
	val move : Field * int * int * Direction -> Field
	val gameWon : Field  -> bool
	val undo : Field -> Field
	val sub : Field * int * int-> Fieldstate
	val checkForPiece : Field * int * int * Fieldstate -> bool 
	val fieldLength : Field -> (int * int)
	(*
	EN jag har förlorat funktion. Alexanders AI kan räkna ut det?
	highscore lista 
	Tids funktion
	Poäng system
	*)
	
end