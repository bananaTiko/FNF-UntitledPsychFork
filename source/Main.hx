package;

#if android
import android.content.Context;
#end

import backend.ColorBlindness;
import debug.FPSCounter; 
import funkin.GameBorder;
import backend.FunkinRatioScaleMode as RatioScaleMode;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.StageQuality;
import lime.app.Application;
import states.TitleState;
import flxres.FlxRes;
import Sys.println as log;

#if desktop
import backend.ALConfig; // Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
#end

#if windows
import hxwindowmode.WindowColorMode;
#end

#if linux
import lime.graphics.Image;
#end

//audio fix stuff
import backend.api.WinAPI;
import backend.AudioSwitchFix;
// import backend.Native;

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
#end

import backend.Highscore;
import meta.GameDimensions;

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
#if windows
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end
// // // // // // // // //
class Main extends Sprite
{
	private static final game = {
		width: GameDimensions.width, // WINDOW width
		height: GameDimensions.height, // WINDOW height
		initialState: TitleState, // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var focused:Bool = true;
	public static var appName:String = ''; // Application name.
	public static var modifier_keys:Array<String> = #if !mac ['Control', 'Alt']; #else['Command', 'Option']; #end 
	public static var fpsVar:FPSCounter;
	public static var daColorFilter:ColorBlindness;
	/**
	 * The desing width of this game. You will use either this or the design height
	*/
	private static inline var DESIGN_WIDTH:Int = 1280;

	/**
	 * The desing height of this game. You will use either this or the design width
   	*/
 	private static inline var DESIGN_HEIGHT:Int = 720;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		#if (cpp && windows)
		backend.Native.fixScaling();
		backend.Native.registerDPIAware();
		backend.Native.disableGhosting();
		#end

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		Highscore.load();

		#if windows
		static final UPDATE_INTERVAL:Float = 1.0;
		var time:Float = 0;
		var prev:Float = -1;
		
		function onEnterFrame(e:Event):Void {
			time += FlxG.elapsed;
			if (Std.int(prev) != Std.int(time) && time - prev >= UPDATE_INTERVAL) {
				backend.AudioSwitchFix.checkForDisconnect();
				prev = time;
			}
		}
		
		// Add event listener in constructor or initialization
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		#end

		var _width:Int;
		var _height:Int;

		/**
		 * returnWidth = true : resulted resolution is based on DESIGN_WIDTH
		 * returnWidth = false : resulted resolution is based on DESIGN_HEIGHT
		 */
		var returnWidth:Bool = false;

		if (returnWidth)
		{
			_height = DESIGN_HEIGHT;
			_width = FlxRes.getOtherDimension(_height, returnWidth);
		}
		else
		{
			_width = DESIGN_WIDTH;
			_height = FlxRes.getOtherDimension(_width);
		}

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		var gameObject = new FlxGame(_width, _height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		// FlxG.game._customSoundTray wants just the class, it calls new from
		// create() in there, which gets called when it's added to stage
		// which is why it needs to be added before addChild(game) here
		@:privateAccess
		gameObject._customSoundTray = backend.FunkinSoundTray;
		addChild(gameObject);

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		var border = new GameBorder();
		addChild(border);
		Lib.current.stage.window.onResize.add(border.updateGameSize);
		addChild(fpsVar);
		// Lib.current.stage.align = "tl";
		// Lib.current.stage.scaleMode = StageScaleMode.NO_BORDER;
		// Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		// Lib.current.stage.quality = StageQuality.BEST;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
	#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if desktop
		// Get first window in case the coder creates more windows.
		@:privateAccess
		appName = openfl.Lib.application.windows[0].__backend.parent.__attributes.title;
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
			 if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
				}
			}	

		if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		FlxG.stage.window.onClose.add(function() {
			// closed
			FileSystem.deleteFile('modsList.txt');
		});
	}

	// Similar from Sanic's Psych Engine 0.3.2h fork...
	public static function tweenFPS(visible:Bool = true, duration:Float = 1.5)
		{
			if (ClientPrefs.data.showFPS && fpsVar != null) if (visible) FlxTween.tween(fpsVar, {alpha: 1}, duration); else FlxTween.tween(fpsVar, {alpha: 0}, duration);
		}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
				sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	var oldVol:Float = 1.0;
	var newVol:Float = 0.2;

	public static var focusMusicTween:FlxTween;

	function onWindowFocusOut()
	{
		focused = false;
	
		oldVol = FlxG.sound.volume;
		if (oldVol > 0.3)
		{
			newVol = 0.3;
		}
		else
		{
			if (oldVol > 0.1)
			{
			newVol = 0.1;
			}
			else
			{
			newVol = 0;
			}
		}

		if (focusMusicTween != null) focusMusicTween.cancel();
		focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);
	}
	
	function onWindowFocusIn()
	{
		new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			focused = true;
		});
		
		  // Normal global volume when focused
		if (focusMusicTween != null) focusMusicTween.cancel();
	
		focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);
	}

	#if windows
	public static function startOfTrace(fileName:String, lineNumber:Int) {
		// so its like:    [03:17:48] [debug/GPUStats:75] Traced string yeah
		// and colors are:    blue           cyan            basic (white)
		var time = ('[' + DateTools.format(Date.now(), '%H:%M:%S') + ']').toCMD(BLUE);
		var path = ('[' + (fileName.substring(fileName.startsWith('source/') ? (fileName.indexOf('/') + 1) : 0, fileName.length - 3)) + ':' + lineNumber + ']').toCMD(CYAN);

		return '$time $path ';
	}
	#end

	public static function println(str:Dynamic) {
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(str);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(str));
		#elseif sys
		Sys.println(str);
		#else
		throw new haxe.exceptions.NotImplementedException()
		#end
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "UPF_Crashlog_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
		/*
		 * remove if you're modding and want the crash log message to contain the link
		 * please remember to actually modify the link for the github page to report the issues to.
		*/
		// 
		#if officialBuild
		errMsg += "\nPlease report this error to the GitHub page: https://github.com/bananaTiko/FNF-UntitledPsychFork\n\n> Crash Handler written by: sqirra-rng";
		#end

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		#if windows
		Application.current.window.alert(errMsg, "Error!");
		#elseif linux
		Sys.command("notify-send",["Error!",errMsg]);
		#end

		// FlxG.sound.play(Paths.sound('error'));

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
