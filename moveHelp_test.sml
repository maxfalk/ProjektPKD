(* FOR TESTING *)

fun brT (b,SOME(x,y,dir)) = (b,x,y,dir)
  | brT (b,NONE) = (b,0,0,S.NORTH);

val b1 = S.createNewField(4,4);

val b1 = S.field(vector.fromList([Vector.fromList[S.OUT,   S.OUT,   S.EXISTS,S.EXISTS,S.EXISTS,S.OUT,      S.OUT],
                                  Vector.fromList[S.OUT,   S.OUT,   S.EXISTS,S.EXISTS,S.EXISTS,S.OUT,      S.OUT],
                                  Vector.fromList[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
                                  Vector.fromList[S.EXISTS,S.EXISTS,S.EXISTS,S.VOID,  S.EXISTS,S.EXISTS,S.EXISTS],
                                  Vector.fromList[S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS,S.EXISTS],
                                  Vector.fromList[S.OUT,   S.OUT,   S.EXISTS,S.EXISTS,S.EXISTS,S.OUT,      S.OUT],
                                  Vector.fromList[S.OUT,   S.OUT,   S.EXISTS,S.EXISTS,S.EXISTS,S.OUT,      S.OUT]]));

val b1 = S.field(vector.fromList([Vector.fromList[S.OUT,   S.OUT,   S.VOID  ,S.EXISTS,S.EXISTS,S.OUT,      S.OUT],
                                  Vector.fromList[S.OUT,   S.OUT,   S.EXISTS,S.EXISTS,S.VOID  ,S.OUT,      S.OUT],
                                  Vector.fromList[S.VOID  ,S.EXISTS,S.VOID  ,S.EXISTS,S.VOID  ,S.EXISTS,S.EXISTS],
                                  Vector.fromList[S.VOID  ,S.VOID  ,S.VOID  ,S.EXISTS,S.VOID  ,S.EXISTS,S.EXISTS],
                                  Vector.fromList[S.VOID  ,S.VOID  ,S.EXISTS,S.EXISTS,S.VOID  ,S.VOID  ,S.EXISTS],
                                  Vector.fromList[S.OUT,   S.OUT,   S.VOID  ,S.VOID  ,S.VOID  ,S.OUT,      S.OUT],
                                  Vector.fromList[S.OUT,   S.OUT,   S.VOID  ,S.VOID  ,S.VOID  ,S.OUT,      S.OUT]]));

val b2 = S.move(brT(b1,bestMove(b1)));
val b3 = S.move(brT(b2,bestMove(b2)));
val b4 = S.move(brT(b3,bestMove(b3)));
val b5 = S.move(brT(b4,bestMove(b4)));
val b6 = S.move(brT(b5,bestMove(b5)));
val b7 = S.move(brT(b6,bestMove(b6)));
val b8 = S.move(brT(b7,bestMove(b7)));
val b9 = S.move(brT(b8,bestMove(b8)));
val b10 = S.move(brT(b9,bestMove(b9)));
val b11 = S.move(brT(b10,bestMove(b10)));
val b12 = S.move(brT(b11,bestMove(b11)));
val b13 = S.move(brT(b12,bestMove(b12)));
val b14 = S.move(brT(b13,bestMove(b13)));
val b15 = S.move(brT(b14,bestMove(b14)));
val b16 = S.move(brT(b15,bestMove(b15)));
val b17 = S.move(brT(b16,bestMove(b16)));
