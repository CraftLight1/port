package mobile.options;

import options.BaseOptionsMenu;
import options.Option;
#if sys
import sys.io.File;
#end
import mobile.SUtil;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	var externalPaths:Array<String> = SUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.storageType;
	#end
	final hintOptions:Array<String> = ["No Gradient", "No Gradient (Old)", "Gradient", "Hidden"];

	public function new()
	{
		#if android if (externalPaths != null && externalPaths.length > 0 || externalPaths[0] != '') storageTypes = storageTypes.concat(externalPaths); #end
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		var option:Option = new Option('Mobile Controls Opacity',
		'Selects the opacity for the mobile buttons (carefull not to put it at 0 and loose track of your buttons).',
		'mobileCAlpha',
		'percent',
		null);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			virtualPad.alpha = curOption.getValue();
			if (MobileControls.enabled) {
				FlxG.sound.volumeUpKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.muteKeys = [];
			} else {
				FlxG.sound.volumeUpKeys = [FlxKey.PLUS, FlxKey.NUMPADPLUS];
				FlxG.sound.volumeDownKeys = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
			}
		};
		addOption(option);

		#if mobile
		var option:Option = new Option('Allow Phone Screensaver',
		'If checked, the phone will sleep after going inactive for few seconds.\n(The time depends on your phone\'s options)',
		'screensaver',
		'bool',
        false);
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);
		#end

		if (MobileControls.mode == "Hitbox")
		{
			var option:Option = new Option('Hitbox Design',
			'Choose how your hitbox should look like.',
			'hitboxType',
			'string',
			null,
			hintOptions);
			addOption(option);
		}

		#if android
		var option:Option = new Option('Storage Type',
			'Which folder Psych Engine should use?\n(CHANGING THIS MAKES DELETE YOUR OLD FOLDER!!)',
			'storageType',
			'string',
            null,
			storageTypes);
			addOption(option);
		#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.storageType);
	
		var lastStoragePath:String = StorageType.fromStrForce(lastStorageType) + '/';
	
		try
		{
			Sys.command('rm', ['-rf', lastStoragePath]);
		}
		catch (e:haxe.Exception)
			trace('Failed to remove last directory. (${e.message})');
	}
	#end

	override public function destroy() {
		super.destroy();
		#if android
		if (ClientPrefs.storageType != lastStorageType) {
			onStorageChange();
			SUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
			lime.system.System.exit(0);
		}
		#end
	}
}