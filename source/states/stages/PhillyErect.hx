package states.stages;

import states.stages.objects.PicoDopplegangerSprite;
import states.stages.objects.*;
import objects.Character;
import cutscenes.CutsceneHandler;
import objects.Note;

import shaders.AdjustColorShader;

class PhillyErect extends BaseStage
{
	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:PhillyTrain;
	var curLight:Int = -1;

	//For Philly Glow events
	var blammedLightsBlack:FlxSprite;
	var phillyGlowGradient:PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;
	var phillyWindowEvent:BGSprite;
	var curLightEvent:Int = -1;

	//shaders
	var colorShader = new AdjustColorShader();

	override function create()
	{
		if(!ClientPrefs.data.lowQuality) {
			var bg:BGSprite = new BGSprite('philly/erect/sky', -100, 0, 0.1, 0.1);
			add(bg);
		}

		var city:BGSprite = new BGSprite('philly/erect/city', -10, 0, 0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		add(city);

		phillyLightsColors = [0xFF2663AC, 0xFF329A6D, 0xFF502D64, 0xFF932C28, 0xFFB66F43];
		phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
		phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
		phillyWindow.updateHitbox();
		add(phillyWindow);
		phillyWindow.alpha = 0;

		if(!ClientPrefs.data.lowQuality) {
			var streetBehind:BGSprite = new BGSprite('philly/erect/behindTrain', -40, 50);
			add(streetBehind);
		}

		phillyTrain = new PhillyTrain(2000, 360);
		add(phillyTrain);

		phillyStreet = new BGSprite('philly/erect/street', -40, 50);
		add(phillyStreet);
		if(songName == "pico-(pico-mix)" || songName == "philly-nice-(pico-mix)" || songName == "blammed-(pico-mix)"){
		setStartCallback(ughIntro);
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			case "Philly Glow":
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.data.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				Paths.image('philly/particle'); //precache philly glow particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}
	}

	override function update(elapsed:Float)
	{
		phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
		if(phillyGlowParticles != null)
		{
			var i:Int = phillyGlowParticles.members.length-1;
			while (i > 0)
			{
				var particle = phillyGlowParticles.members[i];
				if(particle.alpha <= 0)
				{
					particle.kill();
					phillyGlowParticles.remove(particle, true);
					particle.destroy();
				}
				--i;
			}
		}
	}

	override function beatHit()
	{
		phillyTrain.beatHit(curBeat);
		if (curBeat % 4 == 0)
		{
			curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
			phillyWindow.color = phillyLightsColors[curLight];
			phillyWindow.alpha = 1;
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Philly Glow":
				if(flValue1 == null || flValue1 <= 0) flValue1 = 0;
				var lightId:Int = Math.round(flValue1);

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.data.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.data.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.data.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.data.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.data.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlowParticle = new PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}
		}
	}

	function doFlash()
	{
		var color:FlxColor = FlxColor.WHITE;
		if(!ClientPrefs.data.flashing) color.alphaFloat = 0.5;

		FlxG.camera.flash(color, 0.15, null, true);
	}

	override function createPost() {
        super.createPost();
        if(!ClientPrefs.data.lowQuality) {
            game.boyfriend.shader = colorShader;
            game.dad.shader = colorShader;
            game.gf.shader = colorShader;
			phillyTrain.shader = colorShader;

            colorShader.brightness.value = [-5];
            colorShader.hue.value = [-26];
            colorShader.contrast.value = [0];
		    colorShader.saturation.value = [-16];
        }
    }
	
	// Cutscenes
	var cutsceneHandler:CutsceneHandler;
	var imposterPico:PicoDopplegangerSprite;
	var pico:PicoDopplegangerSprite;
	var bloodPool:FlxAnimate;
	var cigarette:FlxSprite;
	var audioPlaying:FlxSound;

	var playerShoots:Bool;
	var explode:Bool;
	var seenOutcome:Bool;

	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		boyfriend.visible = dad.visible = false;
		camHUD.visible = false;
		// inCutscene = true; //this would stop the camera movement, oops

		imposterPico = new PicoDopplegangerSprite(dad.x + 82, dad.y + 400);
		imposterPico.showPivot = false;
		imposterPico.antialiasing = ClientPrefs.data.antialiasing;
		cutsceneHandler.push(imposterPico);

		pico = new PicoDopplegangerSprite(boyfriend.x + 48.5, boyfriend.y + 400);
		pico.showPivot = false;
		pico.antialiasing = ClientPrefs.data.antialiasing;
		cutsceneHandler.push(pico);

		bloodPool = new FlxAnimate(0, 0);
		bloodPool.visible = false;
		Paths.loadAnimateAtlas(bloodPool, "philly/erect/cutscenes/bloodPool");

		cigarette = new FlxSprite();
		cigarette.frames = Paths.getSparrowAtlas('philly/erect/cutscenes/cigarette');
		cigarette.animation.addByPrefix('cigarette spit', 'cigarette spit', 24, false);
		cigarette.visible = false;

		cutsceneHandler.finishCallback = function()
		{
			seenCutscene = true;
			//Restore camera
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});

			//Show still alive chars
			if (explode)
				{
					if (playerShoots) boyfriend.visible = true;
					else dad.visible = true;
				}
			else boyfriend.visible = dad.visible = true;
			
			camHUD.visible = true;

			//Crear callbacks
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
	
