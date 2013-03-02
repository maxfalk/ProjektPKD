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
	val rawSize = 7;
	val url = "http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi"
	val change = Mosmlcgi.cgi_field_string("input1")
	val moveCoords = Mosmlcgi.cgi_field_string("input2")
	val help = Mosmlcgi.cgi_field_string("input4")
	(*---------------------------------------------------------------------------*)
	fun convertToFieldState(x) =
		(case x of
			"OUT" => S.OUT
			| "VOID" => S.VOID
			| _ => S.EXISTS)
	(*---------------------------------------------------------------------------*)
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

	(*---------------------------------------------------------------------------*)
	fun convert(board,"") = S.field(Vector.fromList(board))
		| convert(board,line) =
		let
			val(out,line) = convertRowToField(line,"",[])
			val out = Vector.fromList(out)
		
		in
			convert(board@[out],line)
		end;
	(*---------------------------------------------------------------------------*)
	fun convertRowToString(board,x,y) =
		if (x < columnSize) then
			(case S.sub(board,x,y) of
				S.OUT 		=>	"OUT"
				| S.VOID 	=>  "VOID"
				| S.EXISTS	=>  "EXISTS"
			)^","^convertRowToString(board,x+1,y)
		else
			""
	(*---------------------------------------------------------------------------*)
	fun convertAllRows(board,x,y) =
		if (y < rawSize) then
			convertRowToString(board,x,y)^";"^convertAllRows(board,x,y+1)	
		else
			 ""
	(*---------------------------------------------------------------------------*)
	fun row(board,x,y) =
			if (x < columnSize) then
				(case S.sub(board,x,y) of
							S.OUT 		=>	makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/Empty.png",("",""))
							| S.VOID 	=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/EmptySpot.png",("ChooseBall(","document.getElementById("))
							| S.EXISTS	=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/Ball.png",("ChooseBall(","document.getElementById(")))
				^row(board,x+1,y)
			else
			 ""
	(*---------------------------------------------------------------------------*)
	fun createAllRows(board,x,y) =
			if (y < rawSize) then
				makeRaw(row(board,x,y))^createAllRows(board,x,y+1)
			else
			 ""
	(*---------------------------------------------------------------------------*)
	fun convertDirection(x) = 
		(case x of
			"SOUTH" => S.SOUTH
			| "NORTH" => S.NORTH
			| "EAST" => S.EAST
			| "WEST" => S.WEST)
	(*---------------------------------------------------------------------------*)

	(*---------------------------------------------------------------------------*)
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
	fun listtostring([]) = ""
		| listtostring(first::last) = first^listtostring(last)
	(*---------------------------------------------------------------------------*)
		val (movex,movey,movedir) = case moveCoords of 
					NONE => (NONE,NONE,NONE)
					| _ => let val a = convertMove(valOf(moveCoords),"",[]) in (Int.fromString(hd(a)),Int.fromString(hd(tl(a))),SOME(convertDirection(hd(tl(tl(a)))))) end

		val board = case change of
				NONE =>	S.createNewField(columnSize,rawSize)
				| _	=> convert([],valOf(change))
				
		val (movex,movey,movedir) = case help of
					 SOME("true") => let val (a,b,c) = valOf(bestMove(board)) in (SOME(a),SOME(b),SOME(c)) end 
					| _ => (movex,movey,movedir)
					
					
		val board = case movex of
					NONE => board
					| _ => S.move(board,valOf(movex),valOf(movey),valOf(movedir))


		val form  	 = makeForm (url, makeInput("text", "input1", "input1",convertAllRows(board,0,0))^makeInput("text", "input2","input2","empty")^makeInput("text", "input3","input3",Bool.toString(S.gameWon(board)))^makeInput("text", "input4","input4","empty"),"myform")
		val script 	= "var coordx = \"\";\nvar coordy = \"\";\nvar help = \"false\";\nfunction saveID(x,y)\n{\ncoordx = x;\ncoordy = y;\n}\nfunction validMove(x1,y1,x2,y2)\n{\nvar xdiff = x1 -x2;\nvar ydiff = y1 -y2;\nvar form = document.getElementById(\"input2\");\nif (xdiff == 0)\n{\nif (ydiff == 2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"SOUTH;\";\ndocument.forms[\"myform\"].submit();\n}\nelse if (ydiff == -2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"NORTH;\";\ndocument.forms[\"myform\"].submit();\n}\n}\nelse if  (ydiff == 0)\n{\nif (xdiff == 2) \n{\nform.value = x1 + \",\" + y1 + \",\" + \"WEST;\";\ndocument.forms[\"myform\"].submit();\n}\nelse if (xdiff == -2)\n{\nform.value = x1 + \",\" + y1 + \",\" + \"EAST;\";\ndocument.forms[\"myform\"].submit();\n}\n} \n}\nfunction ChooseBall(x)\n{\nif (x.src == \"http://user.it.uu.se/~mani9271/Ball.png\" && coordx == \"\" && coordy == \"\")\n{\nvar temp = (x.id).split(\".\");\nsaveID(temp[0],temp[1]);\nx.src=\"http://user.it.uu.se/~mani9271/ChosenBall.png\";\n}\nelse if (x.src == \"http://user.it.uu.se/~mani9271/ChosenBall.png\")\n{\nsaveID(\"\",\"\");\nx.src=\"http://user.it.uu.se/~mani9271/Ball.png\";\n}\nelse if (x.src == \"http://user.it.uu.se/~mani9271/EmptySpot.png\" && coordx != \"\" && coordy != \"\")\n{\nvar temp1 = (x.id).split(\".\");\nvalidMove(coordx,coordy,temp1[0],temp1[1]);\n}\ndocument.getElementById(\"t\").innerHTML=x.src+\" : \"+coordx+\" : \"+coordy;\n}\nfunction reset()\n{\nwindow.location = \"http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi\";\n}\nfunction movehelp()\n{\nvar form = document.getElementById(\"input4\");\nform.value = \"true\";\ndocument.forms[\"myform\"].submit();\n}\nfunction win()\n{\nvar form = document.getElementById(\"input3\");\nif (form.value == \"true\")\n{\n\ndocument.getElementById(\"t\").innerHTML=\"You Winn!!\";\n}\n\n}\n\n"
		val page 	= "<div id=\"t\"></div>"^makeScript(script)^makeTable("30","margin-left: 20%;",createAllRows(board,0,0))^form^makeButton("reset()","restart")^makeButton("movehelp()","Help")
	in 
		printPage("",page, "win()")

	end;