package gameObjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.CelebiNote;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.display.BitmapData;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	// uni sprites
	var floor:FNFSprite;
	var black:FNFSprite;
	var message:FNFSprite;

	// calle tres
	var wey:FNFSprite;

	// chronomatron
	var gore:FNFSprite;
	var dead:FNFSprite;

	// discord stage
	var groovy:FNFSprite;

	// skyblock stage
	var tree:FNFSprite;
	var outpost:FNFSprite;
	var cabin:FNFSprite;
	// calamity
	var dogSummoned:Bool = false;
	var calEnded:Bool = false;
	var bossSound:FlxSound;
	var calbg:FNFSprite;
	var aura:FNFSprite;
	var credit:FNFSprite;
	var dog:FNFSprite;

	// cave stage
	var stone1:FNFSprite;
	var stone2:FNFSprite;
	var bg1:FNFSprite;
	var bg2:FNFSprite;
	var bg3:FNFSprite;

	// end of stage sprites

	public var curStage:String;
	private var curSong:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());

	// grupos de sprites
	public var foreground:FlxTypedGroup<FlxBasic>;
	public var aboveHUD:FlxTypedGroup<FlxBasic>;
	public var aboveNote:FlxTypedGroup<FlxBasic>;

	var sbSprites:FlxTypedGroup<FNFSprite>;
	var calSprites:FlxTypedGroup<FNFSprite>;
	var wordGroup:Array<FlxSprite> = [];

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
				case 'chronomatron':
					curStage = 'lost';
				case 'take-five':
					curStage = 'secret';
				case 'asf':
					curStage = 'camara';
				case 'pelea-en-la-calle-tres':
					curStage = 'calleTres';
				case 'pilin':
					curStage = 'tepito';
				case 'succionar':
					curStage = 'cagar';
				default:
					curStage = 'discord';
			}

			PlayState.curStage = curStage;
		}

		// grupos padrisimos para hacer mas facil el trabajo
		foreground = new FlxTypedGroup<FlxBasic>(); // foreground.add();
		aboveHUD = new FlxTypedGroup<FlxBasic>(); // aboveHUD.add();
		aboveNote = new FlxTypedGroup<FlxBasic>(); // aboveNote.add();

		//
		switch (curStage)
		{
			case 'skyblock': // serian 2 stages en una
				PlayState.defaultCamZoom = 0.7;

				calSprites = new FlxTypedGroup<FNFSprite>();
				sbSprites = new FlxTypedGroup<FNFSprite>();
				
				bossSound = new FlxSound().loadEmbedded(Paths.sound('event/spawnBoss'));
				bossSound.persist = true;
				bossSound.play();

				var bitmapData:Map<String, FlxGraphic>;
				bitmapData = new Map<String, FlxGraphic>();
				Paths.image('backgrounds/skyblock/DOG_Assets');
				
				var data:BitmapData = BitmapData.fromFile("assets/images/backgrounds/skyblock/DOG_Assets");
				var graph = FlxGraphic.fromBitmapData(data);
				graph.persist = true;
				graph.destroyOnNoUse = false;
				bitmapData.set('DOG_Assets', graph);

				// * ESTA ES LA STAGE DE CALAMITY

				black = new FNFSprite();
				aura = new FNFSprite();
				message = new FNFSprite(10, 510);
				calbg = new FNFSprite(-2800, -1900);
				var plat1:FNFSprite = new FNFSprite(-4200, 635);
				var plat2:FNFSprite = new FNFSprite(-4200, 1715);
				credit = new FNFSprite(330, 430);
				dog = new FNFSprite(-4000, -2700);

				black.makeGraphic(2548, 2048, FlxColor.BLACK);
				message.loadGraphic(Paths.image('backgrounds/' + curStage + '/dogSummon'));
				aura.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/Auras');
				calbg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/CCBG');
				plat1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/platform');
				plat2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/platform');
				credit.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/creditTeam');
				dog.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/DOG_Assets');

				aura.animation.addByPrefix('purple', 'purpleAura', 24, false);
				aura.animation.addByPrefix('blue', 'blueAura', 24, false);
				calbg.animation.addByPrefix('purple', 'purpleBg', 24, false);
				calbg.animation.addByPrefix('blue', 'blueBg', 24, false);
				credit.animation.addByPrefix('bop', 'creditTeam', 24, false);
				dog.animation.addByPrefix('fullanim', 'DOG_Idle', 24, true);
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

				message.visible = false;
				black.visible = false;
				black.screenCenter(XY);
				aboveHUD.add(black);

				aboveNote.add(aura);
				aboveNote.add(credit);
				aboveNote.add(message);

				calSprites.add(calbg);
				calSprites.add(plat1);
				calSprites.add(plat2);
				calSprites.add(dog);
				add(calSprites);

				dog.animation.play('wiggle1', true);
				dog.animation.play('wiggle2', true);
				dog.animation.play('fullanim', true);

				// * ESTA ES LA STAGE DE SKYBLOCK
				
				var bg:FNFSprite = new FNFSprite(-600, -400);
				var sky:FNFSprite = new FNFSprite(-600, -200);
				tree = new FNFSprite(1100, -300);
				outpost = new FNFSprite(500, 300);
				floor = new FNFSprite(-1250, 100);
				cabin = new FNFSprite(-1000, -525);
				var cesar:FNFSprite = new FNFSprite(-920, 550);
				
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

				sbSprites.add(bg);
				sbSprites.add(sky);
				sbSprites.add(tree);
				sbSprites.add(outpost);
				sbSprites.add(floor);
				sbSprites.add(cabin);
				sbSprites.add(cesar);
				add(sbSprites);

				// actualizar los objetos
				triggerEvent('Calamity Mode', 'init');
			
			case 'cave':
				PlayState.defaultCamZoom = 0.5;

				var fx:FNFSprite = new FNFSprite();
				var wood1:FNFSprite = new FNFSprite(0, 655);
				var wood2:FNFSprite = new FNFSprite(2037, 655);
				var wood3:FNFSprite = new FNFSprite(-2037, 655);
				var track1:FNFSprite = new FNFSprite(0, 580);
				var track2:FNFSprite = new FNFSprite(1383, 580);
				var track3:FNFSprite = new FNFSprite(-1383, 580);

				// objetos del fondo para mover
				stone1 = new FNFSprite(-990, -371);
				stone2 = new FNFSprite(1550, -371);
				bg1 = new FNFSprite(-710, -885);
				bg2 = new FNFSprite(675, -883);
				bg3 = new FNFSprite(2060, -881);

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


				FlxTween.tween(bg1, {x: -2060}, 0.6, {onComplete: function(twn:FlxTween) {loopCompleted('bg1');}});
				FlxTween.tween(bg2, {x: -2060}, 1.2, {onComplete: function(twn:FlxTween) {loopCompleted('bg2');}});
				FlxTween.tween(bg3, {x: -2060}, 1.8, {onComplete: function(twn:FlxTween) {loopCompleted('bg3');}});

				FlxTween.tween(stone1, {x: -3500}, 10, {onComplete: function(twn:FlxTween) {loopCompleted('stone1');}});
				FlxTween.tween(stone2, {x: -3500}, 20, {onComplete: function(twn:FlxTween) {loopCompleted('stone2');}});

			case 'lost':
				// JAJAJAJAJAJA ME MORI NO LEAS ESTO PORFA
				PlayState.defaultCamZoom = 0.75;
				PlayState.cameraSpeed = 10;

				Paths.getSparrowAtlas('backgrounds/lost/Celebi_Assets');
				Paths.getSparrowAtlas('backgrounds/lost/Note_asset');
				Paths.image('backgrounds/lost/jumpscare');
				
				gore = new FNFSprite(480, 120);
				gore.loadGraphic(Paths.image('backgrounds/' + curStage + '/CesarTieso'));
				gore.setGraphicSize(Std.int(gore.width * 0.68), Std.int(gore.height * 0.68));
				gore.updateHitbox();
				gore.antialiasing = true;

				dead = new FNFSprite(215, 350);
				dead.loadGraphic(Paths.image('backgrounds/' + curStage + '/Cesar_Dead'));
				dead.setGraphicSize(Std.int(dead.width * 0.7), Std.int(dead.height * 0.7));
				dead.updateHitbox();
				dead.antialiasing = true;

				black = new FNFSprite();
				black.makeGraphic(2548, 2048, FlxColor.BLACK);
				black.screenCenter(XY);
				
				add(gore);
				add(black);

			case 'calleTres':
				PlayState.defaultCamZoom = 0.75;
				PlayState.cameraSpeed = 3;

				var bg:FNFSprite = new FNFSprite(-655, -400);
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/fondo'));
				bg.scale.set(8, 7);
				bg.updateHitbox();
				add(bg);

				wey = new FNFSprite(-200, 45);
				wey.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/doce');
				wey.animation.addByPrefix('mover', 'doce idle', 48, true);
				wey.scale.set(8, 8);
				wey.updateHitbox();
				wey.visible = false;
				add(wey);

				var asset:Array<String> = ['we', 'cock', 'dick', 'balling'];
				for (i in 0...asset.length)
				{
					var word:FlxSprite = new FlxSprite();
					word.loadGraphic(Paths.image('backgrounds/calleTres/' + asset[i]));
					word.antialiasing = true;
					word.scrollFactor.set();
					word.screenCenter();
					word.updateHitbox();
					word.alpha = 0;

					wordGroup.push(word);
					aboveNote.add(word);
				}
				
			case 'tepito':
				PlayState.defaultCamZoom = 0.75;
				PlayState.cameraSpeed = 2;

				var bg:FNFSprite = new FNFSprite(-500, -600);
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/calle'));
				bg.scale.set(4, 4);
				bg.updateHitbox();
				add(bg);

			case 'cagar':
				PlayState.defaultCamZoom = 0.75;

				var bg:FNFSprite = new FNFSprite();
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/cagar'));
				bg.scrollFactor.set();
				bg.scale.set(1.45, 1.45);
				bg.updateHitbox();
				bg.screenCenter();
				bg.y += 30;
				add(bg);

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

				var bg:FNFSprite = new FNFSprite(-1883, -1300);
				bg.loadGraphic(Paths.image('backgrounds/' + curStage + '/camara'));
				bg.scale.set(2, 2);
				bg.updateHitbox();
				add(bg);

			case 'discordEvil':
				PlayState.defaultCamZoom = 0.7;

				var bg:FNFSprite = new FNFSprite(-500, -300);
				floor = new FNFSprite(-268, 610);
				var leftSide:FNFSprite = new FNFSprite(-1337, -349);
				var rightSide:FNFSprite = new FNFSprite(1381, -607);
				var corner1:FNFSprite = new FNFSprite(-126, 434);
				var corner2:FNFSprite = new FNFSprite(909, 393);

				bg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_backGround');
				floor.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_Floor');
				leftSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideLeft');
				rightSide.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/discord_sideRight');
				corner1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/corner1');
				corner2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/corner2');

				bg.animation.addByPrefix('idle', 'discord_background', 24, true);
				floor.animation.addByPrefix('idle', 'discord_floor', 24, true);
				leftSide.animation.addByPrefix('idle', 'discord_sideRight', 24, true);
				rightSide.animation.addByPrefix('idle', 'discord_sideRight', 24, true);
				corner1.animation.addByPrefix('idle', 'corner1', 24, true);
				corner2.animation.addByPrefix('idle', 'corner2', 24, true);

				bg.animation.play('idle', true);
				floor.animation.play('idle', true);
				leftSide.animation.play('idle', true);
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

			default:
				curStage = 'discord';
				PlayState.defaultCamZoom = 0.75;

				var bg:FNFSprite = new FNFSprite(-1131, -970);
				floor = new FNFSprite(-514, 512);
				var leftSide:FNFSprite = new FNFSprite(-1611, -978);
				var rightSide:FNFSprite = new FNFSprite(1417, -978);
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
				var txt:FlxText = new FlxText(-175, 312, 0, 'Now playing: ' + CoolUtil.dashToSpace(PlayState.SONG.song), 56);
				txt.setFormat(Paths.font("whitneybook.otf"), 56, FlxColor.WHITE);
				txt.updateHitbox();

				message.scale.set(0.35, 0.35);
				message.updateHitbox();
				message.visible = false;

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
		}
	}

	function loopCompleted(tag:String):Void
	{
		// esto ya sirve asi que ni le muevo
		switch (tag)
		{
			case 'bg1':
				bg1.x = 2060;
				FlxTween.tween(bg1, {x: -2060}, 1.8, {onComplete: function(twn:FlxTween) {loopCompleted('bg1');}});
			case 'bg2':
				bg2.x = 2060;
				FlxTween.tween(bg2, {x: -2060}, 1.8, {onComplete: function(twn:FlxTween) {loopCompleted('bg2');}});
			case 'bg3':
				bg3.x = 2060;
				FlxTween.tween(bg3, {x: -2060}, 1.8, {onComplete: function(twn:FlxTween) {loopCompleted('bg3');}});
			case 'stone1':
				stone1.x = 1500;
				FlxTween.tween(stone1, {x: -3500}, 20, {onComplete: function(twn:FlxTween) {loopCompleted('stone1');}});
			case 'stone2':
				stone2.x = 1500;
				FlxTween.tween(stone2, {x: -3500}, 20, {onComplete: function(twn:FlxTween) {loopCompleted('stone2');}});
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'mari';

		switch (curStage)
		{
			case 'discord' | 'discordEvil' | 'skyblock':
				gfVersion = 'mari';
			case 'cave':
				gfVersion = 'mariCave';
			case 'camara':
				gfVersion = 'reimu';
			case 'cagar':
				gfVersion = 'cesar';
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
				gf.y = -140;
				gf.scrollFactor.set(1, 1);
			case 'discordEvil':
				boyfriend.y -= 65;
				dad.y -= 65;
				gf.y = -70;
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
			case 'lost':
				boyfriend.visible = false;
				dad.visible = false;
				gf.visible = false;
				boyfriend.screenCenter(XY);
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
				gf.scrollFactor.set(1, 1);
			case 'calleTres':
				gf.visible = false;
				boyfriend.x = 1200;
				boyfriend.y = 420;
				dad.x = -200;
				dad.y = 70;
			case 'tepito':
				gf.visible = false;
				boyfriend.x = 950;
				boyfriend.y = -75;
				dad.x = -100;
				dad.y = -55;
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
					if (!calEnded)
					{
						credit.animation.play('bop', true);
						aura.animation.play('purple', true);
						calbg.animation.play('purple', true);

						if (dogSummoned)
							dog.animation.play('wiggle1', true);
					}
				}
				else if (curBeat % 4 == 2)
				{
					// skyblock
					tree.animation.play('bop', true);
					floor.animation.play('bop', true);
					cabin.animation.play('bop', true);
					outpost.animation.play('bop', true);
					// calamity
					if (!calEnded)
					{
						credit.animation.play('bop', true);
						aura.animation.play('blue', true);
						calbg.animation.play('blue', true);

						if (dogSummoned)
							dog.animation.play('wiggle2', true);
					}
				}
			case 'calleTres':
				if (wey.visible)
					PlayState.camGame.zoom = 1.5;
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'skyblock':
				// putos todos
		}
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Deshabilitar Suavizado') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	// ========================================================================================================
	// !            EVENTOS EPICOS PARA LAS CANCIONES EPICAS
	// ========================================================================================================
	/**
	 * Eventos de las canciones epicas
	 * @param name String del nombre del evento
	 * @param value String para el valor del evento
	 */
	public function triggerEvent(name:String, ?value:String = '')
	{
		switch(name)
		{
			case 'Calamity Mode':
				switch (value)
				{
					case 'init':
						aura.kill();
						credit.kill();
						calSprites.forEach(function(spr:FNFSprite)
						{
							spr.kill();
						});
						
					case 'true':
						aura.revive();
						credit.revive();
						calSprites.forEach(function(spr:FNFSprite)
						{
							spr.revive();
						});
						sbSprites.forEach(function(spr:FNFSprite)
						{
							spr.kill();
						});

					case 'false':
						aura.destroy();
						credit.destroy();
						message.destroy();
						calSprites.forEach(function(spr:FNFSprite)
						{
							spr.destroy();
						});
						sbSprites.forEach(function(spr:FNFSprite)
						{
							spr.revive();
						});
						calEnded = true;
				}

			case 'DOG Spawn':
				triggerEvent('Display Message');
				FlxTween.tween(dog, {x: 4000}, 10);
				bossSound.play();
				dogSummoned = true;

			case 'Display Message':
				message.visible = true;
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					message.visible = false;
				});

			case 'Black Screen':
				black.visible = !black.visible;

			case 'Chronomatron Transition':
				switch(value)
				{
					case 'enter':
						FlxTween.tween(black, {alpha: 0}, 2, {ease: FlxEase.sineOut});
						FlxTween.tween(gore.scale, {x: 0.7, y: 0.7}, 2, {ease: FlxEase.sineOut});
					case 'start':
						add(dead);
						remove(gore);
					case 'exit':
						FlxTween.tween(black, {alpha: 0}, 2, {ease: FlxEase.sineOut});
						FlxTween.tween(dead.scale, {x: 0.65, y: 0.65}, 2, {ease: FlxEase.sineOut});
				}
				
			case 'Jumpscare':
				var newJumpscare:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/lost/jumpscare'));
				var jumpscareSize:Float = 1.2;
				newJumpscare.setGraphicSize(Std.int(FlxG.width * jumpscareSize));
				newJumpscare.cameras = [PlayState.camHUD];
				newJumpscare.screenCenter();
				add(newJumpscare);

				jumpscareSize = jumpscareSize + 0.05;
				FlxTween.tween(newJumpscare, {alpha: 0}, 0.5, {
					ease: FlxEase.expoIn,
					onUpdate: function(tween:FlxTween)
					{
						var jumpscareSizeInterval:Float = jumpscareSize;
						var shakeIntensity:Float = (0.0125 * (jumpscareSizeInterval / 2));
						newJumpscare.x += FlxG.random.float(-shakeIntensity * FlxG.width,
							shakeIntensity * FlxG.width) * jumpscareSizeInterval * newJumpscare.scale.x;
						newJumpscare.y += FlxG.random.float(-shakeIntensity * FlxG.height,
							shakeIntensity * FlxG.height) * jumpscareSizeInterval * newJumpscare.scale.y;
					}
				});

			case 'Perish Song':
				var parsed:Float = Std.parseFloat(value);

				var newMin:Float = parsed;
				PlayState.minHealth = newMin;

				var celebi:FlxSprite = new FlxSprite();
				celebi.frames = Paths.getSparrowAtlas('backgrounds/lost/Celebi_Assets');
				celebi.animation.addByPrefix('spawn', 'Celebi Spawn Full', 24, false);
				celebi.animation.addByIndices('recede', 'Celebi Spawn Full', [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
				celebi.animation.addByPrefix('idle', 'Celebi Idle', 24, false);
				celebi.animation.play('spawn');
				celebi.antialiasing = true;

				var direction:Int = -1;
				if (FlxG.random.bool(50))
					direction = -direction;
				celebi.setPosition((510 + FlxG.random.int(-100, 100)) + ((FlxG.width / 1.55) * PlayState.defaultCamZoom) * direction,
					(dead.y + FlxG.random.int(-180, 30)));
				add(celebi);

				new FlxTimer().start(Conductor.stepCrochet * 4 / 1000, function(tmr:FlxTimer)
				{
					var noteCountCelebi:Int = 3;
					trace('celeber 2');
					for (i in 0...noteCountCelebi)
					{
						var note:CelebiNote = new CelebiNote(celebi.x + celebi.width / 2, celebi.y);
						note.frames = Paths.getSparrowAtlas('backgrounds/lost/Note_asset');
						note.animation.addByPrefix('spawn', 'Note Full', 24, false);
						note.animation.play('spawn');
						//
						note.setGraphicSize(Std.int(note.width * 1.5));
						note.updateHitbox();
						note.antialiasing = true;
						//
						FlxTween.tween(note, {alpha: 0}, Conductor.stepCrochet * 8 / 1000, {
							ease: FlxEase.linear,
							startDelay: Conductor.stepCrochet * 8 / 1000,
							onComplete: function(tween:FlxTween)
							{
								remove(note);
							}
						});
						add(note);
					};

					FlxTween.tween(PlayState.uiHUD.healthBar, {
						barWidth: (Std.int(PlayState.uiHUD.healthBarBG.width - 8) - Std.int(PlayState.uiHUD.healthBarBG.width * (PlayState.minHealth / 2)))
					}, Conductor.stepCrochet * 12 / 1000, {ease: FlxEase.linear});
					FlxTween.tween(PlayState.uiHUD.healthBar, {min: newMin}, Conductor.stepCrochet * 12 / 1000, {ease: FlxEase.linear});
				});

				new FlxTimer().start(Conductor.stepCrochet * 16 / 1000, function(tmr:FlxTimer)
				{
					celebi.animation.play('recede', true);
					celebi.animation.finishCallback = function(name:String) remove(celebi);
				});

			case 'Calle Tres Ending':
				var wordStep:Int = Std.parseInt(value);

				var words:Array<String> = ['we', 'cock', 'dick', 'balling'];
				FlxG.sound.play(Paths.sound('event/twelve/' + words[wordStep]));

				wordGroup[wordStep].alpha = 1;
				FlxTween.tween(PlayState.camGame, {zoom: 1 + (wordStep * 0.2)}, 0.1);
				FlxTween.tween(wordGroup[wordStep], {alpha: 0}, 0.5, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						if (wordStep < 3)
							triggerEvent('Calle Tres Ending', Std.string(wordStep + 1));
					}
				});
				if (wordStep == 3)
					new FlxTimer().start(1.7, function(tmr:FlxTimer)
					{
						PlayState.camGame.zoom = 1.5;
						PlayState.dadOpponent.visible = false;
						wey.animation.play('mover', true);
						wey.visible = true;
						for (i in 0...wordGroup.length)
							wordGroup[i].destroy();
					});
		}
	}
}