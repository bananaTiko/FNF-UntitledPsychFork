package options;

import backend.ColorBlindness;
import objects.Character;
#if mobile
import backend.UPFscaleMode;
#end

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'Graphics Settings');
		rpcTitle = 'Changing Graphics Settings'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker PCs.", //Description
			'shaders',
			BOOL);
		addOption(option);

		#if mobile
		var option = new Option('Wide Screen Mode',
		'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
		'wideScreen', BOOL);
		option.onChange = () -> FlxG.scaleMode = new UPFscaleMode();
		addOption(option);
		#end

		var option:Option = new Option(Language.getPhrase('setting_color_filter','Color Filter:'), 
			'Choose your color blindness filter of your choice.', 
			'daColorFilter', 
			STRING,
			['NONE', "DEUTERANOPIA", "PROTANOPIA", "TRITANOPIA", "TRITANOMALY", "PROTANOMALY", "ACHROMATOPSIA", "MONOCHROMACY"]
		);
		option.onChange = onChangeColorFilter;
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", //Description
			'cacheOnGPU',
			BOOL);
		addOption(option);

		#if !html5
		// var option:Option = new Option(
		// 	'Resolution',
		// 	"Changes the game's resolution.",
		// 	'resolution',
		// 	STRING,
		// 	[ //some these Resolutions may never be used but it still good do have them
		// 	'128x72', '214x120', '256x144', '480x270',
		// 	'640x360', '640x480', '854x480', '960x540',
		// 	'1280x720', '1920x1080', '2560x1440', '3200x1800',
		// 	'3840x2160', '5120x2880', '7680x4320', '15360x8640',
		// 	'2560x1080', '3440x1440', '5120x2160',
		// 	'1280x800', '1920x1200', '2560x1600',
		// 	'320x240', '400x300', '800x600',
		// 	'1366x768', '1440x900',
		// 	'1080x2340', '1440x3200',
		// 	'3840x1080', '5120x1440',
		// 	'2048x1080', '2880x1800', '3360x2100', '4096x2160',
		// 	'5120x3200', '7680x4800', '10240x5760'
		// 	]
		// );
		// addOption(option);

		//Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync stuff enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 30; //Make it almost under 60
		option.maxValue = 10000; //Make it almost unlimited
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeColorFilter()
		{
			ColorBlindness.setFilter();
		}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}
