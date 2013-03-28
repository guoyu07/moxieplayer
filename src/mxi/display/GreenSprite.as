/*
...
If the listener was registered for both the capture phase and the target and bubbling phases, two calls to removeEventListener() 
are required to remove both: one call with useCapture set to true, and another call with useCapture set to false.

http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/IEventDispatcher.html#removeEventListener()
*/

package mxi.display
{
	import flash.display.Sprite;

	public class GreenSprite extends Sprite
	{
		protected var events:Array = [];
		
		override public function addEventListener(type:String, callback:Function, useCapture:Boolean = false, priority:int = 0, useWeak:Boolean = false) : void
		{
			events.push({
				type: type,
				callback: callback
			});
			
			/* we pass only required params for simplicity of removal operation, if you need to use other params
			you will need something more intricate then this one */
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