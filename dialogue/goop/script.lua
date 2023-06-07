local gameOverWindow = false;
local song = true;
local allowCountdown = false
local canEnd = false;
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then
		setProperty('inCutscene', true);
		setProperty('camGame.zoom', 0.65);
		runTimer('startZoom', 0.5);
		runTimer('startDialogue', 2.75);
		allowCountdown = true;
		makeLuaSprite('blackTransition', nil, -500, -400);
		makeGraphic('blackTransition', screenWidth * 2, screenHeight * 2, '000000')
		addLuaSprite('blackTransition', true);
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'conversation');
	elseif tag == 'startEndDialogue' then
		startDialogue('dialogue1', 'none');
	elseif tag == 'startZoom' then
		doTweenZoom('camGameZoomTwn', 'camGame', getProperty('defaultCamZoom'), 2, 'quadInOut');
		doTweenAlpha('blackTransitionTwn', 'blackTransition', 0, 2, 'sineOut');
	end
end

function onUpdate()
	if song then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: Goop')
	end
	
	if gameOverWindow then
		setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Vs. CDD")
	end
end

function onEndSong()
	if not canEnd and isStoryMode then
		setProperty('inCutscene', true);
		runTimer('startEndDialogue', 0.8)
		canEnd = true
		return Function_Stop;
	end
   
	if not canEnd then
		setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Vs. CDD")
		song = false;
	end
	
   return Function_Continue;
end

function onGameOver()
	gameOverWindow = true;
	song = false;
end