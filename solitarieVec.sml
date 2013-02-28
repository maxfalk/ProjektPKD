
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
	(* oldMoves
	   TYPE:  (int * int * Direction) list ref
	   VALUE: Här sparas en lista med inversen till alla drag som görs när man spelar.
	*)
	val oldMoves : (int * int * Direction) list ref = ref []
	(*-------------------------------------------------------------------------------------------------------------*)
	(*sub(cField,x,y)
	TYPE: Field * int * int -> Fieldstate
	PRE: 0 <= x < längden av cField i x-led, 0 <= y < längden av cFeild i y-led
	POST: Värdet av elementet i cField med posistion (x,y), y är platen i första vektorn och x i den andra.
	EXAMPLE:
	*)
	fun sub(field(plan),x,y) = Vector.sub(Vector.sub(plan,y),x)
	
	(*-------------------------------------------------------------------------------------------------------------*)
	(*update(vec,x,value)
	TYPE: 'a vector * int * 'a -> 'a vector
	PRE: 0 < = x < length(vec)
	POST: vec uppdaterat med value på position x
	EXAMPLE:
	*)
	fun update(vec,x,value) = Vector.tabulate(Vector.length(vec), (fn y => if y = x then value else Vector.sub(vec,y)) )
	(*updateVector(vec,x,y,value)
	TYPE: Field * int * int * Fieldstate -> Field
	PRE: 0 < = y < length(vec), 0 < = x < length(length(vec)), 
	POST: vec uppdaterat på element (x,y) (kolumn,rad) med value.
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
	POST: Ger tillbaka längden på plan i x och y-led.
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
	POST: Ger true om x och y är innanför plann annars false.
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
	POST: true om element (x,y) i plan har värdet value och x,y är innom planen. Annars false.
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
	SIDE-EFFECT: Sparar inversen till x,y och direct i variablen oldMoves.
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
	TYPE: Field * int * int * Direction * Fieldstate * Fieldstate * Fieldstate -> Field
	PRE: direct = WEST, så måste x-2,y befinna sig inom cField.
		 direct = EAST, så måste x+2,y befinna sig inom cField.
		 direct = SOUTH, så måste x,y-2 befinna sig inom cField.
		 direct = NORTH, så måste x,y+2 befinna sig inom cField.
	POST: cField uppdaterade med FromValue på platsen x,y, med Value på sin destinations plats och OverValue på platsen som hoppas över i processen.
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
	POST:  true när en plats (x,y) berhåller ett speciellt värde annars false.
	EXAMPLE:
	*)
	fun rules(cField,x,y,NORTH) = checkForPiece(cField,x,y+2,VOID) andalso checkForPiece(cField,x,y+1,EXISTS)
		| rules(cField,x,y,SOUTH) = checkForPiece(cField,x,y-2,VOID) andalso checkForPiece(cField,x,y+1,EXISTS)
		| rules(cField,x,y,EAST) =  checkForPiece(cField,x+2,y,VOID) andalso checkForPiece(cField,x+1,y,EXISTS)
		| rules(cField,x,y,WEST) = checkForPiece(cField,x-2,y,VOID) andalso checkForPiece(cField,x-1,y,EXISTS) 
	(*-------------------------------------------------------------------------------------------------------------*)
	(*move(cField,x,y,direc)
	TYPE: Field * int * int * Direction -> Field
	PRE: none.
	POST: Vid ett giltigt drag: cField uppdaterat enligt draget (x,y) i riktingen direkt. Enligt regler för att röra pjäser i Solitarie.
		 Vid ett oglitigt drag blir cField oförändrad.
	EXAMPLE:
	*)
	fun move(cField,x,y,direc) =
		let
			val OOB = outOfBounds(cField,x,y)
			val PeiceToMove = checkForPiece(cField,x,y,EXISTS)	
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
	PRE: 0 <= y <= längden på cField i y-led.
	POST: Ger true om totalFound > 1, annars false.
	EXAMPLE:
	*)
	(*VARIANT: y*)
	fun gameWon'(_,0,_) = true 
		| gameWon'(cField as field(plan),y,totalFound) = 
		let
			val subPlan = Vector.sub(plan,y-1)
			val amountFound = Vector.foldl (fn (x,y) => if x = EXISTS then y+1 else y) 0 subPlan
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
	PRE: none.
	POST: Ger true om det bara finns en pjäs på planen cField, annars false.
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
	TYPE: Field -> Field
	PRE: oldMoves måste finnas med typen (int * int * Direction) list ref.
	POST: Ett nytt Field med det senaste draget som var gjort borta. dvs ett nytt Field som det såg ut innan det senaste draget gjordes.
	SIDEFFECT: huvudet på (första elementet) oldMoves tas bort om length( !oldMoves) <> 0.
	EXAMPLE:
	*)
	fun undo(cField) = 
		if length( !oldMoves) <> 0 then
			let
				val (x,y,direct) = hd( !oldMoves)
			in
				(oldMoves := tl( !oldMoves);				
				movedirection(cField,x,y,direct,VOID,EXISTS,EXISTS))
			end
		else
			cField
	

	
(*-------------------------------------------------------------------------------------------------------------*)
end;


		
				
				
				