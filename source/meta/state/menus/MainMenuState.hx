package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.state.PlayState;
import meta.state.menus.*;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxText>;
	var htags:FlxTypedGroup<FlxText>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var linelol:FlxSprite;
	var menutxt:FlxText;
	var cddtxt:FlxText;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var optionShit:Array<String> = ['story-mode', 'freeplay', 'options'];
	var canSnap:Array<Float> = [];

	var codeStep:Int = 0;

	// the create 'state'
	override function create()
	{
		super.create();

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite(-85);
		bg.makeGraphic(1286, 730, FlxColor.fromRGB(47, 49, 54));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		linelol = new FlxSprite(0, 115);
		linelol.makeGraphic(FlxG.width, 4, FlxColor.fromRGB(36, 37, 41));
		linelol.scrollFactor.set();
		linelol.updateHitbox();
		linelol.antialiasing = true;
		add(linelol);

		menutxt = new FlxText(120, 149, 550, 'MAIN MENU', 65);
		menutxt.setFormat(Paths.font("unisans.otf"), 65, FlxColor.fromRGB(139, 141, 146), LEFT);
		menutxt.scrollFactor.set();
		menutxt.updateHitbox();
		menutxt.antialiasing = true;
		add(menutxt);

		cddtxt = new FlxText(50, 15, 550, 'Vs. CDD', 70);
		cddtxt.setFormat(Paths.font("whitneysemibold.otf"), 70, FlxColor.fromRGB(243, 255, 238), LEFT);
		cddtxt.scrollFactor.set();
		cddtxt.updateHitbox();
		cddtxt.antialiasing = true;
		add(cddtxt);

		/*
		magenta = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		*/

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		//add(camFollow); no camera

		// add the menu items
		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		htags = new FlxTypedGroup<FlxText>();
		add(htags);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/base/title/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			//var menuItem:FlxSprite = new FlxSprite(0, 80 + (i * 200));
			var menuItem:FlxText = new FlxText(220, (16 * 9 * i) + (29 * 8), 450, optionShit[i], 80);
			menuItem.setFormat(Paths.font("whitneymedium.otf"), 80, FlxColor.fromRGB(139, 141, 146), LEFT);

			var htag:FlxText = new FlxText(130, (16 * 9 * i) + (29 * 8), 450, '#', 100);
			htag.setFormat(Paths.font("whitneymedium.otf"), 90, FlxColor.fromRGB(139, 141, 146), LEFT);

			var menuBox:FlxSprite = new FlxSprite(220, (16 * 9 * i) + (29 * 8));
			menuBox.makeGraphic(500, 50, FlxColor.fromRGB(60, 63, 69));


			canSnap[i] = -1;
			menuItem.ID = i;
			/*
			menuItem.frames = tex;
			// add the animations in a cool way (real
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			canSnap[i] = -1;
			// set the id
			menuItem.ID = i;
			// menuItem.alpha = 0;
			*/

			// placements
			//*menuItem.screenCenter(X);
			// if the id is divisible by 2
			/*if (menuItem.ID % 2 == 0)
				menuItem.x += 1000;
			else
				menuItem.x -= 1000;
			*/
			// actually add the item
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();

			htags.add(htag);
			htag.scrollFactor.set();
			htag.antialiasing = true;
			htag.updateHitbox();

			/*
				FlxTween.tween(menuItem, {alpha: 1, x: ((FlxG.width / 2) - (menuItem.width / 2))}, 0.35, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(tween:FlxTween)
					{
						canSnap[i] = 0;
					}
			});*/
		}

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		updateSelection();

		// from the base game lol

		var versionShit:FlxText = new FlxText(5, FlxG.height - 25, 0, "Forever Engine v" + Main.gameVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var back = controls.BACK;
		var controlArray:Array<Bool> = [up, down, up_p, down_p, back];

		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;

						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					if (controls.BACK)
					{
						Main.switchState(this, new TitleState());
					}
					/* idk something about it isn't working yet I'll rewrite it later
						else
						{
							// paaaaaaaiiiiiiiinnnn
							var curDir:Int = 0;
							if (i == 0)
								curDir = -1;
							else if (i == 1)
								curDir = 1;

							if (counterControl < 2)
								counterControl += 0.05;

							if (counterControl >= 1)
							{
								curSelected += (curDir * (counterControl / 24));
								if (curSelected % 1 == 0)
									FlxG.sound.play(Paths.sound('scrollMenu'));
							}
					}*/

					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}

		if ((controls.ACCEPT) && (!selectedSomethin))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			//FlxFlicker.flicker(magenta, 0.8, 0.1, false);

			menuItems.forEach(function(spr:FlxText)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];

						switch (daChoice)
						{
							case 'story-mode':
								Main.switchState(this, new StoryMenuState());
							case 'freeplay':
								Main.switchState(this, new FreeplayState());
							case 'options':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);
		easterEggCheck();
	}

	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxText)
		{
			//spr.animation.play('idle');
			spr.setFormat(Paths.font("whitneymedium.otf"), 80, FlxColor.fromRGB(139, 141, 146));
			spr.updateHitbox();
		});

		// set the sprites and all of the current selection
		camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
			menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

		if (menuItems.members[Math.floor(curSelected)].color == FlxColor.fromRGB(139, 141, 146))
			menuItems.members[Math.floor(curSelected)].setFormat(Paths.font("whitneymedium.otf"), 80, FlxColor.fromRGB(243, 255, 238));

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
	}

	function easterEggCheck()
	{
		if (FlxG.keys.anyJustPressed([Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M]))
		{
			var resetCode = true;
			switch (codeStep)
			{
				case 0:
					if (FlxG.keys.justPressed.A)
						resetCode = false;
				case 1:
					if (FlxG.keys.justPressed.S)
						resetCode = false;
				case 2:
					if (FlxG.keys.justPressed.F)
						amloSiempreFiel();
			}

			if (resetCode)
				codeStep = 0;
			else
				codeStep += 1;
		}
	}

	function amloSiempreFiel():Void
	{
		FlxG.sound.play(Paths.sound('click'));

		var black = new FlxSprite();
		black.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.scrollFactor.set();
		black.screenCenter();
		add(black);

		PlayState.SONG = Song.loadFromJson('asf', 'asf');
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;

		PlayState.storyWeek = 0;
		trace('CUR WEEK:' + PlayState.storyWeek);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Main.switchState(this, new PlayState());
	}
}
