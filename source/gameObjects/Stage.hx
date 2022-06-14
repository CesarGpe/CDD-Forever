package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.background.*;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	// uni sprites
	var bg:FNFSprite;
	var floor:FNFSprite;

	// discord stage
	var leftSide:FNFSprite;
	var rightSide:FNFSprite;
	var groovy:FNFSprite;
	var txt:FlxText;

	// skyblock stage
	var sky:FNFSprite;
	var tree:FNFSprite;
	var outpost:FNFSprite;
	var cabin:FNFSprite;
	var cesar:FNFSprite;

	// cave stage
	var stone1:FNFSprite;
	var stone2:FNFSprite;
	var bg1:FNFSprite;
	var bg2:FNFSprite;
	var bg3:FNFSprite;
	var track1:FNFSprite;
	var track2:FNFSprite;
	var track3:FNFSprite;
	var wood1:FNFSprite;
	var wood2:FNFSprite;
	var wood3:FNFSprite;
	// cave loop tweens
	var bg1Twn:FlxTween;
	var bg2Twn:FlxTween;
	var bg3Twn:FlxTween;
	var stone1Twn:FlxTween;
	var stone2Twn:FlxTween;

	// end of stage sprites

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'gaming':
					curStage = 'skyblock';
				case 'chase' | 'pandemonium':
					curStage = 'cave';
				case 'temper':
					curStage = 'discordEvil';
				case 'take-five':
					curStage = 'secret';
				case 'asf':
					curStage = 'camara';
				default:
					curStage = 'discord';
			}

			PlayState.curStage = curStage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			case 'skyblock':
				PlayState.defaultCamZoom = 0.7;

				bg = new FNFSprite(-600, -400);
				sky = new FNFSprite(-600, -200);
				tree = new FNFSprite(1100, -300);
				outpost = new FNFSprite(500, 300);
				floor = new FNFSprite(-1250, 100);
				cabin = new FNFSprite(-1000, -525);
				cesar = new FNFSprite(-900, 500);
				
				bg.makeGraphic(2548, 2048, FlxColor.fromRGB(133, 175, 254));
				sky.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/Sky');
				tree.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/Tree');
				outpost.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/MinionOutpost');
				floor.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/Land');
				cabin.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/PollosHermanos');
				cesar.loadGraphic(Paths.image('backgrounds/' + curStage + '/cesar_dead'));
				
				tree.animation.addByPrefix('bop', 'Tree', 24, false);
				outpost.animation.addByPrefix('bop', 'MinionOutpost', 24, false);
				floor.animation.addByPrefix('bop', 'Land', 24, false);
				cabin.animation.addByPrefix('bop', 'PollosHermanos', 24, false);

				sky.setGraphicSize(Std.int(sky.width * 1.3), Std.int(sky.height * 1.3));
				tree.setGraphicSize(Std.int(tree.width * 1.3), Std.int(tree.height * 1.3));
				outpost.setGraphicSize(Std.int(outpost.width * 1), Std.int(outpost.height * 1));
				floor.setGraphicSize(Std.int(floor.width * 1), Std.int(floor.height * 1));
				cabin.setGraphicSize(Std.int(cabin.width * 1.7), Std.int(cabin.height * 1.7));
				cesar.setGraphicSize(Std.int(cesar.width * 0.7), Std.int(cesar.height * 0.7));

				sky.updateHitbox();
				tree.updateHitbox();
				outpost.updateHitbox();
				floor.updateHitbox();
				cabin.updateHitbox();
				cesar.updateHitbox();

				sky.scrollFactor.set(0.2, 0.2);

				bg.antialiasing = true;
				sky.antialiasing = true;
				tree.antialiasing = true;
				outpost.antialiasing = true;
				floor.antialiasing = true;
				cabin.antialiasing = true;
				cesar.antialiasing = true;

				add(bg);
				add(sky);
				add(tree);
				add(outpost);
				add(floor);
				add(cabin);
				add(cesar);

			case 'cave':
				PlayState.defaultCamZoom = 0.5;

				stone1 = new FNFSprite(-990, -371);
				stone2 = new FNFSprite(1550, -371);
				bg1 = new FNFSprite(-710, -885);
				bg2 = new FNFSprite(675, -883);
				bg3 = new FNFSprite(2060, -881);
				track1 = new FNFSprite(0, 580);
				track2 = new FNFSprite(1383, 580);
				track3 = new FNFSprite(-1383, 580);
				wood1 = new FNFSprite(0, 655);
				wood2 = new FNFSprite(2037, 655);
				wood3 = new FNFSprite(-2037, 655);

				stone1.loadGraphic(Paths.image('backgrounds/' + curStage + '/StoneBg'));
				stone2.loadGraphic(Paths.image('backgrounds/' + curStage + '/StoneBg'));
				bg1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/cave1');
				bg2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/cave2');
				bg3.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/cave1');
				track1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars2');
				track2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars2');
				track3.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars2');
				wood1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars');
				wood2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars');
				wood3.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/woodPillars');

				bg1.animation.addByPrefix('idle', 'cave_1', 24, true);
				bg2.animation.addByPrefix('idle', 'cave_2', 24, true);
				bg3.animation.addByPrefix('idle', 'cave_1', 24, true);
				track1.animation.addByPrefix('idle', 'WoodPog2', 24, true);
				track2.animation.addByPrefix('idle', 'WoodPog2', 24, true);
				track3.animation.addByPrefix('idle', 'WoodPog2', 24, true);
				wood1.animation.addByPrefix('idle', 'WoodPog', 24, true);
				wood2.animation.addByPrefix('idle', 'WoodPog', 24, true);
				wood3.animation.addByPrefix('idle', 'WoodPog', 24, true);

				// play all the anims
				bg1.animation.play('idle', true);
				bg2.animation.play('idle', true);
				bg3.animation.play('idle', true);
				track1.animation.play('idle', true);
				track2.animation.play('idle', true);
				track3.animation.play('idle', true);
				wood1.animation.play('idle', true);
				wood2.animation.play('idle', true);
				wood3.animation.play('idle', true);

				stone1.scrollFactor.set(0.1, 0.1);
				stone2.scrollFactor.set(0.1, 0.1);
				bg1.scrollFactor.set(0.2, 0.2);
				bg2.scrollFactor.set(0.2, 0.2);
				bg3.scrollFactor.set(0.2, 0.2);

				stone1.antialiasing = true;
				stone2.antialiasing = true;
				bg1.antialiasing = true;
				bg2.antialiasing = true;
				bg3.antialiasing = true;
				track1.antialiasing = true;
				track2.antialiasing = true;
				track3.antialiasing = true;
				wood1.antialiasing = true;
				wood2.antialiasing = true;
				wood3.antialiasing = true;

				// vignette in Strumline state
				add(stone1);
				add(stone2);
				add(bg1);
				add(bg2);
				add(bg3);
				add(track1);
				add(track2);
				add(track3);
				foreground.add(wood1);
				add(wood2);
				add(wood3);

				// background loop stuff
				bg1Twn = FlxTween.tween(bg1, {x: -2060}, 0.6, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg1');}});
				bg2Twn = FlxTween.tween(bg2, {x: -2060}, 1.2, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg2');}});
				bg3Twn = FlxTween.tween(bg3, {x: -2060}, 1.8, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg3');}});

				stone1Twn = FlxTween.tween(stone1, {x: -3500}, 10, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('stone1');}});
				stone2Twn = FlxTween.tween(stone2, {x: -3500}, 20, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('stone2');}});

			case 'discordEvil':
				PlayState.defaultCamZoom = 0.7;

				bg = new FNFSprite(-500, -300);
				floor = new FNFSprite(-268, 610);
				leftSide = new FNFSprite(-1337, -349);
				rightSide = new FNFSprite(1381, -607);

				bg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_backGround');
				floor.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_Floor');
				leftSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideLeft');
				rightSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideRight');

				bg.animation.addByPrefix('idle', 'discord_background', 24, true);
				floor.animation.addByPrefix('idle', 'discord_floor', 24, true);
				rightSide.animation.addByPrefix('idle', 'discord_sideRight', 24, true);

				// play all the anims
				bg.animation.play('idle', true);
				floor.animation.play('idle', true);
				rightSide.animation.play('idle', true);

				bg.antialiasing = true;
				floor.antialiasing = true;
				leftSide.antialiasing = true;
				rightSide.antialiasing = true;

				// corners in ClassHUD state
				add(bg);
				add(floor);
				add(leftSide);
				add(rightSide);

			case 'secret':
				PlayState.defaultCamZoom = 1.2;

				var pink:FNFSprite = new FNFSprite(-400, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/pink grid'));
				FlxTween.tween(pink, {x: -300, y: -500}, 4.2, {type: FlxTweenType.LOOPING});
				pink.scrollFactor.set(0.5, 0.5);
				pink.active = false;
				add(pink);

				var white:FNFSprite = new FNFSprite(-400, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/white grid'));
				FlxTween.tween(white, {x: -500, y: -300}, 4, {type: FlxTweenType.LOOPING});
				white.scrollFactor.set(0.3, 0.6);
				white.active = false;
				add(white);

				var darkfx:FlxSprite = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				darkfx.scrollFactor.set();
				darkfx.alpha = 0.5;
				add(darkfx);

			case 'camara':
				PlayState.defaultCamZoom = 0.7;

				bg = new FNFSprite(-655, -400);
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/camara'));
				bg.setGraphicSize(Std.int(bg.width * 2), Std.int(bg.height * 2));
				bg.updateHitbox();
				bg.antialiasing = true;
				add(bg);

			default:
				curStage = 'discord';
				PlayState.defaultCamZoom = 0.75;

				bg = new FNFSprite(-1131, -970);
				floor = new FNFSprite(-514, 512);
				leftSide = new FNFSprite(-1611, -978);
				rightSide = new FNFSprite(1417, -978);

				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordExtenseBg'));
				floor.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordFloor'));
				leftSide.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordSideLeft'));
				rightSide.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordSideRight'));
				
				// groovy
				groovy = new FNFSprite(-270, 60);
				groovy.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/groovySong');
				groovy.animation.addByPrefix('left', 'bganimated_1', 24, false);
				groovy.animation.addByPrefix('right', 'bganimated_2', 24, false);
				groovy.setGraphicSize(Std.int(groovy.width * 0.8), Std.int(groovy.height * 0.8));
				groovy.updateHitbox();

				// song text
				txt = new FlxText(-175, 312, 0, 'Now playing: ' + CoolUtil.dashToSpace(PlayState.SONG.song), 56);
				txt.setFormat(Paths.font("whitneybook.otf"), 56, FlxColor.WHITE);
				txt.updateHitbox();

				bg.antialiasing = true;
				floor.antialiasing = true;
				leftSide.antialiasing = true;
				rightSide.antialiasing = true;
				groovy.antialiasing = true;
				txt.antialiasing = true;

				add(bg);
				add(groovy);
				add(txt);
				add(floor);
				add(leftSide);
				add(rightSide);
		}
	}

	function loopCompleted(tag:String):Void
	{
		switch (tag)
		{
			case 'bg1':
				bg1.x = 2060;
				bg1Twn = FlxTween.tween(bg1, {x: -2060}, 1.8, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg1');}});
			case 'bg2':
				bg2.x = 2060;
				bg2Twn = FlxTween.tween(bg2, {x: -2060}, 1.8, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg2');}});
			case 'bg3':
				bg3.x = 2060;
				bg3Twn = FlxTween.tween(bg3, {x: -2060}, 1.8, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('bg3');}});
			case 'stone1':
				stone1.x = 1500;
				stone1Twn = FlxTween.tween(stone1, {x: -3500}, 20, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('stone1');}});
			case 'stone2':
				stone2.x = 1500;
				stone2Twn = FlxTween.tween(stone2, {x: -3500}, 20, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {loopCompleted('stone2');}});
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'mari';

		switch (curStage)
		{
			case 'discord' | 'discordEvil' | 'skyblock' | 'camara':
				gfVersion = 'mari';
			case 'cave':
				gfVersion = 'mariCave';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, gf:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray) {
			switch (char.curCharacter)
			{
				case 'gf':
					char.setPosition(gf.x, gf.y);
					gf.visible = false;
				/*
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
				}*/
				/*
				case 'spirit':
					var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
					evilTrail.changeValuesEnabled(false, false, false, false);
					add(evilTrail);
					*/
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'discord':
				boyfriend.y -= 140;
				dad.y -= 140;
				gf.y =- 140;
				gf.scrollFactor.set(1, 1);
			case 'discordEvil':
				boyfriend.y -= 65;
				dad.y -= 65;
				gf.y =- 70;
				gf.scrollFactor.set(1, 1);
			case 'skyblock':
				boyfriend.x += 130;
				boyfriend.y -= 130;
				dad.x -= 130;
				dad.y -= 130;
				gf.y =- 160;
				gf.scrollFactor.set(1, 1);
			case 'cave':
				boyfriend.x += 550;
				boyfriend.y -= 60;
				dad.x -= 350;
				dad.y += 25;
				gf.x = 200;
				gf.y = 120;
				gf.scrollFactor.set(0.95, 1);
				FlxTween.tween(boyfriend, {x: boyfriend.x - 170}, 0.8, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
				FlxTween.tween(dad, {x: dad.x - 160}, 0.8, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
				FlxTween.tween(gf, {x: gf.x + 300}, 1, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
			case 'secret':
				boyfriend.visible = false;
				dad.visible = false;
				gf.visible = false;
				boyfriend.screenCenter(XY);
				dad.screenCenter(XY);
				gf.screenCenter(XY);
			case 'camara':
				boyfriend.x = 905;
				boyfriend.y = 200;
				dad.x = -150;
				dad.y = 60;
				gf.x = 300;
				gf.y = -50;
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'discord':
				if (curBeat % 4 == 0)
					groovy.animation.play('left', true);
				else if (curBeat % 4 == 1)
					groovy.animation.play('right', true);
				else if (curBeat % 4 == 2)
					groovy.animation.play('left', true);
				else if (curBeat % 4 == 3)
					groovy.animation.play('right', true);
			case 'skyblock':
				if (curBeat % 2 == 1)
				{
					tree.animation.play('bop', true);
					outpost.animation.play('bop', true);
					floor.animation.play('bop', true);
					cabin.animation.play('bop', true);
				}
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'cave':
				// amonus
		}
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
