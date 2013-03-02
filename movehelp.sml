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

use "S.sml";
*)





(* bestMove(b)
   TYPE: Field -> (int * int * Direction) option
   PRE: 
   POST: SOME(The first non-losing move), NONE if no non-losing move was found.
   EXAMPLE:
*)
fun bestMove (board) = 
    let
        (* getMoves(b)
           TYPE: Field -> (Field * int * int * Direction) list
           PRE: 
           POST: A list of all possible moves at the game board b's current state.
           EXAMPLE:
        *)
        fun getMoves (board) = 
	    let
                val (xLength,yLength) = S.fieldLength(board)

                (* checkCross(b,x,y)
                   TYPE: int * int -> (Field * int * int * Direction) list
                   PRE:     
                   POST: A list of all possible moves from (x,y) at the game board b's current state.
                   EXAMPLE:
                 *)
		fun checkCross (x,y) = 
		    let
			val east = S.checkForPiece(board,x+1,y,S.EXISTS) andalso S.checkForPiece(board,x+2,y,S.EXISTS)
			val west = S.checkForPiece(board,x-1,y,S.EXISTS) andalso S.checkForPiece(board,x-2,y,S.EXISTS)
			val south = S.checkForPiece(board,x,y-1,S.EXISTS) andalso S.checkForPiece(board,x,y-2,S.EXISTS)
			val north = S.checkForPiece(board,x,y+1,S.EXISTS) andalso S.checkForPiece(board,x,y+2,S.EXISTS)
                    in
                        (if(east) then
                             [(board,x+1,y,S.WEST)]
                         else
                             [])
                        @
                        (if(west) then
                             [(board,x-1,y,S.EAST)]
                         else
                             [])
                        @
                        (if(south) then
                             [(board,x,y+2,S.NORTH)]
                         else
                             [])
                        @
                        (if(north) then
                             [(board,x,y-2,S.SOUTH)]
                         else
                             [])
		    end;
                
                (* checkThis(b,x,y)
                   TYPE: int * int -> (Field * int * int * Direction) list
                   PRE:     
                   POST: A list of all possible moves from (x,y) at the game board b's current state.
                   EXAMPLE:
                 *)
                fun checkThis (x,y) = 
                    let
                         val this = S.checkForPiece(board,x+1,y,S.VOID)
                    in
                         if(this) then
                             checkCross(x,y)
                         else
                             []
                    end;

                (* getMoves'(b,x,y)
                   TYPE: Field * int * int -> (Field * int * int * Direction) list
                   PRE:     
                   POST: A list of all possible moves from (x,y) at the game board b's current state.
                   EXAMPLE:
                 *)
		fun getMoves' (0,0) = checkThis(0,0)
                  | getMoves' (x,0) = checkThis(x,0)@(getMoves'(x-1,yLength))
                  | getMoves' (x,y) = checkThis(x,y)@(getMoves'(x,y-1))

	    in
		getMoves'(xLength,yLength)		 
	    end;

        (* checkFail(b)
           TYPE: Field -> bool
           PRE: 
           POST: Gives true if no more move can be made on the game board b. Else false.
           EXAMPLE:
        *)
        fun checkFail (board) = true;

        (* bestMove'(b, m)
           TYPE: Field * (Field * int * int * Direction) list -> int * int * Direction
           PRE: 
           POST: The first non-losing move.
           EXAMPLE: 
         *)
        fun bestMove' (board,m::ms) =
            if(getMoves(board) = []) then
                []
            else
                let
                    val newBoard = S.move(m);
                in
                    (* If we've won *)
                    if(S.gameWon(board)) then
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
        fun start (board) =
            let
                val result = bestMove'(board,getMoves(board))
            in
                if(result = []) then
                    NONE
                else
                    let
                        val (brd,x,y,dir) = hd(result);
                    in
                        SOME(x,y,dir)
                    end
            end;
    in
        start(board)
    end;
(*
fun brT (b,SOME(x,y,dir)) = (b,x,y,dir);

val b1 = S.createNewField(7,7);
val b2 = S.move(brT(b1,bestMove(b1)));
val b3 = S.move(brT(b2,bestMove(b2)));
val b4 = S.move(brT(b3,bestMove(b3)));
val b5 = S.move(brT(b4,bestMove(b4)));
val b6 = S.move(brT(b5,bestMove(b5)));
val b7 = S.move(brT(b6,bestMove(b6)));
*)