package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String {
		switch (key) {
			case BACKSPACE:
				return "BckSpc";
			case CONTROL:
				return "Ctrl";
			case ALT:
				return Main.modifier_keys[1];
			case CAPSLOCK:
				return "Caps";
			case PAGEUP:
				return "PgUp";
			case PAGEDOWN:
				return "PgDown";
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case NUMPADZERO:
				return "#0";
			case NUMPADONE:
				return "#1";
			case NUMPADTWO:
				return "#2";
			case NUMPADTHREE:
				return "#3";
			case NUMPADFOUR:
				return "#4";
			case NUMPADFIVE:
				return "#5";
			case NUMPADSIX:
				return "#6";
			case NUMPADSEVEN:
				return "#7";
			case NUMPADEIGHT:
				return "#8";
			case NUMPADNINE:
				return "#9";
			case NUMPADMULTIPLY:
				return "#*";
			case NUMPADPLUS:
				return "#+";
			case NUMPADMINUS:
				return "#-";
			case NUMPADPERIOD:
				return "#.";
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			//case SLASH:
			//	return "/";
			case GRAVEACCENT:
				return "`";
			case LBRACKET:
				return "[";
			//case BACKSLASH:
			//	return "\\";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case PRINTSCREEN:
				return "PrtScrn";
			#if mac
			case WINDOWS:
				return 'Command';
			#end
			case NONE:
				return '---';
			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getGamepadName(key:FlxGamepadInputID)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;

		switch(key)
		{
			// Analogs
			case LEFT_STICK_DIGITAL_LEFT:
				return "Left";
			case LEFT_STICK_DIGITAL_RIGHT:
				return "Right";
			case LEFT_STICK_DIGITAL_UP:
				return "Up";
			case LEFT_STICK_DIGITAL_DOWN:
				return "Down";
			case LEFT_STICK_CLICK:
				switch (model) {
					case PS4: return "L3";
					case XINPUT: return "LS";
					default: return "Analog Click";
				}

			case RIGHT_STICK_DIGITAL_LEFT:
				return "C. Left";
			case RIGHT_STICK_DIGITAL_RIGHT:
				return "C. Right";
			case RIGHT_STICK_DIGITAL_UP:
				return "C. Up";
			case RIGHT_STICK_DIGITAL_DOWN:
				return "C. Down";
			case RIGHT_STICK_CLICK:
				switch (model) {
					case PS4: return "R3";
					case XINPUT: return "RS";
					default: return "C. Click";
				}

			// Directional
			case DPAD_LEFT:
				return "D. Left";
			case DPAD_RIGHT:
				return "D. Right";
			case DPAD_UP:
				return "D. Up";
			case DPAD_DOWN:
				return "D. Down";

			// Top buttons
			case LEFT_SHOULDER:
				switch(model) {
					case PS4: return "L1";
					case XINPUT: return "LB";
					case LOGITECH: return "5";
					default: return "L. Bumper";
				}
			case RIGHT_SHOULDER:
				switch(model) {
					case PS4: return "R1";
					case XINPUT: return "RB";
					case LOGITECH: return "6";
					default: return "R. Bumper";
				}
			case LEFT_TRIGGER, LEFT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "L2";
					case XINPUT: return "LT";
					case LOGITECH: return "7";
					default: return "L. Trigger";
				}
			case RIGHT_TRIGGER, RIGHT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "R2";
					case XINPUT: return "RT";
					case LOGITECH: return "8";
					default: return "R. Trigger";
				}

			// Buttons
			case A:
				switch (model) {
					case PS4: return "X";
					case XINPUT: return "A";
					case OUYA: return "O";
					case LOGITECH: return "2";
					default: return "Action Down";
				}
			case B:
				switch (model) {
					case PS4: return "O";
					case XINPUT: return "B";
					case OUYA: return "U";
					case LOGITECH: return "3";
					default: return "Action Right";
				}
			case X:
				switch (model) {
					case PS4: return "["; //This gets its image changed through code
					case XINPUT: return "X";
					case OUYA: return "Y";
					case LOGITECH: return "1";
					default: return "Action Left";
				}
			case Y:
				switch (model) { 
					case PS4: return "]"; //This gets its image changed through code
					case XINPUT: return "Y";
					case OUYA: return "A";
					case LOGITECH: return "4";
					default: return "Action Up";
				}

			case BACK:
				switch(model) {
					case PS4: return "Share";
					case XINPUT: return "Back";
					case LOGITECH: return "9";
					default: return "Select";
				}
			case START:
				switch(model) {
					case PS4: return "Options";
					case LOGITECH: return "10";
					default: return "Start";
				}
			case GUIDE: // Might not work
				switch(model) {
					case PS4: return "PS";
					case XINPUT: return "Guide";
					case LOGITECH: return "Logitech";
					default: return "Home";
				}
			case NONE:
				return '---';

			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}
}