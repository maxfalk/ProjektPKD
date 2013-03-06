(*
load "Time";
load "TextIO";
load "Int";
load "Bool";
*)
load "Time";
load "TextIO";
load "Int";
load "Bool";

structure S =
struct
	(*Anv�nds d� filen man f�rs�ker ladda �r p� n�gots�tt fel konfigurerad.*)
	exception BadFile
	(* 
	REPRESENTAION CONVENTION: EXISTS, VOID och OUT representerar 3 l�gen p� positioner p� ett seplbr�de.
							  EXISTS representerar n�r det finns n�got p� den positionen, VOID n�r det inte finns n�got och OUT n�r den platen inte ing�r i spelplanen.
	REPRESENTAION INVARIANT: 
	*)
	datatype Fieldstate = EXISTS | VOID | OUT 
	(* 
	REPRESENTAION CONVENTION:field representerar en 2-dimensionell plan d�r varje postition i planen representeras av ett Fieldstate. 
	REPRESENTAION INVARIANT: Varje subvektor dvs varje vektor i den innre vektorn m�ste vara av samma l�ngd.
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
	POST: V�rdet av elementet i cField med posistion (x,y), y �r platen i f�rsta vektorn och x i den andra(subvektorn).
	EXAMPLE:
	*)
	fun sub(field(plan),x,y) = Vector.sub(Vector.sub(plan,y),x)
	

	(*updateVector(vec,x,y,value)
	TYPE: Field * int * int * 'a -> Field
	PRE: 0 < = y < length(vec), 0 < = x < length(length(vec)), 
	POST: vec uppdaterat p� element (x,y) (kolumn,rad) med value.
	EXAMPLE:
	*)
	fun updateVector(field(vec),x,y,value) = 
		let
			(*-------------------------------------------------------------------------------------------------------------*)
			(*update(vec,x,value)
			TYPE: 'a vector * int * 'a -> 'a vector
			PRE: 0 < = x < length(vec)
			POST: vec uppdaterat med value p� position x
			EXAMPLE:
			*)
			fun update(vec,x,value) = Vector.tabulate(Vector.length(vec), (fn y => 
																					if y = x then 
																						value 
																					else 
																						Vector.sub(vec,y)) )
		in
			field(update(vec,y,update(Vector.sub(vec,y),x,value)))
		end
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
	POST: Ger true om x och y �r innanf�r plan annars false.
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
	POST: true om element (x,y) i cField har v�rdet value och x,y �r innom cField. Annars false.
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
	POST:  	direct = NORTH s� m�ste (x,y+2) vara en ledigt plats (VOID) och (x,y+1) vara en "ej ledigplats" (EXISTS),
			direct = SOUTH s� m�ste (x,y-2) vara en ledigt plats (VOID) och (x,y-1) vara en "ej ledigplats" (EXISTS),
			direct = EAST s� m�ste (x+2,y) vara en ledigt plats (VOID) och (x+1,y) vara en "ej ledigplats" (EXISTS),
			direct = WEST s� m�ste (x-2,y) vara en ledigt plats (VOID) och (x-1,y) vara en "ej ledigplats" (EXISTS),
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
	POST: Vid ett giltigt drag: cField uppdaterat enligt draget (x,y) i riktingen direc. Enligt regler f�r att r�ra pj�ser i Solitarie.
		  Vid ett oglitigt drag blir cField of�r�ndrad.
	EXAMPLE:
	*)
	fun move(cField,x,y,direc) =
		let
			val PeiceToMove = checkForPiece(cField,x,y,EXISTS)	
			val rulespassed = rules(cField,x,y,direc) 
		in
			if PeiceToMove andalso rulespassed then
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
	(*addPoint(points)
	TYPE: int -> int
	PRE:none
	POST: points+1
	EXAMPLE:
	*)
	fun addPoint(points) = points+1
	(*-------------------------------------------------------------------------------------------------------------*)
	(*removePoint(points)
	TYPE: int -> int
	PRE:none
	POST: points-11
	EXAMPLE:
	*)	
	fun removePoint(points) = points-1
	(*-------------------------------------------------------------------------------------------------------------*)
	(*getTime()
	TYPE: unit -> real
	PRE: none.
	POST: Tiden d� funktionen k�rdes.
	EXAMPLE
	*)
	fun getTime() = Time.toReal(Time.now())
	(*-------------------------------------------------------------------------------------------------------------*)
	(*getTimeDiff(xTime,yTime)
	TYPE: real * real -> int
	PRE: 0 < xTime-yTime
	POST: xTime-yTime i sekunder.
	EXAMPLE:
	*)
	fun getTimeDiff(xTime,yTime) = Time.toSeconds(Time.-(Time.fromReal(xTime),Time.fromReal(yTime)))
	(*-------------------------------------------------------------------------------------------------------------*)
	(*saveHighScoreList(path,saveType,vList)
	TYPE: string * string *(string * int * int) list -> unit
	PRE:none.
	SIDE-EFFECT: Sparar listan vList till filen med den relativa s�kv�gen path. Appendar till filen om saveType= "append" annars spara (�ver en existerande om det finns) den filen.
	EXAMPLE:
	*)
	fun saveHighScoreList(path,saveType,vList) =
		let
			(*saveToFile(oStream,value)
			TYPE: outstream * string -> unit
			PRE: none
			SIDE-EFFECT: Skickar value till oStream.
			EXAMPLE:
			*)
			fun saveToFile(oStream,value) = TextIO.output(oStream,value)
			(*-------------------------------------------------------------------------------------------------------------*)
			(*saveListToFile(oStream,vList)
			TYPE: outstream * string list -> unit
			PRE: none.
			SIDE-EFFECT: Skickar varje v�rde i vList till oStream
			EXAMPLE:
			*)
			(*VARIANT: |vList|*)
			fun saveListToFile(oStream,[]) = ()
				| saveListToFile(oStream,vList) = (saveToFile(oStream,hd(vList));
														saveListToFile(oStream,tl(vList)))
			(*-------------------------------------------------------------------------------------------------------------*)		
			(*convertToStingFormat(name,timeSec,points)
			TYPE: string * int * int -> string
			PRE: none.
			POST: name,timeSec,points konvertarade till en str�ng enligt name,timeSec,points;
			EXAMPLE:
			*)	
			fun convertToStringFormat(name,timeSec,points) = 
				name^","^Int.toString(timeSec)^","^Int.toString(points)^";\n"
			(*-------------------------------------------------------------------------------------------------------------*)		
			(*convertToListFormat(vList)
			TYPE: (string * int * int) list -> string list
			PRE: none.
			POST: vList[(name,timeSec,points),(name1,timeSec1,points1)...]. ["name,timeSec,points;\n","name1,timeSec1,points1;\n"...]
			EXAMPLE:
			*)	
			(*VARIANT: |vList|*)
			fun convertToListFormat([]) = []
				| convertToListFormat((name,timeSec,points)::last) = convertToStringFormat(name,timeSec,points)::convertToListFormat(last)
			(*-------------------------------------------------------------------------------------------------------------*)		
			val formatedlist = convertToListFormat(vList)
			val oStream = case saveType of
							"append" => TextIO.openAppend(path)
							|	_	=>	TextIO.openOut(path)

		in
			(saveListToFile(oStream,formatedlist);
			TextIO.closeOut(oStream))
		end
	(*-------------------------------------------------------------------------------------------------------------*)
	(*loadHighScoreList(path)
	TYPE: string -> (string * int * int) list
	PRE: Filen dit path pekar m�ste f�lja formateringen av funktionen saveHighScoreList(path,vList) (Se ovan denna).
	POST: En Lista av tupler med den f�rsta "raden" fr�n path f�rst i listan, andra raden efter osv.
	EXAMPLE:
	*)
	fun loadHighScoreList(path) = 
		let

			(*loadRow(iStream)
			TYPE: instream -> string
			PRE: iStream f�r inte st� vid stultet av filen.
			POST: Texten p� den rad som iStream pekar p� f�r tillf�llet.
			EXAMPLE:
			*)
			fun loadRow(iStream) = TextIO.inputLine(iStream)
			(*-------------------------------------------------------------------------------------------------------------*)
			(*loadList(iStream)
			TYPE: instream -> string list
			PRE:none.
			POST: En lista med varje rad i iStream som ett element.
			EXAMPLE:
			*)
			(*VARIANT: iStream - endOfStream*)
			fun loadList(iStream) = 
				if TextIO.endOfStream(iStream) then
					[]
				else
					loadRow(iStream)::loadList(iStream)
			(*-------------------------------------------------------------------------------------------------------------*)
			(*convertToFormat(line)
			TYPE: string -> (string * int * int) 
			PRE: line =[string","string1","string2";"...], D�r string1 och string2 m�ste vara ett tal.
			POST:line = [string","string1","string2";"...]. En tupel enligt (string,string1,string2).
			EXAMPLE:
			*)
			fun convertToFormat(line) =
				let
					(*breakLine(line,A)
					TYPE: string * string-> string list
					PRE:none
					POST: Delar upp line till en lista d�r varje element best�r av alla karakt�rer fram till ",", och slutningen ";" som slut. 
					EXAMPLE:
					*)
					(*VARIANT: |line|*)
					fun breakLine("",A) = []
						| breakLine(line,A) = 
						let 
							val cChar = String.substring(line,0,1)
						in
							if cChar = "," then
								A::breakLine(String.substring(line,1,size(line)-1),"")
							else if cChar = ";" then
								A::[]
							else
								breakLine(String.substring(line,1,size(line)-1),A^cChar)
						end
					
					val line = breakLine(line,"")
					val (name,timeSec,points) = (fn (head::middle::tail) => (head,valOf(Int.fromString(middle)),valOf(Int.fromString(hd(tail))))) line
					in
						(name,timeSec,points)
					
					end						
			(*-------------------------------------------------------------------------------------------------------------*)			
			(*convertListToFormat(fList)
			TYPE: string list -> (string * int * int) list
			PRE: hd(fList) =[string","string1","string2";"...], D�r string1 och string2 m�ste vara ett tal.
			POST: En lista med varje element i fList uppdelat enligt funktionen convertToFormat.
			EXAMPLE:
			*)
			(*VARIANT: |fList|*)
			fun convertListToFormat([]) = []
				| convertListToFormat(first::rest) =  convertToFormat(first)::convertListToFormat(rest)

					
			(*-------------------------------------------------------------------------------------------------------------*)	
			
			val iStream = TextIO.openIn(path)
			val fList = loadList(iStream)
			val output = convertListToFormat(fList)
			(*St�ng filstr�mmen om det blir n�got fel*)
					handle 	_ => (TextIO.closeIn(iStream);raise BadFile)
			val _ = TextIO.closeIn(iStream)

		in
			output
		end
		(*sortHighScoreList(sortBy,fList)
		TYPE: string * ('a * int *int) list -> ('a * int *int) list
		PRE:sortBy = time eller sortBy = "points"
		POST:fList=[(name,timeSec,points),...]. listan fList sorterad i icke �kande ordning om sortBy = "points" efter points.
			om sortBy = "time" blir listan fList sorterad i icke minskande ordning enligt timeSec.
		EXAMPLE:
		*)
		(*VARIANT: |fList|*)
		fun sortHighScoreList(sortBy,[]) = []
			| sortHighScoreList(sortBy,(name,timeSec,points)::rest) =
				let
					(*partition(p,f,sortBy,fList)
					TYPE: int * function * string * ('a * int *int) list -> ('a * int *int) list * ('a * int *int) list
					PRE: sortBy = "time" eller sortBy = "points".
					POST: 	fList=[(name,timeSec,points),...]
							(less,more). less inneh�ller alla element i fList d�r p > timeSec om sortBy = "time". 
							Om sortBy = "points" inneh�ller less alla elemant i fList d�r points < p.
							more inneh�ller alla andra element.
					EXAMPLE:
					*)
					(*VARIANT: |fList|*)
					fun partition(p,_,_,[]) = ([],[])
						| partition(p,f,sortBy,(name,timeSec,points)::rest) = 
							let
								val sortByValue = (case sortBy of
												"time" => timeSec
												| "points" => points)
												
								val (less, more) = partition(p,f,sortBy,rest)
							in
								if f(p,sortByValue) then 
									(less, (name,timeSec,points)::more)
								else
									((name,timeSec,points)::less, more)
							end
								
					val pivot = (case sortBy of
										"time" => timeSec
										| "points" => points)
					val f = (case sortBy of
										"time" => op >
										| "points" => op <)	
							
					val (less, more) = partition(pivot,f,sortBy,rest)

				in
					sortHighScoreList(sortBy,more)@((name,timeSec,points):: (sortHighScoreList(sortBy,less)))
				
				end
		(*addToHighScroeList(path,(name,timeSec,points))
		TYPE: (string * int * int), string -> unit
		PRE:none.
		SIDE-EFFECT: L�gger till (name,timeSec,points) i filen med den relativa s�kv�gen path.
		EXAMPLE:
		
		*)
		fun addToHighScroeList(path,(name,timeSec,points)) = saveHighScoreList(path,"append",[(name,timeSec,points)])
		(*getSpecificField(fType)
		TYPE: string -> Field
		PRE: fType = "cross","circle" eller "hexagon"
		POST: Ett Field av en f�rbest�md storlek och form. cross ger ett field i formen av ett kors, rumb i formen av en rumb och hexagon i fromen av en hexagon.
		EXAMPLE:
		*)
		fun getSpecificField(fType) =
			let
				val newField = case fType of
								"cross" => #[#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS],
												#[EXISTS,EXISTS,EXISTS,VOID,EXISTS,EXISTS,EXISTS],
												#[EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT]]
								| "hexagon" => #[#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[OUT,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,OUT],
												#[EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS],
												#[EXISTS,EXISTS,EXISTS,VOID,EXISTS,EXISTS,EXISTS],
												#[EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS],
												#[OUT,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,OUT],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT]]
								| "rumb" => #[#[OUT,OUT,OUT,EXISTS,OUT,OUT,OUT],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[OUT,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,OUT],
												#[EXISTS,EXISTS,EXISTS,VOID,EXISTS,EXISTS,EXISTS],
												#[OUT,EXISTS,EXISTS,EXISTS,EXISTS,EXISTS,OUT],
												#[OUT,OUT,EXISTS,EXISTS,EXISTS,OUT,OUT],
												#[OUT,OUT,OUT,EXISTS,OUT,OUT,OUT]]
			in
				field(newField)
			end
	
(*-------------------------------------------------------------------------------------------------------------*)
end;


		
				
				
				