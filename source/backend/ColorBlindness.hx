package backend;

import backend.ClientPrefs;
import openfl.filters.ColorMatrixFilter;

@:access(flixel.FlxGame)
class ColorBlindness extends ColorMatrixFilter
{
	public var filterEnabled:Bool = true;

	public function new(type:String)
	{
		filterEnabled = type.toUpperCase() != "NONE";

		if (!filterEnabled)
			return;

		var filter:Array<Float> = [];
		switch (type.toUpperCase())
		{
			// Color Blindness Types
			case "DEUTERANOPIA":
				filter = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];
			case "PROTANOPIA":
				filter = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];
			case "TRITANOPIA":
				filter = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];
			case "PROTANOMALY":
				filter = [
					0.817, 0.183, 0, 0, 0,
					0.333, 0.667, 0, 0, 0,
					0, 0.125, 0.875, 0, 0,
					   0, 0, 0, 1, 0,
				];
			case "TRITANOMALY":
				filter = [
					0.967, 0.033, 0, 0, 0,
					0, 0.733, 0.267, 0, 0,
					0, 0.183, 0.817, 0, 0,
					   0, 0, 0, 1, 0,
				];
			case "ACHROMATOPSIA":
				filter = [
					0.299, 0.587, 0.114, 0, 0,
					0.299, 0.587, 0.114, 0, 0,
					0.299, 0.587, 0.114, 0, 0,
					   0,    0,    0, 1, 0,
				];
			case "MONOCHROMACY":
				filter = [
					0.333, 0.333, 0.333, 0, 0,
					0.333, 0.333, 0.333, 0, 0,
					0.333, 0.333, 0.333, 0, 0,
					   0,    0,    0, 1, 0,
				];
			default:
		}

		super(filter);
	}

	public static function setFilter()
	{
		if (FlxG.game._filters == null)
			FlxG.game._filters = [];

		if (FlxG.game._filters.contains(Main.daColorFilter))
			FlxG.game._filters.remove(Main.daColorFilter);

		Main.daColorFilter = new ColorBlindness(ClientPrefs.data.daColorFilter);
		if (ClientPrefs.data.daColorFilter != "NONE")
		{
			FlxG.game._filters.push(Main.daColorFilter);
		}
		/*else
		{
			FlxG.game.setFilters([]);
		}*/
	}
}
