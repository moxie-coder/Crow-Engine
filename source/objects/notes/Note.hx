package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import backend.NoteStorageFunction;
import objects.notes.NoteFile;
import sys.FileSystem;
import openfl.Assets;
import haxe.Json;

using StringTools;

@:allow(states.PlayState)
class Note extends FlxSprite
{
	public static var earlyMult:Float = 0.5;

	public static var currentSkin:String = 'NOTE_assets';

	public static var transformedWidth:Float = 160 * 0.7;

	public override function new(strumTime:Float = 0, direction:Int = 0, mustPress:Bool = false, sustainIndex:Float = 0, sustainLength:Float = 0,
			singAnim:String = '')
	{
		super();

		this.strumTime = strumTime;
		this.direction = direction;
		this.mustPress = mustPress;
		this.isSustainNote = sustainIndex > 0;

		if (_noteFile == null)
		{
			var path = Paths.image('game/ui/$currentSkin').replace('png', 'json');

			if (!FileSystem.exists(path))
			{
				path = path.replace(currentSkin, 'NOTE_assets');
				FlxG.log.error('Couldn\'t find $currentSkin in "game/ui/$currentSkin"!');
			}

			_noteFile = Json.parse(Assets.getText(path));
		}

		frames = Paths.getSparrowAtlas('game/ui/$currentSkin');

		for (animData in _noteFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			animOffsets.set(animData.name, new FlxPoint(animData.offset.x, animData.offset.y));
			animForces.set(animData.name, animData.looped);
		}

		var animPlay:String = _noteFile.animDirections[direction];
		if (isSustainNote)
		{
			if (sustainIndex == sustainLength)
			{
				animPlay = _noteFile.sustainAnimDirections[direction].end;
				isEndNote = true;
			}
			else
				animPlay = _noteFile.sustainAnimDirections[direction].body;
		}

		animation.play(animPlay, true);
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	public var noteType:String = '';
	public var singAnim:String = '';

	public var direction:Int = 0;
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;

	private var _lockedScaleY:Bool = true;
	private var _lockedToStrumX:Bool = true;
	private var _lockedToStrumY:Bool = true; // if you disable this, the notes won't ever go, if you want a modchart controlling notes, here u go

	private var animOffsets:Map<String, FlxPoint> = [];
	private var animForces:Map<String, Bool> = [];

	private static var _noteFile:NoteFile;

	// public var strumOwner:Int = 0; // enemy = 0, player = 1, useful if you wanna make a pasta night / bonedoggle gimmick thing
	public var canBeHit(get, null):Bool;
	public var tooLate(get, null):Bool;
	public var wasGoodHit(get, null):Bool;

	private function get_canBeHit():Bool
	{
		return (strumTime > Conductor.songPosition - NoteStorageFunction.safeZoneOffset
			&& strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult));
	}

	private function get_tooLate():Bool
	{
		return (strumTime < Conductor.songPosition - NoteStorageFunction.safeZoneOffset && !wasGoodHit);
	}

	private function get_wasGoodHit():Bool
	{
		return ((strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult))
			&& (/*(isSustainNote && prevNote.wasGoodHit) ||*/ strumTime <= Conductor.songPosition));
	}
}
