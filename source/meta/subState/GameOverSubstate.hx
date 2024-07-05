package meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;
import meta.subState.UnownSubstate;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var stageSuffix:String = '';
	var daBf:String = 'bf-dead';

	public function new(x:Float, y:Float)
	{
		
		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case 'chase' | 'pandemonium':
				daBf = 'bfMinecartDead';
				stageSuffix = '_cave';
			case 'temper' | 'temper-x':
				daBf = 'bfTemperDeath';
				stageSuffix = '_temper';
		}

		super();

		openfl.Lib.application.window.title = 'Vs. CDD Forever - Game Over';
		Conductor.songPosition = 0;

		bf = new Boyfriend();
		bf.setCharacter(x, y + PlayState.boyfriend.height, daBf);
		add(bf);

		if (PlayState.SONG.song.toLowerCase() == 'chronomatron' && PlayState.unowning)
		{
			var unownWord:FlxText = new FlxText(bf.x, bf.y-100, 0, UnownSubstate.selectedWord);
			unownWord.setFormat(Paths.font("metro.otf"), 56, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(unownWord);
			PlayState.unowning = false;
		}

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		if (stageSuffix == '')
			FlxG.sound.play(Paths.sound('lose/fnf_loss_sfx'));
		else
			FlxG.sound.play(Paths.sound('lose/fnf_loss_sfx' + stageSuffix));

		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			openfl.Lib.application.window.title = 'Vs. CDD Forever';
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				if (PlayState.SONG.song.toLowerCase() == 'asf')
					Main.switchState(this, new FreeplayState());
				else
					Main.switchState(this, new StoryMenuState());
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music('gameOver'));

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
