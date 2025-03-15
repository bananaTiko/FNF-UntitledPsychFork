package backend.api;

#if !macro
import openfl.geom.ColorTransform;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

import backend.Paths;
import backend.CoolUtil;
#end

import flixel.util.typeLimit.OneOfTwo;
import backend.api.WinCmdAPI;
using StringTools;

/** 
 * To use:
 * ```haxe
 * using util.StaticExtensions;
 * ```
 */
class StaticExtensions {
	#if !macro
	/** Shortcut of `FlxMath.roundDecimal` */
	inline public static function roundDecimal(n:Float, decimals:Int):Float return FlxMath.roundDecimal(n, decimals);
	/** Shortcut of `CoolUtil.floorDecimal` */
	inline public static function floorDecimal(n:Float, decimals:Int):Float return CoolUtil.floorDecimal(n, decimals);
	/** `0.2423` to `0.24` / `0.2453` => `0.25` */
	inline public static function toDouble(n:Float):Float return roundDecimal(n, 2);
	/** `"meow.json".hasExtension("json")` returns `true`, `"meow".hasExtension("json")` returns `false` */
	inline public static function hasExtension(path:String, ext:String):Bool return Paths.hasExtension(path, ext);
	/** `"meow.json".removeExtension()` returns `"meow"` */
	inline public static function removeExtension(path:String):String return Paths.removeExtension(path);

	/** Clears array and returns `null` */
	public static function clearArray<T:Any>(array:Array<T>):Array<T> {
		array.splice(0, array.length);
		return array;
	}
	/** Destroys each object in array, clears it and then returns `null` */
	public static function destroyArray<T:IFlxDestroyable>(array:Array<T>):Array<T> {
		for (a in array) a.destroy();
		clearArray(array);
		return array;
	}
	/** Destroys each object in group, clears it and then returns `null` */
	public static function destroyGroup<T:FlxBasic>(group:FlxTypedGroup<T>):FlxTypedGroup<T> {
		for (g in group) g.destroy();
		group.clear();
		return group;
	}

	/** Useful when you need to disable antialiasing of object which initialized and added in one line, like this: `add(new FlxSprite().disableAntialiasing());` */
	public static function disableAntialiasing<T:FlxSprite>(spr:T):T {
		spr.antialiasing = false; return spr;
	}
	/** Useful when you need to set ID of object which initialized and added in one line, like this: `add(new FlxBasic().setID(3));` */
	public static function setID<T:FlxBasic>(spr:T, id:Int):T {
		spr.ID = id; return spr;
	}

	/**
	 * One-liner of setting `ColorTransform` offset vars
	 * @param red redOffset
	 * @param green greenOffset
	 * @param blue blueOffset
	 */
	public static function setOffset(c:ColorTransform, red:Float = 0, green:Float = 0, blue:Float = 0) {
		c.redOffset = red; c.greenOffset = green; c.blueOffset = blue;
	}

	/**
	 * One-liner of setting `ColorTransform` multiplier vars
	 * @param red redMultiplier
	 * @param green greenMultiplier
	 * @param blue blueMultiplier
	 */
	public static function setMultiplier(c:ColorTransform, red:Float = 1, green:Float = 1, blue:Float = 1) {
		c.redMultiplier = red; c.greenMultiplier = green; c.blueMultiplier = blue;
	}
	#end

	/** Shortcut of `Math.pow` */
	public static function pow(n:Float, ?exp:Float = 2):Float return Math.pow(n, exp);

	/** Shortcut of `Std.int` */
	inline public static function floatToInt(n:Float):Int return Std.int(n);
	/** Shortcut of `bool ? 1 : 0` */
	inline public static function boolToInt(b:Bool):Int return b ? 1 : 0;

	/** Works like `Std.parseInt()`, but returns `null` if `Std.parseInt()` returns `NaN` */
	public static function toInt(n:Null<OneOfTwo<Int, String>>):Null<Int> {
		if (n == null) return null;
		var n:Int = n is Int ? n : Std.parseInt(n);
		return Math.isNaN(n) ? null : n;
	}
	/** Works like `Std.parseFloat()`, but returns `null` if `Std.parseFloat()` returns `NaN` */
	public static function toFloat(n:Null<OneOfTwo<Float, String>>):Null<Float> {
		if (n == null) return null;
		var n:Float = n is Float ? n : Std.parseFloat(n);
		return Math.isNaN(n) ? null : n;
	}

	/** Returns `false` if `arr` is empty array or `null` */
	public static function arrNotEmpty(arr:Array<Dynamic>, ?length:Int = 1):Bool return arr != null ? arr.length >= length : false;
	/** Returns `false` if `str` is empty string or `null` */
	public static function strNotEmpty(str:String, ?length:Int = 1):Bool return str != null ? str.trim().length >= length : false;

	/** Formats this `str` as `format` in Windows cmd, on other platforms will return just `str` */
	inline public static function toCMD(str:String, format:CMDFormat):String return WinCmdAPI.toCMD(str, format);
}