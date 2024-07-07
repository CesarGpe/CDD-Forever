import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Highscore;
import meta.data.Windows;
import meta.state.*;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

using StringTools;
/** 
	Enumerator for settingtypes
**/
enum SettingTypes
{
	Checkmark;
	Selector;
}

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';

	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [
			false,
			Checkmark,
			'Las notas iran hacia abajo en vez de hacia arriba.',
			NOT_FORCED
		],
		'Auto Pausa' => [true, Checkmark, 'Pausa automaticamente cuando el juego se minimiza.', NOT_FORCED],
		'Mostrar FPS' => [false, Checkmark, 'Muestra los FPS de tu juego en la esquina de la pantalla.', NOT_FORCED],
		'Contador de Memoria' => [
			false,
			Checkmark,
			'Muestra la cantidad aproximada de memoria que consume el juego.',
			NOT_FORCED
		],
		'Modo Debug' => [
			false,
			Checkmark,
			'Habilita el botplay, el editor de charts y otras cosas utiles para desarrolladores.',
			NOT_FORCED
		],
		'Ventana Oscura' => [
			true,
			Checkmark,
			'Colorea la ventana del juego de color oscuro, solo funciona en Windows.',
			NOT_FORCED
		],
		'Movimiento Reducido' => [
			false,
			Checkmark,
			'Reduce el movimiento, como los iconos moviendose con el ritmo o los zooms durante el gameplay.',
			NOT_FORCED
		],
		'Oscurecer' => [
			Checkmark,
			Selector,
			'Oscurece el escenario y los personajes, por si te distraen.',
			NOT_FORCED
		],
		'Tipo' => [
			'UI',
			Selector,
			'Escoge si quieres el filtro de opacidad detras del UI o de las notas.',
			NOT_FORCED,
			['UI', 'Notas']
		],
		'Contador' => [
			'No',
			Selector,
			'Escoge si quieres mostrar tus ratings, y en donde los quieres.',
			NOT_FORCED,
			['No', 'Izquierda', 'Derecha']
		],
		'Mostrar Precision' => [true, Checkmark, 'Muestra tu precision en la barra de informacion.', NOT_FORCED],
		'Deshabilitar Suavizado' => [
			false,
			Checkmark,
			'Deshabilita el suavizado de imagenes. Por si tienes problemas con FPS.',
			NOT_FORCED
		],
		'Movimiento con Notas' => [
			true,
			Checkmark,
			'Las notas moveran un poco la camara al ser presionadas.',
			NOT_FORCED
		],
		'Sin Note Splashes' => [
			false,
			Checkmark,
			'Deshabilita los note splashes, por si te distraen.',
			NOT_FORCED
		],
		// custom ones lol
		'Offset' => [Checkmark, 3],
		'Filtro' => [
			'nada',
			Selector,
			'Escoge un filtro de daltonismo.',
			NOT_FORCED,
			['nada', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		'Clip Style' => ['FNF', Selector, "Escoge como quieres las notas mantenidas; StepMania: debajo del receptor; FNF: encima del receptor", NOT_FORCED, 
			['StepMania', 'FNF']],
		'UI Skin' => ['forever', Selector, 'Escoge una skin para los ratings, combos, etc.', NOT_FORCED, ''],
		'Note Skin' => ['default', Selector, 'puto el que lo lea', NOT_FORCED, ''],
		'Limite de FPS' => [120, Selector, 'Establece un limite de FPS.', NOT_FORCED, ['']],
		'Flechas Opacas' => [false, Checkmark, "Vuelve los receptores de flechas opacos.", NOT_FORCED],
		'Holds Opacas' => [false, Checkmark, "Hace la linea de las notas mantenidas opaca.", NOT_FORCED],
		'Ghost Tapping' => [
			true,
			Checkmark,
			"Activa el Ghost Tapping, no recibiras fallos por presionar notas que no estaban ahi.",
			NOT_FORCED
		],
		'Notas centradas' => [false, Checkmark, "Centra tus notas, y deshabilita las notas del oponente."],
		'Custom Titlescreen' => [
			false,
			Checkmark,
			"MOTOR PARA SIEMPRE lesfaquin go",
			FORCED
		],
		'Dialogo' => [
			'historia',
			Selector,
			'Decide cuando se mostraran los dialogos.',
			NOT_FORCED,
			['nunca', 'historia', 'siempre']
		],
		'Fixed Judgements' => [
			false,
			Checkmark,
			"Pone los ratings en la camara y no en el escenario para que sean mas faciles de leer.", 
			NOT_FORCED
		],
		'Simply Judgements' => [
			true,
			Checkmark,
			"Simplifica las animaciones de los ratings, mostrando solo uno a la vez",
			NOT_FORCED
		],
		'fpStory' => [
			true,
			Checkmark,
			"controlador del menu de freeplay",
			NOT_FORCED
		],
		'asfUnlock' => [
			false,
			Checkmark,
			"mostrar asf si esta desbloqueado",
			NOT_FORCED
		]


	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var gameControls:Map<String, Dynamic> = [
		'UP' => [[FlxKey.UP, W], 0],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'LEFT' => [[FlxKey.LEFT, A], 2],
		'RIGHT' => [[FlxKey.RIGHT, D], 3],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 5],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 6],
		'PAUSE' => [[FlxKey.ENTER, P], 7],
		'RESET' => [[R, null], 8],
		'UI_UP' => [[FlxKey.UP, W], 10],
		'UI_DOWN' => [[FlxKey.DOWN, S], 11],
		'UI_LEFT' => [[FlxKey.LEFT, A], 12],
		'UI_RIGHT' => [[FlxKey.RIGHT, D], 13]
	];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];

	override public function create():Void
	{
		FlxG.save.bind('foreverengine-options');
		Highscore.load();

		loadSettings();
		loadControls();

		#if !html5
		Main.updateFramerate(trueSettings.get("Limite de FPS"));
		#end

		// apply saved filters
		FlxG.game.setFilters(filters);

		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
		FlxGraphic.defaultPersist = true; // make sure we control all of the memory
		
		// volumen epico
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		/*if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;*/
		FlxG.save.flush();

		Main.switchState(this, new TitleState());
	}

	public static function loadSettings():Void
	{
		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null && gameSettings.get(singularSetting)[3] != FORCED)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		// lemme fix that for you
		if (!Std.isOfType(trueSettings.get("Limite de FPS"), Int)
			|| trueSettings.get("Limite de FPS") < 30
			|| trueSettings.get("Limite de FPS") > 360)
			trueSettings.set("Limite de FPS", 30);

		if (!Std.isOfType(trueSettings.get("Oscurecer"), Int)
			|| trueSettings.get("Oscurecer") < 0
			|| trueSettings.get("Oscurecer") > 100)
			trueSettings.set("Oscurecer", 100);

		// 'hardcoded' ui skins
		gameSettings.get("UI Skin")[4] = CoolUtil.returnAssetsLibrary('UI');
		if (!gameSettings.get("UI Skin")[4].contains(trueSettings.get("UI Skin")))
			trueSettings.set("UI Skin", 'default');
		gameSettings.get("Note Skin")[4] = CoolUtil.returnAssetsLibrary('noteskins/notes');
		if (!gameSettings.get("Note Skin")[4].contains(trueSettings.get("Note Skin")))
			trueSettings.set("Note Skin", 'default');

		saveSettings();

		updateAll();
	}

	public static function loadControls():Void
	{
		if ((FlxG.save.data.gameControls != null) && (Lambda.count(FlxG.save.data.gameControls) == Lambda.count(gameControls)))
			gameControls = FlxG.save.data.gameControls;

		saveControls();
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.data.gameControls = gameControls;
		FlxG.save.flush();
	}

	public static function updateAll()
	{
		InfoHud.updateDisplayInfo(trueSettings.get('Mostrar FPS'), false, trueSettings.get('Contador de Memoria'));

		#if !html5
		Main.updateFramerate(trueSettings.get("Limite de FPS"));
		#end

		// modo oscuro
		#if windows
		Windows.setDarkMode('Vs. CDD Forever', trueSettings.get('Ventana Oscura'));
		#end

		///*
		filters = [];
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filtro');
		if (gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}

		FlxG.game.setFilters(filters);
		// */
	}
}
