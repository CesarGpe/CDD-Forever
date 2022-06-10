package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef CharacterData = {
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var quickDancer:Bool;
}

class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var iconColor:FlxColor;
	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public function new(?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		var tex:FlxAtlasFrames;
		antialiasing = true;

		characterData = {
			offsetY: 0,
			offsetX: 0, 
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false
		};

		switch (curCharacter)
		{
			case 'bf':
				iconColor = FlxColor.fromRGB(49, 176, 209);
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

				characterData.offsetY = 70;

			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/BF_DEATH');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

			case 'bf-pixel':
				iconColor = FlxColor.fromRGB(49, 176, 209);
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

				characterData.offsetY = 180;

			/*
			=========================================
				PERSONAJES DE CAMARA DE DIPUTADOS
			=========================================
			*/
			case 'mari':
				// añade a la mari :o
				iconColor = FlxColor.fromRGB(102, 204, 153);
				frames = Paths.getSparrowAtlas('characters/mari');
				animation.addByPrefix('cheer', 'Mari_Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'Mari_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Mari_Right', 24, false);
				animation.addByPrefix('singUP', 'Mari_Up', 24, false);
				animation.addByPrefix('singDOWN', 'Mari_Down', 24, false);
				animation.addByIndices('sad', 'Mari_Sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'Mari_Idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Mari_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "Mari_HairBlowLeft", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "Mari_HairLand", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'Mari_Scared', 24);

				playAnim('danceRight');
				
			case 'mariCave':
				// mari en el carrito chistosito
				iconColor = FlxColor.fromRGB(102, 204, 153);
				frames = Paths.getSparrowAtlas('characters/mariCave');
				animation.addByIndices('danceLeft', 'Mari_HairBlowLeft', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Mari_HairBlowLeft', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');
				
			case 'reimu':
				iconColor = FlxColor.fromRGB(255, 0, 135);
				// LA REIMU HAKUREI DEL PROYECTO TOUHOU
				frames = Paths.getSparrowAtlas('characters/Reimu_Assets');
				animation.addByPrefix('cheer', 'Reimu_Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'Reimu_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Reimu_Right', 24, false);
				animation.addByPrefix('singUP', 'Reimu_Up', 24, false);
				animation.addByPrefix('singDOWN', 'Reimu_Down', 24, false);
				animation.addByIndices('sad', 'Reimu_Sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'Reimu_Idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Reimu_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "Reimu_HairBlowLeft", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "Reimu_HairLand", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'Reimu_Scared', 24);
				
				playAnim('danceRight');
				
			case '2ndplayer':
				// la calaca mas chida
				iconColor = FlxColor.fromRGB(255, 204, 255);
				frames = Paths.getSparrowAtlas('characters/2nd_player');
				animation.addByPrefix('danceLeft', 'Isaac_IdleLeft', 24, false);
				animation.addByPrefix('danceRight', 'Isaac_IdleRight', 24, false);
				animation.addByPrefix('singUP', 'Isaac_Up', 24);
				animation.addByPrefix('singRIGHT', 'Isaac_Right', 24);
				animation.addByPrefix('singDOWN', 'Isaac_Down', 24);
				animation.addByPrefix('singLEFT', 'Isaac_Left', 24);
				animation.addByPrefix('trabar', 'Isaac_Lag', 24, true);
				characterData.quickDancer = true;

				playAnim('danceRight');

			case 'BrownishSea':
				// doug
				iconColor = FlxColor.fromRGB(255, 102, 255);
				frames = Paths.getSparrowAtlas('characters/BrownishSea_Assets');
				animation.addByPrefix('idle', 'Brown_Idle', 24, false);
				animation.addByPrefix('singUP', 'Brown_Up', 24);
				animation.addByPrefix('singRIGHT', 'Brown_Right', 24);
				animation.addByPrefix('singDOWN', 'Brown_Down', 24);
				animation.addByPrefix('singLEFT', 'Brown_Left', 24);

				playAnim('idle');

			case 'cesar':
				// yo el cesar
				iconColor = FlxColor.fromRGB(176, 11, 105);
				frames = Paths.getSparrowAtlas('characters/Cesar_Assets');
				animation.addByPrefix('idle', 'CesarGpe_Idle', 24, false);
				animation.addByPrefix('singUP', 'CesarGpe_Up', 24);
				animation.addByPrefix('singRIGHT', 'CesarGpe_Right', 24);
				animation.addByPrefix('singDOWN', 'CesarGpe_Down', 24);
				animation.addByPrefix('singLEFT', 'CesarGpe_Left', 24);
				animation.addByPrefix('tired', 'CesarGpe_TiredPig', 24);
				animation.addByPrefix('still', 'CesarGpe_StillPig', 24, true);

				playAnim('idle');

			case 'cesarito':
				// solo esta para el icono, no hay otro personaje
				iconColor = FlxColor.fromRGB(153, 0, 0);
				frames = Paths.getSparrowAtlas('characters/Cesar_Assets');
				animation.addByPrefix('idle', 'CesarGpe_Idle', 24, false);
				animation.addByPrefix('singUP', 'CesarGpe_Up', 24);
				animation.addByPrefix('singRIGHT', 'CesarGpe_Right', 24);
				animation.addByPrefix('singDOWN', 'CesarGpe_Down', 24);
				animation.addByPrefix('singLEFT', 'CesarGpe_Left', 24);

				playAnim('idle');

			case 'hyperpig':
				// terrence god potioneado
				iconColor = FlxColor.fromRGB(255, 102, 153);
				frames = Paths.getSparrowAtlas('characters/HyperPig_Assets');
				animation.addByPrefix('idle', 'HyperPig_Idle', 24, false);
				animation.addByPrefix('singUP', 'HyperPig_Up', 24);
				animation.addByPrefix('singRIGHT', 'HyperPig_Right', 24);
				animation.addByPrefix('singDOWN', 'HyperPig_Down', 24);
				animation.addByPrefix('singLEFT', 'HyperPig_Left', 24);

				playAnim('idle');

			case 'blueslime32':
				// buleslamamenominomanemanominumio
				iconColor = FlxColor.fromRGB(146, 113, 79);
				frames = Paths.getSparrowAtlas('characters/blueslime32');
				animation.addByPrefix('idle', 'bs32_use_idle', 24, false);
				animation.addByPrefix('singUP', 'bs32_use_up', 24);
				animation.addByPrefix('singRIGHT', 'bs32_use_right', 24);
				animation.addByPrefix('singDOWN', 'bs32_use_down', 24);
				animation.addByPrefix('singLEFT', 'bs32_use_left', 24);

				playAnim('idle');

			case 'blueslime32minecart':
				// el eslamio pero en carrito
				iconColor = FlxColor.fromRGB(146, 113, 79);
				frames = Paths.getSparrowAtlas('characters/blueslime32minecart');
				animation.addByPrefix('idle', 'bs32_use_idle', 24, false);
				animation.addByPrefix('singUP', 'bs32_use_up', 24);
				animation.addByPrefix('singRIGHT', 'bs32_use_right', 24);
				animation.addByPrefix('singDOWN', 'bs32_use_down', 24);
				animation.addByPrefix('singLEFT', 'bs32_use_left', 24);

				playAnim('idle');

			case 'bfMinecart':
				// el niño pero en el carrito
				iconColor = FlxColor.fromRGB(49, 176, 209);
				frames = Paths.getSparrowAtlas('characters/bfMinecart');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BFM_Up', 24, false);
				animation.addByPrefix('singLEFT', 'BFM_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'BFM_Right', 24, false);
				animation.addByPrefix('singDOWN', 'BFM_Down', 24, false);
				animation.addByPrefix('singUPmiss', 'BFM_Pendejo', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BFM_Estupido', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BFM_Burro', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BFM_Cabezon', 24, false);
				playAnim('idle');

				flipX = true;

				characterData.offsetY = 70;

			case 'TsuyAr-1':
				// tysauayer
				iconColor = FlxColor.fromRGB(180, 40, 40);
				frames = Paths.getSparrowAtlas('characters/TsuyAr-1');
				animation.addByPrefix('idle', 'TsuyAr_Idle', 24, false);
				animation.addByPrefix('singUP', 'TsuyAr_Up', 24);
				animation.addByPrefix('singRIGHT', 'TsuyAr_Right', 24);
				animation.addByPrefix('singDOWN', 'TsuyAr_Down', 24);
				animation.addByPrefix('singLEFT', 'TsuyAr_Left', 24);

				playAnim('idle');

			case 'TsuyAr-2':
				// tusayr poquito enfadado
				iconColor = FlxColor.fromRGB(220, 40, 40);
				frames = Paths.getSparrowAtlas('characters/TsuyAr-2');
				animation.addByPrefix('idle', 'aTsuyAr_Idle', 24, false);
				animation.addByPrefix('singUP', 'aTsuyAr_Up', 24);
				animation.addByPrefix('singRIGHT', 'aTsuyAr_Right', 24);
				animation.addByPrefix('singDOWN', 'aTsuyAr_Down', 24);
				animation.addByPrefix('singLEFT', 'aTsuyAr_Left', 24);

				playAnim('idle');

			case 'TsuyAr-3':
				// tsauayr requete recontra bien emputado
				iconColor = FlxColor.fromRGB(255, 40, 40);
				frames = Paths.getSparrowAtlas('characters/TsuyAr-3');
				animation.addByPrefix('idle', 'eTsuyAr_Idle', 24, false);
				animation.addByPrefix('singUP', 'eTsuyAr_Up', 24);
				animation.addByPrefix('singRIGHT', 'eTsuyAr_Right', 24);
				animation.addByPrefix('singDOWN', 'eTsuyAr_Down', 24);
				animation.addByPrefix('singLEFT', 'eTsuyAr_Left', 24);

				playAnim('idle');

			case 'juan':
				// el juan papotas numero teintacuato
				iconColor = FlxColor.fromRGB(115, 0, 60);
				frames = Paths.getSparrowAtlas('characters/juan');
				animation.addByPrefix('idle', 'JP_Idle', 24, false);
				animation.addByPrefix('singUP', 'JP_Up', 24);
				animation.addByPrefix('singRIGHT', 'JP_Right', 24);
				animation.addByPrefix('singDOWN', 'JP_Down', 24);
				animation.addByPrefix('singLEFT', 'JP_Left', 24);

				playAnim('idle');
				
			default:
				// set up animations if they aren't already

				// fyi if you're reading this this isn't meant to be well made, it's kind of an afterthought I wanted to mess with and
				// I'm probably not gonna clean it up and make it an actual feature of the engine I just wanted to play other people's mods but not add their files to
				// the engine because that'd be stealing assets
				var fileNew = curCharacter + 'Anims';
				if (OpenFlAssets.exists(Paths.offsetTxt(fileNew)))
				{
					var characterAnims:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(fileNew));
					var characterName:String = characterAnims[0].trim();
					frames = Paths.getSparrowAtlas('characters/$characterName');
					for (i in 1...characterAnims.length)
					{
						var getterArray:Array<Array<String>> = CoolUtil.getAnimsFromTxt(Paths.offsetTxt(fileNew));
						animation.addByPrefix(getterArray[i][0], getterArray[i][1].trim(), 24, false);
					}
				}
				else 
					return setCharacter(x, y, 'bf'); 					
		}

		// set up offsets cus why not
		if (OpenFlAssets.exists(Paths.offsetTxt(curCharacter + 'Offsets')))
		{
			var characterOffsets:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(curCharacter + 'Offsets'));
			for (i in 0...characterOffsets.length)
			{
				var getterArray:Array<Array<String>> = CoolUtil.getOffsetsFromTxt(Paths.offsetTxt(curCharacter + 'Offsets'));
				addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}

		dance();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf'))
			flipLeftRight();

		if (adjustPos) {
			x += characterData.offsetX;
			trace('character ${curCharacter} scale ${scale.y}');
			y += (characterData.offsetY - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;
		
		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		switch (curCharSimplified)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
		}

		// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
		if (animation.curAnim.finished && animation.curAnim.name == 'idle')
		{
			// We look for an animation called 'idlePost' to switch to
			if (animation.getByName('idlePost') != null)
				// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play('idlePost', true, false, 0);
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
						danced = !danced;
						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
					else
						playAnim('idle', forced);
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}
}
