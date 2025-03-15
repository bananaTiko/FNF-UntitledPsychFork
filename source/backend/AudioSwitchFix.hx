package backend;

import openfl.media.Sound;
import lime.media.openal.ALC;
import lime.media.AudioManager;
import flixel.sound.FlxSound;

typedef PlayingSound = {
	var sound:FlxSound;
	var path:String;
	var time:Float;
}

// Fix for audio device disconnections and reconnecting audio.
@:access(flixel.sound.FlxSound)
class AudioSwitchFix {
	
	private static var prevDevice:String = null; // Store previous device
	public static var currentAudioDevice:String;
	
	// Checks for a change in the audio device and reconnects if needed.
	public static function checkForDisconnect():Void {
		currentAudioDevice = ALC.getString(null, 0x1013);
		if (prevDevice != null && prevDevice != currentAudioDevice) {
			reconnect();
			trace('Audio reconnected: ' + getParsedAudioDevice(currentAudioDevice));
		}
		prevDevice = currentAudioDevice;
	}
	
	// Extracts device name from a device string.
	public static function getParsedAudioDevice(device:String):String {
		var start = device.indexOf('(') + 1;
		var end = device.lastIndexOf(')');
		return (start > 0 && end > start) ? device.substring(start, end) : device;
	}
	
	// Stops all playing sounds and returns a list of them.
	public static function stopPlayingSounds():Array<PlayingSound> {
		var playingList:Array<PlayingSound> = [];
		var soundPathMap:Map<Sound, String> = [];
		for (key => sound in Paths.currentTrackedSounds)
			soundPathMap.set(sound, key);
		var soundList = FlxG.sound.list.members.copy();
		soundList.push(FlxG.sound.music);
		for (e in soundList) {
			if (e.playing) {
				playingList.push({
					sound: e,
					path: soundPathMap.get(e._sound),
					time: e.time
				});
				e.stop();
			}
		}
		return playingList;
	}
	
	// Dumps all tracked sound assets and clears the tracking map.
	public static function dumpTrackedAssets():Void {
		for (key in Paths.currentTrackedSounds.keys())
			Paths.dumpAsset(key);
		Paths.currentTrackedSounds.clear();
	}
	
	// Reinitializes the audio manager.
	public static function reinitializeAudioManager():Void {
		AudioManager.shutdown();
		AudioManager.init();
	}
	
	// Restores playing sounds from the provided list.
	public static function restorePlayingSounds(playingList:Array<PlayingSound>):Void {
		for (soundInfo in playingList) {
			soundInfo.sound.loadEmbedded(Paths.soundAbsolute(soundInfo.path));
			soundInfo.sound.play(soundInfo.time);
		}
	}
	
	// Reconnects audio by stopping sounds, dumping assets, reinitializing, and restoring sounds.
	public static function reconnect():Void {
		var playingList = stopPlayingSounds();
		dumpTrackedAssets();
		reinitializeAudioManager();
		// Force reloading of sounds if needed
		for (key in Paths.currentTrackedSounds.keys())
			Paths.soundAbsolute(key);
		restorePlayingSounds(playingList);
	}
}
