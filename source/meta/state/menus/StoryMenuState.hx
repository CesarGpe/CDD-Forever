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
import gameObjects.userInterface.menu.MenuCharacter;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var weekCharacters:Array<String> = ['mari', 'doug', 'cesar', 'bule', 'tsuyar'];
	var grpWeekText:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var grpBoxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var grpSpeakers:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var grpChars:FlxTypedGroup<MenuCharacter> = new FlxTypedGroup<MenuCharacter>();

	var selectedSomethin:Bool = false;
	static var curWeek:Int = 0;

	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	
	var groovy:FlxSprite;
	var menuBF:FlxSprite;

	final boxWidth = 510;

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
		buttonsBG.makeGraphic(Std.int(FlxG.width * (2/5) + 40), FlxG.height, 0xff2b2d31);
		add(buttonsBG);

		var line1:FlxSprite = new FlxSprite(0, 115);
		line1.makeGraphic(Std.int(FlxG.width * 0.5) + 20, 4, 0xff27282d);
		line1.antialiasing = true;
		add(line1);

		var line2:FlxSprite = new FlxSprite(0, 115);
		line2.makeGraphic(FlxG.width, 4, 0xff242529);
		line2.antialiasing = true;
		add(line2);

		var menutxt:FlxText = new FlxText(35, 140, 550, 'HISTORIA');
		menutxt.setFormat(Paths.font("unisans.otf"), 60, 0xff8b8d92, LEFT);
		menutxt.antialiasing = true;
		add(menutxt);

		var cddtxt:FlxText = new FlxText(35, 15, 550, 'Vs. CDD');
		cddtxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		cddtxt.antialiasing = true;
		add(cddtxt);

		groovy = new FlxSprite(762, 150);
		groovy.frames = Paths.getSparrowAtlas('menus/storymenu/groovy');
		groovy.animation.addByPrefix('left', 'bganimated_1', 24, false);
		groovy.animation.addByPrefix('right', 'bganimated_2', 24, false);
		groovy.setGraphicSize(Std.int(groovy.width * 0.35), Std.int(groovy.height * 0.35));
		groovy.updateHitbox();
		groovy.antialiasing = true;
		add(groovy);

		txtTracklist = new FlxText(groovy.x + 75, groovy.y + 60, 0, "- Pistas -");
		txtTracklist.setFormat(Paths.font("whitneymedium.otf"), 36, 0xff8b8d92, LEFT);
		txtTracklist.antialiasing = true;
		add(txtTracklist);

		scoreText = new FlxText(10, 10, 0, "Puntaje: 69420", 36);
		scoreText.setFormat(Paths.font("whitneymedium.otf"), 32);
		// add(scoreText);

		txtWeekTitle = new FlxText(580, 27, 500, "Semana epica");
		txtWeekTitle.setFormat(Paths.font("whitneymedium.otf"), 50, FlxColor.WHITE, LEFT);
		txtWeekTitle.alpha = 0.7;
		add(txtWeekTitle);

		menuBF = new FlxSprite(1000, 480);
		menuBF.frames = Paths.getSparrowAtlas('menus/storymenu/chars/bf');
		menuBF.animation.addByPrefix('idle', 'BF idle dance white', 24, false);
		menuBF.animation.addByPrefix('press', 'BF HEY!!', 24, false);
		menuBF.animation.play('idle', true);
		menuBF.scale.set(0.5, 0.5);
		menuBF.updateHitbox();
		menuBF.antialiasing = true;
		menuBF.alpha = 0.5;
		add(menuBF);

		add(grpBoxes);
		add(grpSpeakers);
		add(grpWeekText);
		add(grpChars);

		for (i in 0...weekCharacters.length)
		{
			var char:MenuCharacter = new MenuCharacter(600, 375, weekCharacters[i]);
			char.ID = i;
			grpChars.add(char);
		}

		for (i in 0...Main.gameWeeks.length)
		{
			var weekThing:FlxText;
			if (i > 0) weekThing = new FlxText(0, 100, 200, 'Week ' + i);
			else weekThing = new FlxText(0, 100, 200, 'Tutorial');
			weekThing.setFormat(Paths.font("whitneymedium.otf"), 50, FlxColor.WHITE, LEFT);
			weekThing.y += ((weekThing.height + 30) * i) + 123;
			weekThing.antialiasing = true;
			weekThing.screenCenter(X);
			weekThing.x -= 420;
			weekThing.ID = i;

			var box:FlxSprite = new FlxSprite(20, 100);
			box.y += ((weekThing.height + 30) * i) + 110;
			box.makeGraphic(boxWidth, 90, 0xff35373c);
			box.ID = i;

			var speaker:FlxSprite = new FlxSprite(30, 100);
			speaker.loadGraphic(Paths.image('menus/storymenu/speaker'));
			speaker.setGraphicSize(Std.int(speaker.width * 0.3), Std.int(speaker.height * 0.3));
			speaker.updateHitbox();
			speaker.antialiasing = true;
			speaker.alpha = 0.5;
			speaker.y += ((weekThing.height + 30) * i) + 115;
			speaker.ID = i;

			grpBoxes.add(box);
			grpWeekText.add(weekThing);
			grpSpeakers.add(speaker);
		}

		updateText();
		changeWeek();
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));
		scoreText.text = "Puntaje: " + lerpScore;

		txtWeekTitle.text = Main.gameWeeks[curWeek][3];
		//txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		if (!selectedSomethin)
		{
			// mover
			if (controls.UI_UP_P)
				changeWeek(-1);
			else if (controls.UI_DOWN_P)
				changeWeek(1);

			// agarrar
			if (controls.ACCEPT)
				selectWeek();

			// atras
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('menu/cancelMenu'));
				selectedSomethin = true;
				Main.switchState(this, new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	function changeWeek(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

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

		for (item in grpBoxes.members)
		{
			if (item.ID == curWeek)
				item.visible = true;
			else
				item.visible = false;
		}

		for (char in grpChars.members)
		{
			if (char.ID == curWeek)
				char.visible = true;
			else
				char.visible = false;
		}

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "- Pistas -\n";

		var swagFormat:FlxTextFormat = new FlxTextFormat(FlxColor.WHITE);
		var swagPair:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(swagFormat, "#");
		txtTracklist.applyMarkup("#- Pistas -#", [swagPair]);

		if (curWeek == 0)
			txtTracklist.text += '\nTutorial';
		else 
		{
			var stringThing:Array<String> = Main.gameWeeks[curWeek][0];
			for (i in stringThing)
				txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);
		}

		intendedScore = Highscore.getWeekScore(curWeek, 1);
	}

	function selectWeek()
	{
		selectedSomethin = true;
		menuBF.animation.play('press', true);
		FlxG.sound.play(Paths.sound('menu/joinVC'), 0.35);
		FlxG.sound.play(Paths.sound('menu/confirmMenu'));

		PlayState.storyPlaylist = Main.gameWeeks[curWeek][0].copy();
		PlayState.isStoryMode = true;
		PlayState.seenCutscene = false;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyDifficulty = 1;
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;

		grpBoxes.members[curWeek].makeGraphic(boxWidth, 90, 0xff3f4248);

		FlxFlicker.flicker(grpWeekText.members[curWeek], 1, 0.06, false, false);
		FlxFlicker.flicker(grpSpeakers.members[curWeek], 1, 0.06, false, false);
		FlxFlicker.flicker(grpBoxes.members[curWeek], 1, 0.06, false, false);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			Main.switchState(this, new PlayState(), true);
		});
	}

	var danced:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		danced = !danced;
		if (danced)
			groovy.animation.play('left', true);
		else
			groovy.animation.play('right', true);

		for (char in grpChars.members)
			char.dance(true);

		if (!selectedSomethin)
		menuBF.animation.play('idle', true);
	}

}
