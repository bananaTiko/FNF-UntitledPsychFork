package states.stages;

// import states.stages.ABotSpeakerFunctions;
import objects.Note;
import objects.Character;
import shaders.AdjustColorShader;
import shaders.RainShader;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

//I now realize how shitty my stage coding really is, especially in haxe oml

class SpookyMansion extends BaseStage {
	var bg:BGSprite;
	var bgLight:BGSprite;
	var stairsDark:BGSprite;
	var stairsLight:BGSprite;
	var bgTrees:FlxSprite;

	var bfClone:Character;
	var gfClone:Character;
	var dadClone:Character;

	//var rain:Rain;
    //var rainShader = new RainShader();
	var shader:RainShader;
    var solid:FlxSprite;

	var nene:ABotSpeakerFunctions;
	public function new(nene:ABotSpeakerFunctions) {
		super();
		this.nene = nene;
	}

	override function create()
	{

        solid = new FlxSprite().makeGraphic(2400,2000,0xFF242336);

        var bgTrees = new FlxSprite(200, 50);
        bgTrees.frames = Paths.getSparrowAtlas('erect/bgtrees');
        bgTrees.animation.addByPrefix('idle', 'bgtrees', 5, true);
        bgTrees.scrollFactor.set(0.8, 0.8);
        bgTrees.scale.set(1, 1);
        bgTrees.animation.play('idle');

        var bgDark:BGSprite = new BGSprite('erect/bgDark', -360, -220, 1, 1);
		bgDark.scale.set(1, 1);
        //bgDark.updateHitbox();
		bgDark.alpha = 1;

        bgLight = new BGSprite('erect/bgLight', -360, -220, 1, 1);
		bgLight.scale.set(1, 1);
		bgLight.alpha = 0;

        stairsDark = new BGSprite('erect/stairsDark', 966, -225, 1, 1);
		stairsDark.scale.set(1, 1);
		stairsDark.alpha = 1;

        stairsLight = new BGSprite('erect/stairsLight', 966, -225, 1, 1);
		stairsLight.scale.set(1, 1);
		stairsLight.alpha = 0;

        insert(0, solid); 
        insert(11, bgTrees); 
        insert(10, bgDark); 
        insert(9, bgLight);
	}

    override function createPost() {
        super.createPost();

		// if(ClientPrefs.data.shaders){
		// 	shader = new shaders.RainShader();
		// 	shader.scale = FlxG.height / 200 * 2;
		// 	shader.intensity = 0.4;
		// 	shader.spriteMode = true;
		// 	bgTrees.shader = shader;
		// }

        if(!ClientPrefs.data.lowQuality) makeChars();
            //code
			insert(members.indexOf(game.boyfriendGroup)+1, stairsDark); 
        	insert(members.indexOf(game.boyfriendGroup)+2, stairsLight);
}
    var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var danced:Bool = false;
	override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality) return;
		if(curBeat == 4 && songName == "spookeez-erect") lightningStrikeShit(false); 
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		if (curBeat % game.boyfriend.danceEveryNumBeats == 0 && !StringTools.startsWith(boyfriend.getAnimationName(),'sing') && !game.boyfriend.stunned)
			bfClone.dance();
		if (curBeat % game.dad.danceEveryNumBeats == 0 && !StringTools.startsWith(dad.getAnimationName(),'sing') && !game.dad.stunned)
			dadClone.dance();
		if (curBeat % game.gf.danceEveryNumBeats == 0 && !StringTools.startsWith(gf.getAnimationName(),'sing') && !game.gf.stunned)
			gfClone.dance();
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {		
		switch (eventName){
			case "Play Animation":{
				var char:Character = dadClone;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = bfClone;
					case 'gf' | 'girlfriend':
						char = gfClone;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}
			}
		}
	}

	function lightningStrikeShit(playSound:Bool = true):Void
    {
		if(playSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

        lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		//stage and character alpha shit
		game.dad.alpha = 0;
		game.gf.alpha = 0;
		game.boyfriend.alpha = 0;

		bfClone.alpha = 1;
		gfClone.alpha = 1;
		dadClone.alpha = 1;

		bgLight.alpha = 1;
		stairsLight.alpha = 1;

		new FlxTimer().start(0.06, (tmr) -> {
			game.dad.alpha = 1;
			game.gf.alpha = 1;
			game.boyfriend.alpha = 1;

			bfClone.alpha = 0;
			gfClone.alpha = 0;
			dadClone.alpha = 0;

			bgLight.alpha = 0;
			stairsLight.alpha = 0;
		});

		new FlxTimer().start(0.12, (tmrt) -> {
			nene.ABot_plink();
			game.dad.alpha = 0;
			game.gf.alpha = 0;
			game.boyfriend.alpha = 0;

			bfClone.alpha = 1;
			gfClone.alpha = 1;
			dadClone.alpha = 1;

			bgLight.alpha = 1;
			stairsLight.alpha = 1;

			FlxTween.tween(bgLight, {alpha: 0}, 1.5);
			FlxTween.tween(stairsLight, {alpha: 0}, 1.5);
			FlxTween.tween(bfClone, {alpha: 0}, 1.5);
			FlxTween.tween(gfClone, {alpha: 0}, 1.5);
			FlxTween.tween(dadClone, {alpha: 0}, 1.5);
			FlxTween.tween(game.boyfriend, {alpha: 1}, 1.5);
			FlxTween.tween(game.gf, {alpha: 1}, 1.5);
			FlxTween.tween(game.dad, {alpha: 1}, 1.5);
		});
		//

        if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(dad.animOffsets.exists('scared')) {
			dad.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

        if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}
    }
	override function goodNoteHit(note:Note) {
        var anims = ["singLEFT","singDOWN","singUP","singRIGHT"];
		bfClone?.playAnim(anims[note.noteData],true);
		super.goodNoteHit(note);
    }
    override function noteMiss(note:Note) {
        var anims = ["singLEFT","singDOWN","singUP","singRIGHT"];
		bfClone?.playAnim(anims[note.noteData]+"miss",true);
		super.noteMiss(note);
    }
    override function opponentNoteHit(note:Note) {
        var anims = ["singLEFT","singDOWN","singUP","singRIGHT"];
		dadClone?.playAnim(anims[note.noteData],true);
	}
	function makeChars()
		{
			
			var bfName = PlayState.instance.boyfriend.curCharacter.split("-")[0];
			if(bfName == "pico") bfName = "pico-playable";

			var gfMode = PlayState.instance.gf.curCharacter.split("-")[0];

			// var dadName = PlayState.instance.dad.curCharacter.split("-")[0];

			gfClone = new Character(game.gf.x, game.gf.y, gfMode, false);
			//if (gfMode == 'nene')
			//gfGhost.y -= 190;
			game.add(gfClone);
			gfClone.dance();

			bfClone = new Character(game.boyfriend.x, game.boyfriend.y, bfName, true);
			game.add(bfClone);
			bfClone.dance();

			dadClone = new Character(game.dad.x, game.dad.y, 'spooky', true);
			game.add(dadClone);
			dadClone.dance();

			bfClone.alpha = 0;
			gfClone.alpha = 0;
			dadClone.alpha = 0;
    }
}