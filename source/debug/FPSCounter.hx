package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import haxe.Timer;

#if flash
import openfl.Lib;
#end



/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	public var MemoryMin(default, null):Float = 0.0;
	public var memoryMax(default, null):Float = 0.0;

    @:noCompletion private var lastFramerateUpdateTime:Float;
    @:noCompletion private var updateTime:Int;
	@:noCompletion private var framesCount:Int;
	@:noCompletion private var prevTime:Int;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		positionFPS(x, y);

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("Open Sans Regular", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		lastFramerateUpdateTime = Timer.stamp();
		prevTime = Lib.getTimer();
		updateTime = prevTime + 500;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: ${currentFPS} • RAM: ${CoolUtil.getSizeString(debug.Memory.getProcessMemory())} / ${CoolUtil.getSizeString(memoryMax)}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.stage.window.frameRate * 0.5)
			textColor = 0xFFFF0000;
		else if (currentFPS <= FlxG.stage.window.frameRate / 2 && currentFPS >= FlxG.stage.window.frameRate / 3) 
			textColor = 0xFFFFFF00;
		else if (currentFPS <= FlxG.stage.window.frameRate / 3 && currentFPS >= FlxG.stage.window.frameRate / 4) 
			textColor = 0xFFFF6F00;
	}

	private override function __enterFrame(deltaTime:Float):Void
		{
			// Flixel keeps reseting this to 60 on focus gained
			if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate)
				FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
	
			var currentTime = openfl.Lib.getTimer();
			framesCount++;
	
			if (currentTime >= updateTime) {
				var elapsed = currentTime - prevTime;
				currentFPS = Math.ceil((framesCount * 1000) / elapsed);
				framesCount = 0;
				prevTime = currentTime;
				updateTime = currentTime + 500;
			}
	
			// Set Update and Draw framerate to the current FPS every 1.5 second to prevent "slowness" issue
			if ((FlxG.updateFramerate >= currentFPS + 5 || FlxG.updateFramerate <= currentFPS - 5)
				&& haxe.Timer.stamp() - lastFramerateUpdateTime >= 1.5 && currentFPS >= 30)
			{
				FlxG.updateFramerate = FlxG.drawFramerate = currentFPS;
				lastFramerateUpdateTime = haxe.Timer.stamp();
			}
			memoryMax = Math.max(debug.Memory.getProcessMemory(), debug.Memory.getProcessMemory());
	
			updateText();
		}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = (scale > 1 ? scale : 1);
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}

    inline function get_memoryMegas():Float
        return debug.Memory.getProcessMemory();
}