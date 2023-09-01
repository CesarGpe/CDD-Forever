package meta.data.dependency;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import meta.data.dependency.LoadingScreen;

class FNFUIState extends FlxUIState
{
	override function create()
	{
		// state stuffs
		if (!FlxTransitionableState.skipNextTransOut)
		{
			if (Main.onLoadingScreen)
				openSubState(new LoadingScreen(0.5, true, LoadingScreen.fontUsed));
			else
				openSubState(new FNFTransition(0.5, true));
		}
	
		super.create();
	}
}
