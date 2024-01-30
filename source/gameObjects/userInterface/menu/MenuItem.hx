package gameObjects.userInterface.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxText;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		//week = new FlxSprite().loadGraphic(Paths.image('menus/storymenu/weeks/week' + weekNum));
		if (weekNum > 0)
			week = new FlxText(0, 0, 0, 'Week ' + weekNum);
		else
			week = new FlxText(0, 0, 0, 'Tutorial');
		week.setFormat(Paths.font("whitneymedium.otf"), 50, FlxColor.WHITE, LEFT);
		week.antialiasing = true;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	// yo no problem man, totally understand!
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var lerpVal = Main.framerateAdjust(0.17);
		y = FlxMath.lerp(y, (targetY * 120) + 200, lerpVal);

		if (isFlashing)
		{
			flashingInt += 1;
			if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
				week.alpha = 0;
			else
				week.alpha = 1;
		}
	}
}
