/*
by		: BAHAMAGAMES / rickky
GMail	: bahamagames@gmail.com 
Discord	: rickky#1696
GitHub	: https://github.com/BahamaGames
*/

// feather ignore all

#macro os_version_name	(os_type == os_windows || os_type == os_uwp || os_win8native?\
							(os_version == 327680? "2000" :\
								(os_version == 327681 || os_version == 237862? "XP" :\
									(os_version == 393216? "Vista" :\
										(os_version == 393217? "7" :\
											(os_version == 393218? "8" :\
												(os_version == 393219? "8.1":\
													(os_version == 655360? "10": "Unknown")\
												)\
											)\
										)\
									)\
								)\
							)\
						:\
						(os_type == os_macosx || os_type == os_ios? $"{os_version >> 24}.{(os_version >> 12) & 0xfff}":\
							(os_type == os_android?\
								(os_version == 21 ||os_version == 22? "Lollipop":\
									(os_version == 23? "Marshmallow" :\
										(os_version == 24? "Nouget" :\
											(os_version == 25? "Oreo" :\
												(os_version == 26? "Pie": "Unknown")\
											)\
										)\
									)\
								):\
							"Unknown")\
						))
						
#macro os_device_name	(os_type == os_windows || os_type == os_uwp || os_win8native? "Windows": \
						(os_type == os_gxgames? "GX.games":\
						(os_type == os_linux? "Linux":\
						(os_type == os_macosx? "Mac OS X":\
						(os_type == os_tvos? "Apple tvOS":\
						(os_type == os_android? "Android":\
						(os_type == os_switch? "Nintendo Sitch":\
						(os_type == os_xboxone || os_type == os_xboxseriesxs? "Microsoft XBox":\
						(os_type == os_ps3 || os_type == os_ps4 || os_type == os_ps5? "Sony PlayStation":\
						(os_type == os_ios?\
						(\
							os_device == device_ios_ipad || os_device == device_ios_ipad_retina? "iPad":\
							(\
							os_device == device_ios_iphone || os_device == device_ios_iphone_retina ||\
							os_device == device_ios_iphone6 || os_device == device_ios_iphone6plus ||\
							os_device == device_ios_iphone5? "iPhone": "iOS"\
							)\
						): "Unknown")\
						)))))))))

#macro os_browser_name	(os_browser == browser_not_a_browser? undefined:\
						(os_browser == browser_ie? "Internet Explorer":\
						(os_browser == browser_ie_mobile? "Internet Explorer Mobile":\
						(os_browser == browser_firefox? "Firefox":\
						(os_browser == browser_chrome? "Chsome":\
						(os_browser == browser_safari? "Safari":\
						(os_browser == browser_safari_mobile? "Safari Mobile":\
						(os_browser == browser_opera? "Opera":\
						(os_browser == browser_tizen? "Tizen":\
						(os_browser == browser_windows_store? "Windows App":\
						(os_browser == browser_unknown? "Unknown Browser": "Unknown Browser"\
						)))))))))))

#macro os_name os_browser == browser_not_a_browser? (os_type != os_linux? $"{os_device_name} {os_version_name}": "Linux"): os_browser_name

function datetime_string(____timestamp = date_current_datetime())
{
	return	string_replace_all(
			string_format(date_get_year(	____timestamp), 4, 0)	+ "-" +
			string_format(date_get_month(	____timestamp), 2, 0)	+ "-" +
			string_format(date_get_day(		____timestamp), 2, 0)	+ "T" +
			string_format(date_get_hour(	____timestamp), 2, 0)	+ ":" +
			string_format(date_get_minute(	____timestamp), 2, 0)	+ ":" +
			string_format(date_get_second(	____timestamp), 2, 0)
			, " ", "0");
}
	
function unix_timestamp(____time = date_current_datetime()){return floor((____time - 25569) * 86400);}