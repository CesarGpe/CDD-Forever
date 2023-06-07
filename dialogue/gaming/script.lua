local gameOverWindow = false;
local song = true;
local allowCountdown = false;
local playDialogue = false;
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then
		startVideo('gamingCutscene');
		allowCountdown = true;
		playDialogue = true;
		return Function_Stop;
	elseif playDialogue then
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.25);
		playDialogue = false;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then
		startDialogue('dialogue', 'none');
	end
end

function onUpdate()
	if song then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Vs. CDD: Gaming')
	end
	
	if gameOverWindow then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Destornillador marca Philips de base plastica cubierta con resina epoxica y acabados de franja amarilla punta plana de 1 cm a base de hierro')
	end
end

function onEndSong()
	if not canEnd then
		setPropertyFromClass("openfl.Lib", "application.window.title", 'Destornillador marca Philips de base plastica cubierta con resina epoxica y acabados de franja amarilla punta plana de 1 cm a base de hierro')
		song = false;
	end
end

function onGameOver()
	gameOverWindow = true;
	song = false;
end

function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'bfGiant'); --Character json file for the death animation
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx_expurgation'); --put in mods/sounds/
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameOver'); --put in mods/music/
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'gameOverEnd'); --put in mods/music/
end