var coordx = "";
var coordy = "";
var help = "false";
function saveID(x,y)
{
	coordx = x;
	coordy = y;
}
function validMove(x1,y1,x2,y2)
{
	var xdiff = x1 -x2;
	var ydiff = y1 -y2;
	var form = document.getElementById("input2");
	if (xdiff == 0)
	{
		if (ydiff == 2)
		{
			form.value = x1 + "," + y1 + "," + "SOUTH;";
			document.forms["myform"].submit();
		}
		else if (ydiff == -2)
		{
			form.value = x1 + "," + y1 + "," + "NORTH;";
			document.forms["myform"].submit();
		}
	}
	else if  (ydiff == 0)
	{
		if (xdiff == 2) 
		{
			form.value = x1 + "," + y1 + "," + "WEST;";
			document.forms["myform"].submit();
		}
		else if (xdiff == -2)
		{
			form.value = x1 + "," + y1 + "," + "EAST;";
			document.forms["myform"].submit();
		}
	} 
}
function ChooseBall(x)
{
	var temp = (x.id).split(".");
	if (x.src == "http://user.it.uu.se/~mani9271/Ball.png" && coordx == "" && coordy == "")
	{
		saveID(temp[0],temp[1]);
		x.src="http://user.it.uu.se/~mani9271/ChosenBall.png";		
		oldball = x;
	}
	else if (x.src == "http://user.it.uu.se/~mani9271/Ball.png" && coordx != "" && coordy != "")
	{
		saveID(temp[0],temp[1]);
		oldball.src="http://user.it.uu.se/~mani9271/Ball.png";
		oldball = x;
		x.src="http://user.it.uu.se/~mani9271/ChosenBall.png";

	}
	else if (x.src == "http://user.it.uu.se/~mani9271/ChosenBall.png")
	{
		saveID("","");
		x.src="http://user.it.uu.se/~mani9271/Ball.png";
	}
	else if (x.src == "http://user.it.uu.se/~mani9271/EmptySpot.png" && coordx != "" && coordy != "")
	{
		var temp1 = (x.id).split(".");
		validMove(coordx,coordy,temp1[0],temp1[1]);
	}
	//document.getElementById("t").innerHTML=x.src+" : "+coordx+" : "+coordy;
}
function reset()
{
	window.location = "http://user.it.uu.se/cgi-bin/cgiwrap/mani9271/test.cgi";
}
function movehelp()
{
		var form = document.getElementById("input4");
		form.value = "true";
		document.forms["myform"].submit();
}
function win()
{
	var form = document.getElementById("input3");
	if (form.value == "true")
	{

		document.getElementById("t").innerHTML="You Win!!";	
	}	
		
}
function undo()
{

	var form = document.getElementById("input5");
	var formValue = form.value;
	if (formValue != "")
	{
		var temp = formValue.split(",");
		var x1 = temp[0];
		var y1 = temp[1];
		var direct = temp[2]; 
		var x2 = "";
		var y2 = "";
		var stringlength = (x1+y1+direct+",,,").length;	
	
		switch(direct)
		{
			case "SOUTH":
			x2 = x1;y2 = parseInt(y1)-2;
			break;
			case "NORTH":
			x2 =  x1;y2=2+parseInt(y1);
			break;
			case "WEST":
			x2 = parseInt(x1)-2;y2 = y1;
			break;
			case "EAST":
			x2 = parseInt(x1)+2;y2 = y1;
			break;
		}

		
		
		form.value = formValue.substring(stringlength);
		//document.getElementById("t").innerHTML=x1+", "+y1 +", "+direct+", "+ x2+", "+y2;
		document.getElementById("input6").value = "true";
		validMove(x1,y1,x2,y2);

		//document.getElementById("t").innerHTML=stringlength;

	}
					
}
function boardStyle()
{
	var element = document.getElementById("mySelect");
	var sValue = element.options[element.selectedIndex].value;
	document.getElementById("input7").value = sValue;
	document.forms["myform"].submit();
}