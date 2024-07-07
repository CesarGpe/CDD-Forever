package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import meta.MusicBeat.MusicBeatState;
import meta.data.Conductor;
import meta.data.Song;
import meta.data.dependency.Discord;
import meta.state.PlayState;
import meta.state.menus.*;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ButtonData = 
{
	micX:Float,
	micY:Float,
	micSF:Float,

	deafX:Float,
	deafY:Float,
	deafSF:Float,

	cogX:Float,
	cogY:Float,
	cogSF:Float,

	pfpX:Float,
	pfpY:Float,
	pfpSF:Float,

	statusX:Float,
	statusY:Float,
	statusTH:Float,
	statusSF:Int,

	txt1X:Float,
	txt1Y:Float,
	txt1SF:Int,
	
	txt2X:Float,
	txt2Y:Float,
	txt2SF:Int
}

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	// por lo de la rockola
	public static var resetMusic:Bool = false;

	// mute y deafen
	public static var muted:Bool = false;
	public static var deafen:Bool = false;

	// de que el menu real
	var optionShit:Array<String> = ['modo-historia', 'juego-libre', 'rockola', 'config'];
	var menuItems:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var boxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var htags:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var selectedSomethin:Bool = false;

	// fondo
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var line1:FlxSprite;
	var line2:FlxSprite;
	var menutxt:FlxText;
	var cddtxt:FlxText;
	var channeltxt:FlxText;
	var channeltag:FlxText;

	// galeria
	var images:Array<String>;
	var art:FlxSprite;
	var arrow1:FlxText;
	var arrow2:FlxText;
	var credArt:FlxText;
	var infoText:FlxText;
	var daTween:FlxTween;

	// la cosa de abajo
	var micBox:FlxSprite;
	var mic:FlxSprite;

	var deafBox:FlxSprite;
	var deaf:FlxSprite;

	var cogBox:FlxSprite;
	var cog:FlxSprite;

	var pfp:FlxSprite;
	var status:FlxSprite;
	var userTxt1:FlxText;
	var userTxt2:FlxText;
	var userBG:FlxSprite;
	var buttonJSON:ButtonData;
	
	// datos
	var canChange:Bool = false;
	var galleryNum:Int;
	static var curSelected:Int = 0;
	var codeStep:Int = 0;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;
		buttonJSON = Json.parse(File.getContent(Paths.getPath('images/menus/mainmenu/buttonPos.json', TEXT)));

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		if (resetMusic)
		{
			if (FreeplayState.changedMenuSong)
				Conductor.changeBPM(FreeplayState.curSongBPM);
			else
				Conductor.changeBPM(102);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			resetMusic = false;
		}
		else
			ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('En los Menús:', 'Menú Principal');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		bg1 = new FlxSprite();
		bg1.makeGraphic(FlxG.width, FlxG.height, 0xff313338);
		bg1.screenCenter();
		add(bg1);

		line1 = new FlxSprite(0, 115);
		line1.makeGraphic(Std.int(FlxG.width * 0.5) + 20, 4, 0xff27282d);
		line1.antialiasing = true;
		add(line1);

		channeltxt = new FlxText(770, 10, 550, 'galeria');
		channeltxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		channeltxt.antialiasing = true;
		add(channeltxt);

		channeltag = new FlxText(690, 0, 550, '#');
		channeltag.setFormat(Paths.font("whitneymedium.otf"), 90, 0xff8b8d92, LEFT);
		channeltag.antialiasing = true;
		add(channeltag);

		// hacer la imagen para la galeria epica
		art = new FlxSprite();
		images = FileSystem.readDirectory('assets/images/menus/mainmenu/art');
		for (file in images)
		{
			if (!file.endsWith('.png'))
				images.remove(file);
		}
		for (i in 0...images.length)
			images[i] = images[i].replace('.png', '');
		galleryNum = FlxG.random.int(0, images.length);
		add(art);

		// textos de la galeria
		credArt = new FlxText(720, (FlxG.height - 576), 0, '');
		credArt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		credArt.textField.background = true;
		credArt.textField.backgroundColor = FlxColor.BLACK;
		add(credArt);

		infoText = new FlxText(720, (FlxG.height - 100), 0, '');
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		// preparar esta madre antes de los tweens
		changeGalleryArt();

		// flechitas para la galeria
		arrow1 = new FlxText(0, 0, 0, '<');
		arrow1.setFormat(Paths.font("unisans.otf"), 90, 0xff8b8d92, LEFT);
		arrow1.screenCenter();
		arrow1.x += 75;
		arrow1.y += 40;
		add(arrow1);

		arrow2 = new FlxText(0, 0, 0, '>');
		arrow2.setFormat(Paths.font("unisans.otf"), 90, 0xff8b8d92, LEFT);
		arrow2.screenCenter();
		arrow2.x += 595;
		arrow2.y += 40;
		add(arrow2);

		// segundo fondo para los botones del menu
		bg2 = new FlxSprite();
		bg2.makeGraphic(Std.int(FlxG.width * 0.5) + 20, FlxG.height, 0xff2b2d31);
		add(bg2);

		line2 = new FlxSprite(0, 115);
		line2.makeGraphic(FlxG.width, 4, 0xff242529);
		line2.antialiasing = true;
		add(line2);

		menutxt = new FlxText(35, 149, 550, 'MENU PRINCIPAL');
		menutxt.setFormat(Paths.font("unisans.otf"), 65, 0xff8b8d92, LEFT);
		menutxt.antialiasing = true;
		add(menutxt);

		cddtxt = new FlxText(35, 15, 550, 'Vs. CDD');
		cddtxt.setFormat(Paths.font("whitneysemibold.otf"), 70, 0xfff3ffee, LEFT);
		cddtxt.antialiasing = true;
		add(cddtxt);

		userBG = new FlxSprite(0, 610);
		userBG.makeGraphic(Std.int(FlxG.width * 0.5) + 20, Std.int(FlxG.height * (1 / 6)), 0xff232428);
		add(userBG);

		pfp = new FlxSprite(buttonJSON.pfpX, buttonJSON.pfpY);
		if (FlxG.random.bool(5))
			pfp.loadGraphic(Paths.image('menus/mainmenu/bfmejor'));
		else
			pfp.loadGraphic(Paths.image('menus/mainmenu/bf'));
		pfp.setGraphicSize(Std.int(pfp.width * buttonJSON.pfpSF), Std.int(pfp.height * buttonJSON.pfpSF));
		pfp.updateHitbox();
		pfp.antialiasing = true;
		add(pfp);

		status = new FlxShapeCircle(buttonJSON.statusX, buttonJSON.statusY, buttonJSON.statusSF, {thickness: buttonJSON.statusTH, color: 0xff232428}, 0xff23a55a);
		status.antialiasing = true;
		add(status);

		mic = new FlxSprite(buttonJSON.micX, buttonJSON.micY);
		mic.loadGraphic(Paths.image('menus/mainmenu/microphone'));
		mic.setGraphicSize(Std.int(mic.width * buttonJSON.micSF), Std.int(mic.height * buttonJSON.micSF));
		mic.updateHitbox();
		mic.antialiasing = true;
		mic.alpha = 0.7;

		micBox = new FlxSprite(mic.x - 5, mic.y - 5);
		micBox.makeGraphic(Std.int(mic.width + 10), Std.int(mic.height + 10), 0xff35373c);
		micBox.visible = false;
		add(micBox);
		add(mic);

		deaf = new FlxSprite(buttonJSON.deafX, buttonJSON.deafY);
		deaf.loadGraphic(Paths.image('menus/mainmenu/headphones'));
		deaf.setGraphicSize(Std.int(deaf.width * buttonJSON.deafSF), Std.int(deaf.height * buttonJSON.deafSF));
		deaf.updateHitbox();
		deaf.antialiasing = true;
		deaf.alpha = 0.7;

		deafBox = new FlxSprite(deaf.x - 5, deaf.y - 5);
		deafBox.makeGraphic(Std.int(deaf.width + 10), Std.int(deaf.height + 10), 0xff35373c);
		deafBox.visible = false;
		add(deafBox);
		add(deaf);

		cog = new FlxSprite(buttonJSON.cogX, buttonJSON.cogY);
		cog.loadGraphic(Paths.image('menus/mainmenu/cog'));
		cog.setGraphicSize(Std.int(cog.width * buttonJSON.cogSF), Std.int(cog.height * buttonJSON.cogSF));
		cog.updateHitbox();
		cog.antialiasing = true;
		cog.alpha = 0.7;

		cogBox = new FlxSprite(cog.x - 5, cog.y - 5);
		cogBox.makeGraphic(Std.int(cog.width + 10), Std.int(cog.height + 10), 0xff35373c);
		cogBox.visible = false;
		add(cogBox);
		add(cog);
		
		userTxt1 = new FlxText(buttonJSON.txt1X, buttonJSON.txt1Y, 0, 'Boyfriend');
		userTxt1.setFormat(Paths.font("whitneysemibold.otf"), buttonJSON.txt1SF, 0xfff3ffee, LEFT);
		userTxt1.antialiasing = true;
		add(userTxt1);

		userTxt2 = new FlxText(buttonJSON.txt2X, buttonJSON.txt2Y, 0, 'En linea');
		userTxt2.setFormat(Paths.font("whitneymedium.otf"), buttonJSON.txt2SF, 0xff8b8d92, LEFT);
		userTxt2.antialiasing = true;
		add(userTxt2);

		// añade cosas
		add(boxes);
		add(menuItems);
		add(htags);

		// ! bucle para las opciones del menu
		for (i in 0...3)
		{
			var box:FlxSprite = new FlxSprite(20, (16 * 8 * i) + (28 * 8));
			box.makeGraphic(615, 110, 0xff35373c);

			var menuItem:FlxText = new FlxText(120, (16 * 8 * i) + (28 * 8), 500, optionShit[i]);
			menuItem.setFormat(Paths.font("whitneymedium.otf"), 80, 0xff8b8d92, LEFT);

			var htag:FlxText = new FlxText(35, (16 * 8 * i) + (28 * 8), 450, '#');
			htag.setFormat(Paths.font("whitneymedium.otf"), 90, 0xff8b8d92, LEFT);

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

		///* AQUI EMPIEZAN LOS TWEENS !!
		menuItems.forEach(function(spr:FlxSprite) { setAndTween(spr, -800, 0.75, 'x'); });
		htags.forEach(function(spr:FlxSprite)     { setAndTween(spr, -800, 0.75, 'x'); });
		boxes.forEach(function(spr:FlxSprite)     { setAndTween(spr, -800, 0.75, 'x'); });

		setAndTween(cddtxt,     -200, 0.75, 'y');
		setAndTween(channeltxt, -200, 0.75, 'y');
		setAndTween(channeltag, -200, 0.75, 'y');

		setAndTween(menutxt,    -800, 0.75, 'x');

		setAndTween(infoText,   800, 1.25, 'x');
		setAndTween(credArt,    800, 1.25, 'x');
		setAndTween(art,        800, 1.25, 'x');

		arrow1.alpha = 0;
		arrow2.alpha = 0;
		new FlxTimer().start(1.25, function(tmr:FlxTimer)
		{
			FlxTween.tween(arrow1, {alpha: 1}, 0.5);
			FlxTween.tween(arrow2, {alpha: 1}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
					canChange = true;
				}
			});
		});
		///* AQUI TERMINAN LOS TWEENS !!

		changeSelection();
		updateButtonSprites();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		// cambiar entre las opciones
		if (controls.UI_UP_P && !selectedSomethin)
			changeSelection(-1);
		else if (controls.UI_DOWN_P && !selectedSomethin)
			changeSelection(1);

		// cambia la imagen de la galeria
		if (controls.UI_LEFT_P && canChange && !selectedSomethin)
			changeGalleryArt(-1);
		if (controls.UI_RIGHT_P && canChange && !selectedSomethin)
			changeGalleryArt(1);

		// selecciona una opcion
		if (controls.ACCEPT && !selectedSomethin)
			selectSomething();

		// volver a la pantalla de titulo
		if (controls.BACK && !selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			Main.switchState(this, new TitleState());
		}

		// me ahorra tiempo reiniciando el menu jaja
		if (FlxG.keys.justPressed.R && Init.trueSettings.get('Modo Debug'))
			FlxG.switchState(new MainMenuState());
		
		easterEggCheck();
		mouseItems();

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		curSelected += change;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;
		else if (curSelected >= optionShit.length)
			curSelected = 0;

		menuItems.forEach(function(spr:FlxText)
		{
			if (curSelected == spr.ID)
				spr.color = 0xffdbdeff;
			else
				spr.color = 0xff8b8d92;
		});

		boxes.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
				spr.visible = true;
			else
				spr.visible = false;
		});

		if (curSelected == 3)
		{
			cogBox.visible = true;
			cog.alpha = 0.85;
		}
		else
		{
			cogBox.visible = false;
			cog.alpha = 0.7;
		}
	}

	function selectSomething()
	{
		selectedSomethin = true;

		if (curSelected == 3)
		{
			FlxG.sound.play(Paths.sound('menu/scrollMenu'));
			Main.switchState(this, new OptionsMenuState());
		}
		else
		{
			FlxG.sound.play(Paths.sound('menu/confirmMenu'));
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				switch (curSelected)
				{
					case 0: // modo historia
						Main.switchState(this, new StoryMenuState());
					case 1: // juego libre
						Main.switchState(this, new FreeplayState());
					case 2: // rockola
						Main.switchState(this, new RadioState(), true, false, false);
				}
			});
		}

		menuItems.forEach(function(spr:FlxText)
		{
			if (curSelected == spr.ID)
			{
				spr.color = FlxColor.WHITE;
				FlxFlicker.flicker(spr, 1, 0.06, false, false);
			}
			else
				tweenKill(spr);
		});
		htags.forEach(function(spr:FlxText)
		{
			if (curSelected == spr.ID)
				FlxFlicker.flicker(spr, 1, 0.06, false, false);
			else
				tweenKill(spr);
		});
		boxes.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
			{
				spr.makeGraphic(615, 110, 0xff3f4248);
				FlxFlicker.flicker(spr, 1, 0.06, false, false);
			}
			else
				spr.kill();
		});
	}

	function changeGalleryArt(change:Int = 0)
	{
		galleryNum += change;

		// para que sea un bucle
		if (galleryNum < 0)
			galleryNum = images.length - 1;
		if (galleryNum >= images.length)
			galleryNum = 0;

		// cambia la imagen de la galeria
		if (galleryNum == 12 || galleryNum == 19)
		{
			art.frames = Paths.getSparrowAtlas('menus/mainmenu/art/' + images[galleryNum]);
			art.animation.addByPrefix('idle', 'bop', 24, false);
			art.flipX = true;
		}
		else
		{
			art.loadGraphic(Paths.image('menus/mainmenu/art/' + images[galleryNum]));
			art.flipX = false;
		}
		art.setGraphicSize(Std.int(FlxG.width * 0.35));
		art.updateHitbox();

		// textos y tamaños de las imagenes
		switch (galleryNum)
		{
			case 0:
				infoText.text = 'La primera portada del album de CDD,\nincluso con el diseño beta de TsuyAr!';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 1:
				infoText.text = 'Has intentado escribir ASF en el menu?';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 2:
				infoText.text = 'Esto es muy triste, presiona Alt+F4\npara ponerlo feliz.';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 3:
				infoText.text = 'chistoso, me rei';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 4:
				infoText.text = 'Dibujo de los miembros de CDD\n(no leas lo que dice en la esquina)';
				credArt.text = '@tsuyar20';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 5:
				infoText.text = 'CESAR EN PADRE DE FAMILIA??\nES ESTO REAL????';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 6:
				infoText.text = 'Pantalla de carga requete bien\nchingona la neta muchas gracias';
				credArt.text = '@mochika_chan';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 7:
				infoText.text = 'La Mari canonicamente va en 3ro de\nprimaria jaja';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 8:
				infoText.text = 'Gracias Feloxsel por el fanart! <3';
				credArt.text = '@TheFeloxselUwU';

				art.scale.set(0.3, 0.3);
			case 9:
				infoText.text = 'Quien haria algo asi?';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 10:
				infoText.text = '(si se llama juan pablo solo es chiste)';
				credArt.text = '@tsuyar20';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 11:
				infoText.text = 'no llorllys??';
				credArt.text = '@cesardicecosas';

				art.scale.set(1.2, 1.2);
			case 12:
				infoText.text = 'Un personaje sin proposito,\nnunca tuvo nada planeado.';
				credArt.text = '@blueslime32';

				art.scale.set(0.6, 0.6);
			case 13:
				infoText.text = 'La foto original del server de\nCamara de Diputados.';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 14:
				infoText.text = "RAZOR'S EDGE GAMING";
				credArt.text = '@blueslime32';

				art.scale.set(0.3, 0.3);
			case 15:
				infoText.text = 'Boceto del primer diseño de TsuyAr.';
				credArt.text = '@tsuyar20';

				art.scale.set(0.5, 0.5);
			case 16:
				infoText.text = 'admitelo';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 17:
				infoText.text = 'terrence cdd videojugando';
				credArt.text = '@cesardicecosas';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 18:
				infoText.text = 'IMPOSIBLE.';
				credArt.text = '@blueslime32';

				art.setGraphicSize(Std.int(FlxG.width * 0.35));
			case 19:
				if (!FlxG.save.data.shubsEgg || FlxG.save.data.shubsEgg == null)
					infoText.text = 'Shubs se mudara a tu juego si\npresionas SHIFT en la pantalla de titulo.';
				else
					infoText.text = 'gabby gaming jaja si o no raza';
				credArt.text = '@kazzyrus';

				art.scale.set(0.9, 0.9);
			default:
				infoText.text = 'que le hiciste a mi bonita carpeta??';
				credArt.text = 'oh no';
		}
		art.alpha = 0;
		if (daTween != null)
			daTween.cancel();
		daTween = FlxTween.tween(art, {alpha: 1}, 0.5);

		art.updateHitbox();
		art.screenCenter();
		art.x += 335;
		art.y += 37;
		art.antialiasing = true;

		infoText.screenCenter(X);
		infoText.x += 335;
		credArt.screenCenter(X);
		credArt.x += 335;
	}

	function easterEggCheck()
	{
		if (FlxG.keys.anyJustPressed([Q, W, E, R, T, Y, U, I, O, P, A, S, D, F, G, H, J, K, L, Z, X, C, V, B, N, M]))
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
					{
						var black:FlxSprite = new FlxSprite();
						black.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						black.scrollFactor.set();
						black.screenCenter();
						add(black);

						FlxG.sound.play(Paths.sound('menu/click'));
						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();

						Init.trueSettings.set('asfUnlock', true);
						Init.trueSettings.set('fpStory', false);
						Init.saveSettings();

						PlayState.SONG = Song.loadFromJson('asf', 'asf');
						PlayState.isStoryMode = true;
						PlayState.seenCutscene = false;
						PlayState.storyDifficulty = 1;
						PlayState.storyWeek = 34;

						Main.switchState(this, new PlayState(), true);
					}
			}
			if (resetCode)
				codeStep = 0;
			else
				codeStep += 1;
		}
	}

	function mouseItems()
	{
		micBox.visible = FlxG.mouse.overlaps(mic);
		if (FlxG.mouse.overlaps(mic) && FlxG.mouse.justPressed && !selectedSomethin)
		{
			if (deafen)
			{
				deafen = false;
				deafToggle();

				muted = !muted;
				muteToggle(false);
			}
			else
			{
				muted = !muted;
				muteToggle(true);
			}
				
			
		}

		deafBox.visible = FlxG.mouse.overlaps(deaf);
		if (FlxG.mouse.overlaps(deaf) && FlxG.mouse.justPressed && !selectedSomethin)
		{
			deafen = !deafen;
			muted = deafen;

			deafToggle();

			if (muted)
				mic.loadGraphic(Paths.image('menus/mainmenu/microphone-muted'));
			else
				mic.loadGraphic(Paths.image('menus/mainmenu/microphone'));
			mic.updateHitbox();
		}
	}

	function muteToggle(?playSounds:Bool = false)
	{
		updateButtonSprites();
		if (playSounds)
		{
			if (muted)
				FlxG.sound.play(Paths.sound('event/discordMute'));
			else
				FlxG.sound.play(Paths.sound('event/discordUnmute'));
		}
	}

	function deafToggle()
	{
		updateButtonSprites();
		var sound:FlxSound = new FlxSound();
		if (deafen)
		{
			sound.loadEmbedded(Paths.sound('menu/discordDeafen'));
			sound.play();

			FlxG.sound.muted = true;
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeUpKeys = [];
			FlxG.sound.volumeDownKeys = [];
		}
		else
		{
			FlxG.sound.muted = false;
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];

			sound.loadEmbedded(Paths.sound('menu/discordUndeafen'));
			sound.play();
		}
	}

	function updateButtonSprites()
	{
		if (deafen)
		{
			deaf.loadGraphic(Paths.image('menus/mainmenu/headphones-muted'));
			deaf.updateHitbox();
		}
		else
		{
			deaf.loadGraphic(Paths.image('menus/mainmenu/headphones'));
			deaf.updateHitbox();
		}

		if (muted)
		{
			mic.loadGraphic(Paths.image('menus/mainmenu/microphone-muted'));
			mic.updateHitbox();
		}
		else
		{
			mic.loadGraphic(Paths.image('menus/mainmenu/microphone'));
			mic.updateHitbox();
		}
	}

	override function beatHit()
	{
		super.beatHit();
		art.animation.play('idle', true);
	}

	function tweenKill(spr:FlxSprite)
	{
		FlxTween.tween(spr, {alpha: 0}, 0.65, {ease: FlxEase.quadOut, startDelay: 0.1});
		FlxTween.tween(spr, {x: (spr.x - 800)}, 0.75, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.kill();
			}
		});
	}

	function setAndTween(spr:FlxSprite, pos:Int, time:Float, type:String)
	{
		if (type == 'x')
		{
			spr.x += pos;
			FlxTween.tween(spr, {x: spr.x - pos}, time, {ease: FlxEase.quadInOut});
		}
		else if (type == 'y')
		{
			spr.y += pos;
			FlxTween.tween(spr, {y: spr.y - pos}, time, {ease: FlxEase.quadInOut});
		}
	}
}