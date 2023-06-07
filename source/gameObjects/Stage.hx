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
import flixel.util.FlxTimer;
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
	var message:FNFSprite;

	// discord stage
	var leftSide:FNFSprite;
	var rightSide:FNFSprite;
	var groovy:FNFSprite;
	var txt:FlxText;
	// evil discord
	var corner1:FNFSprite;
	var corner2:FNFSprite;

	// skyblock stage
	var sky:FNFSprite;
	var tree:FNFSprite;
	var outpost:FNFSprite;
	var cabin:FNFSprite;
	var cesar:FNFSprite;
	// calamity
	var isCalamity:Bool = false;
	var dogSummoned:Bool = false;
	var dogTwn:FlxTween;
	var calbg:FNFSprite;
	var plat1:FNFSprite;
	var plat2:FNFSprite;
	var credit:FNFSprite;
	var dog:FNFSprite;
	var aura:FNFSprite;
	var black:FNFSprite;

	// cave stage
	var fx:FNFSprite;
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
	private var curSong:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var aboveHUD:FlxTypedGroup<FlxBasic>;
	public var aboveNote:FlxTypedGroup<FlxBasic>;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (curSong)
			{
				case 'gaming':
					curStage = 'skyblock';
				case 'chase' | 'pandemonium':
					curStage = 'cave';
				case 'temper' | 'temper-x':
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

		// grupos padrisimos para hacer mas facil el trabajo
		foreground = new FlxTypedGroup<FlxBasic>(); // foreground.add();
		aboveHUD = new FlxTypedGroup<FlxBasic>(); // aboveHUD.add();
		aboveNote = new FlxTypedGroup<FlxBasic>(); // aboveNote();

		//
		switch (curStage)
		{
			case 'skyblock': // serian 2 stages en una
				PlayState.defaultCamZoom = 0.7;
				FlxG.sound.cache(Paths.sound('spawnBoss'));

				// * ESTA ES LA STAGE DE SKYBLOCK
				
				bg = new FNFSprite(-600, -400);
				sky = new FNFSprite(-600, -200);
				tree = new FNFSprite(1100, -300);
				outpost = new FNFSprite(500, 300);
				floor = new FNFSprite(-1250, 100);
				cabin = new FNFSprite(-1000, -525);
				cesar = new FNFSprite(-920, 550);
				
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

				// * ESTA ES LA STAGE DE CALAMITY

				black = new FNFSprite();
				aura = new FNFSprite();
				message = new FNFSprite(10, 510);
				calbg = new FNFSprite(-2800, -1900);
				plat1 = new FNFSprite(-4200, 635);
				plat2 = new FNFSprite(-4200, 1715);
				credit = new FNFSprite(330, 430);
				dog = new FNFSprite(-4000, -2700);

				black.makeGraphic(2548, 2048, FlxColor.BLACK);
				message.loadGraphic(Paths.image('backgrounds/' + curStage + '/calamity/dogSummon'));
				aura.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/Auras');
				calbg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/CCBG');
				plat1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/platform');
				plat2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/platform');
				credit.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/creditTeam');
				dog.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/calamity/DOG_Assets');

				aura.animation.addByPrefix('purple', 'purpleAura', 24, false);
				aura.animation.addByPrefix('blue', 'blueAura', 24, false);
				calbg.animation.addByPrefix('purple', 'purpleBg', 24, false);
				calbg.animation.addByPrefix('blue', 'blueBg', 24, false);
				credit.animation.addByPrefix('bop', 'creditTeam', 24, false);
				dog.animation.addByIndices('wiggle1', 'DOG_Idle', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				dog.animation.addByIndices('wiggle2', 'DOG_Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1], "", 24, false);

				aura.setGraphicSize(Std.int(aura.width * 0.69), Std.int(aura.height * 0.69));
				calbg.setGraphicSize(Std.int(calbg.width * 4), Std.int(calbg.height * 4));
				plat1.setGraphicSize(Std.int(plat1.width * 1.5), Std.int(plat1.height * 1));
				plat2.setGraphicSize(Std.int(plat2.width * 1.5), Std.int(plat2.height * 1));
				credit.setGraphicSize(Std.int(credit.width * 0.8), Std.int(credit.height * 0.8));
				dog.setGraphicSize(Std.int(dog.width * 1.5), Std.int(dog.height * 1.5));
				message.scale.set(0.35, 0.35);

				aura.updateHitbox();
				message.updateHitbox();
				calbg.updateHitbox();
				plat1.updateHitbox();
				plat2.updateHitbox();
				credit.updateHitbox();
				dog.updateHitbox();

				aura.antialiasing = true;
				message.antialiasing = true;
				calbg.antialiasing = true;
				plat1.antialiasing = true;
				plat2.antialiasing = true;
				credit.antialiasing = true;
				dog.antialiasing = true;

				aura.scrollFactor.set(0, 0);
				credit.scrollFactor.set(0, 0);
				message.scrollFactor.set(0, 0);
				calbg.scrollFactor.set(0.3, 0.3);

				black.visible = false;
				aboveHUD.add(black);
				
				aboveNote.add(aura);
				aboveNote.add(credit);
				aboveNote.add(message);

				textDisplay(false);
			
			case 'cave':
				PlayState.defaultCamZoom = 0.5;

				fx = new FNFSprite();
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

				fx.loadGraphic(Paths.image('backgrounds/' + curStage + '/black_vignette'));
				fx.setGraphicSize(Std.int(fx.width * 0.7), Std.int(fx.height * 0.7));
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
				fx.scrollFactor.set(0, 0);

				fx.updateHitbox();
				fx.screenCenter(XY);

				fx.antialiasing = true;
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

				aboveNote.add(fx);
				add(stone1);
				add(stone2);
				add(bg1);
				add(bg2);
				add(bg3);
				add(track1);
				add(track2);
				add(track3);
				foreground.add(wood1); // madera pendeja
				add(wood2);
				add(wood3);

				// bucle del fondo la neta no se si esta bien optimizado pero al chile me vale caca jaja risa malvada
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
				corner1 = new FNFSprite(-126, 434);
				corner2 = new FNFSprite(909, 393);

				bg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_backGround');
				floor.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_Floor');
				leftSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideLeft');
				rightSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideRight');
				corner1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/corner1');
				corner2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/corner2');
				
				
				bg.animation.addByPrefix('idle', 'discord_background', 24, true);
				floor.animation.addByPrefix('idle', 'discord_floor', 24, true);
				rightSide.animation.addByPrefix('idle', 'discord_sideRight', 24, true);
				corner1.animation.addByPrefix('idle', 'corner1', 24, true);
				corner2.animation.addByPrefix('idle', 'corner2', 24, true);

				bg.animation.play('idle', true);
				floor.animation.play('idle', true);
				rightSide.animation.play('idle', true);
				corner1.animation.play('idle', true);
				corner2.animation.play('idle', true);

				bg.antialiasing = true;
				floor.antialiasing = true;
				leftSide.antialiasing = true;
				rightSide.antialiasing = true;
				corner1.antialiasing = true;
				corner2.antialiasing = true;

				corner1.scrollFactor.set(0, 0);
				corner2.scrollFactor.set(0, 0);

				add(bg);
				add(floor);
				add(leftSide);
				add(rightSide);
				aboveHUD.add(corner1);
				aboveHUD.add(corner2);

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

				bg = new FNFSprite(-1883, -1300);
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/camara'));
				bg.scale.set(2, 2);
				bg.updateHitbox();
				add(bg);

			default:
				curStage = 'discord';
				PlayState.defaultCamZoom = 0.75;

				bg = new FNFSprite(-1131, -970);
				floor = new FNFSprite(-514, 512);
				leftSide = new FNFSprite(-1611, -978);
				rightSide = new FNFSprite(1417, -978);
				message = new FNFSprite(15, 510);

				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordExtenseBg'));
				floor.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordFloor'));
				leftSide.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordSideLeft'));
				rightSide.loadGraphic(Paths.image('backgrounds/' + curStage + '/discordSideRight'));
				message.loadGraphic(Paths.image('backgrounds/' + curStage + '/message'));
				
				// groovy (RIP)
				groovy = new FNFSprite(-270, 60);
				groovy.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/groovySong');
				groovy.animation.addByPrefix('left', 'bganimated_1', 24, false);
				groovy.animation.addByPrefix('right', 'bganimated_2', 24, false);
				groovy.setGraphicSize(Std.int(groovy.width * 0.8), Std.int(groovy.height * 0.8));
				groovy.updateHitbox();

				// texto del groovoso
				txt = new FlxText(-175, 312, 0, 'Now playing: ' + CoolUtil.dashToSpace(PlayState.SONG.song), 56);
				txt.setFormat(Paths.font("whitneybook.otf"), 56, FlxColor.WHITE);
				txt.updateHitbox();

				message.scale.set(0.35, 0.35);
				message.updateHitbox();

				bg.antialiasing = true;
				floor.antialiasing = true;
				leftSide.antialiasing = true;
				rightSide.antialiasing = true;
				groovy.antialiasing = true;
				txt.antialiasing = true;
				message.antialiasing = true;

				add(bg);
				add(groovy);
				add(txt);
				add(floor);
				add(leftSide);
				add(rightSide);
				aboveNote.add(message);
				textDisplay(false);
		}
	}

	function loopCompleted(tag:String):Void
	{
		// esto ya sirve asi que ni le muevo
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
				boyfriend.x += 50;
				boyfriend.y -= 160;
				dad.x -= 50;
				dad.y -= 160;
				gf.y =- 140;
				gf.scrollFactor.set(1, 1);
			case 'discordEvil':
				boyfriend.y -= 65;
				dad.y -= 65;
				gf.y =- 70;
				gf.scrollFactor.set(1, 1);
			case 'skyblock':
				boyfriend.x = 890;
				boyfriend.y = 320;
				dad.x = -100;
				dad.y = 390;
				gf.x = 340;
				gf.y = -160;
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
				boyfriend.y = 255;
				dad.x = -150;
				dad.y = 60;
				gf.x = 255;
				gf.y = -105;
		}
	}
	
	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'discord':
				if (curBeat % 2 == 0)
					groovy.animation.play('left', true);
				else if (curBeat % 2 == 1)
					groovy.animation.play('right', true);
			case 'skyblock':
				if (curBeat % 4 == 0)
				{
					// skyblock
					tree.animation.play('bop', true);
					floor.animation.play('bop', true);
					cabin.animation.play('bop', true);
					outpost.animation.play('bop', true);
					// calamity
					credit.animation.play('bop', true);
					aura.animation.play('purple', true);
					calbg.animation.play('purple', true);
					
					if (dogSummoned)
						dog.animation.play('wiggle1', true);
				}
				else if (curBeat % 4 == 2)
				{
					// skyblock
					tree.animation.play('bop', true);
					floor.animation.play('bop', true);
					cabin.animation.play('bop', true);
					outpost.animation.play('bop', true);
					// calamity
					credit.animation.play('bop', true);
					aura.animation.play('blue', true);
					calbg.animation.play('blue', true);

					if (dogSummoned)
						dog.animation.play('wiggle2', true);
				}
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'skyblock':
				aura.visible = isCalamity;
				credit.visible = isCalamity;
		}
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Deshabilitar Suavizado') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	public function calamityMode(on:Bool = false) // solo para la stage de skyblock
	{
		isCalamity = on;
		switch(on) // no quiero ponerlo en un array porque capaz y el orden se caga encima
		{
			case true:
				// calamity
				add(calbg);
				add(plat1);
				add(plat2);
				add(dog);

				// skyblock
				remove(bg);
				remove(sky);
				remove(tree);
				remove(outpost);
				remove(floor);
				remove(cabin);
				remove(cesar);

			case false:
				// calamity
				remove(calbg);
				remove(plat1);
				remove(plat2);
				remove(dog);

				// skyblock
				add(bg);
				add(sky);
				add(tree);
				add(outpost);
				add(floor);
				add(cabin);
				add(cesar);
				
		}
	}

	public function dogSpawn()
	{
		textDisplay(true);
		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			textDisplay(false);
		});
		dogSummoned = true;
		FlxG.sound.play(Paths.sound('spawnBoss'));
		dogTwn = FlxTween.tween(dog, {x: 4000}, 10);
	}

	// si esto es toda la funcion es que no quiero ponerlo en el update
	public function textDisplay(on:Bool = true) {message.visible = on;}

	// asi es soy racista :sunglasses:
	public function toggleBlack() {black.visible = !black.visible;}
}