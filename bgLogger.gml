/*
by		: BahamaGames / rickky
GMail	: bahamagames@gmail.com 
Discord	: rickky#1696
GitHub	: https://github.com/BahamaGames

Credits : Yal(YellowAfterLife). Beautifier was used from his example. https://yal.cc/gamemaker-beautifying-json/
*/

// Feather disable all

/// @context							bgLogger
/// @function							bgLogger(configStruct)
/// @description						A simple alternative to the default show_debug_message(). All methods can be chained together.
/// @param {Struct}		configStruct	- A struct containing configurations for indiviual log layers. 
function bgLogger(__bg_config	= {
		/*
		The following are levels to the built in logger top to bottom on severity. FATAL indicating a game crash worth message.
		
		TAG						{String}	The name to attach to the logger [Timestamp][TAG][LEVEL] Message.
		enabled					{Bool}		Shortcut to enable/disable showing any logs.
		tag_string_case			{Real}		0 = Unchanged, 1 = lower case, 2 = UPPER CASE.
		lvls_string_case		{Real}		0 = Unchanged, 1 = lower case, 2 = UPPER CASE.
		logs_string_case		{Real}		0 = Unchanged, 1 = lower case, 2 = UPPER CASE.
		maxdepth				{Real}		The maximum depth of the callstack that can be traced.
		show					{Bool}		Whether to show the log message within terminal.
		cache					{Bool}		Whether to store the log within a ds_list.
		*/
		"TAG"					: "BG",
		"enabled"				: true,
		"tag_string_case"		: 2,
		"lvls_string_case"		: 2,
		"logs_string_case"		: 0,
								
		"FATAL"					: {
			"maxdepth"			: 4,
			"cache"				: true
		},						
		"ERROR"					: {
			"maxdepth"			: 4,
			"cache"				: true
		},						
		"WARN"					: {
			"maxdepth"			: 20,
			"show"				: true,
			"cache"				: true
		},						
		"TRACE"					: {
			"show"				: true,
			"cache"				: true
		},						
		"DEBUG"					: {
			"maxdepth"			: 4,
			"show"				: true,
			"cache"				: true
		},						
		"INFO"					: {
			"show"				: true,
			"cache"				: true
		}
	}) constructor{
	
	/*
	All accessiable variables, and methods are abbrivated with bg
	to avoid conflicts with other projects.
	
	All variables are to be used for READONLY purposes if wishs to write
	simply make a copy, and use that.
	*/
	
	_bg_logger_config			= __bg_config;
	bg_tag						= _bg_logger_config[$ "TAG"];
	_bg_og_tag					= bg_tag;
	_bg_logger_logs				= [];
	bg_json_beautify_fb			= buffer_create(1024, buffer_fast, 1);
	bg_json_beautify_rb			= buffer_create(1024, buffer_grow, 1);
	bg_enabled					= _bg_logger_config[$ "enabled"];
	bg_file_writer				= undefined;
	_bg_tag_string_case			= _bg_logger_config[$ "tag_string_case"];
	_bg_lvls_string_case		= _bg_logger_config[$ "lvls_string_case"];
	_bg_logs_string_case		= _bg_logger_config[$ "logs_string_case"];
	_bg_draw_text_x				= 0;
	_bg_draw_text_y				= 0;
	_bg_draw_text_padding		= 2;
	_bg_draw_previous_instance	= noone;
	
	/// @context						self
	/// @function						bgLog(level, message)
	/// @description					The barebone to all log features. 
	/// @param {String}			level	- What level to log message as.
	/// @param {String}			msg		- Message to log.
	/// @return {Struct}
	static bgLog				= function(__bg_level, __bg_message)
	{
		if(!bg_enabled) return self;
		
		var 
		__bg_timestamp		= "["+date_time_string(date_current_datetime())+"]",
		__bg_level_struct	= _bg_logger_config[$ __bg_level],
		__bg_cache			= __bg_level_struct[$ "cache"];;
		
		if(__bg_level_struct == undefined)
		{
			__bg_message = "Log level "+__bg_level+" doesnt exists!!!";
			__bg_level	 = "FATAL";
		}
		
		if(__bg_level != "FATAL" && __bg_level != "ERROR")
		{
			var 
			__bg_log,
			__bg_show  = __bg_level_struct[$ "show"];
			
			if(__bg_show || __bg_cache)
			{
				var __bg_callstack = __bg_level_struct[$ "maxdepth"];
		
				if(__bg_callstack) 
				{
					__bg_callstack = debug_get_callstack(__bg_callstack);
					__bg_message += " [LOCATION]:";
					
					for(var i = array_length(__bg_callstack) - 2; i >= 0; --i) __bg_message += "\n"+__bg_callstack[i];
				}
		
				switch(_bg_tag_string_case)
				{
					case 0: bg_tag = _bg_og_tag; break;
					case 1: bg_tag = string_lower(bg_tag); break;
					case 2: bg_tag = string_upper(bg_tag); break;
				}
			
				switch(_bg_lvls_string_case)
				{
					case 1: __bg_level = string_lower(__bg_level); break;
					case 2: __bg_level = string_upper(__bg_level); break;
				}
			
				switch(_bg_logs_string_case)
				{
					case 1: __bg_message = string_lower(__bg_message); break;
					case 2: __bg_message = string_upper(__bg_message); break;
				}
				
				__bg_log = __bg_timestamp+" ["+bg_tag+"] ["+__bg_level+"] "+__bg_message;
				
				if(__bg_show) show_debug_message(__bg_log);
				
				if(bg_file_writer != undefined) 
				{
					file_text_write_string(bg_file_writer, bgBeautify(json_stringify(__bg_log), false));
					file_text_writeln(bg_file_writer);
				}
				
				if(__bg_cache) array_push(_bg_logger_logs, __bg_log);
			}
		}else 
		{
			var __bg_callstack = __bg_level_struct[$ "maxdepth"];
		
			if(__bg_callstack) 
			{
				__bg_callstack = debug_get_callstack(__bg_callstack);
				__bg_message += " [LOCATION]:";
				for(var i = array_length(__bg_callstack) - 2; i >= 0; --i) __bg_message += "\n"+__bg_callstack[i];
			}
			
			if(__bg_cache) array_push(_bg_logger_logs, __bg_message);
			
			if(bg_file_writer != undefined) 
			{
				file_text_write_string(bg_file_writer, bgBeautify(json_stringify(__bg_message), false));
				file_text_writeln(bg_file_writer);
			}
			
			show_error(__bg_message, __bg_level == "FATAL");
		}
		
		return self;
	}
	
	/// @context						self
	/// @function						bgInfo(msg, ...)
	/// @description					Logs a message as info.
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgInfo				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);	
		bgLog("INFO", r);
		return self;
	}
	
	/// @context						self
	/// @function						bgDebug(msg, ...)
	/// @description					Logs a debug
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgDebug				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);
		bgLog("DEBUG", r);
		return self;
	}
		
	/// @context						self
	/// @function						bgTrace(msg, ...)
	/// @description					Logs a message as trace.
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgTrace				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);	
		bgLog("TRACE", r);
		return self;
	}
	
	/// @context						self
	/// @function						bgWarn(msg, ...)
	/// @description					Logs a message as a warning
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgWarn				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);	
		bgLog("WARN", r);
		return self;
	}
		
	/// @context						self
	/// @function						bgError(msg, ...)
	/// @description					Logs a message as an error 
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgError				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);	
		bgLog("ERROR", r);
		return self;
	}
		
	/// @context						self
	/// @function						bgFatal(msg, ...)
	/// @description					Logs a message as fatal. Will attempt to close app.
	/// @param {String}			msg		- Message to log.
	/// @param {String}			...		- additional messages
	/// @return {Struct}
	static bgFatal				= function()
	{
		var r = string(argument[0]);
		for(var i = 1; i < argument_count; i++) r += " " + string(argument[i]);
		bgLog("FATAL", r);
		return self;
	}
	
	/// @context						self
	/// @function						bgAssert(level, value, ...msg)
	/// @description					If the value is false, logs a message as provided level.
	/// @param {String}			level	-
	/// @param {Bool}			value	-
	/// @param {String}			...		- additional messages
	static bgAssert				= function(__bg_level, __bg_value)
	{
		if(__bg_value) return;
		var r = string(argument[2]);
		for(var i = 3; i < argument_count; i++) r += " " + string(argument[i]);
		bgLog(__bg_level, r);
	}
	
	/// @context						self
	/// @function						bgToFile(fname)
	/// @description					Writes cached logs to a file.
	/// @param {String}			fname	- File to write a json of cached logs to.
	/// @return {Struct}
	static bgToFile				= function(__bg_fname)
	{
		var __bg_file = file_text_open_write(__bg_fname);
		file_text_write_string(__bg_file, bgBeautify(json_stringify(_bg_logger_logs), false));
		file_text_close(__bg_file);
		bgLog("TRACE", "Saving to file", __bg_fname);
		return self;
	}
	
	/// @context						self
	/// @function						bgEnable(enable)
	/// @description					Toggle whether to enable logging of any kind.
	/// @param {Bool}			enable	- Enable logging?
	/// @return {Struct}
	static bgEnable				= function(__bg_enable = !bg_enabled)
	{
		bg_enabled = __bg_enable;
		return self;
	}
	
	/// @context						self
	/// @function						bgBeautify(string, print)
	/// @description					Beautifies a json, or array string.
	///									and returns logger interface for chaining, else returns the string beautified string.
	/// @param {String}			json	- Json/Array string to print.
	/// @param {Bool}			print	- Print results to terminal.
	/// @return {Any}
	static bgBeautify			= function(__bg_string, __bg_print = false)
	{
		//Ensure its a string
		__bg_string = string(__bg_string);
		
		var __bg_rb = bg_json_beautify_rb;
		buffer_seek(__bg_rb, buffer_seek_start, 0);
		buffer_write(__bg_rb, buffer_string, __bg_string);
		var 
		__bg_size	= buffer_tell(__bg_rb) - 1,
		__bg_fb		= bg_json_beautify_fb;
		if (buffer_get_size(__bg_fb) < __bg_size) buffer_resize(__bg_fb, __bg_size);
		buffer_copy(__bg_rb, 0, __bg_size, __bg_fb, 0);
		buffer_seek(__bg_rb, buffer_seek_start, 0);
		var 
		__bg_start	= 0, // __bg_start offset in input buffer
		__bg_pos	= 0, // reading position in input buffer
		__bg_next	= 0;
		while (__bg_pos < __bg_size) 
		{
		    var c = buffer_peek(__bg_fb, __bg_pos++, buffer_u8);
		    switch (c) 
			{
		        case 9: case 10: case 13: case 32: // `\t\n\r `
		            _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos - 1);
		            // skip over trailing whitespace:
		            while (__bg_pos < __bg_size) 
					{
		                switch (buffer_peek(__bg_fb, __bg_pos, buffer_u8)) 
						{
		                    case 9: case 10: case 13: case 32: __bg_pos += 1; continue;
		                    // default -> break
		                } break;
		            }
		            __bg_start = __bg_pos;
		            break;
		        case 34: // `"`
		            while (__bg_pos < __bg_size) 
					{
		                switch (buffer_peek(__bg_fb, __bg_pos++, buffer_u8)) 
						{
		                    case 92: __bg_pos++; continue; // `\"`
		                    case 34: break; // `"` -> break
		                    default: continue; // else
		                } break;
		            }
		            break;
		        case ord("["): case ord("{"):
		            _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos);
		            // skip over trailing whitespace:
		            while (__bg_pos < __bg_size) 
					{
		                switch (buffer_peek(__bg_fb, __bg_pos, buffer_u8)) 
						{
		                    case 9: case 10: case 13: case 32: __bg_pos += 1; continue;
		                    // default -> break
		                } break;
		            }
		            // indent or contract `[]`/`{}`
		            c = buffer_peek(__bg_fb, __bg_pos, buffer_u8);
		            switch (c) 
					{
		                case ord("]"): case ord("}"): // `[]` or `{}`
		                    buffer_write(__bg_rb, buffer_u8, c);
		                    __bg_pos += 1;
		                    break;
		                default: // `[\r\n\t
		                    buffer_write(__bg_rb, buffer_u16, 2573); // `\r\n`
		                    repeat (++__bg_next) buffer_write(__bg_rb, buffer_u8, 9); // `\t`
		            }
		            __bg_start = __bg_pos;
		            break;
		        case ord("]"): case ord("}"):
		            _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos - 1);
		            buffer_write(__bg_rb, buffer_u16, 2573); // `\r\n`
		            repeat (--__bg_next) buffer_write(__bg_rb, buffer_u8, 9); // `\t`
		            buffer_write(__bg_rb, buffer_u8, c);
		            __bg_start = __bg_pos;
		            break;
		        case ord(","):
		            _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos);
		            buffer_write(__bg_rb, buffer_u16, 2573); // `\r\n`
		            repeat (__bg_next) buffer_write(__bg_rb, buffer_u8, 9); // `\t`
		            __bg_start = __bg_pos;
		            break;
		        case ord(":"):
		            if (buffer_peek(__bg_fb, __bg_pos, buffer_u8) != ord(" ")) 
					{
		                _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos);
		                buffer_write(__bg_rb, buffer_u8, ord(" "));
		                __bg_start = __bg_pos;
		            } else __bg_pos += 1;
		            break;
		        default:
		            if (c >= ord("0") && c <= ord("9"))
					{ // `0`..`9`
		                var 
						__bg_pre	= true, // whether reading __bg_pre-dot or not
		                __bg_till	= __bg_pos - 1; // index at which meaningful part of the number ends
		                while (__bg_pos < __bg_size) 
						{
		                    c = buffer_peek(__bg_fb, __bg_pos, buffer_u8);
		                    if (c == ord(".")) 
							{
		                        __bg_pre = false; // whether reading __bg_pre-dot or not
		                        __bg_pos += 1; // index at which meaningful part of the number ends
		                    } else if (c >= ord("0") && c <= ord("9")) 
							{
		                        // write all __bg_pre-dot, and __bg_till the last non-zero after dot:
		                        if (__bg_pre || c != ord("0")) __bg_till = __bg_pos;
		                        __bg_pos += 1;
		                    } else break;
		                }
		                if (__bg_till < __bg_pos) 
						{ // flush if number can be shortened
		                    _bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_till + 1);
		                    __bg_start = __bg_pos;
		                }
		            }
		    }
		}
		if (__bg_start == 0)
		{
			if(__bg_print)
			{
				bgInfo(__bg_string);
				return self;
			}
			return __bg_string; // source string was unchanged
		}
		_bgBufferWriteSlice(__bg_rb, __bg_fb, __bg_start, __bg_pos);
		buffer_write(__bg_rb, buffer_u8, 0); // terminating byte
		buffer_seek(__bg_rb, buffer_seek_start, 0);
		var __bg_res = buffer_read(__bg_rb, buffer_string);
		if(__bg_print)
		{
			bgInfo(__bg_res);
			return self;
		}
		return __bg_res;
	}
	
	/// @context						self
	/// @function						bgGetLogs()
	/// @description					Returns the internal ds_list of logs. READONLY!!!
	/// @return {Array<String>}
	static bgGetLogs			= function()
	{
		return _bg_logger_logs;
	}
	
	/// @context						self
	/// @function						bgDrawText(string, x, y, padding)
	/// @description					Draws texts vertically, incrementing the y pos with padding.
	/// @param {Array<String>}	string	- Array of strings to draw.
	/// @param {Real}			x		- X position 
	/// @param {Real}			y		- Y position 
	/// @param {Real}			padding	- Padding to add to y position. 
	/// @return {Struct}
	static bgDrawText			= function(t, x = _bg_draw_text_x, y = _bg_draw_text_y, p = string_height("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + _bg_draw_text_padding)
	{
		if(!is_array(t)) t = [t];
		
		var r = string(t[0]);
		for(var i = 1; i < array_length(t); ++i) r += " " + string(t[i]);
		
		draw_text(x, y, r);
		
		_bg_draw_text_x = x;
		_bg_draw_text_y = y;
		_bg_draw_text_y += p;
		
		return self;
	}
	
	/// @context						self
	/// @funtion						bgLoggerCleanup()
	/// @description					Cleans up the logger deleting its buffer's and data structures.
	/// @return {Bool}
	static bgLoggerCleanup		= function()
	{
		buffer_delete(bg_json_beautify_fb);
		buffer_delete(bg_json_beautify_rb);
		_bg_logger_logs = -1;
		delete _bg_logger_config;
		return true;
		//show_debug_message("["+string(date_get_month(date_current_datetime()))+"/"+string(date_get_day(date_current_datetime()))+" "+string(date_get_hour(date_current_datetime()))+":"+string(date_get_minute(date_current_datetime()))+":"+string(date_get_second(date_current_datetime()))+"] ["+bg_tag+"] [TRACE] logger cleaned up");
	}
	
	static _bgBufferWriteSlice	= function(__bg_buffer, __bg_data, __bg_start, __bg_end)
	{
		var __bg_next = __bg_end - __bg_start;
		if (__bg_next <= 0) exit;
		var 
		__bg_size	= buffer_get_size(__bg_buffer),
		__bg_pos	= buffer_tell(__bg_buffer),
		__bg_need	= __bg_pos + __bg_next;
		if (__bg_size < __bg_need) {
		    do __bg_size *= 2 until (__bg_size >= __bg_need);
		    buffer_resize(__bg_buffer, __bg_size);
		}
		buffer_copy(__bg_data, __bg_start, __bg_next, __bg_buffer, __bg_pos);
		buffer_seek(__bg_buffer, buffer_seek_relative, __bg_next);
	}
}
