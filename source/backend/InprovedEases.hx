package backend;

import haxe.macro.Compiler;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
#end

/**
 * Class contains regular FlxEases and advanced ones.
 * Class is used for more than the original eases from FlxEase.
 */
class ImprovedEases
{
	/** Easing constants */
	static var PI2:Float = Math.PI / 2;
  static var EL:Float = 2 * Math.PI / .45;
	static var B1:Float = 1 / 2.75;
	static var B2:Float = 2 / 2.75;
	static var B3:Float = 1.5 / 2.75;
	static var B4:Float = 2.5 / 2.75;
	static var B5:Float = 2.25 / 2.75;
	static var B6:Float = 2.625 / 2.75;
	static var ELASTIC_AMPLITUDE:Float = 1;
	static var ELASTIC_PERIOD:Float = 0.4;

    public static inline function tri(t:Float):Float
    {
      return 1 - Math.abs(2 * t - 2);
    }
    public static inline function bell(t:Float):Float
    {
    return quintInOut(tri(t));
    }
    public static inline function pop(t:Float):Float
    {
      return 3.5 * (1 - t) * (1 - t) * Math.sqrt(t);
    }
    public static inline function tap(t:Float):Float
    {
      return 3.5 * t * t * Math.sqrt(1 - t);
    }
    public static inline function pulse(t:Float):Float
    {
      return t < .5 ? tap(t * 2) : -pop(t * 2 - 1);
    }
    public static inline function spike(t:Float):Float
    {
      return Math.exp(-10 * Math.abs(2 * t - 1));
    }
  }


