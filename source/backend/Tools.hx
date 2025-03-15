package backend;

import backend.ClientPrefs;

class Tools {
public static function framerateAdjust(input:Float)
    {
        return input * (ClientPrefs.data.framerate / FlxG.stage.window.frameRate);
    }
}