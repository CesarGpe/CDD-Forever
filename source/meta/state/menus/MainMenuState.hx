package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.ds.StringMap;
import meta.MusicBeat.MusicBeatState;
import meta.data.Conductor;
import meta.data.ScriptHandler;
import meta.data.Song;
import meta.data.dependency.Discord;
import meta.state.PlayState;
import meta.state.menus.*;
import sys.FileSystem;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var optionShit:Array<String> = ['modo-historia', 'juego-libre', 'configuracion'];
	var menuItems:FlxTypedGroup<FlxText>;
	var htags:FlxTypedGroup<FlxText>;
	var boxes:FlxTypedGroup<FlxSprite>;

	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var line1:FlxSprite;
	var line2:FlxSprite;

	var menutxt:FlxText;
	var cddtxt:FlxText;
	var channeltxt:FlxText;
	var channeltag:FlxText;

	var images:Array<String>;
	var art:FlxSprite;
	var arrow1:FlxText;
	var arrow2:FlxText;
	var credArt:FlxText;
	var infoText:FlxText;
	var daTween:FlxTween;

	var userBG:FlxSprite;
	var mic:FlxSprite;
	var deaf:FlxSprite;
	var cog:FlxSprite;
	var pfp:FlxSprite;
	var status:FlxSprite;
	var userTxt1:FlxSprite;
	var userTxt2:FlxSprite;
	
	var canChange:Bool = false;
	var galleryNum:Int;
	var coolBeat:Int;
	var oldBeat:Int = 0;

	var lastCurSelected:Int = 0;
	var curSelected:Float = 0;
	var codeStep:Int = 0;

	// script
	var coolScript:ForeverModule;

	override function create()
	{
		super.create();

		var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
		exposure.set('add', add);

		coolScript = ScriptHandler.loadModule('script', 'images/menus/mainmenu', exposure);
		if (coolScript.exists("onCreate"))
			coolScript.get("onCreate")();
		trace('Menu script loaded successfully');

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
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
		channeltxt.setFormat(Paths.font("whitneymedium.otf"), 70, 0xfff3ffee, LEFT);
		channeltxt.antialiasing = true;
		add(channeltxt);

		channeltag = new FlxText(690, 0, 550, '#');
		channeltag.setFormat(Paths.font("whitneymedium.otf"), 90, 0xff8b8d92, LEFT);
		channeltag.antialiasing = true;
		add(channeltag);

		// hacer la imagen para la galeria epica
		art = new FlxSprite();
		images = FileSystem.readDirectory('assets/images/menus/art');
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

		// ya que los objetos esten listos
		changeGalleryArt();

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

		pfp = new FlxSprite(20, 590);
		pfp.loadGraphic(Paths.image('menus/mainmenu/bf'));
		pfp.setGraphicSize(Std.int(pfp.width * 0.25), Std.int(pfp.height * 0.25));
		pfp.updateHitbox();
		pfp.antialiasing = true;
		add(pfp);

		// prepara los grupos padrisimos
		boxes = new FlxTypedGroup<FlxSprite>();
		menuItems = new FlxTypedGroup<FlxText>();
		htags = new FlxTypedGroup<FlxText>();
		add(boxes);
		add(menuItems);
		add(htags);

		// bucle para las opciones del menu
		for (i in 0...optionShit.length)
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

		///* AQUI EMPIEZAN LOS TWEENS
		menuItems.forEach(function(spr:FlxText)
		{
			spr.x -= 800;
			FlxTween.tween(spr, {x: (spr.x + 800)}, 0.75, {ease: FlxEase.quadInOut});
		});
		htags.forEach(function(spr:FlxText)
		{
			spr.x -= 800;
			FlxTween.tween(spr, {x: (spr.x + 800)}, 0.75, {ease: FlxEase.quadInOut});
		});
		boxes.forEach(function(spr:FlxSprite)
		{
			spr.x -= 800;
			FlxTween.tween(spr, {x: (spr.x + 800)}, 0.75, {ease: FlxEase.quadInOut});
		});

		arrow1.alpha = 0;
		arrow2.alpha = 0;

		art.x += 800;
		infoText.x += 800;
		credArt.x += 800;
		menutxt.x -= 800;

		cddtxt.y -= 200;
		channeltxt.y -= 200;
		channeltag.y -= 200;

		FlxTween.tween(cddtxt,     {y: (cddtxt.y + 200)},     0.75, {ease: FlxEase.quadInOut});
		FlxTween.tween(channeltxt, {y: (channeltxt.y + 200)}, 0.75, {ease: FlxEase.quadInOut});
		FlxTween.tween(channeltag, {y: (channeltag.y + 200)}, 0.75, {ease: FlxEase.quadInOut});
		FlxTween.tween(menutxt,	   {x: (menutxt.x + 800)},    0.75, {ease: FlxEase.quadInOut});
		
		FlxTween.tween(infoText,   {x: (infoText.x - 800)},   1.25, {ease: FlxEase.quadInOut});
		FlxTween.tween(credArt,    {x: (credArt.x - 800)},    1.25, {ease: FlxEase.quadInOut});
		FlxTween.tween(art,        {x: (art.x - 800)},        1.25, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(arrow1, {alpha: 1}, 0.5);
				FlxTween.tween(arrow2, {alpha: 1}, 0.5, {
					onComplete: function(twn:FlxTween)
					{
						canChange = true;
					}
				});
			}
		});
		///* AQUI SE TERMINAN LOS TWEENS

		updateSelection();

		// y ya por ultimo el texto de la version
		/*var versionShit:FlxText = new FlxText(5, FlxG.height - 25, 0, "Forever Engine " + Main.gameVersion);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);*/

		//
	}

	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
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

						FlxG.sound.play(Paths.sound('menu/scrollMenu'));
					}
					if (controls.BACK)
					{
						FlxG.sound.play(Paths.sound('menu/cancelMenu'));
						Main.switchState(this, new TitleState());
					}

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
			FlxG.sound.play(Paths.sound('menu/confirmMenu'));

			menuItems.forEach(function(spr:FlxText)
			{
				if (curSelected != spr.ID)
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
				else
				{
					spr.setFormat(Paths.font("whitneymedium.otf"), 80, FlxColor.WHITE);
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];
						switch (daChoice)
						{
							case 'modo-historia':
								Main.switchState(this, new StoryMenuState());
							case 'juego-libre':
								Main.switchState(this, new FreeplayState());
							case 'configuracion':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});

			htags.forEach(function(spr:FlxText)
			{
				if (curSelected != spr.ID)
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
				else
					FlxFlicker.flicker(spr, 1, 0.06, false, false);
			});

			boxes.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
					spr.kill();
				else
				{
					spr.makeGraphic(615, 110, 0xff3f4248);
					FlxFlicker.flicker(spr, 1, 0.06, false, false);
				}
			});

		}

		// como curBeat pero mas barato
		coolBeat = Math.floor(FlxG.sound.music.time / Conductor.stepCrochet);
		coolHit(coolBeat);

		// cambia la imagen de la galeria
		if (controls.UI_LEFT_P && canChange)
			changeGalleryArt(-1);
		if (controls.UI_RIGHT_P && canChange)
			changeGalleryArt(1);

		
		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

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
						FlxG.sound.play(Paths.sound('menu/click'));
						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();

						Init.trueSettings.set('asfUnlock', true);
						Init.trueSettings.set('fpStory', false);
						Init.saveSettings();

						PlayState.SONG = Song.loadFromJson('asf', 'asf');
						PlayState.isStoryMode = true;
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

		super.update(elapsed);
	}

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxText)
		{
			spr.setFormat(Paths.font("whitneymedium.otf"), 80, 0xff8b8d92);
			spr.updateHitbox();
		});

		if (menuItems.members[Math.floor(curSelected)].color == 0xff8b8d92)
			menuItems.members[Math.floor(curSelected)].setFormat(Paths.font("whitneymedium.otf"), 80, 0xffdbdeff);

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		boxes.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
				spr.visible = false;
			else
				spr.visible = true;
		});

		lastCurSelected = Math.floor(curSelected);
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
			art.frames = Paths.getSparrowAtlas('menus/art/' + images[galleryNum]);
			art.animation.addByPrefix('idle', 'bop', 24, false);
			//art.animation.play('idle', true);
			art.flipX = true;
		}
		else
		{
			art.loadGraphic(Paths.image('menus/art/' + images[galleryNum]));
			art.flipX = false;
		}
		art.setGraphicSize(Std.int(FlxG.width * 0.35));
		art.updateHitbox();
		art.antialiasing = true;

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
				credArt.text = '@TsuyAr';

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
				credArt.text = '@TsuyAr';

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
				credArt.text = '@TsuyAr';

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
				infoText.text = 'Shubs se mudara a tu juego si\npresionas SHIFT en la pantalla de titulo.';
				credArt.text = '@kazzyrus';

				art.scale.set(0.9, 0.9);
			default:
				infoText.text = 'ah pinche puto pendejo idiota\nmetiste otro archivo a la carpeta verdad';
				credArt.text = 'puto el que lo lea';
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

	function coolHit(beat:Int)
	{
		if (oldBeat != beat)
		{
			if (beat % 4 == 0)
				art.animation.play('idle', true);
		}
		oldBeat = beat;
	}
}