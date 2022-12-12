package music;

import flixel.math.FlxMath;
import openfl.utils.Assets;
import haxe.Json;
import music.Section.SectionInfo;
import weeks.SongHandler;

using StringTools;
using utils.Tools;

class Song
{
	public static var currentSong:SongInfo;

	public static function loadSong(song:String, diff:Int = 2):SongInfo
	{
		var diffString:String = SongHandler.PLACEHOLDER_DIFF[Std.int(FlxMath.bound(diff, 0, 2))];

		try
		{
			var fixData:String->String = function(str:String)
			{
				while (!str.endsWith("}"))
				{
					str = str.substr(0, str.length - 1);
				}

				return str;
			};

			var path = Paths.data('charts/' + song.toLowerCase().replace(' ', '-') + '/' + song.toLowerCase().replace(' ', '-') + '-'
				+ diffString.toLowerCase());
			trace(path);

			currentSong = backend.compat.ChartConvert.convertType('base', Assets.getText(path));

			return currentSong;
		}
		catch (e)
		{
			throw 'Couldn\'t load song $song with difficulty $diffString (${Paths.data('charts/' + song.toLowerCase().replace(' ', '-') + '/' + song.toLowerCase().replace(' ', '-') + '-' + diffString.toLowerCase())})';
		}

		return {
			song: song,
			sectionList: [
				{
					notes: [],
					length: 16,
				}
			],
			speed: 1.0,
			mustHitSections: [],
			bpmMapping: [],
			bpm: 100,
			player: 'bf',
			opponent: 'dad',
			spectator: 'gf',
			extraData: []
		};
	}
}

typedef SongInfo =
{
	var song:String;
	var sectionList:Array<SectionInfo>;
	var mustHitSections:Array<Null<Bool>>;
	var bpmMapping:Array<{step:Int, bpm:Float}>;
	var bpm:Float;
	var speed:Float;

	@:optional var extraData:Map<String, Dynamic>;
	var player:String;
	var opponent:String;
	var spectator:String; // fancy term for gf
}
