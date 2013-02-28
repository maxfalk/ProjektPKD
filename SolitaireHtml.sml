
open Mosmlcgi;
exception HTML of string;


fun makePage(script,table) =
	"Content-type: text/html\n\n" ^
	"<HTML>\n" ^
	"<BODY>\n" ^
	script ^ table ^
	"</BODY>\n"^
	"</HTML>\n"
	;

fun printPage(script,table) = print(makePage(script,table));	

fun makeForm(url, text) =
    "<FORM method = \"post\" action = \"" ^ url ^ "\">\n" ^
    text ^
    "</FORM>\n";
	
fun makeScript(code) = 
	"<SCRIPT>" ^ code ^ "</SCRIPT>"
	;

fun makeTable(border,style,tableInput) =
	"<TABLE border=\"" ^ border ^ "\" style= \"" ^ style ^ ";\" >\n" ^ tableInput ^	"</TABLE>\n"
	;
	
fun makeCell(x) =
	"<td>"^x^"</td>\n"
	;
	
fun makeRaw(rawContent) =	
	"<tr>\n" ^ makeCell(rawContent) ^ "</tr>\n"
	;
	
	
(* Tänk på att i alla fall förutom basfallet måste alla argumentens(Function,argument,id)
   vänsterparenteser skrivas med. 
   Högerparenteserna skrivs ut av funktionen.*)	
fun makeOnClick("","","") = ""
	|makeOnClick(Function,"","") = "onclick=\"" ^ Function ^ "\""
	|makeOnClick("",argument,"") = ""
	|makeOnClick("","",id) = ""
	|makeOnClick(Function,argument,"") = "onclick=\"" ^ Function ^ argument ^ "))\""
	|makeOnClick(Function,argument,id) = "onclick=\"" ^ Function ^ argument ^ "'" ^ id ^ "'" ^ "))\""
	;
	
fun makeImage(id,src,(Function,argument)) = 
	"<img id=\"" ^ id ^ "\"" ^ makeOnClick(Function,argument,id) ^ "src=\"" ^ src ^ "\" width=\"90\" height=\"90\" >\n"
	; 
	
fun makeButton(scriptFunName,buttonText) = 
	"<button type=\"button\"" ^ makeOnClick(scriptFunName,"","") ^ ">" ^ buttonText ^ "</button>"
	;


