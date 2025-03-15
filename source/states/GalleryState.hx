package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import flixel.FlxState;
import openfl.system.System;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
using StringTools;
import hxvlc.flixel.FlxVideoSprite;


class GalleryState extends FlxState
{
	// file name, title, desc, type (0 = image, 1 = video, 2 = sound effect, 3 = music)
	var galleryList:Array<Array<Dynamic>> = [
        // ["bima", "bimagamongMOP", "The creator of this gallery and this image.", 0],
		["Screenshot_20241211_200926_YouTube", "", "", 0],
		["jorg Washingmachine", "", "", 0],
		["omygod", "", "Press enter to play video.", 1],
		["Fabric_of_reality", "", "Press enter to play video.", 1],
		["Download_33", "", "Press enter to play video.", 1],
		["ahh", "", "Press enter to play video.", 1],
		["Peter Grifi", "", "Press enter to play video.", 1],
		["videoexample", "", "Press enter to play video.", 1],
		["Heaey", "", "Press enter to play video.", 1],
		// ["check-mark_oPG7Xo5", "", "Press enter to play sound effect.", 2],
		// ["queen-never-cry-made-with-Voicemod", "", "Press enter to play sound effect.", 2],
		// ["spongebob-stinky-sound-effect-made-with-Voicemod", "", "Press enter to play sound effect.", 2],
		// ["Opening", "", "Press enter to play sound effect.", 2],
		// ["Reflection-EncoreInfinitum", "", "Press enter to play sound effect.", 2],
		// ["audioexample", "Audio Example", "Press enter to play a sound effect.", 2],
		// ["musicexample", "Audio Example 2", "Press enter to play a song.", 3]
	];		

	var disableInput:Bool = false;
    var curSelected:Int = 0;
	var pageNo:Int;

	var img:FlxSprite;
	var daSound:FlxSound;
	var titleG:FlxText;
	var descG:FlxText;
	var instDisplay:FlxText;
	var colorBG:FlxSprite;

