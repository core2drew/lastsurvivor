package 
{
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Settings extends MovieClip
	{
		public static var menuChannel:SoundChannel;
		public static var menuSound:Sound;
		
		public function Settings()
		{
			//SFX Vars
			menuSound = new MenuSound();
			menuChannel = new SoundChannel();
		}
		
		public static function playBGSound (BGMusic:int,currentView:String) {
			if (BGMusic) {
				if (currentView === "Main") {
					menuChannel = menuSound.play(0, 9999);
				}
			}
		}
		
		public static function stopBGSounds ():void { 
			menuChannel.stop();
		}
		
		public static function stopAllSounds ():void {
			SoundMixer.stopAll();
		}
	}
}