

(*fun sub(field(plan),x,y) *)
val vectest = S.createNewField(4,4);
(S.sub(vectest,0,0) = S.EXISTS,"S.sub(vectest,0,0)",S.sub(vectest,0,0));
(S.sub(vectest,1,1) = S.EXISTS,"S.sub(vectest,1,1)",S.sub(vectest,1,1));
(S.sub(vectest,2,2) = S.VOID,"S.sub(vectest,0,1) ",S.sub(vectest,0,1));


(*updateVector(vec,x,y,value)*)
val myfield = S.createNewField(4,4);
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
val myfield4x4 = S.createNewField(4,4);
(S.fieldLength(myfield4x4) = (4,4),"S.fieldLength(myfield4x4)");
val myfield1x1 = S.createNewField(1,1);
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


(*S.CheckForPiece(cField,x,y,value)*)
(S.CheckForPiece(myfield4x4,0,0,S.VOID) = false, "S.CheckForPiece(myfield4x4,0,0,S.VOID)");
(S.CheckForPiece(myfield4x4,0,0,S.EXISTS) = true, "S.CheckForPiece(myfield4x4,0,0,S.VOID)");
(S.CheckForPiece(myfield4x4,0,~1,S.EXISTS) = false, "S.CheckForPiece(myfield4x4,0,~1,S.EXISTS)");
(S.CheckForPiece(myfield4x4,5,0,S.EXISTS) = false, "S.CheckForPiece(myfield4x4,5,0,S.EXISTS)");
(S.CheckForPiece(myfield4x4,4,4,S.OUT) = false, "S.CheckForPiece(myfield4x4,4,4,S.OUT)");
(S.CheckForPiece(myfield4x4,2,2,S.VOID) = true, "S.CheckForPiece(myfield4x4,2,2,S.VOID)");
val testCFP = S.updateVector(myfield4x4,2,0,S.OUT);
(S.CheckForPiece(testCFP,2,0,S.OUT) = true, "S.CheckForPiece(myfield4x4,2,0,S.OUT) ");


