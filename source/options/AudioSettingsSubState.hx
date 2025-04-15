package options;

import objects.Alphabet;


class AudioSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('audio_menu', 'Audio Settings');
		rpcTitle = 'Changing Audio Settings'; //for Discord Rich Presence
		var PM:Array<String> = Mods.mergeAllTextsNamed('music/PM_list.txt');
		if(PM.length > 0)
		{
			if(!PM.contains(ClientPrefs.data.pauseMusic))
				ClientPrefs.data.pauseMusic = ClientPrefs.defaultData.pauseMusic;
		}
		var option:Option = new Option('Pause Music:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			STRING,
			PM);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var TM:Array<String> = Mods.mergeAllTextsNamed('music/Menu_list.txt');
		if(TM.length > 0)
		{
			if(!TM.contains(ClientPrefs.data.daMenuMusic))
				ClientPrefs.data.daMenuMusic = ClientPrefs.defaultData.daMenuMusic;
		}
		var option:Option = new Option('Menu Music:',
			"What song do you prefer for the Menus?",
			'daMenuMusic',
			STRING,
			TM);
		addOption(option);
		option.onChange = onChangeMenuMusic;

    		var option:Option = new Option('Opponent Hitsound Volume',
			'Funny notes make a sound when the Opponents hit them.',
			'opphitsoundVolume',
			PERCENT);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeOppHitsoundVolume;

		var opphitSounds:Array<String> = Mods.mergeAllTextsNamed('sounds/hitsounds/list.txt');
		if(opphitSounds.length > 0)
		{
			if(!opphitSounds.contains(ClientPrefs.data.oppHitsoundType))
				ClientPrefs.data.oppHitsoundType = ClientPrefs.defaultData.oppHitsoundType;
		}
		var option:Option = new Option(Language.getPhrase('setting_dad_note',"Opponent Hitsound Type:"), 
			"Change the Opponents hitsound type",
			'oppHitsoundType',
			STRING,
			opphitSounds);
		addOption(option);
		option.onChange = onChangeOppHitSound;

		var option:Option = new Option('Player Hitsound Volume',
			'Funny notes make a sound when you hit them.',
			'hitsoundVolume',
			PERCENT);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;
    
		var pphitSounds:Array<String> = Mods.mergeAllTextsNamed('sounds/hitsounds/list.txt');
		if(pphitSounds.length > 0)
		{
			if(!pphitSounds.contains(ClientPrefs.data.hitsoundType))
				ClientPrefs.data.hitsoundType = ClientPrefs.defaultData.hitsoundType;
		var option:Option = new Option(Language.getPhrase('setting_player_note', "Player Hitsound Type:"), 
			"Change the Players hitsound type",
			'hitsoundType',
			STRING,
			pphitSounds);
		addOption(option);
		option.onChange = onChangeHitSound;
		}
  }

  var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
			splash.animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
			}
		}

	var menuMusicChanged:Bool = false;
	function onChangeMenuMusic()
	{
			if (ClientPrefs.data.daMenuMusic != 'Default') FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic));
			if (ClientPrefs.data.daMenuMusic == 'Default') FlxG.sound.playMusic(Paths.music('freakyMenu'));
		menuMusicChanged = true;
	}

	function onChangeHitSound()
	{
		FlxG.sound.play(Paths.sound("hitsounds/" + "hitsound-" + ClientPrefs.data.hitsoundType), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeOppHitSound()
	{
		FlxG.sound.play(Paths.sound("hitsounds/" + "hitsound-" + ClientPrefs.data.oppHitsoundType), ClientPrefs.data.opphitsoundVolume);
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound("hitsounds/" + "hitsound-" + ClientPrefs.data.hitsoundType), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeOppHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound("hitsounds/" + "hitsound-" + ClientPrefs.data.oppHitsoundType), ClientPrefs.data.opphitsoundVolume);
  }

	override function destroy()
	{
		if (!OptionsState.onPlayState && (changedMusic || menuMusicChanged)) FlxG.sound.playMusic(Paths.music('Options'));
		// if(changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.data.daMenuMusic), 1, true);
		// else if (!OptionsState.onPlayState && (changedMusic || menuMusicChanged)) FlxG.sound.playMusic(Paths.music('Options'));
		super.destroy();
	}
  }
