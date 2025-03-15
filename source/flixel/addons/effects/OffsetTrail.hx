package flixel.addons.effects;

import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.*;
import flixel.system.FlxAssets;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

class OffsetTrail extends FlxTrail
{
	/**
	 * An offset applied to the target position whenever a new frame is saved.
	 */
	public final frameOffset:FlxPoint = FlxPoint.get();
	
	override function update(elapsed:Float)
	{
		final oldX = target.offset.x;
		final oldY = target.offset.y;
		target.offset.copyFrom(frameOffset);
		super.update(elapsed);
		target.offset.set(oldX, oldY);
	}
	
	override function destroy()
	{
		super.destroy();
		
		frameOffset.put();
	}
}