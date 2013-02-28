val vectest = S.createNewField(4,4);
val myfield = S.createNewField(4,4);
val myfield1x1 = S.createNewField(1,1);
val testCFP = S.updateVector(myfield4x4,2,0,S.OUT);
val myfieldGameWon4x4 = S.createNewField(4,4);
val undoField = S.createNewField(8,8);


(*fun sub(field(plan),x,y) *)
(S.sub(vectest,0,0) = S.EXISTS,"S.sub(vectest,0,0)",S.sub(vectest,0,0));
(S.sub(vectest,1,1) = S.EXISTS,"S.sub(vectest,1,1)",S.sub(vectest,1,1));
(S.sub(vectest,2,2) = S.VOID,"S.sub(vectest,0,1) ",S.sub(vectest,0,1));


(*updateVector(vec,x,y,value)*)
(S.sub(S.updateVector(myfield,0,0,S.VOID),0,0) = S.VOID, "S.sub(S.updateVector(myfield,0,0,S.VOID),0,0)");
(S.sub(S.updateVector(myfield,3,3,S.VOID),3,3) = S.VOID, "S.sub(S.updateVector(myfield,3,3,S.VOID),3,3)"); 
(S.sub(S.updateVector(myfield,2,0,S.OUT),2,0) = S.OUT, "S.sub(S.updateVector(myfield,3,3,S.VOID),3,3)");
(S.sub(S.updateVector(myfield,2,2,S.EXISTS),2,2) = S.EXISTS, "S.sub(S.updateVector(myfield,3,3,S.VOID),3,3)");


