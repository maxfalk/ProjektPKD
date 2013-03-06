(*
use "S.sml";
use "SolitaireHtml_vm.sml";
use "movehelp.sml";


*)

open SolitaireHtml_vm;
open movehelp;


val _ = 
let
	val columnSize = 7;
	val rowSize = 7;
	val url = "http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/solid.cgi"
	val change = Mosmlcgi.cgi_field_string("input1")
	val moveCoords = Mosmlcgi.cgi_field_string("input2")
	val help = Mosmlcgi.cgi_field_string("input4")
	val undoMoves = Mosmlcgi.cgi_field_string("input5")
	val undoPressed = Mosmlcgi.cgi_field_string("input6")
	val boardLayout = Mosmlcgi.cgi_field_string("input7")		

	(*---------------------------------------------------------------------------*)
	(*convert(board,line)
	TYPE: Fieldstate vector list * string -> Fieldstate vector vector 
	PRE: Strängen line måste vara en komma separerad stäng med semikolon som rad separerare.
		Varje ord mellan 2 komman eller ett komma och ett semikonlon måste bestå av ett av orden "OUT",VOID" eller "EXISTS".
	POST: line konverterade till en Fieldstate vector vector
	EXAMPLE:
	*)
	fun convert(board,"") = S.field(Vector.fromList(board))
		| convert(board,line) =
		let
			(*---------------------------------------------------------------------------*)
			(*convertToFieldState(x)
			TYPE: string -> Fieldstate
			PRE:none,
			POST: 	Om x = "OUT" så ger den S.OUT.
					Om x = "VOID" så ger den S.VOID
					annars ges S.EXISTS
			EXAMPLE:
			*)
			fun convertToFieldState(x) =
				(case x of
					"OUT" => S.OUT
					| "VOID" => S.VOID
					| _ => S.EXISTS)
		
			(*---------------------------------------------------------------------------*)
			(*convertRowToField(line,A,out)
			TYPE: string * string * Fieldstate list -> (Fieldstate list, string)
			PRE:Strängen line måste vara en komma separerad stäng med semikolon som rad separerare.
				A^(Varje ord mellan 2 komman eller ett komma och ett semikonlon) måste bestå av ett av orden "OUT",VOID" eller "EXISTS".
			POST: (line konverterar till en Fieldstate lista fram till semikolon, line med den del av line man gått igenom borttagen)
			EXAMPE:
			*)
			(*VARIANT: Enligt pre måste varje rad sluta med ";". Ger oss cChar = ";"*)
			fun convertRowToField(line,A,out) =
				let 
					val cChar = String.substring(line,0,1)
				in
					if cChar = "," then
						convertRowToField(String.substring(line,1,size(line)-1),"",out@[convertToFieldState(A)])
					else if cChar = ";" then
						(out,String.substring(line,1,size(line)-1))
					else
						convertRowToField(String.substring(line,1,size(line)-1),A^cChar,out)	
				end;

			val(out,line) = convertRowToField(line,"",[])
			val out = Vector.fromList(out)
		
		in
			convert(board@[out],line)
		end;

	(*---------------------------------------------------------------------------*)
	(*convertAllRows(board,x,y)
	TYPE: Field * int * int * int -> string
	PRE:none
	POST: Board konverterad till en komma separerad sträng med semikolon separerare vid varje ny rad(varje nytt x-led).
	EXAMPLE:
	*)
	(*VARIANT: y - rowSize*)
	fun convertAllRows(board,x,y,rowSize,columnSize) =
		let
			(*---------------------------------------------------------------------------*)
			(*convertFromFieldState(x)
			TYPE: Fieldstate -> string
			PRE:none.
			POST: om x = S.OUT så "OUT". om x = S.VOID så "VOID", OM x = S.EXISTS så "EXISTS"
			EXAMPLE:
			*)
			fun convertFromFieldState(x) =
					case x of
						S.OUT 		=>	"OUT"
						| S.VOID 	=>  "VOID"
						| S.EXISTS	=>  "EXISTS"
			(*---------------------------------------------------------------------------*)
			(*convertRowToString(board,x,y)
			TYPE: Field * int * int -> string
			PRE:none
			POST: en rad i board konverterad till en komma separerad sträng.
			EXAMPLE:
			*)
			(*VARIANT: x-columnSize *)
			fun convertRowToString(board,x,y,columnSize) =
				if (x < columnSize) then
					(convertFromFieldState(S.sub(board,x,y)) 
					)^","^convertRowToString(board,x+1,y,columnSize)
				else
					""		
		in
			if (y < rowSize) then
				convertRowToString(board,x,y,columnSize)^";"^convertAllRows(board,x,y+1,rowSize,columnSize)	
			else
				 ""
		end

	(*---------------------------------------------------------------------------*)
	(*createAllRows(board,x,y,rowSize)
	TYPE: Field * int * int * int * int -> string
	PRE:rowSize = längden av board i y-led. 
	POST: Rader till en tabell i html med varje element i board som element i tabellen. Där varje element har html koden för en bild och dess id = (x,y) i board. Olika status av Fieldstate i varje element i board ger olika bilder till html koden.
	EXAMPLE:
	*)
	(*VARIANT: y - rowSize*)
	fun createAllRows(board,x,y,rowSize,columnSize) =
		let
			(*---------------------------------------------------------------------------*)
			(*row(board,x,y)
			TYPE: Field * int * int * int -> string
			PRE: columnSize = längden av field i x-led.
			POST:  Varje element i rad y i Field som en sträng av htmlkod för en bild, med samma id som position i Field och en speciell bild beroende på dess Fieldstate.
			EXAMPLE:
			*)
			(*VARIANT: x - columnSize*)
			fun row(board,x,y,columnSize) =
					if (x < columnSize) then
						(case S.sub(board,x,y) of
									S.OUT 		=>	makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/Empty.png",("",""))
									| S.VOID 	=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/EmptySpot.png",("ChooseBall(","document.getElementById("))
									| S.EXISTS	=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/Ball.png",("ChooseBall(","document.getElementById(")))
						^row(board,x+1,y,columnSize)
					else
						""		
		in
			if (y < rowSize) then
				makeRaw(row(board,x,y,columnSize))^createAllRows(board,x,y+1,rowSize,columnSize)
			else
			 ""
		end
	(*---------------------------------------------------------------------------*)
	(*convertMove(line,A,out)
	TYPE: string * string * string list -> string list
	PRE: line måste vara en komma separerad text sträng med semikolon som radbrytare
	POST: line, med varje sträng mellan 2 komman eller ett komma och ett semikolon som element i en lista.@out
	EXAMPLE:
	*)
	(*VARIANT: Enligt pre måste varje rad sluta med ";". Ger oss cChar = ";"*)
	fun convertMove(line,A,out) =
		let 
			val cChar = String.substring(line,0,1)
		in
			if cChar = "," then
				convertMove(String.substring(line,1,size(line)-1),"",A::out)
			else if cChar = ";" then
				rev(A::out)
			else
				convertMove(String.substring(line,1,size(line)-1),A^cChar,out)	
		end
	(*---------------------------------------------------------------------------*)
	(*checkUndo(pressed,moves)
	TYPE: string option * string -> bool
	PRE:none
	POST: ger true om moves <> "empty" eller none och pressed <> "true" eller help = SOME("true") och pressed <> "true". Annars false
	EXAMPLE:
	*)
	fun checkUndo(pressed,moves,help) = (getOpt(moves,"empty") <> "empty" orelse help = SOME("true")) andalso pressed <> "true" 
	(*---------------------------------------------------------------------------*)
	(*makeSelect()
	TYPE: unit -> string
	PRE:none.
	POST: En sträng med htmlkoden för en select med options Kvadrat,Hexagon, Rumb och Kryss, och på eventet onchange anropas boardstyle(). 
	EXAMPLE:
	*)
	fun makeSelect() =
		"<select id =\"mySelect\" onchange=\"boardStyle()\">"^
		  "<option value=\"Kvadrat\">Kvadrat</option>"^
		 "<option value=\"Hexagon\">Hexagon</option>"^
		 "<option value=\"Rumb\">Rumb</option>"^
		  "<option value=\"Kryss\">Kryss</option>"^
		"</select>"
	(*---------------------------------------------------------------------------*)
	(*convertMoveCoords(moveCoords)
	TYPE: string option -> (int option, int option, Direction option)
	PRE:moveCoords måste se ut enligt "x,y,z;" där x,y är tal och z =  någon av {WEST,EAST,SOUTH,NORTH}
	POST: (x,y,z) x är talet innan det första kommat, y är talet innan det andra och z är riktiningen innan semikolonet.
	EXAMPLE:
	*)
	fun convertMoveCoords(moveCoords) =
		let
			(*---------------------------------------------------------------------------*)
			(*convertToDirection(x)
			TYPE: string -> Direction
			PRE:none
			POST: "SOUTH" ger S.SOUTH, "NORTH" ger S.NORTH, "EAST" ger S.EAST, annars ges S.WEST
			EXAMPLE:
			*)
			fun convertToDirection(x) = 
				(case x of
					"SOUTH" => S.SOUTH
					| "NORTH" => S.NORTH
					| "EAST" => S.EAST
					| _ => S.WEST)
		in
			if getOpt(moveCoords,"empty") = "empty" then
				(NONE,NONE,NONE)
			else
				let 
					val a = convertMove(valOf(moveCoords),"",[]) 
				in 
					(Int.fromString(hd(a)),Int.fromString(hd(tl(a))),SOME(convertToDirection(hd(tl(tl(a)))))) 
				end
		end
	(*---------------------------------------------------------------------------*)
	(*saveUndoMoves(moveCoords,help,undoPressed,movex,movey,movedir)
	TYPE: string option * string option  * string option * int option * int option * string option -> string 
	PRE:none.
	POST: checkUndo = true så movex^movey^movedir^undoMoves
	EXAMPLE:
	*)
	fun saveUndoMoves(moveCoords,help,undoPressed,movex,movey,movedir) =
		let
			(*---------------------------------------------------------------------------*)
			(*convertFromDirection(x)
			TYPE: Direction -> string
			PRE:none
			POST: S.SOUTH ger "SOUTH", S.NORTH ger "NORTH", S.EAST ger "EAST", S.WEST ger "WEST"
			EXAMPLE:
			*)
			fun convertFromDirection(x) = 
				(case x of
					S.SOUTH	=>	"SOUTH"  
					| S.NORTH	=> 	"NORTH" 
					| S.EAST	=>	"EAST"  
					| S.WEST =>	"WEST")		
		in
			
			if checkUndo(getOpt(undoPressed,"false"),moveCoords,help) then
				let 
					val (movexInverse,moveyInverse,movedirInverse)  = S.saveInverseMove(valOf(movex),valOf(movey),valOf(movedir)) 
				in 
					Int.toString(movexInverse)^
					","^
					Int.toString(moveyInverse)^
					","^
					convertFromDirection(movedirInverse)^
					(if isSome(undoMoves) then
						","^valOf(undoMoves) 
					else
						"")
				end
			else
				getOpt(undoMoves,"")
		
		end
	(*---------------------------------------------------------------------------*)
	(*getHelp(help,board,movex,movey,movedir)
	TYPE: string option * Field * int option * int option * Direction -> (int option * int option * Direction option )
	PRE: 
	POST: Om help är lika med "true" så returneras ett smart nästa drag i x-koordinat och y-koordinat för kulan, samt riktningsförflyttning. 
	Om help är skilt från "true" så returneras movex, movey och movedir.
	EXAMPLE:
	*)
	fun getHelp(help,board,movex,movey,movedir) =
		if help = SOME("true") then
			let 
				val bMove = bestMove(board)
				val (a,b,c) = (fn SOME(a,b,c) => (SOME(a),SOME(b),SOME(c)) | (NONE) => (NONE,NONE,NONE)) bMove
			in 
				
				(a,b,c)
			end
		else
			(movex,movey,movedir)
	(*---------------------------------------------------------------------------*)
	(*chooseBoardStyle(boardStyle,currentBoard)
	TYPE: string option * Field -> Field
	PRE: None.
	POST: Om boardStyle är skilt från NONE eller "false" så skapas en ny Field beroende av värdet på boardStyle.
	EXAMPLE:
	*)
	fun chooseBoardStyle(boardStyle,currentBoard) =
			if getOpt(boardStyle,"false") <> "false" then
				case valOf(boardStyle) of
						"Kvadrat" => S.createNewField(columnSize,rowSize)
					| 	"Rumb" => S.getSpecificField("rumb")
					|	"Hexagon" => S.getSpecificField("hexagon")
					|	_ => S.getSpecificField("cross")
			else if isSome(currentBoard) then
				convert([],valOf(currentBoard))
			else
				S.createNewField(columnSize,rowSize)
	(*---------------------------------------------------------------------------*)
	val board = chooseBoardStyle(boardLayout,change)
	val (movex,movey,movedir) = convertMoveCoords(moveCoords)
	val (movex,movey,movedir) = getHelp(help,board,movex,movey,movedir)		
	val undoMoves = saveUndoMoves(moveCoords,help,undoPressed,movex,movey,movedir)		
	val board = 
		case movex of
				NONE => board
				| _ => (case getOpt(undoPressed,"false") of
						"true" => S.undo(board,valOf(movex),valOf(movey),valOf(movedir))
						| "false" => S.move(board,valOf(movex),valOf(movey),valOf(movedir)))
	

	(*---------------------------------------------------------------------------*)			
	(*makeMyInputs()
	TYPE: unit -> string
	PRE: None
	Post: Skapar en sträng med HTML-kod av typ INPUT.
	*)
	fun makeMyInputs() =
		makeInput("hidden", "input1", "input1",convertAllRows(board,0,0,rowSize,columnSize))^
		makeInput("hidden", "input2","input2","empty")^
		makeInput("hidden", "input3","input3",Bool.toString(S.gameWon(board)))^
		makeInput("hidden", "input4","input4","empty")^
		makeInput("hidden", "input5","input5",undoMoves)^
		makeInput("hidden", "input6","input6","false")^
		makeInput("hidden", "input7","input7","false")^
		makeSelect()
	(*---------------------------------------------------------------------------*)
	(*makeMyPage()
	TYPE: unit -> string
	PRE: None
	POST: Skapar en sträng innehållande HTML-kod.
	EXAMPLE:
	*)
	fun makeMyPage() =
		let
			val htmlDiv = "<div id=\"t\"></div>"
			val script 	= "var coordx = \"\";\nvar coordy = \"\";\nvar help = \"false\";\nfunction saveID(x,y)\n{\ncoordx = x;\ncoordy = y;\n}\nfunction validMove(x1,y1,x2,y2)\n{\nvar xdiff = x1 -x2;\nvar ydiff = y1 -y2;\nvar form = document.getElementById(\"input2\");\nif (xdiff == 0)\n{\nif (ydiff == 2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"SOUTH;\";\ndocument.forms[\"myform\"].submit();\n}\nelse if (ydiff == -2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"NORTH;\";\ndocument.forms[\"myform\"].submit();\n}\n}\nelse if  (ydiff == 0)\n{\nif (xdiff == 2) \n{\nform.value = x1 + \",\" + y1 + \",\" + \"WEST;\";\ndocument.forms[\"myform\"].submit();\n}\nelse if (xdiff == -2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"EAST;\";\ndocument.forms[\"myform\"].submit();\n}\n} \n}\nfunction ChooseBall(x)\n{\nvar temp = (x.id).split(\".\");\nif (x.src == \"http://user.it.uu.se/~mani9271/Ball.png\" && coordx == \"\" && coordy == \"\")\n{\nsaveID(temp[0],temp[1]);\nx.src=\"http://user.it.uu.se/~mani9271/ChosenBall.png\";\noldball = x;\n}\nelse if (x.src == \"http://user.it.uu.se/~mani9271/Ball.png\" && coordx != \"\" && coordy != \"\")\n{\nsaveID(temp[0],temp[1]);\noldball.src=\"http://user.it.uu.se/~mani9271/Ball.png\";\noldball = x;\nx.src=\"http://user.it.uu.se/~mani9271/ChosenBall.png\";\n\n}\nelse if (x.src == \"http://user.it.uu.se/~mani9271/ChosenBall.png\")\n{\nsaveID(\"\",\"\");\nx.src=\"http://user.it.uu.se/~mani9271/Ball.png\";\n}\nelse if (x.src == \"http://user.it.uu.se/~mani9271/EmptySpot.png\" && coordx != \"\" && coordy != \"\")\n{\nvar temp1 = (x.id).split(\".\");\nvalidMove(coordx,coordy,temp1[0],temp1[1]);\n}\n//document.getElementById(\"t\").innerHTML=x.src+\" : \"+coordx+\" : \"+coordy;\n}\nfunction reset()\n{\nwindow.location = \"http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi\";\n}\nfunction movehelp()\n{\nvar form = document.getElementById(\"input4\");\nform.value = \"true\";\ndocument.forms[\"myform\"].submit();\n}\nfunction win()\n{\nvar form = document.getElementById(\"input3\");\nif (form.value == \"true\")\n{\n\ndocument.getElementById(\"t\").innerHTML=\"You Win!!\";\n}\n\n}\nfunction undo()\n{\n\nvar form = document.getElementById(\"input5\");\nvar formValue = form.value;\nif (formValue != \"\")\n{\nvar temp = formValue.split(\",\");\nvar x1 = temp[0];\nvar y1 = temp[1];\nvar direct = temp[2]; \nvar x2 = \"\";\nvar y2 = \"\";\nvar stringlength = (x1+y1+direct+\",,,\").length;\n\nswitch(direct)\n{\ncase \"SOUTH\":\nx2 = x1;y2 = parseInt(y1)-2;\nbreak;\ncase \"NORTH\":\nx2 =  x1;y2=2+parseInt(y1);\nbreak;\ncase \"WEST\":\nx2 = parseInt(x1)-2;y2 = y1;\nbreak;\ncase \"EAST\":\nx2 = parseInt(x1)+2;y2 = y1;\nbreak;\n}\n\n\n\nform.value = formValue.substring(stringlength);\n//document.getElementById(\"t\").innerHTML=x1+\", \"+y1 +\", \"+direct+\", \"+ x2+\", \"+y2;\ndocument.getElementById(\"input6\").value = \"true\";\nvalidMove(x1,y1,x2,y2);\n\n//document.getElementById(\"t\").innerHTML=stringlength;\n\n}\n\n}\nfunction boardStyle()\n{\nvar element = document.getElementById(\"mySelect\");\nvar sValue = element.options[element.selectedIndex].value;\ndocument.getElementById(\"input7\").value = sValue;\ndocument.forms[\"myform\"].submit();\n}\n"
		in
			htmlDiv^
			makeScript(script)^
			makeTable("30","margin-left: 20%;",createAllRows(board,0,0,rowSize,columnSize))^
			makeForm (url, makeMyInputs(),"myform")^
			makeButton("movehelp()","Help")^
			makeButton("undo()","Ångra")
		
		
		end	
	(*---------------------------------------------------------------------------*)	

	in 
		printPage("",makeMyPage(), "win()")
		

	end;