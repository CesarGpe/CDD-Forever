package gameObjects.userInterface.notes;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.data.Conductor;
import meta.data.Timings;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/*
	import flixel.FlxG;

	import flixel.animation.FlxBaseAnimation;
	import flixel.graphics.frames.FlxAtlasFrames;
	import flixel.tweens.FlxEase;
	import flixel.tweens.FlxTween; 
 */
class UIStaticArrow extends FlxSprite
{
	/*  Oh hey, just gonna port this code from the previous Skater engine 
		(depending on the release of this you might not have it cus I might rewrite skater to use this engine instead)
		It's basically just code from the game itself but
		it's in a separate class and I also added the ability to set offsets for the arrows.

		uh hey you're cute ;)
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var babyArrowType:Int = 0;
	public var canFinishAnimation:Bool = true;

	public var initialX:Int;
	public var initialY:Int;

	public var xTo:Float;
	public var yTo:Float;
	public var angleTo:Float;

	public var setAlpha:Float = (Init.trueSettings.get('Opaque Arrows')) ? 1 : 0.8;

	public function new(x:Float, y:Float, ?babyArrowType:Int = 0)
	{
		// this extension is just going to rely a lot on preexisting code as I wanna try to write an extension before I do options and stuff
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();

		this.babyArrowType = babyArrowType;

		updateHitbox();
		scrollFactor.set();
	}

	// literally just character code
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == 'confirm')
			alpha = 1;
		else
			alpha = setAlpha;

		animation.play(AnimName, Force, Reversed, Frame);
		updateHitbox();

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public static function getArrowFromNumber(numb:Int)
	{
		// yeah no I'm not writing the same shit 4 times over
		// take it or leave it my guy
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'left';
			case(1):
				stringSect = 'down';
			case(2):
				stringSect = 'up';
			case(3):
				stringSect = 'right';
		}
		return stringSect;
		//
	}

	// that last function was so useful I gave it a sequel
	public static function getColorFromNumber(numb:Int)
	{
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'purple';
			case(1):
				stringSect = 'blue';
			case(2):
				stringSect = 'green';
			case(3):
				stringSect = 'red';
		}
		return stringSect;
		//
	}
}

class Strumline extends FlxTypedGroup<FlxBasic>
{
	//
	public var receptors:FlxTypedGroup<UIStaticArrow>;
	public var splashNotes:FlxTypedGroup<NoteSplash>;
	public var notesGroup:FlxTypedGroup<Note>;
	public var holdsGroup:FlxTypedGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;

	public var autoplay:Bool = true;
	public var character:Character;
	public var playState:PlayState;
	public var displayJudgements:Bool = false;

	var curStage = PlayState.curStage;
	var bpm = PlayState.SONG.bpm;

	// cave stage
	var fx:FNFSprite;

	// midas
	var midasLines:FlxTypedGroup<FNFSprite>;
	var midasAura:FNFSprite;

	public function new(x:Float = 0, playState:PlayState, ?character:Character, ?displayJudgements:Bool = true, ?autoplay:Bool = true,
			?noteSplashes:Bool = false, ?keyAmount:Int = 4, ?downscroll:Bool = false, ?parent:Strumline)
	{
		super();

		receptors = new FlxTypedGroup<UIStaticArrow>();
		splashNotes = new FlxTypedGroup<NoteSplash>();
		notesGroup = new FlxTypedGroup<Note>();
		holdsGroup = new FlxTypedGroup<Note>();

		allNotes = new FlxTypedGroup<Note>();

		this.autoplay = autoplay;
		this.character = character;
		this.playState = playState;
		this.displayJudgements = displayJudgements;

		for (i in 0...keyAmount)
		{
			var staticArrow:UIStaticArrow = ForeverAssets.generateUIArrows(-25 + x, 25 + (downscroll ? FlxG.height - 200 : 0), i, PlayState.assetModifier);
			staticArrow.ID = i;

			staticArrow.x -= ((keyAmount / 2) * Note.swagWidth);
			staticArrow.x += (Note.swagWidth * i);
			receptors.add(staticArrow);

			staticArrow.initialX = Math.floor(staticArrow.x);
			staticArrow.initialY = Math.floor(staticArrow.y);
			staticArrow.angleTo = 0;
			staticArrow.y -= 10;
			staticArrow.playAnim('static');

			staticArrow.alpha = 0;
			FlxTween.tween(staticArrow, {y: staticArrow.initialY, alpha: staticArrow.setAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			if (noteSplashes) {
				var noteSplash:NoteSplash = ForeverAssets.generateNoteSplashes('noteSplashes', PlayState.assetModifier, PlayState.changeableSkin, 'UI', i);
				splashNotes.add(noteSplash);
			}
		}

		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'stepmania')
			add(holdsGroup);
		add(receptors);
		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'fnf')
			add(holdsGroup);
		add(notesGroup);
		if (splashNotes != null)
			add(splashNotes);

		// cave black vignette
		if (curStage == 'cave')
		{
			fx = new FNFSprite(-53, -32);
			fx.antialiasing = true;
			fx.loadGraphic(Paths.image('backgrounds/' + curStage + '/black_vignette'));
			fx.setGraphicSize(Std.int(fx.width * 0.7), Std.int(fx.height * 0.7));
			fx.updateHitbox();
			fx.screenCenter(XY);
			fx.scrollFactor.set();
			add(fx);
		}

		// midas stuff
		if (curStage == 'discord' || curStage == 'discordEvil' 
			|| curStage == 'skyblock' || curStage == 'cave')
		{
			// vignette
			midasAura = new FNFSprite(-53, -32);
			midasAura.antialiasing = true;
			midasAura.loadGraphic(Paths.image('midas/GoldenAura'));
			midasAura.setGraphicSize(Std.int(midasAura.width * 0.7), Std.int(midasAura.height * 0.7));
			midasAura.updateHitbox();
			midasAura.screenCenter(XY);
			midasAura.scrollFactor.set();
			midasAura.alpha = 0;
			add(midasAura);

			// lines because loop is dumb
			var line1:FNFSprite = new FNFSprite(375, -700);
			var line2:FNFSprite = new FNFSprite(-500, -325);
			var line3:FNFSprite = new FNFSprite(-600, 350);
			var line4:FNFSprite = new FNFSprite(-500, 500);
			var line5:FNFSprite = new FNFSprite(300, 550);
			var line6:FNFSprite = new FNFSprite(700, 550);
			var line7:FNFSprite = new FNFSprite(800, 400);
			var line8:FNFSprite = new FNFSprite(900, 350);
			var line9:FNFSprite = new FNFSprite(900, -400);
			var line10:FNFSprite = new FNFSprite(700, -700);

			line1.frames = Paths.getSparrowAtlas('midas/lines/name1');
			line2.frames = Paths.getSparrowAtlas('midas/lines/name2');
			line3.frames = Paths.getSparrowAtlas('midas/lines/name3');
			line4.frames = Paths.getSparrowAtlas('midas/lines/name4');
			line5.frames = Paths.getSparrowAtlas('midas/lines/name5');
			line6.frames = Paths.getSparrowAtlas('midas/lines/name6');
			line7.frames = Paths.getSparrowAtlas('midas/lines/name7');
			line8.frames = Paths.getSparrowAtlas('midas/lines/name8');
			line9.frames = Paths.getSparrowAtlas('midas/lines/name9');
			line10.frames = Paths.getSparrowAtlas('midas/lines/name10');

			line1.animation.addByPrefix('anim', '1_Line', Std.int(bpm / 6), false);
			line2.animation.addByPrefix('anim', '2_Line', Std.int(bpm / 6), false);
			line3.animation.addByPrefix('anim', '3_Line', Std.int(bpm / 6), false);
			line4.animation.addByPrefix('anim', '4_Line', Std.int(bpm / 6), false);
			line5.animation.addByPrefix('anim', '5_Line', Std.int(bpm / 6), false);
			line6.animation.addByPrefix('anim', '6_Line', Std.int(bpm / 6), false);
			line7.animation.addByPrefix('anim', '7_Line', Std.int(bpm / 6), false);
			line8.animation.addByPrefix('anim', '8_Line', Std.int(bpm / 6), false);
			line9.animation.addByPrefix('anim', '9_Line', Std.int(bpm / 6), false);
			line10.animation.addByPrefix('anim', '10_Line', Std.int(bpm / 6), false);

			midasLines = new FlxTypedGroup<FNFSprite>();
			midasLines.add(line1);
			midasLines.add(line2);
			midasLines.add(line3);
			midasLines.add(line4);
			midasLines.add(line5);
			midasLines.add(line6);
			midasLines.add(line7);
			midasLines.add(line8);
			midasLines.add(line9);
			midasLines.add(line10);
			add(midasLines);

			midasLines.forEach(function(spr:FNFSprite)
			{
				spr.antialiasing = true;
				spr.scrollFactor.set();
				spr.updateHitbox();
			});
		}
	}

	public function createSplash(coolNote:Note)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function push(newNote:Note)
	{
		//
		var chosenGroup = (newNote.isSustainNote ? holdsGroup : notesGroup);
		chosenGroup.add(newNote);
		allNotes.add(newNote);
		chosenGroup.sort(FlxSort.byY, (!Init.trueSettings.get('Downscroll')) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}

	public function midasNoteHit()
	{
		midasAura.alpha = 1;
		FlxTween.tween(midasAura, {alpha: 0}, 0.3, {ease: FlxEase.linear});
	}

	public function midasVignette()
	{
		//
	}
}
