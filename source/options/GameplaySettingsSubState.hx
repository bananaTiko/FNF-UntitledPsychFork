package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('gameplay_menu', 'Gameplay Settings');
		rpcTitle = 'Changing Gameplay Settings'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			BOOL);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			BOOL);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			BOOL);
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
			"If checked, the game automatically pauses if the screen isn't on focus.",
			'autoPause',
			BOOL);
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			BOOL);
		addOption(option);

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

		var option:Option = new Option(Language.getPhrase('setting_combo', "Combo Sprite:"),
		'Do you want the combo sprite to be shown?',
		'comboSprite',
		BOOL);
		addOption(option);

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Epic! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Epic!" in milliseconds.',
			'epicWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 1.0;
		option.maxValue = 15.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15.0;
		option.maxValue = 45.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15.0;
		option.maxValue = 135.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			FLOAT);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Sustains as One Note',
			"If checked, Hold Notes can't be pressed if you miss,\nand count as a single Hit/Miss.\nUncheck this if you prefer the old Input System.",
			'guitarHeroSustains',
			BOOL);
		addOption(option);

		super();
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

	function onChangeAutoPause()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}
}