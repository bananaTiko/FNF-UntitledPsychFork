package backend.api;

#if windows
// some functions from here: https://github.com/FNF-CNE-Devs/CodenameEngine
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
	#include <iostream>
	#include <Windows.h>
	#include <dwmapi.h>
	#include <winuser.h>
')
class Windows {
	@:functionCode('return SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (void*)path.c_str(), SPIF_UPDATEINIFILE);')
	public static function changeWallpaper(path:String):Bool
		return false;

	/** 
	 * Allows drawing window frame in dark mode, works on Windows 10 build 17763 or greater.
	 * 
	 * Doesn't do anything if ColorPrevalence is 1 (google it)
	 * @return Is dark mode allowed?
	 */
	@:functionCode('
		DWORD val;
		DWORD valSize = sizeof(val);
		RegGetValue(HKEY_CURRENT_USER, "SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Themes\\\\Personalize\\\\", "AppsUseLightTheme", RRF_RT_DWORD, nullptr, &val, &valSize);
		int darkMode = val == 0 ? 1 : 0;

		if (S_OK != DwmSetWindowAttribute(GetActiveWindow(), 19, &darkMode, sizeof(darkMode)))
			DwmSetWindowAttribute(GetActiveWindow(), 20, &darkMode, sizeof(darkMode));

		return darkMode == 1;
	') public static function allowDarkMode():Bool return false;


	/**
	 * Removes minimize and maximize buttons of current window
	 * @see https://stackoverflow.com/a/46145911
	 */
	@:functionCode('
		HWND hwnd = GetActiveWindow();
		DWORD style = GetWindowLong(hwnd, GWL_STYLE);
		style &= ~WS_MINIMIZEBOX;
		style &= ~WS_MAXIMIZEBOX;
		SetWindowLong(hwnd, GWL_STYLE, style);
		SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOSIZE|SWP_NOMOVE|SWP_FRAMECHANGED);
	') public static function removeMaximizeMinimizeButtons() {}

	/**
	 * Adds minimize and maximize buttons to current window
	 * @see https://stackoverflow.com/a/46145911
	 */
	@:functionCode('
		HWND hwnd = GetActiveWindow();
		DWORD style = GetWindowLong(hwnd, GWL_STYLE);
		style |= WS_MINIMIZEBOX;
		style |= WS_MAXIMIZEBOX;
		SetWindowLong(hwnd, GWL_STYLE, style);
		SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOSIZE|SWP_NOMOVE|SWP_FRAMECHANGED);
	') public static function addMaximizeMinimizeButtons() {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setBorderColor(color:FlxColor)
		setBorderColorFromRGBFloat(color.redFloat, color.greenFloat, color.blueFloat);
	/** Changes window border color from RGB float, works on Windows 11 build 22000 or greater. */
	public static function setBorderColorFromRGBFloat(red:Float, green:Float, blue:Float) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', red * 255, green * 255, blue * 255);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr));
	') public static function resetBorderColor() {}
	/** Suppresses drawing window border, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xfffffffe;
		DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr));
	') public static function suppressBorderColor() {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setCaptionColor(color:FlxColor)
		setCaptionColorFromRGBFloat(color.redFloat, color.greenFloat, color.blueFloat);
	/** Changes window border color from RGB float, works on Windows 11 build 22000 or greater. */
	public static function setCaptionColorFromRGBFloat(red:Float, green:Float, blue:Float) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', red * 255, green * 255, blue * 255);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 35, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 35, &clr, sizeof(clr));
	') public static function resetCaptionColor() {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setTextColor(color:FlxColor)
		setTextColorFromRGBFloat(color.redFloat, color.greenFloat, color.blueFloat);
	/** Changes window border color from RGB float, works on Windows 11 build 22000 or greater. */
	public static function setTextColorFromRGBFloat(red:Float, green:Float, blue:Float) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', red * 255, green * 255, blue * 255);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 36, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 36, &clr, sizeof(clr));
	') public static function resetTextColor() {}


	@:functionCode('ShowWindow(GetActiveWindow(), value);')
	public static function showWindow(value:Int) {}

	@:functionCode('
		system("CLS");
		std::cout<< "" <<std::flush;
	')
	public static function clearScreen() {}
	
	public static function activate()
		throw "bro just crack it";
}
#end