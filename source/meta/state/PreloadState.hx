package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.Character;
import sys.FileSystem;
import sys.thread.Thread;

using StringTools;

enum PreloadType
{
	atlas;
	image;
	directory;
}

class PreloadState extends FlxState
{
	public static var preloadedAssets:Map<String, FlxGraphic>;
	var assetStack:Map<String, PreloadType> = [
		'backgrounds/cave' => PreloadType.directory,
		'backgrounds/discord' => PreloadType.directory,
		'backgrounds/discordEvil' => PreloadType.directory,
		'backgrounds/lost' => PreloadType.directory,
		'backgrounds/secret' => PreloadType.directory,
		'backgrounds/skyblock' => PreloadType.directory
	];
	var maxCount:Int;

	var loadText:FlxText;
	var bg:FlxSprite;

	override public function create()
	{
		super.create();

		FlxG.camera.alpha = 0;

		maxCount = Lambda.count(assetStack);
		trace(maxCount);
		FlxG.mouse.visible = false;

		preloadedAssets = new Map<String, FlxGraphic>();

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/base/menuDesat'));
		//bg.setGraphicSize(Std.int(bg.width * globalRescale));
		bg.updateHitbox();
		add(bg);

		FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {
			onComplete: function(tween:FlxTween)
			{
				Thread.create(function()
				{
					assetGenerate();
				});
			}
		});

		loadText = new FlxText(5, FlxG.height - (32 + 5), 0, 'Loading...', 32);
		loadText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadText);
	}

	var storedPercentage:Float = 0;

	function assetGenerate()
	{
		//
		var countUp:Int = 0;
		for (i in assetStack.keys())
		{
			trace('calling asset $i');

			FlxGraphic.defaultPersist = true;
			switch (assetStack[i])
			{
				case PreloadType.image:
					var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image(i, 'images'));
					preloadedAssets.set(i, savedGraphic);
					trace(savedGraphic + ', yeah its working');
				case PreloadType.atlas:
					var preloadedCharacter:Character = new Character();
					preloadedCharacter.setCharacter(FlxG.width / 2, FlxG.height / 2, i);
					preloadedCharacter.visible = false;
					add(preloadedCharacter);
					trace('character loaded ${preloadedCharacter.frames}');
				case PreloadType.directory:
					var images = FileSystem.readDirectory('assets/images/$i');
					for (file in images) 
					{
						if (!file.endsWith('.png'))
							images.remove(file);
					}
					for (j in 0...images.length)
						images[j] = images[j].replace('.png', '');

					for (image in images)
						Paths.image('$i/$image');
			}
			FlxGraphic.defaultPersist = false;

			countUp++;
			storedPercentage = countUp / maxCount;
			loadText.text = 'Loading... Progress at ${Math.floor(storedPercentage * 100)}%';
		}

		FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, {
			onComplete: function(tween:FlxTween)
			{
				FlxG.switchState(new TitleState());
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}