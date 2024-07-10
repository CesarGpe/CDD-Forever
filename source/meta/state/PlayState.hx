package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.ClassHUD;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import hxcodec.flixel.FlxVideo;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.events.KeyboardEvent;

using StringTools;

#if !html5
import meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;

	public static var misses:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var endingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;

	public static var seenCutscene:Bool = false;

	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result
	public static var cameraSpeed:Float = 1;

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	// strumlines
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;
	// enable/disable the rating combo and number
	var showRatings:Bool = true;

	// makes the camera bump with the beat
	public var bumpThing:Bool;

	// moves the camera with the notes
	var camDisplaceExtend:Float = 15;

	// mas cosas de la camara que usa CDD
	var stopCharZooms:Bool = false;
	var lockedCameraPos:Bool = false;
	var canBump:Bool = true;

	//* SKULLODY
	var sans:FlxSprite; //sans e e e e
	var lag:Bool = false;

	//* CHRONOMATRON
	public static var minHealth:Float = 0.0; // esto te mata
	public static var unowning:Bool = false; // unowon :3
	// quien escribio eso sal de mi cabeza sal de mi cabeza sal de mi cabeza

	//* saltar intros largas de canciones en freeplay
	var skipTimer:FlxTimer = null;
	var skipTxt:FlxText;
	var skipTime:Int;
	var canSkip:Bool;
	var longIntro:Bool;

	// timer de las notas muteadas
	var muteTimer:FlxTimer = null;

	// pipi popo caca
	public static var songsPlayed:Int = 0;

	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// reset any values and variables that are static
		unowning = false;
		minHealth = 0;
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		defaultCamZoom = 1.05;
		cameraSpeed = 1;
		forceZoom = [0, 0, 0, 0];

		// sets up the combo object array
		lastCombo = [];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// camara para el dialogo se añade hasta el final
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;

		// oh no!! la cagaste!! no te preocupes el hijo de su puta madre esta aqui para evitar que el juego no crashee
		if (SONG == null)
			SONG = Song.loadFromJson('skullody', 'skullody');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";
		
		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache shit
		displayRating('sick', 'early', true);
		popUpCombo(true);
		//

		stageBuild = new Stage(curStage);
		add(stageBuild);

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene,
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised
			engine for both myself and other modders to use!
		 */

		// set up characters here too
		gf = new Character();
		gf.adjustPos = false;
		gf.setCharacter(300, 100, stageBuild.returnGFtype(curStage));

		// cosas para el principio de cada cancion aqui en un solo lugar
		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case 'memories' | 'razortrousle' | 'temper-x':
				gf.setCharacter(300, 100, 'reimu');

			case 'pelea-en-la-calle-tres':
				camDisplaceExtend = 0;
				
			case 'skullody':
				// evento de sans
				sans = new FlxSprite();
				sans.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				sans.updateHitbox();
				sans.screenCenter();
				sans.alpha = 0;
				add(sans);

				// proyecto oriental
				gf.setCharacter(300, 100, 'reimu');
				Paths.getSparrowAtlas('characters/mari');
				FlxG.sound.cache(Paths.sound('event/touhou'));
				Paths.sound('event/touhou');

			case 'spring' | 'deadbush' | 'chronomatron':
				// canciones con intro larga
				if (!isStoryMode)
				{
					longIntro = true;
					skipTxt = new FlxText(0, (FlxG.height - 200), 0, 'Pulsa SHIFT para saltar.');
					skipTxt.setFormat(Paths.font('pixel.otf'), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					skipTxt.cameras = [dialogueHUD];
					skipTxt.scrollFactor.set();
					skipTxt.screenCenter(X);
					skipTxt.borderSize = 3;
					skipTxt.alpha = 0;
					add(skipTxt);

					switch (PlayState.SONG.song.toLowerCase())
					{
						case 'spring':
							skipTime = 27;
						case 'deadbush':
							skipTime = 23;
						case 'chronomatron':
							skipTime = 11;
							canBump = false;
							camHUD.visible = false;
							showRatings = false;
							UnownSubstate.init();
					}
					
				}
		}

		dadOpponent = new Character().setCharacter(50, 850, SONG.player2);
		boyfriend = new Boyfriend();
		boyfriend.setCharacter(750, 850, SONG.player1); // culo
		// ! if you want to change characters later use setCharacter() instead of new or it will break

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);

		if (gf.curCharacter == 'reimu' || curStage == 'discordEvil')
			gf.y += 40;

		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';

		// add characters
		add(gf);
		add(dadOpponent);
		add(boyfriend);

		add(stageBuild.foreground);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// te muteaste desde el menu principal
		boyfriend.stunned = MainMenuState.muted;

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		if ((curStage != 'secret') && (curStage != 'lost'))
			FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		if (curStage == 'secret')
		{
			boyfriendStrums = new Strumline(placement, this, boyfriend, true, false, true, 4, Init.trueSettings.get('Downscroll'));
			dadStrums = new Strumline(placement, this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
			dadStrums.visible = true;
		}
		else
		{
			boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Notas centradas') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true, 4, Init.trueSettings.get('Downscroll'));
			dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
			dadStrums.visible = !Init.trueSettings.get('Notas centradas');
		}
		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			//strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		if (PlayState.SONG.song.toLowerCase() == 'chronomatron')
			strumLines.visible = false;

		add(stageBuild.aboveNote);
		stageBuild.aboveNote.cameras = [strumHUD[1]];
		
		add(stageBuild.aboveHUD);
		stageBuild.aboveHUD.cameras = [camHUD];

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];

		// ya añade la camara a lo ultimo
		FlxG.cameras.add(dialogueHUD);

		//
		keysArray = [
			copyKey(Init.gameControls.get('LEFT')[0]),
			copyKey(Init.gameControls.get('DOWN')[0]),
			copyKey(Init.gameControls.get('UP')[0]),
			copyKey(Init.gameControls.get('RIGHT')[0])
		];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
		Paths.clearUnusedMemory();
		openfl.Lib.application.window.title = 'Vs. CDD Forever - ' + (CoolUtil.dashToSpace(PlayState.SONG.song));

		// call the funny intro cutscene depending on the song
		if (showCutscenes())
			songIntroCutscene();
		else
			startCountdown();
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
	
	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !boyfriend.stunned
			&& !boyfriendStrums.autoplay
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				boyfriendStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable) {
							goodNoteHit(coolNote, boyfriend, boyfriendStrums, firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!Init.trueSettings.get('Ghost Tapping'))
						missNoteCheck(true, key, boyfriend, true);
				Conductor.songPosition = previousTime;
			}

			if (boyfriendStrums.receptors.members[key] != null 
			&& boyfriendStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				boyfriendStrums.receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			// receptor reset
			if (key >= 0 && boyfriendStrums.receptors.members[key] != null)
				boyfriendStrums.receptors.members[key].playAnim('static');
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		//stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		super.update(elapsed);

		if (lag)
			dadOpponent.animation.play('still', false);

		if (health > 2)
			health = 2;

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive) {
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT)
				dialogueBox.closeDialog();

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT && dialogueBox.textStarted)
			{
				FlxG.sound.play(Paths.sound('menu/cancelMenu'));
				dialogueBox.curPage += 1;

				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}

		}

		if (!inCutscene) {
			// pause the game if the game is allowed to pause and enter is pressed
			if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			{
				// update drawing stuffs
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// open pause substate
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				updateRPC(true);
			}

			// saltar la cancion al segundo indicado
			if (FlxG.keys.justPressed.SHIFT && canSkip && longIntro && !startingSong)
			{
				canSkip = false;
				longIntro = false;
				skipTimer.cancel();

				vocals.time = skipTime*1000;
				songMusic.time = skipTime*1000;
				FlxG.sound.music.time = skipTime*1000;
				Conductor.songPosition = skipTime*1000;
				resyncVocals();

				FlxTween.tween(skipTxt, {alpha: 0}, 0.25, {ease: FlxEase.quadInOut, type: ONESHOT});
				FlxG.sound.play(Paths.sound('menu/click'));
				camGame.flash(FlxColor.CYAN, 0.25);
			}

			if (health <= minHealth && !startingSong && !boyfriendStrums.autoplay)
				die();

			if (controls.RESET && !startingSong && !unowning)
				die();

			// cosas del modo debug bien padre a la verga
			if (Init.trueSettings.get('Modo Debug'))
			{
				if (FlxG.keys.justPressed.ONE && !startingSong)
					endSong();
				
				if (FlxG.keys.justPressed.SIX)
					boyfriendStrums.autoplay = !boyfriendStrums.autoplay;

				if (FlxG.keys.justPressed.SEVEN && !startingSong)
				{
					resetMusic();
					Main.switchState(this, new ChartingState());
				}
			}

			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}

			// boyfriend.playAnim('singLEFT', true);
			// */

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				var curSection = Std.int(curStep / 16);
				if (curSection != lastSection) {
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit) {
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}

				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					var char = dadOpponent;

					if (curSong.toLowerCase() == 'pelea en la calle tres' && !stopCharZooms)
						FlxTween.tween(camGame, {zoom: 0.65}, 0.1, {ease: FlxEase.linear});

					// ASF zoom
					if (curSong.toLowerCase() == 'asf')
					{
						camDisplaceExtend = 50;
						defaultCamZoom = 0.9;
					}
						
					var getCenterX = char.getMidpoint().x + 100;
					var getCenterY = char.getMidpoint().y - 100;

					camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);

					if (char.curCharacter == 'mom')
						vocals.volume = 1;
				}
				else
				{
					var char = boyfriend;

					if (curSong.toLowerCase() == 'pelea en la calle tres' && !stopCharZooms)
						FlxTween.tween(camGame, {zoom: 1}, 0.1, {ease: FlxEase.linear});

					// ASF zoom
					if (curSong.toLowerCase() == 'asf')
					{
						camDisplaceExtend = 0;
						defaultCamZoom = 0.8;
					}
	
					var getCenterX = char.getMidpoint().x - 100;
					var getCenterY = char.getMidpoint().y - 100;
					switch (curStage)
					{
						case 'limo':
							getCenterX = char.getMidpoint().x - 300;
						case 'mall':
							getCenterY = char.getMidpoint().y - 200;
						case 'school':
							getCenterX = char.getMidpoint().x - 200;
							getCenterY = char.getMidpoint().y - 200;
						case 'schoolEvil':
							getCenterX = char.getMidpoint().x - 200;
							getCenterY = char.getMidpoint().y - 200;
					}

					camFollow.setPosition(getCenterX + camDisplaceX - char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);
				}
			}

			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			if (!lockedCameraPos)
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 0.95;
			// camera stuffs
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
			for (hud in allUIs)
				hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			// discord stuffs should go here
			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			noteCalls();
		}

	}

	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			var i = 0;
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.trueSettings.get('Downscroll'))
					downscrollMultiplier = -1;
				
				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote) {
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null)) {
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (Init.trueSettings.get('Downscroll')) {
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY) {
									// set the end hold offset yeah I hate that I fix this like this
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
									trace(daNote.endHoldOffset);
								}
								else
									daNote.y += daNote.endHoldOffset;
							} else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}
						
						if (Init.trueSettings.get('Downscroll'))
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit) 
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height) {
						daNote.active = false;
						daNote.visible = false;
					} else {
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit && daNote.noteType != 1)
					{
						if ((!daNote.tooLate) && (daNote.mustPress)) {
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;
								
								vocals.volume = 0;
								missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true, false, daNote.noteType);
								// ambiguous name
								Timings.updateAccuracy(0);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true, false, daNote.noteType);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					
					}

					// if the note is off screen (above)
					if ((((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
					|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
					&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
				});


				// unoptimised camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == boyfriendStrums));
			}
			
		}
		
		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000)
			&& (!holdControls.contains(true) || boyfriendStrums.autoplay)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}


	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit) {
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			if (coolNote.noteType == 1)
			{
				//decreaseCombo(true);
				if (boyfriend.stunned)
					muteTimer.reset();
				else
				{
					FlxG.sound.play(Paths.sound('event/discord/mute'));
					boyfriend.playAnim('muted', true);
					boyfriend.stunned = true;
					boyfriendStrums.receptors.forEach(function(arrow:UIStaticArrow)
					{
						arrow.color = 0xffff4a4a;
					});
					muteTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						boyfriend.dance();
						boyfriend.stunned = false;
						FlxG.sound.play(Paths.sound('event/discord/unmute'));
						boyfriendStrums.receptors.forEach(function(arrow:UIStaticArrow)
						{
							arrow.color = FlxColor.WHITE;
						});
					});
				}
			}

			characterPlayAnimation(coolNote, character);
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);
	
			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (canDisplayJudgement && coolNote.noteType != 1) {
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote && coolNote.noteType != 1) {
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, ratingTiming, characterStrums, coolNote);
					if (coolNote.childrenNotes.length > 0)
						Timings.notesHit++;
					healthCall(Timings.judgementsMap.get(foundRating)[3]);
				} else if (coolNote.isSustainNote) {
					// call updated accuracy stuffs
					if (coolNote.parentNote != null) {
						Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
						healthCall(100 / coolNote.parentNote.childrenNotes.length);
					}
				}
			}

			if (!coolNote.isSustainNote)
				destroyNote(characterStrums, coolNote);
			//
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false, noteStyle:Int = 0)
	{
		if (noteStyle != 1)
		{
			if (includeAnimation)
			{
				var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

				FlxG.sound.play(Paths.soundRandom('miss/bad', 1, 3), FlxG.random.float(0.1, 0.2));
				if (!boyfriend.stunned)
					character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
			}

			decreaseCombo(popMiss);
		}
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// esto es el life drain de asf jaja
		if (character == dadOpponent && dadOpponent.curCharacter == 'juan' && health > 0.04)
		{
			if (health > 0.04)
				health -= 0.02;
			if (health > 1)
				bumpCamera(0.03, 0.02);
		}	

		// el gordo de michelin pone un vine boom con cada nota
		if (character == dadOpponent && dadOpponent.curCharacter == 'twelve')
			FlxG.sound.play(Paths.sound('event/twelve/vineBoom'));

		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;
		if (character == dadOpponent)
			character.playAnim(stringArrow, true);
		else
		{
			if (!boyfriend.stunned)
				character.playAnim(stringArrow, true);
		}
		character.holdTimer = 0;
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition && daNote.noteType != 1)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		} 

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if (!autoplay) {
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
					&& coolNote.canBeHit && coolNote.mustPress
					&& !coolNote.tooLate && coolNote.isSustainNote
					&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (Init.trueSettings.get('Movimiento con Notas') || curSong.toLowerCase() == 'asf')
		{
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;
					
					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;

				}
			}
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if !html5
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick" && coolNote.noteType == 0)
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
 			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			if (showRatings)
				add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				if (showRatings)
					add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				if (showRatings)
					add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				if (!cache)
					numScore.cameras = [camHUD];
				numScore.y += 50;
			}
				numScore.x += 100;
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			displayRating("miss", 'late');
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		if (showRatings)
			add(rating);

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			if (showRatings)
				add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null) {
				lastRating.kill();
			}
			if (showRatings)
				add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (!cache) {
			if (Init.trueSettings.get('Fixed Judgements')) {
				// bound to camera
				rating.cameras = [camHUD];
				rating.screenCenter();
			}
			
			// return the actual rating to the array of judgements
			Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

			// set new smallest rating
			if (Timings.smallestRating != daRating) {
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
					Timings.smallestRating = daRating;
			}
		}
	}

	function setRatingsAlhpa(value:Float)
	{
		if (lastRating != null)
			FlxTween.tween(lastRating, {alpha: value}, 1, {ease: FlxEase.quadInOut});

		for (combo in lastCombo)
			FlxTween.tween(combo, {alpha: value}, 1, {ease: FlxEase.quadInOut});
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;
		
		if (longIntro)
		{
			// mostrar el texto y dejar saltar
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxTween.tween(skipTxt, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut, type: ONESHOT});
				canSkip = true;
			});

			// quita el texto si no saltaste
			skipTimer = new FlxTimer().start(skipTime, function(tmr:FlxTimer)
			{
				FlxTween.tween(skipTxt, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut, type: ONESHOT});
				longIntro = false;
				canSkip = false;
			});
		}

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			resyncVocals();

			#if !html5
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}

		// cuando yo la void
		new FlxTimer().start(songLength, function(tmr:FlxTimer) { endSong(); });
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = 'Jugando: ' + CoolUtil.dashToSpace(SONG.song);

		// String for when the game is paused
		detailsPausedText = 'En pausa: ' + CoolUtil.dashToSpace(SONG.song);

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;
		songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song), false, true);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song), false, true);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);
	
		// genera el chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		trace('resyncing vocal time ${vocals.time}');
		songMusic.pause();
		vocals.pause();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		songMusic.play();
		vocals.play();
		trace('new vocal time ${Conductor.songPosition}');
	}

	override function stepHit()
	{
		super.stepHit();
		if (songMusic.time >= Conductor.songPosition + 20 || songMusic.time <= Conductor.songPosition - 20)
			resyncVocals();

		// * =================================================
		// !       EVENTOS EN LAS CANCIONES VAN AQUI !!
		// * =================================================
		// para los rebotes de la camara esos van en la funcion del beatHit()
		// wey a quien fregados le estoy hablando nadie va leer esto
		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			//
			case 'skullody':
				switch (curStep)
				{
					case 192, 320, 384, 576:
						defaultCamZoom = 0.9;
					case 256, 284, 316, 336:
						defaultCamZoom = 0.8;
					case 268, 348, 380, 416, 640:
						defaultCamZoom = 0.75;
					case 272, 332, 352:
						defaultCamZoom = 0.85;
					case 288, 480:
						defaultCamZoom = 0.95;
					case 507:
						defaultCamZoom = 1;
					case 448:
						defaultCamZoom = 1;
						modoSans(true); // e e e
					case 508, 510, 511:
						bumpCamera(0.07, 0.07);
					case 512:
						bumpCamera(0.07, 0.07);
						defaultCamZoom = 0.75;
						modoSans(false); // e e e
					case 677:
						touhou(); // PROYECTO ORIENTAL REFERENCIA
				}
			
			//
			case 'rules':
				switch(curStep)
				{
					case 400, 416, 432, 448, 464, 480, 496, 504, 512, 516, 520, 522, 524, 526, 528, 544, 560, 576, 
						 592, 608, 624, 632, 640, 644, 648, 650, 652, 654, 928, 944, 960, 968, 976, 980, 984, 986, 
						 988, 990, 992, 1008, 1024, 1032, 1040, 1044, 1048, 1050, 1052, 1054, 1056, 1072, 1088, 1096, 
						 1104, 1108, 1112, 1114, 1116, 1118, 1120, 1136, 1152, 1160, 1168, 1172, 1176, 1178, 1180, 1182, 
						 1200, 1232, 1240, 1248, 1252, 1256, 1258, 1260, 1262, 1264, 1296, 1304, 1312, 1316, 1320, 1322,
						 1324, 1326, 1328, 1344, 1360, 1368, 1376, 1380, 1384, 1386, 1388, 1390, 1392, 1408, 1424, 1432, 
						 1440, 1444, 1448, 1450, 1452, 1454, 1456, 1472, 1488, 1496, 1504, 1508, 1512, 1514, 1516, 1518,
						 1520, 1536, 1552, 1560, 1568, 1572, 1576, 1578, 1580, 1582:
						bumpCamera(0.05, 0.05);
						if (defaultCamZoom > 0.75)
							defaultCamZoom = 0.75;
					case 656, 658, 660, 662, 664, 666, 668, 670:
						bumpCamera();
					case 720, 736, 784, 800, 848, 864, 912:
						if (defaultCamZoom == 0.95)
							defaultCamZoom = 0.75;
						else
							defaultCamZoom = 0.95;
					case 1216, 1280:
						bumpCamera(0.05, 0.05);
						defaultCamZoom = 1;
					case 1646, 1648:
						bumpCamera(0.08, 0.08);
				}

			//
			case 'necron':
				switch(curStep)
				{
					case 128:
						bumpCamera(0.05, 0.05);
					case 368, 684, 750, 1472:
						defaultCamZoom = 0.95;
					case 384, 704, 768, 1888:
						defaultCamZoom = 0.75;
					case 448:
						bumpCamera(0.07, 0.07);
					case 1008, 1012, 1016, 1020, 1021, 1022, 1023, 1264, 1268, 1272, 1276, 
						 1277, 1278, 1279, 1396, 1398, 1400, 1404, 1405, 1406, 1407, 1478,
						 1480, 1484, 1488, 1492, 1496, 1504, 1508, 1512, 1516, 1520, 1528, 
						 1532, 1534, 1544, 1552, 1556, 1560, 1562, 1564, 1565, 1566, 1567:
						bumpCamera();
					case 1536:
						defaultCamZoom = 0.75;
						bumpCamera();
					case 1824:
						defaultCamZoom = 0.95;
						cameraSpeed = 3;
					case 2080:
						for (hud in strumHUD)
							FlxTween.tween(hud, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						
						camFollow.setPosition(camFollow.x, camFollow.y - 100);
						dadOpponent.animation.play('tired', true);
						cameraSpeed = 1;
						canBump = false;
						
						showRatings = false;
						setRatingsAlhpa(0);

					case 2112:
						bumpCamera(0.05, 0.05);
						defaultCamZoom = 0.65;
						lag = true;
				}

			//
			case 'gaming':
				switch(curStep)
				{
					case 1:
						camDisplaceExtend = 30;
						cameraSpeed = 1.5;

					case 218, 220, 222, 224, 227, 250, 252, 254, 256, 259, 282, 284, 286, 288, 291, 988, 990, 
						 1128, 1144, 1160, 1176, 1192, 1208, 1224, 1240, 1267, 1280, 1283, 1296, 1299, 1312, 1315, 
						 1328, 1331, 1336, 1339, 1344, 1347, 1352, 1355, 1360, 1364, 1368, 1372, 1404, 1406, 1664:
						bumpCamera(0.05, 0.05);

					case 864:
						defaultCamZoom = 0.8;
						cameraSpeed = 1;

					case 968, 976, 984:
						bumpCamera(0.2, 0.2);

					case 992:
						stageBuild.triggerEvent('Calamity Mode', 'true');
						camGame.flash(FlxColor.WHITE, 0.7);
						camDisplaceExtend = 80;
						defaultCamZoom = 0.7;
						cameraSpeed = 1.2;

						gf.x = 300;
						gf.y = -90;
					
					case 1120:
						defaultCamZoom = 0.2;
						stageBuild.triggerEvent('DOG Spawn');

					case 1248:
						bumpCamera(0.05, 0.05);
						stageBuild.triggerEvent('Calamity Mode', 'false');
						stageBuild.triggerEvent('Black Screen');
						camDisplaceExtend = 30;
						defaultCamZoom = 0.1;
						
						dadOpponent.x = -100;
						dadOpponent.y = 390;
						boyfriend.x = 890;
						boyfriend.y = 320;
						gf.x = 340;
						gf.y = -160;
						
					case 1264:
						defaultCamZoom = 0.7;
						stageBuild.triggerEvent('Black Screen');
				}

			//
			case 'asf':
				switch (curStep)
				{
					case 764, 766, 1592, 1594, 1596, 1598, 1840, 1846, 1852:
						bumpCamera(0.07, 0.07);
				}

			//
			case 'chronomatron':
				switch (curStep)
				{
					case 1:
						stageBuild.triggerEvent('Chronomatron Transition', 'enter');
					case 123:
						stageBuild.triggerEvent('Chronomatron Transition', 'start');
						camHUD.visible = true;
						canBump = true;
						strumLines.visible = true;
					case 256, 512, 640, 1280:
						startUnown(16);
					case 896, 928, 1408, 1440:
						startUnown(8);
					case 368:
						stageBuild.triggerEvent('Perish Song', '0.6');
					case 816:
						stageBuild.triggerEvent('Perish Song', '1.2');
					case 1264:
						stageBuild.triggerEvent('Perish Song', '1.8');
					case 504, 952, 964, 972, 980, 1116, 1208, 1536:
						stageBuild.triggerEvent('Jumpscare', '0.6');
				}

			//
			case 'memories':
				switch (curStep)
				{
					case 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,412,413,414,415,
						 924,925,926,927,1308,1309,1310,1311,1500,1501,1502,1503:
						bumpCamera();
					case 1568:
						bumpCamera(0.07, 0.07);
				}

			//
			case 'pelea-en-la-calle-tres':
				if (curStep == 116)
				{
					stopCharZooms = true;
					stageBuild.triggerEvent('Calle Tres Ending');
				}

			//
			case 'razortrousle':
				switch (curStep)
				{
					case 192:
						defaultCamZoom = 1;
					case 248, 312, 504:
						defaultCamZoom = 0.8;
					case 256, 320:
						defaultCamZoom = 0.9;
					case 441, 514:
						defaultCamZoom = 0.95;
					case 446:
						defaultCamZoom = 0.7;
					case 449:
						defaultCamZoom = 0.65;
					case 572:
						defaultCamZoom = 0.75;
				}
				
			//
			case 'temper-x':
				switch (curStep)
				{
					case 5016, 5018, 5020, 5022:
						bumpCamera(0.07, 0.07);
				}

		}
	}

	override function beatHit()
	{
		super.beatHit();

		// bota bota y no es pelota
		// es la camara cuando esto esta activado
		if (bumpThing == true)
		{
			if (curBeat % 1 == 0)
			{
				FlxG.camera.zoom += 0.03;
				camHUD.zoom += 0.06;
				for (hud in strumHUD)
					hud.zoom += 0.06;
			}
		}

		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case 'take-five':
				switch (curBeat)
				{
					case 80, 184, 256, 272, 320:
						bumpThing = true;
					case 144, 248, 264, 296, 328:
						bumpThing = false;
				}

			//
			case 'necron':
				switch (curBeat)
				{
					case 96, 192, 256, 392:
						bumpThing = true;
					case 128, 252, 316, 520:
						bumpThing = false;
				}

			//
			case 'gaming':
				switch (curBeat)
				{
					case 1:
						bumpThing = true;
					case 16:
						bumpThing = false;
				}

			//	
			case 'memories':
				switch (curBeat)
				{
					case 20, 39, 232:
						bumpThing = true;
					case 36, 200, 376:
						bumpThing = false;
				}
		}

		if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			&& (!Init.trueSettings.get('Movimiento Reducido'))
			&& (canBump == true))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
			for (hud in strumHUD)
				hud.zoom += 0.05;
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		uiHUD.beatHit();

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);
	}

	function modoSans(on:Bool):Void
	{
		switch (on)
		{
			case true: // PRENDE A SANS DE UNDERTALE A LA BESTIA E E E E E E
				FlxTween.tween(sans, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

				FlxTween.color(gf, 1, FlxColor.WHITE, 0xff31a2fd, {ease: FlxEase.quadInOut});
				FlxTween.color(boyfriend, 1, FlxColor.WHITE, 0xff31a2fd, {ease: FlxEase.quadInOut});
				FlxTween.color(dadOpponent, 1, FlxColor.WHITE, 0xff31a2fd, {ease: FlxEase.quadInOut});

				showRatings = false;
				setRatingsAlhpa(0);

			case false: // DESACTIVAR A SANS UNDERTALE E E E E E E E
				FlxTween.tween(sans, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});

				FlxTween.color(gf, 1, gf.color, FlxColor.WHITE, {ease: FlxEase.quadInOut});
				FlxTween.color(boyfriend, 1, boyfriend.color, FlxColor.WHITE, {ease: FlxEase.quadInOut});
				FlxTween.color(dadOpponent, 1, dadOpponent.color, FlxColor.WHITE, {ease: FlxEase.quadInOut});

				showRatings = true;
				setRatingsAlhpa(1);
		}
	}

	// pone la animacion del dedos player (se supone)
	function touhou():Void
	{
		lag = true;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			stageBuild.triggerEvent('Display Message');
			defaultCamZoom = 0.65;
			dadOpponent.visible = false;
			gf.setCharacter(300, -140, 'mari');
			FlxG.sound.play(Paths.sound('event/touhou'));
		});
	}

	public function startUnown(timer:Int = 15, word:String = ''):Void
	{
		canPause = false;
		unowning = true;
		persistentUpdate = true;
		persistentDraw = true;
		var realTimer = timer;
		var unownState = new UnownSubstate(realTimer, word);
		unownState.win = wonUnown;
		unownState.lose = loseUnown;
		unownState.cameras = [dialogueHUD];
		// FlxG.autoPause = false;
		openSubState(unownState);
	}

	function wonUnown()
	{
		canPause = true;
		unowning = false;
	}

	function loseUnown()
	{
		if (!boyfriendStrums.autoplay)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			canPause = true;
			unowning = false;
			resetMusic();
			vocals.pause();
			songMusic.pause();
			for (hud in strumHUD)
				FlxTween.tween(hud, {alpha: 0}, 1.5);
			FlxTween.tween(camHUD, {alpha: 0}, 1.5);
			FlxTween.tween(camGame, {alpha: 0}, 1.5, {
				onComplete: function(twn:FlxTween) 
				{
					camGame.alpha = 1;
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			});
		}
		else
		{
			canPause = true;
			unowning = false;
		}
	}

	function die()
	{
		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		detailsPausedText = "Game Over - " + songDetails;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		resetMusic();

		FlxTimer.globalManager.clear();
		FlxTween.globalManager.clear();
	}

	function bumpCamera(gameZoom:Float = 0.015, uiZoom:Float = 0.03)
	{
		FlxG.camera.zoom += gameZoom;
		camHUD.zoom += uiZoom;
		for (hud in strumHUD)
			hud.zoom += uiZoom;
	}

	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0) 
		&& ((gf.animation.curAnim.name.startsWith("idle")
		|| gf.animation.curAnim.name.startsWith("dance"))))
			gf.dance();

		if ((boyfriend.animation.curAnim.name.startsWith("idle") 
		|| boyfriend.animation.curAnim.name.startsWith("dance")) 
			&& (curBeat % 2 == 0 || boyfriend.characterData.quickDancer))
			boyfriend.dance();

		// OK YA NO LE MUEVAS A ESTO AL JUEGO NO LE GUSTA
		if ((dadOpponent.animation.curAnim.name.startsWith("idle") 
		|| dadOpponent.animation.curAnim.name.startsWith("dance"))  
			&& (curBeat % 2 == 0 || dadOpponent.characterData.quickDancer))
			dadOpponent.dance();
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (songMusic != null)
			{
				songMusic.pause();
				vocals.pause();
			}

			// trace('ui shit break');
			/*if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;*/

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished) tmr.active = false);
			//FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished) twn.active = false);
		}
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			/*if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;*/

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished) tmr.active = true);
			//FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished) twn.active = true);

			paused = false;
			updateRPC(false);
		}

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		openfl.Lib.application.window.title = 'Vs. CDD Forever';

		seenCutscene = false;
		inCutscene = false;
		endingSong = true;
		canPause = false;

		songMusic.volume = 0;
		vocals.volume = 0;

		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (!isStoryMode)
		{
			Main.switchState(this, new FreeplayState());
		}
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				if (SONG.song.toLowerCase() == 'asf')
					Main.switchState(this, new FreeplayState());
				else
					Main.switchState(this, new StoryMenuState());
					
				// save the week's score if the score is valid
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else
				songEndSpecificActions();
		}
		//
	}

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'necron':
				startVideo('assets/images/backgrounds/skyblock/gamingCutscene.mp4');
			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		songsPlayed++;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		// deliberately did not use the main.switchstate as to not unload the assets
		FlxG.switchState(new PlayState());
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}

						});

					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			default:
				callTextbox();
		}
		//
	}

	public function startVideo(filepath:String)
	{
		inCutscene = true;

		// se detiene si no encuentra el video
		if (!sys.FileSystem.exists(filepath))
		{
			FlxG.log.warn('Couldnt find video file: ' + filepath);
			callDefaultSongEnd();
			return;
		}

		// proceder
		var screen = new FlxSprite().loadGraphic(Paths.image('menus/mainmenu/art/loadingScreen'));
		screen.setGraphicSize(Std.int(FlxG.width));
		screen.updateHitbox();
		screen.scrollFactor.set();
		screen.screenCenter();
		screen.antialiasing = true;
		screen.cameras = [dialogueHUD];
		add(screen);

		var txt:FlxText = new FlxText(20, FlxG.height - 690, 0, 'Cargando...');
		txt.setFormat(Paths.font('terraria.ttf'), 50, FlxColor.WHITE, CENTER);
		txt.cameras = [dialogueHUD];
		txt.scrollFactor.set();
		txt.antialiasing = true;
		add(txt);

		var saveVolume = FlxG.sound.volume;
		FlxG.sound.volume = 0.6;
		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.volumeDownKeys = [];

		var video:FlxVideo = new FlxVideo();
		video.play(filepath);
		video.onEndReached.add(function()
		{
			FlxG.sound.volume = saveVolume;
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];

			video.dispose();
			callDefaultSongEnd();
			return;
		}, true);

	}

	function callTextbox() {
		var dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue');
		if (sys.FileSystem.exists(dialogPath))
		{
			startedCountdown = false;

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = startCountdown;

			add(dialogueBox);
		}
		else
			startCountdown();
	}

	public static function showCutscenes():Bool {
		if (seenCutscene)
			return false;

		// pretty messy but an if statement is messier
		if (Init.trueSettings.get('Dialogo') != null
		&& Std.isOfType(Init.trueSettings.get('Dialogo'), String)) {
			switch (cast(Init.trueSettings.get('Dialogo'), String))
			{
				case 'nunca':
					return false;
				case 'historia':
					if (isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		seenCutscene = true;
		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		if (PlayState.SONG.song.toLowerCase() != 'chronomatron')
			camHUD.visible = true;
		else
			FlxG.sound.play(Paths.sound('event/unown/muerto'));

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkinAsset('3', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('2', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('1', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					three.scrollFactor.set();
					three.updateHitbox();

					if (assetModifier == 'pixel')
						three.setGraphicSize(Std.int(three.width * PlayState.daPixelZoom));

					three.screenCenter();
					add(three);
					FlxTween.tween(three, {y: three.y + 30, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro/count'), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					two.scrollFactor.set();
					two.updateHitbox();

					if (assetModifier == 'pixel')
						two.setGraphicSize(Std.int(two.width * PlayState.daPixelZoom));

					two.screenCenter();
					add(two);
					FlxTween.tween(two, {y: two.y + 30, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro/count'), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					one.scrollFactor.set();

					if (assetModifier == 'pixel')
						one.setGraphicSize(Std.int(one.width * PlayState.daPixelZoom));

					one.screenCenter();
					add(one);
					FlxTween.tween(one, {y: one.y + 30, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							one.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro/count'), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
					go.scrollFactor.set();

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y + 30, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro/go'), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 1);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = Init.trueSettings.get('Antialiasing');
		return super.add(Object);
	}
}
