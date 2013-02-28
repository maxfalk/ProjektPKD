(* 
-- PSEUDOKOD --

1. L?s in b, ett godtyckligt br?dscenario.
2. S?tt M = getMoves(b)::M.
3. Om M ?r tom, avsluta rekursionen. (F?rlust).
4. Utf?r doMove(hd(M)), s?tt resultatet till nB, s?tt M = tl(M), s?tt DM = hd(M)::DM.
5. Om checkBoard(nB) = 1 (antal pj?ser kvar), g? till steg 8.
6. Om checkFail = true, s?tt DM = tl(DM), g? till steg 3.
7. S?tt b =  nB, g? till steg 2.
8. Ge tillbaka sista elementet i DM.
9. Slut.


1. L?s in b, ett godtyckligt br?dscenario.
2. S?tt M = getMoves(b).
3. Om M ?r tom, avsluta rekursionen.
4. Utf?r doMove(hd(M)), s?tt resultatet till nB, s?tt M = tl(M), s?tt DM = hd(M).
5. Om checkBoard(nB) = 1 (antal pj?ser kvar), g? till steg 8.
6. Om checkFail(nB) = true, s?tt DM = tl(DM), g? till steg 3.
7. S?tt b =  nB, g? till steg 2.
8. Ge tillbaka sista elementet i DM.
9. Slut.


*)

use "solitarieVec.sml";



(* bestMove(b)
   TYPE: Field -> (int * int * Direction) option
   PRE: 
   POST: SOME(The first non-losing move), NONE if no non-losing move was found.
   EXAMPLE:
*)
fun bestMove(board) = 
    let
        (* getMoves(b)
           TYPE: Field -> (Field * int * int * Direction) list
           PRE: 
           POST: A list of all possible moves at the game board b's current state.
           EXAMPLE:
        *)
        fun getMoves(board) = 
			let
				fun checkCross(board,x,y) = 
					let
						val right = CheckForPiece(board,x+1,y,EXISTS) andalso CheckForPiece(board,x+2,y,EXISTS)
						val left = CheckForPiece(board,x-1,y,EXISTS) andalso CheckForPiece(board,x-2,y,EXISTS)
						val down = CheckForPiece(board,x,y-1,EXISTS) andalso CheckForPiece(board,x,y-2,EXISTS)
						val up = CheckForPiece(board,x,y+1,EXISTS) andalso CheckForPiece(board,x,y+2,EXISTS)
					in
					
					end
				val (xLength,yLength) = fieldLength(board)
			in
				getMoves'(xLength,yLength)
			
			end;

        (* doMove(b,x,y,dir)
           TYPE: Field * int * int * Direction -> Field
           PRE: 
           POST: The game board b's state after the given move is made.
           EXAMPLE:
        *)
        fun doMove(board,x,y,dir) = board;

        (* checkBoard(b)
           TYPE: Field -> int
           PRE: 
           POST: The number of game pieces left on the game board b.
           EXAMPLE:
        *)
        fun checkBoard(board) = 1;

        (* checkFail(b)
           TYPE: Field -> bool
           PRE: 
           POST: Gives true if no more move can be made on the game board b. Else false.
           EXAMPLE:
        *)
        fun checkFail(board) = true;

        (* bestMove'(b, m)
           TYPE: Field * (Field * int * int * Direction) list -> int * int * Direction
           PRE: 
           POST: The first non-losing move.
           EXAMPLE: 
         *)
        fun bestMove'(board,m::ms) =
            if(getMoves(board) = []) then
                []
            else
                let
                    val newBoard = doMove(m);
                in
                    (* If we've won *)
                    if(checkBoard(newBoard) = 1) then
                        [m]

                    (* If we've *)
                    else if(checkFail(newBoard) = true) then
                        bestMove'(board, ms)
                    else
                        if(bestMove'(newBoard,getMoves(newBoard)) = []) then
                            bestMove'(board, ms)
                        else
                            [m]
                end;

        (* bestMove'(b)
           TYPE: Field -> (int * int * Direction) option
           PRE: 
           POST: SOME(The first non-losing move), NONE if no non-losing move was found.
           EXAMPLE: 
         *)
        fun start(board) =
            let
                val result = bestMove'(board,getMoves(board))
            in
                if(result = []) then
                    NONE
                else
                    SOME(hd(result))
            end;
    in
        start(board)
    end;
