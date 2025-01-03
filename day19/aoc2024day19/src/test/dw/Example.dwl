%dw 2.0
output application/json
import dw::core::Strings

// this is a lambda type
type StringTransformer = (String) -> String

fun processString(anInput: String, formatter: StringTransformer): String = 
	formatter(anInput)
	
fun processInput(anInput: Any, formatter: StringTransformer) = log("procesing", anInput) match {
	case "SFO" -> processInput("San Fransisco International Airport", formatter) // recursion
	case is String -> processString(anInput, formatter)
	case is Array -> anInput map (s) -> processString(s, formatter)
	else -> anInput
}
	
fun oldProcessInput(anInput: Any, formatter: StringTransformer) =
	if (anInput is String) processString(anInput, formatter)
	else if (anInput is Array) anInput map (s) -> processString(s, formatter)
	else anInput
	
var message = "Code is like humor"
var multiline = 'Always remember
in coding as in life:
simpler is better than complex,
but complex is better than broken.' splitBy "\n"

---
{
	// upper is in dw::Core
	uppercase: upper("Trailhead Academy"),
	// lower is also in dw::Core
	lowercase: lower("Max the Mule"),
	// dasherize is in dw::core::Strings
	kebobCase: processString(message, Strings::dasherize),
	useFunction: processString("If you have to explain it, it's bad", Strings::underscore),
	multiline: processInput(multiline, Strings::dasherize),
	specialCase: processInput("SFO", upper)
}