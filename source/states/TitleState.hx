package states;

import backend.ColorBlindness;
import backend.WeekData;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDirectionFlags;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import openfl.ui.GameInput;
import openfl.ui.GameInputDevice;
import lime._internal.backend.native.NativeCFFI;
import lime.ui.Gamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.MainMenuState;
import states.AttractState;

import objects.VisualizerSprite;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;

#if windows
import hxwindowmode.WindowColorMode;
#end

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Int;
	
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;
	var bgGrad:FlxSprite;
	var waveSprite:VisualizerSprite;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var Timer:Float = 0;
	var curWacky:Array<String> = [];

	var checker:FlxBackdrop;
	var speed:Float = 1;

	var wackyImage:FlxSprite;

	//keeps track of how many texts were added so they always come from different directions
	var counter:Int = 0;

	#if TITLE_SCREEN_EASTER_EGG
	final easterEggKeys:Array<String> = [
		'SHADOW', 'RIVEREN', 'BBPANZU', 'PESSY', 'PIZZA', 'RADIO'
	];
	final allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	public static var mouse:FlxSprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			#if windows
			if(ClientPrefs.data.daWindowBar == 'Dark')
			{
				WindowColorMode.setWindowColorMode(true);
				WindowColorMode.redrawWindowHeader();
			}
			else if (ClientPrefs.data.daWindowBar == 'Light')
			{
				WindowColorMode.setWindowColorMode(false);
				WindowColorMode.redrawWindowHeader();
			}
			#end
			Language.reloadPhrases();
			ColorBlindness.setFilter();
			FlxG.mouse.useSystemCursor = true;
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if(!initialized)
		{
				if(FlxG.save.data != null && FlxG.save.data.fullscreen)
				{
					FlxG.fullscreen = FlxG.save.data.fullscreen;
					//trace('LOADED FULLSCREEN SETTING!!');
				}
				persistentUpdate = true;
				persistentDraw = true;
			}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
			startIntro();
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		persistentUpdate = true;
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 0);

		loadJsonData();
		#if TITLE_SCREEN_EASTER_EGG easterEggData(); #end
		switch(ClientPrefs.data.daMenuMusic) // change this if you're making a source mod, like add your own or something
		{
			case 'VS Impostor' | 'VS Nonsense V2' | 'Neo' | 'B Sides' | 'Shaggy'| 'JSR'  |'(OST Version)': 
			Conductor.bpm = 102;
			case 'B Sides Redux':
			Conductor.bpm = 88;
			case 'Mario Madness':
			Conductor.bpm = 45.593;
			case 'Kapi':
			Conductor.bpm = 47;
			case 'Ghost':
			Conductor.bpm = 55;
			case 'DnB':
			Conductor.bpm = 74;
			case 'Gapple':
			Conductor.bpm = 75;
			case 'IC':
			Conductor.bpm = 117;
			case 'Tricky':
			Conductor.bpm = 139;
			case 'Frog Remix':
			Conductor.bpm = 138;
			case 'DDTO+':
			Conductor.bpm = 120;
			case 'Stay Funky':
			Conductor.bpm = 90;
			case 'Default': // just in case you're not making a source mod & wanna change this
			Conductor.bpm = musicBPM;
			default: // fallback
			Conductor.bpm = musicBPM;
		}

		bgGrad = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x003A1D3A,0x753A1D3A, 0xC93A1D3A, 0xE1492649, 0xEF613261, 0xFF6C376C], 1, 90, true);
		bgGrad.antialiasing = ClientPrefs.data.antialiasing;
		bgGrad.scale.set(1.2, 1.2);
		bgGrad.alpha = 0.4;

		logoBl = new FlxSprite(logoPosition.x, logoPosition.y);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(gfPosition.x, gfPosition.y);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
		
		if(ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}
		
		gfDance.frames = Paths.getSparrowAtlas(characterImage);
		if(!useIdle)
		{
			gfDance.animation.addByIndices('danceLeft', animationName, danceLeftFrames, "", 24, false);
			gfDance.animation.addByIndices('danceRight', animationName, danceRightFrames, "", 24, false);
			gfDance.animation.play('danceRight');
		}
		else
		{
			gfDance.animation.addByPrefix('idle', animationName, 24, false);
			gfDance.animation.play('idle');
		}


		var animFrames:Array<FlxFrame> = [];
		titleText = new FlxSprite(enterPosition.x, enterPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (newTitle = animFrames.length > 0)
		{
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);

		if (FlxG.random.bool(1))
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo_classic'));
		}
		else if (FlxG.random.bool(30))
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo_animated'), true, 600);
			ngSpr.animation.add('idle', [0, 1], 4);
			ngSpr.animation.play('idle');
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.55));
			ngSpr.y += 25;
		}
		else
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo'));
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		}
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;  
		ngSpr.visible = false;

		waveSprite = new VisualizerSprite(-50,0,FlxG.width, 300, 150, FlxG.sound.music);
		waveSprite.y = FlxG.height - (waveSprite.height-50);
		waveSprite.x -= FlxG.width*0.55;
		waveSprite.color = 0xff8c00ff;
		waveSprite.alpha = 0.2;
		waveSprite.blend = BlendMode.ADD;

		checker = new FlxBackdrop(Paths.image('checker'), FlxAxes.XY);
		checker.scale.set(1.5, 1.5);
		checker.color = 0xFFEA00FF;
		checker.blend = BlendMode.LAYER;
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.4;
		checker.updateHitbox();

		add(bgGrad);
		add(checker);
		add(waveSprite);
		add(gfDance);
		add(logoBl); //FNF Logo
		add(titleText); //"Press Enter to Begin" text
		add(credGroup);
		add(ngSpr);


		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	// JSON data
	var characterImage:String = 'gfDanceTitle';
	var animationName:String = 'gfDance';

	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);
	
	var useIdle:Bool = false;
	var musicBPM:Float = 102;
	var danceLeftFrames:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
	var danceRightFrames:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

	function loadJsonData()
	{
		if(Paths.fileExists('images/gfDanceTitle.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('images/gfDanceTitle.json');
			if(titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					var titleJSON:TitleData = tjson.TJSON.parse(titleRaw);
					gfPosition.set(titleJSON.gfx, titleJSON.gfy);
					logoPosition.set(titleJSON.titlex, titleJSON.titley);
					enterPosition.set(titleJSON.startx, titleJSON.starty);
					musicBPM = titleJSON.bpm;
					
					if(titleJSON.animation != null && titleJSON.animation.length > 0) animationName = titleJSON.animation;
					if(titleJSON.dance_left != null && titleJSON.dance_left.length > 0) danceLeftFrames = titleJSON.dance_left;
					if(titleJSON.dance_right != null && titleJSON.dance_right.length > 0) danceRightFrames = titleJSON.dance_right;
					useIdle = (titleJSON.idle == true);
	
					if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.trim().length > 0)
					{
						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(titleJSON.backgroundSprite));
						bg.antialiasing = ClientPrefs.data.antialiasing;
						add(bg);
					}
				}
				catch(e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else trace('[WARN] No Title JSON detected, using default values.');
		}
		//else trace('[WARN] No Title JSON detected, using default values.');
	}

	function easterEggData()
	{
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		switch(easterEgg.toUpperCase())
		{
			case 'SHADOW':
				characterImage = 'ShadowBump';
				animationName = 'Shadow Title Bump';
				gfPosition.x += 210;
				gfPosition.y += 40;
				useIdle = true;
			case 'RIVEREN':
				characterImage = 'ZRiverBump';
				animationName = 'River Title Bump';
				gfPosition.x += 180;
				gfPosition.y += 40;
				useIdle = true;
			case 'BBPANZU':
				characterImage = 'BBBump';
				animationName = 'BB Title Bump';
				danceLeftFrames = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
				danceRightFrames = [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
				gfPosition.x += 45;
				gfPosition.y += 100;
			case 'PESSY':
				characterImage = 'PessyBump';
				animationName = 'Pessy Title Bump';
				gfPosition.x += 165;
				gfPosition.y += 60;
				danceLeftFrames = [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
				danceRightFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28];
			case 'PIZZA':
				characterImage = 'PizzaBump';
				animationName = 'gfDance';
				gfPosition.x += 0;
				gfPosition.y += 0;
				danceLeftFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
				danceRightFrames = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
			case 'RADIO':
				characterImage = 'RadioBump';
				animationName = 'gfDance';
				gfPosition.x += 0;
				gfPosition.y += 0;
				danceLeftFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
				danceRightFrames = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var intendedSpeed:Float = 1;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (!cheatActive && skippedIntro)
			cheatCodeShit();

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		bgGrad.alpha = FlxMath.lerp(0.2, bgGrad.alpha, FlxMath.bound(1 - (elapsed * 7), 0, 1));

		speed = FlxMath.lerp(intendedSpeed, speed, FlxMath.bound(1 - (elapsed * 2), 0, 1));
		checker.x += 0.45 / (ClientPrefs.data.framerate / 60);
		checker.y += (0.16 / (ClientPrefs.data.framerate / 60));

		if (FlxG.keys.justPressed.Y)
			{
			FlxTween.cancelTweensOf(FlxG.stage.window, ['x', 'y']);
			FlxTween.tween(FlxG.stage.window, {x: FlxG.stage.window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.35});
			FlxTween.tween(FlxG.stage.window, {y: FlxG.stage.window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: PINGPONG});
			}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
						{
							if (cheatActive)
							{
								FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 0);
								FlxG.sound.music.fadeIn(4, 0, 0.7);
							}
							FlxTransitionableState.skipNextTransIn = true;
							MusicBeatState.switchState(new MainMenuState());
						}
						closedState = true;
					});
					// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
				}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('secret'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
							black.scale.set(FlxG.width, FlxG.height);
							black.updateHitbox();
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if (swagShader != null)
			{
				if (cheatActive || controls.UI_LEFT)
					swagShader.hue -= elapsed * 0.1;
				if (controls.UI_RIGHT)
					swagShader.hue += elapsed * 0.1;
			}
	
			super.update(elapsed);
		}
	

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		var determined = (counter % 2 == 0 ? 1 : -1);
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			var oldX = money.x;
			money.x += FlxG.width * 2 * determined;
			money.y += (i * 65) + 200 + offset;
			FlxTween.tween(money, {x: oldX}, Conductor.crochet * .001, {type: ONESHOT, ease: FlxEase.expoOut});
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
		counter += 1;
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			var oldX = coolText.x;
			coolText.x += FlxG.width * 2 * (counter % 2 == 0 ? 1 : -1);
			coolText.y += (textGroup.length * 65) + 200 + offset;
			FlxTween.tween(coolText, {x: oldX}, Conductor.crochet * .001, {type:ONESHOT, ease:FlxEase.expoOut});
			credGroup.add(coolText);
			textGroup.add(coolText);
			counter += 1;
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom += 0.015;

        FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1200, {ease: FlxEase.quadOut});

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null)
		{
			danceLeft = !danceLeft;
			if(!useIdle)
			{
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
			else if(curBeat % 2 == 0) gfDance.animation.play('idle', true);
		}

		if (cheatActive && this.curBeat % 2 == 0 && swagShader != null)
			swagShader.hue += 0.125;

		if(!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					// FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 0);
					#if VIDEOS_ALLOWED
					FlxG.sound.music.onComplete = moveToAttract;
					#end
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					Main.tweenFPS();
					FlxG.mouse.visible = true;
				case 2:
					createCoolText(['Funkin Crew Inc', 'Shadow Mario', 'BananaTiko2']);
				case 4:
					addMoreText('present');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['Not associated', 'with'], -40);
				case 8:
					addMoreText('Newgrounds', -40);
					var oldNgSprY = ngSpr.y;
					ngSpr.y += FlxG.height * 2;
					ngSpr.visible = true;
					FlxTween.tween(ngSpr, {y: oldNgSprY}, Conductor.crochet * .001, {type: ONESHOT, ease: FlxEase.expoOut});
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10 | 12 | 14:
					deleteCoolText();
					curWacky = FlxG.random.getObject(getIntroTextShit());
					createCoolText([curWacky[0]]);
				case 11 | 13 | 15:
					addMoreText(curWacky[1]);
					deleteCoolText();
				case 16:
					deleteCoolText();
					createCoolText(['Friday']);
				case 17:
              // easter egg for when the game is trending with the wrong spelling
              // the random intro text would be "trending--only on x
              if (curWacky[0] == "trending") addMoreText('Nigth');
              else
                addMoreText('Night');
				case 18:

					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				case 19:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			#if TITLE_SCREEN_EASTER_EGG
			if (playJingle) //Ignore deez
			{
				playJingle = false;
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVEREN':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));
					case 'PESSY':
						sound = FlxG.sound.play(Paths.sound('JinglePessy'));
					case 'PIZZA':
						sound = FlxG.sound.play(Paths.sound('JinglePizza'));
					case 'RADIO':
						sound = FlxG.sound.play(Paths.sound('JingleRadio'));
					default: //Go back to normal ugly ass boring GF
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;
						FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
						if(easteregg == 'PESSY')
							Achievements.unlock('pessy_easter_egg');
					};
				}
			}
			else #end //Default! Edit this one!!
			{
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 4);

				FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});
				logoBl.angle = -4;
				new FlxTimer().start(0.01, function(tmr:FlxTimer)
					{
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			skippedIntro = true;
		}
	}

		// Cheat code shit
		//left right (2X) up down (2X)
		var cheatArray:Array<Int> = [0x0001, 0x0010, 0x0001, 0x0010, 0x0100, 0x1000, 0x0100, 0x1000];
		var curCheatPos:Int = 0;
		var cheatActive:Bool = false;
	
		function cheatCodeShit():Void
		{
			if (FlxG.keys.justPressed.ANY)
			{
				if (controls.NOTE_DOWN_P || controls.UI_DOWN_P)
					codePress(FlxDirectionFlags.DOWN);
				if (controls.NOTE_UP_P || controls.UI_UP_P)
					codePress(FlxDirectionFlags.UP);
				if (controls.NOTE_LEFT_P || controls.UI_LEFT_P)
					codePress(FlxDirectionFlags.LEFT);
				if (controls.NOTE_RIGHT_P || controls.UI_RIGHT_P)
					codePress(FlxDirectionFlags.RIGHT);
			}
		}
	
		function codePress(input:Int)
		{
			if (input == cheatArray[curCheatPos])
			{
				curCheatPos += 1;
				if (curCheatPos >= cheatArray.length)
					startCheat();
			}
			else
				curCheatPos = 0;
	
			trace(input);
		}
	
		function startCheat():Void
		{
			cheatActive = true;
	
			// var spec:SpectogramSprite = new SpectogramSprite(FlxG.sound.music);
	
			FlxG.sound.playMusic(Paths.music('girlfriendsRingtone'), 0);
			Conductor.bpm = 160; // GF's ringnote has different BPM
	
			FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
	
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		}

		/**
		 * After sitting on the title screen for a while, transition to the attract screen.
		 */
		function moveToAttract():Void
		{	
			if(!Std.isOfType(FlxG.state,TitleState)) return;
			FlxG.switchState(() -> new AttractState());
		}
	}