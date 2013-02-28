(**)


open SolitaireHtml;


val B = 
let
	val columnSize = 7;
	val rawSize = 7;
	val newBoard = S.createNewField(columnSize,rawSize);
	(*val changePicture = Mosmlcgi.cgi_field_string*)
	val url = "http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi"


	fun createBoard(x,y) =
		if (y < rawSize) then
			if (x < columnSize) then
				if S.sub(newBoard,x,y) = S.OUT then
					(makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"Empty.png",("","")) ^ createBoard(x+1,y))
				else if S.sub(newBoard,x,y) = S.VOID then
					(makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"EmptySpot.png",("","")) ^ createBoard(x+1,y))
				else
					(makeImage((Int.toString(x) ^ "." ^ Int.toString(y)),"Ball.png",("ChooseBall(","document.getElementById(")) ^ createBoard(x+1,y))
			else
				(createBoard(0,(y+1)))
		else
			""
		;

in printPage("",makeTable("30","margin-left: 400;",makeRaw(createBoard(0,0))))
end
;