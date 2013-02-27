signature S =
sig
	datatype Fieldstate = EXISTS | VOID | OUT 
	datatype Field = field of Fieldstate vector vector 
	datatype Direction = WEST | EAST | SOUTH | NORTH
	
	val createNewField : int * int -> Field
	val move : Field * int * int * Direction -> Field
	val getDirection : string -> Direction
	val gameWon : Field  -> bool
	val undo : Field -> Field
	val sub : Field * int * int-> Fieldstate
	(*
	EN jag har förlorat funktion 
	highscore lista 
	Tids funktion
	Poäng system
	*)
	
end

structure S :> S =
struct
	(* 
	REPRESENTAION CONVENTION: EXISTS, VOID och OUT representerar 3 lägen på positioner på ett seplbräde.
							  EXISTS representerar när det finns något på den positionen, VOID när det inte finns något och OUT när den platen inte ingår i spelplanen.
	REPRESENTAION INVARIANT: 
	*)
	datatype Fieldstate = EXISTS | VOID | OUT 
	(* 
	REPRESENTAION CONVENTION:field representerar en 2-dimensionell plan där varje postition i planen representeras av ett Fieldstate. 
	REPRESENTAION INVARIANT: 
	*)
	datatype Field = field of Fieldstate vector vector 
	(* 
	REPRESENTAION CONVENTION: WEST, EAST, SOUTH OCH NORTH representerar riktningar enligt EAST = höger(Positivt i x-led), WEST = vänster (negativt i x-led), 
								NORTH = upp(positivt i y-led) och SOUTH = ner(negativt i y-led).
	REPRESENTAION INVARIANT: 
	*)
	datatype Direction = WEST | EAST | SOUTH | NORTH
	
	val oldMoves : (int * int * Direction) list ref = ref []
	(*-------------------------------------------------------------------------------------------------------------*)
	(*sub(cField,x,y)
	TYPE: Field * int * int -> Fieldstate
	PRE: 0 <= x < längden av cField i x-led, 0 <= y < längden av cFeild i y-led
	POST:
	EXAMPLE:
	*)
	fun sub(field(plan),x,y) = Vector.sub(Vector.sub(plan,y),x)
	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*getDirection(direct)
	TYPE: string -> Direction
	PRE:
	POST:
	EXAMPLE:

	*)
	fun getDirection(direct) =
		case direct of
			"EAST" => EAST
			| "WEST" => WEST
			| "SOUTH" => SOUTH
			| "NORTH" => NORTH
	(*-------------------------------------------------------------------------------------------------------------*)
	(*updateVector(vec,x,y,value)
	TYPE: Field * int * int * 'a -> Field
	PRE:
	POST:
	EXAMPLE:

	*)
	fun updateVector(field(vec),x,y,value) = field(Vector.update(vec,y,Vector.update(Vector.sub(vec,y),x,value)))
	(*-------------------------------------------------------------------------------------------------------------*)	
	(*createNewField(xLength,yLength)
	TYPE: int * int -> Field
	PRE:
	POST:
	EXAMPLE:

	*)
	fun createNewField(xLength,yLength) = 
		let
			val vec = Vector.tabulate(yLength,(fn y => Vector.tabulate(xLength, (fn x => EXISTS))))
		in
			updateVector(field(vec),(xLength div 2),(yLength div 2),VOID)
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*fieldLength(plan)
	TYPE: Field -> (int * int)
	PRE:
	POST:
	EXAMPLE:

	*)
	fun fieldLength(field(plan)) =
		let
			val yLength = Vector.length(plan)-1
			val xLength = Vector.length(Vector.sub(plan,0))-1
		in
			(yLength,xLength)
		
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(* outOfBounds(plan,x,y)
	TYPE: Field * int * int -> bool
	PRE:
	POST:
	EXAMPLE:

	*)
	fun outOfBounds(field(plan),x,y) = 
		let
			val (xLimit,yLimit) = fieldLength(field(plan))	
		in
			if x < 0 orelse x > xLimit orelse y < 0 orelse y > yLimit then
				false
			else 
				true
		end	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*CheckForPiece(cField,x,y,value)
	TYPE: Field * int * int * Fieldstate -> Field
	PRE:
	POST:
	EXAMPLE:

	*)
	fun CheckForPiece(cField,x,y,value) = 
		let
			val OOB = outOfBounds(cField,x,y)	
		in
			if OOB andalso sub(cField,x,y) = value then 
				true 
			else 
				false
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*saveInverseMove(x,y,direct)
	TYPE: 'a list * int * int * Direction -> unit
	PRE:
	SIDE-EFFECT:
	EXAMPLE:

	*)
	fun saveInverseMove(x,y,direct) =
		let
			val (ix,iy) = (case direct of
									WEST => (x-2,y)
									| EAST => (x+2,y)
									| SOUTH => (x,y-2)
									| NORTH => (x,y+2))
			val inverseDirection = (case direct of
										WEST => EAST
										| EAST => WEST
										| SOUTH => NORTH
										| NORTH => SOUTH)
		
		in
			oldMoves := (ix,iy,inverseDirection):: !oldMoves
		
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*movedirection(cField,x,y,direct)
	TYPE: Field * int * int * Direction -> Field
	PRE:
	POST:
	EXAMPLE:

	*)
	fun movedirection(cField,x,y,WEST,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x-2,y,Value),x-1,y,OverValue))
		| movedirection(cField,x,y,EAST,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x+2,y,Value),x+1,y,OverValue))
		| movedirection(cField,x,y,SOUTH,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x,y-2,Value),x,y-1,OverValue))
		| movedirection(cField,x,y,NORTH,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x,y+2,Value),x,y+1,OverValue))
	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*rules(cField,x,y,direct)
	TYPE: Field * int * int * Fieldstate -> bool
	PRE:
	POST:
	EXAMPLE:
	*)
	fun rules(cField,x,y,NORTH) = CheckForPiece(cField,x,y+2,VOID) andalso CheckForPiece(cField,x,y+1,EXISTS)
		| rules(cField,x,y,SOUTH) = CheckForPiece(cField,x,y-2,VOID) andalso CheckForPiece(cField,x,y+1,EXISTS)
		| rules(cField,x,y,EAST) =  CheckForPiece(cField,x+2,y,VOID) andalso CheckForPiece(cField,x+1,y,EXISTS)
		| rules(cField,x,y,WEST) = CheckForPiece(cField,x-2,y,VOID) andalso CheckForPiece(cField,x-1,y,EXISTS) 
	(*-------------------------------------------------------------------------------------------------------------*)
	(*move(cField,x,y,direc)
	TYPE: Field * int * int * Direction -> Field
	PRE:
	POST:
	EXAMPLE:

	*)
	fun move(cField,x,y,direc) =
		let
			val OOB = outOfBounds(cField,x,y)
			val PeiceToMove = CheckForPiece(cField,x,y,EXISTS)	
			val rulespassed = rules(cField,x,y,direc) 
		in
			if PeiceToMove andalso OOB andalso rulespassed then
				(saveInverseMove(x,y,direc);
				movedirection(cField,x,y,direc,VOID,VOID,EXISTS))
			else
				cField
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*gameWon'(cField,y,totalFound)
	TYPE: Field * int * int -> bool
	PRE:
	POST:
	EXAMPLE:

	*)
	fun gameWon'(_,0,_) = true 
		| gameWon'(cField as field(plan),y,totalFound) = 
		let
			val subPlan = Vector.sub(plan,y-1)
			val amountFound = Vector.foldr (fn (x,y) => if x = EXISTS then y+1 else y) 0 subPlan
			val totalFound = totalFound + amountFound
		
		in
			if totalFound > 1 then
				false
			else
				gameWon'(cField,y-1,totalFound)			

		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*gameWon(cField,y,totalFound)
	TYPE: Field -> bool
	PRE:
	POST:
	EXAMPLE:

	*)
	fun gameWon(cField) = 
		let
			val (x,y) = fieldLength(cField)
		in
			gameWon'(cField,y,0)
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*undo(cField)
	TYPE:
	PRE:
	POST:
	EXAMPLE:
	*)
	
	fun undo(cField) = 
		if length( !oldMoves) <> 0 then
			let
				val (x,y,direct) = hd( !oldMoves)
				val _ = print(Int.toString(x)^", "^Int.toString(y)^"\n")
			in
				(oldMoves := tl( !oldMoves);				
				movedirection(cField,x,y,direct,VOID,EXISTS,EXISTS))
			end
		else
			cField
	

(*-------------------------------------------------------------------------------------------------------------*)
end

		
				
				
				