use "S.sml";

(* bestMove(b)
   TYPE: Field -> (int * int * Direction) option
   PRE: NONE
   POST: SOME(The first non-losing move), NONE if no non-losing move was found.
*)
fun bestMove (board) = 
    let
        (* getMoves(b)
           TYPE: Field -> (Field * int * int * Direction) list
           PRE: NONE
           POST: A list of all possible moves at the game board b's current state.
        *)
        fun getMoves (board) = 
	    let
                val (yLength,xLength) = S.fieldLength(board)

                (* checkCross(b,x,y)
                   TYPE: int * int -> (Field * int * int * Direction) list
                   PRE: NONE     
                   POST: A list of all possible moves to (x,y) at the game board b's current state.
                 *)
		fun checkCross (x,y) = 
		    let
			val east = S.checkForPiece(board,x+1,y,S.EXISTS) andalso S.checkForPiece(board,x+2,y,S.EXISTS)
			val west = S.checkForPiece(board,x-1,y,S.EXISTS) andalso S.checkForPiece(board,x-2,y,S.EXISTS)
			val south = S.checkForPiece(board,x,y-1,S.EXISTS) andalso S.checkForPiece(board,x,y-2,S.EXISTS)
			val north = S.checkForPiece(board,x,y+1,S.EXISTS) andalso S.checkForPiece(board,x,y+2,S.EXISTS)
                    in
                        (if(east) then
                             [(board,x+2,y,S.WEST)]
                         else
                             [])
                        @
                        (if(west) then
                             [(board,x-2,y,S.EAST)]
                         else
                             [])
                        @
                        (if(south) then
                             [(board,x,y-2,S.NORTH)]
                         else
                             [])
                        @
                        (if(north) then
                             [(board,x,y+2,S.SOUTH)]
                         else
                             [])
		    end;
                
                (* checkThis(b,x,y)
                   TYPE: int * int -> (Field * int * int * Direction) list
                   PRE: NONE
                   POST: A list of all possible moves to (x,y) at the game board b's current state if (x,y) is empty/free, else, a list of no moves.
                 *)
                fun checkThis (x,y) = 
                    let
                         val this = S.checkForPiece(board,x,y,S.VOID)
                    in
                         if(this) then
                             checkCross(x,y)
                         else
                             []
                    end;

                (* getMoves'(b,x,y)
                   TYPE: Field * int * int -> (Field * int * int * Direction) list
                   PRE: NONE    
                   POST: A list of all possible moves at the game board b's current state.
                 *)
                (* VARIANT: x *)
		fun getMoves' (0,0) = checkThis(0,0)
                  | getMoves' (x,0) = checkThis(x,0)@(getMoves'(x-1,yLength))
                  | getMoves' (x,y) = checkThis(x,y)@(getMoves'(x,y-1))

	    in
		getMoves'(xLength-1,yLength-1)		 
	    end;

        (* bestMove'(b, m)
           TYPE: Field * (Field * int * int * Direction) list -> int * int * Direction
           PRE: NONE
           POST: The first non-losing move.
         *)
        (* VARIANT: (The number of game pieces left on the board)-1 *)
        fun bestMove' (board,[]) = []
          | bestMove' (board,m::ms) = 
            let
                val newBoard = S.move(m);
            in
                
                (* If we've won *)
                if(S.gameWon(newBoard)) then
                    [m]

                (* If we're not sure yet *)
                else
                    if(bestMove'(newBoard,getMoves(newBoard)) = []) then
                        bestMove'(board, ms)
                    else
                        [m]
            end;
        
        (* bestMove'(b)
           TYPE: Field -> (int * int * Direction) option
           PRE: NONE
           POST: SOME(The first non-losing move), NONE if no non-losing move was found.
         *)
        fun start (board) =
            let
                val result = bestMove'(board,getMoves(board));
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

