val vectest = S.createNewField(4,4);
val myfield = S.createNewField(4,4);
val myfield1x1 = S.createNewField(1,1);
val testCFP = S.updateVector(myfield,2,0,S.OUT);
val myfieldGameWon4x4 = S.createNewField(4,4);
val undoField = S.createNewField(7,7);


(*fun sub(field(plan),x,y) *)
(S.sub(vectest,0,0) = S.EXISTS,"S.sub(vectest,0,0)",S.sub(vectest,0,0));
(S.sub(vectest,1,1) = S.EXISTS,"S.sub(vectest,1,1)",S.sub(vectest,1,1));
(S.sub(vectest,2,2) = S.VOID,"S.sub(vectest,0,1) ",S.sub(vectest,0,1));


(*updateVector(vec,x,y,value)*)
(*Ger kod teckning i update också*)
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
(S.fieldLength(myfield) = (4,4),"S.fieldLength(myfield)");
(S.fieldLength(myfield1x1) = (1,1),"S.fieldLength(myfield1x1)");
(S.fieldLength(S.field(#[#[]])) = (1,0),"S.fieldLength(#[#[]]))");
(S.fieldLength(S.field(#[])) = (0,0),"S.fieldLength(#[])");

(*S.OUTOfBounds(plan,x,y)*)
(S.outOfBounds(myfield,5,5) = false, "S.outOfBounds(myfield,5,5)");
(S.outOfBounds(myfield,4,4) = false, "S.outOfBounds(myfield,4,4)");
(S.outOfBounds(myfield,0,0) = true, "S.outOfBounds(myfield,0,0)");
(S.outOfBounds(myfield,~1,~1) = false, "S.outOfBounds(myfield,~1,~1)");
(S.outOfBounds(myfield,~1,0) = false, "S.outOfBounds(myfield,~1,0)");
(S.outOfBounds(myfield,0,~1) = false, "S.outOfBounds(myfield,0,~1)");
(S.outOfBounds(myfield,0,4) = false, "S.outOfBounds(myfield,0,4)");


(*S.checkForPiece(cField,x,y,value)*)
(S.checkForPiece(myfield,0,0,S.VOID) = false, "S.checkForPiece(myfield,0,0,S.VOID)");
(S.checkForPiece(myfield,0,0,S.EXISTS) = true, "S.checkForPiece(myfield,0,0,S.VOID)");
(S.checkForPiece(myfield,0,~1,S.EXISTS) = false, "S.checkForPiece(myfield,0,~1,S.EXISTS)");
(S.checkForPiece(myfield,5,0,S.EXISTS) = false, "S.checkForPiece(myfield,5,0,S.EXISTS)");
(S.checkForPiece(myfield,4,4,S.OUT) = false, "S.checkForPiece(myfield,4,4,S.OUT)");
(S.checkForPiece(myfield,2,2,S.VOID) = true, "S.checkForPiece(myfield,2,2,S.VOID)");
(S.checkForPiece(testCFP,2,0,S.OUT) = true, "S.checkForPiece(myfield,2,0,S.OUT) ");


(**movedirection(cField,x,y,direct)*)
(S.movedirection(myfield,2,2,S.WEST,S.VOID,S.VOID,S.EXISTS) = 
	S.field(#[
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
	#[S.EXISTS,S.VOID,S.VOID,S.EXISTS],
	#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
	])
,"(S.movedirection(myfield,2,2,S.WEST,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield,1,2,S.EAST,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.VOID,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]),"S.movedirection(myfield,1,2,S.EAST,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield,2,1,S.NORTH,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]),"S.movedirection(myfield,2,1,S.NORTH,S.VOID,S.VOID,S.EXISTS)");
(S.movedirection(myfield,2,2,S.SOUTH,S.VOID,S.VOID,S.EXISTS) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.movedirection(myfield,2,2,S.SOUTH,S.VOID,S.VOID,S.EXISTS)");

(*rules(cField,x,y,NORTH)*)
(S.rules(myfield,0,0,S.NORTH) = false, "rules(myfield,0,0,NORTH)");
(S.rules(myfield,6,6,S.SOUTH) = false, "rules(myfield,0,0,SOUTH)");
(S.rules(myfield,4,2,S.WEST) = true, "rules(myfield,0,0,WEST)");
(S.rules(myfield,0,0,S.EAST) = false, "rules(myfield,0,0,EAST)");
(S.rules(myfield,110,110,S.EAST) = false, "rules(myfield,0,0,EAST)");

(*move(cField,x,y,direc)*)
(S.move(myfield,0,2,S.EAST) =
S.field(#[
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.VOID,S.VOID,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.move(myfield,0,2,S.EAST)");
(S.move(myfield,0,2,S.WEST) = myfield, "S.move(myfield,0,2,S.WEST)");
(S.move(myfield,2,0,S.NORTH) = 
S.field(#[
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.VOID,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
#[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS]
]), "S.move(myfield,2,0,S.NORTH)");
(S.move(myfield,10,20,S.SOUTH) = myfield, "S.move(myfield,10,20,S.SOUTH)");

(*gameWon'(cField as field(plan),y,totalFound)*)
(*
(S.gameWon'(myfieldGameWon4x4,4,0) = false, "gameWon'(myfield,4,0)");
(S.gameWon'(
S.field(#[
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.VOID],
#[S.VOID,S.VOID,S.VOID,S.EXISTS]
]),4,0) = true, "gameWon'(!!kolla koden!!,3,0)");
*)
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
(S.saveInverseMove(0,0,S.EAST) = (2,0,S.WEST),"S.saveInverseMove(0,0,S.EAST)");
(S.saveInverseMove(2,0,S.WEST) = (0,0,S.EAST),"S.saveInverseMove(2,0,S.WEST)");
(S.saveInverseMove(4,4,S.SOUTH) = (4,2,S.NORTH),"S.saveInverseMove(4,4,S.SOUTH)");
(S.saveInverseMove(4,4,S.NORTH) = (4,6,S.SOUTH),"S.saveInverseMove(4,4,S.NORTH)");

(*undo*)
(S.undo(S.move(undoField,1,3,S.EAST),3,3,S.WEST) = undoField,"S.undo(S.move(undoField,2,4,S.EAST),4,4,S.WEST)");
(S.undo(S.move(undoField,6,4,S.WEST),3,3,S.EAST) = undoField,"S.undo(S.move(undoField,2,4,S.WEST))");
(S.undo(S.undo(S.move(S.move(undoField,3,4,S.SOUTH),3,2,S.NORTH),3,4,S.SOUTH),3,3,S.NORTH) = undoField,"S.undo(S.move(undoField,2,4,S.WEST))");

(*SaveFile*)
(S.saveHighScoreList("test.score",[("Max",1,2),("Johan",3,4),("Erik",5,6),("Jonas",7,8),("Adam",9,10)]));

(*loadFile*)
(S.loadHighScoreList("test.score") = [("Max",1,2),("Johan",3,4),("Erik",5,6),("Jonas",7,8),("Adam",9,10)],"loadHighScoreList");

(*sortHighScoreList*)
(S.sortHighScoreList("points",[("Johan",3,4),("Max",1,2),("Jonas",7,8),("Erik",5,6),("Adam",9,10)]) = [("Adam",9,10),("Jonas",7,8),("Erik",5,6),("Johan",3,4),("Max",1,2)],"sortHighScoreList");

(*addPoints(points)*)
(S.addPoints(1) = 2,"addPoints");
(*removePoint(points)*)
(S.removePoint(2) = 1,"removePoint");
(*getTime()*)
(S.getTime() = Time.now(),"getTime()");
(*getTimeDiff(xTime,yTime)*)
(S.getTimeDiff(S.getTime(),S.getTime()) = 0,"getTimeDiff");


