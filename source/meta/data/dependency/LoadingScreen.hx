package meta.data.dependency;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import meta.state.PlayState;

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
		'metalgear.ttf',
		'deltarune.ttf',
		'terraria.ttf',
		'minecraft.ttf',
		'earthbound.ttf'
	];

	var screen:FlxSprite;
	var black:FlxSprite;
	var txt:FlxText;

	var isTransIn:Bool = false;
	public function new(duration:Float, isTransIn:Bool, ?font:String = null)
	{
		super();
		this.isTransIn = isTransIn;

		#if !html5
		Discord.changePresence('Cargando...');
		#end

		if (PlayState.SONG != null)
		{
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'skullody':
					fontUsed = 'metalgear.ttf';
				case 'coffee' | 'spring' | 'rules':
					fontUsed = 'deltarune.ttf';
				case 'deadbush' | 'necron' | 'gaming' | 'chronomatron' | 'take-five':
					fontUsed = 'terraria.ttf';
				case 'goop' | 'chase' | 'pandemonium':
					fontUsed = 'minecraft.ttf';
				case 'edge' | 'absolution' | 'temper' | 'razortrousle' | 'temper-x':
					fontUsed = 'earthbound.ttf';
				case 'asf':
					fontUsed = 'morena.otf';
				case 'memories':
					fontUsed = 'puruaran.ttf';
				case 'pelea-en-la-calle-tres':
					fontUsed = 'venom.ttf';
				case 'pilin':
					fontUsed = 'tiktok.ttf';
				case 'succionar':
					fontUsed = '';
			}
		}
		else
		{
			if (font == null)
				fontUsed = fonts[FlxG.random.int(0, 4)];
			else
				fontUsed = font;
		}

		black = new FlxSprite();
		black.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.scrollFactor.set();
		black.screenCenter();
		black.alpha = 0;
		add(black);

		screen = new FlxSprite().loadGraphic(Paths.image('menus/mainmenu/art/loadingScreen'));
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

		txt.antialiasing = true;
		txt.alpha = 0;
		add(txt);

		if (isTransIn)
		{
			txt.alpha = 1;
			black.alpha = 1;
			screen.alpha = 1;
			FlxTween.tween(txt, {alpha: 0}, duration, {ease: FlxEase.circInOut});
			FlxTween.tween(screen, {alpha: 0}, duration, {
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(black, {alpha: 0}, duration, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							close();
						}
					});
				},
				ease: FlxEase.circInOut
			});
		}
		else
		{
			FlxTween.tween(black, {alpha: 1}, duration, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(txt, {alpha: 1}, duration + 0.15, {ease: FlxEase.circInOut});
					FlxTween.tween(screen, {alpha: 1}, duration + 0.15, {
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
			});
		}
	}

	override function update(elapsed:Float)
	{
		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		txt.cameras = [camera];
		black.cameras = [camera];
		screen.cameras = [camera];

		super.update(elapsed);
	}

	override function destroy()
	{
		finishCallback();
		super.destroy();
	}
}