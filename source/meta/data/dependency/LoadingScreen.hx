package meta.data.dependency;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.Transition;
import flixel.addons.transition.TransitionData;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;

/**
 *
 * Shitty loading screen
 * based on Shadow_Mario_'s transition
 *
**/
class LoadingScreen extends MusicBeatSubState
{
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;
	public static var fontUsed:String;
	
	var fonts:Array<String> = [
		'deltarune.ttf',
		'earthbound.ttf',
		'metalgear.ttf',
		'minecraft.ttf',
		'terraria.ttf'];
	var screen:FlxSprite;
	var txt:FlxText;

	var isTransIn:Bool = false;
	public function new(duration:Float, isTransIn:Bool, ?font:String = null)
	{
		super();
		this.isTransIn = isTransIn;

		if (font == null)
			fontUsed = fonts[FlxG.random.int(0, 4)];
		else
			fontUsed = font;

		screen = new FlxSprite().loadGraphic(Paths.image('menus/base/art/loadingScreen'));
		screen.setGraphicSize(Std.int(FlxG.width));
		screen.updateHitbox();
		screen.scrollFactor.set();
		screen.screenCenter();
		screen.antialiasing = true;
		screen.alpha = 0;
		add(screen);

		txt = new FlxText(20, FlxG.height - 690, 0, 'Cargando...');
		if (fontUsed != 'earthbound.ttf')
			txt.setFormat(Paths.font(fontUsed), 50, FlxColor.WHITE);
		else {
			txt.setFormat(Paths.font(fontUsed), 90, FlxColor.WHITE);
			txt.y -= 35;
		}
		
		txt.alignment = FlxTextAlign.CENTER;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;

		txt.scrollFactor.set();
		txt.antialiasing = true;
		txt.alpha = 0;
		add(txt);

		if (isTransIn)
		{
			txt.alpha = 1;
			screen.alpha = 1;
			FlxTween.tween(txt, {alpha: 0}, duration, {ease: FlxEase.circInOut});
			FlxTween.tween(screen, {alpha: 0}, duration, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.circInOut
			});
		}
		else
		{
			FlxTween.tween(txt, {alpha: 1}, duration, {ease: FlxEase.circInOut});
			FlxTween.tween(screen, {alpha: 1}, duration, {
				onComplete: function(twn:FlxTween)
				{
					if (finishCallback != null)
					{
						finishCallback();
					}
				},
				ease: FlxEase.circInOut
			});
		}
	}

	override function update(elapsed:Float)
	{
		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		txt.cameras = [camera];
		screen.cameras = [camera];

		super.update(elapsed);
	}

	override function destroy()
	{
		finishCallback();
		super.destroy();
	}
}