local gameOverWindow = false;
local song = true;
local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		allowCountdown = true;
		return Function_Stop;
	end
	setProperty('camZooming', true);
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'Conversation');
	end
end

function onUpdate()
	if song then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: Spring')
	end
	
	if gameOverWindow then
		setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Vs. CDD")
	end
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