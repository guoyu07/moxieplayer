package mxi.player
{
	import flash.events.Event;
	
	public class ControlsEvent extends Event
	{
		public static const ASSETS_READY:String = 'assetsready';
		public static const PLAY_CLICK:String = 'playclick';
		public static const PAUSE_CLICK:String = 'pauseclick';
		public static const PROGRESS_CLICK:String = 'progressclick';
		public static const VOLUME_CHANGE:String = 'volumechange';
		public static const VOLUMEUP_CLICK:String = 'volumeupclick';
		public static const VOLUMEDOWN_CLICK:String = 'volumedownclick';
		public static const FULLSCREEN_CLICK:String = 'fullscreenclick';
		public static const NORMSCREEN_CLICK:String = 'normscreenclick';
		
		public var data:*;
		
		public function ControlsEvent(type:String, data:* = false)
		{
			this.data = data;
			super(type, false, false);
		}
	}
}