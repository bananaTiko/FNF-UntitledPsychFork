package backend.api;

/** @see https://gist.githubusercontent.com/mlocati/fdabcaeb8071d5c75a2d51712db24011/raw/b710612d6320df7e146508094e84b92b34c77d48/win10colors.cmd */ 
enum CMDFormat {
	BOLD;
	UNDERLINE;
	INVERSE;
	BLACK;        // 0x878787
	RED;          // 0xd75959
	GREEN;        // 0x12bc5a
	YELLOW;       // 0xe5e510
	BLUE;         // 0x4e8ed3
	MAGENTA;      // 0xc353c3
	CYAN;         // 0x11a8cd
	WHITE;        // 0xe5e5e5
	BLACK_BOLD;   // 0x848484
	RED_BOLD;     // 0xf14c4c
	GREEN_BOLD;   // 0x23d18b
	YELLOW_BOLD;  // 0xf5f543
	BLUE_BOLD;    // 0x3b8eea
	MAGENTA_BOLD; // 0xd670d6
	CYAN_BOLD;    // 0x29b8db
	WHITE_BOLD;   // 0xe5e5e5
	RESET;
}

class WinCmdAPI {
	/** Formats this `str` as `format` in Windows cmd, on other platforms will return just `str` */
	public static function toCMD(str:String, format:CMDFormat = RESET) {
		if (!isWindows) return str;
		switch(format) {
			case BOLD:      return '[1m$str[0m';
			case UNDERLINE: return '[4m$str[0m';
			case INVERSE:   return '[7m$str[0m';

			case BLACK:   return '[30m$str[0m';
			case RED:     return '[31m$str[0m';
			case GREEN:   return '[32m$str[0m';
			case YELLOW:  return '[33m$str[0m';
			case BLUE:    return '[34m$str[0m';
			case MAGENTA: return '[35m$str[0m';
			case CYAN:    return '[36m$str[0m';
			case WHITE:   return '[37m$str[0m';

			case BLACK_BOLD:   return '[30m[1m$str[0m';
			case RED_BOLD:     return '[31m[1m$str[0m';
			case GREEN_BOLD:   return '[32m[1m$str[0m';
			case YELLOW_BOLD:  return '[33m[1m$str[0m';
			case BLUE_BOLD:    return '[34m[1m$str[0m';
			case MAGENTA_BOLD: return '[35m[1m$str[0m';
			case CYAN_BOLD:    return '[36m[1m$str[0m';
			case WHITE_BOLD:   return '[37m[1m$str[0m';

			default: return '[0m$str[0m';
		}
	}

	@:noCompletion public static var isWindows:Bool = #if windows true #else false #end;
}