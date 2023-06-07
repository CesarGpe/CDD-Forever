local allowCountdown = false;
local gameOverWindow = false;
local song = true;
local aguanta = false;
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then
		setProperty('inCutscene', true);
		setProperty('camGame.zoom', 0.65);
		runTimer('startZoom', 0.5);
		runTimer('startDialogue', 2.75);
		allowCountdown = true;
		makeLuaSprite('blackTransition', nil, -500, -400);
		makeGraphic('blackTransition', screenWidth * 2, screenHeight * 2, '000000');
		addLuaSprite('blackTransition', true);
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'conversation');
	elseif tag == 'startZoom' then
		doTweenZoom('camGameZoomTwn', 'camGame', getProperty('defaultCamZoom'), 2, 'quadInOut');
		doTweenAlpha('blackTransitionTwn', 'blackTransition', 0, 2, 'sineOut');
	end
end

function onUpdate()
	if song and not aguanta then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: A.S.F');
	end
	
	if gameOverWindow == true then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Viste Cesar? Le gane.');
	end
	
	if curStep >= 1008 and curStep < 1014 then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'AMLO');
		aguanta = true;
	elseif curStep >= 1014 and curStep < 1020 then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'SIEMPRE');
		aguanta = true;
	elseif curStep > 1020 and curStep < 1035 then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'FIEL!');
		aguanta = true;
	elseif curStep > 1035 then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: A.S.F');
		aguanta = false;
	end
end

function onEndSong()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Vs. CDD");
	song = false;
end

function onGameOver()
	gameOverWindow = true;
	song = false;
	playSound('oucbue', 2);
end

function onCreate()
	setProperty('cameraSpeed', 2.4);
end