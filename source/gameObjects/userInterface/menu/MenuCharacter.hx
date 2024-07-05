package gameObjects.userInterface.menu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	var curCharacterMap:Map<String, Array<Dynamic>> = [
		// name of character => anim, fps, loop, scale, offsetx, offsety
		'mari' => ["el pepe", 24, false, 0.5, 15, -65],
		'doug' => ["Brown_Idle", 24, false, 0.5, 50, 30],
		'cesar' => ["CesarGpe_Idle", 24, false, 0.5, 10, -110],
		'bule' => ["bs32_use_idle", 24, false, 0.5, 50, -10],
		'tsuyar' => ["TsuyAr_Idle", 24, false, 0.5, 80, -75]
	];

	public var character:String = '';
	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, y:Float, newCharacter:String = 'bf')
	{
		super(x, y);

		baseX = x;
		baseY = y;

		createCharacter(newCharacter);
		updateHitbox();
	}

	public function createCharacter(newCharacter:String)
	{
		if (newCharacter == '')
			frames = Paths.getSparrowAtlas('characters/blank');
		else
			frames = Paths.getSparrowAtlas('menus/storymenu/chars/' + newCharacter);

		var assortedValues = curCharacterMap.get(newCharacter);
		if (assortedValues != null)
		{
			if (!visible)
				visible = true;

			if (newCharacter == 'mari')
			{
				animation.addByIndices('danceLeft', 'Mari_Idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Mari_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			}
			else
			{
				animation.addByPrefix('bop', assortedValues[0], assortedValues[1], assortedValues[2]);
				animation.play('bop');
			}

			setGraphicSize(Std.int(width * assortedValues[3]));
			updateHitbox();

			setPosition(baseX + assortedValues[4], baseY + assortedValues[5]);
			antialiasing = true;
			alpha = 0.5;
		}
		else
			visible = false;

		character = newCharacter;
	}

	var danced:Bool = false;
	public function dance(?forced:Bool = false)
	{
		switch(character)
		{
			case 'mari':
				danced = !danced;
				if (danced)
					animation.play('danceLeft', true);
				else
					animation.play('danceRight', true);
			default:
				animation.play('bop', true);
		}
	}
}
