
datatype Fieldstate = EXSISTS | VOID | OUT 
datatype Field = field of Fieldstate list list 
datatype Direction = WEST | EAST | SOUTH | NORTH


(*-------------------------------------------------------------------------------------------------------------*)
fun createList(0,_,_,_,_) = []
	| createList(Amount,value,midValue,atMid,mid) = (if atMid andalso mid = (Amount-1) then midValue else value)::createList(Amount-1,value,midValue,atMid,mid)
(*-------------------------------------------------------------------------------------------------------------*)
fun updateList([],_,_) = []
	| updateList(xList as first::rest,at,value) = (if length(xList)-1 = at then value else first)::updateList(rest,at,value) 	
(*-------------------------------------------------------------------------------------------------------------*)	
fun createNewField(xLENGTH,_,0) = []
	| createNewField(xLENGTH,yLENGTH,yCURRENT) = 
	let
		val atMid = ((yLENGTH div 2)+1 = yCURRENT)
	in
		createList(xLENGTH,EXSISTS,VOID,atMid,(xLENGTH div 2))::createNewField(xLENGTH,yLENGTH,yCURRENT-1)
		
	end
(*-------------------------------------------------------------------------------------------------------------*)
fun checkList()
(*-------------------------------------------------------------------------------------------------------------*)
fun move(plan,x,y,direc) =
	let
	
	
	in
		movedirection(plan,x,y,direc)
	end

(*-------------------------------------------------------------------------------------------------------------*)
fun movedirection(field([]),_,_,_) = []
	| movedirection(cField as field(plan),x,y,WEST) =
		(if y = length(plan) then
			updateList(updateList(hd(plan),x,VOID),x-2,EXSISTS)
		else
			hd(plan))::movedirection(field(tl(plan)),x,y,WEST)
	| movedirection(cField as field(plan),x,y,EAST) =
			(if y = length(plan)then	
				updateList(updateList(hd(plan),x,VOID),x+2,EXSISTS)
			else
				hd(plan))::movedirection(field(tl(plan)),x,y,EAST)
	| movedirection(cField,x,y,SOUTH) =
			(if y+2 = length(plan) then	
				updateList(updateList(hd(plan),x,VOID),x,EXSISTS)
			else
				hd(plan))::movedirection'(field(tl(plan)),x,y-1)
	| movedirection(cField,x,y,NORTH) =
			(if y-2 = length(plan) then	
				updateList(updateList(hd(plan),x,VOID),x,EXSISTS)
			else
				hd(plan))::movedirection'(field(tl(plan)),x,y-1)
			
		
				
				
				