	override function create()
	{
		pageNo = curSelected + 1;

		var fontPath:String = "assets/fonts/vcr.ttf";

		colorBG = new FlxSprite().makeGraphic(1300, 800, FlxColor.fromRGB(FlxG.random.int(0, 225), FlxG.random.int(0, 225), FlxG.random.int(0, 225)));
		colorBG.antialiasing = false;
		colorBG.screenCenter();
		add(colorBG);

        var daBG = new FlxBackdrop("assets/shared/images/gallery/squares.png", XY, 0, 0);
		daBG.updateHitbox();
		daBG.scrollFactor.set(0, 0);
		daBG.alpha = 0.3;
		daBG.setGraphicSize(Std.int(daBG.width * FlxG.random.float(0.5, 1)));
		daBG.screenCenter();
		daBG.velocity.set(FlxG.random.int(-50, 50), FlxG.random.int(-50, 50));
		daBG.antialiasing = false;
		add(daBG);

		loadfirstThing();

		titleG = new FlxText(0, 0, 900, galleryList[curSelected][1]);
		titleG.setFormat(fontPath, 45, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		titleG.screenCenter();
		titleG.alpha = 0;
		titleG.y -= 280;
		add(titleG);

		descG = new FlxText(0, 0, 900, galleryList[curSelected][2]);
		descG.setFormat(fontPath, 35, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		descG.screenCenter();
		descG.alpha = 0;
		descG.y += 280;
		add(descG);

		instDisplay = new FlxText(0, 0, 0, "Q/E - Zoom In/Out\nWASD - Move Image\nX - Toggle Text\n" + pageNo + " / " + galleryList.length);
		instDisplay.setFormat(fontPath, 35, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		instDisplay.screenCenter();
		instDisplay.alpha = 0;
		instDisplay.x -= 450;
		add(instDisplay);

		changeItem(0);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!disableInput)
		{
			if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			{
				FlxG.switchState(new MainMenuState());

				/*
					Adding this in case:
					MusicBeatState.switchState(new MainMenuState());
				*/
			}

			if (FlxG.keys.justPressed.LEFT)
			{
				changeItem(-1);
			}
	
			if (FlxG.keys.justPressed.RIGHT)
			{
				changeItem(1);
			}

			if (galleryList[curSelected][3] == 0)
			{
				if (FlxG.keys.justPressed.Q)
				{
					img.scale.set(img.scale.x + 0.2, img.scale.y + 0.2);
				}
						
				if (FlxG.keys.justPressed.E)
				{
					img.scale.set(img.scale.x - 0.2, img.scale.y - 0.2);
				}
			
				if (FlxG.keys.justPressed.W)
				{
					img.y -= 20;
				}
						
				if (FlxG.keys.justPressed.A)
				{
					img.x -= 20;
				}
			
				if (FlxG.keys.justPressed.S)
				{
					img.y += 20;
				}
						
				if (FlxG.keys.justPressed.D)
				{
					img.x += 20;
				}
				
				if (FlxG.keys.justPressed.X)
				{
					if (instDisplay.alpha == 1)
					{
						instDisplay.alpha = 0;
						descG.alpha = 0;
						titleG.alpha = 0;
					}
					else
					{
						instDisplay.alpha = 1;
						descG.alpha = 1;
						titleG.alpha = 1;
					}
				}
			}
			else if (galleryList[curSelected][3] == 1)
			{
                if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.music.pause();
					disableInput = true;
					img.alpha = 0;
					instDisplay.alpha = 0;
					descG.alpha = 0;
					titleG.alpha = 0;

					// CHANGE THE PATH IF NEEDED!
					var filepath:String = "assets/videos/gallery/" + galleryList[curSelected][0] + "." + Paths.VIDEO_EXT;
					var video:FlxVideoSprite = new FlxVideoSprite(0, 0);
					video.load(filepath);
					video.bitmap.onFormatSetup.add(function():Void
					{
						if (video.bitmap != null && video.bitmap.bitmapData != null)
						{
							final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);

							video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
							video.updateHitbox();
							video.screenCenter();
						}
					});
					video.bitmap.onEndReached.add(function()
					{
						video.destroy();
						FlxG.sound.music.resume();
						disableInput = false;
						img.alpha = 1;
						instDisplay.alpha = 1;
						descG.alpha = 1;
						titleG.alpha = 1;
						remove(video);						
					});
					video.play();
					add(video);			
				}
			}
			else if (galleryList[curSelected][3] == 2)
			{
				if (FlxG.keys.justPressed.ENTER)
				{
					var filepath:String = "assets/shared/sounds/gallery/" + galleryList[curSelected][0] + ".ogg";
					FlxG.sound.music.pause();
					
					if (daSound != null) daSound.stop();
					daSound = new FlxSound();
					daSound.loadEmbedded(filepath, false, true);
					daSound.onComplete = function():Void {
						FlxG.sound.music.resume();
					}
					daSound.play(true, 0);
				}
			}
			else
			{
				if (FlxG.keys.justPressed.ENTER)
				{
					var filepath:String = "assets/shared/music/gallery/" + galleryList[curSelected][0] + ".ogg";
					FlxG.sound.music.pause();
	
					if (daSound != null) daSound.stop();
					daSound = new FlxSound();
					daSound.loadEmbedded(filepath, false, true);
					daSound.onComplete = function():Void {
						FlxG.sound.music.resume();
					}
					daSound.play(true, 0);
				}
			}
		}

		super.update(elapsed);
	}

	public function changeItem(change:Int)
	{
		curSelected += change;

		if (daSound != null)
		{
			daSound.stop();
		}
		FlxG.sound.music.resume();

		instDisplay.alpha = 1;
		descG.alpha = 1;
		titleG.alpha = 1;
		
		if (curSelected < 0) {curSelected = 0;}
		else if (curSelected > galleryList.length - 1) {curSelected = galleryList.length - 1;}

		pageNo = curSelected + 1;

		titleG.text = galleryList[curSelected][1];
		descG.text = galleryList[curSelected][2];

		instDisplay.text = "Q/E - Zoom In/Out\nWASD - Move Image\nX - Toggle Text\n" + pageNo + " / " + galleryList.length;
		loadfirstThing();
	}

	public function loadfirstThing()
	{
		var imagePath:String = "";

		// CHANGE YOUR PATHS IF NEEDED!
		switch (galleryList[curSelected][3])
		{
			case 0:
				// THE PATH TO IMAGE!!!!!
				imagePath = "assets/shared/images/gallery/img/" + galleryList[curSelected][0] + ".png";
			case 1:
				// THE PATH TO IMAGE!!!!!
				imagePath = "assets/shared/images/gallery/img/" + galleryList[curSelected][0] + ".png";
			default:
				// Displays the audio graphic
				imagePath = "assets/shared/images/gallery/audioGraphic.png";
		}

		remove(img);
		img = new FlxSprite().loadGraphic(imagePath);
		img.setGraphicSize(Std.int(img.width * 1));
		img.screenCenter();
		add(img);
	}
}