/*
by		: BAHAMAGAMES / rickky
GMail	: bahamagames@gmail.com 
Discord	: rickky#1696
GitHub	: https://github.com/BahamaGames

Credits : https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/Error
*/

// Feather disable GM2017
// Feather disable GM1019
// Feather disable GM1041
// Feather disable GM1042
// Feather disable GM1043
// Feather disable GM2043

/*
new Error()
new Error(message)
new Error(message, options)
new Error(message, script)
new Error(message, script, lineNumber)
*/

/// @function Error()
/// @param {string} message		A human-readable description of the error.
/// @param {struct}	options		An object that has the following properties: longMessage Optional A string value indicating to exact cause of the message, may also contain the brift message passed.
/// @param {string} script		The script/event that raised this error, reflected in the script property. Defaults to the name of the script/event containing the code that called the Error() constructor.
/// @param {real}	lineNumber	The line number within the script/event on which the error was raised, reflected in the lineNumber property. Defaults to the line number containing the Error() constructor invocation.
function Error(a = undefined, b = undefined, c = undefined) constructor
{	
	static name			= "Error";
	
	//init the global var options if doesnt exists already
	if(!variable_global_exists("__error_opts")) global.__error_opts = 
	{
		longMessage		: {default_: undefined, isValid: is_string, message: "longMessage should be a string"},
	}
	
	message				= a ?? name;
	script				= undefined;
	stacktrace			= debug_get_callstack();
	lineNumber			= undefined;
	
	if(b != undefined)
	{
		var ___type		= typeof(b);
		
		//check if options
		if(___type == "struct") 
		{
			if(typeof(b) != "struct") 
			{
				var e			= new Error($"Expected options to be a struct");
				e.name			= "TypeError";
				throw e;
			}
			
			var ___names		= struct_get_names(global.__error_opts);
	
			for(var i = array_length(___names) - 1; i >= 0; --i)
			{
				var ___key		= ___names[i];
		
				//temp fix for html injecting _Struct key into structs
				if(string_count("_struct_", ___key)) continue;
		
				var
				___value		= b[$ ___key],
				___validator	= global.__error_opts[$ ___key];
		
				if(___value == undefined) 
				{
					var d		= ___validator.default_;
					___value	= !is_callable(d)? d: d();
				}
		
				if(!___validator.isValid(___value)) 
				{
					var e		= new Error(___validator.message);
					e.name		= "TypeError";
					throw e;
				}
				
				self[$ ___key]	= ___value;
			}
		}
		else if(___type == "string") script = b;
		else {
			var e		= new Error("Invalid 'argument[1]' should be options: struct, or script: string");
			e.name		= "TypeError";
			throw e;
		}
		
		if(c != undefined) 
		{
			___type		= typeof(c);
			
			if(___type == "number") lineNumber = c;
			else {
				var e		= Error("Invalid 'argument[2] lineNumber' should a number");
				e.name		= "TypeError";
				throw e;
			}
		}
	}
	
	//Ether option hasnt been set we'll auto set
	if(script == undefined || lineNumber == undefined)
	{
		var 
		___stack				= stacktrace,
		___script				= ___stack[array_length(___stack) - 2],
		___line_pos				= string_pos(":", ___script);
		
		if(___line_pos) 
		{
			var ___function		= string_copy(___script, 1, ___line_pos - 1);
		
			if(string_pos("gml_Script_", ___function) == 1) ___function = string_delete(___function, 1, 11);
			else if(string_pos("gml_GlobalScript_", ___function) == 1) ___function = string_delete(___function, 1, 17);
			else if(string_pos("gml_Object_", ___function) == 1) 
			{
				___function		= string_delete(___function, 1, 11);
				// find second-last _ in object name
				var 
				___f1			= 1,
				___f2			= 1,
				___underscore	= 1,
				___max_iter		= 100;
						
				do {
					___f1		= ___f2;
					___f2		= ___underscore;
					var ___find	= string_pos("_", string_copy(___function, ___underscore, string_length(___function)-___underscore+1));
					___underscore += ___find;
				} until (___find == 0 || ___max_iter-- <= 0)
				
				___function		= string_copy(___function, 1, ___f1-2);
			}
				
			script				??= ___function;
			lineNumber			??= real(string_copy(___script, ___line_pos + 1, string_length(___script)));
		}
	}
	
	/// @function toString()
	static toString		= function(){return $"{name}: {message}";}
}