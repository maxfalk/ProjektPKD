(*
K�r utan signature f�r att underl�tta f�r alla.
*)
structure S =
struct
	(* 
	REPRESENTAION CONVENTION: EXISTS, VOID och OUT representerar 3 l�gen p� positioner p� ett seplbr�de.
							  EXISTS representerar n�r det finns n�got p� den positionen, VOID n�r det inte finns n�got och OUT n�r den platen inte ing�r i spelplanen.
	REPRESENTAION INVARIANT: 
	*)
	datatype Fieldstate = EXISTS | VOID | OUT 
	(* 
	REPRESENTAION CONVENTION:field representerar en 2-dimensionell plan d�r varje postition i planen representeras av ett Fieldstate. 
	REPRESENTAION INVARIANT: 
	*)
	datatype Field = field of Fieldstate vector vector 
	(* 
	REPRESENTAION CONVENTION: WEST, EAST, SOUTH OCH NORTH representerar riktningar enligt EAST = h�ger(Positivt i x-led), WEST = v�nster (negativt i x-led), 
							  NORTH = upp(positivt i y-led) och SOUTH = ner(negativt i y-led).
	REPRESENTAION INVARIANT: 
	*)
	datatype Direction = WEST | EAST | SOUTH | NORTH
	(*-------------------------------------------------------------------------------------------------------------*)
	(*sub(cField,x,y)
	TYPE: Field * int * int -> Fieldstate
	PRE: 0 <= x < l�ngden av cField i x-led, 0 <= y < l�ngden av cFeild i y-led
	POST: V�rdet av elementet i cField med posistion (x,y), y �r platen i f�rsta vektorn och x i den andra.
	EXAMPLE:
	*)
	fun sub(field(plan),x,y) = Vector.sub(Vector.sub(plan,y),x)
	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*update(vec,x,value)
	TYPE: 'a vector * int * 'a -> 'a vector
	PRE: 0 < = x < length(vec)
	POST: vec uppdaterat med value p� position x
	EXAMPLE:
	*)
	fun update(vec,x,value) = Vector.tabulate(Vector.length(vec), (fn y => if y = x then value else Vector.sub(vec,y)) )
	(*updateVector(vec,x,y,value)
	TYPE: Field * int * int * 'a -> Field
	PRE: 0 < = y < length(vec), 0 < = x < length(length(vec)), 
	POST: vec uppdaterat p� element (x,y) (kolumn,rad) med value.
	EXAMPLE:
	*)
	fun updateVector(field(vec),x,y,value) = field(update(vec,y,update(Vector.sub(vec,y),x,value)))
	(*-------------------------------------------------------------------------------------------------------------*)	
	(*createNewField(xLength,yLength)
	TYPE: int * int -> Field
	PRE: 0 < xLength,yLength < Vector.maxLen
	POST: Ett Field med storleken xLength x yLength. Med Void i det mittersta elementet och EXISTS i de andra. 
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
	PRE: none.
	POST: Ger tillbaka l�ngden p� plan i x och y-led.
	EXAMPLE:
	*)
	fun fieldLength(field(plan)) =
		let
			val yLength = Vector.length(plan)
			val xLength = if yLength > 0 then
							Vector.length(Vector.sub(plan,0))
						  else
							0
		in
			(yLength,xLength)
		
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(* outOfBounds(plan,x,y)
	TYPE: Field * int * int -> bool
	PRE:none
	POST: Ger true om x och y �r innanf�r plann annars false.
	EXAMPLE:
	*)
	fun outOfBounds(field(plan),x,y) = 
		let
			val (xLimit,yLimit) = fieldLength(field(plan))	
		in
			if x < 0 orelse x >= xLimit orelse y < 0 orelse y >= yLimit then
				false
			else 
				true
		end	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*checkForPiece(cField,x,y,value)
	TYPE: Field * int * int * Fieldstate -> bool
	PRE:none.
	POST: true om element (x,y) i plan har v�rdet value och x,y �r innom planen. Annars false.
	EXAMPLE:
	*)
	fun checkForPiece(cField,x,y,value) = 
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
	TYPE: int * int * Direction -> unit
	PRE: none.
	POST: Inversen till det drag som x,y,direct skulle gjort
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
			(ix,iy,inverseDirection)
		
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*movedirection(cField,x,y,direct,FromValue,OverValue,Value)
	TYPE: Field * int * int * Direction * Fieldstate * Fieldstate * Fieldstate   -> Field
	PRE: direct = WEST, s� m�ste x-2,y befinna sig inom cField.
		 direct = EAST, s� m�ste x+2,y befinna sig inom cField.
		 direct = SOUTH, s� m�ste x,y-2 befinna sig inom cField.
		 direct = NORTH, s� m�ste x,y+2 befinna sig inom cField.
		 FromValue=OverValue=Value= {EXISTS,VOID}
	POST: cField uppdaterade med FromValue p� platsen x,y, med Value p� sin destinations plats och OverValue p� platsen som hoppas �ver i processen.
	EXAMPLE:
	*)
	fun movedirection(cField,x,y,WEST,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x-2,y,Value),x-1,y,OverValue))
		| movedirection(cField,x,y,EAST,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x+2,y,Value),x+1,y,OverValue))
		| movedirection(cField,x,y,SOUTH,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x,y-2,Value),x,y-1,OverValue))
		| movedirection(cField,x,y,NORTH,FromValue,OverValue,Value) = (updateVector(updateVector(updateVector(cField,x,y,FromValue),x,y+2,Value),x,y+1,OverValue))
	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*rules(cField,x,y,direct)
	TYPE: Field * int * int * Direction -> bool
	PRE: none.
	POST:  	direct = NORTH s� m�ste (x,y+2) vara en lidigt plats (VOID) och (x,y+1) vara en "ej liedigplats" (EXISTS),
			direct = SOUTH s� m�ste (x,y-2) vara en lidigt plats (VOID) och (x,y-1) vara en "ej liedigplats" (EXISTS),
			direct = EAST s� m�ste (x+2,y) vara en lidigt plats (VOID) och (x+1,y) vara en "ej liedigplats" (EXISTS),
			direct = WEST s� m�ste (x-2,y) vara en lidigt plats (VOID) och (x-1,y) vara en "ej liedigplats" (EXISTS),
			alla dessa fall ger true, annars ger den false
	EXAMPLE:
	*)
	fun rules(cField,x,y,NORTH) = checkForPiece(cField,x,y+2,VOID) andalso checkForPiece(cField,x,y+1,EXISTS)
		| rules(cField,x,y,SOUTH) = checkForPiece(cField,x,y-2,VOID) andalso checkForPiece(cField,x,y-1,EXISTS)
		| rules(cField,x,y,EAST) =  checkForPiece(cField,x+2,y,VOID) andalso checkForPiece(cField,x+1,y,EXISTS)
		| rules(cField,x,y,WEST) = checkForPiece(cField,x-2,y,VOID) andalso checkForPiece(cField,x-1,y,EXISTS) 
	(*-------------------------------------------------------------------------------------------------------------*)
	(*move(cField,x,y,direc)
	TYPE: Field * int * int * Direction -> Field
	PRE: none.
	POST: Vid ett giltigt drag: cField uppdaterat enligt draget (x,y) i riktingen direkt. Enligt regler f�r att r�ra pj�ser i Solitarie.
		  Vid ett oglitigt drag blir cField of�r�ndrad.
	EXAMPLE:
	*)
	fun move(cField,x,y,direc) =
		let
			val OOB = outOfBounds(cField,x,y)
			val PeiceToMove = checkForPiece(cField,x,y,EXISTS)	
			val rulespassed = rules(cField,x,y,direc) 
		in
			if PeiceToMove andalso OOB andalso rulespassed then
				movedirection(cField,x,y,direc,VOID,VOID,EXISTS)
			else
				cField
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*gameWon(cField,y,totalFound)
	TYPE: Field -> bool
	PRE: none.
	POST: Ger true om det bara finns en pj�s p� planen cField, annars false.
	EXAMPLE:
	*)
	fun gameWon(cField) = 
		let
			(*gameWon'(cField,y,totalFound)
			TYPE: Field * int * int -> bool
			PRE: 0 <= y < l�ngden p� cField i y-led.
			POST: Ger true om det bara finns en pj�s p� planen cField, annars false.
			EXAMPLE:
			*)
			(*VARIANT: y*)
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
			val (x,y) = fieldLength(cField)
		in
			gameWon'(cField,y,0)
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*undo(cField,x,y,direct)
	TYPE: Field * int * int * Direction -> Field
	PRE: x,y,direct m�ste vara inversen till ett drag utf�rt av funtionen move.
	POST: Ett nytt Field med draget x,y,direct gjort, med VOID p� platen man flyttar fr�n och EXISTS p� platsen man hoppar �ver samt den man flyttar till. 
	EXAMPLE:
	*)
	fun undo(cField,x,y,direct) = movedirection(cField,x,y,direct,VOID,EXISTS,EXISTS)

	

	
(*-------------------------------------------------------------------------------------------------------------*)
end;


		
				
				
				