			if (audioPlaying != null) audioPlaying.stop();
			pico.cancelSounds();
			imposterPico.cancelSounds();
			
			if (explode)
			{
				if(playerShoots){
					if (seenOutcome)
						imposterPico.playAnimation("loopOpponent", true, true, true);
					else
					{
						imposterPico.kill();
						game.remove(imposterPico);
						imposterPico.destroy();
						dad.visible = true;
					}
				}
				else{

					if(seenOutcome){
						pico.playAnimation("loopPlayer", true, true, true);
						endSong();
					}
					else{
						pico.kill();
						game.remove(pico);
						pico.destroy();
						boyfriend.visible = true;
					}
				}
				if(seenOutcome && playerShoots){
					game.camZooming = true;
					#if LEGACY_PSYCH
					game.vocals = new FlxSound();
					switch(songName.toLowerCase()){
						case "blammed-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("blammed_solo"));
						case "pico-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("pico_solo"));
						case "philly-nice-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("philly_solo"));
					}
					#else
					game.opponentVocals = new FlxSound();
					#end
					for (note in (game.unspawnNotes : Array<Note>)) {
						if (!note.mustPress && note.eventName == "")
							{
								note.ignoreNote = true;
							}
					} 
				}
			}
			//Dance!
			dad.dance();
			boyfriend.dance();
			gf.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(camFollow);
			@:privateAccess
			game.moveCameraSection();
			FlxG.camera.scroll.set(camFollow.x - FlxG.width / 2, camFollow.y - FlxG.height / 2);
			FlxG.camera.zoom = defaultCamZoom;
			if(!explode || playerShoots) startCountdown();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			#if !LEGACY_PSYCH cutsceneHandler.finishCallback(); #end
		};
		camFollow_set(dad.x + 280, dad.y + 170);
	}

	function ughIntro()
	{
		prepareCutscene();
		seenOutcome = false;
		// 50/50 chance for who shoots
		if (FlxG.random.bool(50))
		{
			playerShoots = true;
		}
		else
		{
			playerShoots = false;
		}
		if (FlxG.random.bool(8))
		{
			explode = true;
		}
		else
		{
			explode = false;
		}
		cutsceneHandler.endTime = 13;
		cutsceneHandler.music = playerShoots ? 'cutscene/cutscene2' : 'cutscene/cutscene';
		Paths.sound('cutscene/picoCigarette');
		Paths.sound('cutscene/picoExplode');
		Paths.sound('cutscene/picoShoot');
		Paths.sound('cutscene/picoSpin');
		Paths.sound('cutscene/picoCigarette2');
		Paths.sound('cutscene/picoGasp');

		var cigarettePos:Array<Float> = [];
		var shooterPos:Array<Float> = [];
		if (playerShoots == true)
		{
			cigarette.flipX = true;

			addBehindBF(cigarette);
			addBehindBF(bloodPool);
			addBehindBF(imposterPico);
			addBehindBF(pico);

			cigarette.setPosition(boyfriend.x - 143.5, boyfriend.y + 210);
			bloodPool.setPosition(dad.x - 1487, dad.y - 173);

			shooterPos = cameraPos(boyfriend, game.boyfriendCameraOffset);
			cigarettePos = cameraPos(dad, [250, 0]);
		}
		else
		{
			addBehindDad(cigarette);
			addBehindDad(bloodPool);
			addBehindDad(pico);
			addBehindDad(imposterPico);
			bloodPool.setPosition(boyfriend.x - 788.5, boyfriend.y - 173);
			cigarette.setPosition(boyfriend.x - 478.5, boyfriend.y + 205);

			cigarettePos = cameraPos(boyfriend, game.boyfriendCameraOffset);
			shooterPos = cameraPos(dad, [250, 0]);
		}
		var midPoint:Array<Float> = [(shooterPos[0] + cigarettePos[0]) / 2, (shooterPos[1] + cigarettePos[1]) / 2];

		// Allw picos to set their cutscene timers
		imposterPico.doAnim("Opponent", !playerShoots, explode, cutsceneHandler);
		pico.doAnim("Player", playerShoots, explode, cutsceneHandler);

		camFollow_set(midPoint[0], midPoint[1]);

		if (ClientPrefs.data.shaders)
		{
			cutsceneHandler.timer(0.01, () ->
			{
				pico.shader = colorShader;
				imposterPico.shader = colorShader;
				bloodPool.shader = colorShader;
			});
		}

		cutsceneHandler.timer(4, () ->
		{
			camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(6.3, () ->
		{
			camFollow_set(shooterPos[0], shooterPos[1]);
		});

		cutsceneHandler.timer(8.75, () ->
		{
			seenOutcome = true;
			// cutting off skipping here. really dont think its needed after this point and it saves problems from happening
			camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(11.2, () ->
		{
			if (explode == true)
			{
				bloodPool.visible = true;
				bloodPool.anim.play("bloodPool", true);
			}
		});

		cutsceneHandler.timer(11.5, () ->
		{
			if (explode == false)
			{
				cigarette.visible = true;
				cigarette.animation.play('cigarette spit');
			}
		});
	}

	function cameraPos(char:Character, camOffset:Array<Float>)
	{
		var point = new FlxPoint(char.getMidpoint().x - 100, char.getMidpoint().y - 100);
		point.x -= char.cameraPosition[0] - camOffset[0];
		point.y += char.cameraPosition[1] + camOffset[1];
		return [point.x, point.y];
	}
}