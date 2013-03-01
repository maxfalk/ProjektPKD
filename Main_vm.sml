(*
use "SolitaireHtml.sml";
use "S.sml";

*)


open SolitaireHtml;



val _ = 
let
	val columnSize = 7;
	val rawSize = 7;
	val url = "http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi"
	val change = Mosmlcgi.cgi_field_string("test")
	

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
				convertRowToField(String.substring(line,1,size(line)-1),"",convertToFieldState(A)::out)
			else if cChar = ";" then
				(out,String.substring(line,1,size(line)-1))
			else
				convertRowToField(String.substring(line,1,size(line)-1),A^cChar,out)	
		end;

	(*---------------------------------------------------------------------------*)
	fun convert(S.field(board),y,"") = S.field(board)
		| convert(S.field(board),y,line) =
		let
			val(out,line) = convertRowToField(line,"",[])
			val out = Vector.fromList(out)
			val board = S.update(board,y,out)
		
		in
			convert(S.field(board),y+1,line)
		end;
	(*---------------------------------------------------------------------------*)
	fun convertRowToString(board,x,y) =
		if (x < columnSize) then
			(case S.sub(board,x,y) of
				S.OUT 		=>	"OUT"
				| S.VOID 	=>  "VOID"
				| _			=>  "EXISTS"
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
							| S.VOID 	=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/EmptySpot.png",("",""))
							| _			=>  makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"http://user.it.uu.se/~mani9271/Ball.png",("ChooseBall(","document.getElementById(")))
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
	(*---------------------------------------------------------------------------*)
	(*---------------------------------------------------------------------------*)
			 

		val board = S.createNewField(columnSize,rawSize)
		val board = case change of
				NONE =>	S.createNewField(columnSize,rawSize)
				| _	=> convert(board,0,valOf(change))



		val form   = makeForm (url, makeInput ("hidden", "test",convertAllRows(board,0,0)  ) ^ makeSubmit ("Press me!"))
		
	in 
	(
		printPage("",makeTable("30","margin-left: 20%;",createAllRows(board,0,0))^form); 
		print("change:"^getOpt(change,"NONE")^"\n")
	)
	end;