package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
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
	var grpWeekText:FlxTypedGroup<FlxText>;
	var curWeek:Int = 0;

	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	
	var menuBF:FlxSprite;
	var yellowBG:FlxSprite;

	override function create()
	{
		super.create();

		persistentUpdate = persistentDraw = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if !html5
		Discord.changePresence('En los Menús:', 'Menú del Modo Historia');
		#end

		// freeaaaky
		ForeverTools.resetMenuMusic();

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xff313338);
		bg.screenCenter();
		add(bg);

		var buttonsBG:FlxSprite = new FlxSprite();
		buttonsBG.makeGraphic(Std.int(FlxG.width * (2/5)), FlxG.height, 0xff2b2d31);
		buttonsBG.screenCenter();
		add(buttonsBG);

		scoreText = new FlxText(10, 10, 0, "PUTAS: 69420420", 36);
		scoreText.setFormat(Paths.font("whitneymedium.otf"), 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("whitneymedium.otf"), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		yellowBG = new FlxSprite(0, 56);
		yellowBG.frames = Paths.getSparrowAtlas('menus/storymenu/story-bgs');
		yellowBG.animation.addByPrefix('week0', 'tutorial', 24, true);
		yellowBG.animation.addByPrefix('week1', 'brown', 24, true);
		yellowBG.animation.addByPrefix('week2', 'cesar', 24, true);
		yellowBG.animation.addByPrefix('week3', 'bule', 24, true);
		yellowBG.animation.addByPrefix('week4', 'tsuyar', 24, true);
		yellowBG.animation.play('week0', true);
		yellowBG.antialiasing = true;
		yellowBG.alpha = 0;

		menuBF = new FlxSprite(455, 70);
		menuBF.frames = Paths.getSparrowAtlas('menus/storymenu/MenuBF');
		menuBF.animation.addByPrefix('idle', 'idle', 24, true);
		menuBF.animation.addByPrefix('press', 'hey', 24, false);
		menuBF.animation.play('idle', true);
		menuBF.scale.set(1.1, 1.1);
		menuBF.updateHitbox();
		menuBF.antialiasing = true;
		menuBF.alpha = 0;

		grpWeekText = new FlxTypedGroup<FlxText>();
		add(grpWeekText);

		for (i in 0...Main.gameWeeks.length)
		{
			var weekThing:FlxText;
			if (i > 0)
				weekThing = new FlxText(0, 100, 0, 'Week ' + i);
			else
				weekThing = new FlxText(0, 100, 0, 'Tutorial');
			
			weekThing.setFormat(Paths.font("whitneymedium.otf"), 50, FlxColor.WHITE, LEFT);
			weekThing.y += ((weekThing.height + 40) * i);
			weekThing.antialiasing = true;
			weekThing.screenCenter(X);
			weekThing.ID = i;

			grpWeekText.add(weekThing);
		}

		add(yellowBG);
		add(menuBF);

		txtTracklist = new FlxText(FlxG.width * 0.05, 486, 0, "");
		txtTracklist.setFormat(Paths.font("whitneymedium.otf"), 36);
		txtTracklist.color = 0xff8b8d92;
		txtTracklist.antialiasing = true;
		txtTracklist.alignment = CENTER;
		
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();
		changeWeek(0);
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		scoreText.text = "Puntaje: " + lerpScore;

		txtWeekTitle.text = Main.gameWeeks[curWeek][3];
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

				FlxFlicker.flicker(grpWeekText.members[curWeek], 1, 0.06, false, false);
				menuBF.animation.play('press', true);
				stopspamming = true;
			}

			PlayState.storyPlaylist = Main.gameWeeks[curWeek][0].copy();
			PlayState.isStoryMode = true;
			selectedWeek = true;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
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

		for (item in grpWeekText.members)
		{
			if (item.ID == curWeek)
				item.alpha = 1;
			else
				item.alpha = 0.6;
		}

		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "- Pistas -\n";

		var swagFormat:FlxTextFormat = new FlxTextFormat(FlxColor.WHITE);
		var swagPair:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(swagFormat, "#");
		txtTracklist.applyMarkup("#- Pistas -#", [swagPair]);

		var stringThing:Array<String> = Main.gameWeeks[curWeek][0];
		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		//txtTracklist.text += "\n";
		//txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		yellowBG.animation.play('week' + curWeek, true);

		intendedScore = Highscore.getWeekScore(curWeek, 1);
	}
}
