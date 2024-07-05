package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.util.FlxColor;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
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
				// el niño de fridi night fuki
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

				playAnim('idle');

				flipX = true;

				characterData.offsetY = 70;

			case 'bf-dead':
				// jaja se murio que pendejo
				frames = Paths.getSparrowAtlas('characters/BF_DEATH');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;
			
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

			case 'bfMinecartDead':
				// ay no que menso se volvio a morir
				frames = Paths.getSparrowAtlas('characters/bfMinecart');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

				characterData.offsetX = 100;
				characterData.offsetY = 70;

			case 'bfTemper':
				// pinche boifren con una gota de sudor no mames
				iconColor = FlxColor.fromRGB(49, 176, 209);
				frames = Paths.getSparrowAtlas('characters/bfTemper');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('muted', 'BF idle shaking', 48, true);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				playAnim('idle');

				flipX = true;

				characterData.offsetX = 30;
				characterData.offsetY = -10;

			case 'bfTemperDeath':
				// no se puede estar mas pendejo
				frames = Paths.getSparrowAtlas('characters/bfTemper');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

				characterData.offsetY = 130;

			case 'mari':
				// añade a la mari :o
				iconColor = FlxColor.fromRGB(102, 204, 153);
				frames = Paths.getSparrowAtlas('characters/mari');
				animation.addByIndices('danceLeft', 'Mari_Idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Mari_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');
				
			case 'mariCave':
				// mari en el carrito chistosito
				iconColor = FlxColor.fromRGB(102, 204, 153);
				frames = Paths.getSparrowAtlas('characters/mariCave');
				animation.addByIndices('danceLeft', 'Mari_HairBlowLeft', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Mari_HairBlowLeft', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

			case 'mariGhost':
				// jaja se murio que pendeja
				iconColor = FlxColor.fromRGB(118, 71, 224);
				frames = Paths.getSparrowAtlas('characters/mariGhost');
				animation.addByPrefix('idle', 'MariGhost_Idle instance', 24, false);
				animation.addByPrefix('singUP', 'MariGhost_Up instance', 24);
				animation.addByPrefix('singRIGHT', 'MariGhost_Right instance', 24);
				animation.addByPrefix('singDOWN', 'MariGhost_Down instance', 24);
				animation.addByPrefix('singLEFT', 'MariGhost_Left instance', 24);

				playAnim('idle');
				
			case 'reimu':
				// LA REIMU HAKUREI DEL PROYECTO TOUHOU
				iconColor = FlxColor.fromRGB(255, 0, 135);
				frames = Paths.getSparrowAtlas('characters/reimu');
				animation.addByIndices('danceLeft', 'Reimu_Idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Reimu_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				
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
				animation.addByPrefix('still', 'Isaac_Lag', 24, false);
				characterData.quickDancer = true;

				playAnim('danceRight');

			case 'BrownishSea':
				// doug
				iconColor = FlxColor.fromRGB(255, 102, 255);
				frames = Paths.getSparrowAtlas('characters/BrownishSea');
				animation.addByPrefix('idle', 'Brown_Idle', 24, false);
				animation.addByPrefix('singUP', 'Brown_Up', 24);
				animation.addByPrefix('singRIGHT', 'Brown_Right', 24);
				animation.addByPrefix('singDOWN', 'Brown_Down', 24);
				animation.addByPrefix('singLEFT', 'Brown_Left', 24);

				playAnim('idle');

			case 'cesar':
				// yo el cesar
				iconColor = FlxColor.fromRGB(176, 11, 105);
				frames = Paths.getSparrowAtlas('characters/cesar');
				animation.addByPrefix('idle', 'CesarGpe_Idle', 24, false);
				animation.addByPrefix('singUP', 'CesarGpe_Up', 24);
				animation.addByPrefix('singRIGHT', 'CesarGpe_Right', 24);
				animation.addByPrefix('singDOWN', 'CesarGpe_Down', 24);
				animation.addByPrefix('singLEFT', 'CesarGpe_Left', 24);
				animation.addByPrefix('tired', 'CesarGpe_TiredPig', 24);
				animation.addByPrefix('still', 'CesarGpe_StillPig', 24, true);

				playAnim('idle');

			case 'morir':
				// el cesar si se muriera
				iconColor = FlxColor.fromRGB(176, 11, 105);
				frames = Paths.getSparrowAtlas('characters/blank');
				animation.addByPrefix('idle', 'blank', 24, false);
				animation.addByPrefix('singUP', 'blank', 24);
				animation.addByPrefix('singRIGHT', 'blank', 24);
				animation.addByPrefix('singDOWN', 'blank', 24);
				animation.addByPrefix('singLEFT', 'blank', 24);

				playAnim('idle');

			case 'cesarito':
				// solo esta para el icono, no hay otro personaje
				iconColor = FlxColor.fromRGB(153, 0, 0);
				frames = Paths.getSparrowAtlas('characters/blank');
				animation.addByPrefix('idle', 'blank', 24, false);
				animation.addByPrefix('singUP', 'blank', 24);
				animation.addByPrefix('singRIGHT', 'blank', 24);
				animation.addByPrefix('singDOWN', 'blank', 24);
				animation.addByPrefix('singLEFT', 'blank', 24);

				playAnim('idle');

			case 'hyperpig':
				// terrence god potioneado
				iconColor = FlxColor.fromRGB(255, 102, 153);
				frames = Paths.getSparrowAtlas('characters/hyperpig');
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

			case 'bs32minecart':
				// el eslamio pero en carrito
				iconColor = FlxColor.fromRGB(146, 113, 79);
				frames = Paths.getSparrowAtlas('characters/bs32minecart');
				animation.addByPrefix('idle', 'bs32_use_idle', 24, false);
				animation.addByPrefix('singUP', 'bs32_use_up', 24);
				animation.addByPrefix('singRIGHT', 'bs32_use_right', 24);
				animation.addByPrefix('singDOWN', 'bs32_use_down', 24);
				animation.addByPrefix('singLEFT', 'bs32_use_left', 24);

				playAnim('idle');

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

			case 'Tsuraran':
				// ayra ayra
				iconColor = FlxColor.fromRGB(204, 204, 204);
				frames = Paths.getSparrowAtlas('characters/Tsuraran');
				animation.addByPrefix('idle', 'Tsuraran Idle instance', 24, false);
				animation.addByPrefix('singUP', 'Tsuraran Up instance', 24);
				animation.addByPrefix('singRIGHT', 'Tsuraran Right instance', 24);
				animation.addByPrefix('singDOWN', 'Tsuraran Down instance', 24);
				animation.addByPrefix('singLEFT', 'Tsuraran Left instance', 24);
				characterData.quickDancer = true;
				characterData.offsetY = 37;
				characterData.offsetX = 100;
				flipX = true;

				scale.set(1.25, 1.25);
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

			case 'twelve':
				// gordo de michelin
				iconColor = FlxColor.fromRGB(255, 255, 255);
				frames = Paths.getSparrowAtlas('characters/twelve');
				animation.addByPrefix('idle', 'twelve', 24, false);
				animation.addByPrefix('singUP', 'twelve', 24);
				animation.addByPrefix('singRIGHT', 'twelve', 24);
				animation.addByPrefix('singDOWN', 'twelve', 24);
				animation.addByPrefix('singLEFT', 'twelve', 24);

				playAnim('idle');

			case 'venudo':
				// when todos quieren de tu venenoso
				iconColor = FlxColor.fromRGB(0, 0, 0);
				frames = Paths.getSparrowAtlas('characters/venudo');
				animation.addByPrefix('idle', 'venudo', 24, false);
				animation.addByPrefix('singUP', 'venudo', 24);
				animation.addByPrefix('singRIGHT', 'venudo', 24);
				animation.addByPrefix('singDOWN', 'venudo', 24);
				animation.addByPrefix('singLEFT', 'venudo', 24);

				playAnim('idle');

			case 'pepe':
				// mama huevaso
				iconColor = FlxColor.fromRGB(181, 118, 112);
				frames = Paths.getSparrowAtlas('characters/pepe');
				animation.addByPrefix('idle', 'pepe idle', 24, false);
				animation.addByPrefix('singUP', 'pepe singUP', 24);
				animation.addByPrefix('singRIGHT', 'pepe singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'pepe singDOWN', 24);
				animation.addByPrefix('singLEFT', 'pepe singLEFT', 24);

				playAnim('idle');

			case 'sech':
				// aqui con mi compa el sech
				iconColor = FlxColor.fromRGB(40, 20, 0);
				frames = Paths.getSparrowAtlas('characters/sech');
				animation.addByPrefix('idle', 'sech idle', 24, false);
				animation.addByPrefix('singUP', 'sech singUP', 24);
				animation.addByPrefix('singRIGHT', 'sech singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'sech singDOWN', 24);
				animation.addByPrefix('singLEFT', 'sech singLEFT', 24);

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