(*createNewField(xLength,yLength)*)
(S.createNewField(4,4) =
S.field(#[#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]]),"S.createNewField(4,4)");
(S.createNewField(1,1) = S.field(#[#[S.VOID]]),"S.createNewField(1,1)");


(*fieldLength(plan)*)
(S.fieldLength(myfield4x4) = (4,4),"S.fieldLength(myfield4x4)");
(S.fieldLength(myfield1x1) = (1,1),"S.fieldLength(myfield1x1)");
(S.fieldLength(S.field(#[#[]])) = (1,0),"S.fieldLength(#[#[]]))");

(*S.OUTOfBounds(plan,x,y)*)
(S.outOfBounds(myfield4x4,5,5) = false, "S.outOfBounds(myfield4x4,5,5)");
(S.outOfBounds(myfield4x4,4,4) = false, "S.outOfBounds(myfield4x4,4,4)");
(S.outOfBounds(myfield4x4,0,0) = true, "S.outOfBounds(myfield4x4,0,0)");
(S.outOfBounds(myfield4x4,~1,~1) = false, "S.outOfBounds(myfield4x4,~1,~1)");
(S.outOfBounds(myfield4x4,~1,0) = false, "S.outOfBounds(myfield4x4,~1,0)");
(S.outOfBounds(myfield4x4,0,~1) = false, "S.outOfBounds(myfield4x4,0,~1)");
(S.outOfBounds(myfield4x4,0,4) = false, "S.outOfBounds(myfield4x4,0,4)");


(*S.checkForPiece(cField,x,y,value)*)
(S.checkForPiece(myfield4x4,0,0,S.VOID) = false, "S.checkForPiece(myfield4x4,0,0,S.VOID)");
(S.checkForPiece(myfield4x4,0,0,S.EXISTS) = true, "S.checkForPiece(myfield4x4,0,0,S.VOID)");
(S.checkForPiece(myfield4x4,0,~1,S.EXISTS) = false, "S.checkForPiece(myfield4x4,0,~1,S.EXISTS)");
(S.checkForPiece(myfield4x4,5,0,S.EXISTS) = false, "S.checkForPiece(myfield4x4,5,0,S.EXISTS)");
(S.checkForPiece(myfield4x4,4,4,S.OUT) = false, "S.checkForPiece(myfield4x4,4,4,S.OUT)");
(S.checkForPiece(myfield4x4,2,2,S.VOID) = true, "S.checkForPiece(myfield4x4,2,2,S.VOID)");
(S.checkForPiece(testCFP,2,0,S.OUT) = true, "S.checkForPiece(myfield4x4,2,0,S.OUT) ");


(**movedirection(cField,x,y,direct)*)
(S.movedirection(myfield4x4,2,2,S.WEST,S.VOID,S.VOID,S.EXISTS) = 
	S.field(#[
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
	#[S.EXISTS,S.VOID,S.VOID,S.EXISTS],
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
	])
,"(S.movedirection(myfield4x4,2,2,S.WEST,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield4x4,1,2,S.EAST,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.VOID,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]),"S.movedirection(myfield4x4,1,2,S.EAST,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield4x4,2,1,S.NORTH,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]),"S.movedirection(myfield4x4,2,1,S.NORTH,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield4x4,2,2,S.SOUTH,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.movedirection(myfield4x4,2,2,S.SOUTH,S.VOID,S.VOID,S.EXISTS)");

(*rules(cField,x,y,NORTH)*)
(S.rules(myfield4x4,0,0,S.NORTH) = false, "rules(myfield4x4,0,0,NORTH)");
(S.rules(myfield4x4,6,6,S.SOUTH) = false, "rules(myfield4x4,0,0,SOUTH)");
(S.rules(myfield4x4,4,2,S.WEST) = true, "rules(myfield4x4,0,0,WEST)");
(S.rules(myfield4x4,0,0,S.EAST) = false, "rules(myfield4x4,0,0,EAST)");
(S.rules(myfield4x4,110,110,S.EAST) = false, "rules(myfield4x4,0,0,EAST)");

(*move(cField,x,y,direc)*)
(S.move(myfield4x4,0,2,S.EAST) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.VOID,S.VOID,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.move(myfield4x4,0,2,S.EAST)");
(S.move(myfield4x4,0,2,S.WEST) = myfield4x4, "S.move(myfield4x4,0,2,S.WEST)");
(S.move(myfield4x4,2,0,S.NORTH) = 
S.field(#[
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.move(myfield4x4,2,0,S.NORTH)");
(S.move(myfield4x4,10,20,S.SOUTH) = myfield4x4, "S.move(myfield4x4,10,20,S.SOUTH)");

(*gameWon'(cField as field(plan),y,totalFound)*)

(S.gameWon'(myfieldGameWon4x4,4,0) = false, "gameWon'(myfield4x4,4,0)");
(S.gameWon'(
S.field(#[
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.EXISTS]
]),4,0) = true, "gameWon'(!!kolla koden!!,3,0)");

(*gameWon(cField)*)
(S.gameWon(myfieldGameWon4x4) = false, "S.gameWon(myfieldGameWon4x4)");
(S.gameWon(
S.field(#[
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.EXISTS],
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.VOID]
])
) = true, "S.gameWon(!!kolla koden!!");

(*saveInverseMove(x,y,direct)*)
S.saveInverseMove(0,0,S.EAST);
(hd( !S.oldMoves) = (2,0,S.WEST));
S.saveInverseMove(2,0,S.WEST);
(hd( !S.oldMoves) = (0,0,S.EAST));
S.saveInverseMove(4,4,S.SOUTH);
(hd( !S.oldMoves) = (4,2,S.NORTH));
S.saveInverseMove(4,4,S.NORTH);
(hd( !S.oldMoves) = (4,6,S.SOUTH));

(*undo(cField)*)
(S.undo(S.move(undoField,2,4,S.EAST)) = undoField,"S.undo(S.move(undoField,2,4,S.EAST))");
(S.undo(S.move(undoField,6,4,S.WEST)) = undoField,"S.undo(S.move(undoField,2,4,S.WEST))");
(S.undo(S.undo(S.move(S.move(undoField,6,4,S.WEST),5,2,S.NORTH))) = undoField,"S.undo(S.move(undoField,2,4,S.WEST))");



