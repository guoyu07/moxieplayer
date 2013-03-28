package mxi.display
{
	import flash.utils.Timer;
	
	public class GreenTimer extends Timer
	{
		protected var events:Array = [];
		
		public function GreenTimer(delay:Number, repeatCount:int = 0)
		{
			super(delay, repeatCount);
		}
		
		override public function addEventListener(type:String, callback:Function, useCapture:Boolean = false, priority:int = 0, useWeak:Boolean = false) : void
		{
			events.push({
				type: type,
				callback: callback
			});
			super.addEventListener(type, callback);
		}
		
		
		/* anyone any idea why Flash doesn't have a call like this?.. */
		public function removeAllEvents() : void
		{
			var i:int,
			max:int = events.length; 
			for (i=0; i<max; i++) { 
				removeEventListener(events[i].type, events[i].callback);
			}
			events = [];
		}
		
	}
}