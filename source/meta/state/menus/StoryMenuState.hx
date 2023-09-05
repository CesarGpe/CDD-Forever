package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var scoreText:FlxText;
	var curWeek:Int = 0;

	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var menuBF:FlxSprite;
	var yellowBG:FlxSprite;

	override function create()
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if !html5
		Discord.changePresence('En los Menús:', 'Menú del Modo Historia');
		#end

		// freeaaaky
		ForeverTools.resetMenuMusic();

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "PUNTOS: 69420420", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		yellowBG = new FlxSprite(0, 56);
		yellowBG.frames = Paths.getSparrowAtlas('menus/base/storymenu/story-bgs');
		yellowBG.animation.addByPrefix('week0', 'tutorial', 24, true);
		yellowBG.animation.addByPrefix('week1', 'brown', 24, true);
		yellowBG.animation.addByPrefix('week2', 'cesar', 24, true);
		yellowBG.animation.addByPrefix('week3', 'bule', 24, true);
		yellowBG.animation.addByPrefix('week4', 'tsuyar', 24, true);
		yellowBG.animation.play('week0', true);
		yellowBG.antialiasing = true;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		for (i in 0...Main.gameWeeks.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();
		}

		menuBF = new FlxSprite(455, 70);
		menuBF.frames = Paths.getSparrowAtlas('menus/base/storymenu/MenuBF');
		menuBF.animation.addByPrefix('idle', 'idle', 24, true);
		menuBF.animation.addByPrefix('press', 'hey', 24, false);
		menuBF.animation.play('idle', true);
		menuBF.scale.set(1.1, 1.1);
		menuBF.updateHitbox();
		menuBF.antialiasing = true;

		add(yellowBG);
		add(menuBF);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Pistas");
		txtTracklist.setFormat(Paths.font("vcr.ttf"), 36);
		txtTracklist.color = 0xFFe55777;
		txtTracklist.alignment = CENTER;
		
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		scoreText.text = "PUNTAJE:" + lerpScore;

		txtWeekTitle.text = Main.gameWeeks[curWeek][3].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UI_UP_P)
					changeWeek(-1);
				else if (controls.UI_DOWN_P)
					changeWeek(1);
			}

			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			movedBack = true;
			Main.switchState(this, new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('menu/confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				menuBF.animation.play('press', true);
				stopspamming = true;
			}

			PlayState.storyPlaylist = Main.gameWeeks[curWeek][0].copy();
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var turd:String = '';

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + turd, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				Main.switchState(this, new PlayState(), true);
			});
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= Main.gameWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = Main.gameWeeks.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "Pistas\n";

		var stringThing:Array<String> = Main.gameWeeks[curWeek][0];
		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		txtTracklist.text += "\n"; // pain
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		yellowBG.animation.play('week' + curWeek, true);

		intendedScore = Highscore.getWeekScore(curWeek, 1);
	}
}
