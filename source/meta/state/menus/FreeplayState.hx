package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];
	var existingSongs:Array<String> = [];
	var iconArray:Array<HealthIcon> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;

	var overStuff:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>();

	var curSelected:Int = 0;
	static var storySelect:Int = 0;
	static var bonusSelect:Int = 0;

	var curSongPlaying:Int = -1;

	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;
	var curPlaying:Bool = false;

	var mainColor = FlxColor.WHITE;
	var colorTwn:FlxTween;
	var scoreBG:FlxSprite;

	public static var story:Bool = true;
	public static var curSongBPM:Float;
	public static var changedMenuSong:Bool = false;

	final boxWidth = 285;
	var optionShit:Array<String> = ['historia', 'bonus'];
	var menuItems:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var boxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var htags:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	var sideSelectin:Bool = true;
	var sideSelection:Int = 0;

	override function create()
	{
		super.create();
		mutex = new Mutex();

		#if !html5
		Discord.changePresence('En los Menús:', 'Menú de Freeplay');
		#end

		//story = Init.trueSettings.get('fpStory');

		var bg1 = new FlxSprite();
		bg1.makeGraphic(FlxG.width, FlxG.height, 0xff313338);
		add(bg1);

		var bg2 = new FlxSprite();
		bg2.makeGraphic(328, FlxG.height, 0xff2b2d31);
		add(bg2);

		var menutxt:FlxText = new FlxText(35, 140, 550, 'JUEGO LIBRE');
		menutxt.setFormat(Paths.font("unisans.otf"), 42, 0xff8b8d92, LEFT);
		menutxt.antialiasing = true;
		add(menutxt);

		add(boxes);
		add(menuItems);
		add(htags);

		for (i in 0...optionShit.length)
		{
			var box:FlxSprite = new FlxSprite(20, (64 * i) + 200);
			box.makeGraphic(boxWidth, 55, 0xff35373c);
			box.visible = false;

			var menuItem:FlxText = new FlxText(80, (64 * i) + 200, 500, optionShit[i]);
			menuItem.setFormat(Paths.font("whitneymedium.otf"), 40, FlxColor.WHITE, LEFT);
			menuItem.alpha = 0.6;

			var htag:FlxText = new FlxText(35, (64 * i) + 195, 450, '#');
			htag.setFormat(Paths.font("whitneymedium.otf"), 50, FlxColor.WHITE, LEFT);
			htag.alpha = 0.6;

			menuItem.ID = i;
			htag.ID = i;
			box.ID = i;

			// añade los items del menu a los grupos
			boxes.add(box);
			box.scrollFactor.set();
			box.antialiasing = true;
			box.updateHitbox();

			htags.add(htag);
			htag.scrollFactor.set();
			htag.antialiasing = true;
			htag.updateHitbox();

			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
		}

		// LOAD THE TEXTS
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		loadSongsArray();

		add(overStuff);

		var headerBG:FlxSprite = new FlxSprite(328, 0);
		headerBG.makeGraphic(FlxG.width, 115, 0xff313338);
		headerBG.antialiasing = true;
		overStuff.add(headerBG);

		var line:FlxSprite = new FlxSprite(0, 115);
		line.makeGraphic(FlxG.width, 4, 0xff27282d);
		line.antialiasing = true;
		overStuff.add(line);

		var cddtxt:FlxText = new FlxText(35, 15, 550, 'Vs. CDD');
		cddtxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		cddtxt.antialiasing = true;
		overStuff.add(cddtxt);

		var channeltag = new FlxText(350, 0, 550, '#');
		channeltag.setFormat(Paths.font("whitneymedium.otf"), 90, 0xff8b8d92, LEFT);
		channeltag.antialiasing = true;
		overStuff.add(channeltag);

		var channeltxt = new FlxText(channeltag.x + 80, 10, 550, 'juego-libre');
		channeltxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		channeltxt.antialiasing = true;
		overStuff.add(channeltxt);

		var poopLine:FlxSprite = new FlxSprite(channeltxt.x + 380, 30);
		poopLine.makeGraphic(4, 60, 0xff3f4147);
		overStuff.add(poopLine);

		scoreText = new FlxText(poopLine.x + 55, 35, 0, 'Mejor puntaje: 000000');
		scoreText.setFormat(Paths.font("whitneymedium.otf"), 40, 0xff8b8d92, RIGHT);
		overStuff.add(scoreText);

		goBackToSide();
	}

	function loadSongsArray()
	{
		songs = [];
		existingSongs = [];

		for (icon in iconArray)
			icon.destroy();
		iconArray = [];

		for (song in grpSongs)
			song.destroy();
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');
		var mainSongs:Array<String> = ['skullody',
		'coffee','spring','rules',
		'deadbush','necron','gaming',
		'goop','chase','pandemonium',
		'edge','absolution','temper'];
		for (i in mainSongs)
			folderSongs.remove(i);

		if (story)
		{
			curSelected = storySelect;
			for (i in 0...Main.gameWeeks.length)
			{
				addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
				for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
					existingSongs.push(j.toLowerCase());
			}
		}
		else
		{
			curSelected = bonusSelect;
			for (i in folderSongs)
			{
				if (!existingSongs.contains(i.toLowerCase()))
				{
					var icon:String = 'face';
					var freeplayColor:FlxColor = FlxColor.WHITE;
					var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
					if (chartExists)
					{
						var castSong:SwagSong = Song.loadFromJson(i, i);
						icon = (castSong != null) ? castSong.player2 : 'face';

						if (CoolUtil.spaceToDash(castSong.song.toLowerCase()) == 'succionar')
							icon = 'face';

						if (Init.trueSettings.get('asfUnlock'))
							addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, freeplayColor);
						else if (castSong.song.toLowerCase() != 'asf')
							addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, freeplayColor);
					}
				}
			}
		}

		remove(overStuff);
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(475, (70 * i) + 30, songs[i].songName, true, false, 0.8);
			songText.isMenuItem = true;
			songText.disableX = true;
			songText.targetY = i;
			songText.xTo = 475;
			songText.alpha = 0.6;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false, 0.8);
			icon.sprTracker = songText;
			icon.alpha = 0.6;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
		add(overStuff);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
		songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (accepted)
		{
			if (sideSelectin)
			{
				sideSelectin = false;
				FlxG.sound.play(Paths.sound('menu/confirmMenu'));
				flashSideItem();
				changeSelection();
			}
			else
			{
				var poop:String = songs[curSelected].songName.toLowerCase();

				PlayState.SONG = Song.loadFromJson(poop, poop);
				PlayState.isStoryMode = false;
				PlayState.seenCutscene = false;
				PlayState.storyDifficulty = 1;
				PlayState.songsPlayed = 0;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);

				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				threadActive = false;

				Main.switchState(this, new PlayState(), true);
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			if (sideSelectin)
			{
				threadActive = false;
				Main.switchState(this, new MainMenuState());
			}
			else
				goBackToSide();
		}

		// primer mod en tener un morbillon de puntos
		scoreText.text = "Mejor puntaje: " + lerpScore;
		//scoreText.x = FlxG.width - scoreText.width - 5;

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();
	}

	function changeSelection(change:Int = 0)
	{
		if (sideSelectin)
		{
			if (change != 0)
				FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.8);

			sideSelection += change;

			// wrap selections
			if (sideSelection < 0)
				sideSelection = optionShit.length - 1;
			if (sideSelection >= optionShit.length)
				sideSelection = 0;

			// update items lol
			for (item in boxes.members)
			{
				if (item.ID == sideSelection)
					item.visible = true;
				else
					item.visible = false;
			}
			for (item in menuItems.members)
			{
				if (item.ID == sideSelection)
					item.alpha = 1;
				else
					item.alpha = 0.6;
			}
			for (item in htags.members)
			{
				if (item.ID == sideSelection)
					item.alpha = 1;
				else
					item.alpha = 0.6;
			}

			switch (sideSelection)
			{
				case 0:
					story = true;
				case 1:
					story = false;
			}
			loadSongsArray();
		}
		else
		{
			if (change != 0)
				FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.5);

			curSelected += change;

			// wrap selections
			if (curSelected < 0)
				curSelected = songs.length - 1;
			if (curSelected >= songs.length)
				curSelected = 0;

			// save selection
			if (story)
				storySelect = curSelected;
			else
				bonusSelect = curSelected;

			intendedScore = Highscore.getScore(songs[curSelected].songName, 1);

			// song switching stuffs
			var bullShit:Int = 0;
			for (i in 0...iconArray.length)
				iconArray[i].alpha = 0.6;

			iconArray[curSelected].alpha = 1;
			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}

			trace("curSelected: " + curSelected);

			changeSongPlaying();
		}
	}

	public static var epicSong:SwagSong;
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

							// var inst:Sound = Paths.inst(songs[curSelected].songName);
							var poop:String = songs[curSelected].songName.toLowerCase();

							epicSong = Song.loadFromJson(poop, poop);

							curSongBPM = epicSong.bpm;
							if (epicSong.song == 'succionar')
								Conductor.changeBPM(420);
							else
								Conductor.changeBPM(curSongBPM);

							var inst:Sound = Paths.inst(epicSong.song);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
								changedMenuSong = true;
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

	function goBackToSide()
	{
		sideSelectin = true;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		for (item in grpSongs.members)
			item.alpha = 0.6;

		changeSelection();
	}

	function flashSideItem()
	{
		for (item in boxes.members)
		{
			if (item.ID == sideSelection)
			{
				FlxFlicker.flicker(item, 0.5, 0.06 * 2, true, false);
				item.makeGraphic(boxWidth, 55, 0xff35373c);
			}
		}

		for (item in menuItems.members)
		{
			if (item.ID == sideSelection)
			{
				FlxFlicker.flicker(item, 0.5, 0.06 * 2, true, false);
				item.alpha = 0.6;
			}
		}

		for (item in htags.members)
		{
			if (item.ID == sideSelection)
			{
				FlxFlicker.flicker(item, 0.5, 0.06 * 2, true, false);
				item.alpha = 0.6;
			}
		}
	}

}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
