package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.state.menus.*;
import openfl.Assets;

using StringTools;

/**
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var spr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, 0.64];
	var curWacky:Array<String> = [];
	var titleTimer:Float = 0;

	override public function create():Void
	{
		if (FlxG.save.data.shubsEgg == null)
			FlxG.save.data.shubsEgg = false;
		FlxG.save.flush();

		controls.setKeyboardScheme(None, false);
		if (!FlxG.save.data.shubsEgg)
			curWacky = FlxG.random.getObject(getIntroTextShit());
		else
			curWacky = ['quien chingados', 'es psych engine'];
		super.create();

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			///*
			#if !html5
			Discord.changePresence('En la pantalla', 'del titulo');
			#end
			
			ForeverTools.resetMenuMusic(true);
		}
		persistentUpdate = true;

		logoBl = new FlxSprite(-5, 10);
		if (FlxG.save.data.shubsEgg)
		{
			logoBl.x = 450;
			logoBl.y = 0;
			logoBl.frames = Paths.getSparrowAtlas('menus/base/title/foreverlogo');
			logoBl.animation.addByIndices('bump', 'forever bop', [1, 2, 3, 4], "", 24, false);
			logoBl.setGraphicSize(Std.int(logoBl.width / 1.8));
		}
		else
		{
			logoBl.frames = Paths.getSparrowAtlas('menus/base/title/logoBumpin');
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		}
		logoBl.antialiasing = true;
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(470, 55);
		if (FlxG.save.data.shubsEgg)
		{
			gfDance.x = 60; //672
			gfDance.y = 30;
			gfDance.frames = Paths.getSparrowAtlas('menus/base/title/ShubBump');
			gfDance.animation.addByPrefix('danceLeft', 'Shubs Title Bump', 24, false);
			gfDance.animation.addByPrefix('danceRight', 'Shubs Title Bump', 24, false);
		}
		else
		{
			gfDance.frames = Paths.getSparrowAtlas('menus/base/title/CDDTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = true;
		gfDance.updateHitbox();
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(160, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/enterText');
		titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');	
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		spr = new FlxSprite(0, FlxG.height * 0.38).loadGraphic(Paths.image('menus/base/title/forever'));
		add(spr);
		spr.visible = false;
		spr.setGraphicSize(Std.int(spr.width * 0.65));
		spr.updateHitbox();
		spr.screenCenter(X);
		spr.antialiasing = true;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [];
		if (Assets.exists(Paths.txt('introText')))
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
			var firstArray:Array<String> = fullText.split('\n');

			for (i in firstArray)
				swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var pressedShift:Bool = FlxG.keys.justPressed.SHIFT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// prepara el temporizador para los tweens
		titleTimer += FlxMath.bound(elapsed, 0, 1);
		if (titleTimer > 2) titleTimer -= 2;

		// texto de presiona enter para iniciar
		if (!pressedEnter && !transitioning && skippedIntro)
		{
			var timer:Float = titleTimer;
			if (timer >= 1)
				timer = (-timer) + 2;

			timer = FlxEase.quadInOut(timer);

			titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
			titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
		}

		// empezar videojuego
		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');
			titleText.color = FlxColor.WHITE;
			titleText.alpha = 1;

			FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
			FlxG.sound.play(Paths.sound('menu/confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				Main.switchState(this, new MainMenuState());
			});
		}

		// easter egg de shubs
		if (pressedShift && !transitioning && skippedIntro)
		{
			transitioning = true;

			FlxG.save.data.shubsEgg = !FlxG.save.data.shubsEgg;
			FlxG.save.flush();

			FlxG.save.data.playJingle = true;

			FlxG.sound.play(Paths.sound('secret/ToggleJingle'));
			FlxG.sound.music.fadeOut();

			var black = new FlxSprite();
			black.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			black.scrollFactor.set();
			black.screenCenter();
			black.alpha = 0;
			add(black);

			FlxTween.tween(black, {alpha: 1}, 1, {
				onComplete: function(twn:FlxTween)
				{
					Main.switchState(this, new TitleState());
				}
			});
		}

		// salta la intro
		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		
		danceLeft = !danceLeft;
		if (danceLeft) {
			gfDance.animation.play('danceRight');
			if (!FlxG.save.data.shubsEgg)
				FlxTween.tween(logoBl, {angle: 4}, 0.15, {ease: FlxEase.elasticOut});
		} else {
			gfDance.animation.play('danceLeft');
			if (!FlxG.save.data.shubsEgg)
				FlxTween.tween(logoBl, {angle: -2}, 0.15, {ease: FlxEase.elasticOut});
		}
		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 5:
				createCoolText(['Hecho en']);
			case 7:
				spr.visible = true;
			case 8:
				deleteCoolText();
				spr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Camara');
			case 14:
				addMoreText('de Diputados');
			case 15:
				addMoreText('Forever');
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (FlxG.save.data.playJingle)
			{
				var sound:FlxSound = null;
				if (FlxG.save.data.shubsEgg)
				{
					sound = FlxG.sound.play(Paths.sound('secret/JingleShubs'));
					sound.onComplete = function()
					{
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				else
				{
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					transitioning = false;
				}
				FlxG.save.data.playJingle = false;
			}

			remove(spr);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
