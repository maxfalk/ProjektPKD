
datatype Fieldstate = EXSISTS | VOID | OUT 
datatype Field = field of Fieldstate list list 
datatype Direction = WEST | EAST | SOUTH | NORTH

fun createNewField(xLENGTH,_,0) = []
	| createNewField(xLENGTH,yLENGTH,yCURRENT) = 
	let
	
		fun createList(0,_,_,_,_) = []
			| createList(Amount,value,midValue,atMid,mid) = (if atMid andalso mid = (Amount-1) then midValue else value)::createList(Amount-1,value,midValue,atMid,mid)
	
		val atMid = ((yLENGTH div 2)+1 = yCURRENT)
	in
	
		createList(xLENGTH,EXSISTS,VOID,atMid,(xLENGTH div 2))::createNewField(xLENGTH,yLENGTH,yCURRENT-1)
		
	end
		

(*-------------------------------*)
fun move(Move,WEST) =
	let
	
	in
	
	end;
	| move(Move,EAST) =
	| move(Move,SOUTH) =
	move(Move,NORTH) =