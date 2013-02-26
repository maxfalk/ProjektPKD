signature S =
sig
	datatype Fieldstate = EXISTS | VOID | OUT 
	datatype Field = field of Fieldstate vector vector 
	datatype Direction = WEST | EAST | SOUTH | NORTH
	
	val createNewField : int * int -> Field
	val move : Field * int * int * Direction -> Field
	val getDirection : string -> Direction
	val gameWon : Field  -> bool
	val getOldMoves : unit -> (int*int*Direction) list

end

structure S :> S =
struct
	datatype Fieldstate = EXISTS | VOID | OUT 
	datatype Field = field of Fieldstate vector vector 
	datatype Direction = WEST | EAST | SOUTH | NORTH
	
	val oldMoves : (int * int * Direction) list ref = ref []
	fun getOldMoves() = !oldMoves
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
	fun CheckForPiece(cField as field(plan),x,y,value) = 
		let
			val OOB = outOfBounds(cField,x,y)	
		in
			if OOB andalso Vector.sub(Vector.sub(plan,y),x) = value then 
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
	fun movedirection(cField,x,y,WEST) = 
			let
				val PeiceMovedTo = CheckForPiece(cField,x-2,y,VOID)	
				val OOB = outOfBounds(cField,x-2,y)
			in
				if PeiceMovedTo andalso OOB  then
					(
					saveInverseMove(x,y,WEST);
					updateVector(updateVector(updateVector(cField,x,y,VOID),x-2,y,EXISTS),x-1,y,VOID)
					)
				else
					cField
			end
		| movedirection(cField,x,y,EAST) = 
			let
				val PeiceMovedTo = CheckForPiece(cField,x+2,y,VOID)	
				val OOB = outOfBounds(cField,x+2,y)
			in
				if PeiceMovedTo andalso OOB  then
					updateVector(updateVector(updateVector(cField,x,y,VOID),x+2,y,EXISTS),x+1,y,VOID)
				else
					cField
			end
		| movedirection(cField,x,y,SOUTH) = 
			let
				val PeiceMovedTo = CheckForPiece(cField,x,y-2,VOID)
				val OOB = outOfBounds(cField,x,y-2)
			in	
				if PeiceMovedTo andalso OOB  then
					updateVector(updateVector(updateVector(cField,x,y,VOID),x,y-2,EXISTS),x,y-1,VOID)
				else
					cField
			end
		| movedirection(cField,x,y,NORTH) = 
			let
				val PeiceMovedTo = CheckForPiece(cField,x,y+2,VOID)	
				val OOB = outOfBounds(cField,x,y+2)
			in
				if PeiceMovedTo andalso OOB then
					updateVector(updateVector(updateVector(cField,x,y,VOID),x,y+2,EXISTS),x,y+1,VOID)
				else
					cField
			end	
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
		in
			if PeiceToMove andalso OOB then
				movedirection(cField,x,y,direc)
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
end

		
				
				
				