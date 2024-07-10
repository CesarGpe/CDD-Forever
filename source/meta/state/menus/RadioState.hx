package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Character;
import gameObjects.userInterface.HealthIcon;
import meta.MusicBeat.MusicBeatState;
import meta.data.Conductor;
import meta.data.Song;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import meta.state.menus.FreeplayState.SongMetadata;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class RadioState extends MusicBeatState
{
	var curSongPlaying:Int = -1;
	var curSelected:Int = 0;

	var threadActive:Bool = true;
	var songThread:Thread;
	var mutex:Mutex;
	
	var songInst:FlxSound = new FlxSound();
	var songVocals:FlxSound = new FlxSound();

	var playVocals:Bool = true;
	var pauseMusic:Bool = false;
	var songs:Array<SongMetadata> = [];
	var radioSongs:Array<String> = [
		'skullody',
		'coffee','spring','rules',
		'deadbush','necron','gaming',
		'goop','chase','pandemonium',
		'edge','absolution','temper',
		'temper-x', 'memories',
	];

	var epicSong:SwagSong;
	var groovy:FNFSprite;
	var vocTxt:FlxText;
	var volTxt:FlxText;
	var gText:FlxText;
	var gf:Character;

	var volTween:FlxTween;
	var vocTween:FlxTween;
	var prevTween:FlxTween;
	var nextTween:FlxTween;
	var playTween:FlxTween;
	var pauseTween:FlxTween;

	var playIcon:FlxSprite;
	var pauseIcon:FlxSprite;
	var prevIcon:FlxSprite;
	var nextIcon:FlxSprite;

	override function create()
	{
		super.create();
		mutex = new Mutex();

		FlxG.sound.list.add(songInst);
		FlxG.sound.list.add(songVocals);

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xff313338);
		bg.screenCenter();
		add(bg);

		//var topBar:FlxSprite = new FlxSprite(0, -20);
		//topBar.makeGraphic(FlxG.width, Std.int(FlxG.height * (1 / 6)), 0xff232428);
		//add(topBar);

		var sepLine:FlxSprite = new FlxSprite(0, 115);
		sepLine.makeGraphic(FlxG.width, 4, 0xff27282d);
		add(sepLine);

		var channeltag:FlxText = new FlxText(30, 0, 550, '#');
		channeltag.setFormat(Paths.font("whitneymedium.otf"), 90, 0xff8b8d92, LEFT);
		channeltag.antialiasing = true;
		add(channeltag);

		var channeltxt:FlxText = new FlxText(110, 15, 550, 'rockola');
		channeltxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		channeltxt.antialiasing = true;
		add(channeltxt);

		var poopLine:FlxSprite = new FlxSprite(373, 30);
		poopLine.makeGraphic(4, 60, 0xff3f4147);
		add(poopLine);

		var channeltxt:FlxText = new FlxText(420, 30, 0, 'Escucha el soundtrack de Vs. CDD!');
		channeltxt.setFormat(Paths.font("whitneymedium.otf"), 50, 0xff8b8d92, LEFT);
		channeltxt.antialiasing = true;
		add(channeltxt);

		var subBar:FlxSprite = new FlxSprite(0, 620);
		subBar.makeGraphic(FlxG.width, Std.int(FlxG.height * (1/6)), 0xff232428);
		add(subBar);

		var dirTxt:FlxText = new FlxText(120, 385, 0, 'IZQUIERDA/DERECHA: Cambiar canciones\nARRIBA/ABAJO: Cambiar volumen\nESPACIO: Pausar y reanudar\nENTER: Alternar vocales');
		dirTxt.setFormat(Paths.font("whitneybook.otf"), 25, FlxColor.WHITE, FlxTextAlign.LEFT);
		dirTxt.scrollFactor.set();
		dirTxt.antialiasing = true;
		add(dirTxt);

		volTxt = new FlxText(0, FlxG.height - 65, 0, 'Volumen: 100%');
		volTxt.setFormat(Paths.font("whitneymedium.otf"), 30, FlxColor.WHITE, FlxTextAlign.CENTER);
		volTxt.scrollFactor.set();
		volTxt.updateHitbox();
		volTxt.x = FlxG.width - volTxt.width - 25;
		volTxt.antialiasing = true;
		volTxt.alpha = 0.5;
		add(volTxt);

		vocTxt = new FlxText(25, FlxG.height - 65, 0, 'Vocales: O');
		vocTxt.setFormat(Paths.font("whitneymedium.otf"), 30, FlxColor.WHITE, FlxTextAlign.CENTER);
		vocTxt.scrollFactor.set();
		vocTxt.updateHitbox();
		vocTxt.antialiasing = true;
		vocTxt.alpha = 0.5;
		add(vocTxt);

		pauseIcon = new FlxSprite(0, FlxG.height - 78);
		pauseIcon.loadGraphic(Paths.image('menus/radio/pause'));
		pauseIcon.setGraphicSize(Std.int(pauseIcon.width * 0.25), Std.int(pauseIcon.height * 0.25));
		pauseIcon.updateHitbox();
		pauseIcon.antialiasing = true;
		pauseIcon.screenCenter(X);
		pauseIcon.x -= 5;
		pauseIcon.alpha = 0.5;
		add(pauseIcon);

		playIcon = new FlxSprite(0, FlxG.height - 78);
		playIcon.loadGraphic(Paths.image('menus/radio/play'));
		playIcon.setGraphicSize(Std.int(playIcon.width * 0.25), Std.int(playIcon.height * 0.25));
		playIcon.updateHitbox();
		playIcon.antialiasing = true;
		playIcon.screenCenter(X);
		playIcon.alpha = 0;
		add(playIcon);

		prevIcon = new FlxSprite(0, FlxG.height - 78);
		prevIcon.loadGraphic(Paths.image('menus/radio/skip'));
		prevIcon.setGraphicSize(Std.int(prevIcon.width * 0.25), Std.int(prevIcon.height * 0.25));
		prevIcon.updateHitbox();
		prevIcon.antialiasing = true;
		prevIcon.screenCenter(X);
		prevIcon.flipX = true;
		prevIcon.x -= 90;
		prevIcon.alpha = 0.5;
		add(prevIcon);

		nextIcon = new FlxSprite(0, FlxG.height - 78);
		nextIcon.loadGraphic(Paths.image('menus/radio/skip'));
		nextIcon.setGraphicSize(Std.int(nextIcon.width * 0.25), Std.int(nextIcon.height * 0.25));
		nextIcon.updateHitbox();
		nextIcon.antialiasing = true;
		nextIcon.screenCenter(X);
		nextIcon.x += 80;
		nextIcon.alpha = 0.5;
		add(nextIcon);

		gf = new Character();
		gf.adjustPos = false;
		gf.setCharacter(570, 10, 'reimu');
		gf.setGraphicSize(Std.int(gf.width * 0.6), Std.int(gf.height * 0.6));
		gf.updateHitbox();
		gf.dance(true);
		gf.dance(true);
		add(gf);

		groovy = new FNFSprite(80, 140);
		groovy.frames = Paths.getSparrowAtlas('backgrounds/discord/groovySong');
		groovy.animation.addByPrefix('left', 'bganimated_1', 24, false);
		groovy.animation.addByPrefix('right', 'bganimated_2', 24, false);
		groovy.setGraphicSize(Std.int(groovy.width * 0.5), Std.int(groovy.height * 0.5));
		groovy.updateHitbox();
		add(groovy);

		gText = new FlxText(140, 295, 0, 'Now playing: Skullody');
		gText.setFormat(Paths.font("whitneybook.otf"), 40, FlxColor.WHITE);
		gText.updateHitbox();
		add(gText);

		var black:FlxSprite = new FlxSprite();
		black.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.screenCenter();
		add(black);

		var introTxt:FlxText = new FlxText(30, FlxG.height - 685, 0, 'Sincronizando audio...');
		introTxt.setFormat(Paths.font("whitneybook.otf"), 30, FlxColor.WHITE, FlxTextAlign.CENTER);
		introTxt.antialiasing = true;
		add(introTxt);

		// ASF en la rokola si lo tienes desbloqueado
		if (Init.trueSettings.get('asfUnlock'))
			radioSongs.push('asf');

		// añadir cancionesss verga
		for (song in radioSongs)
			songs.push(new SongMetadata(song, 1, '', FlxColor.WHITE));

		#if !html5
		Discord.changePresence('En la rockola:', 'Sincronizando audio...');
		#end

		FlxG.sound.music.fadeOut(1.5, 0);
		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			FlxTween.tween(black, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
			FlxTween.tween(introTxt, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
		});

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = songInst.time;
			//Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		mutex.acquire();

		// cambiar canciones
		if (FlxG.keys.justPressed.LEFT)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.RIGHT)
			changeSelection(1);

		// cambiar volumen
		if (FlxG.keys.pressed.UP)
			changeVolume(0.01);
		else if (FlxG.keys.pressed.DOWN)
			changeVolume(-0.01);

		// pausar y reanudar
		if (FlxG.keys.justPressed.SPACE && epicSong != null)
		{
			pauseMusic = !pauseMusic;
			if (pauseMusic)
				pauseSong();
			else
				resumeSong();
		}

		// alternar voces
		if (FlxG.keys.justPressed.ENTER && epicSong != null && epicSong.needsVoices)
		{
			playVocals = !playVocals;
			songVocals.volume = (playVocals) ? songInst.volume : 0;
			vocTxt.text = 'Vocales: ' + ((playVocals) ? 'O' : 'X');

			vocTxt.alpha = 1;
			if (vocTween != null) vocTween.cancel();
			vocTween = FlxTween.tween(vocTxt, {alpha: 0.5}, 0.5, {ease: FlxEase.quadInOut});
		}

		// regresar al menu principal
		if (controls.BACK)
		{
			threadActive = false;
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));

			songInst.destroy();
			songVocals.destroy();

			MainMenuState.resetMusic = true;
			Main.switchState(this, new MainMenuState());
		}

		mutex.release();
	}

	function changeVolume(change:Float = 0)
	{
		songInst.volume += change;
		if (playVocals)
			songVocals.volume = songInst.volume;

		volTxt.alpha = 1;
		volTxt.text = 'Volumen: ' + Std.int(songInst.volume * 100) + '%';

		if (volTween != null) volTween.cancel();
		volTween = FlxTween.tween(volTxt, {alpha: 0.5}, 0.5, {ease: FlxEase.quadInOut});
		
	}

	function pauseSong()
	{
		songInst.pause();
		songVocals.pause();

		pauseIcon.alpha = 1;

		if (playTween != null) playTween.cancel();
		playTween = FlxTween.tween(playIcon, {alpha: 0.5}, 0.25, {ease: FlxEase.quadInOut});

		if (pauseTween != null) pauseTween.cancel();
		pauseTween = FlxTween.tween(pauseIcon, {alpha: 0}, 0.25, {ease: FlxEase.quadInOut});
	}

	function resumeSong()
	{
		resyncVocals();

		playIcon.alpha = 1;

		if (playTween != null) playTween.cancel();
		playTween = FlxTween.tween(playIcon, {alpha: 0}, 0.25, {ease: FlxEase.quadInOut});

		if (pauseTween != null) pauseTween.cancel();
		pauseTween = FlxTween.tween(pauseIcon, {alpha: 0.5}, 0.25, {ease: FlxEase.quadInOut});
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.6);

		curSelected += change;
		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		trace("curSelected: " + curSelected);

		if (change == 1) {
			nextIcon.alpha = 1;
			if (nextTween != null) nextTween.cancel();
			nextTween = FlxTween.tween(nextIcon, {alpha: 0.5}, 0.25, {ease: FlxEase.quadInOut});
		} else {
			prevIcon.alpha = 1;
			if (prevTween != null) prevTween.cancel();
			prevTween = FlxTween.tween(prevIcon, {alpha: 0.5}, 0.25, {ease: FlxEase.quadInOut});
		}
		
		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							songInst.stop();
							songVocals.stop();

							var poop:String = songs[curSelected].songName.toLowerCase();

							epicSong = Song.loadFromJson(poop, poop);
							Conductor.changeBPM(epicSong.bpm);
							
							if (index == curSelected && threadActive)
							{
								mutex.acquire();

								loadSong();
								if (pauseMusic && songInst != null && songVocals != null)
								{
									songInst.pause();
									songVocals.pause();
								}
								else
									resyncVocals();

								mutex.release();

								curSongPlaying = curSelected;
								gText.text = 'Now playing: ' + CoolUtil.dashToSpace(epicSong.song);

								#if !html5
								Discord.changePresence('En la rockola:', 'Escuchando ' + CoolUtil.dashToSpace(epicSong.song));
								#end
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	function loadSong()
	{
		songInst.loadEmbedded(Paths.inst(epicSong.song));
		songVocals.loadEmbedded(Paths.voices(epicSong.song));

		songInst.looped = true;

		if (songInst != null)
		{
			songInst.play();
			songInst.onComplete = resyncVocals;
		}
		if (songVocals != null)
		{
			songVocals.play();
			songVocals.volume = (playVocals) ? songInst.volume : 0;
		}
	}

	/*function restartSong()
	{
		trace('Restarting song');
		if (epicSong != null)
		{
			mutex.acquire();



			songInst.destroy();
			songVocals.destroy();

			resyncVocals(true);

			mutex.release();
		}
	}*/

	function resyncVocals()
	{
		songInst.pause();
		songVocals.pause();
		Conductor.songPosition = songInst.time;
		songVocals.time = Conductor.songPosition;
		songInst.play();
		songVocals.play();
	}

	private var danced:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		trace('beat: ' + curBeat);
		
		//if (!pauseMusic)
		//{
			gf.dance(true);

			danced = !danced;
			if (danced)
				groovy.animation.play('left', true);
			else
				groovy.animation.play('right', true);
		//}

	}

}