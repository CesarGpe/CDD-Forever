local allowCountdown = false
local gameOverWindow = false;
local song = true;
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'Collapse');
	end
end

function onUpdate(elapsed)
	if song then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: Temper')
	end
	
	if gameOverWindow then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'git gud')
	end
	
	setProperty('iconP2.y', 550);
end

function onEndSong()
	if not canEnd then
		setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Vs. CDD")
		song = false;
	end
end

function onGameOver()
	gameOverWindow = true;
	song = false;
end

function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'bfTemper'); --Character json file for the death animation
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx_temper'); --put in mods/sounds/
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameOver'); --put in mods/music/
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'gameOverEnd'); --put in mods/music/
	
	makeAnimatedLuaSprite('hideTimesuckdickUP', 'hideTimeSucksDick', 400, 5);
	makeAnimatedLuaSprite('hideTimesuckdickDOWN', 'hideTimeSucksDick', 400, 680);
	setObjectCamera('hideTimesuckdickUP', 'hud');
	setObjectCamera('hideTimesuckdickDOWN', 'hud');
	addAnimationByPrefix('hideTimesuckdickUP', 'X', 'X', 24, true);
	addAnimationByPrefix('hideTimesuckdickDOWN', 'X', 'X', 24, true);
	scaleObject('hideTimesuckdickUP', 1, 0.4);
	scaleObject('hideTimesuckdickDOWN', 1, 0.4);

	if not downscroll then
		addLuaSprite('hideTimesuckdickUP', true);
	elseif downscroll then
		addLuaSprite('hideTimesuckdickDOWN', true);
	end
end