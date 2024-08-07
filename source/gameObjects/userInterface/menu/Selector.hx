package gameObjects.userInterface.menu;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;

class Selector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:Alphabet;
	public var chosenOptionString:String = '';
	public var options:Array<String>;

	public var fpsCap:Bool = false;

	public function new(x:Float = 0, y:Float = 0, word:String, options:Array<String>, fpsCap:Bool = false, filter:Bool = false, ?wordFactor:Float = 0, ?size:Float = 1)
	{
		// call back the function
		super(x, y);

		this.options = options;
		trace(options);

		// oops magic numbers
		var shiftX = 45;
		var shiftY = 35;
		// generate multiple pieces

		this.fpsCap = fpsCap;

		#if html5
		// lol heres how we fuck with everyone
		var lock = new FlxSprite(shiftX + ((word.length) * wordFactor) + (shiftX / 4) + ((fpsCap) ? -100 : 0), shiftY);
		lock.frames = Paths.getSparrowAtlas('menus/storymenu/campaign_menu_UI_assets');
		lock.animation.addByPrefix('lock', 'lock', 24, false);
		lock.animation.play('lock');
		add(lock);
		#else
		leftSelector = createSelector(shiftX, shiftY, word, 'left');
		rightSelector = createSelector(shiftX + ((word.length) * wordFactor) + (shiftX / 4) + ((fpsCap) ? -50 : 0), shiftY, word, 'right');

		add(leftSelector);
		add(rightSelector);
		#end

		chosenOptionString = Init.trueSettings.get(word);
		if (fpsCap)
		{
			chosenOptionString = Std.string(Init.trueSettings.get(word));
			optionChosen = new Alphabet(FlxG.width / 2 + 100, shiftY + 20, chosenOptionString, false, false, size);
		}
		else if (filter)
			optionChosen = new Alphabet(FlxG.width / 2 - 190, shiftY + 15, chosenOptionString, true, false, size);
		else
			optionChosen = new Alphabet(FlxG.width / 2 - 100, shiftY + 15, chosenOptionString, true, false, size);

		add(optionChosen);
	}

	public function createSelector(objectX:Float = 0, objectY:Float = 0, word:String, dir:String):FNFSprite
	{
		var returnSelector = new FNFSprite(objectX, objectY);
		returnSelector.frames = Paths.getSparrowAtlas('menus/storymenu/campaign_menu_UI_assets');

		returnSelector.animation.addByPrefix('idle', 'arrow $dir', 24, false);
		returnSelector.animation.addByPrefix('press', 'arrow push $dir', 24, false);
		returnSelector.addOffset('press', 0, -10);
		returnSelector.playAnim('idle');

		return returnSelector;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (object in 0...objectArray.length)
			objectArray[object].setPosition(x + positionLog[object][0], y + positionLog[object][1]);
	}

	public function selectorPlay(whichSelector:String, animPlayed:String = 'idle')
	{
		switch (whichSelector)
		{
			case 'left':
				leftSelector.playAnim(animPlayed);
			case 'right':
				rightSelector.playAnim(animPlayed);
		}
	}

	var objectArray:Array<FlxSprite> = [];
	var positionLog:Array<Array<Float>> = [];

	override public function add(object:FlxSprite):FlxSprite
	{
		objectArray.push(object);
		positionLog.push([object.x, object.y]);
		return super.add(object);
	}
}
