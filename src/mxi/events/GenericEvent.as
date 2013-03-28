package mxi.events
{
	import flash.events.Event;

	public class GenericEvent extends Event
	{
		public static const DATA:String = 'genericdata';
		
		public function GenericEvent(type:String, action:String, params:Object = {})
		{
			super(type, false, false);
		}
	}
}