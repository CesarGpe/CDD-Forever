package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import meta.subState.OptionsSubstate;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	var categoryMap:Map<String, Dynamic>;
	var activeSubgroup:FlxTypedGroup<Alphabet>;
	var attachments:FlxTypedGroup<FlxBasic>;

	var sideSelection = 0;
	var sideSelectin:Bool = true;
	var chooseText:FlxText;
	var sideButtons:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var grpBoxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var curSelection = 0;
	var curSelectedScript:Void->Void;
	var curCategory:String;

	var infoText:FlxText;
	var finalText:String = '';
	var textValue:String = '';
	var infoTimer:FlxTimer;
	var controlMockup:FlxSprite;

	var lockedMovement:Bool = false;
	final boxWidth = 285;

	override public function create():Void
	{
		super.create();

		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */

		// NOTE : Make sure to check Init.hx if you are trying to add options.

		#if !html5
		Discord.changePresence('En los Menús:', 'Menú de Opciones');
		#end

		categoryMap = [
			'main' => [
				[
					['', null],
					['Preferencias', null],
					['Gameplay', callNewGroup],
					['Miscelaneo', callNewGroup],
					['', null],
					['Apariencia', null],
					['Visuales', callNewGroup],
					['Notas', callNewGroup],
					['Accesibilidad', callNewGroup],
					['', null],
					['Controles', openControlmenu]
				]
			],
			'Gameplay' => [
				[
					['Downscroll', getFromOption],
					['Notas centradas', getFromOption],
					['Ghost Tapping', getFromOption],
					['Mostrar Precision', getFromOption],
					['Dialogo', getFromOption]
				]
			],
			'Miscelaneo' => [
				[
					['Limite de FPS', getFromOption],
					['Mostrar FPS', getFromOption],
					['Contador de Memoria', getFromOption],
					['Modo Debug', getFromOption]
				]
			],
			'Visuales' => [
				[
					['Ventana Oscura', getFromOption],
					['UI Skin', getFromOption],
					['Fixed Judgements', getFromOption],
					['Simply Judgements', getFromOption],
					['Contador', getFromOption]
				]
			],
			'Notas' => [
				[
					['Movimiento con Notas', getFromOption],
					['Note Splashes', getFromOption],
					['Flechas Opacas', getFromOption],
					['Holds Opacas', getFromOption]
				]
			],
			'Accesibilidad' => [
				[
					['Filtro', getFromOption],
					['Antialiasing', getFromOption],
					['Movimiento Reducido', getFromOption]
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xff313338);
		bg.screenCenter();
		add(bg);

		var buttonsBG = new FlxSprite();
		buttonsBG.makeGraphic(328, FlxG.height, 0xff2b2d31);
		add(buttonsBG);

		infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		controlMockup = new FlxSprite(328, 0);
		controlMockup.loadGraphic(Paths.image('menus/options/controls'));
		controlMockup.visible = false;
		add(controlMockup);

		add(grpBoxes);
		add(sideButtons);

		createSideBar('main');
		selectOption(curSelection);

		loadSubgroup('Gameplay');
		loadSubgroup('Miscelaneo');
		loadSubgroup('Visuales');
		loadSubgroup('Notas');
		loadSubgroup('Accesibilidad');
		goBackToSide();
	}

	function createSideBar(subgroupName:String)
	{
		var j = 0;
		for (i in 0...categoryMap.get(subgroupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(subgroupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(subgroupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:FlxText = new FlxText(40, 25, 250, categoryMap.get(subgroupName)[0][i][0]);
				if (categoryMap.get(subgroupName)[0][i][1] == null)
				{
					thisOption.setFormat(Paths.font("unisans.otf"), 30, 0xff8b8d92, LEFT);
					thisOption.updateHitbox();
					thisOption.y += ((thisOption.height + 25) * i);
					thisOption.antialiasing = true;
					add(thisOption);
				}
				else
				{
					thisOption.setFormat(Paths.font("whitneymedium.otf"), 30, FlxColor.WHITE, LEFT);
					thisOption.updateHitbox();
					thisOption.y += ((thisOption.height + 20) * i);
					thisOption.alpha = 0.6;
					thisOption.antialiasing = true;
					thisOption.ID = j;
					sideButtons.add(thisOption);

					var box:FlxSprite = new FlxSprite(20, thisOption.y - 7);
					// box.y += ((thisOption.height + 30) * i) + 0;
					box.makeGraphic(boxWidth, 55, 0xff3f4248);
					box.ID = j;
					grpBoxes.add(box);

					j++;
				}
			}
		}
	}

	var currentAttachmentMap:Map<Alphabet, Dynamic>;

	function loadSubgroup(subgroupName:String)
	{
		// unlock the movement
		lockedMovement = false;

		// lol we wanna kill infotext so it goes over checkmarks later
		if (infoText != null)
			remove(infoText);

		// kill previous stuff
		removeActiveSubgroup();

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		// re-add
		add(infoText);
		regenInfoText();

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);
			activeSubgroup.members[i].targetY = (i - curSelection) / 2;
			activeSubgroup.members[i].xTo = 200 + ((i - curSelection) * 25);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null)
			{
				activeSubgroup.members[i].alpha = 1;
				activeSubgroup.members[i].xTo += Std.int((FlxG.width / 2) - ((activeSubgroup.members[i].text.length / 2) * 40)) - 200;
			}
		}

		// move the attachments if there are any
		for (setting in currentAttachmentMap.keys())
		{
			if ((setting != null) && (currentAttachmentMap.get(setting) != null))
			{
				var thisAttachment = currentAttachmentMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}

		// reset the selection
		if (sideSelectin)
		{
			curSelection = sideSelection;
			infoText.visible = false;
			resetSideItem();
		}
		else
		{
			curSelection = 0;
			infoText.visible = true;
			selectOption(curSelection);
		}
	}

	function selectOption(newSelection:Int, playSound:Bool = true)
	{
		if ((newSelection != curSelection) && (playSound))
			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		if (sideSelectin)
		{
			// updates to that new selection
			curSelection = newSelection;

			// wrap the current selection
			if (curSelection < 0)
				curSelection = sideButtons.length - 1;
			else if (curSelection >= sideButtons.length)
				curSelection = 0;

			// update items lol
			for (item in grpBoxes.members)
			{
				if (item.ID == curSelection)
					item.visible = true;
				else
					item.visible = false;
			}
			for (item in sideButtons.members)
			{
				if (item.ID == curSelection)
					item.alpha = 1;
				else
					item.alpha = 0.6;
			}
			sideSelection = curSelection;
			curSelectedScript = callFromSide;

			if (sideButtons.members[curSelection].text == 'Controles')
			{
				controlMockup.visible = true;
				removeActiveSubgroup();
			}
			else
			{
				controlMockup.visible = false;
				loadSubgroup(sideButtons.members[curSelection].text);
			}
		}
		else
		{
			// direction increment finder
			var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

			// updates to that new selection
			curSelection = newSelection;

			// wrap the current selection
			if (curSelection < 0)
				curSelection = activeSubgroup.length - 1;
			else if (curSelection >= activeSubgroup.length)
				curSelection = 0;

			// set the correct group stuffs lol
			for (i in 0...activeSubgroup.length)
			{
				activeSubgroup.members[i].alpha = 0.6;
				if (currentAttachmentMap != null)
					setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);
				activeSubgroup.members[i].targetY = (i - curSelection) / 2;
				activeSubgroup.members[i].xTo = 200 + ((i - curSelection) * 25);

				// check for null members and hardcode the dividers
				if (categoryMap.get(curCategory)[0][i][1] == null)
				{
					activeSubgroup.members[i].alpha = 1;
					activeSubgroup.members[i].xTo += Std.int((FlxG.width / 2) - ((activeSubgroup.members[i].text.length / 2) * 40)) - 200;
				}
			}

			activeSubgroup.members[curSelection].alpha = 1;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 1);

			// what's the script of the current selection?
			for (i in 0...categoryMap.get(curCategory)[0].length)
				if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
					curSelectedScript = categoryMap.get(curCategory)[0][i][1];
			// wow thats a dumb check lmao

			// skip line if the selected script is null (indicates line break)
			if (curSelectedScript == null)
				selectOption(curSelection + directionIncrement, false);
		}

		trace('curSelection: ' + curSelection);
	}

	function setAttachmentAlpha(attachment:FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// just uses my outdated code for the main menu state where I wanted to implement
		// hold scrolling but I couldnt because I'm dumb and lazy
		if (!lockedMovement)
		{
			// check for the current selection
			if (curSelectedScript != null)
				curSelectedScript();

			updateSelections();
		}

		if (!sideSelectin)
		{
			if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
			{
				// lol had to set this or else itd tell me expected }
				var currentSetting = Init.gameSettings.get(activeSubgroup.members[curSelection].text);
				var textValue = currentSetting[2];
				if (textValue == null)
					textValue = "";

				if (finalText != textValue)
				{
					// trace('call??');
					// trace(textValue);
					regenInfoText();

					var textSplit = [];
					finalText = textValue;
					textSplit = finalText.split("");

					var loopTimes = 0;
					infoTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
					{
						//
						infoText.text += textSplit[loopTimes];
						infoText.screenCenter(X);
						infoText.x += 164;

						loopTimes++;
					}, textSplit.length);
				}
			}

			// move the attachments if there are any
			for (setting in currentAttachmentMap.keys())
			{
				if ((setting != null) && (currentAttachmentMap.get(setting) != null))
				{
					var thisAttachment = currentAttachmentMap.get(setting);
					thisAttachment.x = setting.x - 100;
					thisAttachment.y = setting.y - 50;
				}
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			if (!sideSelectin)
				goBackToSide();
			else
				Main.switchState(this, new MainMenuState());
		}
	}

	function regenInfoText()
	{
		finalText = '';
		if (infoTimer != null)
			infoTimer.cancel();
		if (infoText != null)
			infoText.text = "";
	}

	function updateSelections()
	{
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if (controlArray.contains(true))
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
							selectOption(curSelection - 1);
						else if (i == 3)
							selectOption(curSelection + 1);
					}
				}
				//
			}
		}
	}

	function returnSubgroup(groupName:String):FlxTypedGroup<Alphabet>
	{
		//
		var newGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(groupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(groupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:Alphabet = new Alphabet(450, 250, categoryMap.get(groupName)[0][i][0], true, false, 0.8);
				//thisOption.screenCenter();
				thisOption.y += (90 * (i - Math.floor(categoryMap.get(groupName)[0].length / 2)));
				thisOption.targetY = i;
				thisOption.disableX = true;
				// hardcoded main so it doesnt have scroll
				//if (groupName != 'main')
				//thisOption.isMenuItem = true;
				thisOption.alpha = 0.6;
				newGroup.add(thisOption);
			}
		}

		return newGroup;
	}

	function returnExtrasMap(alphabetGroup:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic>
	{
		var extrasMap:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, letter.y, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(20, letter.y, letter.text, Init.gameSettings.get(letter.text)[4],
							(letter.text == 'Limite de FPS') ? true : false, (letter.text == 'Filtro') ? true : false, 46, 0.8);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// checkmark basics lol
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('menu/confirmMenu'));
						lockedMovement = true;
						FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							// LMAO THIS IS HUGE
							Init.trueSettings.set(activeSubgroup.members[curSelection].text,
								!Init.trueSettings.get(activeSubgroup.members[curSelection].text));
							updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
								Init.trueSettings.get(activeSubgroup.members[curSelection].text));

							// save the setting
							Init.saveSettings();
							lockedMovement = false;
						});
					}
				case Init.SettingTypes.Selector:
					#if !html5
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);

					if (!controls.UI_LEFT)
						selector.selectorPlay('left');
					if (!controls.UI_RIGHT)
						selector.selectorPlay('right');

					if (controls.UI_RIGHT_P)
						updateSelector(selector, 1);
					else if (controls.UI_LEFT_P)
						updateSelector(selector, -1);
					#end
				default:
					// none
			}
		}
	}

	function updateCheckmark(checkmark:FNFSprite, animation:Bool) {
		if (checkmark != null)
			checkmark.playAnim(Std.string(animation));
	}

	function updateSelector(selector:Selector, updateBy:Int)
	{
		var fps = selector.fpsCap;
		if (fps)
		{
			// bro I dont even know if the engine works in html5 why am I even doing this
			// lazily hardcoded fps cap
			var originalFPS = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 15 * updateBy;
			if (originalFPS + increase < 30)
				increase = 0;
			// high fps cap
			if (originalFPS + increase > 360)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

			originalFPS += increase;
			selector.chosenOptionString = Std.string(originalFPS);
			selector.optionChosen.text = Std.string(originalFPS);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originalFPS);
			Init.saveSettings();
		}
		else if (!fps)
		{ 
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null) {
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.optionChosen.text)
						storedNumber = curOption;
				}
				
				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('menu/scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.trueSettings.set(activeSubgroup.members[curSelection].text, selector.chosenOptionString);
			Init.saveSettings();
		}
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('menu/confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadSubgroup(activeSubgroup.members[curSelection].text);
			});	
		}
	}

	public function callFromSide()
	{
		if (controls.ACCEPT)
		{
			var curButton = sideButtons.members[curSelection].text;
			trace(curButton);

			FlxG.sound.play(Paths.sound('menu/confirmMenu'));
			lockedMovement = true;

			flashSideItem();
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				if (curButton == 'Controles')
					openControlmenu();
				else
				{
					sideSelectin = false;
					loadSubgroup(curButton);
				}
			});
		}
	}

	public function openControlmenu()
	{
		controlMockup.visible = false;
		removeActiveSubgroup();
		openSubState(new OptionsSubstate());
		lockedMovement = false;
	}

	public function exitMenu()
	{
		//
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('menu/confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				Main.switchState(this, new MainMenuState());
				lockedMovement = false;
			});
		}
		//
	}

	public function removeActiveSubgroup()
	{
		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);
	}

	public function goBackToSide()
	{
		sideSelectin = true;
		for (item in grpBoxes.members)
			item.makeGraphic(boxWidth, 55, 0xff3f4248);
		for (item in sideButtons.members)
			item.alpha = 1;

		curSelection = sideSelection;
		selectOption(curSelection);

		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);
		}
	}

	override public function closeSubState()
	{
		//sideSelection = 5;
		goBackToSide();

		super.closeSubState();
	}

	function flashSideItem()
	{
		for (item in grpBoxes.members)
		{
			if (item.ID == curSelection)
			{
				FlxFlicker.flicker(item, 0.5, 0.06 * 2, true, false);
				item.makeGraphic(boxWidth, 55, 0xff35373c);
			}
		}

		for (item in sideButtons.members)
		{
			if (item.ID == curSelection)
			{
				FlxFlicker.flicker(item, 0.5, 0.06 * 2, true, false);
				item.alpha = 0.6;
			}
		}
	}

	function resetSideItem()
	{
		for (item in grpBoxes.members)
		{
			if (item.ID == curSelection)
				item.makeGraphic(boxWidth, 55, 0xff3f4248);
		}

		for (item in sideButtons.members)
		{
			if (item.ID == curSelection)
				item.alpha = 1;
		}
	}
}
