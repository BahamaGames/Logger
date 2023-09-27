/*
by		: BahamaGames / rickky
GMail	: bahamagames@gmail.com 
Discord	: rickky#1696
GitHub	: https://github.com/BahamaGames
*/

// feather ignore all

#macro LOGGER_DEFAULT_CATEGORY "GENERIC"

enum LOGGER_FLAGS
{
	MASK	= 0x111,
	SHOW	= 0x101,
	CACHE	= 0x110,
	ENABLED	= 0x100
}

enum LOGGER_LEVELS
{
	FATAL,
	ERROR,
	WARN,
	INFO,
	DEBUG
}

function Logger()						constructor
{
	static version						= "1.0.0";
	
	/// @context							self
	/// @function							log()
	/// @description			
	/// @param {String}				message	- Message to log
	/// @param {Struct}				options -
	/// @return {Struct}
	static log							= function(____message, ____options = undefined)
	{
		____options						= bg_validate_options(global.__logger_opts, ____options, "options", function(){}, true);
		
		var ___flags					= ____options.flags;
		
		if(___flags & LOGGER_FLAGS.ENABLED)
		{
			var ___catagory				= ____options.category;
					
			if(___flags & LOGGER_FLAGS.SHOW) show_debug_message($"[{____options.date}]{___catagory != undefined? $" [{___catagory}]": ""} {____message}");
			if(___flags & LOGGER_FLAGS.CACHE) addBreadCrumb(___catagory, ____options.level, ____message, ____options.data);
		}
		
		return self;
	}
	
	/// @context Logger					
	/// @function						addBreadCrumb()
	/// @description					Creates a breadcrumb
	/// @param {String}					category	The category of the breadcrumb, e.g. "ui.keypress.L"
	/// @param {Constant}				level		The level of the breadcrumb: SENTRY_ERROR, SENTRY_WARNING, SENTRY_INFO, SENTRY_DEBUG
	/// @param {String}					message		A message
	/// @param {Struct}					[data]		A struct containing additional data
	/// @return Logger					
	static addBreadCrumb				= function(____category, ____level, ____message, ____data = undefined)
	{
		var ___crumb = 
		{
			level		: is_real(____level)? global.__logger_level_array[____level]: ____level,
			message		: ____message,
			category	: ____category,
			timestamp	: unix_timestamp()
		}
	
		if(____data != undefined) ___crumb.data = ____data;
	
		ds_list_add(_logger_bread_crumbs, ___crumb);
	
		// trim breadcrumbs
		if(ds_list_size(_logger_bread_crumbs) > maxBreadCrumbs) 
		{
			delete _logger_bread_crumbs[| 0];
			ds_list_delete(_logger_bread_crumbs, 0);
		}
		
		return self;
	}
	
	/// @context Logger					
	/// @function						setMaxBreadCrumbs()
	/// @description					Creates a breadcrumb
	/// @param {real}					n	The amount to set maxBreadCrumbs to.
	/// @return Logger	
	static setMaxBreadCrumbs			= function(n)
	{
		if(!is_real(n)) throw TypeError("Breadcrumbs must be a number");
		
		maxBreadCrumbs = n;
		
		return self;	
	}
	
	/// @context Logger					
	/// @function						breadCrumbs()
	/// @description					Returns the breadcrumbs list.
	/// @return {Id.DSList}
	static breadCrumbs					= function()
	{
		return _logger_bread_crumbs;	
	}
	
	/// @context							self
	/// @function							assert(value, message, options)
	/// @description						If the value is false, logs a message as provided level.
	/// @param {Bool}				value	-
	/// @param {String}				message	- 
	/// @return {Struct}
	static assert						= function(____value, ____message = undefined, ____options = undefined)
	{
		if(!____value) 
		{
			if(____message != undefined) 
			{
				____options ??= {};
				____options[$ "level"] ??= "FATAL";
				//log(____message, ____options);
			}
			return false;
		}
		return true;
	}
	
	/// @function							drawText(string, x, y, padding)
	/// @description						Draws texts vertically, incrementing the y pos with padding.
	/// @param {Array<String>}		string	- Array of strings to draw.
	/// @param {Real}				x		- X position 
	/// @param {Real}				y		- Y position 
	/// @param {Real}				padding	- Padding to add to y position. 
	/// @return {Struct}
	static drawText						= function()
	{
		var t = argument[0];
		if(!is_array(t)) t = [t];
		
		var 
		xx= argument_count > 1? argument[1]: _logger_draw_text_x,
		yy= argument_count > 2? argument[2]: _logger_draw_text_y,
		r = string(t[0]),
		s = argument_count > 3? argument[3]: 0,
		p = argument_count > 4? argument[4]: string_height("A") + _logger_draw_text_padding;
			
		if(xx == undefined) xx = _logger_draw_text_x;
		if(yy == undefined) yy = _logger_draw_text_y;
			
		for(var i = 1; i < array_length(t); ++i) 
			r += $"{t[i]}";
		
		draw_text(xx, yy, r);
		
		_logger_draw_text_x = xx;
		_logger_draw_text_y = yy;
		_logger_draw_text_x += s ?? string_width(t);
		_logger_draw_text_y += p;
		
		return self;
	}
										
	static assertPoint					= function(____point = _logger_assert_point)
	{
		show_debug_message($"Assert point: {____point}");
		_logger_assert_point		= ____point + 1;
		return self;
	};
	
	/// @function						destroy()
	static destroy						= function()
	{
		ds_list_destroy(_logger_bread_crumbs);
		var s = self;
		delete s;
	}
					
	/// @function						cleanup()
	static cleanup						= function()
	{
		delete global.__logger_opts;
	}
	
	maxBreadCrumbs						= 100;
	_logger_bread_crumbs				= ds_list_create();
	_logger_draw_text_x					= 0;
	_logger_draw_text_y					= 0;
	_logger_draw_text_padding			= 2;
	_logger_draw_text_spacing			= 2;
	_logger_assert_point				= 0;
	
	if(!variable_global_exists("__logger_opts"))
	{
		global.__logger_opts			= 
		{
			date						: {default_: datetime_string(), isValid: is_string, message: "date should be converted to a string"},
			data						: {default_: undefined, isValid: function(v){return v == undefined || is_struct(v)}, message: "data should be a struct"},
			level						: {default_: LOGGER_LEVELS.INFO, isValid: function(v){return is_string(v) || v >= LOGGER_LEVELS.FATAL && v <= LOGGER_LEVELS.DEBUG}, message: "level should be a string or one of the enum constants 'LOGGER_LEVELS'"},
			flags						: {default_: LOGGER_FLAGS.SHOW | LOGGER_FLAGS.CACHE | LOGGER_FLAGS.ENABLED, isValid: function(v){return v >= 0 && v <= LOGGER_FLAGS.MASK}, message: $"Flags should be one of the enum constants 'LOGGER_FLAGS'"},
			category					: {default_: LOGGER_DEFAULT_CATEGORY, isValid: is_string, message: "category should be a string"},
			//maxBreadCrumbs				: {default_: 100, isValid: is_real, message: "maxBreadCrumbs should be a number"}
		}
		
		global.__logger_level_array		= ["fatal", "error", "warning", "info", "debug"];
	}
}