local canEnd = false;
local gameOverWindow = false;
local song = true;
local allowCountdown = false;
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then
		setProperty('inCutscene', true);
		setProperty('camGame.zoom', 0.65);
		runTimer('startZoom', 0.5);
		runTimer('startDialogue', 2.75);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'Conversation');
	elseif tag == 'startEndDialogue' then
		startDialogue('dialogue3', 'none');
	end
end

function onUpdate()
	if song then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: Absolution')
	end
	
	if gameOverWindow then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'ez')
	end
	
	setProperty('iconP2.y', 550);
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

function opponentNoteHit()

	health = getProperty('health')
    if getProperty('health') > 1.10 then
        setProperty('health', health- 0.01);
    end
	
end